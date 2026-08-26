//<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//      Template:  \Common_Files\scripts\showhide.js
//          Date:  March 21 2012
//        Author:  Chris Nguyen
//       Purpose:  Show / hide html elements with fading effect
//
//         Notes:  Show / hide setting is saved in user''s cookie and expires in one year
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

var constant = {
    	 hide: '[ hide ]'       <!---text for hide link--->
    	,show: '[ show ]'       <!---text for show link--->
    	,cookie: 'bsa_'         <!---cookie names are prefixed with this common initial--->
    	,expires: 365           <!---cookie expires in a year--->
    };

//<!---events for hide/show info----------------------------------------------------------------------------------------->

function hideShowEvent( toggleID, eligibleID ) {
 $('#' + toggleID).click(function(e) {
  var $toggle = $(this);                                   <!---save link element--->
  e.preventDefault();
  $('#' + eligibleID).fadeToggle( function() {             <!---hide eligible section--->
    if ( $(this).is(':visible') ) {
     $.cookie(constant.cookie + toggleID, constant.hide, { expires: constant.expires, path: '/' });    <!---save hide setting in cookie for future reference--->
     $toggle.html( constant.hide );                        <!---change link content--->
    }
    else {
     $.cookie(constant.cookie + toggleID, constant.show, { expires: constant.expires, path: '/' });    <!---save show setting in cookie for future reference--->
     $toggle.html( constant.show );                        <!---change link content--->
    }
  });
 });
}

//<!---handle initial display of hide/show link-------------------------------------------------------------------------->

function defaultHideShow( toggleID, eligibleID ) {
	if ( $.cookie( constant.cookie + toggleID ) == constant.show ) { <!---previous link setting is show, eligible section is hidden--->
    $('#' + eligibleID).toggle();                                  <!---hide eligible section--->
    $('#' + toggleID).html( constant.show );                       <!---update link to show--->
	}
	else {
    $('#' + toggleID).html( constant.hide );                       <!---update link to hide--->
	}
}

//<!---set up hide/show initial display & events------------------------------------------------------------------------->

function setupHideShow( toggleID, eligibleID ) {
  defaultHideShow( toggleID, eligibleID );     <!---set up initial display--->
  hideShowEvent( toggleID, eligibleID );       <!---set up events--->
}
