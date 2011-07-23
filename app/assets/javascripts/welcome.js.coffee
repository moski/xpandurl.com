# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


jQuery ->
	isUrl = (s)  ->
		regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
		regexp.test(s)
	
	($ '.shorteningInput').focus()
	
	($ '#shortenForm').submit ->
		form = $(this)
		api_url = form.attr('action')
		
		short_url = $('.shorteningInput').val();
		
		# Make sure we have a valid url 
		if !isUrl(short_url)
			alert('Please enter a valid url');
			return false
		
		$('.results').html("").addClass("loading").show()
		
		data = form.serialize()
		
		$.getJSON(api_url, data, (data) -> 
			if data.error
				url = $('.shorteningInput').val();
				html =  '<ul><li>' + "we don't know how to expand " + url + '</li></ul>'
				$('.results').removeClass("loading").removeClass("success").addClass("error").html(html).show()
			else
				html =  '<ul>'
				html += '<li class="expanded_url">'
				html += '<a href="' + data.long_url + '" target="_blank">' + data.long_url + '</a>'
				html += '</li>'
				html += '<li class="expand_count"><span class="label">xp: </span>' + data.expand_count + ' times</li>' 
				$('.results').removeClass("loading").removeClass("error").addClass("success").html(html).show()
		)
		
		
		return false