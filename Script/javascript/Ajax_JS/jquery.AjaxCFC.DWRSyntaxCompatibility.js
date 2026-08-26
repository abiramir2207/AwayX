DWREngine = {
		_execute: function(path, scriptName, methodName, vararg_params) {
			var args = [];
			var callback = null;
			for (var i = 0; i < arguments.length - 3; i++) {
				args[i] = arguments[i + 3];
			}
			var lastArg = args[args.length - 1];
			if (typeof lastArg == "function") {
				callback = args.pop();
			}

			jQuery.AjaxCFC({
			  url: path,
			  method: methodName,
			  data: args,
			  unnamedargs: true,
			  success: callback
			});

		}
	};

DWRUtil = {
	useLoadingMessage: function(message) {
	  var loadingMessage;
	  if (message) loadingMessage = message;
		  else loadingMessage = "Loading";
	
	  jQuery().ajaxSend(function(e, xml, s) {
	    var disabledZone = document.getElementById('disabledZone');
	    if (!disabledZone) {
	      disabledZone = document.createElement('div');
	      disabledZone.setAttribute('id', 'disabledZone');
	      disabledZone.style.position = "absolute";
	      disabledZone.style.zIndex = "1000";
	      disabledZone.style.left = "0px";
	      disabledZone.style.top = "0px";
	      disabledZone.style.width = "100%";
	      disabledZone.style.height = "100%";
	      document.body.appendChild(disabledZone);
	      var messageZone = document.createElement('div');
	      messageZone.setAttribute('id', 'messageZone');
	      messageZone.style.position = "absolute";
	      messageZone.style.top = "0px";
	      messageZone.style.right = "0px";
	      messageZone.style.background = "red";
	      messageZone.style.color = "white";
	      messageZone.style.fontFamily = "Arial,Helvetica,sans-serif";
	      messageZone.style.padding = "4px";
	      disabledZone.appendChild(messageZone);
	      var text = document.createTextNode(loadingMessage);
	      messageZone.appendChild(text);
	    }
	    else {
	      document.getElementById('messageZone').innerHTML = loadingMessage;
	      disabledZone.style.visibility = 'visible';
	    } // if (!disabledZone) {
	  }); // jQuery().ajaxSend(function(e, xml, s) {
	  jQuery().ajaxComplete(function() {
	    document.getElementById('disabledZone').style.visibility = 'hidden';
	  }); // $().ajaxComplete(function() {
	}, // useLoadingMessage: function(message) {


	/**
	* Setup a AJAX image indicator.
	* Added by Rey Bango (8/16/06) based on code in the URL below
	* @see http://getahead.ltd.uk/dwr/browser/util/useloadingmessage
	*/

	useLoadingImage:  function(imageSrc) {
		var loadingImage;
		if (imageSrc)
		   loadingImage = imageSrc;
		else loadingImage = "ajax-loader.gif";
	
		jQuery().ajaxSend(function(e, xml, s) {
			var disabledImageZone = document.getElementById('disabledImageZone');
			if (!disabledImageZone) {
				disabledImageZone = document.createElement('div');
				disabledImageZone.setAttribute('id', 'disabledImageZone');
				disabledImageZone.style.position = "absolute";
				disabledImageZone.style.zIndex = "1000";
				disabledImageZone.style.left = "0px";
				disabledImageZone.style.top = "0px";
				disabledImageZone.style.width = "100%";
				disabledImageZone.style.height = "100%";
				var imageZone = document.createElement('img');
				imageZone.setAttribute('id','imageZone');
				imageZone.setAttribute('src',imageSrc);
				imageZone.style.position = "absolute";
				imageZone.style.top = "0px";
				imageZone.style.right = "0px";
				disabledImageZone.appendChild(imageZone);
				document.body.appendChild(disabledImageZone);
			}
			else {
				document.getElementById('imageZone').src = imageSrc;
				disabledImageZone.style.visibility = 'visible';
			} // if (!disabledImageZone) {
		}); // jQuery().ajaxSend(function(e, xml, s) {
		jQuery().ajaxComplete(function() {
			document.getElementById('disabledImageZone').style.visibility = 'hidden';
		});
	} // useLoadingImage:  function(imageSrc) {

}; // DWRUtil = {

if(typeof window._ajaxConfig != "undefined" && typeof window._ajaxConfig.debug != "undefined" && window._ajaxConfig.debug == true) {
	jQuery.AjaxCFCHelper.setDebug(true);
}
