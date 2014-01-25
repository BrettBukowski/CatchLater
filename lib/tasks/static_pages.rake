require 'fileutils'

namespace :assets do
  desc 'Moves static, compiled html pages from /public/assets to /public'
  task :static_pages => [:precompile] do
    Dir.glob("#{Rails.public_path}/assets/*.html") do |file|
      name = file.match(/([a-zA-Z0-9]*)-/)[1] + ".html"
      FileUtils.cp file, "#{Rails.public_path}/#{name}"
    end
  end
end