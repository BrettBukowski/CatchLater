module HomeHelper
  def bookmarklet
    IO.read(File.expand_path('app/assets/javascripts/bookmarklet.min.js'))
  end
end
