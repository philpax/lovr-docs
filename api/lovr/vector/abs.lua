return {
  summary = 'Get the absolute value of a vector.',
  description = 'Returns a vector with the absolute value of each component.',
  arguments = {
    v = { type = 'vector', description = 'The vector.' }
  },
  returns = {
    result = { type = 'vector', description = 'The component-wise absolute value.' }
  },
  variants = {
    { arguments = { 'v' }, returns = { 'result' } }
  }
}
