return {
  summary = 'Round vector components up.',
  description = 'Returns a vector with each component rounded up to the nearest integer.',
  arguments = {
    v = { type = 'vector', description = 'The vector.' }
  },
  returns = {
    result = { type = 'vector', description = 'The rounded vector.' }
  },
  variants = {
    { arguments = { 'v' }, returns = { 'result' } }
  }
}
