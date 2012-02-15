$ ->
  # Don't run on non-video pages
  return if not $('.videos').length

  every = (milliseconds, callback) => setInterval callback, milliseconds
  nearBottom = () ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 600
  page = 1
  loading = false
  infiniteScroll = every 200, () ->
    if not loading and nearBottom()
      loading = true
      $('.queue').append($('<div id="loading">Loading...</div>'))
      page++
      $.ajax(window.location.pathname + (window.location.search || '?') + "&page=#{ page }", {
        dataType: 'script',
        complete: (resp) ->
          if resp.responseText
            $('#loading').replaceWith("<div class='page' data-page='#{ page }'>#{ resp.responseText }</div>")
            affixTags($(".page[data-page='#{ page }'] .video .tagEntry"))
            loading = false
          else
            clearInterval(infiniteScroll)
            $('#loading').remove()
      })
      
  goUpDiv = $('<div class="hide" id="up">Go back up ↑</div>').click () ->
    $('body').animate({scrollTop: 0}, 500)
  $(document.body).append(goUpDiv)
  goBackUp = every 200, () ->
    if $(window).scrollTop() > $(window).height()
      goUpDiv.removeClass('hide')
    else
      goUpDiv.addClass('hide')
      
      $(document).keypress (e) ->
        return unless e.target.tagName.toLowerCase() == 'body' and (e.which == 107 or e.which == 106)
        debugger;