<!---------------------------------------------------------------------------------------------------------------
	What-IF Remarks:

----------------------------------------------------------------------------------------------------------------->
<!DOCTYPE html><!--- PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">--->
<html>
<head>
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET contract_main_id = cryp.value>
<cfsilent>
	<!---
    FILE:
    FILENAME: 	Common_Files/contracts/layered_approval_include.cfm
    CREATED: 	??/??/???? - ???
    EDITED:		10/31/2008 - RBL [D17421]

    FUNCTIONALITY:
    - ...
    --->

    <!--- These parameters are required for this template to process correctly --->
    <cfparam name="MarginTooLow" default="1">
    <cfparam name="Program_Is_A_Revision" default="0">
    <cfparam name="showagreepopup" default="0">
    <cfparam name="button_label" default="Approve">
    <cfparam name="form.AgreeList" 		default="">
    <cfparam name="form.ApproveList"		default="">
    <cfparam name="form.RestrictedList"	default="">
    <cfparam name="form.preAgreeList" 		default="">
    <cfparam name="form.preApproveList"		default="">
    <cfparam name="form.preRestrictedList"	default="">
    <cfparam name="ShowLSAutoApproveMessage"  default="0" />
    <cfparam name="duplicateprogram"  default="0" />

	<cfif Not isDefined("url.groupCheckStatusChange")>
		<cfparam name="form.Agree"			default="1" >
		<cfparam name="form.Approve"		default="1" >
		<cfparam name="form.Restricted"		default="1" >
	</cfif>

	<cfif Not isDefined("ProgramMarginLog")>
		<cfset ProgramMarginLog = CreateObject("component","components.programs.MarginLog") />
	</cfif>

	<cfif isDefined("url.groupCheckStatusChange")>
		<cfif form.AgreeList neq "">
			<cfset form.preAgreeList = form.AgreeList >
		</cfif>
		<cfif form.ApproveList neq "">
			<cfset form.preApproveList = form.ApproveList>
		</cfif>
		<cfif form.RestrictedList neq "">
			<cfset form.preRestrictedList = form.RestrictedList >
		</cfif>
		<cfset form.AgreeList = "" >
		<cfset form.ApproveList = "">
		<cfset form.RestrictedList = "" >
	</cfif>
	<cfparam name="title" default="">
	<cfparam name="duplicateprogram" default="false">
	<cfparam name="disablecheckbox" default="">
	<cfparam name="url.groupapproval" default="1">
	<cfparam name="rollover_allowed" default="1">
	<cfparam name="direct_pricing" default="0">
	<cfparam name="marginTagetEnabled" default = "0">
	<cfparam name="form.lAgreeReason" default = "">

	<cfparam name="url.verticalPNL"  default="">
	<cfparam name="url.fixed_type"   default="">
	<cfparam name="url.showProducts" default="1">
	<cfparam name="url.detail7"      default="show">    <!--- show = show detail elements under discount, trade, cost |  anything else = hide detail --->
	<cfparam name="form.Manual_Select_Approvers" default="0" />
</cfsilent>

<cfif url.verticalPNL eq "">         <!---  44017  --->
	<cf_include files="/script/javascript/dhtml.js">
</cfif>
<cfset margin_display_style = application.util.query.get_Setting("margin_display_style")>

<!---TSF - Label 11072: If margin targets are enabled, then display target % at the item level--->
<cfset useLakebaseForqGetMarginTargetEnabled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForqGetMarginTargetEnabled>
	<cftry>
		<cfset qGetMarginTargetEnabled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "program_margin_target_enabled"
			}), "program_margin_target_enabled"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetMarginTargetEnabled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetMarginTargetEnabled>
<CFQUERY NAME="qGetMarginTargetEnabled" datasource="#application.datasource#">
	SELECT 	Program_Margin_Target_Enabled
	FROM 	General_Settings
</CFQUERY>
</cfif>
<cfif trim(qGetMarginTargetEnabled.Program_Margin_Target_Enabled) eq "1">
	<cfset marginTagetEnabled = 1 />
</cfif>

<!--- Dev Note: KAL; D7432 --->
<cfsilent>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.appSettingsGet>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">

<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
	<!---
	We will be getting the UOM from the user profiles settings.
	Default UOM will be the default from the application settings-approval settings as long as the user have permission to see that UOM
	If not the defult UOM will be one of the UOM the user has permission to see.
	 --->
	<CFSET DisplayMarginUOMCS = 0 />
	<CFSET DisplayMarginUOMLB = 0 />
	<CFSET DisplayMarginUOMEQ = 0 />
	<CFSET DisplayMarginUOMDefault = appsettings.getMarginDisplayDefault() />
	<cfif appsettings.getMarginDisplayCS() AND Get_Profile_Settings.Margin_Display_UOM_CS EQ 1>
		<CFSET DisplayMarginUOMCS = 1 />
	</cfif>
	<cfif appsettings.getMarginDisplayLB() AND Get_Profile_Settings.Margin_Display_UOM_LB EQ 1>
		<CFSET DisplayMarginUOMLB = 1 />
	</cfif>
	<cfif appsettings.getMarginDisplayEQ() AND Get_Profile_Settings.Margin_Display_UOM_EQ EQ 1>
		<CFSET DisplayMarginUOMEQ = 1 />
	</cfif>
	<!--- if no UOM selected, set it to use the default --->
	<cfif DisplayMarginUOMCS EQ 0 AND DisplayMarginUOMLB EQ 0 AND DisplayMarginUOMEQ EQ 0>
		<cfswitch expression="#DisplayMarginUOMDefault#">
			<cfcase value="1">
				<cfset DisplayMarginUOMCS = 1 />
			</cfcase>
			<cfcase value="3">
				<cfset DisplayMarginUOMLB = 1 />
			</cfcase>
			<cfcase value="2">
				<cfset DisplayMarginUOMEQ = 1 />
			</cfcase>
		</cfswitch>
	<!--- if the user do nto have permission to see the default, set the default to one of teh UOM the user can see --->
	<cfelseif (DisplayMarginUOMDefault EQ 1 AND DisplayMarginUOMCS EQ 0)
			OR (DisplayMarginUOMDefault EQ 3 AND DisplayMarginUOMLB EQ 0)
			OR (DisplayMarginUOMDefault EQ 2 AND DisplayMarginUOMEQ EQ 0)>
		<cfif DisplayMarginUOMEQ EQ 1><cfset DisplayMarginUOMDefault = 2></cfif>
		<cfif DisplayMarginUOMLB EQ 1><cfset DisplayMarginUOMDefault = 3></cfif>
		<cfif DisplayMarginUOMCS EQ 1><cfset DisplayMarginUOMDefault = 1></cfif>
	</cfif>

	<cfparam name="form.Margin_Type" default="#DisplayMarginUOMDefault#">
<cfelse>
<cfparam name="form.Margin_Type" default="1">
</cfif>

<cfif url.verticalPNL neq "">         <!---  44017  --->
	<cfif isDefined("url.margin_type")>
		<cfset form.margin_type = url.margin_type>
	</cfif>
</cfif>

<cfparam name="url.bFromPlanner" default="0" />
<cfparam name="form.bFromPlanner" default="#url.bFromPlanner#" />

<cfset display_business_consideration = 0 ><!--- Dev Note: KAL; 8891 --->

<cfset objProgram = CreateObject("component", "components.programs.Program") />
<cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
<cfset ApprovalManager = CreateObject("component", "components.programs.Approval.ApprovalManager") />
<cfset programagreed = programManager.isProgramAgreed(contract_main_id)>

<cfif Get_Profile_Settings.Internal_Notes EQ 1 and appSettings.getbusinessconsiderations_on() EQ 1>
	<cfset display_business_consideration = 1 ><!--- Dev Note: KAL; 9559 --->
</cfif>

<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo() />

<cfset userManager = CreateObject("component", "components.user.UserManager").init() />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />

<!--- get maximum approvable volume --->
<cfset annualvolume_CS = Get_Profile_Settings.Max_Approval_Volume>
<cfset minvolume_CS = Get_Profile_Settings.min_Approval_Volume>
<cfset annualvolume_UOM = Get_Profile_Settings.Max_Approval_Volume_Uom>
<cfset minvolume_UOM = Get_Profile_Settings.Min_Approval_Volume_Uom>
<cfelseif Get_Profile_Settings.program_margin_approval_method IS 7>
<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.standard_program_approval") />

<!--- get maximum approvable volume --->
<cfset annualvolume_CS = Get_Profile_Settings.Max_Approval_Volume>
<cfset minvolume_CS = Get_Profile_Settings.min_Approval_Volume>
<cfset annualvolume_UOM = Get_Profile_Settings.Max_Approval_Volume_Uom>
<cfset minvolume_UOM = Get_Profile_Settings.Min_Approval_Volume_Uom>

<cfelseif Get_Profile_Settings.program_margin_approval_method IS 6>
	<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.disposable_program_approval") />
</cfif>
<!--- get all program info --->

<cfset approvableannualvolume_CS = Get_Profile_Settings.Max_Approval_Annual_Volume><!---72497--->
<cfset approvableannualvolume_UOM = Get_Profile_Settings.Max_Approval_Annual_Volume_UOM><!---72497--->

