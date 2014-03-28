through  = require("through2").obj
util     = require("gulp-util")
path     = require("path")
filesize = require("filesize")

module.exports = logger = ->

  return through((file, enc, done) ->
    util.log(
      ">>"
      util.colors.yellow(path.relative(process.cwd(), file.path))
      util.colors.grey("(#{filesize(file.contents.length, round : 1)})")
    )
    done(null, file)
    return
  )