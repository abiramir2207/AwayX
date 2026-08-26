<!--- ~~~~~~~~~~~~~~~~ default not to read left panel from html file ~~~~~~~~~~~~~~~~ --->
<cfparam name="request.getProgramLeftPanelHtml" default="0">

<cfset contract_status_legend = ''>
<!--- ~~~~~~~~~~~~~~~~~~~~~~~ read left panel from html file ~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfif request.getProgramLeftPanelHtml>
    <cfset useLakebaseForisContractCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForisContractCurrentlyLocked>
	<cftry>
		<cfset isContractCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#CSL_Contract_Main_ID#",
				"select" = "contract_is_locked,contract_locked_by_user_id"
			}), "contract_is_locked,contract_locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisContractCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisContractCurrentlyLocked>
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
        SELECT Contract_Is_Locked, Contract_Locked_By_User_ID
          FROM Contract_Main
         WHERE Contract_Main_ID = #CSL_Contract_Main_ID#
    </cfquery>
</cfif>
    <cfset request.is_in_edit_mode = isContractCurrentlyLocked.Contract_Is_Locked
                                        and isContractCurrentlyLocked.Contract_Locked_By_User_ID eq request.AccessStructure.User_ID>
    <cfset left_panel_output       = application.util.io.getProgramLeftPanelHtml( CSL_Contract_Main_ID, request.is_in_edit_mode )>
    <cfset contract_status_legend  = left_panel_output.html_content>
    <!--- <cfoutput><h1>#request.is_in_edit_mode#</h1></cfoutput> --->
</cfif>

<!--- <cfinclude template="/developer/dev_tools.cfm"> --->

<!--- ~~~~~~~~~~~~~~~~~ left panel html exists, use it skip queries ~~~~~~~~~~~~~~~~~ --->
<cfif len(contract_status_legend)>
    <cfset save_left_panel = 0>
<cfelse>
    <cfset save_left_panel = 1>

    <cfsavecontent variable="contract_status_legend">
    <cfset request.is_in_edit_mode = 0>
    <cf_include files="/script/javascript/DHTML_Tooltip_Code.js, /common_files/viewmodes.css, /styles/css-loader.css">
    <cfinclude template="/Common_Files/jQuery.cfm">
    <script>
        function customContainer(){
            document.getElementById('customContainer').style.display='block';//D51575
        }

        function customContainerEditlink(){
            document.getElementById('editActive').style.display = 'none';
            document.getElementById('editInActive').style.display = 'block';
            document.getElementById('editInActive').style.cursor = 'pointer';
            document.getElementById('customContainer').style.display='block';//D51575
        }

        function callSpinner(){
            show_loader( "LOADING... PLEASE WAIT...", 1000 );
        }

    </script>
    <style>
        select{
            height:18px;
            }
    </style>
    <CFPARAM NAME="Cache_Control_Header_Already_Added" 	DEFAULT="0">
    <CFPARAM name="Print_Button_Show" default = "0">
    <CFPARAM name="Email_Button_Show" default = "0">
    <CFPARAM name="Fax_Button_Show" default = "0">
    <CFPARAM name="History_Button_Show" default = "0">
    <CFPARAM name="Cancel_Button_Show" default = "0">
    <CFPARAM name="Renew_Button_Show" default = "0">
    <CFPARAM name="RollOver_Button_Show" default = "0">
    <CFPARAM name="Revise_Button_Show" default = "0">
    <CFPARAM name="Delete_Button_Show" default = "0">
    <CFPARAM name="Purge_Button_Show" default = "0">
    <CFPARAM name="WIP_Kickback_Show" default = "0">
    <CFPARAM name="Revision_History_Button_Show" default = "0">
    <CFPARAM name="Program_Changes_Button_Show" default = "0">
    <CFPARAM name="Release_Settlement_Button_Show" default = "0">
    <cfparam name="programagreed" default="0">
    <cfparam name="Revision_Settings_Allowed" default="0">
    <cfparam name="URL.CID" default="">
    <cfparam name="url.EZTemplate" default="0">
    <CFPARAM name="Mass_Copy_Button_Show" default = "0">
    <CFPARAM name="BestPlanLinkDisable" default = "0"><!--- 67157 --->
    <CFPARAM name="Modify_Won_By" default = "0">
    <CFIF NOT Cache_Control_Header_Already_Added>
        <cfheader name="Cache-Control" value="no-store">
        <cfheader name="expires" value="-100">
    </CFIF>

    <CFPARAM NAME="CSL_Contract_Main_ID" DEFAULT="">
    <CFPARAM NAME="List_Of_Contract_Main_IDs" DEFAULT="">
    <CFPARAM NAME="CSL_CallingPageCode" DEFAULT="">
    <CFPARAM NAME="CSL_data" DEFAULT="0">
    <CFPARAM NAME="url.bViewReadOnly" DEFAULT="0">

    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
    <cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
    <cfset oRecaptureOperatorList = CreateObject("component", "components.programs.RecaptureOperatorList") />

    <CFSET MainLinksNotClickableClass = "Grayed">

    <!--- retrieve all settings and place them into request.settings variable --->
    <cfset application.util.query.request_settings()>

    <CFIF CSL_CallingPageCode NEQ "viewcontract" and url.EZTemplate EQ 0>
        <!--- lock checker --->
        <CFSET LockChecker_CID  = CSL_Contract_Main_ID>
        <CFINCLUDE TEMPLATE="LockChecker.cfm">
        <!--- lock checker --->
    </CFIF>

    <CFINCLUDE TEMPLATE="commonqueries.cfm">
    <cfquery name="variables.performanceRequirements" datasource="#application.datasource#">
        <cfif val(CSLGetContractInfo.ProgramType_ID) eq 0>
            SELECT 0 AS RowsCount
        <cfelse>
            SELECT COUNT(1) AS RowsCount
            FROM Program_Perf_Mapping
                INNER JOIN Program_Perf_req ON Program_Perf_req.Program_Perf_req_Id = Program_Perf_Mapping.Program_Perf_req_Id
            WHERE Program_Perf_Mapping.Template_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#CSLGetContractInfo.ProgramType_ID#">
        </cfif>
    </cfquery>

    <!--- Add the Revision Settings Component --->
    <cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
    <cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = GetSettings.ProgramControl_Panel_Options_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = CSL_Contract_Main_ID)>
    <cfset bIsContractARevision = 0 />

    <cfif URL.CID NEQ "">

        <CF_CRYP type="de" string="#URL.CID#" key="#request.key#">

        <cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(cryp.value)>
        <cfif len(trim(CSL_Contract_Main_ID))>
            <cfset bIsContractARevision = CreateObject("component", "components.programs.Program").isARevision(#CSL_Contract_Main_ID#) />
        </cfif>
        <cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number neq "")>
            <cfset Revision_Settings_Allowed = 1>
        </cfif>

    <cfelse>

        <cfset RevisionStatus = QueryNew("Is_A_Revision, Contract_Reference_Number, Client_Sent")>

    </cfif>
    <cfsilent>
    <CFPARAM name="GetSettings.Specify_Distributors" default="1">
    <CFPARAM name="GetSettings.Specify_Operators" default="1">
    <CFPARAM name="GetSettings.Specify_Brokers" default="1">
    <CFPARAM name="GetSettings.Specify_Products" default="1">
    <CFPARAM name="GetSettings.Bid_Rules" default="1">
    <CFPARAM name="Sent_To_External_Client" default="0">
    <CFPARAM name="group_processed" default="0">
    <cfparam name="edit_program" default="1">
    <cfparam name="editcopyrevise" default="1">
    <cfparam name="user_acess_approval_tabs" default="1">
    <cfparam name="modifyingusername" default="">
    <cfparam name="checkuom" default="0">

    <CFIF CSL_CallingPageCode EQ "viewcontract">
        <cfif (CSLGetContractInfo.is_a_revision EQ 1 or CSLGetContractInfo.renewal_of_contract_main_id NEQ "") and CSLGetContractInfo.check_program_uom EQ 1>
        <cfset templateid = CSLGetContractInfo.programtype_id>
        <cfset program_id = CSLGetContractInfo.contract_main_id>
        <cfinclude template="check_program_uoms.cfm">
        </cfif>
    </CFIF>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="SetUpOption" output="true" hint="I display LHP option with one enabled condition.">
    <cfargument name="text"     type="string"  required="true"  hint="option text">
    <cfargument name="enabled"  type="boolean" required="true"  hint="true = option is enabled">
    <cfargument name="anchor"   type="string"  required="true"  hint="anchor attributes (href, onclick, etc..)">
    <cfargument name="disabled" type="string"  required="false" default="display" hint="none = do not display of disabled option">
    <cfargument name="dot_img"  type="string"  required="false" default="/images/programs/ball_blue.gif" hint="dot image file name">

    <cfset var vars = {}>
    <cfsetting enablecfoutputonly="true" >
    <!---determine the disabled dot image file name--->
    <cfif arguments.dot_img contains 'ball_green.gif'>
        <cfset vars.disabled_dot = '/images/programs/ball_red.gif'>
    <cfelse>
        <cfset vars.disabled_dot = '/images/programs/ball_gray_filled.gif'>
    </cfif>
    <cfoutput><tr class="contractLinks"></cfoutput>
            <!---test enabled condition--->
        <cfif arguments.enabled>
        <cfoutput><td nowrap><img border="0" src="#arguments.dot_img#" align="absmiddle"><a #arguments.anchor# class="tablink_back">&nbsp;#arguments.text#</a></td></cfoutput>

            <!---option is not enabled--->
        <cfelseif arguments.disabled eq "display">
        <cfoutput><td nowrap class="Grayed"><img border="0" src="#vars.disabled_dot#" align="absmiddle">&nbsp;#arguments.text#</td></cfoutput>
        </cfif>
    <cfoutput></tr></cfoutput>
    <cfsetting enablecfoutputonly="false" >
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="SetUpOption2" output="true" hint="I display LHP option with 2 enabled conditions.">
    <cfargument name="text"      type="string"  required="true"  hint="option text">
    <cfargument name="enabled1"  type="boolean" required="true"  hint="true = option is enabled">
    <cfargument name="anchor1"   type="string"  required="true"  hint="anchor attributes (href, onclick, etc..)">
    <cfargument name="enabled2"  type="boolean" required="true"  hint="true = option is enabled">
    <cfargument name="anchor2"   type="string"  required="true"  hint="anchor attributes (href, onclick, etc..)">
    <cfargument name="disabled"  type="string"  required="false" default="display" hint="none = do not display of disabled option">
    <cfargument name="dot_img"  type="string"   required="false" default="/images/programs/ball_blue.gif" hint="enabled dot image file name">

    <cfset var vars = {}>
    <cfsetting enablecfoutputonly="true" >
    <!---determine the disabled dot image file name--->
    <cfif arguments.dot_img contains 'ball_green.gif'>
        <cfset vars.disabled_dot = '/images/programs/ball_red.gif'>
    <cfelse>
        <cfset vars.disabled_dot = '/images/programs/ball_gray_filled.gif'>
    </cfif>
    <cfoutput><tr></cfoutput>
            <!---test 1st enabled condition--->
        <cfif arguments.enabled1>
        <cfoutput><td nowrap><img border="0" src="#arguments.dot_img#" align="absmiddle"><a #arguments.anchor1# class="tablink_back">&nbsp;#arguments.text#</a></td></cfoutput>
            <!---test 2nd enabled condition--->
        <cfelseif arguments.enabled2>
        <cfoutput><td nowrap><img border="0" src="#arguments.dot_img#" align="absmiddle"><a #arguments.anchor2# class="tablink_back">&nbsp;#arguments.text#</a></td></cfoutput>
            <!---option is not enabled--->
        <cfelseif arguments.disabled eq "display">
        <cfoutput><td nowrap class="Grayed"><img border="0" src="#vars.disabled_dot#" align="absmiddle">&nbsp;#arguments.text#</td></cfoutput>
        </cfif>
    <cfoutput></tr></cfoutput>
    <cfsetting enablecfoutputonly="false" >
    </cffunction>

    <!--------------------------------------------------------------------------------------------------------------------->

    <cfset programManager = CreateObject("component", "components.programs.ProgramManager") />
    <cfset agreed = programManager.isProgramAgreed(CSL_Contract_Main_ID, request.AccessStructure.User_ID)>
    <cfset programagreed = programManager.isProgramAgreed(CSL_Contract_Main_ID)>

    <cfif CSLGetContractInfo.modifying_program EQ 0 AND CSLGetContractInfo.CONTRACT_STATUS_TYPE_IDX eq 2 and appsettings.getmodifyagreeprogram()>
        <CFSET edit_program = 0>
    </cfif>

    <cfif CSLGetContractInfo.CONTRACT_STATUS_TYPE_IDX GT 1  AND CSL_CallingPageCode IS "viewcontract">
        <cfset Mass_Copy_Button_Show = 1 />
    </cfif>

    <cfif edit_program EQ 1 and CSLGetContractInfo.modifying_user_id NEQ request.AccessStructure.User_ID and CSLGetContractInfo.modifying_program EQ 1>
        <cfset edit_program = 0>
        <cfset user_acess_approval_tabs = 0>
        <cfset getmodifyinguser = programManager.getmodifyinguser(CSLGetContractInfo.modifying_user_id)>
        <cfset modifyingusername = getmodifyinguser.User_name>
    </cfif>

    <cfif CSLGetContractInfo.Dont_Allow_Edit EQ 1>
    <cfset Revise_Button_Show = 0>
    <cfset Cannot_Edit_Program_Msg = "This program cannot be revised." >
    </cfif>

    <cfif CSLGetContractInfo.price_protection_scheduled EQ 1>
    <cfset Revise_Button_Show = 0>
    <cfset Cannot_Edit_Program_Msg = "This program cannot be revised because it is locked for price protection update." >
    </cfif>

    <cfset ListOfAvailUOM = "">
    <cfif GetSettings.RateTypeOption_1 EQ 1>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 2)>
    </cfif>
    <cfif GetSettings.RateTypeOption_2 EQ 1>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 1)>
    </cfif>
    <cfif GetSettings.RateTypeOption_3 EQ 1>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 3)>
    </cfif>
    <cfif listlen(ListOfAvailUOM) EQ 0>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 0)>
    </cfif>

    <cfset ListOfAvailUOMFF = "">
    <cfif GetSettings.RateTypeOption_1 EQ 1>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 2)>
    </cfif>
    <cfif GetSettings.RateTypeOption_2 EQ 1>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 1)>
    </cfif>
    <cfif listlen(ListOfAvailUOM) EQ 0>
        <CFSET ListOfAvailUOM = listappend(ListOfAvailUOM, 0)>
    </cfif>

        <cfset Contract_Main_ID = CSLGetContractInfo.Contract_Main_ID>

        <cfif GetSettings.Date_Exclusions_ON EQ 1>
            <cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
            <cfset getParentContractInfo = GenProgramManager.ParentProgramInfo(CSL_Contract_Main_ID)>

            <cfif getParentContractInfo.RecordCount eq 0>
                <cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
            <cfelse>
                <cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(getParentContractInfo.Contract_Main_ID,1)>
            </cfif>
        </cfif>

    <!--- If its a Date exclusion project, get all the IDs including the Date Exclusion Program IDs --->
        <cfif GetSettings.Date_Exclusions_ON EQ 1>
            <CFSET ContractIDs = CSL_Contract_Main_ID>
            <CFSET ContractIDList = GenProgramManager.ChildProgramIDs(ContractIDs,0)>
                <cfset ChildProgramIDList = ValueList(ContractIDList.Revision_Program_ID)>
                <CFIF ContractIDList.Recordcount neq 0>
                    <CFSET ContractIDs = ContractIDs & "," & ChildProgramIDList>
                </CFIF>
        </cfif>

    <!--- Get the encrypted values for all the programs (including the date exclusion programs)--->
        <cfif GetSettings.Date_Exclusions_ON EQ 1>
            <cfif CSLGETCONTRACTINFO.IsExclusionRevision EQ 1>
                <cf_cryp type = "en" string = "#getParentContractInfo.Contract_Main_ID#" key = "#request.key#">
                <cfset Parent_Program_ID =cryp.value>
                <cfset editcopyrevise = 0>
            <cfelse>
                    <cfset LoopCount = 0>
                <cfif ListLen(ChildProgramIDList) neq 0>
                    <cfloop list="#ChildProgramIDList#" index="ContractID">
                        <cfset LoopCount = LoopCount + 1>
                        <cf_cryp	type = "en" string = "#ContractID#" key = "#request.key#">
                        <cfset Child_Program_ID[LoopCount]= cryp.value>
                    </cfloop>
                </cfif>
            </cfif>
        </cfif>



    <!--- This include queries each discount type to see if one has been added to the program --->
        <cfinclude template="discount_queries.cfm">
        <!---This include has the following queries:
            FixedPricesStatus
            FormulaStatus
            RebateStatus
            GrowthStatus
            LumpStatus
            getBidRequestProducts
            Off_Invoice
        --->
        <!--- If the Program has Date Exclusions turned on --->

    <cfif appSettings.getsend_to_sap()>
        <cfset Sent_To_External_Client = CSLGetContractInfo.Sent_To_External_Client>
    </cfif>

    <cfset Cannot_Edit_Program_Condition_Y = 0 />
    <cfparam name="We_Are_Sending_Program_To_External_Client" 		default="0">
    <cfparam name="Cannot_Edit_Program_Msg" 	default="">
    <!------ Make this msg short, because no space to display, it is better to display a small image and then a title ----->
    <cfif appSettings.getPgmDisableEditWhileSendingToClient()>
        <cfset We_Are_Sending_Program_To_External_Client = Val(CSLGetContractInfo.Sending_To_External_Client)>
        <cfif We_Are_Sending_Program_To_External_Client>
            <cfset Cannot_Edit_Program_Msg = "This program is currently locked, sending to ERP..." />
        </cfif>
    </cfif>
    <cfset Cannot_Edit_Program_Condition_Y = We_Are_Sending_Program_To_External_Client />

    <!---if a lock type is set in the app settings and the program is approved and the program hasn't already been locked based on the
    "Do not Allow Revisions Untill Success Acknowledgement from SAP" app setting, then we have to determine if we have to lock the program--->
    <cfif URL.CID NEQ "">
        <cfif appSettings.getProgramLockTypeID() and CSLGetContractInfo.Approved eq 1 and not Cannot_Edit_Program_Condition_Y>
            <cfset objProgramLockType = createObject("component", "components.programs.ProgramLockType") />
            <cfset lockTypeStatus = objProgramLockType.getProgramLockStatus(CSLGetContractInfo.Contract_Main_ID) />
            <!---if getProgramLockStatus() doesn't return 0 then we have to lock the program--->
            <cfif lockTypeStatus>
                <cfset Cannot_Edit_Program_Condition_Y	= 1 />
                <cfset Cannot_Edit_Program_Msg 			= "Revisions locked pending ERP communication" />
            </cfif>
        </cfif>
    </cfif>
    <!------ check whether responsible user is available
    if not set Cannot_Edit_Program_Condition_Y = 1 and Cannot_Edit_Program_Msg = "responsible user is not avaialble, please reassign this program"
    ----->
    <cfif Not Cannot_Edit_Program_Condition_Y and CSLGetContractInfo.recordCount gt 0 and appSettings.getApplyRSPFilters() EQ 1>
        <cfset userManager = CreateObject("component", "components.user.UserManager") />
        <cfset qUser = userManager.getUser(CSLGetContractInfo.Responsible_User_Id) />
        <cfif qUser.recordCount eq 0>
            <cfset Cannot_Edit_Program_Condition_Y = 1 >
            <cfset Cannot_Edit_Program_Msg = "responsible user is not available, please reassign this program" >
        </cfif>
    </cfif>

    <!--- Start Dev Note:19985 Milan - This code used to exist in scorecard\display_list.cfm --->
    <CFIF Cannot_Edit_Program_Condition_Y eq 0  AND left(application.returned_customer_setting.Customer_Keyword,6) EQ "Foster">
        <CFIF CSLGetContractInfo.Approved EQ 1 AND CSLGetContractInfo.Sent_To_External_Client NEQ 1>

        <cfset useLakebaseForGetDiscountIdentifier = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_identifier")>
<cfif useLakebaseForGetDiscountIdentifier>
	<cftry>
		<cfset GetDiscountIdentifier = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_identifier", {
				"discount_identifier_id" = "eq.#GetSettings.Discount_Identifier_ID#",
				"select" = "discount_identifier_number,discount_identifier_desc"
			}), "discount_identifier_number,discount_identifier_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDiscountIdentifier = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDiscountIdentifier>
<cfquery name="GetDiscountIdentifier" datasource="#application.datasource#">
            SELECT Discount_Identifier_Number, Discount_Identifier_Desc
            FROM Discount_Identifier
            WHERE Discount_Identifier_ID = '#GetSettings.Discount_Identifier_ID#'
        </cfquery>
</cfif>

            <CFIF CSLGetContractInfo.Generic_Type EQ "Distributor Trade/Shelter">
                <CFSET Cannot_Edit_Program_Condition_Y = 1>
                <CFSET Cannot_Edit_Program_Msg = "This is a Distributor Trade/Shelter program" >
        </CFIF>

            <CFIF Cannot_Edit_Program_Condition_Y EQ 0>
            <CFIF GetDiscountIdentifier.Discount_Identifier_Number EQ "ZDis" OR GetDiscountIdentifier.Discount_Identifier_Number EQ "ZNet">
                <CFSET Cannot_Edit_Program_Condition_Y = 1>
                <CFSET Cannot_Edit_Program_Msg = "The discount identier is either ZDis or ZNet" >
        </CFIF>
            </CFIF>

            <CFIF Cannot_Edit_Program_Condition_Y EQ 0>
                <cfset useLakebaseForIsALumpsum = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForIsALumpsum>
	<cftry>
		<cfset IsALumpsum = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sums", {
				"program_id" = "eq.#CSLGetContractInfo.contract_main_id#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsALumpsum = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsALumpsum>
<cfquery name="IsALumpsum" datasource="#application.datasource#">
                    SELECT Top 1 Program_ID FROM Program_Lump_Sums	WHERE Program_ID = #CSLGetContractInfo.contract_main_id# AND Program_Lump_Sums.deleted = 0
                </cfquery>
