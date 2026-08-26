<cfset useLakebaseForGeneralSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGeneralSettings>
	<cftry>
		<cfset GeneralSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"limit" = "1",
				"select" = "use_discount_id"
			}), "use_discount_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGeneralSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGeneralSettings>
<cfquery name="GeneralSettings" datasource="#application.datasource#">
SELECT TOP 1 Use_Discount_ID
FROM General_Settings
</cfquery>
</cfif>

<CFOUTPUT>
<CFSET PAGETITLE = "DISCOUNT IDENTIFICATION CODES">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="discount_id_component.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif GeneralSettings.Use_Discount_ID IS 1>
<!---Turning it off--->
<form name="Remove" action="turn_on_off_action.cfm" method="post">
	<input type="hidden" name="action" value="remove">
	<table>
		<TR>
			<TD><B>Are you sure you want to turn off Discount Type identification? All relationships you have created will be permanently deleted, and cannot be recovered.</B></TD>
			
		</TR>		
	
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Turn discount identification off"
					button_action	=	"Remove.submit();"
					button_type		=	"javascript_link"
					button_width	=	"300"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	
	</table>
	</form>

<cfelse>
<!---Turning it on--->
	<form name="AddFirstID" action="turn_on_off_action.cfm" method="post">
	<input type="hidden" name="action" value="add">
	<table>
		<TR>
			<TD ALIGN="right"><B>Discount ID Number:</B></TD>
			<TD><INPUT NAME="Discount_ID_Number" TYPE="text" SIZE="25" MAXLENGTH="25"></TD>
		</TR>		
		<TR>
			<TD ALIGN="right"><B>Discount ID Description:</B></TD>
			<TD><INPUT NAME="Discount_ID_Desc" TYPE="text" SIZE="25" MAXLENGTH="50"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"AddFirstID.submit();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
		<tr><td colspan="2">Until you change it, this will be the default identifier for all program templates.</td></tr>
	</table>
	</form>
</cfif>

</body></html>