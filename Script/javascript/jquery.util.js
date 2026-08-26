/*
 * jQuery Utilities Plug-in
 *
*/
(function($){

	$.fn.forceNumeric = function () {
 		return this.each(function () {
	    $(this).keydown(function (e) {
	        var key = e.which || e.keyCode;
	        if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
	         ( key >= 48 && key <= 57 ) ||    <!---numbers--->
	         ( key >= 96 && key <= 105 ) ||   <!---Numeric keypad--->
	         key == 190 || key == 188 || key == 109 ||  key == 189 || <!---comma, period and minus--->
	         key == 8 || key == 9 || key == 13 ||  <!---Backspace and Tab and Enter--->
	         key == 35 || key == 36 ||             <!---Home and End--->
	         ( key >= 37 && key <= 40 ) ||         <!---left, up and right, down arrows--->
	         key == 110 ||                         <!---Decimal point on numeric keypad---> 
	         key == 46 || key == 45) {             <!---Del and Ins--->
	          return true;
	        }
	        return false;
	    });
	 });
	}
	
})(jQuery);