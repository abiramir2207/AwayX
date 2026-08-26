<cf_cryp type="de" string ="#FORM.ApproveContract#" key="#request.key#">
<CFPARAM name="duplicateprogram" default="false">
<cfparam name="FORM.from_duplicate_approve" 	default="0">
<CFPARAM name="checkDuplicateProgram" default="1">
<cfparam name="form.BackTotemplate"				default="">	
<cfif checkDuplicateProgram>
	<cfset checkDuplicateProgram = NOT FORM.from_duplicate_approve />
</cfif>

<!--- from now on, no need to check dup again since it's handled in clause approval --->
<cfset checkDuplicateProgram = 0 >

<!---get application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
	SELECT     dbo.Program_Control_Panel_Options.Active, dbo.Program_Control_Panel_Options.Deleted, dbo.Contract_Main.Parent_Revised_Contract_Main_ID, 
						  dbo.Contract_Main.Revision_of_Contract_Main_ID, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID,
						  dbo.Program_Control_Panel_Options.Disable_Duplicate_Check_For_Revisions
	FROM         dbo.Contract_Main INNER JOIN
						  dbo.Program_Control_Panel_Options ON 
						  dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#cryp.value#'
</CFQUERY>

<CFQUERY NAME="getSettings" datasource="#application.datasource#">
	SELECT	*
	FROM	dbo.Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#getProgramTemplateInfo.ProgramControl_Panel_Options_ID#'
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

<CFIF TemplateIsReuseable NEQ 1>
	<CFSET ContinueWithApproval = 0>
</CFIF>

<CFIF ProgramIsARevision EQ 1>
	<CFSET ContinueWithApproval = 1>
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
	<BR><BR><BR>
	<DIV ALIGN="center" STYLE="font-size: 15px;"><B>The template you are attempting to use has been removed from circulation.<BR>You will be returned to the view program page.</B></DIV>
	<script language="JavaScript">
		function seeya()
		{
			this.close();
			opener.window.location.href="contract_edit_menu.cfm?CID=<CFOUTPUT>#FORM.ApproveContract#</CFOUTPUT>";
		}
		setTimeout('seeya()',2000); 
	</script>
	</BODY>
	</HTML>
	
