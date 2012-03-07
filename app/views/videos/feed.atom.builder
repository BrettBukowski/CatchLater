atom_feed do |feed|
  feed.title @title
  
  latest = @videos.sort_by(&:created_at).last
  feed.updated(latest && latest.created_at)
  
  @videos.each do |video|
    feed.entry(video) do |entry|
      entry.title "Video saved #{video.created_at}"
      entry.summary type: 'xhtml' do |xhtml|
        xhtml.iframe src: video.embed(false)
      end
      entry.author do |author|
        author.name video.user.email
      end
    end
  end
end