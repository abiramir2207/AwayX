<cfif isDefined("blnSubmit")>

	<cfquery name="UpdateSettings" datasource="#application.datasource#">
	UPDATE General_Settings
	SET Login_Attempts = #Form.LoginTries#,
		LA_Changed_Date = #Now()#,
		LA_Changed_By = '#request.AccessStructure.User_ID#'
	</cfquery>

</cfif>

<CFSET pagetitle = "SYSTEM ADMINISTRATION: LOGIN ATTEMPTS">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><Cfoutput>#PageTitle#</CFOUTPUT></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">


<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset useLakebaseForGetCurrentSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGetCurrentSetting>
	<cftry>
		<cfset GetCurrentSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "login_attempts,la_changed_date,la_changed_by"
			}), "login_attempts,la_changed_date,la_changed_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrentSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrentSetting>
<cfquery name="GetCurrentSetting" datasource="#application.datasource#">
Select		Login_Attempts, LA_Changed_Date, LA_Changed_By
From		General_Settings
</cfquery>
</cfif>

<cfset useLakebaseForGetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserName>
	<cftry>
		<cfset GetUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#GetCurrentSetting.LA_Changed_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserName>
<cfquery name="GetUserName" datasource="#application.datasource#">
SELECT Name_First, Name_Last
FROM _Users
WHERE User_ID = '#GetCurrentSetting.LA_Changed_By#'
</cfquery>
</cfif>

<BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<p></p>

	<!---Displays who last updated this information and when--->
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(GetCurrentSetting.LA_Changed_Date,  'm/d/yyy')# #timeformat(GetCurrentSetting.LA_Changed_Date, 'h:mm:ss TT')# by #GetUserName.Name_First#  #GetUserName.Name_Last#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE> 


<form action="login_attempts.cfm" method="post" name="LoginAttempts">
<table><tr><td>
Select the number of times you want a user to be able to try to log in before they are locked out of their account:</td>
<td>
<select name="LoginTries">
<cfoutput query="GetCurrentSetting">
<option value="1" <cfif Login_Attempts IS 1> selected</cfif>>1</option>
<option value="2" <cfif Login_Attempts IS 2> selected</cfif>>2</option>
<option value="3" <cfif Login_Attempts IS 3> selected</cfif>>3</option>
<option value="4" <cfif Login_Attempts IS 4> selected</cfif>>4</option>
<option value="5" <cfif Login_Attempts IS 5> selected</cfif>>5</option>
<option value="6" <cfif Login_Attempts IS 6> selected</cfif>>6</option>
<option value="7" <cfif Login_Attempts IS 7> selected</cfif>>7</option>
<option value="8" <cfif Login_Attempts IS 8> selected</cfif>>8</option>
<option value="9" <cfif Login_Attempts IS 9> selected</cfif>>9</option>
<option value="10" <cfif Login_Attempts IS 10> selected</cfif>>10</option>
</cfoutput>
</select>
<input type="hidden" name="blnSubmit" value="1">
</td></tr>
<tr>
<td colspan="2" align="Center">&nbsp;
<CF_button
		button_name		=	""
		button_caption	=	"Change..."
		button_action	=	"LoginAttempts.submit();"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</td>
 </tr></table>
</form>

</BODY>
</HTML>