#version 300

precision mediump float;

vec3      iResolution;           // viewport resolution (in pixels)
float     iTime;                 // shader playback time (in seconds)
float     iTimeDelta;            // render time (in seconds)
float     iFrameRate;            // shader frame rate
int       iFrame;                // shader playback frame
float     iChannelTime[4];       // channel playback time (in seconds)
vec3      iChannelResolution[4]; // channel resolution (in pixels)
vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
vec4      iDate;                 // (year, month, day, time in seconds)
float     iSampleRate;           // sound sample rate (i.e., 44100)

float radian = 2. * 3.14159265;

// at the time of writing, I can't rewrite it from memory, but I can imagine why this fn works
float opSmoothUnion( float d1, float d2, float k ) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

float sdSphere(vec3 p, vec3 offset, float radius) {
  return length(offset - p) - radius;
}

vec3 sphereCenter = vec3(0, 0, 5);
float sphereCount = 5.;

vec3 sphereShift(int i, float n) {
  float p = float(i) / n, c = 1.5;
  float d = p * (n * 0.05); // * 1.0 to make them equidistant
  float t = (iTime / 4. + d * c) / c * radian;
  return vec3(cos(t) * 2., sin(t * 2.), 0);
}

float sdf(vec3 uv) {
  float sdf = 1000., n = 5., r = 0.4;

  for (int i; float(i) < n; i++) {
    vec3 center = sphereCenter + sphereShift(i, n);
    vec3 center_ = sphereCenter + sphereShift(i - 1, n);
    sdf = opSmoothUnion(sdf, sdSphere(uv, center, r), (length(center - center_) - r + 0.1));
  }

  return sdf;
}

float sdfDiff(vec3 uv, vec3 diff) {
  return sdf(uv + diff) - sdf(uv - diff);
}

float sdfLight(vec3 uv, vec3 light, float eps) {
  vec3 normal = vec3(sdfDiff(uv, vec3(eps, 0, 0)), sdfDiff(uv, vec3(0, eps, 0)), sdfDiff(uv, vec3(0, 0, eps)));
  float angle = dot(normalize(light - uv), normalize(normal));
  angle = pow((angle + 1.) / 2., 3.) * 2. - 1.;
  return angle;
}

vec4 color(vec3 uv, vec3 light) {
  vec4 red = vec4(0.92, 0.13, 0.07, 0);
  vec4 white = vec4(250, 222, 255, 0) / 255.;
  vec4 dark = vec4(112, 30, 71, 0) / 255.;

  float angle = sdfLight(uv, light, 0.01);
  vec4 color = angle >= 0. ? mix(red, white, angle) : mix(dark, red, 1. + angle);

  return color;
}

vec4 checkerboard(vec3 uv1) {
  vec2 uv = fract(normalize(uv1).xy * 4.) * 2.;
  int bit = (int(uv.x) + int(uv.y)) % 2;
  return mix(vec4(0.2), vec4(0.3), float(bit));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  vec3 uv = normalize(vec3(2.0 * (fragCoord.xy - iResolution.xy / 2.) / iResolution.y, 3.));
  vec3 uvNormal = uv;
  vec3 light = sphereCenter - vec3(0, 0, 0.5) + sphereShift(int(sphereCount) + 2, sphereCount);

  if (iMouse.z > 0.) light = vec3(2.0 * (iMouse.xy - iResolution.xy / 2.) / iResolution.y, 4);

  float i, d, most = 50., esc = 10.;
  for (i = 0.; i < most && (d = sdf(uv)) <= esc; i++) uv += uvNormal * d;

  vec4 background = checkerboard(uv);
  fragColor = i < most ? background : color(uv, light);
}
