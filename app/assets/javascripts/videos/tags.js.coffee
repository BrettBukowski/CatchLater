$ ->
	# Don't run on non-video pages
  return if not $('.videos').length
	
	$('.tagEntry').textext({plugins: 'tags autocomplete'})