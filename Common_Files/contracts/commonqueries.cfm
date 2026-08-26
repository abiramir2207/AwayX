<!---
FILE: 		common_files/contracts/commonqueries.cfm
FILEname:   commonqueries.cfm
CREATED:  	??/??/???? - ???
EDITED:   	10/29/2008 - Brad Lee MMCP/ACI [D17386]

FUNCTIONALITY:
- DNA? Perhaps a cfc-generated Bean someday?  --->


<cfif NOT IsDefined("commonqueries_Called") or commonqueries_Called eq 0>

<cfset commonqueries_Called = 1 />

<CFIF isdefined("request.AccessStructure.name_first")>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</CFIf>

<cfset objProgram = CreateObject("component", "components.programs.program") />

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT 	PCPO.Created_Type,
        ( SELECT Count( 1 )
            FROM CONTRACT_PRODUCTS p
                 INNER JOIN PRINT_PROGRAM_CUSTOM_OPTIONS ppco ON ppco.Contract_Main_Id = p.Contract_Main_Id
                                                                 AND p.Contract_Products_Id = ppco.Contract_Products_Id
                                                                 AND ppco.Deleted = 0
           WHERE p.Contract_Main_Id = cm.Contract_Main_Id
		   		<!---  Tim Ford - 10/23/2013 Label 39712 - Update Program Summary: Commented out Is_Group = 0 --->
                 --AND p.Is_Group = 0
                 AND p.Deleted = 0 ) AS custom_print,
		PCPO.BidRequestStatusOn,
		PCPO.BidRequestStatusChangePgmStatus,
		PCPO.Generic_Type,
		PCPO.revision_not_allowed,
		PCPO.copy_not_allowed,
		PCPO.pullbacks_on,
		PCPO.generic_type,
		PCPO.Release_Settlement,
		PCPO.Market_Price,
		PCPO.Shared,
		PCPO.Discount_Lump_Sums_Item_Mandated,
		PCPO.Display_Reminder_Comp_Data_Page,
		PCPO.Single_Component_Per_Discount_Type,
		PCPO.ItemMarked_Lost_Program_Volume_Automation,
		PCPO.Previous_Fiscal_Year_Volume,
		PCPO.EzButton_On,
		CM.*,
		CMAD.*,
		<!---  D38942 :: Program Blackout Period on Frontend --->
		PCPO.Blackout_Periods,
		PCPO.Auto_Volume,
		'WeeksAfter' = CASE
				WHEN PCPO.Blackout_Periods = 2
				THEN CMAD.Program_Start_Zero
				ELSE PCPO.Start_Zero
				END,
		'WeeksBefore' = CASE
				WHEN PCPO.Blackout_Periods = 1
				THEN CMAD.Program_Future_Zero
				ELSE PCPO.Future_Zero
				END,
		<!---  D38942 :: Program Blackout Period on Frontend --->
		TF.Description AS Template_Filter_Description
		,PCPO.Enable_Program_Qualifications <!---D43479--->
		,PCPO.Price_List_Download <!---D47306 --->
		,PCPO.specify_distributor_groups  		<!---D56899 --->
		,PCPO.specify_individual_distributors <!---D56899 --->
		,PCPO.Label_Set_Default <!--- D63927 --->
		,PCPO.RFP_Process,
		PCPO.Formula_Pricing_Type
	FROM 	Contract_Main CM
	LEFT JOIN Contract_Main_Aux_Data CMAD
	ON		CMAD.Contract_Main_ID = CM.Contract_Main_ID
	INNER JOIN	Program_Control_Panel_Options PCPO
	ON 		CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	LEFT JOIN Template_Filters TF ON
		TF.Template_Filters_Id = CM.Template_Filters_Id
	WHERE 	CM.Contract_Main_ID = '#CSL_Contract_Main_ID#'
</CFQUERY>


<cfset useLakebaseForCSLGetOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseForCSLGetOperators>
	<cftry>
		<cfset CSLGetOperators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_operators", {
				"contract_main_id" = "eq.#CSL_Contract_Main_ID#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCSLGetOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCSLGetOperators>
