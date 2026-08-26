<!---
	FILENAME: 	settings/app_settings.cfm
	Copyright 	(c) 2008 Blacksmith Applications, Inc.
	CREATED: 	??/??/?? 	??
	EDITED: 	09/26/08 	RBL [16314] (may be no changes)
--->
<cfsilent>
<!------ set defaults ----->
<cfparam name="form.state"	 	default="0">
<cfparam name="url.updated" 	default="0">
<cfparam name="url.command" 	default="Settings1">
<cfparam name="url.labelMode" 	default="">
<cfparam name="url.appSetCode" default="0" />
<cfparam name="form.command" 	default="#url.command#">
<cfparam name="form.labelMode" 	default="#url.labelMode#">
<CFSET TR_BORDER_WIDTH = 2>
<CFSET TD_FORE_COLOR = "FFE083">
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "applicationSettings"
							jQueryNoConflict = "true"
							selectedIndex = "" >


    <style type="text/css">
<!--
.style1 {color: #F5F5F5}
-->
    </style>
		<style>
	td.bottoml {
	border-bottom-width: 2px;
	border-bottom-color: #c02025;
	border-bottom-style: solid;

	border-left-width: 2px;
	border-left-color: #c02025;
	border-left-style: solid;
	}
	td.bottomr {
	border-bottom-width: 2px;
	border-bottom-color: #c02025;
	border-bottom-style: solid;

	border-right-width: 2px;
	border-right-color: #c02025;
	border-right-style: solid;
	}

		td.bottomm {
	border-bottom-width: 2px;
	border-bottom-color: #c02025;
	border-bottom-style: solid;

	}

	td.topr {
	border-top-width: 2px;
	border-top-color: #c02025;
	border-top-style: solid;

	border-right-width: 2px;
	border-right-color: #c02025;
	border-right-style: solid;

	}
	td.topl {
	border-top-width: 2px;
	border-top-color: #c02025;
	border-top-style: solid;

	border-left-width: 2px;
	border-left-color: #c02025;
	border-left-style: solid;
	}
	td.topm {
	border-top-width: 2px;
	border-top-color: #c02025;
	border-top-style: solid;
	}
	td.left {
		border-left-width: 2px;
	border-left-color: #c02025;
	border-left-style: solid;
	}
	td.right {
	border-right-width: 2px;
	border-right-color: #c02025;
	border-right-style: solid;
	}
	</style>
	<script type="text/javascript" src="/script/tTip.js"></script>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
<!--- Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  START
What  I did: Added New Jquery Text Editor WYUIWYG--->
<cfparam name="url.command" default="Settings1">
<cfif isdefined("url.command") AND (#url.command# EQ 'Settings4')>
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg.js"></script>
		<script type="text/javascript" src="/Script/Editor/scripts/wysiwyg-settings.js"></script>
		<script type="text/javascript">
			WYSIWYG.attach('textarea', full);
			WYSIWYG.attach('textarea1', full);
		</script>
</cfif>
<!--- End Dev Note: drachala; D28078: Text Editor tools in Forge not working with Windows 7  --->

<span class="style1"></span>

<cfoutput>
<!--------------------------------------------------------------------------------
    Dev Notes: D18971
    Added the url querystring appSetCode here as it was throwing an error after save,
    as the value was not getting passed over again.
    - Anand Rao/13-May-09
--------------------------------------------------------------------------------->
<cfset thisPage = "app_settings.cfm?command=#form.command#&appSetCode=#url.appSetCode#">
<cfset formName = "frmAppGeneralSettings">

<!--- <cfinclude template="app_settings_header.cfm"> --->

<script language="JavaScript">
	function submitForm(thisForm, sCommand)
	{
	/* Label 9879 (Milan). To submit the "ActiveEdit control, we need to use this, as it only works by submitting the form through clicking
			the submit button */
		thisForm.command.value = sCommand;
		if (sCommand == 'Settings4')
		{
			thisForm.save.click();
		}
		else
		{
			thisForm.submit();
		}

		return false;
	}
</script>

<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">
	function validateThisField(iType, oInput, sMsg)
	{
		var isValid = true;
		switch(iType)
		{
			case 1:
			{
				isValid = isInt(oInput.value);
				break;
			}
			case 2:
			{
				isValid = !isSpace(oInput.value);
				break;
			}
		}

		var errObj = eval("document.all.err_sp_" + oInput.name);
		if(isValid)
		{
			clearQueue(errObj);
		}
		else
		{
			queueMessage(sMsg, errObj);
		}
		return isValid;
	}

</script>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<form action="#thisPage#" method="post" name="#formName#" style="display:inline;">
	<cfswitch expression="#form.command#">
		<cfcase value="Settings1">
			<cfinclude template="app_settings_1.cfm">
		</cfcase>
		<cfcase value="Settings2">
			<cfinclude template="app_settings_2.cfm">
		</cfcase>
		<cfcase value="Settings3">
			<cfinclude template="app_settings_3.cfm">
		</cfcase>
		<cfcase value="Settings4">
			<cfinclude template="app_settings_4.cfm">
		</cfcase>
		<cfcase value="Settings5">
			<cfinclude template="report_settings.cfm">
		</cfcase>
		<!--- CREATED MASS LABEL TOOL TO HANDLE ALL OF THESE LINKS Settings6 - Settings9 --->
		<cfcase value="LabelMaster">
			<cfinclude template="app_settings_label_master.cfm">
		</cfcase>
		<cfcase value="ApprovalViaEmail">
			<cfinclude template="app_settings_approval_via_email.cfm">
		</cfcase>
		<!--- Dev Notes: 21554/Anand Rao/30-Apr-10 HZ - Single sign on to application using LDAP --->
		<cfcase value="LDAPSettings">
			<cfinclude template="app_settings_LDAP.cfm">
		</cfcase>
	</cfswitch>
	<input type="Hidden" name="state" value="1">
	<input type="Hidden" name="command" value="#form.command#">
</form>
<CF_MessageWindow />
</cfoutput>

<!--- Display Brokerage Margin Calculation Settings Panel in the Margin Tab--->
<cfif form.command EQ "Settings3">
	<cfinclude template="/settings/Brokerage_Margin_Calc_Settings.cfm" >
</cfif>
<!--- update the application var application.appSettingsGet used in other templates --->
<cfinclude template="/Application_AppSettingsMan.cfm">


<cfif command eq "Settings2">
	<script>
		if(document.all.Flex_Program_Search.checked==false) {
			document.all.ExpiredRecently_ID.style.display='none';
		}
	</script>
</cfif>


</cfmodule>