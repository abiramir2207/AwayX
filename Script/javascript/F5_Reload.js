//   * ====================================================================================================
//   *    @File: \Script\javascript\F5_Reload.js
//   *  @Author: Chris Nguyen
//   *    @Date: 2022 August 2
//   *
//   * @Remarks: F5 event handler - reload page with added URL "_F5_Reload" parameter needed to update the
//   *           cached html content
//   *
//   * ====================================================================================================

// attempt to append a F5 '::' enabled indicator to the page title
try {
    if ( document.title && document.title.indexOf( "::" ) == -1 ) {
        document.title = document.title + " ::";
    }
}
catch (e) {
}

window.addEventListener( "keydown", function ( e ) {
    // F5 key was pressed
    if ( event.keyCode == 116 ) {
        e.preventDefault();

        const F5_REFRESH = "_F5_Reload=True";
        let new_location = window.location.href;

        // append conditionally a new refresh URL parameter to send back
        if ( new_location.toLowerCase().indexOf( F5_REFRESH.toLowerCase() ) == -1 ) {
            new_location = new_location.concat( ( new_location.indexOf( "?" ) == -1 )
                                                    ? '?'
                                                    : '&', F5_REFRESH );
        }

        // automatically refresh the page with URL refresh parameter
        window.location = new_location;
    }
} );