<CFQUERY NAME="CSLGetOperators" datasource="#application.datasource#">
	SELECT top 1 Contract_Main_ID
	FROM Contract_Operators
	WHERE Contract_Main_ID = '#CSL_Contract_Main_ID#' AND Deleted = 0
</CFQUERY>
</cfif>

<cfset useLakebaseForcheckForBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseForcheckForBrokers>
	<cftry>
		<cfset checkForBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_brokers", {
				"contract_main_id" = "eq.#CSL_Contract_Main_ID#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckForBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckForBrokers>
<CFQUERY NAME="checkForBrokers" datasource="#application.datasource#">
	SELECT top 1 Contract_Main_ID
	FROM Contract_Brokers
	WHERE Contract_Main_ID = '#CSL_Contract_Main_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>

<CFQUERY NAME="checkForDistributors" datasource="#application.datasource#">
	SELECT CD.*
	FROM Contract_Distributors CD
	INNER JOIN  BSA_Foodservice_Customers BSAFC ON BSAFC.BSA_Foodservice_Customers_ID =  CD.BSA_Foodservice_Customers_ID
	WHERE Contract_Main_ID = '#CSL_Contract_Main_ID#'
	AND CD.Deleted = 0
	ORDER BY Name
</CFQUERY>

<cfset ParentProgramDistributors = objProgram.getParentProgramDistributors(CSL_Contract_Main_ID) />

<CFQUERY NAME="ParentProgramOperators" datasource="#application.datasource#">
	SELECT BSA_Operator_ID
	FROM Contract_Operators
	WHERE Contract_Main_ID = (SELECT Revision_of_contract_main_id FROM Contract_Main
								WHERE Contract_Main_ID =	'#CSL_Contract_Main_ID#')
	AND Deleted = 0
</CFQUERY>

<!--- 17386 RBL let's flip this to eliminate error HERE and/or SUBSEQUENT errors!!!! [begin]
<CFIF trim(CSLGetContractInfo.ProgramType_ID) GT 0>
	<CFSET ThisProgramID = CSLGetContractInfo.ProgramType_ID>
<CFELSEIF isdefined("FORM.ProgramType_ID")>
	<CFSET ThisProgramID = FORM.ProgramType_ID>
    <!--- 17386 RBL fixing for frequent errors ARGH --->
<cfelse>
	<!--- without a default somewhere, the code above ocassionally will throw an error... --->
    <cfset ThisProgramID = 0>
</CFIF>
17386 RBL fixing for frequent errors ARGH --->
<cfinclude template="letters/include_display_letters.cfm">
<cfif (NOT findNoCase("#includeLettersFilename#",cgi.script_name,1)) AND (isdefined("FORM.ProgramType_ID") AND len(trim(FORM.ProgramType_ID)) AND isNumeric(FORM.ProgramType_ID))>
	<cfset ThisProgramID = FORM.ProgramType_ID>
<cfelse>
	<cfset ThisProgramID = CSLGetContractInfo.ProgramType_ID>
</cfif>

<!--- 17386 RBL let's flip this to eliminate error HERE and/or SUBSEQUENT errors!!!! [end] OK --->
<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM
		Program_Control_Panel_Options
	WHERE
		ProgramControl_Panel_Options_ID = '#trim(ThisProgramID)#'
</cfquery>

<!--- 	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
		SET A BIT THAT CAN BE USED TO HIDE ELEMENTS FOR THE LUMP SUM AUTO
		PAY GENERIC TEMPLATE TYPE
		oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--->
<cfif GetSettings.Generic_Type EQ "LSAutoPay">
	<cfset variables.bHideFromLSAutoPay = 1 />
<cfelse>
	<cfset variables.bHideFromLSAutoPay = 0 />
