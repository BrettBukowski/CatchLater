$ ->
	# Don't run on non-video pages
	return if $('.videos')
  $(window).sausage({page: '.video'
  , content: (i, page) ->
   '<span class="sausage-span">' + (i + 1) + ". " + page.find('.date').html() + '</span>'
  })
  every = (milliseconds, callback) => setInterval callback, milliseconds
  nearBottom = () ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 300
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
            $(window).sausage('draw')
            loading = false
          else
            clearInterval(checkPage)
      })