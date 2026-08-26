<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">

<IMG SRC="/deductions/images/color_palette.gif" WIDTH="113" HEIGHT="113" BORDER="0" USEMAP="#Map">
<CFSET URLStr = Replace(URL.URLStr,",","&","All")>
<CFOUTPUT>
<MAP NAME="Map">
  <AREA SHAPE="RECT" COORDS="4,4,27,27" HREF="javascript: passColorToParent('008200','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="32,4,54,27" HREF="javascript: passColorToParent('00FF00','000000','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="58,4,80,27" HREF="javascript: passColorToParent('848200','000000','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="86,4,107,27" HREF="javascript: passColorToParent('FFFF00','000000','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="4,32,27,54" HREF="javascript: passColorToParent('000000','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="32,32,54,54" HREF="javascript: passColorToParent('C6C3C6','000000','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="58,32,80,54" HREF="javascript: passColorToParent('848284','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="86,32,107,54" HREF="javascript: passColorToParent('FFFFFF','000000','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="4,58,27,81" HREF="javascript: passColorToParent('000084','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="32,58,54,81" HREF="javascript: passColorToParent('0000FF','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="58,58,80,81" HREF="javascript: passColorToParent('008284','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="86,58,107,81" HREF="javascript: passColorToParent('00FFFF','000000','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="4,85,28,107" HREF="javascript: passColorToParent('840000','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="32,85,54,107" HREF="javascript: passColorToParent('FF0000','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="58,85,80,107" HREF="javascript: passColorToParent('840084','FFFFFF','#URL.SelItem#')">
  <AREA SHAPE="RECT" COORDS="86,86,107,107" HREF="javascript: passColorToParent('FF00FF','FFFFFF','#URL.SelItem#')">
</MAP>
</CFOUTPUT>

<SCRIPT language="JavaScript">
/*function passColorToParent(colorID,fontID,Index)
{alert(Index)
	var x = "<CFOUTPUT>#URLStr#</CFOUTPUT>";
	var replacecolorID="colorID_"+Index+"="+colorID;
	var replacefontID="fontID_"+Index+"="+fontID;
	alert(replacecolorID)
	alert(replacefontID)
	x=x+"&ColorID="+colorID+"&fontID="+fontID+"&FromColorPalette=1&Mode=2";	
	
	//window.opener.location.href ="Create_Aging.cfm?"+x;
	//window.close();
}
*/

function passColorToParent(colorID,fontID,Index)
{
	//alert(Index)
	var x = "<CFOUTPUT>#URLStr#</CFOUTPUT>";
	var replacecolorID = "colorID_" + Index + "=" + colorID;
	var replacefontID = "fontID_" + Index + "=" + fontID;
	
	var re;
	var newX = x;
	re = new RegExp("&" + "colorID_" + Index + "=[^&]*" + "&","ig");
	var newX = newX.replace(re, "&" + replacecolorID + "&");
	re = new RegExp("&" + "fontID_" + Index + "=[^&]*" + "&","ig");
	newX = newX.replace(re, "&" + replacefontID + "&");
	
	//alert(x + "\n\n" + newX + "\n\n" + replacecolorID + "\n\n" + replacefontID);
	
	newX=newX+"&FromColorPalette=1&Mode=2";	
	
	window.opener.location.href ="Create_Aging.cfm?"+newX;
	window.close();	
}

//resultString.replace(/_/ig, "-");
</SCRIPT>
</body>
</html>
