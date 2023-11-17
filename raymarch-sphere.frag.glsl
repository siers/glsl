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

float sdSphere(vec3 p, vec3 offset, float radius) {
  return length(offset - p) - radius;
}

float sdf(vec3 uv) {
  float sdf = 1000., p, n = 4., c = 1.5, t, d;

  for (int i; float(i) < n; i++) {
    p = float(i) / n;
    d = p * 0.15; // * 1.0 to make them equidistant
    t = (iTime / 4. + d * c) / c * radian;
    vec3 center = vec3(0, 0, 5.) + vec3(cos(t) * 2., sin(t * 2.), 0);
    sdf = min(sdf, sdSphere(uv, center, 0.4));
  }

  return sdf;//min(sdSphere(uv, center1, r), sdSphere(uv, center2, r));
}

float sdfLight(vec3 uv, vec3 light) {
  float e = 0.01;
  vec3 normal;
  normal.x = sdf(uv + vec3(e, 0, 0)) - sdf(uv + vec3(-e, 0, 0));
  normal.y = sdf(uv + vec3(0, e, 0)) - sdf(uv + vec3(0, -e, 0));
  normal.z = sdf(uv + vec3(0, 0, e)) - sdf(uv + vec3(0, 0, -e));
  return clamp(dot(normalize(light - uv), normalize(normal)), 0., 1.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  vec3 uv = normalize(vec3(2.0 * (fragCoord.xy - iResolution.xy / 2.) / iResolution.y, 3.));
  vec3 light = vec3(0, 0, 3.5);

  float d = 100., b = 100., esc = 10.;

  for (int i = 0; i < 100; i++) {
    d = sdf(uv);
    uv += normalize(uv) * d * 0.5;

    if (d > esc) break;
  }

  vec4 red = vec4(0.92, 0.13, 0.07, 0);
  vec4 white = vec4(1);
  vec4 background = vec4(251, 219, 255, 0) / 255.0 / 3. * 0.;

  fragColor = d > esc ? background : mix(red, (red + white * 2.) / 3., sdfLight(uv, light));
}
