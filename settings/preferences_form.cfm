<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the user settings from the database to be used by all tabs								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForGet_Settings>
	<cftry>
		<cfset Get_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.User_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Settings>
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
Select		*
From		_Users_Settings
Where		User_ID		=		'#request.AccessStructure.User_ID#'
</CFQUERY>
</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the date that this setting was updated													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_This_Date = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForGet_This_Date>
	<cftry>
		<cfset Get_This_Date = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "prefered_uom_date_updated"
			}), "prefered_uom_date_updated"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_This_Date = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_This_Date>
<CFQUERY NAME="Get_This_Date" datasource="#application.datasource#">
Select	Prefered_UOM_Date_Updated
From	_Users_Settings
Where	User_ID		=		'#request.AccessStructure.User_ID#'
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=26>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>


<FORM ACTION="/settings/preferences_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">


<!--- Set the update/save flag that will be passed to the next page --->
<CFIF Get_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_This_Date.Prefered_UOM_Date_Updated, 'm/d/yyy')# #timeformat(Get_This_Date.Prefered_UOM_Date_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>


<b>What is your prefered Unit of Measurement:</b></font><BR><BR>
	<FONT SIZE="2">
	Cases	<INPUT TYPE="radio" NAME="Prefered_UOM" VALUE="1"<CFIF Get_Settings.Prefered_UOM EQ 1 OR Get_Settings.recordcount EQ 0> CHECKED<CFELSE></CFIF>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Gallons	<INPUT TYPE="radio" NAME="Prefered_UOM" VALUE="3"<CFIF Get_Settings.Prefered_UOM EQ 3> CHECKED<CFELSE></CFIF>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Pounds	<INPUT TYPE="radio" NAME="Prefered_UOM" VALUE="2"<CFIF Get_Settings.Prefered_UOM EQ 2> CHECKED<CFELSE></CFIF>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Liters	<INPUT TYPE="radio" NAME="Prefered_UOM" VALUE="4"<CFIF Get_Settings.Prefered_UOM EQ 4> CHECKED<CFELSE></CFIF>>
	</FONT>

	
	<INPUT TYPE="hidden" NAME="Date_Updated" VALUE="<CFOUTPUT>#createodbcdatetime(now())#</CFOUTPUT>">
	
	
	<BR><BR><BR><INPUT TYPE="Submit" VALUE="Save Preferences...">
	
</FORM>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



