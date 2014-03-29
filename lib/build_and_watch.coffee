through     = require("through2").obj
plumber     = require("gulp-plumber")
watch       = require("gulp-watch")

logger      = require("./logger")
handleError = require("./handle_error")

module.exports = buildAndWatch = (gulp) ->
  (key, src, dest, options, streamMaker) ->

    if arguments.length == 3
      streamMaker = -> through()
      options = {}

    if arguments.length == 4
      streamMaker = options
      options = {}

    unless key?
      throw new Error("No task key given.")
    unless src?
      throw new Error("No source path given.")
    unless dest?
      throw new Error("No destination path given.")

    options.emitOnGlob ?= true
    options.singleFile ?= false

    gulp.task("build:#{key}", ->

      stream = streamMaker()
      stream.on("error", handleError)
      return gulp
        .src(src)
        .pipe(plumber())
        .pipe(stream)
        .pipe(gulp.dest(dest))
        .pipe(logger())
    )

    gulp.task("watch:#{key}", ->

      stream = streamMaker()
      stream.on("error", handleError)
      if options.singleFile

        if options.emitOnGlob
          _stream = streamMaker()
          _stream.on("error", handleError)
          gulp
            .src(src)
            .pipe(plumber())
            .pipe(_stream)
            .pipe(gulp.dest(dest))
            .pipe(logger())

        return watch(glob : options.watchSrc ? src, emitOnGlob : false, name : "#{key}-watcher", ->
          gulp
            .src(src)
            .pipe(plumber())
            .pipe(stream)
            .pipe(gulp.dest(dest))
            .pipe(logger())
        )
      else
        return watch(glob : options.watchSrc ? src, emitOnGlob : options.emitOnGlob, name : "#{key}-watcher")
          .pipe(plumber())
          .pipe(stream)
          .pipe(gulp.dest(dest))
          .pipe(logger())
    )