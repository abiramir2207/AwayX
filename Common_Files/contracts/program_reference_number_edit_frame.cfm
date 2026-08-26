<!-----      
		Name: 			program_reference_number_edit_frame.cfm
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						03/20/2006
						Deepa Kunnath
		Last Modified:
						03/21/2006
						Deepa Kunnath  
		Description:
                       	This page allows users who have (profile) access to post approval status = 2, Pending ERP Entry
					   	to edit the program reference number.
					   	Will be called from inside the program.
					   
		Parameters:
                       CID - encrypted program ID
		Usage:
                       program_reference_number_edit_frame.cfm?CID=0202J8444AB6AA54B0A040441
----->

<cfparam name="URL.CID" 	default="">
<cfif URL.CID NEQ "">
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
	<CFSET Program_ID = cryp.value>
	
	<cfset program = CreateObject("component", "components.programs.program") />
	<cfset qGetProgramInfo = program.getProgramInfo(Program_ID) />
	
	<cfinclude template="/Get_Access_Profile.cfm" />
	
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<title><cfoutput>Program: Edit #application.returned_customer_setting.reference_number_label#</cfoutput></title>
	</head>
	
	<body>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	
	<!------ CHECK ACCESS PERMISSION START ----->
	<cfset postApprovalStatusReferneceNumberEditUserAccess = 0 />
	<cfset postApprovalStatusReferneceNumberEditUserAccessMessage = "" />
	<!------ If post approval status is on ----->
	<cfif appSettings.getPgmPostApprovalStatus() and appSettings.getPgmPostApprovalStatusType() NEQ 1>
		<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
		<!------ check if this program can have program reference number edit ----->
		<cfset qGetTemplateProgramPostApprovalStatus1 = ProgramPostApprovalStatusManager.getSelectedTemplateProgramPostApprovalStatus
					(templateId = qGetProgramInfo.programtype_id,
					programPostApprovalStatusId = 1) />
		<cfset qGetTemplateProgramPostApprovalStatus2 = ProgramPostApprovalStatusManager.getSelectedTemplateProgramPostApprovalStatus
					(templateId = qGetProgramInfo.programtype_id,
					programPostApprovalStatusId = 2) />
		
		<!------ whether this program has post approval status = 1 and 2, and thus enable program reference id edit ----->
		<cfif qGetTemplateProgramPostApprovalStatus1.recordCount OR qGetTemplateProgramPostApprovalStatus2.recordCount>
			<cfset programPostApprovalStatus2Desc = ProgramPostApprovalStatusManager.getProgramPostApprovalStatusDesc(statusId=2) />
			
			<!------ determine if program is locked by me ----->
			<CFSET DisAllowAccessBasedOnLockStatus = 0 />
			<CFIF qGetProgramInfo.Contract_Is_Locked EQ 1 AND qGetProgramInfo.Contract_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
				<CFSET DisAllowAccessBasedOnLockStatus = 1>
			</CFIF>
	
			<!------ If the current user do not have access to edit status = 2 ----->
			<cfif ProgramPostApprovalStatusManager.getProfileProgramPostApprovalStatusChangeAccess(request.AccessStructure.Profiles_ID, 2) NEQ 1>
				<cfset postApprovalStatusReferneceNumberEditUserAccess = 0 />
				<cfset postApprovalStatusReferneceNumberEditUserAccessMessage = "You do not have access to edit '#programPostApprovalStatus2Desc#' status" />
			<cfelseif DisAllowAccessBasedOnLockStatus NEQ 0><!------ if program is not locked ----->
				<cfset postApprovalStatusReferneceNumberEditUserAccess = 0 />
				<cfset postApprovalStatusReferneceNumberEditUserAccessMessage = "Program need to be locked" />
			<cfelse>
				<cfset postApprovalStatusReferneceNumberEditUserAccess = 1 />
				<cfset postApprovalStatusReferneceNumberEditUserAccessMessage = "" />
			</cfif>
		<cfelse><!------ else - whether this program has post approval status = 1 and 2, and thus enable program reference id edit ----->
			<cfset postApprovalStatusReferneceNumberEditUserAccess = 0 />
			<cfset postApprovalStatusReferneceNumberEditUserAccessMessage = "Program not eligible for #LCase(application.returned_customer_setting.reference_number_label)# edit" />
		</cfif>
	</cfif><!------ If post approval status is on ----->
	<!------ CHECK ACCESS PERMISSION END ----->
	
	<!------ STOP THE USER HERE ----->
	<CFIF postApprovalStatusReferneceNumberEditUserAccess EQ 0>
	<table align="center" cellpadding="4" cellspacing="0">
	<tr>
		<td style="color:red;font-weight:bold;"><cfoutput>#postApprovalStatusReferneceNumberEditUserAccessMessage#</cfoutput></td>
	</tr>
	<tr>
	<td align="center">
	<CF_smallLink 
			title = "close window" 
			url = "##"
			parameters = "onClick=""javascript: window.close();return false;"""
		>
	</td>
	</tr>
	</table>
	<cfabort>
	</CFIF>
	
	
	<script language="JavaScript">
	function saveProgramRefNumber()
	{
		var oParentForm = document.all.frmProgramRefNumberEdit;
		var bContinue = true;
		var sMsg = "";
		if(oParentForm.Contract_Reference_Number.value == "")
		{
			bContinue = false;
			sMsg = "Please enter a value for <cfoutput>#LCase(application.returned_customer_setting.reference_number_label)#</cfoutput>";
		}
		
		if(bContinue)
		{
			oParentForm.submit();
		}
		else
		{
			alert(sMsg);
		}
		return false;
	}
	</script>
	<br>
	<cfoutput>
	<form action="program_reference_number_save.cfm" method="post" name="frmProgramRefNumberEdit">
	<table align="center" cellpadding="4" cellspacing="0" border="0" width="100%">
	<caption style="font-weight:bold;font-size:14px;border-bottom:navy solid 2px;">
	Edit #application.returned_customer_setting.reference_number_label#
	</caption>	
	<colgroup>
	<col span="1" style="font-weight:bold;"></col>
	</colgroup>
	<tr>
		<td>Contract Number: </td>
		<td>[#qGetProgramInfo.Contract_Number#]</td>
	</tr>
	<tr>
		<td>Contract Title: </td>
		<td>#qGetProgramInfo.Contract_Title#</td>
	</tr>
	<tr>
		<td>#application.returned_customer_setting.reference_number_label#: </td>
		<td>#qGetProgramInfo.Contract_Reference_Number#</td>
	</tr>
	<tr>
		<td>Change #application.returned_customer_setting.reference_number_label# to: </td>
		<td><input type="Text" name="Contract_Reference_Number" value="#qGetProgramInfo.Contract_Reference_Number#" maxlength="250">
		<input type="Hidden" name="Program_ID" value="#Program_ID#">
		<input type="Hidden" name="CID" value="#URL.CID#">
		</td>
	</tr>
	</cfoutput>
	<tr>
	<td align="center" colspan="2">
	<table>
		<tr>
		<td>			
			<CF_smallLink 
				title = "save #LCase(application.returned_customer_setting.reference_number_label)#" 
				url = "##"
				parameters = "onClick=""javascript: return saveProgramRefNumber();"""
			>
		</td>
		<td align="center">
			<CF_smallLink 
					title = "close window" 
					url = "##"
					parameters = "onClick=""javascript: window.close();return false;"""
				>
		</td>
		</tr>
	</table>
	</td>
	</tr>	
	</table>
	</form>
	
	</body>
	</html>
</cfif>