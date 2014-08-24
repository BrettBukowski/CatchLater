module VideosHelper
  def share_link(label, url)
    link_to url, target: "_blank", title: "Share on #{label.capitalize}" do
      share_icon label
    end
  end

  def share_icon(label)
    raw "<i class='icon-#{label}' aria-hidden='true' role='presentation'></i><span class='screenReaderOnly'>#{label.capitalize}</span>"
  end

  def full_date(date)
    date.strftime("%B %e %Y, %l:%M %p %Z")
  end

  def created_date(date)
    if (date < 5.days.ago)
      date.strftime("%b %e")
    else
      time_ago_in_words(date) + ' ago'
    end
  end

  def equivalent_urls(a_url, b_url)
    URI.split(a_url).slice(1, 8) == URI.split(b_url).slice(1, 8) rescue false
  end

  def source_url(url, truncate_size = 20)
    url.gsub(/http(s)?:\/\/(www.)?/, '').truncate(truncate_size)
  end
end