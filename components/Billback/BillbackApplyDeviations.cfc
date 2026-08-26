<cfcomponent output="false">

	<!--- Summary information for all active deviations --->
	<cffunction name="GetDeviationSums" output="false" returntype="query">
		<cfquery name="qGetDeviationSums" datasource="#application.datasource#">
		SELECT  SUM(Adjustment_Amount) AS TotalDeviationAmount,
				Count(BB_Adjustment_ID) AS NumberofDeviations
		FROM 	BB_Adjustment
		INNER JOIN 	Billback
		ON		Billback.Billback_ID = BB_Adjustment.Billback_ID
		AND		Billback.Deleted = 0
		INNER JOIN 	BSA_Foodservice_Customers
		ON		cast(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID as nvarchar(100)) = BB_Adjustment.Payee_ID
		WHERE 	BB_Adjustment.Applied = 0
		AND		BB_Adjustment.Deleted = 0
		AND 	BB_Adjustment.Recalculate = 0
		AND 	BB_Adjustment.Hidden = 0		
		AND		BB_Adjustment.Billback_Payee_Type_ID = 1
		</cfquery>
		
		<cfreturn qGetDeviationSums/>
	</cffunction>

	<!--- Search for a subset of active deviations --->
	<cffunction name="searchDeviations" output="false" returntype="query">

		<cfargument name="Customer_Info" required="false" default="">
		<cfargument name="Billback_Info" required="false" default="">
		<cfargument name="BB_Analyst_ID" required="false" default="0">
		<cfargument name="sql_Sort_By" required="false" default="dbo.BB_Adjustment.Adjustment_Amount">
		<cfargument name="sql_Sort_By_Order" required="false" default="DESC">
		<cfargument name="Deviation_Status" required="false" default="Active">
		<cfargument name="Date_Operator" 	type="string" 	required="false"  default=""/>
		<cfargument name="BB_Date" 		type="date" 	required="false"  default="#now()#"/>
		
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif  businessSegManager.isEnabled()>
			<cfset Business_Segment_On = 1>
			<cfset UserSegmentFiltersAutopayResults = businessSegManager.getEnabled().User_Segment_Filters_Autopay_Results />
		<cfelse>
			<cfset Business_Segment_On = 0>
			<cfset UserSegmentFiltersAutopayResults = 0>
		</cfif>
		
			<cfquery name="qSearchDeviations" datasource="#application.datasource#">
			SELECT 	DISTINCT	
						BB_Adjustment.BB_Adjustment_ID, cast(BB_Adjustment.Adjustment_Amount as float) as Adjustment_Amount, Billback.Billback_ID, Billback.BB_Code, 
						Billback.BB_Title, Billback.Billback_ID, BB_Adjustment.Ignore, BB_Adjustment.Hidden, BB_Adjustment.Recalculate,
						Billback.BB_Date, datediff(d, Billback.BB_Date, getdate()) as Billback_Age, BB_Adjustment.Applied,
						BSA_Foodservice_Customers.Name as Distributor_Name, BSA_Foodservice_Customers.Ship_To, BB_Adjustment.Deleted,
						BB_Adjustment.Last_Updated_Date, _Users.Name_First + ' ' + _Users.Name_Last AS Updated_By
			FROM		BB_Adjustment
			INNER JOIN 	Billback
			ON			Billback.Billback_ID = BB_Adjustment.Billback_ID
			AND			Billback.Deleted = 0
			<cfif len(trim(arguments.Billback_Info)) GT 0>
			AND			(Billback.BB_Code LIKE <cfqueryparam value="%#arguments.Billback_Info#%" cfsqltype="CF_SQL_VARCHAR"> OR
						Billback.BB_Title LIKE <cfqueryparam value="%#arguments.Billback_Info#%" cfsqltype="CF_SQL_VARCHAR"> OR
						Billback.BB_Reference LIKE <cfqueryparam value="%#arguments.Billback_Info#%" cfsqltype="CF_SQL_VARCHAR">)
			</cfif>
			<cfif arguments.Date_Operator NEQ "" AND isDate(arguments.BB_Date) AND (ListFindNOCase("Greater_Or_Equal,Equal,Less_Or_Equal",arguments.Date_Operator,",") GT 0)>
				AND DateDiff(d, '#arguments.BB_Date#', Billback.Created_Date)
				<CFSWITCH EXPRESSION="#arguments.Date_Operator#">
					<CFCASE VALUE="Greater_Or_Equal">
						>=
					</CFCASE>
					<CFCASE VALUE="Equal">
						=
					</CFCASE>
					<CFCASE VALUE="Less_Or_Equal">
						<=
					</CFCASE>
				</CFSWITCH>
				0
			</cfif>
			INNER JOIN 	BSA_Foodservice_Customers
			ON 			cast(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID as nvarchar(100)) = BB_Adjustment.Payee_ID
			<cfif len(trim(arguments.Customer_Info)) GT 0>
			AND			(BSA_Foodservice_Customers.Name LIKE <cfqueryparam value="%#arguments.Customer_Info#%" cfsqltype="CF_SQL_VARCHAR"> OR
						BSA_Foodservice_Customers.Ship_To LIKE <cfqueryparam value="%#arguments.Customer_Info#%" cfsqltype="CF_SQL_VARCHAR">	OR
						BSA_Foodservice_Customers.Shr_Ship_To LIKE <cfqueryparam value="%#arguments.Customer_Info#%" cfsqltype="CF_SQL_VARCHAR">)
			</cfif>
			<cfif BB_Analyst_ID IS NOT 0>
			AND 		Billback.Analyst_User_ID = <cfqueryparam value="#arguments.BB_Analyst_ID#" cfsqltype="CF_sql_varchar">
			</cfif>
			LEFT JOIN	_Users 
			ON			_Users.User_ID = BB_Adjustment.Last_Updated_By
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
				LEFT JOIN Billback_Program BP ON BP.Billback_ID = Billback.Billback_ID 
				LEFT JOIN Contract_Main CM ON CM.Contract_Main_ID = BP.Program_ID
			 	LEFT JOIN User_Business_Segment UBS ON UBS.Business_Segment_ID = CM.Business_Segment_ID 
			 	LEFT JOIN _Users u ON u.User_ID = UBS.User_ID
			</cfif>
			WHERE 		<Cfif arguments.Deviation_Status EQ "Applied">
							BB_Adjustment.Applied = 1
						<cfelse>
							BB_Adjustment.Applied = 0
						</Cfif>
			AND			<Cfif arguments.Deviation_Status EQ "Deleted">
							BB_Adjustment.Deleted = 1
						<cfelse>
							BB_Adjustment.Deleted = 0
						</Cfif>
			AND 		<Cfif arguments.Deviation_Status EQ "Recalc">
							BB_Adjustment.Recalculate = 1
						<cfelse>
							BB_Adjustment.Recalculate = 0
						</Cfif>
			AND 		<Cfif arguments.Deviation_Status EQ "Hidden">
							BB_Adjustment.Hidden = 1
						<cfelse>
							BB_Adjustment.Hidden = 0
						</Cfif>	
				 		<Cfif arguments.Deviation_Status EQ "Ignore">
			AND				BB_Adjustment.Ignore = 1
						</Cfif>	
			<cfif (Business_Segment_On EQ 1 AND UserSegmentFiltersAutopayResults EQ 1)>
			AND u.User_ID = '#request.accessStructure.User_Id#' 
			</cfif>			
			AND			BB_Adjustment.Adjustment_Amount >= .01
				 					
			ORDER BY 	#arguments.sql_Sort_By# #arguments.sql_Sort_By_Order#
			</cfquery>

	<cfreturn qSearchDeviations>
		
	</cffunction>

	<!--- Update the status for a deviation --->
	<cffunction name="updateDeviation" output="true" returntype="string">
		<cfargument name="BB_Adjustment_ID" required="true">
		<cfargument name="DeviationType" required="true">
		<cfargument name="User_ID" required="true">
		
		<cfswitch expression="#arguments.DeviationType#">
			<cfcase value="0"> 
				<cfquery name="PriorValue" datasource="#application.datasource#">
				SELECT 	Hidden, Recalculate, Ignore
				FROM 	BB_Adjustment
				WHERE 	BB_Adjustment_ID = <cfqueryparam value="#arguments.BB_Adjustment_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				
				<cfset UseUpdatedBy = 0>
				<cfif PriorValue.Hidden IS 1 OR PriorValue.Recalculate IS 1 OR PriorValue.Ignore IS 1>
					<cfset UseUpdatedBy = 1>
				</cfif>
				
				<cfquery name="UpdateDeviation" datasource="#application.datasource#">
				UPDATE 	BB_Adjustment
				SET 	Hidden = 0,
						Recalculate = 0,
						Ignore = 0<cfif UseUpdatedBy IS 1>,
						Last_Updated_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Updated_Date = getdate()</cfif>
				WHERE 	BB_Adjustment_ID = <cfqueryparam value="#arguments.BB_Adjustment_ID#" cfsqltype="CF_SQL_VARCHAR">				
				</cfquery>
			</cfcase>
			<cfcase value="1">
				<cfquery name="UpdateDeviation" datasource="#application.datasource#">
				UPDATE 	BB_Adjustment
				SET 	Hidden = 1,
						Recalculate = 0,
						Ignore = 0,
						Hidden_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Updated_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Updated_Date = getdate()
				WHERE 	BB_Adjustment_ID = <cfqueryparam value="#arguments.BB_Adjustment_ID#" cfsqltype="CF_SQL_VARCHAR">					
				</cfquery>
			</cfcase>
			<cfcase value="2">
				<cfquery name="UpdateDeviation" datasource="#application.datasource#">
				UPDATE 	BB_Adjustment
				SET 	Hidden = 0,
						Recalculate = 0,
						Ignore = 1,
						Last_Updated_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Updated_Date = getdate()
				WHERE 	BB_Adjustment_ID = <cfqueryparam value="#arguments.BB_Adjustment_ID#" cfsqltype="CF_SQL_VARCHAR">				
				</cfquery>
			</cfcase>
			<cfcase value="3">
				<cfquery name="UpdateDeviation" datasource="#application.datasource#">
				UPDATE 	BB_Adjustment
				SET 	Hidden = 0,
						Recalculate = 1,
						Ignore = 0,
						Last_Updated_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Updated_Date = getdate()
				WHERE 	BB_Adjustment_ID = <cfqueryparam value="#arguments.BB_Adjustment_ID#" cfsqltype="CF_SQL_VARCHAR">			
				</cfquery>
			</cfcase>
		</cfswitch>

	<cfset DevType = arguments.DeviationType>
	<cfreturn DevType/>

	</cffunction>

	<cffunction name="recalcNow" output="false" returntype="void">	
		<cfstoredproc procedure="BB_Auto_Deviation" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Recalc_Now" value="1" null="no" />			
		</cfstoredproc>	
	</cffunction>
	
	
</cfcomponent>