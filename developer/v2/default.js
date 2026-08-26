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
    var winl=(screen.width-w)/2;
    var wint=(screen.height-h)/2;
    var winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize+',status=';
    if(menubar){winprops=winprops+',menubar='+menubar}
    var win=window.open(mypage,myname.replace(/\s/g, ''),winprops);
    if(parseInt(navigator.appVersion)>=4)
        {win.window.focus()}
    if(returnWindow)
        {return win}
}
function NewWindowTopLeft(mypage,myname,w,h,scroll,resize,returnWindow,menubar){
	myname = myname || "_popup_" + random367();
	w = w || ( screen.availWidth * 0.80 );
	h = h || ( screen.availHeight * 0.80 );
	scroll = scroll || "0";
	resize = resize || "0";
	returnWindow = returnWindow || "0";
	menubar = menubar || "0";
	if(myname.indexOf('/')!==-1){myname=myname.replace(/\057/g,"")}if(myname.indexOf('-')!==-1){myname=myname.replace(/-/g,"")}
	var winl=(screen.width-w)/2;var wint=(screen.height-h)/2;var winprops='height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize+',status=';if(menubar){winprops=winprops+',menubar='+menubar} var win=window.open(mypage,myname.replace(/\s/g, ''),winprops);win.moveTo(0,0);win.focus();if(parseInt(navigator.appVersion)>=4){win.window.focus()}
	if(returnWindow){return win}
}
function popupCenterByPercentages(url, title, w, h) {
	w = w || 80;
	h = h || 80;
	// w, h are numeric values, they represent percentages without the % sign
	var  w2 = Math.floor( screen.availWidth  * w / 100 );
    var h2 = Math.floor( screen.availHeight * h / 100 );
	return popupInCenter(url, title, w2, h2);
}
function random367() {
	return Math.random().toString(36).substring(7);
}
function popupInCenter(url, title, w, h) {
	return popupCenter2022( url, title, w, h );
}
function isNumeric(n) {
	return !isNaN(parseFloat(n)) && isFinite(n);
}
function popupCenter(url, title, width, height) {
	return popupCenter2022( url, title, width, height );
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
	if (on_event === "onclick")
		event = "click";
	else if (on_event === "onchange")
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
        var grid_element = document.getElementById( grid_id.replace('#', '') );
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
    var grid_height = get_grid_full_height( grid_id );
    if (grid_height) {
        var grid_element = document.getElementById( grid_id.replace('#', '') );
        // adjust grid element height
        try { grid_element.style.height = grid_height + "px"; } catch(error) {};
    }
}
// serialize form elements without trailing blank spaces
function serialize_form( form_name ) {
    if ( form_name && jQuery ) {
        const selected_form = jQuery("form[name=" + form_name + "]");
        // remove trailing blank spaces in text input elements
        selected_form.find("input[type=text]").each(function(){
            jQuery(this).val( jQuery(this).val().trim() )
        });
        return selected_form.serialize();
    }
    return '';
}



popup_dimensions = {    height_sm: 0.35,   // range from 0 to 1, where 1 is 100% of the screen dimension
						height_md: 0.5,
						height_lg: 0.75,
						height_xl: 0.85,
						height_xs: 0.25,
						width_xs:  0.35,
						width_sm:  0.5,
						width_md:  0.65,
						width_lg:  0.75,
						width_xl:  0.85             };


/* Convert XS, SM, MD, LG, XL sizes into pixels based on user screen dimension */
function popup_dimension( given_width, given_height ) {
	/* define maximum sizes to avoid big popups on ultra large monitors */
	let max_widths  = { xs:800, sm:1100, md:1400, lg:1600, xl:1800 };
	let max_heights = { xs:300, sm:400,  md:600,  lg:900,  xl:1000 };

	// arbitrary default dimension
	let result = { width:max_widths.sm, height:max_heights.md };

	/* turn the given size arguments into lowercase */
	const width_lc  = given_width.trim().toLowerCase();
	const height_lc = given_height.trim().toLowerCase();

	/* unexpected given width */
	if (typeof( max_widths[ width_lc ] ) === "undefined") {
		/* default to a tiny popup for developers to fix the parameters */
		result.width  = 300;
		result.height = 300;
		console.log( "Unexpected width = ", given_width );
	}
	else {
		/* avoid being too wide on ultra large monitors */
		result.width = Math.min( popup_dimensions[ "width_" + width_lc ] * screen.width * window.devicePixelRatio, max_widths[ width_lc ] );
	}

	/* unexpected given height */
	if (typeof( max_heights[ height_lc ] ) === "undefined") {
		/* default to a tiny popup for developers to fix the parameters */
		result.width  = 300;
		result.height = 300;
		console.log( "Unexpected height = ", given_height );
	}
	else {
		/* avoid being too tall on ultra large monitors */
		result.height = Math.min( popup_dimensions[ "height_" + height_lc ] * screen.height * window.devicePixelRatio, max_heights[ height_lc ] );
	}
	return result;
}


function popupCenter2022( url, title, width, height ) {
	return popup2022( url, title, width, height, "center" );
}


function popup2022( url, title, width, height, position ) {
	title  = title  || "";
	width  = width  || "md";
	height = height || "md";
	position = position || "";

	if (title.trim() === '') {
		title = "_popup_" + Math.random().toString(36).substring(7);
	}

	// convert popup width/height into pixels and figure out the position coordinate
	let popup = popup_dimension( width, height );

	let browser_tab_url_height = 70;

	switch ( position.toLowerCase().trim() ) {
		case 'center':
			position = {  left: Math.floor( ( ( screen.availWidth * window.devicePixelRatio ) - popup.width ) / 2 )
							,top: Math.floor( ( ( screen.availHeight * window.devicePixelRatio ) - ( popup.height  + browser_tab_url_height ) ) / 2 ) };
			break;

		default:
			position = { top: 0, left: 0 };
			break;
	}

	// console.log( position, screen, popup, window.devicePixelRatio );
	return window.open( url, title, "scrollbars, resizable, width=" + popup.width + ", height=" + popup.height + ", top=" + position.top + ", left=" + position.left );
}