</cfif>
<!--- 	oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo --->
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
FOR GENERIC TYPE LUMP SUM AUTO PAY, WE ALLOW USER TO SELECT ONLY ONE
DISTRIBUTOR, OPERATOR, OR BROKER.  SET A FLAG HERE TO BE USED IN
CONTRACT_STATUS_LEGEND WHEN THE MENU IS BUILT
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--->
<!--- UPDATE BASED ON RESULTS --->
	<cfset variables.bShowRFA = 1>
	<CFIF variables.bHideFromLSAutoPay AND CSLGetOperators.RecordCount GT 0>
		<cfset variables.bShowBrokerLink = 0 />
		<cfset variables.bShowOperatorlink = 1 />
		<cfset variables.bShowDistributorLink = 0 />
	<CFELSEIF variables.bHideFromLSAutoPay AND checkForBrokers.RecordCount GT 0 >
		<cfset variables.bShowBrokerLink = 1 />
		<cfset variables.bShowOperatorlink = 0 />
		<cfset variables.bShowDistributorLink = 0 />
	<CFELSEIF variables.bHideFromLSAutoPay AND checkForDistributors.RecordCount GT 0 >
		<cfset variables.bShowBrokerLink = 0 />
		<cfset variables.bShowOperatorLink = 0 />
		<cfset variables.bShowDistributorLink = 1 />
	<CFELSE> <!--- SHOW ALL OF THEM --->
		<cfset variables.bShowBrokerLink = 1 />
		<cfset variables.bShowOperatorLink = 1 />
		<cfset variables.bShowDistributorLink = 1 />
		<cfset variables.bShowRFA = 0 />
	</CFIF>
<CFSET IsProgramTemplateAvailable = 1>
<CFIF (GetSettings.Deleted EQ 1 OR GetSettings.Active EQ 0) AND CSLGetContractInfo.Contract_Status_Type_IDX LTE 3>
	<CFSET IsProgramTemplateAvailable = 0>
</CFIF>

<CFIF isdefined("request.AccessStructure.name_first")>
    <CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
        SELECT User_Positions_ID
        FROM User_Position_Holders
        WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
    </CFQUERY>


    <!--- 17386 RBL fixing for frequent errors ARGH [begin] --->
    <cfif (NOT isDefined("CSL_Contract_Main_ID") OR NOT len(trim(CSL_Contract_Main_ID))) AND (isDefined("CSLGetContractInfo.Contract_Main_ID") AND len(trim(CSLGetContractInfo.Contract_Main_ID)))>
    	<cfset CSL_Contract_Main_ID EQ CSLGetContractInfo.Contract_Main_ID>
    </cfif>

    <CF_CRYP type="en" string="#CSL_Contract_Main_ID#" key="#request.key#" return="Enc">

    <cfif isDefined("Enc.value")>
    	<cfset EncryptedCID = Enc.value>
    <cfelse>
    	<cfset EncryptedCID = CSL_Contract_Main_ID>
    </cfif>
    <!--- 17386 RBL fixing for frequent errors ARGH [end] --->

    <!--- Flag This Contract As Locked As Long As This User Is Using It --->
    <cfset useLakebaseForisContractCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForisContractCurrentlyLocked>
	<cftry>
		<cfset isContractCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#CSLGetContractInfo.Contract_Main_ID#",
				"select" = "contract_is_locked,contract_locked_by_user_id,contract_main_id"
			}), "contract_is_locked,contract_locked_by_user_id,contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisContractCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisContractCurrentlyLocked>
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
        SELECT Contract_Is_Locked, Contract_Locked_By_User_ID, Contract_Main_ID
        FROM Contract_Main
        WHERE Contract_Main_ID ='#CSLGetContractInfo.Contract_Main_ID#'
    </cfquery>
</cfif>
    <!--- END Flag This Contract As Locked As Long As This User Is Using It --->

    <!---  check position tree for  user access--->

    <CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
    <CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

    <CFSET DisAllowAccessBasedOnPosition = 0>
    <cfif CSLGetContractInfo.Creating_User_Position_ID NEQ "" and len(GP_Supplied_Position) gt 0>
        <cfquery name="qGetMyPositionsListSameAsCreating_User_Position_ID" datasource="#application.datasource#">
            #GP_Position_List_From_My_Position_Down#
            AND Below_User_Positions_ID = #CSLGetContractInfo.Creating_User_Position_ID#
        </cfquery>
        <CFIF qGetMyPositionsListSameAsCreating_User_Position_ID.recordCount EQ 0>
            <CFSET DisAllowAccessBasedOnPosition = 1>
        </CFIF>
    </cfif>
