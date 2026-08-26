
<cfcomponent rest="true" restpath="Planner" extends="Service" produces="application/json">
	<cfproperty name="Planner_Template_Id"	type="numeric"/>
	<cfproperty name="Program_Template_Id"	type="numeric"/>
	<cfproperty name="Batch_Id"				type="numeric"/>
	<cfproperty name="User_Positions_ID"	type="string"/>
	<cfproperty name="User_Id"				type="string"/>
	<cfproperty name="user_Code"			type="string"/>
	<cfproperty name="Forge_Planner_Id"		type="string"/>
	<cfproperty name="Fiscal_Year"			type="string"/>
	<cfset this.noAuthMessage='NOT TODAY'/>

	<cffunction name="Create" access="remote" returntype="any" httpmethod="POST" restpath="Create" output='false'>
		<cfargument name="plan" required="true" restargsource="Form" type="string"/>
		<cfscript>
			if(!request.bAuthorized){
					return serializeJson(this.noAuthMessage);
			}

			try{
				jsonFileName = "tpoPlan_" & DateTimeFormat(now(),"mmddyy_hhnnss") & ".json";
				jsonFilepath = application.Doc_Path & "\Data_Files\Created\settings\Planners\"  & jsonFileName;
				FileWrite(jsonFilepath, arguments.plan);

				var newPlan = deserializeJson(arguments.plan);
				/* rename the file with PlanId after parsing in case the parser throws an error we already have the file */
				newJsonFilepath = Replace(jsonFilepath,"tpoPlan_","tpo_#newPlan.Planner.Planner_Id#_");
				FileMove(jsonFilepath, newJsonFilepath);

				var response = CreateObject("component","components.Interfaces.Service.CreateResponse").init();
				var detail = CreateObject("component","components.Interfaces.Service.Detail").init();
				var planMan = CreateObject("component","mvc.Models.Planner.PlannerManager");
				var plannerId = 0;
				var aDetail	= ArrayNew(1);
				//  Find the TPO specific pg & planner templates.  Only 1 each...may need a setting.
				this.Fiscal_Year = LEFT(Right(newPlan.Planner.Planner_Id,7), 4);
				this.PERIOD = Right(newPlan.Planner.Planner_Id,2);
				this.CUSTOMER = listFirst(newPlan.Planner.Planner_Id, '-');
				// set base line response info before we start parsing data
				response["Planner_Id"]  = newPlan.Planner.Planner_Id;
				response["Fiscal_Year"]  = this.Fiscal_Year;
				response["Forge_Planner_Id"]  = "";

				plannerId = this.parseData(newPlan);

				if(plannerId > 0){
					response["Status"]  = "SUCCESS";
					response["Forge_Planner_Id"]  = this.getPlannerNumber(plannerId);
				}
				else{
					response["Status"]  = "Planner not created";
				}
				response["Batch_Id"] = this.Batch_ID;
				response["Details"] = this.getResponse();
			} catch (any e) {
				sError = 'REST Planner Upload ERROR::  #e.Message# :: #e.Detail#';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				response["Status"] = sError;
				response["Batch_Id"] = this.Batch_ID;
				response["Details"] = this.getResponse();
				/*  this error gets thrown to site wide errorhandler in components.Interfaces.Service.Application.onRequestEnd() */
				Request.tpoInterfaceError = e;
				return serializeJson(response);
			}
        	return serializeJson(response);
		</cfscript>
	</cffunction>

	<cffunction name="parseData" access="public" returntype="any" output="false">
		<cfargument name="p" required="true" type="any" />

		<cfscript>
			var rowData = '';
			var plannerId = 0;
			var plan = arguments.p.Planner;
		    var arrPrg = arguments.p.Planner.Programs;
		    var q = this.getPositionId(plan.Responsible_Sales_Person, plan.RSP_Position);			
		    var uploadMan = CreateObject("component","mvc.Models.Program.Upload.ProgramUploadManager");

		    this.planner = plan;
		</cfscript>
		<cfquery name="qGetBatchId" datasource="#application.datasource#">
			Select (isnull(max(Batch_ID), 0)+1) as next_batch_id from Y_DEAL_UI_Upload
		</cfquery>
		<cfset this.Batch_Id = qGetBatchId.next_batch_id />
		<cfscript>
			arrPrg = arguments.p.Planner.Programs;

			this.Planner_Template_ID = -1;
			this.Program_Template_Id = -1;
			this.parsePrograms(arrPrg,this.Batch_Id);
			this.setProgramTemplate();
			this.setPlannerTemplate(this.Fiscal_Year, this.PERIOD, this.CUSTOMER);
			var bIsValid = uploadMan.validateUpload(this.Batch_Id);
			if(bIsValid){ //validate the "Feature Price"
				bIsValid = this.validateRetailPrice();
			}
			if(bIsValid){
				plannerId = this.parsePlan(plan, this.Batch_Id);
				
				//this.dmp(plannerId);

				if(plannerId > 0){
					uploadMan.exceuteUpload(this.Batch_Id);
					this.savePlannerVolume(plannerID);
					this.updPrgPlanId(plannerId);
					this.saveRetailPrice(plannerId);
				}
			}
			return plannerId;
		</cfscript>
	</cffunction>

	<cffunction name="getResponse" access="public" returntype="array" output="false" >

		<cfquery name="qGetResponse" datasource="#application.datasource#">
			SELECT * 
			FROM  [dbo].[LOG_Y_DEAL_Program_Upload] 
			WHERE Batch_Id = '#this.Batch_Id#'
		</cfquery>

		<cfscript>
			var detail = '';
			var arr = ArrayNew(1);

			for (row in qGetResponse) {
				detail = CreateObject("component","components.Interfaces.Service.Detail").init();
			    detail["Legacy_Program_Id"] = row.LEGACY_PROGRAM_ID;
				detail["Forge_Program_Id"] = row.BA_Program_ID;
				detail["Description"] = row.Upload_Description;
				detail["Detail_Id"] = row.Y_DEAL_UI_Upload_ID;
			    //this.dmp(row);
			    arrayAppend(arr, detail);
			}
						
			return arr;
		</cfscript>
	</cffunction>

	<cffunction name="updPrgPlanId" access="public" returntype="any" output="false" >
		<cfargument name="pId" required="true" type="numeric" />

		<cfquery name="qGetResponse" datasource="#application.datasource#">
			UPDATE CM SET 
				Planner_ID = #arguments.pId#,
				Delivery_start_date = Contract_Start_Date,
				Delivery_End_Date = Contract_End_Date
			FROM Contract_Main CM 
			INNER JOIN LOG_Y_DEAL_Program_Upload U ON U.BA_Program_Id = CM.Contract_Number
			WHERE Batch_Id = '#this.Batch_Id#'

			EXEC Planner_Program_Product_Volume_From_Volume_Plan null, null, #arguments.pId#
		</cfquery>

		<cfscript>
			return 'updPrgPlanId';
		</cfscript>
	</cffunction>

<!--- 	<cffunction name="validatePrograms" access="public" returntype="any" output="false">
		<cfargument name="batchId" required="true" type="numeric" />
		<cftry>
			<cfstoredproc procedure="USP_Unified_Program_Upload_Validate" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" value="#arguments.batchId#" null="no" />
				<cfprocparam type="Out" cfsqltype="CF_SQL_INTEGER" variable="bIsValid" />
			</cfstoredproc>
			<cfcatch type="any">
				<cfreturn cfcatch.message />
			</cfcatch>
		</cftry>

		<cfreturn bIsValid />
	</cffunction> --->

	<cffunction name="parsePrograms" access="public" returntype="any" output="false">
		<cfargument name="arr" required="true" type="array" />
		<cfargument name="bId" required="true" type="numeric" />

		<cfscript>
			var rowData  = '';
			var rowDataDist  = '';
			var rowDataReb  = '';
			var rowDataLump  = '';
			var rowDataVol  = '';

			var arrDist  = '';
			var arrReb  = '';
			var arrLump  = '';
			var arrVol  = '';
		    var arrPrg	 = arguments.arr;
		    var Batch_ID = arguments.bId;
		    var UOM_OverRide = application.util.query.get_setting("TPO_Planner_Volume_UOM_Over_Ride", 0);
		</cfscript>

		<cfscript>
			for (i=1;i LTE ArrayLen(arrPrg);i=i+1){
				prg = arrPrg[i];
				rowData = getRowData();

				//this.dmp(rowData.Group);

				rowData.Template = this.Program_Template_Id;
				rowData.Batch_ID = Batch_ID;
				rowData.Record_Type = 'H';
				rowData.Header_Action = 'A';
				rowData.External_Program = prg.Legacy_Program_ID;
				//rowData.FORGE_Program = ;
				rowData.Title = prg.Program_Title;
				rowData.Start = prg.Program_Start_Date;
				rowData.End = prg.Program_End_Date;
				rowData.Performance_Start = prg.Performance_Start;
				rowData.Performance_End = prg.Performance_End;
				var perfType = '';
				rowData.Performance_Type = getPerfType(prg.Performance_Type);
				//rowData.Planner_ID = prg.Planner_ID;
				rowData.RSP_ID = len(this.user_Code) ? this.user_Code : this.planner.Responsible_Sales_Person;
				rowData.Position_ID = this.User_Positions_ID;
				rowData.Creator_ID = this.User_Id;
				//rowData.Segment = '';
				this.insertUploadData(rowData);

				// Customers
				arrDist = prg.Distributors;
				for (x=1;x LTE ArrayLen(arrDist);x=x+1){
					dist = arrDist[x];
					rowDataDist = getRowData();
					rowDataDist.Batch_ID = Batch_ID;
					rowDataDist.Record_Type = 'C';
					rowDataDist.External_Program = prg.Legacy_Program_ID;
					rowDataDist.Creator_ID = this.User_Id;
					rowDataDist.Template = this.Program_Template_Id;

					rowDataDist.Sold_To = dist.Distributor_Id;
    				if(dist.Group neq "DST"){
                        rowDataDist.Group_Id = dist.Distributor_Id;
                    }
					rowDataDist.Group_Type = dist.Group;
					
					//this.dmp(rowDataDist.Group_Type);

					this.insertUploadData(rowDataDist);
				}

				// Rebates
				arrReb = prg.Rebates;
				for (y=1;y LTE ArrayLen(arrReb);y=y+1){
					reb = arrReb[y];
					comp = this.getRebateComponent(reb.External_Component_ID);
					claim = this.getClaimMechanic(reb.Claim_Mechanic);

					rowDataReb = getRowDataRebate();
					rowDataReb.Batch_ID = Batch_ID;
					rowDataReb.Record_Type = 'M';
					rowDataReb.External_Program = prg.Legacy_Program_ID;
					rowDataReb.Creator_ID = this.User_Id;
					rowDataReb.Template = this.Program_Template_Id;
					if(UOM_OverRide != ''){
						rowDataReb.UOM = UOM_OverRide;
					}
					else{
						if(IsDefined('reb.Rebate_Unit_of_Measure')){
							rowDataReb.UOM = reb.Rebate_Unit_of_Measure;
						}
					}
					if(IsDefined('reb.Payment_Frequency')){rowDataReb.Frequency = reb.Payment_Frequency;}
					if(IsDefined('reb.Currency')){rowDataReb.Currency = reb.Currency;}
					if(IsDefined('reb.Pays_To')){rowDataReb.Pays_To = reb.Pays_To;}

					rowDataReb.Material = reb.Item_Number;
					rowDataReb.Product_Level_ID = reb.Group;
					if(isnumeric(reb.Rebate_Amount)){
						rowDataReb.Rate = reb.Rebate_Amount;
					}
					if(IsDefined('reb.Scan_Redemption_Pct') &&  isnumeric(reb.Scan_Redemption_Pct)){
						rowDataReb.Scan_Redemption_Pct = reb.Scan_Redemption_Pct; // Program_Rebates_Component_Data.Scan_Percentage
					}
					rowDataReb.Component = len(comp) ? comp : ':#reb.External_Component_ID#:'; /* Add : : since TPO may send an unmapped External_Id*/
					rowDataReb.Claim_Mechanic = claim; //reb.Claim_Mechanic
					rowDataReb.Volume = 1;
					rowDataReb.VOLUME_UOM = 'CS';
					this.insertUploadData(rowDataReb);
				}

				// Lump Sum
				arrLump = prg.LumpSums;
				for (z=1;z LTE ArrayLen(arrLump);z=z+1){
					lump = arrLump[z];
					if(z == 1 ){
						lsComp = this.getLumpSumComponent(lump.LS_component_Name);
					}
					rowDataLump = getRowDataRebate();
					rowDataLump.Batch_ID = Batch_ID;
					rowDataLump.Record_Type = 'M';
					rowDataLump.Discount_Type = 'L';
					rowDataLump.External_Program = prg.Legacy_Program_ID;
					rowDataLump.Creator_ID = this.User_Id;
					rowDataLump.Template = this.Program_Template_Id;

					if(IsDefined('reb.Payment_Frequency')){rowDataLump.Frequency = lump.Payment_Frequency;}
					if(IsDefined('reb.Currency')){rowDataLump.Currency = lump.Currency;}
					if(IsDefined('reb.Pays_To')){rowDataLump.Pays_To = lump.LS_Pays_To;}

					rowDataLump.Material = lump.Item_Number;
					rowDataLump.Product_Level_ID = lump.Group;
					if(isnumeric(lump.LS_Amount)){
						rowDataLump.Rate = lump.LS_Amount;
					}
					rowDataLump.UOM = '$';
					rowDataLump.Component = len(lsComp) ? lsComp : ':#lump.LS_component_Name#:'; /* Add : : since TPO may send an unmapped External_Id*/
					rowDataLump.Claim_Mechanic = lump.Claim_Mechanic;
					rowDataLump.Volume = 1;
					rowDataLump.VOLUME_UOM = 'CS';
					this.insertUploadData(rowDataLump);
				}
				// Retail_Prices
				arrRetailPrices = prg.Retail_Prices;
				for (n=1;n LTE ArrayLen(arrRetailPrices);n=n+1){
					rp = arrRetailPrices[n];
					rowDataRtlPrc = getRowData();
					rowDataRtlPrc.Batch_ID = Batch_ID;
					rowDataRtlPrc.Record_Type = 'RP';
					rowDataRtlPrc.External_Program = prg.Legacy_Program_ID;
					rowDataRtlPrc.Creator_ID = this.User_Id;
					rowDataRtlPrc.Template = this.Program_Template_Id;
					rowDataRtlPrc.Material = rp.Item_Number;
					rowDataRtlPrc.Product_Level_ID = rp.Group;
					if(isnumeric(rp.Feature_Price)){
						rowDataRtlPrc.rate = rp.Feature_Price;	
					}
					rowDataRtlPrc.EveryDay_Unit_Price = rp.Everyday_Price;
					this.insertUploadData(rowDataRtlPrc);
				}
				this.updateVolume(Batch_ID);
			}
			return '';
		</cfscript>
	</cffunction>

	<cffunction name="getPerfType" access="public" returntype="any" output="false">
		<cfargument name="TPO_Perf" required="true"/>

		<cfset useLakebaseForqPerfType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planner_perf_types")>
