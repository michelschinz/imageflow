m4_include(luminosity.ci)

kernel vec4 threshold(sampler image, float threshold)
{
  vec4 p = unpremultiply(sample(image, samplerCoord(image)));
  float l = luminosity(p);
  return (l < threshold)
    ? vec4(0.0, 0.0, 0.0, p.a)
    : vec4(p.a, p.a, p.a, p.a);
}
