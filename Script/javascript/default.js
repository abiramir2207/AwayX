/*
 **  \script\javascript\default.js
 **  This JS script is loaded onto every page automatically by Application_Common.cfm
 */
function NewWindow(mypage, myname, w, h, scroll, resize, returnWindow, menubar) {
    myname = myname || "_popup_" + random367();
    w = w || Math.min(1300, Math.floor(screen.availWidth * 0.85));
    h = h || Math.min(800, Math.floor(screen.availHeight * 0.85));
    scroll = scroll || "0";
    resize = resize || "0";
    returnWindow = returnWindow || "0";
    menubar = menubar || "0";
    var winl = (screen.width - w) / 2;
    var wint = (screen.height - h) / 2;
    var winprops = "height=" + h + ",width=" + w + ",top=" + wint + ",left=" + winl + ",scrollbars=" + scroll + ",resizable=" + resize + ",status=";
    if (menubar) {
        winprops = winprops + ",menubar=" + menubar;
    }
    var win = window.open(mypage, myname.replace(/\s/g, ""), winprops);
    if (parseInt(navigator.appVersion) >= 4) {
        win.window.focus();
    }
    if (returnWindow) {
        return win;
    }
}
function NewWindowTopLeft(mypage, myname, w, h, scroll, resize, returnWindow, menubar) {
    myname = myname || "_popup_" + random367();
    w = w || Math.min(1300, Math.floor(screen.availWidth * 0.85));
    h = h || Math.min(800, Math.floor(screen.availHeight * 0.85));
    scroll = scroll || "1";
    resize = resize || "0";
    returnWindow = returnWindow || "0";
    menubar = menubar || "0";
    if (myname.indexOf("/") !== -1) {
        myname = myname.replace(/\057/g, "");
    }
    if (myname.indexOf("-") !== -1) {
        myname = myname.replace(/-/g, "");
    }
    var winl = (screen.width - w) / 2;
    var wint = (screen.height - h) / 2;
    var winprops = "height=" + h + ",width=" + w + ",top=" + wint + ",left=" + winl + ",scrollbars=" + scroll + ",resizable=" + resize + ",status=";
    if (menubar) {
        winprops = winprops + ",menubar=" + menubar;
    }
    var win = window.open(mypage, myname.replace(/\s/g, ""), winprops);
    win.moveTo(0, 0);
    win.focus();
    if (parseInt(navigator.appVersion) >= 4) {
        win.window.focus();
    }
    if (returnWindow) {
        return win;
    }
}
function popupCenterByPercentages(url, title, w, h) {
    w = w || 85;
    h = h || 85;
    // w, h are numeric values, they represent percentages without the % sign
    var w2 = Math.min(1800, Math.floor((screen.availWidth * w) / 100));
    var h2 = Math.min(1000, Math.floor((screen.availHeight * h) / 100));
     if(w2 > 2560){
        w2 = 2560;
    }
    if(h2 > 1660){
        h2 = 1660;
    }
    return popupInCenter(url, title, w2, h2);
}
function random367() {
    return Math.random()
        .toString(36)
        .substring(7);
}
function popupInCenter(url, title, w, h) {
    w = w || Math.min(1300, Math.floor(screen.availWidth * 0.85));
    h = h || Math.min(800, Math.floor(screen.availHeight * 0.85));
    title = title || "_popup_" + random367();
    var left = Math.floor((screen.availWidth - w) / 2);
    var top = Math.floor((screen.availHeight - h) / 2);
    return window.open(url, title, "toolbar=no, location=no, directories=no, status=no, menubar=no, copyhistory=no, scrollbars=yes, resizable=yes, width=" + w + ", height=" + h + ", top=" + top + ", left=" + left);
}
/* open a popup window and send a form into it - form object is the only required parameter */
function popup_form(form, title, w, h) {
    title = title || "_popup_" + random367();
    form.target = title;
    return popupInCenter("", title, w, h);
}
function show_loader(message, delay) {
    /* delay is in miliseconds */
    delay = delay || 0;
    message = message || " ";
    var loader_div = '<div class="loader loader-default is-active" half data-text="' + message + '"></div>';
    /* /styles/css-loader.css must be preloaded in order to use this */
    if (delay === 0) {
        jQuery("body").append(loader_div);
    } else {
        var loadChain = new LoadChain();
        loadChain.push(function() {
            jQuery("body").append(loader_div);
        });
        loadChain.push(function() {
            sleep(Math.abs(delay));
        });
        /* pass a negative delay to display a loading message and hide it automatically after the specified time period */
        if (delay < 0)
            loadChain.push(function() {
                $("div.loader").hide();
            });
        loadChain.start();
    }
}
function hide_loader( delay ) {
    if ( typeof delay === 'number' ) {
        setTimeout( function() {
                        const collection = document.querySelectorAll( "div.loader" );
                        for ( let i = 0; i < collection.length; i ++ ) {
                            collection[ i ].hidden = true;
                        }
                    }, delay );
    }
}
function fireEvent(on_event, obj) {
    var event = "";
    on_event = on_event || "onclick";
    if (on_event === "onclick") event = "click";
    else if (on_event === "onchange") event = "change";
    if (event !== "") {
        jQuery(obj).trigger(event);
    }
}
function sleep(milliseconds) {
    var now = new Date().getTime();
    while (new Date().getTime() < now + milliseconds) {
        /* do nothing */
    }
}
// https://confluence.awayx.com/x/hwGD
function LoadChain() {
    this.queue = [];
    this.push = function(f) {
        var self = this;
        // Push a function onto the queue that executes the user-specified function, then sets a timeout to execute the
        // next function if there is one
        this.queue.push(function() {
            f();
            var next = self.queue.shift();
            if (next) window.setTimeout(next, 0);
        });
    };
    this.start = function() {
        var first = this.queue.shift();
        first();
    };
}
// This takes a date string that MIGHT have a two digit year
// as the last two digits. If it does, this function replaces
// the two digit year with what it *assumes* is the proper
// four digit year.
function CleanDate(strDate) {
    return strDate.replace(
        // This regular expression will search for a slash
        // followed by EXACTLY two digits at the end of
        // this date string. The two digits are being
        // grouped together for future referencing.
        new RegExp("/(\\d{2})$", ""),

        // We are going to pass the match made by the
        // regular expression off to this function literal.
        // Our arguments are as follows:
        // $0 : The entire match found.
        // $1 : The first group within the match.
        function($0, $1) {
            // Check to see if our first group begins with
            // a zero or a one. If so, replace with 20 else
            // replace with 19.
            //if ($1.match(new RegExp("^[01]{1}", "")) || $1.match(new RegExp("^[02]{1}", ""))) {
                // Replace with 20.
                return "/20" + $1;
            /*} else {
                // Replace with 19.
                return "/19" + $1;
            }*/
        }
    );
}
// document.all replacement function: e = element, d = document | window.opener
function seekElement(e, d) {
    d = d || document;
    if (d.getElementsByName(e))
        return d.getElementsByName(e);
    else
        return d.getElementById(e);
}
function pageTitle(title, grand_parent) {
    try {
        var ancestor = grand_parent ? parent.parent : parent;
        ancestor.frames["header_new"].document.getElementById("Page_Title").innerHTML = title;
    } catch (e) {}
}
function zeroCheckBoxes(selector, val) {
    val = val || 0;
    selector = selector || "input[type=checkbox]:not(:checked)"; // get all unchecked checkboxes
    jQuery(selector).each(function() {
        // create a hidden input with the same name, zero value if it does not exist
        var input_name = jQuery(this).attr("name");
        if (jQuery("input[type=hidden][name=" + input_name + "]").length === 0) {
            jQuery(this).after("<input type='hidden' name='" + input_name + "' value='" + val + "'>");
        }
    });
}
function autoSelect() {
    jQuery("input.autoselect").focus(function() {
        jQuery(this).select();
    });
}
function duration(name) {
    var start = performance.now();
    return {
        stop: function() {
            var end = performance.now();
            console.log("Timer:", name, "finished in", end - start, "ms");
        },
    };
}
function isNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}
// 2019 mar 18 - chrisn added new popupCenter()
function popupCenter(url, title, width, height) {
    width = width || "md";
    height = height || "md";
    title = title || "_popup_" + random367();
    if (title.trim() === "") title = "_popup_" + random367();
    var w_percent = 0;
    var h_percent = 0;
    // determine the width
    switch (width.trim().toLowerCase()) {
        case "xs": // extra small width
            w_percent = 0.15;
            break;
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
            break;
        default:
            width.replace("%", "");
            // allow custom percentage from 1% to 100%
            w_percent = isNumeric(width) && width <= 100 && width > 0 ? width / 100 : 0.5; // unexpected width
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
            h_percent = isNumeric(height) && height <= 100 && height > 0 ? height / 100 : 0.5; // unexpected height
            break;
    }
    // calculate width/height in pixels and figure out position coordinates
    var w_pixel = screen.availWidth * w_percent;
    var h_pixel = screen.availHeight * h_percent;
    var left    = Math.floor((screen.availWidth - w_pixel) / 2);
    var top     = Math.floor((screen.availHeight - h_pixel) / 2);

    return window.open(url, title, "scrollbars,resizable,width=" + w_pixel + ",height=" + h_pixel + ",top=" + top + ",left=" + left);
}
// return a numeric grid height (in pixels) to cover the remaining body height
function get_grid_full_height(grid_id, height_offset) {
    // a numeric value (without 'px' unit) represents the height offset
    height_offset = height_offset || -8;
    // process only valid grid id parameter
    if (typeof grid_id === "string" && grid_id.length) {
        // remove pound character from grid id & grap grid element
        var grid_element = document.getElementById(grid_id.replace("#", ""));
        // process only grid element that exists
        if (grid_element) {
            var inner_height = jQuery ? jQuery(window).innerHeight() : window.innerHeight;
            // calculate grid height in pixels, use a negative 8 pixels to avoid body overflow
            return Math.max(0, inner_height - grid_element.offsetTop + height_offset);
        }
    }
    // something went wrong send back a zero value
    return 0;
}
// sets a grid height to cover the remaining body height
function set_grid_full_height(grid_id, height_offset) {
    // a numeric value (without 'px' unit) represents the height offset
    height_offset = height_offset || -8;
    var grid_height = get_grid_full_height(grid_id, height_offset);
    if (grid_height) {
        var grid_element = document.getElementById(grid_id.replace("#", ""));
        // adjust grid element height
        try {
            grid_element.style.height = grid_height + "px";
        } catch (error) {}
    }
}
// javascript error handler :: ajax() usage example :: error: function(xhr, status, error) { error_handler(arguments) }
function error_handler() {
    for (var i = 0; i < arguments.length; i++) console.log(arguments[i]); // show error detail on console for developers to debug
    modal_alert("An unexpected error has occurred, please report it to the technical support department.");
}
// display a message in a modal alert dialog box
function modal_alert(message, category, style) {
    if (typeof message === "string") {
        category = category || "information";
        style = style || "center";
        if (typeof dhx_alert === "function") {
            dhx_alert(message); // 85971
        } else if (typeof Noty === "function") {
            // noty version 3
            var n = new Noty({
                text: message,
                type: category,
                buttons: [
                    Noty.button("close", "", function() {
                        n.close();
                    }),
                ],
                killer: true,
                modal: true,
                layout: style,
            });
            n.show();
        } else if (typeof noty === "function")
            noty({
                text: message,
                type: category,
                buttons: [
                    {
                        text: "close",
                        onClick: function($noty) {
                            $noty.close();
                        },
                    },
                ],
                killer: true,
                modal: true,
                layout: style,
            });
        else alert(message);
    }
}
// turn off JS error display in an alert box
function suppress_js_error() {
    window.onerror = function() {
        return true;
    };
}
// 89672 - display JS error in an alert dialog - without this function JS error is visible only in browser console
function alert_js_error() {
    window.onerror = function(msg, url, linenumber) {
        // display technical error information on stage sites and developer sites
        if ( window.location.hostname.indexOf(".stage.") > -1 || // customer stage site
             window.location.hostname.indexOf("awayx.") === -1 )
            // domain without awayx => developer site
            alert(msg + "\n\n" + url + "\n\non line number: " + linenumber);
        else
            // display a non-technical message on production sites
            alert("Sorry, an unexpected JavaScript error has occurred. Please help us to reproduce the problem by reporting the steps to us.");
        return true;
    };
}
// detects MS Internet Explorer browsers //
function is_ie() {
    return (navigator.userAgent.indexOf('MSIE') !== -1 || navigator.appVersion.indexOf('Trident/') > -1);
}
// display selected elements in browser console (i.e. log_elements( "input[type=hidden][name^=rebate]") )
function log_elements( selector ) {
    let elements = [];
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  gather all elements into an array of structures --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    jQuery( selector ).each(function(){
        let name = jQuery(this).attr("name");
        if (name) {
            elements.push( { name:jQuery(this).attr("name"), value:jQuery(this).val() });
        }
    });
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  sort array of structures by names  --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    elements = elements.sort(function(a, b) {
                                    let one = a.name.toLowerCase();
                                    let two = b.name.toLowerCase();

                                    return one === two
                                            ? 0
                                            : one > two
                                                ? 1
                                                : -1;
                                });
    console.table(elements);
    return elements;
}

