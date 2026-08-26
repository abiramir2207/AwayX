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
 border:'2px solid black'; 
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

function dontclose()
	{
		event.returnValue=false;
		event.cancelBubble=true;
		return false;
	}


function showPrintDiv()
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
 if(divObj)
 {
  
  divObj.style.left = wid;
  divObj.style.top = hei;
  divObj.style.visibility='visible';
 }
 event.cancelBubble = true;
 event.returnValue = false;
}




function hidePrintDiv()
{  
 var divObj = document.all.divPrintHelp;
 divObj.style.visibility='hidden';
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
 
window.onbeforeprint=new Function ("hidePrintDiv();");
document.body.onload=new Function ("showPrintDiv();");
document.onclick=new Function ("showPrintDiv();");
</SCRIPT>
 
<!-------------------- Add this for Print Help Window ----------------------------------------->