<cfset getProgramInfo = ApprovalProgramManager.getProgramInfo(contract_main_id)>
<!--- Dev Note: Kal; D13380: Margin Page Highlight Changes --->
<CFIF getProgramInfo.Is_A_Revision EQ 1>
	<CFSET Program_Is_A_Revision = 1>
	<CFSET getProgramPreviousVersionInfo = ApprovalProgramManager.getProgramInfo(getProgramInfo.Revision_of_Contract_Main_ID)>
</CFIF>

<!---
<cfset IsARolloverProgram = 0 />
<cfif getProgramInfo.Rollover_from_Contract_Main_ID NEQ "">
  <cfset IsARolloverProgram = 1 />
  <cfset getRollOverProgramInfo = ApprovalProgramManager.getProgramInfo(getProgramInfo.Rollover_from_Contract_Main_ID)>
</cfif>
--->
<cfset getSettings = ApprovalProgramManager.getProgramSettngs(getProgramInfo.ProgramType_ID)>

<cfif Get_Profile_Settings.program_margin_approval_method IS 7>
	<cfif getSettings.approval_uom EQ 2>
		<cfset form.margin_type = 3>
	</cfif>
</cfif>

<!--- check if trade icluded --->
<CFSET ShowTPA = getSettings.Include_Trade>

<cfif TRIM(getSettings.generic_type) EQ "Direct Pricing">
<cfset direct_pricing  = 1>
</cfif>

<cfinclude template="common_approval_check.cfm">
<!---  if message array legth is GT 0 then there are some settings user cannot approve --->
<cfif ArrayLen(messageArray) GT 0>
	<cfset CannotApproveSettings = 1>
</cfif>

<!---
	START: 25709: EZ Button/Anand Rao/04/13/2011
				Run the rate checker only if the EZButton is ON, EzTemplate is 0 and Discount_Rebate_Max_Rate_On is 1
				and either EZButton_Approve_Beyond_MaxRate is 0 OR EzButton_Enter_Beyong_Max_Rates EQ 0
--->

<cfparam name="URL.EZTemplate" default="0">
<cfparam name="displaygrouptype" default="0">
<cfparam name="compUUID" default="0">
<cfset lProductsBeyondMaxRateList = "" />
<cfif getsettings.EZButton_On EQ 1 AND isDefined("URL.EZTemplate") AND	URL.EZTemplate EQ 0 AND	(GetSettings.Discount_Rebate_Max_Rate_On EQ 1) AND
			(Get_Profile_Settings.EZButton_Approve_Beyond_MaxRate EQ 0 OR GetSettings.EzButton_Enter_Beyond_Max_Rates EQ 0)>
	<cfset MaxRateError = 0 />
	<!--- Dev Note: Drachala; D27505 : EZ Button margin page message START--->
	<!---<cfset strMessage = "The Following Error Occurred in the Rebates:\n\n" />--->
		<cfset strMessage = "" />
	<!--- Dev Note: Drachala; D27505 : EZ Button margin page message END--->
	<cfinclude template="EzButton_Rebate_Template_Rate_Checker.cfm" />
	<cfif (MaxRateError EQ 1)>
		<cfset letUserProceed = 0 />
		<cfset ArrayAppend(messageArray, strMessage)>
	</cfif>
</cfif>
<!---
	END 25709: EZ Button
--->

<!------ Get pullback information ----->
<cfset bPullbackAvailable = 0 />
<cfset bPullbackApproved = 0 />
<cfset sPullbackApprovedMessage = "" />
<cfset bUserCanApprovePullbackForThisPgm = 0 />
<cfset bProgramFinalApprove = 0 />
<cfset bApprovingPullbackApprovesProgram = 0 />

<cfset oProgram = CreateObject("component", "components.programs.program") />
<cfset qGetProgramUserSettings = oProgram.getProgramUserSettings() />
<cfset qGetTemplate = oProgram.getProgramInfo(contract_main_id) />

<cfif appSettings.getPullbacksOn() AND getProgramInfo.Pullback_Available EQ 1 AND qGetProgramUserSettings.Pullback_Requires_Approval EQ 1>
<!------
Different possible scenario
- pullback already approved
- pullback not approved and user do not have approval right for this template
- pullback not approved and user do have approval right for this template
----->
<cfset bPullbackAvailable = 1 />
<cfset bPullbackApproved = getProgramInfo.Pullback_Approved />
<cfset sPullbackApprovedMessage = "" />
<cfset bUserCanApprovePullbackForThisPgm = 0 />
<cfset bApprovingPullbackApprovesProgram = 0 />
<!------ Find if the current user can approve pullbacks ----->
<cfif Get_Profile_Settings.Approve_Pullback EQ 1>
	<cfset qGetProfileTemplates = templateManager.getProfileTemplates(
				profileId = request.AccessStructure.Profiles_ID,
				forbidAccessType = 6,
				checkForPullbacks = 0,
				templateId = getProgramInfo.ProgramType_ID
				) />
	<cfif qGetProfileTemplates.recordCount>
		<cfset bUserCanApprovePullbackForThisPgm = 1 />
	</cfif>
</cfif>
<cfif bPullbackApproved>
	<cfset sPullbackApprovedMessage = "Approved by #userManager.getUserName(getProgramInfo.Pullback_Approved_By)# (#DateFormat(getProgramInfo.Pullback_Approved_Date, "mm/dd/yyyy")#)" />
<cfelse>
	<cfif bUserCanApprovePullbackForThisPgm EQ 0>
		<cfset button_label = "Agree">
		<cfset temp = ArrayAppend(messageArray, "You cannot approve programs with #appSettings.getPullbackLabelLower()#.")>
	</cfif>
</cfif>
</cfif>
</cfsilent>

<!---D45761 :: Approval Workflow START --->
<cfif getsettings.EZButton_On and appSettings.getCustomMaxRate()>
	<cfset displayinEZmaxRate = 0>
<cfelse>
	<cfset displayinEZmaxRate = 1>
</cfif>
<!---D45761 :: Approval Workflow END --->

<!---Tim Ford - Label 23377: Reformat Approved Margins page --->
<cfset bDisplayRevisionNotice = 1 />
<cfif isDefined("margin_version") and margin_version eq "approved">
	<cfset bDisplayRevisionNotice = 0 />
</cfif>
<!--- check if the program is a revision --->
<!---D50860 :: Release 8.0 - Improvements to the ‘View Margin’ page inside a program START --->
<CFIF getProgramInfo.Is_A_Revision EQ 1 and bDisplayRevisionNotice AND displayinEZmaxRate>
	<cfsavecontent variable="ProgramIsARevision">
	<CFSET Program_Is_A_Revision = 1>
		*** NOTE: This Is A Revision Of An Existing Program ***
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND getProgramInfo.Auto_Renew><!----- If auto renew is on, check if the parent program had auto renew on, if yes, did it already renew? ----->
		<cfif objProgram.getAutoRenewStatus(getProgramInfo.Contract_Number) EQ 1>
		<br>An auto renewed version of this program already exists. <br>The changes getting approved in this revision will not be reflected in that auto renewed program.
		</cfif>
	</cfif>
	</cfsavecontent>
</CFIF>

<cfif url.verticalPNL eq "">
	<cfsavecontent variable="MarginDate">

	<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
			<cfif IsDefined("Post_MarginLogInfo")>
				<cfset MarginCalculatedDate = Post_MarginLogInfo[6]>
			</cfif>
			<cfoutput>
			<!--- <div style="width:100%;height:20px;margin-bottom: 5px;"> --->
				<!--- 	Dev Notes: 22946/Anand Rao/26-Apr-10  I found an issue with this "if" and added a quick fix to check for "isDefined" as I was getting an error saying margin_version was undefined, while working on 22946. --->
                <cfif isDefined("margin_version") AND  margin_version neq "approved" AND displayinEZmaxRate>
                    <!--- ngt --->
					<!--- <div style="width:33%;float2:left;color:red;font-size:11px;" id="recalculate-margin">			 --->
						<span style="color:red;padding-right:10px;">The Margin is calculated as of #DateFormat(MarginCalculatedDate,"MM/DD/YYYY")# #TimeFormat(MarginCalculatedDate,"h:mm tt")#</span>
						<!---76388 Ability for user to re-run margin for a program START--->
						<cfset urlString = HTTP_URL &  "&reRunMargin=1"/>
						<a href="#urlString#">#application.util.string.actionLinkFormat2('recalculate margin')#</a>
						<!---76388 Ability for user to re-run margin for a program END--->
					<!--- </div>	 --->
				</cfif>
				<!--- <div style="width:33%;float:left;text-align: center;"> --->
					<cfif url.verticalPNL is '' 	and margin_display_style is "custom_t" and get_Profile_Settings.View_LH_pane_Vertical_P_L>
						<a href="javascript:verticalPNL(1)">#application.util.string.actionLinkFormat2('vertical p&l')#</a>
					</cfif>
				<!--- </div> --->
				<!--- <div style="width:33%;float:right;text-align: left;"> --->
					<cfif appSettings.getuploadmargintargets_on() AND Get_Profile_Settings.View_Additional_Margins_Targets>
							<a href="javascript:MarginTargetComparison();">#application.util.string.actionLinkFormat2('#appSettings.getMarginColHeader26()# Comparison')#</a>
					</cfif>
				<!--- </div>		 --->
			<!--- </div> --->
			</cfoutput>
	</cfif>
	</cfsavecontent>