<CFELSE>

	<CFPARAM NAME="FORM.Program_Is_A_Revision" DEFAULT="0">
	<CFPARAM NAME="FORM.Pay_Brokerage" DEFAULT="EMPTY">
	
	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "contract_start_date,contract_end_date,revision_of_contract_main_id,revision_version,contract_number"
			}), "contract_start_date,contract_end_date,revision_of_contract_main_id,revision_version,contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<CFQUERY NAME="GetContractInfo" datasource="#application.datasource#">
		SELECT Contract_Start_Date, Contract_End_Date, Revision_Of_Contract_Main_ID, revision_version,contract_number
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</CFQUERY>
</cfif>

	<!--- Dev Note(69720) - If the program is a revision and the template setting does not allow for "duplicate check" for revisions, then do not do "duplicate check". --->
	<cfif ProgramIsARevision eq 1 AND getProgramTemplateInfo.Disable_Duplicate_Check_For_Revisions eq 1>
		<cfset checkDuplicateProgram = 0>
		<cfset duplicateprogram = 0>
	</cfif>

	<!------ Check whether this program is a duplicate program ----->
	<cfif checkDuplicateProgram>
		<CFINCLUDE TEMPLATE="/includes/progress_bar.cfm">
		<cfinclude template="duplicate_program_check.cfm">
	</cfif>

	<CFIF duplicateprogram IS "true">
		<!--- don't use access profile for now --->
		<CFINCLUDE TEMPLATE="/get_access_profile.cfm"> 
		<!--- <cfif Get_Profile_Settings.Approve_Duplicate_Programs >--->
		<cfif 1  EQ 1 >
			<div align="center" STYLE="color: red; font-size: 13px; font-weight: bold;">
			<br><br>
			Sorry the same program already exists.
			<br>The program that matches your program is <cfoutput>[#check_contract_number#]: #check_contract_title#</cfoutput>
			<br>
			Would you like to email the creator of existing program to make modification or approve this program?
			<!--- get email address for the creator of the program based on check_contract_creator--->
			<CFSET objHandle = CreateObject("component", "components.user.UserManager")>
			<cfset creator_email_addr = objHandle.getUser(#check_contract_creator#).User_Email>
			<form name="duplicateprogram" action="contract_approve_action.cfm" METHOD="post">
			<cfoutput>
			<CFLOOP COLLECTION="#Form#" ITEM="FormItem">
				<cfif FormItem NEQ "from_duplicate_approve">
		 		<INPUT TYPE="HIDDEN" ID="#FormItem#" NAME="#FormItem#" VALUE="#Evaluate("Form.#FormItem#")#">
				</cfif>
			</CFLOOP>
			</cfoutput>
			<input type="hidden" id="from_duplicate_approve" name="from_duplicate_approve" value="1">
			<input type="hidden" id="check_contract_number" name="check_contract_number" value="<cfoutput>#check_contract_number#</cfoutput>">
			<input type="hidden" id="check_contract_title" name="check_contract_title" value="<cfoutput>#check_contract_title#</cfoutput>">
			<input type="hidden" id="creator_email_addr" name="creator_email_addr" value="<cfoutput>#creator_email_addr#</cfoutput>">
			 <input type="Hidden" name="BackToTemplate" value="<cfoutput>#form.BackToTemplate#</cfoutput>">
				
			<table>
				<tr>
					<td>
						<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"emailCreator(#cryp.value#,#check_contract_number#);"
						button_type		=	"javascript_link"
						button_width	=	"130"
						button_color	=	"Navy"
						button_tip		=	"email notification"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						>
					</td>
					<!--- determine the action based on the control setting dup_action--->
					<cfset dupAction = template.getDupAction(ContractControlID)>
					<cfif dupAction EQ 1>
						<td>
							<CF_button
								button_name		=	""
								button_caption	=	"approve this program"
								button_action	=	"approveProgram()"
								button_type		=	"javascript_link"
								button_width	=	"130"
								button_color	=	"Navy"
								button_tip		=	"approve program"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
							>
						</td>
					</cfif>
				</tr>
			</table>
			</form>
			</div>
			<script>
			function approveProgram(){
				<cfif GetSettings.Date_Exclusions_ON EQ 0>
					var ConfirmMessage = "Are you sure you want to approve this program?";
				<cfelse>
					var ConfirmMessage = "Are you sure you want to approve this program and any applicable date exclusions?";
				</cfif>
			if(confirm(ConfirmMessage)) {
									programGettingApproved = 1;
									document.duplicateprogram.submit()
								}
							}
			function emailCreator(contract_main_id,check_contract_number) {
				//document.all.duplicateprogram.action = "contract_email_create.cfm?passedForm=dupForm&contractMainId=" + contract_main_id + "&check_contract_number=" + check_contract_number + "&check_contract_title=" + check_contract_title;
				document.all.duplicateprogram.action = "contract_email_create.cfm?passedForm=dupForm&contractMainId=" + contract_main_id;
				document.duplicateprogram.submit()
				}
			</script>
			
		<cfelse>
		
			<div align="center" STYLE="color: red; font-size: 13px; font-weight: bold;">
			<br><br>
			Sorry the same program already exists. You do not have rights to approve duplicate programs.
			<br>The program that matches your program is <cfoutput>[#check_contract_number#]: #check_contract_title#</cfoutput>
			<br><br><br>
			<CF_button
						button_name		=	""
						button_caption	=	"close this window"
						button_action	=	"window.close();"
						button_type		=	"javascript_link"
						button_width	=	"130"
						button_color	=	"Navy"
						button_tip		=	"close this window"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
			</div>
		</cfif>
		<CFABORT>
		
	<CFELSE>
	   		<!--- moved to an include so sysco deals could call same approve action --->
	     <cfinclude template="contract_approve_action_include.cfm">
	  
</CFIF>
</CFIF>
