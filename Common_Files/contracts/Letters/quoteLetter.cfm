<cfparam name="URL.Email" default="0">

<cfif NOT isDefined('URL.Contract_Main_ID')>
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
	<CFSET url.Contract_Main_ID = cryp.value>
</cfif>

<!---email mode is off - starts a new pop-up page--->
<cfif URL.Email eq 0>
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!---------------------------------------------------------------------------------------------------------------------
	      Template: \Common_Files\contracts\Letters\quoteLetter.cfm
	      Date:     Sep 1, 2011
	      Author:   Chris Nguyen
	      Purpose:  Generate Quote Letter

	      Required parameter:
	      - URL.Contract_Main_ID (integer)
	      - URL.Email (bit) 1 = email quote letter
				- URL.All_Distributors - if this parameter exists put all distributors on letter
	----------------------------------------------------------------------------------------------------------------------->
	<html lang="en">
	<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8">
	<title>Quote Letter</title>
	<link href="/common_files/print.css" rel="stylesheet" type="text/css" media="print">

	</head>
	<body>
</cfif>

<cfscript>
  vars = StructNew();
  vars.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
  vars.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');

  vars.qOperators = vars.programCFC.getOperators( URL.Contract_Main_ID );
  vars.qFixedPricedItems = vars.programCFC.getFixedPriceOnEmail( URL.Contract_Main_ID );
  vars.qFixedAllowances = vars.programCFC.getRebateOnEmail( URL.Contract_Main_ID );
</cfscript>
<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
        method="isEnabled"
        returnVariable="busSegMgr.isEnabled">
</cfinvoke>
<cfset vars.qDistributors = vars.programCFC.getDistributors( URL.Contract_Main_ID, busSegMgr.isEnabled, false )>

<!---30297 - include only selected distributors --->
<cfif not StructKeyExists(URL, "All_Distributors")>
  <cfquery name="vars.qDistributors" dbtype="query">
  	SELECT *
 	    FROM vars.qDistributors
 	   WHERE Is_On_Quote_Letter = 1
  </cfquery>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<cfquery name="vars.qProgram" Datasource="#application.datasource#">
  SELECT   Contract_Title
         , Contract_Number
         , Contract_Created_Date
         , Effective_Start_Date
         , Effective_End_Date
         , RSP_Name = _Users.Name_First + ' ' + _Users.Name_Last
         , RSP_Phone = _Users.Work_Phone_1 + ' ' + _Users.Work_Phone_2 + ' ' + _Users.Work_Phone_3
         , RSP_Email = _Users.User_Email
         , Creator = _Users2.Name_First + ' ' + _Users2.Name_Last
         , ProgramType_ID
         , pcpo.generic_type        <!--- 55724 --->
    FROM Contract_Main
    INNER JOIN _Users ON Contract_Main.Responsible_user_ID = _Users.User_ID
    INNER JOIN _Users _Users2 ON Contract_Main.Creator_ID = _Users2.User_ID
    INNER JOIN  Program_Control_Panel_Options pcpo
                ON (Contract_Main.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID)
   WHERE Contract_Main.Contract_Main_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
</cfquery>
</cfoutput>
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->

<cfif vars.appSettings.getlettersavailable() eq 3>   <!---Hormel quote letter --->
  <cfinclude template="quoteLetter/custom2.cfm">
<cfelseif vars.appSettings.getlettersavailable() eq 4>   <!---Kraft quote letter--->
  <cfinclude template="quoteLetter/custom3.cfm">
</cfif>

<cfif URL.Email neq 1>
	</body>
	</html>
</cfif>