</cfif>
                <CFIF IsALumpsum.RecordCount GT 0>
                    <CFSET Cannot_Edit_Program_Condition_Y = 1>
                    <CFSET Cannot_Edit_Program_Msg = "There is a lump sum component on the program" >
                </CFIF>
            </CFIF>

            <CFIF Cannot_Edit_Program_Condition_Y EQ 1>
                <cfquery name="AnyDirectCustomers" datasource="#application.datasource#">
                    SELECT TOP 1 Customer_Type,BSA_FoodService_Customers.BSA_FoodService_Customers_ID FROM Contract_Distributors
                    INNER JOIN BSA_FoodService_Customers ON BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID
                    WHERE Contract_main_ID = #CSLGetContractInfo.contract_main_id# AND (Customer_Type IS NULL OR Customer_Type <> 'I')
                </cfquery>
                <!--- Any eligible component to send --->
                <cfquery name="AnyEligibleFixed" datasource="#application.datasource#">
                    SELECT		TOP 1 Program_Fixed_Component_Name.External_ID
                    FROM		Program_Fixed_Component

                    INNER JOIN 	Program_Fixed_Component_Name ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID AND
                                Program_Fixed_Component_Name.External_ID <> 'XX' AND
                                Program_Fixed_Component.deleted = 0 AND
                                Program_Fixed_Component.program_id = #CSLGetContractInfo.contract_main_id#
                </cfquery>
                <cfquery name="AnyEligibleRebate" datasource="#application.datasource#">
                    SELECT		TOP 1 Program_Rebates_Component_Name.External_ID
                    FROM		Program_Rebates_Component

                    INNER JOIN	Program_Rebates_Component_Name ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID AND
                                Program_Rebates_Component_Name.External_ID <> 'XX' AND
                                Program_Rebates_Component.deleted = 0 AND
                                Program_Rebates_Component.program_id = #CSLGetContractInfo.contract_main_id#
                </cfquery>
                <cfquery name="AnyEligibleLS" datasource="#application.datasource#">
                    SELECT		TOP 1 Program_Lump_Sum_Name.External_ID
                    FROM		Program_Lump_Sums

                    INNER JOIN	Program_Lump_Sum_Name ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID AND
                                Program_Lump_Sum_Name.External_ID <> 'XX' AND
                                Program_Lump_Sums.deleted = 0 AND
                                Program_Lump_Sums.program_id = #CSLGetContractInfo.contract_main_id#
                </cfquery>
                <cfquery name="AnyEligibleGrowth" datasource="#application.datasource#">
                    SELECT		TOP 1 Program_Growth_Components_Name.External_ID
                    FROM		Program_Growth_Components

                    INNER JOIN	Program_Growth_Components_Name ON Program_Growth_Components_Name.Program_Growth_Components_Name_Id = Program_Growth_Components.Program_Growth_Components_Name_Id AND
                                Program_Growth_Components_Name.External_ID <> 'XX' AND
                                Program_Growth_Components.deleted = 0 AND
                                Program_Growth_Components.program_id  = #CSLGetContractInfo.contract_main_id#
                </cfquery>
                <!--- End Any eligible component to send --->
                <CFIF (AnyDirectCustomers.RecordCount EQ 0 AND AnyEligibleLS.RecordCount EQ 0) OR (AnyEligibleFixed.RecordCount EQ 0 AND AnyEligibleRebate.RecordCount EQ 0 AND AnyEligibleLS.RecordCount EQ 0 AND AnyEligibleGrowth.RecordCount EQ 0)>
                    <CFSET Cannot_Edit_Program_Condition_Y = 0>
                    <CFSET Cannot_Edit_Program_Msg = "" >
                </CFIF>
            </CFIF>
        </CFIF>
    </CFIF>
    <!--- End - Dev Note:19985 Milan - This code used to exist in scorecard\display_list.cfm --->

    <cfif appSettings.getPullbacksOn() EQ 1>
        <cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
    <cfset qGetProfileTemplates = templateManager.getProfileTemplates(
                    profileId = request.AccessStructure.Profiles_ID,
                    forbidAccessType = 6,
                    templateId = GetSettings.ProgramControl_Panel_Options_ID
                    ) />
    </cfif>

    </cfsilent>

    <!--- check to see if the program template used for this contract is deleted or made inactive --->
    <cfif url.EZTemplate EQ 0>
    <CFOUTPUT>
        <script language="JavaScript" type="text/JavaScript">
        <!--
        function MM_reloadPage(init) {  //reloads the window if Nav4 resized
        if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
            document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
        else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
        }
        MM_reloadPage(true);
        //-->
        </script>

        <!--- Dev Note: Kal; D42587: French Language Labels; Display only when user has french and template has french --->
        <cfif lcase(request.AccessStructure.User_Language) eq "french" AND lcase(GetSettings.Label_Set_Default) eq "french">
            <div id="google_translate_element"></div><br>
            <!-----------------------------------
            *** Custom Language Dropdown Box ***
            ------------------------------------>
            <script language="JavaScript" type="text/javascript">
                function googleTranslateElementInit() {
                    <!--- Custom Language dropdown --->
                    new google.translate.TranslateElement({pageLanguage: 'en', includedLanguages: 'fr,en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
                    <!--- Styles --->
                }
            </script>
            <script language="JavaScript" type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
            <!--- remove previous google translation cookie (if any) --->
            <!--- BELOW CSS WILL HIDE GOOGLE TRANSLATER LOGO --->
            <style>
                .goog-logo-link {
                display:none !important;
                }
            </style>
        </cfif>

        <!--- <cfinclude template="/common_files/programTranslate.cfm"> --->
        <!--- <cfdump var="#session#"> --->

    <div id="divTooltip" style="z-index:200;width:200px;"></div>
    <!--- <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"> --->
    </CFOUTPUT>


    <cfset Program_ID = CSL_Contract_Main_ID>
    <CF_SmallHelp
        height = "200"
        width = "500"
        overflow = "auto"
        displayShifyX = "-30"
        displayShifyY = "-5"
        showImage="-1"
        returnDivId="returnDivId">
    <center>
    <font color="blue">*** click on the window to close ***</font><br>
    <cfinclude template="users_agreed.cfm"></center>
    </CF_SmallHelp>
    <cfset anyUsergreed = getprogramuseragreed.recordCount>
    <CFIF DisAllowAccessBasedOnLockStatus EQ 0 AND Get_Profile_Settings.Internal_Notes eq 1>
    <CF_SmallHelp
        height = "100"
        width = "300"
        overflow = "auto"
        displayShifyX = "-30"
        displayShifyY = "-5"
        showImage="-1"
        returnDivId="returnDivIdComments">
    <center>
    <font color="blue">*** click on the window to close ***</font><br></center>
    <table width="100%"><tr><td>
    <cfoutput><pre>#CSLGetContractInfo.Comments#</pre></cfoutput>
    </td></tr></table>
    </CF_SmallHelp>
    </CFIF>
    <!--- D50074 :: Viewing and Editing prior program versions START --->
    <cfif len(CSLGetContractInfo.Contract_Main_ID)>
        <cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(CSLGetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
    <cfelse>
        <cfset ModifyDeletedPrograms = 0>
    </cfif>
    <!--- D50074 :: Viewing and Editing prior program versions END --->

    <!---<SPAN style="color:red; position:absolute; width:100px; z-index:1; top: 36px; left: 5px;">--->

    <cfset custom_rfp_process = appSettings.get_Setting('Custom_RFP_Process',0)>
    <div <cfif custom_rfp_process neq 0>style="background-color:#f8fafc;height:100vh;width:141px;"</cfif> >
    <TABLE BORDER="0" CELLPADDING="0" ID="table1">
    <!---  END check position tree for  user access--->
    <cfif checkuom EQ 1>
        <TR>
            <TD NOWRAP COLSPAN="2" align="center">
                <div id="Layer2" align="center" style="clear:both; position:absolute; width:800px; height:40px; left: 138px; top: 5px; color:red; font-weight:bold; font-size:14px">
                    The program's Unit of Measurements do not match with the template UOM settings.<br> You must go into each discount page to review and adjust the UOM for the products.
                </div>
            </TD>
        </TR>
    </cfif>

    <CFIF (DisAllowAccessBasedOnProfile EQ 1 AND DisAllowApproveBasedOnProfile EQ 1) OR Cannot_Edit_Program_Condition_Y EQ 1 OR  CSLGetContractInfo.price_protection_scheduled EQ 1 OR CSLGetContractInfo.Dont_Allow_Edit EQ 1 or url.bViewReadOnly eq 1>
    <TR>
        <TD NOWRAP COLSPAN="2" align="center">
        <cfoutput>
        <!--- <IMG BORDER="0" SRC="/images/readonly_mode.gif" class="readonly" TITLE="#Cannot_Edit_Program_Msg#"> --->
        <button class="readonly" title="#Cannot_Edit_Program_Msg#">Read Only</button>
        <div id="Layer2" align="center" style="position:absolute; width:100px; height:29px; z-index:2; left: 138px; top: -30px; color: RGB(255,0,0); font-weight:bold; font-size:14px">
            #Cannot_Edit_Program_Msg#
        </div>
        </cfoutput>
        </TD>
    </TR>

        <CFIF CSLGetContractInfo.Contract_Locked_By_User_ID EQ request.AccessStructure.User_ID AND CSLGetContractInfo.Contract_Locked_By_User_ID NEQ '00000000-0000-0000-0000000000000000'>
            <!--- Unlock the program if it is locked by current user. Here the program is showing the unclickable "read-only" image and so the program should be unlocked. --->
            <cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
                <cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#CSLGetContractInfo.Contract_Locked_By_User_ID#">
                <cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
                <cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
                <cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
                <cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
                <cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="#CSLGetContractInfo.Contract_Main_ID#">
                <cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
            </cfstoredproc>
        </CFIF>

        <CFSET DisAllowAccessBasedOnLockStatus = 1>

    <CFELSEIF LEN(URL.CID) GT 0>
        <!--- if the length is zero than this contract cannot be locked so dont do it --->
        <CFSET TabsAreActive = 1>
        <CFIF isContractCurrentlyLocked.Contract_Is_Locked EQ 1 AND isContractCurrentlyLocked.Contract_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
            <CFSET DisAllowAccessBasedOnLockStatus = 1>
        </CFIF>
        <script language="JavaScript" type="text/javascript">
            Locked = new Image();
            //Locked.src = "/images/lock2.gif";
            Locked.src = "/images/readonly_mode.gif";

            UnLocked = new Image();
            //UnLocked.src = "/images/lock3.gif";
            UnLocked.src = "/images/edit_mode.gif";
        </script>

        <CFIF DisAllowAccessBasedOnLockStatus EQ 1>
            <cfsilent>
            <!--- get the information of the user who locked the program --->
            <cfset useLakebaseForLookUpTheLockingUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForLookUpTheLockingUser>
	<cftry>
		<cfset LookUpTheLockingUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#CSLGetContractInfo.Contract_Locked_By_User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLookUpTheLockingUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLookUpTheLockingUser>
<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
                SELECT Name_First, Name_Last
                FROM _Users
                WHERE User_ID = '#CSLGetContractInfo.Contract_Locked_By_User_ID#'
            </cfquery>
</cfif>

            <!--- get the database setting for session timeout and use that for now as the program timeout --->
            <cfset useLakebaseForgetSessionTimeoutSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetSessionTimeoutSetting>
	<cftry>
		<cfset getSessionTimeoutSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "session_expiration_length"
			}), "session_expiration_length"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSessionTimeoutSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSessionTimeoutSetting>
<CFQUERY NAME="getSessionTimeoutSetting" datasource="#application.datasource#">
                SELECT Session_Expiration_Length
                FROM General_Settings
            </CFQUERY>
</cfif>

            <CFSET PercentageOfTHeDayInactive = getSessionTimeoutSetting.Session_Expiration_Length + 1>
            <!--- get the time the user sent a request to the system last --->
            <CFQUERY NAME="getSessionTime" datasource="#application.datasource#">
                SELECT DATEDIFF(n, Session_Date_Time_Stamp, GetDate()) AS InactiveTimeSpanInMinutes
                FROM Session_Tracker
                WHERE Session_User_ID = '#CSLGetContractInfo.Contract_Locked_By_User_ID#'
            </CFQUERY>
            <CFIF getSessionTime.RecordCount GT 0>
                <!--- what percentage of the day has the user been inactive for --->
                <CFSET InactiveTimeSpanInMinutes = getSessionTime.InactiveTimeSpanInMinutes>
                <CFSET PercentageOfTHeDayInactive = InactiveTimeSpanInMinutes/1440>
            </CFIF>

            <!--- has the user been inactive longer than the setting specified :: 000000... user_id is BB_AUTO_REPORT admin.  It is used to lock programs that are in a WIP BB auto report --->
            <CFIF PercentageOfTHeDayInactive GT getSessionTimeoutSetting.Session_Expiration_Length and CSLGetContractInfo.Contract_Locked_By_User_ID NEQ '00000000-0000-0000-0000000000000000'>

                <cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
                    <cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#CSLGetContractInfo.Contract_Locked_By_User_ID#">
                    <cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
                    <cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
                    <cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
                    <cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
                    <cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="#CSLGetContractInfo.Contract_Main_ID#">
                    <cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
                </cfstoredproc>

                <CFSET DisAllowAccessBasedOnLockStatus = 0>
            </CFIF>
            </cfsilent>
            <CFIF DisAllowAccessBasedOnLockStatus EQ 1>
            <cfoutput>
            <TR>
                <TH NOWRAP COLSPAN="2">
                <!--- <IMG BORDER="0" SRC="/images/readonly_mode.gif" class="readonly" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#"><BR /> --->
                <button class="readonly" title="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#">Read Only</button><BR/>
        <span style="color:RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br />#ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#</span>
                </TH>
            </TR>
            </cfoutput>
            </CFIF>
        <CFELSE>
            <cfoutput>
            <CFIF isContractCurrentlyLocked.Contract_Is_Locked EQ 1>
                <!--- if it is locked offer to unlock it --->
                <TR>
                    <TD COLSPAN="2" align="center" style="word-wrap:break-word;width:13em;">
                        <cfset variables.lockHref = '/Common_Files/Contracts/UnLock_Contract.cfm?CID=#EncryptedCID#&ModifyDeletedPrograms=#ModifyDeletedPrograms#'>
                        <div id="editActive">
                        <a href="#variables.lockHref#" onclick="customContainerEditlink();">
                            <cfset request.is_in_edit_mode = 1>
                            <button class="edit" onclick="location.href='#variables.lockHref#';remove_window_from_list();" style="margin-bottom:5px;">&nbsp; Edit &nbsp;</button><br>
                            #application.util.string.LinkFormat("Click for Read Only")#
                        </a>
                        </div>
                        <div id="editInActive" style="display:none;cursor:pointer;">
                            <button class="edit" style="margin-bottom:5px;cursor:pointer;" onclick="alert('PROCESSING PLEASE WAIT......');">&nbsp; Edit &nbsp;</button><br>
                            <font color="gray">[ Click for Read Only ]</font>
                        </div>
                    </TD>
                </TR>
            <CFELSE>
                <CFSET DisAllowAccessBasedOnLockStatus = 1>
                <!--- if it is unlocked offer to lock it --->
                <TR>
                <TD COLSPAN="2" align="center" style="word-wrap:break-word;width:13em;">
                    <cfif CSLGetContractInfo.Best_Plan_Program AND ! Get_Profile_Settings.Best_Plan_Program>
                        <button class="readonly" style="margin-bottom:5px;" onMouseOver="initTheTooltip('User dont have access to Best Plan Program')" onMouseOut="popOut()">Read Only</button><br>
                        #application.util.string.LinkFormat("Click to Edit")#
                    <cfelse>
                        <cfset variables.lockHref = '/Common_Files/Contracts/Lock_Contract.cfm?CID=#EncryptedCID#&ModifyDeletedPrograms=#ModifyDeletedPrograms#'>
                        <a href="#variables.lockHref#" onclick="customContainer();">
                            <button class="readonly" onclick="CheckBeforeEditMode();" style="margin-bottom:5px;">Read Only</button><br>
                            #application.util.string.LinkFormat("Click to Edit")#
                        </a>
                    </cfif>
                </TD>
                </TR>
            </CFIF>
            </cfoutput>
        </CFIF>
    <CFELSE>
    <TD NOWRAP COLSPAN="2">
        <cfset request.is_in_edit_mode = 1>
        <!--- <IMG id="Locked" SRC="/images/edit_mode.gif" class="editmode" TITLE="Edit Mode" ALIGN="absmiddle" border="0"></TD> --->
        <button class="edit">&nbsp; Edit &nbsp;</button></TD>
    </TR>
    </CFIF>
    <tr>
        <td colspan="2">&nbsp;</td>
    </tr>
    <!--- 67157 :: Grey out Best Plans program menus START --->
    <cfif CSLGetContractInfo.Best_Plan_Program EQ 1 AND Get_Profile_Settings.Best_Plan_Program EQ 0>
        <CFSET BestPlanLinkDisable = 1>
    </cfif>
    <!--- 67157 :: Grey out Best Plans program menus END --->

    <!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
    <!---/////////////////////////////////////////// Lock Code End ///////////////////////////////////////////////////////--->
    <!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

    <!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes START --->
    <cfset disable_pages_in_rfa = 0>
    <cfif cslgetcontractinfo.contract_status_type_idx EQ 2 AND appSettings.getdisablepagesinrfa()>
        <cfset disable_pages_in_rfa = 1>
    </cfif>
    <!---D43661 :: Program RFA status - disable pages and require user to Reset to make any changes END--->

    <CFSET CanEditProgram = 0>
    <CFIF (
                    (
                        (
                            CSLGetContractInfo.Contract_Status_Type_IDX LTE 2
                            AND DisAllowAccessBasedOnLockStatus EQ 0
                            AND BestPlanLinkDisable EQ 0
                            AND DisAllowAccessBasedOnPosition EQ 0
                        )
                        OR len(URL.CID) EQ 0
                    )
                    AND DisAllowAccessBasedOnProfile EQ 0
                )
            OR ModifyDeletedPrograms><!--- D50074 :: Viewing and Editing prior program versions --->
            <CFSET CanEditProgram = 1>
    </CFIF>

    <CF_Cryp type="en" key="#request.key#" string="#CSL_Contract_Main_ID#" return="CSL_Encryp_Contract_Main_ID">

    <cfset request.letters_available = appSettings.getlettersavailable()>

    <CFIF 	NOT CanEditProgram AND len(URL.CID) EQ 0>
        <CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
        <!--- CSL_CallingPageCode = "at" means attachment. Now attachment can be seen even after approval (9/29/2005) --->
        <!--- CSL_CallingPageCode = "ci" means Competitive Info. Now Competitive Data(Info) can be seen even after approval (10/16/2006) - Milan (10697) --->


    <CFELSEIF  CSL_CallingPageCode NEQ "Sys" AND CSL_CallingPageCode NEQ ""
        AND (
            NOT(CanEditProgram
                OR (CSL_CallingPageCode EQ "viewcontract" AND len(URL.CID) GT 0)
                OR (CSL_CallingPageCode EQ "at")
                OR (CSL_CallingPageCode EQ "ci")
                OR (CSL_CallingPageCode EQ "bidinfopage")
                OR (CSL_CallingPageCode EQ "pullbacks")
                OR (CSL_CallingPageCode EQ "freightPage")
                OR (CSL_CallingPageCode EQ "gi")     <!--- ngt --->
                OR (CSL_CallingPageCode EQ "fixed_rebate_grid")
                OR ((CSL_CallingPageCode EQ "letters" and request.letters_available))
            )
        )
        >
        <CFLOCATION URL="/Common_Files/contracts/Contract_Edit_Menu.cfm?CID=#CSL_Encryp_Contract_Main_ID.value#" ADDTOKEN="No">
    </CFIF>
        <cfquery name="GetDiscountIdentifier" datasource="#application.datasource#">
            SELECT Discount_Identifier_Number, Discount_Identifier_Desc
            FROM Discount_Identifier
            WHERE Discount_Identifier_ID = '#GetSettings.Discount_Identifier_ID#'
        </cfquery>

    <!--- Do not show the tabs if CanEditProgram = 0 --->
    <CFIF CanEditProgram OR len(URL.CID) EQ 0>
            <cfsilent>
            <CFSET TabsClickable = 1>
            <CFIF len(URL.CID) EQ 0 OR IsProgramTemplateAvailable EQ 0>
                <CFSET TabsClickable = 0>
            </CFIF>
            <CFIF Sent_To_External_Client EQ 1>
            <!--- <CFIF Sent_To_External_Client EQ 1 OR group_processed EQ 1 OR (edit_program EQ 0)> --->
                <CFSET TabsClickable = 0>
            </CFIF>
            <!--- View Program Tab --->
            <CFSET CSL_ThisPageCode = "viewcontract">
            <CFIF request.TemplateName EQ "contract_edit_menu.cfm"><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
            <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
            </cfsilent>
            <cfset SetUpOption(  text = 'view program'
                        , enabled = (TabsClickable EQ 1)
                        , anchor = "onclick='callSpinner();customContainer();' href='/Common_Files/contracts/contract_edit_menu.cfm?CID=#EncryptedCID#'"
                            )>

            <!--- Basic Info Tab --->
            <!--- GPO - One Page Program - Custom Program Creation Screen 			***********************************************************************
                                TODO -> INCLUDE TEMPLATE SETTING when decideing to use GPO_One_Page_Program.cfm

                        *************************************************************************************************************************************--->
            <cfset biAnchor = '/Common_Files/contracts/contract_create_1_form.cfm'>
            <cfset biText = 'basic info' >


            <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND (GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO" OR GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA")>
                <cfset biAnchor = '/Common_Files/contracts/OPP/GPO_One_Page_Program.cfm'>
                <cfset biText = 'modify' >
            </cfif>

            <CFSET CSL_ThisPageCode = "gi">
            <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
            <CFIF CSLGetContractInfo.RecordCount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
            <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
            <cfset SetUpOption(  text = '#biText#'
                            , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and (edit_program EQ 1 or getGeneralSettings.edit_basic_info EQ 1)))
                            , anchor = "href='#biAnchor#?CID=#EncryptedCID#'"
                            , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>


            <!--- Operators Tab --->
            <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR (GetDiscountIdentifier.Discount_Identifier_Number NEQ "GPO" AND GetDiscountIdentifier.Discount_Identifier_Number NEQ "CPA")>
                <cfif GetSettings.Specify_Operators EQ 1>
                    <CFSET CSL_ThisPageCode = "op">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFIF CSLGetOperators.Recordcount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    <cfset SetUpOption(  text = lcase(application.returned_customer_setting.operator_label_singular)
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and (edit_program EQ 1 or getGeneralSettings.edit_operators EQ 1) AND variables.bShowOperatorlink and TabsAreActive EQ 1))
                                    , anchor = "href='/Common_Files/contracts/select_operators.cfm?CID=#EncryptedCID#'"
                                , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                </cfif>
                <!--- distributors Tab --->
                <cfif GetSettings.Specify_Distributors EQ 1>
                    <CFSET CSL_ThisPageCode = "di">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFIF checkForDistributors.RecordCount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    <cfset SetUpOption(  text = lcase(application.returned_customer_setting.distributor_label_singular)
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 AND variables.bShowDistributorLink and TabsAreActive EQ 1))
                                    , anchor = "onclick='customContainer()' href='/Common_Files/contracts/select_distributors.cfm?CID=#EncryptedCID#'"
                                , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                <cfelse>
                    <!---Dev Note: WR 78635 - vendors Tab (Note: We get vendors from the customer master table) --->
                    <cfif variables.bvendorOnlyProgram eq 1>
                        <CFSET CSL_ThisPageCode = "vn">
                        <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                        <CFIF variables.bVendorsExist EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
                        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                        <cfset SetUpOption(  text = lcase(variables.VendorLabel)
                                        , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                        , anchor = "onclick='customContainer()' href='/Common_Files/contracts/select_vendors.cfm?CID=#EncryptedCID#'"
                                    , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                    </cfif>
                </cfif>
            </cfif>
            <!--- brokers Tab --->
            <cfif GetSettings.Specify_Brokers EQ 1>
                <CFSET CSL_ThisPageCode = "br">
                <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                <CFIF checkForBrokers.RecordCount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                <cfset SetUpOption(  text = lcase(application.returned_customer_setting.broker_label_singular)
                                , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 AND Get_Profile_Settings.View_Broker_List EQ 1 and edit_program  EQ 1 AND variables.bShowBrokerLink and TabsAreActive EQ 1))
                                , anchor = "href='/Common_Files/contracts/select_brokers.cfm?CID=#EncryptedCID#'"
                                , dot_img = IMG_SRC )>
            </cfif>
            <!--- Formula --->
            <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND GetSettings.Discount_Formula_Pricing EQ 1 and Custom_RFP_Process EQ 0> <!--- GetSettings.Discount_Formula_Pricing EQ 1 --->
                <cfset biAnchor = '/Common_Files/contracts/Formula/Fixed_Formula_Items.cfm'>
                <cfset biText = 'formula' >
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                <cfset SetUpOption(  text = '#biText#'
                            , enabled = ((TabsClickable EQ 1 and (edit_program EQ 1 or getGeneralSettings.edit_basic_info EQ 1)))
                            , anchor = "href='#biAnchor#?CID=#EncryptedCID#'"
                            , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
            <!--- CUSTOM RFP --->
            <cfelseif Custom_RFP_Process EQ 1 and GetSettings.RFP_Process EQ 1>
                <cfset biAnchor = '/Common_Files/contracts/OPP/RFP_Form_Tabs.cfm'>
                <cfset biText = 'rfp form' >
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                <!--- ngt --->
                <cfset SetUpOption(  text = '#biText#'
                            , enabled = (cslgetcontractinfo.CONTRACT_STATUS_TYPE_IDX LT 3 AND DisAllowAccessBasedOnProfile eq 0) OR
                                        (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and (edit_program EQ 1 or getGeneralSettings.edit_basic_info EQ 1)))
                            , anchor = "href='#biAnchor#?CID=#EncryptedCID#'"
                            , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
            </cfif>


            <!--- Off-Invoice Tab --->
            <cfif GetSettings.Generic_Type IS "Distributor Off-Invoice">
                <cfsilent>
                        <CFSET CSL_ThisPageCode = "off-invoice">
                <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)>
                    <CFSET CSL_there = 1>
                <CFELSE>
                    <CFSET CSL_there = 0>
                </CFIF>

                <CFIF Off_Invoice.RecordCount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                </cfsilent>
                <cfset SetUpOption(  text = 'off-invoice'
                                , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1))
                                , anchor = "href='/Common_Files/contracts/off-invoice.cfm?CID=#EncryptedCID#'"
                                , dot_img = IMG_SRC )>
            </cfif>

    <!---TSF: Modification Bid Request--->
    <!--- Bid Request Tab --->
    <cfif TRIM(GetSettings.Generic_Type) EQ "Bid Request" and GetSettings.Discount_BidRequest EQ 1>
        <cfsilent>
        <CFSET CSL_ThisPageCode = "bid request">
        <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)>
            <CFSET CSL_there = 1>
        <CFELSE>
            <CFSET CSL_there = 0>
        </CFIF>

        <!---if the bid request has products then display the tab with the checkmark--->
        <CFIF BidStatus.recordcount EQ 0>
            <CFSET CSL_data = 0>
        <CFELSE>
            <CFSET CSL_data = 1>
        </CFIF>

        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
        <CFIF appSettings.getBidRequestComponentsOn()>
                <cfset bidrequestaction_page = "/Common_Files/contracts/bid_request/bid_request_Component.cfm">
                <cfelse>
                    <cfset bidrequestaction_page = "/Common_Files/contracts/bid_request/bid_request.cfm">
                </CFIF>
        </cfsilent>
        <cfset SetUpOption(  text = 'bid fixed price'
                        , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1))
                        , anchor = "href='#bidrequestaction_page#?CID=#EncryptedCID#'"
                        , dot_img = IMG_SRC )>
    </cfif>

    <!---  END Bid Request Tab --->
            <!--- fixed prices Tab --->
            <cfif (  appSettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR (GetDiscountIdentifier.Discount_Identifier_Number NEQ "GPO" AND GetDiscountIdentifier.Discount_Identifier_Number NEQ "CPA")   )  AND (  appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 0 OR GetSettings.Discount_Formula_Pricing EQ 0) AND (GetSettings.RFP_Process NEQ 1)>
                <CFIF GetSettings.Discount_Fixed_Prices EQ 1 and GetSettings.Fixed_Rebate_Grid_Option neq 1>
                    <cfsilent>
                    <CFSET CSL_ThisPageCode = "fixed_prices">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)>
                        <CFSET CSL_there = 1>
                    <CFELSE>
                        <CFSET CSL_there = 0>
                        <!--- 	used for busine s_rule_popup...url could not handle size of list...reset session var to keep things tidy--->
                        <cfset session.fix_Product_List = "">
                    </CFIF>
                    <CFSET CSL_data = 1><CFIF FixedPricesStatus.Recordcount EQ 0><CFSET CSL_data = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    </cfsilent>
                    <CFIF appSettings.getFixedcomponents_on()>
                        <cfset fixedaction_page = "/Common_Files/contracts/Contract_Discount_Fixed_Component.cfm">
                    <cfelse>
                        <cfset fixedaction_page = "/Common_Files/contracts/Contract_Discount_Fixed_Prices.cfm">
                    </CFIF>
                    <cfset SetUpOption(  text = lcase(Application.FixedPriceLabel)<!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                    , anchor = "href='#fixedaction_page#?CID=#EncryptedCID#'"
                                , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                </cfif>
            </cfif>
            <cfscript>
                oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");
                qAdminFee = oOPP.getAdminFeeCompIdList(CSL_Contract_Main_ID);
            </cfscript>
            <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR (GetDiscountIdentifier.Discount_Identifier_Number NEQ "GPO" AND GetDiscountIdentifier.Discount_Identifier_Number NEQ "CPA") OR (qAdminFee.recordcount GT 0)>
                <!--- rebates Tab --->
                <CFIF GetSettings.Discount_Rebates EQ 1 and (GetSettings.Fixed_Rebate_Grid_Option neq 1 or (GetSettings.Discount_Rebates_Group_Level eq 1 AND application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 0))>
                    <cfsilent>
                    <CFSET CSL_ThisPageCode = "rebates">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFSET CSL_data = 1><CFIF RebateStatus.Recordcount EQ 0><CFSET CSL_data = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    </cfsilent>
                    <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO" AND CSLGetContractInfo.Formula_Price_Rebate_Type EQ 1>
                        <cfoutput><cfsavecontent variable="vars.optionText">admin fee</cfsavecontent></cfoutput>
                    <cfelse>
                        <cfoutput><cfsavecontent variable="vars.optionText"><cfif TRIM(GetSettings.Generic_Type) EQ "Bid Request">proposal </cfif>#lcase(Application.RebateLabel)#</cfsavecontent></cfoutput>
                    </cfif>
                    <cfset SetUpOption(  text = vars.optionText
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                    , anchor = "onclick='customContainer()' href='/Common_Files/contracts/Contract_Discount_Rebates.cfm?CID=#EncryptedCID#'"
                                , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                </cfif>
            </cfif>
            <!---Fixed / Rebate Grid--->
            <cfif GetSettings.Fixed_Rebate_Grid_Option eq 1>
                <cfsilent>
                    <CFSET CSL_ThisPageCode = "fixed_rebate_grid">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)>
                        <CFSET CSL_there = 1>
                    <CFELSE>
                        <CFSET CSL_there = 0>
                    </CFIF>
                    <CFSET CSL_data = 1>
                    <CFIF FixedPricesStatus.Recordcount EQ 0 AND RebateStatus.Recordcount EQ 0>
                        <CFSET CSL_data = 0>
                    </CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">

                </cfsilent>
                <cfif request.settings.Program_Rate_Format is "Flex">
                    <cfset SetUpOption(  text = 'rates'
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                    , anchor = "href='/flex/Program/ContractMain.cfm?CID=#EncryptedCID#'"
                                , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                    <cfelse>
                    <cfset SetUpOption(  text = 'rates'
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                    , anchor = "href='/Programs/product/rate_main.cfm?CID=#EncryptedCID#'"
                                , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                </cfif>
            </cfif>
            <!--- lump sums Tab --->
            <CFIF GetSettings.Discount_Lump_Sums EQ 1>
                <cfsilent>
                <CFSET CSL_ThisPageCode = "lump_sums">
                <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                <CFSET CSL_data = 1><CFIF LumpStatus.Recordcount EQ 0><CFSET CSL_data = 0></CFIF>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                </cfsilent>
                <cfset SetUpOption(  text = lcase(Application.LumpsumLabel)
                                , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                , anchor = "href='/Common_Files/contracts/Contract_Discount_Lump_Sums.cfm?CID=#EncryptedCID#'"
                            , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
            </cfif>
                <!--- growth Tab --->
            <CFIF GetSettings.Discount_Growth EQ 1>
                <cfsilent>
                <CFSET CSL_ThisPageCode = "growth">
                <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                <CFSET CSL_data = 1><CFIF GrowthStatus.Recordcount EQ 0><CFSET CSL_data = 0></CFIF>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                </cfsilent>
                <cfset SetUpOption(  text = lcase(Application.GrowthLabel)<!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
                                , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                , anchor = "href='/Common_Files/contracts/Contract_Discount_Growth.cfm?CID=#EncryptedCID#'"
                            , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
            </cfif>
            <!--- Formula Pricing --->
            <CFIF GetSettings.Discount_Formula_Pricing EQ 99>  <!---  LEGACY --->
                <cfsilent>
                <CFSET CSL_ThisPageCode = "formula">
                <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                <CFSET CSL_data = 1><CFIF FormulaStatus.Recordcount EQ 0><CFSET CSL_data = 0></CFIF>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                </cfsilent>
                <cfset SetUpOption(  text = 'formula'
                                , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 and TabsAreActive EQ 1))
                                , anchor = "href='/Common_Files/contracts/Formula_Pricing_Index.cfm?CID=#EncryptedCID#'"
                            , dot_img = (disable_pages_in_rfa eq 1 ? '/images/programs/ball_gray_filled.gif' : IMG_SRC) )>
                </cfif>

                <!--- Date_Exclusions_tab --->
                <cfif GetSettings.Date_Exclusions_ON EQ 1>
                    <cfsilent>
                        <cfset useLakebaseForgetExclusioncount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_exclusions")>
<cfif useLakebaseForgetExclusioncount>
	<cftry>
		<cfset getExclusioncount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_exclusions", {
				"original_program_id" = "eq.#CSL_Contract_Main_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetExclusioncount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetExclusioncount>
<cfquery name="getExclusioncount" datasource="#application.datasource#">
                            SELECT *
                            FROM Program_Exclusions
                            WHERE Original_Program_ID = '#CSL_Contract_Main_ID#' AND Deleted = 0
                        </cfquery>
</cfif>
                    <cfset CSL_data = 0>
                    <cfif getExclusioncount.Recordcount GT 0><cfset CSL_data = 1></cfif>
                    <CFSET CSL_ThisPageCode = "pe">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    </cfsilent>
                    <CFIF (disable_pages_in_rfa EQ 0 AND TabsClickable EQ 1 and edit_program  EQ 1 AND  (Revision_Settings_Allowed eq 1 AND NOT(RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Date_Changes eq 2)))>
                            <cfif CSLGETCONTRACTINFO.IsExclusionRevision EQ 0>
                                <cfset SetUpOption(  text = 'date exclusions'
                                                , enabled = (true)
                                                , anchor = "href='/Common_Files/contracts/contract_exclusions.cfm?CID=#EncryptedCID#'"
                                                , dot_img = IMG_SRC )>
                            </cfif>

                    <cfelse>
                            <cfset SetUpOption(  text = 'date exclusions'
                                            , enabled = (false)
                                            , anchor = "href='##'"
                                            , dot_img = IMG_SRC )>
                    </CFIF>
                </cfif>
            <!--- Competitive info data tracking_tab --->
                <cfif GetSettings.Include_Competitive_Data_Tracking EQ 1>
                    <cfsilent>
                    <cfset CSL_data = 0>
                    <cfif CompetitiveDataStatus.recordcount GT 0><cfset CSL_data = 1></cfif>
                    <CFSET CSL_ThisPageCode = "ci">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    </cfsilent>
                    <!--- Dev Note: 12898; Milan --->
                    <CFIF TabsClickable EQ 1>
                        <cfset SetUpOption(  text = 'competitive data'
                                                            <!--- Show Competitive Data even after approval (Dev Note: Milan; D10697) --->
                                        , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                                        <!---, anchor = "href='/Common_Files/contracts/bid_request/competitive_data.cfm?CID=#EncryptedCID#'"--->
                                , anchor = "href='##' onClick='competitive_data()'"
                                        , dot_img = IMG_SRC )>
                    </cfif>
                </cfif>
            <cfsilent>
            <!--- Attachment Tab --->
            <CFQUERY NAME="Attachment_Count" DATASOURCE="#application.datasource#">
                SELECT 	*
                FROM	Contract_Attachments
                WHERE	(Program_ID = '#CSL_Contract_Main_ID#' OR  Program_Qualification_ID = '#CSL_Contract_Main_ID#')
                AND	Deleted=0
            </CFQUERY>

            <cfset qProgramClause = CreateObject("component", "components.clause_library.ClauseProgramManager").getAllProgramClause(CSL_Contract_Main_ID)>

            <CFSET CSL_ThisPageCode = "at,clause">
            <CFIF ListFindNoCase(CSL_ThisPageCode, CSL_CallingPageCode, ",")><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
            <!--- <CFIF Attachment_Count.RecordCount EQ 0 AND qProgramClause.RecordCount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF> --->
            <CFIF Attachment_Count.RecordCount GT 0 ><CFSET CSL_data = 1><CFELSE><CFSET CSL_data = 0></CFIF>
            <cfif DisAllowAccessBasedOnLockStatus EQ 1>
                <cfset CSL_data = 0>
            </cfif>
            <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
            </cfsilent>
            <!---D112591 - Ability to Add Comments When Uploading a Document
                If the Ability to Add Comments When Uploading a Document: setting is on then use the custom upload
            --->
            <cfset businessConsiderationReqDocUpload = appSettings.get_Setting("Business_Consideration_Req_Doc_Upload", 0)>
            <cfif businessConsiderationReqDocUpload>
                <cfset SetUpOption(  text = 'documents'
                                , enabled = (TabsClickable EQ 1)
                                , anchor = "href='/Common_Files/contracts/contract_attachments_custom.cfm?CID=#EncryptedCID#'"
                                , dot_img = IMG_SRC )>
            <cfelse>
                <cfset SetUpOption(  text = 'documents'
                                , enabled = (TabsClickable EQ 1)
                                , anchor = "href='/Common_Files/contracts/contract_attachments.cfm?CID=#EncryptedCID#'"
                                , dot_img = IMG_SRC )>
            </cfif>
            <!--- 5.0 fixed freight - start --->
            <cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight() eq 1
                    AND GetSettings.Freight_Program EQ 1
                    AND CSLGetContractInfo.Freight_Component_Type NEQ 0>

				<cfif CreateObject("component","components.freight.FreightBracketSetting").getFreightVersionItem()>
					<cfsilent>
					<cfquery name="getProgramFreight" datasource="#application.datasource#">
						SELECT 	top 1 Program_Freight_Version_CC_ID
						FROM 	Program_Freight_Version_CC
						WHERE 	Program_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
						AND 	Deleted = 0
					</cfquery>

					<cfset CSL_data = 0>
					<cfif getProgramFreight.Recordcount GT 0><cfset CSL_data = 1></cfif>
					<CFSET CSL_ThisPageCode = "freightPage">
					<CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
					<CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
					<cfset freightPageAvailable = 0 />
					<CFIF TabsClickable EQ 1 and Get_Profile_Settings.Freight_View_Create NEQ 0>
						<cfset freightPageAvailable = 1 />
					</CFIF>
					</cfsilent>
					<cfset SetUpOption(  text = 'freight'
									, enabled = (freightPageAvailable EQ 1 AND BestPlanLinkDisable EQ 0)
									, anchor = "href='/Common_Files/contracts/Freight/Program_Fixed_Freight_Rates_Display.cfm?CID=#EncryptedCID#'"
									, dot_img = IMG_SRC )>
				<cfelse>
					<cfsilent>
					<cfquery name="getProgramDistributorFreightCount" datasource="#application.datasource#">
						SELECT 	top 1 Program_Distributor_Freight_ID
						FROM 	Program_Distributor_Freight
						WHERE 	Program_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
						AND 	Deleted = 0
					</cfquery>
					<cfif getProgramDistributorFreightCount.Recordcount EQ 0>


<cfquery name="deleteTmpTables" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_dist_ibf') IS NOT NULL
	DROP TABLE ##tmp_dist_ibf

	IF OBJECT_ID('tempdb..##tmp_dist_bracket') IS NOT NULL
	DROP TABLE ##tmp_dist_bracket

	IF OBJECT_ID('tempdb..##tmp_dist') IS NOT NULL
	DROP TABLE ##tmp_dist
</cfquery>
						<cfstoredproc procedure = "Populate_Program_Distributor_Freight" dataSource="#application.datasource#">
							<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" value="#CSL_Contract_Main_ID#"  />
							<cfprocparam type="IN" CFSQLType="CF_SQL_BIT" value="0"  />
							<cfprocparam type="IN" CFSQLType="CF_SQL_VARCHAR" value=""  />
						</cfstoredproc>
						<cfquery name="getProgramDistributorFreightCount" datasource="#application.datasource#">
							SELECT 	top 1 Program_Distributor_Freight_ID
							FROM 	Program_Distributor_Freight
							WHERE 	Program_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
							AND 	Deleted = 0
						</cfquery>
					</cfif>

					<cfset CSL_data = 0>
					<cfif getProgramDistributorFreightCount.Recordcount GT 0><cfset CSL_data = 1></cfif>
					<CFSET CSL_ThisPageCode = "freightPage">
					<CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
					<CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
					<cfset freightPageAvailable = 0 />
					<CFIF TabsClickable EQ 1 and Get_Profile_Settings.Freight_View_Create NEQ 0 AND getProgramDistributorFreightCount.Recordcount GT 0 AND CSLGetContractInfo.Contract_Status_Type_IDX GT 1>
						<cfset freightPageAvailable = 1 />
					</CFIF>
					</cfsilent>
					<cfset SetUpOption(  text = 'freight'
									, enabled = (freightPageAvailable EQ 1 AND BestPlanLinkDisable EQ 0)
									, anchor = "href='/Common_Files/contracts/Freight/index.cfm?CID=#EncryptedCID#'"
									, dot_img = IMG_SRC )>
				</cfif>
            </cfif>
            <!--- 5.0 fixed freight - end --->

    <!--- D37372 Kraft Special Project - Program Qualificaitons START--->
    <cfif GetSettings.Enable_Program_Qualifications>
    <cfoutput><cfsavecontent variable="vars.qualifications">href="/Common_Files/contracts/qualifications.cfm?DisAllowAccessBasedOnLockStatus=#DisAllowAccessBasedOnLockStatus#&Program_ID=#CSL_Contract_Main_ID#" onClick="NewWindow(this.href,'help','850','600','Yes', 'Yes');return false;"</cfsavecontent></cfoutput>
    <cfset useLakebaseForhasQualifications = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_qualifications_info")>
<cfif useLakebaseForhasQualifications>
	<cftry>
		<cfset hasQualifications = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_qualifications_info", {
				"program_id" = "eq.#CSL_Contract_Main_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForhasQualifications = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForhasQualifications>
<cfquery name="hasQualifications" datasource="#application.datasource#" >
        SELECT *
        FROM Program_Qualifications_Info
        WHERE program_id = #CSL_Contract_Main_ID#
        AND deleted = 0
    </cfquery>
</cfif>
        <cfif hasQualifications.recordcount GT 0>
        <CFSET CSL_data = 1>
        <cfelse>
        <CFSET CSL_data = 0>
        </cfif>
        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
        <cfset SetUpOption(  text = 'qualifications'
                                , enabled =  (BestPlanLinkDisable EQ 0)
                                , anchor = vars.qualifications
                                , dot_img = IMG_SRC )>
    </cfif>
    <!--- D37372 Kraft Special Project - Program Qualificaitons END --->

        <!--- If pullbacks is On --->
        <cfparam name="CSLGetContractInfo.Pullback_Available" default="0">
        <cfif appSettings.getPullbacksOn() EQ 1>
                <cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
                <cfset bRecaptureComponentExists = programManager.getIsRecaptureOperatorOnForAnyProgramRebateComponent(CSL_Contract_Main_ID)>
            <!--- Dev Note(76989) - Recapture fpr multiple operator list --->
            <cfif appSettings.get_Setting('Recapture_By_Operator_For_Multiple_Lists') eq '1' AND GetSettings.Pullbacks_On EQ 1 AND GetSettings.generic_type EQ "Distributor Trade/Shelter"
                AND GetSettings.is_pullback_corporate_deal EQ 1 AND bRecaptureComponentExists EQ 1>
                <cfset bRecaptureOperatorPGExists =  PullbackManager.getRecaptureOperatorPGlistExists(CSLGetContractInfo.contract_number)>
                    <CFSET CSL_data = 1><CFIF bRecaptureOperatorPGExists EQ 0><CFSET CSL_data = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                        <cfset SetUpOption(  text = lcase(appsettings.getPullbackLabelLower())
                                        , enabled = Get_Profile_Settings.View_LH_Pane_Recapture_Link
                                        , anchor = "href='##' onClick=NewWindow('/Common_Files/contracts/Pullbacks/pullback_multiple_operator_list.cfm?CID=#EncryptedCID#&DisAllowAccessBasedOnLockStatus=#DisAllowAccessBasedOnLockStatus#','pullback_multiple_list','1020','870','Yes','No');"
                                        , dot_img = IMG_SRC )>
            <!--- If pullbacks On on the template and pullback from corporate is on and not a is corporate deal give an option to apply pullbacks. If pullbacks On on the template and is a corporate deal give an option to just view the pullback amounts --->
            <cfelseif Get_Profile_Settings.View_LH_Pane_Recapture_Link EQ 1>
                <cfsilent>
                    <CFSET CSL_ThisPageCode = "pullbacks">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFSET CSL_data = 1><CFIF CSLGetContractInfo.applied_pullbacks NEQ 1><CFSET CSL_data = 0></CFIF>
                </cfsilent>
                <CFIF
                    (GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and GetSettings.is_pullback_corporate_deal EQ 0 and GetSettings.pullback_from_corporate EQ 1)
                    OR
                    ((GetSettings.generic_type EQ "Operator Direct or HQ Programs" OR GetSettings.generic_type EQ "Operator-Deviated Pricing")
                    and GetSettings.Pullbacks_On EQ 1)>
                    <cfsilent><CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm"></cfsilent>
                    <cfset SetUpOption(  text = lcase(appsettings.getPullbackLabelLower())
                                    , enabled = (TabsClickable EQ 1 And qGetProfileTemplates.APPROVE EQ 1 And Get_Profile_Settings.Approve_Pullback EQ 0)
                                    , anchor = "href='/Common_Files/contracts/pullbacks/Pullback_Index.cfm?CID=#EncryptedCID#'"
                                    , dot_img = IMG_SRC )>
                <!--- Dev Note: CPM 10102: Added Check for where Pullbacks_On is on in the template. Pullback Menu option was displayed even when pullbacks where turned off in template.--->
                <cfelseif Get_Profile_Settings.Approve_Pullback EQ 1 AND GetSettings.is_pullback_corporate_deal EQ 1 and GetSettings.Pullbacks_On EQ 1  and GetSettings.generic_type EQ "Distributor Trade/Shelter"  and CSLGetContractInfo.Pullback_From_This_Program EQ 1>

                    <cfsilent>
                    <CFSET CSL_data = 1>
                    <CFIF CSLGetContractInfo.applied_pullbacks EQ 0>
                    <CFSET CSL_data = 0>
                    </CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    </cfsilent>
                    <cfset SetUpOption(  text = lcase(appsettings.getPullbackLabelLower())
                                    , enabled = (disable_pages_in_rfa EQ 0 AND (TabsClickable EQ 1 and edit_program  EQ 1 AND qGetProfileTemplates.APPROVE EQ 1 and TabsAreActive EQ 1))
                                    , anchor = "href='/Common_Files/contracts/pullbacks/Pullback_Index.cfm?CID=#EncryptedCID#&FromDistributor_Prg=1'"
                                    , dot_img = IMG_SRC )>
                </cfif>
            </cfif>
        </cfif><!--- If pullbacks is On --->

            <!---TSF: Volume Modification--->
            <cfsilent>
            <!---Volume--->
            <cfset hasVolume = 0 />
            <!------ Program_Volume is already loaded in thin contract general display ----->
            <cfif NOT isDefined("Program_Volume")>
                <CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
                <CFSET Program_Volume.Load_Basic_Information(CSL_Contract_Main_ID, request.AccessStructure.Company_Main_ID)>
                <cfset hasVolume = Program_Volume.isVolumeApplied() />
            <cfelse>
                <cfset hasVolume = Program_Volume.isVolumeApplied() />
            </cfif>
            <cfif hasVolume>
                <CFSET CSL_data = 1>
            <cfelse>
                <CFSET CSL_data = 0>
            </cfif>
            <CFSET CSL_there = 0>
            <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
            </cfsilent>
            <!--- 	ooooooooooooooooooooooooooooooooooooooooooo
                    Flag that says this is a LSAutoPay template
                    Set in Common_Queries.cfm 	bHideFromLSAutoPay
                    ooooooooooooooooooooooooooooooooooooooooooo	--->
        <!--- D45294 :: Added if condition --->
        <cfif CSLGetContractInfo.Contract_Status_Type_IDX GT 1>
            <cfparam name="CSL_Contract_Main_ID" default="">
            <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/contract_volume.cfm?Program_ID=#CSL_Contract_Main_ID#&action=display&showPrint=1" onClick="NewWindow(this.href,'help','850','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
            <cfset SetUpOption(  text = 'view volume'
                            , enabled = (TabsClickable EQ 1  AND NOT bHideFromLSAutoPay AND BestPlanLinkDisable EQ 0)
                            , anchor = vars.anchor
                                )>
        </cfif>
        <cfif GetSettings.Retailer_Info_On EQ 1>
            <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/contract_retailer_info.cfm?CID=#EncryptedCID#" onClick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
            <cfset SetUpOption(  text = 'retailer information'
                            , enabled = (BestPlanLinkDisable EQ 0)
                            , anchor = vars.anchor
                            , dot_img = IMG_SRC )>
        </cfif>

    <cfset Display_Budget_Option()>
    <cfif Get_Profile_Settings.View_LH_pane_Vertical_P_L EQ 1 AND GetSettings.ByPass_Margin_Evaluation neq "1">
    <tr><td nowrap><img border="0" src="/images/programs/ball_blue.gif" align="absmiddle"> <a href="##" onclick="verticalPNL(1)" class="#href_class#">vertical p&l</a></td></tr>  <!---  44017  --->
    </cfif>
    <cfif Get_Profile_Settings.View_LH_pane_What_If_P_L EQ 1>
    <tr><td nowrap><img border="0" src="/images/programs/ball_blue.gif" align="absmiddle"> <a href="##" onclick="verticalPNL(2)" class="#href_class#">what if p&l</a></td></tr>
    </cfif>
    <!---- D28354/Anand Rao/08-Nov-2011 - Bid Info page ---->
                <cfif GetSettings.display_bid_info_page EQ 1>
                    <cfsilent>
                    <cfset CSL_data = 0>
                    <cfif IsDefined("CompetitiveDataStatus")><cfif CompetitiveDataStatus.recordcount GT 0><cfset CSL_data = 1></cfif></cfif>
                    <CFSET CSL_ThisPageCode = "bidinfopage">
                    <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    </cfsilent>
                    <cfset SetUpOption(  text = 'bid info'
                                        , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                                        , anchor = "href='/Common_Files/contracts/bid_request/bid_info.cfm?CID=#EncryptedCID#'"
                                        , dot_img = IMG_SRC )>
                </cfif>


    <!--- END: D28354 --->



        <!--- sap references --->
        <CFIF appsettings.getSend_to_SAP() and CSLGetContractInfo.Contract_Status_Type_IDX GT 3>
            <cfsilent>
            <!--- Dev Note: KAL: D12719: SAP reference displays red dot but has reference number --->
            <cfset CSL_data = 1>
            <cfset CSL_there = 0>
            <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
            </cfsilent>
            <cfset SetUpOption(  text = 'sap reference numbers'
                            , enabled = (BestPlanLinkDisable EQ 0)
                            , anchor = "href='##' onClick='showSAPreferences('#CSLGetContractInfo.contract_main_id#')'"
                            , dot_img = IMG_SRC )>
        </cfif>
    <CFELSE><!--- Else for If = Do not show the tabs if CanEditProgram = 0 --->
        <cfset IMG_SRC = "/images/programs/ball_gray_filled.GIF">
        <cfset SetUpOption(  text = 'view program'
                        , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0 OR CSL_CallingPageCode IS "at" OR CSL_CallingPageCode IS "letters" OR  CSL_CallingPageCode IS "pullbacks" OR  CSL_CallingPageCode IS "ci" OR  CSL_CallingPageCode IS "freightPage" OR CSL_CallingPageCode IS "bidinfopage")
                        , anchor = "onclick='callSpinner();customContainer();' href='/Common_Files/contracts/contract_edit_menu.cfm?CID=#EncryptedCID#'" )>
        <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND (GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO" OR GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA")>
                <cfset SetUpOption(  text = 'modify'
                        , enabled = (false)
                        , anchor = "href='##'" )>

                <cfif CSLGetContractInfo.Contract_Status_Type_IDX GT 3 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO" AND CSLGetContractInfo.Formula_Price_Rebate_Type NEQ 1>    <!--- AND CSLGetContractInfo.Formula_Price_Rebate_Type EQ 1 --->

                    <cfset SetUpOption(  text = 'create admin fee'
                        , enabled = true
                        , anchor = "href='javascript: createAdminFee();'"
                        , dot_img = IMG_SRC )>
                    <cf_include files=#arrayToList(["/styles/css-loader.css"])#>
                    <script>
                    function createAdminFee()
                        {
                            show_loader('Creating Admin Fee Program...');
                            $.ajax({
                                            async: true
                                            ,data: {
                                                        contractId: <cfoutput>#CSL_Contract_Main_ID#</cfoutput>,
                                                        createdBy: 	<cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>,
                                                        method: "createAdminFee" }
                                            //,dataType: "json"
                                            ,success: function (data) {
                                            // console.log(data);
                                                window.location.href="/Common_Files/contracts/contract_edit_menu.cfm?CID=" + data;
                                                //$("div.loader").hide();
                                            }
                                            ,error: function (data) {
                                                alert('An error occurred.  ' + data );
                                                $("div.loader").hide();
                                            }
                                            ,type: "post"
                                            ,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
                                });

                        }
                    </script>
                </cfif>

            <cfelse>
                <cfset SetUpOption(  text = 'basic info'
                        , enabled = (false)
                        , anchor = "href='##'" )>
            </cfif>
        <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR (GetDiscountIdentifier.Discount_Identifier_Number NEQ "GPO" AND GetDiscountIdentifier.Discount_Identifier_Number NEQ "CPA")>
        <cfif GetSettings.Specify_Operators EQ 1>
            <cfset SetUpOption(  text = lcase(application.returned_customer_setting.operator_label_singular)
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <cfif GetSettings.Specify_Distributors EQ 1>
            <cfset SetUpOption(  text = lcase(application.returned_customer_setting.distributor_label_singular)
                            , enabled = (false)
                            , anchor = "href='##'" )>
        <cfelse>
            <cfif variables.bvendorOnlyProgram eq 1>
                <cfset SetUpOption(  text = lcase(variables.VendorLabel)
                                , enabled = (false)
                                , anchor = "href='##'" )>
            </cfif>
        </cfif>
        </cfif>
        <cfif GetSettings.Specify_Brokers EQ 1>
            <cfset SetUpOption(  text = lcase(application.returned_customer_setting.broker_label_singular)
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <cfif GetSettings.Generic_Type IS "Distributor Off-Invoice">
            <cfset SetUpOption(  text = 'off-invoice'
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <cfif GetSettings.Generic_Type IS "Bid Request" and GetSettings.Discount_BidRequest EQ 1>
            <cfset SetUpOption(  text = 'bid fixed price'
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <cfif GetSettings.Fixed_Rebate_Grid_Option EQ 1>
            <cfscript>
                objComponentManager	= CreateObject("component","mvc.Models.Program.Component.ComponentManager");
                bProgramWonLossEligible = objComponentManager.programWonLossEligible(Contract_Main_Id);

            </cfscript>
        <!---	<cfoutput>#DisAllowAccessBasedOnLockStatus# :: #CanEditProgram# :: #edit_program# :: #TabsAreActive# :: #GetSettings.Custom_Fixed_Price_Options# :: #bProgramWonLossEligible#</cfoutput>--->
            <cfif (DisAllowAccessBasedOnLockStatus EQ 0 AND CSLGetContractInfo.BidRequestStatusOn EQ 1)>
                <cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
                <cfset bidRequestObj = createObject("component", "components.programs.bid_request.BidRequestStatus")>
                <!---get bid request status--->
                <cfset qGetBidReqStatus = bidRequestManager.getStatus(Contract_Main_ID) />
                <cfset currStatusId = qGetBidReqStatus.Bid_Request_Status_ID />
                <cfif edit_program EQ 1 AND TabsAreActive EQ 1 AND
                            GetSettings.Custom_Fixed_Price_Options EQ 1 AND
                            bProgramWonLossEligible EQ false AND
                            DisAllowAccessBasedOnLockStatus EQ 0 AND
                            CSLGetContractInfo.BidRequestStatusOn EQ 1 AND
                            ((Program_Is_A_Revision gt 1 and CSLGetContractInfo.Contract_Status_Type_IDX lt 4)
                        OR (currStatusId eq 1 and CSLGetContractInfo.Contract_Status_Type_IDX eq 4 or CSLGetContractInfo.Contract_Status_Type_IDX eq 10)
                        OR (currStatusId eq 1 and CSLGetContractInfo.BidRequestStatusChangePgmStatus EQ 0 AND CSLGetContractInfo.Contract_Status_Type_IDX GT 4)
                        OR (appSettings.AllowBidStatusEditAnytime AND CSLGetContractInfo.Contract_Status_Type_IDX GT 2)
                        OR (appSettings.AllowBidStatusEditAnytime AND Program_Is_A_Revision))>
                    <cfif request.settings.Program_Rate_Format is "Flex">
                        <cfset SetUpOption(  text = 'rates'
                                        , enabled = (disable_pages_in_rfa EQ 0 AND BestPlanLinkDisable EQ 0 AND (edit_program  EQ 1 and TabsAreActive EQ 1))
                                        , anchor = "href='/flex/Program/ContractMain.cfm?CID=#EncryptedCID#'"
                                        , dot_img = IMG_SRC )>
                        <cfelse>
                        <cfset SetUpOption(  text = 'rates'
                                        , enabled = (disable_pages_in_rfa EQ 0 AND BestPlanLinkDisable EQ 0 AND (edit_program  EQ 1 and TabsAreActive EQ 1))
                                        , anchor = "href='/Programs/product/rate_main.cfm?CID=#EncryptedCID#'"
                                        , dot_img = IMG_SRC )>
                    </cfif>
                <cfelse>
                    <cfset SetUpOption(  text = 'rates'
                                , enabled = (false)
                                , anchor = "href='##'" )>
                </cfif>
            <cfelse>
                <cfset SetUpOption(  text = 'rates'
                                , enabled = (false)
                                , anchor = "href='##'" )>
            </cfif>

        </cfif>
        <cfif appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND GetSettings.Discount_Formula_Pricing EQ 1 and Custom_RFP_Process EQ 0>
            <cfset biAnchor = '/Common_Files/contracts/Formula/Fixed_Formula_Items.cfm'>

            <cfset SetUpOption(  text = 'formula'
                    , enabled =  ( DisAllowAccessBasedOnLockStatus EQ 0 )
                    , anchor = "href='#biAnchor#?CID=#EncryptedCID#'"
                    , dot_img = "/images/programs/ball_green.gif" )>

        <cfelseif Custom_RFP_Process EQ 1 and GetSettings.RFP_Process EQ 1>
            <!--- ngt --->
            <cfset biAnchor = '/Common_Files/contracts/OPP/RFP_Form_Tabs.cfm'>
            <cfset SetUpOption(  text = 'rfp form'
                            , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND (cslgetcontractinfo.CONTRACT_STATUS_TYPE_IDX gte 4))
                            , anchor = "href='#biAnchor#?CID=#EncryptedCID#'"
                            )>
        </cfif>
        <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') NEQ 1 OR (GetDiscountIdentifier.Discount_Identifier_Number NEQ "GPO" AND GetDiscountIdentifier.Discount_Identifier_Number NEQ "CPA")>
            <cfif GetSettings.Discount_Fixed_Prices EQ 1  and GetSettings.Fixed_Rebate_Grid_Option neq 1>
                <cfset SetUpOption(  text = lcase(Application.FixedPriceLabel)<!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
                                , enabled = (false)
                                , anchor = "href='##'" )>
            </cfif>
            <cfif GetSettings.Discount_Rebates EQ 1  and GetSettings.Fixed_Rebate_Grid_Option neq 1>
                <cfoutput><cfsavecontent variable="vars.optionText"><cfif TRIM(GetSettings.Generic_Type) EQ "Bid Request">proposal </cfif>#lcase(Application.RebateLabel)#</cfsavecontent></cfoutput>
                <cfset SetUpOption(  text = vars.optionText
                                , enabled = (false)
                                , anchor = "href='##'" )>
            </cfif>
        </cfif>
        <CFIF GetSettings.Discount_Lump_Sums EQ 1>
            <cfset SetUpOption(  text = lcase(Application.LumpsumLabel)
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <CFIF GetSettings.Discount_Growth EQ 1>
            <cfset SetUpOption(  text = lcase(Application.GrowthLabel)<!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <CFIF GetSettings.Discount_Formula_Pricing EQ 99> <!--- legacy --->
            <cfset SetUpOption(  text = 'formula'
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>
        <CFIF GetSettings.Include_Competitive_Data_Tracking EQ 1>
            <cfset SetUpOption(  text = 'competitive data'
                            , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                            <!---, anchor = "href='/Common_Files/contracts/bid_request/competitive_data.cfm?CID=#EncryptedCID#'"--->
                        , anchor = "href='##' onClick='competitive_data()'"
                            , dot_img = IMG_SRC )>
        </cfif>
        <cfif GetSettings.Date_Exclusions_ON EQ 1 AND CSLGETCONTRACTINFO.IsExclusionRevision EQ 0>
            <cfset SetUpOption(  text = 'date exclusions'
                            , enabled = (false)
                            , anchor = "href='##'" )>
        </cfif>

    <!--- Attachment Tab --->
    <CFQUERY NAME="Attachment_Count" DATASOURCE="#application.datasource#">
        SELECT 1
        FROM Contract_Attachments
        WHERE (Program_ID = '#CSL_Contract_Main_ID#' OR  Program_Qualification_ID = '#CSL_Contract_Main_ID#')
            AND Deleted=0
    </CFQUERY>
    <cfset CSL_There = 0>
    <cfset CSL_data = ( Attachment_Count.RecordCount gt 0 ? 1 : 0 )>
    <cfif DisAllowAccessBasedOnLockStatus EQ 1>
        <cfset CSL_data = 0>
    </cfif>
    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
    <cfset SetUpOption2(  text = 'documents'
                        , enabled1 = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0 and (request.letters_available eq 1 OR request.letters_available eq 2) and (GetSettings.operator_letters_required EQ 1 OR GetSettings.distributor_letters_required EQ 1) and CSLGetContractInfo.Contract_Status_Type_IDX GT 3)
                        , anchor1 = "href='/Common_Files/contracts/contract_letters.cfm?CID=#EncryptedCID#'"
                        , enabled2 = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                        , anchor2 = "href='/Common_Files/contracts/contract_attachments.cfm?CID=#EncryptedCID#'"
                        , dot_img = IMG_SRC )>

    <!--- D44850  Green / Red / Gray
    <!--- D37372 Kraft Special Project - Program Qualificaitons START --->
    <cfif GetSettings.Enable_Program_Qualifications>
        <cfset SetUpOption(  text = 'qualifications'
                        , enabled = (false)
                        , anchor = "href='##'" )>
    </cfif>
    <!---  D37372 Kraft Special Project - Program Qualificaitons END --->
    --->

    <cfif GetSettings.Enable_Program_Qualifications>
        <cfoutput><cfsavecontent variable="vars.qualifications">href="/Common_Files/contracts/qualifications.cfm?DisAllowAccessBasedOnLockStatus=#DisAllowAccessBasedOnLockStatus#&Program_ID=#CSL_Contract_Main_ID#" onClick="NewWindow(this.href,'help','850','600','Yes', 'Yes');return false;"</cfsavecontent></cfoutput>
        <cfquery name="hasQualifications" datasource="#application.datasource#" >
            SELECT *
            FROM Program_Qualifications_Info
            WHERE program_id = #CSL_Contract_Main_ID#
            AND deleted = 0
        </cfquery>
        <cfif hasQualifications.recordcount GT 0>
            <CFSET CSL_data = 1>
        <cfelse>
            <CFSET CSL_data = 0>
        </cfif>
        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
        <cfset SetUpOption(  text = 'qualifications'
                                , enabled =  ( BestPlanLinkDisable EQ 0 )
                                , anchor = vars.qualifications
                                , dot_img = IMG_SRC )>
    </cfif>

        <!--- If pullbacks is On --->
        <cfif appSettings.getPullbacksOn() EQ 1>
                <cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
                <cfset bRecaptureComponentExists = programManager.getIsRecaptureOperatorOnForAnyProgramRebateComponent(CSL_Contract_Main_ID)>
            <!--- Dev Note(76989) - Recapture fpr multiple operator list --->
            <cfif appSettings.get_Setting('Recapture_By_Operator_For_Multiple_Lists') eq '1' AND GetSettings.Pullbacks_On EQ 1 AND GetSettings.generic_type EQ "Distributor Trade/Shelter"
                AND GetSettings.is_pullback_corporate_deal EQ 1 AND bRecaptureComponentExists EQ 1>

                <cfset bRecaptureOperatorPGExists =  PullbackManager.getRecaptureOperatorPGlistExists(CSLGetContractInfo.contract_number)>
                    <CFSET CSL_data = 1><CFIF bRecaptureOperatorPGExists EQ 0><CFSET CSL_data = 0></CFIF>
                    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    <cfset SetUpOption(  text = lcase(appsettings.getPullbackLabelLower())
                                    , enabled = Get_Profile_Settings.View_LH_Pane_Recapture_Link
                                    , anchor = "href='##' onClick=NewWindow('/Common_Files/contracts/Pullbacks/pullback_multiple_operator_list.cfm?CID=#EncryptedCID#&DisAllowAccessBasedOnLockStatus=#DisAllowAccessBasedOnLockStatus#','pullback_multiple_list','1020','870','Yes','No');"
                                    , dot_img = IMG_SRC )>
            <cfelseif Get_Profile_Settings.View_LH_Pane_Recapture_Link EQ 1>
            <CFSET CSL_data = 0>
            <cfset CSL_There = 0>
            <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                <cfif CSLGetContractInfo.Contract_Status_Type_IDX GT 3>
                    <cfset SetUpOption2(  text = lcase(appsettings.getPullbackLabelLower())
                                        , enabled1 = (Get_Profile_Settings.Approve_Pullback EQ 1 AND BestPlanLinkDisable EQ 0 AND ((GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.is_pullback_corporate_deal EQ 0 and GetSettings.pullback_from_corporate EQ 1) OR (GetSettings.generic_type EQ "Operator Direct or HQ Programs") OR (GetSettings.generic_type EQ "Operator-Deviated Pricing")) and qGetProfileTemplates.approve EQ 1)
                                        , anchor1 = "href='/Common_Files/contracts/pullbacks/Pullback_Index.cfm?CID=#EncryptedCID#'"
                                        , enabled2 = (Get_Profile_Settings.Approve_Pullback EQ 1 AND BestPlanLinkDisable EQ 0 AND GetSettings.is_pullback_corporate_deal EQ 1 and GetSettings.generic_type EQ "Distributor Trade/Shelter" and qGetProfileTemplates.approve EQ 1)
                                        , anchor2 = "href='/Common_Files/contracts/pullbacks/Pullback_Index.cfm?CID=#EncryptedCID#&FromDistributor_Prg=1'"
                                        , dot_img = IMG_SRC )>
                <cfelse>
                    <cfset SetUpOption(  text = lcase(appsettings.getPullbackLabelLower())
                                    , enabled = (false)
                                    , anchor = "href='##'" )>
                </cfif>
                <!---Doesn't show grayed out if app setting is off --->
            </cfif>
        </cfif>
        <!--- If pullbacks is On --->

        <!--- 5.0 fixed freight - start --->
        <cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getShow_Fixed_Freight() eq 1
                AND GetSettings.Freight_Program EQ 1
                AND CSLGetContractInfo.Freight_Component_Type NEQ 0>
            <cfset freightPageAvailable = 0 />
            <cfif DisAllowAccessBasedOnLockStatus EQ 0>
                <cfset freightPageAvailable = 1 />
            </CFIF>
            <cfoutput>
            <cfif freightPageAvailable eq 1 AND BestPlanLinkDisable EQ 0>

                <cfset freightURL = "/Common_Files/contracts/Freight/index.cfm?CID=#EncryptedCID#" />
                <cfif CreateObject("component","components.freight.FreightBracketSetting").getFreightVersionItem()>
                	<cfset freightURL = "/Common_Files/contracts/Freight/Program_Fixed_Freight_Rates_Display.cfm?CID=#EncryptedCID#" />

					<cfquery name="getProgramDistributorFreightCount" datasource="#application.datasource#">
						SELECT 	top 1 Program_Freight_Version_CC_ID
						FROM 	Program_Freight_Version_CC
						WHERE 	Program_ID = '#CSL_Contract_Main_ID#' AND Deleted = 0
					</cfquery>
                <cfelse>
					<cfquery name="getProgramDistributorFreightCount" datasource="#application.datasource#">
						SELECT 	top 1 Program_Distributor_Freight_ID
						FROM 	Program_Distributor_Freight
						WHERE 	Program_ID = '#CSL_Contract_Main_ID#' AND Deleted = 0
					</cfquery>
				</cfif>


                <cfset CSL_data = 0>
                <cfif getProgramDistributorFreightCount.Recordcount GT 0><cfset CSL_data = 1></cfif>
                <CFSET CSL_ThisPageCode = "freightPage">
                <CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                <cfset SetUpOption(  text = 'freight'
                                , enabled = (BestPlanLinkDisable EQ 0)
                                , anchor = "href='#freightURL#'"
                                , dot_img = IMG_SRC )>
            <cfelse>
                <cfset SetUpOption(  text = 'freight'
                                , enabled = (false)
                                , anchor = "href='##'")>
            </cfif>
            </cfoutput>
        </cfif>
        <!--- 5.0 fixed freight - end --->

    <!---TSF: Volume Modification--->
    <cfsilent>
    <!---Volume--->
    <cfset hasVolume = 0 />
    <!------ Program_Volume is already loaded in thin contract general display ----->
    <!--- D44850  Green / Red / Gray
    <cfif NOT isDefined("Program_Volume")>
        <CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
        <CFSET Program_Volume.Load_Basic_Information(CSL_Contract_Main_ID, request.AccessStructure.Company_Main_ID)>
        <cfset hasVolume = Program_Volume.isVolumeApplied() />
    <cfelse>
        <cfset hasVolume = Program_Volume.isVolumeApplied() />
    </cfif>
    <cfif hasVolume>
        <CFSET CSL_data = 1>
    <cfelse>
        <CFSET CSL_data = 0>
    </cfif>
    --->
    <CFSET CSL_there = 0>
    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
    </cfsilent>
        <!--- D45294 :: Added if condition --->
        <cfif CSLGetContractInfo.Contract_Status_Type_IDX GT 1>
    <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/contract_volume.cfm?Program_ID=#CSL_Contract_Main_ID#&action=display&showPrint=1" onClick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'view volume'
                    , enabled = (BestPlanLinkDisable EQ 0)
                    , anchor = vars.anchor
                    , dot_img =  '/images/programs/ball_blue.gif')>
        </cfif>
    <cfif GetSettings.Retailer_Info_On EQ 1>
        <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/contract_retailer_info.cfm?CID=#EncryptedCID#&action=display&showPrint=1" onClick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'retailer information'
                        , enabled = (BestPlanLinkDisable EQ 0)
                        , anchor = vars.anchor
                        , dot_img = '/images/programs/ball_blue.gif' )>
    </cfif>


    <!---- Budget display ---->
    <cfset Display_Budget_Option()>
    <!--- <tr><td nowrap><img border="0" src="/images/programs/ball_blue.gif" align="absmiddle"> <a href="##" onclick="verticalPNL(1)" class="#href_class#">vertical p&l</a></td></tr>   44017
    <tr><td nowrap><img border="0" src="/images/programs/ball_blue.gif" align="absmiddle"> <a href="##" onclick="verticalPNL(2)" class="#href_class#">what if p&l</a></td></tr> --->


    <!---- Claim rates display ---->
    <cfif programManager.getProgramIncludeInReport(
            approved = CSLGetContractInfo.approved,
            genericType = GetSettings.generic_type,
            cancelled = CSLGetContractInfo.manual_cancel,
            report_type = 1,
            IncludeInReport = CSLGetContractInfo.Include_Claim_Rates_Report
            )>
        <CFSET CSL_data = 1>
        <CFSET CSL_there = 0>
        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
        <cfoutput><cfsavecontent variable="vars.anchor">href="/reportwriter/program_claim_rates_report.cfm?Program_ID=#CSL_Contract_Main_ID#&Report_Type=1" onClick="NewWindow(this.href,'program_claim_rates','900','600','Yes', 'Yes');return false;" id="claim_rates_within_program"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'claim rates'
                        , enabled = ( val(GetSettings.Claim_Rates_Config_Id) gt 0 AND BestPlanLinkDisable EQ 0)     <!---38460--->
                        , anchor = vars.anchor
                        )>
    </cfif>
    <!---- Claim rates display ---->

    <!---- pricing report display ---->
    <cfif programManager.getProgramIncludeInReport(
            approved = CSLGetContractInfo.approved,
            genericType = GetSettings.generic_type,
            cancelled = CSLGetContractInfo.manual_cancel,
            report_type = 2,
            IncludeInReport = CSLGetContractInfo.Include_Pricing_Report
            )>
        <CFSET CSL_data = 1>
        <CFSET CSL_there = 0>
        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
        <cfoutput><cfsavecontent variable="vars.anchor">href="/reportwriter/program_claim_rates_report.cfm?Program_ID=#CSL_Contract_Main_ID#&Report_Type=2" onClick="NewWindow(this.href,'program_pricing','600','500','Yes', 'Yes');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'pricing'
                        , enabled = ( BestPlanLinkDisable EQ 0 )
                        , anchor = vars.anchor
                        , dot_img = IMG_SRC )>
    </cfif>
    <!---- pricing report display ---->

    <!--- view approved margins only for standard approval --->
            <!--- 	ooooooooooooooooooooooooooooooooooooooooooo
                    Flag that says this is a LSAutoPay template
                    Set in Common_Queries.cfm 	bHideFromLSAutoPay
                    ooooooooooooooooooooooooooooooooooooooooooo	--->
    <cfif (Get_Profile_Settings.program_margin_approval_method EQ 7 OR Get_Profile_Settings.program_margin_approval_method EQ 5) AND NOT bHideFromLSAutoPay>
        <CFIF Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Approved_Margins EQ 1>
            <cfif custom_rfp_process eq 0>
                <cfoutput><CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                    <cfif CSLGetContractInfo.Contract_Status_Type_IDX GT 3>
                        <cfset approvedMarginDataStatus = programManager.setApprovedMarginData(#CSL_Contract_Main_ID#) >
                        <TR>
                            <TD NOWRAP><IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
                            <A STYLE="cursor:pointer;" ONCLICK="viewapprovedmargins()" CLASS="#HREF_Class#">approved margins</A></TD>
                        </TR>
                    </cfif>
                </cfoutput>
            </cfif>
        </CFIF>
    </cfif>

    <cfoutput>
        <cfif Get_Profile_Settings.View_LH_pane_Vertical_P_L EQ 1 AND BestPlanLinkDisable EQ 0 AND GetSettings.ByPass_Margin_Evaluation neq "1">
            <tr><td nowrap><img border="0" src="/images/programs/ball_blue.gif" align="absmiddle"> <a href="##" onclick="verticalPNL(1)" class="#href_class#">vertical p&l</a></td></tr>
        </cfif>
        <cfif DisAllowAccessBasedOnLockStatus neq 1 AND Get_Profile_Settings.View_LH_pane_What_If_P_L EQ 1>
            <tr><td nowrap><img border="0" src="/images/programs/ball_blue.gif" align="absmiddle"> <a href="##" onclick="verticalPNL(2)" class="#href_class#">what if p&l</a></td></tr>
        </cfif>
    </cfoutput>


    <!---- D28354/Anand Rao/08-Nov-2011 - Bid Info page ---->
    <cfif GetSettings.display_bid_info_page EQ 1>
            <cfset SetUpOption(  text = 'bid info'
                            , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                            , anchor = "href='/Common_Files/contracts/bid_request/bid_info.cfm?CID=#EncryptedCID#'"
                            , dot_img = IMG_SRC )>
    </cfif>
    <!---- ENDS: D28354 --->

    <!---- Tim Ford - Label 42349: MFN Display START ---->
    <cfset objProgramMFN = createObject("component", "components.programs.ProgramMostFavoredNation") />
    <cfset qGetMFNData = objProgramMFN.getMFNData(CSLGetContractInfo.contract_main_id) />

    <cfif qGetMFNData.RecordCount and CSLGetContractInfo.Contract_Status_Type_IDX GT 3>
    <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/most_favored_nation_display.cfm?programId=#CSLGetContractInfo.contract_main_id#" onClick="NewWindow(this.href,'most_favored_nation_display','900','600','Yes', 'Yes');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'mfn data'
                        , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                        , anchor = vars.anchor
                        , dot_img = IMG_SRC )>
    </cfif>
    <!---- Tim Ford - Label 42349: MFN Display END ---->

    <!--- sap references --->
    <cfoutput>
    <cfsilent>
    <!--- Dev Note: KAL: D12719: SAP reference displays red dot but has reference number --->
    <cfset CSL_data = 1>
    <cfset CSL_there = 0>
    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
    </cfsilent>
        <TR>
            <TD NOWRAP>
            <CFIF appsettings.getSend_to_SAP() and CSLGetContractInfo.Contract_Status_Type_IDX GT 3>
            <A STYLE="cursor:pointer;" ONCLICK="showSAPreferences('#CSLGetContractInfo.contract_main_id#',1)" CLASS="#HREF_Class#"><IMG BORDER="0" SRC="#IMG_SRC#" ALIGN="absmiddle"></A>
            <A STYLE="cursor:pointer;" ONCLICK="showSAPreferences('#CSLGetContractInfo.contract_main_id#',1)" CLASS="#HREF_Class#">sap references</A></TD>
            <CFELSEIF appSettings.getERP_Deal_ID_PopUp() AND CSLGetContractInfo.Contract_Status_Type_IDX GT 2 AND (CSLGetContractInfo.Sent_To_External_Client EQ 1 OR CSLGetContractInfo.error_from_external_client EQ 1)>
            <A STYLE="cursor:pointer;" ONCLICK="showSAPreferences('#CSLGetContractInfo.contract_main_id#',2)" CLASS="#HREF_Class#"><IMG BORDER="0" SRC="#IMG_SRC#" ALIGN="absmiddle"></A>
            <A STYLE="cursor:pointer;" ONCLICK="showSAPreferences('#CSLGetContractInfo.contract_main_id#',2)" CLASS="#HREF_Class#">sap references</A>
            </CFIF>
            </TD>
        </TR>
    </cfoutput>
    <!------ DEV NOTE DRK D9455: edit sap id ----->
    <!------ If program is approved ----->
    <CFIF CSLGetContractInfo.Contract_Status_Type_IDX GT 3>
        <!------ if post approval status is on, and post approval status <> 1 ----->
        <cfif appSettings.getPgmPostApprovalStatus() and appSettings.getPgmPostApprovalStatusType() NEQ 1>
            <cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
            <!------ check if this program can have program reference number edit ----->
            <cfset qGetTemplateProgramPostApprovalStatus1 = ProgramPostApprovalStatusManager.getSelectedTemplateProgramPostApprovalStatus
                        (templateId = CSLGetContractInfo.programtype_id,
                        programPostApprovalStatusId = 1) />
            <cfset qGetTemplateProgramPostApprovalStatus2 = ProgramPostApprovalStatusManager.getSelectedTemplateProgramPostApprovalStatus
                        (templateId = CSLGetContractInfo.programtype_id,
                        programPostApprovalStatusId = 2) />
            <cfset postApprovalStatusReferneceNumberEdit = 0 />
            <cfif qGetTemplateProgramPostApprovalStatus1.recordCount OR qGetTemplateProgramPostApprovalStatus2.recordCount>
                <cfset postApprovalStatusReferneceNumberEdit = 1 />
            </cfif>
            <!------ whether this program has post approval status = 1 and 2, and thus enable program reference id edit ----->
            <cfif postApprovalStatusReferneceNumberEdit>
                <cfsilent>
                <cfset TabsClickable = 1 />
                <cfset TabsClickableMessage = "" />
                <cfset programPostApprovalStatus2Desc = ProgramPostApprovalStatusManager.getProgramPostApprovalStatusDesc(statusId=2) />
                <!------ If the current user do not have access to edit status = 2 ----->
                <cfif ProgramPostApprovalStatusManager.getProfileProgramPostApprovalStatusChangeAccess(request.AccessStructure.Profiles_ID, 2) NEQ 1>
                    <cfset TabsClickable = 0 />
                    <cfset TabsClickableMessage = "You do not have access to edit '#programPostApprovalStatus2Desc#' status" />
                <cfelseif DisAllowAccessBasedOnLockStatus NEQ 0><!------ if program is not locked ----->
                    <cfset TabsClickable = 0 />
                    <cfset TabsClickableMessage = "Program need to be locked" />
                </cfif>
                <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
                </cfsilent>
                <cfset SetUpOption(  text = left(LCase(application.returned_customer_setting.reference_number_label),20)
                                , enabled = (TabsClickable AND BestPlanLinkDisable EQ 0)
                                , anchor = "href='##' onClick='showProgramRefNumberEdit()'"
                                , dot_img = IMG_SRC )>
                </cfif><!------ whether this program has post approval status = 1 and 2, and thus enable program reference id edit ----->
        </cfif><!------ if post approval status is on, and post approval status <> 1 ----->
    </CFIF><!------ If program is approved ----->

    </CFIF><!--- End Else for If = Do not show the tabs if CanEditProgram = 0 --->


    <cfif CSL_CallingPageCode EQ "sys">
        <CFSET CSL_there = 1>
        <CFSET CSL_data = 1>
        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
    </cfif>

    <cfif GetSettings.Sysco_report_on EQ 1>
        <cfset SetUpOption(  text = 'sysco report'
                        , enabled = (CSLGetContractInfo.Contract_contains_Sysco EQ 1 AND BestPlanLinkDisable EQ 0 AND isContractCurrentlyLocked.Contract_Is_Locked EQ 1 and Get_Profile_Settings.Approve_Sysco_Deals)
                        , anchor = "href='/common_files/contracts/sysco_deal_sheet/sysco_report_form.cfm?CID=#EncryptedCID#'" )>
    </cfif>



    <!---- Tim Ford - Label 48049: Count / Dont Count Volume based on Program Component START ---->
    <!--- only display if the setting is on for the template and application --->
    <cfif GetSettings.BB_Dont_Count_Volume_Select EQ 1 and appSettings.getAllow_BB_Dont_Count_From_Program() NEQ 0>
    <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/volume_dont_count.cfm?programId=#CSLGetContractInfo.contract_main_id#" onClick="NewWindow(this.href,'Volume_Count_Dont_Count','900','600','Yes', 'Yes');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'volume override'
                        , enabled = (BestPlanLinkDisable EQ 0 and (FixedPricesStatus.Recordcount NEQ 0 or RebateStatus.Recordcount NEQ 0))
                        , anchor = vars.anchor)>
    </cfif>
    <!---- Tim Ford - Label 48049: Count / Dont Count Volume based on Program Component END ---->

    <!---- Retro Scheduler START ---->
    <!--- only display if the setting is on for the template and application --->
    <cfif CSLGetContractInfo.Contract_Status_Type_IDX GT 3 and appSettings.get_setting('Margin_Display_Style') EQ "CUSTOM_T" and GetSettings.Discount_Formula_Pricing EQ 1>
    <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/Formula/Formula_Retro_Scheduler.cfm?Program_ID=#CSLGetContractInfo.contract_main_id#" onClick="NewWindow(this.href,'retro_scheduler','900','600','Yes', 'Yes');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'retro scheduler'
                        , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 )
                        , anchor = vars.anchor)>
    </cfif>
    <!---- Retro Scheduler END ---->

    <!---
    D50074 :: Viewing and Editing prior program versions
    Added below IF condition to Hide second section of links if user editing program using Modify porgram link in revision history.
    --->
    <cfif ModifyDeletedPrograms EQ 0>

    <cfif (CSL_CallingPageCode IS "viewcontract")>
    <cfsavecontent variable = "var">
        <CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
    </cfsavecontent>
    <!--- Keeps all of the logic to generate email and faxes --->
        <CFINCLUDE TEMPLATE="email_fax_handler.cfm">
        <!--- Keeps all of the logic to generate email and faxes --->

        <cfset CHECKFORREVISION = QueryNew("Contract_Main_ID")>
        <!--- encrypt the contract main ID --->
        <cf_cryp	type = "en" string = "#filename_email#" key = "#request.key#">
        <CFSET Program_Number=cryp.value>
    <cfelse>
        <CFSET Program_Number=''>
    </cfif>

    <cfsilent>
    <cfset APVL_Contract_Status = CSLGetContractInfo.Contract_Status_Type_IDX>
    <CFIF IsProgramTemplateAvailable EQ 1 AND (CSL_CallingPageCode IS "viewcontract")>
        <CFSET Print_Button_Show 	= 1>
        <CFSET Fax_Button_Show 	 	= 0>
        <CFSET Email_Button_Show 	= 1>
    <CFELSE>
        <CFIF DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "viewcontract")>
            <cfif (NOT (appSettings.getDeleteIsCancelAutoRenew() AND CSLGetContractInfo.Is_AutoRenew EQ 1) AND Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1) OR Get_Profile_Settings.Delete_Program_Access EQ 1>
                <CFSET Delete_Button_Show 	= 1>
            </cfif>
        </CFIF>
    </CFIF>

    <CFSET WIP_Kickback_Show	= 0>

    <!--- show when the contract is a WIP or RFA --->
        <CFIF APVL_Contract_Status GTE 1 AND APVL_Contract_Status LTE 2 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "viewcontract")>
            <CFSET Print_Button_Show 	= 1>
            <CFSET Fax_Button_Show 	 	= 0>
            <CFSET Email_Button_Show 	= 1>
            <CFIF DisAllowAccessBasedOnProfile EQ 0>
                <CFSET Renew_Button_Show 	= 1>
            </CFIF>
            <!--- kickback button --->
            <CFIF APVL_Contract_Status EQ 2>
                <CFSET WIP_Kickback_Show	= 1>
            </CFIF>
            <!--- based on the locked status --->
            <CFIF DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "viewcontract")>
                <cfif (NOT (appSettings.getDeleteIsCancelAutoRenew() AND CSLGetContractInfo.Is_AutoRenew EQ 1) AND Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 1) OR Get_Profile_Settings.Delete_Program_Access EQ 1>
                    <CFSET Delete_Button_Show 	= 1>
                </cfif>
            </CFIF>
        </CFIF>

        <CFIF IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnPosition EQ 0 AND CSL_CallingPageCode IS "viewcontract">
                <CFSET History_Button_Show 	= 1>
        </CFIF>

    <!--- when the contract is post approval the print button is shown to those who are in the approval tree or have positions matching the distributors and / or brokers --->
        <CFIF APVL_Contract_Status GTE 3 AND (APVL_Contract_Status LTE 8 Or APVL_Contract_Status EQ 10) AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "viewcontract")>
            <!--- If user has access to program, enable copy  and rollover links --->
            <CFIF DisAllowAccessBasedOnProfile EQ 0>
                <CFSET Renew_Button_Show 	= 1>
                <CFSET RollOver_Button_Show	= 1>
            </CFIF>
            <CFIF DisAllowAccessBasedOnPosition EQ 0>
                <CFIF DisAllowAccessBasedOnProfile EQ 0>
                    <CFSET Revise_Button_Show 	= 1>
                </CFIF>

                <!--- if the contract has expired --->
                <cfset allow_parent_revise = 0>
                <cfif GetSettings.Date_Exclusions_ON EQ 1>
                <cfquery name="checkifdateexclusionisactive" datasource="#application.datasource#">
                select contract_main_id
                from contract_main
                inner join program_exclusions on
                program_exclusions.revision_program_id = contract_main.contract_main_id
                where program_exclusions.original_program_id = '#CSLGetContractInfo.contract_main_id#'
                and program_exclusions.deleted = 0
                and contract_main.deleted = 0
                and contract_main.contract_status_type_idx > 4 and contract_main.contract_status_type_idx < 7
                </cfquery>

                <cfif checkifdateexclusionisactive.recordcount GT 0>
                    <cfset allow_parent_revise = 1>
                </cfif>
                </cfif>
                <CFIF APVL_Contract_Status EQ 7 and allow_parent_revise EQ 0>
                    <CFIF CSLGetContractInfo.Manual_Cancel EQ 1 AND CSLGetContractInfo.Cancel_And_End_Dated EQ 0 AND Get_Profile_Settings.Delete_Program_Access EQ 1 AND PaymentHistoryManager.getPaymentHistoryExist(CSLGetContractInfo.contract_number) eq 0 AND programManager.bProgramHasBillback(CSL_Contract_Main_ID) eq false>
                        <CFSET Purge_Button_Show 	= 1>
                    </CFIF>

                    <cfif appSettings.Renew_expired_programs IS 1>
                        <CFSET Revise_Button_Show 	= 0 />
                        <!------ check if revision settings values ----->
                        <cfif not RevisionSettings.RecordCount>
                            <cfset Revise_Button_Show 	= 1>
                        <cfelse>
                            <cfif RevisionSettings.End_Date_Revision_Not_Eligibile EQ 0 OR (DateDiff("d", CSLGETCONTRACTINFO.Contract_End_Date, Now()) LTE RevisionSettings.End_Date_Revision_Not_Eligibile_Days)>
                                <CFSET Revise_Button_Show 	= 1>
                            </cfif>
                        </cfif>
                    <cfelse>
                        <CFSET Revise_Button_Show 	= 0>
                    </CFIF>

                </CFIF>

                <CFIF Get_Profile_Settings.Delete_Program_Access EQ 1>
                    <CFSET Cancel_Button_Show 	= 1>
                </CFIF>

                <CFIF CSLGetContractInfo.revision_not_allowed EQ 1>
                    <CFSET Revise_Button_Show 	= 0>
                </CFIF>

                <!--- if the program is a revision do not show the renew button --->

                <CFIF Program_Is_A_Revision EQ 1 AND APVL_Contract_Status EQ 4>
                    <!--- <CFSET Renew_Button_Show 	= 0>	 --->
                    <CFSET RollOver_Button_Show = 0>
                </CFIF>
                    <!---Checks to see if there's an active or expiring version--->
            <cfquery name="checkforpreactiverevisions" datasource="#application.datasource#">
                SELECT ISNULL(max(Contract_Main.contract_main_id),0) as contract_main_id
                FROM Contract_Main
                WHERE contract_number  = '#CSLGetContractInfo.contract_number#'
                and deleted = 0
                and force_expiration_flag = 0
                and (contract_status_type_idx = 4)
                <cfif GetSettings.Date_Exclusions_ON EQ 1>
                and contract_main_id not in (select revision_program_id from
                program_exclusions inner join contract_main on contract_main.contract_main_id =
                program_exclusions.revision_program_id where contract_main.contract_number  = '#CSLGetContractInfo.contract_number#')
                </cfif>
            </cfquery>

            <cfif checkforpreactiverevisions.recordcount GT 0>
                <cfif checkforpreactiverevisions.contract_main_id NEQ 0 and checkforpreactiverevisions.contract_main_id NEQ CSLGetContractInfo.contract_main_id and not appSettings.getAllowReviseActiveWithPreActive()>
                    <CFSET Revise_Button_Show 	= 0>
                <cfelseif checkforpreactiverevisions.contract_main_id NEQ 0 and checkforpreactiverevisions.contract_main_id EQ CSLGetContractInfo.contract_main_id>
                    <CFSET Revise_Button_Show 	= 1>
                </cfif>
            </cfif>
                <!--- if is revision show extra buttons --->
                <CFIF Program_Is_A_Revision EQ 1 AND APVL_Contract_Status GTE 3>
                    <CFSET History_Button_Show 	= 1>
                </CFIF>
            </CFIF>
        </CFIF>

        <!---BJF: Added to make it so you can copy a program which is not locked --->
        <CFIF (APVL_Contract_Status LTE 7 OR APVL_Contract_Status EQ 10) AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 1 AND (CSL_CallingPageCode IS "viewcontract")>

                <CFIF DisAllowAccessBasedOnProfile EQ 0>
                    <CFSET Renew_Button_Show 	= 1>
                </CFIF>

        </cfif>

        <CFIF CSLGetContractInfo.copy_not_allowed EQ 1>
            <CFSET Renew_Button_Show 	= 0>
        </CFIF>
    <!--- END print button logic --->

    <!--- Dev Note: KAL; 8067 --->
    <cfset Revision_popup_msg = 'Revisions only allowed after successful acknowledgement from ERP' />
    <cfset Revision_popup_msg_show = 0 />
    <cfset Cancel_popup_msg = 'Cancellation only allowed after successful acknowledgement from ERP' />
    <cfset Cancel_popup_msg_show = 0 />

    <!--- Cancel button logic --->
    <cfif CSLGetContractInfo.Contract_Main_ID NEQ "" and RevisionStatus.Client_Sent EQ 0>
        <cfset Cancel_Button_Show = 0 />
        <cfset Cancel_popup_msg_show = 1 />

    </cfif>
    <!--- End Note: KAL; 8067 --->
    <!--- Cancel button logic ExpiredProgram 31691--->
    <cfset CancelExpiredProgram = 1>
    <cfif CSLGetContractInfo.CONTRACT_STATUS_TYPE_IDX eq 7 or CSLGetContractInfo.CONTRACT_STATUS_TYPE_IDX eq 6>
        <cfset qGetProgramUserSettings = CreateObject("component", "components.programs.Program").getProgramUserSettings() />
        <cfif qGetProgramUserSettings.Cancel_Program_Options EQ 2 and dateDiff("d", Now(), CSLGetContractInfo.Contract_End_Date) LT 0>
            <cfset CancelExpiredProgram = 0>
        </cfif>
    </cfif>

    <!-- Dev Note: Ben 12332 -->
    <!-- Revise Button Show  -->
    <cfif CSLGetContractInfo.Contract_Main_ID NEQ "" and RevisionStatus.Client_Sent EQ 0 AND NOT (GetSettings.Interface_On_Approval eq 0 and CSLGetContractInfo.Contract_Status_Type_IDX eq 10)>
        <cfset Revise_Button_Show = 0 />
        <cfset Revision_popup_msg_show = 1 />
    </cfif>

    <!--- Release Settlement - Disable Editing once Released --->
    <cfif 	appSettings.getReleaseSettlement() AND CSLGetContractInfo.Released NEQ 0>
        <cfset Revise_Button_Show = 0>
        <cfset WIP_Kickback_Show = 0>
        <cfset Rollover_Button_Show = 0>
        <cfset Cancel_Button_Show = 0 />
    </cfif>


    <CFIF CSLGetContractInfo.Manual_Cancel EQ 1 OR CSLGetContractInfo.Force_Expiration_Flag EQ 1 OR CSLGetContractInfo.Dont_Allow_Edit EQ 1><!------ already cancelled ----->
        <cfset Cancel_Button_Show = 0 />
    </CFIF>

    <!--- If cancelled, Do not allow revision --->
    <CFIF CSLGetContractInfo.Cancelled_By neq "">
        <cfset Revise_Button_Show = 0>
    </CFIF>

    <!--- released program and setting prevents it from revision --->
    <cfif application.util.query.get_Setting("release_settlement_allow_revision",0) eq '0' and val(CSLGetContractInfo.Released)>
        <cfset Revise_Button_Show = 0>
    </cfif>

    <!---D38941 :: New Limited User Profile Edit Functionality STARTAND GetSettings.Forbid_Access_Type EQ 7--->
        <cfset useLakebaseForForbiddenAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_forbidden_template")>
