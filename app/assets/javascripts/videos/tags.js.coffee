(exports ? this).affixTags = (elements) ->
	elements.textext(
		plugins: 'autocomplete tags'
		ext:
			tags:
				removeTag: (tag) ->
					$.fn.textext.TextExtTags.prototype.removeTag.apply(this, arguments)
					$.post(this.core().input().closest('form').attr('action'), { tags: this.core().hiddenInput().attr('value').replace(/["\[\]]/g, '')})
				addTags: (tags, alreadySaved) ->
					return unless tags
					$.fn.textext.TextExtTags.prototype.addTags.apply(this, arguments)
					if not alreadySaved
						$.post(this.core().input().closest('form').attr('action'), { tags: this.core().hiddenInput().attr('value').replace(/["\[\]]/g, '')})
  )
	.bind 'isTagAllowed', (e, data) ->
		if data.tag.indexOf(',') > -1 or $.inArray(data.tag, $(e.target).textext()[0].tags()._formData) > -1
			data.result = false
	.on 'focus', () ->
		return if window.localStorage.protips > 5
		$(this).closest('.text-core').addClass('focus').next().fadeIn()
		window.localStorage.protips = (parseInt(window.localStorage.protips, 10) || 0) + 1
	.on 'blur', () ->
		$(this).closest('.text-core').removeClass('focus').next().fadeOut()
	.each () ->
		$(this).textext()[0].tags().addTags($(this).attr('data-tags').split(','), true)

$ ->	
	proto = $.fn.textext.TextExt.prototype
	onKeyDown = proto.onKeyDown
	onAnyKeyUp = proto.onAnyKeyUp
	
	$.fn.textext.TextExt.prototype.onKeyDown = (e) ->
		if e.keyCode is 9
			$(e.target).textext()[0].tags().onEnterKeyPress(e)
			e.target.value = ''
			e.stopPropagation()
		onKeyDown.call(this, e)
	$.fn.textext.TextExt.prototype.onAnyKeyUp = (e, keyCode) ->
		if keyCode is 188
			e.target.value = e.target.value.substr(0, e.target.value.length - 1)
			$(e.target).textext()[0].tags().onEnterKeyPress(e)
			e.target.value = ''
			false
		onAnyKeyUp.call(this, e, keyCode)
	affixTags($('.tagEntry'))