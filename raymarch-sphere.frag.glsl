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
  return length(p - offset) - radius;
}

float sdSphereAngle(vec3 p, vec3 offset, float radius) {
  return dot(normalize(p), normalize(offset - p));
}

float sdSphereLight(vec3 p, vec3 offset, float radius, vec3 light) {
  // p - offset is sphere's normal
  return max(0., dot(normalize(p - offset), normalize(light - p)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  vec3 uv;
  uv = normalize(vec3(2.0 * (fragCoord.xy - iResolution.xy / 2.) / iResolution.y, 1.0));

  float tc = (cos(iTime * 1.7) + 1.) / 2.;

  float r = 0.25;
  vec3 off1 = vec3(2.2, 1. + -tc * 2., 5.);
  vec3 off2 = vec3(-2.2, -1. + tc * 2., 5.);
  float a, b;

  for (int i = 0; i < 1000; i++) {
    a = sdSphere(uv, off1, r);
    b = sdSphere(uv, off2, r);
    uv *= 0.5 * min(a, b);

    float t = 0.2;
    if (a < t || b < t) break;
  }

  vec3 light = normalize(vec3(0, 2, 0));
  /* vec3 light = normalize(vec3(0.5, 0.5, -2)); */
  vec4 red = vec4(0.92, 0.33, 0.20, 0);
  vec4 orange = vec4(1.00, 0.85, 0.79, 0);
  vec4 white = vec4(1);

  if (a < 3. || b < 3.) { // no idea what this 3. represents
    /* uv = cross(normalize(uv), light); */
    /* fragColor = mix(red, white, pow(max(sdSphereAngle(uv, off1, r),sdSphereAngle(uv, off2, r)), 1.)); */

    /* float angle = max(sdSphereAngle(uv, off1, r),sdSphereAngle(uv, off2, r)); */
    /* float angle = sdSphereLight(uv, off1, r, light); */
    float angle = max(sdSphereLight(uv, off1, r, light), sdSphereLight(uv, off2, r, light));

    fragColor = mix(red, white, angle);
    /* fragColor = mix(red, white, pow(angle, 1.)); */
  } else
    fragColor = vec4(1.00, 0.90, 1.00, 0);
}
