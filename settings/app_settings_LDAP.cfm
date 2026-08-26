<!---
	Copyright (c)2009 Blacksmith Applications, Inc.       
	Filename:		AwayX/settings/app_settings_LDAP.cfm
	Created:		4/30/2010
	Developer:		Kal
	Description:	This page is used to set/modify the settings for LDAP
	Usage:			AwayX/components/Settings/LDAPSettingsManager.cfc
	Tip:			 
--->
 
<cfoutput>
  <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
  <cfset appSettings = genSettingsManager.get(1) />
  <cfset oLDAPSettingsManager = createObject("component", "components.settings.LDAPSettingsManager").init() />
  <cfparam name="FORM.LDAP_Settings_Updated_By" default="#request.AccessStructure.User_ID#" />
  <cfif isDefined("FORM.btnSave") AND FORM.btnSave EQ "1">
  	<cfif appSettings.getLDAP_SSO_Enabled()>
	  	<!--- LDAP --->
	  	<cfset oLDAPSettingsManager.setLDAPSettings(
	    			LDAP_Server 				=	FORM.LDAP_Server, 
	    			LDAP_Read_Username 			=	FORM.LDAP_Read_Username, 
	    			LDAP_Read_Password 			=	FORM.LDAP_Read_Password, 
	    			LDAP_Port 					=	FORM.LDAP_Port, 
	    			LDAP_SSL_Enabled 			=	FORM.chkSSLEnabledVal, 
	    			LDAP_SSL_Port 				=	FORM.LDAP_SSL_Port, 
	    			LDAP_Org_Name 				=	FORM.LDAP_Org_Name, 
	    			LDAP_Org_Unit_Name 			=	FORM.LDAP_Org_Unit_Name, 
	    			LDAP_Issue_Message 			=	FORM.LDAP_Issue_Message, 
	    			LDAP_BSA_Issue_Message 		=	FORM.LDAP_BSA_Issue_Message, 
	    			LDAP_New_User_Message 		=	FORM.LDAP_New_User_Message, 
	    			LDAP_Settings_Updated_By 	=	request.AccessStructure.User_ID) />
	  <cfelseif appSettings.getsinglesign_on() eq 2>
	    <!--- SSO-ADFS --->
	  	<cfset oLDAPSettingsManager.setLDAPSettings(
	    			LDAP_BSA_Issue_Message 		=	FORM.LDAP_BSA_Issue_Message, 
	    			LDAP_New_User_Message 		= 	FORM.LDAP_New_User_Message, 
	    			LDAP_Settings_Updated_By 	= 	request.AccessStructure.User_ID) />
	</cfif>
  </cfif> 
  
  <cfset variables.qGetLDAPSettings = oLDAPSettingsManager.getLDAPSettings() />

  <cfset strMode = "ADD" />
  <cfif (variables.qGetLDAPSettings.RecordCount GT 0)>
    <cfset strMode = "EDIT" />
    <!--- Add all the required data in the variables scope --->
    <cfset variables.LDAP_Settings_ID           =  variables.qGetLDAPSettings.LDAP_Settings_ID />
    <cfset variables.LDAP_Server                =  variables.qGetLDAPSettings.LDAP_Server />
    <cfset variables.LDAP_Read_Username         =  variables.qGetLDAPSettings.LDAP_Read_Username />
    <cfset variables.LDAP_Read_Password         =  variables.qGetLDAPSettings.LDAP_Read_Password />
    <cfset variables.LDAP_Port                  =  variables.qGetLDAPSettings.LDAP_Port />
    <cfset variables.LDAP_SSL_Enabled           =  variables.qGetLDAPSettings.LDAP_SSL_Enabled />
    <cfset variables.LDAP_SSL_Port              =  variables.qGetLDAPSettings.LDAP_SSL_Port />
    <cfset variables.LDAP_Org_Name              =  variables.qGetLDAPSettings.LDAP_Org_Name />
    <cfset variables.LDAP_Org_Unit_Name         =  variables.qGetLDAPSettings.LDAP_Org_Unit_Name />
    <cfset variables.LDAP_Issue_Message         =  variables.qGetLDAPSettings.LDAP_Issue_Message />
    <cfset variables.LDAP_BSA_Issue_Message     =  variables.qGetLDAPSettings.LDAP_BSA_Issue_Message />
    <cfset variables.LDAP_New_User_Message      =  variables.qGetLDAPSettings.LDAP_New_User_Message />
    <cfset variables.LDAP_Settings_Updated_By   =  variables.qGetLDAPSettings.LDAP_Settings_Updated_By />
    <cfset variables.LDAP_Settings_Updated_Date =  variables.qGetLDAPSettings.LDAP_Settings_Updated_Date />
    <cfset variables.Name_First                 =  variables.qGetLDAPSettings.Name_First />
    <cfset variables.Name_Last                  =  variables.qGetLDAPSettings.Name_Last />
  </cfif> 
 
