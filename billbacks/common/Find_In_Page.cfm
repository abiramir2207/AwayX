<!---
<SCRIPT LANGUAGE="JavaScript">
	document.onkeypress = new Function("callFind();");
	document.body.onscroll = new Function("moveFindDiv();");
	
	function callFind()
	{
		if(event.shiftKey)
		{
			if(event.keyCode == 70)
			{
				startFind();				
			}
		}		
	}
	
	function startFind()
	{
		event.returnValue = false;
		try
		{
			Page_Specific_Before_Find_Code();
		}
		catch(e)
		{
			
		}		
		n = 0;
		moveFindDiv(true);
	}
	
	function moveFindDiv(bShow)
	{
		var divObj = document.all.FindDiv;
		if(divObj.style.display == "" || bShow)
		{
			var wid1 = document.body.clientWidth;
			var hei1 = document.body.clientHeight;
			var wid2 = document.body.scrollLeft;
			var hei2 = document.body.scrollTop;
			
			
			var divWidth = parseInt(divObj.style.width);
			var divHeight = parseInt(divObj.style.height);
			var wid = (wid1/2) - (divWidth/2);
			var hei = (hei1/2) - (divHeight/2);
			
			
			divObj.style.left = wid + document.body.scrollLeft;
			divObj.style.top = hei + document.body.scrollTop;
		}
		if(bShow)
		{
			divObj.style.display = "";
			document.all.find_Text.focus();
		}
	}
	
	function hideFindDiv()
	{
		var divObj = document.all.FindDiv;
		divObj.style.display = "none";
		return false;
	}
</SCRIPT>

<SCRIPT LANGUAGE="JavaScript">
var oRange;
var sBookMark;
var first = true;
var n=0;
var oldValue = "";
//var winName= window.parent.frames[1];
function findThisText(find_Value)
{	
	event.returnValue = false;
	if(window)
	{						
		findInPage(window,find_Value);
    } 
	return false;
}

function findInPage(wObj,str) 
{
	var txt, i, found;
	if (str == "") return false; 
	if(oldValue != str) 
	{	
		n = 0 ;
	}
	
	oldValue = str;
	txt = wObj.document.body.createTextRange();

	// Find the nth match from the top of the page.
	for (i = 0; i <= n && (found = txt.findText(str)) != false; i++) 
	{
		txt.moveStart("character", 1);
		txt.moveEnd("textedit");
	}
	// If found, mark it and scroll it into view.
	if (found) 
	{
		txt.moveStart("character", -1);
		txt.findText(str)
		try
		{
			n++;
			txt.select();
			txt.scrollIntoView();
		}
		catch(e)
		{
			findInPage(wObj,str);
		}
		
	} 
	else 
	{
		// Start over at the top of the page and find first match.
		if (n > 0) 
		{
			n = 0;
			findInPage(wObj,str);
		} 
		else 
		{
			// Not found anywhere, give message.
			alert("Not found.");
		}
	}
return false;
}

</SCRIPT>
--->
<!---<DIV ID="FindDiv" STYLE="BORDER:2pz solid black;POSITION:ABSOLUTE;WIDTH:200px;top:10px;HEIGHT:50px;background-color:#CCCCCC">
<TABLE WIDTH="100%" HEIGHT="100%" BORDER="0">
<TR>
	<TD ALIGN="right">
	<B><A HREF="#" onClick="javaSCript: return hideFindDiv();"><FONT COLOR="FF0000">[</FONT>x<FONT COLOR="FF0000">]</FONT></A></B>&nbsp;&nbsp;&nbsp;
	</TD>
</TR>
<TR>
--->
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.highlight.js"></script>
<style type="text/css">
.highlight {
	background-color: yellow;
}
</style>
<script type="text/javascript">
highlightText = function() {
	$(document.body).unhighlight();
	$(document.body).highlight(document.getElementById('find_Text').value);
}
</script>
<table>
<TR>
<TD nowrap="1">
Find on Page:
<INPUT TYPE="TEXT" ID="find_Text" onKeyup="highlightText()">
</TD>
<!---
<TD nowrap="1">
<CF_button
	button_name="find"
	button_caption="find"
	button_action="findThisText(document.getElementById('find_Text').value);"
	button_type="javascript_link"
	button_width="150"
	button_color="Navy"
	button_tip	="save"
	font_color="White"
	font_size	="12"
	font_weight="bold"
	title="find"
>
</TD>
--->
<TR>
</TABLE>
<!---<TR>
</TABLE>
</DIV>--->
