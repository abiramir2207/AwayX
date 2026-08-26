<!------ 
Moved the commented qcode which was here to to /index_extra_code.cfm
----->
<cfheader name="Cache-Control" value="no-store">
<cfheader name="pragma" value="no-cache">
<cfparam name="error" default="">
<cfparam name="url.closewindow" default="N0">

 <!--- <cfabort> --->
<cfif url.closewindow EQ "yes">
	<script>
		window.close();
	</script>
	<cfabort>
</cfif> 



<cfset isHttps = false>

<cfif CGI.SERVER_NAME EQ "BSA.blacksmithapps.com" or CGI.SERVER_NAME EQ "BSA.awayx.com">
	<cfset isHttps = true>
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyName#</CFOUTPUT></TITLE>
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="common_files/main_style.css">
</HEAD>

<CFPARAM NAME="error" 	DEFAULT="">
<BODY 	onLoad="checkVersion();"
		BGCOLOR=#FFFFFF			TEXT="Black"			LINK="Blue"
		VLINK="Blue"			ALINK="Red"				LEFTMARGIN="0"
		TOPMARGIN="0" 			MARGINWIDTH=0 			MARGINHEIGHT=0>

<cfset appSettings = application.appSettingsGet>
<cfif appSettings.getDisableAutoLogIn()>
	<cfset frmKey = DateFormat(now(),"ddmmyyyy")&"_"&timeformat(now(),"hhmmss")>
<cfelse>
	<cfset frmKey = 0>
</cfif>
<SCRIPT>
		function Is ()
		{   
			
			var checkFor = "MSIE";
			var MSIEIndex = navigator.appVersion.indexOf(checkFor);
			this.version = parseFloat(navigator.appVersion.substring(MSIEIndex + checkFor.length, (navigator.appVersion.length)));
		}
		
		

		function checkVersion()
		{
			var is = new Is();
			if(is.version < 5.5)
			{		
				window.location.href = '/getie.cfm';
			}
			else
			{
				document.all.bodyText.style.display='';
			}
		}
		
		function addbookmark()
		{
        	window.external.AddFavorite(location.href, document.title);
		}
		function setU()
		{
			<cfoutput>document.MyForm.u.value = document.MyForm.u#frmKey#.value;</cfoutput>
		}
		function setP(pObject,theKey)
		{
			var theString = pObject.value;
			var length	= theString.length;
			//alert(theKey+ ' :: ' + length);
			if (theKey > 31 && theKey < 128)
			{
				var realkey = String.fromCharCode(theKey)
				<cfoutput>document.MyForm.p.value = document.MyForm.p.value.substr(0,length) + realkey</cfoutput>;
				<!--- <cfoutput>document.MyForm.p.value = document.MyForm.p#frmKey#.value;</cfoutput>; --->
				
			}
		}
		function maskP(pObject,theKey)
		{
		if (theKey > 31 && theKey < 128)
			{
			var theString = pObject.value;
			var length	= theString.length;
				<cfoutput>document.MyForm.p#frmKey#.value = ''</cfoutput>;
				for (var x = 1; x <= length; x++)
				{
				  <cfoutput>document.MyForm.p#frmKey#.value = document.MyForm.p#frmKey#.value + '#chr(248)#'</cfoutput>;
				}
			}
		
		}
		function finalize() //in case the user hit the backspace as the last key prior to submit
		{
			<cfoutput>document.MyForm.p.value = document.MyForm.p.value.substr(0,document.MyForm.p#frmKey#.value.length);</cfoutput>
			
		}
	</SCRIPT>


<SPAN ID="bodyText">

<BR><BR><BR>

	

<TABLE WIDTH=784 BORDER=0 CELLPADDING=0 CELLSPACING=0 ALIGN="CENTER"  valign="top">
	<TR>

		<TD VALIGN="TOP"><IMG SRC="/images/Logon_Blacksmith/index_01.gif" WIDTH=38 HEIGHT=171 ALT=""></TD>
		<TD VALIGN="TOP"><IMG SRC="<cfoutput>#appSettings.getLoginPageLogoPath()#</cfoutput>"  ALT=""><br /><IMG SRC="/images/Logon_Blacksmith/index_05.gif" WIDTH=75 HEIGHT=178 ALT="" valign="top"></TD>
		<TD VALIGN="TOP"><IMG SRC="/images/Logon_Blacksmith/index_03.gif" WIDTH=606 HEIGHT=98 BORDER="0" USEMAP="#mymap">
	 	
			<br/><br/><br/><br/><br/><br/>
			<FONT SIZE="+1" STYLE="Align:center" FACE="Arial, Helvetica, sans-serif" COLOR="#990000">
				The Application is under maintenance. Please check back later.
			</FONT>

		</TD>
	</TR>
	<TR>
		<TD>
			<IMG SRC="/images/Logon_Blacksmith/index_07.gif" WIDTH=38 HEIGHT=104 ALT="">
		</TD>
		<TD ALIGN="CENTER">
			<cfif isHttps>
			<cfoutput><script src=https://seal.verisign.com/getseal?host_name=#CGI.HTTP_HOST#&size=S&use_flash=NO&use_transparent=YES&lang=en></script>
			</cfoutput>
			</cfif>
		</TD>
		<TD ALIGN="CENTER">&nbsp;
					
		</TD>
	</TR>	
</TABLE>			
</SPAN>

<MAP NAME="mymap">
  <AREA SHAPE="RECT" COORDS="375,75,601,93" HREF="http://www.blacksmithapps.com" TARGET="_blank">
</MAP>
</BODY>
</HTML>

	