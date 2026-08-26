<!--- First collect all the required variables --->
<!--- 
<PRE>
<CFOUTPUT>
<B>Variables being passed to the fax/email page</B>
program number: #CSLGetContractInfo.Contract_Number#
programnam:     #CSLGetContractInfo.Contract_Title#
</CFOUTPUT>
</PRE>
 --->
 
<!--- encrypt the contract main ID --->
<cfparam name="FromFlex" default="0">
<cfparam name="Action" default="">
<cfparam name="bHideMarketPrice" default="0">
<!---D108099 - 8.1 Upgrade: Event error when viewing EZ Rates in Template: default var variable --->
<cfparam name="var" default="">


<cf_cryp	type = "en" string = "#URL.Contract_Main_ID#" key = "#request.key#">
<CFSET Encoded_Contract_Main_ID=cryp.value>

<!--- If the request is from Flex, do the actions which are already done when clicking on program summary page.
			Since we are not requesting the actions from the program summary page, we need to do this now.
			Here we are trying to replicate email/print/copy as if being done from the Program Left NAV.
			Also, we do not want the section of code below to execute when we view the summary page from Flex.
--->
<cfif (FromFlex eq 1 AND (Action eq "print" OR Action eq "email")) or bHideMarketPrice neq 0>
	<CFSET CSL_Contract_Main_ID = URL.Contract_Main_ID>

<cfinclude template="/common_files/contracts/commonqueries.cfm" />
<cfsavecontent variable = "var">
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
</cfsavecontent>
</cfif>

<cfif FromFlex eq 1  AND Action eq "copy">
<!--- We do not need  "thin_contract_general_display.cfm" for copy. Also, we only need the query below for Copy and not
			all the queries in /common_files/contracts/commonqueries.cfm
--->
	<cfset useLakebaseForGetSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetSettings>
	<cftry>
		<cfset GetSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#URL.Contract_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSettings>
<cfquery name="GetSettings" datasource="#application.datasource#">
		SELECT *
		FROM 
		Program_Control_Panel_Options
	WHERE 
		ProgramControl_Panel_Options_ID = '#URL.Contract_Main_ID#'
	</cfquery>
</cfif>
</cfif>

<!---(start) We do not need any of the code below for copy --->
<cfif Action neq "copy">

<!--- Date/Time stamp construction to be used int he naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- Build file name --->
<CFSET filename_email	=	"#CSLGetContractInfo.Contract_Number#_#datetimestamp#_#gettickcount()#">

<!--- get install path --->
<!--- END get install path --->
<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & "\temp_files\contracts\contract_documents\#filename_email#.htm">
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath_email=The_File_Location>

<!--- Encrypt the path of the file --->
<cf_cryp	type = "en" string = "#completepath_email#" key = "#request.key#">
<CFSET Encoded_completepath_email=cryp.value>

<CFSET FinalVarForEmailFax = var>

<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "<a[^>]*?>", "", "All")>
<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "</a>", "", "All")>
<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "<!--attachmentstart-->.*?<!--attachmentend-->", "", "All")>

<!--- Save the file to the server --->
<cffile action="write" file="#completepath_email#" output="#FinalVarForEmailFax#">

</cfif>
<!---(end) We do not need any of the code below for copy --->

<!--- If the request if from Flex --->
<cfif FromFlex eq 1>
	<cfif Action neq "copy">
		<!---(start) We do not need the line below for copy --->
		<cf_cryp	type = "en" string = "#filename_email#" key = "#request.key#">
	</cfif>
	<CFSET Program_Number=cryp.value>

	<!--- Print --->
	<cfif Action eq "print">
		<cflocation url="printer_friendly.cfm?id=#Program_Number#">

	<!--- Email --->
	<cfelseif Action eq "email">
		<cflocation url="contract_email_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#">

	<!--- Copy --->
	<cfelseif Action eq "copy">

		<FORM ACTION="contract_renewal_action.cfm" METHOD="post" NAME="RenewForm" ID="RenewForm">
			<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#Encoded_Contract_Main_ID#</CFOUTPUT>">
			<INPUT TYPE="hidden" NAME="EZTemplate" VALUE="<cfoutput>#GetSettings.EZButton_on#</cfoutput>">
			<!--- These are needed for revision only (Not being used here, for now ) --->
			<INPUT TYPE="hidden" NAME="IsRevisionOfExistingContract" VALUE="0">
			<input TYPE="hidden" name="contract_reference_number" value="">
			<!--- This are needed for rollover only (Not being used here, for now )--->
			<INPUT TYPE="hidden" NAME="IsRollOver" VALUE="0" >
			<INPUT TYPE="hidden" NAME="IsCopyProgram" VALUE="1" >
		</FORM>

	<script language="javascript">
		document.all.RenewForm.submit();
	</script>
	</cfif>
</cfif>