<cfif useLakebaseForForbiddenAccess>
	<cftry>
		<cfset ForbiddenAccess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_forbidden_template", {
				"template_id" = "eq.#GetSettings.ProgramControl_Panel_Options_ID#",
				"profile_id" = "eq.#Get_Profile_Settings.Profiles_ID #",
				"forbid_access_type" = "eq.7"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForForbiddenAccess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForForbiddenAccess>
<cfquery name="ForbiddenAccess" datasource="#application.datasource#">
            SELECT *
            FROM Profile_Forbidden_Template
            WHERE Template_ID = #GetSettings.ProgramControl_Panel_Options_ID#
            AND Profile_ID = #Get_Profile_Settings.Profiles_ID #
            AND Forbid_Access_Type = 7
        </cfquery>
</cfif>
    <cfif Get_Profile_Settings.Limited_Revise AND ForbiddenAccess.RecordCount AND CSLGetContractInfo.Contract_Status_Type_IDX GTE 3 AND DisAllowAccessBasedOnLockStatus EQ 0>
            <cfset Mass_Copy_Button_Show = 0>
            <cfset Renew_Button_Show = 0>
            <cfset editcopyrevise = 0>
            <cfset Limited_Revise_Button_Show = 1>
    <cfelse>
                <cfset Limited_Revise_Button_Show = 0>
    </cfif>
    <!---D38941 :: New Limited User Profile Edit Functionality END--->
        <!---Logic for Apply_Won_Lost Button--->
        <CFIF APVL_Contract_Status EQ 8 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0>
            <cfset Modify_Won_By = 1 />
        </CFIF>
        </cfsilent>
        <TR>
            <TD NOWRAP>
            <IMG BORDER="0" SRC="/images/programs/ball_none.gif"></TD>
            <TD NOWRAP></TD>
        </TR>
        <!--- D32000:Show Creat/Search links in Program pop-up --->
        <cfif appSettings.getFlexProgramSearch() EQ 1>
        <TR>
        <!--- Comment out this section and add another section where the create link is disabled. We need to disable it because
                    in the program flex tool, the program page is is a new window and we do not want the users to create programs from
                    a new window.--->
            <TD NOWRAP>
                <CFOUTPUT>
                <A HREF="/common_files/select_new_program_type.cfm" TITLE="create a new program" CLASS="#HREF_Class#">
                <IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle"></A>
                <A HREF="/common_files/select_new_program_type.cfm" TITLE="create a new program" CLASS="#HREF_Class#">create
                </A>
                </CFOUTPUT>
            </TD>
            <!--- If we want the "create" link enabled, we just need to remove the section below and uncomment the section above. --->
            <!---<TD NOWRAP CLASS="Grayed">
            <IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            create
            </TD>--->
        </TR>
        <TR>
        <!--- Comment out this section and add another section where the search link is disabled. We need to disable it because
                    in the program flex tool, the program page is is a new window and we do not want the users to search programs from
                    a new window.--->
            <TD NOWRAP>
                <CFOUTPUT>
        <!---31906 - 	If app setting is set to Flex, then open the Flex program search
                                            If app setting is set to CF, then open the CF program search
                                            If app setting is set to Both, then open the Flex program search
                                            If app setting is set to CF 2020, then open the Ag Grid program search
                                            If app setting is set to Both CF & CF 2020, then open the Ag Grid program search
                                            --->
        <cfif appSettings.getFlexProgramSearch() EQ 1>
            <cfset vars.programSearch = "/Scorecard/program_Search.cfm">
        <cfelseif appSettings.getFlexProgramSearch() EQ 2 OR ppSettings.getFlexProgramSearch() EQ 3>
            <cfset vars.programSearch = "/flex/search/programSearchFx.cfm">
        <cfelseif appSettings.getFlexProgramSearch() EQ 4 OR ppSettings.getFlexProgramSearch() EQ 5>
            <cfset vars.programSearch = "/programs/program_search.cfm">
        </cfif>
                <A HREF="#vars.programSearch#" TITLE="search for a program" CLASS="#HREF_Class#"><IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle"></A>
                <A HREF="#vars.programSearch#" TITLE="search for a program" CLASS="#HREF_Class#">search</A>
                </CFOUTPUT>
            </TD>
            <!--- If we want the "search" link enabled, we just need to remove the section below and uncomment the section above. --->
            <!---<TD NOWRAP CLASS="Grayed">
            <IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            search
            </TD>--->
        </TR>
        </cfif>
        <TR>
            <TD NOWRAP>
            <IMG BORDER="0" SRC="/images/programs/ball_none.gif"></TD>
            <TD NOWRAP></TD>
        </TR>

    <cfif CSLGetContractInfo.Contract_Status_Type_IDX LT 3>
            <cfset showimage =1>
    <cfelse>
            <cfset showimage =0>
    </cfif>

    <cfif variables.performanceRequirements.rowsCount gt 0>
        <cfoutput><cfsavecontent variable="variables.anchor">href="/common_files/contracts/performance_req.cfm?Program_ID=#CSL_Contract_Main_ID#" onClick="NewWindow(this.href,'performance_req','650','650','Yes', 'No');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'perf req'
                        , enabled = (BestPlanLinkDisable EQ 0)
                        , anchor = "#variables.anchor#" )>
    </cfif>

    <cfset SetUpOption(  text = 'print'
                    , enabled = (Print_Button_Show EQ 1 AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='printer_friendly.cfm?id=#Program_Number#&bgimage=#showimage#'" )>

    <!--- Dev Note: drachala; D29588: Clicking on email redirects to quote letter  START
    Added/Changed: Added if condition START--->
    <cfif appSettings.getDisplayQuoteLetter() neq 1 or request.letters_available neq 3>
    <cfparam name="Encoded_Contract_Main_ID"   default="">
    <cfparam name="Encoded_completepath_email" default="">
    <cfset SetUpOption2(  text = 'email'
                        , enabled1 = (Email_Button_Show EQ 1 AND BestPlanLinkDisable EQ 0)
                        , anchor1 = "href='contract_email_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
                        , enabled2 = (CSL_CallingPageCode IS "sys" AND BestPlanLinkDisable EQ 0)
                        , anchor2 = "href='/common_files/contracts/sysco_deal_sheet/sysco_report_call_contract_email_create.cfm?CID=#URL.CID#'" )>
    </cfif>
    <!--- End Dev Note: drachala; D29588: Clicking on email redirects to quote letter END --->

    <!---D81343 :: View Program export & count... START --->
    <cfset SetUpOption(  text = 'export to excel'
                    , enabled = 1
                    , anchor = "href='##' onClick=generate_export('/common_files/contracts/export2excel.cfm?CID=#URL.CID#&ContractNumber=#CSLGetContractInfo.Contract_Number#')" )>

    <cfif GetSettings.Formula_Pricing_Type and application.util.query.get_setting( "Formula_Price_Item_Level_Config", 0 ) eq '1'>
        <cfset SetUpOption(  text = 'formula export'
                            , enabled = ( Get_Profile_Settings.Generate_Program_letters ? 1 : 0 )
                            , anchor = "href='##' onClick=generate_export('/common_files/contracts/formulaExport.cfm?id=#CSLGetContractInfo.contract_main_id#&ContractNumber=#CSLGetContractInfo.Contract_Number#')" )>
    </cfif>
    <!---D81343 :: View Program export & count... END --->


    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~ letters option ~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- Tim Ford 45204 - Changes to Kraft Operator Letters: if the request.letters_available eq 4 then display a different letters page --->
    <cfif appSettings.getDisplayQuoteLetter() neq 0>

        <cfset CUSTOM_RFP = 5>
        <cfif (request.letters_available eq 4 or request.letters_available eq CUSTOM_RFP)>
            <cfoutput><cfsavecontent variable="vars.anchor">href="##" onClick="NewWindow('/common_files/contracts/letters/view_letters.cfm?CID=#CSLGetContractInfo.contract_main_id#','name','1000','600','Yes', 'Yes');"</cfsavecontent></cfoutput>
            <cfif request.letters_available neq CUSTOM_RFP>
                <cfset letters_enabled = CSLGetContractInfo.Contract_Status_Type_IDX gte 3
                                            and BestPlanLinkDisable eq 0
                                            and (GetSettings.operator_letters_required eq 1 or GetSettings.distributor_letters_required eq 1)>
            <cfelse>
                <cfif !isDefined("getfieldsettings")>
                    <cfset templateManager  = CreateObject("component", "components.programs.template.TemplateManager").init()>
                    <cfset getFieldSettings = templateManager.getProgramTemplate(CSLGetContractInfo.contract_main_id)>
                </cfif>
                <!--- disable letters option when program is not approved
                                            or when all three excel exports and custom rfp are not selected from program template setting --->
                                                                                                <!--- RFP RESTRICTS ACCESS ON PROFILE --->
                <cfset letters_enabled = CSLGetContractInfo.Contract_Status_Type_IDX lt 3 or Get_Profile_Settings.Generate_Program_letters neq 1
                                            ? false
                                            : getfieldsettings.Non_Blended_Delivered_Freight_Matrix_Excel_Export neq 0
                                                or getfieldsettings.Blended_Delivered_Freight_Matrix_Excel_Export neq 0
                                                or getfieldsettings.Escalator_Excel_Export neq 0
                                                or getfieldsettings.custom_rfp_letter neq 0>
            </cfif>

            <cfset SetUpOption(  text = 'letters'
                                ,enabled = letters_enabled
                                ,anchor  = vars.anchor )>
        <cfelse>
            <!---30297 take users to distributors pop up--->
            <cfif DisAllowAccessBasedOnLockStatus neq 1>
                <cfset vars.nextPage = "distributors.cfm">   <!---edit mode allow users to select distributors--->
            <cfelse>
                <cfset vars.nextPage = "quoteLetter.cfm">    <!---read-only mode--->
            </cfif>
            <cfoutput><cfsavecontent variable="vars.anchor">href="##" onClick="NewWindow('/common_files/contracts/letters/distributors.cfm?Contract_Main_ID=#CSLGetContractInfo.contract_main_id#','name','1000','600','Yes', 'Yes');"</cfsavecontent></cfoutput>
            <cfset SetUpOption(  text = 'letters'
                                ,enabled = (CSLGetContractInfo.Contract_Status_Type_IDX GTE 3 AND BestPlanLinkDisable EQ 0)
                                ,anchor = vars.anchor )>
        </cfif>


    <cfelse>        <!--- appSettings.getDisplayQuoteLetter() eq 0 --->

        <cfparam name="CSLGetContractInfo.contract_main_id" default="">
        <cfif request.letters_available lt 4>
            <cfinclude template="letters/include_display_letters.cfm">
            <!--- Dev Note: 56090. When the program is in "read only" mode and the user clicks on "view letters", for certain client configurations, the page does not redirect to
                the "view letters" page. We need to add "SkipLock=1", so that "lockchecker.cfm" does not redirect the page to "contract_edit_menu.cfm".
            --->

            <cfset bviewEnabled = (request.letters_available and CSLGetContractInfo.Contract_Status_Type_IDX GTE 3 and (GetSettings.operator_letters_required EQ 1 OR GetSettings.distributor_letters_required EQ 1)) />
            <cfset SetUpOption(  text = 'view letters'
                                ,enabled = (bviewEnabled AND BestPlanLinkDisable EQ 0)
                                ,disabled = 'none'
                                ,anchor = "href='#includeLettersFilename#?CID=#CSLGetContractInfo.contract_main_id#&SkipLock=1'" )>
            <cfoutput><cfsavecontent variable="vars.anchorEmailLog">href="##" onclick="window.open('/common_files/contracts/Email_Log.cfm?ContractId=#CSLGetContractInfo.contract_main_id#','paymenthistorywindow','height=620,width=1150,scrollbars=yes,resizable=yes,left=0,top=0')"</cfsavecontent></cfoutput>

            <cfset SetUpOption(  text = 'email log'
                                ,enabled = (bviewEnabled AND appSettings.External_Contacts_Option NEQ 0 AND BestPlanLinkDisable EQ 0)
                                ,disabled = 'none'
                                ,anchor = vars.anchorEmailLog )>
        </cfif>

    </cfif>






    <cfif GetSettings.Email_Letters_On_Approval eq 1>
    <cfset editContacts = "view">
    <cfif (CSLGetContractInfo.Contract_Status_Type_IDX lte 2) and (DisAllowAccessBasedOnLockStatus eq 0)>
    <cfset editContacts = "edit">
    </cfif>
    <!---enable contacts option only after contract is saved--->
    <cfparam name="CSLGetContractInfo.contract_main_id" default="">
    <cfset SetUpOption(  text = 'contacts'
                        , enabled = (Val(CSLGetContractInfo.Contract_Main_ID) gt 0 AND BestPlanLinkDisable EQ 0)
                        , anchor = "href='##' onClick=NewWindow('/common_files/contracts/contacts.cfm?ContractId=#CSLGetContractInfo.contract_main_id#&mode=#editContacts#','contacts','870','720','Yes','No');" )>
    </cfif>

    <cfset SetUpOption(  text = 'copy'
                    , enabled = (Renew_Button_Show EQ 1 and editcopyrevise EQ 1)
                    , anchor = "href='##' onClick='verifyRenewal(0)'" )>

    <cfif appSettings.getMassCopy() eq 1>
    <cfset SetUpOption(  text = 'mass copy'
                    , enabled = (Mass_Copy_Button_Show eq 1 and  Renew_Button_Show EQ 1 and editcopyrevise EQ 1 AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='##' onClick='verifyMassCopy()'" )>
    </cfif>

    <CFIF  appSettings.getrolloverprograms_on()>
            <!--- 	ooooooooooooooooooooooooooooooooooooooooooo
                    Flag that says this is a LSAutoPay template
                    Set in Common_Queries.cfm 	bHideFromLSAutoPay
                    ooooooooooooooooooooooooooooooooooooooooooo	--->
    <cfset SetUpOption(  text = 'roll over'
                        , enabled = (RollOver_Button_Show EQ 1 and editcopyrevise EQ 1 AND NOT bHideFromLSAutoPay AND BestPlanLinkDisable EQ 0)
                        , anchor = "href='##' onClick='verifyRollover()'" )>
    </CFIF>

    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onClick="NewWindow('bid_request/bid_request_product_split.cfm?CID=#URL.CID#&contract_status=#APVL_Contract_Status#','name','800','600','Yes', 'No');"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'won by'
                    , enabled = (Modify_Won_By EQ 1 AND BestPlanLinkDisable EQ 0)
                    , disabled = 'none'
                    , anchor = vars.anchor )>

    <cfset SetUpOption(  text = 'history'
                    , enabled = (History_Button_Show EQ 1 AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='view_contract_history.cfm?CID=#URL.CID#&RO=1'" )>

    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="window.open('/common_files/contracts/payment_history/payment_history.cfm?ContractId=#CSLGetContractInfo.contract_main_id#','paymenthistorywindow','height=620,width=1150,scrollbars=yes,resizable=yes,left=0,top=0')"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'payment history'
                    , enabled = (appSettings.getpaymenthistoryon() and (CSLGetContractInfo.is_a_revision EQ 1 or CSLGetContractInfo.contract_status_type_idx GT 3) AND BestPlanLinkDisable EQ 0)
                    , anchor = vars.anchor )>
    <!---  D47306 : Price List Download START--->
        <cfif CSLGetContractInfo.Price_List_Download EQ 1>
            <cfset SetUpOption(  text = 'list price'
                            , enabled = (BestPlanLinkDisable EQ 0)
                            , anchor = "href='Price_List_Download.cfm?Contract_Main_Id=#CSLGetContractInfo.contract_main_id#&Contract_Number=#CSLGetContractInfo.Contract_Number#'" )>
        </cfif>
    <!---  D47306 : Price List Download END--->
    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="NewWindow('/common_files/contracts/view_contract_inactive_products.cfm?ContractID=#CSLGetContractInfo.contract_main_id#','name','450','450','Yes', 'No');"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'inactive records'
                    , enabled = (CSLGetContractInfo.Renewal_Of_Contract_Main_ID NEQ "" AND CSLGetContractInfo.Renewal_Of_Contract_Main_ID NEQ 0 AND BestPlanLinkDisable EQ 0)
                    , disabled = ' none'
                    , anchor = vars.anchor )>

    <!--- Dev Note: KAL; 8067 --->
    <cfset SetUpOption2(  text = 'cancel'
                        , enabled1 = (Cancel_Button_Show EQ 1 and editcopyrevise EQ 1 and  CancelExpiredProgram eq 1 AND BestPlanLinkDisable EQ 0)
                        , anchor1 = "href='##' onClick='verifyCancelation()'"
                        , enabled2 = (Cancel_popup_msg_show EQ 1 AND BestPlanLinkDisable EQ 0)
                        , anchor2 = "href='##' onMouseOver=initTheTooltip('#Cancel_popup_msg#') onMouseOut=popOut()" )>

    <!---TSF: Label 9176 - Added "not CSLGetContractInfo.revision_not_allowed" to not show revise button if the the template doesn't allow it.---->
    <!--- D38941 :: New Limited User Profile Edit Functionality
        Added Limited_Revise_Button_Show to check if user profile has access to revise the program
    --->
    <cfset SetUpOption2(  text = 'revise'
                        , enabled1 = ((Revise_Button_Show EQ 1 and editcopyrevise EQ 1 and not CSLGetContractInfo.revision_not_allowed AND NOT variables.bHideFromLSAutoPay) OR (Limited_Revise_Button_Show EQ 1) AND BestPlanLinkDisable EQ 0)
                        , anchor1 = "href='##' onClick='verifyRevision()'"
                        , enabled2 = (Revision_popup_msg_show EQ 1 AND NOT variables.bHideFromLSAutoPay)
                        , anchor2 = "href='##' onMouseOver=initTheTooltip('#Revision_popup_msg#') onMouseOut=popOut()" )>
    <!--- End Note: KAL; 8067 --->





    <cfset SetUpOption(  text = 'delete'
                    , enabled = (Delete_Button_Show EQ 1 and editcopyrevise EQ 1 AND BestPlanLinkDisable EQ 0 AND NOT ((CSLGetContractInfo.Sent_To_External_Client EQ 1 OR CSLGetContractInfo.Sending_To_External_Client EQ 1) ))
                    , anchor = "href='##' onClick='verifyDelete()'" )>
    <!--- 66079 :: Ability to delete 1 version & keep another version alive START--->
        <cfif request.AccessStructure.User_Rights_ID EQ '9999'>
        <cfset show_Delete_Program_Versions = 0>
        <cfset obj_Prg = CreateObject("component", "components.programs.Program")>
        <cfif obj_Prg.isARevision(CSL_Contract_Main_ID) OR obj_Prg.hasAnApprovedRevision(CSL_Contract_Main_ID)>
            <!--- This version of the program is either a revision or has a revision --->
            <cfset show_Delete_Program_Versions = 1>
        </cfif>
            <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="window.open('/settings/Delete_Program_Versions.cfm?RevisionContractMainID=#CSLGetContractInfo.Revision_of_Contract_Main_ID#&ContractMainID=#CSL_Contract_Main_ID#','DeleteProgramVersions','height=600,width=950,status=no,toolbar=no,menubar=no,location=no,titlebar=no,scrollbars=yes,resizable=yes');"</cfsavecontent></cfoutput>
            <cfset SetUpOption(  text = 'delete version'
                            , enabled = (DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0 AND show_Delete_Program_Versions)
                            , anchor = vars.anchor)>
        </cfif>
    <!--- 66079 :: Ability to delete 1 version & keep another version alive END--->
    <cfset SetUpOption(  text = 'purge'
                    , enabled = (Purge_Button_Show EQ 1 AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='##' onClick='verifyPurge()'" )>

    <cfset SetUpOption(  text = 'reset'
                    , enabled = (WIP_Kickback_Show EQ 1 AND editcopyrevise EQ 1 AND NOT (CSLGetContractInfo.Sent_To_External_Client EQ 1 OR CSLGetContractInfo.Sending_To_External_Client EQ 1)) OR (variables.bHideFromLSAutoPay AND NOT CSLGetContractInfo.Dont_Allow_Edit EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='##' onClick='verifyKB()'" )>
    <!---D50074 :: Viewing and Editing prior program versions START--->
    <cfif appSettings.getModifyExpiredPrograms() AND Get_Profile_Settings.Modify_Expired_Programs>
    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="window.open('contract_revision_history.cfm?CID=#EncryptedCID#&editOldProgram=1&contract_number=#CSLGetContractInfo.Contract_Number#','ProgramRevisionDetails','1300','600','Yes', 'Yes');"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'modify program'
                    , enabled = ( CSLGetContractInfo.Is_A_Revision EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                    , anchor = vars.anchor)>
    </cfif>
    <!---D50074 :: Viewing and Editing prior program versions END--->
    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="window.open('Reassign_Programs.cfm?Contract_Number=#CSL_Contract_Main_ID#&Reassign_Type=3','Reassign','height=600,width=950,status=no,toolbar=no,menubar=no,location=no,titlebar=no,scrollbars=yes,resizable=yes');"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'reassign'
                    , enabled = (Get_Profile_Settings.Reassign_Program_Access EQ 1 AND BestPlanLinkDisable EQ 0)
                    , disabled = 'none'
                    , anchor = vars.anchor )>

    <!--- D37981:Revision of program--->
    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="window.open('Reassign_history.cfm?Contract_Number=#CSL_Contract_Main_ID#&Reassign_Type=3','Reassign','height=600,width=950,status=no,toolbar=no,menubar=no,location=no,titlebar=no,scrollbars=yes,resizable=yes');"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'reassign history'
                    , enabled = (Get_Profile_Settings.Reassign_Program_Access EQ 1 AND BestPlanLinkDisable EQ 0)
                    , disabled = 'none'
                    , anchor = vars.anchor )>
    <!---D37981: Revision of program--->

    <!--- Dev Note: 11286 --->
    <cfif appSettings.getReleaseSettlement()>
    <!--- 66094 :: Release Settlement:  Update condition requiring OI Program Ack START--->
        <cfset Release_Settlement_Availability = 0>
        <cfif appSettings.get_Setting('Release_Settlement_Availability') eq '1'>
            <cfset Release_Settlement_Availability = 1>
        </cfif>
    <!--- 66094 :: Release Settlement:  Update condition requiring OI Program Ack END--->
        <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="window.open('release_settlement.cfm?CID=#EncryptedCID#',null,'height=150,width=380,status=no,toolbar=no,menubar=no,location=no,titlebar=no');"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'release'
                        , enabled = (CSLGetContractInfo.Release_Settlement NEQ 0
                                                                            AND Get_Profile_Settings.Release_Settlement EQ 1

                                                                            AND (
                                                                                            Release_Settlement_Availability NEQ 1
                                                                                        OR (
                                                                                                    CSLGetContractInfo.Sending_To_External_Client EQ 0
                                                                                            AND CSLGetContractInfo.Sent_To_External_Client EQ 1
                                                                                            AND len(CSLGetContractInfo.Contract_Reference_Number) GT 0
                                                                                            AND len(CSLGetContractInfo.External_Client_Ack_Date) GT 0
                                                                                        )
                                                                                )

                                                                            AND CSLGetContractInfo.Released EQ 0
                                                                            AND
                                                                            (	CSLGetContractInfo.Contract_Status_Type_IDX EQ 5
                                                                                OR CSLGetContractInfo.Contract_Status_Type_IDX EQ 6
                                                                                OR CSLGetContractInfo.Contract_Status_Type_IDX EQ 7
                                                                            )
                                                                                AND DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0)
                        , anchor = vars.anchor )>
    </cfif>
    <!--- End Dev Note: 11286 --->

    <cfquery name="revisioncount" datasource="#application.datasource#">
                SELECT count(*) as revisioncontractcount
                FROM contract_main
                WHERE contract_number = '#CSLGetContractInfo.contract_number#'
    </cfquery>
    <cfif revisioncount.revisioncontractcount GT 1 AND CSL_CallingPageCode IS "viewcontract">
        <cfset Revision_History_Button_Show = 1 />
    </cfif>
    <cfif revisioncount.revisioncontractcount GTE 1>
        <cfset Program_Changes_Button_Show = 1 />
    </cfif>

            <!--- 	ooooooooooooooooooooooooooooooooooooooooooo
                    Flag that says this is a LSAutoPay template
                    Set in Common_Queries.cfm 	bHideFromLSAutoPay
                    ooooooooooooooooooooooooooooooooooooooooooo	--->
    <cfset SetUpOption(  text = 'revision history'
                    , enabled = (Revision_History_Button_Show EQ 1 AND NOT variables.bHideFromLSAutoPay AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='##' onClick='viewRevisionHistory()'" )>

                    <!--- START: 56440: 'Duplicate Check' link inside a program/Anand Rao/04-Jan-2016 --->
    <cfif Get_Profile_Settings.View_LH_Pane_Duplicate_Checker_Link EQ 1 AND getsettings.Check_Duplicate_Program EQ 1>
        <cfset SetUpOption(  text = 'duplicate check'
                    , enabled = (Val(CSLGetContractInfo.Contract_Main_ID) gt 0 AND BestPlanLinkDisable EQ 0)
                    , anchor = "href='##' onClick=NewWindow('/common_files/contracts/duplicate_check.cfm?CID=#URL.CID#&Mode=showDup','Duplicate_Check','870','720','Yes','No');" )>
    </cfif>
    <!--- END: 56440: 'Duplicate Check' link inside a program/Anand Rao/04-Jan-2016 --->
    <!--- 118317 :: Program level - Update Distributors on Program based on 3rd Party Billbacks START --->
    <cfif !isDefined("getfieldsettings")>
        <cfset templateManager  = CreateObject("component", "components.programs.template.TemplateManager").init()>
        <cfset getFieldSettings = templateManager.getProgramTemplate(CSLGetContractInfo.contract_main_id)>
    </cfif>
    <cfif getFieldSettings.AutoAdd_Distributor_ThirdPartyClaims EQ 1 AND getFieldSettings.AutoAdd_Distributor_ThirdPartyClaims_Prg_Level EQ 1>
        <cfset SetUpOption(  text = 'auto add dist'
                    , enabled = ( DisAllowAccessBasedOnLockStatus EQ 0 )
                    , anchor = "href='##' onClick=NewWindow('/common_files/contracts/Auto_Add_Distributors.cfm?CID=#URL.CID#&Status=#CSLGetContractInfo.Contract_Status_Type_IDX#&Contract_main_id=#CSLGetContractInfo.contract_main_id#&Contract_number=#CSLGetContractInfo.Contract_number#','Auto_Add_Distributors','870','720','Yes','No');" )>
    </cfif>
    <!--- 118317 :: Program level - Update Distributors on Program based on 3rd Party Billbacks START --->
    <cfoutput><cfsavecontent variable="vars.anchor">href="##" onclick="NewWindow('/Common_Files/contracts/programChanges.cfm?Contract_main_id=#CSLGetContractInfo.contract_main_id#','ProgramChanges','1000','600','Yes', 'No')"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'changes'
                    , enabled = (Program_Changes_Button_Show EQ 1 AND NOT variables.bHideFromLSAutoPay AND BestPlanLinkDisable EQ 0)
                    , anchor = vars.anchor )>

    <cfif ((CSLGetContractInfo.EZButton_On EQ 1) AND CSLGetContractInfo.Contract_Status_Type_IDX GTE 2)>
        <cfset SetUpOption(  text = 'ez rate'
                        , enabled = (BestPlanLinkDisable EQ 0)
                        , anchor = "href='##' onClick=NewWindow('/Common_Files/contracts/EZ_Rates.cfm?CID=#EncryptedCID#','EZ_Rates','870','720','Yes','No');")>

    </cfif>

    <cfif getsettings.Display_FixedPrice_Basesales_On_Approval EQ 1 > <!---44653 if this setting is off, do not show the link  --->
    <!--- Dev Note: 20842 - Display base sales at time of approval --->
    <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/display_fixedprice_basesales.cfm?Program_ID=#CSL_Contract_Main_ID#&List_Of_Contract_Main_IDs=#List_Of_Contract_Main_IDs#" onclick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
    <cfset SetUpOption(  text = 'Base Sales @ Approval'
                    , enabled = (CSLGetContractInfo.contract_status_type_idx GT 2 AND BestPlanLinkDisable EQ 0 and (CSLGetContractInfo.saved_bidrequest_basesales EQ 1 and (appsettings.getshowfixedpriceadditionalfields() EQ 1 OR getsettings.display_FixedPrice_basesales EQ 1 OR getsettings.Display_FixedPrice_Basesales_On_Approval EQ 1)))
                    , disabled = 'none'
                    , anchor = vars.anchor )>
    </cfif>
    <!---62343 8.0 - Blended Rate, CF START--->
    <!---
    <!--- Blended Rates Report. --->
    <cfif appSettings.getPullbacksOn() AND GetSettings.generic_type EQ "Distributor Trade/Shelter">
        <cfset qRecaptureOperators = oRecaptureOperatorList.getRecaptureOperatorList() />
        <!--- at least one operator --->
        <cfif qRecaptureOperators.recordcount>
        <cfoutput><cfsavecontent variable="vars.anchor">href="/reportWriter/blendedRateFrm.cfm?CID=#EncryptedCID#" onclick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'blended rate'
                , enabled = 1
                , disabled = 'none'
                , anchor = vars.anchor )>
        </cfif>
    </cfif>
    --->
    <cfif appSettings.get_Setting('Blended_Rate') eq '1'>
        <cfset CheckComponentCount = 0>
        <cfif len(CSLGetContractInfo.Contract_Main_ID)>
            <cfquery name="CheckComponent" datasource="#application.datasource#">
            SELECT  *
            FROM dbo.Program_Rebates_Component PRC
            INNER JOIN dbo.Program_Rebates_Component_Name PRCN
            ON PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
            WHERE PRC.Program_ID = #CSLGetContractInfo.Contract_Main_ID#
            AND PRCN.Deleted = 0
            AND PRCN.rebate_type = 7
            AND PRC.Deleted = 0
            </cfquery>
            <cfset CheckComponentCount = CheckComponent.recordcount>
        </cfif>
        <cfif CheckComponentCount>
        <cfoutput><cfsavecontent variable="vars.anchor">href="/reportWriter/blendedCalculation.cfm?CID=#EncryptedCID#" onclick="NewWindow(this.href,'help','1100','600','Yes', 'No');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'blended calculation'
                , enabled = (BestPlanLinkDisable EQ 0)
                , disabled = 'none'
                , anchor = vars.anchor )>
        </cfif>
    </cfif>
    <!---62343 8.0 - Blended Rate, CF END--->
    <cfset createdByString = "" />
    <!------ get the created by user name ----->
    <cfset useLakebaseForCreatedUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForCreatedUser>
	<cftry>
		<cfset CreatedUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#CSLGetContractInfo.Creator_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCreatedUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreatedUser>
<cfquery name="CreatedUser" datasource="#application.datasource#">
        SELECT Name_First, Name_Last
        FROM _Users
        WHERE User_ID = '#CSLGetContractInfo.Creator_ID#'
    </cfquery>
</cfif>
    <CFIF CreatedUser.recordcount GT 0>
        <cfset createdByString = "#CreatedUser.Name_First# #CreatedUser.Name_Last# #Dateformat(CSLGetContractInfo.contract_created_date,'mm/dd/yyyy')#" />
    </CFIF>
    <!------
    if the current program is an autorenewed program - get the autorenewed from program information
    else if the current program is a copied program - get the copied from program information
    ----->
    <cfif CSLGetContractInfo.Renewal_Of_Contract_Main_ID NEQ ""><!------ this can be either an auto renew or a copy ----->
        <cfquery name="qGetCopyParentInfo" datasource="#application.datasource#">
            SELECT 	Contract_Number, Contract_Title
            FROM 	Contract_Main
            WHERE 	Contract_Main_ID = <cfqueryparam value="#CSLGetContractInfo.Renewal_Of_Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfif CSLGetContractInfo.Is_AutoRenew><!------ if auto renew ----->
            <cfset createdByString = "#createdByString#<br/><nobr>Auto-renewed from: #qGetCopyParentInfo.Contract_Number#</nobr>" />
        <cfelse><!------ regular copy ----->
            <cfset createdByString = "#createdByString#<br/><nobr>Copied from: #qGetCopyParentInfo.Contract_Number#</nobr>" />
        </cfif>
    </cfif>
    <!---
    ////////////   Tim Ford Label D25706: Removed Created By, RFA By, Agreed By and Approved By from Status Legend and put in workflow diplay from workflow link /////////////////
    <CFIF Len(createdByString) GT 0>
        <TR>
            <TD NOWRAP style="cursor:pointer;">
            <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
            <cf_smallHelp
                borderColor="black"
                backgroundColor="WhiteSMoke"
                showImage="0"
                showText="Created By"
                showTextColor="blue"
                borderWidth="1">
                <cfoutput><span style="color:RGB(0,0,255)">#JSStringFormat(createdByString)#</span></cfoutput>
            </cf_smallHelp>
            </TD>
        </TR>
    <CFELSE>
        <TR>
            <TD NOWRAP CLASS="Grayed">
            <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            created by</cfoutput></TD>
        </TR>
    </CFIF>
    <cfquery name="RFAUser" datasource="#application.datasource#">
                SELECT Name_First, Name_Last
                FROM _Users
                WHERE User_ID = '#CSLGetContractInfo.Broker_User_ID#'
    </cfquery>
    <CFIF RFAUser.recordcount GT 0>
        <TR>
            <TD NOWRAP style="cursor:pointer;">
            <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
            <cf_smallHelp
                borderColor="black"
                backgroundColor="WhiteSMoke"
                showImage="0"
                showText="Req.Approval By"
                showTextColor="blue"
                borderWidth="1">
                <cfoutput><span style="color:RGB(0,0,255)">#JSStringFormat(RFAUser.Name_First)# #JSStringFormat(RFAUser.Name_Last)# #Dateformat(CSLGetContractInfo.Broker_Approved_Date,'mm/dd/yyyy')#</span></cfoutput>
            </cf_smallHelp>
            </TD>
        </TR>
    <CFELSE>
        <TR>
            <TD NOWRAP CLASS="Grayed">
            <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            Req.Approval By</cfoutput></TD>
        </TR>
    </CFIF>
            <cfquery name="ApprovedUser" datasource="#application.datasource#">
                SELECT Name_First, Name_Last
                FROM _Users
                WHERE User_ID = '#CSLGetContractInfo.Approved_By_User_ID#'
    </cfquery>
    <!--- 	ooooooooooooooooooooooooooooooooooooooooooo
                    Flag that says this is a LSAutoPay template
                    Set in Common_Queries.cfm 	bHideFromLSAutoPay
                    ooooooooooooooooooooooooooooooooooooooooooo	--->
    <CFIF anyUsergreed NEQ 0 AND NOT variables.bHideFromLSAutoPay>
        <TR>
            <TD NOWRAP style="cursor:pointer;">
                <cfoutput>
                    <cfsilent>
                        <cfinclude template="users_agreed.cfm">
                    </cfsilent>
                    <cfsavecontent variable="str_users_agreed"><cfloop query="getprogramuseragreed">#Name_First# #Name_Last# (#Dateformat(Agree_DateTime,'mm/dd/yyyy')#)<br /></cfloop></cfsavecontent>
                    </cfoutput>
                    <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
            <cf_smallHelp
                borderColor="black"
                backgroundColor="WhiteSMoke"
                showImage="0"
                showText="Agreed By"
                showTextColor="blue"
                borderWidth="1">
                <cfoutput><span style="color:RGB(0,0,255)">#str_users_agreed#</span></cfoutput>
            </cf_smallHelp>
            </TD>
        </TR>
    <CFELSE>
        <TR>
            <TD NOWRAP CLASS="Grayed">
            <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            Agreed By</cfoutput></TD>
        </TR>
    </CFIF>
    <CFIF ApprovedUser.recordcount GT 0>
        <TR>
            <TD NOWRAP style="cursor:pointer;">
            <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
            <cf_smallHelp
                borderColor="black"
                backgroundColor="WhiteSMoke"
                showImage="0"
                showText="Approved By"
                showTextColor="blue"
                borderWidth="1">
                <cfoutput><span style="color:RGB(0,0,255)">#ApprovedUser.Name_First# #ApprovedUser.Name_Last# #Dateformat(CSLGetContractInfo.Approval_Date,'mm/dd/yyyy')#</span></cfoutput>
            </cf_smallHelp>
            </TD>
        </TR>
    <CFELSE>
        <TR>
            <TD NOWRAP CLASS="Grayed">
            <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            Approved By</cfoutput></TD>
        </TR>
    </CFIF>
    ////////////   Tim Ford Label D25706: Removed Created By, RFA By, Agreed By and Approved By from Status Legend and put in workflow diplay from workflow link /////////////////
    --->
    <!--- Dev Note: Clay 11286 --->
    <cfif 	appSettings.getReleaseSettlement()>
        <cfif CSLGetContractInfo.Released GT 0>
            <cfinvoke component="components.programs.releasesettlement.releasesettlementmanager" method="GetReleaseData" returnvariable="ReleaseData">
                <cfinvokeargument name="contract_main_id" value="#CSLGetContractInfo.Contract_Main_ID#">
            </cfinvoke>
            <cfinvoke component="components.user.usermanager" method="getUserName" returnvariable="releaseUserName">
                    <cfinvokeargument name="userID" value="#ReleaseData.Released_By#"/>
            </cfinvoke>
            <TR>
                <TD NOWRAP style="cursor:pointer;">
                    <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
                    <cf_smallHelp
                        borderColor="black"
                        backgroundColor="WhiteSMoke"
                        showImage="0"
                        showText=" released by"
                        showTextColor="blue"
                        borderWidth="1"
						width="190"
						>
                    <cfoutput>
                        <span style="color:RGB(0,0,255);">
                            Released By: <cfif len(ReleaseUserName) EQ 0>Auto<cfelse>#ReleaseUserName#</cfif><br />
                            Release Date: #Dateformat(ReleaseData.Released_Date,'mm/dd/yyyy')# #Timeformat(ReleaseData.Released_Date,'hh:mm')#<br />
                            Acknowlegement Date: #Dateformat(ReleaseData.Released_Ack_Date,'mm/dd/yyyy')# #Timeformat(ReleaseData.Released_Ack_Date,'hh:mm')#
                        </span>
                    </cfoutput>
                    </cf_smallHelp>
                </TD>
            </TR>
        <cfelse>
            <TR>
                <TD NOWRAP CLASS="Grayed"><cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle"> released by</cfoutput></TD>
            </TR>
        </cfif>
    </cfif>
    <!---
    ////////////   Tim Ford Label D25706: Removed Cancelled from Status Legend and put in workflow diplay from workflow link /////////////////
    <!--- End Dev Note: Clay 11286 --->
    <CFIF CSLGetContractInfo.Contract_Status_Type_IDX IS 7>
    <cfif len(trim(CSLGetContractInfo.Cancelled_Date)) GT 0>
    <cfset useLakebaseForGetCancellingUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetCancellingUser>
	<cftry>
		<cfset GetCancellingUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#CSLGetContractInfo.Cancelled_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCancellingUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCancellingUser>
<cfquery name="GetCancellingUser" datasource="#application.datasource#">
    SELECT Name_First, Name_Last from _Users WHERE User_ID = '#CSLGetContractInfo.Cancelled_By#'
    </cfquery>
</cfif>
        <TR>
            <TD NOWRAP style="cursor:pointer;">
            <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
            <cf_smallHelp
                borderColor="black"
                backgroundColor="WhiteSMoke"
                showImage="0"
                showText="Cancelled By"
                showTextColor="blue"
                borderWidth="1">
                <cfoutput><span style="color:RGB(0,0,255)">#GetCancellingUser.Name_First# #GetCancellingUser.Name_Last# #Dateformat(CSLGetContractInfo.Cancelled_Date,'mm/dd/yyyy')#</span></cfoutput>
            </cf_smallHelp>
            </TD>
        </TR>
    <CFELSE>
        <TR>
            <TD NOWRAP CLASS="Grayed">
            <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
            Cancelled By</cfoutput></TD>
        </TR>
    </CFIF>
    </cfif>
    --->


    <!--- Dev Note: KAL; 8891 --->
    <cfif appSettings.getDisplayEvaluationNotes() EQ 1>
        <cfoutput><cfsavecontent variable="variables.anchor23">href='##' onClick="javascript:showEvaluationNotes('#EncryptedCID#', 1, 0)"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'evaluation notes'
                        , enabled = (CSLGetContractInfo.Contract_Main_ID NEQ '0' AND BestPlanLinkDisable EQ 0 AND len(trim(CSLGetContractInfo.Contract_Main_ID)) NEQ 0)
                        , anchor = variables.anchor23 )>
    </cfif>


    <cfif NOT appsettings.getSend_to_SAP()>
        <cfif BestPlanLinkDisable EQ 0>
            <CFIF CSLGetContractInfo.Cancel_Sent_to_Client EQ 1>
                <TR>
                    <TD NOWRAP>
                    <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_red.gif" ALIGN="absmiddle">
                    <A onMouseOver="initTheTooltip('This program has been cancelled in ERP')" onMouseOut="popOut()"><span style="color : Blue;cursor:pointer;">Cancelled in ERP</span></A></cfoutput></TD>
                </TR>
            <CFELSEIF CSLGetContractInfo.Sent_To_External_Client EQ 1>
                <TR>
                    <TD NOWRAP>
                    <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle">
                    <A onMouseOver="initTheTooltip('This program has been successfully loaded in ERP')" onMouseOut="popOut()"><span style="color : Blue;cursor:pointer;">Loaded in ERP</span></A></cfoutput></TD>
                </TR>
            <CFELSEIF CSLGetContractInfo.Sending_To_External_Client EQ 1>
                <TR>
                    <TD NOWRAP>
                    <cfoutput><IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
                    <A onMouseOver="initTheTooltip('This program is being sent to ERP')" onMouseOut="popOut()"><span style="color : Blue;cursor:pointer;">Sending to ERP</span></A></cfoutput></TD>
                </TR>
            </CFIF>
        </cfif>
    </cfif>

    <!--- Dev Note: KAL; 8891: Business Consideration Section with user/date stamp:
        Reusing the Evaluation notes function but passing addtional arguments (NoteType) to differentiate  --->

    <cfoutput><cfsavecontent variable="variables.foobar1">href='##' onClick="javascript:showEvaluationNotes('#EncryptedCID#',2,1)"</cfsavecontent>
    <cfsavecontent variable="variables.foobar2">href='##' onClick="javascript:showEvaluationNotes('#EncryptedCID#',2,0)"</cfsavecontent></cfoutput>
    <cfset SetUpOption2(  text = 'bus. consid.'
                        , enabled1 = (Get_Profile_Settings.Internal_Notes eq 1 and DisAllowAccessBasedOnLockStatus EQ 0 AND BestPlanLinkDisable EQ 0 AND len(trim(CSLGetContractInfo.Contract_Main_ID)) NEQ 0)
                        , anchor1 = variables.foobar1
                        , enabled2 = (Get_Profile_Settings.Internal_Notes eq 1 and DisAllowAccessBasedOnLockStatus EQ 1 AND BestPlanLinkDisable EQ 0 AND len(trim(CSLGetContractInfo.Contract_Main_ID)))
                        , anchor2 = variables.foobar2 )>

    <!---Display if program alerts are on--->
    <cfif appsettings.getProgramAlerts()>
        <!---check to see if any alerts have been sent--->
        <cfparam name="variables.bAlertsSent" default="0" />
        <cfset variables.oProgramAlertManager = createObject("component", "components.settings.ProgramAlerts.ProgramAlertManager") />
        <cfif len(trim(CSLGetContractInfo.Contract_Main_ID)) NEQ 0>
            <cfset variables.bAlertsSent = variables.oProgramAlertManager.getProgramAlertMessage(CSLGetContractInfo.Contract_Main_ID, 1).RecordCount />
        </cfif>
        <cfif variables.bAlertsSent neq "0" AND BestPlanLinkDisable EQ 0>
            <TR>
                <TD NOWRAP CLASS="Grayed">
                    <cfoutput>
                    <IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
                    <a href="/common_files/contracts/Program_Alert_Display.cfm?Program_ID=#CSLGetContractInfo.Contract_Main_ID#" onClick="NewWindow(this.href,'ProgramAlert','800','600','Yes', 'No');return false;">Program Alerts</a>
                    </cfoutput>
                </TD>
            </TR>
        <cfelse>
            <TR>
                <TD NOWRAP CLASS="Grayed"><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">Program Alerts</TD>
            </TR>
        </cfif>
    </cfif>
    <cfoutput>
    <cfif len(trim(CSLGetContractInfo.Contract_Main_ID)) NEQ 0 AND BestPlanLinkDisable EQ 0>
    <TR>
        <TD NOWRAP>
            <A HREF="/workflow/workflow.cfm?Program_ID=#CSL_Contract_Main_ID#" onClick="NewWindow(this.href,'help','1000','800','Yes', 'Yes');return false;"><IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle"></A>
            <A HREF="/workflow/workflow.cfm?Program_ID=#CSL_Contract_Main_ID#" onClick="NewWindow(this.href,'help','1000','800','Yes', 'Yes');return false;" CLASS="#HREF_Class#">workflow</A>
        </TD>
    </TR>
    <CFELSE>
        <TR>
            <TD NOWRAP CLASS="Grayed"><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">workflow</TD>
        </TR>
    </cfif>
    </cfoutput>

    <TR>
            <TD NOWRAP>
            <IMG BORDER="0" SRC="/images/programs/finial.gif" ALIGN="absmiddle">
            </TD>
    </TR>
        <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->
    </cfif><!---  D50074 :: Viewing and Editing prior program versions --->
        </TABLE>
    </span>

    </div>      <!--- style="background-color: #f8fafc;height:100vh;" --->


    <!--------------------------------------------------------------------------------------------------------------------->

    <cffunction name="Display_Budget_Option" output="true">
    <!---
        Dev Notes: 21828/Anand Rao/30-Dec-09
        CAG - display of LH pane link called Budgets
        Added an AND condition to check and display the link in the LHS only if the profile also has the setting ON
        to display the Budgets on the LHS
    --->
    <cfif (appSettings.getBudgetsFunctionalityOn() AND (Get_Profile_Settings.View_LH_Pane_Budget_Link EQ 1))>
        <CFSET CSL_data = 0>
        <CFSET CSL_there = 0>
        <CFQUERY NAME="Budget_Count" DATASOURCE="#application.datasource#">
            select *
            FROM Budget_Program_Selection bps
            INNER JOIN Budget b ON b.Budget_ID = bps.Budget_ID
            WHERE Program_ID = #CSL_Contract_Main_ID#
        </CFQUERY>
        <cfset CSL_data = ( Budget_Count.RecordCount gt 0 ? 1 : 0 )>

        <cfif DisAllowAccessBasedOnLockStatus eq 1>
            <cfset CSL_data =0>
        </cfif>
        <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
        <!---enable budgets option only after contract is saved, edit mode--->
        <!---- Budget display ---->
        <cfoutput><cfsavecontent variable="vars.anchor">href="/common_files/contracts/budget_display.cfm?fromprogram=1&Program_ID=#CSL_Contract_Main_ID#&data_handler=refresh_budget" onClick="NewWindow(this.href,'help','650','650','Yes', 'No');return false;"</cfsavecontent></cfoutput>
        <cfset SetUpOption(  text = 'budgets'
                        , enabled = ( Val(CSLGetContractInfo.Contract_Main_ID) gt 0 and DisAllowAccessBasedOnLockStatus eq 0 AND BestPlanLinkDisable EQ 0)
                        , anchor = vars.anchor
                        , dot_img = IMG_SRC )>
    </cfif>
    </cffunction>


    <STYLE TYPE="text/css">
    TD.foreground
        {
            border-left :		1px solid Gray;
            border-right :		1px solid Gray;
            border-top :		1px solid Gray;
            color: 				Red;
        }
    TD.background
        {
            border-left:		1px solid Gray;
            border-right:		1px solid Gray;
            border-top :		1px solid Gray;
            border-bottom:		1px solid Gray;
            color: 				White;
        }
    TD.Filler
        {
            border-left:		1px solid White;
            border-bottom:		1px solid Gray;
            color: 				White;
        }
    A.tablink_back, A:Hover.tablink_back
        {
            color: 				Blue;
            font-family:		Arial;
            font-size :			11px;
            text-decoration:	none;
        }
    A:visited.tablink_back
        {
            color: 				Blue;
            font-family:		Arial;
            font-size :			11px;
            text-decoration:	none;
        }
    A.tablink_fore
        {
            color: 				Red;
            font-family:		Arial;
            font-size :			11px;
            font-weight:		bold;
            text-decoration:	none;
        }
    A:visited.tablink_fore
        {
            color: 				Red;
            font-family:		Arial;
            font-size :			11px;
            font-weight:		bold;
            text-decoration:	none;
        }
    .Grayed
        {
            color: 				gray;
            font-family:		Arial;
            font-size :			11px;
        }

        /* POPup tooltip style*/
        #divTooltip {
            position:absolute;
            top:0px;
            width:100px;
            visibility:hidden;
            z-index:200;
            background:#FFFFFF;
            layer-background-color:#FFFFFF;
            text-align:left;
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
        <!--[if gt IE 8]>
            table#table1 { border-collapse: collapse; table-layout:fixed; }
        <![endif]-->
        <!--[if lte IE 8]>
            table#table1 { border-collapse: collapse; }
        <![endif]-->
    </style>


    <script language="JavaScript" type="text/javascript">
    function initTheTooltip(ToolTipText){
        textHolder = ToolTipText;
        messages[0]="";
        messages[0]= "" + textHolder + ""

        popUp(0)
    }

    function showSAPreferences(CID,Type){
        if (Type == 1)
        NewWindow('/common_files/contracts/show_sap_references.cfm?CID='+ CID, 'SAPReference','450','450','Yes', 'Yes')
        else if (Type == 2)
        NewWindow('/common_files/contracts/show_sap_references_Common.cfm?CID='+ CID, 'SAPReference','850','450','Yes', 'NO')
    }

    function showProgramRefNumberEdit(){
        <cfoutput>
        window.showModalDialog('/common_files/contracts/program_reference_number_edit.cfm?CID=#URL.CID#&RAND=#CreateUUID()#', window, 'dialogHeight:400px;dialogWidth:600px;center:yes;edge:raised');
        </cfoutput>
    }

    function showEvaluationNotes(CID, NoteType, Edit){
        NewWindow('/common_files/contracts/EvaluationNotes.cfm?CID='+CID+'&NoteType='+NoteType+'&SuppressBusConsid=1&EDIT='+Edit,'EvaluationNotes','800','400','Yes', 'Yes');
    }

    function viewapprovedmargins(){
        //window.open()
        <cfif Get_Profile_Settings.program_margin_approval_method EQ 5>
            NewWindow('/common_files/contracts/contract_profit_analysis.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&displayPreviousVersionMargin=0&margin_version=approved','Margins','990','650','Yes','Yes');
        <cfelse>
            <cfset filePath = "Data_Files/Margins/#CSLGetContractInfo.contract_main_id#_Margin.htm" />
            <cfif FileExists("#Application.Doc_Path#\#filePath#")>
                NewWindow("<cfoutput>#application.HTTPVar##cgi.server_name#/getDocument.cfm?FilePath=#filePath#</cfoutput>","Margins","800","600","Yes","Yes")
            <cfelse>
                alert("Sorry, saved margin not found");
            </cfif>
        </cfif>
    }

    /* Extending the Tooltip to control text alignment */
    function showtooltip(showToolTipText)
    {
        var tipobj = document.all.divTooltip;
        tipobj.style.textAlign="left";
        initTheTooltip(showToolTipText);
    }

    function hidetooltip(){
        var tipobj = document.all.divTooltip;
        tipobj.innerHTML = "";
        tipobj.style.textAlign="center";
        popOut();
    }
    <!--------------------------------------------------------------------------------------------------------------------->
    <!---refresh the budget information based on returned value from budgets popup --->
    function refresh_budget( selected_budgets ) {
    var budget = window.parent.document.getElementById("budget728");  <!---locate the budget element--->
    if ( budget ) {                                                   <!---found budget element, refresh its content--->
    budget.innerHTML = selected_budgets;
    }
    }
    <!--------------------------------------------------------------------------------------------------------------------->
    function competitive_data() {
    NewWindowTopLeft(<cfoutput>'/Common_Files/contracts/bid_request/competitive_data.cfm?CID=#EncryptedCID#'</cfoutput>, 'CompetitiveData', screen.availWidth, screen.availHeight, 'Yes', 'Yes');
    }
    <!--------------------------------------------------------------------------------------------------------------------->
    function verticalPNL( pClass ) {
    // NewWindowTopLeft( '/common_files/processing.cfm?actualPage=/common_files/contracts/contract_profit_analysis.cfm'
        <cfif appSettings.get_Setting('Margin_Display_Style') EQ 'custom_h'>
            popupCenterByPercentages( '/common_files/contracts/verticalpnl_hm.cfm'
                                        + '?verticalPNL=' + pClass
                                        + '&CID=<cfoutput>#URL.CID#</cfoutput>'
                                        + '&displayPreviousVersionMargin=0'
                                        + '&margin_version=current',
                                        'verticalPNL' + pClass,
                                        90, 90);
        <cfelse>
             popupCenterByPercentages( '/common_files/contracts/contract_profit_analysis.cfm'
                                    + '?verticalPNL=' + pClass
                                    + '&CID=<cfoutput>#URL.CID#</cfoutput>'
                                    + '&displayPreviousVersionMargin=0'
                                    + '&margin_version=current',
                                    'verticalPNL' + pClass,
                                    // screen.availWidth, (screen.availHeight - 40), 'yes', 'yes');  // taskbar is 40px high
                                    90, 90);
        </cfif>
    }
    /* Since multiple program windows can now be open, once a user edits a program, we need to see if another program is already in edit mode.
    If it is, we tell the user that data in that window may not be saved (just in case, the user hasn't saved any data from that window).
    */
    function CheckBeforeEditMode()
    {
        var bAddWindowToList = 1;
        var bAnyWindowOpen = 0;
        if(window.opener){
            /*
            When a user opens a program and then goes to the home page, the opened window does not have a parent.
            In that case, one cannot change the status of the program to edit mode without he below code -
            "typeof window.opener.addWindowToList == 'function' || typeof window.opener.addWindowToList == 'object'"
            "Object" is for IE 9 and "function" is for higher versions.
            */
            if (typeof window.opener.addWindowToList == 'function' || typeof window.opener.addWindowToList == 'object') {
                if(window.opener.openedWindows.length > 0){

                    /* Sometimes a user can close the window when the program is in edit mode. In this case, the "openedWindows"
                    array will still have this entry. So, we need to check whether a program which was in edit mode is still open.
                    If yes, we need to show the measage below, when the user tries to set another program to edit mode.
                    */
                    for(i=0;i<window.opener.openedWindows.length;i++)
                    {
                        if(!window.opener.openedWindows[i].closed){
                            bAnyWindowOpen = 1;
                        }
                    }
                    if(bAnyWindowOpen)
                    {
                        if(confirm("Another program is in edit mode. Any unsaved information on that program will be lost. Do you want to continue?") == true){
                            bAddWindowToList = 2;
                        }
                        else{
                            bAddWindowToList = 0;
                        }
                    }
                }
                /* This can be called in 2 conditions -
                1) If the user does not have any other program in edit mode
                2) If the user clicks on "OK" to the above question - "Another program is in edit mode. Any unsaved information on that program
                will be lost. Do you want to continue?"
                */
                if(bAddWindowToList != 0){
                    add_window_to_list();
                }
            }
        }
        /* If the user does not have any other program in edit mode */
        if(bAddWindowToList == 1){
            <cfoutput>
            <cfif IsDefined("variables.lockHref")>
                location.href='#variables.lockHref#';
            </cfif>
            </cfoutput>
        }
    }
    /* Lock the program. */
    function lock_current_program(){
    <cfoutput>
        location.href='/Common_Files/Contracts/Lock_Contract.cfm?CID=#EncryptedCID#&ModifyDeletedPrograms=#ModifyDeletedPrograms#';
    </cfoutput>
    }

    /* Since multiple programs can now be open, when a user wants to set a program to edit mode, we add the program to an array, so that
    we can keep track of the open pop-up windows. We only keep track of programs in edit mode.
    */
    function add_window_to_list(){
        if(window.opener){
                if(window.opener.addWindowToList)
                {
                    window.opener.addWindowToList(window);
                    refresh_window();
                }
        }
    }
    /* Since multiple programs can now be open, when a user wants to set a program to read-only mode, we remove the program from the array, so that
    we can keep track of the open pop-up windows. We only keep track of programs in edit mode.
    */
    function remove_window_from_list(){
        if(window.opener){
            if(window.opener.removeWindowFromList)
            {
                window.opener.removeWindowFromList(window);
            }
        }
    }

    /* Since multiple programs can now be open, when a user wants to set a program to edit mode, we need to check whether there is already
    another program in edit mode. If yes, we need to unlock that program so that it gets set to read-only. */
    <cfoutput>
    function refresh_window(){
        if(window.opener){
            if(window.opener.openedWindows){
                if(window.opener.openedWindows.length > 0){
                    for(i=0;i<window.opener.openedWindows.length;i++){
                        /* If the other window is not closed and it is not the current window */
                        if ((!window.opener.openedWindows[i].closed) && window.opener.openedWindows[i] != window){

                            /* get the value of "CID" for the other program - opened program popup window in edit mode */
                            CID_Value = getUrlParameterValue('CID',window.opener.openedWindows[i].location);

                            /* Unlock the other program */
                            window.opener.openedWindows[i].location.href='/Common_Files/Contracts/UnLock_Contract.cfm?CID='+CID_Value;

                            /* Remove the other program from the window list */
                            window.opener.removeWindowFromList(window.opener.openedWindows[i]);
                        }
                    }
                }
            }
            /* Now that the other program is unlocked (if it was locked), we can lock our current program */
            lock_current_program();
        }
    }
    </cfoutput>
    </script>
    </cfif>
    </cfsavecontent>
</cfif>



<cfoutput>
#contract_status_legend#

<cfif save_left_panel>
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  gather left panel .html info (html_full_path & html_content) based on setting  --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfset left_panel_output = application.util.io.getProgramLeftPanelHtml( CSL_Contract_Main_ID, request.is_in_edit_mode )>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- left panel .html full path is defined (setting is enabled) and its content is empty --->
    <!---  save program left panel options to a reusable .html file for best performance      --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif (left_panel_output.html_full_path gt '') and (left_panel_output.html_content eq '')>
        <cfif request.is_in_edit_mode and isDefined("TabsClickable") and TabsClickable neq 1>
            <!--- do not generate html when program is in edit mode and tabs are not clickable --->
        <cfelse>
            <cffile action="write" file="#left_panel_output.html_full_path#" output="#contract_status_legend#">
        </cfif>
    </cfif>
</cfif>
</cfoutput>