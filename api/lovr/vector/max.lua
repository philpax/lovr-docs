return {
  summary = 'Get the component-wise maximum of vectors.',
  description = 'Returns the maximum of each component across one or more vectors.',
  arguments = {
    v = { type = 'vector', description = 'The first vector.' },
    ['...'] = { type = 'vector', description = 'Additional vectors.' }
  },
  returns = {
    result = { type = 'vector', description = 'The component-wise maximum.' }
  },
  variants = {
    { arguments = { 'v', '...' }, returns = { 'result' } }
  },
  related = { 'vector.min' }
}
