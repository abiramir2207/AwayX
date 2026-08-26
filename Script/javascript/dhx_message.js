/* ------------------------------------------------------------------------------------------------------------------------------------------------------------
			Template:  \script\javascript\dhx_message.js
				Date:  2017 June
			  Author:  Chris Nguyen
			 Purpose:  Define common dhtml message functions

	       IMPORTANT:  Use /common_files/dhx_message.cfm to load this .js file to avoid problems
	       				( e.g. loading this file more than once, missing components from dhtmlx message plugin )
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* global dhx modal message variable, can be used in callback */
let dhx_modal_id = null;	// last dhx modal id
let do_nothing = function(){}; // do nothing, default callback
  
  function dhx_alert( msg, header, kind ) {
    if ( msg )
        header = header || "Alert";
        kind   = kind || "alert-error";
        dhtmlx.alert( {
                            text:  dhx_msg_wrapper(msg),
                            title: header,
                            type:  kind
                        } );
}
function dhx_confirm( msg ) {
	if ( msg )
		dhtmlx.confirm( {
			text: msg,
			title: "Confirm",
			type:"confirm",
		} );
}
	
function dhx_alert_wait( msg, func, title_msg, btns ) {
	if ( msg ) {
		// provide defaults
		btns      = btns || ["OK"];
		title_msg = title_msg || "Alert";
		func      = func || do_nothing;

		// SAH - use alert to get the Enter key support, doesn't work with modalbox
		dhx_modal_id = dhtmlx.alert( {
							text: msg,
							title: title_msg,
							ok: btns,
							callback: func
		} );

	}
}

function dhx_modal( msg, func, title_msg, btns ) {
	if ( msg ) {
		// provide defaults
		btns      = btns || ["OK"];
		title_msg = title_msg || "Alert";
		func      = func || do_nothing;

		dhx_modal_id = dhtmlx.modalbox( {
							text: msg,
							title: title_msg,
							buttons: btns,
							callback: func
		} );

		// Modal returns a value.  If there is an input field on the popup, focus on it
		let elem = dhx_modal_id.getElementsByTagName("input")[0];
		if ( elem )
			elem.focus();
	}
}

/* 85971 - Added ability to display a long message with many lines */
function dhx_msg_wrapper(msg) {
    // make dialog box height 40% of window height
    let dialog_box_height = window.innerHeight * 0.40;
    return '<div style="overflow-y: auto; max-height:' + dialog_box_height + 'px;">' + msg + '</div>';
}
