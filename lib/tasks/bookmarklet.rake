namespace :assets do
  desc 'Include SnackJS within the bookmarklet module, minify, write to app.min.js'
  task :bookmarklet do
    require 'erb'
    require 'uglifier'
    
    javascript_path = File.expand_path('app/assets/javascripts') + '/'
    
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
    IO.write(javascript_path + 'app.min.js', Uglifier.compile(app))
  end
end