</cfif>
<!---D50860 :: Release 8.0 - Improvements to the ‘View Margin’ page inside a program END --->
<cfif groupapproval EQ 1>
<!--- duplicate program check --->
<cfsilent>
<!---we are in a cfsilent...turn off the flush--->
<cfset Variables.PW_DoNotCFFLUSH = 1>
<cfif getSettings.Check_Duplicate_Program>
		<cfset ProgramIsARevision = getProgramInfo.Is_A_Revision>
		<cfset getContractInfo.contract_start_date = getProgramInfo.contract_start_date>
		<cfset getContractInfo.contract_end_date = getProgramInfo.contract_end_date>
</cfif>

<!------
Profile                            				Template Setting              			Approve
Approve dup, No                    Check for dups, Warning       	NO
Approve dup, No                    Check for dups, Stop           		NO

Approve dup, Yes                   Check for dups, Warning        	YES
Approve dup, Yes                   Check for dups, Stop           		NO
----->
</cfsilent>



<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
    <cfset form.contract_main_id = cryp.value>

    <!--- ngt - show program basic info in the header --->
    <cfset request.style = "2020">
    <div class="prg-header2">
        <cfif url.verticalPNL eq ''>
            <cfinclude template="/Common_Files/contracts/minimal_contract_info.cfm">
        </cfif>
        <style>
            .prg-header {
                border: 1px solid blue;
            }
            .duplicate-program {
                font-weight: bold;
                font-size  : 13px;
                text-align : center;
                position   : relative;
                top        : -25px;
            }
            #recalculate-margin {
                position: absolute;
                top: 55px;
                left: 10px;
            }
        </style>
    </div>



<!------ If duplicate program ----->
<cfif duplicateprogram EQ "true">
	<cfif displayinEZmaxRate>
		<div class="duplicate-program">*** NOTE: This Is A Duplicate Program ***</div>
	</cfif>
	<!------ Find out if it is warning, or stop ----->
	<cfset template = templateManager.get(getProgramInfo.ProgramType_ID)>
	<cfset dupAction = template.getDupAction(getProgramInfo.ProgramType_ID)><!------ 1=warning and allow to go forward ----->
	<cfif dupAction EQ 1><!------ If warning ----->
		<cfif Get_Profile_Settings.Approve_Duplicate_Programs EQ 1><!------ Approve dup, Yes ----->

		<cfelse><!------ Approve dup, No ----->
			<cfset CannotApproveSettings = 1>
			<cfset temp = ArrayAppend(messageArray, "You cannot approve duplicate programs.")>
		</cfif>
	<cfelse><!------ If Stop ----->
		<cfset CannotApproveSettings = 1>
		<cfset temp = ArrayAppend(messageArray, "Program template does not allow you to approve duplicate programs.")>
	</cfif>
</cfif>
<!--- end duplicate program check --->
</cfif>
<!--- lumpsum check --->
<cfsilent>
<cfset getProgramLumpsum = ApprovalProgramManager.getProgramLumpsum(contract_main_id)>
<cfset getProgramPreviousVersionLumpsum = ApprovalProgramManager.getProgramLumpsum(getProgramInfo.Revision_of_Contract_Main_ID)>

<CFIF getProgramInfo.RevisionTypeA EQ 1 and Get_Profile_Settings.Approve_Revision_Types_A EQ 0>
<cfset CannotApproveSettings = 1>
<cfset temp = ArrayAppend(messageArray, "You cannot approve Type A Revisions")>
</cfif>

<CFIF getProgramInfo.RevisionTypeB EQ 1 and Get_Profile_Settings.Approve_Revision_Types_B EQ 0>
<cfset CannotApproveSettings = 1>
<cfset temp = ArrayAppend(messageArray, "You cannot approve Type B Revisions")>
</cfif>

<CFIF getProgramInfo.RevisionTypeC EQ 1 and Get_Profile_Settings.Approve_Revision_Types_C EQ 0>
<cfset CannotApproveSettings = 1>
<cfset temp = ArrayAppend(messageArray, "You cannot approve Type C Revisions")>
</cfif>

<cfset Current_Trade_Label = application.returned_customer_setting.Trade_Label />

<CFIF  appSettings.getrolloverprograms_on()>
<CFQUERY NAME="CheckIfRollOverProgram" datasource="#application.datasource#">
	select 	contract_main_id
	from 	contract_main
	where 	contract_main_id = '#contract_main_id#'
	AND 	isRollOver = 1
	<!------ D9833: while auto renew, we will retain the rollover flag from parent ----->
</CFQUERY>

<CFIF CheckIfRollOverProgram.Recordcount GT 0>
<CFQUERY NAME="GetUserRollOverApprovalProfile" datasource="#application.datasource#">
	Select Approve_Roll_Over_Programs
	from profiles_settings, _users
	where profiles_settings.Profiles_ID = _users.Profiles_ID
	and _Users.User_id = '#request.AccessStructure.user_id#'
</CFQUERY>

<cfset Program_ID = contract_main_id>

<CFIF GetUserRollOverApprovalProfile.Approve_Roll_Over_Programs EQ 0>
<CFINCLUDE TEMPLATE="/Common_Files/Contracts/check_roll_over_program_approval.cfm">
<CFIF rollover_allowed EQ 0>
<cfset CannotApproveSettings = 1>
<cfset temp = ArrayAppend(messageArray, "You cannot approve a net price decrease when rolling over a program")>
</CFIF>
</CFIF>
</CFIF>
</cfif><!------ only if getrolloverprograms_on ----->
</cfsilent>

<cfset bPromptManualApprovalSelection = 0 />
<cfset bManualApprovalSelectionRights = 0 />
<!--- Tim Ford - 01/09/2015: WR 47065 Change Order - Program Approvals --->
<!--- BEGIN :: 47065  --->
<cfif getProgramInfo.Manual_Selection_Of_Approvers>

	<cfset form.Manual_Select_Approvers = 1 />
	<!--- <cfset oOppMan = CreateObject("component","mvc.Models.Program.OnePageProgramManager").init() />
	<cfset discIdentifier = oOppMan.getDiscountIdentifier(contract_main_id) /> --->
	<!--- If the template setting is on then check if the user can select which profiles can approve if not already selected --->
	<cfif Get_Profile_Settings.Manually_Select_Approvers eq 1 and not ApprovalProgramManager.checkProgramApprovalByProfile(contract_main_id)>
		<cfset bPromptManualApprovalSelection = 1 />
	</cfif>

	<cfset CannotApproveSettings = 0 />
	<cfset ArrayClear(messageArray) />

	<cfif not ApprovalProgramManager.checkProgramApprovalByProfileUser(contract_main_id, request.AccessStructure.User_ID) AND (appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 0 OR (approvaltype EQ 0 ))>
		<!--- AND (discIdentifier = 'CPA' OR discIdentifier = 'GPO') --->
		<cfset CannotApproveSettings = 1 />
		<cfset ArrayAppend(messageArray, "Cannot approve until all eligible profiles have agreed.")>
	<cfelseif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND approvaltype EQ 0 >  <!--- AND (discIdentifier = 'CPA' OR discIdentifier = 'GPO') --->
		<cfset CannotApproveSettings = 1 />
		<cfset bPromptManualApprovalSelection = 1 />
	</cfif>

	<cfif Get_Profile_Settings.Manually_Select_Approvers eq 1 and bPromptManualApprovalSelection eq 0>
		<cfset bManualApprovalSelectionRights = 1 />
	</cfif>

</cfif>
<!--- END :: 47065  --->


<link rel="stylesheet" type="text/css" href="/common_files/jquery.maxlength.css">
<style>
	/*textarea[name=whatif_notes] + .maxlength-feedback { display: block; width: auto; margin-left: 2%; }*/
	#DIV_DONT_PRINT a {
		margin-right: 15px;
	}
	input.cb {
		position: relative;
		top: 2px;
	}
</style>

<cfif not isDefined("routinesDeclared")>
	<cfset routinesDeclared = 1 />
	<cfinclude template="\Script\cf\margin_functions.cfm">
