<!--- /mvc/Models/Program/OnePageProgramManager.cfc --->
<cfcomponent displayname="One Page Programr" output="false" access="public">

<cffunction name="init" output="false" returntype="mvc.Models.Program.OnePageProgramManager">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfset variables.ContractId = arguments.contractId />
	<cfreturn this />
</cffunction>

<cffunction name="getDiscountIdentifier" hint="getDiscountIdentifier" access="public" output="false" returntype="string">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfset var qGetDiscountIdentifier = "" />

	<cfquery name="qGetDiscountIdentifier" datasource="#application.datasource#">
		SELECT Disc.Discount_Identifier_Number,
				Disc.Discount_Identifier_Desc
		FROM Contract_Main CM
		INNER JOIN Program_Control_Panel_Options PCPO ON
			PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
		INNER JOIN Discount_Identifier Disc ON
				Disc.Discount_Identifier_ID = PCPO.Discount_Identifier_ID
		WHERE  CM.Contract_Main_Id = #arguments.contractId#
	</cfquery>

	<cfreturn qGetDiscountIdentifier.Discount_Identifier_Number />

</cffunction>

<cffunction name="getDistributors" hint="getDistributors" access="public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfset var qGetDistributors = "" />

	<cfset useLakebaseForqGetDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForqGetDistributors>
	<cftry>
		<cfset qGetDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"program_id" = "eq.#arguments.contractId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributors>
<cfquery name="qGetDistributors" datasource="#application.datasource#">
		SELECT	*
		FROM Contract_Distributors
		WHERE Program_Id = #arguments.contractId#
	</cfquery>
</cfif>

	<cfreturn qGetDistributors />

</cffunction>

<cffunction name="isStrategic" hint="getDistributors" access="public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="custId" type="string" required="false" default="" />

	 <cfscript>
		// stuff
		var a = arguments;
	</cfscript>
	<cfset var qGetDistributors = "" />

	<cfquery name="qGetDistributors" datasource="#application.datasource#">
		Declare
		@Family_Strategic int = 0,
		@Family_Network int = 0

		IF EXISTS (
			SELECT	1
			FROM Contract_Distributors CD
			inner JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
			inner join Distributor_Type_C tc
			on		tc.Distributor_Type_C_ID = c.Distributor_Type_C_ID
			WHERE CD.Contract_Main_Id = #a.contractId#
			And CD.Distributor_group_Id = '#a.custId#'
			and		c.Deleted = 0
			and		c.Active_Code = 'A'
			AND		tc.Distributor_Type_C LIKE 'STRATEGIC%'
		)
		SET @Family_Strategic = 1

		-- If atleast one distributor in the family is NETWORK
		IF	EXISTS (
			SELECT	1
			FROM Contract_Distributors CD
			inner JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
			inner join Distributor_Customer_ID custid
			on		custid.Customer_ID = c.Customer_ID
			WHERE	CD.Contract_Main_Id = #a.contractId#
			And CD.Distributor_group_Id = '#a.custId#'
			and		c.Deleted = 0
			and		c.Active_Code = 'A'
			AND		custid.Custid = 'NETWORK'
		)
		SET @Family_Network = 1

		SELECT @Family_Strategic AS strategic, @Family_Network AS network
	</cfquery>

	<cfreturn qGetDistributors />

</cffunction>

<cffunction name="getPerfReqs" hint="getPerfReqs" access="public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	 <cfargument name="field" type="any" required="false" default="0" />
	<cfset var qGetPerfReqs = "" />

	<cfquery name="qGetPerfReq" datasource="#application.datasource#">
			select PPR.Requirement_Name,
					PPR.Program_Perf_Req_ID
			FROM One_Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR ON
				PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
				<cfif arguments.field EQ 'parentChild'>
					AND (PPR.Requirement_Name = 'Parent' OR PPR.Requirement_Name = 'Child')
				<cfelseif arguments.field EQ 'Acute'>
					AND (PPR.Requirement_Name = 'Acute' OR PPR.Requirement_Name = 'Non-Acute'OR PPR.Requirement_Name = 'N/A')
				</cfif>
			WHERE PPM.Contract_Main_Id = #arguments.contractId# and checked = 1
	</cfquery>
	<cfreturn qGetPerfReq />

</cffunction>

<cffunction name="saveBasicInfo" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfset var qSaveInfo = "" />
	<cfscript>
		switch(arguments.field) {
		    case "Contract_Reference_Number": case "Contract_Title" : case "notes" :
		    	this.updContractMain(arguments.val,arguments.field,arguments.contractId);
		        break;
		    case "Incremental_Sales":
		    	this.updContractMain(arguments.val,'Fixed_Rebate_Amount',arguments.contractId);
		        break;
		    case "start_date":
		        this.updContractMain(arguments.val,'Contract_start_date',arguments.contractId);
		        break;
		    case "end_date":
		        this.updContractMain(arguments.val,'Contract_End_date',arguments.contractId);
		        break;
		    case "acute": case "parentChild":
		        this.updPerfReq(arguments.val,arguments.field,arguments.contractId);
		        break;
		    case "Override_Price_List_Id": case "Gpo_Price_List_Id" : case "NonGpo_Price_List_Id" :
		        this.updContractMainAuxData(arguments.val,arguments.field,arguments.contractId);
		        break;
		    default:
		         WriteOutput("bad data");
		}
	</cfscript>

	<cfreturn arguments />

</cffunction>

