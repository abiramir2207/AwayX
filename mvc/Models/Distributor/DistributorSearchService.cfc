

<cfcomponent name="DistributorSearchService" displayname="DistributorSearchService" hint="Search Distributors" extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />
	
	<cffunction name="getDistributors" hint="return all distributors" access="remote" output="false" returntype="Array">
		<cfargument name="ProgramId" default="0">
		<cfargument name="mode" default="Search">
		<cfset var businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfset var qGetDistributors =  queryNew('tmp') />
		<cfset var arrRet = ArrayNew(1)>
		<cfset var i = 0/>
		<cfset var s = ''/>
		<cfset var sJoin = ''/>
		<cfset var l = ''/>
		<cfset var lGroup = ''/>
		<cfset var busSegIdForProgram = 0 />
		<cfset this.dmp(arguments)/>
		<cfif ProgramId NEQ 0>
			<cfif businessSegManager.isEnabled()>
				<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(arguments.programId) />
			</cfif>
			<cfquery name="GetSettings" datasource="#application.datasource#">
				SELECT PCPO.Discount_Rebates_Group_Level,
						PCPO.Group_Deal,
						exclude_sig_products,
						modifying_program,
						EZButton_On,
						EZ_Contract_Id,
						First_Parent_Id,
						Contract_Main.Template_Filters_Id
				FROM Contract_Main
				INNER JOIN	Program_Control_Panel_Options PCPO ON 
					Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfscript>
				FirstParentId = GetSettings.First_Parent_Id;
				varTemplateFiltersID = GetSettings.Template_Filters_Id;
				//var objAttr = CreateObject("component","components.customer.Group.DistributorGroupAttributeManager");
				var objData = CreateObject("component", "components.customer.Group.DataManager").init();
				
				var q = objData.getDistributorLevels(bActive = 1, 
												allowList = "", 
												disAllowList = "",
												Template_ID = FirstParentId,
												allowInSearch = 1,
												allowInGroupSearch = 0);
				//this.dmp(q);
				
				//TODO: LOOP Groups and create Dynamica sql
				//populate arrCustAttr and send to ui.
			</cfscript>
			<cfloop query="q">
				<cfscript>
					sGroupJoin = '';
					if(q.is_PG == 0 AND q.ALLOW_IN_SEARCH EQ 1){
					 s = " #s# rTrim(lTrim(isNull(#q.Distributor_Group_Attribute_Table#.#q.Distributor_Group_Attribute_Name_Field#,''))) AS #q.Distributor_Group_Attribute_Name_Field#,";
					
					 sJoin = ' #sJoin# LEFT JOIN #q.Distributor_Group_Attribute_Table# ON 
					 			#q.Distributor_Group_Attribute_Table#.#q.DISTRIBUTOR_GROUP_ATTRIBUTE_MASTER_ID_FIELD# =  BFC.#q.DISTRIBUTOR_GROUP_ATTRIBUTE_MASTER_ID_FIELD# AND
					 			BFC.#q.DISTRIBUTOR_GROUP_ATTRIBUTE_MASTER_ID_FIELD# IS NOT NULL ';
					  
					 l= listappend(l,q.Distributor_Group_Attribute_Name_Field);
					 lGroup= listappend(lGroup,q.Distributor_Group_Level_ID);	 
					}
				</cfscript>
			</cfloop>
			<cfset arrFields = listToArray(l) />
		</cfif>
				<CFQUERY NAME="qGetDistributors" datasource="#application.datasource#">
					<!--- <cfloop from="1" to="#lCount#" index="i"> --->
					 SELECT
					isnull(rtrim(ltrim(BFC.Ship_To)),'')	AS baItem,	 <!--- +  '#i#' --->
					BFC.BSA_Foodservice_Customers_ID				AS distGuid,
		  			isnull(rtrim(ltrim(BFC.Name)),'') 				AS Description,
		  				isnull(rtrim(ltrim(BFC.Address_1)),'') 	+ ', ' + 
		  				isnull(rtrim(ltrim(BFC.City)),'') 		+ ' ' + 
		  				isnull(rtrim(ltrim(BFC.State)),'')  	+ ' ' + 
		  				isnull(rtrim(ltrim(BFC.ZipCode)),'')   	+ ' ' + 
		  				isnull(rtrim(ltrim(BFC.country_code)),'') 
		  															AS Address,
		  			<cfif Mode EQ 'Search'>
			  			isnull(rtrim(ltrim(DF.Family_Name)),'')  		AS col1,
			  			isnull(rtrim(ltrim(DBG.Buying_Group_Name)),'') 	AS col2,
			  			isnull(rtrim(ltrim(SR.Region_Name)),'') 		AS col3,
			  			isnull(rtrim(ltrim(BFB.Broker_Name)),'') 		AS col4,
			  			isnull(rtrim(ltrim(BFC.country_code)),'') 		AS col5,
			  			isnull(rtrim(ltrim(BFC.State)),'') 				AS col6,
			  			isnull(rtrim(ltrim(BFC.City)),'')   				AS col7, 
			  			isnull(rtrim(ltrim(replace(SZ.Zone_Name,'/','-'))),'') AS col8,	
			 		<cfelse>
			 		 	<cfoutput>#s#</cfoutput>
					</cfif>
			 		 
			 	<!---	CASE 
			 			WHEN CD.Contract_Distributors_ID > 0 THEN
			 			 	0 
			 			ELSE
			 			 	0
			 			END--->
			 			0 AS isSelected
			FROM		BSA_Foodservice_Customers BFC
						<!---LEFT JOIN Contract_Distributors CD
							ON CD.BSA_Foodservice_Customers_ID = BFC.BSA_Foodservice_Customers_ID
							AND CD.Contract_Main_ID = '#arguments.programId#'
							AND CD.Deleted = 0--->
						
					<cfif Mode EQ 'Search'>
						INNER JOIN	Distributor_Family DF
							ON BFC.Family_ID = DF.Family_ID
						INNER JOIN	Distributor_Buying_Groups DBG
							ON BFC.Buying_Group_ID = DBG.Buying_Group_ID
						INNER JOIN	Line_Of_Business LOB
							ON BFC.Line_Of_Business_ID = LOB.Line_Of_Business_ID
						LEFT JOIN	BSA_Foodservice_Brokers BFB
							ON BFC.BSA_Foodservice_Brokers_ID = BFB.BSA_Foodservice_Brokers_ID
						LEFT JOIN Service_Markets SM
							ON SM.Service_Market_ID = BFB.Service_Market_ID
						LEFT JOIN	Service_Regions SR
							ON BFB.Service_Region_ID = SR.Service_Region_ID
						LEFT JOIN	Service_Zones SZ
							ON SR.Service_Zone_ID = SZ.Service_Zone_ID
						LEFT OUTER JOIN Distributor_Group_Distributor DGD
							ON BFC.BSA_Foodservice_Customers_ID = DGD.Distributor_ID
							AND DGD.Deleted = 0
						<!---LEFT JOIN Warehouse_Master WM
						ON WM.Warehouse_Master_ID =
						CASE
							WHEN CD.Warehouse_Master_ID IN ('',0)
							OR CD.Warehouse_Master_ID IS NULL THEN
							BFC.Warehouse_Master_ID
							ELSE
							CD.Warehouse_Master_ID
						END	--->
					<cfelse>
						 <cfoutput>#sJoin#</cfoutput>
					</cfif>
			WHERE
						BFC.deleted = 0
						AND BFC.Active_Code = 'A'
						<cfif busSegIdForProgram neq 0 and busSegIdForProgram neq "" and mode EQ 'Search'>
						 	AND BFC.Business_Segment_ID = #busSegIdForProgram#
						<cfelseif mode EQ 'Rates'>
							AND CD.Contract_Main_ID IS NOT NULL
						</cfif>
		
				  </CFQUERY>
			  <!--- <cfdump var='#qGetDistributors#' output="c:\dump.log" /> --->
				<!--- <cfloop query="qGetDistributors">--->
				 <cfloop index="i" from="1" to="#qGetDistributors.recordcount#">
					<cfscript>
						stData = structNew();
						
						if(mode == 'Search'){
							stData["__type__"] = "mvc.Models.Distributor.vos.GridData";
							stData["baItem"] = qGetDistributors.baItem[i];
							stData["distGuid"] = qGetDistributors.distGuid[i];
							stData["Description"] = qGetDistributors.Description[i];
							stData["Address"] = qGetDistributors.Address[i];
							stData["col1"] = qGetDistributors.col1[i];
							stData["col2"] = qGetDistributors.col2[i];
							stData["col3"] = qGetDistributors.col3[i];
							stData["col4"] = qGetDistributors.col4[i];
							stData["col5"] = qGetDistributors.col5[i];
							stData["col6"] = qGetDistributors.col6[i];
							stData["col7"] = qGetDistributors.col7[i];
							stData["col8"] = qGetDistributors.col8[i];
							stData["isSelected"] = qGetDistributors.isSelected[i];
						}
						else{
							stData["__type__"] = "mvc.Models.Program.Component.vos.Payee";
							stData["distGuid"] = qGetDistributors.distGuid[i];
							stData["payeeId"] = qGetDistributors.baItem[i];
							stData["name"] = qGetDistributors.Description[i];
							stData["address"] = qGetDistributors.Address[i];
							for (n=1;n LTE ArrayLen(arrFields);n=n+1) {
        						stData["#arrFields[n]#"] = qGetDistributors["#arrFields[n]#"][i];
							}
						}
						ArrayAppend(arrRet, duplicate(stData));
					</cfscript>
				</cfloop>
			<cfreturn arrRet />

	</cffunction>
	
	<cffunction name="getCustomerAttrsInTemplate" output="false" returntype="Array" >
		<cfargument name="argFirstParentID" required="true" default="0" type="numeric" />
		<cfargument name="bGroupDeal" required="true" default="0" type="boolean" />
		
		<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
		<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(
											bActive = 1, 
											allowList = "", 
											disAllowList = "",
											Template_ID = "#argFirstParentID#",
											allowInSearch = 1,
											allowInGroupSearch = 0
											) />
		<cfset qGetDistributorLevelsGroupTemplate = DistGroupDataManager.getDistributorLevelsGroupTemplate(templateID=argFirstParentID) />
		<cfscript>
			var arrCustAttr = arrayNew(1);
			var obj = CreateObject("component","components.customer.Group.DistributorGroupAttributeManager");
			
			//qAttrsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = argFirstParentID, TemplateFiltersID = 0);
			
				/*</cfscript>
				
					<cfdump var = "#qAttrsInTemplate#" output="c:\dump.log" />
				<cfscript>*/
			
			for (idxRow = 1; idxRow LTE qAttrsInTemplate.RecordCount; idxRow = (idxRow + 1))
			{
				if(qAttrsInTemplate["PG_Flag"][idxRow] == 0  && ((qAttrsInTemplate["ALLOW_IN_GROUP_SEARCH"][idxRow] == 1 && bGroupDeal == 1) || (qAttrsInTemplate["ALLOW_IN_SEARCH"][idxRow] == 1 && bGroupDeal == 0))  ){
					stPrdAttr["__type__"] = "mvc.Models.Distributor.vos.CustomerAttr";
					stPrdAttr["active"] = qAttrsInTemplate["ACTIVE"][idxRow];
					stPrdAttr["allowFilter"] = qAttrsInTemplate["ALLOW_FILTER"][idxRow];
					stPrdAttr["allowInGroupSearch"] = qAttrsInTemplate["ALLOW_IN_GROUP_SEARCH"][idxRow];
					stPrdAttr["allowInSearch"] = qAttrsInTemplate["ALLOW_IN_SEARCH"][idxRow];
					stPrdAttr["createdDate"] = qAttrsInTemplate["CREATED_DATE"][idxRow];
					stPrdAttr["groupLevelId"] = qAttrsInTemplate["GROUP_LEVEL_ID"][idxRow];
					stPrdAttr["groupLevelDesc"] = qAttrsInTemplate["Group_Level_Desc"][idxRow];
					stPrdAttr["listOrder"] = qAttrsInTemplate["LIST_ORDER"][idxRow];
					stPrdAttr["pgFlag"] = qAttrsInTemplate["PG_Flag"][idxRow];
					stPrdAttr["pgGroupType"] = qAttrsInTemplate["PG_GROUP_TYPE"][idxRow];
					stPrdAttr["productGroupAttributeId"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_ID"][idxRow];
					stPrdAttr["productGroupAttributeIdField"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_ID_FIELD"][idxRow];
					stPrdAttr["productGroupAttributeInterfaceField"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_INTERFACE_FIELD"][idxRow];
					stPrdAttr["productGroupAttributeMasterIdField"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD"][idxRow];
					stPrdAttr["productGroupAttributeNameField"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD"][idxRow];
					stPrdAttr["productGroupAttributeNumberField"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_NUMBER_FIELD"][idxRow];
					stPrdAttr["productGroupAttributeSearchSequenceField"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_SEARCH_SEQUENCE_FIELD"][idxRow];
					stPrdAttr["productGroupAttributeTable"] = qAttrsInTemplate["PRODUCT_GROUP_ATTRIBUTE_TABLE"][idxRow];
					stPrdAttr["ProductGroupLevelId"] = qAttrsInTemplate["PRODUCT_GROUP_LEVEL_ID"][idxRow];
					stPrdAttr["searchDp"] = ArrayNew('1');
					ArrayAppend(arrCustAttr, duplicate(stPrdAttr));
				}
			}
			
			return arrCustAttr;
		</cfscript>
		
	</cffunction>

	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">
		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>
		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.models.SettingsService") />
		<cfset objTemplate = createobject("component", "components.programs.template.TemplateManager") />
		<cfset stSettings.user = StructNew()/>
		<cfset stSettings.user = obj.getUserObject(arguments.userId) />
		
		<!--- return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<cfset stSettings.appSettings = StructNew()/>
		<!--- <cfset stSettings.appSettings = obj.getAppSettingsObject() /> --->
		<cfset structinsert(stSettings.appSettings,"Exact_List_Matching_On",appSettings.Exact_List_Matching_On)>
		<!--- appsettings: variables returned are specific to calling swf --->
		<cfset stSettings.appFlex = StructNew()/>
		<cfset stSettings.appFlex.col1 = application.returned_customer_setting.family_name_label_singular /><!--- Family --->
		<cfset stSettings.appFlex.col2 = application.returned_customer_setting.buying_group_label_singular /> <!--- Buying Group --->
		<cfset stSettings.appFlex.col3 = application.returned_customer_setting.region_label_singular /> <!--- ZONE --->
		<cfset stSettings.appFlex.col4 = "Broker"/><!--- Broker --->
		<cfset stSettings.appFlex.col5 = "Country"/><!--- Country --->
		<cfset stSettings.appFlex.col6 = "State"/><!--- State --->
		<cfset stSettings.appFlex.distLabel = application.returned_customer_setting.Distributor_Label_Singular /> <!--- Distributor Label --->
		<cfif arguments.programId NEQ 0>
			<cfset stSettings.appFlex.oneDistSelection = objTemplate.getProgramTemplate(arguments.programId).one_distributor />
		<cfelse>
			<cfset stSettings.appFlex.oneDistSelection = 0 />
		</cfif>
		<!--- Select one or Many (check box or radioBtn) --->
		<cfset stsettings.UIAttributes = obj.getUIAttributes()>
		<cfreturn stSettings>
	</cffunction>
	
</cfcomponent>
