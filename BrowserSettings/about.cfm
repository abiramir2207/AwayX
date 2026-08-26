<CFINCLUDE template="bsInclude.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> - Browser Settings</title>
	<CFOUTPUT><BASE TARGET="#IMGPageName#"></CFOUTPUT>
</head>

<body>
<BLOCKQUOTE>
<cfset colStr="<colgroup><col width=""#width1#"" span=""1""></col><col width=""#width2#"" span=""1""></col></colgroup>">
<CFOUTPUT>





<DIV CLASS="steps">STEP 1 - Browser Version</DIV>
<DIV CLASS="steps">IE</DIV>
<OL>
	<LI><a href="#IMGPage#?IMG=about1">Click Internet Explorer -> Help -> About Internet Explorer</a></LI>
	<LI><a href="#IMGPage#?IMG=about2">Check whether the browser version is 5.5 or above</a></LI>
	<LI><a href="#IMGPage#?IMG=about3">Check whether the Update Version is SP2 or above</a></LI>
</OL>
<DIV CLASS="steps">Chrome</DIV>
<OL>
	<LI><a href="#IMGPage#?IMG=about4">Chrome -> Help -> About Google Chrome</a></LI>
	<LI><a href="#IMGPage#?IMG=about5">Check that Google Chrome is up to date</a></LI>
</OL>



<DIV CLASS="steps"><BR>STEP 2 - <a href="index2.cfm?PG=1" target="_parent"><b>Security Settings</b></a><BR></DIV>



<DIV CLASS="steps"><BR>STEP 3 - <a href="index2.cfm?PG=2" target="_parent"><b>Advanced Settings</b></a><BR></DIV>

<a name="contents"></a>

<!------<iframe id="oIframe" name="IMG" src="#IMGPage#?IMG=about1"  style="position:absolute; top:200; left:550; width:450; height:500; z-index:1" SCROLLING="No" allowTransparency="true"></iframe>----->

</CFOUTPUT>

</BLOCKQUOTE>
</body>
</html>
