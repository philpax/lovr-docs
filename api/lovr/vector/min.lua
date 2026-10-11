return {
  summary = 'Get the component-wise minimum of vectors.',
  description = 'Returns the minimum of each component across one or more vectors.',
  arguments = {
    v = { type = 'vector', description = 'The first vector.' },
    ['...'] = { type = 'vector', description = 'Additional vectors.' }
  },
  returns = {
    result = { type = 'vector', description = 'The component-wise minimum.' }
  },
  variants = {
    { arguments = { 'v', '...' }, returns = { 'result' } }
  },
  related = { 'vector.max' }
}
