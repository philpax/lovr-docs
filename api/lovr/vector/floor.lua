return {
  summary = 'Round vector components down.',
  description = 'Returns a vector with each component rounded down to the nearest integer.',
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
