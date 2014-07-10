suggestionList = $.map $('.tagList .name'), (i) -> { name: i.innerHTML }

(exports ? this).affixTags = (elements) ->
	select = elements.selectize(
		plugins: ['remove_button'],
		create: true,
		openOnFocus: false,
		selectOnTab: true,
		options: suggestionList,
		valueField: 'name',
		labelField: 'name',
		searchField: 'name',
	)
	select.on 'change', (e) ->
		value = $(this).val()
		$.post($(e.target).closest('form').attr('action'), {
			tags: value,
		})
		$(this).selectize()[0].selectize.close()

$ ->
	affixTags($('.tagEntry'))

$ ->
	$('#tagDropdown').click () ->
		$('.tagList').toggleClass('hide')
		false
