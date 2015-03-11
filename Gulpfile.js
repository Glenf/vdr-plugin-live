var gulp = require('gulp'),
    sass = require('gulp-sass'),
    autoprefixer = require('gulp-autoprefixer');

gulp.task('styles', function () {
    gulp.src('css/scss/*.scss')
        .pipe(sass({
            outputStyle : 'compressed'
        }))
        .pipe(autoprefixer())
        .pipe(gulp.dest('css/'));
});


gulp.task('default', ['styles']);
