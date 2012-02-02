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
		if data.tag.indexOf(',') > -1
			data.result = false
	.each () ->
		$(this).textext()[0].tags().addTags($(this).attr('data-tags').split(','), true)

$ ->	
	affixTags($('.tagEntry'))