module VideosHelper
  def window_open(body, url, attrs = {})
    link_to body, url, attrs.merge({onclick: "window.open('#{url}'); return false;"})
  end
  
  def created_date(date)
    if (date < 5.days.ago)
      date.strftime("%b %e")
    else
      time_ago_in_words(date) + ' ago'
    end
  end
end