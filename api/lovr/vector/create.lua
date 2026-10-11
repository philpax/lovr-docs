return {
  summary = 'Pack numbers into a vector.',
  description = 'Packs numbers into a vector.  This is an alias of `vector.pack`.',
  arguments = {
    x = { type = 'number', description = 'The x component.' },
    y = { type = 'number', description = 'The y component.' },
    z = { type = 'number', default = '0', description = 'The z component.' },
    n = { type = 'number', description = 'A number to assign to all three components.' }
  },
  returns = {
    v = { type = 'vector', description = 'The new vector.' }
  },
  variants = {
    { arguments = { 'x', 'y', 'z' }, returns = { 'v' } },
    { arguments = { 'n' }, returns = { 'v' } }
  },
  related = { 'vector.pack' }
}
