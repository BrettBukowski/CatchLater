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

  def equivalent_urls(a_url, b_url)
    URI.split(a_url).slice(1, 8) == URI.split(b_url).slice(1, 8)
  end

  def source_url(url, truncate_size = 20)
    url.gsub(/http(s)?:\/\/(www.)?/, '').truncate(truncate_size)
  end
end