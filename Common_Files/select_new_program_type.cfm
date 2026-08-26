<!---
	Name: select_new_program_type.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		This page serves two functions: (1) Contract Template selection. (2) Responsible Sales Person Selection
	Modifications:
		Added Handling for When Current user is not an eligible RSP - Clay Label 9478 3/27/2006
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!---Gets application settings--->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfset userManager = CreateObject("component", "components.user.UserManager") />

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program NEQ 1 OR (appSettings.getUserNumberRestrict() EQ 1 AND userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 0)>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<!------ get user positions id ----->
<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />

<!---
	Tim Ford - WR 57305 - Retail Planner - Design
	Bypass RSP selection if coming from Planner Templates
--->
<cfparam name="bypassRSPSelect"		default="0" />
<cfparam name="fromRetailPlanner" 	default="0" />
<cfparam name="url.plannerId"			default="" />
<cfparam name="Form.plannerId"			default="#url.plannerId#" />

<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

<cfif trim(fromRetailPlanner) AND IsDefined("form.plannerId") AND form.plannerId NEQ "">
	<cfquery name="qGetPlanner" datasource="#application.datasource#">
		SELECT	RSP_ID, Creator_Position_ID
		FROM	Planners
		WHERE	Planner_ID = <cfqueryparam cfsqltype="cf_sql_numeric"  value="#form.plannerId#" />
	</cfquery>
	<cfset FORM.Responsible_Position_Id = qGetPlanner.Creator_Position_ID />
	<cfset FORM.Responsible_User_Id = qGetPlanner.RSP_ID />
	<cfset FORM.Responsible_User_Id_Position_Id = "#FORM.Responsible_Position_Id#_#FORM.Responsible_User_Id#" />
	<cfset bypassRSPSelect = 0 />
</cfif>

<!--- Get RSP Pulldown BJF D11341 --->
<cfif bypassRSPSelect eq 0>
	<cfinclude template="/common_files/rsp_include.cfm">
</cfif>


<cfinclude template="/common_files/rsp_include.cfm">


<cfset display_generic_type = application.returned_customer_setting.display_generic_type>
<!--- get profile id of the responsible person --->

<cfset qUser = userManager.getUser(FORM.Responsible_User_Id) />
<cfset rspProfileID = qUser.profiles_id >

<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

<!------ Operating Group ----->
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset profileRestrictionLevel 			= operatingGroupManager.getProfileRestrictionLevel() />
	<cfset profileRestrictionLevelLabel 	= operatingGroupManager.getLabel(profileRestrictionLevel) />
	<!------ Get the operating groups available for this profile ----->
	<cfset qOperatingGroupForUserProfile	= operatingGroupManager.getOperatingGroupProfileSettings(level=profileRestrictionLevel, profileId=rspProfileID, returnCheckedOnly=1)>
	<cfset sOperatingGroupForUserProfile	= ValueList(qOperatingGroupForUserProfile.Operating_Group_ID) />
</cfif>

<cfif not isDefined("businessSegManager")>
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
</cfif>

<cfif businessSegManager.isEnabled() and appSettings.getFilterBusinessSegments()>
	<!--- the getActiveClasscodes() function holds the logic to that determines if class codes are on then get class codes,
	otherwise get business segments--->
	<cfset variables.qUserBusinessSegments = businessSegManager.getActiveClasscodes(FORM.Responsible_User_Id,0) />
</cfif>
<!--- get position list for the rsp.  used to determine what templates they can choose from -> Template_Filter_User_Positions table holds template level filters --->
<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(qUser.user_id, 0, 0) />

<cfscript>
	request.planner_indirect_categories = application.util.query.get_Setting( "Planner_Indirect_Categories", 0 );
</cfscript>

