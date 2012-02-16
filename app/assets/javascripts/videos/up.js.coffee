(window ? exports).every = (milliseconds, callback) => setInterval callback, milliseconds

goUpDiv = $('<div class="hide" id="up">Go back up ↑</div>').click () ->
  $('body').animate({scrollTop: 0}, 500)
$(document.body).append(goUpDiv)
goBackUp = every 200, () ->
  if $(window).scrollTop() > $(window).height()
    goUpDiv.fadeIn()
  else
    goUpDiv.fadeOut()
