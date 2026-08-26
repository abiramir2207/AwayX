<cf_cryp type="de" string ="#FORM.Program_ID#" key="#request.key#">
<cfparam name="Scheduled" default="0">
<!--- Dev Note: Clay 10613   --->
<CFPARAM name="form.NewSearchSequence" default="0">
<CFPARAM name="form.suppressProductsDistributors" default="0">
<CFPARAM name="form.New_Business_Segment" default="0">
<CFPARAM name="form.New_Spending_Category" default="0">
<CFPARAM name="form.legacy_id" default="">
<CFPARAM name="form.start_date" default="">
<CFPARAM name="form.end_date" default="">
<CFPARAM name="form.contract_reference_number" default="" />
<CFPARAM name="form.IsCopyProgram" default="0">
<CFPARAM name="form.Limited_Revise" default="0">
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif scheduled eq 0>
	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</cfif>

<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
SELECT     dbo.Program_Control_Panel_Options.Active, dbo.Program_Control_Panel_Options.Deleted, dbo.Contract_Main.Parent_Revised_Contract_Main_ID,
                      dbo.Contract_Main.Revision_of_Contract_Main_ID, dbo.Contract_Main.Contract_Status_Type_IDX, First_Parent_ID, Contract_Main.Best_Plan_Program
FROM         dbo.Contract_Main
INNER JOIN dbo.Program_Control_Panel_Options
ON                dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
WHERE dbo.Contract_Main.Contract_Main_ID = '#cryp.value#'
</CFQUERY>
<!---60308	Best Plans Enhancement START--->
<cfset showRSPdropdown = 0>
<cfif form.IsCopyProgram AND getProgramTemplateInfo.Best_Plan_Program>
	<cfset userManager = CreateObject("component", "components.user.UserManager") />
	<cfset UserPositions = userManager.getUserPositionsList(request.AccessStructure.User_Id)>
	<!---If user coping “Best Plan Program" and user has multiple positions; we should provide user an option to select a Position --->
	<cfif UserPositions.RecordCount GT 1>
		<cfset showRSPdropdown = 1>
	</cfif>
</cfif>
<!---60308	Best Plans Enhancement END--->
<!--- Dev Note:Milan (25639) - Check whether the most recent version is active --->
<CFQUERY NAME="getActiveTemplateVersion" datasource="#application.datasource#">
SELECT IsDominant
FROM Program_Control_Panel_Options
WHERE First_Parent_ID = '#getProgramTemplateInfo.First_Parent_ID#'
AND Deleted = 0
AND Active = 1
AND IsDominant = 1
</CFQUERY>