<cfquery name="getCreatedTypes" datasource="#application.datasource#">
	DECLARE @Planner_Template_ID int,
            	@Indirect_Planner bit = 0
	<cfif trim(fromRetailPlanner) AND IsDefined("form.plannerId") AND form.plannerId NEQ "">
	SELECT	@Planner_Template_Id =Planners.Planner_Template_Id,
            @Indirect_Planner = CASE WHEN Planner_Template.Category IN ( #listQualify( request.planner_indirect_categories, "'" )# )
										THEN 1
										WHEN ISNULL(Parent_Planner_ID, 0) = 0
											THEN 0
											ELSE 1
								END
	FROM    Planners
	INNER JOIN Planner_Template on Planner_Template.Planner_Template_ID = Planners.Planner_Template_ID
	WHERE   Planner_ID = '#form.plannerId#'
	</cfif>
	SELECT 		DISTINCT Program_Control_Panel_Options.*,TF.*,ISNULL(D.Discount_Identifier_Number,'0') AS Discount_Identifier_Number
	FROM 		Program_Control_Panel_Options
	LEFT JOIN Template_Filters TF ON
			TF.Parent_Template_Id = Program_Control_Panel_Options.First_Parent_ID AND
			TF.Deleted = 0
				<cfif businessSegManager.isEnabled() and appSettings.getFilterBusinessSegments()>
					<cfif variables.qUserBusinessSegments.RecordCount>
						INNER JOIN Template_Business_Segment ON
						Template_Business_Segment.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID AND
						Template_Business_Segment.Business_Segment_ID IN (#valueList(variables.qUserBusinessSegments.Business_Segment_ID)#) AND
						Template_Business_Segment.Deleted = 0
					</cfif>
				</cfif>
	LEFT JOIN Discount_Identifier D ON
		D.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID AND
		D.Active = 1
	WHERE 		Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
				AND Hide_On_Create_Program = 0
				AND Program_Control_Panel_Options.Deleted = 0
				AND Program_Control_Panel_Options.Active = 1
				AND IsDominant = 1
				AND programcontrol_panel_options_id
					<cfif forbidType EQ 1>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
					in
					(	select 	distinct template_id
						from 	Profile_Forbidden_Template
						where 	Deleted = 0
								AND Forbid_Type = #forbidType#
								AND	Forbid_Access_Type = 1
								AND profile_id = #rspProfileID#
					)
				<!------ Operating Group ----->
				<cfif appSettings.getOperatingGroupOn()>
				<cfif Len(sOperatingGroupForUserProfile) EQ 0>
				AND 1 = 2
				<cfelse>
				AND programcontrol_panel_options_id in
					(	select 	distinct template_id
						from 	Template_Operating_Group
						where 	Deleted = 0
								AND Operating_Group_ID IN (#sOperatingGroupForUserProfile#)
					)
				</cfif>
				</cfif>
				<!------ DEV NOTE: DRK 9674 : if the template - restrict group type is class code alone ----->
				<cfif appSettings.getTemplateRestrictGroupLevel() eq 10>
				<cfset qRespUserClassCodes = businessSegManager.getActiveClasscodes(userId=FORM.Responsible_User_Id, returnAllClassCode=0)>
				<cfset classCodeIDList = ValueList(qRespUserClassCodes.Class_Code_UUID) />
				AND	(Program_Control_Panel_Options.Restrict_On_Approval_Group = 0 <!------ either the template should not be restricted at group level  ----->
					<cfif classCodeIDList neq ""><!------ if the template is restricted at group level, check to see if the user have atleast one of the selected class code ----->
					OR
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID IN
					(
					SELECT	DISTINCT Program_Type_ID
					FROM	Template_Allow_Approval_Group
					WHERE	Deleted = 0
					AND		Group_ID IN (#ListQualify(classCodeIDList, "'")#))
					</cfif>
					)
				</cfif>
	<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>
				AND Generic_Type = 'Distributor Trade/Shelter'
				AND Specify_Distributors = 1

				<cfif form.hasRebate>
				AND Discount_Rebates = 1

					<cfif form.bCheckPerc>
				AND	RateTypeOption_3 = 1
					</cfif>

					<cfif form.bCheckLBS>
				AND	RateTypeOPtion_1 = 1
					</cfif>

				</cfif>

				<cfif form.hasLumpSum>
				AND Discount_Lump_Sums = 1
				</cfif>
	</cfif>
				<cfif appSettings.getDisplayDistributorOffInvoice() eq 0>
				AND Generic_Type != 'Distributor Off-Invoice'
				</cfif>
				<cfif appSettings.getDisplayProposal() eq 0>
				AND Generic_Type != 'Bid Request'
				</cfif>
				<cfif appSettings.getDisplayUSDANOI() eq 0>
				AND Generic_Type != 'USDA NOI'
				</cfif>
				<!--- Check Template Filters User_Positions
						* 1st check if a user position filter exists
						* If it does exist see if current user has access --->
				AND
				(
						(
							NOT EXISTS
							(SELECT Template_Filters_Id
								FROM Template_Filter_User_Positions
								WHERE Template_Filters_Id = TF.Template_Filters_Id)
						)
						OR
						(
							EXISTS
								(SELECT TFUP.Template_Filters_Id
									FROM Template_Filter_User_Positions TFUP
									WHERE TFUP.Template_Filters_Id = TF.Template_Filters_Id AND
										TFUP.User_Positions_Id IN
										--Positions Below Me
										(SELECT DISTINCT Below_User_Positions_ID
											FROM	Positions_Below_Me
											WHERE	User_Positions_ID IN (#UserPositionList#)
										)
								)
						)
				)
			<cfif trim(fromRetailPlanner)>
			AND Program_Control_Panel_Options.Retail_Planner = 1
			AND (
				(@Indirect_Planner = 0 AND Program_Control_Panel_Options.Generic_Type = 'Distributor Trade/Shelter')
				OR
				(@Indirect_Planner = 1 AND Program_Control_Panel_Options.Generic_Type IN ('Operator Direct or HQ Programs', 'Operator-Deviated Pricing'))
			)
			AND EXISTS (
					SELECT 	1
					FROM 	Planner_Program_Templates ppt
					WHERE 	ppt.Planner_Template_ID = @Planner_Template_ID
					and 	ppt.First_Parent_Id = Program_Control_Panel_Options.First_Parent_ID
					and 	ppt.Deleted = 0)
			<cfelse>
			AND Program_Control_Panel_Options.Retail_Planner = 0
			</cfif>
	ORDER BY 	Generic_Type, Created_Type asc

</cfquery>

<cfset PAGE_TITLE = "Select Program Type">

<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>

	<form name="create_planner_program" action="/planners/create/planner_program_create.cfm" method="post">
		<input type="hidden" name="templateId">
		<input type="hidden" name="Product_List">
		<input type="hidden" name="Product_List_Type">
		<input type="hidden" name="customerId">
		<input type="hidden" name="plannerId">
	</form>

	<script>
		function initPage(){
			if(document.all.ProgramType != null){
				for(var x=0; x<document.all.ProgramType.length;x++){
					document.all.ProgramType[x].checked = false;
				}
			}
		}

		function confirmSelection(labelObject,TFId, fromRetailPlanner, discNumber)
		{
			var firstLetter = labelObject.getAttribute('created_type').substr(0, 1).toLowerCase();
			var vowelArticle = "";
			if(firstLetter == 'a' || firstLetter == 'e' || firstLetter == 'i' || firstLetter == 'o' || firstLetter == 'u')
			{
				vowelArticle = "n";
			}
			// if coming from retail planner then redirect to planner program create page
			if (fromRetailPlanner){
				// hide page content to give users visual feedback
				$("body").hide();

				$("input[name=templateId]").val(labelObject.getAttribute('ProgramType_ID'));
				$("input[name=Product_List]").val(document.MyForm.Product_List.value);
				$("input[name=Product_List_Type]").val(document.MyForm.Product_List_Type.value);
				$("input[name=customerId]").val(document.MyForm.customerId.value );
				$("input[name=plannerId]").val(document.MyForm.plannerId.value);
				$("form[name=create_planner_program]").submit();

				return;
			}
			if(confirm("Create a" + vowelArticle + " '" + labelObject.getAttribute('created_type') + "' program?"))
			{
				<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
					if(discNumber == 'GPO' || discNumber == 'CPA'){
						document.MyForm.action = '/Common_Files/contracts/OPP/GPO_One_Page_Program.cfm';
					}
				</cfif>
				document.MyForm.ProgramType_ID.value = labelObject.getAttribute('ProgramType_ID');
				document.MyForm.TemplateFiltersId.value = TFId;
				document.MyForm.submit()
			}
		}



	</script>
</head>

<body leftmargin="0" topmargin="0" bottommargin="0" rightmargin="0" onLoad="initPage()">

<cfinclude template="/includes/top_header.cfm">

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<cfif getCreatedTypes.recordcount GT 0>
<cfparam name="Form.TemplateFiltersId" 	default="0" />
<cfparam name="url.Product_List" 		default="" />
<cfparam name="Form.Product_List" 		default="#url.Product_List#" />
<cfparam name="url.Product_List_Type"	default="" />
<cfparam name="Form.Product_List_Type"	default="#url.Product_List_Type#" />
<cfparam name="url.customerId"			default="" />
<cfparam name="Form.customerId"			default="#url.customerId#" />

<center>



<cfoutput>
<form method="post" name="MyForm" id="MyForm" ACTION="contracts/contract_create_1_form.cfm">
<input name="ProgramType_ID" type="hidden" value="">
<input name="Responsible_User_Id_Position_Id" type="hidden" value="#FORM.Responsible_User_Id_Position_Id#">
<INPUT TYPE="Hidden" NAME="TemplateFiltersId" VALUE="#FORM.TemplateFiltersId#">
<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#FORM.Product_List#">
<INPUT TYPE="Hidden" NAME="Product_List_Type" VALUE="#FORM.Product_List_Type#">
<INPUT TYPE="Hidden" NAME="customerId" VALUE="#FORM.customerId#">
<INPUT TYPE="Hidden" NAME="plannerId" VALUE="#FORM.plannerId#">

</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	.Maintable {border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>
<cfscript>
	// save all general labels into a structure
	general_labels = application.util.query.generalLabel();
</cfscript>

<TABLE WIDTH="85%" CELLPADDING="4" CELLSPACING="0">
	<TR>
		<TD colspan="3"  style="border-style: none;">
			<CFINCLUDE TEMPLATE="/Billbacks/Common/Find_In_Page.cfm">
		</TD>
	</TR>
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="#FFCE84" valign="center">
		<TD CLASS="Maintable" ID="header">&nbsp;</TD>
		<TD CLASS="Maintable" ID="header"><B><cfif fromRetailPlanner><cfoutput>#Application.PlannerPrgLabel# Type</cfoutput><cfelse>Program Type</cfif></B></TD>
		<TD CLASS="Maintable" ID="header"><B>Description</B></TD>
	</TR>

	<!--- TABLE DATA QUERY --->
	<CFOUTPUT QUERY="getCreatedTypes" GROUP="Generic_Type">
	<cfif display_generic_type EQ 1><TR><TD CLASS="Maintable" COLSPAN="100%" STYLE="border-bottom:solid ##93BEE2 1px;"><BR><FONT SIZE="2"><B>#ReReplaceNoCase(general_labels[ Generic_Type ], "trade", application.returned_customer_setting.Trade_Label)#</B></FONT></TD></TR></cfif>
	<CFOUTPUT>
		<!--- This is really only for the initial release of template filters. Insert each template into Template_Filters--->
		<cfscript>
			TemplateMan = createObject("component","components.programs.template.TemplateManager").init();
			Template  = TemplateMan.get(getCreatedTypes.ProgramControl_Panel_Options_ID);
			//Insert record for non MP Templates 1:1 relationship -> no user input
			//WriteOutput( "XX  ::  #getCreatedTypes.ProgramControl_Panel_Options_ID# :: #Template.createdType# MP:: #Template.MarketPrice# :: LEN:: #ArrayLen(Template.TemplateFilters)#" );
			if(!Template.MarketPrice){
				if(ArrayLen(Template.TemplateFilters) == 0){
					//WriteOutput( "TF");
					TemplateFilter = createObject("component", "mvc.models.Template.TemplateFilter").init();
					TemplateFilter.Name = Left(Template.createdType,50);
					TemplateFilter.Desc = '';
					//save obj
					Template.saveTemplateFilter(TemplateFilter);
				}
			}
		</cfscript>
			<!--- DATA OUTPUT --->
			<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" style="cursor:pointer;">
				<TD CLASS="Maintable">&nbsp;</TD>
				<TD CLASS="Maintable" style="cursor:pointer;" ONCLICK="confirmSelection(document.getElementById('program_#Currentrow#'),#getCreatedTypes.Template_Filters_Id#, #fromRetailPlanner#,'#getCreatedTypes.Discount_Identifier_Number#')" nowrap>
					<a id="program_#Currentrow#" created_type="#Created_Type#" ProgramType_ID="#getCreatedTypes.ProgramControl_Panel_Options_ID#">#Created_Type#</a>
				</TD>
				<TD CLASS="Maintable" ID="" ONCLICK="confirmSelection(document.all.program_#Currentrow#,#getCreatedTypes.Template_Filters_Id#, #fromRetailPlanner#)">
					<a>#getCreatedTypes.Program_Description#<cfif getCreatedTypes.Market_Price><br>Market Price: #getCreatedTypes.Description#</cfif></a>
				</TD>
			</TR>
	</CFOUTPUT>
</CFOUTPUT>
</TABLE>

<cfoutput>
<!---If we are coming from trade planner then we need these values--->
<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>

	<INPUT TYPE="Hidden" NAME="Contract_Renewal_Packets_ID" value="#form.Contract_Renewal_Packets_ID#">
	<INPUT TYPE="Hidden" NAME="IsRevisionOfExistingContract" VALUE="0">
	<INPUT TYPE="Hidden" NAME="tpFileName" VALUE="#Form.tpFileName#">
	<INPUT TYPE="Hidden" NAME="bIsFromTradePlan" VALUE="#FORM.bIsFromTradePlan#">
	<INPUT TYPE="Hidden" NAME="tradePlanId" VALUE="#Form.tradePlanId#">
	<INPUT TYPE="Hidden" NAME="On_Release_Contract_Status_Type_IDX" VALUE="4">
	<INPUT TYPE="Hidden" NAME="start_date" VALUE="#FORM.start_date#">
	<INPUT TYPE="Hidden" NAME="end_date" VALUE="#FORM.end_date#">

</cfif>
</cfoutput>

</form>


<br>
</center>

<cfelse>
	<br><br>
	<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
	<DIV ALIGN="center" STYLE="font-size:12px;font-weight:bold;">
	<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>
		There are currently no template types available that match data from <CFOUTPUT>#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel#.</CFOUTPUT><br>
		A template type must be created with the following properties:<br><br>
		<table width="35%" border="0" cellpadding="0" cellspacing="0" bgcolor="E6E6E6">
			<tr>
				<cfif form.hasRebate>
				<td valign="top">
					<strong>Rate Types:</strong><br>
					<cfif form.bCheckPerc>
						-Per Pound<br>
					</cfif>
					<cfif form.bCheckLBS>
						-Percent<br>
					</cfif>
				</td>
				</cfif>
				<cfif form.hasLumpSum or form.hasRebate>
				<td valign="top">
					<strong>Discount Types:</strong><br>
					<cfif form.hasRebate>
						-<CFOUTPUT>#Application.RebateLabel#</CFOUTPUT><br>
					</cfif>
					<cfif form.hasLumpSum>
						-<CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT><br>
					</cfif>
				</td>
				</cfif>
			</tr>
			<tr>
				<td><br><b><CFOUTPUT>#Application.PlannerPrgLabel#</CFOUTPUT> Template Requires Distributors</b></td>
			</tr>
		</table>
	<cfelse>
		There are currently no templates available<br>
	</cfif>
	<br>
	<cfif getSPA.Program_Wizard_Index EQ 1>
		Please create programs types using the program template in the <a href="/settings/index2.cfm">settings</a> control panel before creating programs
	<CFELSE>
		Please contact your <a href="mailto:<cfoutput>#Contact_Admin_Email_Address#</cfoutput>">system administrator</a> to request a template to be created<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan> with specific rate and discount types</cfif>.
	</CFIF>
	<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>
		<br>
		<br>
		<b><font color="FF0000">[</font> <a href="../ReportWriter/trade_plan/index.cfm?action=display&Trade_Plan_ID=<cfoutput>#TradePlanId#</cfoutput>">Return To Trade Plan</a><font color="FF0000">]</font></b>
	</cfif>
	</DIV>
</cfif>


<cfinclude template="/includes/footer.cfm">
<cfinclude template="/common_files/jQuery.cfm">
<script>
	$("input#find_Text").keypress(function(e){
		if (e.which == 13) {
			return false;
		}
	});
	function sendScripts(){
		if(MyForm.action.length == 0) alert("Please select a program");
		else MyForm.submit();
	}
</script>

</body>
</html>