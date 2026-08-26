<!---
FILE: 		Search_On_Page.cfm
CREATED DATE:  	12/16/2014
CREATED BY:	Milan Mushran
FUNCTIONALITY:  Highlight multiple occurences
		of the search keyword on the page.

EDITED DATE:
EDITED BY:
MODIFIED FUNCTIONALITY:
 --->

<script type="text/javascript">
// Global range object variable
var rng;

<!---
 // rng.pasteHTML = ("<font style='color:blue; background-color:yellow;'>" + rng.text + "</font>")
//rng.execCommand("Bold");
--->
/* Clear the highlight on the previous search highlighted text. */
function clearHighlightedText(container, search1, search2) {
    if (search1) {
        rng = document.body.createTextRange();
        rng.moveToElementText(container);

        for (var i = 0; rng.findText(search1); i++) {
	   /* clear the background color for the previous search keyword. */
	   rng.execCommand('BackColor', false, '');
           rng.collapse(false);
        }
    }

    highlightThisText(container, search2)
}

/* Highlight the current search keyword. */
function highlightThisText(container, search2) {
var Scroll_Into_View = 0;

    if (search2) {
        rng = document.body.createTextRange();
        rng.moveToElementText(container);
        for (var i = 0; rng.findText(search2); i++) {

	   /* yellow background for the search keyword. */
	   rng.execCommand('BackColor', false, 'yellow');

		   /* scroll only to the first found instance of the keyword. */
		   if(Scroll_Into_View == 0)
		   {
		   rng.scrollIntoView();
		   Scroll_Into_View = 1;
		   }

           rng.collapse(false);
        }
    }
}



var searchTermsArray = new Array();
function findThisText(search, container) {
var search = search;
var search1;
var search2;


  if(searchTermsArray.length == 0)
  {
	searchTermsArray.push(search);
  }
  else if(searchTermsArray.length == 1)
  {
	searchTermsArray.push(search);
  }
  else{
	/* delete the first element from the array */
	searchTermsArray.splice(0,1);
	searchTermsArray.push(search);
  }

 /* The searchTermsArray will only have 2 elements at anytime.
 First element is the previous serach keyword and the second element is the current search keyword.
 */

/* Store the previous search keyword (unless it is the first keyword for search). */
search1 = searchTermsArray[0];

/* "search2" is the current search keyword being used. We need to highlight this keyword on the page. */
if(searchTermsArray.length == 2){
	search2 =  searchTermsArray[1];
}
else{
       /* If it is the first keyword for search (user searching for the first time on a page during a session),
       then "search1" and "search2" are the same. */
	search2 =  searchTermsArray[0];
}

  clearHighlightedText(container, search1, search2)
}
</script>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/FilteringHighlight.js"></script>
<style type="text/css">
    .filteringHighlight {
        background-color: yellow;
    }
</style>
<script type="text/javascript">
    jQuery(function() {
        jQuery('#find_Text').filteringHighlight('body', 'filteringHighlight');
    });
</script>

<div style="margin:3px; font-size:11px; width:300px;">
Find on Page: &nbsp;<INPUT TYPE="TEXT" ID="find_Text"> 
<!---
&nbsp; <a href="#" onclick="findThisText(document.getElementById('find_Text').value,document.body)"><cfoutput>#application.util.string.actionLinkFormat2("find")#</cfoutput></a>
--->
</div>