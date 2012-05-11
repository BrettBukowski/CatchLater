namespace :assets do
  desc 'Include SnackJS within the bookmarklet module, minify, write to app.min.js'
  task :bookmarklet do
    require 'erb'
    require 'uglifier'
    
    env = ENV['RAILS_ENV'] || 'development'
    javascript_path = File.expand_path('app/assets/javascripts') + '/'
    write_to = (env == 'development') ? javascript_path : (File.expand_path('public/assets') + '/')
    
    # Minify the bookmarklet loader
    IO.write(javascript_path + 'bookmarklet.min.js', 
      Uglifier.compile(IO.read(javascript_path + 'bookmarklet.js'))
    )
    
    # Compile & minify the bookmarklet app
    app = ERB.new(IO.read(javascript_path + 'app.js.erb'))
    # Insert Snack into the bookmarklet app's source
    snack = IO.read(File.expand_path('vendor/assets/javascripts/externals/snack/builds/snack-qwery.js'))
    app = app.result(binding)

    # Minify and write out the whole thing
    IO.write(write_to + 'app.min.js', Uglifier.compile(app))

    if env == 'development'
      IO.write(javascript_path + 'app.debug.js', app)
    end
  end
end