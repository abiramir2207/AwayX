<!---
Name:        Create_Product_Rate_List.cfm
Copyright (c) 2016 Blacksmith Applications, Inc.
Description: Used to upload items/rate/UOM into rebate page.
--->

<cfparam name="form.programId" default="0">
<cfparam name="url.programId" default="#form.programId#" />
<cfparam name="form.finalSave" default ="0"/>
<cfparam name="url.discountype" default ="0"/>
<cfparam name="form.Vendor_Master_ID" default =""/>
<cfparam name="form.Vendor_Selection" default ="0"/>
<cfparam name="form.Payee_Selection" default ="0"/>
<cfparam name="form.GL_Account_ID" default ="0"/>
<cfparam name="form.volume_percentage" default="0" />


<cfif form.Vendor_Selection eq 'true'>
	<cfset form.Vendor_Selection = 1 />
</cfif>

<cfif form.Vendor_Selection eq 'false'>
	<cfset form.Vendor_Selection = 0 />
</cfif>


<cfset tablename = '####'&#replace(request.AccessStructure.User_ID,'-','_','ALL')#&'_Program_upload_'&#url.programId#>
<cfset RebateCFC = createObject("component","components.programs.rebates.Rebate")>

<cfif form.finalSave>
<!---BELOW FUNCTION WILL INSERT DATA AFTER VALIDATION THIS SECTION WILL TRIGGER ONLY WHEN THERE IS NO NEED FOR USER TO PICK A PRICING LEVEL --->
	<cfset uploaddata = RebateCFC.FinalUploadSave(url.programId,tablename,url.discountype)/>
	<script>
		var sURL = window.opener.location.href.replace(/bInit=0/i, "bInit=1");
		<!--- append bInit=1 parameter to load planner program data from database --->
		if (sURL.match( /bInit=/i ) == null) {
			sURL = sURL + "&bInit=1";
		}

		var programID = opener.document.querySelectorAll( "input.contract_main_id" );
		// found hidden element with class contract_main_id on parent window
		if ( programID.length ) {
			// remove existing programID 0 url parameter (exists in new program creation)
			// replace it with the newly created programID saved in form.programId hidden element
			sURL = sURL.replace(/programID=0/i, "") + "&programID=" + programID[ 0 ].value;
		}

		window.opener.location.href = sURL;
		window.close();
	</script>
<cfelse>

