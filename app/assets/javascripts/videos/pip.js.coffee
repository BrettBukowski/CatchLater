$ ->
  $('.videoList').on 'click', '.video a.pip', (e) ->
    e.preventDefault()
    popup = window.open($(this).attr('href'), 'pipWindow', 'height=400,width=600,location=no')
    popup.addEventListener 'DOMContentLoaded', ()->
      popup.scrollTo(40, 200);