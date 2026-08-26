

<cfcomponent name="OperatorSearchService" displayname="OperatorSearchService" hint="Search Operators">
	<cfset appSettings = application.appSettingsGet />
	
	
	<!-- Function to split the search string into individual terms and query operator using full text  -->
	<cffunction name="getOperatorsFT" access="remote" returntype="query" output="true" hint="Full text query">

		<cfargument name="programID"			default="0">
		<cfargument name="businessSegmentsOn"	default="0">
		<cfargument name="businessSegmentID"	default="0">
		
		<cfargument name="state"				default="">
		<cfargument name="operatorType"			default="">
		<cfargument name="status"				default="">
		<cfargument name="searchFieldText"		default="">

		<cfscript>
			var searchTerm = "";
			var searchString = "";
			var var_operatorType = "";
			var var_qGetOperators = queryNew('tmp');
			
			
			if (len(arguments.searchFieldText) GT 0){
				// remove all non-alphanumeric characters from string
				searchString = trim(reReplace(arguments.searchFieldText,'[^a-zA-Z0-9\,_]',' ','ALL')); // replace with spaces
				
				if(len(searchString) GT 0){
					// If criteria is not blank then break apart the words and create a new list with qualifiers for full text search
					
					searchString = reReplace(searchString, '(\s)+',',','ALL');		// replace multiple spaces with comma
					searchString = reReplace(searchString, '(\,)+\1','\1','ALL');	// replace multiple commas with a single comma
				
					searchString = listQualify(searchString,'*',','); 	// Add wildcard for each term 
					searchString = listQualify(searchString,'"',',');	// Add quotes around the wilcard search term E.g: '"*Subway*"'
				}
			}
		</cfscript>

		<!--- Query time --->
		<cfquery name="var_qGetOperators" datasource="#application.datasource#">
			Select	-- Top 1000
					LTRIM(RTRIM(BO.BSA_Operator_ID)) 										as BSA_Operator_ID, 
					isnull(nullif(LTRIM(RTRIM(BO.Legacy_ID)),''), LTRIM(RTRIM(BO.BSA_Operator_ID)))	as Legacy_ID, 
					LTRIM(RTRIM(BO.Operator_Name)) 											as Operator_Name, 
					LTRIM(RTRIM(BO.Operator_City)) 											as Operator_City, 
					LTRIM(RTRIM(BO.Operator_State)) 										as Operator_State, 
					LTRIM(RTRIM(BO.Operator_Zip)) 											as Operator_Zip,
					LTRIM(RTRIM(BO.Operator_Type)) 											as Operator_Type, 
					CAST(LTRIM(RTRIM(BO.Business_Segment_ID)) as nvarchar(10)) 				as Business_Segment_ID,
					CASE LTRIM(RTRIM(BO.Display_Code))
						WHEN 'A' THEN 'Active'
						ELSE 'Inactive'
					END																		as Display_Code,
					CASE 	
						WHEN CO.BSA_Operator_ID is null THEN 0
						ELSE 1	
					END																		as isSelected
			From	BSA_Operator BO
			
			<!--- Full Text part for searchTerm --->
			<cfif len(searchString) GT 0>
			<!--- Search on BSA_Operator_ID --->
			   <cfif appSettings.getShowBSAOperators()>
				<cfloop index="i" from="1" to="#listLen(searchString)#" >
					<cfset searchTerm = listGetAt(searchString,#i#) />
					INNER JOIN CONTAINSTABLE (BSA_Operator, (BSA_Operator_ID_Text,Display_Code,Operator_City,Operator_Type,Operator_Name,Operator_State,Operator_Zip), <cfqueryparam value="#searchTerm#" cfsqltype="cf_sql_varchar" />) KEY_TBL_#i#
					ON 	KEY_TBL_#i#.[KEY] = BO.BSA_Operator_ID			
				</cfloop>
			  <cfelse>
			<!--- Search on Legacy_ID --->
				<cfloop index="i" from="1" to="#listLen(searchString)#" >
					<cfset searchTerm = listGetAt(searchString,#i#) />
					INNER JOIN CONTAINSTABLE (BSA_Operator, (Legacy_ID,Display_Code,Operator_City,Operator_Type,Operator_Name,Operator_State,Operator_Zip), <cfqueryparam value="#searchTerm#" cfsqltype="cf_sql_varchar" />) KEY_TBL_#i#
					ON 	KEY_TBL_#i#.[KEY] = BO.BSA_Operator_ID			
				</cfloop>
			  </cfif>
			</cfif>
			
			<!--- state --->
			<cfif len(#arguments.state#) GT 0>
					INNER JOIN CONTAINSTABLE (BSA_Operator, Operator_State, <cfqueryparam value="#arguments.state#" cfsqltype="cf_sql_varchar" />) KEY_TBL_Operator_State
					ON 	KEY_TBL_Operator_State.[KEY] = BO.BSA_Operator_ID
			</cfif>
			
			<!--- operatorType --->
			<cfif len(#arguments.operatorType#) GT 0>
					<cfset var_operatorType = ListFirst(#arguments.operatorType#," ") />
					INNER JOIN CONTAINSTABLE (BSA_Operator, Operator_Type, <cfqueryparam value="#var_operatorType#" cfsqltype="cf_sql_varchar" />) KEY_TBL_Operator_Type
					ON 	KEY_TBL_Operator_Type.[KEY] = BO.BSA_Operator_ID
			</cfif>
						
			Left Join 	Contract_Operators CO
			On		CO.Contract_Main_ID = <cfqueryparam value="#arguments.programID#" cfsqltype="cf_sql_integer" list="true" />
			And		CO.BSA_Operator_ID = BO.BSA_Operator_ID
			And		CO.Deleted = 0
			
			Where	BO.Deleted = 0
			And		BO.Display_Code = 'A'
			And		LEN(LTRIM(RTRIM(BO.Operator_Name)))		> 0
			And		LEN(LTRIM(RTRIM(BO.Operator_City))) 	> 0
			And		LEN(LTRIM(RTRIM(BO.Operator_State)))	> 0
			And		LEN(LTRIM(RTRIM(BO.Operator_Zip)))		> 0

			<!--- status --->
			<cfif len(#arguments.status#) GT 0>
				<!--- active/inactive --->
				<cfif arguments.status EQ "Active">
						And		LTRIM(RTRIM(BO.Display_Code)) like <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
				<cfelse>
						And		LTRIM(RTRIM(BO.Display_Code)) not like <cfqueryparam value="A" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfif>

			<!--- Business Segment used for Conagra and may be AE --->
			<cfif application.returned_customer_setting.customer_keyword EQ "conagra" AND arguments.businessSegmentsOn eq 1 AND arguments.businessSegmentID neq 0>
				And BO.Business_Segment_ID = <cfqueryparam value="#arguments.businessSegmentID#" cfsqltype="cf_sql_integer" />
			</cfif>
							
			ORDER BY BO.Operator_Name, BO.Operator_State
		</cfquery>
		
		<cfreturn var_qGetOperators /> 
			
	</cffunction>
	
	
	<!-- Function to get the saved list operators using the OR operator -->
	<cffunction name="getSavedOperators" access="remote" returntype="query" output="true" hint="Full text query">

		<cfargument name="programID"			default="0">
		<cfargument name="businessSegmentsOn"	default="0">
		<cfargument name="businessSegmentID"	default="0">
		<cfargument name="savedOperators"		default="">

		<cfscript>
			var searchString = "";
			var var_qGetOperators = queryNew('tmp');
			
			if (len(arguments.savedOperators) GT 0){
				searchString = listQualify(arguments.savedOperators,'"');	//  To turn (156558,163150) into ("156558","163150") 
				searchString = replace(searchString, ',', ' OR ', 'ALL');	//	To turn ("156558","163150") into ("156558" OR "163150")
			}
		</cfscript>
		
		<!--- Query time --->
		<cfquery name="var_qGetOperators" datasource="#application.datasource#">
			Select	
					LTRIM(RTRIM(BO.BSA_Operator_ID)) 										as BSA_Operator_ID, 
					isnull(LTRIM(RTRIM(BO.Legacy_ID)), LTRIM(RTRIM(BO.BSA_Operator_ID)))	as Legacy_ID, 
					LTRIM(RTRIM(BO.Operator_Name)) 											as Operator_Name, 
					LTRIM(RTRIM(BO.Operator_City)) 											as Operator_City, 
					LTRIM(RTRIM(BO.Operator_State)) 										as Operator_State, 
					LTRIM(RTRIM(BO.Operator_Zip)) 											as Operator_Zip,
					LTRIM(RTRIM(BO.Operator_Type)) 											as Operator_Type, 
					CAST(LTRIM(RTRIM(BO.Business_Segment_ID)) as nvarchar(10)) 				as Business_Segment_ID,
					CASE LTRIM(RTRIM(BO.Display_Code))
						WHEN 'A' THEN 'Active'
						ELSE 'Inactive'
					END																		as Display_Code,
					CASE 	
						WHEN CO.BSA_Operator_ID is null THEN 0
						ELSE 1	
					END																		as isSelected

			From	BSA_Operator BO
			
			<!--- Full Text part for Operators_ID's --->
			<cfif len(searchString) GT 0>
					INNER JOIN CONTAINSTABLE (BSA_Operator, BSA_Operator_ID_Text, <cfqueryparam value="#searchString#" cfsqltype="cf_sql_varchar" />) KEY_TBL_Operator
					ON 	KEY_TBL_Operator.[KEY] = BO.BSA_Operator_ID			
			</cfif>
						
			Left Join 	Contract_Operators CO
			On		CO.Contract_Main_ID = <cfqueryparam value="#arguments.programID#" cfsqltype="cf_sql_integer" list="true" />
			And		CO.BSA_Operator_ID = BO.BSA_Operator_ID
			And		CO.Deleted = 0
			
			Where	BO.Deleted = 0
			And		BO.Display_Code = 'A'
			And		LEN(LTRIM(RTRIM(BO.Operator_Name)))		> 0
			And		LEN(LTRIM(RTRIM(BO.Operator_City))) 	> 0
			And		LEN(LTRIM(RTRIM(BO.Operator_State)))	> 0
			And		LEN(LTRIM(RTRIM(BO.Operator_Zip)))		> 0

			<!--- Business Segment used for Conagra and may be AE --->
			<cfif application.returned_customer_setting.customer_keyword EQ "conagra" AND arguments.businessSegmentsOn eq 1 AND arguments.businessSegmentID neq 0>
				And BO.Business_Segment_ID = <cfqueryparam value="#arguments.businessSegmentID#" cfsqltype="cf_sql_integer" />
			</cfif>
			
			<!--- AppSetting whether to show operators who dont have Legacy_ID --->
			<cfif not appSettings.getShowBSAOperators()>
				AND (BO.Legacy_ID IS NOT NULL OR LEN(LTRIM(RTRIM(BO.Legacy_ID))) != 0)
			</cfif>
							
			ORDER BY BO.Operator_Name, BO.Operator_State
		</cfquery>
		
		<cfreturn var_qGetOperators /> 
			
	</cffunction>
		
	
	<!-- Query to get all the States -->
	<cffunction name="getAllStates" access="remote" returntype="Query" hint="returns all the states used in drop down filter">
		<!-- scoped variable to hold the query -->
		<cfset var var_qAllStates = queryNew('tmp') />
		
		<!-- If the states are not already in memory  -->
		<cfif NOT isDefined("session.qAllStates")>
			<cfquery name="var_qAllStates" datasource="#application.datasource#" >
				Select 	Distinct LTRIM(RTRIM(Operator_State))	as Operator_State 
				From	BSA_Operator
				Where	Deleted = 0
				And		LEN(LTRIM(RTRIM(Operator_State))) > 0
				Order By Operator_State 
			</cfquery>
			<!--- <cfset session.qAllStates = SerializeJSON(var_qAllStates) />  --->
			<cfset session.qAllStates = var_qAllStates /> 
		</cfif>
		
		<cfreturn session.qAllStates />
		
	</cffunction>

	
	<!-- Query to get all the Operator Types -->		
	<cffunction name="getAllOperatorTypes" access="remote" returntype="Query" hint="returns all the Operator Types used in drop down filter">
		<!-- scoped variable to hold the query -->
		<cfset var var_qAllOperatorTypes = queryNew('tmp') />
		
		<!-- If the states are not already in memory  -->
		<cfif NOT isDefined("session.qAllOperatorTypes")>
			<cfquery name="var_qAllOperatorTypes" datasource="#application.datasource#" >
				Select 	Distinct LTRIM(RTRIM(Operator_Type))	as Operator_Type
				From	BSA_Operator
				Where	Deleted = 0
				And		LEN(LTRIM(RTRIM(Operator_Type))) > 0
				Order By Operator_Type 
			</cfquery>
			<cfset session.qAllOperatorTypes = var_qAllOperatorTypes />
		</cfif>

		<cfreturn session.qAllOperatorTypes />
		
	</cffunction>

	
	<!-- Query to get all the Status -->		
	<cffunction name="getAllStatus" access="remote" returntype="Query" hint="returns all the statuses used in drop down filter">
		<!-- scoped variable to hold the query -->
		<cfset var var_qAllStatus = queryNew('tmp') />
		
		<!-- If the states are not already in memory  -->
		<cfif NOT isDefined("session.qAllStatus")>
			<cfquery name="var_qAllStatus" datasource="#application.datasource#" >
				Select 	Distinct 
						CASE LTRIM(RTRIM(Display_Code))
							WHEN 'A' THEN 'Active'
							ELSE 'Inactive'
						END	as Display_Code
				From	BSA_Operator
				Where	Deleted = 0
				And		LEN(LTRIM(RTRIM(Display_Code))) > 0
				Order By Display_Code 
			</cfquery>
			<cfset session.qAllStatus = var_qAllStatus /> 
		</cfif>

		<cfreturn session.qAllStatus />
		
	</cffunction>
	
	
	<!-- function to return all the user and application settings and also labels for column names -->
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		
		<cfset var stSettings = StructNew()/>
		<cfset obj = createobject("component", "mvc.models.SettingsService") />
				
		<!--- profile and user settings [empty for now] --> we may want to write and all use a common function for profile data --->
		<cfset stSettings.user 						= StructNew() />
		<cfset stSettings.user 						= obj.getUserObject(arguments.userId) />
		
		<!--- return application.appSettingsGet as a structure with keys namedd the same as the appsettings methods --->
		<cfset stSettings.appSettings 				= StructNew() />
		<!--- We dont require this --->
		<!---<cfset stSettings.appSettings 				= obj.getAppSettingsObject() />--->
		<!--- Column Headers & Labels --->
		<cfset stSettings.appFlex 					= StructNew() />
		<cfset stsettings.appFlex 					= obj.getUIAttributes()>													<!--- UI Attribute Properties --->
		<cfset stSettings.appFlex.operatorID		= application.returned_customer_setting.operator_label_singular & " ID" />	<!--- Operator ID --->
		<cfset stSettings.appFlex.operatorSingular	= application.returned_customer_setting.operator_label_singular />			<!--- Operator Label Singular --->
		<cfset stSettings.appFlex.operatorPlural	= application.returned_customer_setting.operator_label_plural /> 			<!--- Operator Label Plural --->

		<cfset stSettings.appFlex.city 				= "City" /> 																<!--- City --->
		<cfset stSettings.appFlex.state 			= "State" /> 																<!--- State --->
		<cfset stSettings.appFlex.operatorType 		= "Operator Type" />														<!--- Operator Type --->
		<cfset stSettings.appFlex.status 			= "Status" />																<!--- Status --->	
		<cfset stSettings.appFlex.legacyID 			= application.returned_customer_setting.Operator_Legacy_Id_label />			<!--- Legacy ID --->	
		
		<!--- App Setting --->
		<cfset stsettings.appflex.cfapp_showBSAOperators           = appSettings.ShowBSAOperators />

		<cfreturn stSettings />
		
	</cffunction>
	
</cfcomponent>
