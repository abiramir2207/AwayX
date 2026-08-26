<cfcomponent hint="Program Most Favored Nation" extends="components.Base">

	<cffunction name="checkIfMFNExists" access="public" returntype="query" output="false">
		
		<cfargument name="programId"	type="numeric" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID		= "";
			
			//assign local variables
			nProgramID		= arguments.programId;
		</cfscript>
		
		<cfquery name="qCheckIfIxists" datasource="#application.datasource#">
		
			SELECT	mfn.*
			from	Contract_Main cm
					INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Business_Segment bs ON bs.Business_Segment_ID =  cm.Business_Segment_ID
					INNER JOIN Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0
					INNER JOIN BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					INNER JOIN Program_Most_Favored_Nation_Data mfn on mfn.Template_Created_Type = pcpo.Created_Type and mfn.Component_Type = cp.Product_Type_ID
					and mfn.Item = im.Item and mfn.Business_Unit_ID = bs.Business_Unit_ID and mfn.Deleted = 0
					/* Only include APPROVED PROGRAMS (PRE-ACTIVE, ACTIVE & EXPIRING). Only include non-deleted versions */
					INNER JOIN Contract_Main cm_mfn on cm_mfn.Contract_Main_ID = mfn.Program_ID and cm_mfn.Deleted = 0 and cm_mfn.Effective_Start_Date is not null and cm_mfn.Contract_Status_Type_IDX in (4, 5, 6)
			WHERE	cm.Contract_Main_ID = '#nProgramID#'
			AND		cm.Contract_Main_ID != mfn.Program_ID
			AND		cm.Contract_Number != mfn.Program_Number

		</cfquery>
		
		<cfreturn qCheckIfIxists />
		
	</cffunction>
	
	<cffunction name="getTemplatesByType" access="public" returntype="query" output="false">
	
		<cfargument name="templateType" 		type="string" required="true" />
		<cfargument name="businessUnitID" 		type="string" required="true" />
		<cfargument name="excludeCreatedType" 	type="string" required="false" default="" />
		
		
		<cfscript>
			//set local variables
			var strTemplateType			= "";
			var strBusinessUnitID		= "";
			var strExcludeCreataedType	= "";
			
			//assign local variables
			strTemplateType			= arguments.templateType;
			strBusinessUnitID		= arguments.businessUnitID;
			strExcludeCreataedType	= arguments.excludeCreatedType;
			
		</cfscript>
		
		<cfquery name="qTemplateTypeData" datasource="#application.datasource#">
		
			SELECT	DISTINCT BS.Business_Unit_ID, PCPO.Generic_Type, PCPO.Created_Type
			FROM	Program_Control_Panel_Options PCPO
					INNER JOIN 	Template_Business_Segment TBS ON TBS.Template_ID = PCPO.ProgramControl_Panel_Options_ID AND TBS.Deleted = 0
					INNER JOIN Business_Segment BS ON BS.Business_Segment_ID =  TBS.Business_Segment_ID
			WHERE	PCPO.Deleted = 0
			AND		PCPO.IsDominant = 1
			AND		BS.Deleted = 0
			AND		BS.Active = 1
			AND		PCPO.Generic_Type = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strTemplateType#">
			AND		BS.Business_Unit_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strBusinessUnitID#">
			<cfif trim(strExcludeCreataedType) neq "">
			AND		PCPO.Created_Type != <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strExcludeCreataedType#">
			</cfif>
			ORDER BY 	PCPO.Created_Type asc	

		</cfquery>
		
		<cfreturn qTemplateTypeData />
		
	</cffunction>

	<cffunction name="saveMFNData" access="public" output="false">
	
		<cfargument name="templateType"		type="string" 	required="true" />
		<cfargument name="createdType"		type="string" 	required="true" />
		<cfargument name="programId" 		type="numeric" 	required="true" />
		<cfargument name="programNumber"	type="string" 	required="true" />
		<cfargument name="componentType"	type="numeric" 	required="true" />
		<cfargument name="componentNameID"	type="numeric" 	required="true" />
		<cfargument name="componentName"	type="string" 	required="true" />
		<cfargument name="componentPaysTo"	type="numeric" 	required="true" />
		<cfargument name="componentRate"	type="string" 	required="true" />
		<cfargument name="componentUOM"		type="numeric" 	required="true" />
		<cfargument name="item" 			type="string" 	required="true" />
		<cfargument name="businessUnitID"	type="string" 	required="true" />

		<cfscript>
			//set local variables
			var strTemplateType		= "";
			var strCreatedType		= "";
			var nProgramId			= "";
			var strProgramNumber	= "";
			var nComponentType		= "";
			var nComponentNameID	= "";
			var strComponentName	= "";
			var nComponentPaysTo	= "";
			var strComponentRate	= "";
			var nComponentUOM		= 0;
			var strItem				= "";
			var strBusinessUnitID	= "";
			
			//assign local variables
			strTemplateType		= arguments.templateType;
			strCreatedType		= arguments.createdType;
			nProgramId			= arguments.programId;
			strProgramNumber	= arguments.programNumber;
			nComponentType		= arguments.componentType;
			nComponentNameID	= arguments.componentNameID;
			strComponentName	= arguments.componentName;
			nComponentPaysTo	= arguments.componentPaysTo;
			strComponentRate	= arguments.componentRate;
			nComponentUOM		= arguments.componentUOM;
			strItem				= arguments.item;
			strBusinessUnitID	= arguments.businessUnitID;
			
		</cfscript>
	
		<cfquery name="qAddData" datasource="#application.datasource#">
			
			UPDATE	Program_Most_Favored_Nation_Data
			SET		Deleted = 1
			WHERE	Template_Generic_Type = '#strTemplateType#'
			AND		Template_Created_Type = '#strCreatedType#'
			AND		Program_Number = '#strProgramNumber#'
			AND		Component_Type = '#nComponentType#'
			AND		Component_Name_ID = '#nComponentNameID#'
			AND		Component_Pays_To = '#nComponentPaysTo#'
			AND		Item = '#strItem#'
			AND		Business_Unit_ID = '#strBusinessUnitID#'
			
				
			INSERT INTO Program_Most_Favored_Nation_Data
				(Template_Generic_Type, Template_Created_Type, Program_ID, Program_Number, Component_Type, Component_Name_ID, Component_Name, Component_Pays_To, Component_Rate, Unit_Of_Measure_ID, Item, Business_Unit_ID)
			VALUES
				('#strTemplateType#', '#strCreatedType#', '#nProgramId#', '#strProgramNumber#', '#nComponentType#', '#nComponentNameID#', '#strComponentName#', '#nComponentPaysTo#', '#strComponentRate#', #nComponentUOM#, '#strItem#', '#strBusinessUnitID#')
		
		</cfquery>
	
	</cffunction>
	
	<cffunction name="getMFNConflicts" access="public" returntype="query" output="false">
	
		<cfargument name="programId"	type="numeric" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID		= "";
			
			//assign local variables
			nProgramID		= arguments.programId;
		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
		
			select	cm.Contract_Number AS Current_Program_Number,
					im.Item,
					<!--- Current program rate --->
					CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2)) as Current_Program_Price,
					CASE fxp.Unit_Of_Measure_ID WHEN 1 THEN '/CS' WHEN 2 THEN '/LB' END as Current_Program_UOM,
					fxp.Unit_Of_Measure_ID as Current_Program_UOM_ID,
					CASE fxp.Unit_Of_Measure_ID 
					WHEN 1 THEN CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2)) / cast(im.Net_Weight as float) 
					WHEN 2 THEN CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2)) 
					END as Current_Program_LB,
					CASE fxp.Unit_Of_Measure_ID 
					WHEN 1 THEN CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2))
					WHEN 2 THEN CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2)) * cast(im.Net_Weight as float)  
					END as Current_Program_CS,
			
					<!--- MFN rate --->
					mfn.program_number as MFN_Program_Number,
					mfn.Component_Rate as MFN_Price,
					CASE mfn.Unit_Of_Measure_ID WHEN 1 THEN '/CS' WHEN 2 THEN '/LB' END as MFN_UOM,
					mfn.Unit_Of_Measure_ID as MFN_UOM_ID,
					mfn.Component_Type,
					CASE mfn.Unit_Of_Measure_ID 
					WHEN 1 THEN mfn.Component_Rate / cast(im.Net_Weight as float) 
					WHEN 2 THEN mfn.Component_Rate
					END as MFN_Price_LB,
					CASE mfn.Unit_Of_Measure_ID 
					WHEN 1 THEN mfn.Component_Rate
					WHEN 2 THEN mfn.Component_Rate * cast(im.Net_Weight as float) 
					END as MFN_Price_CS
			from	Contract_Main cm
					INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Business_Segment bs ON bs.Business_Segment_ID =  cm.Business_Segment_ID
					INNER JOIN Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0 and cp.Product_Type_ID = 1
					INNER JOIN BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					INNER JOIN Program_Fixed_Component fx on fx.Program_ID = cm.Contract_Main_ID and fx.Deleted = 0
					INNER JOIN Program_Fixed_Price_Product_Data fxp on fxp.Program_Fixed_Component_ID = fx.Program_Fixed_Component_ID AND fxp.Contract_Products_ID = cp.Contract_Products_ID
					INNER JOIN Program_Most_Favored_Nation_Data mfn on mfn.Template_Created_Type = pcpo.Created_Type and mfn.Component_Type = cp.Product_Type_ID
					and mfn.Component_Name_ID = fx.Program_Fixed_Component_Name_ID
					and mfn.Item = im.Item and mfn.Business_Unit_ID = bs.Business_Unit_ID
					and mfn.Deleted = 0
					/* Only include APPROVED PROGRAMS (PRE-ACTIVE, ACTIVE & EXPIRING). Only include non-deleted versions */
					INNER JOIN Contract_Main cm_mfn on cm_mfn.Contract_Main_ID = mfn.Program_ID and cm_mfn.Deleted = 0 and cm_mfn.Effective_Start_Date is not null and cm_mfn.Contract_Status_Type_IDX in (4, 5, 6) 
			WHERE	cm.Contract_Main_ID = '#nProgramID#'
			AND		case 
					when mfn.Unit_Of_Measure_ID = fxp.Unit_Of_Measure_ID then CAST(fxp.Fixed_Price_Value AS FLOAT) -- UOM is same
					when fxp.Unit_Of_Measure_ID = 2 then CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2)) * cast(im.Net_Weight as float) -- convert from LB to CS
					when fxp.Unit_Of_Measure_ID = 1 then CAST(fxp.Fixed_Price_Value AS DECIMAL(18,2)) / cast(im.Net_Weight as float) -- convert from CS to LB
					end < mfn.Component_Rate 
			
			
			UNION
			
			SELECT	cm.Contract_Number AS Current_Program_Number,
					im.Item,
					
					<!--- Current program rate --->
					CAST(prcd.Rate AS DECIMAL(18,2)) as Current_Program_Price,
					CASE prcd.Unit_Of_Measure_ID WHEN 1 THEN '/CS' WHEN 2 THEN '/LB' WHEN 3 THEN '%' END as Current_Program_UOM,
					prcd.Unit_Of_Measure_ID as Current_Program_UOM_ID,
					CASE prcd.Unit_Of_Measure_ID 
					WHEN 1 THEN CAST(prcd.Rate AS DECIMAL(18,2)) / cast(im.Net_Weight as float) 
					WHEN 2 THEN CAST(prcd.Rate AS DECIMAL(18,2)) 
					WHEN 3 THEN CAST(prcd.Rate AS DECIMAL(18,2)) <!--- need to add conversion logic later --->
					END as Current_Program_LB,
					CASE prcd.Unit_Of_Measure_ID 
					WHEN 1 THEN CAST(prcd.Rate AS DECIMAL(18,2))
					WHEN 2 THEN CAST(prcd.Rate AS DECIMAL(18,2)) * cast(im.Net_Weight as float)  
					WHEN 3 THEN CAST(prcd.Rate AS DECIMAL(18,2)) <!--- need to add conversion logic later --->
					END as Current_Program_CS,
			
					<!--- MFN rate --->
					mfn.program_number as MFN_Program_Number,
					mfn.Component_Rate as MFN_Price,
					CASE mfn.Unit_Of_Measure_ID WHEN 1 THEN '/CS' WHEN 2 THEN '/LB' END as MFN_UOM,
					mfn.Unit_Of_Measure_ID as MFN_UOM_ID,
					mfn.Component_Type,
					CASE mfn.Unit_Of_Measure_ID 
					WHEN 1 THEN mfn.Component_Rate / cast(im.Net_Weight as float) 
					WHEN 2 THEN mfn.Component_Rate
					WHEN 3 THEN mfn.Component_Rate <!--- need to add conversion logic later --->
					END as MFN_Price_LB,
					CASE mfn.Unit_Of_Measure_ID 
					WHEN 1 THEN mfn.Component_Rate
					WHEN 2 THEN mfn.Component_Rate * cast(im.Net_Weight as float) 
					WHEN 3 THEN mfn.Component_Rate <!--- need to add conversion logic later --->
					END as MFN_Price_CS
			from	Contract_Main cm
					INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Business_Segment bs ON bs.Business_Segment_ID =  cm.Business_Segment_ID
					INNER JOIN Contract_Products cp on cp.Contract_Main_ID = cm.Contract_Main_ID and cp.Deleted = 0
					INNER JOIN BSA_Foodservice_Items_Master im on im.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					INNER JOIN Program_Rebates_Component prc on prc.Program_ID = cm.Contract_Main_ID and prc.Deleted = 0
					INNER JOIN Program_Rebates_Product_Data prpd on prpd.Program_ID = cm.Contract_Main_ID and prpd.Contract_Products_ID = cp.Contract_Products_ID and prpd.Deleted = 0
					INNER JOIN Program_Rebates_Component_Data prcd on prcd.Program_Rebates_Component_ID = prc.Program_Rebates_Component_ID and prcd.Program_Rebates_Product_Data_ID = prpd.Program_Rebates_Product_Data_ID
					INNER JOIN Program_Most_Favored_Nation_Data mfn on mfn.Template_Created_Type = pcpo.Created_Type and mfn.Component_Type = cp.Product_Type_ID
					and mfn.Component_Name_ID = prc.Program_Rebates_Component_Name_ID
					and mfn.Item = im.Item and mfn.Business_Unit_ID = bs.Business_Unit_ID
					and mfn.Deleted = 0
					/* Only include APPROVED PROGRAMS (PRE-ACTIVE, ACTIVE & EXPIRING). Only include non-deleted versions */
					INNER JOIN Contract_Main cm_mfn on cm_mfn.Contract_Main_ID = mfn.Program_ID and cm_mfn.Deleted = 0 and cm_mfn.Effective_Start_Date is not null and cm_mfn.Contract_Status_Type_IDX in (4, 5, 6)
			WHERE	cm.Contract_Main_ID = '#nProgramID#'
			AND		case 
					when mfn.Unit_Of_Measure_ID = prcd.Unit_Of_Measure_ID then CAST(prcd.Rate AS FLOAT) -- UOM is same
					when prcd.Unit_Of_Measure_ID = 2 then CAST(prcd.Rate AS FLOAT) * cast(im.Net_Weight as float) -- convert from LB to CS
					when prcd.Unit_Of_Measure_ID = 1 then CAST(prcd.Rate AS FLOAT) / cast(im.Net_Weight as float) -- convert from CS to LB
					end > mfn.Component_Rate
			

		</cfquery>

		<cfreturn qGetData />
	
	</cffunction>
	
	<cffunction name="getMFNData" access="public" returntype="query" output="false">
	
		<cfargument name="programId"	type="numeric" 	required="true" />

		<cfscript>
			//set local variables
			var nProgramID		= "";
			
			//assign local variables
			nProgramID		= arguments.programId;
		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
		
			SELECT	DISTINCT Template_Created_Type, Component_Name
			FROM	Program_Most_Favored_Nation_Data
			WHERE	Program_ID = '#nProgramID#'
			AND		Deleted = 0
			
		</cfquery>
		
		<cfreturn qGetData />
		
	</cffunction>
	
</cfcomponent>