/*

			Template:  \script\javascript\focus.js
				Date:  2017 January
			  Author:  Chris Nguyen
			 Purpose:  Enable background style for focused element

*/
(function() {
	<!--- do not apply focus background styling to pages with prototype --->
	if ( typeof Prototype !== "undefined" ) {     <!--- settings - admin - label --->
	}
	else {
		(window.jQuery  ||  (document.write('<script src="/script/javascript/ajax_js/jquery-1.7.2-min.js"><\/script>')) );
		<!--- Poll for jQuery to come into existance--->
		var checkReady = function(callback) {
		  if (window.jQuery) {
			callback(jQuery);
		  }
		  else {
			window.setTimeout(function() { checkReady(callback); }, 100);
		  }
		};
		<!--- Start polling... --->
		checkReady(function($) {
		  if ( window.jQuery ) {
			  try {
				var apply$Elements = 'input[type=text], input[type=textbox], input[type=password], input[type=search], textarea';
				jQuery('body').on('focus', apply$Elements, function(e) { $(e.target).addClass("hilight") })
							  .on('blur',  apply$Elements, function(e) { $(e.target).removeClass("hilight") });
			  }
			  catch (err) {
			  }

			  if ( window.jQuery.ui ) {
				try {
				    jQuery.widget("ui.tooltip", jQuery.ui.tooltip, {
					    options: { 	content: function () { jQuery(".ui-tooltip").fadeOut(); /* tooltip genocide */ return jQuery(this).prop("title"); },
					        		show: { effect: "fade", delay: 300 }
					        	}
					});
					jQuery( "[title]" ).tooltip().click(function(){ jQuery('[class^="ui-tooltip"]').remove(); });
				}
				catch (err) {
				}
			  }
		  }
		});
		
		jQuery('input.autoselect[type=text]').focus( function() {
			$(this).select();
		});
	}
})();
