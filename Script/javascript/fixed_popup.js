/* Dev Note: 11462; Milan - The fixed_popup.js file is for keeping the popup windows fixed 
This function is useful in keeping the popup page fixed.
   Steps to be folllowed:
   - Include this file in the page
   - Add this to the page's body tag - [onload = "mytimer = setTimeout('fcsOnMe()', 25);"]
   - Add this to all the controls (like textbox, textarea, etc) on the page - [onfocus="skipcycle=true" onblur="skipcycle=false"]
*/
var skipcycle = false;

function fcsOnMe(){
if (!skipcycle){
window.focus(); 
}
mytimer = setTimeout('fcsOnMe()', 25);
}