$(document).ready ->
  prompt = $('#emailDialog')
  if prompt.length
    new Dialog('Success!', prompt.removeClass('hide'), buttons: false).show()