<cfif useLakebaseForqPerfType>
	<cftry>
		<cfset qPerfType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planner_perf_types", {
				"tpo_name" = "eq.#arguments.TPO_Perf#",
				"select" = "description"
			}), "description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqPerfType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqPerfType>
<cfquery name="qPerfType" datasource="#application.datasource#">
			SELECT 	Description
			FROM 	Planner_Perf_Types
			WHERE	TPO_Name = '#arguments.TPO_Perf#'
		</cfquery>
</cfif>

		<cfreturn qPerfType.Description>
	</cffunction>

	<cffunction name="parsePlan" access="public" returntype="any" output="false">
		<cfargument name="p" required="true" type="any" />
		<cfargument name="bId" required="true" type="numeric" />

		<cfscript>
			var planMan = createObject( "component", "mvc.Models.Planner.PlannerManager");
			var rowData  = '';
			var plan	 = arguments.p;
			var Batch_ID = arguments.bId;
			var plannerId 	 = 0;
			
			var  arrVol = ArrayNew(1);

			//this.setPlannerTemplate(this.Fiscal_Year, this.PERIOD, this.CUSTOMER);
		</cfscript>

		<cfquery name="qgetCust" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_Group_Type') IS NOT NULL
				DROP TABLE ##tmp_Group_Type

			SELECT	TOP 1 Group_Type, 
					CASE ISNULL(Group_Type, '')  
						WHEN 'DST' THEN '0'  
						WHEN 'FAM' THEN '2'  
						WHEN 'BGP' THEN '3'  
						WHEN 'CID' THEN '5'  
						WHEN 'DTP' THEN '7'  
					END AS Group_Level
			INTO	##tmp_Group_Type
			FROM	Y_DEAL_UI_Upload
			WHERE	Batch_ID = '#this.Batch_ID#'
			AND		Record_Type = 'C'

			SELECT All_Customer_Group_Types.Group_GUID AS Bsa_Foodservice_Customers_Id, All_Customer_Group_Types.Distributor_Group_Level_ID 
			FROM	All_Customer_Group_Types 	
			INNER JOIN Distributor_Group_Level on Distributor_Group_Level.Distributor_Group_Level_ID = All_Customer_Group_Types.Distributor_Group_Level_ID 
			INNER JOIN ##tmp_Group_Type ON ##tmp_Group_Type.Group_Level = Distributor_Group_Level.Distributor_Group_Level_ID
			WHERE All_Customer_Group_Types.Group_Number = '#this.CUSTOMER#'
		</cfquery>
		
		<cfif qgetCust.recordCount eq 0>
			<cfquery name="qgetCust" datasource="#application.datasource#">
				SELECT Bsa_Foodservice_Customers_Id, 0 as Distributor_Group_Level_ID 
				FROM Bsa_Foodservice_Customers 
				WHERE Ship_to = '#this.CUSTOMER#'
			</cfquery>
		</cfif>

		<cfquery name="qgetPlan" datasource="#application.datasource#">

			 SELECT P.Planner_Id, P.Planner_number-- , PW.Planner_Month, PW.Planner_Quarter
			 FROM Planners P
			  INNER JOIN Planner_Volume_Plan PVP ON
				PVP.BSA_Foodservice_Customers_Id = P.Customer_ID AND
				P.Deleted = 0
				INNER JOIN planner_week PW on PW.Planner_Week_ID = PVP.Planner_Week_ID
				INNER JOIN Fiscal_Nomenclature FN ON fn.Period_Quarters = PW.Planner_Quarter
			WHERE  P.Customer_id = '#qgetCust.Bsa_Foodservice_Customers_Id#' AND 
				Planner_Template_ID = '#this.Planner_Template_Id#' AND 
				PW.Planner_Year = '#this.Fiscal_Year#' AND 
				(
					Period_Abbr = '#this.PERIOD#'
					OR 
					Period_Alias = '#this.PERIOD#'
				) 
			UNION
			 SELECT P.Planner_Id, P.Planner_number--, PW.Planner_Quarter		-- PW.Planner_Month, 
			 FROM Planners P
			  INNER JOIN Customer_Group_Members CGM
			  ON CGM.Customer_Group_ID = P.Customer_ID
			  AND P.Deleted = 0
			  AND CGM.Deleted = 0
			  INNER JOIN Planner_Volume_Plan PVP ON
				PVP.BSA_Foodservice_Customers_Id = CGM.BSA_Foodservice_Customers_Id
				INNER JOIN dbo.Planner_Week PW on PW.Planner_Week_ID = PVP.Planner_Week_ID
				INNER JOIN Fiscal_Nomenclature FN ON fn.Period_Quarters = PW.Planner_Quarter
			WHERE CGM.Customer_Group_ID = '#qgetCust.Bsa_Foodservice_Customers_Id#' AND 
				CGM.Customer_Group_Type = '#qgetCust.Distributor_Group_Level_ID#' AND
				Planner_Template_ID = '#this.Planner_Template_Id#' AND 
				PW.Planner_Year = '#this.Fiscal_Year#' AND
				(
					Period_Abbr = '#this.PERIOD#'
					OR 
					Period_Alias = '#this.PERIOD#'
				)

		</cfquery>

		<cfscript>
			if(qgetCust.recordcount GT 0 AND qgetPlan.recordcount == 0){  //AND qgetPlan.recordcount == 0
			
				plannerId = planMan.createPlanner(this.User_Id,this.User_Positions_ID,this.User_Id,this.Planner_Template_Id,qgetCust.Bsa_Foodservice_Customers_Id,qgetCust.Distributor_Group_Level_ID);
				arrVol = plan.PlannerVolume;
				// Volume
				for (a=1;a LTE ArrayLen(arrVol);a=a+1){
					vol = arrVol[a];
					rowDataVol = getRowData();
					rowDataVol.Creator_ID = this.User_Id;
					rowDataVol.Start = vol.Start_Date;
					rowDataVol.Record_Type = 'V';
					rowDataVol.Batch_ID = Batch_ID;
					rowDataVol.Sold_To = vol.Distributor_ID;
					rowDataVol.Material = vol.Item_Number;
					rowDataVol.Product_Level_ID = vol.Group;
					rowDataVol.Volume = vol.Base_Volume;
					rowDataVol.Volume_lift = vol.Incr_Volume;
					rowDataVol.VOLUME_UOM = vol.UOM;
					this.insertUploadData(rowDataVol);
				}
			}
			else if(qgetPlan.recordcount > 0){
				arrVol = plan.PlannerVolume;
				//this.dmp(arrVol);
				// Volume
				for (a=1;a LTE ArrayLen(arrVol);a=a+1){
					vol = arrVol[a];
					rowDataVol = getRowData();
					rowDataVol.Creator_ID = this.User_Id;
					rowDataVol.Start = vol.Start_Date;
					rowDataVol.Record_Type = 'V';
					rowDataVol.Batch_ID = Batch_ID;
					rowDataVol.Sold_To = vol.Distributor_ID;
					rowDataVol.Material = vol.Item_Number;
					rowDataVol.Product_Level_ID = vol.Group;
					rowDataVol.Volume = vol.Base_Volume;
					rowDataVol.Volume_lift = vol.Incr_Volume;
					rowDataVol.VOLUME_UOM = vol.UOM;
					this.insertUploadData(rowDataVol);
				}
				return qgetPlan.Planner_Id;
			}
			else{
				return 0;
			}
			return plannerId;
		</cfscript>
	</cffunction>

	<cffunction name="validateRetailPrice" access="public" returntype="boolean" output="false" >
		<cfscript>
			var b = true;
		</cfscript>

		<cfquery name="qgetPlan" datasource="#application.datasource#">
			SELECT U.*
			FROM	Y_DEAL_UI_Upload U
			WHERE	U.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'RP'
					AND u.rate = 0
		</cfquery> 

		

		<cfquery name="qInsertError" datasource="#application.datasource#">
			INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
			SELECT	B.LEGACY_Program_ID, '' , 'FEATURE PRICE IS NOT NUMERIC Item [' + u.Material + ' ] Price [' + cast(u.Rate as Varchar(12)) + ']' , 'REJECTED DEAL','D', B.Batch_ID, B.Y_DEAL_UI_Upload_ID
			FROM	Y_DEAL_BASIC_INFORMATION B
			INNER JOIN Y_DEAL_UI_Upload U ON
				U.Batch_ID = B.Batch_ID AND
				U.External_Program = B.Legacy_Program_Id AND
				U.Record_type = 'RP'
			WHERE		B.REJECTED = 0		
			AND		B.Batch_ID = '#this.Batch_ID#'
			AND u.rate = 0
		</cfquery> 

		<cfscript>
			if(qgetPlan.recordcount > 0){
				b = false;
			}
			return b;
		</cfscript>
	</cffunction>

	<cffunction name="saveRetailPrice" access="public" returntype="any" output="false" >
		<cfargument name="Planner_ID" required="false" default="" type="string" />
		<cfscript>
			var b = true;

		</cfscript>
		<cfquery name="updPrgEDLP" datasource="#application.datasource#">
			UPDATE CM Set is_Edlp = 1
			FROM 	 Y_DEAL_UI_Upload U 
			INNER JOIN LOG_Y_DEAL_Program_Upload L ON
				L.Batch_Id = U.Batch_Id AND
				L.Legacy_Program_Id = U.External_Program
			INNER JOIN Contract_main CM ON
				CM.Planner_ID = '#arguments.Planner_ID#' AND
				CM.Contract_number = L.BA_Program_Id
			INNER JOIN Planner_Perf_Types PPT ON
				PPT.Description = U.Performance_Type
			WHERE U.Batch_Id = '#this.Batch_ID#' AND
				Record_type = 'H' AND
				PPT.Everyday_Price = 1
		</cfquery>
		
 		<cfquery name="updRetailPriceGroup" datasource="#application.datasource#">
			---  UPDATE GroupLevelId
			UPDATE	Y_DEAL_UI_Upload
			SET		[GROUP_ID] =  PGT.Group_GUID  /* CASE WHEN pgl.Is_PG = 1 THEN '100' ELSE pgt.Product_Group_Level_ID END  */
					, DETAIL_Action = Product_Group_Attribute_Master_ID_Field 
			FROM	Y_DEAL_UI_Upload YDUI
					INNER JOIN All_Product_Group_Types pgt ON YDUI.Material = pgt.Group_Number
					INNER JOIN Product_Group_Level pgl on pgl.Product_Group_Level_ID = pgt.Product_Group_Level_ID
					INNER JOIN Product_Group_Attribute PGA ON PGA.Product_Group_Level_ID = pgt.Product_Group_Level_ID 
					AND (
							(ISNULL(YDUI.Product_Level_ID, 0) != 0 AND pgl.Product_Group_Level_ID = YDUI.Product_Level_ID)
							OR
							(ISNULL(YDUI.Product_Level_ID, 0) = 0)
						)
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'RP'

			SELECT DISTINCT DETAIL_Action FROM Y_DEAL_UI_Upload YDUI
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'RP'
		</cfquery> 

		<!--- CUSTOM UOM OVerRide --->
		<cfscript>
			UOM_OverRide = application.util.query.get_setting("TPO_Planner_Volume_UOM_Over_Ride", 0);
			switch(UOM_OverRide) {
			    case "LB": case "LBS": case "EA":
			         Merch_Uom = 2;
			         break;
			    case "CS":
			         Merch_Uom = 1;
			         break;
			    default: 
			         Merch_Uom = 1;
			}
		</cfscript>

		 <cfquery name="qCopyProgramUpdatePrice" datasource="#application.datasource#">
	
			INSERT INTO Contract_group_merchant_info (Program_id, Group_id, Merchant_price, Merchant_quantity, Uom, Everyday_unit_price)
				SELECT 	cm.Contract_main_Id, CASE WHEN ISNULL(U.Group_ID, '') = '' THEN IM.bsa_FoodService_Items_Master_ID ELSE U.Group_ID END, U.Rate, 1, #Merch_Uom#, U.Everyday_unit_price
			FROM 	 Y_DEAL_UI_Upload U 
			INNER JOIN LOG_Y_DEAL_Program_Upload L ON
				L.Batch_Id = U.Batch_Id AND
				L.Legacy_Program_Id = U.External_Program
			LEFT JOIN BSA_FoodService_Items_Master IM
				ON IM.Item = U.Material
			INNER JOIN Contract_main CM ON
				CM.Planner_ID = '#arguments.Planner_ID#' AND
				CM.Contract_number = L.BA_Program_Id
			WHERE U.Batch_Id = '#this.Batch_ID#' AND
				Record_type = 'RP'
		</cfquery> 

		<!--- SET THE EDLP Price.  It is the "Rebate Amount" on the same program when Is_EDLP = 1 --->
		 <cfquery name="qUpdateEDLPData" datasource="#application.datasource#">
			UPDATE CGMI
				SET Everyday_Low_Price = U_Disc.Rate,
					Everyday_Low_Price_UOM = #Merch_Uom#
				FROM LOG_Y_DEAL_Program_Upload L
				INNER JOIN Contract_main CM ON
					CM.Planner_ID = '#arguments.Planner_ID#' AND
					CM.Contract_number = L.BA_Program_Id AND
					CM.Deleted = 0
				INNER JOIN Y_DEAL_UI_Upload U_Disc ON
					U_Disc.Batch_Id = '#this.Batch_ID#' AND
					U_Disc.External_Program = L.LEGACY_PROGRAM_ID and
					U_Disc.Record_type = 'M' AND
					U_Disc.Discount_Type = 'R'
				INNER JOIN All_Product_Group_Types PGT ON
					PGT.Group_Number = U_Disc.Material AND
					PGT.Product_Group_Level_ID = U_Disc.Product_Level_ID
				INNER JOIN Contract_group_merchant_info CGMI ON
					CGMI.Program_ID = CM.Contract_Main_Id AND
					CGMI.Group_ID = PGT.Group_GUID
				WHERE L.Batch_Id = '#this.Batch_ID#' AND
					 CM.Is_EDLP = 1
		</cfquery>
		<!---  FOR MULTIPLE COMPONENTS sum()- qUpdateEDLPData
			UPDATE C
				SET Everyday_Low_Price = TMP.rate,
					Everyday_Low_Price_UOM = 2
				FROM Contract_Group_Merchant_Info C 
				INNER JOIN (SELECT SUM(U_Disc.Rate) as Rate, CGMI.Contract_Group_Merchant_Info_ID, U_Disc.Material FROM  LOG_Y_DEAL_Program_Upload L
							INNER JOIN Contract_main CM ON
								CM.Planner_ID = '#arguments.Planner_ID#' AND
								CM.Contract_number = L.BA_Program_Id AND
								CM.Deleted = 0
							INNER JOIN Y_DEAL_UI_Upload U_Disc ON
								U_Disc.Batch_Id = '#this.Batch_ID#' AND
								U_Disc.External_Program = L.LEGACY_PROGRAM_ID and
								U_Disc.Record_type = 'M' AND
								U_Disc.Discount_Type = 'R'
							INNER JOIN All_Product_Group_Types PGT ON
								PGT.Group_Number = U_Disc.Material AND
								PGT.Product_Group_Level_ID = U_Disc.Product_Level_ID
							INNER JOIN Contract_Group_Merchant_Info CGMI ON
								CGMI.Program_ID = CM.Contract_Main_Id AND
								CGMI.Group_ID = PGT.Group_GUID
							WHERE L.Batch_Id = '#this.Batch_ID#' AND
								 CM.Is_EDLP = 1
							GROUP BY cgmi.Contract_Group_Merchant_Info_ID,material) TMP
				ON TMP.Contract_Group_Merchant_Info_ID = C.Contract_Group_Merchant_Info_ID
		 --->

		<cfscript>
			return b;
		</cfscript>
	</cffunction>

	<cffunction name="getPlannerNumber" access="public" returntype="String" output="false" >
		<cfargument name="Planner_ID" required="false" default="" type="string" />

		<cfquery name="qgetPlan" datasource="#application.datasource#">
			SELECT Planner_Number FROM Planners 
			WHERE  Planner_ID = '#arguments.Planner_ID#' 
		</cfquery>

		<cfscript>
			return qgetPlan.Planner_Number;
		</cfscript>
	</cffunction>

	<cffunction name="setPlannerTemplate" access="public" returntype="void" output="false" >
		<cfargument name="FY" required="false" default="" type="string" />
		<cfargument name="PERIOD" required="false" default="" type="string" />
		<cfargument name="CUSTOMER" required="false" default="" type="string" />
		
			<!--- TODO		TODO		TODO	Set a Fplag on the Planner_Template saying it is a "T-Pro Planner" instead of  Planner_Type like 'CBD DIRECT RETAIL PLANNER%' --->

		<cfquery datasource="#application.datasource#">

				IF OBJECT_ID('tempdb..##tmp_Planner_Types') IS NOT NULL
					DROP TABLE ##tmp_Planner_Types

				IF OBJECT_ID('tempdb..##TMP_Plan_Templ_Filt') IS NOT NULL
					DROP TABLE ##TMP_Plan_Templ_Filt

				IF OBJECT_ID('tempdb..##TMP_Plan_Templ_Filt_Cust') IS NOT NULL
					DROP TABLE ##TMP_Plan_Templ_Filt_Cust

				IF OBJECT_ID('tempdb..##TMP_Plan_Templ_Filt_Prod') IS NOT NULL
					DROP TABLE ##TMP_Plan_Templ_Filt_Prod
				
				IF OBJECT_ID('tempdb..##TMP_Planner_Template') IS NOT NULL
					DROP TABLE ##TMP_Planner_Template
		</cfquery>

		<cfquery name="qGetPlannerTemplate" datasource="#application.datasource#">

				SELECT	LTRIM(RTRIM(ITEMS)) AS PlanType
				INTO	##tmp_Planner_Types
				FROM	dbo.SplitString((SELECT VALUE FROM _Settings WHERE [Input_Name] = 'TPO_Planner_Type'), ',')

				SELECT	pt.Planner_Template_ID, Planner_Type, Planner_Start_Date, Planner_End_Date, Planner_Template_Filters_Customers_ID, Distributor_Group_Level_ID, Distributor_Group_ID
				INTO	##TMP_Plan_Templ_Filt
				FROM	dbo.Planner_Template pt
				INNER	JOIN Planner_Template_Filters ptf
				ON		pt.Planner_Template_ID = ptf.Planner_Template_ID
				INNER	JOIN Planner_Template_Filters_Customers ptfc 
				ON		ptf.Planner_Template_ID = ptfc.Planner_Template_ID
				AND		ptfc.Distributor_Group_level_ID = ptf.Group_Level_ID
				INNER	JOIN ##tmp_Planner_Types TMP
				ON		pt.Planner_Type LIKE '% ' + TMP.PlanType + '%'
				WHERE	pt.Deleted = 0
				AND		pt.Active = 1
				AND		ptfc.Active = 1
				AND		ptf.PG_Group_Type = 2
				AND		ptf.Allow_Filter = 1
				AND		LEFT(pt.Planner_Type, 4) = '#arguments.FY#'
				AND		RIGHT(LEFT(pt.Planner_Type, 7), 2) = '#arguments.PERIOD#'

				-- 1. When the Individual Distributor DST is part of the Group Selected on the Planner Template
				SELECT	TMP.*, BSA.BSA_Foodservice_Customers_ID, BSA.Shr_Ship_to, BSA.Ship_to, BSA.Name
				INTO	##TMP_Plan_Templ_Filt_Cust
				FROM 	##TMP_Plan_Templ_Filt TMP
				-- INNER	JOIN PG_Customer_Members PCM
				INNER	JOIN Customer_Group_Members CGM
				ON		TMP.Distributor_Group_Level_ID = CGM.Customer_Group_Type
				AND		TMP.Distributor_Group_ID = CGM.Customer_Group_ID
				INNER JOIN BSA_Foodservice_Customers BSA
				ON		BSA.BSA_Foodservice_Customers_ID = CGM.BSA_Foodservice_Customers_ID
				WHERE 	CGM.Deleted = 0
				AND		BSA.Active_Code = 'A'
				AND		BSA.Ship_To = '#arguments.CUSTOMER#'
				UNION
				-- 2. When the Group Distributor is part of the Planner Template
				SELECT	TMP.*, ACG.Group_GUID, ACG.Group_Number, ACG.Group_Number, ACG.Group_Desc
				FROM 	##TMP_Plan_Templ_Filt TMP
				INNER JOIN All_Customer_Group_Types ACG
				ON		TMP.Distributor_Group_Level_ID = ACG.Distributor_Group_Level_ID
				AND		TMP.Distributor_Group_ID = ACG.Group_GUID
				WHERE 	ACG.Deleted = 0
				AND		ACG.Group_Number = '#arguments.CUSTOMER#'
				UNION
				-- 3. When the Group Distributor is part of the Planning Group Selected on the Planner Template
				SELECT    TMP.*, ACG.Group_GUID, ACG.Group_Number, ACG.Group_Number, ACG.Group_Desc
				FROM     ##TMP_Plan_Templ_Filt TMP
				INNER JOIN PG_Customer_Category_Definition PGD
				ON      PGD.PG_Customer_Category_ID = TMP.Distributor_Group_ID
				AND     PGD.Deleted = 0
				AND     PGD.Inclusion_Exclusion = 1
				INNER JOIN All_Customer_Group_Types ACG
				ON        ACG.Distributor_Group_Level_ID = PGD.Distributor_Group_Level_ID
				AND        ACG.Group_GUID = PGD.Distributor_Group_ID
				WHERE     ACG.Deleted = 0
				AND        ACG.Group_Number = '#arguments.CUSTOMER#'

				IF (SELECT COUNT(DISTINCT Planner_Template_ID) FROM ##TMP_Plan_Templ_Filt_Cust) = 0
				BEGIN
					INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
					SELECT	DISTINCT External_Program, '', 'No Planner Template found at Customer Filter Level', 'REJECTED DEAL', 'D', Batch_ID, 0
					FROM	Y_DEAL_UI_Upload U 
					WHERE	Batch_ID = '#this.Batch_Id#'

					UPDATE	Y_DEAL_UI_UPLOAD
					SET		Planner_Template_ID = 0,
							Error_Info = 'No Planner Template found at Customer Filter Level'
					WHERE	Batch_ID = '#this.Batch_Id#'

					SELECT '0' AS Planner_Template_ID, 'No Planner Template found at Customer Filter Level' AS info
				END
				ELSE IF (SELECT COUNT(DISTINCT Planner_Template_ID) FROM ##TMP_Plan_Templ_Filt_Cust) = 1 
				BEGIN

					INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
					SELECT	DISTINCT External_Program, '', 'Selecting Planner Template ID at the Customer Filter and not proceeding further into Product Filters', 'INFORMATION', 'I', Batch_ID, 0
					FROM	Y_DEAL_UI_Upload U 
					WHERE	Batch_ID = '#this.Batch_Id#'

					UPDATE	Y_DEAL_UI_UPLOAD
					SET		Planner_Template_ID = (SELECT DISTINCT Planner_Template_ID FROM ##TMP_Plan_Templ_Filt_Cust)
					WHERE	Batch_ID = '#this.Batch_Id#'

					SELECT DISTINCT Planner_Template_ID, '' AS info FROM ##TMP_Plan_Templ_Filt_Cust
				END
				ELSE
				BEGIN
					SELECT	TMP.*, ptfp.Planner_Template_Filters_Products_ID, ptfp.Product_Group_Level_ID, ptfp.Product_Group_ID
					INTO	##TMP_Plan_Templ_Filt_Prod
					FROM	##TMP_Plan_Templ_Filt_Cust TMP
					INNER	JOIN Planner_Template_Filters ptf
					ON		TMP.Planner_Template_ID = ptf.Planner_Template_ID
					INNER	JOIN Planner_Template_Filters_Products ptfp
					ON		ptf.Planner_Template_ID = ptfp.Planner_Template_ID
					WHERE	ptfp.Active = 1
					AND		ptf.PG_Group_Type = 1
					AND		ptf.Allow_Filter = 1

					IF (SELECT	COUNT(DISTINCT Planner_Template_ID) FROM ##TMP_Plan_Templ_Filt_Prod) = 0
					BEGIN
						INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
						SELECT	DISTINCT External_Program, '', 'Multiple Planner Templates found at Customer Level but found none at Product Level', 'REJECTED DEAL', 'D', Batch_ID, 0
						FROM	Y_DEAL_UI_Upload U 
						WHERE	Batch_ID = '#this.Batch_Id#'
					
						UPDATE	Y_DEAL_UI_UPLOAD
						SET		Planner_Template_ID = 0,
								Error_Info = 'Multiple Planner Templates found at Customer Level but found none at Product Level'
						WHERE	Batch_ID = '#this.Batch_Id#'

						SELECT '0' AS Planner_Template_ID, 'Multiple Planner Templates found at Customer Level but found none at Product Level' AS info
					END
					ELSE IF (SELECT	COUNT(DISTINCT Planner_Template_ID) FROM ##TMP_Plan_Templ_Filt_Prod) = 1
					BEGIN
						INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
						SELECT	DISTINCT External_Program, '', 'Selecting Planner Template ID at the Product Filter Level', 'INFORMATION', 'I', Batch_ID, 0
						FROM	Y_DEAL_UI_Upload U 
						WHERE	Batch_ID = '#this.Batch_Id#'

						UPDATE	Y_DEAL_UI_UPLOAD
						SET		Planner_Template_ID = (SELECT DISTINCT Planner_Template_ID FROM ##TMP_Plan_Templ_Filt_Prod)
						WHERE	Batch_ID = '#this.Batch_Id#'
					
						SELECT DISTINCT Planner_Template_ID, '' AS info FROM ##TMP_Plan_Templ_Filt_Prod
					END
					ELSE
					BEGIN
						-- SELECT	TMP.*, IM.BSA_Foodservice_Items_Master_ID, IM.UPC, IM.Item, IM.Description
						SELECT	DISTINCT TMP.Planner_Template_ID
						INTO	##TMP_Planner_Template
						FROM 	##TMP_Plan_Templ_Filt_Prod TMP
						INNER	JOIN Group_Members GPM
						ON		TMP.Product_Group_Level_ID = GPM.Product_Group_Level_Type
						AND		TMP.Product_Group_ID = GPM.Product_Group_ID
						INNER JOIN dbo.BSA_Foodservice_Items_Master IM
						ON		IM.BSA_Foodservice_Items_Master_ID = GPM.BSA_Foodservice_Items_Master_ID
						WHERE 	GPM.Deleted = 0
						-- AND		IM.Active_Code = 'A'
						AND		EXISTS (	SELECT	1 
											-- SELECT DISTINCT Material, Discount_Type, Record_Type
											FROM	Y_DEAL_UI_UPLOAD Y
											WHERE	Batch_ID = '#this.Batch_Id#'
											AND		Record_Type = 'M'
											AND		IM.Item = Y.Material
										)
						/*UNION
						-- SELECT	TMP.*, APG.Group_GUID, APG.Group_Number, APG.Group_Number, APG.Group_Desc
						SELECT	TMP.Planner_Template_ID
						FROM 	##TMP_Plan_Templ_Filt_Prod TMP
						INNER JOIN dbo.All_Product_Group_Types APG
						ON		TMP.Distributor_Group_Level_ID = APG.Product_Group_Level_ID
						AND		TMP.Distributor_Group_ID = APG.Group_GUID
						WHERE 	APG.Deleted = 0
						AND		EXISTS (	SELECT	1 
											-- SELECT DISTINCT Material, Discount_Type, Record_Type
											FROM	Y_DEAL_UI_UPLOAD Y
											WHERE	Batch_ID = 'this.Batch_Id'	--hashes!
											AND		Record_Type = 'M'
											AND		APG.Group_Number = Y.Material_Group			---- Column doesn't exist!
										)*/
						ORDER	BY TMP.Planner_Template_ID
						
						IF(SELECT COUNT(DISTINCT Planner_Template_ID) FROM ##TMP_Planner_Template) = 0
						BEGIN
							INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
							SELECT	DISTINCT External_Program, '', 'Multiple Planner Templates found at Customer Level but found none at Product Level (2)', 'REJECTED DEAL', 'D', Batch_ID, 0
							FROM	Y_DEAL_UI_Upload U 
							WHERE	Batch_ID = '#this.Batch_Id#'
					
							UPDATE	Y_DEAL_UI_UPLOAD
							SET		Planner_Template_ID = 0,
									Error_Info = 'Multiple Planner Templates found at Customer Level but found none at Product Level (2)'
							WHERE	Batch_ID = '#this.Batch_Id#'

							SELECT '0' AS Planner_Template_ID, 'Multiple Planner Templates found at Customer Level but found none at Product Level (2)' AS info						
						END
						ELSE IF(SELECT COUNT(DISTINCT Planner_Template_ID) FROM ##TMP_Planner_Template) = 1
						BEGIN
							INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
							SELECT	DISTINCT External_Program, '', 'Selecting Planner Template ID at the Product Filter Level (2)', 'INFORMATION', 'I', Batch_ID, 0
							FROM	Y_DEAL_UI_Upload U 
							WHERE	Batch_ID = '#this.Batch_Id#'

							UPDATE	Y_DEAL_UI_UPLOAD
							SET		Planner_Template_ID = (SELECT DISTINCT Planner_Template_ID FROM ##TMP_Plan_Templ_Filt_Prod)
							WHERE	Batch_ID = '#this.Batch_Id#'
					
							SELECT DISTINCT Planner_Template_ID, '' AS info FROM ##TMP_Plan_Templ_Filt_Prod
						END
						ELSE
						BEGIN
							INSERT INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
							SELECT	DISTINCT External_Program, '', 'Multiple Planner Templates found overall', 'REJECTED DEAL', 'D', Batch_ID, 0
							FROM	Y_DEAL_UI_Upload U 
							WHERE	Batch_ID = '#this.Batch_Id#'

							UPDATE	Y_DEAL_UI_UPLOAD
							SET		Planner_Template_ID = 0,
									Error_Info = 'Multiple Planner Templates found overall'
							WHERE	Batch_ID = '#this.Batch_Id#'

							SELECT '0' AS Planner_Template_ID, 'Multiple Planner Templates found overall' AS info
						END
					END
				END

				DECLARE	@Business_Segment_Enabled_ID INT
				SELECT	@Business_Segment_Enabled_ID = Business_Segment_Enabled_ID FROM Business_Segment_Enabled WHERE DELETED = 0  AND Enabled = 1

				UPDATE	Y_DEAL_UI_Upload
				SET		Segment = ISNULL(PT.Business_Segment_ID, 0)
				FROM	Y_DEAL_UI_Upload YDUI
				INNER	JOIN Planner_Template PT
				ON		PT.Planner_Template_ID = YDUI.Planner_Template_ID
				WHERE 	Batch_ID = '#this.Batch_ID#'
				AND		@Business_Segment_Enabled_ID = 1

		</cfquery>

		<cfif qGetPlannerTemplate.Planner_Template_ID eq 0>
			<cfthrow type="Any" message="Error Message: Planner Template Configuration issue - #qGetPlannerTemplate.info#" />
			<!--- <cfabort> --->
		</cfif>

		<cfscript>
			this.Planner_Template_Id = qGetPlannerTemplate.Planner_Template_ID;
			//return;
		</cfscript>
	</cffunction>

	<cffunction name="setProgramTemplate" access="public" returntype="void" output="false" >
		<cfargument name="status" required="false" default="" type="string" />

		<cfquery name="qIsCustGroup" datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_Group_Type') IS NOT NULL
				DROP TABLE ##tmp_Group_Type

			SELECT	TOP 1 Group_Type, 
					CASE ISNULL(Group_Type, '')  
						WHEN 'DST' THEN '0'  
						WHEN 'FAM' THEN '2'  
						WHEN 'BGP' THEN '3'  
						WHEN 'CID' THEN '5'  
						WHEN 'DTP' THEN '7'  
					END AS Group_Level
			INTO	##tmp_Group_Type
			FROM	Y_DEAL_UI_Upload
			WHERE	Batch_ID = '#this.Batch_ID#'
			AND		Record_Type = 'C'

			SELECT All_Customer_Group_Types.Group_GUID AS Bsa_Foodservice_Customers_Id, All_Customer_Group_Types.Distributor_Group_Level_ID 
			FROM	All_Customer_Group_Types 	
			INNER JOIN Distributor_Group_Level ON Distributor_Group_Level.Distributor_Group_Level_ID = All_Customer_Group_Types.Distributor_Group_Level_ID 
			INNER JOIN ##tmp_Group_Type ON ##tmp_Group_Type.Group_Level = Distributor_Group_Level.Distributor_Group_Level_ID
			WHERE All_Customer_Group_Types.Group_Number = '#this.CUSTOMER#'
		</cfquery>
		
		<cfquery datasource="#application.datasource#">

			IF OBJECT_ID('tempdb..##tmp_Program_Template') IS NOT NULL
				DROP TABLE ##tmp_Program_Template

			IF OBJECT_ID('tempdb..##TMP_First_Parent_Templates') IS NOT NULL
				DROP TABLE ##TMP_First_Parent_Templates

			IF OBJECT_ID('tempdb..##tmppgmupld_Product_Group_Template_Selection') IS NOT NULL
				DROP TABLE ##tmppgmupld_Product_Group_Template_Selection

			IF OBJECT_ID('tempdb..##tmp_Y_DEAL_UI_UPLOAD_Materials') IS NOT NULL
				DROP TABLE ##tmp_Y_DEAL_UI_UPLOAD_Materials

			IF OBJECT_ID('tempdb..##tmp_Y_DEAL_Item_Members') IS NOT NULL
				DROP TABLE ##tmp_Y_DEAL_Item_Members

			IF OBJECT_ID('tempdb..##Program_Template_ProductFilter') IS NOT NULL  
				DROP TABLE ##Program_Template_ProductFilter

			IF OBJECT_ID('tempdb..##tmp_Program_Templates') IS NOT NULL
				DROP TABLE ##tmp_Program_Templates

		</cfquery>

		<cfquery name="qGetProgramTemplate" datasource="#application.datasource#">

			DECLARE @Template_ID INT

			SELECT	LTRIM(RTRIM(ITEMS)) AS ProgTempl
			INTO	##tmp_Program_Template
			FROM	dbo.SplitString((SELECT VALUE FROM _Settings WHERE [Input_Name] = 'TPO_Program_Template'), ',')

			IF (SELECT COUNT(*) FROM ##tmp_Program_Template) != 0
			BEGIN
				SELECT	@Template_ID = ProgramControl_Panel_Options_ID
				FROM	Program_Control_Panel_Options
				WHERE	Deleted = 0 AND Created_Type IN (SELECT ProgTempl FROM ##tmp_Program_Template) AND IsDominant = 1

				UPDATE	Y_DEAL_UI_UPLOAD
				SET		TEMPLATE = @Template_ID
				WHERE	Batch_ID = '#this.Batch_Id#'
			END
			ELSE
			BEGIN
				/*	Kelly C: 8/11/2021 
					For Butterball there are 2 possible Program Templates: Retail Trade & Retail Trade - no OI's 
					But for other clients, only Retail Trade.
					Coming to Butterball, since this Program Template is not sent from TPO, we need to figure out the correct one based on the current logic provided by Kelly:
							If Distributor Group is sent by TPO - pick Retail Trade - no OI's 
							If Individual Distributor is sent by TPO - pick Retail Trade 

					This logic might not apply for other clients, so Karen, P.W. & Kelly are planning for a separate Configuration Page, to Standardize.

					Most of the clients will have Retail Trade only. Few might have both of these. Very few might have 3 or more Program Templates.
				*/			
				IF (SELECT ISNULL(VALUE, '') FROM _Settings WHERE Input_Name = 'TPO_ProgTempl_Product') != 2
				BEGIN
						SELECT	@Template_ID = ProgramControl_Panel_Options_ID
						FROM	Program_Control_Panel_Options
						WHERE	Deleted = 0 AND Created_Type IN (SELECT ProgTempl FROM ##tmp_Program_Template) AND IsDominant = 1			
						<cfif qIsCustGroup.recordCount>
			                AND Created_Type = 'Retail Trade - no OI''s'
			            <cfelse>
			                AND Created_Type = 'Retail Trade'
			            </cfif>

						UPDATE	Y_DEAL_UI_UPLOAD
						SET		TEMPLATE = @Template_ID
						WHERE	Batch_ID = '#this.Batch_Id#'
			    END
			    ELSE
			    BEGIN
					/*	Kelly C: 02/22/2022
						For Smithfield there are 2 possible Program Templates: TPO_Program_Template, Planner Packaged - Direct Trade
						But the Program Template should be picked based on the Product Filters on the Program Template depending on the Items received in JSON
						Template might change with Programs under the same Planner. Product Filters on Templates are Groups only. 
						Between Multiple Products Group filters, there might be common Products, in that case pick the TOP 1 Planner Template.						
					*/
					SELECT	DISTINCT ProgTempl, pcpo.First_Parent_ID, pcpo.ProgramControl_Panel_Options_ID
					INTO	##TMP_First_Parent_Templates
					FROM	dbo.Program_Control_Panel_Options pcpo
					INNER	JOIN ##tmp_Program_Template tmp
					ON		Created_Type = ProgTempl
					WHERE	Deleted = 0 
					AND		pcpo.IsDominant = 1

					-- Product filters
					SELECT	fpt.ProgramControl_Panel_Options_ID, ts.Product_Group_Level_ID, ts.Product_Group_ID, fpt.First_Parent_ID, fpt.ProgTempl
					INTO	##tmppgmupld_Product_Group_Template_Selection  
					FROM	dbo.Group_Template gt
					INNER	JOIN dbo.Product_Group_Template_Selection ts
					ON		ts.Template_ID = gt.Template_ID
					AND		ts.Product_Group_Level_ID = gt.Group_Level_ID
					AND		ts.Deleted = 0
					INNER	JOIN ##TMP_First_Parent_Templates fpt
					ON		fpt.First_Parent_ID = gt.Template_ID
					WHERE	gt.Deleted = 0
					AND		gt.Allow_Filter = 1
					AND		gt.PG_Group_Type = 1

					SELECT	DISTINCT External_Program, Y.Material, Product_Level_ID
					INTO	##tmp_Y_DEAL_UI_UPLOAD_Materials
					FROM	dbo.Y_DEAL_UI_Upload Y
					WHERE	Batch_ID = '#this.Batch_Id#'
					AND		Record_Type = 'M'

					SELECT	DISTINCT External_Program, AGT.Group_Number, AGM.Product_Group_Level_ID, AGM.Product_Group_ID, AGM.BSA_Foodservice_Items_Master_ID
					INTO	##tmp_Y_DEAL_Item_Members
					FROM	##tmp_Y_DEAL_UI_UPLOAD_Materials tmp
					INNER	JOIN dbo.All_Product_Group_Types AGT
					ON		AGT.Group_Number = tmp.Material
					AND		AGT.Product_Group_Level_ID = tmp.Product_Level_ID
					INNER	JOIN dbo.All_Product_Group_Type_Members AGM
					ON		AGT.Product_Group_Level_ID = AGM.Product_Group_Level_ID
					AND		AGT.Group_GUID = AGM.Product_Group_ID
					WHERE	AGT.Deleted = 0
					UNION
					SELECT	DISTINCT External_Program, IM.Item, 0 AS Product_Group_Level_ID, IM.BSA_Foodservice_Items_Master_ID, IM.BSA_Foodservice_Items_Master_ID
					FROM	##tmp_Y_DEAL_UI_UPLOAD_Materials TMP
					INNER	JOIN dbo.BSA_Foodservice_Items_Master IM
					ON		TMP.Material = IM.Item				

					SELECT	DISTINCT TMP.ProgTempl, TMP.First_Parent_ID, TMP.ProgramControl_Panel_Options_ID, MEM.External_Program
					INTO	##Program_Template_ProductFilter
					FROM 	##tmppgmupld_Product_Group_Template_Selection TMP
					INNER	JOIN dbo.All_Product_Group_Types APT
					ON		TMP.Product_Group_Level_ID = APT.Product_Group_Level_ID
					AND		TMP.Product_Group_ID = APT.Group_GUID
					INNER	JOIN dbo.All_Product_Group_Type_Members APM
					ON		TMP.Product_Group_Level_ID = APM.Product_Group_Level_ID
					AND		TMP.Product_Group_ID = APM.Product_Group_ID
					INNER JOIN dbo.BSA_Foodservice_Items_Master IM
					ON		IM.BSA_Foodservice_Items_Master_ID = APM.BSA_Foodservice_Items_Master_ID
					INNER	JOIN ##tmp_Y_DEAL_Item_Members MEM
					ON		MEM.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID

					SELECT	ProgTempl, First_Parent_ID, ProgramControl_Panel_Options_ID, External_Program, ROW_NUMBER() OVER(PARTITION BY External_Program ORDER BY External_Program) AS RN
					INTO	##tmp_Program_Templates
					FROM	##Program_Template_ProductFilter

					IF EXISTS (SELECT * FROM ##tmp_Program_Templates WHERE RN != 1)
					BEGIN
						INSERT	INTO LOG_Y_DEAL_Program_Upload( [LEGACY_PROGRAM_ID],	[BA_Program_ID] ,[Upload_Description] ,	[Upload_Stat],[Upload_Ratio], Batch_ID, Y_DEAL_UI_Upload_ID )
						SELECT	DISTINCT yd.External_Program, '', 'Multiple or No Program Templates found at Product Level', 'REJECTED DEAL', 'D', Batch_ID, 0
						FROM	##tmp_Program_Templates tmp
						INNER	JOIN dbo.Y_DEAL_UI_Upload yd
						ON		tmp.External_Program = yd.External_Program
						WHERE	RN != 1
						AND		Batch_ID = '#this.Batch_Id#'
						
						UPDATE	Y_DEAL_UI_UPLOAD
						SET		TEMPLATE = 0,
								Error_Info = 'Multiple or No Program Templates found at Product Level'
						WHERE	Batch_ID = '#this.Batch_Id#'

						UPDATE	dbo.Y_DEAL_UI_Upload 
						SET		Error_Info = Error_Info + ': ' + yd.External_Program
						FROM	##tmp_Program_Templates tmp
						INNER	JOIN dbo.Y_DEAL_UI_Upload yd
						ON		tmp.External_Program = yd.External_Program
						WHERE	RN != 1
						AND		Batch_ID = '#this.Batch_Id#'

						SET		@Template_ID = 0
					END
					ELSE
					BEGIN
						UPDATE	dbo.Y_DEAL_UI_Upload
						SET		TEMPLATE = ProgramControl_Panel_Options_ID
						FROM	##tmp_Program_Templates tmp
						INNER	JOIN dbo.Y_DEAL_UI_Upload yd
						ON		tmp.External_Program = yd.External_Program
						WHERE	RN = 1
						AND		Batch_ID = '#this.Batch_Id#'
					END
			    END
	        END
		</cfquery>
	</cffunction>

	<cffunction name="getRebateComponent" access="public" returntype="String" output="false" >
		<cfargument name="type" required="true" default="" type="string" />

		<cfquery name="qGetRebateComponent" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_Name
			FROM Program_Rebates_Component_Name 
			WHERE deleted = 0 AND 
					active = 1 AND
					TPO_Rebate_Name LIKE '%#arguments.type#%'
		</cfquery>

		<cfscript>
			return qGetRebateComponent.Program_Rebates_Component_Name;
		</cfscript>
	</cffunction>

	<cffunction name="getClaimMechanic" access="public" returntype="String" output="false" >
		<cfargument name="type" required="true" default="" type="string" />

		<cfquery name="qGetClaimMechanic" datasource="#application.datasource#">
			SELECT Payment_Type_Name
			FROM Payment_Type 
			WHERE deleted = 0 AND 
					active = 1 AND
					TPO_Payment LIKE '%#arguments.type#%'
		</cfquery>

		<cfscript>
			return qGetClaimMechanic.Payment_Type_Name;
		</cfscript>
	</cffunction>

	<cffunction name="getLumpSumComponent" access="public" returntype="String" output="false" >
		<cfargument name="type" required="true" default="" type="string" />

		<cfquery name="qGetLumpSumComponent" datasource="#application.datasource#">
				SELECT Program_Lump_Sum_Name
						FROM  [dbo].[Program_Lump_Sum_Name]
						WHERE deleted = 0 AND 
								active = 1 AND 
								--Accrual_On  = 1 AND
								TPO_Lumpsum_Name LIKE '%#arguments.type#%'

		</cfquery>

		<cfscript>
			return qGetLumpSumComponent.Program_Lump_Sum_Name;
		</cfscript>
	</cffunction>


	<!--- insert the contents into db --->
	<cffunction name="insertUploadData" access="public" returntype="any" output="false" >
		<cfargument name="rData" type="any" required="true" />
		<cfscript>
			var rowData = arguments.rData;
			var local.qInsert = "";
		</cfscript>
				<cfquery name="local.qInsert" datasource="#application.datasource#">
					INSERT INTO Y_DEAL_UI_UPLOAD
					(
						Template,
						Batch_ID,
						Record_Type,
						Header_Action,
						External_Program,
						FORGE_Program,
						Title,
						Start,
						[End],
						RSP_ID,
						Position_ID,
						Segment,
						Sold_To,
						Group_Type,
						Operator_ID,
						Material,
						Product_Level_ID,
						Rate,
						UOM,
						Discount_Type,
						Component,
						Pays_To,
						Frequency,
						Claim_Mechanic,
						Currency,
						Volume,
						Volume_Lift,
						Volume_UOM,
						Creator_ID,
						Performance_Start,
						Performance_End,
						Performance_Type,
						Planner_ID,
						Group_ID,
						EveryDay_Unit_Price,
						Scan_Redemption_Pct,
						TPO_Created
					)
					VALUES
					(
						'#rowData["Template"]#',
						'#rowData["Batch_ID"]#',
						'#rowData["Record_Type"]#',
						'#rowData["Header_Action"]#',
						'#rowData["External_Program"]#',
						'#rowData["FORGE_Program"]#',
						'#rowData["Title"]#',
						'#rowData["Start"]#',
						'#rowData["End"]#',
						'#rowData["RSP_ID"]#',
						'#rowData["Position_ID"]#',
						'#rowData["Segment"]#',
						'#rowData["Sold_To"]#',
						'#rowData["Group_Type"]#',
						'#rowData["Operator_ID"]#',
						'#rowData["Material"]#',
						'#rowData["Product_Level_ID"]#',
						'#rowData["Rate"]#',
						'#rowData["UOM"]#',
						'#rowData["Discount_Type"]#',
						'#rowData["Component"]#',
						'#rowData["Pays_To"]#',
						'#rowData["Frequency"]#',
						'#rowData["Claim_Mechanic"]#',
						'#rowData["Currency"]#',
						'#rowData["Volume"]#',
						CAST(CAST('#rowData["Volume_Lift"]#' as float) AS Decimal(14,4)),
						'#rowData["VOLUME_UOM"]#',
						'#rowData["Creator_ID"]#',
						'#rowData["Performance_Start"]#',
						'#rowData["Performance_End"]#',
						'#rowData["Performance_Type"]#',
						'#rowData["Planner_ID"]#',
						'#rowData["Group_ID"]#',
						'#rowData["EveryDay_Unit_Price"]#',
						'#rowData["Scan_Redemption_Pct"]#',
						'1'
					)
				</cfquery>
		<cfreturn '' />
	</cffunction>

	<cffunction name="getRowDataRebate" access="public" returntype="Struct" output="false">

		<cfscript>
			var rowData = this.getRowData();
			rowData["Record_Type"] = 'M';
			rowData["UOM"] = 'CS';
			rowData["Discount_Type"] = 'R';
			rowData["Pays_To"] = 'D';
			rowData["Frequency"] = 'Upon Due';
			rowData["Currency"] = 'USD';
	    	return rowData;
		</cfscript>
	</cffunction>

	<cffunction name="getRowData" access="public" returntype="Struct" output="false">

		<cfscript>
			var rowData = StructNew();
			rowData["Template"] = '';
			rowData["Batch_ID"] = '';
			rowData["Record_Type"] = '';
			rowData["Header_Action"] = '';
			rowData["External_Program"] = '';
			rowData["FORGE_Program"] = '';
			rowData["Title"] = '';
			rowData["Start"] = '';
			rowData["End"] = '';
			rowData["RSP_ID"] = '';
			rowData["Position_ID"] = 0;
			rowData["Segment"] = 1;
			rowData["Sold_To"] = '';
			rowData["Group_Type"] = '';
			rowData["Operator_ID"] = '';
			rowData["Material"] = '';
			rowData["Product_Level_ID"] = 0;
			rowData["Rate"] = 0;
			rowData["UOM"] = '';
			rowData["Discount_Type"] = '';
			rowData["Component"] = '';
			rowData["Pays_To"] = '';
			rowData["Frequency"] = '';
			rowData["Claim_Mechanic"] = '';
			rowData["Currency"] = '';
			rowData["Volume"] = 0;
			rowData["Volume_Lift"] = 0;
			rowData["Volume_UOM"] = '';
			rowData["Creator_ID"] = '';
			rowData["Performance_Start"]  = '';
			rowData["Performance_End"]  = '';
			rowData["Performance_Type"]  = '';
			rowData["Planner_ID"]  = '';
			rowData["Group_Id"]  = '';
			rowData["EveryDay_Unit_Price"]  = 0;
			rowData["Scan_Redemption_Pct"]  = 100;

	    	return rowData;
		</cfscript>
	</cffunction>

	<cffunction name="updateVolume" access="public" returntype="any" output="false" >
		<cfargument name="Batch_Id" type="any" required="true" />
		<!--- <cfargument name="rData" type="any" required="true" /> --->

		<cfset useLakebaseForqUpdateVol = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("y_deal_ui_upload")>
<cfif useLakebaseForqUpdateVol>
	<cftry>
		<cfset application.oLakebase.updateRows("y_deal_ui_upload",
			{
				"batch_id" = "eq.#arguments.Batch_ID#",
				"record_type" = "eq.M"
			},
			{
				"volume" = "1",
				"volume_uom" = "CS"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateVol = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateVol>
<cfquery name="qUpdateVol" datasource="#application.datasource#">
			UPDATE Y_DEAL_UI_UPLOAD
			    SET Volume = 1, <!---'#arguments.rData.Volume#',--->
			    	Volume_UOM = 'CS'<!---'#arguments.rData.Volume_UOM#'--->
			    WHERE Batch_Id = '#arguments.Batch_ID#' AND
			    		Record_Type	= 'M' 
			    		<!---AND Material = '#arguments.rData.Material#'--->
		</cfquery>
</cfif>

		<cfscript>
			 return;
		</cfscript> 
	</cffunction>

	<cffunction name="getPositionId" access="public" returntype="query" output="false" >
		<cfargument name="userCode" required="false" default="" type="string" />
		<cfargument name="positionDescription" required="false" default="" type="string" />
		
		<cfquery name="qGetPositionId" datasource="#application.datasource#">
			SELECT	DISTINCT UPH.User_Positions_ID, U.User_Id, U.User_code
			FROM	_users U
			INNER JOIN User_Position_Holders UPH ON
				UPH.User_id = U.User_Id
			INNER JOIN User_Positions
				ON User_Positions.User_Positions_ID	= UPH.User_Positions_ID
				AND User_Positions.Deleted = 0
			 WHERE	
					u.Name_First = '#trim(listFirst(arguments.userCode, ' '))#' AND
					u.Name_Last = '#trim(listLast(arguments.userCode, ' '))#' AND
					U.deleted = 0 AND
					<cfif Trim(arguments.positionDescription) neq "">
					User_Positions.Position_Label = '#Trim(arguments.positionDescription)#' AND
						<!---
						User_Positions.Position_Label like '%#Trim(arguments.positionDescription)#%'
						--->
					<cfelse>
					User_Position_Type = 'P' AND
					</cfif>
					UPH.Deleted = 0 AND
					UPH.User_Positions_ID <> 0
		</cfquery>
		
		<!--- U.User_Code = '#arguments.userCode#' --->
		<cfscript>
			//this.dmp(qGetPositionId);
			this.User_Id = qGetPositionId.User_Id;
			this.User_positions_Id = qGetPositionId.User_Positions_ID;
			this.User_code = qGetPositionId.User_code;
			return qGetPositionId;
		</cfscript>
	</cffunction>

	<cffunction name="savePlannerVolume" hint="Save products based on a list of products.">
		<cfargument name="plannerID" type="numeric" required="true">
		<!--- <cfargument name="products_list" required="true" hint="The list of products."> --->
		<!--- <cfargument name="product_group_level_id" required="true"> --->
		<!--- <cfargument name="data" required="false" type="struct" default="#StructNew()#" /> --->

		<cfscript>
			//set local variables
			var dToday					= DateFormat(Now(), "mm/dd/yyyy");
			var itemMasterField			= "Item";

			//this.dmp(dToday);
			//this.dmp(#arguments.plannerID#);
		</cfscript>

		<!--- CUSTOM FOR Eaches --->
		<cfif application.util.query.get_setting("TPO_Planner_Volume_UOM_Over_Ride", 0) EQ "LB">
		 <!--- This works because Unit_Of_Measure_ID = 2 has the Lable EAs :: Select * from units_of_measure 
		 		EA is treated like LBS => 
		 								CASE Volume_UOM WHEN 'CS' THEN 1 ELSE 2 END 
		 --->
			<cfquery name="qUpdateVol" datasource="#application.datasource#">
				UPDATE 	Y_DEAL_UI_UPLOAD
				SET 	Volume_UOM = 'LB'
				WHERE 	Batch_Id = '#this.Batch_ID#' AND
						Record_Type	= 'V' 
			</cfquery>
		</cfif>

 		<cfquery name="local.updPlannerGroup" datasource="#application.datasource#">
			/* UPDATE GroupLevelId */
			UPDATE	Y_DEAL_UI_Upload
			SET		[GROUP_ID] =  PGT.Group_GUID  /* CASE WHEN pgl.Is_PG = 1 THEN '100' ELSE pgt.Product_Group_Level_ID END  */
					, DETAIL_Action = Product_Group_Attribute_Master_ID_Field 
			FROM	Y_DEAL_UI_Upload YDUI
					INNER JOIN All_Product_Group_Types pgt ON YDUI.Material = pgt.Group_Number
					INNER JOIN Product_Group_Level pgl on pgl.Product_Group_Level_ID = pgt.Product_Group_Level_ID
					INNER JOIN Product_Group_Attribute PGA ON PGA.Product_Group_Level_ID = pgt.Product_Group_Level_ID 
					AND (
							(ISNULL(YDUI.Product_Level_ID, 0) != 0 AND pgl.Product_Group_Level_ID = YDUI.Product_Level_ID)
							OR
							(ISNULL(YDUI.Product_Level_ID, 0) = 0)
						)
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type IN ('V', 'M')

		 	SELECT DISTINCT DETAIL_Action FROM Y_DEAL_UI_Upload YDUI
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type IN ('V', 'M')	

		</cfquery> 

		<cfset bIsGroup = 0 />
 		<cfif local.updPlannerGroup.DETAIL_Action neq "">
			<cfset bIsGroup = 1 />
			<cfset itemMasterField = local.updPlannerGroup.DETAIL_Action />
		</cfif> 

		<cfquery name="local.drop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##Tmp_Add_Planner_products') IS NOT NULL
				DROP TABLE ##Tmp_Add_Planner_products

			IF OBJECT_ID('tempdb..##Tmp_Add_VP_Prod_Dist') IS NOT NULL
				DROP TABLE ##Tmp_Add_VP_Prod_Dist

			IF OBJECT_ID('tempdb..##Tmp_Add_VP_Prod_Dist_Week') IS NOT NULL
				DROP TABLE ##Tmp_Add_VP_Prod_Dist_Week

			IF OBJECT_ID('tempdb..##tmp_planner_distributors') IS NOT NULL
				DROP TABLE ##tmp_planner_distributors
			IF OBJECT_ID('tempdb..##Tmp_Add_Planner_Week') IS NOT NULL
				DROP TABLE ##Tmp_Add_Planner_Week
			IF OBJECT_ID('tempdb..##Tmp_Add_VP_Prod_Dist_List1') IS NOT NULL
				DROP TABLE ##Tmp_Add_VP_Prod_Dist_List1
			IF OBJECT_ID('tempdb..##Tmp_Add_VP_Prod_Dist_List2') IS NOT NULL
				DROP TABLE ##Tmp_Add_VP_Prod_Dist_List2
		</cfquery>

		<cfquery name="local.insert" datasource="#application.datasource#" result="qInsert">
			CREATE TABLE ##tmp_planner_distributors ( BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER )

			<!--- /* If planner has individual distributor */ --->
			INSERT  INTO ##tmp_planner_distributors
					( BSA_Foodservice_Customers_ID )
					SELECT	DISTINCT
							Customer_ID
					FROM    Planners p
					WHERE   Planner_ID = #arguments.plannerID# 		-- Do not use cfqueryparam as we are using this temp table in other query.
							AND IsNull(Distributor_Group_Level_ID, 0) = 0

			<!--- /* If planner has group distributor */ --->
			INSERT  INTO ##tmp_planner_distributors
					( BSA_Foodservice_Customers_ID )
					SELECT	DISTINCT
							Distributor_ID
					FROM    Planner_Customer_Group_Members p
					WHERE   Planner_ID = #arguments.plannerID# 

            <!--- /* Populate list of weeks for this planner */ --->
			SELECT	Planner_Week.*,Planner_Template.Business_Segment_ID
			INTO	##Tmp_Add_Planner_Week
			FROM   Planners
					INNER JOIN Planner_Template
						ON Planner_Template.Planner_Template_Id = Planners.Planner_Template_Id
							AND Planner_Template.Deleted = 0
					INNER JOIN Planner_Week
						ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
							AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
							AND Planner_Week.Deleted = 0
			WHERE  Planners.Planner_Id  = #arguments.plannerID#
			CREATE TABLE ##Tmp_Add_Planner_products (
				Product_ID Varchar(50),
				Forecast_Value decimal(20, 2),
				Forecast_UOM int,
				Forecast_Start_Date DATE,
				Volume_Lift decimal(20, 2),
				Planner_Week_ID int,
				Business_Segment_ID int
			)
			
			<!--- /* Get products & volume from upload*/ --->
			INSERT INTO ##Tmp_Add_Planner_products 
						(Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift)
			SELECT  DISTINCT Material, Volume, CASE Volume_UOM WHEN 'CS' THEN 1 ELSE 2 END, Start, volume_lift
			FROM Y_DEAL_UI_Upload YDUI
			WHERE 	YDUI.Batch_ID = '#this.Batch_ID#' AND 
				Record_Type = 'V'

			<!--- /* Get Week Id's*/ --->
			UPDATE	p
			SET		Planner_Week_ID = W.Planner_Week_ID,
					Business_Segment_ID = W.Business_Segment_ID
			FROM   ##Tmp_Add_Planner_Week W
            INNER JOIN ##Tmp_Add_Planner_products p ON  
            	(DATEDIFF(DAY, p.Forecast_Start_Date, W.Planner_Week_Start_Date) BETWEEN -3 AND 3)
			
			<!--- /* Get distinct list of products and distributors */ --->
			SELECT 	p.*,
					Dist.BSA_Foodservice_Customers_ID,
					IM.BSA_FoodService_Items_Master_ID,
					IM.Active_Code,
					CAST(IM.Net_Weight as  decimal(16,4)) as Net_Weight,
					CAST(0 as decimal(20, 4)) as Current_Forecast_CS
			INTO	##Tmp_Add_VP_Prod_Dist_List1
			FROM   ##Tmp_Add_Planner_products P
			INNER JOIN BSA_FoodService_Items_Master IM
			ON		IM.Item = P.Product_ID
					AND IM.Item IS NOT NULL
					AND IM.deleted = 0
					<!---/*AND IM.Active_Code = 'A' We will include inactive products also */--->
			INNER JOIN ##tmp_planner_distributors Dist on 1=1
			UNION
			SELECT 	p.*,
					Dist.BSA_Foodservice_Customers_ID,
					IM.BSA_FoodService_Items_Master_ID,
					IM.Active_Code,
					CAST(IM.Net_Weight as  decimal(16,4)) as Net_Weight,
					CAST(0 as decimal(20, 4)) as Current_Forecast_CS
			FROM	All_Product_Group_Types PGT
			INNER	JOIN dbo.All_Product_Group_Type_Members PGM
			ON		PGT.Group_GUID = PGM.Product_Group_ID
			AND		PGT.Product_Group_Level_ID = PGM.Product_Group_Level_ID
			INNER	JOIN ##Tmp_Add_Planner_products P
			ON		PGT.Group_Number = P.Product_ID
			INNER JOIN BSA_FoodService_Items_Master IM
			ON		IM.BSA_Foodservice_Items_Master_ID = PGM.BSA_Foodservice_Items_Master_ID
			AND		PGM.Product_Group_ID IS NOT NULL
			AND		IM.Item IS NOT NULL
			AND		IM.deleted = 0
			/*AND IM.Active_Code = 'A' We will include inactive products also */
			INNER	JOIN ##tmp_planner_distributors Dist
			ON		1 = 1
			/* Get prior year cs from Planner_Volume_Plan */
			UPDATE	t
			SET		Current_Forecast_CS = vp.Prior_Year_CS
			FROM	##Tmp_Add_VP_Prod_Dist_List1 t
			inner join Planner_Volume_Plan vp
			on		vp.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID
			and		vp.BSA_Foodservice_Items_Master_ID = t.BSA_Foodservice_Items_Master_ID
			and		vp.Planner_Week_ID = t.Planner_Week_ID

			<!--- /*----------------------------------------------------------------------------------------
				Get products/customers based on existing volume value in planner volume plan table
			----------------------------------------------------------------------------------------*/ --->
			<!--- /*
				1. For a given group/week, if there are some records with volume and some records without volume, include records with volume
			*/ --->
			SELECT	Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, Current_Forecast_CS,Business_Segment_ID
			INTO	##Tmp_Add_VP_Prod_Dist_List2
			FROM	##Tmp_Add_VP_Prod_Dist_List1 p
			WHERE	p.Current_Forecast_CS > 0  /* In future f there is a need to allocate to records with negative volume, we can ajust this filter*/
			<!--- /*
				2. For a given group/week, if there are no records with volume. 
				Get product/distributor with volume in other weeks and evenly allocate
			*/ --->
			INSERT INTO ##Tmp_Add_VP_Prod_Dist_List2 (Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, Current_Forecast_CS,Business_Segment_ID)
			SELECT	DISTINCT t.Product_ID, t.Forecast_Value, t.Forecast_UOM, t.Forecast_Start_Date, t.Volume_Lift, t.Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, 0 as Current_Forecast_CS,Business_Segment_ID
			FROM	(
				SELECT	DISTINCT Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID
				FROM	##Tmp_Add_VP_Prod_Dist_List1 p
				WHERE	NOT EXISTS (SELECT 1 FROM ##Tmp_Add_VP_Prod_Dist_List2 l WHERE l.Product_ID = p.Product_ID AND l.Planner_Week_ID = p.Planner_Week_ID)
			) as t
			INNER JOIN ##Tmp_Add_VP_Prod_Dist_List1 p
			ON		p.Product_ID = t.Product_ID
			WHERE	p.Current_Forecast_CS != 0
			<!--- /*
			3. For a given group if there are no products with volume, use all products/customers and evenly allocate.
			*/ --->
			INSERT INTO ##Tmp_Add_VP_Prod_Dist_List2 (Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, Current_Forecast_CS,Business_Segment_ID)
			SELECT	Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, 0 as Current_Forecast_CS,Business_Segment_ID
			FROM	##Tmp_Add_VP_Prod_Dist_List1 p
			WHERE	NOT EXISTS (SELECT 1 FROM ##Tmp_Add_VP_Prod_Dist_List2 l WHERE l.Product_ID = p.Product_ID AND l.Planner_Week_ID = p.Planner_Week_ID)
			/* Get record count based on final list of products and distributors */
			SELECT 	p.*,
					CAST(0 as decimal(16,2)) as Forecast_Value_Per_Record,
					CAST(0 as decimal(16,2)) as Lift_Value_Per_Record,
					CAST(Count(*) OVER (Partition By p.Product_ID, p.Planner_Week_ID) as decimal(16,2)) as Rec_Count,  /* BSA_Foodservice_Customers_ID */
					/*Order products in such a way that the balance is applied to active product if any*/
					Row_Number() OVER (Partition By p.Product_ID, p.Planner_Week_ID Order By Active_Code, Current_Forecast_CS Desc, BSA_FoodService_Items_Master_ID, BSA_Foodservice_Customers_ID) as Rec_Index,
					SUM(Current_Forecast_CS) OVER (Partition By p.Product_ID, p.Planner_Week_ID) as Group_Week_Current_Forecast_CS  /* BSA_Foodservice_Customers_ID */
			INTO	##Tmp_Add_VP_Prod_Dist
			FROM   ##Tmp_Add_VP_Prod_Dist_List2 P
			/* If group/week has volume plan records with volume, allocate volume based on existing volume */
			UPDATE	##Tmp_Add_VP_Prod_Dist
			SET		Forecast_Value_Per_Record = Round(Forecast_Value * Current_Forecast_CS / Group_Week_Current_Forecast_CS, 2),
					Lift_Value_Per_Record =  Round(Volume_Lift * Current_Forecast_CS / Group_Week_Current_Forecast_CS, 2)
			WHERE	Group_Week_Current_Forecast_CS != 0
			/* If group/week does not have volume plan records with volume, allocate evenly */
			UPDATE	##Tmp_Add_VP_Prod_Dist
			SET		Forecast_Value_Per_Record = Round(Forecast_Value / Rec_Count, 2),
					Lift_Value_Per_Record =  Round(Volume_Lift / Rec_Count, 2)
			WHERE	Group_Week_Current_Forecast_CS = 0

			<!--- /* Set forecast = 0 for inactive products */ --->
			UPDATE	##Tmp_Add_VP_Prod_Dist
			SET		Forecast_Value_Per_Record = 0,
					Lift_Value_Per_Record =  0
			WHERE	Active_Code != 'A'

			<!--- /* 
				Apply balance to row 1 (Rec_Index = 1)
				Products are ordered in such a way that row 1 will be an active product if any
			*/ --->

			UPDATE	p
			SET		Forecast_Value_Per_Record = p.Forecast_Value_Per_Record + (tmp.Forecast_Value - tmp.Sum_Forecast_Value_Per_Record),
					Lift_Value_Per_Record = p.Lift_Value_Per_Record + (tmp.Volume_Lift - tmp.Sum_Lift_Value_Per_Record)
			-- SELECT tmp.*
			FROM	(
				SELECT	p.Product_ID, p.Planner_Week_ID, p.Forecast_Value, p.Volume_Lift, 
						sum(Forecast_Value_Per_Record) as Sum_Forecast_Value_Per_Record,
						sum(Lift_Value_Per_Record) as Sum_Lift_Value_Per_Record
				FROM	##Tmp_Add_VP_Prod_Dist p
				GROUP BY p.Product_ID, p.Planner_Week_ID, p.Forecast_Value, p.Volume_Lift
			) as tmp
			INNER JOIN ##Tmp_Add_VP_Prod_Dist p
			ON		p.Product_ID = tmp.Product_ID
			AND		p.Planner_Week_ID = tmp.Planner_Week_ID
			AND		p.Rec_Index = 1
			WHERE	tmp.Forecast_Value != tmp.Sum_Forecast_Value_Per_Record
			OR		tmp.Volume_Lift != tmp.Sum_Lift_Value_Per_Record

			<!--- /* 
				Insert product/customer/week that should get set to Forecast = 0
				For eg: if volume plan table already has existing record with a certain volume, but we want to set it to Forecast = 0 based on above logic
			*/ --->
			
			INSERT INTO ##Tmp_Add_VP_Prod_Dist (
					Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, Current_Forecast_CS,Business_Segment_ID,
					Forecast_Value_Per_Record, Lift_Value_Per_Record, Rec_Count, Rec_Index, Group_Week_Current_Forecast_CS)
			SELECT 	Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift, Planner_Week_ID,
					BSA_Foodservice_Customers_ID, BSA_FoodService_Items_Master_ID, Active_Code, Net_Weight, 0 as Current_Forecast_CS,Business_Segment_ID,
					CAST(0 as decimal(16,2)) as Forecast_Value_Per_Record,
					CAST(0 as decimal(16,2)) as Lift_Value_Per_Record,
					0 as Rec_Count,
					0 as Rec_Index,
					0 as Group_Week_Current_Forecast_CS
			FROM	##Tmp_Add_VP_Prod_Dist_List1 p
			WHERE	NOT EXISTS (
				SELECT	1 
				FROM	##Tmp_Add_VP_Prod_Dist l 
				WHERE	l.BSA_Foodservice_Customers_ID = p.BSA_Foodservice_Customers_ID 
				AND		l.BSA_FoodService_Items_Master_ID = p.BSA_FoodService_Items_Master_ID 
				AND		l.Planner_Week_ID = p.Planner_Week_ID
			)

			DECLARE @Planner_Volume_Plan_Segment_Enable INT
			SELECT	@Planner_Volume_Plan_Segment_Enable = Planner_Volume_Plan_Segment_Enable FROM Business_Segment_Enabled WHERE DELETED = 0

			<!--- /*  Get distinct list of products, distributors and weeks */ --->
			SELECT 	DISTINCT
					CASE @Planner_Volume_Plan_Segment_Enable WHEN 1 THEN ISNULL(Business_Segment_ID, 0) ELSE 0 END AS Business_Segment_ID,
					Planner_Week_Id,
					p.BSA_Foodservice_Customers_ID,
					p.bsa_FoodService_Items_Master_Id,
					CASE
					--WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Forecast_Value_Per_Record / p.Net_Weight
					ELSE p.Forecast_Value_Per_Record
					END AS Forecast_cs,
					CASE
					--WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Forecast_Value_Per_Record
					ELSE p.Forecast_Value_Per_Record * p.Net_Weight
					END AS Forecast_lbs,
					CASE
					--WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Lift_Value_Per_Record / p.Net_Weight
					ELSE p.Lift_Value_Per_Record
					END AS Lift_cs,
					CASE
					--WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Lift_Value_Per_Record
					ELSE p.Lift_Value_Per_Record * p.Net_Weight
					END AS Lift_lbs,
					CASE
					--WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Forecast_Value_Per_Record / p.Net_Weight
					ELSE p.Forecast_Value_Per_Record
					END AS Forecast_base_cs,
					CASE
					--WHEN Planner_Week.Planner_Week_Start_Date < p.Forecast_Start_Date THEN '0.00'
					WHEN p.Forecast_UOM = 2 THEN p.Forecast_Value_Per_Record
					ELSE p.Forecast_Value_Per_Record * p.Net_Weight
					END AS Forecast_base_lbs
			INTO	##Tmp_Add_VP_Prod_Dist_Week
			FROM   ##Tmp_Add_VP_Prod_Dist p

			UPDATE ##Tmp_Add_VP_Prod_Dist_Week set Forecast_cs = Lift_cs + Forecast_base_cs, 
												   Forecast_lbs = Lift_lbs + Forecast_base_lbs

			<!--- /* UPDATE FIRST */ --->
			UPDATE PVP
				SET 
					Forecast_CS = t.Forecast_CS,
					Forecast_LBS = t.Forecast_LBS,
					Forecast_Lift_CS = t.Lift_CS,
					Forecast_Lift_LBS = t.Lift_LBS,
					Forecast_Base_CS = t.Forecast_Base_CS,
					Forecast_Base_LBS = t.Forecast_Base_LBS,
					Forecast_Updated = 1,
					Business_Segment_ID = t.Business_Segment_ID,
					Updated_DAte = GetDate()
				FROM Planner_Volume_Plan PVP
				INNER JOIN ##Tmp_Add_VP_Prod_Dist_Week t ON
					PVP.Planner_Week_ID = t.Planner_Week_ID AND
					PVP.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID AND
				    PVP.BSA_Foodservice_Items_Master_ID = t.bsa_FoodService_Items_Master_ID AND
				    PVP.Business_Segment_ID = t.Business_Segment_ID
				/* WHERE isnull(PVP.Forecast_Updated,0) != 1 */

			<!--- /* Insert */ --->
			INSERT Planner_Volume_Plan (
					Planner_Week_ID,
					BSA_Foodservice_Customers_ID,
					BSA_Foodservice_Items_Master_ID,
					Prior_Year_CS,
					Prior_Year_LBS,
					Forecast_CS,
					Forecast_LBS,
					Forecast_Lift_CS,
					Forecast_Lift_LBS,
					Forecast_Base_CS,
					Forecast_Base_LBS,
					Actual_CS,
					Actual_LBS,
					Forecast_Percent_Prior_Year_CS,
					Forecast_Percent_Prior_Year_LBS,
					Actual_Percent_Forecast_CS,
					Actual_Percent_Forecast_LBS,
					Forecast_Updated,
					Business_Segment_ID)
			SELECT	Planner_Week_Id,
					BSA_Foodservice_Customers_ID,
					bsa_FoodService_Items_Master_Id,
					'0.00' AS Prior_year_cs,
					'0.00' AS Prior_year_lbs,
					Forecast_cs,
					Forecast_lbs,
					Lift_cs,
					Lift_lbs,
					Forecast_base_cs,
					Forecast_base_lbs,
					'0.00' AS Actual_cs,
					'0.00' AS Actual_lbs,
					'100'  AS Forecast_percent_prior_year_cs,
					'100'  AS Forecast_percent_prior_year_lbs,
					'0'    AS Actual_percent_forecast_cs,
					'0'    AS Actual_percent_forecast_lbs,
					1,
					t.Business_Segment_ID
			FROM	##Tmp_Add_VP_Prod_Dist_Week t
			WHERE 	NOT EXISTS (
				SELECT  1
				FROM    Planner_Volume_Plan v
				WHERE   v.Planner_Week_ID = t.Planner_Week_ID
				AND     v.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID
				AND     v.BSA_Foodservice_Items_Master_ID = t.bsa_FoodService_Items_Master_ID
				AND     v.Business_Segment_ID = t.Business_Segment_ID
			)
			AND		t.Forecast_CS != 0
			AND		Planner_Week_Id IS NOT NULL

			DELETE	Planner_Volume_Plan_Deleted_Records
			WHERE	EXISTS (
				SELECT  1
				FROM    ##Tmp_Add_VP_Prod_Dist_Week t
				WHERE   t.Planner_Week_ID = Planner_Volume_Plan_Deleted_Records.Planner_Week_ID
				AND     t.BSA_Foodservice_Customers_ID = Planner_Volume_Plan_Deleted_Records.BSA_Foodservice_Customers_ID
				AND     t.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan_Deleted_Records.bsa_FoodService_Items_Master_ID
				AND     t.Business_Segment_ID = Planner_Volume_Plan_Deleted_Records.Business_Segment_ID
			)
		</cfquery>
		<!--- <cfscript>
				//this.dmp(qInsert);
		</cfscript> --->

	</cffunction>

	<!--- Used for testing --->
	<cffunction name="GetData" access="remote" httpmethod="Get" restpath="GetData" output='false' returntype="any">
		<cfargument name="Id" required="false" restargsource="query" type="string" default="70011256 - FY 2020"/>
		<cfscript>
			if(!request.bAuthorized){
					return serializeJson(this.noAuthMessage);
			}

			try{
					var legacy_id = "PromoEvents.PromoEventNumber aa";
					var legacy_id2 = "PromoEvents.PromoEventNumber bb";
					var x = CreateObject("component","components.Interfaces.Service.Planner").init();
					var prg = CreateObject("component","components.Interfaces.Service.Program").init();
			
			} catch (any e) {
				sError = 'REST Planner GET ERROR::  #e.Message# :: #e.Detail#';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				//dmpError(sError);
				//this.updateActivityLog(sError,'1500');
				throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}
			var ret["Planner"] = x;
        	return ret; 
		</cfscript>
	</cffunction>

</cfcomponent>
