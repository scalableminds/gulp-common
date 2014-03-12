gulp        = require("gulp")
eventStream = require("event-stream")
util        = require("gulp-util")
plumber     = require("gulp-plumber")
watch       = require("gulp-watch")
through     = require("through2")
duplexer    = require("duplexer2")
multipipe   = require("multipipe")
parallel    = require("concurrent-transform")
merge       = require("multistream-merge")
connect     = require("connect")

os          = require("os")
path        = require("path")
http        = require("http")


handleError = (err) ->
  util.log(util.colors.red("⚠"), err, err.stack)
  util.beep()


logger = ->

  return through.obj((file, enc, done) ->
    util.log(">>", util.colors.yellow(path.relative(process.cwd(), file.path)))
    done(null, file)
    return
  )

clone = ->

  return through.obj(
    (file, enc, done) ->
      done(null, file.clone())
  )


fork = (streams...) ->

  input = through.obj()

  streams.forEach((stream) ->
    input
      .pipe(clone())
      .pipe(stream)
  )
  return duplexer(input, merge.obj(streams...))


parallelize = (transform, concurrency = os.cpus().length) ->

  return parallel(transform, concurrency)


server = (dir, port) ->

  http
    .createServer(
      connect()
        .use(connect.static(dir))
    )
    .listen(port)


buildAndWatch = (key, src, dest, options, streamMaker) ->

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
  options.newer ?= false

  gulp.task("build:#{key}", ->

    stream = streamMaker()
    stream.on("error", handleError)
    return gulp
      .src(src)
      .pipe(logger())
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
        gulp
          .src(src)
          .pipe(plumber())
          .pipe(stream)
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


module.exports = {
  handleError
  buildAndWatch
  server
  logger
  clone
  fork
  parallelize
  pipe : multipipe
}