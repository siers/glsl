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

float sdSphere(vec3 p, vec3 offset, float radius) {
  return length(offset - p) - radius;
}

float sdSphereAngle(vec3 p, vec3 offset, vec3 light, float radius) {
  float angle = dot(normalize(light), normalize(offset - p));
  return angle;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  vec3 uv = normalize(vec3(2.0 * (fragCoord.xy - iResolution.xy / 2.) / iResolution.y, 3.));
  vec3 light = vec3(3);

  float t;
  t = iTime * 1.5;
  vec3 center1 = vec3(0, 0, 5.) + vec3(cos(t)*2., sin(t*2.), 0);
  t = (iTime + 0.5) * 1.5;
  vec3 center2 = vec3(0, 0, 5.) + vec3(cos(t)*2., sin(t*2.), 0);

  float r = 0.4;
  float a = 100., b = 100., esc = 10.;
  vec3 uva = uv, uvb = uv;

  for (int i = 0; i < 100; i++) {
    a = sdSphere(uva, center1, r); uva += normalize(uva) * a * 0.5;
    b = sdSphere(uvb, center2, r); uvb += normalize(uvb) * b * 0.5;

    if (min(a, b) > esc) break;
  }

  vec4 red = vec4(0.92, 0.33, 0.20, 0);
  vec4 white = vec4(1);

  bool first = uvb.z > uva.z;
  float n     = first ? a : b;
  uv          = first ? uva : uvb;
  vec3 center = first ? center1 : center2;

  float angle = sdSphereAngle(uv, center, light, r);
  fragColor = n > esc ? vec4(0) : mix(red, white, angle);
}
