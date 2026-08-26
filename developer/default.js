/*
**  \script\javascript\default.js
**  This JS script is loaded onto every page automatically by Application_Common.cfm
*/
function NewWindow(mypage,myname,w,h,scroll,resize,returnWindow,menubar){
	myname = myname || "_popup_" + random367();
	w = w || ( screen.availWidth * 0.80 );
	h = h || ( screen.availHeight * 0.80 );
	scroll = scroll || "1";
	resize = resize || "1";
	returnWindow = returnWindow || "0";
	menubar = menubar || "0";
	var winl=(screen.width-w)/2;var wint=(screen.height-h)/2;status="";winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize+',status='+status;if(menubar){winprops=winprops+',menubar='+menubar}win=window.open(mypage,myname.replace(/\s/g, ''),winprops);if(parseInt(navigator.appVersion)>=4){win.window.focus()}
	if(returnWindow){return win}
}
function NewWindowTopLeft(mypage,myname,w,h,scroll,resize,returnWindow,menubar){
	myname = myname || "_popup_" + random367();
	w = w || ( screen.availWidth * 0.80 );
	h = h || ( screen.availHeight * 0.80 );
	scroll = scroll || "0";
	resize = resize || "0";
	returnWindow = returnWindow || "0";
	menubar = menubar || "0";
	if(myname.indexOf('/')!=-1){myname=myname.replace(/\057/g,"")}if(myname.indexOf('-')!=-1){myname=myname.replace(/-/g,"")}
	var winl=(screen.width-w)/2;var wint=(screen.height-h)/2;status="";winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize+',status='+status;if(menubar){winprops=winprops+',menubar='+menubar}win=window.open(mypage,myname.replace(/\s/g, ''),winprops);win.moveTo(0,0);win.focus();if(parseInt(navigator.appVersion)>=4){win.window.focus()}
	if(returnWindow){return win}
}
function popupCenterByPercentages(url, title, w, h) {
	w = w || 80;
	h = h || 80;
	// w, h are numeric values, they represent percentages without the % sign
	var  w2 = Math.floor( screen.availWidth  * w / 100 )
		,h2 = Math.floor( screen.availHeight * h / 100 );
	return popupInCenter(url, title, w2, h2);
}
function random367() {
	return Math.random().toString(36).substring(7);
}
function popupInCenter(url, title, w, h) {
    w = w || (screen.availWidth * 0.80);
    h = h || (screen.availHeight * 0.80);
    title = title || "_popup_" + random367();
    var left = Math.floor((screen.availWidth - w) / 2)
        , top = Math.floor((screen.availHeight - h) / 2);
    return window.open(url, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, copyhistory=no, scrollbars=yes, resizable=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
}
function isNumeric(n) {
	return !isNaN(parseFloat(n)) && isFinite(n);
}
function popupCenter(url, title, width, height) {
    width  = width || 'md';
    height = height || "md";
    title  = title || "_popup_" + random367();
    if (title.trim() === '')
        title = "_popup_" + random367();
    let w_percent = 0, h_percent = 0;
    // determine the width
    switch (width.trim().toLowerCase()) {
		case "xs": // extra small width
			w_percent = 0.15;
		case "sm": // small width
			w_percent = 0.3;
			break;
		case "md": // medium width
			w_percent = 0.5;
			break;
		case "lg": // large width
			w_percent = 0.7;
			break;
		case "xl": // extra large width
			w_percent = 0.85;
		default:
			width.replace("%", "");
			// allow custom percentage from 1% to 100%
			w_percent =
				isNumeric(width) && width <= 100 && width > 0
					? width / 100
					: 0.5; // unexpected width
			break;
	}
    // determine the height
    switch (height.trim().toLowerCase()) {
		case "xs": // extra small height
			h_percent = 0.15;
			break;
		case "sm": // small height
			h_percent = 0.3;
			break;
		case "md": // medium height
			h_percent = 0.5;
			break;
		case "lg": // large height
			h_percent = 0.7;
			break;
		case "xl": // extra large height
			h_percent = 0.85;
			break;
		default:
			height.replace("%", "");
			// allow custom percentage from 1% to 100%
			h_percent =
				isNumeric(height) && height <= 100 && height > 0
					? height / 100
					: 0.5; // unexpected height
			break;
	}
    // calculate width/height in pixels and figure out position coordinates
    let  w_pixel = ( screen.availWidth * w_percent )
        ,h_pixel = ( screen.availHeight * h_percent )
	    ,left    = Math.floor( ( screen.availWidth  - w_pixel ) / 2 )
		,top     = Math.floor( ( screen.availHeight - h_pixel ) / 2 );
	return window.open(url, title, 'scrollbars,resizable,width='+w_pixel+',height='+h_pixel+',top='+top+',left='+left);
}

/* open a popup window and send a form into it - form object is the only required parameter */
function popup_form( form, title, w, h ) {
	title = title || "_popup_" + random367();
	form.target = title;
	return popupInCenter('', title, w, h);
}
function show_loader ( message, delay ) {
	/* delay is in miliseconds */
	delay = delay || 0;
	message = message || ' ';
	/* /styles/css-loader.css must be preloaded in order to use this */
	jQuery("body").append('<div class="loader loader-default is-active" half data-text="' + message + '"></div>');
	if ( delay > 0 ) {
		setTimeout(function(){ }, delay);
	}
	/* pass a negative delay to display a loading message and hide it automatically after the specified time period */
	else if ( delay < 0 ) {
		jQuery("div.loader").delay( Math.abs(delay) ).fadeOut();
	}
}
function fireEvent(on_event, obj) {
	var event = "";
	on_event = on_event || "onclick";
	if (on_event == "onclick")
		event = "click";
	else if (on_event == "onchange")
		event = "change";
	if (event !== "") {
		jQuery(obj).trigger(event);
	}
}
function close_popups() {
    try {        
        for (var i = 0; i < window.popups.length; i++) {
            window.popups[i].close();
        }
        window.popups = [];
    } catch (error) {
    }
	return false;
}
// return a numeric grid height (in pixels) to cover the remaining body height
function get_grid_full_height( grid_id ) {
    // process only valid grid id parameter
    if (typeof grid_id === 'string' && grid_id.length) {
        // remove pound character from grid id & grap grid element
        let grid_element = document.getElementById( grid_id.replace('#', '') );
        // process only grid element that exists
        if (grid_element) {
            // calculate grid height in pixels, use a negative 8 pixels to avoid body overflow
            return Math.max(0, window.innerHeight - grid_element.offsetTop - 8);
        }
    }
    // something went wrong send back a zero value
    return 0;
}
// sets a grid height to cover the remaining body height
function set_grid_full_height( grid_id ) {
    let grid_height = get_grid_full_height( grid_id );   
    if (grid_height) {
        let grid_element = document.getElementById( grid_id.replace('#', '') );
        // adjust grid element height
        try { grid_element.style.height = grid_height + "px"; } catch(error) {};
    }
}
