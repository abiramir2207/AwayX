<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>User Profiles XL Download</title>
</head>

<body onLoad="javascript:window.focus();" >
	<cfif url.display EQ 'none'>
	<script>
	 window.opener.parent.parent.close();
	</script>
	</cfif>
<cfparam name="url.fn" default="index.cfm">
<cfoutput>
<table cellpadding="7" align="center">
<tr>
	
	 <td>
	 <B><A HREF="javascript:getandclose()"><img src="/images/excel_icon.gif" border="0" title="Download the Xl file containing user profile data!"></A>
	</td>

	<td>
  	<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"Download XL File"
			BUTTON_ACTION	=	"javascript:getandclose()"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold"><br>
	<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"Close Window"
			BUTTON_ACTION	=	"javascript:window.close()"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">
	</td>
</tr>
</table>
		<!--- Dev Note: 9377 - Move Excel Download into Common Documents folder --->	
		<!--- Dev Note: drachala; D28054: User Profile issues  START
		What  I did:  changed the file to access_rights.csv--->
		<script language="JavaScript">
				<!-- hide
					
				function getandclose() {
	                location.href = '/getDocument.cfm?filepath=Temp_Files/Settings/Profiles/Access_Rights.csv';
				 // location.href = '/getDocument.cfm?filepath=Temp_Files/Settings/Profiles/#url.fn#.csv&FileName=Access_Rights.csv';
				  
				}
				// -->
			</script>
 </cfoutput> 


</body>
</html>
<!--- <B><FONT COLOR="Red">[</FONT>&nbsp;<A HREF="javascript:getandclose()"><img src="/images/excel_icon.gif" border="0"></A>&nbsp;<FONT COLOR="Red">]</FONT></B> --->