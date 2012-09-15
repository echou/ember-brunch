fs   = require 'fs'
path = require 'path'

# See docs at http://brunch.readthedocs.org/en/latest/config.html.

exports.config =

    files:
        javascripts:
            defaultExtension: 'js'
            joinTo:
                'app.js': /^app/
                'vendor.js': /^vendor/
            order:
                before: [
                    'vendor/scripts/jquery-1.8.1.min.js'
                    'vendor/scripts/handlebars-1.0.0.beta.6.js'
                    'vendor/scripts/ember-1.0.pre.min.js'
                    'vendor/scripts/bootstrap-2.1.1.min.js'
                    'vendor/scripts/moment-1.7.0.min.js'
                ]
        stylesheets:
            defaultExtension: 'css'
            joinTo: 'app.css'
            order:
                before: [
                    'vendor/styles/bootstrap.min.css'
                    'vendor/styles/font-awesome.css'
                ]
        templates:
            precompile: true
            defaultExtension: 'hbs'
            joinTo:
                'app.js' : /^app/

    server:
        port: 3333
        base: '/'
        run: yes