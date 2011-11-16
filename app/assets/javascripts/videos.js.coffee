$ ->
	itemOpened = 0
	$('.video a.share').click (toggleClick) ->
		itemOpened++
		dropdown = $(this).next('.shareDropdown').toggle()
		button = $(toggleClick.target)
		$(document).bind 'click.' + itemOpened, {ns: itemOpened}, (evt) ->
			target = $(evt.target)
			if !dropdown.has(target).length and button.get(0) != target.get(0)
				dropdown.hide()
				$(document).unbind('.' + evt.data.ns)
	# $('a[data-confirm]').live 'confirm', (e) ->
		# false
		
	$.rails.allowAction = (element) ->
		message = element.data('confirm')
		fire = $.rails.fire
#		if not message return true
		
		if fire(element, 'confirm')
			$('<div/>').html(message).dialog({
				draggable: false,
				resizable: false,
				modal: true,
				title: 'Delete this video',
				closeText: '×',
				buttons: [
					{
						text: 'Yes, kill it',
						click: () -> 
						  $(this).dialog('close')
						  callback = fire(element, 'confirm:complete', [true])
						  if (callback)
						    allowActionOrig = $.rails.allowAction
						    $.rails.allowAction = () -> true
						    element.trigger('click')
						    $.rails.allowAction = allowActionOrig
					},
					{
						text: 'Cancel',
						click: () -> $(this).dialog('close')
					}
				]
			})
		false