</CFIF>
<!--- decide if this program is a revision of an existing one --->
<CFSET Program_Is_A_Revision = 0>
<CFIF len(trim(CSLGetContractInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(CSLGetContractInfo.Revision_of_Contract_Main_ID)) NEQ 0>
	<CFSET Program_Is_A_Revision = 1>
</CFIF>
<CFSET IsRollOver = 0>
<CFIF CSLGetContractInfo.IsRollOver EQ 1 >
	<CFSET IsRollOver = 1>
</CFIF>

<CFSET IsLimitedRevise = 0>
<CFIF CSLGetContractInfo.Limited_Revise EQ 1 >
	<CFSET IsLimitedRevise = 1>
</CFIF>

<CFIF isdefined("request.AccessStructure.name_first")>
	<CFSET DisAllowAccessBasedOnLockStatus = 0>
	<CFSET TabsAreActive = 0>

	<!------ Check Access Profile ----->
	<cfset DisAllowAccessBasedOnProfile = 0>
	<cfset DisAllowApproveBasedOnProfile = 0>
	<CFIF (isDefined("Get_Profile_Settings.Cont_Prog_View_Create_Program") AND Get_Profile_Settings.Cont_Prog_View_Create_Program NEQ 1)>
		<cfset DisAllowAccessBasedOnProfile = 1>
	<CFELSE>
		<!------ Check to see if User Number restriction is there ----->
		<cfif NOT isDefined("appSettings")>
			<!---Gets application settings--->
			<cfset appSettings = application.appsettingsGet />
		</cfif>
		<cfset userManager = CreateObject("component", "components.user.UserManager") />
		<cfif appSettings.getUserNumberRestrict() EQ 1 AND userManager.getUserNumberExists(request.AccessStructure.User_ID) EQ 0>
			<cfset DisAllowAccessBasedOnProfile = 1>
		</cfif>
	</CFIF>
	<CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights NEQ 1>
		<cfset DisAllowApproveBasedOnProfile = 1>
	</CFIF>
</CFIF>
  <!---D38941 :: New Limited User Profile Edit Functionality START--->
	<cfif isDefined("Get_Profile_Settings.Cont_Prog_View_Create_Program") and Get_Profile_Settings.Cont_Prog_View_Create_Program EQ -1 AND Get_Profile_Settings.Limited_Revise EQ 1>

		<cfquery name="GetForbidAccessType" datasource="#application.datasource#">
				SELECT *
				FROM Program_Control_Panel_Options PCPO
				INNER JOIN Profile_Forbidden_Template PFT
				ON PFT.Template_ID = PCPO.ProgramControl_Panel_Options_ID
				And PFT.Deleted = 0
				WHERE 	PCPO.ProgramControl_Panel_Options_ID =  '#trim(ThisProgramID)#'
				AND PFT.Forbid_Access_Type = 7
		</cfquery>
		<cfif GetForbidAccessType.recordcount>
				<cfset DisAllowAccessBasedOnProfile = 0>
		</cfif>

	</cfif>
  <!---D38941 :: New Limited User Profile Edit Functionality END--->
<cfquery name="getGeneralSettings" datasource="#application.datasource#">
	SELECT 	TOP 1 Use_Discount_ID, edit_basic_info, edit_operators,
	edit_opr_basinfo
	FROM 	General_Settings
</cfquery>

<!--- Dev Note: WR 78635 - Check to see if it is a template which pays to "vendor only" --->
<cfset variables.bvendorOnlyProgram = objProgram.IsVendorOnlyPayeeOnTemplate(ThisProgramID)>
<cfif variables.bvendorOnlyProgram eq 1>
	<cfset variables.bVendorsExist = objProgram.getVendorsExistOnProgram(CSL_Contract_Main_ID)>
	<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
	<cfset variables.VendorLabel = labelSettings.getBBLabels().vendor />
</cfif>

</cfif>
