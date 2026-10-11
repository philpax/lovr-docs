return {
  tag = 'vectors',
  deprecated = true,
  summary = 'Create a quaternion.',
  description = 'This is a deprecated alias for the callable `quaternion` table. Arguments are raw quaternion components, not angle/axis.',
  arguments = {
    x = { type = 'number', description = 'The x component of the quaternion.' },
    y = { type = 'number', description = 'The y component of the quaternion.' },
    z = { type = 'number', description = 'The z component of the quaternion.' },
    w = { type = 'number', description = 'The w component of the quaternion.' }
  },
  returns = {
    q = {
      type = 'quaternion',
      description = 'The new quaternion.'
    }
  },
  variants = {
    { arguments = { 'x', 'y', 'z', 'w' }, returns = { 'q' } },
    { description = 'Returns the identity quaternion.', arguments = {}, returns = { 'q' } }
  }
}
