<!-------------------- Add this for Print Help Window ----------------------------------------->

<style type="text/css">
#divPrintHelp
 {
 position:absolute; 
 top:15px; 
 left:100px; 
 width:400px; 
 height:300px; 
 background-color:ffffee; 
 z-index:100;
 visibility:hidden;
 padding:10px;
 border:2px solid black; 
 }
</style>
<DIV ID="divPrintHelp" ONCLICK="dontclose();">
 <b><FONT SIZE="+1" COLOR="Green">print help</FONT><HR COLOR="Orange"></b>
 <br>

	 
To print this document, click "print" and a dialog box will prompt for your printer settings.<BR><BR>
 
For best print results, please address the following items:

<UL>
	<LI>Select the correct printer</LI>
	<LI>In the "Layout", turn off headers and footers</LI>
	<LI>Select the appropriate layout: portrait or landscape</LI>
</UL>

<B><FONT COLOR="Red" SIZE="2">To achieve expected results please review your printer margin settings in advance.</FONT></B>
<BR>
<BR>
To return to this help screen click on the body of the document.
<BR><BR>

<TABLE CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="100%">
<TR>
	<TD ALIGN="center"><B><FONT SIZE="2" COLOR="Red">[</FONT> <A HREF="##" ONCLICK="hidePrintDiv();">close help</A> <FONT SIZE="2" COLOR="Red">]</FONT></B></TD>
	<TD ALIGN="center"><B><FONT SIZE="2" COLOR="Red">[</FONT> <A HREF="##" onClick="javaScript: printPage();">print document</A> <FONT SIZE="2" COLOR="Red">]</FONT></B></TD>
	<TD ALIGN="center"><B><FONT SIZE="2" COLOR="Red">[</FONT> <A HREF="##" ONCLICK="window.close();">close document</A> <FONT SIZE="2" COLOR="Red">]</FONT></B></TD>
</TR>
</TABLE>

</DIV>
 
<SCRIPT LANGUAGE="JavaScript">
var show_State = 0;
function dontclose()
	{
		event.returnValue=false;
		event.cancelBubble=true;
		return false;
	}


function showPrintDiv(dontcancel)
{
 var winWidth = 400;
 var winHeight = 300;
 
 var divObj = document.all.divPrintHelp;
/* if(divObj.style.visibility == 'visible')
 {
  hidePrintDiv();
  return;
 }
*/
 var wid,hei;
/* if(event.type == "click")
 {
  wid = event.clientX;
  hei = event.clientY; 
 }
 else
 */
 {
  wid = document.body.clientWidth;
  hei = document.body.clientHeight;
  
  wid = (wid/2) - (winWidth/2);
  hei = (hei/2) - (winHeight/2);
 }
 
hei =  hei + document.body.scrollTop;
 if(divObj)
 {
  
  divObj.style.left = wid;
  divObj.style.top = hei;
  divObj.style.visibility='visible';
  show_State = 1;
 }
 if(dontcancel)
 {
 }
 else
 {
 	event.cancelBubble = true;
 	event.returnValue = false;
 }
}




function hidePrintDiv()
{  
 var divObj = document.all.divPrintHelp;
 divObj.style.visibility='hidden';
 show_State = 0;
 event.cancelBubble = true;
 event.returnValue = false;
}
 
function printPage()
{
 hidePrintDiv();
 window.print();
 event.cancelBubble = true;
 event.returnValue = false;
}

function scrollPage()
{
	if(show_State)
	{
		showPrintDiv(1);
	}
}
var timeout1 = null;
function settimeoutScroll()
{
	if(timeout1)
	{
		window.clearTimeout(timeout1);
	}
	timeout1 = window.setTimeout("scrollPage()", 10);
}
window.onbeforeprint=new Function ("hidePrintDiv();");
document.body.onload=new Function ("printPage();");
document.onclick=new Function ("showPrintDiv();");
document.body.onscroll=new Function ("settimeoutScroll();");

</SCRIPT>
 
<!-------------------- Add this for Print Help Window ----------------------------------------->
