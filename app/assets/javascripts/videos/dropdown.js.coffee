$ ->
  itemOpened = 0
  $('.videoList').on 'click', '.video a.share', (toggleClick) ->
    itemOpened++
    dropdown = $(this).next('.shareDropdown').toggle()
    button = $(toggleClick.target)
    $(document).bind 'click.' + itemOpened, {ns: itemOpened}, (evt) ->
      target = $(evt.target)
      if !dropdown.has(target).length and button.get(0) != target.get(0)
        dropdown.hide()
        $(document).unbind('.' + evt.data.ns)