</cfif>
<cfif url.verticalPNL eq "">         <!---  44017  --->
<style type="text/css">
		/* POPup tooltip style*/
		#divTooltip {
			position:absolute;
			top:0px;
			width:200px;
			visibility:hidden;
			z-index:200;
			background-color:#f3f3f3;
			layer-background-color:#f3f3f3;
		}
		.normalStyle {
			padding:2px;
			text-align:center;
			font-weight:500;
			width:175px;
			color:#000000;
			top:100px;
			font-family:verdana,arial,helvetica;
			font-size:11px;
			background-color:#f3f3f3;
			layer-background-color:#f3f3f3;
			border-width:1px;
			border-style:solid;
			border-color:#000000;
			cursor:default;
		}

		div#tbl-container2 {
			height: 400px;
			overflow: auto;
		}
		div#tbl-container2 table {
			table-layout: auto;
			border-collapse:collapse;
		}
		div#tbl-container2 thead th, thead th.locked	{
			text-align: left;
			background-color: #FFCE84;
			position:relative;
			cursor: default;
		}
		div#tbl-container2 table th {text-align: right;}
		div#tbl-container2 thead th {z-index: 20;	}
		div#tbl-container2 thead th.locked {z-index: 30;}
		div#tbl-container2 td.locked,  th.locked{z-index: 10;}

		div#tbl-container {
			height: 400px;
			overflow: auto;
		}

		div#tbl-container table {
			table-layout: auto;
			border-collapse:collapse;
		}

		div#tbl-container table th {
			padding: 0 5px 0 5px;
		}

		div#tbl-container thead th, thead th.locked	{
			text-align: left;
			background-color: #FFCE84;
			position:relative;
			cursor: default;
		}

		div#tbl-container thead th {
			/* Comment code as a fix for IE 10. */
			/*top: expression(document.getElementById("tbl-container").scrollTop-2);*/ /* IE5+ only */
			z-index: 20;
		}

		div#tbl-container thead th.locked {z-index: 30;}

		div#tbl-container td.locked,  th.locked{
			/* CSS Expressions are not a part of IE 10. */
			/*left: expression(parentNode.parentNode.parentNode.parentNode.scrollLeft);*/ /* IE5+ only */
			z-index: 10;
		}


		div#tbl-container td {
			text-align: left;
			padding: 0 0 0 5px;
		}

		div#tbl-container td .btns {
			text-align: center;
			padding: 10px 1px 0 1px;
			border: none;
		}
	</style>


	<style type="text/css" media="print">
		#DIV_DONT_PRINT
		{
			display:none;
		}
		div#tbl-container
	    {
   			height: auto;
   		    overflow: auto;
		}

		div#tbl-container thead th, thead th.locked
		{
			text-align: left;
			background-color: #FFCE84;
			position:fixed;
			cursor: default;

		}

		div#tbl-container thead th
		{
			top: expression(document.getElementById("tbl-container").scrollTop-2); /* IE5+ only */
			z-index: 20;
		}

		div#tbl-container thead th.locked
		{
			z-index: 30;
		}
	</style>
	<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}

	#Summary {border-top:double solid #93BEE2;border-bottom:double solid #93BEE2; font-size : 12px; color: black; font-weight : bold;}
	#header {font-size: 10px; color: black;}
	#highlight {background-color: #FFCE84;}
	#highlight a{font-size : 12px; color: black; font-weight : bold; text-decoration:none;}


</style>
<!--- D17421 [end] RBL --->



<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>

<SCRIPT>
var programGettingApproved = 0;

function keepHeaderFixed(topPosition,leftPosition){
	/* CODE FOR VERTICAL SCROLLING */
	/* Find the element which is a "<th>" */
	var cellObject = document.getElementsByTagName("th");
	   /*Loop through the "<th>" object. Look for specific "id" (below), then move that cell from the top based on scroll position.
	   The position of the "<th>" will match the scroll position.
	   */
	   for(i=0;i<cellObject.length;i++)
	   {
		if (cellObject[i].getAttribute('id') == 'header' || cellObject[i].getAttribute('class') == 'header') {
			cellObject[i].style.top = topPosition;
		}
	   }
}

		function verifySubmission(){
			if(opener){
				if(programGettingApproved == 0){

				}
			}
		}
function showCashDiscountDetails(CPID)
{
	<cfoutput>
	NewWindow('Contract_Cash_Discount_Analysis.cfm?ItemId='+CPID+'&CID=#URL.CID#&margin_type=#form.margin_type#','cashDiscountDetails','750','350','Yes', 'Yes')
	</cfoutput>
}

function showCostCalculation(CPID,type,desc){
			//window.open()

<cfoutput>	NewWindow('Contract_Cost_Analysis.cfm?ItemId='+CPID+'&CID=#URL.CID#&Type='+type+'&margin_type=#form.margin_type#','CostAnalysis','450','450','Yes', 'Yes')
</cfoutput>
		}

		function initTheTooltip(ToolTipText){
		textHolder = ToolTipText;
		messages[0]="";
		messages[0]= "" + textHolder + ""

		popUp(0)
		}
		function showPullbackCalculation(CPID){
		<cfoutput>
			NewWindow('/common_files/contracts/pullbacks/Contract_Pullback_Analysis.cfm?ProductId='+CPID+'&CID=#URL.CID#&type=CS&margin_type=#form.margin_type#','PullbackAnalysis','750','350','Yes', 'Yes')
		</cfoutput>
		}
		function selectAll(Check_Box){
		if(Check_Box == 'b')
		{
			var bCurrentCheck = document.all.checkall_1.checked;
			document.all.checkall.checked = bCurrentCheck;
		}
		else
		{
			var bCurrentCheck = document.all.checkall.checked;
			if(document.all.checkall_1)
			{
				document.all.checkall_1.checked = bCurrentCheck;
			}
		}
			if(window.checkAllProducts != null){
				if(checkAllProducts.length)
				{
					for(var x=0; x<checkAllProducts.length;x++){
						box = getFirstChild(checkAllProducts[x])
						if(box.disabled == false)
						{
						box.checked = bCurrentCheck
						}
						else
						{
							box.disabled = true
						}
					}
				}
				else
				{
					box = getFirstChild(checkAllProducts)
					box.checked = bCurrentCheck
				}
			}
			// check if pullback approvel check box is available, and if it is checked
			var oChkPullbackApproval = document.all.Approve_Pullback;
			if(oChkPullbackApproval)
			{
				if(oChkPullbackApproval.disabled == false)
				{
					oChkPullbackApproval.checked = bCurrentCheck;
				}
			}
		}



	function showGroupCalculation(Group_Id,type){
			//window.open()
<cfoutput>	NewWindow('Group_Cost_Analysis.cfm?Group_id='+Group_Id+'&CID=#URL.CID#&Type='+type,'costAnalysis','450','450','Yes', 'Yes')
</cfoutput>
		}

		function changeApproveLabel()
		{
			var bApprove = -1;

			// pullback
			var chkApprovePullback = document.all.Approve_Pullback;
			if(chkApprovePullback) // if object is found
			{
				if(chkApprovePullback.bApprovingPullbackApprovesProgram == "1") // do we need to care about this check box?
				{
					if(bApprove != 0) bApprove = chkApprovePullback.checked;
				}
			}

			// budget
			var hiddenBudgetAgreeApproveStatus = document.all.Budget_Agree_Approve_Status;
			if(hiddenBudgetAgreeApproveStatus)
			{
				if(hiddenBudgetAgreeApproveStatus) // if object is found
				{
					if(bApprove != 0)
					{
						if(hiddenBudgetAgreeApproveStatus.value == "1") // agree only
						{
							bApprove = 0;
						}
						else // can approve
						{
							bApprove = 1;
						}
					}
				}
			}

			if(bApprove != -1)
			{
				bChecked = bApprove;
				var oDivAgree = document.all.sp_agree_table;
				var oDivApprove = document.all.sp_approve_table;
				if(oDivAgree && oDivApprove)
				{
					if(bChecked)
					{
						// show approve link, hide agree link
						oDivAgree.style.display = "none";
						oDivApprove.style.display = "";
						document.all.ProgramAgree.value = "0";
					}
					else
					{
						// hide approve link, show agree link
						oDivAgree.style.display = "";
						oDivApprove.style.display = "none";
						document.all.ProgramAgree.value = "1";
					}
				}
			}

		}
	</script>
</cfif>   <!--- url.verticalPNL neq "1" --->

<script>
function showBaseSalesDetails(CPID) {
	<cfoutput> NewWindow('Contract_Base_Sales_Analysis.cfm?ItemId='+CPID+'&CID=#URL.CID#&margin_type=#form.margin_type#','baseSalesDetails','750','350','Yes', 'Yes') </cfoutput>
}
function showLocalCostCalculation(CPID,type,desc) {
	<cfoutput> NewWindow('Contract_Local_Cost_Analysis.cfm?ItemId='+CPID+'&CID=#URL.CID#&Type='+type+'&margin_type=#form.margin_type#','CostAnalysis','450','450','Yes', 'Yes') </cfoutput>
}
////////// 16314 emulate these incoming vars [begin] //////////
function showCalculation(CPID,type,desc,pid) {
	pid = pid || 0;
	<cfoutput> NewWindow('Contract_Allowance_Analysis.cfm?'
									+ 'ItemId=' + CPID
									+ '&CID=#URL.CID#'
									+ '&Type=' + type
									+ '&desc=' + desc
									+ '&margin_type=#form.margin_type#'
									+ '&duplicateprogram=#duplicateprogram#'
									+ '&verticalPNL=#URL.verticalPNL#'
									+ '&parent_element_id=' + pid
									,'tradeAnalysis','500','600','Yes', 'Yes') </cfoutput>
}
////////// 16314 emulate these incoming vars [end] //////////
function showTradeCalculation(CPID,operator) {
	<cfoutput> NewWindow('Contract_Trade_Analysis.cfm?ItemId='+CPID+'&CID=#URL.CID#&type=#(form.margin_type eq '3' ? "LB" : "CS")#&margin_type=#form.margin_type#&Operator='+operator,'tradeAnalysis','750','600','Yes', 'Yes') </cfoutput>
}
function showBrokerage(CPID) {
	<cfoutput> NewWindow('Contract_Brokerage_Analysis.cfm?ItemId='+CPID+'&CID=#URL.CID#&margin_type=#form.margin_type#','tradeAnalysis','750','350','Yes', 'Yes') </cfoutput>
}
function changemarginTypePNL( newType ) {
	var newURL = <cfoutput>"/common_files/contracts/layered_margin_calculation.cfm?CID=#URL.CID#&duplicateprogram=0&MarginRequestAction=&displayPreviousVersionMargin=0&margin_version=current&verticalPNL=#url.verticalPNL#&showProducts=#url.showProducts#&margin_type="</cfoutput> + newType + "&fixed_type=1";

	$j('form[name=MyForm]').hide();
	noty( { text: "Processing, please wait..."
	        ,layout:'topLeft'
	        ,type:'information'
	        ,killer:true
	      });

	$j("input[name=action]").val("switch_uom");
	$j('input[name=next_page_url]').val( newURL );

	$j("input[disabled=disabled]").removeAttr("disabled");
	$j('form[name=MyForm]').submit();
}

