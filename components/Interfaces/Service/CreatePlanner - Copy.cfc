
<cfcomponent rest="true" restpath="Planner" extends="Service">
	<cfproperty name="Planner_Template_Id"	type="numeric"/>
	<cfproperty name="Program_Template_Id"	type="numeric"/>
	<cfproperty name="Batch_Id"				type="numeric"/>
	<cfproperty name="User_Positions_ID"	type="string"/>
	<cfproperty name="User_Id"				type="string"/>
	<cfproperty name="user_Code"			type="string"/>
	<cfproperty name="Forge_Planner_Id"		type="string"/>
	<cfproperty name="Fiscal_Year"			type="string"/>
	<cfset this.noAuthMessage='NOT TODAY'/>

	<cffunction name="Create" access="remote" returntype="Any" httpmethod="POST" restpath="Create" output='false'>
		<cfargument name="plan" required="true" restargsource="Form" type="string"/>
		<cfscript>
			if(!request.bAuthorized){
					return serializeJson(this.noAuthMessage);
			}

			try{
				jsonFileName = "tproPlanner_" & DateTimeFormat(now(),"MMDDYY_HH_MM_SS") & ".json";
				jsonFilepath = application.Doc_Path & "\Temp_Files\TradePlanner\"  & jsonFileName;
				//this.dmp(jsonFilepath);
				FileWrite("#jsonFilepath#", "#arguments.plan#");

				var newPlan = deserializeJson(arguments.plan);
				var response = CreateObject("component","components.Interfaces.Service.CreateResponse").init();
				var detail = CreateObject("component","components.Interfaces.Service.Detail").init();
				var planMan = CreateObject("component","mvc.Models.Planner.PlannerManager");
				var plannerId = 0;
				var aDetail	= ArrayNew(1);
				//  Find the t-pro specific pg & planner templates.  Only 1 each...may need a setting.
				var FY = Right(listLast(newPlan.Planner.Planner_Id, '-'),4);

				this.Fiscal_Year = FY;
				this.setPlannerTemplate(FY);
				this.setProgramTemplate();
				//this.dmp(this.Template_Planner_Id);
				plannerId = this.parseData(newPlan);
				response["Planner_Id"]  = newPlan.Planner.Planner_Id;
				if(plannerId > 0){
					response["Status"]  = "SUCCESS";
					response["Forge_Planner_Id"]  = this.getPlannerNumber(plannerId);
					response["Batch_Id"] = this.Batch_ID;
					response["Details"] = this.getResponse();
				}
				else{
					response["Status"]  = "Planner not created";
					response["Batch_Id"] = this.Batch_ID;
				}
				response["Details"] = this.getResponse();
			} catch (any e) {
				sError = 'REST Planner Upload ERROR::  #e.Message# :: #e.Detail#';
				writelog(type='Error',file='CF_Error',  text='#sError#');
				response["Status"] = sError;
				this.dmp(e);
				return response;
				//dmpError(sError);
				//this.updateActivityLog(sError,'1500');
				//throw(message="#NOW()# :: #e.Message#", detail="#e.Detail#");
			}
        	return response; 
		</cfscript>
	</cffunction>

	<cffunction name="parseData" access="public" returntype="any" output="false">
		<cfargument name="p" required="true" type="any" />

		<cfscript>
			// This.dmp(arguments.p);
			var rowData = '';
			var plannerId = 0;
			var plan = arguments.p.Planner;
		    var arrPrg = arguments.p.Planner.Programs;
		    var q = this.getPositionId(plan.Responsible_Sales_Person);
		    var uploadMan = CreateObject("component","mvc.Models.Program.Upload.ProgramUploadManager");
		</cfscript>
		<cfquery name="qGetBatchId" datasource="#application.datasource#">
			Select (isnull(max(Batch_ID), 0)+1) as next_batch_id from Y_DEAL_UI_Upload
		</cfquery>
		<cfset this.Batch_Id = qGetBatchId.next_batch_id />
		<cfscript>
			arrPrg = arguments.p.Planner.Programs;

			this.parsePrograms(arrPrg,this.Batch_Id);
			var bIsValid = uploadMan.validateUpload(this.Batch_Id);
			if(bIsValid){ //validate the "Feature Price"
				bIsValid = this.validateRetailPrice();
			}
			if(bIsValid){
				plannerId = this.parsePlan(plan, this.Batch_Id);
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
		</cfscript>
		<cfscript>
			for (i=1;i LTE ArrayLen(arrPrg);i=i+1){
				prg = arrPrg[i];
				rowData = getRowData();
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
				switch(prg.Performance_Type) {
				    case "EDLP":
				         perfType = 'EDLP';
				         break;
				    case "TPR Only":
				         perfType = 'TPR';
				         break;
				    case "Display Only":
				         perfType = 'Display';
				         break;
				    case "Ad Only":
				         perfType = 'Feature';
				         break;
				    case "Ad & Display":
				         perfType = 'Feature & Display';
				         break;
				    case "Other":
				         perfType = 'Coupon';
				         break;
				}
				rowData.Performance_Type = perfType;
				//rowData.Planner_ID = prg.Planner_ID;
				rowData.RSP_ID = this.user_Code;
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
					rowDataDist.Group_Id = dist.Distributor_Id;
					this.insertUploadData(rowDataDist);
				}

				// Rebates
				arrReb = prg.Rebates;
				for (y=1;y LTE ArrayLen(arrReb);y=y+1){
					reb = arrReb[y];
					comp = this.getRebateComponent(reb.External_Component_ID);

					rowDataReb = getRowDataRebate();
					rowDataReb.Batch_ID = Batch_ID;
					rowDataReb.Record_Type = 'M';
					rowDataReb.External_Program = prg.Legacy_Program_ID;
					rowDataReb.Creator_ID = this.User_Id;
					rowDataReb.Template = this.Program_Template_Id;

					if(IsDefined('reb.Rebate_Unit_of_Measure')){rowDataReb.UOM = reb.Rebate_Unit_of_Measure;}
					if(IsDefined('reb.Payment_Frequency')){rowDataReb.Frequency = reb.Payment_Frequency;}
					if(IsDefined('reb.Currency')){rowDataReb.Currency = reb.Currency;}
					if(IsDefined('reb.Pays_To')){rowDataReb.Pays_To = reb.Pays_To;}

					rowDataReb.Material = reb.Item_Number;
					if(isnumeric(reb.Rebate_Amount)){
						rowDataReb.Rate = reb.Rebate_Amount;
					}
					if(IsDefined('reb.Scan_Redemption_Pct') &&  isnumeric(reb.Scan_Redemption_Pct)){
						rowDataReb.Scan_Redemption_Pct = reb.Scan_Redemption_Pct; // Program_Rebates_Component_Data.Scan_Percentage
					}
					rowDataReb.Component = comp;
					rowDataReb.Claim_Mechanic = reb.Claim_Mechanic;
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
					if(isnumeric(lump.LS_Amount)){
						rowDataLump.Rate = lump.LS_Amount;
					}
					rowDataLump.UOM = '$';
					rowDataLump.Component = lsComp;
					rowDataLump.Claim_Mechanic = lump.Claim_Mechanic;
					rowDataLump.Volume = 1;
					rowDataLump.VOLUME_UOM = 'CS';
					this.insertUploadData(rowDataLump);
				}
				// Retail_Prices
				arrRetailPrices = prg.Retail_Prices;
				//this.dmp(arrRetailPrices);
				for (n=1;n LTE ArrayLen(arrRetailPrices);n=n+1){
					rp = arrRetailPrices[n];
					this.dmp(rp);
					rowDataRtlPrc = getRowData();
					rowDataRtlPrc.Batch_ID = Batch_ID;
					rowDataRtlPrc.Record_Type = 'RP';
					rowDataRtlPrc.External_Program = prg.Legacy_Program_ID;
					rowDataRtlPrc.Creator_ID = this.User_Id;
					rowDataRtlPrc.Template = this.Program_Template_Id;
					rowDataRtlPrc.Material = rp.Item_Number;
					if(isnumeric(rp.Feature_Price)){
						rowDataRtlPrc.rate = rp.Feature_Price;	
					}
					rowDataRtlPrc.EveryDay_Unit_Price = rp.Everyday_Price;
					this.insertUploadData(rowDataRtlPrc);
				}
				this.updateVolume(Batch_ID);
				// arrVol = prg.ItemVolume;
				// // Volume
				// for (a=1;a LTE ArrayLen(arrVol);a=a+1){
				// 	vol = arrVol[a];
				// 	rowDataVol = getRowData();
				// 	rowDataVol.Batch_ID = Batch_ID;
				// 	rowDataVol.External_Program = prg.Legacy_Program_ID;
				// 	rowDataVol.Material = vol.Item_Number;
				// 	rowDataVol.Volume = vol.Program_Volume_Cases;
				// 	rowDataVol.VOLUME_UOM = 'CS';
				// 	this.updateVolume(rowDataVol);
				// }
			}
			return '';
		</cfscript>
	</cffunction>

	<cffunction name="parsePlan" access="public" returntype="any" output="false">
		<cfargument name="p" required="true" type="components.Interfaces.Service.Planner" />
		<cfargument name="bId" required="true" type="numeric" />

		<cfscript>
			var planMan = createObject( "component", "mvc.Models.Planner.PlannerManager");
			var rowData  = '';
			var plan	 = arguments.p;
			var Batch_ID = arguments.bId;
			var plannerId 	 = 0;
			var cust = listFirst(plan.Planner_Id, '-');
			var FY = Right(listLast(plan.Planner_Id, '-'),4);
			var  arrVol = ArrayNew(1);

			this.Fiscal_Year = FY;
		</cfscript>

		<cfquery name="qgetCust" datasource="#application.datasource#">
			SELECT All_Customer_Group_Types.Group_GUID AS Bsa_Foodservice_Customers_Id, All_Customer_Group_Types.Distributor_Group_Level_ID 
			FROM	All_Customer_Group_Types 	
			INNER JOIN Distributor_Group_Level on Distributor_Group_Level.Distributor_Group_Level_ID = All_Customer_Group_Types.Distributor_Group_Level_ID 
			WHERE All_Customer_Group_Types.Group_Number =  '#cust#'
		</cfquery>

		<!--- <cfquery name="qgetCust" datasource="#application.datasource#">
			SELECT Bsa_Foodservice_Customers_Id 
			FROM Bsa_Foodservice_Customers 
			WHERE Ship_to = '#cust#'
		</cfquery> --->

		<cfquery name="qgetPlan" datasource="#application.datasource#">
			 SELECT DISTINCT P.Planner_Id, P.Planner_number --, pvp.* 
			 FROM Planners P
			 INNER JOIN Planner_Customer_Group_Members G ON
				G.Planner_ID = P.Planner_ID
			  INNER JOIN Planner_Volume_Plan PVP ON
				PVP.BSA_Foodservice_Customers_Id = G.Distributor_Id
				INNER JOIN planner_week PW on PW.Planner_Week_ID = PVP.Planner_Week_ID
			WHERE  P.Customer_id =  '#qgetCust.Bsa_Foodservice_Customers_Id#' AND 
				Planner_Template_ID = '#this.Planner_Template_Id#' AND 
				PW.Planner_Year = '#FY#' AND
				P.Deleted = 0
		</cfquery>

		<cfscript>
			if(qgetCust.recordcount GT 0 AND qgetPlan.recordcount == 0){  //AND qgetPlan.recordcount == 0
				plannerId = planMan.createPlanner(this.User_Id,this.User_Positions_ID,this.User_Id,this.Planner_Template_Id,qgetCust.Bsa_Foodservice_Customers_Id,qgetCust.Distributor_Group_Level_ID);
				arrVol = plan.PlannerVolume;
				//this.dmp(arrVol);
				//this.dmp(plannerId);
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
		
		<cfquery name="updRetailPriceGroup" datasource="#application.datasource#">
			---  UPDATE GroupLevelId
			UPDATE	Y_DEAL_UI_Upload
			SET		[GROUP_ID] =  PGT.Group_GUID  /* CASE WHEN pgl.Is_PG = 1 THEN '100' ELSE pgt.Product_Group_Level_ID END  */
					, DETAIL_Action = Product_Group_Attribute_Master_ID_Field 
			FROM	Y_DEAL_UI_Upload YDUI
					INNER JOIN All_Product_Group_Types pgt ON SUBSTRING(YDUI.Material, PATINDEX('%[^0]%',YDUI.Material), 11) = SUBSTRING(pgt.Group_Number, PATINDEX('%[^0]%',pgt.Group_Number), 11)
					INNER JOIN Product_Group_Level pgl on pgl.Product_Group_Level_ID = pgt.Product_Group_Level_ID
					INNER JOIN Product_Group_Attribute PGA ON PGA.Product_Group_Level_ID = pgt.Product_Group_Level_ID 
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'RP'

			SELECT DISTINCT DETAIL_Action FROM Y_DEAL_UI_Upload YDUI
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'RP'
		</cfquery>

		 <cfquery name="qCopyProgramUpdatePrice" datasource="#application.datasource#">
	
			INSERT INTO Contract_group_merchant_info (Program_id, Group_id, Merchant_price, Merchant_quantity, Uom, Everyday_unit_price, Everyday_Low_Price_UOM)
				SELECT 	cm.Contract_main_Id,U.Group_id, U.Rate, 1, 5, U.Everyday_unit_price, 1
			FROM 	 Y_DEAL_UI_Upload U 
			INNER JOIN LOG_Y_DEAL_Program_Upload L ON
				L.Batch_Id = U.Batch_Id AND
				L.Legacy_Program_Id = U.External_Program
			INNER JOIN Contract_main CM ON
				CM.Planner_ID = '#arguments.Planner_ID#' AND
				CM.Contract_number = L.BA_Program_Id
			WHERE U.Batch_Id = '#this.Batch_ID#' AND
				Record_type = 'RP'
		</cfquery> 

		<!--- <cfset bIsGroup = 0 />
		<cfif local.updPlannerGroup.DETAIL_Action neq "">
			<cfset bIsGroup = 1 />
			<cfset itemMasterField = local.updPlannerGroup.DETAIL_Action />
		</cfif> --->

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
			<!--- TODO		TODO		TODO	Set a Fplag on the Planner_Template saying it is a "T-Pro Planner" instead of  Planner_Type like 'CBD DIRECT RETAIL PLANNER%' --->
		<cfquery name="qGetPlannerTemplate" datasource="#application.datasource#">
			SELECT *
			FROM Planner_Template
			WHERE Deleted = 0
			AND Planner_Type like 'CBD DIRECT RETAIL PLANNER%' AND
			RIGHT(Planner_Type, 4 ) = '#arguments.FY#'
			--AND Planner_Template_ID = 1
		</cfquery>

		<cfscript>
			this.Planner_Template_Id = qGetPlannerTemplate.Planner_Template_Id;
			return;
		</cfscript>
	</cffunction>

	<cffunction name="setProgramTemplate" access="public" returntype="void" output="false" >
		<cfargument name="status" required="false" default="" type="string" />

		<cfquery name="qGetProgramTemplate" datasource="#application.datasource#">
			SELECT ProgramControl_Panel_Options_ID
			FROM Program_Control_Panel_Options
			WHERE Deleted = 0 and created_type = 'CBD RETAIL TRADE' and isdominant = 1
		</cfquery>

		<cfscript>
			this.Program_Template_Id = qGetProgramTemplate.ProgramControl_Panel_Options_ID;
			return;
		</cfscript>
	</cffunction>

	<cffunction name="getRebateComponent" access="public" returntype="String" output="false" >
		<cfargument name="type" required="true" default="" type="string" />

		<cfquery name="qGetRebateComponent" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_Name
			FROM Program_Rebates_Component_Name 
			WHERE deleted = 0 AND 
					active = 1 AND 
					external_id  = 'ZCMC'
					<cfif left(arguments.type,2) eq 'OI'>
						AND off_invoice_on = 1
						AND accrual_on = 0
					<cfelseif left(arguments.type,2) eq 'BB' OR left(arguments.type,4) eq 'Scan'>
						AND off_invoice_on = 0
						AND accrual_on = 1
					</cfif>
					AND Program_Rebates_Component_Name like '%CBD%[#listLast(arguments.type,'_')#]%'
		</cfquery>

		<cfscript>
			return qGetRebateComponent.Program_Rebates_Component_Name;
		</cfscript>
	</cffunction>

	<cffunction name="getLumpSumComponent" access="public" returntype="String" output="false" >
		<cfargument name="type" required="true" default="" type="string" />

		<cfquery name="qGetLumpSumComponent" datasource="#application.datasource#">
				SELECT Program_Lump_Sum_Name
						FROM  [dbo].[Program_Lump_Sum_Name]
						WHERE deleted = 0 AND 
								active = 1 AND 
								Accrual_On  = 1 AND
								<cfif arguments.type eq 'Lump_Sum'>
									Program_Lump_Sum_Name = 'CBD Lump Sum'
								<cfelseif left(arguments.type,2) eq 'MDF_Demo'>
									Program_Lump_Sum_Name = 'CBD MDF/DEMO'
								<cfelseif left(arguments.type,2) eq 'Slotting'>
									Program_Lump_Sum_Name = 'CBD Slotting'
								<cfelse>
									Program_Lump_Sum_Name_id = 0 ---not found
								</cfif>
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
						Operator_ID,
						Material,
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
						Scan_Redemption_Pct
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
						'#rowData["Operator_ID"]#',
						'#rowData["Material"]#',
						'#rowData["Rate"]#',
						'#rowData["UOM"]#',
						'#rowData["Discount_Type"]#',
						'#rowData["Component"]#',
						'#rowData["Pays_To"]#',
						'#rowData["Frequency"]#',
						'#rowData["Claim_Mechanic"]#',
						'#rowData["Currency"]#',
						'#rowData["Volume"]#',
						'#rowData["Volume_Lift"]#', 
						'#rowData["VOLUME_UOM"]#',
						'#rowData["Creator_ID"]#',
						'#rowData["Performance_Start"]#',
						'#rowData["Performance_End"]#',
						'#rowData["Performance_Type"]#',
						'#rowData["Planner_ID"]#',
						'#rowData["Group_ID"]#',
						'#rowData["EveryDay_Unit_Price"]#',
						'#rowData["Scan_Redemption_Pct"]#'
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
			rowData["Operator_ID"] = '';
			rowData["Material"] = '';
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

		<cfquery name="qUpdateVol" datasource="#application.datasource#">
			UPDATE Y_DEAL_UI_UPLOAD
			    SET Volume = 1, <!---'#arguments.rData.Volume#',--->
			    	Volume_UOM = 'CS'<!---'#arguments.rData.Volume_UOM#'--->
			    WHERE Batch_Id = '#arguments.Batch_ID#' AND
			    		Record_Type	= 'M' 
			    		<!---AND Material = '#arguments.rData.Material#'--->
		</cfquery>

		<cfscript>
			 return;
		</cfscript> 
	</cffunction>

	<cffunction name="getPositionId" access="public" returntype="query" output="false" >
		<cfargument name="userCode" required="false" default="" type="string" />
			
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
					User_Position_Type = 'P' AND
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
			var itemMasterField			= "bsa_FoodService_Items_Master_ID";
		</cfscript>

		<cfquery name="local.updPlannerGroup" datasource="#application.datasource#">
			---  UPDATE GroupLevelId
			UPDATE	Y_DEAL_UI_Upload
			SET		[GROUP_ID] =  PGT.Group_GUID  /* CASE WHEN pgl.Is_PG = 1 THEN '100' ELSE pgt.Product_Group_Level_ID END  */
					, DETAIL_Action = Product_Group_Attribute_Master_ID_Field 
			FROM	Y_DEAL_UI_Upload YDUI
					INNER JOIN All_Product_Group_Types pgt ON SUBSTRING(YDUI.Material, PATINDEX('%[^0]%',YDUI.Material), 11) = SUBSTRING(pgt.Group_Number, PATINDEX('%[^0]%',pgt.Group_Number), 11)
					INNER JOIN Product_Group_Level pgl on pgl.Product_Group_Level_ID = pgt.Product_Group_Level_ID
					INNER JOIN Product_Group_Attribute PGA ON PGA.Product_Group_Level_ID = pgt.Product_Group_Level_ID 
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'V'

			SELECT DISTINCT DETAIL_Action FROM Y_DEAL_UI_Upload YDUI
			WHERE	YDUI.Batch_ID = '#this.Batch_ID#'
					AND Record_Type = 'V'

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
		</cfquery>

		<cfquery name="local.insert" datasource="#application.datasource#" result="qInsert">
			CREATE TABLE ##tmp_planner_distributors ( BSA_Foodservice_Customers_ID UNIQUEIDENTIFIER )

			-- If planner has individual distributor
			INSERT  INTO ##tmp_planner_distributors
					( BSA_Foodservice_Customers_ID )
					SELECT	DISTINCT
							Customer_ID
					FROM    Planners p
					WHERE   Planner_ID = #arguments.plannerID# 		-- Do not use cfqueryparam as we are using this temp table in other query.
							AND IsNull(Distributor_Group_Level_ID, 0) = 0

			-- If planner has group distributor
			INSERT  INTO ##tmp_planner_distributors
					( BSA_Foodservice_Customers_ID )
					SELECT	DISTINCT
							Distributor_ID
					FROM    Planner_Customer_Group_Members p
					WHERE   Planner_ID = #arguments.plannerID# 

			CREATE TABLE ##Tmp_Add_Planner_products (
				Product_ID uniqueidentifier,
				Forecast_Value decimal(20, 2),
				Forecast_UOM int,
				Forecast_Start_Date DATE,
				Volume_Lift decimal(20, 2)
			)
			<!---
			-- Loop over the form and populate the products/groups into temp table
			-- <cfloop index="iIndx" list="#arguments.products_list#">
			-- 	<cfscript>
			-- 		local.postfix = "#Replace(iIndx, "-", "_", "ALL")#";

			-- 		param name="stData.Forecast_Val_#local.postfix#"    default="0";
			-- 		param name="stData.Forecast_UOM_#local.postfix#" 	default="1";
			-- 		param name="stData.Forecast_Start_Date_#local.postfix#"    default="#dToday#";

			-- 		var local.forecastValue = Val(stData[ "Forecast_Val_" & local.postfix ]);
			-- 		var local.forecastUOM = stData[ "Forecast_UOM_" & local.postfix ];
			-- 		var local.forecastDate = stData[ "Forecast_Start_Date_" & local.postfix ];

			-- 		local.forecastDate = (local.forecastDate eq "") ? dToday : local.forecastDate;
			-- 	</cfscript>
			-- 	INSERT INTO ##Tmp_Add_Planner_products (Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date)
			-- 	VALUES (
			-- 		'#iIndx#',
			-- 		'#local.forecastValue#',
			-- 		'#local.forecastUOM#',
			-- 		'#local.forecastDate#'
			-- 	)
			-- </cfloop>
			--->

			INSERT INTO ##Tmp_Add_Planner_products (Product_ID, Forecast_Value, Forecast_UOM, Forecast_Start_Date, Volume_Lift)
			SELECT  Group_Id, Volume, CASE Volume_UOM WHEN 'CS' THEN 1 ELSE 2 END, Start, volume_lift
			FROM Y_DEAL_UI_Upload YDUI
			WHERE 	YDUI.Batch_ID = '#this.Batch_ID#' AND 
				Record_Type = 'V'

			-- Get distinct list of products and distributors
			SELECT 	p.*,
					Dist.BSA_Foodservice_Customers_ID,
					IM.BSA_FoodService_Items_Master_ID,
					CAST(0 as decimal(16,6)) as Forecast_Value_Per_Record,
					CAST(0 as  decimal(16,6)) as Lift_Value_Per_Record,
					CAST(IM.Net_Weight as  decimal(16,6)) as Net_Weight,
					CAST(Count(*) OVER (Partition By p.Product_ID) as  decimal(16,6))/CAST(Count(*) OVER (Partition By IM.BSA_FoodService_Items_Master_ID,Dist.BSA_Foodservice_Customers_ID) as  decimal(16,6)) as Rec_Count,
					Row_Number() OVER (Order By IM.BSA_FoodService_Items_Master_ID) as Rec_Index
			INTO	##Tmp_Add_VP_Prod_Dist
			FROM   ##Tmp_Add_Planner_products P
			INNER JOIN BSA_FoodService_Items_Master IM
				ON IM.#itemMasterField# = p.Product_ID
					AND IM.Item IS NOT NULL
					AND IM.deleted = 0
					AND IM.Active_Code = 'A'
			INNER JOIN ##tmp_planner_distributors Dist on 1=1


			-- If record count is less than volume, ok to divide by record count
			UPDATE	##Tmp_Add_VP_Prod_Dist
			SET		Forecast_Value_Per_Record = Round(Forecast_Value / Rec_Count, 4),
					Lift_Value_Per_Record =  Round(Volume_Lift / Rec_Count, 4)
			---WHERE	Rec_Count <= Forecast_Value

			-- If record count is more than volume, divide volume amoung top x records
			
			-- UPDATE	##Tmp_Add_VP_Prod_Dist
			-- SET		Forecast_Value_Per_Record = 1
			-- WHERE	Rec_Count > Forecast_Value
			-- AND		Rec_Index <= Forecast_Value


			-- Get distinct list of products, distributors and weeks
			SELECT DISTINCT
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
			FROM   Planners
					INNER JOIN Planner_Template
						ON Planner_Template.Planner_Template_Id = Planners.Planner_Template_Id
							AND Planner_Template.Deleted = 0
					INNER JOIN Planner_Week
						ON Planner_Week.Planner_Week_Start_Date >= Planner_Template.Planner_Start_Date
							AND Planner_Week.Planner_Week_End_Date <= Planner_Template.Planner_End_Date
							AND Planner_Week.Deleted = 0
					INNER JOIN ##Tmp_Add_VP_Prod_Dist p
						ON 1 = 1
						---T-Pro and Forge can be off by one day
						AND (Planner_Week.Planner_Week_Start_Date =  dateadd(day,1,p.Forecast_Start_Date) OR 	Planner_Week.Planner_Week_Start_Date =  dateadd(day,-1,p.Forecast_Start_Date) OR Planner_Week.Planner_Week_Start_Date =  p.Forecast_Start_Date)
			WHERE  Planners.Planner_Id  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.plannerID#" >

			UPDATE ##Tmp_Add_VP_Prod_Dist_Week set Forecast_cs = Lift_cs + Forecast_base_cs, 
												   Forecast_lbs = Lift_lbs + Forecast_base_lbs

			---UPDATE FIRST
			UPDATE PVP
				SET 
					Forecast_CS = t.Forecast_CS,
					Forecast_LBS = t.Forecast_LBS,
					Forecast_Lift_CS = t.Lift_CS,
					Forecast_Lift_LBS = t.Lift_LBS,
					Forecast_Base_CS = t.Forecast_Base_CS,
					Forecast_Base_LBS = t.Forecast_Base_LBS,
					Forecast_Updated = 1,
					Updated_DAte = GetDate()
				FROM Planner_Volume_Plan PVP
				INNER JOIN ##Tmp_Add_VP_Prod_Dist_Week t ON
					PVP.Planner_Week_ID = t.Planner_Week_ID AND
					PVP.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID AND
				    PVP.BSA_Foodservice_Items_Master_ID = t.bsa_FoodService_Items_Master_ID
				WHERE isnull(PVP.Forecast_Updated,0) != 1

			-- Insert
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
					Forecast_Updated)
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
					1
			FROM	##Tmp_Add_VP_Prod_Dist_Week t
			WHERE 	NOT EXISTS (
				SELECT  1
				FROM    Planner_Volume_Plan v
				WHERE   v.Planner_Week_ID = t.Planner_Week_ID
				AND     v.BSA_Foodservice_Customers_ID = t.BSA_Foodservice_Customers_ID
				AND     v.BSA_Foodservice_Items_Master_ID = t.bsa_FoodService_Items_Master_ID
			)

			DELETE	Planner_Volume_Plan_Deleted_Records
			WHERE	EXISTS (
				SELECT  1
				FROM    ##Tmp_Add_VP_Prod_Dist_Week t
				WHERE   t.Planner_Week_ID = Planner_Volume_Plan_Deleted_Records.Planner_Week_ID
				AND     t.BSA_Foodservice_Customers_ID = Planner_Volume_Plan_Deleted_Records.BSA_Foodservice_Customers_ID
				AND     t.BSA_Foodservice_Items_Master_ID = Planner_Volume_Plan_Deleted_Records.bsa_FoodService_Items_Master_ID
			)
		</cfquery>
		<cfscript>
				this.dmp(qInsert);
		</cfscript>

	</cffunction>

	<cffunction name="GetData" access="remote" httpmethod="Get" restpath="GetData" output='false' returntype="any">
		<cfargument name="Id" required="false" restargsource="query" type="string" default="70011256 - FY 2020"/>
		<cfscript>
			/*	COSTCO 70011256
			    274950

				70012846
				916720
				499745
				70000695
				70023586
				224178
				70023072
				327222
				255417
				430393
				719306
				52214
				781572
				463460
				430406
				274010
				-------
				70033231
				70070795
				46081
				70072590
				70015572
				70038811
				70032982
				70084912
			*/
			if(!request.bAuthorized){
					return serializeJson(this.noAuthMessage);
			}

			try{
					var legacy_id = "PromoEvents.PromoEventNumber aa";
					var legacy_id2 = "PromoEvents.PromoEventNumber bb";
					var x = CreateObject("component","components.Interfaces.Service.Planner").init();
					var prg = CreateObject("component","components.Interfaces.Service.Program").init();
					
					

					X["Planner_Id"]	=	arguments.Id;
			 		X["Start_Date"]	=	"01/01/2020";
			 		X["End_Date"]		=	"05/31/2020";
			 		X["Responsible_Sales_Person"] =	"Mark Saunders" ;
			 		X["PlannerVolume"]	= ArrayNew(1);
/*
Perf Types
	FORGE:				T-Pro:
	EDLP				EDLP
	TPR					TPR Only
	Display				Display Only
	Feature				Ad Only
	Feature & Display	Ad & Display
	Coupon				Other
*/		


						Start_Date = '04/19/2020';
					for (i=1; i <= 12;i=i+1) {
						PlannerVol = CreateObject("component","components.Interfaces.Service.PlannerVolume").init();
						PlannerVol["Distributor_ID"] 	= '#arguments.Id#';
						PlannerVol["Item_Number"] 	= "050-15";
						PlannerVol["Base_Volume"] 	= 1000 + i -1;
						PlannerVol["Incr_Volume"] 	= 200 + i -1;
						PlannerVol["UOM"] 	= 'CS';
						PlannerVol["Start_Date"] = dateformat(dateAdd('ww', i-1, Start_Date),'mm/dd/yyyy');
					   X.PlannerVolume[i] = PlannerVol;
					}
					for (i=13; i <= 18;i=i+1) {
						PlannerVol = CreateObject("component","components.Interfaces.Service.PlannerVolume").init();
						PlannerVol["Distributor_ID"] 	= '#arguments.Id#';
						PlannerVol["Item_Number"] 	= "060-40";
						PlannerVol["Base_Volume"] 	= 1000 + i -1;
						PlannerVol["Incr_Volume"] 	= 200 + i -1;
						PlannerVol["UOM"] 	= 'CS';
						PlannerVol["Start_Date"] = dateformat(dateAdd('ww', i-1, Start_Date),'mm/dd/yyyy');
					   X.PlannerVolume[i] = PlannerVol;
					}
					//X.PlannerVolume[1] = PlannerVol;

			 		X["Programs"]	= ArrayNew(1);
			 			prg["Legacy_Program_ID"] 	=	legacy_id;
						prg["Template_Description"] =	"template aa";
						prg["Program_Title"] 		=	"Super great Deli Deal";
						prg["Program_Start_Date"] 	=	"01/01/2020";
						prg["Program_End_date"] 	=	"05/31/2020";
						prg["Responsible_Sales_Person"] =	"Mark Saunders" ;
						//prg["Creator_Position"] 	=	"admin";
						prg["Created_Date"] 		=	  DateTimeFormat(now(),'mm/dd/yyyy hh:mm:ss');
						// These are all NULL so don't need them
						// prg.RFA_ID =						"";
						// prg.RFA_Date =						now();
						// prg.Approval_ID =					"";
						// prg.Approval_Date =					now();
						// prg.Bid_Status =					"";
						// prg.Reference_Number =				"";
						// 
						// prg.Business_Segment =				"";
						//
						prg["Action_code"] 		=	"N";
						prg["Planner_Id"] 			=	arguments.Id;
						prg["Performance_Start"] 	= "2020-01-01";
						prg["Performance_End"] 		=  "2020-05-31";
						prg["Performance_Type"] 	=	"EDLP";
			 			prg["Distributors"]		= 	ArrayNew(1);
			 			prg["Rebates"] 			=	ArrayNew(1);
			 			prg["LumpSums"] 			=	ArrayNew(1);
			 			prg["ItemVolume"] 			=	ArrayNew(1);
			 				
			 				var dst = CreateObject("component","components.Interfaces.Service.Distributor").init();
			 				//dst["Legacy_Program_ID"] 	= legacy_id;
			 				dst["Distributor_Id"] 		= arguments.Id;
			 			prg.Distributors[1] = dst;

			 				var reb = CreateObject("component","components.Interfaces.Service.Rebate").init();
				 			//reb["Legacy_Program_ID"] 	= legacy_id;
							reb["Item_Number"] 			= '050-15';
							reb["Rebate_Amount"] 			= '2.50';
							reb["Rebate_Unit_of_Measure"] 	= 'CS';
							reb["External_Component_ID"] 	= 'BB_$';
							reb["GL_Account"] 				= '';
							//reb.Pays_To 				= '';
							//reb.Payment_frequency 		= '';
							reb["Claim_Mechanic"] 			= 'Billback';
							//reb.Empty_Field_1 			= '';
							//reb.Empty_Field_2 			= '';
							reb["Currency"] 				= 'USD';
							reb["Group"] 					= '1';
						prg.Rebates[1] = reb;

							var lump = CreateObject("component","components.Interfaces.Service.LumpSum").init();
							//lump["Legacy_Program_ID"] 		=	legacy_id;	
							lump["Item_Number"] 			=	"060-40";	
							lump["LS_Amount"] 				=	"150.00";	
							//lump.Lump_Sum_Description 	=	"";	
							lump["LS_component_Name"] 		=	"Lump_Sum";	
							//lump.GL_Account 			=	"";	
							//lump.LS_Pays_To 			=	"D";	
							//lump.Payment_frequency 		=	"Upon Due";	
							lump["Claim_Mechanic"] 		=	"Billback";	
							//lump.Payee 					=	"";	
							//lump.Payee_Eligibility 		=	"";	
							lump["Currency"] 				=	"USD";	
							lump["Group"] 					=	"1";	
						prg.LumpSums[1] = lump;

							var itemVol = CreateObject("component","components.Interfaces.Service.ItemVolume").init();
							//itemVol["Legacy_Program_ID"] 	= legacy_id;
							itemVol["Item_Number"] 	= "060-40";
							itemVol["Program_Volume_Cases"] 	= 1200;
							//itemVol["Program_Volume_Pounds"] 	= ;
							var itemVol4 = CreateObject("component","components.Interfaces.Service.ItemVolume").init();
							//itemVol2["Legacy_Program_ID"] 	= legacy_id2;
							itemVol4["Item_Number"] 	= "060-86";
							itemVol4["Program_Volume_Cases"] 	= 99;
						//prg.ItemVolume[1]	= itemVol;
						//prg.ItemVolume[2]	= itemVol4;

					X.Programs[1] = prg;
				//////////////////////////////////////////////////////////////////////////////////////////////////
					var prg2 = CreateObject("component","components.Interfaces.Service.Program").init();
						prg2["Legacy_Program_ID"] 	=	legacy_id2;
						prg2["Template_Description"] =	"template BB";
						prg2["Program_Title"] 		=	"Another Program";
						prg2["Program_Start_Date"] 	=	"01/01/2020";
						prg2["Program_End_date"] 	=	"05/31/2020";
						prg2["Responsible_Sales_Person"] =	"Mark Saunders" ;
						prg2["Creator_Position"] 	=	"admin";
						prg2["Created_Date"] 		=	 DateTimeFormat(now(),'mm/dd/yyyy hh:mm:ss');
						// These are all NULL so don't need them
						// prg2.RFA_ID =						"";
						// prg2.RFA_Date =						now();
						// prg2.Approval_ID =					"";
						// prg2.Approval_Date =					now();
						// prg2.Bid_Status =					"";
						// prg2.Reference_Number =				"";
						// 
						// prg2.Business_Segment =				"";
						//
						prg2["Action_code"] 		=	"N";
						prg2["Planner_Id"] 			=	arguments.Id;
						prg2["Performance_Start"] 	=	"01/01/2020";
						prg2["Performance_End"] 	=	"05/31/2020";
						prg2["Performance_Type"] 	=	"TPR Only";
			 			prg2["Distributors"]		= 	ArrayNew(1);
			 			prg2["Rebates"] 			=	ArrayNew(1);
			 			prg2["LumpSums"] 			=	ArrayNew(1);
			 			prg2["ItemVolume"] 			=	ArrayNew(1);
			 				
			 				var dst2 = CreateObject("component","components.Interfaces.Service.Distributor").init();
			 				//dst2["Legacy_Program_ID"] 	= legacy_id2;
			 				dst2["Distributor_Id"] 		= arguments.Id;
			 			prg2.Distributors[1] = dst2;

			 				var reb2 = CreateObject("component","components.Interfaces.Service.Rebate").init();
				 			//reb2["Legacy_Program_ID"] 	= legacy_id2;
							reb2["Item_Number"] 			= '050-15';
							reb2["Rebate_Amount"] 			= '7.77';
							reb2["Rebate_Unit_of_Measure"] 	= 'PER';
							reb2["External_Component_ID"] 	= 'OI_%';
							reb2["GL_Account"] 				= '';
							//reb2.Pays_To 				= '';
							//reb2.Payment_frequency 		= '';
							reb2["Claim_Mechanic"] 			= 'OFF INVOICE';
							//reb2.Empty_Field_1 			= '';
							//reb2.Empty_Field_2 			= '';
							reb2["Currency"] 				= 'USD';
							reb2["Group"] 					= '1';
						prg2.Rebates[1] = reb2;

							var lump2 = CreateObject("component","components.Interfaces.Service.LumpSum").init();
							//lump2["Legacy_Program_ID"] 		=	legacy_id2;	
							lump2["Item_Number"] 			=	"060-40";	
							lump2["LS_Amount"] 				=	"99.00";	
							//lump.Lump_Sum_Description 	=	"";	
							lump2["LS_component_Name"] 		=	"Lump_Sum";	
							//lump.GL_Account 			=	"";	
							//lump.LS_Pays_To 			=	"D";	
							//lump.Payment_frequency 		=	"Upon Due";	
							lump2["Claim_Mechanic"] 		=	"Billback";	
							//lump.Payee 					=	"";	
							//lump.Payee_Eligibility 		=	"";	
							lump2["Currency"] 				=	"USD";	
							lump2["Group"] 					=	"1";	
						prg2.LumpSums[1] = lump2;

							var itemVol2 = CreateObject("component","components.Interfaces.Service.ItemVolume").init();
							//itemVol2["Legacy_Program_ID"] 	= legacy_id2;
							itemVol2["Item_Number"] 	= "050-15";
							itemVol2["Program_Volume_Cases"] 	= 1700;

							var itemVol3 = CreateObject("component","components.Interfaces.Service.ItemVolume").init();
							//itemVol2["Legacy_Program_ID"] 	= legacy_id2;
							itemVol3["Item_Number"] 	= "060-40";
							itemVol3["Program_Volume_Cases"] 	= 22;
							//itemVol["Program_Volume_Pounds"] 	= ;
						//prg2.ItemVolume[1]	= itemVol2;
						//prg2.ItemVolume[2]	= itemVol3;


				//////////////////////////////////////////////////////////////////////////////////////////////////
					X.Programs[2] = prg2;


			
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
