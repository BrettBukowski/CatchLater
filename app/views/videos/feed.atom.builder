atom_feed do |feed|
  feed.title @title
  
  latest = @videos.sort_by(&:created_at).last
  feed.updated(latest && latest.created_at)
  
  @videos.each do |video|
    feed.entry(video) do |entry|
      entry.url video_path(video) 
      entry.title "Video saved " + video.created_at.strftime("%A, %B %Y")
      entry.summary type: 'xhtml' do |xhtml|
        xhtml.iframe src: video.embed_url, width: "500", height: "401"
      end
      entry.author do |author|
        author.name video.user.email
      end
    end
  end
end