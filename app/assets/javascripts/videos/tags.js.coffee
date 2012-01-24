$ ->	
	$('.tagEntry').textext({
	  plugins: 'tags autocomplete'
		ext: {
			tags: {
				addTags: (tags) ->
					return unless tags
					$.fn.textext.TextExtTags.prototype.addTags.apply(this, arguments);
					$.post(this.core().input().closest('form').attr('action'), { 
						tags: this.core().hiddenInput().attr('value').replace(/["\[\]]/g, '')
					})
			}
		}
	}).bind 'isTagAllowed', (e, data) ->
		if data.tag.indexOf(',') > -1
			data.result = false