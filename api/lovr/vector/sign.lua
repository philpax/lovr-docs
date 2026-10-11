return {
  summary = 'Get the sign of vector components.',
  description = 'Returns a vector whose components are -1, 0, or 1 according to the sign of each input component.',
  arguments = {
    v = { type = 'vector', description = 'The vector.' }
  },
  returns = {
    result = { type = 'vector', description = 'The component-wise signs.' }
  },
  variants = {
    { arguments = { 'v' }, returns = { 'result' } }
  }
}
