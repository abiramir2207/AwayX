<cfcomponent name="ComponentDefManager" displayname="ComponentDefManager"  extends="mvc.Models.SettingsService" >

	<cfset objTemplateManager 	= CreateObject("component", "components.programs.template.TemplateManager") />
	<cfset objMarketPrice		= CreateObject("component","mvc.Models.Template.MarketPriceManager") />

	<cffunction name="getComponentDefJSON" access="remote" output="false" returnformat="JSON">
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="bMarketPrice" type="Boolean" required="false" default="false" />
		<cfscript>
			var jsonData = '';
			//var a = arguments;
			jsonData = serializeJSON(getComponentDef(arguments.programId,arguments.bMarketPrice));
		</cfscript>

		<cfreturn jsonData/>	
	</cffunction>
	
	<cffunction name="getComponentDef" access="remote" output="false" returntype="Array" hint="function to return all components">
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="bMarketPrice" type="Boolean" required="false" default="false" />
		<cfscript>	
			//set local variables
			var arrRet 				= ArrayNew(1);
			
			if(arguments.bMarketPrice){
				arrRet = this.getMPComponentDef(arguments.programId);
			}
			else{
				arrRet = this.getFixRebComponentDef(arguments.programId);
			}
		</cfscript>
		<cfreturn arrRet />
	</cffunction>

	<!--- GET MP Comp DEF Whne the rates tool is uesed to edit MP rates from Program Wizard --->
	<cffunction name="getMPComponentDef" access="remote" output="false" returntype="Array" hint="function to return all components">
		<cfargument name="programId" type="Numeric" required="true" />
		<cfscript>	
			//set local variables
			var qTemplateUOM 		= "";
			var qUOM 				= "";
			var arrPaidTo 			= ArrayNew(1);
			var arrPaymentCycle 	= ArrayNew(1);
			var arrClaimMechanic	= ArrayNew(1);
			var arrGlAccount 		= ArrayNew(1);
			var qGetMPDef 			= "";
			var arrUom				= ArrayNew(1);
			var arrRet 				= ArrayNew(1);
			var uom_id_list			= "";
			var templateFiltersId	= 0;
			
			
				//now go get the Template_Filter_Id based on the iMarketPriceListId
			templateFiltersId = objMarketPrice.getTemplateFiltersIDBasedOnMP(arguments.programId);
			arrUom = objMarketPrice.getMPUomData(templateFiltersId);
		</cfscript>
		<!--- get MP details that will be stored as a component --->
		<cfquery name="qGetMPDef" datasource="#application.datasource#">
			SELECT  MP.Status + ' [' + CONVERT(char(10), Start_Date, 101) + '] ' AS Description,
					MP.Market_Price_List_Id,
					MP.Start_Date,
					MP.Status
			FROM Template_Filters TF
			INNER JOIN Market_Price_List MP ON
				MP.Template_Filters_Id = TF.Template_Filters_Id
			WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#templateFiltersId#">
				AND MP.Market_Price_List_Id = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" />
				AND		TF.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
				AND		MP.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
		</cfquery>
		
		<!--- loop over MP Def--->
		<cfloop query="qGetMPDef">
			<cfscript>
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.ComponentDef";
				stData["componentId"] = qGetMPDef.Market_Price_List_Id;
				stData["name"] = qGetMPDef.Description;
				stData["type"] = 1;
				stData["uom"] = arrUom;
				stData["paidTo"] = arrPaidTo;
				stData["paymentCycle"] = arrPaymentCycle;
				stData["claimMechanic"] = arrClaimMechanic;
				stData["glAccount"] = arrGlAccount;
				stData["bGreatestValue"] = JavaCast("boolean" ,0);
            	ArrayAppend(arrRet, duplicate(stData));
			</cfscript>
		</cfloop>
		
		<cfreturn arrRet />
	</cffunction>
	<!--- GET FIXED AND REBATE COMPONENT DEF --->
	<cffunction name="getFixRebComponentDef" access="remote" output="false" returntype="Array" hint="function to return all components">
		
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="componentId" type="Numeric" required="false" default="0" />
		<cfargument name="compType" type="String" required="false" default="1,2" />

		<cfscript>	
			//set local variables
			var nProgramID			= "";
			var nProgramTypeID		= "";
			var nDefaultFixedComp	= 0;
			var nDefaultRebateComp	= 0;
			var arrUomTypeFixed 	= ArrayNew(1);
			var arrUomTypeRebate	= ArrayNew(1);
			var arrPaidTo 			= ArrayNew(1);
			var arrPaymentCycle 	= ArrayNew(1);
			var bDefaultComp 		= 0;
			var qGetFixedComp 		= "";
			var qGetRebateComp 		= "";
			var qGetTemplate 		= "";
			var arrRet 				= ArrayNew(1);
	
			//assign local variables
			nProgramID 			= arguments.programId;
			qGetTemplate		= objTemplateManager.getProgramTemplate(nProgramID);
			nProgramTypeID		= qGetTemplate.ProgramControl_Panel_Options_ID;
			nDefaultFixedComp	= qGetTemplate.Default_Fixed_Component_Name_Id;
			nDefaultRebateComp	= qGetTemplate.Default_Rebate_Component_Name_Id;
			arrUomTypeFixed 	= getComponentUomData(nProgramID, 1);
			arrUomTypeRebate 	= getComponentUomData(nProgramID, 2);
			arrPaymentCycle		= getComponentPaymentCycleData(nProgramTypeID);
		</cfscript>

		<!--- get active fixed component data --->
		<cfset qGetComps = CreateObject("component","components.programs.template.TemplateManager").getAllTemplateDiscountComponents(nProgramTypeID,arguments.compType,1,arguments.componentId) />
		<!---<cfset qGetFixedComp = CreateObject("component","components.programs.Fixed.FixedComponent").getActive() />--->
		<!--- PROFILE RESTRICTION --->
		<cfquery name="qGetFixedCompProfileRestriction" datasource="#application.datasource#">
			SELECT	Program_Fixed_Component_Name_ID
			FROM Program_Fixed_Component_Profile PFCP
			WHERE
				PFCP.Profiles_ID = #request.accessStructure.PROFILES_ID# AND
				DELETED = 0
		</cfquery>
		<cfquery name="qGetFixedComp" dbtype="query">
			SELECT	Component_ID AS Program_Fixed_Component_Name_ID,
					Component_Name AS Program_Fixed_Component_Name,
					fixedType,
					Greatest_Program_Value
			FROM	qGetComps
			WHERE	Discount_Type_ID = 1
			AND		Component_Selected = 1
			<cfif qGetFixedCompProfileRestriction.recordcount>
				AND qGetComps.Component_ID NOT IN (#ValueList(qGetFixedCompProfileRestriction.Program_Fixed_Component_Name_ID)#)
			</cfif>
			ORDER BY Program_Fixed_Component_Name DESC
		</cfquery>
		
		<!--- loop over fixed component data and build array of structs--->
		<cfloop query="qGetFixedComp">
			<cfscript>
				arrGlAccount = ArrayNew(1);
				arrClaimMechanic = ArrayNew(1);
				arrGlAccount = getComponentGlAccount(1,qGetFixedComp.Program_Fixed_Component_Name_ID,programId);
				arrClaimMechanic = getComponentClaimMechanicData(nProgramTypeID, 1, qGetFixedComp.Program_Fixed_Component_Name_ID);
				arrPaidTo 			= getComponentPaidToData(nProgramTypeID,  1, qGetFixedComp.Program_Fixed_Component_Name_ID);
				bDefaultComp = 0;
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.ComponentDef";
				stData["componentId"] = qGetFixedComp.Program_Fixed_Component_Name_ID;
				stData["name"] = qGetFixedComp.Program_Fixed_Component_Name;
				stData["type"] = 1;
				stData["fixedType"] = qGetFixedComp.fixedType;
				stData["uom"] = arrUomTypeFixed;
				stData["paidTo"] = arrPaidTo;
				stData["paymentCycle"] = arrPaymentCycle;
				stData["claimMechanic"] = arrClaimMechanic;
				stData["glAccount"] = arrGlAccount;
				stData["bGreatestValue"] = JavaCast("boolean" ,qGetFixedComp.Greatest_Program_Value);
				if(qGetFixedComp.Program_Fixed_Component_Name_ID == nDefaultFixedComp){
					bDefaultComp = 1;
				}
				stData["bDefaultComp"] = JavaCast("boolean" ,bDefaultComp);
            	if(bDefaultComp == 1){
					ArrayPrepend(arrRet, duplicate(stData));
				}
				else{
					ArrayAppend(arrRet, duplicate(stData));
				}
			</cfscript>
		</cfloop>
		
		<!--- get active rebate component data --->
		<!---<cfset qGetRebateComp = createObject("component","components.programs.rebates.RebateComponent").getActive() />--->
		<!--- PROFILE RESTRICTION --->
		<cfquery name="qGetRebateCompProfileRestriction" datasource="#application.datasource#">
			SELECT	Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component_Profile PRCP
			WHERE
				PRCP.Profiles_ID = #request.accessStructure.PROFILES_ID# AND
				DELETED = 0
		</cfquery>
		<cfquery name="qGetRebateComp" dbtype="query">
			SELECT	Component_ID AS Program_Rebates_Component_Name_ID,
					Component_Name AS Program_Rebates_Component_Name
			FROM	qGetComps
			WHERE	Discount_Type_ID = 2
			AND		Component_Selected = 1
			<cfif qGetRebateCompProfileRestriction.recordcount>
				AND qGetComps.Component_ID NOT IN (#ValueList(qGetRebateCompProfileRestriction.Program_Rebates_Component_Name_ID)#)
			</cfif>
			ORDER BY Program_Rebates_Component_Name DESC
		</cfquery>
		
		<!--- loop over rebate component data and build array of structs--->
		<cfloop query="qGetRebateComp">
			<cfscript>
				arrGlAccount = ArrayNew(1);
				arrClaimMechanic = ArrayNew(1);
				arrGlAccount = getComponentGlAccount(2,qGetRebateComp.Program_Rebates_Component_Name_ID);
				arrClaimMechanic = getComponentClaimMechanicData(nProgramTypeID, 2, qGetRebateComp.Program_Rebates_Component_Name_ID);
				arrPaidTo 			= getComponentPaidToData(nProgramTypeID,2,qGetRebateComp.Program_Rebates_Component_Name_ID);
				bDefaultComp = 0;
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.ComponentDef";
				stData["componentId"] = qGetRebateComp.Program_Rebates_Component_Name_ID;
				stData["name"] = qGetRebateComp.Program_Rebates_Component_Name;
				stData["type"] = 2;
				stData["uom"] = arrUomTypeRebate;
				stData["paidTo"] = arrPaidTo;
				stData["paymentCycle"] = arrPaymentCycle;
				stData["claimMechanic"] = arrClaimMechanic;
				stData["glAccount"] = arrGlAccount;
				if(qGetRebateComp.Program_Rebates_Component_Name_ID == nDefaultRebateComp){
					bDefaultComp = 1;
				}
				stData["bDefaultComp"] = JavaCast("boolean" ,bDefaultComp);
				if(bDefaultComp == 1){
					ArrayPrepend(arrRet, duplicate(stData));
				}
				else{
					ArrayAppend(arrRet, duplicate(stData));
				}
            	
			</cfscript>
		</cfloop>
		<cfreturn arrRet />
	
	</cffunction>
	
	<cffunction name="getComponentUomData" output="false" returntype="array" hint="function to return uom data">
		
		<cfargument name="programId" 	type="Numeric" required="true" />
		<cfargument name="type" 		type="Numeric" required="true" />

		<cfscript>
			//set local variables
			var nProgramID		= "";
			var nType			= "";
			var arrUomRet		= ArrayNew(1);
			var qReturnUomData 	= "" ;
			var bDefault		= 0;
			
			//assign local variables
			nProgramID	= arguments.programId;
			nType 		= arguments.type;
		</cfscript>
		
		<!--- call existing cf_uom_dropdown custom tag --->
		<cf_uom_dropdown
			program_id				=	"#nProgramID#"
			option_text_abbreviated	=	"1"
			plural_uom_display		=	""
			product_type_id			=	"#nType#"
			program_template_id		=	""
			uom_id_exclusion_list	=	""
			uom_id_inclusion_list	=	""
			returnResults			= 	"1"
			returnResultsData		=	"qReturnUomData"
		/>
		
		<!--- loop over results and build an array of structs --->
		<cfloop query="qReturnUomData">
			<cfscript>
				bDefault = JavaCast("boolean",0 );
				if(qReturnUomData.Default_UOM == Unit_Of_Measure_ID){
					bDefault = JavaCast("boolean",1 );
				}
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
				stData["uomId"] = qReturnUomData.Unit_Of_Measure_ID;
				stData["description"] = qReturnUomData.Unit_Of_Measure_Desc;
				stData["abbreviation"] = qReturnUomData.ABBREVIATION_SINGULAR;
				stData["bDefault"] = bDefault;
            	ArrayAppend(arrUomRet, duplicate(stData));
			</cfscript>
		</cfloop>
		<!--- return the array --->
		<cfreturn arrUomRet />
		
	</cffunction>

	<cffunction name="getComponentPaidToData" output="false" returntype="array" hint="function to return paid to data">
	
		<cfargument name="programTypeId" type="Numeric" required="true" />
		<cfargument name="discountTypeID" type="numeric" required="true" />
		<cfargument name="componentNameID" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nProgramTypeID		= "";
			var arrPaidToRet		= ArrayNew(1);
			var qReturnPaidToData	= "";
			var a = arguments;
		
			//assign local variables
			nProgramTypeID		= arguments.programTypeId;
			qReturnPaidToData	= objTemplateManager.GetPaymentPaidToTypes(nProgramTypeID,a.discountTypeID,a.componentNameID);
		</cfscript>
		
		<!--- loop over results and build an array of structs --->
		<cfloop query="qReturnPaidToData">
			<cfscript>
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.PaidTo";
				stData["paidToId"] = qReturnPaidToData.Payment_Paid_To_ID;
				stData["description"] = qReturnPaidToData.Payment_Paid_To_Type_Name;
				if(qReturnPaidToData.Payment_Paid_To_ID == qReturnPaidToData.Default_Paid_To_Rates_Grid){
					stData["bDefault"] = Javacast("boolean",1);
				}
				else{
					stData["bDefault"] = Javacast("boolean",0);
				}
				
            	ArrayAppend(arrPaidToRet, duplicate(stData));
			</cfscript>
		</cfloop>
		<!--- return the array --->
		<cfreturn arrPaidToRet />
		
	</cffunction>

	<cffunction name="getComponentPaymentCycleData" output="false" returntype="array" hint="function to return payment cycle data">
	
		<cfargument name="programTypeId" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nProgramTypeID			= "";
			var objPaymentCycleManager	= "";
			var qReturnPaymentCycleData	= "";
			var bDef					= Javacast("boolean",0);
			var arrPaymentCycleRet		= ArrayNew(1);
		
			//assign local variables
			nProgramTypeID 			= arguments.programTypeId;
			objPaymentCycleManager 	= CreateObject("component", "components.programs.PaymentCycleManager").init();
			qReturnPaymentCycleData = objPaymentCycleManager.getPaymentCycles(nProgramTypeID);
		</cfscript>
		
		<!--- loop over results and build an array of structs --->
		<cfloop query="qReturnPaymentCycleData">
			<cfscript>
				if(qReturnPaymentCycleData.Payment_Cycle_ID == PayCycleDefaultOption){
					bDef = Javacast("boolean",1);
				}
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.PaymentCycle";
				stData["paymentCycleId"] = qReturnPaymentCycleData.Payment_Cycle_ID;
				stData["description"] = qReturnPaymentCycleData.Payment_Cycle;
				stData["bDefault"] = bDef;
            	ArrayAppend(arrPaymentCycleRet, duplicate(stData));
            	
            	bDef = Javacast("boolean",0);
			</cfscript>
		</cfloop>
		
		<!--- return the array --->
		<cfreturn arrPaymentCycleRet />
		
	</cffunction>
	
	<cffunction name="getComponentClaimMechanicData" output="false" returntype="array" hint="function to return claim mechanic data">
		
		<cfargument name="programTypeId" type="Numeric" required="true" />
		<cfargument name="componentType" type="Numeric" required="true" />
		<cfargument name="componentNameId" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nProgramTypeID		= "";
			var nComponentType		= "";
			var nComponentNameId	= "";
			var qReturnPaymentType	= "";
			var qGetPayeeType		= "";
			var arrPaymentTypeRet	= ArrayNew(1);
		
			//assign local variables
			nProgramTypeID 		= arguments.programTypeId;
			nComponentType		= arguments.componentType;
			nComponentNameId	= arguments.componentNameId;
			qReturnAllPaymentType 	= CreateObject("component", "components.programs.payment_type.paymenttype").getActive();
		</cfscript>
		
			<cfquery name="qReturnPaymentType" datasource="#application.datasource#">
				SELECT PT.Payment_Type_ID,
						PT.Payment_Type_Name,
						PT.Billback_Closing_Method_ID,
						CASE WHEN PCPO.ClaimMechDefaultOption = PTM.Payment_Type_ID
						 THEN
							1
						 ELSE
							0
						 END AS SortCol
				FROM 	Payment_Template_Mapping PTM
				INNER JOIN Payment_Type PT ON 
					PT.Payment_Type_ID = PTM.Payment_Type_ID AND
					PT.Deleted = 0
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.ProgramControl_Panel_Options_ID = PTM.Template_ID
					<cfif nComponentType eq 1>
						INNER JOIN Program_Fixed_Component_Name ON
						Program_Fixed_Component_Name.Off_Invoice_On = PT.Off_Invoice AND
						Program_Fixed_Component_Name_ID = '#nComponentNameId#'
					<cfelseif nComponentType eq 2>
						INNER JOIN Program_Rebates_Component_Name ON 
						Program_Rebates_Component_Name.Off_Invoice_On = PT.Off_Invoice AND
						Program_Rebates_Component_Name_ID = '#nComponentNameId#'
					</cfif>
				WHERE 	PTM.Template_ID = <cfqueryparam value="#nProgramTypeID#" cfsqltype="cf_sql_integer" />
				AND		PTM.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
				AND 	PT.Deleted = 0 AND PT.Active = 1
				ORDER BY SortCol DESC,PT.Payment_Type_Name ASC
			</cfquery>
		
			<cfif qReturnPaymentType.RecordCount>
			<!--- loop over results and build an array of structs --->
			<cfloop query="qReturnPaymentType">
				
				<cfquery name="qGetPayeeType" datasource="#application.datasource#">
			 		SELECT 	Payee_Type
			 		FROM 	Billback_Closing_Methods
			 		WHERE 	iBillback_Closing_Method_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qReturnPaymentType.Billback_Closing_Method_ID#" />
			 		AND		Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
				</cfquery>
				
				<cfscript>
					stData = structNew();
					stData["__type__"] = "mvc.Models.Program.Component.vos.ClaimMechanic";
					stData["claimMechanicId"] = qReturnPaymentType.Payment_Type_ID;
					stData["description"] = qReturnPaymentType.Payment_Type_Name;
					stData["payeeTypeId"] = qGetPayeeType.Payee_Type;
	            	ArrayAppend(arrPaymentTypeRet, duplicate(stData));
				</cfscript>
			</cfloop>
		</cfif>
		<cfreturn arrPaymentTypeRet />
		
	</cffunction>
	
	<cffunction name="getComponentGlAccount" output="false" returntype="array" hint="function to return gl Account data">
		
		<cfargument name="type" 		type="Numeric" required="true" />
		<cfargument name="componentId" 	type="Numeric" required="true" />
		<cfargument name="programId" 	type="Numeric" required="false" default = 0 />
		
		<cfscript>
			//set local variables
			var nType			= "";
			var nComponentId	= "";
			var qGetGlAccount	= "";
			var arrGlAccountRet	= ArrayNew(1);
		
			//assign local variables
			nType 			= arguments.type;
			nComponentId	= arguments.componentId;
		</cfscript>
		<!---<cfif  arguments.programId neq 0>--->
			<cfquery name="qGetDates" datasource="#application.datasource#">
				SELECT	ISNULL(MIN([Start_Date]),'2000-01-01 00:00:00.000') AS StartDate, 
					ISNULL(MAX(End_Date),'2070-01-01 00:00:00.000')  AS EndDate,
					ISNULL(CM.Fiscal_Year,'') AS FY
				FROM Fiscal_Year FY
				INNER JOIN Contract_Main CM ON
					CM.Fiscal_Year = FY.Fiscal_Year
				WHERE CM.Contract_Main_Id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
					AND CM.Fiscal_Year IS NOT NULL
				GROUP BY CM.Fiscal_Year
			</cfquery>
		<!---</cfif>--->
		<cfquery name="qGetGlAccount" datasource="#application.datasource#">
			SELECT	GL_Account.GL_Account_ID AS glAccountId,
					GL_Account.GL_Account AS description
			FROM	GL_Account
			INNER JOIN GL_Component_Mapping ON
				GL_Component_Mapping.Gl_Account_ID = GL_Account.GL_Account_ID
			
			WHERE	GL_Account.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		GL_Account.Is_Active = <cfqueryparam cfsqltype="cf_sql_bit" value="1">
			AND		GL_Component_Mapping.Discount_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nType#" />
			AND		GL_Component_Mapping.Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#nComponentId#" />
			<cfif  arguments.programId neq 0 and qGetDates.RecordCount gt 0>
				AND GL_Account.Start_Date <= '#qGetDates.StartDate#' AND
				GL_Account.End_Date >= '#qGetDates.EndDate#'
			</cfif>
		</cfquery>
		
		<!--- loop over results and build an array of structs --->
		<cfloop query="qGetGlAccount">
			<cfscript>
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.GlAccount";
				stData["glAccountId"] =  qGetGlAccount.glAccountId;
				stData["description"] =  qGetGlAccount.description;
            	ArrayAppend(arrGlAccountRet, duplicate(stData));
			</cfscript>
		</cfloop>
	
		<cfreturn arrGlAccountRet />
		
	</cffunction>

</cfcomponent>