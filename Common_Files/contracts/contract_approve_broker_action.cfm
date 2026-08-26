<cfif Not isDefined("FORM.ApproveContract") and isDefined("url.CID")>
	<cfset FORM.ApproveContract = url.CID >
</cfif>
<cfset Approve_Contract_ID = FORM.ApproveContract>

<!--- Dev Note: drachala; D28582: Element CID is undefined in URL error when submitting prg for approval  START --->
<cfif isDefined("FORM.ApproveContract")>
<cfset url.CID = FORM.ApproveContract>
</cfif>
<!--- End Dev Note: drachala; D28582: Element CID is undefined in URL error when submitting prg for approval  --->
<cfparam name="BUSINESS_CONSIDERATIONS" default="">
<cfif isDefined("url.passedForm")>
	<cfset form.passedForm = url.passedForm>
	<cfset form.dupAction = url.dupAction>
	<cfset duplicateprogram = url.duplicateprogram >
</cfif>
<cfparam name="url.BUSINESS_CONSIDERATIONS" 	default="">
<cfparam name="form.BUSINESS_CONSIDERATIONS" 	default="#url.BUSINESS_CONSIDERATIONS#">
<cfset BUSINESS_CONSIDERATIONS = form.BUSINESS_CONSIDERATIONS>
<cf_cryp type="de" key="#request.key#" string="#FORM.ApproveContract#">
<cfset ContactContractId = #cryp.value#>
<cfparam name="duplicateprogram" 				default="false">
<cfparam name="FORM.from_duplicate_approve" 	default="0">
<cfparam name="form.dupAction"					default="0">
<cfparam name="checkDuplicateProgram" 			default="1">
<cfparam name="form.passedForm"					default="">
<cfparam name="form.BackTotemplate"				default="">
<cfparam NAME="DuplicateProgramIDList" DEFAULT="">
<cfparam NAME="IncludeProgressBar" DEFAULT="0">
<cfparam NAME="Form.approvaltype" DEFAULT="">
<cfparam NAME="Form.Cont_Prog_Approval_Rights" DEFAULT="">
<cfparam NAME="URL.mfnComplete"	DEFAULT="0">
<cfparam NAME="mfnExists" 		DEFAULT="0">

<cfset bAutoApproveProgram = 0 />

<cfif checkDuplicateProgram>
	<cfset checkDuplicateProgram = NOT FORM.from_duplicate_approve />
</cfif>

<!--- 34392 FOB vs DEL validation :: if validation fails this rfa process would stop otherwise it would continue with all logic below --->
<!--- Dev Note -Milan (38629). Validation (including validation at the distributor level, which does not exist on "greatest_program_value.cfm")
has been added to the "rates" grid and so we do not need validation here anymore. No need to maintain the logic in 2 places.
<cfmodule template="greatest_program_value.cfm" 	Program_ID = #cryp.value#  	Return_To_Page = "contract_edit_menu.cfm?CID=#URL.CID#">
--->

<cfquery NAME="getProgramTemplateInfo" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT	dbo.Program_Control_Panel_Options.Check_Duplicate_Program,
				 	dbo.Program_Control_Panel_Options.Active,
				 	dbo.Program_Control_Panel_Options.Deleted,
				 	dbo.Contract_Main.Parent_Revised_Contract_Main_ID,
				 	dbo.Contract_Main.Revision_of_Contract_Main_ID,
				 	Contract_Main.Contract_Status_Type_IDX,
				 	dbo.Program_Control_Panel_Options.Email_Letters_On_Approval,
				 	dbo.Program_Control_Panel_Options.First_Parent_ID,
				 	dbo.Program_Control_Panel_Options.Item_Fixed_Rebate_Paid_To_Dup_Message,
				 	dbo.Program_Control_Panel_Options.Program_Date_Type,
					Contract_Main_Aux_Data.Program_Most_Favored_Nation,
					Program_Control_Panel_Options.Generic_Type,
					Program_Control_Panel_Options.Created_Type,
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID,
					Program_Control_Panel_Options.Disable_Duplicate_Check_For_Revisions,
					Program_Control_Panel_Options.Pullbacks_On,
					Program_Control_Panel_Options.is_pullback_corporate_deal,
					Contract_Main.Contract_Number
					,Contract_Main.ProgramType_ID 
					,Allow_Vendor_Only
	FROM dbo.Contract_Main
		INNER JOIN dbo.Program_Control_Panel_Options ON dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		INNER JOIN Contract_Main_Aux_Data ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
		WHERE dbo.Contract_Main.Contract_Main_ID = '#cryp.value#'
