<!---
Document Name:	rebill_letter.cfm
Directory:		/deductions/settings
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	November 5, 2003

Letter sent with rebill
--->

<cfset error="">

<!---If the form has been submitted--->
<cfif isDefined("form.blnSubmit")>

	<cfif up_sv IS 1>
	
		<cfset useLakebaseForUpdateSettings1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill")>
		<cfif useLakebaseForUpdateSettings1>
			<cftry>
				<cfset application.oLakebase.updateRows("dd_rebill",
					{ "dd_rebill_id" = "eq.#DD_Rebill_ID#" },
					{
						"dd_rebill_text" = DD_Rebill_Text,
						"changed_by" = request.AccessStructure.user_ID,
						"changed_on" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateSettings1 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateSettings1>
		<cfquery name="UpdateSettings" datasource="#application.datasource#">
		UPDATE DD_Rebill
		SET DD_Rebill_Text 	= 	'#DD_Rebill_Text#',
			Changed_By 		= 	'#request.AccessStructure.user_ID#',	
			Changed_On		=	#now()#
		WHERE DD_Rebill_ID = #DD_Rebill_ID#
		</cfquery>
		</cfif>

	<cfelse>
	
	<cfset useLakebaseForUpdateSettings2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill")>
	<cfif useLakebaseForUpdateSettings2>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_rebill", {
				"dd_rebill_text" = DD_Rebill_Text,
				"changed_by" = request.AccessStructure.user_ID,
				"changed_on" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateSettings2 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateSettings2>
	<cfquery name="UpdateSettings" datasource="#application.datasource#">
		INSERT INTO DD_Rebill
		(
			DD_Rebill_Text,
			Changed_By,
			Changed_On
		)
		VALUES
		(
			'#DD_Rebill_Text#',
			'#request.AccessStructure.user_ID#',
			#now()#
		)
		</cfquery>
	</cfif>
	</cfif>

</cfif>
<!---End form has been submitted logic--->

<HTML>
<HEAD>
	<TITLE>Rebill Letter</TITLE>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFSET pagetitle = "Deviation Settings">

<!---Displays the page title set above--->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!--- Gets the date that this setting was updated --->
<cfset useLakebaseForGet_Rebill = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill")>
<cfif useLakebaseForGet_Rebill>
	<cftry>
		<cfset Get_Rebill = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_rebill", {})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Rebill = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Rebill>
<CFQUERY NAME="Get_Rebill" DATASOURCE="#application.datasource#">
SELECT * FROM DD_Rebill
</CFQUERY>
</cfif>


<cfif len(trim(Get_Rebill.Changed_By)) GT 0>
	<cfset useLakebaseForGetChangerName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
	<cfif useLakebaseForGetChangerName>
		<cftry>
			<cfset GetChangerName = application.oLakebase.toQuery(
				application.oLakebase.selectRows("_users", {
					"select" = "name_first,name_last",
					"user_id" = "eq.#Get_Rebill.Changed_By#"
				}),
				"name_first,name_last"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetChangerName = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetChangerName>
	<cfquery name="GetChangerName" datasource="#application.datasource#">
		SELECT Name_First, Name_Last FROM _Users WHERE User_ID = '#Get_Rebill.Changed_By#'
	</cfquery>
	</cfif>
	<cfset FirstName = GetChangerName.Name_First>
	<cfset LastName = GetChangerName.Name_Last>
<cfelse>
	<cfset FirstName="Not Yet">
	<cfset LastName="Changed">
</cfif>

<div align="center">
<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="rebill_letter.cfm" METHOD="post" name="Rebill" ENCTYPE="application/x-www-form-urlencoded">

<!---Hidden boolean, which, if defined, tells me that the form has been submitted--->
<input type="hidden" name="blnSubmit" value="1">


<CFIF Get_Rebill.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">


	<!---Displays who last updated this information and when--->

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_Rebill.Changed_On,  'm/d/yyy')# #timeformat(Get_Rebill.Changed_On, 'h:mm:ss TT')# by #FirstName#  #LastName#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>

</CFIF>


<!---Majority of form goes here--->

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0">
		<tr><Td>Details on the rebill, such as dollar amounts, will be shown immediately above this text. Include generic information that should be sent every time rebilling happens here.
	<!--- 
				Dev Notes: D24468/Anand Rao/17-Aug-10
				URL on email notifications
	--->  
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
			
		<CF_ACTIVEDIT 
	NAME="DD_Rebill_Text"
	TOOLBAR="cut,copy,paste,|,undo,redo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers"
	IMAGEPATH="#APPLICATIONPATH#/images/"
	IMAGEURL="/images/"
	BASEURL="#siteURL#/"
	INC="/Customtags/ActiveEdit/activedit/inc/"
	DEFAULTFONT="12pt Times New Roman"
	QUICKSTYLES="title,header"
	TABVIEW="0"
	ACTIVSCAN="0"
	ALLOWEDITSOURCE="no"
	HEIGHT=400
	WIDTH=600>
		<cfoutput>#Get_Rebill.DD_Rebill_Text#</cfoutput>
</CF_ACTIVEDIT>

		<input type="Submit" value="Save this letter">
		<input type="hidden" name="DD_Rebill_ID" value="<cfoutput>#Get_Rebill.DD_Rebill_ID#</cfoutput>">
		</TD></tr>
	</TABLE>
</form>
</div>	

</BODY>
</HTML>
