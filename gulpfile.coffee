gulp = require 'gulp'
sass = require 'gulp-ruby-sass'
combiner = require 'stream-combiner2'
sourcemaps = require 'gulp-sourcemaps'
autoprefixer = require 'gulp-autoprefixer'
minifycss = require 'gulp-minify-css'
jshint = require 'gulp-jshint'
uglify = require 'gulp-uglify'
imagemin = require 'gulp-imagemin'
rename = require 'gulp-rename'
concat = require 'gulp-concat'
notify = require 'gulp-notify'
cache = require 'gulp-cache'
connect = require 'gulp-connect'
livereload = require 'gulp-livereload'
del = require 'del'

gulp.task 'default', ['clean'], ->
  gulp.start 'styles', 'scripts', 'images', 'copy', 'connect', 'watch'

gulp.task 'connect', ->
  connect.server
    root: 'dist'
    livereload: true
    port: 8081

gulp.task 'watch', ->
  gulp.watch 'src/styles/**/*.scss', ['styles']
  gulp.watch 'src/app/**/*.js', ['scripts']
  gulp.watch 'src/assets/images/**/*', ['images']
  gulp.watch 'src/*.html', ['copy']

  livereload.listen
    port: 35729
    basePath: 'dist/'

  gulp.watch ['dist/**']
    .on 'change', livereload.changed

gulp.task 'styles', ->
  combined = combiner.obj [
    sass 'src/assets/styles', {style: 'expanded'}
    .on 'error', (err)->
      console.log err.message
    .pipe autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
    .pipe gulp.dest('dist/assets/css')
    .pipe rename({ suffix: '.min' })
    .pipe minifycss()
    .pipe gulp.dest('dist/assets/css')
    .pipe notify({ message: 'Styles task complete.'})
  ]

  combined.on 'error', console.error.bind console 

  combined

gulp.task 'scripts', ->
  gulp.src [
    'src/app/**/*.js'
  ]
  .pipe jshint('.jshintrc')
  .pipe jshint.reporter('default')
  .pipe concat('main.js')
  .pipe gulp.dest('dist/assets/js')
  .pipe rename( suffix: '.min' )
  .pipe uglify()
  .pipe gulp.dest('dist/assets/js')
  .pipe notify( message: 'Scripts task complete.' )

gulp.task 'images', ->
  gulp.src 'src/assets/images/**/*'
  .pipe imagemin
    optimizationLevel: 3
    progressive: true
    interlaced: true
  .pipe gulp.dest('dist/assets/images')
  .pipe notify( message: 'Images task complete.' )

gulp.task 'copy', ->
  gulp.src 'src/*.html'
  .pipe gulp.dest('dist')
  .pipe connect.reload()

gulp.task 'clean', (cb)->
  del [
   'dist/assets/css'
   'dist/assets/js'
   'dist/assets/images'
  ], cb



