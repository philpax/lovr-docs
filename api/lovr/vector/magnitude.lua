return {
  summary = 'Get the length of a vector.',
  description = 'Returns the length of a vector.  This is an alias of `vector.length`.',
  arguments = {
    v = { type = 'vector', description = 'The vector.' }
  },
  returns = {
    length = { type = 'number', description = 'The vector length.' }
  },
  variants = {
    { arguments = { 'v' }, returns = { 'length' } }
  },
  related = { 'vector.length' }
}
