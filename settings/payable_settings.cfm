<BODY BGCOLOR="WhiteSmoke">
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
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "payable_aging_range_date_updated"
			}), "payable_aging_range_date_updated"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_This_Date = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_This_Date>
<CFQUERY NAME="Get_This_Date" datasource="#application.datasource#">
Select	PAYABLE_AGING_RANGE_Date_Updated
From	_Users_Settings
Where	User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>
</cfif>


<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
	Select		*
	From		_Users_Settings
	Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=30>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR><BR>
<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="payable_settings_Action.cfm" METHOD="post">
<CFIF Get_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_This_Date.PAYABLE_AGING_RANGE_Date_Updated, 'm/d/yyy')# #timeformat(Get_This_Date.PAYABLE_AGING_RANGE_Date_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
</CFIF>



<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>
		<B>How Many Days After The Billback Date Does A Payable Start Aging?</B>&nbsp;
		<INPUT TYPE="text" SIZE="4" NAME="payable_aging_range" VALUE="<CFIF len(Get_Settings.payable_aging_range) GT 0><CFOUTPUT>#Get_Settings.payable_aging_range#</CFOUTPUT><CFELSE>30</CFIF>">
	</TD>
</TABLE>
<BR>

<INPUT TYPE="hidden" NAME="User_ID" VALUE="<CFOUTPUT>#request.AccessStructure.User_ID#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Date_Updated" VALUE="<CFOUTPUT>#createodbcdatetime(now())#</CFOUTPUT>">

<INPUT TYPE="submit" VALUE="Save Preferences...">


</BODY>
