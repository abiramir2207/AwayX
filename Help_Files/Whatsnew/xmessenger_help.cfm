<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<script language="JavaScript">
	function MM_findObj(n, d) { //v3.0
	  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
	    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
	  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
	  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document); return x;
	}
	
	function MM_showHideLayers() { //v3.0
	  var i,p,v,obj,args=MM_showHideLayers.arguments;
	  for (i=0; i<(args.length-2); i+=3) if ((obj=MM_findObj(args[i]))!=null) { v=args[i+2];
	    if (obj.style) { obj=obj.style; v=(v=='show')?'visible':(v='hide')?'hidden':v; }
	    obj.visibility=v; }
	}
</script>

<STYLE>
	.mystyle
		{
			position:absolute;
			z-index:1; 
			border: 1px none #000000; 		visibility: hidden;
		}

</STYLE>

<BR>

<CENTER>
<FONT COLOR="Red"><B>click the numbered bullet to view an explanation</B></FONT>

<MAP NAME="xmessenger">
	<AREA ALT="" SHAPE="CIRCLE" COORDS="12,22,9" HREF="#" ONCLICK="MM_showHideLayers('one','','show','two','','hide','three','','hide','four','','hide','five','','hide','six','','hide')">
	<AREA ALT="" SHAPE="CIRCLE" COORDS="12,42,9" HREF="#" ONCLICK="MM_showHideLayers('one','','hide','two','','show','three','','hide','four','','hide','five','','hide','six','','hide')">
	<AREA ALT="" SHAPE="CIRCLE" COORDS="12,209,9" HREF="#" ONCLICK="MM_showHideLayers('one','','hide','two','','hide','three','','show','four','','hide','five','','hide','six','','hide')">
	<AREA ALT="" SHAPE="CIRCLE" COORDS="366,31,9" HREF="#" ONCLICK="MM_showHideLayers('one','','hide','two','','hide','three','','hide','four','','show','five','','hide','six','','hide')">
	<AREA ALT="" SHAPE="CIRCLE" COORDS="366,132,9" HREF="#" ONCLICK="MM_showHideLayers('one','','hide','two','','hide','three','','hide','four','','hide','five','','show','six','','hide')">
	<AREA ALT="" SHAPE="CIRCLE" COORDS="366,232,9" HREF="#" ONCLICK="MM_showHideLayers('one','','hide','two','','hide','three','','hide','four','','hide','five','','hide','six','','show')">
</MAP>
<IMG SRC="/images/xmessenger_help.gif" WIDTH="378" HEIGHT="262" BORDER="0" USEMAP="#xmessenger">
</CENTER>



<BR>

<DIV ID="one" CLASS="mystyle" STYLE="visibility: visible;"><FONT SIZE="+1"><FONT COLOR="Red" SIZE="4"><B>1 - </B></FONT>Click to here to connect/call a user.</FONT></DIV>
<DIV ID="two" CLASS="mystyle"><FONT SIZE="+1"><FONT COLOR="Red" SIZE="4"><B>2 - </B></FONT>Select the user that you would like to connect to.</FONT></DIV>
<DIV ID="three" CLASS="mystyle"><FONT SIZE="+1"><FONT COLOR="Red" SIZE="4"><B>3 - </B></FONT>Type the message that you would like to send.</FONT></DIV>
<DIV ID="four" CLASS="mystyle"><FONT SIZE="+1"><FONT COLOR="Red" SIZE="4"><B>4 - </B></FONT>Click here to close the Xmessenger.</FONT></DIV>
<DIV ID="five" CLASS="mystyle"><FONT SIZE="+1"><FONT COLOR="Red" SIZE="4"><B>5 - </B></FONT>The main message area.</FONT></DIV>
<DIV ID="six" CLASS="mystyle"><FONT SIZE="+1"><FONT COLOR="Red" SIZE="4"><B>6 - </B></FONT>Click here to send the typed message.</FONT></DIV>




</BODY>
</HTML>
