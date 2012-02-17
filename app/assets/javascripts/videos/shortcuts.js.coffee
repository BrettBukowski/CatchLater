getCurrentVideo = () ->
  currentVideo = null
  do (currentVideo) ->
  	$('.video').each () ->
  	  if $(window).scrollTop() <= $(this).offset().top
        currentVideo = this
        false
    $(currentVideo)

$ ->
  $(document).keypress (e) ->
    return unless e.target.tagName.toLowerCase() == 'body' and (e.which == 107 or e.which == 106)
    current = getCurrentVideo()
    sibling = if e.which == 107 then current.prev() else current.next()
    if sibling.length
      $('body').animate({scrollTop: sibling.offset().top}, 200)