<cffunction name="updContractMain" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfset useLakebaseForqSaveInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqSaveInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#arguments.contractId#"
			},
			{
				"field#" = "#arguments.val#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSaveInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSaveInfo>
<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Contract_main SET #arguments.field# = '#arguments.val#' WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>
</cfif>

	<cfreturn arguments />

</cffunction>

<cffunction name="updClaimMechanic" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />
		<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Program_Fixed_Component set Claim_Mechanics = #arguments.claim_Mechanics# WHERE Program_Id = #arguments.contractId#

			Update Program_Rebates_Component set Claim_Mechanics = #arguments.claim_Mechanics# WHERE Program_Id = #arguments.contractId#

			Update Contract_Main set ClaimMechanics = #arguments.claim_Mechanics# WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>

	<cfreturn arguments />

</cffunction>

<cffunction name="updContractMainAuxData" hint="Save Form Fields on Change" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

	<cfif (arguments.field EQ 'Gpo_Price_List_Id' OR arguments.field EQ 'NonGpo_Price_List_Id') AND arguments.val eq '0'>
		<cfset arguments.val = 'NULL'>
	</cfif>
	<cfif arguments.val eq 'NULL'>
		<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Contract_main_Aux_Data SET #arguments.field# = NULL WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>
	<cfelse>
		<cfquery name="qSaveInfo" datasource="#application.datasource#">
			Update Contract_main_Aux_Data SET #arguments.field# = '#arguments.val#' WHERE Contract_Main_Id = #arguments.contractId#
		</cfquery>
	</cfif>cfif>
	<cfreturn arguments />

</cffunction>

<cffunction name="getOnePriceList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="plId" type="any" required="false" default="0" />

		<cfif trim(arguments.plId) NEQ ''>
			<cfset useLakebaseForqgetPL = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_list_header")>
<cfif useLakebaseForqgetPL>
	<cftry>
		<cfset qgetPL = application.oLakebase.toQuery(
			application.oLakebase.selectRows("price_list_header", {
				"price_list_header_id" = "eq.#arguments.plId#",
				"select" = "price_list_id,tier,gpo_name"
			}), "price_list_id,tier,gpo_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetPL = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetPL>
<cfquery name="qgetPL" datasource="#application.datasource#">
				select Price_list_id,Tier ,GPO_Name
				from Price_list_header
				Where Price_List_Header_ID = '#arguments.plId#'
			</cfquery>
</cfif>
		<cfelse>
			<cfset qgetPL = querynew('Price_list_id,Tier,GPO_Name','varchar,integer,varchar') />
		</cfif>

	<cfreturn application.util.query.toAgGridJSON(qgetPL, 'Price_list_id, Tier, GPO_Name') />

</cffunction>

<cffunction name="updPerfReq" hint="Save perf requirements" access="remote" output="false" returntype="any">
	<cfargument name="val" type="any" required="false" default="0" />
	<cfargument name="field" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetPerfReq" datasource="#application.datasource#">
			Delete FROM PPM
			FROM One_Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR ON
				PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
				<cfif arguments.field EQ 'parentChild'>
					AND (PPR.Requirement_Name = 'Parent' OR PPR.Requirement_Name = 'Child')
				<cfelseif arguments.field EQ 'Acute'>
					AND (PPR.Requirement_Name = 'Acute' OR PPR.Requirement_Name = 'Non-Acute'OR PPR.Requirement_Name = 'N/A')
				<cfelse>
					AND 1=2
				</cfif>
			WHERE PPM.Contract_Main_Id = #arguments.contractId#
		</cfquery>

			<cfquery name="qInsPerfReq" datasource="#application.datasource#">
				INSERT INTO One_Program_Perf_Mapping (
					Contract_Main_ID,
					Program_Perf_Req_ID,
					checked)
				SELECT #arguments.contractId#,
					Program_Perf_Req_ID,
					1
				FROM 	Program_Perf_Req
				WHERE
				<cfif arguments.field EQ 'parentChild'>
					<cfif arguments.val EQ '1'>
						Requirement_Name = 'Parent'
					<cfelseif arguments.val EQ '2'>
						Requirement_Name = 'Child'
					<cfelse>
						1 = 2
					</cfif>
				<cfelseif arguments.field EQ 'Acute'>
					<cfif arguments.val EQ '1'>
						Requirement_Name = 'Acute'
					<cfelseif arguments.val EQ '2'>
						Requirement_Name = 'Non-Acute'
					<cfelseif arguments.val EQ '3'>
						Requirement_Name = 'N/A'
					<cfelse>
						1 = 2
					</cfif>
				</cfif>
			</cfquery>

	<cfreturn arguments />

</cffunction>

<cffunction name="getCustomers" hint="get current customers" access="public" output="false" returntype="query">
	<cfargument name="ContractMainID" type="numeric" required="false" default="0" />
	<cfargument name="custId" type="string" required="false" default="" />
	<cfscript>
		var a		= arguments;
		// var qStrat	= this.isStrategic(a.ContractMainID,a.custId);
		// var isStrat	= qStrat.strategic;
		// var sStrat  = 'Non-Strategic';
		// if(isStrat == 1){
		// 	sStrat  = 'Strategic';
		// }
	</cfscript>
		<cfquery name="qGetDistributors" datasource="#application.datasource#">

			SELECT CD.*,
					C.Name + ' (' + C.Ship_to + ')' as cust,
					L.Group_Level_Desc as type,
					ISNULL(strat.Distributor_Type_C,'Non-Strategic') AS Strat,
					Distributor_Group_Id,
					C.Name
			FROM 	Contract_Distributors CD
			LEFT JOIN BSA_Foodservice_Customers C ON C.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
			LEFT JOIN Distributor_Group_Level L ON L.Distributor_Group_Level_ID = CD.Distributor_Group_Level_ID
			LEFT JOIN (
						SELECT Distinct tc.Distributor_Type_C,CFam.Family_ID FROM BSA_Foodservice_Customers CFam
						LEFT join Distributor_Type_C tc
						on		tc.Distributor_Type_C_ID = cFam.Distributor_Type_C_ID
						where	tc.Distributor_Type_C LIKE 'STRATEGIC%'
							) AS Strat ON Strat.Family_ID = C.BSA_Foodservice_Customers_ID
			WHERE 	Contract_Main_ID = '#a.ContractMainID#'
			<cfif arguments.custId NEQ ''> and CD.BSA_Foodservice_Customers_ID = '#arguments.custId#'</cfif>
			AND 	CD.Deleted = 0
			AND		CD.Is_Group = 1
		</cfquery>

	<cfreturn qGetDistributors />

</cffunction>

<cffunction name="deleteCustomer" hint="get current customers" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="ContractMainID" type="numeric" required="false" default="0" />
	<cfargument name="custId" type="string" required="false" default="0" />

		<cfquery name="qDeleteDistributors" datasource="#application.datasource#">
			DELETE CD
			FROM Contract_Distributors CD
			WHERE 	Contract_Main_ID = '#arguments.ContractMainID#' AND
				distributor_group_id = '#arguments.custId#'
		</cfquery>

	<cfreturn application.util.query.toAgGridJSON(this.getCustomers(arguments.ContractMainID), 'cust, type, strat,distributor_group_id') />

</cffunction>

<cffunction name="saveCustomerGroup" hint="Save Cust Groupds From Popup" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	 <cfargument name="arrData" type="any" required="false" default="" />
	<cfset var qSaveInfo = "" />

	<cftry>
	<cfscript>
		// stuff
		var arr = deserializeJSON(arguments.arrData);
		var form = structNew();
		for (i=1;i LTE ArrayLen(arr);i=i+1) {
			form['#arr[i].name#'] = arr[i].value;
		}
		form.Contract_Main_ID = arguments.contractId;
		//writedump(var=form,output='c:\dump.log');
	</cfscript>
	<cfif len(form.FinalItemList)>
	<!--- 	<cfquery name="qGetDistGroupLevelID" datasource="#application.datasource#">
			SELECT	Distributor_Group_Level_ID
			FROM   Distributor_Group_Distributor
			WHERE Distributor_ID = '#ListFirst(trim(form.FinalItemList))#'
		</cfquery>

		<cfset thisGroupLevel = qGetDistGroupLevelID.Distributor_Group_Level_ID / > --->


		<cfset useLakebaseFordeletedCurrentDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseFordeletedCurrentDistributors>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_distributors",
			{
				"contract_main_id" = "eq.#Form.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletedCurrentDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletedCurrentDistributors>
<CFQUERY NAME="deletedCurrentDistributors" datasource="#application.datasource#">
			UPDATE Contract_Distributors
			SET Deleted = 1
			WHERE Contract_Main_ID = '#Form.Contract_Main_ID#'
		</CFQUERY>
</cfif>

		 <!--- <cfif qGetDistGroupLevelID.recordcount>
		 	AND Distributor_Group_Level_ID = #thisGroupLevel#
		</cfif> --->
	</cfif>
	<cfset ProdGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
	<cfset iDistributorListLen = listlen(FORM.FinalItemList) />
		<cfif iDistributorListLen> <!--- if no distributor selected, do not try to set the weight --->

			<cfset iDefaultWeight = request.app_general_functions.roundDecimalPlaces(100.00 / iDistributorListLen, 2) />
			<cfset iTotalWeightAssigned = 0 />

			<cfloop list="#form.FinalItemList#" index="CurrentRecord">
				<cfset stripCustId = request.app_general_functions.replaceHyphen(CurrentRecord) />
				<cfparam name="form.Group_Level_ID_#stripCustId#" default="0" />
				<cfset thisGroupLevel = Evaluate("form.Group_Level_ID_#stripCustId#")/>

				<cfset "FORM.Weight_DID_#stripCustId#" = iDefaultWeight />
				<cfset "FORM.Group_Level_ID_#stripCustId#" = "#thisGroupLevel#" />
				<cfset iTotalWeightAssigned = iTotalWeightAssigned + iDefaultWeight />
			</cfloop>

			<!--- if weight does not add up to 100, set the remaining to last record --->
			<cfif iTotalWeightAssigned neq 100>
				<cfset "FORM.Weight_DID_#stripCustId#" = iDefaultWeight + (100 - iTotalWeightAssigned) />
			</cfif>

		</cfif>
	<CFLOOP INDEX="ListDistributor_ID" LIST="#trim(form.FinalItemList)#" DELIMITERS=",">
			<CFSET Dis_Program_Weight = 100>
				<CFSET Dis_Program_Weight = evaluate("FORM.Weight_DID_#replace(ListDistributor_ID,"-","_","ALL")#")>
				<cfset stripCustId = request.app_general_functions.replaceHyphen(ListDistributor_ID) />
				<cfparam name="FORM.Contract_Main_ID" default="#contractId#" />
				<cfparam name="form.Group_Level_ID_#stripCustId#" default="0" />
				<cfparam name="FORM.Distributor_Level_1" default="0" />
				<cfparam name="FORM.groupLevelDistributors" default="0" />
				<cfparam name="FORM.Is_Group" default="1" />
				<cfparam name="FORM.Dynamic_Static_Groups" default="0" />
				<cfparam name="FORM.SelectedWarehouse_#stripCustId#" default="0" />
				<cfparam name="FORM.DefaultWarehouse_#stripCustId#" default="0" />
						<cfset useLakebaseForisitgroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForisitgroup>
	<cftry>
		<cfset isitgroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#ListDistributor_ID#",
				"ship_to" = "eq.Group"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisitgroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisitgroup>
<cfquery name="isitgroup" datasource="#application.datasource#">
							SELECT *
							FROM 	BSA_Foodservice_Customers
							WHERE BSA_Foodservice_Customers_ID = '#ListDistributor_ID#'
							AND 	ship_to = 'Group'
						</cfquery>
</cfif>
						<cfif isitgroup.recordcount>
							<cfset form.Is_Group = 1>
						<cfelse>
							<cfset form.Is_Group = 0>
						</cfif>
				<!--- D56899 END --->
				<!---handle for groups--->
				<cfif form.Is_Group eq 1>
					<cfset useLakebaseForqGetDistributorGroupLevelID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_group_distributor")>
<cfif useLakebaseForqGetDistributorGroupLevelID>
	<cftry>
		<cfset qGetDistributorGroupLevelID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_group_distributor", {
				"distributor_id" = "eq.#ListDistributor_ID#",
				"select" = "distributor_group_level_id"
			}), "distributor_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributorGroupLevelID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributorGroupLevelID>
<cfquery name="qGetDistributorGroupLevelID" datasource="#application.datasource#">
						SELECT	Distributor_Group_Level_ID
						FROM   Distributor_Group_Distributor
						WHERE Distributor_ID = '#ListDistributor_ID#'
					</cfquery>
</cfif>

					<cfset thisGroupLevel = qGetDistributorGroupLevelID.Distributor_Group_Level_ID / >
					<cfset thisGroupId = ListDistributor_ID />
				<cfelse>
					<cfset thisGroupLevel = FORM.groupLevelDistributors />
					<cfset thisGroupId = FORM.Distributor_Level_1 />
				</cfif>

			<!---set thisGroupLevel = to 0 if it's a null string--->
			<cfif trim(thisGroupLevel) eq "">
				<cfset thisGroupLevel = 0 />
			</cfif>
			<cfset Overridden_Warehouse = 0>

			<!--- D56899 START--->
				<cfif form.Is_Group EQ 0>
					<cfset useLakebaseForDeleteDuplicates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForDeleteDuplicates>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_distributors",
			{
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#",
				"bsa_foodservice_customers_id" = "eq.#ListDistributor_ID#",
				"captured_from_group" = "eq.1",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteDuplicates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteDuplicates>
<cfquery name="DeleteDuplicates" datasource="#application.datasource#">
						UPDATE Contract_Distributors
						SET DELETED = 1
						WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
						AND BSA_Foodservice_Customers_ID = '#ListDistributor_ID#'
						AND Captured_From_Group = 1
						AND Deleted = 0
					</cfquery>
</cfif>
				</cfif>
			<!--- D56899 END--->

			<cfquery name="SaveDistributor" datasource="#application.datasource#">
				INSERT INTO Contract_Distributors
				(BSA_Foodservice_Customers_ID, Contract_Main_ID,Program_Weight, Distributor_Group_Level_ID, Distributor_Group_ID, Is_Group, Dynamic_Static_Groups,Warehouse_Master_ID,Default_Warehouse_Master_ID,Overridden_Warehouse_Master_ID)
				VALUES
				('#ListDistributor_ID#', '#FORM.Contract_Main_ID#', '#trim(Dis_Program_Weight)#', #thisGroupLevel#, '#thisGroupId#', #form.Is_Group#, #form.Dynamic_Static_Groups#
				,NULL,NULL,NULL)
			</cfquery>

			<!---D42322 ::  Programs cannot be submitted for approval
			Added "GetTemplateInfo.Custom_Fixed_Price_Options" to below IF condition
			--->
			<cfif ProdGroupDataManager.isGroupDeal(FORM.Contract_Main_ID) AND GetTemplateInfo.Custom_Fixed_Price_Options eq 0>
				<!---if it's a group then flag to process when applying volume--->
				<cfquery name="qFlagGroup" datasource="#application.datasource#">
					UPDATE	Contract_Main
					SET		Group_Processed = 1
					WHERE	Deleted = 0
					AND 	Contract_Main_ID = #Form.Contract_Main_ID#
				</cfquery>
			</cfif>

			<!---if it's a group being added then capture group customers--->
			<!--- <cfif form.Is_Group EQ 1>

				<cfstoredproc procedure="CAPTURE_CUSTOMER_GROUPS" datasource="#application.datasource#">

					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#FORM.Contract_Main_ID#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PROGRAM_WEIGHT" value="#trim(Dis_Program_Weight)#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@DISTRIBUTOR_GROUP_LEVEL_ID" value="#thisGroupLevel#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@DISTRIBUTOR_GROUP_ID" value="#thisGroupId#" null="no">
					<cfprocparam type="In" CFSQLType="CF_SQL_BIT" dbVarName = "@@DYNAMIC_STATIC_GROUPS" value = "#form.Dynamic_Static_Groups#" null="no">

				</cfstoredproc>

			</cfif> --->
			<!--- ################################################################################### --->
		</CFLOOP>
		<cfcatch type="any">
           <cfdump var= "#cfcatch#" output="c:\dump.log">
           <cfthrow>
    	</cfcatch>
	    </CFtry>
	<cfreturn application.util.query.toAgGridJSON(this.getCustomers(FORM.Contract_Main_ID), 'cust, type, strat,distributor_group_id') />

</cffunction>

<cffunction name="getOperatorList" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="gpoKey" type="any" required="false" default="0" />
	<cfargument name="level" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfscript>
		//writedump(var=arrFxComp,output='c:\dump.log');;
		var a = arguments;
		var q = getOperatorListQuery(a.gpoKey,a.level,a.contractId);
	// </cfscript>
	// 	<cfdump var= "#q#" output="c:\dump.log">
	// <cfscript>
		return application.util.query.toAgGridJSON(q, 'key,level,name,level_id,gpo_id,Operator_Address,Operator_City,Operator_State,Operator_Zip');
	</cfscript>

</cffunction>

<cffunction name="getOperatorListQuery" hint="Save Form Fields on Change" access="public" output="false" returntype="query">
	<cfargument name="gpoKey" type="any" required="false" default="0" />
	<cfargument name="level" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfscript>
				//writedump(var=arrFxComp,output='c:\dump.log');;
				var a = arguments;
		</cfscript>
		<cfif a.contractId NEQ 0> <!--- get current selection --->
			<cftry>
			<cfquery name="qGetInfo" datasource="#application.datasource#">
				SELECT  DISTINCT
					IsNUll(G.GPO_Key,'') [key] ,
					IsNUll(G.Operator_GPO_ID,'') gpo_id,
					CO.Group_Level_ID AS level_id,
					CO.Group_Level_Desc AS name,
					CASE CO.Group_Level_ID
					 WHEN '0' THEN 'GPO Key'
			         WHEN '1' THEN 'Top Parent Name 1'
			         WHEN '2' THEN 'Top Parent Name 2'
			         WHEN '3' THEN 'Direct Parent Name 1'
			         WHEN '4' THEN 'Direct Parent Name 2'
			         WHEN '5' THEN 'End User Parent'
			         WHEN '6' THEN 'End User Child'
			         ELSE ''
			      END AS Level,
			      '' as Operator_Address,
				  '' as Operator_City,
				  '' as Operator_State,
				  '' as Operator_Zip,
				  G.GPO_Name
				FROM Contract_Operators CO
				LEFT JOIN Operator_GPO G ON
					G.Operator_GPO_ID = CO.Operator_Group_ID_Int
				WHERE CO.Contract_Main_ID = '#a.contractId#'  AND
						CO.Is_group = 1 AND
						CO.Deleted = 0
				ORDER BY [Key] ASC
			</cfquery>
			<!--- <cfdump var= "#qGetInfo#" output="c:\dump.log"> --->
			<cfif qGetInfo.recordCount EQ 0>
				<cfscript>
						//writedump(var=arrFxComp,output='c:\dump.log');;
						return getUserSelectedOperatorList(a.contractId);
				</cfscript>

			</cfif>

				<cfcatch type="any">
		           <cfdump var= "#cfcatch#" output="c:\dump.log">
		    	</cfcatch>
	  		  </CFtry>
		<cfelseif isnumeric(arguments.level) AND arguments.level NEQ 0> <!--- Get Level info --->
			<cfquery name="qGetInfo" datasource="#application.datasource#">
				SELECT DISTINCT
					IsNUll(G.GPO_Key,'') [key] ,
					IsNUll(G.Operator_GPO_ID,'') gpo_id
					<cfswitch expression="#arguments.level#">
					    <cfcase value="1">,IsNUll(Operator_Number_Of_Locations,'')  as name, 'Top Parent Name 1' as level, 1 as level_id</cfcase>
					    <cfcase value="2">,IsNUll(Operator_Phone,'')  as name, 'Top Parent Name 2' as level, 2 as level_id</cfcase>
					    <cfcase value="3">,IsNUll(Operator_First_Name,'')  as name, 'Direct Parent Name 1' as level, 3 as level_id</cfcase>
					    <cfcase value="4">,IsNUll(Operator_Last_Name,'')  as name, 'Direct Parent Name 2' as level, 4 as level_id</cfcase>
					    <cfcase value="5">,IsNUll(Operator_DBA,'')  as name, 'End User Parent' as level, 5 as level_id</cfcase>
					    <cfcase value="6">,IsNUll(Priority_Label,'')  as name, 'End User Child' as level, 6 as level_id</cfcase>
					    <cfdefaultcase>'' as name, '' as level, 0 as level_id</cfdefaultcase>
					</cfswitch>,
					 '' as Operator_Address,
					  '' as Operator_City,
					  '' as Operator_State,
					  '' as Operator_Zip
				FROM BSA_Operator O
				LEFT JOIN Operator_GPO G ON
					G.Operator_GPO_ID = O.Operator_GPO_ID AND
					G.Operator_GPO_ID ='#arguments.gpoKey#'
				<cfif arguments.level GTE 5>
					LEFT JOIN Operator_Priority OP ON
						OP.Operator_Priority_Id = O.Operator_Priority_Id AND
						OP.Deleted = 0
					WHERE Operator_Type !=  'GPO_Roster' AND
							G.Operator_GPO_ID IS NULL AND
							o.deleted = 0
				</cfif>
				<cfif arguments.level LT 5>
					WHERE Operator_Type =  'GPO_Roster' AND
							G.Operator_GPO_ID IS NOT NULL AND
							o.deleted = 0
				</cfif>
				ORDER BY [Key] ASC
			</cfquery>
		<cfelse> <!--- Get GPO Info --->
			<cfquery name="qGetInfo" datasource="#application.datasource#">
				SELECT DISTINCT g.*,
					G.GPO_Key [key] ,
					G.Operator_GPO_ID gpo_id,
					G.GPO_Name as name,
					'GPO Key' as level,
					0 as level_id,
					'' as Operator_Address,
					'' as Operator_City,
					'' as Operator_State,
					'' as Operator_Zip
				FROM Operator_GPO G
				WHERE G.Operator_GPO_ID ='#arguments.gpoKey#'
				ORDER BY [Key] ASC
			</cfquery>
		</cfif>
	<cfreturn qGetInfo />

</cffunction>
<!---
	HARD CODED MAPPING  ----- SHOULD BE TABLE DRIVEN...
,Operator_Number_Of_Locations -> 'Top_Parent_Name_1' as level, 1 as level_id
,Operator_Phone -> 'Top Parent Name 2' as level, 2 as level_id
,Operator_First_Name -> 'Direct Parent Name 1' as level, 3 as level_id
,Operator_Last_Name -> 'Direct Parent Name 2' as level, 4 as level_id
OPERATOR DBA -> Rollup Parent as level, 5 as level_id
OPERATOR PRIORITY -> Rollup Parent as level, 6 as level_id
 --->
 <cffunction name="getUserSelectedOperatorList" hint="Save" access="remote" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfscript>
				//writedump(var=arrFxComp,output='c:\dump.log');;
				var a = arguments;
		</cfscript>
			<cfquery name="qGetOperatorInfo" datasource="#application.datasource#">
				SELECT  DISTINCT
					IsNUll(BO.Legacy_Id,'') [key] ,
					IsNUll(BO.BSA_Operator_Id,'') gpo_id,
					CO.Group_Level_ID AS level_id,
					BO.Operator_Name
						+ ' [' + BO.Operator_Address
						+ ', ' + BO.Operator_City
						+ ', ' + BO.Operator_State
						+ ' ' + BO.Operator_Zip + ']'
					 AS name,
					'End User'   AS Level,
					Operator_Address,
					Operator_City,
					Operator_State,
					Operator_Zip,
					'' AS  GPO_Name
				FROM Contract_Operators CO
				INNER JOIN BSA_Operator BO ON
					BO.BSA_Operator_Id = CO.BSA_Operator_Id
				WHERE CO.Contract_Main_ID = '#arguments.contractId#'  AND
						CO.Is_group = 0 AND
						CO.Deleted = 0
				ORDER BY [Key] ASC
			</cfquery>
	<cfreturn qGetOperatorInfo/>
</cffunction>

<cffunction name="deleteOperator" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="operatorId" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qDeleteContractOperator" datasource="#application.datasource#">
			DELETE CO
			FROM  Contract_operators CO
			INNER JOIN BSA_Operator O ON co.BSA_Operator_Id = O.BSA_Operator_Id
			WHERE Contract_Main_Id  ='#arguments.contractId#' AND
				O.Legacy_Id = '#operatorId#'

		</cfquery>
	<cfreturn 'Operator Deleted'/>
</cffunction>

<cffunction name="deleteOperatorLevel" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qDeleteContractOperatorLevel" datasource="#application.datasource#">
			DELETE CO
			FROM  Contract_operators CO
			WHERE Contract_Main_Id  ='#arguments.contractId#'
		</cfquery>
	<cfreturn 'Operator Level Deleted'/>
</cffunction>

<cffunction name="getAllOperators" hint="" access="public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetAllOperators" datasource="#application.datasource#">
			Select o.*
			FROM  Contract_operators CO
			INNER JOIN BSA_Operator O ON co.BSA_Operator_Id = O.BSA_Operator_Id
			WHERE Contract_Main_Id  ='#arguments.contractId#' AND
				Co.Is_Group = 0
		</cfquery>
	<cfreturn qGetAllOperators />
</cffunction>

<cffunction name="saveOperator" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="gpoId" type="any" required="false" default="0" />
	<cfargument name="levelId" type="any" required="false" default="0" />
	<cfargument name="name" type="any" required="false" default="0" />
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qDeleteContractOperator" datasource="#application.datasource#">
			DELETE FROM  Contract_operators
			WHERE Contract_Main_Id  ='#arguments.contractId#'
		</cfquery>

		<cfquery name="qGetOpId" datasource="#application.datasource#">
			SELECT BSA_Operator_iD
			FROM BSA_Operator BO
			WHERE BO.Is_PG = 1 AND
			<cfif arguments.levelId LT 5>
				Operator_GPO_ID = #arguments.gpoId#
			<cfelseif arguments.levelId eq 5>
				Operator_Name = 'End User Parent'
			<cfelseif arguments.levelId eq 6>
				Operator_Name = 'End User Child'
			</cfif>

		</cfquery>
		<!--- <cfif >

		</cfif> --->
		<cfquery name="qSaveOperator" datasource="#application.datasource#">
			INSERT Contract_operators(
				BSA_Operator_ID,
				Contract_Main_ID,
				Is_Group,
				Operator_Group_ID_Int,
				Group_Level_Desc,
				Group_Level_ID
				)
			VALUES (
				'#qGetOpId.BSA_Operator_ID#',
				#arguments.contractId#,
				1,
				#arguments.gpoId#,
				'#arguments.name#',
				'#arguments.levelId#'
				)
		</cfquery>
		<cfif arguments.levelId LT 5>
			<cfquery name="qSaveOperator" datasource="#application.datasource#">
				DECLARE @Contract_Main_ID INT = #arguments.contractId#

					INSERT INTO Contract_Operators
					(BSA_Operator_ID,
					 Contract_Main_ID,
					 Deleted,
					 Created_Date,
					 Captured_From_Group,
					 Is_Group,
					 Operator_Group_ID,
					 Added_From_BB,
					 Operator_Group_ID_Int,
					 Group_Level_ID,
					 Group_Level_Desc
					)
					SELECT o.BSA_Operator_ID,
					       co.Contract_Main_ID,
					       0 AS Deleted,
					       GETDATE() AS Created_Date,
					       1 AS Captured_From_Group,
					       0 AS Is_Group,
					       NULL AS Operator_Group_ID,
					       0 AS Added_From_BB,
					       g.Operator_GPO_ID Operator_Group_ID_Int,
					       co.Group_Level_ID,
					       CASE co.Group_Level_ID
					           WHEN '0'           THEN g.GPO_Name
					           WHEN '1'           THEN o.Operator_Number_Of_Locations
					           WHEN '2'           THEN o.Operator_Phone
					           WHEN '3'           THEN o.Operator_First_Name
					           WHEN '4'           THEN o.Operator_Last_Name
					           ELSE ''       END AS Group_Level_Desc
					FROM Contract_Operators co
					     INNER JOIN Operator_GPO g ON g.Operator_GPO_ID = co.Operator_Group_ID_Int AND g.Deleted = 0
					     INNER JOIN BSA_Operator o ON co.Operator_Group_ID_Int = o.Operator_GPO_ID AND o.Is_Pg = 0 AND o.Deleted = 0
						 INNER JOIN Operator_Priority op ON op.Operator_Priority_ID = o.Operator_Priority_ID AND op.Deleted = 0
					WHERE co.Contract_Main_ID = @Contract_Main_ID
					      AND co.Deleted = 0
					      AND co.Is_group = 1
					      AND co.Group_Level_Desc = CASE co.Group_Level_ID
					                                    WHEN '0'  THEN g.GPO_Name
					                                    WHEN '1'  THEN o.Operator_Number_Of_Locations
					                                    WHEN '2'  THEN o.Operator_Phone
					                                    WHEN '3'  THEN o.Operator_First_Name
					                                    WHEN '4'  THEN o.Operator_Last_Name
					                                    ELSE ''   END
					ORDER BY 1;
			</cfquery>
		<cfelse>
			<cfquery name="qSaveOperator" datasource="#application.datasource#" result="result_name">
				DECLARE @Contract_Main_ID INT = #arguments.contractId#

					INSERT INTO Contract_Operators
					(BSA_Operator_ID,
					 Contract_Main_ID,
					 Deleted,
					 Created_Date,
					 Captured_From_Group,
					 Is_Group,
					 Operator_Group_ID,
					 Added_From_BB,
					 Operator_Group_ID_Int,
					 Group_Level_ID,
					 Group_Level_Desc
					)
					SELECT o.BSA_Operator_ID,
					       co.Contract_Main_ID,
					       0 AS Deleted,
					       GETDATE() AS Created_Date,
					       1 AS Captured_From_Group,
					       0 AS Is_Group,
					       NULL AS Operator_Group_ID,
					       0 AS Added_From_BB,
					       o.Operator_GPO_ID Operator_Group_ID_Int,
					       co.Group_Level_ID,
					       CASE co.Group_Level_ID
							   WHEN '5'			  THEN o.Operator_DBA
							   WHEN '6'			  THEN op.Priority_Label
					           ELSE ''       END AS Group_Level_Desc
					FROM Contract_Operators co
					     INNER JOIN BSA_Operator o ON  o.Is_Pg = 0 AND o.Deleted = 0 ---co.Operator_Group_ID_Int = o.Operator_GPO_ID AND o.Is_Pg = 0 AND o.Deleted = 0 AND o.Operator_Type <> 'GPO_Roster'
						 INNER JOIN Operator_Priority op ON op.Operator_Priority_ID = o.Operator_Priority_ID AND op.Deleted = 0
					WHERE co.Contract_Main_ID = @Contract_Main_ID
					      AND co.Deleted = 0
					      AND co.Is_group = 1
					      AND co.Group_Level_Desc = CASE co.Group_Level_ID
														WHEN '5'  THEN o.Operator_DBA
														WHEN '6'  THEN op.Priority_Label
					                                    ELSE ''   END
					ORDER BY 1;
			</cfquery>
		</cfif>
	<cfreturn 'DONE' />

</cffunction>

<cffunction name="saveSelectedOperators" hint="save" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="oprList" type="any" required="false" default="" />
	<cfset var qSaveOperatorList = "" />
	<cfscript>
		var l = arguments.oprList;
	</cfscript>


		<cfquery name="qDeleteContractOperator" datasource="#application.datasource#">
			DELETE FROM  Contract_operators
			WHERE Contract_Main_Id  ='#arguments.contractId#'
		</cfquery>

		<cfquery name="qSaveOperatorList" datasource="#application.datasource#">
			INSERT INTO Contract_operators(
				BSA_Operator_ID,
				Contract_Main_ID,
				Is_Group
				)
			SELECT
				BSA_Operator_ID,
				#arguments.contractId#,
				0
			FROM BSA_Operator WHERE BSA_Operator_ID IN (<cfqueryparam value="#l#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

		</cfquery>

<cfreturn 'SelectedOperatorSaved' />
	<!--- <cfreturn getUserSelectedOperatorList(arguments.contractId) /> --->
</cffunction>

<cffunction name="getTierData" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfset q = getTierDataQuery(arguments.contractId)>
	<cfreturn application.util.query.toAgGridJSON(qGetInfo, 'id, t, start, end, rate_desc, rate, tierNum') />

</cffunction>

<cffunction name="getTierDataQuery" hint="Save Form Fields on Change" access="remote" output="false" returntype="query" >
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="tierNumber" type="numeric" required="false" default="0" />

		<cfquery name="qGetInfo" datasource="#application.datasource#">
			 select Contract_Main_ID,
			 		GPO_Program_Tier_Data_ID as [id],
			 		Tier_Number as [tierNum],
					Tier_Number_Desc as [t],
					Range_Start as [start],
					Range_End as [end],
					Rate,
					Rate_Desc,
					Rate_UOM_Desc,
					Rate_UOM_Id,
					Range_UOM_Desc,
					Range_UOM_Id,
					Deleted,
					Program_Fixed_Component_Name_Id,
					Created_Date
			from GPO_Program_Tier_Data
			where Contract_Main_ID = '#arguments.contractId#'
			<cfif tierNumber GT 0>
				AND Tier_Number = #arguments.tierNumber#
			</cfif>
			Order by Tier_Number

		</cfquery>

	<cfreturn qGetInfo />

</cffunction>

<cffunction name="saveTierData" hint="Save Form Fields on Change" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="data" type="string" required="false" default="" />
	<cfargument name="field" type="string" required="false" default="0" />
	<cfset variables.data = deserializeJSON(arguments.data) >
		<cfquery name="qGetExisting" datasource="#application.datasource#">
			 select Contract_Main_ID,
			 		GPO_Program_Tier_Data_ID
			from GPO_Program_Tier_Data
			where Contract_Main_ID = '#arguments.contractId#' and
				GPO_Program_Tier_Data_ID = '#variables.data.id#'
			Order by Tier_Number
		</cfquery>

		<cfif qGetExisting.recordcount GT 0>
			<cfquery name="qUpdExisting" datasource="#application.datasource#">
				 UPDATE GPO_Program_Tier_Data
				 SET
				 <cfif arguments.field eq 'start'>
				 	Range_Start = '#variables.data.start#'
				 <cfelseif arguments.field eq 'end'>
				 	Range_End = '#variables.data.end#'
				 <cfelseif arguments.field eq 'rate_desc'>
				 	Rate_Desc = '#variables.data.rate_desc#',
				 	Rate = '#variables.data.rate#'
				 </cfif>
				 WHERE Contract_Main_ID = '#arguments.contractId#' and
					GPO_Program_Tier_Data_ID = '#variables.data.id#'
			</cfquery>
		<cfelse>
			<cfquery name="qGetInsert" datasource="#application.datasource#">
				 INSERT INTO GPO_Program_Tier_Data
				(Contract_Main_ID, Tier_Number, Tier_Number_Desc, Range_Start, Range_End, Rate, Rate_Desc)
				VALUES
				(#arguments.contractId#, '#variables.data.tierNum#', 'TIER #variables.data.tierNum#', '#variables.data.start#', '#variables.data.end#', '#variables.data.rate#', '#variables.data.rate_desc#')
			</cfquery>
				<!--- Make sure the sequence is OK --->
			<cfquery name="qUpdTierSequence" datasource="#application.datasource#">
				update Tier
				set tier_number = rn,
					Tier_Number_Desc = 'TIER ' + cast(rn as Varchar(2))
				from (
				       select tier_number,
							  Tier_Number_Desc,
				              row_number() over(order by (select GPO_Program_Tier_Data_id)) as rn
				       from GPO_Program_Tier_Data where Contract_main_Id = '#arguments.contractId#' and deleted = 0
				     ) Tier Where tier_number != rn
		</cfquery>
		</cfif>
	<cfreturn this.getTierData(arguments.contractId) />

</cffunction>

<cffunction name="getProducts" hint="Get Product Data" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfscript>
		qGetProdInfo = this.getProductsQuery(arguments.contractId);
	</cfscript>
	<cfreturn application.util.query.toAgGridJSON(qGetProdInfo, 'Item,Description,Brand,Type_Code_Desc,Q_Brand,Type_Group_Desc,BSA_Foodservice_Items_Master_ID,Contract_Products_Id,OverRide,#compIdList#') />
</cffunction>

<cffunction name="getProductsQuery" hint="Get Product Data Query" access="Public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfset compIdList = this.getCompIdList(arguments.contractId) />
		<cfset variables.tmpTable = replace(request.AccessStructure.User_ID, "-", "", "all")/>
		<cfquery name="qGetProdInfo" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##FPTiersTmp') IS NOT NULL
			    DROP TABLE ##FPTiersTmp
			IF OBJECT_ID('tempdb..####Tmp#variables.tmpTable#') IS NOT NULL
			    DROP TABLE ####Tmp#variables.tmpTable#
		    IF OBJECT_ID('tempdb..##OverRideTmp') IS NOT NULL
		    	DROP TABLE ##OverRideTmp

				SELECT  CP.BSA_Foodservice_Items_Master_ID, CP.Contract_Products_Id, PFCN.Program_Fixed_Component_Name_Id,
					CAST(PFD.Fixed_Price_Value AS DECIMAL(12,2)) AS Fixed_Price_Value
					-- ,CAST(ISNULL(User_Picked_Fixed_Price,0) AS DECIMAL(12,2)) AS User_Picked_Fixed_Price
				INTO ##FPTiersTmp
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				LEFT JOIN Program_Fixed_Price_Product_Data PFD ON
					PFD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					PFD.Deleted = 0
				LEFT JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PFD.Contract_Products_ID AND
					CP.Deleted = 0
				LEFT JOIN BSA_Foodservice_Items_Master I ON
							I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				WHERE 	PFC.Program_ID = '#arguments.contractId#' AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0

				SELECT DISTINCT  CP.BSA_Foodservice_Items_Master_ID,PFD.Program_Fixed_Price_Product_Data_Id,
						CAST(PFD.User_Picked_Fixed_Price AS DECIMAL(12,2)) AS User_Picked_Fixed_Price
				INTO ##OverRideTmp
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				INNER JOIN Program_Fixed_Price_Product_Data PFD ON
					PFD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					PFD.Deleted = 0
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PFD.Contract_Products_ID AND
					CP.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master I ON
							I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				WHERE 	PFC.Program_ID =  '#arguments.contractId#' AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0 AND
						ISNULL(PFD.User_Picked_Fixed_Price,0) != 0

			DECLARE   @SQLQuery AS NVARCHAR(MAX)
			DECLARE   @PivotColumns AS NVARCHAR(MAX)

			SELECT   @PivotColumns= COALESCE(@PivotColumns + ',','') + QUOTENAME(Program_Fixed_Component_Name_Id)
			FROM (SELECT DISTINCT Program_Fixed_Component_Name_Id FROM ##FPTiersTmp) AS PivotExample

			SET   @SQLQuery =
			    N'
				SELECT BSA_Foodservice_Items_Master_ID, Contract_Products_Id,' +   @PivotColumns + '
				INTO ####Tmp#variables.tmpTable#
				FROM ##FPTiersTmp
			    PIVOT (MAX(Fixed_Price_Value)
			          FOR Program_Fixed_Component_Name_Id IN (' + @PivotColumns + ')) AS P'

			EXEC sp_executesql @SQLQuery

			SELECT I.Item, I.Description, B.Brand, TDS.Type_Code_Desc, Q.Q_Brand, TGS.Type_Group_Desc, T.*
					,CASE WHEN ISNULL(TX.User_Picked_Fixed_Price,0) != 0 THEN 1 ELSE 0 END AS OverRide
			FROM ####Tmp#variables.tmpTable# T
			LEFT JOIN BSA_Foodservice_Items_Master I ON
				I.BSA_Foodservice_Items_Master_ID = T.BSA_Foodservice_Items_Master_ID
			LEFT JOIN  ##OverRideTmp TX ON TX.BSA_Foodservice_Items_Master_ID = T.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Type_Code_Desc TDS ON
				I.Type_Code_Desc_ID = TDS.Type_Code_Desc_ID
			LEFT JOIN Brand B ON
				I.Brand_ID = B.Brand_ID
			LEFT JOIN	Q_Brand_Desc Q ON
				I.Q_Brand_ID = Q.Q_Brand_ID
			LEFT JOIN	Type_Group_Desc TGS
					ON I.Type_Group_Desc_ID = TGS.Type_Group_Desc_ID
			ORDER BY I.Item
		</cfquery>
<!--- <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contractId#"> AND   ----------------------------------------->
	<cfreturn qGetProdInfo />

</cffunction>

<cffunction name="getCompIdList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCompInfo" datasource="#application.datasource#">
				SELECT  Distinct PFCN.Program_Fixed_Component_Name_Id
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				WHERE 	PFC.Program_ID = '#arguments.contractId#' AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0
		</cfquery>
		<cfset compIdList = ValueList(qGetCompInfo.Program_Fixed_Component_Name_Id) />
		<!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
	<cfreturn compIdList />
</cffunction>

<cffunction name="getAdminFeeCompIdList" hint="" access="public" output="false" returntype="query">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCompInfo" datasource="#application.datasource#">
				SELECT  Distinct R.Program_Rebates_Component_Name_ID
				FROM Program_Rebates_Component PRC
				INNER JOIN Program_Rebates_Component_Name R ON
						R.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_ID AND
						R.Program_Rebates_Component_Name LIKE '%Admin Fees%'
				where Program_Id = '#arguments.contractId#' and
						PRC.deleted = 0
		</cfquery>
		<!--- <cfset compIdList = ValueList(qGetCompInfo.Program_Rebates_Component_Name_ID) /> --->
		<!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
	<cfreturn qGetCompInfo />
</cffunction>

<cffunction name="getCPACompIdList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCPACompInfo" datasource="#application.datasource#">
				SELECT r.Program_Rebates_Component_Name_ID AS compnameid,
					prc.Program_Rebates_Component_Id AS compid,
					R.Program_Rebates_Component_Name AS compname, -- delete prc
					CASE WHEN (R.Program_Rebates_Component_Name NOT LIKE '%DAA%' AND  R.Program_Rebates_Component_Name NOT LIKE '%LPA%') THEN 1
					ELSE 0 END AS isLoyalty
				from Program_Rebates_Component PRC
				INNER JOIN Program_Rebates_Component_Name R ON
						R.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_ID
				where Program_Id = '#arguments.contractId#' and
						PRC.deleted = 0
				ORDER BY isLoyalty DESC
		</cfquery>
		<!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
	<cfreturn application.util.query.toAgGridJSON(qGetCPACompInfo, 'compname,compid,compnameid,isLoyalty') />
</cffunction>

<cffunction name="isLoyalty" hint="" access="public" output="false" returntype="numeric">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetCPALoyaltyCompInfo" datasource="#application.datasource#">
				SELECT r.Program_Rebates_Component_Name_ID AS compnameid,
					prc.Program_Rebates_Component_Id AS compid,
					R.Program_Rebates_Component_Name AS compname, -- delete prc
					CASE WHEN (R.Program_Rebates_Component_Name NOT LIKE '%DAA%' AND  R.Program_Rebates_Component_Name NOT LIKE '%LPA%') THEN 1
					ELSE 0 END AS isLoyalty
				from Program_Rebates_Component PRC
				INNER JOIN Program_Rebates_Component_Name R ON
						R.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_ID
				where Program_Id = '#arguments.contractId#' and
						PRC.deleted = 0 AND
						R.Program_Rebates_Component_Name NOT LIKE '%DAA%' AND
						R.Program_Rebates_Component_Name NOT LIKE '%LPA%'
				ORDER BY isLoyalty DESC
		</cfquery>
		<!--- <cfdump var="#compIdList#" output="c:/dump.log" /> --->
	<cfreturn qGetCPALoyaltyCompInfo.recordcount />
</cffunction>

<cffunction name="checkFixedComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />

		<cfquery name="qGetFixed" datasource="#application.datasource#">
			SELECT Count(F.Program_Fixed_Component_ID) AS FixedCount
			FROM Program_Fixed_Component F
			WHERE F.Program_ID = #arguments.contractId# AND
				  F.Deleted = 0
		</cfquery>

	<cfreturn qGetFixed.FixedCount />
</cffunction>

<cffunction name="deleteTiers" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	 <cfargument name="arrData" type="string" required="false" default="0" />
	<cfset var qSaveInfo = "" />

	<cfscript>
		// stuff
		var arr = deserializeJSON(arguments.arrData);
		for (i=1;i LTE ArrayLen(arr);i=i+1) {
			    myQry = new Query(datasource="#application.datasource#"); // new query object
			    myQry.setSQL("DELETE FROM GPO_Program_Tier_Data WHERE Contract_Main_Id = :contractid AND GPO_Program_Tier_Data_Id = :tierid"); //set query
			    myQry.addParam(name="tierid",value="#arr[i].id#",CFSQLTYPE="cf_sql_integer"); // add query param
			    myQry.addParam(name="contractid",value="#arguments.contractId#",CFSQLTYPE="cf_sql_integer"); // add query param
			    qryRes = myQry.execute(); // execute query
			   // writedump(var=qryRes.getResult(),output='c:\dump.log'); // dump result

		}
		//writedump(var=form,output='c:\dump.log');
	</cfscript>
	<cfreturn this.getTierData(arguments.contractId) />
</cffunction>

<cffunction name="deleteGPOProducts" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="aData" type="any" required="true" />
			<cfscript>
				// stuff
				var arrData = deserializeJson(aData);
				var a = arguments;
				var lCPid = '';
				for (i=1; i <= arrayLen(arrData);i=i+1) {
				    st = arrData[i];
				    lCPid = listappend(lCPid,st.contract_products_id);
				}
			</cfscript>
			<cfquery name="qDeletSelectedGPOProds" datasource="#application.datasource#" result='qDeletSelectedGPOProds'>
				DELETE PFPPD
				FROM  Contract_Products CP
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_ID = CP.Contract_Products_ID
				WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
					CP.Product_Type_ID = 1 AND
					CP.Contract_Products_ID in (<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

				DELETE FROM Contract_Products where Contract_Main_Id = #a.contractId# AND
					Contract_Products_Id IN(<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
			</cfquery>

			<cfreturn 'DELETE_GPO PRODUCTS'/>
	</cffunction>

<cffunction name="createComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
	<cfargument name="contractId" type="numeric" required="false" default="0" />
	<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />

		<cfquery name="qGetFixedComps" datasource="#application.datasource#">
				SELECT F.Program_Fixed_Component_Name_ID, External_ID, T.Tier_Number
				FROM GPO_Program_Tier_Data T
				INNER JOIN Program_Fixed_Component_Name f ON
						F.GPO_Program_Tier_Number = t.Tier_Number
				WHERE Contract_Main_ID = '#arguments.contractId#'
				ORDER BY T.tier_Number
		</cfquery>
		<cfquery name="qGetTiers" datasource="#application.datasource#">
			DECLARE
			@Program_Fixed_Component_Name_ID int,
			@External_ID VarChar(150),
			@Tier_Number INT,
			@Contract_Main_ID INT = '#arguments.contractId#',
			@Claim_Mechanics INT = '#arguments.Claim_Mechanics#',
			@GL_account_Id INT

			UPDATE Contract_Main
			SET ClaimMechanics = '#arguments.Claim_Mechanics#'
			WHERE Contract_Main_ID = @Contract_Main_ID

			DECLARE tmp_cursor CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
				SELECT F.Program_Fixed_Component_Name_ID, External_ID, T.Tier_Number, GL_account_Id
				FROM GPO_Program_Tier_Data T
				INNER JOIN Program_Fixed_Component_Name f ON
						F.GPO_Program_Tier_Number = t.Tier_Number
				LEFT JOIN GL_Component_Mapping GCM
					ON GCM.Discount_Type_ID = 1
					AND GCM.Component_Name_ID = f.Program_Fixed_Component_Name_ID
				WHERE Contract_Main_ID = @Contract_Main_ID AND NOT Exists(
									SELECT Program_Fixed_Component_Name_ID
									FROM Program_Fixed_Component PFC
									WHERE Program_ID = @Contract_Main_ID AND
											Deleted = 0 AND
											Program_Fixed_Component_Name_ID = F.Program_Fixed_Component_Name_ID
								)
				ORDER BY T.tier_Number

				UPDATE PFC Set Deleted = 1
				FROM Program_Fixed_Component PFC
				INNER JOIN Program_Fixed_Component_Name FN ON
					FN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
				LEFT JOIN GPO_Program_Tier_Data GPTD ON
					FN.Program_Fixed_Component_Name_ID = GPTD.Program_Fixed_Component_Name_ID AND
					GPTD.Contract_Main_ID = PFC.Program_ID AND
					GPTD.Deleted = 0
				WHERE Program_ID = @Contract_Main_ID AND
					PFC.Deleted = 0 AND
					GPTD.Program_Fixed_Component_Name_ID IS NULL

				 UPDATE PFPPD Set Deleted = 1
				 FROM Program_Fixed_Price_Product_Data PFPPD
				 LEFT JOIN Program_Fixed_Component PFC ON
					PFPPD.Program_ID = PFC.Program_Id AND
					PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND
					PFC.Deleted = 0
				 WHERE PFPPD.Program_ID = @Contract_Main_ID And
						PFPPD.Deleted = 0 AND
						PFC.Program_Fixed_Component_ID IS NULL

				OPEN tmp_cursor

					FETCH NEXT FROM tmp_cursor
					INTO @Program_Fixed_Component_Name_ID, @External_ID, @Tier_Number, @GL_account_Id

						WHILE @@FETCH_STATUS = 0
						BEGIN
						--Do Something
						SET NOCOUNT ON
						---- UPDATE Tier Data
						UPDATE GPO_Program_Tier_Data
						SET Program_Fixed_Component_Name_ID = @Program_Fixed_Component_Name_ID
						WHERE Tier_Number = @Tier_Number AND
							  Contract_Main_ID = @Contract_Main_ID
						---- INSERT Component

						INSERT INTO Program_Fixed_Component
						(
							Program_Fixed_Component_Name_ID,
							Fixed_Component_Paid_To,
							Program_ID,
							Claim_Mechanics,
							GL_Account_ID,
							Component_External_ID
							--,Payee_Type
						)
						VALUES
						(
							@Program_Fixed_Component_Name_ID,
							1,
							@Contract_Main_ID,
							@Claim_Mechanics,
							@GL_account_Id,
							@External_ID
							--,Payee_Type
						)
						SELECT Program_Fixed_Component_ID = @@IDENTITY
						SET NOCOUNT OFF

							-- Get the next tmp.
						FETCH NEXT FROM tmp_cursor
						INTO @Program_Fixed_Component_Name_ID, @External_ID, @Tier_Number, @GL_account_Id
					END
				CLOSE tmp_cursor
			DEALLOCATE tmp_cursor

				INSERT INTO Program_Fixed_Price_Product_Data
						(Program_ID, Contract_Products_ID, Fixed_Price_Value, Unit_Of_Measure_ID, Program_Fixed_Component_ID)
				SELECT CP.Contract_Main_Id, CP.Contract_Products_ID, 0, 1, PFC.Program_Fixed_Component_ID
				FROM Contract_Products CP
				INNER JOIN Program_Fixed_Component PFC ON
					CP.Contract_Main_Id = PFC.Program_Id AND
					PFC.Deleted = 0
				LEFT JOIN Program_Fixed_Price_Product_Data PFPPD ON
				    PFPPD.Program_ID = PFC.Program_Id AND
					PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND
					PFPPD.Contract_Products_ID = CP.Contract_Products_ID AND
					PFPPD.deleted = 0
				WHERE CP.Contract_Main_Id = @Contract_Main_ID AND
						PFPPD.Program_ID IS NULL

		</cfquery>
		<cfscript>
			// recalculate the rest of the tiers
			qGetProdTiers = this.getProdTiers(arguments.contractId,0,0);
			try {
				var arrPrdTiers = this.QueryToArray(qGetProdTiers);
				for (x=1;x LTE ArrayLen(arrPrdTiers);x=x+1) {
					var q = arrPrdTiers[x];
					This.dbInsertProducts(	q.contract_main_Id,
											q.BSA_Foodservice_Items_Master_ID,
											q.Program_Fixed_Component_ID,
											q.Rate,
											q.tier_number
											);
				}
			}
			catch (any e) {
			    writedump(var=e,output='c:\dump.log');
			    throw(message=e.message);
			}
		</cfscript>

		<!--- <cfset program_fixed_component_id = addNewFixedCategory.Program_Fixed_Component_ID> --->
	<cfreturn getProducts( #arguments.contractId# ) />
</cffunction>

	<cffunction name="saveProductOverride" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="any" required="false" default="0" />
		<cfargument name="compId" type="numeric" required="true" default="0" />
		<cfargument name="compIdList" type="numeric" required="false" default="0" />

		<cfscript>
				//writedump(var=arrFxComp,output='c:\dump.log');;
				var a = arguments;
				var st = deserializeJSON(a.stData);
				var price = replace(st['#a.compId#'],',','','ALL');
				var bClearOverride = 0;
				var rate = 0;
				var listPrice = 0;
				//abort;
				if(price == 0 || isnumeric(price) == false ){ // get price
					listPrice = this.getPriceFromList(contractId, st.BSA_Foodservice_Items_Master_ID).price;
					if(not isnumeric(listPrice)){listPrice = 0;}
					bClearOverride = 1;
					rate = this.getTierDataQuery(contractId,1).rate/100;
					price =  listPrice - (listPrice * rate);
				}
		</cfscript>

		<cfquery name="qUpdateUserPrice" datasource="#application.datasource#">
			UPDATE FPD
			SET
							Fixed_Price_Value 	= #price#,
							<cfif bClearOverride eq 1>
								User_Picked_Fixed_Price = NULL
							<cfelse>
								User_Picked_Fixed_Price = #price#
							</cfif>
			FROM	Contract_Products CP
			INNER JOIN Program_Fixed_Price_Product_Data FPD ON
				FPD.Contract_Products_ID = CP.Contract_Products_ID AND
				FPD.Deleted = 0
			INNER JOIN Program_Fixed_Component PFC ON
				PFC.Program_ID = CP.Contract_Main_Id AND
				PFC.Program_Fixed_Component_Id = FPD.Program_Fixed_Component_Id
			INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID AND
					PFCN.GPO_Program_Tier_Number = 1
			WHERE  CP.contract_products_id = '#st.contract_products_id#' AND
					CP.BSA_Foodservice_Items_Master_ID = '#st.BSA_Foodservice_Items_Master_ID#' AND
					CP.Deleted = 0
		</cfquery>



		<cfscript>
			// recalculate the rest of the tiers
			qGetProdTiers = this.getProdTiers(a.contractId,st.contract_products_id,st.BSA_Foodservice_Items_Master_ID);
			try {
				var arrPrdTiers = this.QueryToArray(qGetProdTiers);
				for (x=1;x LTE ArrayLen(arrPrdTiers);x=x+1) {
					var q = arrPrdTiers[x];
					This.dbInsertProducts(	q.contract_main_Id,
											q.BSA_Foodservice_Items_Master_ID,
											q.Program_Fixed_Component_ID,
											q.Rate,
											q.tier_number
											);
				}
			}
			catch (any e) {
			    writedump(var=e,output='c:\dump.log');
			    throw(message=e.message);
			}
		</cfscript>

		<cfreturn this.getProducts(arguments.contractId) />
	</cffunction>

	<cffunction name="getProdTiers" hint="" access="Public" output="false" returntype="query">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="contract_products_id" type="any" required="false" default="0" />
		<cfargument name="BSA_Foodservice_Items_Master_ID" type="any" required="false" default="0" />
		<cfscript>
				//writedump(var=arrFxComp,output='c:\dump.log');;
				var a = arguments;
		</cfscript>

		<cfquery name="qGetProdTiers" datasource="#application.datasource#">
			SELECT DISTINCT PFC.Program_Fixed_Component_ID, T.Tier_Number, t.rate , CP.BSA_Foodservice_Items_Master_ID, CP.Contract_Products_Id, CP.contract_main_Id
			FROM	Contract_Products CP
				INNER JOIN Program_Fixed_Price_Product_Data FPD ON
					FPD.Contract_Products_ID = CP.Contract_Products_ID AND
					FPD.Deleted = 0
				 INNER JOIN Program_Fixed_Component PFC ON
				 	PFC.Program_ID = CP.Contract_Main_Id AND
				 	PFC.Program_Fixed_Component_Id = FPD.Program_Fixed_Component_Id AND
				 	PFC.Deleted = 0
				 INNER JOIN  Program_Fixed_Component_Name PFCN ON
				 		PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				INNER JOIN GPO_Program_Tier_Data T ON
					pfcn.GPO_Program_Tier_Number = t.Tier_Number AND
					T.Contract_Main_ID = PFC.Program_Id
				WHERE <cfif a.contract_products_id NEQ 0> CP.contract_products_id = '#a.contract_products_id#' AND
						CP.BSA_Foodservice_Items_Master_ID = '#a.BSA_Foodservice_Items_Master_ID#' AND
					</cfif>
						CP.Contract_Main_ID = #contractId# AND
						PFCN.GPO_Program_Tier_Number != 1 AND
						CP.Deleted = 0
		</cfquery>

		<cfreturn qGetProdTiers />

	</cffunction>

	<cffunction name="saveProducts" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="arrData" type="any" required="false" default="0" />

		<cfquery name="qGetProgramFixedCompID" datasource="#application.datasource#">
			SELECT DISTINCT Program_Fixed_Component_ID, T.Rate, t.Tier_Number
			FROM 	Program_Fixed_Component PFC
			INNER JOIN Program_Fixed_Component_Name f ON
				F.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN GPO_Program_Tier_Data T ON
				F.GPO_Program_Tier_Number = t.Tier_Number AND
				T.Contract_Main_ID = PFC.Program_Id
			WHERE PFC.Program_Id = <cfqueryparam value="#arguments.contractId#" cfsqltype="cf_sql_integer" /> AND
				PFC.Deleted = 0 AND
				T.Deleted = 0 AND
				F.Deleted = 0

		</cfquery>

		<cfscript>
			// stuff
			try {
				var arrFxComp = this.QueryToArray(qGetProgramFixedCompID);
				//writedump(var=arrFxComp,output='c:\dump.log');
				var arr = deserializeJSON(arguments.arrData);
				var form = structNew();
				for (i=1;i LTE ArrayLen(arr);i=i+1) {
					form['#arr[i].name#'] = arr[i].value;
				}
				var arrProds = ListToArray(Form.Product_List);
				var existingProds = ListToArray(Form.ExistingProductList);
				var existingProdsTmp = ListToArray(Form.ExistingProductList);

				// get list of existing items we need to delete -> not in Product_List means see ya.
				for (n=1;n LTE ArrayLen(arrProds);n=n+1) {
					existingProds.delete(arrProds[n]);
				}
				//Only insert New Products so clean up the "new" list
				for (n=1;n LTE ArrayLen(existingProdsTmp);n=n+1) {
					arrProds.delete(existingProdsTmp[n]);
				}

				//from Program_Fixed_Price_Product_Data where Contract_Products_ID not in (select Contract_Products_ID from Contract_Products

				for (x=1;x LTE ArrayLen(arrFxComp);x=x+1) {
					var q = arrFxComp[x];
					for (i=1;i LTE ArrayLen(arrProds);i=i+1) {
						This.dbInsertProducts(	arguments.contractId,
												arrProds[i],
												q.Program_Fixed_Component_ID,
												q.Rate,
												q.tier_number
												);
					}
					for (iNum=1;iNum LTE ArrayLen(existingProds);iNum=iNum+1) {
						This.dbDeleteProducts(	arguments.contractId,
												existingProds[iNum],
												q.Program_Fixed_Component_ID
												);
					}
				}
			}
			catch (any e) {
			    writedump(var=e,output='c:\dump.log');
			    throw(message=e.message);
			}
		</cfscript>

		<cfreturn this.getProducts(arguments.contractId) />
	</cffunction>

	<cffunction name="dbInsertProducts" hint="" access="remote" output="false" returntype="string">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="item" type="any" required="true" default="" />
		<cfargument name="FixedCompId" type="numeric" required="true" default="0" />
		<cfargument name="Rate" type="numeric" required="true" default="0" />
		<cfargument name="tierNumber" type="numeric" required="true" default="0" />
		<cfargument name="Unit_Of_Measure_ID" type="any" required="false" default="1" />
		<cfscript>
			var a = arguments;
			var price = 0;  // Tier 1 uses list.  Tier 2 uses List 1 price
			var FixedPriceValue = 0;
			var prdRate = (a.rate/100); // turn rate to a percent
			var previousTier = a.tierNumber - 1;
			if(a.tierNumber == 1){ //get price list price.
				q = this.getProductTierPrice(a.contractID,a.item,0);
				if(q.recordcount){
					price = q.price; //check for an override rate
					FixedPriceValue =  price; //for Override, we don't apply the % discount
				}
				if(price == 0){
					q = this.getPriceFromList(contractId, item);
					if(not isnumeric(q.price)){price = 0;}else{price = q.price;}
					if(not isnumeric(q.Net_Weight)){weight = 1;}else{weight = q.Net_Weight;}
					// (ROUNDUP((([PPD Bracket 4 Price]/[PACK])-(([PPD Bracket 4 Price]/[PACK])*[PERCENTAGE])),2))*[PACK]
					FixedPriceValue =  ((Price/weight)-((Price/weight)*prdRate));// penny round
					FixedPriceValue = DecimalFormat((ceiling(numberformat(FixedPriceValue*100,'9999999.0000'))/100)*weight);// ROUND UP
					FixedPriceValue = replace(FixedPriceValue,',','','ALL');
				}

			}
			else{ //get fixed price from previous tier  Make sure to check if user entered a value on tier 1.  That is an override
				q = this.getProductTierPrice(a.contractID,a.item,previousTier);
				if(not isnumeric(q.price)){price = 0;}else{price = q.price;}
				if(not isnumeric(q.Net_Weight)){weight = 1;}else{weight = q.Net_Weight;}
				FixedPriceValue =  ((Price/weight)-((Price/weight)*prdRate));// penny round
				FixedPriceValue = DecimalFormat((ceiling(numberformat(FixedPriceValue*100,'9999999.0000'))/100)*weight); // ROUND UP
				FixedPriceValue = replace(FixedPriceValue,',','','ALL');
			}
		</cfscript>

			<CFQUERY NAME="GPOGet_Existing"  datasource="#application.datasource#">
					SELECT	ISNULL(Program_Fixed_Price_Product_Data_ID,0) AS Program_Fixed_Price_Product_Data_ID,
								CP.Contract_Products_ID
					FROM	Contract_Products CP
					LEFT JOIN Program_Fixed_Price_Product_Data FPD ON
						FPD.Contract_Products_ID = CP.Contract_Products_ID AND
						FPD.Program_Fixed_Component_ID = #a.FixedCompId# AND
						FPD.Deleted = 0
					WHERE  CP.Contract_main_Id = '#a.contractId#' AND
							CP.BSA_Foodservice_Items_Master_ID = '#item#' AND
							CP.Deleted = 0
			</CFQUERY>

			<CFIF GPOGet_Existing.recordcount EQ 0>
				<CFQUERY NAME="saveGPOContractProducts" datasource="#application.datasource#">
					INSERT INTO Contract_Products
					(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID)
					VALUES
					('#a.item#', '#a.contractId#', 1)
				</CFQUERY>
				<cfset contractProductsId = saveGPOContractProducts.Contract_Products_ID />
			<cfelse>
				<cfset contractProductsId = GPOGet_Existing.Contract_Products_ID />
			</CFIF>
				<!---XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					Calculate the price based on the Tier rate and Price List
						User_Picked_Fixed_Price for manual Overrides
				 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->

			<CFIF GPOGet_Existing.Program_Fixed_Price_Product_Data_ID EQ 0 OR GPOGet_Existing.recordcount EQ 0>
				<CFQUERY NAME="InsertNewGPOProduct" datasource="#application.datasource#">
					INSERT INTO Program_Fixed_Price_Product_Data
					(Program_ID, Contract_Products_ID, Fixed_Price_Value, Unit_Of_Measure_ID, Program_Fixed_Component_ID, Market_Price_Rate)
					VALUES
					('#a.contractId#', '#contractProductsId#', '#FixedPriceValue#', #a.Unit_Of_Measure_ID#, #a.FixedCompId#, #prdRate#)
				</CFQUERY>
			<CFELSE>
				<CFIF GPOGet_Existing.Program_Fixed_Price_Product_Data_ID NEQ 0>
					<!--- Make sure to check if user entered a value on tier 1.  That is an override --->
					<CFQUERY NAME="updateFixedPriceDataGPO" datasource="#application.datasource#">
						UPDATE Program_Fixed_Price_Product_Data
						SET
							Fixed_Price_Value 	= '#FixedPriceValue#',
							Unit_Of_Measure_ID	= #a.Unit_Of_Measure_ID#,
							Market_Price_Rate	= #prdRate#
						WHERE Program_Fixed_Price_Product_Data_ID = '#GPOGet_Existing.Program_Fixed_Price_Product_Data_ID#'
					</CFQUERY>
				</CFIF>
			</CFIF>

			<cfreturn a.item />
	</cffunction>

	<cffunction name="dbDeleteProducts" hint="" access="remote" output="false" returntype="string">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="item" type="any" required="true" default="" />
		<cfargument name="FixedCompId" type="numeric" required="true" default="0" />
		<cfscript>
			var a = arguments;
			//abort;
		</cfscript>
			<CFQUERY NAME="qDeleteFixedPriceDataGPO" datasource="#application.datasource#">
					DELETE  FPD
					FROM	Program_Fixed_Price_Product_Data FPD
					INNER JOIN Contract_Products CP ON
						FPD.Contract_Products_ID = CP.Contract_Products_ID AND
						FPD.Deleted = 0 AND
						CP.BSA_Foodservice_Items_Master_ID = '#item#' AND
						CP.Deleted = 0
					WHERE  FPD.Program_Id = '#a.contractId#' AND
						   FPD.Program_Fixed_Component_ID = #a.FixedCompId#

			</CFQUERY>
			<CFQUERY NAME="qDeleteContractProductsDataGPO" datasource="#application.datasource#">
					DELETE  CP
					FROM	Contract_Products CP
					LEFT JOIN Program_Fixed_Price_Product_Data FPD ON
						FPD.Contract_Products_ID = CP.Contract_Products_ID AND
						FPD.Deleted = 0 AND
						CP.Deleted = 0
					WHERE  CP.Contract_main_Id = '#a.contractId#' AND
							CP.BSA_Foodservice_Items_Master_ID = '#item#' AND
							CP.Product_Type_Id = 1 AND
							FPD.Program_Fixed_Price_Product_Data_ID IS NULL AND ---None left in FPD
							CP.Deleted = 0
			</CFQUERY>

			<cfreturn a.item />
	</cffunction>

	<cffunction name="getProductTierPrice" hint="" access="remote" output="false" returntype="query">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="item" type="any" required="true" default="" />
		<cfargument name="tierNumber" type="numeric" required="true" default="0" />
		<cfargument name="FixedCompId" type="numeric" required="true" default="0" />
		<cfset var a = arguments />
		<cfset var price = 0 />
		<cfset var tierNum = a.tierNumber />
			<cfquery name="qGetProductTierPrice" datasource="#application.datasource#">
				SELECT
				<cfif a.tierNumber eq 0 >
					<cfset tierNum = 1 />
					CAST(ISNULL(PFD.User_Picked_Fixed_Price,0) AS DECIMAL(14,2)) AS price
				<cfelse>
					CAST(ISNULL( NULLIF(PFD.User_Picked_Fixed_Price,0),PFD.Fixed_Price_Value) AS DECIMAL(14,2)) AS price
				</cfif>
				,I.Net_Weight
				FROM Program_Fixed_Component PFC
				INNER JOIN  Program_Fixed_Component_Name PFCN ON
					PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				INNER JOIN Program_Fixed_Price_Product_Data PFD ON
					PFD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					PFD.Deleted = 0
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PFD.Contract_Products_ID AND
					CP.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
				WHERE 	PFC.Program_ID = #a.contractId# AND
					CP.BSA_Foodservice_Items_Master_ID = '#a.item#' AND
					PFCN.GPO_Program_Tier_Number = #tierNum# AND
					PFC.Deleted = 0 AND
					PFCN.Deleted = 0
					--- pfc.Program_Fixed_Component_ID = a.FixedCompId
			</cfquery>
			<!--- <cfif qGetProductTierPrice.recordCount GT 0 >
				<cfset price = qGetProductTierPrice.Fixed_Price_Value />
			</cfif> --->
		<cfreturn qGetProductTierPrice />
	</cffunction>

	<cffunction name="getPriceFromList" hint="" access="remote" output="false" returntype="query">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="item" type="any" required="true" default="" />
		<cfset var a = arguments />
		<cfset var price = 0 />
			<cfquery name="qGetPrice" datasource="#application.datasource#">
				SELECT top 1 D.Price,I.Net_Weight
				FROM Price_List_Header H
				INNER JOIN Price_List_Detail D ON
					D.Price_List_Header_ID = H.Price_List_Header_ID
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_Id = D.Product_ID
				INNER JOIN Contract_Main CM ON
					CM.Contract_Main_Id = #a.contractId#
				WHERE H.GPO_Key IS NULL AND
						D.Product_Id  = '#a.item#' AND
						CM.Contract_Start_Date > D.Start_Date AND
						H.tier = 4
				ORDER BY D.Start_Date DESC
			</cfquery>
			<cfif qGetPrice.recordCount GT 0 >
				<cfset price = qGetPrice.Price />
			</cfif>
		<cfreturn qGetPrice />
	</cffunction>

	<cffunction name="getGPOList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
			<cfset useLakebaseForqGetGPOList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_gpo")>
<cfif useLakebaseForqGetGPOList>
	<cftry>
		<cfset qGetGPOList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operator_gpo", {
				"deleted" = "eq.0",
				"order" = "gpo_key.asc",
				"select" = "operator_gpo_id,gpo_key,gpo_name"
			}), "operator_gpo_id,gpo_key,gpo_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGPOList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGPOList>
<cfquery name="qGetGPOList" datasource="#application.datasource#">
				SELECT  Operator_GPO_ID,
						GPO_Key
						,GPO_Name
				FROM Operator_GPO
				 where deleted = 0
				Order by GPO_Key ASC
			</cfquery>
</cfif>

		<cfreturn application.util.query.toAgGridJSON(qGetGPOList, 'Operator_GPO_ID,GPO_Key,GPO_Name')  />
	</cffunction>

	<cffunction name="getPriceList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
			<cfquery name="qGetPriceList" datasource="#application.datasource#">
				SELECT Price_list_Id,
					isNull(gpo_Key,'NON-GPO') AS GPO_Key,
					Tier,
					Price_List_Header_Id
				FROM Price_List_Header H
				where GPO_Key IS NOT NULL AND Deleted = 0
				ORDER BY gpo_Key,Price_list_Id,tier
			</cfquery>

		<cfreturn application.util.query.toAgGridJSON(qGetPriceList, 'Price_list_Id,gpo_Key,Tier,Price_List_Header_Id')  />
	</cffunction>

	<cffunction name="getOverRidePriceList" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
			<cfquery name="qGetPriceList" datasource="#application.datasource#">
				SELECT Price_list_Id,
					isNull(gpo_Key,'NON-GPO') AS GPO_Key,
					Tier,
					Price_List_Header_Id
				FROM Price_List_Header H
				where GPO_Key IS NULL and deleted = 0
				ORDER BY gpo_Key,tier
			</cfquery>

		<cfreturn application.util.query.toAgGridJSON(qGetPriceList, 'Price_list_Id,gpo_Key,Tier,Price_List_Header_Id')  />
	</cffunction>
<!--- MASS APPLY RATES --->
	<cffunction name="updateCPACompRates" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="aData" type="any" required="true" />
		<cfargument name="compId" type="string" required="true" default="0" />
		<cfargument name="rate" type="numeric" required="true" default="0" />
			<cfscript>
				// stuff
				var arrData = deserializeJson(aData);
				var a = arguments;
				var st = {};
				var rId = 0;
				var s = '';
				for (i=1; i <= arrayLen(arrData);i=i+1) {
				    st = arrData[i];
				    rId = st['program_rebates_component_id_byname_#compId#'];
				    st['rate_#rId#'] = a.rate;
				    rid = 'rate_' & rid;
				    s = serializeJson(st);
				    saveCPAProductOverRide(a.contractId,s,rId);
				}

				//writedump(var=dId,output='c:\dump.log');
			</cfscript>

			<cfreturn 'MASSAPPLY'/>
	</cffunction>

	<cffunction name="deleteCPAProducts" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="aData" type="any" required="true" />
			<cfscript>
				// stuff
				var arrData = deserializeJson(aData);
				var a = arguments;
				var lBSAid = '';
				var lCPid = '';
				var lPRDid = '';
				var lCPFixedid = '';
				for (i=1; i <= arrayLen(arrData);i=i+1) {
				    st = arrData[i];
				    if(st.gpo_key == ''){ // only delete manually added items
				    	lBSAid = listappend(lBSAid,st.bsa_foodservice_items_master_id);
				    	lCPid = listappend(lCPid,st.contract_products_id);
				    	lCPid = listappend(lCPid,st.contract_products_id_fixed);
				    	lCPFixedid = listappend(lCPFixedid,st.contract_products_id_fixed);
				    	lPRDid = listappend(lPRDid,st.program_rebates_product_data_id);
					}
				}
			</cfscript>
			<cfquery name="qDeletSelectedCPAProds" datasource="#application.datasource#" result='qDeletSelectedCPAProds'>
				DELETE FROM PRCD
				FROM Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Rebates_Component_Id = PRCD.Program_Rebates_Component_ID
				WHERE PRC.program_Id = #a.contractId# AND
					Program_Rebates_Product_Data_ID IN (<cfqueryparam value="#lPRDid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

				DELETE FROM Program_Rebates_Product_Data
				WHERE program_Id = #a.contractId# AND
					Program_Rebates_Product_Data_ID IN (<cfqueryparam value="#lPRDid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

				DELETE PFPPD
				FROM  Contract_Products CP
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_ID = CP.Contract_Products_ID
				WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
					CP.Product_Type_ID = 1 AND
					CP.Contract_Products_ID in (<cfqueryparam value="#lCPFixedid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

				DELETE FROM Contract_Products where Contract_Main_Id = #a.contractId# AND
					Contract_Products_Id IN(<cfqueryparam value="#lCPid#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
			</cfquery>

			<cfreturn 'DELETE_CPA PRODUCTS'/>
	</cffunction>

	<cffunction name="deleteOneCPAComponent" hint="Mass Apply Rates" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="compId" type="string" required="true" default="0" />
			<cfscript>
				// stuff
				var a = arguments;
			</cfscript>

			<cfquery name="qDeleteOneCPAComponentProds" datasource="#application.datasource#" result='qDelOneCPACompProd'>
				DELETE FROM PRCD
				FROM Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Rebates_Component_Id = PRCD.Program_Rebates_Component_ID
				WHERE PRC.program_Id = #a.contractId# AND
					PRC.Program_Rebates_Component_Name_ID = #a.compID#
			</cfquery>
			<cfquery name="qDeleteOneCPAComponent" datasource="#application.datasource#" result='qDelOneCPAComp'>
				DELETE FROM Program_Rebates_Component
				WHERE program_Id = #a.contractId# AND
					Program_Rebates_Component_Name_ID = #a.compID#
			</cfquery>
			<!--- <cfdump var="#qDelOneCPACompProd#" output="c:\dump.log">
			<cfdump var="#qDelOneCPAComp#" output="c:\dump.log"> --->
			<cfscript>
				this.recalcCPAFixed(a.contractId);
			</cfscript>


			<cfreturn 'deleteCPAComponent'/>
	</cffunction>

	<cffunction name="saveCPAProductOverRide" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="stData" type="any" required="true" />
		<cfargument name="compId" type="string" required="true" default="0" />
			<cfscript>
				// stuff
				var st = deserializeJson(stData);
				var a = arguments;
				var rId = listLast(compId,'_');
				var rate = st['#compId#'];
				var dId = st['PROGRAM_REBATES_COMPONENT_DATA_ID_#rId#'];
			</cfscript>
			<cfquery name="qSaveCpaProdOverRide" datasource="#application.datasource#">
				UPDATE Program_Rebates_Component_Data
				SET RATE = #rate#
					--,Unit_Of_Measure_ID = 1
				WHERE Program_Rebates_Component_Data_id = #dId#
			</cfquery>
			<!--- UPDATE FIXED COMPONENTS--->
			<cftry>
			<cfquery name="qSaveFixedDsitPrice" datasource="#application.datasource#" result="qDistFixed">
				UPDATE FP
				SET Fixed_Price_Value =  CAST(  (CAST(Base_Sales_CS as decimal(12,4))) - TMP.Perc_RATE - TMP.Reb_RATE  AS  DECIMAL(12,2))
				FROM Program_Fixed_Price_Product_Data FP
				INNER JOIN (
				SELECT SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							0
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
							(CAST(((CAST(CP.Base_Sales_CS as decimal(12,4))/I.Net_Weight) * Rate/100) AS Decimal (12,2))* I.Net_Weight)
						ELSE 0 END)  AS Perc_RATE,
						SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							CAST(Rate as decimal(12,4))
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
								0
						ELSE 0 END)  AS Reb_RATE,
						PFPPD.Program_Fixed_Price_Product_Data_ID, Base_Sales_CS,I.Net_Weight
				FROM Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID AND
					PRPD.Deleted = 0
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_Id = PRPD.Contract_Products_ID AND
					CP.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CP.Contract_Main_Id AND
					PFC.Deleted = 0
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID AND
					PFCN.Deleted = 0 AND
					PFCN.Program_Fixed_Component_Name LIKE '%Distributor%'
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_Id = #st.contract_products_id_fixed# AND
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					PFPPD.Deleted = 0
				WHERE prpd.Contract_Products_Id = #st.Contract_Products_Id#  AND
					PRCD.Deleted = 0
				GROUP BY PFPPD.Program_Fixed_Price_Product_Data_ID,Base_Sales_CS,I.Net_Weight) AS Tmp ON
				FP.Program_Fixed_Price_Product_Data_ID = Tmp.Program_Fixed_Price_Product_Data_ID
			</cfquery>
			<!--- <cfdump var="#qDistFixed#" output="c:\dump.log"> --->
			<cfquery name="qSaveFixedEndUSerPrice" datasource="#application.datasource#" result="qEndUser">
				UPDATE FP
				SET Fixed_Price_Value =  CAST(  (CAST(CPF.Base_Sales_CS as decimal(12,4))) - ISNULL(TMP.Perc_RATE,0) - ISNULL(TMP.Reb_RATE,0)   AS  DECIMAL(12,2))

				FROM Program_Fixed_Price_Product_Data FP
				INNER JOIN Contract_Products CPF ON
					CPF.Contract_Products_ID = FP.Contract_Products_Id
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_ID = CPF.BSA_Foodservice_Items_Master_ID
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CPF.Contract_Main_Id AND
					PFC.Program_Fixed_Component_ID = FP.Program_Fixed_Component_ID AND
					PFC.Deleted = 0
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID AND
					PFCN.Deleted = 0 AND
					PFCN.Program_Fixed_Component_Name LIKE '%End USer%'
				LEFT JOIN (
				SELECT SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							0
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
							(CAST(((CAST(CP.Base_Sales_CS as decimal(12,4))/I.Net_Weight) * Rate/100) AS Decimal (12,2))* I.Net_Weight)
						ELSE 0 END)  AS Perc_RATE,
						SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							CAST(Rate as decimal(12,4))
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
								0
						ELSE 0 END)  AS Reb_RATE
						, PFPPD.Program_Fixed_Price_Product_Data_ID,Base_Sales_CS
				FROM Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Rebates_Component_Id = PRCD.Program_Rebates_Component_ID AND
					PRC.Deleted = 0
				INNER JOIN Program_Rebates_Component_Name PRCN ON
					PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID AND
					PRCN.Program_Rebates_Component_Name NOT LIKE '%DAA%'
				INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID AND
					PRPD.Deleted = 0
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_Id = PRPD.Contract_Products_ID AND
					CP.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CP.Contract_Main_Id AND
					PFC.Deleted = 0
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID AND
					PFCN.Deleted = 0 AND
					PFCN.Program_Fixed_Component_Name LIKE '%End USer%'
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_Id = #st.contract_products_id_fixed# AND
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					PFPPD.Deleted = 0
				WHERE prpd.Contract_Products_Id = #st.Contract_Products_Id# AND
					PRCD.deleted = 0
				GROUP BY PFPPD.Program_Fixed_Price_Product_Data_ID,Base_Sales_CS) AS Tmp ON
				FP.Program_Fixed_Price_Product_Data_ID = Tmp.Program_Fixed_Price_Product_Data_ID
				WHERE FP.Contract_Products_Id = #st.contract_products_id_fixed#
			</cfquery>
			 <!--- <cfdump var="#qEndUser#" output="c:\dump.log"> --->
				<cfcatch>
				<cfdump var="#cfcatch#" output="c:\dump.log">
				<cfrethrow>
			</cfcatch>
		</cftry>
			<!--- <cfdump var='#qEndUser#' output='c:\dump.log'> --->
		<cfreturn this.getCpaProducts(contractId,st.Contract_Products_Id,st.item) />
	</cffunction>

	<cffunction name="recalcCPAFixed" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
			<cfscript>
				// stuff
				var a = arguments;
			</cfscript>
			<!--- UPDATE FIXED COMPONENTS--->
			<cftry>
			<cfquery name="qrecalcFixedDsitPrice" datasource="#application.datasource#" result="qDistFixed">
				UPDATE FP
				SET Fixed_Price_Value = CAST(  (CAST(Base_Sales_CS as decimal(12,4))) - TMP.Perc_RATE - TMP.Reb_RATE  AS  DECIMAL(12,2))
				FROM Program_Fixed_Price_Product_Data FP
				INNER JOIN (
				SELECT SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							0
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
							(CAST(((CAST(CP.Base_Sales_CS as decimal(12,4))/I.Net_Weight) * Rate/100) AS Decimal (12,2))* I.Net_Weight)
						ELSE 0 END)  AS Perc_RATE,
						SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							CAST(Rate as decimal(12,4))
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
								0
						ELSE 0 END)  AS Reb_RATE,
						PFPPD.Program_Fixed_Price_Product_Data_ID, CP.Base_Sales_CS,I.Net_Weight
				FROM Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID AND
					PRPD.Deleted = 0
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_Id = PRPD.Contract_Products_ID AND
					CP.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CP.Contract_Main_Id AND
					PFC.Deleted = 0
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID AND
					PFCN.Deleted = 0 AND
					PFCN.Program_Fixed_Component_Name LIKE '%Distributor%'
				INNER JOIN Contract_Products CPF ON
					CPF.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID AND
					CPF.Product_Type_Id = 1 AND
					CP.Product_Type_Id = 2 AND
					CPF.Deleted = 0
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_Id = CPF.Contract_Products_Id AND
					PFPPD.Program_Id = #a.contractId# AND
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID AND
					PFPPD.deleted = 0
				WHERE    prpd.Program_Id = #a.contractId#  AND
				PRCD.Deleted = 0  ---  prpd.Contract_Products_Id = 586746
				GROUP BY PFPPD.Program_Fixed_Price_Product_Data_ID,CP.Base_Sales_CS,I.Net_Weight) AS Tmp ON
				FP.Program_Fixed_Price_Product_Data_ID = Tmp.Program_Fixed_Price_Product_Data_ID
			</cfquery>

			<cfquery name="qRecalcFixedEndUSerPrice" datasource="#application.datasource#" result="qEndUser">
				UPDATE FP
				SET Fixed_Price_Value =  CAST(  (CAST(CPF.Base_Sales_CS as decimal(12,4))) - ISNULL(TMP.Perc_RATE,0) - ISNULL(TMP.Reb_RATE,0)   AS  DECIMAL(12,2))
				FROM Program_Fixed_Price_Product_Data FP
				INNER JOIN Contract_Products CPF ON
					CPF.Contract_Products_ID = FP.Contract_Products_Id
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_ID = CPF.BSA_Foodservice_Items_Master_ID
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CPF.Contract_Main_Id AND
					PFC.Program_Fixed_Component_ID = FP.Program_Fixed_Component_ID AND
					PFC.Deleted = 0
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID AND
					PFCN.Deleted = 0 AND
					PFCN.Program_Fixed_Component_Name LIKE '%End USer%'
				LEFT JOIN (
				SELECT SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							0
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
							(CAST(((CAST(CP.Base_Sales_CS as decimal(12,4))/I.Net_Weight) * Rate/100) AS Decimal (12,2))* I.Net_Weight)
						ELSE 0 END)  AS Perc_RATE,
						SUM(CASE WHEN PRCD.Unit_Of_Measure_ID = 1 THEN
							CAST(Rate as decimal(12,4))
						WHEN PRCD.Unit_Of_Measure_ID = 3 THEN
								0
						ELSE 0 END)  AS Reb_RATE
						, PFPPD.Program_Fixed_Price_Product_Data_ID,cp.Base_Sales_CS
				FROM Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Rebates_Component_Id = PRCD.Program_Rebates_Component_ID
				INNER JOIN Program_Rebates_Component_Name PRCN ON
					PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID AND
					PRCN.Program_Rebates_Component_Name NOT LIKE '%DAA%' AND
					PRCN.Deleted = 0
				INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_Id = PRPD.Contract_Products_ID AND
					CP.Deleted = 0
				INNER JOIN BSA_Foodservice_Items_Master I ON
					I.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CP.Contract_Main_Id AND
					PFC.Deleted = 0
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_Id = PFC.Program_Fixed_Component_Name_ID AND
					PFCN.Deleted = 0 AND
					PFCN.Program_Fixed_Component_Name LIKE '%End USer%'
				INNER JOIN Contract_Products CPF ON
					CPF.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID AND
					CPF.Product_Type_Id = 1 AND
					CP.Product_Type_Id = 2 AND
					CPF.deleted = 0
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Contract_Products_Id = CPF.Contract_Products_Id AND
					PFPPD.Program_Id = #a.contractId# AND
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID
				WHERE  prpd.Program_Id = #a.contractId# AND
					PRCD.Deleted = 0
				GROUP BY PFPPD.Program_Fixed_Price_Product_Data_ID,cp.Base_Sales_CS) AS Tmp ON
				FP.Program_Fixed_Price_Product_Data_ID = Tmp.Program_Fixed_Price_Product_Data_ID
				WHERE cpf.contract_Main_Id = #a.contractId#
			</cfquery>
		<!--- 	<cfdump var="#qEndUser#" output="c:\dump.log"> --->
				<cfcatch>
				<cfdump var="#cfcatch#" output="c:\dump.log">
				<cfrethrow>
			</cfcatch>
		</cftry>
			<!--- <cfdump var='#qEndUser#' output='c:\dump.log'> --->
		<cfreturn 'RECALCPA' />
	</cffunction>


	<cffunction name="getRebateComps" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="isLoyalty" type="numeric" required="false" default="0" />
		<cfargument name="hasData" type="numeric" required="false" default="0" />
			<cfscript>
				// stuff
				var a = arguments;
				//var hasData = a.hasData; // checkCPARebateComp(a.contractId);
			</cfscript>
			<cfquery name="qGetRebateComps" datasource="#application.datasource#">
				SELECT 	'' AS chkbox,
						R.Program_Rebates_Component_Name_ID as CompId,
						R.Program_Rebates_Component_Name as name,
						CASE WHEN PRC.Program_Rebates_Component_Name_Id IS NOT NULL THEN 1
						ELSE 0
						END AS Selected
				FROM 	Contract_Main CM
				INNER JOIN	Program_Control_Panel_Options PCPO ON
					CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
				INNER JOIN Program_Template_Component ptc ON
					ptc.Template_ID = pcpo.ProgramControl_Panel_Options_ID
				INNER JOIN Program_Rebates_Component_Name R ON
					R.Program_Rebates_Component_Name_Id = PTC.Component_Id
				<cfif a.hasData EQ 0>
					LEFT
				<cfelse>
					INNER
				</cfif>
				JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id AND
					PRC.Program_Rebates_Component_Name_Id = R.Program_Rebates_Component_Name_Id AND
					PRC.Deleted = 0
				WHERE CM.Contract_Main_Id = #a.contractId# AND
				PTC.Deleted = 0 AND
				R.Deleted = 0 AND
				PTC.Discount_Type_Id = 2 AND
				<cfif a.isLoyalty EQ 0>
					(R.Program_Rebates_Component_Name LIKE '%DAA%' OR R.Program_Rebates_Component_Name LIKE '%LPA%')
				<cfelse>
					(R.Program_Rebates_Component_Name NOT LIKE '%DAA%' AND  R.Program_Rebates_Component_Name NOT LIKE '%LPA%')
				</cfif>
				<cfif a.hasData EQ 0>
					AND R.Active = 1
				</cfif>
				ORDER BY R.Program_Rebates_Component_Name
			</cfquery>

		<cfreturn application.util.query.toAgGridJSON(qGetRebateComps, 'compid,name,selected')  />
	</cffunction>



	<cffunction name="saveCPARebateComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="data" type="string" required="false" default="" />
		<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />

		<cfset variables.data = deserializeJSON(arguments.data) >

		<!--- <cfset useLakebaseForqDelRebateComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqDelRebateComps>
	<cftry>
		<cfset application.oLakebase.updateRows("program_rebates_component",
			{
				"program_id" = "eq.#arguments.contractId#",
				"program_rebates_component_name_id" = "eq.#variables.data.compid#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDelRebateComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDelRebateComps>
<cfquery name="qDelRebateComps" datasource="#application.datasource#">
			Update Program_Rebates_Component
			Set deleted = 1
			WHERE Program_Id = #arguments.contractId# AND
				Program_Rebates_Component_Name_Id = #variables.data.compid#
		</cfquery>
</cfif> --->

		<cfif variables.data.selected>
			<cfquery name="qInsRebateComps" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component
						(Program_ID,Program_Rebates_Component_Name_ID,Component_Paid_To, Claim_Mechanics, GL_account_Id)
				SELECT #arguments.contractId#,#variables.data.compid#, 1, #arguments.Claim_Mechanics#, GCM.GL_account_Id
				FROM Program_Rebates_Component_Name R
				LEFT JOIN GL_Component_Mapping GCM
					ON GCM.Discount_Type_ID = 2
					AND GCM.Component_Name_ID = R.Program_Rebates_Component_Name_ID
				WHERE R.Program_Rebates_Component_Name_ID = #variables.data.compid#


				UPDATE Contract_Main
				SET ClaimMechanics = '#arguments.Claim_Mechanics#'
				WHERE Contract_Main_ID = #arguments.contractId#
			</cfquery>

			<cfquery name="qInsCPACompDataUpdate" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component_Data (
					Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_ID, Is_Group
				)
				SELECT distinct
					PRC.Program_Rebates_Component_ID,
					PRPD.Program_Rebates_Product_Data_ID,
					 0 as Rate,
					 CASE WHEN R.Program_Rebates_Component_Name LIKE '%[%]%'
					 THEN 3 ELSE 1 END as Unit_Of_Measure_ID,
					 PRPD.Is_Group
				FROM Contract_Main CM
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id AND
					PRC.Program_Rebates_Component_Name_ID = #variables.data.compid#
				INNER JOIN Program_Rebates_Component_Name R ON
						R.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_ID
				INNER JOIN Contract_Products CP ON
					CP.Contract_Main_Id = CM.Contract_Main_Id
				INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Contract_Products_ID = CP.Contract_Products_ID
				WHERE CM.Contract_Main_Id = #arguments.contractId# AND
						PRC.Deleted = 0 AND
						CP.Deleted = 0 AND NOT EXISTS (SELECT Program_Rebates_Component_ID FROM Program_Rebates_Component_Data WHERE Program_Rebates_Component_ID = PRC.Program_Rebates_Component_ID)
			</cfquery>
		</cfif>

		<cfreturn 'SAVED'  />
	</cffunction>

	<cffunction name="saveCPAFixedComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />
		<!--- <cfset useLakebaseForqDelFixedComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForqDelFixedComps>
	<cftry>
		<cfset application.oLakebase.updateRows("program_fixed_component",
			{
				"program_id" = "eq.#arguments.contractId#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDelFixedComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDelFixedComps>
<cfquery name="qDelFixedComps" datasource="#application.datasource#">
			Update Program_Fixed_Component
			Set deleted = 1
			WHERE Program_Id = #arguments.contractId#
		</cfquery>
</cfif> --->
			<cfquery name="qInsFixedComps" datasource="#application.datasource#">
				INSERT INTO Program_Fixed_Component
						(Program_ID,Program_Fixed_Component_Name_Id,Fixed_Component_Paid_To, Claim_Mechanics, GL_account_Id)
				SELECT #arguments.contractId#,
					PFCN.Program_Fixed_Component_Name_Id,
					ISNULL(PTC.Default_Paid_To_CF_Pages,1) AS Fixed_Component_Paid_To,
					#arguments.Claim_Mechanics# AS Claim_Mechanics,
					GCM.GL_Account_Id
				FROM Program_Fixed_Component_Name PFCN
				INNER JOIN Contract_Main CM ON
					CM.Contract_Main_ID = #arguments.contractId#
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
				LEFT JOIN GL_Component_Mapping GCM
					ON GCM.Discount_Type_ID = 1
					AND GCM.Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
				LEFT JOIN Program_Template_Component PTC ON
					Template_Id = PCPO.ProgramControl_Panel_Options_ID AND
					PTC.Discount_Type_Id = 1 AND
					PTC.Component_Id = PFCN.Program_Fixed_Component_Name_ID AND
					PTC.Deleted = 0
				WHERE External_ID Like '%CPA%' AND
						PFCN.Deleted = 0 AND
						 NOT EXISTS(
								SELECT Program_ID FROM Program_Fixed_Component PFC2
								WHERE PFC2.Program_ID = #arguments.contractId# AND PFC2.Deleted = 0
							)

				UPDATE Contract_Main
				SET ClaimMechanics = '#arguments.Claim_Mechanics#'
				WHERE Contract_Main_ID = #arguments.contractId#
			</cfquery>

		<cfreturn 'SAVED'  />
	</cffunction>

	<cffunction name="checkCPARebateComp" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />

			<cfquery name="qGetCPArebate" datasource="#application.datasource#">
				SELECT Max(ISNULL(PFC.Program_Fixed_Component_ID,0)) AS iNumber
				FROM 	Contract_Main CM
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = PRC.Program_Id AND
					PFC.Deleted = 0
			---	INNER JOIN Program_Rebates_Product_Data PRPD ON
			---		PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
				WHERE CM.Contract_Main_Id = #arguments.contractId# AND
						PRC.Deleted = 0
			</cfquery>

		<cfreturn application.util.query.toAgGridJSON(qGetCPArebate, 'inumber') />
	</cffunction>

	<cffunction name="checkCPARebateCompHeader" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />

			<cfquery name="qGetCPArebate" datasource="#application.datasource#">
				SELECT Count(PRC.Program_Rebates_Component_ID) AS iNumber FROM 	Contract_Main CM
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id
				WHERE CM.Contract_Main_Id = #arguments.contractId# AND
						PRC.Deleted = 0
			</cfquery>

		<cfreturn qGetCPArebate.iNumber />
	</cffunction>

	<cffunction name="createCpaComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="LoyaltyCompId" type="numeric" required="false" default="0" />
		<cfargument name="Claim_Mechanics" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
			var data = {};
			data.compid = a.LoyaltyCompId;
			data.selected = 1;
			jsonData = serializeJson(data);
			if(checkCPARebateCompHeader(a.contractId) == 0 && a.LoyaltyCompId == 0){
				return('DONE No Rebate Comp Selected');
			}
			// transaction {
			// 	try {
				if(a.LoyaltyCompId > 0){
					saveCPARebateComp(a.contractId,jsonData,a.Claim_Mechanics);
				}
					saveCPAFixedComp(a.contractId,a.Claim_Mechanics);
					saveCpaProducts(a.contractId,a.Claim_Mechanics);
			// 		transaction action="commit";
			// 	}
			// 	catch(any e) {
			// 		transaction action="rollback";
			// 		throw e;
			// 	}
			// }
			//x= getCpaProducts(a.contractId);
			//writedump(var=form,output='c:\dump.log');
		</cfscript>

		<cfreturn 'DONE createCpaComponents'  />
	</cffunction>
<!--- 	<cffunction name="DefaultRateCalc" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />

			<cfscript>
				// stuff
				var arrData = [];
				var a = arguments;
				var aComps = deSerializeJson(getRebateComps(a.contractId));
				var st = {};
				var rId = 0;
				var s = '';
				for (i=1; i <= arrayLen(arrData);i=i+1) {
				    st = arrData[i];
				    rId = st['program_rebates_component_id_byname_#compId#'];
				    st['rate_#rId#'] = a.rate;
				    rid = 'rate_' & rid;
				    s = serializeJson(st);
				    saveCPAProductOverRide(a.contractId,s,rId);
				}

				//writedump(var=dId,output='c:\dump.log');
			</cfscript>


			<cfquery name="qSavePriceList" datasource="#application.datasource#">
				SELECT Price_list_Id,
					isNull(gpo_Key,'NON-GPO') AS GPO_Key,
					Tier,
					Price_List_Header_Id
				FROM Price_List_Header H
				ORDER BY gpo_Key,tier
			</cfquery>

		<cfreturn 'saved' />
	</cffunction>
 --->
	<cffunction name="deleteCpaComponents" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>
			<cfquery name="qDeleteCPArebate" datasource="#application.datasource#">
				DELETE FROM Contract_Products WHERE Contract_Main_Id = #a.contractId#
				DELETE FROM Program_Rebates_Product_Data WHERE program_ID = #a.contractId#
				DELETE FROM Program_Rebates_Component_Data WHERE Program_Rebates_Component_ID IN (SELECT Program_Rebates_Component_Id from Program_Rebates_Component where program_Id = #a.contractId# )
				DELETE FROM Program_Fixed_Price_Product_Data WHERE  Program_Fixed_Component_ID IN (SELECT Program_Fixed_Component_ID FROM Program_Fixed_Component PFC WHERE PFC.Program_ID =#a.contractId#)
				UPDATE Program_Rebates_Component Set Deleted = 1 WHERE program_Id = #a.contractId# AND deleted = 0
				UPDATE Program_Fixed_Component SET Deleted = 1 WHERE Program_ID = #a.contractId# And Deleted = 0
			</cfquery>

		<cfreturn 'DeleteCPAComponents Done' />
	</cffunction>

	<cffunction name="getCpaCompsQuery" hint="getCpaProducts" access="public" output="false" returntype="query">
		<cfargument name="contractId" type="numeric" required="true" default="0" />
		<cfscript>
			var qGetCpaComps = '';
			var a = arguments;
			//writedump(var=form,output='c:\dump.log');
		</cfscript>
		<cfquery name="qGetCpaComps" datasource="#application.datasource#">
				SELECT RN.Program_Rebates_Component_Name,
						RN.Program_Rebates_Component_Name_Id,
						PRC.Program_Rebates_Component_ID,
						convert(varchar, ISNULL(CM.Effective_Start_Date,Contract_Start_Date), 1) AS Contract_Start_Date,
						convert(varchar, ISNULL(CM.Effective_End_Date,Contract_End_Date), 1) AS Contract_End_Date,
						CM.Contract_Reference_Number
				FROM 	Contract_Main CM
				INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Id = CM.Contract_Main_Id
				INNER JOIN Program_Rebates_Component_Name RN ON
					RN.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_Id
				WHERE CM.Contract_Main_Id = #a.contractId# AND
						PRC.Deleted = 0
		</cfquery>

		<cfreturn qGetCpaComps/>
	</cffunction>

	<cffunction name="getCpaProducts" hint="getCpaProducts" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="true" default="0" />
		<cfargument name="ContractProdId" type="numeric" required="false" default="0" />
		<cfargument name="ProdId" type="string" required="false" default="" />
		<cfscript>
			var jsonData = '';
			var a = arguments;
			jsonData = serializeJson(getCpaProductsObject(a.contractId,a.ContractProdId,a.ProdId));
			//writedump(var=form,output='c:\dump.log');
		</cfscript>

		<cfreturn jsonData/>
	</cffunction>

	<cffunction name="getCpaProductsObject" hint="" access="Public" output="false" returntype="Array">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="ContractProdId" type="numeric" required="false" default="0" />
		<cfargument name="ProdId" type="string" required="false" default="" />
		<cfargument name="tier" type="numeric" required="false" default="4" />
		<cfargument name="overRidePricelistId" type="string" required="false" default="" />
		<cfscript>
			// stuff
			var a = arguments;
			var qGetCpaComps = getCpaCompsQuery(a.contractId);
		</cfscript>


		<cfquery name="qGetCpaFixedFComps" datasource="#application.datasource#">
				SELECT PFC.Program_Fixed_Component_ID,
					   PFCN.Program_Fixed_Component_Name_ID,
					   PFCN.Program_Fixed_Component_Name
				FROM Program_Fixed_Component PFC
				INNER JOIN Program_Fixed_Component_Name PFCN
					ON PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
				WHERE PFC.Program_ID = #a.contractId# AND
						PFC.Deleted = 0 AND
						PFCN.Deleted = 0
		</cfquery>
		<cfscript>
			var data = {};
			var data2 = {};
			var aResult = [];
			var qComps = qGetCpaComps;
			var qFixedComps = qGetCpaFixedFComps;
			var qProdData = '';
			var qProdFixData = '';
			var id = 0;
			var i = 1;
			var p = 1;
			for (compRow in qComps) {
			    qProdData = getCpaProductData(compRow.Program_Rebates_Component_ID,a.ContractProdId,a.tier,a.overRidePricelistId);
			    p=1;
			    for (dataRow in qProdData) {
				 	data = {};
				 	id = compRow.Program_Rebates_Component_ID;
				 	nameId = compRow.Program_Rebates_Component_Name_Id;
					data['program_rebates_component_id_#id#'] = compRow.Program_Rebates_Component_ID;
					data['program_rebates_component_name_#id#'] = compRow.Program_Rebates_Component_Name;
					data['program_rebates_component_name_id_#id#'] = compRow.Program_Rebates_Component_Name_Id;
				   	data['program_rebates_component_data_id_#id#']= dataRow.Program_Rebates_Component_Data_Id;
				   	data['program_rebates_component_id_byname_#nameId#']= dataRow.Program_Rebates_Component_ID;
					data['rate_#id#'] = dataRow.Rate;
					data['unit_of_measure_id_#id#'] = dataRow.Unit_Of_Measure_Id;

					if(i == 1){
						data['contract_products_id']= dataRow.contract_products_id;
					   	data['price_list_id'] = dataRow.price_list_id;
						data['gpo_key'] = dataRow.gpo_key;
						data['item'] = dataRow.item;
						data['description'] = dataRow.description;
						data['bsa_foodservice_items_master_id'] = dataRow.bsa_foodservice_items_master_id;
						data['start_date'] = dataRow.start_date;
						data['end_date'] = dataRow.end_date;
						data['base_sales_cs'] = dataRow.base_sales_cs;
						data['gpo_price'] = dataRow.gpo_price;
						data['list_price'] = dataRow.list_price;
						data['bracket4_Price'] = dataRow.price;
						data['program_rebates_product_data_id'] = dataRow.program_rebates_product_data_id;
						data['contract_start_date'] = compRow.Contract_Start_Date;
						data['contract_end_date'] = compRow.Contract_End_Date;
						data['contract_reference_number'] = compRow.Contract_Reference_Number;
						aResult.append(data);
					}
					else{
						data2 = {};
						data2 = aResult[P];
						data2.Append(data);
						aResult[P] = data2;
					}
					p++;
				}
				i++;
			}
			i=1;
			//-------------------------------------   GET FIXED   ------------------------------
			for (compFixRow in qFixedComps) {
			    qProdFixData = getCpaFixedProductData(compFixRow.Program_Fixed_Component_ID,a.contractId,a.ProdId);
			    //writedump(var=qProdFixData,output='c:\dump.log');
			    p=1;
			    for (dataFixRow in qProdFixData) {
				 	data = {};
				 	id = compFixRow.Program_Fixed_Component_ID;
				 	nameId = compFixRow.Program_Fixed_Component_Name_ID;
				 	if(! Isnumeric(dataFixRow.fixed_price_value)){
				 		dataFixRow.fixed_price_value = 0;
					}
					data['program_fixed_component_id_#id#'] = compFixRow.program_fixed_component_id;
					data['program_fixed_component_name_id_#id#'] = compFixRow.program_fixed_component_name_id;
					data['program_fixed_component_name_#id#'] = compFixRow.program_fixed_component_name;
				   	data['program_fixed_price_product_data_id_#id#']= dataFixRow.program_fixed_price_product_data_id;
				   	data['program_fixed_component_id_byname_#nameId#']= dataFixRow.program_fixed_component_id;
				   	if(compFixRow.program_fixed_component_name contains 'cust' || compFixRow.program_fixed_component_name contains 'dist'){
				   		data['fixed_price_value_customer'] = dataFixRow.fixed_price_value;
				    }
				    else{
					   	data['fixed_price_value_end_user'] = dataFixRow.fixed_price_value;
					}

					data['unit_of_measure_id_#id#'] = dataFixRow.unit_of_measure_id;
					if(i==1){
						data['contract_products_id_fixed']= dataFixRow.contract_products_id;
					}
					data2 = {};
					data2 = aResult[P];
					data2.Append(data);
					aResult[P] = data2;
					p++;
				}
				i++;
			}
			//jsonData = serializeJson(aResult);
			//writedump(var=form,output='c:\dump.log');
		</cfscript>

		<cfreturn aResult/>
	</cffunction>

	<cffunction name="getCpaProductData" hint="getCpaProductData" access="public" output="false" returntype="query">
		<cfargument name="ComponentId" type="numeric" required="false" default="0" />
		<cfargument name="ContractProdId" type="numeric" required="false" default="0" />
		<cfargument name="tier" type="numeric" required="false" default="4" />
		<cfargument name="overRidePricelistId" type="string" required="false" default="" />

		<cfquery name="qGetCpaProductData" datasource="#application.datasource#">
				SELECT PRCD.Program_Rebates_Component_Data_Id,
					   PRPD.Contract_products_Id,
					   PRPD.Program_Rebates_Product_Data_Id,
					   PRCD.Program_Rebates_Component_ID,
					   PRCD.Rate,
					   PRCD.Unit_Of_Measure_Id,
					   H.Price_List_Id,
					   ISNULL(H.GPO_Key,'') AS GPO_Key,
					   I.Item,
					   I.Description,
					   I.BSA_Foodservice_Items_Master_Id,
					   ISNULL(convert(varchar, D.Start_Date, 1),'') AS Start_Date,
					   IsNull(convert(varchar, D.end_Date, 1),'') AS end_Date,
					   CP.Base_Sales_CS,
					   CASE WHEN ISNULL(H.GPO_Key,'') = '' THEN
					     CAST(CP.Base_Sales_CS as decimal(12,2))
					   ELSE
					   	 0.00
					   END AS list_price,
					   CASE WHEN ISNULL(H.GPO_Key,'') = '' THEN
					     0.00
					   ELSE
					   	 CAST(CP.Base_Sales_CS as decimal(12,2))
					   END AS gpo_price,
					   <cfif arguments.tier NEQ 0 OR arguments.overRidePricelistId NEQ ''>
					  	 ISNULL(PLD.Price,CP.Base_Sales_CS) as Price
					   <cfelse>
					   		0 As Price
					   </cfif>
				FROM 	 Program_Rebates_Component_Data PRCD
				INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
				INNER JOIN Contract_Products CP ON
					CP.Contract_products_Id = PRPD.Contract_products_Id
				INNER JOIN Contract_Main CM ON
					CP.Contract_Main_Id = CM.Contract_Main_Id
				INNER JOIN Bsa_Foodservice_Items_MAster I ON
					I.Bsa_Foodservice_Items_MAster_Id = CP.Bsa_Foodservice_Items_MAster_Id
				LEFT JOIN Price_List_Detail D ON
					D.Price_List_Detail_Id = CP.Price_List_Id AND
					D.Product_Id = CP.Bsa_Foodservice_Items_Master_Id
				LEFT JOIN Price_List_Header H ON
					H.Price_List_Header_ID = D.Price_List_Header_ID
				<cfif arguments.tier NEQ 0 OR arguments.overRidePricelistId NEQ ''>
				OUTER APPLY(
						SELECT Top 1 PLD2.* from  Price_List_Detail pld2 WHERE
							pld2.Price_List_Header_ID =
							 <cfif arguments.tier EQ 0 AND arguments.overRidePricelistId NEQ ''>
							  '#arguments.overRidePricelistId#' AND
							<cfelse>
								(SELECT TOP 1 Price_List_Header_ID FROM Price_list_Header WHERE GPO_Key Is Null AND Tier = #arguments.tier#) AND
							</cfif>
							pld2.Product_Id = I.BSA_Foodservice_Items_Master_Id AND
							pld2.Deleted = 0 AND
							pld2.Start_Date <= CM.Contract_End_Date AND
								pld2.END_Date >= CM.Contract_Start_Date
								ORDER BY PLD2.End_DAte DESC) PLD
				</cfif>
				WHERE PRCD.Program_Rebates_Component_ID =  #arguments.ComponentId#  AND
						CP.Deleted = 0 AND
						PRCD.Deleted = 0 AND
						PRPD.Deleted = 0
						<cfif arguments.ContractProdID NEQ 0>
							AND CP.Contract_Products_Id = #arguments.ContractProdId#
						</cfif>
				order by I.Item,CP.Bsa_Foodservice_Items_Master_Id DESC
		</cfquery>
		<cfreturn qGetCpaProductData />
	</cffunction>

	<cffunction name="getCpaFixedProductData" hint="getCpaFixedProductData" access="public" output="false" returntype="query">
		<cfargument name="ComponentId" type="numeric" required="false" default="0" />
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="ProdId" type="string" required="false" default="" />

		<cfquery name="qGetCpaFixedProductData" datasource="#application.datasource#">
				SELECT PFC.Program_Fixed_Component_ID,
					  PFPPD.Program_Fixed_Price_Product_Data_ID,
					  PFPPD.Fixed_Price_Value,
					  PFPPD.Unit_Of_Measure_Id,
					  PFC.Program_Fixed_Component_Name_ID,
					  PFCN.Program_Fixed_Component_Name,
					  CP.Contract_Products_Id,
					  CP.BSA_Foodservice_Items_Master_Id
				FROM Program_Fixed_Component PFC
				INNER JOIN Program_Fixed_Component_Name PFCN ON
					PFCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
				INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
					PFPPD.Program_Fixed_Component_ID = PFC.Program_Fixed_Component_ID
				INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PFPPD.Contract_Products_ID
				INNER JOIN BSA_Foodservice_Items_Master I ON I.BSA_Foodservice_Items_Master_Id = CP.BSA_Foodservice_Items_Master_Id
				WHERE PFC.Program_ID = #arguments.contractId#  AND
					PFC.Program_Fixed_Component_Id =  #arguments.ComponentId# AND
					PFPPD.Program_ID = #arguments.contractId# AND
					CP.Deleted = 0 AND
					PFC.Deleted = 0 AND
					PFPPD.Deleted = 0
					<cfif arguments.ProdID NEQ ''>
						AND I.Item = '#arguments.ProdId#'
					</cfif>
				order by I.Item,CP.BSA_Foodservice_Items_Master_Id DESC
		</cfquery>

		<cfreturn qGetCpaFixedProductData />
	</cffunction>

	<cffunction name="saveCpaProducts" hint="save" access="public" output="false" returntype="any">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>
		<cftry>
		<cfquery name="qInsCpaProds" datasource="#application.datasource#">
				INSERT INTO Contract_Products(
					Contract_Main_ID,
					BSA_Foodservice_Items_Master_ID,
					Base_Sales_CS,
					Price_List_ID,
					Date_Created,
					Deleted,
					Product_Type_ID,
					Product_Process_Flag,
					Pricing_Level_ID,
					Is_Group,
					Product_Group_Level_ID,
					Dynamic_Static_Groups,
					Discounted_Item,
					Captured_From_Group,
					EZButton_On_Default,
					products_not_captured_flag,
					Include_In_Margin,
					Include_In_Volume
				)
				-- Need to remove duplicates and take the GPO Price List First
				SELECT
						cm.Contract_Main_ID AS Contract_Main_ID,
						pld.Product_ID AS BSA_Foodservice_Items_Master_ID,
						CAST(pld.Price AS Decimal(12,4)) AS Base_Sales_CS,
						pld.Price_List_Detail_ID AS Price_List_ID,
						GETDATE() AS Created_Date,
						0 AS Deleted,
						2 AS Product_Type_ID,
						0 AS Product_Process_Flag,
						1 AS Pricing_Level_ID,
						0 AS Is_Group,
						0 AS Product_Group_Level_ID,
						0 AS Dynamic_Static_Groups,
						1 AS Discounted_Item,
						0 AS Captured_From_Group,
						0 AS EZButton_On_Default,
						0 AS products_not_captured_flag,
						1 AS Include_In_Margin,
						1 AS Include_In_Volume
				FROM Contract_Main C
				INNER JOIN Contract_Main_Aux_Data CM ON
					CM.Contract_Main_ID = C.Contract_Main_ID
				INNER JOIN Price_List_Detail pld ON
					pld.Price_List_Header_ID = CM.Gpo_Price_List_Id AND
					pld.Deleted = 0
				WHERE C.Contract_Main_ID = #a.contractId# AND
						PLD.Start_Date <= C.Contract_End_Date AND
						PLD.END_Date >= C.Contract_Start_Date AND
						NOT EXISTS(SELECT BSA_Foodservice_Items_Master_ID FROM Contract_products CP
									WHERE CP.BSA_Foodservice_Items_Master_ID = pld.Product_ID AND
											CP.Contract_Main_Id = #a.contractId# AND
											CP.Deleted = 0 AND
											CP.Product_Type_ID = 2)
				ORDER BY 1, 4, 2


				INSERT INTO Contract_Products(
					Contract_Main_ID,
					BSA_Foodservice_Items_Master_ID,
					Base_Sales_CS,
					Price_List_ID,
					Date_Created,
					Deleted,
					Product_Type_ID,
					Product_Process_Flag,
					Pricing_Level_ID,
					Is_Group,
					Product_Group_Level_ID,
					Dynamic_Static_Groups,
					Discounted_Item,
					Captured_From_Group,
					EZButton_On_Default,
					products_not_captured_flag,
					Include_In_Margin,
					Include_In_Volume
				)
				-- Need to remove duplicates and take the GPO Price List First
				SELECT
						cm.Contract_Main_ID AS Contract_Main_ID,
						pld.Product_ID AS BSA_Foodservice_Items_Master_ID,
						CAST(pld.Price AS Decimal(12,4))  AS Base_Sales_CS,
						pld.Price_List_Detail_ID AS Price_List_ID,
						GETDATE() AS Created_Date,
						0 AS Deleted,
						2 AS Product_Type_ID,
						0 AS Product_Process_Flag,
						1 AS Pricing_Level_ID,
						0 AS Is_Group,
						0 AS Product_Group_Level_ID,
						0 AS Dynamic_Static_Groups,
						1 AS Discounted_Item,
						0 AS Captured_From_Group,
						0 AS EZButton_On_Default,
						0 AS products_not_captured_flag,
						1 AS Include_In_Margin,
						1 AS Include_In_Volume
				FROM Contract_Main C
				INNER JOIN Contract_Main_Aux_Data CM ON
					Cm.Contract_Main_ID = C.Contract_Main_ID
				INNER JOIN Price_List_Detail pld ON
					pld.Price_List_Header_ID = CM.NonGpo_Price_List_Id AND
					pld.Deleted = 0
				WHERE C.Contract_Main_ID = #a.contractId# AND
						PLD.Start_Date <= C.Contract_End_Date AND
						PLD.END_Date >= C.Contract_Start_Date AND
						NOT EXISTS(SELECT BSA_Foodservice_Items_Master_ID FROM Contract_products CP
									WHERE CP.BSA_Foodservice_Items_Master_ID = pld.Product_ID AND
											CP.Contract_Main_Id = #a.contractId# AND
											CP.Deleted = 0 AND
											CP.Product_Type_ID = 2)   --@Contract_Main_ID
				ORDER BY 1, 4,2;

				WITH Dupe As
				(
				SELECT
					CP.Contract_Main_Id,
					CP.Contract_products_ID,
					BSA_Foodservice_Items_Master_ID,
					ROW_NUMBER() OVER(PARTITION BY BSA_Foodservice_Items_Master_ID ORDER BY BSA_Foodservice_Items_Master_ID,PLD.End_Date DESC) AS RowNum
					FROM Contract_Products CP
					INNER JOIN Price_List_Detail PLD  ON
						PLD.Price_List_Detail_Id  = CP.Price_List_ID
					WHERE CP.Contract_Main_Id = #a.contractId#  AND
						  CP.Deleted = 0 AND
						  CP.Product_Type_ID = 2
				)
				--Now Delete Duplicate Records
				Delete CP
				FROM Contract_Products CP
				INNER JOIN Dupe D ON
					D.Contract_products_ID = CP.Contract_products_ID
				Where RowNum > 1
		</cfquery>
		<cfquery name="qInsFixedContractProd" datasource="#application.datasource#">
			INSERT INTO Contract_Products(
					Contract_Main_ID,
					BSA_Foodservice_Items_Master_ID,
					Base_Sales_CS,
					Price_List_ID,
					Date_Created,
					Deleted,
					Product_Type_ID,
					Product_Process_Flag,
					Pricing_Level_ID,
					Is_Group,
					Product_Group_Level_ID,
					Dynamic_Static_Groups,
					Discounted_Item,
					Captured_From_Group,
					EZButton_On_Default,
					products_not_captured_flag,
					Include_In_Margin,
					Include_In_Volume
				)
			SELECT Contract_Main_ID,
					BSA_Foodservice_Items_Master_ID,
					Base_Sales_CS,
					Price_List_ID,
					Date_Created,
					Deleted,
					1,
					Product_Process_Flag,
					Pricing_Level_ID,
					Is_Group,
					Product_Group_Level_ID,
					Dynamic_Static_Groups,
					Discounted_Item,
					Captured_From_Group,
					EZButton_On_Default,
					products_not_captured_flag,
					Include_In_Margin,
					Include_In_Volume
			FROM Contract_Products
			WHERE Contract_Main_ID = #a.contractId# AND
					Product_Type_ID = 2 AND
					Deleted = 0
		</cfquery>

		<cfquery name="qInsCPAComps" datasource="#application.datasource#">
			INSERT INTO Program_Rebates_Product_Data (
					Program_ID,
					Contract_Products_ID
				)
				SELECT
					CM.Contract_Main_Id,
					CP.Contract_Products_Id
				FROM Contract_Main CM
				INNER JOIN Contract_Products CP ON
					CP.Contract_Main_Id = CM.Contract_Main_Id
				WHERE CM.Contract_Main_Id = #a.contractId#  AND
						CP.Deleted = 0 AND
						CP.Product_Type_ID = 2
		</cfquery>
		<cfquery name="qInsCPACompData" datasource="#application.datasource#">
			INSERT INTO Program_Rebates_Component_Data (
				Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_ID, Is_Group
			)
			SELECT distinct
				PRC.Program_Rebates_Component_ID,
				PRPD.Program_Rebates_Product_Data_ID,
				 0 as Rate,
				 CASE WHEN R.Program_Rebates_Component_Name LIKE '%[%]%'
				 THEN 3 ELSE 1 END as Unit_Of_Measure_ID,
				 PRPD.Is_Group
			FROM Contract_Main CM
			INNER JOIN Program_Rebates_Component PRC ON
				PRC.Program_Id = CM.Contract_Main_Id
			INNER JOIN Program_Rebates_Component_Name R ON
					R.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_ID
			INNER JOIN Contract_Products CP ON
				CP.Contract_Main_Id = CM.Contract_Main_Id
			INNER JOIN Program_Rebates_Product_Data PRPD ON
				PRPD.Contract_Products_ID = CP.Contract_Products_ID
			WHERE CM.Contract_Main_Id = #a.contractId# AND
					PRC.Deleted = 0 AND
					CP.Deleted = 0
		</cfquery>
		<cfquery name="qInsCPAFixedCompData" datasource="#application.datasource#">
			INSERT INTO Program_Fixed_Price_Product_Data (
					Program_ID,
					Contract_Products_ID,
					Fixed_Price_Value,
					Unit_Of_Measure_ID,
					Program_Fixed_Component_ID
				)
				SELECT
					CM.Contract_Main_Id,
					CP.Contract_Products_Id,
					CP.Base_Sales_Cs,
					1 as Unit_Of_Measure_ID,
					PFC.Program_Fixed_Component_ID
				FROM Contract_Main CM
				INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_ID = CM.Contract_Main_Id AND
					PFC.Deleted = 0
				INNER JOIN Contract_Products CP ON
					CP.Contract_Main_Id = CM.Contract_Main_Id
				WHERE CM.Contract_Main_Id = #a.contractId#  AND
						CP.Deleted = 0 AND
						CP.Product_Type_ID = 1
		</cfquery>
		<cfcatch>
				<cfdump var="#cfcatch#" output="c:\dump.log">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn 'done' />

	</cffunction>

	<cffunction name="saveSelectedCpaProducts" hint="save" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="arrData" type="any" required="false" default="0" />

		<cfscript>
			// stuff
			try {
				var a = arguments;
				//writedump(var=arrFxComp,output='c:\dump.log');
				var arr = deserializeJSON(arguments.arrData);
				var form = structNew();
				for (i=1;i LTE ArrayLen(arr);i=i+1) {
					form['#arr[i].name#'] = arr[i].value;
				}
				var arrProds = ListToArray(Form.Product_List);
				var existingProds = ListToArray(Form.ExistingProductList);
				var existingProdsTmp = ListToArray(Form.ExistingProductList);

				// get list of existing items we need to delete -> not in Product_List means see ya.
				for (n=1;n LTE ArrayLen(arrProds);n=n+1) {
					existingProds.delete(arrProds[n]);
				}
				//Only insert New Products so clean up the "new" list
				for (n=1;n LTE ArrayLen(existingProdsTmp);n=n+1) {
					arrProds.delete(existingProdsTmp[n]);
				}

				insProds = ArrayToList(arrProds);
				delProds = ArrayToList(existingProds);


				//from Program_Fixed_Price_Product_Data where Contract_Products_ID not in (select Contract_Products_ID from Contract_Products

				// for (x=1;x LTE ArrayLen(arrFxComp);x=x+1) {
				// 	var q = arrFxComp[x];
				// 	for (i=1;i LTE ArrayLen(arrProds);i=i+1) {
				// 		This.dbInsertProducts(	arguments.contractId,
				// 								arrProds[i],
				// 								q.Program_Fixed_Component_ID,
				// 								q.Rate,
				// 								q.tier_number
				// 								);
				// 	}
				// 	for (iNum=1;iNum LTE ArrayLen(existingProds);iNum=iNum+1) {
				// 		This.dbDeleteProducts(	arguments.contractId,
				// 								existingProds[iNum],
				// 								q.Program_Fixed_Component_ID
				// 								);
				// 	}
				// }
			}
			catch (any e) {
			    writedump(var=e,output='c:\dump.log');
			    throw(message=e.message);
			}
		</cfscript>
		<cftry>
			<cfif len(trim(insProds)) GT 0>
				<cfquery name="qInsSelectedCpaProds" datasource="#application.datasource#">
						INSERT INTO Contract_Products(
							Contract_Main_ID,
							BSA_Foodservice_Items_Master_ID,
							Base_Sales_CS,
							Price_List_ID,
							Date_Created,
							Deleted,
							Product_Type_ID,
							Product_Process_Flag,
							Pricing_Level_ID,
							Is_Group,
							Product_Group_Level_ID,
							Dynamic_Static_Groups,
							Discounted_Item,
							Captured_From_Group,
							EZButton_On_Default,
							products_not_captured_flag,
							Include_In_Margin,
							Include_In_Volume
						)
						-- Need to remove duplicates and take the GPO Price List First
						SELECT
								cm.Contract_Main_ID AS Contract_Main_ID,
								I.BSA_Foodservice_Items_Master_Id AS BSA_Foodservice_Items_Master_ID,
								pld.Price AS Base_Sales_CS,
								pld.Price_List_Detail_ID AS Price_List_ID,
								GETDATE() AS Created_Date,
								0 AS Deleted,
								2 AS Product_Type_ID,
								0 AS Product_Process_Flag,
								1 AS Pricing_Level_ID,
								0 AS Is_Group,
								0 AS Product_Group_Level_ID,
								0 AS Dynamic_Static_Groups,
								1 AS Discounted_Item,
								0 AS Captured_From_Group,
								0 AS EZButton_On_Default,
								0 AS products_not_captured_flag,
								1 AS Include_In_Margin,
								1 AS Include_In_Volume
						FROM Contract_Main C
						INNER JOIN Contract_Main_Aux_Data CM ON
							CM.Contract_Main_ID = C.Contract_Main_ID
						INNER JOIN BSA_Foodservice_Items_Master I ON
							I.BSA_Foodservice_Items_Master_Id in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"/>)
						CROSS APPLY(
						SELECT Top 1 PLD2.* from  Price_List_Detail pld2 WHERE
							pld2.Price_List_Header_ID = (SELECT TOP 1 Price_List_Header_ID FROM Price_list_Header WHERE GPO_Key Is Null AND Tier = 4) AND
							pld2.Product_Id = I.BSA_Foodservice_Items_Master_Id AND
							pld2.Deleted = 0 AND
							pld2.Start_Date <= C.Contract_End_Date AND
								pld2.END_Date >= C.Contract_Start_Date
								ORDER BY PLD2.End_DAte DESC) PLD
						WHERE 	C.Contract_Main_ID = #a.contractId# AND
								PLD.Start_Date <= C.Contract_End_Date AND
								PLD.END_Date >= C.Contract_Start_Date AND
								NOT EXISTS(SELECT BSA_Foodservice_Items_Master_ID FROM Contract_products CP
											WHERE CP.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_Id  AND
													CP.Contract_Main_Id = #a.contractId# AND
													CP.Deleted = 0 AND
													CP.Product_Type_ID = 2)
						ORDER BY 1, 4, 2
				</cfquery>
					<!--- Some items are not on bracket 4 price list --->
				<cfquery name="qInsSelectedCpaProdsFromPricelist2" datasource="#application.datasource#">
						INSERT INTO Contract_Products(
							Contract_Main_ID,
							BSA_Foodservice_Items_Master_ID,
							Base_Sales_CS,
							Price_List_ID,
							Date_Created,
							Deleted,
							Product_Type_ID,
							Product_Process_Flag,
							Pricing_Level_ID,
							Is_Group,
							Product_Group_Level_ID,
							Dynamic_Static_Groups,
							Discounted_Item,
							Captured_From_Group,
							EZButton_On_Default,
							products_not_captured_flag,
							Include_In_Margin,
							Include_In_Volume
						)
						-- Need to remove duplicates and take the GPO Price List First
						SELECT
								cm.Contract_Main_ID AS Contract_Main_ID,
								I.BSA_Foodservice_Items_Master_Id AS BSA_Foodservice_Items_Master_ID,
								pld.Price AS Base_Sales_CS,
								pld.Price_List_Detail_ID AS Price_List_ID,
								GETDATE() AS Created_Date,
								0 AS Deleted,
								2 AS Product_Type_ID,
								0 AS Product_Process_Flag,
								1 AS Pricing_Level_ID,
								0 AS Is_Group,
								0 AS Product_Group_Level_ID,
								0 AS Dynamic_Static_Groups,
								1 AS Discounted_Item,
								0 AS Captured_From_Group,
								0 AS EZButton_On_Default,
								0 AS products_not_captured_flag,
								1 AS Include_In_Margin,
								1 AS Include_In_Volume
						FROM Contract_Main C
						INNER JOIN Contract_Main_Aux_Data CM ON
							CM.Contract_Main_ID = C.Contract_Main_ID
						INNER JOIN BSA_Foodservice_Items_Master I ON
							I.BSA_Foodservice_Items_Master_Id in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"/>)
						CROSS APPLY(
						SELECT Top 1 PLD2.* from  Price_List_Detail pld2 WHERE
							pld2.Price_List_Header_ID = (SELECT TOP 1 Price_List_Header_ID FROM Price_list_Header WHERE GPO_Key Is Null AND Tier = 1) AND
							pld2.Product_Id = I.BSA_Foodservice_Items_Master_Id AND
							pld2.Deleted = 0 AND
							pld2.Start_Date <= C.Contract_End_Date AND
								pld2.END_Date >= C.Contract_Start_Date
								ORDER BY PLD2.End_DAte DESC) PLD
						WHERE 	C.Contract_Main_ID = #a.contractId# AND
								PLD.Start_Date <= C.Contract_End_Date AND
								PLD.END_Date >= C.Contract_Start_Date AND
								NOT EXISTS(SELECT BSA_Foodservice_Items_Master_ID FROM Contract_products CP
											WHERE CP.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_Id  AND
													CP.Contract_Main_Id = #a.contractId# AND
													CP.Deleted = 0 AND
													CP.Product_Type_ID = 2)
						ORDER BY 1, 4, 2
				</cfquery>

				<cfquery name="qInsSelectedFixedContractProd" datasource="#application.datasource#">
					INSERT INTO Contract_Products(
							Contract_Main_ID,
							BSA_Foodservice_Items_Master_ID,
							Base_Sales_CS,
							Price_List_ID,
							Date_Created,
							Deleted,
							Product_Type_ID,
							Product_Process_Flag,
							Pricing_Level_ID,
							Is_Group,
							Product_Group_Level_ID,
							Dynamic_Static_Groups,
							Discounted_Item,
							Captured_From_Group,
							EZButton_On_Default,
							products_not_captured_flag,
							Include_In_Margin,
							Include_In_Volume
						)
					SELECT Contract_Main_ID,
							CP.BSA_Foodservice_Items_Master_ID,
							Base_Sales_CS,
							Price_List_ID,
							Date_Created,
							0,
							1,
							Product_Process_Flag,
							Pricing_Level_ID,
							Is_Group,
							Product_Group_Level_ID,
							Dynamic_Static_Groups,
							Discounted_Item,
							Captured_From_Group,
							EZButton_On_Default,
							products_not_captured_flag,
							Include_In_Margin,
							Include_In_Volume
					FROM Contract_Products CP
					INNER JOIN BSA_Foodservice_Items_Master I ON
						CP.BSA_Foodservice_Items_Master_ID = I.BSA_Foodservice_Items_Master_Id AND
						I.BSA_Foodservice_Items_Master_Id in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
					WHERE Contract_Main_ID = #a.contractId# AND
							CP.Product_Type_ID = 2 AND
							CP.Deleted = 0
				</cfquery>

				<cfquery name="qInsCPAComps" datasource="#application.datasource#">
					INSERT INTO Program_Rebates_Product_Data (
							Program_ID,
							Contract_Products_ID
						)
						SELECT
							CM.Contract_Main_Id,
							CP.Contract_Products_Id
						FROM Contract_Main CM
						INNER JOIN Contract_Products CP ON
							CP.Contract_Main_Id = CM.Contract_Main_Id AND
							CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
						WHERE CM.Contract_Main_Id = #a.contractId#  AND
								CP.Deleted = 0 AND
								CP.Product_Type_ID = 2
				</cfquery>
				<cfquery name="qInsCPACompData" datasource="#application.datasource#">
					INSERT INTO Program_Rebates_Component_Data (
						Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_ID, Is_Group
					)
					SELECT distinct
						PRC.Program_Rebates_Component_ID,
						PRPD.Program_Rebates_Product_Data_ID,
						 0 as Rate,
						 CASE WHEN R.Program_Rebates_Component_Name LIKE '%[%]%'
						 THEN 3 ELSE 1 END as Unit_Of_Measure_ID,
						 PRPD.Is_Group
					FROM Contract_Main CM
					INNER JOIN Program_Rebates_Component PRC ON
						PRC.Program_Id = CM.Contract_Main_Id
					INNER JOIN Program_Rebates_Component_Name R ON
							R.Program_Rebates_Component_Name_Id = PRC.Program_Rebates_Component_Name_ID
					INNER JOIN Contract_Products CP ON
						CP.Contract_Main_Id = CM.Contract_Main_Id AND
						CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
					INNER JOIN Program_Rebates_Product_Data PRPD ON
						PRPD.Contract_Products_ID = CP.Contract_Products_ID
					WHERE CM.Contract_Main_Id = #a.contractId# AND
							PRC.Deleted = 0 AND
							CP.Deleted = 0
				</cfquery>
				<cfquery name="qInsCPAFixedCompData" datasource="#application.datasource#">
					INSERT INTO Program_Fixed_Price_Product_Data (
							Program_ID,
							Contract_Products_ID,
							Fixed_Price_Value,
							Unit_Of_Measure_ID,
							Program_Fixed_Component_ID
						)
						SELECT
							CM.Contract_Main_Id,
							CP.Contract_Products_Id,
							CP.Base_Sales_Cs,
							1 as Unit_Of_Measure_ID,
							PFC.Program_Fixed_Component_ID
						FROM Contract_Main CM
						INNER JOIN Program_Fixed_Component PFC ON
							PFC.Program_ID = CM.Contract_Main_Id AND
							PFC.Deleted = 0
						INNER JOIN Contract_Products CP ON
							CP.Contract_Main_Id = CM.Contract_Main_Id AND
							CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#insProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)
						WHERE CM.Contract_Main_Id = #a.contractId#  AND
								CP.Deleted = 0 AND
								CP.Product_Type_ID = 1
				</cfquery>
			</cfif>
			<cfif len(trim(delProds)) GT 0>
				<cfquery name="qDeleteCPArebate" datasource="#application.datasource#">
					DELETE PRCD
					FROM  Contract_Products CP
					INNER JOIN Program_Rebates_Product_Data PRPD ON
						PRPD.Contract_Products_ID = CP.Contract_Products_ID
					INNER JOIN Program_Rebates_Component_Data PRCD ON
						PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
					WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
						CP.Product_Type_ID = 2 AND
						CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

					DELETE PRPD
					FROM  Contract_Products CP
					INNER JOIN Program_Rebates_Product_Data PRPD ON
						PRPD.Contract_Products_ID = CP.Contract_Products_ID
					WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
						CP.Product_Type_ID = 2 AND
						CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

					DELETE PFPPD
					FROM  Contract_Products CP
					INNER JOIN Program_Fixed_Price_Product_Data PFPPD ON
						PFPPD.Contract_Products_ID = CP.Contract_Products_ID
					WHERE 	CP.Contract_Main_Id = #a.contractId#  AND
						CP.Product_Type_ID = 1 AND
						CP.BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

					DELETE FROM Contract_Products WHERE Contract_Main_Id = #a.contractId# AND BSA_Foodservice_Items_Master_ID in (<cfqueryparam value="#delProds#" cfsqltype="CF_SQL_VARCHAR" list="true"  />)

				</cfquery>
			</cfif>

			<cfcatch>
				<cfdump var="#cfcatch#" output="c:\dump.log">
				<cfrethrow>
			</cfcatch>
		</cftry>

		<cfreturn 'done' />

	</cffunction>

	<cffunction name="createAdminFee" hint="" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="contractId" type="numeric" required="false" default="0" />
		<cfargument name="createdBy" type="string" required="false" default="0" />
		<cfscript>
			// stuff
			var a = arguments;
		</cfscript>
		<cftry>
			<!--- <cfquery name="qCreateAdminFee" datasource="#application.datasource#">
				-- DECLARE
				-- @Ret_Contract_Main_ID INT

				EXEC Create_Admin_Fee_Program  #a.contractId#,'#a.createdBy#'

				----SELECT @Ret_Contract_Main_ID AS Ret_Contract_Main_ID
			</cfquery> --->
			<CFSTOREDPROC PROCEDURE="Create_Admin_Fee_Program" datasource="#application.datasource#">
	            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_INTEGER"  DBVARNAME="@Contract_Main_Id"      VALUE="#a.contractId#">
	            <CFPROCPARAM TYPE="In"  CFSQLTYPE="CF_SQL_VARCHAR"  DBVARNAME="@Created_By"            VALUE="#a.createdBy#">
	            <CFPROCPARAM TYPE="Out" CFSQLTYPE="CF_SQL_INTEGER"  DBVARNAME="@Ret_Contract_Main_ID"  VARIABLE="Renewed_Program_ID">
	        </CFSTOREDPROC>
			<cfcatch>
				<cfdump var="#cfcatch#" output="c:\dump.log">
				<cfrethrow>
			</cfcatch>
		</cftry>

		<cftry>
			<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.user_id#">
				<cfprocparam type="In" cfsqltype="cf_sql_bit"     dbVarName="@Unlock"  value="1">
				<cfprocparam type="In" cfsqltype="cf_sql_bit"     dbVarName="@Lock"    value="1">
				<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID"       value="#Renewed_Program_ID#">
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number"   value="">
				<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID"     value="0">
				<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
				<cfprocparam type="In" cfsqltype="cf_sql_bit"     dbVarName="@ModifyDeletedPrograms"    value="0">
			</cfstoredproc>
			<!--- ingore any deadlock error --->
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfreturn Renewed_Program_ID />
	</cffunction>

	<cffunction name="QueryToArray" access="public" returntype="array" output="false" hint="This turns a query into an array of structures.">
	    <!--- Define arguments. --->
	    <cfargument name="Data" type="query" required="yes" />
	    <cfscript>
	        var LOCAL = StructNew();
	        LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
	        LOCAL.QueryArray = ArrayNew( 1 );
	        for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
	            LOCAL.Row = StructNew();
	            for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
	                LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
	                LOCAL.Row[ LOCAL.ColumnName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
	            }
	            ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
	        }
	        return( LOCAL.QueryArray );
	    </cfscript>
	</cffunction>


</cfcomponent>
