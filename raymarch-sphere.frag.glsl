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

float sdf(vec3 uv) {
  float t, c = 1.5, r = 0.4;
  t = iTime * c;
  vec3 center1 = vec3(0, 0, 5.) + vec3(cos(t)*2., sin(t*2.), 0);
  t = (iTime + (.8/c)) * c;
  vec3 center2 = vec3(0, 0, 5.) + vec3(cos(t)*2., sin(t*2.), 0);

  return min(sdSphere(uv, center1, r), sdSphere(uv, center2, r));
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
  vec3 light = vec3(0, 0, 4.5);

  float d = 100., b = 100., esc = 10.;

  for (int i = 0; i < 100; i++) {
    d = sdf(uv);
    uv += normalize(uv) * d * 0.5;

    if (d > esc) break;
  }

  vec4 red = vec4(0.92, 0.13, 0.07, 0);
  vec4 white = vec4(1);

  fragColor = d > esc ? vec4(0) : mix(red, white, sdfLight(uv, light));
}
