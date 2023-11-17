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

vec3 sphereShift(int i, float n) {
  float p = float(i) / n, c = 1.5;
  float d = p * (n * 0.05); // * 1.0 to make them equidistant
  float t = (iTime / 4. + d * c) / c * radian;
  return vec3(cos(t) * 2., sin(t * 2.), 0);
}

float sdf(vec3 uv) {
  float sdf = 1000., p, n = 5., c = 1.5, t, r = 0.5;
  vec3 center, centerprev;

  for (int i; float(i) < n; i++) {
    vec3 center = vec3(0, 0, 5.) + sphereShift(i, n);
    vec3 center_ = vec3(0, 0, 5.) + sphereShift(i - 1, n);
    sdf = opSmoothUnion(sdf, sdSphere(uv, center, 0.4), (length(center - center_) - r + 0.2));
  }

  return sdf;
}

float sdfDiff(vec3 uv, vec3 diff) {
  return sdf(uv + diff) - sdf(uv - diff);
}

float sdfLight(vec3 uv, vec3 light, float eps) {
  vec3 normal = vec3(sdfDiff(uv, vec3(eps, 0, 0)), sdfDiff(uv, vec3(0, eps, 0)), sdfDiff(uv, vec3(0, 0, eps)));
  return clamp(dot(normalize(light - uv), normalize(normal)), 0., 1.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  vec3 uv = normalize(vec3(2.0 * (fragCoord.xy - iResolution.xy / 2.) / iResolution.y, 3.));
  vec3 light = vec3(0, 0, 3.5) + vec3(cos(iTime), sin(iTime), 0);

  float d = 100., b = 100., esc = 10.;

  for (int i = 0; i < 100; i++) {
    d = sdf(uv);
    uv += normalize(uv) * d * 0.5;

    if (d > esc) break;
  }

  vec4 red = vec4(0.92, 0.13, 0.07, 0);
  vec4 white = vec4(1);
  vec4 background = vec4(251, 219, 255, 0) / 255.0 / 3. * 0.;

  fragColor = d > esc ? background : mix(red, (red + white * 5.) / 6., sdfLight(uv, light, 0.01));
}
