$ ->
  # Don't run on non-video pages
  return if not $('.videos').length

  # $(window).sausage({page: '.video'
  # , content: (i, page) ->
   # '<span class="sausage-span">' + (i + 1) + ". " + page.find('.date').html() + '</span>'
  # })
  every = (milliseconds, callback) => setInterval callback, milliseconds
  nearBottom = () ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 600
  page = 1
  loading = false
  checkPage = every 200, () ->
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
            # $(window).sausage('draw')
            loading = false
          else
            clearInterval(checkPage)
            $('#loading').remove()
      })