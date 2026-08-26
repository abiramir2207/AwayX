/* ------------------------------------------------------------------------------------------------------------------------------------------------------------
			Template:  \script\javascript\dhx_windows.js
				Date:  2017 June
			  Author:  Chris Nguyen
			 Purpose:  Initialize, manage dhtml windows objects

	       IMPORTANT:  Use /common_files/dhx_windows.cfm to load this .js file to avoid problems
	       				( e.g. loading this file more than once, missing components from dhtmlx window plugin )
--------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* global dhx window variables */
dhx_windows   = new dhtmlXWindows();     /* dhx window objects */
dhx_window_id = null;                    /* last dhx window id */

function dhx_window_close( window_id ) {
	/* if window_id is not passed use the last dhx window id */
	window_id = window_id || dhx_window_id;
	if ( dhx_windows.isWindow( window_id ) ) {
		dhx_windows.window( window_id ).close();
	}
}

function dhx_popupInCenter( url, title, width, height, window_id, modal, park ) {
	modal     = modal  || true;
	park      = ( modal 
					? false 
					: park || false );
	title     = title  || "";
	height    = height || 800;
	width     = width  || 1300;
	window_id = window_id || "_popup_" + random367();

	var popup = dhx_windows.createWindow({ caption: title,
										    	id: window_id, 
										 	 modal: modal, 
											  park: park,
										    height: height, 
										     width: width
										});
	popup.attachURL( url );
	if ( !park ) {
		popup.button( "park" ).hide();
	}
	popup.centerOnScreen();

	/* save window id so we can close it by JS function */
	dhx_window_id = window_id;   
	return popup;
}