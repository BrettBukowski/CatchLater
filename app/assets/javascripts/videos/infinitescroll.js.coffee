$ ->
  every = (milliseconds, callback) => setInterval callback, milliseconds
  nearBottom = () ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 200
  page = 1
  loading = false
  checkPage = every 500, () ->
    if not loading and nearBottom()
      loading = true
      $('.queue').append($('<div id="loading">Loading...</div>'))
      page++
      $.ajax(window.location.pathname + '?page=' + page, {
        dataType: 'script',
        complete: (resp) ->
          if resp.responseText
            $('#loading').replaceWith(resp.responseText)
            loading = false
          else
            clearInterval(checkPage)
      })