function changeUnitOfTime( newUoT ) {
	var newURL = <cfoutput>"/common_files/contracts/layered_margin_calculation.cfm?CID=#URL.CID#&duplicateprogram=0&MarginRequestAction=&displayPreviousVersionMargin=0&margin_version=current&verticalPNL=#url.verticalPNL#&showProducts=#url.showProducts#&margin_type=#form.margin_type#&UoT="</cfoutput> + newUoT + "&NewMarginUoT=1&fixed_type=1";

	window.location.href = newURL;
}

</script>

<TITLE>	<cfif url.verticalPNL eq "1">Vertical P&L<cfelseif url.verticalPNL eq "2">What If P&L<cfelse>Program Profit Analysis</cfif> </TITLE>
</HEAD>
<!--- notification structure --->
<cfscript>
    variables.noty         = {};
    variables.noty.Message = [];
    variables.noty.timeout = [];
</cfscript>
<cfif url.verticalPNL neq ''>
	<body id="verticalPNL">
<cfelse>
<body id="horizontalPNL" onload="popupInit()">
</cfif>
<!--- <LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css"> --->
<div id="divTooltip"></div>

<cfif url.verticalPNL eq "1">
	<cfset action_page = "verticalpnl_action.cfm">
<cfelseif url.verticalPNL eq "2">
	<cfset action_page = "whatif_action.cfm">
<cfelse>
	<cfset action_page = "contract_layered_Approve_Action.cfm">
</cfif>

<cfoutput>
<form action="#action_page#" method="post" name="MyForm" id="MyForm">
<input type="hidden" name="contract_main_id" value="#contract_main_id#">
<input type="hidden" name="Manual_Select_Approvers" value="#form.Manual_Select_Approvers#">
<input type="hidden" name="bFromPlanner" value="#form.bFromPlanner#">
</cfoutput>
<cfinclude template="/common_files/general_labels.cfm">
<cfif url.verticalPNL neq "">         <!---  44017  --->
<!--- 	<cfif appSettings.getShowORHideGroupsInViewMargin()>
		<fieldset style="position:relative; float:right; margin:0; width:300px; padding:2px 2px 4px 4px; border:1px solid #A3A3A3">
			<legend>[ Show / Hide Groups ]</legend>
			<label><input class="cb" type="checkbox" name="Agree" <cfif isDefined("form.Agree")>checked</cfif>>Agree</label>
			<label><input class="cb" type="checkbox" name="Approve" <cfif isDefined("form.Approve")>checked</cfif>>Approve</label>
			<label><input class="cb" type="checkbox" name="Restricted"  <cfif isDefined("form.Restricted")>checked</cfif>>Restricted</label>
			<a href="javaScript:submitMarginForm();" style="margin-left:33px;"><cfoutput>#application.util.string.actionLinkFormat2("apply all")#</cfoutput></a>
		</fieldset>
	</cfif>    ---> <!--- <cfif appSettings.getShowORHideGroupsInViewMargin()> --->
