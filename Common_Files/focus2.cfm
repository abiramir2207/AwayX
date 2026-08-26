<cfprocessingdirective suppressWhitespace="true">
<!---------------------------------------------------------------------------------------------------------------------
			Template:  \Common_Files\focus2.cfm
				Date:  2022 November 22
			  Author:  Chris Nguyen
			 Purpose:  Auto select value in the focused input with "autoselect" class
                       Bypass the classic jQuery focus.js logic
----------------------------------------------------------------------------------------------------------------------->
<!--- set up variable to avoid Application.cfc inserting the other focus using jQuery onto the page --->
<cfset request.focusHiLightOff = true>

<script>
    // on focused input with "autoselect" class select its value automatically
    let _autoselect = document.querySelectorAll( "input.autoselect[type=text]" );
    _autoselect.forEach( function( element ) { element.addEventListener( "focus", function ( e ) { e.target.select() } ) } );
</script>
</cfprocessingdirective>