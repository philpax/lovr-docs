return {
  summary = 'Decompress a string or Blob.',
  description = 'Decompresses data, returning a string for string input or a Blob for Blob input.',
  arguments = {
    string = { type = 'string', description = 'The data to decompress.' },
    blob = { type = 'Blob', description = 'The data to decompress.' },
    method = { type = 'CompressionMethod', default = 'nil', description = 'The compression format, or nil to detect the format automatically.' }
  },
  returns = {
    string = { type = 'string', description = 'The decompressed data.' },
    blob = { type = 'Blob', description = 'The decompressed data.' }
  },
  variants = {
    { arguments = { 'string', 'method' }, returns = { 'string' } },
    { arguments = { 'blob', 'method' }, returns = { 'blob' } }
  },
  related = { 'lovr.data.compress', 'CompressionMethod' }
}