<cfelse>   <!--- cfif url.verticalPNL neq "" --->
<!---Tim Ford - Label 23377: Reformat Approved Margins page --->
<!---//////////////////// Approved Margins Header display BEGIN /////////////////////////////--->
<cfif isDefined("margin_version") and margin_version eq "approved">

	<DIV ALIGN="center"><font color="red">Below are the margins from the date the program was approved.</font></DIV><BR>
	<cfset qGetAllProgramData = objProgram.getProgramInfo(contract_main_id) />
	<cfoutput>
	<table border="0" cellspacing="0" cellpadding="0" width="100%" <cfif displayinEZmaxRate EQ 0> Style="display:none;"</cfif>>
		<tr valign="top">
			<td valign="top">
				<table BORDER="0" CELLPADDING="0" CELLSPACING="0">
					<tr valign="top">
						<td style="padding:2px; font-weight:bold;">
							Program&nbsp;
						</td>
						<td style="border-left: 1px solid CCCCCC; padding-left:5px; font-weight:bold;">
							#Replace(getProgramInfo.Contract_Number,"000-","")#<cfif getProgramInfo.Contract_Status_Type_IDX GT 2>-<cfif len(getProgramInfo.revision_version) eq 4>#right("#getProgramInfo.revision_version#", 4)#<cfelseif len(getProgramInfo.revision_version) eq 5>#right("#getProgramInfo.revision_version#", 5)#<cfelse>#right("000#getProgramInfo.revision_version#", 3)#</cfif></cfif>&nbsp;
						</td>
					</tr>
					<tr>
						<td style="padding:2px;font-weight:bold;">
							Title&nbsp;
						</td>
						<td style="border-left: 1px solid CCCCCC; padding-left: 5px; font-weight:bold;">
							#getProgramInfo.Contract_Title#&nbsp;
						</td>
					</tr>
					<tr>
						<td style="padding:2px;font-weight:bold;">
							#general_labels[ delivery_period ]#&nbsp;
						</td>
						<td style="border-left: 1px solid CCCCCC; padding-left: 5px; font-weight:bold;">
							#DateFormat(getProgramInfo.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(getProgramInfo.Contract_End_Date, "mm/dd/yyyy")#&nbsp;
						</td>
					</tr>
					<tr>
						<td style="padding:2px;font-weight:bold;">
							Program Type&nbsp;
						</td>
						<td style="border-left:1px solid CCCCCC; padding-left:5px;font-weight:bold;">
							#qGetAllProgramData.Created_Type#&nbsp;
						</td>
					</tr>
				</table>
			</td>
			<td valign="top">
				<table BORDER="0" CELLPADDING="0" CELLSPACING="0">
					<tr valign="top">
						<td style="padding:2px;font-weight:bold;">
							Approved On&nbsp;
						</td>
						<td style="border-left: 1px solid CCCCCC; padding-left:5px; font-weight:bold;">
							#DateFormat(qGetAllProgramData.Approval_Date, "mm/dd/yyyy")#&nbsp;
						</td>
					</tr>
					<tr>
						<td style="padding:2px;font-weight:bold;">
							Discount Identifier&nbsp;
						</td>
						<td style="border-left: 1px solid CCCCCC; padding-left: 5px; font-weight:bold;">
							<cfif isNumeric(getSettings.Discount_Identifier_ID) and getSettings.Discount_Identifier_ID gt 0>
								<!---TODO: Move query from the view page into a function--->
								<cfquery name="qGetDiscountIdentifier" datasource="#application.datasource#">
									SELECT 	Discount_Identifier_Number,
											Discount_Identifier_Desc
									FROM 	Discount_Identifier
									WHERE 	Discount_Identifier_ID = <cfqueryparam value="#getSettings.Discount_Identifier_ID#" cfsqltype="CF_SQL_INTEGER" />
								</cfquery>
							(#qGetDiscountIdentifier.Discount_Identifier_Number#)&nbsp;&nbsp;#qGetDiscountIdentifier.Discount_Identifier_Desc#
							</cfif>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td style="padding:2px;font-weight:bold;">
							#application.returned_customer_setting.reference_number_label#&nbsp;
						</td>
						<td style="border-left: 1px solid CCCCCC; padding-left: 5px; font-weight:bold;">
							#qGetAllProgramData.Contract_Reference_Number#&nbsp;
						</td>
					</tr>
					<tr>
						<td style="padding:2px;font-weight:bold;">&nbsp;

						</td>
						<td style="border-left:1px solid CCCCCC; padding-left:5px;font-weight:bold;">&nbsp;

						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<p>
	<input name="margin_version" value="#margin_version#" type="hidden" />
	</cfoutput>
<!---//////////////////// Approved Margins Header display END /////////////////////////////--->
<!---//////////////////// View Margins Header display BEGIN ///////////////////////////////--->
<cfelse>
<!---     <cfif displayinEZmaxRate neq 0>
        <!--- ngt --->
        <style>
            input[type=checkbox] {
                position: relative;
                top: 2px;
            }
        </style>

        <cfoutput>
        <fieldset style="width:260px;float:right;">
            <legend>[ Show / Hide Groups ]</legend>
            <input type="checkbox" name="Agree" <cfif isDefined("form.Agree")>checked</cfif>>Agree
            <input type="checkbox" name="Approve" <cfif isDefined("form.Approve")>checked</cfif>>Approve
            <input type="checkbox" name="Restricted"  <cfif isDefined("form.Restricted")>checked</cfif>>Restricted&nbsp; &nbsp; &nbsp;
            <A HREF="##" onClick="submitMarginForm();; return false;" STYLE="COLOR:0000FF;">#application.util.string.actionLinkFormat2("apply all")#</A>
        </fieldset>
        </cfoutput>

        <div style="clear:both;margin-bottom:10px;"></div>
    </cfif> --->
</cfif>

<!---//////////////////// View Margins Header display END ///////////////////////////////--->
</cfif>   <!--- url.verticalPNL eq ""> --->

<!--- 16314 TESTING 16314 TESTING 16314 TESTING
<cfset variables.testVar = 5> --->
<input name="lAgreeReason" type="hidden" value="<cfoutput>#form.lAgreeReason#</cfoutput>" />


<!---D45761 :: Approval Workflow START --->
<cfif url.verticalPNL eq "" and displayinEZmaxRate EQ 0>
	<cfset none = "none">
<cfelse>
	<cfset none = "block">
</cfif>

<div style="display:<cfoutput>#none#</cfoutput>;">
	<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
		<cfif margin_display_style is "custom_t">
			<cfinclude template="layered_program_approval_t.cfm">
		<cfelseif margin_display_style is "custom_h">
			<cfinclude template="layered_program_approval_h.cfm">
		<cfelse>
			<cfinclude template="layered_program_approval.cfm">
		</cfif>
	<cfelseif Get_Profile_Settings.program_margin_approval_method IS 6>
		<!--- fyi: this option tends to throw unrelated errors to 16314 RBL --->
		<cfinclude template="disposable_program_approval.cfm">
	<cfelseif Get_Profile_Settings.program_margin_approval_method IS 7>
		<!--- fyi: this option tends to throw unrelated errors to 16314 RBL --->
		<cfinclude template="standard_program_approval.cfm">
	<!--- <cfelseif Get_Profile_Settings.program_margin_approval_method IS 6 and url.groupapproval EQ 0>
		<cfinclude template="disposable_item_analysis.cfm"> --->
	</cfif>
</div>

<!---D45761 :: Approval Workflow END --->
<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif url.verticalPNL eq ''>
	<cfset ShowLSAutoApproveMessage = 0>
		<!--- LS auto approval notification --->

<cfset ShowLSAutoApproveMessage = 0>
	<!--- LS auto approval notification --->
	<cfquery name="GetAutoPayLS" datasource="#application.datasource#">
	SELECT	Program_Lump_Sums.Program_Lump_Sum_ID,
			Program_Lump_Sums.Split_For_Auto_Pay
	FROM 	Program_Lump_Sums
		INNER JOIN Payment_Type
		ON 	Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
		AND	Payment_Type.Is_Auto_Pay = 1
	WHERE 	Program_Lump_Sums.Program_ID = '#Contract_Main_ID#'
		AND	Program_Lump_Sums.Deleted = 0
	</cfquery>

	<cfif GetAutoPayLS.Recordcount GT 0>
		<cfset ShowLSAutoApproveMessage = 1>
	</cfif>

	<cfif ShowLSAutoApproveMessage IS 1>
		<div align="center"><strong>Please note:</strong> this program has a lump sum created as an auto payment. When this program is approved, that lump sum will immediately be released for payment.</div><br>
	</cfif>

<cfif (getProgramInfo.Approval_Considerations_ID NEQ 0)>
	<cfset ApprovalConsiderationsID = getProgramInfo.Approval_Considerations_ID />
<cfelse>
	<cfset ApprovalConsiderationsID = -1 />
</cfif>

<cfoutput>
<DIV ALIGN="center" ID="DIV_DONT_PRINT" style="margin-top: 15px;">
	<cfif url.verticalPNL is ''
			and
				(margin_display_style is "custom_t" OR margin_display_style is "custom_h")
			and get_Profile_Settings.View_LH_pane_Vertical_P_L>
		<a href="javascript:verticalPNL(1)">#application.util.string.actionLinkFormat2('vertical p&l')#</a>
	</cfif>

	<a href="javascript:getCSVData();" id="csv">#application.util.string.actionLinkFormat2('export to csv')#</a>
	<a id="close_window" href="javascript:window.close();">#application.util.string.actionLinkFormat2('close this window')#</a>
	<a href="javascript:window.print();">#application.util.string.actionLinkFormat2('print')#</a>

	<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2 and bManualApprovalSelectionRights eq 1>
		<a href="javascript:NewWindowTopLeft('manual_approval_selection_popup.cfm?Formname=MyForm&programID=#contract_main_id#&templateID=#getProgramInfo.ProgramType_ID#','ManualApprovalSelection','800','600','Yes', 'Yes');">#application.util.string.actionLinkFormat2('edit users to approve')#</a>
	</cfif>

	<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2><!------ If not yet approved ----->
		<cfif appSettings.getPgmEmailPricingAdmin() EQ 1><!------ If PgmEmailPricingAdmin setting is on ----->
			<a href="javascript:emailPricingAdmin();">#application.util.string.actionLinkFormat2('email pricing admin')#</a>
		</cfif>
	</cfif>

	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2  AND (approvaltype EQ 1 OR agreetype EQ 1)>
		<cfset useragreed = 0>
		<CFINCLUDE template="program_agree.cfm">

		<cfif CannotApproveSettings EQ 1>
			<cfset button_label = "Agree">
			<cfset bProgramFinalApprove = 0 />
		</cfif>

		<cfset sApproveLabel = "" />
		<cfset sAgreeLabel = " style=""display:none""" />
		<cfparam name="programAgreeOnlyForBudgetDollar" default="0">
		<cfif bApprovingPullbackApprovesProgram or programAgreeOnlyForBudgetDollar or CannotApproveSettings EQ 1>
			<cfset sApproveLabel = " style=""display:none""" />
			<cfset sAgreeLabel = "" />
		</cfif>

		<cfif getAllProductMargins.recordCount GT 0><!------There are products ----->
			<cfif bProgramFinalApprove EQ 0>
				<a href="javascript:saveProgram('save_table');">#application.util.string.actionLinkFormat2( button_label )#</a>

				<cfif button_label eq "Agree" or button_label eq "Approve">
					<cfif Get_Profile_Settings.program_margin_approval_method NEQ 7>
						<span id="sp_disagree_table">
							<a href="javascript:disagreeProgram('disagree_table');">#application.util.string.actionLinkFormat2( 'disagree' )#</a>
						</span>
				  	</cfif>
				</cfif>
			<cfelse>
				<span id="sp_approve_table" #sApproveLabel#>
					<a href="javascript:saveProgram('approve_table');">#application.util.string.actionLinkFormat2( 'approve' )#</a>
				</span>
				<span id="sp_agree_table" #sAgreeLabel#>
					<a href="javascript:saveProgram('agree_table');">#application.util.string.actionLinkFormat2( 'agree' )#</a>
				</span>

				<cfif bProgramFinalApprove NEQ 0 and Get_Profile_Settings.program_margin_approval_method NEQ 7>
					<span id="sp_disagree_table">
						<a href="javascript:disagreeProgram('disagree_table');">#application.util.string.actionLinkFormat2( 'disagree' )#</a>
					</span>
				</cfif>
			</cfif>
		<cfelse><!------ There are no products ----->
			<cfif CannotApproveSettings EQ 0><!------ No errors and There are no products ----->

				<span id="sp_approve_table" #sApproveLabel#>
					<a href="javascript:saveProgram('approve_table');">#application.util.string.actionLinkFormat2( 'approve' )#</a>
				</span>
				<span id="sp_agree_table" #sAgreeLabel#>
					<a href="javascript:saveProgram('agree_table');">#application.util.string.actionLinkFormat2( 'agree' )#</a>
				</span>

			<cfelse><!------ There are errors and there are no products ----->
				<cfif  useragreed EQ 0><!------ No products and I have not agreed and there are errors ----->
					<!---TSF: Label 9186
						if the program_margin_approval_method equals 5 then call the submitagree() java script function, otherwise call the program_agree_action.cfm link
					  --->
					<cfif Get_Profile_Settings.program_margin_approval_method IS 5><!------ No products and I have not agreed and there are errors, and standard approval scheme ----->
						<a href="javascript:submitagree();">#application.util.string.actionLinkFormat2( 'agree' )#</a>
					<cfelse><!------ No products and I have not agreed and there are errors, and not standard approval scheme ----->
						<a href="program_agree_action.cfm?User_Id=#request.AccessStructure.User_id#&CID=#Url.CID#">#application.util.string.actionLinkFormat2( 'agree' )#</a>
					</cfif>
				<cfelse><!------ No products and I have agreed and there are errors ----->
					<a href="##">#application.util.string.actionLinkFormat2( 'agreed' )#</a>
				</cfif>
			</cfif>
			<!--- D39284 :: No Disagree Button
				bProgramFinalApprove NEQ 0 and
				 --->
			<cfif Get_Profile_Settings.program_margin_approval_method NEQ 7>
				<span id="sp_disagree_table">
					<a href="javascript:disagreeProgram('disagree_table');">#application.util.string.actionLinkFormat2( 'disagree' )#</a>
				</span>
			</cfif>
		</cfif>

		<cfif Get_Profile_Settings.program_margin_approval_method IS 7>
			<a href="javascript:submitreject();">#application.util.string.actionLinkFormat2( 'disagree' )#</a>
		</cfif>

		<!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes --->
		<cfif programagreed GT 0 and getProgramInfo.modifying_program EQ 0 and getProgramInfo.Contract_Status_Type_IDX EQ 2 and appsettings.GETMODIFYAGREEPROGRAM() AND appsettings.getdisablepagesinrfa() EQ 0>
			<a href="javascript:submiteditprogram();">#application.util.string.actionLinkFormat2( 'modify agreed program' )#</a>
		</cfif>
	</cfif>

	<cfif getProgramInfo.RevisionTypeA EQ 1 or getProgramInfo.RevisionTypeB EQ 1 or getProgramInfo.RevisionTypeC EQ 1>
		<a href="javascript:submitrevisionchanges();">#application.util.string.actionLinkFormat2( 'view revision changes' )#</a>
	</cfif>
</DIV>
</cfoutput>

<cfset getgroupswithoutproducts = ApprovalManager.getGroupswithoutProducts(contract_main_id)>
<cfif getgroupswithoutproducts.recordcount GT 0>
<CFSET discounttypelist = "">

<table class="Maintable" cellpadding="0" cellspacing="0" width="50%" border="0" Style="display:<cfoutput>#none#</cfoutput>;">
 <TR>
    <TD ID="header" colspan="4" STYLE="font-size: 15px; font-weight:bold; color: Navy;border-bottom:none;">Groups without products<br></TD>
</TR>
 <TR>
 <TD ID="header" VALIGN="top" width="120"><B>Description</B></TD>
 <cfif GetSettings.Discount_Rebates  EQ 1>
 <TD ID="header" VALIGN="top"><B>
	<cfoutput>#Application.RebateLabel#</cfoutput></B></TD>
 </cfif>
 <cfif GetSettings.Discount_Lump_Sums EQ 1>
 <TD ID="header" VALIGN="top"><B>Lumpsum</B></TD>
 </cfif>
 <cfif GetSettings.Discount_Growth EQ 1>
 <TD ID="header" VALIGN="top"><B>Growth</B></TD>
 </cfif>
 <CFIF GetSettings.Generic_Type IS "Distributor Off-Invoice">
  <TD ID="header" VALIGN="top"><B>Off Invoice</B></TD>
 </CFIF>
 </TR>

 <cfoutput query="getgroupswithoutproducts" group="group_id">
<tr BGCOLOR="f4f4f4">
<td width="120" valign="top">#Description#</td>
	<cfif GetSettings.Discount_Rebates  EQ 1>
	<td valign="top">
	<table>
	<cfoutput>
	<tr>
		<cfif getgroupswithoutproducts.product_type_id EQ 2>
		<td style="border-bottom:none" valign="top">
      <cfif getgroupswithoutproducts.UOM EQ 3>
        #trim(numberformat(rate,request.dollar_format))##Abbreviation#
      <cfelse>
    	  #application.util.string.cellFormat(value=rate ,decimalplaces = request.dollar_format)#/#Abbreviation#
      </cfif>
		</td>
		</cfif></tr>
	</cfoutput>
	</table>
	</td>
	</cfif>
	<cfif GetSettings.Discount_Lump_Sums EQ 1>
	<td valign="top">
	<table>
	<cfoutput>
	<tr valign="top">
		<cfif getgroupswithoutproducts.product_type_id EQ 3>
		<td style="border-bottom:none" valign="top">
		<span STYLE="cursor:pointer;" onMouseOver="initTheTooltip('This group has lumpsum.')" onMouseOut="popOut()"><font color="red">*</font></span>
		</td>
		</cfif>
	</tr>
	</cfoutput>
	</table>
	</td>
	</cfif>
	<cfif GetSettings.Discount_Growth EQ 1>
	<td valign="top">
	<table>
	<cfoutput>
	<tr>
		<cfif getgroupswithoutproducts.product_type_id EQ 4>
		<td style="border-bottom:none" valign="top">
      <cfif getgroupswithoutproducts.UOM EQ 3>
        #trim(numberformat(rate,request.dollar_format))##Abbreviation#
      <cfelse>
    	  #application.util.string.cellFormat(value=rate ,decimalplaces = request.dollar_format)#/#Abbreviation#
      </cfif>
		</td>
		</cfif></tr>
	</cfoutput>
	</table>
	</td>
	</cfif>

</tr>
</cfoutput>
</table>
</cfif>
<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2  AND (approvaltype EQ 1 OR agreetype EQ 1)>

<CFSCRIPT>
	Border="Yes";
	BorderSize=1;
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Blue";
	TitleFont="Arial";
	TitleSize=9;
	IsClosed="Yes";
</CFSCRIPT>

<cfif latestTemplateLumpSumCap NEQ 0 and latestTemplateLumpSumCap NEQ "">
<table Style="display:<cfoutput>#none#</cfoutput>;">
<tr>
<td width="7%">&nbsp;</td>
	<td width="93%" valign="top">
	<CF_OPENLAYER
	BORDER="#Border#"							BORDERSIZE="#BorderSize#"
	BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
	IMAGEOPEN="#ImageOpen#"						TITLE="#Application.LumpsumLabel# Balance Information"
	TITLECLOSED="#Application.LumpsumLabel# Balance Information"		TITLETOOLTIP="Click here to toggle view"
	TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
	TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">

	<cfset displayLumpsumBalanceHeader = 0 />
	<cfinclude template="contract_lumpsum_balance_info.cfm">

	</CF_OPENLAYER>
	</td>
	</tr>
</table>
</cfif>
<cfif ArrayLen(messageArray) GT 0>
	<TABLE Style="display:<cfoutput>#none#</cfoutput>;">
	<tr>
	<td width="2" valign="top">
		<IMG SRC="/images/exclamation.gif"onmouseover="initTheTooltip('Click on Error Messages to check errors','AG')" onMouseOut="popOut()">
	</td>
	<td width="100%" valign="top">
		<CF_OPENLAYER
		BORDER="#Border#"							BORDERSIZE="#BorderSize#"
		BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
		IMAGEOPEN="#ImageOpen#"						TITLE="Messages"
		TITLECLOSED="Messages"						TITLETOOLTIP="Click here to toggle view"
		TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
		TITLESIZE="#TitleSize#"						ISCLOSED="No"
		WIDTH = "98%">
		<CFSET TD_Width = 80>


		<cfset ErrorList = ArrayToList(messageArray, "||")>

		<TABLE align="Left">
		<cfoutput>
			<cfloop list="#ErrorList#" index="error" delimiters="||">
				<TR>
					<TD>
					<span STYLE="color: red;">	#Replace(error, "\n", "<br>", "all")# </span>
					</TD>
				</TR>
			</cfloop>
		</cfoutput>
		</TABLE>
		</CF_OPENLAYER>
	</td>
	</tr>
	</TABLE>

	<cfset lAgreeReasons = ArrayToList(messageArray, '|') />
	<cfset lAgreeReasons = ReplaceNoCase(lAgreeReasons, '"', '', 'ALL') />
	<!--- D32620:EZ Button Routing Incorrectly START--->
	<!--- <cfset lAgreeReasons = ReplaceNoCase(lAgreeReasons, "\n", "#chr(10)##chr(13)#", "ALL") /> --->
	<cfset form.lAgreeReason = lAgreeReasons>
	<!--- D32620:EZ Button Routing Incorrectly END--->

		<script>
			if(document.all.lAgreeReason)
			{
				document.all.lAgreeReason.value = "<cfoutput>#lAgreeReasons#</cfoutput>";
			}
		</script>
	</cfif>
</cfif>
<!---D48315 :: Reduce Business Consideration auto pop-ups---- 8.0 Release ONLY START--->
<cfset useLakebaseForCSLGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForCSLGetContractInfo>
	<cftry>
		<cfset CSLGetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#contract_main_id#",
				"select" = "broker_user_id"
			}), "broker_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCSLGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCSLGetContractInfo>
