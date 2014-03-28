duplexer = require("duplexer2")
merge    = require("multistream-merge").obj
through  = require("through2").obj
clone    = require("./clone")

module.exports = fork = (streams...) ->

  input = through()

  streams.forEach((stream) ->
    input
      .pipe(clone())
      .pipe(stream)
  )
  return duplexer(input, merge(streams...))