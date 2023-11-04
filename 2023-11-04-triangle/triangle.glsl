// point inside triangle test
// for triangle a, b, c and point p

// 1. https://www.youtube.com/watch?app=desktop&v=HYAgJN3x4GA
// tl;dr; convert point from standard basis to basis (c - a, b - a)
// then check that the vectors is positive and no longer than 1 (by their sum)
// video say's it's supposedly very computationally effective

// 2. https://nerdparadise.com/math/pointinatriangle
// define cross product of (sa - p, sa - sb) for each consecutive triangle points
// * cross product gives you the area two vectors make in their vector plane
// * if it's negative, then the plane is being created on the "other side", so it's negative
// then check that all cross products are positive, so they're on the same side of all sides


float sdTriangle(in vec2 p1, in vec2 p2, in vec2 p3, in vec2 p)
{
  vec2 e0 = p2 - p1;  vec2 e1 = p3 - p2;  vec2 e2 = p1 - p3;
  vec2 v0 = p - p1;   vec2 v1 = p - p2;   vec2 v2 = p - p3;

  vec3 c0 = cross(vec3(p1 - p3, 0.), vec3(p - p1, 0.));
  vec3 c1 = vec3(p - p1, 0.);
  vec3 c2 = vec3(p - p1, 0.);

  float d = min(min(v0.x*e0.y-v0.y*e0.x, v1.x*e1.y-v1.y*e1.x), v2.x*e2.y-v2.y*e2.x);
  //float d = v0.x*e0.y-v0.y*e0.x;

  return clamp(0., 1., d);
}

vec4 triangle(in vec2 p1, in vec2 p2, in vec2 p3, in vec2 pos
    ,in vec4 col, in vec4 fillColor, in vec4 frameColor
    ,in float frameSize)
{
  float d = sdTriangle(p1, p2, p3, pos);
  return smoothstep(col, fillColor, vec4(d));
}

vec2 uv, mp;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  uv = (2.0 * fragCoord.xy-iResolution.xy) / iResolution.y;
  // uv = fract(2.5 * uv - vec2(0)) * 3. + vec2(-1.5); // if u vant meni triangle
  vec4 col = vec4(0, 0, 0, 1.0);

  vec4 fill =  vec4(0.3, 0.6, 0.9, 0.5);

  float rd = 3.141 * 2.;
  vec2 v = vec2(0, rd / 4.0);
  float t = (rd + iTime) / 3.0;
  vec2 p1 = cos(v + t * 0.);
  vec2 p2 = cos(v + t * 1.);
  vec2 p3 = cos(v + t * 2.);

  col = triangle(p1, p2, p3, uv, col, fill, vec4(0.), 0.);

  fragColor = col;
}
