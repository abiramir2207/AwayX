<!-----------------------------------------------------------------------------

FILE NAME:		VolumeApplicator.cfc
DESCRIPTION:	Returns the data for populating the datagrid

CREATED BY:		Anand Rao/ 06-Jun-09

MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
*******************************************************************************
<Add any modifications to this file here>
*******************************************************************************

------------------------------------------------------------------------------>

<cfcomponent name="VolumeApplicator" displayname="VolumeApplicator" hint="Volume Applicator">
	<cfset appSettings = application.appSettingsGet />

  <cffunction name="getVolumeDetails" hint="return all products" access="remote" output="false" returntype="any">
    <cfargument name="ProgramId" default="0">
    <cfargument name="prgMode" default="">
    <cfargument name="group" default = "">
	<cfargument name="productGroupLevel" default = "0">

    <cfstoredproc procedure="Get_Program_Product_Volume_Forecast" datasource="#application.datasource#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@contract_main_id" null="no" value="#arguments.ProgramId#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@mode" null="no" value="#arguments.prgMode#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@group_by" null="no" value="#arguments.group#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@user_id" null="yes">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@product_group_level" null="no" value="#arguments.productGroupLevel#">
			<cfprocresult name="getProductVolume">
    </cfstoredproc>

    <cfif NOT(isDefined("getProductVolume.invoice_type"))>
      <cfset recType = "BASE" />
      <cfset addColumn = QueryAddColumn(getProductVolume, "invoice_type", "VarChar", recType)>
    </cfif>

    <cfreturn getProductVolume />
  </cffunction>

  <cffunction name="getProgramDetails" Hind = "return all Details about the Program" access="remote" output="false" returntype="any">
    <cfargument name="ProgramId" default="0">
    <cfargument name="UserID" default="0">

    <cfset companyMainID = "" />
    <cfset useLakebaseForqryGetProfileID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqryGetProfileID>
	<cftry>
		<cfset qryGetProfileID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#arguments.UserID#",
				"select" = "profiles_id"
			}), "profiles_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetProfileID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetProfileID>
<CFQUERY NAME="qryGetProfileID" DATASOURCE="#application.datasource#">
    	SELECT Profiles_ID FROM _Users WHERE User_ID = '#arguments.UserID#'
    </CFQUERY>
