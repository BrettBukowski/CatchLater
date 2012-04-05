$ ->
  # Don't run on non-video pages
  return if not $('.videos .videoList').length
  
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
            $('#loading').remove()
            $('.videoList').append(resp.responseText)
            affixTags($(".video[data-page='#{ page }'] .tagEntry"))
            loading = false
          else
            clearInterval(infiniteScroll)
            $('#loading').remove()
      })