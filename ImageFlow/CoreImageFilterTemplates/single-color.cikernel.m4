kernel vec4 singleColor(sampler image, __color color)
{
  float alpha = sample(image, samplerCoord(image)).a;
  return premultiply(vec4(color.r,color.g,color.b,alpha));
}
