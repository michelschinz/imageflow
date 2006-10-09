kernel vec4 opacity(sampler image, float alpha)
{
  vec4 p = unpremultiply(sample(image, samplerCoord(image)));
  return premultiply(vec4(p.r,p.g,p.b,p.a * alpha));
}