<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT Broker_User_ID
	FROM  Contract_main
	WHERE Contract_Main_ID = '#contract_main_id#'
</cfquery>
</cfif>
<!---D48315 :: Reduce Business Consideration auto pop-ups---- 8.0 Release ONLY END --->
<script>
function submitreject()
{
	if(confirm("Are you sure you want to disagree with this program?"))
	{
		<!--- Dev Note: KAL; 8891 --->
		<cfif display_business_consideration AND (CSLGetContractInfo.Broker_User_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
			 NewWindowTopLeft('evaluationnotes.cfm?mode=1&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&reject=1','EvaluationNotes','1050','600','Yes', 'Yes');
		<cfelse>
			if(document.all.MyForm.reject){
				document.all.MyForm.reject.value = 1;
				document.all.MyForm.action = "program_reject_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>";
				document.all.MyForm.submit();
			}
		</cfif>
	}
}

function  submitrevisionchanges()
{
<!--- D32837 :[view revision changes] from margin page-Volume issue --->
	NewWindow('revision_changes_popup.cfm?Formname=MyForm&programid=<cfoutput>#contract_main_id#</cfoutput>&parentid=<cfoutput>#getProgramInfo.Revision_of_Contract_Main_ID#</cfoutput>&programspan=<cfoutput>#getProgramInfo.Program_Span#</cfoutput>','RevisionChanges','500','400','Yes', 'Yes');
}
function submitagree()
{
	<!--- Dev Note: KAL; 8891 --->
	<cfif display_business_consideration AND (CSLGetContractInfo.Broker_User_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
	 	 NewWindowTopLeft('evaluationnotes.cfm?mode=1&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&agree=1&ProgramAgree=1','EvaluationNotes','1050','600','Yes', 'Yes');
	<cfelse>
		if(document.all.MyForm.ProgramAgree){
			document.all.MyForm.ProgramAgree.value = 1;
			document.all.MyForm.submit();
		}
	</cfif>
}

function everythingchecked()
{
var checkcomplete = true;
	if(window.checkAllProducts != null)
		{
				if(checkAllProducts.length)
				{
					for(var x=0; x<checkAllProducts.length;x++){
						box = getFirstChild(checkAllProducts[x])
						if(box.disabled == false)
						{
							if(box.checked == false)
							{
								checkcomplete = false;
							}
						}
					}
				}
		}
	// check if pullback approvel check box is available, and if it is checked
	var oChkPullbackApproval = document.all.Approve_Pullback;
	if(oChkPullbackApproval)
	{
		if(oChkPullbackApproval.disabled == false)
		{
			if(oChkPullbackApproval.checked == false)
			{
				checkcomplete = false;
			}
		}
	}
	return checkcomplete;
}

function saveProgram(sTableName)
{
	var checkprod = everythingchecked();
	if (checkprod == true)
	{
		var bContinue = true;
		<!---
		25715: Budgeting
		No longer needed for advanced budget
		<cfif appSettings.getBudgetsFunctionalityOn()>
			<!------ check if we have to stop the user for any reason ------->
			bContinue = programBudgetValidateOnApprove();
		</cfif>
		--->

		<cfif bPromptManualApprovalSelection eq 1>
			if(confirm("Users to approve this program have not been selected. Please click ok to select users."))
			{
				NewWindowTopLeft('manual_approval_selection_popup.cfm?Formname=MyForm&programID=<cfoutput>#contract_main_id#</cfoutput>&templateID=<cfoutput>#getProgramInfo.ProgramType_ID#</cfoutput>','ManualApprovalSelection','800','600','Yes', 'Yes');
			}
			return;
		</cfif>

		if(bContinue)
		{
			<!--- Dev Note: KAL; 8891 --->
			disableButton(sTableName, true, false);

			var iProgramAgree = MyForm.ProgramAgree.value;
			<cfif display_business_consideration AND (CSLGetContractInfo.Broker_User_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
				<cfif showagreepopup EQ 0>
					NewWindowTopLeft('evaluationnotes.cfm?mode=6&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&ProgramAgree=' + iProgramAgree,'EvaluationNotes','1050','600','Yes', 'Yes');
					<cfelse>
					NewWindowTopLeft('evaluationnotes.cfm?mode=1&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
				</cfif>
			<cfelse>
				MyForm.submit();
			</cfif>
		}
	}
	else
	{
		alert("In order to continue you are required to take action on all items. Please place a check mark on all items above.");
	}

}

function disagreeProgram(sTableName)
{
	disableButton(sTableName, true, false);
	if(confirm("Are you sure you want to disagree and reset this program to Work in Progress status?"))
	{
		<cfif display_business_consideration AND (CSLGetContractInfo.Broker_User_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
	 		NewWindowTopLeft('EvaluationNotes.cfm?MODE=9&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&Disagreed=1','EvaluationNotes','1050','600','Yes', 'Yes');
		<cfelse>
			if(document.all.MyForm.Disagreed){
				document.all.MyForm.Disagreed.value = 1;
				document.all.MyForm.action = "contract_kickback_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&Disagreed=1";
				document.all.MyForm.submit();
			}
		</cfif>
	}
}

function submiteditprogram()
{
	<cfoutput>
	var sMsg = "The #approvalGroupType.Label#'s which you are responsible for will have their previous agreements/approvals cleared and reset.  Changes made to this program will require you to agree/approve the #approvalGroupType.Label#'s you are responsible for again.";
	<cfif bPullbackApproved>
	sMsg = sMsg + "\nThe #appSettings.getPullbackLabelLower()# approval will be reset and will need to be approved again.";
	</cfif>
	</cfoutput>
	if(confirm(sMsg))
	 {
	 	document.MyForm.action = "reset_program_agreed.cfm?CID=<cfoutput>#URL.CID#</cfoutput>";
		MyForm.submit();
	 }
}

function printPage()
{
	window.print();
}
function emailPricingAdmin()
{
	<cfoutput>
	var sURL = "Email_Pricing_Admin.cfm?CID=#URL.CID#";
	</cfoutput>
	NewWindowTopLeft(sURL,'BusinessConsiderations','700','500','Yes', 'Yes');
}
function approvalConsiderationsPopup()
{
	<cfoutput>
	var sURL = "/settings/ApprovalConsiderationsPopup.cfm?acid=#ApprovalConsiderationsID#";
	</cfoutput>
	NewWindowTopLeft(sURL,'BusinessConsiderations','700','500','Yes', 'Yes');
}

<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
//Hide the Progress Bar
 if(document.getElementById('Progress_Bar')){
 	document.getElementById('Progress_Bar').style.display = 'none';
 }
 </cfif>
</script>
<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 7>
	<cfif IsDefined("NewMargin")>
		<cfif NewMargin eq 1>
			<cfset ProgramMarginLog.DeleteMarginLogInfo(trim(contract_main_id))>
		</cfif>
	</cfif>
</cfif>
<cfif Program_Is_A_Revision AND (Get_Profile_Settings.program_margin_approval_method IS 5)>
	<script type='text/javascript'>_marginConfig = {'_cfscriptLocation':'/components/programs/Approval/layered_program_approval.cfc', '_jsscriptFolder':'/Script/javascript/Ajax_JS','debug':false};</script>
	<cf_include files='/Script/javascript/Ajax_JS/ajax.js, /Script/javascript/dhtml.js'>
	<script>
		function refreshPreviousMargin()
		{
			<!--- Delete Current Margin log entries --->
			DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'DeleteMarginLogInfo', <cfoutput>'#trim(getProgramInfo.Revision_of_Contract_Main_ID)#'</cfoutput>,PlaceHolderFunction);
			DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'DeleteMarginLogStatusInfo', <cfoutput>'#trim(getProgramInfo.Revision_of_Contract_Main_ID)#'</cfoutput>,PlaceHolderFunction);

			<!--- Add new Margin log entries --->
			DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'setMarginLogInfo', <cfoutput>'#trim(getProgramInfo.Revision_of_Contract_Main_ID)#'</cfoutput>,PlaceHolderFunction);
			DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'setMarginLogStatusInfo', <cfoutput>'#trim(getProgramInfo.Revision_of_Contract_Main_ID)#','#request.AccessStructure.User_ID#',1</cfoutput>,PlaceHolderFunction);

			<!--- Calculate parent margin --->
			DWREngine._execute(_marginConfig._cfscriptLocation, null, 'getProfitMarginLayered', <cfoutput>'#trim(getProgramInfo.Revision_of_Contract_Main_ID)#'</cfoutput>,updateMarginLog);

			disableButton("btnRefreshPreviousMargin", true, false);
		}
		function updateMarginLog(returnVal){
			<!--- Update Margin log entries --->
			DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'UpdateMarginLogStatusInfo', <cfoutput>'#trim(getProgramInfo.Revision_of_Contract_Main_ID)#','2'</cfoutput>,reloadPage);
		}
		function reloadPage(){
			window.location.reload();
		}

	</script>