</cfquery>

<cfif not isDefined("Get_Profile_Settings")>
<cfinclude template="/get_access_profile.cfm" />
</cfif>

<cfset checkDuplicateProgram = getProgramTemplateInfo.Check_Duplicate_Program />

<cfif getProgramTemplateInfo.Contract_Status_Type_IDX EQ 1> <!------ Do logic for RFA only if program is already in WIP, to avoid page refresh and double clicks causing duplicate emails ----->


<CFSET ProgramIsARevision = 0>
<CFIF len(trim(getProgramTemplateInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(getProgramTemplateInfo.Revision_of_Contract_Main_ID)) NEQ 0>
	<CFSET ProgramIsARevision = 1>
</CFIF>

<cfquery NAME="GetContractInfo" datasource="#application.datasource#">
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SELECT Contract_Start_Date ,
				 Contract_End_Date ,
				 Revision_Of_Contract_Main_ID ,
				 Contract_Number ,
				 Contract_Title ,
				 isnull(Fiscal_Year, '') AS Fiscal_Year
	FROM Contract_Main
	WHERE Contract_Main_ID = '#cryp.value#'
</cfquery>

<!---25715--->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset programObj = CreateObject("component", "components.programs.program") />
<cfset prgManager = CreateObject("component", "components.programs.programManager").init() />
<cfset fiscalPeriodManager = CreateObject("component", "mvc.Models.Settings.fiscalPeriodManager") />
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<!--- 42349 - Most Favored Nations - setup and alert START --->
<cfset objProgramMFNBroker = createObject("component", "components.programs.ProgramMostFavoredNation") />
<!--- check to see if an MFN exists if it does we need to check for alerts --->
<cfset qCheckMFN = objProgramMFNBroker.checkIfMFNExists(cryp.value) />

<cfif qCheckMFN.RecordCount>
	<cfset mfnExists = 1 />
	<cfset qMFNConflicts = objProgramMFNBroker.getMFNConflicts(cryp.value) />

	<cfif qMFNConflicts.RecordCount and URL.mfnComplete eq 0 and form.passedForm neq "dupWarning">
		<cfinclude template="most_favored_nation_alert.cfm">
		<cfabort>
	</cfif>

</cfif>
<!--- conditions to display MFN selection --->
<cfif getProgramTemplateInfo.Program_Most_Favored_Nation eq 1 and URL.mfnComplete eq 0 and mfnExists eq 0 and form.passedForm neq "dupWarning">
	<cfinclude template="most_favored_nation_selection.cfm">
	<cfabort>
</cfif>
<!--- 42349 - Most Favored Nations - setup and alert END --->

<!--- 44975 - is RFA notification on 1 case volume enabled? --->
<cfif appSettings.getRFA_Notification_1_Case()>
  <!--- look for volume with only 1 case --->
  <cfquery name="variables.qVolumes" datasource="#application.datasource#">
		SELECT COUNT(*) AS Volume_1_Case
		FROM PROGRAM_PRODUCT_VOLUME a
		INNER JOIN CONTRACT_MAIN b 
		ON b.Contract_Main_ID = a.Program_ID
		WHERE a.Program_ID = #cryp.value# 
		AND a.Deleted = 0
		AND ROUND( (DATEDIFF(d, b.Contract_Start_Date, b.Contract_End_Date) + 1) * a.Volume_Cs / 7, 0 ) = 1
  </cfquery>
  <!--- found volume with 1 case, alert the users --->
  <cfif variables.qVolumes.Volume_1_Case>
    <script>
      alert("You have not edited the volume estimate for this program \nand at least one product has a volume estimate of 1 case.");
    </script>
  </cfif>
</cfif>

<cfif ( appSettings.getBudgetsFunctionalityOn() )>
  <!---was budgets popped up previously?--->
  <cfif not StructKeyExists(url, "budgets_popped")>
    <!---save the existing URL info--->
    <cfset url_info = urlToNameValuePairs()>
    <cfif len(url_info)>
      <cfset url_info = "&" & url_info>
    </cfif>
		<!---25715------------------------------------------------------------------------------------------------------------->
		<cfinclude template="/Common_Files/Contracts/assign_budgets.cfm">
    <!---assign budgets, get the next action--->
    <cfset next_action = Assign_Budgets(program_id = cryp.value,
                                        Template_First_Parent_ID = getProgramTemplateInfo.First_Parent_ID)>
    <cfset url.cancel_page = "contract_edit_menu.cfm?CID=#FORM.ApproveContract#">

    <cfswitch expression="#next_action#">
      <!---there is no program budget, but the program template has budgets--->
      <cfcase value="stop">
        <cfset DisplayMessageAndRedirect( "You cannot request approval as a valid budget does not exist for this program. Please contact the system administrator."
                                          , url.cancel_page
                                          , GetContractInfo.Contract_Number )>
      </cfcase>
      <!---found budget class with more than 1 budgets--->
      <cfcase value="prompt">
        <!---add url.budgets_popped so we only run budget_display.cfm only once in RFA--->
        <cfset url.save_page   = "contract_approve_broker_action.cfm?budgets_popped=yes" & url_info>
        <cfset url.program_id  = cryp.value>
        <cfinclude template="budget_display.cfm">
      </cfcase>
    </cfswitch>
  </cfif>
</cfif>
<!---25715--->

<!--- Dev Note: Kal; D42585: Program dates as fiscal periods --->
<cfif getProgramTemplateInfo.Program_Date_Type eq 2 >
	<!--- If Contract Fiscal Year is null then alert and stop --->
	<cfif NOT len(GetContractInfo.Fiscal_Year)>
		<cfset DisplayMessageAndRedirect( "Fiscal Year is not selected for the program", url.cancel_page, GetContractInfo.Contract_Number ) />
	<cfelse>
		<cfset qGetFiscalDatesforYear = fiscalPeriodManager.getFiscalDatesforYear(GetContractInfo.Fiscal_Year) />
		<!--- first update the GL on the program based on program  --->
		<cfset programGLList = programObj.updProgramGL(cryp.value, qGetFiscalDatesforYear.StartDate) />
		<!--- get the lsit of GL's on the program --->
		<cfset programGLList = programObj.getProgramGL(cryp.value) />
		<!--- check for the validtiy of the GL's for the fiscal year of the program --->
		<cfif len(programGLList)>			
			<cfset qGetInvalidProgramGL = programObj.getInvalidProgramGL(programGLList, qGetFiscalDatesforYear.StartDate, qGetFiscalDatesforYear.EndDate) />
			<cfif qGetInvalidProgramGL.RecordCount>
				<cfset invalidGLMsg = "GL Accounts are not within Fiscal Year: #GetContractInfo.Fiscal_Year#" />
				<cfloop query="qGetInvalidProgramGL">
					<cfset invalidGLMsg =invalidGLMsg & "<br> &nbsp; #Gl_Account# - #GL_Account_Desc# " />
				</cfloop>
				<cfset DisplayMessageAndRedirect(invalidGLMsg, url.cancel_page, GetContractInfo.Contract_Number ) />
				<cfabort/>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<!---  START Dev Notes: D49800 Update Program RFA logic/Anand Rao/18-May-2015 --->
<cfif (appSettings.getGL_Account_On() AND appSettings.getGL_Account_Required_for_Comp() AND getProgramTemplateInfo.Program_Date_Type EQ 1)>
	<!--- first update the GL on the program based on program  --->
	<cfset programGLList = programObj.updProgramGL(cryp.value, GetContractInfo.Contract_Start_Date) />
	<cfset programGLList = programObj.getProgramGL(cryp.value) />
	<cfif len(programGLList)>
		<!--- <cfset qGetFiscalDatesforYear = fiscalPeriodManager.getFiscalDatesforYear(GetContractInfo.Fiscal_Year) /> --->
		<cfparam name="url.cancel_page" default="contract_edit_menu.cfm?CID=#FORM.ApproveContract#">
		<cfset qGetInvalidProgramGL = programObj.getInvalidProgramGL(programGLList, GetContractInfo.Contract_Start_Date, GetContractInfo.Contract_End_Date) />
		<cfif qGetInvalidProgramGL.RecordCount>
			<cfset invalidGLMsg = "#Application.GLAccountLabel# are not within the date range of the program. " />
			<cfloop query="qGetInvalidProgramGL">
				<cfset invalidGLMsg =invalidGLMsg & "<br> &nbsp; #Gl_Account# - #GL_Account_Desc# " />
			</cfloop>
			<cfset DisplayMessageAndRedirect(invalidGLMsg, url.cancel_page, GetContractInfo.Contract_Number ) />
			<cfabort/>
		</cfif>
	</cfif>
</cfif>
<!---  END Dev Notes: D49800 Update Program RFA --->


<!--- Dev Note(69720) - If the program is a revision and the template setting does not allow for "duplicate check" for revisions, then do not do "duplicate check". --->
<cfif ProgramIsARevision eq 1 AND getProgramTemplateInfo.Disable_Duplicate_Check_For_Revisions eq 1>
	<cfset checkDuplicateProgram =0>
	<cfset duplicateprogram = 0>
</cfif>

	
<!------ Check whether this program is a duplicate program ----->
<!--- if the form.passedForm is dupWarning, which is dupWarningWindow, that means duplicate program
--- check must be true. Note: form.passedForm is passed from continue action--->
<cfif form.passedForm NEQ "dupWarning">
	<cfif checkDuplicateProgram>
	<cftransaction action = "begin" isolation="read_uncommitted">
	<!----------------- Add Progress Bar ------------------------>
	<CFINCLUDE TEMPLATE="/includes/progress_bar.cfm">
		<cfinclude template="duplicate_program_check.cfm">
		<cftransaction action="COMMIT">
	</cftransaction>
	</cfif>

	<cfif duplicateprogram EQ "true" OR DuplicateProgramIDList NEQ "">
		<cfinclude template="dup_warning_window.cfm">
		<cfabort>
	<cfelse>
	<script language="javascript">
	//Hide the Progress Bar
	 if(document.getElementById('Progress_Bar')){
	 	document.getElementById('Progress_Bar').style.display = 'none';
	 }
	 </script>
	</cfif>
</cfif>

			
<!--- Check recapture for multiple operator lists --->
<cfif appSettings.getPullbacksOn()>
<cfif appSettings.get_Setting('Recapture_By_Operator_For_Multiple_Lists') eq '1' AND getProgramTemplateInfo.Pullbacks_On EQ 1 AND getProgramTemplateInfo.generic_type EQ "Distributor Trade/Shelter" 
	AND getProgramTemplateInfo.is_pullback_corporate_deal EQ 1 AND Get_Profile_Settings.View_LH_Pane_Recapture_Link>

	<cfset bRecaptureComponentExists = prgManager.getIsRecaptureOperatorOnForAnyProgramRebateComponent(cryp.value)>
	<cfset bRecaptureOperatorPGExists =  PullbackManager.getRecaptureOperatorPGlistExists(GetContractInfo.Contract_Number)>
	
	<cfif bRecaptureComponentExists EQ 1  AND bRecaptureOperatorPGExists eq 0>
		<cfset URL.FromRFAPage = 1>
		<cfinclude template="/Common_Files/contracts/Pullbacks/pullback_multiple_operator_list.cfm">
		<cfabort>
		</cfif>
	</cfif>
</cfif>
	
<!--- D28559: Warning / Prevent - Identical FIXED PRICE / REBATE / PAID TO --->
<!--- If Warning or Prevent get the list or products with the issue --->
<cfif (getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message eq "2" or getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message eq "3")
		and (not isDefined("url.dupProdPaidToDiscTypeChecked") or url.dupProdPaidToDiscTypeChecked eq 0)
		>
	<cfset bDispalyProgramProductsPaidToWithDuplicateDiscountTypesMessage = 0 />
	<cfmodule template="program_product_fixed_rebate_paid_to_dup.cfm"
				Program_ID = #cryp.value#
				Contract_Number = #GetContractInfo.Contract_Number#
				Contract_Title = #GetContractInfo.Contract_Title#
				CID = #URL.CID#
				Item_Fixed_Rebate_Paid_To_Dup_Message = #getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message#
				ReturnVariable="bDispalyProgramProductsPaidToWithDuplicateDiscountTypesMessage"
				/>
	<cfif bDispalyProgramProductsPaidToWithDuplicateDiscountTypesMessage>
		<cfabort>
	</cfif>
</cfif>

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
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<BR><BR><BR>
	<DIV ALIGN="center" STYLE="font-size: 15px;"><B>The template you are attempting to use has been removed from circulation.<BR>You will be returned to the view program page.</B></DIV>
	<script language="JavaScript">
		function seeya()
		{
			window.parent.window.location.href="contract_edit_menu.cfm?CID=<CFOUTPUT>#FORM.ApproveContract#</CFOUTPUT>";
		}
		setTimeout('seeya()',2000);
	</script>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	</BODY>
	</HTML>
	<CFABORT>
<CFELSE>
		<!--- moved to an include so sysco deals could call same approve action --->
		<cfinclude template="contract_approve_broker_action_include.cfm">
</CFIF>

<!---open a popup window for inputting external contacts for letters--->
	 <!--- Dev Note: drachala; D28728: Email field associated with program announcements  START
      Added/Changed: Added URL Varaible --->
<cfif getProgramTemplateInfo.Email_Letters_On_Approval eq 1>
  <script>
  <cfoutput>
  NewWindow('/common_files/contracts/contacts.cfm?ContractId=#ContactContractId#&mode=rfa&Contract_Main_ID=#cryp.value#','contacts','870','620','Yes', 'No');
  </cfoutput>
  </script>
</cfif>
<!--- End Dev Note: drachala; D28728: Email field associated with program announcements  --->
</cfif>

	<cfif form.backtotemplate neq "">
	    <cfoutput><script>window.location = '#form.backtotemplate#';</script></cfoutput>
	<cfelse>
		<cfset locateBackTo = "contract_edit_menu.cfm?CID=#Approve_Contract_ID#&IncludeProgressBar=#IncludeProgressBar#&emailFax=#bAutoApproveProgram#" />
		<cfoutput>
			<!--- Dev Note: drachala; D28431: Close on RFA  and unlock  START
            Added/Changed: Added IF constion to Check Approval rights and Template Approval Rights If user dont have Approval rights we unlock the program and close it--->
			<!--- Tim Ford - 11/14/2013: Label 40275 - EVENT ERRORS:  Element CONT_PROG_APPROVAL_RIGHTS is undefined in GET_PROFILE_SETTINGS --->
			<cfif (Form.Cont_Prog_Approval_Rights EQ 0) OR (#form.approvaltype# EQ "0")>
				<cfset url.CID=#Approve_Contract_ID#>
				<cfset close_window = 1>
				<cfinclude template="/Common_Files/Contracts/UnLock_Contract.cfm">
			<cfelse>
				<script>
					window.location = '#locateBackTo#';
				</script>
			</cfif>
			<!--- End Dev Note: drachala; D28431: Close on RFA and unlock  --->
		</cfoutput>
    </cfif>



<!--- ***************************************************************************************************************************** ---->
<!--- ***************************************************************************************************************************** ---->
<!--- *************************                    END OF RFA LOGIC                             *********************************** ---->
<!--- ***************************************************************************************************************************** ---->
<!--- ***************************************************************************************************************************** ---->


<!---------------------------------------------------------------------------------------------------------------------
 I generate concatenated name-value pairs from urls.
--------------------------------------------------------------------------------------------------------------------->
<cffunction name="urlToNameValuePairs" returntype="string" output="false" access="remote"
            hint="pass me a url structure and i'll generate concatenated name-value pairs.">

<cfargument name="doNotProcessList" type="string" required="false" hint="a list of url fields to ignore" default="" />

<cfset var local = structNew() />
<cfset local.nameValuePairs = "" />
<cfset local.doNotProcess = arguments.doNotProcessList />
<cfset local.field = "" />

<cfloop collection="#url#" item="local.field">
  <cfif not listFindNoCase(local.doNotProcess,local.field)>
    <cfset local.doNotProcess = listAppend(local.doNotProcess,local.field) />
    <cfset local.nameValuePairs = listAppend(local.nameValuePairs,lcase(local.field) & "=" & urlEncodedFormat(url[local.field], "utf-8"), "&") />
  </cfif>
</cfloop>

<cfreturn local.nameValuePairs />
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="DisplayMessageAndRedirect" output="false" hint="I display a message, redirect users to a specific page.">
<cfargument name="a_message" required="true">
<cfargument name="redirect_url"  required="true">
<cfargument name="contract_number"  required="true">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<cfoutput>
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title>Ready For Approval - Program #arguments.contract_number#</title>
 <link rel="stylesheet" type="text/css" href="/common_files/impromptu.css">
 <script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.1-min.js"></script>
 <script type="text/javascript" src="/Script/javascript/jquery-impromptu.3.1.min.js"></script>
</head>
<body>
<script>
 function redirect() {
  window.location = "#arguments.redirect_url#";
 }
 $.prompt( "#arguments.a_message#", { callback:redirect } );
</script>
</body>
</html>
</cfoutput>
<cfabort>
</cffunction>
<!---25715------------------------------------------------------------------------------------------------------------->
