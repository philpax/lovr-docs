return {
  tag = 'input',
  summary = 'Get the position and orientation of a hand pose.',
  description = 'Returns the position and angle-axis orientation of a hand pose, or zeroes if the pose is not tracked.',
  arguments = {
    hand = { type = 'string', values = { 'left', 'right' }, description = 'The hand to query.' },
    pose = { type = 'HandPose', default = "'grip'", description = 'The hand pose to query.' }
  },
  returns = {
    x = { type = 'number', description = 'The x position, in meters.' },
    y = { type = 'number', description = 'The y position, in meters.' },
    z = { type = 'number', description = 'The z position, in meters.' },
    angle = { type = 'number', description = 'The rotation angle, in radians.' },
    ax = { type = 'number', description = 'The x component of the rotation axis.' },
    ay = { type = 'number', description = 'The y component of the rotation axis.' },
    az = { type = 'number', description = 'The z component of the rotation axis.' }
  },
  variants = {
    { arguments = { 'hand', 'pose' }, returns = { 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az' } }
  },
  related = { 'lovr.headset.getHandPosition', 'lovr.headset.getHandOrientation', 'HandPose' }
}
