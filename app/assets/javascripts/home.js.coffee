# = require jquery

$ ->
  return unless $('#home').size()

  container = $('.vid')
  video = $('video')

  if /(iPhone|iPod|Android)/.test(navigator.userAgent)
    background = video.attr('poster')
    video.remove()
    container.css(
      'backgroundImage': "url(#{background})",
      'backgroundRepeat': 'no-repeat'
    )
    return

  # <http://caniuse.com/#search=object-fit>
  if document.createElement('div').style.objectFit != undefined
    container.css('position', 'absolute')
  else
    video
      .prop('width', window.innerWidth * 2)
      .removeProp('height')
      .css('height', 'auto')