<CFSET ProgramIsARevision = 0>
<CFIF len(trim(getProgramTemplateInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(getProgramTemplateInfo.Revision_of_Contract_Main_ID)) NEQ 0>
	<CFSET ProgramIsARevision = 1>
</CFIF>

<CFSET TemplateIsReuseable = 1>
<CFIF trim(getProgramTemplateInfo.Active) EQ 0 OR trim(getProgramTemplateInfo.Deleted) EQ 1>
	<CFSET TemplateIsReuseable = 0>
</CFIF>


<CFSET ContinueWithApproval = 1>

<CFIF TemplateIsReuseable EQ 0>
	<CFSET ContinueWithApproval = 0>
</CFIF>

<CFIF ProgramIsARevision EQ 1>
	<CFSET ContinueWithApproval = 1>
</CFIF>

<CFIF getProgramTemplateInfo.Contract_Status_Type_IDX GTE 4 AND getProgramTemplateInfo.Contract_Status_Type_IDX LT 7>
	<CFSET ContinueWithApproval = 1>
</CFIF>


<CFIF IsRevisionOfExistingContract EQ 0 AND TemplateIsReuseable EQ 0>
	<CFSET ContinueWithApproval = 0>
</CFIF>

<!---  Dev Note:Milan (25639) - If the request is not for revision AND the template is not active, disallow access.
Here we are disallowing copy or rollover if the template is not active.
--->
<CFIF IsRevisionOfExistingContract EQ 0 AND getActiveTemplateVersion.RecordCount EQ 0>
	<CFSET ContinueWithApproval = 0>
</CFIF>

<CFIF ContinueWithApproval EQ 0>
	<CFSET PAGE_TITLE= "">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

	<HTML>
	<HEAD>
		<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	</HEAD>

	<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<BR><BR><BR>
	<DIV ALIGN="center" STYLE="font-size: 15px;"><B>The template you are attempting to use has been removed from circulation.<BR>You will be returned to the view program page.</B></DIV>

	<script language="JavaScript">
		function seeya()
		{
			window.location.href="contract_edit_menu.cfm?CID=<CFOUTPUT>#FORM.Program_ID#</CFOUTPUT>";
		}
		setTimeout('seeya()',2000);
	</script>

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	</BODY>
	</HTML>
<CFELSE>
	<cfif form.IsCopyProgram eq 1>
		<!---60308 :: Best Plans Enhancement
			If user coping “Best Plan Program" and user has multiple positions; we provide user an option to select RSP for new program--->
		<cfif   appSettings.getretainoriginalRSPcopy() EQ 0 OR  showRSPdropdown>
			<cfset userManager = CreateObject("component", "components.user.UserManager") />
			<!------ get user positions id ----->
			<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />
			<!--- Get RSP Pulldown BJF D11341 --->
			<cfinclude template="/common_files/rsp_include.cfm">
		</cfif>
	<cfelse>
		<cfif Scheduled eq 0 AND appSettings.getretainoriginalRSP() EQ 0>
			<cfset userManager = CreateObject("component", "components.user.UserManager") />
			<!------ get user positions id ----->
			<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />
			<!--- Get RSP Pulldown BJF D11341 --->
			<cfinclude template="/common_files/rsp_include.cfm">
		</cfif>
	</cfif>
	<CFSET Program_ID_To_Replicate = cryp.value>

	<cfif form.IsCopyProgram eq 1>
		<cfif appSettings.getretainoriginalRSPcopy() EQ 0>
			<cfif IsDefined("FORM.Responsible_User_Id_Position_Id")>
				<!--- Get the Responsible User Id --->
				<cfset Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>
			</cfif>
		</cfif>
		<!---
		60308 :: Best Plans Enhancement
		IF USER COPYING A "BEST PLAN PROGRAM" WE SHOULD UPDATE RSP TO BE USER
		--->
		<cfif getProgramTemplateInfo.Best_Plan_Program AND UserPositions.RecordCount EQ 1>
			<cfset Responsible_User_Id = request.AccessStructure.User_ID/>
		</cfif>
	<cfelse>
		<cfif appSettings.getretainoriginalRSP() EQ 0>
			<cfif IsDefined("FORM.Responsible_User_Id_Position_Id")>
				<!--- Get the Responsible User Id --->
				<cfset Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>
			</cfif>
		</cfif>
	</cfif>
	<!---
	D22578: CAG - mass copy a program
	We no longer will be using replicate_program.cfm for copy / revise
	Instead when user clicks save in the basic info page, we will call routine USP_Copy_Program which will do the copy
	--->

	<cfif Scheduled IS 0>

		<FORM ACTION="contract_create_1_form.cfm" METHOD="post" NAME="MyForm">
		<cfif form.IsCopyProgram eq 1>
			<cfif appSettings.getretainoriginalRSPcopy() EQ 0>
				<input name="Responsible_User_Id_Position_Id" type="hidden" value="<cfoutput>#FORM.Responsible_User_Id_Position_Id#</cfoutput>">
			</cfif>
		<cfelse>
			<cfif appSettings.getretainoriginalRSP() EQ 0>
				<input name="Responsible_User_Id_Position_Id" type="hidden" value="<cfoutput>#FORM.Responsible_User_Id_Position_Id#</cfoutput>">
			</cfif>
		</cfif>
			<!---<INPUT TYPE="Hidden" NAME="Contract_Renewal_Packets_ID" value="<CFOUTPUT>#savePacket.Contract_Renewal_Packets_ID#</CFOUTPUT>">--->
			<INPUT TYPE="Hidden" NAME="Contract_Renewal_Packets_ID" value="0">
			<INPUT TYPE="Hidden" NAME="Do_Revise_Copy" value="1">
			<INPUT TYPE="Hidden" NAME="IsRevisionOfExistingContract" VALUE="<CFOUTPUT>#FORM.IsRevisionOfExistingContract#</CFOUTPUT>">
			<INPUT TYPE="Hidden" NAME="IsRollOver" VALUE="<CFOUTPUT>#FORM.IsRollOver#</CFOUTPUT>">
			<INPUT TYPE="Hidden" NAME="IsCopyProgram" VALUE="<CFOUTPUT>#FORM.IsCopyProgram#</CFOUTPUT>">
			<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#FORM.Program_ID#</CFOUTPUT>">
			<!--- Copied Search Sequence Indicators --->
			<INPUT TYPE="hidden" NAME="NewSearchSequence" VALUE="<CFOUTPUT>#Form.NewSearchSequence#</CFOUTPUT>" >
			<INPUT TYPE="hidden" NAME="New_Business_Segment" VALUE="<CFOUTPUT>#Form.New_Business_Segment#</CFOUTPUT>">
			<INPUT TYPE="hidden" NAME="New_Spending_Category" VALUE="<CFOUTPUT>#Form.New_Spending_Category#</CFOUTPUT>">
			<INPUT TYPE="hidden" NAME="suppressProductsDistributors" VALUE="<CFOUTPUT>#Form.suppressProductsDistributors#</CFOUTPUT>">
			<INPUT TYPE="hidden" NAME="Contract_Reference_Number" VALUE="<cfoutput>#FORM.Contract_Reference_Number#</cfoutput>">
			<cfif appSettings.getView_Legacy_ID() EQ 1>
				<INPUT TYPE="hidden" NAME="legacy_id" VALUE="<CFOUTPUT>#form.legacy_id#</CFOUTPUT>" >
			</cfif>
			<INPUT TYPE="hidden" NAME="start_date" VALUE="<CFOUTPUT>#form.start_date#</CFOUTPUT>" >
			<INPUT TYPE="hidden" NAME="end_date" VALUE="<CFOUTPUT>#form.end_date#</CFOUTPUT>" >
			<INPUT TYPE="hidden" NAME="Limited_Revise" VALUE="<CFOUTPUT>#FORM.Limited_Revise#</CFOUTPUT>" >
		</form>

		<script>
			document.all.MyForm.submit();
		</script>

	</cfif>

</CFIF>