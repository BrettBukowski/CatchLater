module VideosHelper
  def window_open(body, url, attrs = {})
    link_to body, url, attrs.merge({onclick: "window.open('#{url}'); return false;"})
  end
end