</cfif>
</cfif>    <!--- url.verticalPNL neq '1'> --->
</form>

<cfset jQueryUI.version = "1.9.1">
<cfset jQueryUI.widgets = "full">
<cfinclude template="/common_files/jQuery.cfm">
<form action="/common_files/csv.cfm" method ="post" id="csv_form">
<input type="hidden" name="csv_text" id="csv_text">
<cfif url.verticalPNL eq "">         <!---  44017  --->
	<input type="hidden" name="csv_file_name">
	<cf_include files="/script/javascript/table2csv.js">
<cfelse>
	<input type="hidden" name="csv_file_name">
	<!--- <cf_include files=#arrayToList([	"/Script/javascript/GridViewScroll2Csv.js"
										, "/Script/javascript/gridviewScroll.min.js"
										, "/script/javascript/jquery.cfjs.min.js"
										, "/script/javascript/jquery.util.js"
										, "/script/javascript/numeral.min.js"
										, "/script/javascript/jquery.noty.packaged.min.js"
										, "/script/javascript/jquery.plugin.min.js"
										, "/script/javascript/jquery.maxlength.min.js"
                                    ])#> --->

	<cf_include files=#arrayToList([	"/Script/javascript/GridViewScroll2Csv.js"
										, "/script/javascript/gridviewscroll/1.0/gridviewscroll.js"
										, "/script/javascript/jquery.cfjs.min.js"
										, "/script/javascript/jquery.util.js"
										, "/script/javascript/numeral.min.js"
										, "/script/javascript/jquery.noty.packaged.min.js"
										, "/script/javascript/jquery.plugin.min.js"
										, "/script/javascript/jquery.maxlength.min.js"
									])#>

</cfif>
</form>

<cfset cfm_js_file = (margin_display_style is "custom_t"
					? "layered_approval_include_t_js.cfm"
					: "layered_approval_include_js.cfm")>

<cfset cfm_js_file = (margin_display_style is "custom_h"
					? "layered_approval_include_h_js.cfm"
					: "layered_approval_include_js.cfm")>
<cfinclude template="#cfm_js_file#">
<script>
<!--- 76537 :: Margin analysis to various targets START --->
function MarginTargetComparison(){
	<cfoutput>
		NewWindow('Margin_Target_Comparison.cfm?CID=#URL.CID#&FirstParentID=#qGetTemplate.First_Parent_ID#&Status=#getProgramInfo.Contract_Status_Type_IDX#&Price_Type=1&margin_version=#margin_version#','MarginTargetComparison','1200','1000','Yes', 'Yes')
	</cfoutput>
}
</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>