</cfif>
    <cfset profile = CreateObject("component","components.user.Profile").init() />
    <cfset Get_Profile_Settings = profile.getProfileSettings(#qryGetProfileID.Profiles_ID#)>

    <cfif Get_Profile_Settings.Volume_Details_Tab_Display EQ 1>
      <cfset bDisplayVolumeDetails = "true" />
    <cfelse>
      <cfset bDisplayVolumeDetails = "false" />
    </cfif>


    <cfset useLakebaseForqryGetCompanyID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForqryGetCompanyID>
	<cftry>
		<cfset qryGetCompanyID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetCompanyID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetCompanyID>
<CFQUERY NAME="qryGetCompanyID" DATASOURCE="#application.datasource#">
      SELECT company_main_id FROM Company_Main WHERE Deleted = 0
    </CFQUERY>
</cfif>
    <cfset companyMainID = qryGetCompanyID.company_main_id />
    <CFQUERY NAME="qryGetProgramDetails" DATASOURCE="#application.datasource#">
			SELECT
          	/* -- Generic_Type.Generic_Type_ID,  */
			Program_Control_Panel_Options.Generic_Type,
			/* -- Program_Control_Panel_Options.Zero_Volume, */
          	Program_Control_Panel_Options.Min_Global_Volume,
          	Program_Control_Panel_Options.Min_Global_Volume_Size_CS,
          	Program_Control_Panel_Options.Min_Global_Volume_Size_LBS,
          	Program_Control_Panel_Options.Max_Global_Volume,
          	Program_Control_Panel_Options.Max_Global_Volume_Size_CS,
          	Program_Control_Panel_Options.Max_Global_Volume_Size_LBS,
		  	Program_Control_Panel_Options.Opportunity_Volume,
			Contract_Main.Contract_Number,
			Contract_Main.Contract_Title,
			Contract_Main.Contract_Quantity_UOM_IDX,
			CASE 	WHEN (Program_Control_Panel_Options.RateTypeDefault = 1) THEN 'Cases'
					WHEN (Program_Control_Panel_Options.RateTypeDefault = 5) THEN 'Each'
					WHEN (Program_Control_Panel_Options.RateTypeDefault = 6) THEN 'Sleeve'
			ELSE '#Application.UOMPoundPlural#' END AS PrgUOMType,
			<!---
			- If Both UOM"S are to ON on the template for the volume page, select the program UOM as the option for the "Apply" option on the program volume grid.
			If we have both as options for the "Apply" option, it causes an issue while calculating the volume on the volume grid - Tim or Dinesh know more.
			- If only CS exists, then CS. If only LB exists, then LB.
			--->
			/*******************************************************************************************************************************/
			CASE WHEN  (Program_Control_Panel_Options.Volume_Page_UOM_CS = 1 AND Program_Control_Panel_Options.Volume_Page_UOM_LB = 1)
				THEN
					 CASE WHEN (Contract_Main.Contract_Quantity_UOM_IDX = 1) THEN 'Cases' ELSE '#Application.UOMPoundPlural#' END
				WHEN Program_Control_Panel_Options.Volume_Page_UOM_CS = 1 THEN 'Cases'
				WHEN Program_Control_Panel_Options.Volume_Page_UOM_LB = 1 THEN '#Application.UOMPoundPlural#'
			END
			AS VolUOMType,
			<!--- Same logic as above --->
			CASE WHEN  (Program_Control_Panel_Options.Volume_Page_UOM_CS = 1 AND Program_Control_Panel_Options.Volume_Page_UOM_LB = 1)
				THEN
					 CASE WHEN (Contract_Main.Contract_Quantity_UOM_IDX = 1) THEN 1 ELSE 2 END
				WHEN Program_Control_Panel_Options.Volume_Page_UOM_CS = 1 THEN 1
				WHEN Program_Control_Panel_Options.Volume_Page_UOM_LB = 1 THEN 2
			END
			AS VolUOMIDX,
			/*******************************************************************************************************************************/
			ISNULL(Contract_Main.Contract_Quantity, 0) as Contract_Quantity,
			CONVERT(VARCHAR(10), Contract_Main.Contract_Start_Date, 101) AS Contract_Start_Date,
			CONVERT(VARCHAR(10), Contract_Main.Contract_End_Date, 101) AS Contract_End_Date,
          	(DateDiff(day,Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date)+1) as Contract_Span,
			/* --	Contract_Main_Aux_Data.Forecast_ID,
			-- Program_Control_Panel_Options.Volume_Cap, */
          	CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR (Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs')) THEN 'true'
			ELSE 'false'
			END AS bOpType,
          	CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR (Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs'))
          		THEN (SELECT Volume_Operator_Template_GroupA FROM _Users_Settings WHERE User_ID= '#companyMainID#')
          		ELSE (SELECT Volume_Distributor_Template_GroupA FROM _Users_Settings WHERE	User_ID		= '#companyMainID#')
          	END AS GroupADefault,
       		CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR (Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs'))
          		THEN  Program_Control_Panel_Options.Volume_Operator_Template_GroupB_Default
          		ELSE  Program_Control_Panel_Options.Volume_Distributor_Template_GroupB_Default
          	END AS GroupBDefault,
          	/* -- the below fields will decide whether each of the group B options displays or not. */
          	CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR
					(Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs'))
					<!--- Operator templates should always have direct ship and billback options ISNULL(Program_Control_Panel_Options.Operator_Off_Invoice_Volume,0) --->
					THEN 1
					ELSE ISNULL(Program_Control_Panel_Options.Distributor_Off_Invoice_Volume,0)
					END AS bDirectShipmentShow,
          CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR
					(Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs'))
					<!--- Operator templates should always have direct ship and billback options ISNULL(Program_Control_Panel_Options.Operator_Billback_Volume,0) --->
					THEN 1
					ELSE ISNULL(Program_Control_Panel_Options.Distributor_Billback_Volume,0)
					END AS bBillbackShow,
			CASE WHEN ((Program_Control_Panel_Options.Generic_Type = 'Operator-Deviated Pricing') OR
					(Program_Control_Panel_Options.Generic_Type = 'Operator Direct or HQ Programs'))
					THEN 0 <!--- Operator templates should never adjust for credit --->
					ELSE ISNULL(Program_Control_Panel_Options.Adjust_For_Credits,0)
					END AS bCreditsShow,
          	(SELECT Volume_Help_Text FROM _Users_Settings WHERE User_ID= '#companyMainID#') AS Volume_Help_Text,
		  	Contract_Main_Aux_Data.Exclude_From_Auto_Volume_Updates,	<!--- D35145: Volume Applicator - Disable Auto Volume --->
			Contract_Main.Approved,
			Program_Control_Panel_Options.Volume_Page_UOM_CS,
			Program_Control_Panel_Options.Volume_Page_UOM_LB,
			(
				SELECT	TOP 1 _Users.Name_First + ' ' + _Users.Name_Last + '  ' + CONVERT(VARCHAR(20), pel.Created_Date, 100)
				FROM	Program_Exclude_From_Auto_Volume_Update_Log pel
						INNER JOIN _Users ON _Users.User_ID = pel.Updated_By
				WHERE	pel.Contract_Main_ID = Contract_Main.Contract_Main_ID
				ORDER BY pel.Created_Date DESC
			) AS  Auto_Volume_Exclude_Updated_Data,
			CASE WHEN (ISNULL(Program_Control_Panel_Options.RateTypeDefault, 0) = 0) THEN Contract_Main.Contract_Quantity_UOM_IDX END AS RateTypeDefault,
			Program_Control_Panel_Options.RateTypeOption_1,
			Program_Control_Panel_Options.RateTypeOption_2,
			Program_Control_Panel_Options.RateTypeOption_3,
			Program_Control_Panel_Options.RateTypeOption_5,
			Program_Control_Panel_Options.RateTypeOption_6

      FROM	Contract_Main
	<!--- D35145: Volume Applicator - Disable Auto Volume START--->
	 INNER JOIN 	Contract_Main_Aux_Data
					ON
	 Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
	 <!--- D35145: Volume Applicator - Disable Auto Volume END--->
					INNER JOIN Program_Control_Panel_Options
					ON
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					INNER JOIN Generic_Type
					ON
					Generic_Type.Generic_Type = Program_Control_Panel_Options.Generic_Type
			WHERE
					Contract_Main.Contract_Main_ID = #arguments.ProgramId#
		</CFQUERY>

     <cfset addColumn = QueryAddColumn(qryGetProgramDetails, "Volume_Details_Tab_Display", "VarChar", ListToArray(bDisplayVolumeDetails))>

    <cfreturn qryGetProgramDetails />
  </cffunction>

  <cffunction name="saveVolume" output="false" access="remote" hint="Set up volume array in same way as classic Flash page & then merge input data into it">
    <cfscript>
        local.requestBody = toString( getHttpRequestData().content );
        // Double-check to make sure it's a JSON value
        if (isJSON( requestBody ))
            local.form = deserializeJSON( local.requestBody );
        else
            return "Unexpected parameters in saveVolume().";

				if(local.form.forecast){
					local.type = 'EDIT-FORECAST';
				}else{
					local.type = 'EDIT';
				}
        local.qVolume = getVolumeDetails(local.form.program_id, local.type, local.form.group_by, local.form.product_group_level);
        local.volume  = [];
        local.columns = listToArray(local.qVolume.columnList);

        // place all volume rows into an array and populate it with entered values from frontend
        for ( local.current_row=1; local.current_row <= local.qVolume.RecordCount; local.current_row++ ) {
            local.row = {};
            local.product_key = local.qVolume[ "bsa_foodservice_items_master_id" ][ local.current_row ];

            // pull row data from database query
            for (local.column in local.columns) {
                local.row[ local.column ] = local.qVolume[ local.column ][ local.current_row ];
            }

            // merge entered values (passed in local.form. structure) in current row
            if (structKeyExists(local.form, "cs_" & local.product_key)) {
								local.row.cases = local.form[ "cs_" & local.product_key ];
								local.row.pounds = local.row.cases * local.row.net_weight;
            }
            if (structKeyExists(local.form, "lbs_" & local.product_key)) {
								local.row.pounds = local.form[ "lbs_" & local.product_key ];
								local.row.cases = local.row.pounds / local.row.net_weight;;
            }
            if (structKeyExists(local.form, "ocs_" & local.product_key)) {
                local.row.Opportunity_Volume_CS = local.form[ "ocs_" & local.product_key ];
            }
            if (structKeyExists(local.form, "olbs_" & local.product_key)) {
                local.row.Opportunity_Volume_LB = local.form[ "olbs_" & local.product_key ];
            }

            // each uom ~ convert it to cases
            if (structKeyExists(local.form, "ea_" & local.product_key)) {
                local.row.Each_Volume = local.form[ "ea_" & local.product_key ];
								local.row.cases = local.row.Each_Volume / local.row.Case_Count;
								local.row.pounds = local.row.cases * local.row.net_weight;
            }
            // sleeve uom ~ convert it to cases
            if (structKeyExists(local.form, "sl_" & local.product_key)) {
                local.row.Sleeve_Volume = local.form[ "sl_" & local.product_key ];
								local.row.cases = local.row.Sleeve_Volume / local.row.Sleeves_Per_Case;
								local.row.pounds = local.row.cases * local.row.net_weight;
            }

            // save current row into an array - mimic Flash structure
            arrayAppend(local.volume, local.row);
        }

        // <!--- actual call to save volume --->
        return updateVolumeDetails(local.form.program_id, local.volume, request.AccessStructure.user_id, "", local.form.product_group_level, local.form.exclude_auto_volume);
		</cfscript>

  </cffunction>


    <!---------------------------------------------------------------------------
  	  Update the volume details into the table Program_Product_Volume
	  --------------------------------------------------------------------------->
	<cffunction name="updateVolumeDetails" Hind = "update the data changed " access="remote" output="true" returntype="any">
		<cfargument name="ProgramId" default="0">
		<cfargument name="updateVolumeData" type="array">
		<cfargument name="UserID" default="0">
		<cfargument name="sReturnType" type="string" required="false" default="">
		<cfargument name="productGroupType" type="string" required="false" default="0">
		<cfargument name="excludeAutoVolumeUpdates" type="boolean" required="false" default="0">

        <!--- <cfset request.dumpToEmail_address = "cnguyen@blacksmithapplications.com"> <cfset application.util.io.dumpToEmail(GetMetaData(this).displayname)> --->

		<cfset var arrArgVolumeData			= "" />
		<cfset var arrProductVolumeData		= "" />
		<cfset strMessage					= "" />
		<cfset strCaughtError				= "" />
		<cfset errorFlag					= 0 />
		<cfset prgSpan						= 1 />
		<cfset poundsSum                  	= 0 />
		<cfset casesSum            			= 0 />
		<cfset contractQty					= 0 />
		<cfset contractSum					= 0 />
		<cfset qryProgramDetails			= getProgramDetails(ProgramId,UserID) />
		<cfset nProductGroupType			= arguments.productGroupType />

		<cfset arrArgVolumeData = arguments.updateVolumeData />
		<cfset appSetProgram_Volume_Allocation_wtd_average = appSettings.get_Setting('Program_Volume_Allocation_wtd_average') />
		<cfif (qryProgramDetails.RecordCount GTE 1)>
			<cfset prgSpan = qryProgramDetails.Contract_Span />
			<cfset ContractQuantityUOM = qryProgramDetails.Contract_Quantity_UOM_IDX />
		</cfif>

		<!--- rebuild array and distribute volume by group count --->
		<cfif nProductGroupType neq 0 and isNumeric(nProductGroupType)>

			<!--- if its group then we need to figure out the sum to handle for rounding --->
			<cfset nUserEnteredSum 		= 0 />
			<cfset nOppUserEnteredSum 	= 0 />

			<!--- build a temp table to store the volume distribution data --->
			<cfquery datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmpProdVolume2') IS NOT NULL
				DROP TABLE ##tmpProdVolume2

				CREATE TABLE ##tmpProdVolume2
				(
					BSA_Foodservice_Items_Master_ID  UNIQUEIDENTIFIER,
					Volume_LB FLOAT,
					Volume_CS FLOAT,
					Net_Dollar FLOAT,
					Original_Volume_LB FLOAT,
					Original_Volume_CS FLOAT,
					Original_Net_Dollar FLOAT,
					Opportunity_Volume_LB FLOAT,
					Opportunity_Volume_CS FLOAT,
					Group_GUID UNIQUEIDENTIFIER
				)
			</cfquery>

			<cfset arrProductVolumeData = arrayNew(1) />

			<cfloop index="indx" from="1" to="#arrayLen(arrArgVolumeData)#">

				<cfquery datasource="#application.datasource#" name="qGetProductGroupVolumeData">
					SELECT	DISTINCT Program_Product_Volume.BSA_Foodservice_Items_Master_ID, 
						BSA_Foodservice_Items_Master.Net_Weight, All_Product_Group_Types.Group_GUID, 
						(Program_Product_Volume.Volume_CS * #prgSpan# / 7.00) AS Program_Product_Vol_CS,
				 		SUM(Volume_CS * #prgSpan# / 7.00) OVER (Partition By 1)  as Group_Product_Volume_CS,
						(Program_Product_Volume.Volume_LB * #prgSpan# / 7.00) AS Program_Product_Vol_LB,
				 		SUM(Volume_LB * #prgSpan# / 7.00) OVER (Partition By 1)  as Group_Product_Volume_LB						
					FROM	Program_Product_Volume
							INNER JOIN All_Product_Group_Type_Members ON All_Product_Group_Type_Members.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
							INNER JOIN All_Product_Group_Types ON All_Product_Group_Types.Product_Group_Level_ID = All_Product_Group_Type_Members.Product_Group_Level_ID AND
							All_Product_Group_Types.Group_GUID = All_Product_Group_Type_Members.Product_Group_ID AND All_Product_Group_Types.Deleted = 0
							INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
					WHERE	Program_Product_Volume.Program_ID = <cfqueryparam value="#ProgramId#" cfsqltype="CF_SQL_INTEGER" />
					AND		Program_Product_Volume.Is_Group = 0
					AND		Program_Product_Volume.Deleted = 0
					AND		All_Product_Group_Type_Members.Product_Group_Level_ID = <cfqueryparam value="#nProductGroupType#" cfsqltype="CF_SQL_INTEGER" />
					AND		All_Product_Group_Types.Group_GUID = <cfqueryparam value="#arrArgVolumeData[indx].bsa_foodservice_items_master_id#" cfsqltype="CF_SQL_VARCHAR" />
				</cfquery>
			
				<!--- get what the user has entered. if its case then sum for case, otherwise sum for pound --->
				<cfif ContractQuantityUOM eq 1>
					<cfset nUserEnteredSum		= LSNumberFormat(replace(arrArgVolumeData[indx].cases,',','',"ALL") , "_-______") />
					<cfset nOppUserEnteredSum	= LSNumberFormat(replace(arrArgVolumeData[indx].Opportunity_Volume_CS,',','',"ALL") , "_-______") />
				<cfelse>
					<cfset nUserEnteredSum		= LSNumberFormat(replace(arrArgVolumeData[indx].pounds,',','',"ALL"), "_-______") />
					<cfset nOppUserEnteredSum	= LSNumberFormat(replace(arrArgVolumeData[indx].Opportunity_Volume_LB,',','',"ALL"), "_-______") />
				</cfif>
				
				<cfloop query="qGetProductGroupVolumeData">

					<!--- convert using net weight based on UOM. if its case then convert pounds,  if its pounds then convert case --->
					<cfif ContractQuantityUOM eq 1>
						<!--- if the UOM is CS then set CS values and convert LB based on CS * net weight  --->
						<!--- SET CS --->
						<cfif (appSetProgram_Volume_Allocation_wtd_average NEQ '1')>
							<cfset csVal 			= LSNumberFormat(replace(arrArgVolumeData[indx].cases,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset origCsVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].original_cases,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset csOppVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].Opportunity_Volume_CS,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset netDolVal		= LSNumberFormat(replace(arrArgVolumeData[indx].net_dollar,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset origNetDolVal 	= LSNumberFormat(replace(arrArgVolumeData[indx].original_net_dollar,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
						<cfelse>
							<cfset csVal 			= LSNumberFormat(replace(arrArgVolumeData[indx].cases,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_CS / qGetProductGroupVolumeData.Group_Product_Volume_CS, "_-______") />
							<cfset origCsVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].original_cases,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_CS / qGetProductGroupVolumeData.Group_Product_Volume_CS, "_-______")  />
							<cfset csOppVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].Opportunity_Volume_CS,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_CS / qGetProductGroupVolumeData.Group_Product_Volume_CS, "_-______")  />
							<cfset netDolVal		= LSNumberFormat(replace(arrArgVolumeData[indx].net_dollar,',','',"ALL")* qGetProductGroupVolumeData.Program_Product_Vol_CS / qGetProductGroupVolumeData.Group_Product_Volume_CS, "_-______") />
							<cfset origNetDolVal 	= LSNumberFormat(replace(arrArgVolumeData[indx].original_net_dollar,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_CS / qGetProductGroupVolumeData.Group_Product_Volume_CS, "_-______") />
						</cfif>	
						<!--- CONVERT LB --->
						<cfset lbVal 			= csVal 	* qGetProductGroupVolumeData.Net_Weight />
						<cfset origLbVal 		= origCsVal	* qGetProductGroupVolumeData.Net_Weight  />
						<cfset lbOppVal 		= csOppVal	* qGetProductGroupVolumeData.Net_Weight />

					<cfelse>
							<!--- if the UOM is LB then set LB values and convert CS based on LB / net weight  --->
							<!--- SET LB --->
						<cfif (appSetProgram_Volume_Allocation_wtd_average NEQ '1')>
							<cfset lbVal 			= LSNumberFormat(replace(arrArgVolumeData[indx].pounds,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset origLbVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].original_pounds,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset lbOppVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].Opportunity_Volume_LB,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset netDolVal		= LSNumberFormat(replace(arrArgVolumeData[indx].net_dollar,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
							<cfset origNetDolVal 	= LSNumberFormat(replace(arrArgVolumeData[indx].original_net_dollar,',','',"ALL") / arrArgVolumeData[indx].count, "_-______") />
						<cfelse>
							<cfset lbVal 			= LSNumberFormat(replace(arrArgVolumeData[indx].pounds,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_LB / qGetProductGroupVolumeData.Group_Product_Volume_LB, "_-______") />
							<cfset origLbVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].original_pounds,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_LB / qGetProductGroupVolumeData.Group_Product_Volume_LB, "_-______") />
							<cfset lbOppVal 		= LSNumberFormat(replace(arrArgVolumeData[indx].Opportunity_Volume_LB,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_LB / qGetProductGroupVolumeData.Group_Product_Volume_LB, "_-______") />
							<cfset netDolVal		= LSNumberFormat(replace(arrArgVolumeData[indx].net_dollar,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_LB / qGetProductGroupVolumeData.Group_Product_Volume_LB, "_-______") />
							<cfset origNetDolVal 	= LSNumberFormat(replace(arrArgVolumeData[indx].original_net_dollar,',','',"ALL") * qGetProductGroupVolumeData.Program_Product_Vol_LB / qGetProductGroupVolumeData.Group_Product_Volume_LB, "_-______") />
						</cfif>
						<!--- CONVERT CS --->
						<cfset csVal 			= lbVal 	/ qGetProductGroupVolumeData.Net_Weight />
						<cfset origCsVal 		= origLbVal	/ qGetProductGroupVolumeData.Net_Weight />
						<cfset csOppVal 		= lbOppVal	/ qGetProductGroupVolumeData.Net_Weight />
					</cfif>

					<cfquery datasource="#application.datasource#">
						INSERT INTO ##tmpProdVolume2
						(
							BSA_Foodservice_Items_Master_ID,
							Volume_LB,
							Volume_CS,
							Net_Dollar,
							Original_Volume_LB,
							Original_Volume_CS,
							Original_Net_Dollar,
							Opportunity_Volume_LB,
							Opportunity_Volume_CS,
							Group_GUID
						)
						VALUES
						(
							'#qGetProductGroupVolumeData.BSA_Foodservice_Items_Master_ID#',
							'#trim(lbVal)#',
							'#trim(csVal)#',
							'#trim(netDolVal)#',
							'#trim(origLbVal)#',
							'#trim(origCsVal)#',
							'#trim(origNetDolVal)#',
							'#trim(lbOppVal)#',
							'#trim(csOppVal)#',
							'#trim(qGetProductGroupVolumeData.Group_GUID)#'
						)
					</cfquery>
				</cfloop>

				<cfquery datasource="#application.datasource#" name="qCheckSums">
					SELECT	SUM(Volume_LB) AS Volume_LB_Sum, SUM(Volume_CS) AS Volume_CS_Sum, SUM(Opportunity_Volume_CS) AS Opp_Volume_CS_Sum, SUM(Opportunity_Volume_LB) AS Opp_Volume_LB_Sum     
					FROM	##tmpProdVolume2						
					WHERE	Group_GUID = <cfqueryparam value="#arrArgVolumeData[indx].bsa_foodservice_items_master_id#" cfsqltype="CF_SQL_VARCHAR" />
				</cfquery>

				<cfif ContractQuantityUOM eq 1>
					<cfset nDiffSum 	= LSNumberFormat(qCheckSums.Volume_CS_Sum , "_-______") />
					<cfset nOppDiffSum 	= LSNumberFormat(qCheckSums.Opp_Volume_CS_Sum , "_-______") />
				<cfelse>
					<cfset nDiffSum 	= LSNumberFormat(qCheckSums.Volume_LB_Sum , "_-______") />
					<cfset nOppDiffSum 	= LSNumberFormat(qCheckSums.Opp_Volume_LB_Sum , "_-______") />
				</cfif>

				<!---if the sum of the volume for all group members is less than the entered volume then adjust the difference --->
				<cfif (nDiffSum lt nUserEnteredSum) OR (nOppDiffSum lt nOppUserEnteredSum)>

					<cfset nTempDiffSum 	= nDiffSum />
					<cfset nTempOppDiffSum 	= nOppDiffSum />

					<cfquery datasource="#application.datasource#" name="qTempAdjustAllocatedVolume">
						SELECT	##tmpProdVolume2.BSA_Foodservice_Items_Master_ID,
								Volume_LB,
								Volume_CS,
								Net_Dollar,
								Original_Volume_LB,
								Original_Volume_CS,
								Original_Net_Dollar,
								Opportunity_Volume_LB,
								Opportunity_Volume_CS,
								BSA_Foodservice_Items_Master.Net_Weight
						FROM	##tmpProdVolume2
								INNER JOIN BSA_Foodservice_Items_Master ON
								BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 	##tmpProdVolume2.BSA_Foodservice_Items_Master_ID
						WHERE	Group_GUID = <cfqueryparam value="#arrArgVolumeData[indx].bsa_foodservice_items_master_id#" cfsqltype="CF_SQL_VARCHAR" />
					</cfquery>

					<!--- keep adding 1 untill they are equal --->
					<cfloop query="qTempAdjustAllocatedVolume">

						<!--- Adjust for volume --->
						<cfif nTempDiffSum lt nUserEnteredSum>

							<cfquery datasource="#application.datasource#">
								UPDATE	##tmpProdVolume2
								SET		<cfif ContractQuantityUOM eq 1>
										Volume_CS = Volume_CS + 1,
										Volume_LB = (Volume_CS + 1) * '#qTempAdjustAllocatedVolume.Net_Weight#'
										<cfelse>
										Volume_LB = Volume_LB + 1,
										Volume_CS = (Volume_LB + 1) / '#qTempAdjustAllocatedVolume.Net_Weight#'
										</cfif>
								WHERE	BSA_Foodservice_Items_Master_ID = '#qTempAdjustAllocatedVolume.BSA_Foodservice_Items_Master_ID#'
							</cfquery>

							<cfset nTempDiffSum = nTempDiffSum + 1 />

						</cfif>

						<!--- Adjust for opportunity volume --->
						<cfif nTempOppDiffSum lt nOppUserEnteredSum>

							<cfquery datasource="#application.datasource#">
								UPDATE	##tmpProdVolume2
								SET		<cfif ContractQuantityUOM eq 1>
										Opportunity_Volume_CS = Opportunity_Volume_CS + 1,
										Opportunity_Volume_LB = (Opportunity_Volume_CS + 1) * '#qTempAdjustAllocatedVolume.Net_Weight#'
										<cfelse>
										Opportunity_Volume_LB = Opportunity_Volume_LB + 1,
										Opportunity_Volume_CS = (Opportunity_Volume_LB + 1) / '#qTempAdjustAllocatedVolume.Net_Weight#'
										</cfif>
								WHERE	BSA_Foodservice_Items_Master_ID = '#qTempAdjustAllocatedVolume.BSA_Foodservice_Items_Master_ID#'
							</cfquery>

							<cfset nTempOppDiffSum = nTempOppDiffSum + 1 />

						</cfif>

					</cfloop>

				</cfif>
							
			</cfloop>

			<cfquery datasource="#application.datasource#" name="qTempAdjustVolume">
				SELECT	BSA_Foodservice_Items_Master_ID,
						Volume_LB,
						Volume_CS,
						Net_Dollar,
						Original_Volume_LB,
						Original_Volume_CS,
						Original_Net_Dollar,
						Opportunity_Volume_LB,
						Opportunity_Volume_CS
				FROM	##tmpProdVolume2
			</cfquery>

			<cfloop query="qTempAdjustVolume">

                <cfscript>
					stData = StructNew();
					stData.bsa_foodservice_items_master_id = qTempAdjustVolume.BSA_Foodservice_Items_Master_ID;
					stData.pounds = qTempAdjustVolume.Volume_LB;
					stData.cases = qTempAdjustVolume.Volume_CS;
					stData.net_dollar = qTempAdjustVolume.Net_Dollar;
					stData.original_pounds = qTempAdjustVolume.Original_Volume_LB;
					stData.original_cases = qTempAdjustVolume.Original_Volume_CS;
					stData.original_net_dollar = qTempAdjustVolume.Original_Net_Dollar;
					stData.Opportunity_Volume_CS = qTempAdjustVolume.Opportunity_Volume_CS;
					stData.Opportunity_Volume_LB = qTempAdjustVolume.Opportunity_Volume_LB;
					ArrayAppend(arrProductVolumeData, stData);
				</cfscript>
			</cfloop>
		<cfelse>
			<cfset arrProductVolumeData = arrArgVolumeData />
		</cfif>

		<cftry>

		<cfquery datasource="#application.datasource#">
			if object_id('tempdb..##tmpProdVolume') is not null
			drop table ##tmpProdVolume

			CREATE TABLE ##tmpProdVolume
			(
				BSA_Foodservice_Items_Master_ID  uniqueidentifier,
				Volume_LB float,
				Volume_CS float,
				Net_Dollar float,
				Original_Volume_LB float,
				Original_Volume_CS float,
				Original_Net_Dollar float,
				Opportunity_Volume_LB float,
				Opportunity_Volume_CS float
			)
		</cfquery>

		<cfloop from="1" to="#ArrayLen(arrProductVolumeData)#" index="i" step="1">
		  <!--- In the mask added a minus so that if the number is negative it works correctly --->
			<cfset poundsVal            = (LSNumberFormat(replace(arrProductVolumeData[i].pounds,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset casesVal             = (LSNumberFormat(replace(arrProductVolumeData[i].cases,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset netDollarVal         = (LSNumberFormat(replace(arrProductVolumeData[i].net_dollar,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset originalPoundsVal    = (LSNumberFormat(replace(arrProductVolumeData[i].original_pounds,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset originalCasesVal     = (LSNumberFormat(replace(arrProductVolumeData[i].original_cases,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset originalNetDollarVal = (LSNumberFormat(replace(arrProductVolumeData[i].original_net_dollar,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset oppCasesVal          = (LSNumberFormat(replace(arrProductVolumeData[i].Opportunity_Volume_CS,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset oppPoundsVal         = (LSNumberFormat(replace(arrProductVolumeData[i].Opportunity_Volume_LB,',','',"ALL"),"_-______.__") / prgSpan) * 7 />
			<cfset poundsSum            += arrProductVolumeData[i].pounds />
			<cfset casesSum             += arrProductVolumeData[i].cases />

			<!--- populate data into temp table --->
			<cfquery name="qryInsertTempVolume" datasource="#application.datasource#" >
				SET NOCOUNT ON
				INSERT INTO ##tmpProdVolume
				(
					BSA_Foodservice_Items_Master_ID,
					Volume_LB,
					Volume_CS,
					Net_Dollar,
					Original_Volume_LB,
					Original_Volume_CS,
					Original_Net_Dollar,
					Opportunity_Volume_LB,
					Opportunity_Volume_CS
				)
				VALUES
				(
					'#arrProductVolumeData[i].bsa_foodservice_items_master_id#',
					#poundsVal#,
					#casesVal#,
					#netDollarVal#,
					#originalPoundsVal#,
					#originalCasesVal#,
					#originalNetDollarVal#,
					#oppPoundsVal#,
					#oppCasesVal#
				)
			</cfquery>

		</cfloop>

		<cfif (ContractQuantityUOM EQ 1)>
			<cfset contractSum = casesSum />
		<cfelseif (ContractQuantityUOM EQ 2)>
			<cfset contractSum = poundsSum />
		</cfif>

		<cfset contractQty = contractSum/prgSpan />

		<cfquery name="qryContractVolumeUpdate" datasource="#application.datasource#" >
			UPDATE Contract_Main
			SET    Contract_Quantity = #contractSum#,
				   Contract_Daily_Volume = #contractQty#
			WHERE  Contract_Main_ID = #ProgramId#
		</cfquery>

		<!--- delete program product volume --->
		<cfquery name="qryDeleteVolume" datasource="#application.datasource#" >
			DELETE FROM Program_Product_Volume
			WHERE Program_ID = #ProgramId# AND Is_Group = 0
		</cfquery>

		<!--- insert into program product volume from temp table --->
		<cfquery name="qryInsertVolume" datasource="#application.datasource#" >
			SET NOCOUNT ON
			INSERT INTO Program_Product_Volume
					(Program_ID, BSA_Foodservice_Items_Master_ID,
					Volume_LB, Volume_CS, Net_Dollar,
					Original_Volume_LB, Original_Volume_CS, Original_Net_Dollar, Opportunity_Volume_LB, Opportunity_Volume_CS,
					Estimated_Volume_CS, Estimated_Volume_LB, Volume_Cap_UOM)
			SELECT	#ProgramId#, BSA_Foodservice_Items_Master_ID,
					Volume_LB, Volume_CS, Net_Dollar,
					Original_Volume_LB, Original_Volume_CS, Original_Net_Dollar, Opportunity_Volume_LB, Opportunity_Volume_CS,
					Volume_CS, Volume_LB, #ContractQuantityUOM#
			FROM  	##tmpProdVolume
		</cfquery>

	<!---D35145: Volume Applicator - Disable Auto Volume START --->
				<cfquery name="qryUpdateAutoVolumeUpdates" datasource="#application.datasource#" >
					UPDATE Contract_Main_Aux_Data
					SET    Exclude_From_Auto_Volume_Updates = <cfqueryparam value="#arguments.excludeAutoVolumeUpdates#" cfsqltype="cf_sql_integer">
					WHERE  Contract_Main_ID = <cfqueryparam value="#ProgramId#" cfsqltype="cf_sql_integer">
				</cfquery>
		<!---D35145: Volume Applicator - Disable Auto Volume END --->

				<cfquery name="qryInsertLog" datasource="#application.datasource#" >
					INSERT INTO Program_Exclude_From_Auto_Volume_Update_Log (Contract_Main_ID, Exclude_From_Auto_Volume_Updates, Updated_By)
					SELECT	Contract_Main_ID, Exclude_From_Auto_Volume_Updates, '#arguments.UserID#'
					FROM	Contract_Main_Aux_Data
					WHERE	Contract_Main_ID = <cfqueryparam value="#ProgramId#" cfsqltype="cf_sql_integer">
				</cfquery>

		<cfquery datasource="#application.datasource#">
			if object_id('tempdb..##tmpProdVolume') is not null
			drop table ##tmpProdVolume
		</cfquery>

		<cfset bIsGroupDeal = CreateObject("component", "components.products.group.DataManager").isGroupDeal(ProgramId) />
		<cfif bIsGroupDeal>
			<!--- sum the volume at item level to set the group level volume --->
			<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_GROUP_VOLUME_UPDATE" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Program_ID" value="#ProgramId#" null="no">
			</cfstoredproc>
		</cfif>

		<!---
			D78047 :: NOT NEEDED :: Table had 1 billion rows and not used.
			<cfstoredproc procedure="Program_Product_Volume_Per_Year_Populate" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@contract_main_id" value="#ProgramId#" null="no">
			</cfstoredproc>
		--->

		<cfif ArrayLen(arrProductVolumeData) GT 0>
			<cfif arrArgVolumeData[1].forecast_id neq "">
				<cfquery name="qryUpdateContractForecastId" datasource="#application.datasource#" >
					UPDATE Contract_Main_Aux_Data
					SET    Forecast_ID = <cfqueryparam value="#arrArgVolumeData[1].forecast_id#" cfsqltype="cf_sql_integer">
					WHERE  Contract_Main_ID = <cfqueryparam value="#ProgramId#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cfif>
		</cfif>

		<!--- In this function (above), Contract_Quantity is being updated in the "Contract_main_Table". There is some added logic in the
		"Update_Program_Volume" SP. which updates the volume too. Before calling this SP, we need to make sure that the "Program_Product_Volume"
		table is populated.
		--->
		<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Contract_Main_ID" value="#ProgramId#" null="no">
		</cfstoredproc>

		<!--- SP Program_Weight_Update will update program distributor weight based on volume --->
		<cfstoredproc procedure="Program_Weight_Update" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName="@Contract_Main_ID" value="#ProgramId#" null="no">
		</cfstoredproc>

		<!--- Tim Ford - Label 38939 Change Program Volume without a Revision: Adding code to handle for volume changes without revising the program --->
		<cfif qryProgramDetails.Approved eq 1>

			<cfquery datasource="#application.datasource#" name="qTempAdjustVolume">
				-- Remove from BO_Contract_Product_Margin table
				DELETE FROM BO_Contract_Product_Margin where Contract_Main_ID = '#ProgramId#'
				-- Run margin to get the trade spend updated in Forge and margin values updated in BO
				EXEC BO_GET_PROFIT_MARGIN_LAYERED '#ProgramId#'
				-- Update committed dollar
				EXECUTE ADV_BUDGET_COMMITTED_DOLLAR_UPDATE 0, '#ProgramId#'
				-- Add to Vantage daily refresh list
				DELETE      BO_Trade_Program_Detail_Approved_Programs
				WHERE       Contract_Main_ID = '#ProgramId#'
			</cfquery>

		</cfif>

		<cfcatch>
			<cfset errorFlag = 1 />
			<cfset strCaughtError = "Type: " & cfcatch.type & " Message: " & cfcatch.message & " Details: " & cfcatch.detail />
		</cfcatch>

		</cftry>
		<!---------------------------------------------------------------------------
		This message will get returned to the Flex and be shown to the user as an alert
		--->
		<cfif (errorFlag EQ 1)>
			<cfset strMessage = "Error Updating Volume:  " & strCaughtError />
		<cfelse>
			<cfset strMessage = "Data has been saved!" />
		</cfif>

		<cfif arguments.sReturnType eq "struct">
			<cfset returnValue = StructNew() />
			<cfset returnValue.error = errorFlag />
			<cfset returnValue.message = strMessage />
			<cfreturn returnValue />
		<cfelse>
			<cfreturn strMessage />
		</cfif>

	</cffunction>

    <!---------------------------------------------------------------------------
  	  Returns a structure (settings) to flex that contains cf AppSettings
	  --------------------------------------------------------------------------->
  <cffunction name="getSettingsObject" returntype="Struct" access="remote">
      <!-----------------------------------------------------------------------
        Flex will send the programId as the parameter on this function call
        so that Rebate_Percentage_On_Net_Sales value can be determined
      ------------------------------------------------------------------------->
		  <cfargument name="programId" default="0">
       	<cfset var stsettings = structnew()/>
      <cfset stsettings.appflex = structnew()/>

      <!-----------------------------------------------------------------------
        This query return the Rebate_Percentage_On_Net_Sales  based on the
        ProgramId that is passed to this query.
      ------------------------------------------------------------------------->
      <cfquery name="qryGetProgramDetails" DATASOURCE="#application.datasource#">
        SELECT   COUNT(*) as Rebate_Percentage_On_Net_Sales
        FROM Program_Rebates_Component
        INNER JOIN Program_Rebates_Component_Name
        ON        Program_Rebates_Component_Name.program_rebates_component_name_id = Program_Rebates_Component.program_rebates_component_name_id
        INNER JOIN program_Rebates_Component_Data
        ON        Program_Rebates_Component_Data.program_rebates_component_id = Program_Rebates_Component.program_rebates_component_id
        AND      Program_Rebates_Component_Data.deleted = 0
        AND      Program_Rebates_Component_Data.unit_of_measure_id = 3
        WHERE  Program_Rebates_Component.program_id = #arguments.ProgramId#
        AND      Program_Rebates_Component.deleted = 0
        AND      Program_Rebates_Component_Name.Rebate_Percent_Option_ID = 1
      </cfquery>

      <!-----------------------------------------------------------------------
          Check to make sure if the value returned by the above query is
          greater than or equal to 1 or else set the value to 0
      ------------------------------------------------------------------------->
      <cfif qryGetProgramDetails.Rebate_Percentage_On_Net_Sales GTE 1>
        <cfset RebatePercentageOnNetSales = qryGetProgramDetails.Rebate_Percentage_On_Net_Sales />
      <cfelse>
        <cfset RebatePercentageOnNetSales  = 0 />
      </cfif>

      <!-----------------------------------------------------------------------
        Get all the setting that are required on the flex page from the
        application scope and set them into the structure stsettings
      ------------------------------------------------------------------------->
      <cfset stsettings.appflex.cfapp_ShipTo = application.returned_customer_setting.shard_ship_to_label />

      <cfif application.returned_customer_setting.distributor_label_singular NEQ "">
	      <cfset stsettings.appflex.cfapp_CustomerLabel = application.returned_customer_setting.distributor_label_singular />
	    <cfelse>
	      <cfset stsettings.appflex.cfapp_CustomerLabel = "Distributor" />
	    </cfif>

      <cfif application.returned_customer_setting.item_label NEQ "">
        <cfset stsettings.appflex.cfapp_ItemLabel     = application.returned_customer_setting.item_label />
      <cfelse>
	      <cfset stsettings.appflex.cfapp_ItemLabel  = "Item" />
	    </cfif>

  <cfset stsettings.appflex.cfapp_PoundLabel  = Application.UOMPoundPlural /> <!--- 36877 --->

      <cfif application.returned_customer_setting.operator_label_singular NEQ "">
        <cfset stsettings.appflex.cfapp_OperatorLabel     = application.returned_customer_setting.operator_label_singular />
      <cfelse>
	      <cfset stsettings.appflex.cfapp_OperatorLabel  = "Operator" />
	    </cfif>

      <!-----------------------------------------------------------------------
        Add the query result (single) value as a variable in the structure
        passed to Flex
      ------------------------------------------------------------------------->
      <cfset stsettings.appflex.cfapp_rebatePercentageOnNetSales = RebatePercentageOnNetSales />

	   <cfreturn stsettings>

  </cffunction>

  <cffunction name="getForecastValidity" Hint = "Find out if the program has changed after prior forecast" access="public" output="false" returntype="struct">
	<cfargument name="ProgramId" default="0">


	<cfquery name="qGetForecastMismatch" datasource="#application.datasource#">
		SET NOCOUNT ON

		DECLARE @Forecast_ID int,
				@Operator_Program bit,
				@Op_In_Forecast_Not_In_Program int,
				@Op_In_Program_Not_In_Forecast int,
				@Dist_In_Forecast_Not_In_Program int,
				@Dist_In_Program_Not_In_Forecast int

		SET @Op_In_Forecast_Not_In_Program = 0
		SET @Op_In_Program_Not_In_Forecast = 0
		SET @Dist_In_Forecast_Not_In_Program = 0
		SET @Dist_In_Program_Not_In_Forecast = 0

		SELECT	@Forecast_ID = Forecast_ID
		FROM	Contract_Main_Aux_Data
		WHERE  	Contract_Main_ID = <cfqueryparam value="#ProgramId#" cfsqltype="cf_sql_integer">

		IF @Forecast_ID IS NOT NULL AND @Forecast_ID <> 0
		BEGIN

			select	@Operator_Program = case when program_control_panel_options.generic_type in ('Operator Direct or HQ Programs', 'Operator-Deviated Pricing') then 1 else 0 end
			from	contract_main
			inner join program_control_panel_options
			on		program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
			where	contract_main_id = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">

			IF @Operator_Program = 1
			BEGIN

				IF OBJECT_ID('tempdb..##tmp_op') IS NOT NULL
				DROP TABLE ##tmp_op

				select	distinct bsa_operator_id
				into	##tmp_op
				from	contract_operators
				where	contract_operators.contract_main_id = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
				and		contract_operators.deleted = 0
				and     contract_operators.Is_Group = 0	<!--- D37779 :Auto apply volume error --->

				SELECT	@Op_In_Forecast_Not_In_Program = Count(*)
				FROM	Forecast_Operator
				WHERE	Forecast_ID = @Forecast_ID
				AND		BSA_Operator_ID NOT IN (select bsa_operator_id from ##tmp_op)

				SELECT	@Op_In_Program_Not_In_Forecast = Count(*)
				FROM	##tmp_op
				WHERE	bsa_operator_id NOT IN (select BSA_Operator_ID from Forecast_Operator WHERE	Forecast_ID = @Forecast_ID)

				IF OBJECT_ID('tempdb..##tmp_op') IS NOT NULL
				DROP TABLE ##tmp_op

			END
			ELSE
			BEGIN

				IF OBJECT_ID('tempdb..##tmp_dist') IS NOT NULL
				DROP TABLE ##tmp_dist

				select	distinct bsa_foodservice_customers_id
				into	##tmp_dist
				from	contract_distributors
				where	contract_distributors.contract_main_id = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
				and		contract_distributors.deleted = 0
				and		contract_distributors.is_group = 0

				SELECT	@Dist_In_Forecast_Not_In_Program = Count(*)
				FROM	Forecast_Distributor
				WHERE	Forecast_ID = @Forecast_ID
				AND		Distributor_ID NOT IN (select bsa_foodservice_customers_id from ##tmp_dist)

				SELECT	@Dist_In_Program_Not_In_Forecast = Count(*)
				FROM	##tmp_dist
				WHERE	bsa_foodservice_customers_id NOT IN (select Distributor_ID from Forecast_Distributor WHERE	Forecast_ID = @Forecast_ID)

				IF OBJECT_ID('tempdb..##tmp_dist') IS NOT NULL
				DROP TABLE ##tmp_dist

			END

		END

		SELECT 	@Forecast_ID as Forecast_ID,
				@Op_In_Forecast_Not_In_Program as Op_In_Forecast_Not_In_Program,
				@Op_In_Program_Not_In_Forecast as Op_In_Program_Not_In_Forecast,
				@Dist_In_Forecast_Not_In_Program as Dist_In_Forecast_Not_In_Program,
				@Dist_In_Program_Not_In_Forecast as Dist_In_Program_Not_In_Forecast
	</cfquery>

	<cfset stReturnValue = StructNew() />
	<cfset stReturnValue.forecastId = qGetForecastMismatch.Forecast_ID />
	<cfset stReturnValue.operatorsNotInProgram = qGetForecastMismatch.Op_In_Forecast_Not_In_Program />
	<cfset stReturnValue.operatorsNotInForecast = qGetForecastMismatch.Op_In_Program_Not_In_Forecast />
	<cfset stReturnValue.distributorsNotInProgram = qGetForecastMismatch.Dist_In_Forecast_Not_In_Program />
	<cfset stReturnValue.distributorsNotInForecast = qGetForecastMismatch.Dist_In_Program_Not_In_Forecast />


	<cfreturn stReturnValue />

  </cffunction>

	<cffunction name="getVolumeProductGroupTypes" hint="returns a list of product group types" access="remote" output="false" returntype="any">

		<cfargument name="programId" required="true" />

		<cfscript>
			//set local variables
			var nProgramId				= "";
			var nFirstParentId			= "";
			var qGetFirstProgramTypeID	= "";
			var objGroupDataManager		= "";
			var qGetProductGroupTypes	= "";
			var qProductGroupsOrderBy	= "";
			var qReturn					= "";

			//assign local variables
			nProgramId = arguments.programId;
			objGroupDataManager = CreateObject("component", "components.products.Group.DataManager");
		</cfscript>

		<cfquery name="qGetFirstProgramTypeID" datasource="#application.datasource#">
			SELECT DISTINCT First_Parent_ID FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_ID IN
			(
				SELECT ProgramType_ID FROM Contract_Main WHERE Contract_Main_ID = <cfqueryparam value="#nProgramId#" cfsqltype="CF_SQL_INTEGER" />
			)
		</cfquery>

		<cfscript>

			nFirstParentId = qGetFirstProgramTypeID.First_Parent_ID;
			//get the group types based on template
			qGetProductGroupTypes = objGroupDataManager.getProductGroupsData(FirstParentID = nFirstParentId, filterProgramVolume = 1);

			QueryAddRow(qGetProductGroupTypes);
			QuerySetCell(qGetProductGroupTypes, "Product_Group_Level_ID", "0");
			QuerySetCell(qGetProductGroupTypes, "Group_Level_Desc", "Product");
			QuerySetCell(qGetProductGroupTypes, "List_Order", "0");


		</cfscript>

		<!--- TODO: Remove this query of a query hack and let the volue applicator set product as the default --->
		<cfset useLakebaseForqProductGroupsOrderBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetproductgrouptypes")>
<cfif useLakebaseForqProductGroupsOrderBy>
	<cftry>
		<cfset qProductGroupsOrderBy = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetproductgrouptypes", {
				"order" = "list_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqProductGroupsOrderBy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqProductGroupsOrderBy>
<cfquery name="qProductGroupsOrderBy" dbtype="query">
			SELECT	*
			FROM	qGetProductGroupTypes
			ORDER BY List_Order
		</cfquery>
</cfif>

		<cfscript>
			//set and return product group types
			qReturn = qProductGroupsOrderBy;
			return qReturn;
		</cfscript>

	</cffunction>

	<cffunction name="getVolumeApplyToUOM" hint="returns a list UOMs for apply to action" access="remote" output="false">
		<cfargument name="programId" required="true" />

        <cfquery name="local.qProgramTemplate" datasource="#application.datasource#">
            SELECT Volume_Page_UOM_CS
                ,Volume_Page_UOM_LB
                ,RateTypeDefault
            FROM Program_Control_Panel_Options pcpo
            INNER JOIN Contract_Main cm ON cm.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID
                AND cm.Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfscript>
            local.uoms = [3];           // percentage uom

            // each default or sleeve default
            if (local.qProgramTemplate.RateTypeDefault eq 5 or local.qProgramTemplate.RateTypeDefault eq 7)
                arrayAppend(local.uoms, local.qProgramTemplate.RateTypeDefault);
            else {
                // include case
                if (local.qProgramTemplate.Volume_Page_UOM_CS eq 1)
                    arrayAppend(local.uoms, 1);
                // include pound
                if (local.qProgramTemplate.Volume_Page_UOM_LB eq 1)
                    arrayAppend(local.uoms, 2);
            }
        </cfscript>

		<cfquery name="local.qGetUOM" datasource="#application.datasource#">
			SELECT 	u.Unit_Of_Measure_ID, u.Abbreviation
			FROM 	Units_of_Measure u
			WHERE 	u.Unit_Of_Measure_ID IN (<cfqueryparam list="true" value="#arrayToList(local.uoms)#">)
			ORDER BY u.Unit_Of_Measure_ID
		</cfquery>

		<cfreturn local.qGetUOM>
	</cffunction>

</cfcomponent>