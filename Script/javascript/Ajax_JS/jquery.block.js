/*
 * jQuery blockUI plugin (by M. Alsup)
 * Version 0.4 (12/27/2006)
 * @requires jQuery v1.0
 * @license: Free beer and free speech. Enjoy!
 */
/**
 * blockUI provides a way to effectively simulate synchronous behavior during ajax operations 
 * without locking the browser.  It will prevent user operations for the current page while it is
 * active.  blockUI accepts the following two arguments:
 *
 *   (String|Element|jQuery) message: The message to be displayed while the UI is blocked. The message argument
 *              can be a plain text string, like "Processing...", an HTML string like,
 *              "<h1><img src="busy.gif" /> Please wait...</h1>", a DOM element, or a jQuery object.
 *
 *   (Object) css:  Object which contains css values to override the default styles of
 *              the message.  Use this argument if you wish to override the default 
 *              styles.  The css Object should be in a format suitable for the jQuery.css
 *              function.  For example:
 *              $().blockUI({
 *                    backgroundColor: '#ff8',
 *                    border: '5px solid #f00,
 *                    fontWeight: 'bold'
 *              });
 *
 * @example
 * $().blockUI();
 * @desc prevent user interaction with the page (and show the default message of 'Please wait...')
 *
 * @example
 * $().blockUI( { backgroundColor: '#f00', color: '#fff'} );
 * @desc prevent user interaction and override the default styles of the message to use a white on red color scheme
 *
 * @example
 * $().blockUI('Processing...');
 * @desc prevent user interaction and display the message "Processing..." instead of the default message
 *
 * @name blockUI
 * @type jQuery
 * @param String|jQuery|Element message Message to display while the UI is blocked
 * @param Object css Style object to control look of the message
 * @cat Plugins/blockUI
 * @see unblockUI
 * @return jQuery
 */
 jQuery.fn.blockUI = function(message, css) {
    if (message && typeof message == 'object' && !message.jquery && !message.nodeType) {
        css = message;
        message = null;
    }
    message = message ? (message.nodeType ? jQuery(message) : message) : '<h1>Please wait...</h1>';
    css = css || {};
    jQuery.blockImpl.init(message, css).show(true);
    return this;
}  
  
/**
 * unblockUI removes the UI block that was put in place by blockUI
 *
 * @example
 * $().unblockUI();
 * @desc Unblocks the UI
 *
 * @name unblockUI
 * @type jQuery
 * @cat Plugins/blockUI
 * @return jQuery
 * @see blockUI
 */
 jQuery.fn.unblockUI = function(options) {
    jQuery.blockImpl.show(false);
    return this;
}    

jQuery.blockImpl = {
    visible: false,
    glass: false,
    msgDiv: false,
    
    init: function(message, css) {
        if (jQuery.blockImpl.glass) {
            msgDiv.empty().append(message).css(css);
            if (message.jquery) message.show();
            return this;
        }
        var iframe  = jQuery('<iframe id="blockingFrame" style="display:none;position:fixed;height:100%;z-index:1000;background-color:#fff;top:0;left:0;width:100%;border:none"><div></div></iframe>');
        var waitDiv = jQuery('<div id="blockingPane" style="display:none;position:fixed;height:100%;z-index:2000;top:0;left:0;width:100%;cursor:wait"></div>');
            msgDiv  = jQuery('<div id="blockingMsg" style="display:none;z-index:3000;cursor:wait;padding:0;position:fixed;top:50%;left:50%;width:250px;margin:-50px 0 0 -125px;text-align:center;background-color:#fff;border:3px solid #aaa"></div>');
        this.glass  = jQuery([iframe[0],waitDiv[0],msgDiv[0]]).appendTo('body');
        msgDiv.append(message).css(css);
        if (message.jquery) message.show();
        
        jQuery('html,body').css('height','100%');
        
        // hook events
        var h = function() { return !jQuery.blockImpl.visible; };
        jQuery().bind('keypress', h).bind('keydown', h).bind('mousedown', h);
        
        // opera 8 didn't support opacity and will display the iframe opaque
        window.opera && window.opera.version() < 9 ? iframe.css('width','0') : iframe.css('opacity','0.6');

        if (jQuery.browser.msie && typeof XMLHttpRequest == 'function') {
            jQuery.each([iframe,waitDiv,msgDiv], function(i) {
                var s = this[0].style;
                s.position = 'absolute';
                if (i < 2)
                    s.setExpression('height', 
                        'document.body.scrollHeight > document.body.offsetHeight ? document.body.scrollHeight : document.body.offsetHeight + "px"');
                else {
                    s.setExpression('top', 
                        '(document.documentElement.clientHeight || document.body.clientHeight) / 2 - (this.offsetHeight / 2) + (ignoreMe = document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop) + "px"');
                    s.marginTop = 0;
                }
            });
        }
        return this;
    },
    show: function(s) { s ? this.glass.show() : this.glass.hide(); this.visible = s }
};