<style>
	.appSettingsInput
	{
		text-align:right;
		width:50px;
	}
	.appSettingsInputLong
	{
		text-align:left;
		width:150px;
	}	
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">

 function validateAndSubmit(thisForm)
	{
		/* Start validating the LDAP settings before submitting them */ 
		ErrorCount = 0
		<!--- BEGIN: DEV NOTE: D25717 KAL: display and validate the following only when LDAP is on*/ --->
		<cfif appSettings.getLDAP_SSO_Enabled()>
    	if (trim(document.all.LDAP_Server.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP server cannot be blank", document.all.err_LDAPServer);
		}
		else
		{
			clearQueue(document.all.err_LDAPServer);
		}
    	if (trim(document.all.LDAP_Read_Username.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP Username cannot be blank", document.all.err_LDAPReadUsername);
		}
		else
		{
			clearQueue(document.all.err_LDAPReadUsername);
		}
    
    	if (trim(document.all.LDAP_Read_Password.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP Password cannot be blank", document.all.err_LDAPReadPassword);
		}
		else
		{
			clearQueue(document.all.err_LDAPReadPassword);
		}    
  
    	if (trim(document.all.LDAP_Port.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP Port cannot be blank", document.all.err_LDAPPort);
		}
		else
		{
			clearQueue(document.all.err_LDAPPort);
		}       
    
    	if (trim(document.all.LDAP_SSL_Port.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP SSL Port cannot be blank", document.all.err_LDAPSSLPort);
		}
		else
		{
			clearQueue(document.all.err_LDAPSSLPort);
		} 
    
    	if (trim(document.all.LDAP_Org_Name.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP Organization Name cannot be blank", document.all.err_LDAPOrgName);
		}
		else
		{
			clearQueue(document.all.err_LDAPOrgName);
		}     
    	if (trim(document.all.LDAP_Org_Unit_Name.value) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP Organizationl Unit Name cannot be blank", document.all.err_LDAPOrgUnitName);
		}
		else
		{
			clearQueue(document.all.err_LDAPOrgUnitName);
		}      
    	//if (trim(document.all.LDAP_Issue_Message.value) == "") CHROMEFIX
		if (trim(jQuery("textarea[name=LDAP_Issue_Message]").val()) == "")
    	{
			ErrorCount++;
			queueMessage("LDAP Issue Message cannot be blank", document.all.err_LDAPIssueMessage);
		}
		else
		{
			clearQueue(document.all.err_LDAPIssueMessage);
		}      
		if(document.all.LDAP_SSL_Enabled.checked  == true)
	    {
	      document.all.chkSSLEnabledVal.value=1;
	    }
	    else
	    {
	    document.all.chkSSLEnabledVal.value=0;
	    }		
		</cfif> 
		<!--- END: DEV NOTE: D25717 KAL: display and validate the following only when LDAP is on --->
    	//if (trim(document.all.LDAP_BSA_Issue_Message.value) == "") CHROMEFIX
		if (trim(jQuery("textarea[name=LDAP_BSA_Issue_Message]").val()) == "")
    	{
			ErrorCount++;
			queueMessage("BSA Issue Message cannot be blank", document.all.err_LDAPBSAIssueMessage);
		}
		else
		{
			clearQueue(document.all.err_LDAPBSAIssueMessage);
		}  
    	//if (trim(document.all.LDAP_New_User_Message.value) == "") CHROMEFIX
		if (trim(jQuery("textarea[name=LDAP_New_User_Message]").val()) == "")
    	{
			ErrorCount++;
			queueMessage("New User Message cannot be blank", document.all.err_LDAPNewUserMessage);
		}
		else
		{
			clearQueue(document.all.err_LDAPNewUserMessage);
		}    
	    
        
		if(ErrorCount == 0)
		{
			document.all.btnSave.value="1";
			submitForm(thisForm, "LDAPSettings");
		}
		else 
		{
			showMessageWindow()
		}
				
	} 
</script>
<br>
<cfif isDefined("variables.LDAP_Settings_Updated_By") AND Len(variables.LDAP_Settings_Updated_By) GT 0>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
		<TR>
			<TD>
				<FONT SIZE="2"><B>The settings were last updated on #dateformat(variables.LDAP_Settings_Updated_Date, 'mm/dd/yyyy')# #timeformat(variables.LDAP_Settings_Updated_Date, 'hh:mm:ss TT')# by #variables.Name_First# #Name_Last#</B></FONT>	</TD>
			</TD>
		</TR>
	</TABLE>
	<br>
</cfif>
 
<table cellpadding="2" cellspacing="0" border="0" width="700">
	<!--- BEGIN: DEV NOTE: D25717 KAL: display and validate the following only when LDAP is on --->
	<cfif appSettings.getLDAP_SSO_Enabled()>
	<tr>
		<td>LDAP Server:</td>
		<td><span id="err_LDAPServer">&nbsp;&nbsp;</span></td>
		<td align="left" width="180"><input class="appSettingsInputLong" type="Text" name="LDAP_Server" <cfif strMode EQ "EDIT">value="#variables.LDAP_Server#"</cfif> maxlength="100"></td>
		<td>LDAP Read Username:</td>
		<td><span id="err_LDAPReadUsername">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="Text" name="LDAP_Read_Username" <cfif strMode EQ "EDIT">value="#variables.LDAP_Read_Username#"</cfif> maxlength="50"></td>
		</tr>	
	<tr>
		<td>LDAP Port:</td>
		<td><span id="err_LDAPPort">&nbsp;&nbsp;</span></td>
		<td align="left"><input type="Text" name="LDAP_Port" onKeyUp="clenseText(this, '0123456789');" <cfif strMode EQ "EDIT">value="#variables.LDAP_Port#"</cfif> maxlength="5" size="5"></td>
			<td>LDAP Read Password:</td>
		<td><span id="err_LDAPReadPassword">&nbsp;&nbsp;</span></td>
		<td align="left"><input class="appSettingsInputLong" type="password" name="LDAP_Read_Password" <cfif strMode EQ "EDIT">value="#variables.LDAP_Read_Password#"</cfif> maxlength="50"></td>
	</tr>	
	<tr>
		<td>LDAP SSL Enabled?:</td>
		<td><span id="err_LDAPSSLEnabled">&nbsp;&nbsp;</span></td>
		<td align="left"><input type="checkbox" name="LDAP_SSL_Enabled"  <cfif strMode EQ "EDIT" AND variables.LDAP_SSL_Enabled EQ 1>checked</cfif>>  <input type="hidden" name="chkSSLEnabledVal" /> </td>
		<td>LDAP Organization Name:</td>
		<td><span id="err_LDAPOrgName">&nbsp;&nbsp;</span></td>
		<td align="left"><input type="Text" name="LDAP_Org_Name" class="appSettingsInputLong" <cfif strMode EQ "EDIT">value="#variables.LDAP_Org_Name#"</cfif> maxlength="100"></td>
	</tr>	
	<tr>
		<td>LDAP SSL Port:</td>
		<td><span id="err_LDAPSSLPort">&nbsp;&nbsp;</span></td>
		<td align="left"><input  align="left" type="Text" name="LDAP_SSL_Port" onKeyUp="clenseText(this, '0123456789');" <cfif strMode EQ "EDIT">value="#variables.LDAP_SSL_Port#"</cfif> maxlength="5" size="5"></td>
		<td width="150" nowrap>LDAP Organizational Unit Name:</td>
		<td><span id="err_LDAPOrgUnitName">&nbsp;&nbsp;</span></td>
		<td align="left"><input type="Text" name="LDAP_Org_Unit_Name" class="appSettingsInputLong" <cfif strMode EQ "EDIT">value="#variables.LDAP_Org_Unit_Name#"</cfif> maxlength="100"></td>
	</tr>	
	<tr>
		<td  valign="top" nowrap>LDAP Issue Message:</td>
		<td><span id="err_LDAPIssueMessage">&nbsp;&nbsp;</span></td>
		<td align="left" colspan="4">
	  	<textarea  name="LDAP_Issue_Message" cols="105" rows="5" ><cfif strMode EQ "EDIT">#variables.LDAP_Issue_Message#</cfif></textarea></td>
	</tr>
	</cfif>
	<!--- END: DEV NOTE: D25717 KAL: display and validate the following only when LDAP is on --->
	<tr>
		<td valign="top" nowrap>BSA Issue Message:</td>
		<td><span id="err_LDAPBSAIssueMessage">&nbsp;&nbsp;</span></td>
		<td align="left" colspan="4">
	  	<textarea  name="LDAP_BSA_Issue_Message" cols="105" rows="5"><cfif strMode EQ "EDIT">#variables.LDAP_BSA_Issue_Message#</cfif></textarea></td>
	</tr>	  
	<tr>
		<td valign="top" nowrap>New User Message:</td>
		<td><span id="err_LDAPNewUserMessage">&nbsp;&nbsp;</span></td>
		<td align="left" colspan="4">
		<textarea   name="LDAP_New_User_Message" cols="105" rows="5"><cfif strMode EQ "EDIT">#variables.LDAP_New_User_Message#</cfif></textarea></td>
	</tr>	
	<tr>
		<td colspan="6">
			<input type="hidden" name="btnSave" value="0" />

			<br><br>
			<div align="center">
				<CF_button
						button_name		=	""
						button_caption	=	"Save"
						button_action	=	"validateAndSubmit(document.#formName#);"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Save"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						>
			</div>
		</td>
	</tr>
</table>
</cfoutput>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
