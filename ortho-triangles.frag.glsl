// vim: ft=c commentstring=//%s

// point inside triangle test
// for triangle a, b, c and point p

// 1. https://www.youtube.com/watch?app=desktop&v=HYAgJN3x4GA
// tl;dr; convert point from standard basis to basis (c - a, b - a)
// then check that the vector is positive and their sum is not more than 1
// video say's it's supposedly very computationally effective

// 2. https://nerdparadise.com/math/pointinatriangle
// define cross product of (sa - p, sa - sb) for each consecutive triangle points
// * cross(a, b) gives you the normal vector of their plane proportional to the area they make when summed
// * if it's negative, then area was negative, which is why cross product has handedness, which we exploit
// then check that all cross products are positive, so they're on the same side of all sides

// 3. https://codeplea.com/triangular-interpolation
// superficially similar to formula in 1., but arrived from solving a linear system

// clamp(gamma(cross.z))
float f(vec2 a, vec2 b) {
  float area = cross(vec3(a, 0.), vec3(b, 0.)).z;
  float gamma = area; // pow(area, 2.2);
  return clamp(gamma, 0., 1.);
}

vec3 crossProductTriangle(in vec2 p1, in vec2 p2, in vec2 p3, in vec2 p) {
  vec2 e1 = p2 - p1;  vec2 e2 = p3 - p2;  vec2 e3 = p1 - p3;
  vec2 v1 = p - p1;   vec2 v2 = p - p2;   vec2 v3 = p - p3;

  return vec3(f(v1, e1), f(v2, e2), f(v3, e3));
}

vec3 barycentric(in vec2 p1, in vec2 p2, in vec2 p3, in vec2 p) {
  float w1 = ((p2.y-p3.y)*(p.x-p3.x)+(p3.x-p2.x)*(p.y-p3.y)) / ((p2.y-p3.y)*(p1.x-p3.x)+(p3.x-p2.x)*(p1.y-p3.y));
  float w2 = ((p3.y-p1.y)*(p.x-p3.x)+(p1.x-p3.x)*(p.y-p3.y)) / ((p2.y-p3.y)*(p1.x-p3.x)+(p3.x-p2.x)*(p1.y-p3.y));
  return vec3(w1, w2, 1.0 - w1 - w2);
}

vec3 barycentric3(in vec3 p1, in vec3 p2, in vec3 p3, in vec2 p) {
  float w1 = ((p2.y-p3.y)*(p.x-p3.x)+(p3.x-p2.x)*(p.y-p3.y)) / ((p2.y-p3.y)*(p1.x-p3.x)+(p3.x-p2.x)*(p1.y-p3.y));
  float w2 = ((p3.y-p1.y)*(p.x-p3.x)+(p1.x-p3.x)*(p.y-p3.y)) / ((p2.y-p3.y)*(p1.x-p3.x)+(p3.x-p2.x)*(p1.y-p3.y));
  return vec3(p, p1.z * w1 + p2.z * w2 + p3 * (1.0 - w1 - w2));
}

vec3 triangle(in vec2 p1, in vec2 p2, in vec2 p3, in vec2 pos, in vec3 bg)
{
  // vec3 tri = crossProductTriangle(p1, p2, p3, pos);
  vec3 tri = barycentric(p1, p2, p3, pos);
  float d = min(tri.x, min(tri.y, tri.z));

  // copy google colorpicker's rgb in format "r, g, b" and run this
  // ruby -e "puts('  vec3 col = vec3(%s);' % eval('[%s]' % %x{xclip -o}).map{|x| '%0.2f' % (x/255.0) }.join(', '))"
  vec3 col1 = vec3(0.99, 0.35, 0.01);
  vec3 col2 = vec3(0.01, 0.99, 0.45);
  vec3 col3 = vec3(0.72, 0.00, 1.00);

  vec3 inside = col1 * tri.x + col2 * tri.y + col3 * tri.z;
  bg = d > 0. ? inside : bg; // bg reused for "just a color"

  return bg;
}

// fract(f) \in 0..1 -> 0..1 wave
float unitCos(float f) {
  return ((cos(2.0*3.14159*f)+1.0)/2.0);
}

// https://gist.github.com/yiwenl/3f804e80d0930e34a0b33359259b556c
mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

// move point in 3d space, return new screen coordinates
vec3 transform(vec3 p2) {
  vec4 p = vec4(p2, 0.);
  mat4 m = rotationMatrix(vec3(0., 1., 0.), iTime);
  return (m * p).xyz;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv;
  uv = 2.1 * (fragCoord.xy - iResolution.xy / 2.) / iResolution.y;

  if (iMouse.z > 0.) {
    float scale = unitCos(iTime / 3.) * 2.5 + 1.; // 3 is wave speed, 2.5 is wave height
    uv = fract(scale * uv) * 2. + vec2(-1); // loop coordinates for many triangles
  };

  vec3 col = vec3(0, 0, 0);

  float rd = 3.141 * 2.;

  int triCount = 4;
  vec3[3 * 4] tris;

  for (int i = 0; i < triCount; i++) {
    float tTime = iTime + float(i);
    vec2 v = vec2(0, rd / 4.0);
    vec3 p1 = transform(vec3(cos(v + rd * (tTime + 0.) / 3.0), 0.) + vec3(0, 0, 1));
    vec3 p2 = transform(vec3(cos(v + rd * (tTime + 1.) / 3.0), 0.) + vec3(0, 0, 1));
    vec3 p3 = transform(vec3(cos(v + rd * (tTime + 2.) / 3.0), 0.) + vec3(0, 0, 1));
    tris[i * 3] = p1;
    tris[i * 3 + 1] = p2;
    tris[i * 3 + 2] = p3;
  }

  // find top triangle
  int i = -1;
  for (int j = 0; j < triCount; j++) {
    vec3 prevZ = barycentric3(tris[i*3], tris[i*3+1], tris[i*3+2], uv);
    vec3 currentZ = barycentric3(tris[j*3], tris[j*3+1], tris[j*3+2], uv);
    if (i == -1 || prevZ.z < currentZ.z) i = j;
  }
  col += triangle(tris[i * 3].xy, tris[i * 3 + 1].xy, tris[i * 3 + 2].xy, uv, col);
  if (i == -1) col = vec3(0.3);

  fragColor = vec4(col, 0.);
}
