//   * =========================================================================================================
//   *    @File: Script\javascript\window_resize.js
//   *  @Author: Chris Nguyen
//   *    @Date: 2022 June 22
//   *
//   * @Remarks: Stops window resize event from firing continuously and reloads its window automatically
//   * =========================================================================================================

// timeOutFunctionId stores a numeric ID which is used by clearTimeOut to reset timer
var timeOutFunctionId;

window.addEventListener( "resize", function() {
    // clearTimeOut() resets the setTimeOut() timer due to this the function in setTimeout() is
    // fired after we are done resizing
    if ( timeOutFunctionId ) {
        clearTimeout( timeOutFunctionId );
    }

    // setTimeout returns the numeric ID which is used by clearTimeOut to reset the timer
    timeOutFunctionId = setTimeout( function() { "use strict"; window.location.reload(); }, 500 );
} );