// Return foreground color based on background color
// Background color in 6 digit hex value
// Based on cf function (keep in sync so they work the same!) in /components/util/string.cfc
//

function foregroundColor (background_color) {

	const dkGrey = "#333333"		// dark grey foreground color for light background
	try {
		let local = {};
		if ( background_color.trim() != "" ) {
			background_color = background_color.replace (/#/g, "");

            // <!--- Get red in decimal format. --->
            local.intRed = parseInt( background_color.substr(0, 2), 16 );

            // <!--- Get green in decimal format. --->
            local.intGreen = parseInt( background_color.substr(2, 2), 16 );

            // <!--- Get blue in decimal format. --->
            local.intBlue = parseInt( background_color.substr(4, 2), 16 );

			// this logic was from jscolor.js version 2
			local.computed = (0.213 * local.intRed) + (0.715 * local.intGreen) + (0.072 * local.intBlue);

			return isNaN (local.computed)
				? dkGrey
				: local.computed > (255 / 2)
					? dkGrey
					: "#FFFFFF";

		}
	}
	catch (e) {	};
	return dkGrey;
}

function generate_export( url ) {
    if ( url ) {
        // add export iframe when it does not exist yet
        if (jQuery("iframe[name=export]").length == 0) {
            jQuery("body").append('<iframe name="export" style="opacity:0"></iframe>');
        }
        // create the export file in the iframe
        jQuery("iframe[name=export]").attr("src", url);
    }
}

function isDollars( str ) {
    /* return true when a given string parameter is a dollar value
        - https://tools.awayx.com/bsa/isDollars/
        - https://confluence.awayx.com/x/uoF4B
    */
    return typeof str !== "string"
               ? false
               : str.trim().match( /^[\$+-]{0,2}([0-9]{1,3},([0-9]{3},)*[0-9]{3}|[0-9]+)(.[0-9]{0,9})?$/ );
}

/* displays debugging info with styles in console - https://confluence.awayx.com/x/yYF4B */
function echo_log( obj1, obj2, type ) {
    if ( arguments.length >= 2 && typeof obj1 !== "undefined" && typeof obj2 !== "undefined" ) {
        type = type || "information";

        const isIE = !!window.MSInputMethodContext && !!document.documentMode;
        if ( isIE ) {
            /* no styles for IE */
            console.log( obj1, obj2 );
            return;
        }

        let font_color       = "black";
        let background_color = "gold";

        if ( typeof type === "string" && type.trim().toLowerCase() === "alert" ) {
            font_color       = "#ffffff";
            background_color = "#e0005a";
        }

        console.log( "%c" + obj1.toString()
                        ,"display:inline-block; font-weight:bold; padding:3px 7px 3px 7px; border-radius:3px; background-color:" + background_color + "; color:" + font_color
                        ,obj2
                    );
    }
}

// find form elements with same name (case insensitive) and same value, and delete the duplicates
function dedupElements( type ) {
    type = type || "input";
    const elements = document.querySelectorAll( type );

    elements.forEach( function( element ) {
        // skip elements without name
        if ( element.name ) {
            try {
                // locate elements with same name regardless of case sensitivity
                let matches = document.querySelectorAll( type + "[name='" + element.name + "' i][value='" + element.value + "']" );

                if ( matches && matches.length > 1 ) {
                    element.remove();
                }
            }
            catch ( e ) {
                    console.log( "Error in dedupElements()", e );
            }
        }
    } );
}
// fix JS floating point calculation
function numCalc( value, precision ) {
	if ( typeof precision !== "number" ) {
		precision = 7;
	}
	var power = Math.pow( 10, precision );

	return typeof value == "number"
			? Math.round( value * power ) / power
			: value;
}