<cftransaction>

	<cfquery name="createTempdb" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..#tablename#') IS NOT NULL
		DROP TABLE #tablename#

		CREATE TABLE #tablename#(
			Row_ID INT IDENTITY NOT NULL,
			Program_ID INT,
			Comp_ID INT,
			BSA_Foodservice_Items_Master_ID UNIQUEIDENTIFIER,
			Products_ID VARCHAR(50),
			Rate VARCHAR(10),
			UOM VARCHAR(5),
			Pricing_Level_Id INT,
			Product_Group_Level_Id INT,
			Valid BIT DEFAULT (0),
			InValid BIT DEFAULT (0),
			Duplicate BIT DEFAULT (0),
			Removed  BIT DEFAULT (0),
			IsGroup BIT DEFAULT (0),
			Reason VARCHAR(100),
			InDB INT DEFAULT (0),
			User_picked_UOM INT NULL,
			Scan_Percentage VARCHAR(10)
		)
	</cfquery>

	<cfset Exisitingdata = RebateCFC.ExistingRecordsReport(url.programId,tablename,url.discountype)/>

	<cfquery name="local.getRateTypesFromTemplate" datasource="#application.datasource#">
		SELECT
				RateTypeOption_1,
				RateTypeOption_2,
				RateTypeOption_3,
				RateTypeOption_4,<!---63887--->
				RateTypeOption_5,
				RateTypeOption_6,
				Generic_Type,
				RateTypeDefault,
				Restrict_On_Inventory_UOM_Case,
				Restrict_On_Inventory_UOM_Pound,
				Group_Programs_UOM,
				Groups_UOM_1,
				Groups_UOM_2,
				Groups_UOM_3,
				Groups_UOM_Default,
				ProgramControl_Panel_Options_ID
		 FROM Program_Control_Panel_Options
		 WHERE ProgramControl_Panel_Options_ID = ( SELECT ProgramType_ID
													FROM Contract_Main
													WHERE Contract_Main_ID = #url.programId# )
				AND Deleted = 0
	</cfquery>

	<cfif len(form.rate)>
		<cfset CompDefaultRate = '#form.rate#'>
	<cfelse>
		<cfset CompDefaultRate = '0.0000'>
	</cfif>

	<cfset CompDefaultUOM = '#form.UOM#'>

	<cfif len(form.volume_percentage)>
		<cfset CompDefaultVol = '#form.volume_percentage#'>
	<cfelse>
		<cfset CompDefaultVol = '0.000'>
	</cfif>

	<cfif url.discountype EQ 1>
		<cfquery name="checkComp" datasource="#application.datasource#">
			SELECT *
			FROM Program_Fixed_Component
			WHERE Program_ID = #form.programid#
			AND Program_Fixed_Component_Name_ID = #form.compnameid#
			AND Deleted = 0
		</cfquery>
		<cfif checkComp.recordCount>
			<cfquery name="updateFixedComp" datasource="#application.datasource#">
				UPDATE Program_Fixed_Component
				SET Fixed_Component_Paid_To = #form.Fixed_Component_Paid_To#
						, Claim_Mechanics = #form.claim_mechanics#
						, Vendor_Selection = #form.Vendor_Selection#
						, Payee_Type = #form.Payee_Selection#
						<cfif form.Vendor_Master_ID neq "" and form.Vendor_Master_ID neq 0>
						, Vendor_Master_ID = '#form.Vendor_Master_ID#'
						</cfif>
						<cfif form.GL_Account_ID neq "" and form.GL_Account_ID neq 0>
						, GL_Account_ID = '#form.GL_Account_ID#'
						</cfif>
				WHERE Program_ID = #form.programid#
				AND Program_Fixed_Component_Name_ID = #form.compnameid#
				AND Deleted = 0
			</cfquery>

			<cfset ProgramComponentID = checkComp.Program_Fixed_Component_ID>
		<cfelse>
			<cfquery name="insertComp" datasource="#application.datasource#">
				INSERT INTO Program_Fixed_Component(Program_ID,Program_Fixed_Component_Name_ID,Fixed_Component_Paid_To, Claim_Mechanics,Vendor_Selection <cfif form.Payee_Selection neq "" and form.Payee_Selection neq 0>,Payee_Type</cfif> <cfif form.Vendor_Master_ID neq "" and form.Vendor_Master_ID neq 0>,Vendor_Master_ID</cfif> <cfif form.GL_Account_ID neq "" and form.GL_Account_ID neq 0>,GL_Account_ID</cfif>)
				Values (#form.programid#,#form.compnameid#,#form.Fixed_Component_Paid_To#,#form.claim_mechanics#, #form.Vendor_Selection# <cfif form.Payee_Selection neq "" and form.Payee_Selection neq 0>, #form.Payee_Selection#</cfif> <cfif form.Vendor_Master_ID neq "" and form.Vendor_Master_ID neq 0>,'#form.Vendor_Master_ID#'</cfif> <cfif form.GL_Account_ID neq "" and form.GL_Account_ID neq 0>,'#form.GL_Account_ID#'</cfif>)
				SELECT SCOPE_IDENTITY() AS Program_Fixed_Component_ID
			</cfquery>
			<cfset ProgramComponentID = insertComp.Program_Fixed_Component_ID>
			<cfquery name="qSavePaymentCycle" datasource="#application.datasource#">
				INSERT INTO Program_Payment_Cycle
					(Program_ID, Discount_Type_ID, Payment_Cycle_ID,Component_ID)
				VALUES
					('#form.programid#','1','#form.PaymentCycle#','#ProgramComponentID#')
			</cfquery>
		</cfif>
	<cfelseif url.discountype EQ 2>

		<cfquery name="getPCPODetail" datasource="#application.datasource#">
			SELECT Ignore_Rebate_Volume
			FROM Program_Control_Panel_Options PCPO
			INNER JOIN Contract_Main CM
			ON CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
			WHERE CM.Contract_Main_ID = <cfqueryparam value="#form.programid#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

		<cfset DontCountVolume = 0 />
		<cfif (isDefined("getPCPODetail") AND getPCPODetail.RecordCount NEQ 0 AND getPCPODetail.Ignore_Rebate_Volume EQ 1)>
			<cfset DontCountVolume = 1 />
		</cfif>

		<cfquery name="checkComp" datasource="#application.datasource#">
			SELECT *
			FROM Program_Rebates_Component
			WHERE Program_ID = #form.programid#
			AND Program_Rebates_Component_Name_ID = #form.compnameid#
			AND Deleted = 0
		</cfquery>
		<cfif checkComp.recordCount>

				<cfquery name="UpdateRebateComp" datasource="#application.datasource#">
					UPDATE Program_Rebates_Component
					SET Component_Paid_To = #form.Component_Paid_To#
							, Claim_Mechanics = #form.claim_mechanics#
							, Vendor_Selection = #form.Vendor_Selection#
							, Payee_Type = #form.Payee_Selection#
							<cfif form.Vendor_Master_ID neq "" and form.Vendor_Master_ID neq 0>
							, Vendor_Master_ID = '#form.Vendor_Master_ID#'
							</cfif>
							<cfif form.GL_Account_ID neq "" and form.GL_Account_ID neq 0>
							, GL_Account_ID = '#form.GL_Account_ID#'
							</cfif>
							, Dont_Count_Volume = #DontCountVolume#
					WHERE Program_ID = #form.programid#
					AND Program_Rebates_Component_Name_ID = #form.compnameid#
					AND Deleted  = 0
				</cfquery>

			<cfset ProgramComponentID = checkComp.Program_Rebates_Component_ID>
		<cfelse>

			<cfquery name="insertComp" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component(Program_ID,Program_Rebates_Component_Name_ID,Component_Paid_To, Claim_Mechanics,Vendor_Selection <cfif form.Payee_Selection neq "" and form.Payee_Selection neq 0>,Payee_Type</cfif> <cfif form.Vendor_Master_ID neq "" and form.Vendor_Master_ID neq 0>,Vendor_Master_ID</cfif>,Dont_Count_Volume <cfif form.GL_Account_ID neq "" and form.GL_Account_ID neq 0>,GL_Account_ID</cfif>)
				Values (#form.programid#, #form.compnameid#, #form.Component_Paid_To#, #form.claim_mechanics#, #form.Vendor_Selection# <cfif form.Payee_Selection neq "" and form.Payee_Selection neq 0>, #form.Payee_Selection#</cfif> <cfif form.Vendor_Master_ID neq "" and form.Vendor_Master_ID neq 0>,'#form.Vendor_Master_ID#'</cfif>,#DontCountVolume# <cfif form.GL_Account_ID neq "" and form.GL_Account_ID neq 0>,'#form.GL_Account_ID#'</cfif>)
			</cfquery>

			<cfset ProgramComponentID = insertComp.Program_Rebates_Component_ID>

			<cfquery name="qSavePaymentCycle" datasource="#application.datasource#">
				INSERT INTO Program_Payment_Cycle
					(Program_ID, Discount_Type_ID, Payment_Cycle_ID,Component_ID)
				VALUES
					('#form.programid#','2','#form.PaymentCycle#','#ProgramComponentID#')
			</cfquery>

			<!--- insert default rate for existing products/groups to avoid event error --->
			<cfquery name="qInsertRateExistingProducts" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component_Data (Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, rate, Unit_Of_Measure_ID, Is_Group, Captured_From_Group, Scan_Percentage)
				SELECT	c.Program_Rebates_Component_ID, pd.Program_Rebates_Product_Data_ID, '#Val(CompDefaultRate)#' as Rate, #Val(CompDefaultUOM)# as Unit_Of_Measure_ID, cp.Is_Group, cp.Captured_From_Group, '#val(CompDefaultVol)#' as Scan_Percentage
				from	Contract_Main cm
				inner join Contract_Products cp
				on		cp.Contract_Main_ID = cm.Contract_Main_ID
				and		cp.Deleted = 0
				and		cp.Captured_From_Group = 0
				inner join Program_Rebates_Product_Data pd
				on		pd.Contract_Products_ID = cp.Contract_Products_ID
				and		pd.Deleted = 0
				inner join Program_Rebates_Component c
				on		c.Program_ID = cm.Contract_Main_ID
				and		c.Deleted = 0
				where	cm.Contract_Main_ID = '#form.programid#'
				and		not exists (
					select	1
					from	Program_Rebates_Component_Data cd
					where	cd.Program_Rebates_Product_Data_ID = pd.Program_Rebates_Product_Data_ID
					and		cd.Program_Rebates_Component_ID = c.Program_Rebates_Component_ID
					and		cd.Deleted = 0
				)
			</cfquery>

		</cfif>
	<cfelse>
		<div style="color:red">Invalid Discount Type</div>
		<script>
			window.close ();
		</script>
		<cfabort>
	</cfif>


	<cfset productlist = ''>
	<cfset rate = ''>
	<cfset uom = ''>
	<cfset delims = '#chr(9)#,#chr(32)#'> <!--- tab, space --->

	<cfset deletedRecords = 0>
	<!--- enable uom validation --->
	<cfset uom_validation = 1>
	<cfloop index = "rawdata" list = "#trim(FORM.itemList)#" delimiters="#chr(13)#">
		<cfset productlist =  listappend(productlist, ListGetAt(rawdata,1,delims))>

	<cfif listlen(rawdata) GT 1>
		<cfset rate = listappend(rate, ListGetAt(rawdata,2,delims))>
	<cfelse>
		<cfset rate = listappend(rate, CompDefaultRate)>
		<cfset rawdata= listappend(rawdata, CompDefaultRate,',')>
	</cfif>

	<cfif listlen(rawdata) GT 2>
		<cfset uom = listappend(uom, ListGetAt(rawdata,3,delims))>
	<cfelse>
		<cfset uom = listappend(uom, CompDefaultUOM)>
		<cfset  rawdata = listappend(rawdata, CompDefaultUOM)>
	</cfif>

		<!--- BELOW FUNCTION WILL CHECK IF ITEMS ALREADY EXISITNGS IF ITEMS EXIST THEN WE UPDATE RATE/UOM IF NOT WE WILL INSERT ITEMS INTO TEMP TABLE --->
		<cfset InsertUpdateData = RebateCFC.InsertUpdateRecords(trim(ListGetAt(rawdata,1,delims)), ListGetAt(rawdata,2,delims), ListGetAt(rawdata,3,delims), tablename, #ProgramComponentID#, uom_validation, local.getRateTypesFromTemplate, CompDefaultVol)>
	</cfloop>

	<cfset form.passedItemList = productlist>
	<cfset form.Program_ID = form.programid>
	<cfset fromPrgUpload = 1>

		<!--- IF AN ITEM EXIST MORE THAN ONCE WE ARE FLAGGING BOTH AS DUPLICATE, WE NEED TO FLAG ONE TIME AS VALID BELOW QUERY DO THAT.--->
		<cfquery name="UpdateDuplicateRecords" datasource="#application.datasource#">
			UPDATE #tablename#
			SET Duplicate = 0, Reason = '', removed = 0
			WHERE Duplicate = 1
			AND removed = 1
			AND Reason = 'Duplicate item'
			AND Row_ID IN (SELECT MIN(Row_ID) FROM #tablename# GROUP BY BSA_Foodservice_Items_Master_ID, Comp_ID)
		</cfquery>

	<cfinclude template="\common_files\validateInput.cfm"/>
</cftransaction>
</cfif>