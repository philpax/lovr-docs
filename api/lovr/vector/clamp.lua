return {
  summary = 'Clamp vector components.',
  description = 'Clamps each component between the corresponding minimum and maximum components.',
  arguments = {
    v = { type = 'vector', description = 'The vector to clamp.' },
    min = { type = 'vector', description = 'The minimum components.' },
    max = { type = 'vector', description = 'The maximum components.  Each must be at least the corresponding minimum component.' }
  },
  returns = {
    result = { type = 'vector', description = 'The clamped vector.' }
  },
  variants = {
    { arguments = { 'v', 'min', 'max' }, returns = { 'result' } }
  }
}
