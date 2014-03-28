through = require("through2").obj

module.exports = clone = ->

  return through(
    (file, enc, done) ->
      done(null, file.clone())
  )