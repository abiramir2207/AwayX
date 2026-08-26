<!----
	Filename:	C:\Work\Code\base\AwayX\components\programs\volume\Volume_Forecast.cfc
	Created:	11/17/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		This CFC is used to SELECT, INSERT, UPDATE, DELETE Class, Plan and groups
	Usage:
		This CFC is used to SELECT, INSERT, UPDATE, DELETE Class, Plan and groups
	Tips:
	 for each specific function take a look at HINT
---->
<cfcomponent displayname="Volume Forecast" hint="Volume Forecast Update Insert">
<!--- //////////////////////////////////////////////////////////////////////////////////////////// --->	
<!--- /////////////////////////////////////////CLASS///////////////////////////////////////////// --->
<!--- ////////////////////////////////////////////////////////////////////////////////////////// --->	
<!--- This Section contains statements to Insert, Update, Delete, Select Class Information START --->
	<cffunction name="GVFC"  access="public"  output="no" hint="Get Volume Forecast Class">    
		<cfset useLakebaseForqGetVFClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vf_class")>
<cfif useLakebaseForqGetVFClass>
	<cftry>
		<cfset qGetVFClass = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vf_class", {
				"deleted" = "eq.0",
				"order" = "vf_class_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVFClass = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVFClass>
<cfquery name="qGetVFClass" datasource="#application.datasource#">
			SELECT * FROM VF_Class WHERE Deleted = 0 ORDER BY VF_Class_Desc
		</cfquery>
</cfif>   
    <cfreturn  qGetVFClass>    
    </cffunction>    

	<cffunction name="PVFC"  access="public"  output="no" hint="Particular Volume Forecast Class"> 
		<cfargument name="id" type="numeric" default="0" required="true">    
		<cfquery name="qOneVFClass" datasource="#application.datasource#">
			SELECT * FROM VF_Class WHERE VF_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    <cfreturn  qOneVFClass>    
    </cffunction> 
  
 	<cffunction name="DVFC"  access="public"  output="no" hint="Delete Volume Forecast Class"> 
	 	<cfargument name="id" type="numeric" default="0" required="true">   
		<cfquery name="qDeleteVFClass" datasource="#application.datasource#">
			UPDATE VF_Class 
			SET Deleted = 1
			WHERE VF_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    </cffunction> 

 	<cffunction name="UVFC"  access="public"  output="no" hint="Update Volume Forecast Class"> 
	 	<cfargument name="id" type="numeric" default="0" required="true">  
		<cfargument name="number" type="string" default="" required="true" >
		<cfargument name="desc" type="string" default="" required="true" >
		<cfargument name="isFiscal" type="numeric" default="0" required="true" >
		<cfargument name="year" type="string" default="" required="true" >
		<cfargument name="active" type="numeric" default="0" required="true" > 
			<cfif arguments.isFiscal>
				<cfset qGetFiscalYear = getFiscalYear(arguments.year) />
				<cfset startDate = qGetFiscalYear.Start_Date />
				<cfset endDate = qGetFiscalYear.End_Date />
			<cfelse>
				<cfset startDate = getCalendarYearStartDate(arguments.year) />
				<cfset endDate = getCalendarYearEndDate(arguments.year) />
			</cfif>		
		<cfquery name="qUpdateVFClass" datasource="#application.datasource#">
			UPDATE VF_Class 
			SET VF_Class_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#" />
      			,VF_Class_Desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#" />
     			,Is_Fiscal = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.isFiscal#" />
      			,Year_Selection = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.year#" />
      			,Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#startDate#" />
      			,End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#endDate#" />
      			,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#" />
      			,Last_Updated_Date = GetDate()
      			,Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
			WHERE VF_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    </cffunction>
    
	<cffunction name="IVFC"  access="public"  output="false" hint="Insert Volume Forecast Class">
			<cfargument name="number" type="string" default="" required="true" >
			<cfargument name="desc" type="string" default="" required="true" >
			<cfargument name="isFiscal" type="numeric" default="0" required="true" >
			<cfargument name="year" type="string" default="" required="true" >
			<cfargument name="active" type="numeric" default="0" required="true" >
				
			<cfif arguments.isFiscal>
				<cfset qGetFiscalYear = getFiscalYear(arguments.year) />
				<cfset startDate = qGetFiscalYear.Start_Date />
				<cfset endDate = qGetFiscalYear.End_Date />
			<cfelse>
				<cfset startDate = getCalendarYearStartDate(arguments.year) />
				<cfset endDate = getCalendarYearEndDate(arguments.year) />
			</cfif>
		
			<cfquery name="qInsertVFClass" datasource="#application.datasource#">
				INSERT INTO VF_Class (				
					VF_Class_Number,
					VF_Class_Desc,
					Is_Fiscal,
					Year_Selection,
					Start_Date,
					End_Date,
					Active,
					Last_Updated_Date,
					Last_Updated_By
				)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.isFiscal#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.year#" />,
					<cfqueryparam cfsqltype="cf_sql_date" value="#startDate#" />,
					<cfqueryparam cfsqltype="cf_sql_date" value="#endDate#" />,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#" />,
					GetDate(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
				)
				SELECT SCOPE_IDENTITY() AS VF_Class_ID
			</cfquery>
			<cfquery name="qPopulateVFPeriod" datasource="#application.datasource#">
				EXEC Populate_VF_Period @VF_Class_ID = #qInsertVFClass.VF_Class_ID#
			</cfquery>
		</cffunction>
		
	<cffunction name="getFiscalYear" returntype="query" access="public" hint="Will return the list of fiscal years" output="false">
		<cfargument name="fiscalYear" type="string" required="false" default="" />
		
		<cfset var qGetFiscalYears = "" />
		
		<cfquery name="qGetFiscalYears" datasource="#application.datasource#">
			SELECT 	Fiscal_Year, Start_Date, End_Date
			FROM 	V_Fiscal_Year_List
			<cfif arguments.fiscalYear neq "">
			WHERE Fiscal_Year = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fiscalYear#" />		
			</cfif>
			ORDER BY Fiscal_Year
		</cfquery>
		
		<cfreturn qGetFiscalYears />
	
	</cffunction>

	<cffunction name="getCalendarYear" returntype="query" access="public" hint="Will return the list of calendar years" output="false">
	
		
		<cfquery name="qGetCalendarYear" datasource="#application.datasource#">
			declare @year_start int,
					@year_end int

			select 	@year_start = year(getdate()) - 5,
					@year_end = year(getdate()) + 5
		
			SELECT 	year, start_date, end_date
			FROM 	udf_GetCalendarYears (@year_start, @year_end)
			ORDER BY year
		</cfquery>
		
		<cfreturn qGetCalendarYear />
	
	</cffunction>

	<cffunction name="getCalendarYearStartDate" returntype="date" access="public" hint="Will return the start date of the provided calendar year" output="false">
		<cfargument name="calendarYear" type="numeric" required="true" />
		
		<cfreturn CreateDate(arguments.calendarYear, 1, 1) />
	
	</cffunction>
	
	<cffunction name="getCalendarYearEndDate" returntype="date" access="public" hint="Will return the end date of the provided calendar year" output="false">
		<cfargument name="calendarYear" type="numeric" required="true" />
		
		<cfreturn CreateDate(arguments.calendarYear, 12, 31) />
	
	</cffunction>
<!--- This Section contains statements to Insert, Update, Delete, Select Class Information END --->
<!--- //////////////////////////////////////////////////////////////////////////////////////////// --->	
<!--- /////////////////////////////////////////GROUP///////////////////////////////////////////// --->
<!--- ////////////////////////////////////////////////////////////////////////////////////////// --->
	<cffunction name="GVFG"  access="public"  output="false" hint="Get Volume Forecast Groups">    
    	<cfset useLakebaseForqGetVFGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vf_group")>
<cfif useLakebaseForqGetVFGroups>
	<cftry>
		<cfset qGetVFGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vf_group", {
				"deleted" = "eq.0",
				"order" = "vf_group_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetVFGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetVFGroups>
<cfquery name="qGetVFGroups" datasource="#application.datasource#">
	    SELECT * FROM VF_Group WHERE Deleted = 0 ORDER BY VF_Group_Desc	
		</cfquery>
</cfif>
    <cfreturn qGetVFGroups>    
    </cffunction>    

	<cffunction name="IVFG"  access="public"  output="false" hint="Insert Volume Forecast Group">
			<cfargument name="number" type="string" default="" required="true" >
			<cfargument name="desc" type="string" default="" required="true" >
			<cfargument name="active" type="numeric" default="0" required="true" >
				
			<cfquery name="qInsertVFGroup" datasource="#application.datasource#">
				INSERT INTO VF_Group (				
					VF_Group_Number,
					VF_Group_Desc,
					Active,
					Created_Date,
					Last_Updated_By
				)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#" />,
					<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#" />,
					GetDate(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
				)
			</cfquery>
		</cffunction>

 	<cffunction name="DVFG"  access="public"  output="no" hint="Delete Volume Forecast Group"> 
	 	<cfargument name="id" type="numeric" default="0" required="true">   
		<cfquery name="qDeleteVFGroup" datasource="#application.datasource#">
			UPDATE VF_Group 
			SET Last_Updated_Date = GetDate(), 
				Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />,
				Deleted = 1
			WHERE VF_Group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    </cffunction> 

	<cffunction name="PVFG"  access="public"  output="no" hint="Particular Volume Forecast Group"> 
		<cfargument name="id" type="numeric" default="0" required="true">    
		<cfquery name="qOneVFGroup" datasource="#application.datasource#">
			SELECT * FROM VF_Group WHERE VF_Group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    <cfreturn  qOneVFGroup>    
    </cffunction> 

 	<cffunction name="UVFG"  access="public"  output="no" hint="Update Volume Forecast Group"> 
	 	<cfargument name="id" type="numeric" default="0" required="true">  
		<cfargument name="number" type="string" default="" required="true" >
		<cfargument name="desc" type="string" default="" required="true" >
		<cfargument name="active" type="numeric" default="0" required="true" > 
		
		<cfquery name="qUpdateVFGroup" datasource="#application.datasource#">
			UPDATE VF_Group 
			SET VF_Group_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#" />
      			,VF_Group_Desc = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#" />
     			,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.active#" />
      			,Last_Updated_Date = GetDate()
      			,Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
			WHERE VF_Group_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    </cffunction>	
<!--- This Section contains statements to Insert, Update, Delete, Select PLAN Information END --->
<!--- //////////////////////////////////////////////////////////////////////////////////////////// --->	
<!--- /////////////////////////////////////////PLAN///////////////////////////////////////////// --->
<!--- ////////////////////////////////////////////////////////////////////////////////////////// --->    
    <cffunction name="IVFP" access="public"  output="false" hint="Insert Volume Forecast Plan">
		<cfargument name="number" type="string" default="" required="true" >
		<cfargument name="desc" type="string" default="" required="true" >
		<cfargument name="class_id" type="numeric" default="0" required="true">  
		<cfargument name="group_id" type="numeric" default="0" required="true"> 
		<cfargument name="segment_id" type="numeric" default="0" required="true">  
		<cfargument name="Forecast_Level" type="numeric" default="-1" required="true"> 
		<cfargument name="UOM" type="numeric" default="0" required="true"> 
		
			<cfquery name="qInsertVFPlan" datasource="#application.datasource#">
				INSERT INTO VF_Plan (				
					VF_Plan_Number,
					VF_Plan_Desc,
					VF_Plan_Class_ID,
					VF_Plan_Group_ID,
					VF_Plan_Segment_ID,
					Forecast_Level,
					VF_UOM,
					Created_Date,
					Last_Updated_By
				)
				VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#" />,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#" />,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.class_id#" />,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.group_id#" />,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.segment_id#" />,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Forecast_Level#" />,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.UOM#" />,
					GetDate(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
				)
			</cfquery>
	</cffunction>	
	
	<cffunction name="GVFP"  access="public"  output="false" hint="Get Volume Forecast Plans">    
    <cfargument name="currentFiscal" required="false" default="on">
    	
    <cfquery name="qGetVFPlans" datasource="#application.datasource#">
		    SELECT *
		           , Detail_Record_Count = ( SELECT COUNT(1) FROM VF_Detail vfd WHERE vfd.VF_Plan_ID = VF_Plan.VF_Plan_ID AND vfd.Deleted = 0)
		      FROM VF_Plan 
		     WHERE Deleted = 0	
		     			<cfif arguments.currentFiscal eq 'on'>
		     				 AND vf_Plan_Class_Id IN ( SELECT vf_Class_Id
	                                           FROM VF_CLASS
	                                          WHERE Deleted = 0
	                                            AND Getdate() BETWEEN Start_Date AND End_Date )
		     			</cfif>
		</cfquery>
    <cfreturn qGetVFPlans>    
  </cffunction>   
    
 	<cffunction name="DVFP"  access="public"  output="no" hint="Delete Volume Forecast Plan"> 
	 	<cfargument name="id" type="numeric" default="0" required="true">   
		<cfquery name="qDeleteVFPlan" datasource="#application.datasource#">
			UPDATE VF_Plan 
			SET Last_Updated_Date = GetDate(), 
				Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />,
				Deleted = 1
			WHERE VF_Plan_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    </cffunction>

    <cffunction name="CopyVFP"  access="public"  output="no" hint="Copy Volume Forecast Plan" returntype="numeric"> 
	 	<cfargument name="id" type="numeric" default="0" required="true">  
	 	<cfquery name="qCopyVFPlan" datasource="#application.datasource#">
			EXEC VF_Copy_Volume_Plan #arguments.id#
		</cfquery> 
		<cfquery name="qUpdCopyVFPlan" datasource="#application.datasource#">
			UPDATE VF_Plan 
			SET Last_Updated_Date = GetDate(), 
				Last_Updated_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
			WHERE VF_Plan_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qCopyVFPlan.New_VF_Plan_ID#" />
		</cfquery> 
		<cfreturn  qCopyVFPlan.New_VF_Plan_ID/> 
    </cffunction> 
    
	<cffunction name="PVFP"  access="public"  output="no" hint="Particular Volume Forecast Plan"> 
		<cfargument name="id" type="numeric" default="0" required="true">    
		<cfquery name="qOneVFPlan" datasource="#application.datasource#">
			SELECT * FROM VF_Plan WHERE VF_Plan_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery>   
    <cfreturn  qOneVFPlan>    
    </cffunction>  
    
    <cffunction name="PPG" access="public" output="no" hint="Pull Planning Groups">
		<cfargument name="pg_group_type" type="numeric" default="1" required="true">    
		<cfargument name="isEnabled" type="numeric" default="0" required="true">
		<cfargument name="Business_Segment_Id" type="numeric" default="0" required="true">
		
		<cfquery name="qGroups" datasource="#application.datasource#">
  			<cfif arguments.pg_group_type eq "1">        <!---product planning groups--->
				SELECT pgt.pg_Type_Id
				, pgt.pg_Type_Code
				, pgt.pg_Type_Name
				, pg_Product_Category_Id     AS Category_ID
				, pg_Product_Category_Code   AS Category_Code
				, pg_Product_Category_Name   AS Category_Name
				FROM pg_Type pgt
				INNER JOIN pg_Product_Category pgpc
				ON pgpc.pg_Type_Id = pgt.pg_Type_Id
				AND pgpc.Active = 1
				AND pgpc.Deleted = 0
				<cfif arguments.isEnabled>
				AND pgpc.Business_Segment_Id = #arguments.Business_Segment_Id#
				</cfif>
				WHERE pgt.pg_Group_Type = 1
				AND pgt.Active = 1
				AND pgt.Deleted = 0
			<cfelseif arguments.pg_group_type eq "2">    <!---distributor planning groups--->
				SELECT pgt.pg_Type_Id
				, pgt.pg_Type_Code
				, pgt.pg_Type_Name
				, pg_Customer_Category_Id    AS Category_ID
				, pg_Customer_Category_Code  AS Category_Code
				, pg_Customer_Category_Name  AS Category_Name
				FROM pg_Type pgt
				INNER JOIN pg_Customer_Category pgcc
				ON pgcc.pg_Type_Id = pgt.pg_Type_Id
				AND pgcc.Active = 1
				AND pgcc.Deleted = 0
				<cfif arguments.isEnabled>
				AND pgpc.Business_Segment_Id = #arguments.Business_Segment_Id#
				</cfif>
				WHERE pgt.pg_Group_Type = 2
				AND pgt.Active = 1
				AND pgt.Deleted = 0
			</cfif>
		</cfquery>
		<cfreturn  qGroups> 
	</cffunction>
	
	<cffunction name="UVFP"  access="public"  output="no" hint="Update Volume Forecast Plan"> 
	 	<cfargument name="id" 		type="numeric" default="0" required="true">  
		<cfargument name="number" 	type="string" default="" required="true" >
		<cfargument name="edit"     type="numeric" default="0" required="true">
		<cfargument name="desc" 	type="string" default="" required="true" >
		<cfargument name="class" 	type="numeric" default="0" required="true"> 
		<cfargument name="group" 	type="numeric" default="0" required="true"> 
		<cfargument name="segment"  type="numeric" default="0" required="true"> 
		<cfargument name="uom" 		type="numeric" default="0" required="true"> 
		<cfargument name="forecast" type="numeric" default="0" required="true"> 
		<cfargument name="pg_group" type="numeric" default="0" required="true">
		<cfargument name="Dist_group" type="numeric" default="0" required="true">
        <cfargument name="list" 	type="string" default="" required="true">
		<cfargument name="Dist_list" 	type="string" default="" required="true">

	
		<cfquery name="qUpdateVFGroup" datasource="#application.datasource#">
			UPDATE VF_Plan 
			SET 
				 VF_Plan_Number 	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#" />
	      		,VF_Plan_Desc 		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#" />
	      		,VF_Plan_Class_ID	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.class#" />
	      		,VF_Plan_Group_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.group#" />
	      		,Last_Updated_Date 	= GetDate()
	      		,Last_Updated_By 	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#" />
	      		,VF_Plan_Segment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.segment#" />
	      		,Forecast_Level 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.forecast#" />
	      		,VF_UOM 			= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.uom#" />
			WHERE VF_Plan_ID 		= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
		</cfquery> 
		
		<cfif arguments.pg_group>
			<cfset pg_ext_info = "">
	<cfset useLakebaseForPg_groups_info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vf_planning_groups")>
<cfif useLakebaseForPg_groups_info>
	<cftry>
		<cfset Pg_groups_info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vf_planning_groups", {
				"vf_plan_id" = "eq.#arguments.edit#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPg_groups_info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPg_groups_info>
<cfquery name="Pg_groups_info" datasource="#application.datasource#">
		SELECT * FROM VF_Planning_Groups WHERE VF_plan_ID = #arguments.edit# AND deleted = 0
	</cfquery>
</cfif>
				<cfif Pg_groups_info.recordcount>
				
						<cfloop query="Pg_groups_info">
							<cfif listfind(arguments.list, Pg_groups_info.PG_Product_Category_ID) EQ 0>
								<cfquery name="Pg_products" datasource="#application.datasource#">
									UPDATE	VF_Planning_Groups
									SET deleted = 1 
									WHERE VF_Plan_ID = #arguments.edit# AND PG_Product_Category_ID = '#TRIM(Pg_groups_info.PG_Product_Category_ID)#'
								</cfquery>	
							</cfif>
							<cfset pg_ext_info = listappend(pg_ext_info, "#Pg_groups_info.PG_Product_Category_ID#")>
						</cfloop>
				
								<cfloop list ="#arguments.list#"  index="PG_Group_Name" delimiters=",">
									<!---D29683 - Chris: ignore empty entry (deleted row), only insert row with non-blank entry--->
									<cfif len(trim(PG_Group_Name)) and listfind(pg_ext_info, PG_Group_Name) EQ 0>
										<cfquery name="Pg_products" datasource="#application.datasource#">
											INSERT INTO	VF_Planning_Groups
														(VF_Plan_ID, PG_Product_Category_ID)
											Values		(#arguments.edit#, '#PG_Group_Name#')
										</cfquery>
									</cfif>
								</cfloop>		
				    
				<cfelse>
			
						<cfloop list ="#arguments.list#"  index="PG_Group_Name" delimiters=",">
							<cfquery name="Pg_products" datasource="#application.datasource#">
								INSERT INTO	VF_Planning_Groups
											(VF_Plan_ID, PG_Product_Category_ID)
								Values		(#arguments.edit#, '#PG_Group_Name#')
							</cfquery>
						</cfloop>
			
			</cfif>
    	</cfif> 
    	<cfif arguments.Dist_group>
			<cfset Dist_ext_info = "">
			<cfquery name="Dist_groups_info" datasource="#application.datasource#">
				SELECT * FROM VF_Distributor_Planning_Groups WHERE VF_plan_ID = #arguments.edit# AND deleted = 0
			</cfquery>	
			<cfif Dist_groups_info.recordcount>
						<cfloop query="Dist_groups_info">
							<cfif listfind(arguments.Dist_list, Dist_groups_info.PG_Customer_Category_ID) EQ 0>
								<cfquery name="Dist_products" datasource="#application.datasource#">
									UPDATE	VF_Distributor_Planning_Groups
									SET deleted = 1 
									WHERE VF_Plan_ID = #arguments.edit# AND PG_Customer_Category_ID = '#TRIM(Dist_groups_info.PG_Customer_Category_ID)#'
								</cfquery>	
							</cfif>
							<cfset Dist_ext_info = listappend(Dist_ext_info, "#Dist_groups_info.PG_Customer_Category_ID#")>
						</cfloop>

								<cfloop list ="#arguments.Dist_list#"  index="Dist_Group_Name" delimiters=",">
									<cfif listfind(Dist_ext_info, Dist_Group_Name) EQ 0>
										<cfquery name="Dist_products" datasource="#application.datasource#">
											INSERT INTO	VF_Distributor_Planning_Groups
														(VF_Plan_ID, PG_Customer_Category_ID)
											Values		(#arguments.edit#, '#Dist_Group_Name#')
										</cfquery>
									</cfif>
								</cfloop>	

			<cfelse>
						<cfloop list ="#arguments.Dist_list#"  index="Dist_Group_Name" delimiters=",">
							<cfquery name="Dist_products" datasource="#application.datasource#">
								INSERT INTO	VF_Distributor_Planning_Groups
											(VF_Plan_ID, PG_Customer_Category_ID)
								Values		(#arguments.edit#, '#Dist_Group_Name#')
							</cfquery>
						</cfloop>			
			</cfif>		
		</cfif>
    </cffunction>

    <cffunction name="IVFDPG" access="public" output="no" hint="Insert VF Distributor Planning Groups">
		<cfargument name="id" 			type="numeric" default="0" required="true">
		<cfargument name="bsa_id" 		type="string"  default="" required="true">

		<cfloop list ="#arguments.bsa_id#"  index="bsa_id" delimiters=",">
			<cfquery name="qInsertVFDistibutorPG" datasource="#application.datasource#">
				INSERT INTO VF_Distributor_Planning_Groups(vf_plan_id, pg_product_category_id)
				Values ('#arguments.id#','#bsa_id#')
			</cfquery>
		</cfloop>

	</cffunction>


    <cffunction name="FindDuplicatePlan" access="public" output="no" hint="Find Duplicate Volume Plan">
		<cfargument name="id" 						type="numeric" default="0" required="true" />
		<cfargument name="classId" 						type="numeric"  default="" required="true" />
		<cfargument name="segmentId" 					type="numeric"  default="" required="true" />
		<cfargument name="forecastLevel" 				type="numeric"  default="" required="true" />
		<cfargument name="productPlanningGroupList" 	type="string"  default="" required="true" />
		<cfargument name="distributorPlanningGroupList" type="string"  default="" required="true" />

		<cfquery name="gGetDuplicatePlan" datasource="#application.datasource#" result="gGetDuplicatePlan_result">
			DECLARE @tmp_prod table (BSA_Foodservice_Items_Master_ID uniqueidentifier, PG_Product_Category_ID uniqueidentifier, PG_Product_Category_Name varchar(100))
			DECLARE @tmp_dist table (BSA_Foodservice_Customers_ID uniqueidentifier, PG_Customer_Category_ID uniqueidentifier, PG_Customer_Category_Name varchar(100))
			
			<!--- If there are product planning groups selected, get the members --->
			<cfif arguments.productPlanningGroupList neq "">
			INSERT INTO @tmp_prod
			SELECT	pgpm.BSA_Foodservice_Items_Master_ID, pgpm.PG_Product_Category_ID, pgpc.PG_Product_Category_Name
			FROM  	PG_Product_Members pgpm
			INNER JOIN PG_Product_Category pgpc
			ON		pgpc.PG_Product_Category_ID = pgpm.PG_Product_Category_ID
			WHERE 	pgpm.PG_Product_Category_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.productPlanningGroupList#" list="yes"  />)
			AND		pgpm.Deleted = 0
			</cfif>

			<!--- If there are distributor planning groups selected, get the members --->
			<cfif arguments.distributorPlanningGroupList neq "">
			INSERT INTO @tmp_dist
			SELECT	pgcm.BSA_Foodservice_Customers_ID, pgcm.PG_Customer_Category_ID, pgcc.PG_Customer_Category_Name
			FROM  	PG_Customer_Members pgcm
			INNER JOIN PG_Customer_Category pgcc
			ON		pgcc.PG_Customer_Category_ID = pgcm.PG_Customer_Category_ID
			WHERE 	pgcm.PG_Customer_Category_ID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.distributorPlanningGroupList#" list="yes"  />)
			AND		pgcm.Deleted = 0
			</cfif>
			
			IF OBJECT_ID('tempdb..##tmp_duplicate_plans') IS NOT NULL
			DROP TABLE ##tmp_duplicate_plans
			
			<!--- Return list of duplicate plans --->
			<!--- Query 1: get plans with customer planning groups --->			
			SELECT	DISTINCT p.VF_Plan_ID,  
					prod.PG_Product_Category_Name,
					pgpc.PG_Product_Category_Name as other_vf_PG_Product_Category_Name,
					i.Item, i.Description,
					ISNULL(dist.PG_Customer_Category_Name,  'ALL') as PG_Customer_Category_Name,
					pgcc.PG_Customer_Category_Name as other_vf_PG_Customer_Category_Name,
					c.Shr_Ship_To, c.Name,
					ROW_NUMBER() OVER(PARTITION BY p.VF_Plan_ID ORDER BY i.Item) AS Row_ID
			INTO	##tmp_duplicate_plans
			FROM	VF_Plan p
			
			<!--- Find product planning groups with same members  --->
			INNER JOIN VF_Planning_Groups vfpg
			ON		vfpg.VF_Plan_ID = P.VF_Plan_ID
			AND		vfpg.Deleted = 0
			INNER JOIN PG_Product_Members pgpm
			ON    	pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
			AND		pgpm.Deleted = 0
			INNER JOIN PG_Product_Category pgpc
			ON		pgpc.PG_Product_Category_ID = pgpm.PG_Product_Category_ID
			INNER JOIN @tmp_prod prod
			ON		prod.BSA_Foodservice_Items_Master_ID = pgpm.BSA_Foodservice_Items_Master_ID
			INNER JOIN BSA_Foodservice_Items_Master i
			ON		i.BSA_Foodservice_Items_Master_ID = prod.bsa_FoodService_Items_Master_Id
			<!--- Find customer planning groups with same members  
			Doing LEFT JOIN as distributor planning group selection is nto required.
			If Forecast_Level is not 4 and distributor planning group is not selected, it will include all distributors
			--->
			INNER JOIN VF_Distributor_Planning_Groups  vfdg
			ON		vfdg.VF_Plan_ID = P.VF_Plan_ID
			AND		vfdg.Deleted = 0
			INNER JOIN PG_Customer_Members pgcm
			ON    	pgcm.PG_Customer_Category_ID = vfdg.PG_Customer_Category_ID
			AND		pgcm.Deleted = 0
			INNER JOIN PG_Customer_Category pgcc
			ON		pgcc.PG_Customer_Category_ID = pgcm.PG_Customer_Category_ID
			<cfif arguments.distributorPlanningGroupList eq "" and arguments.forecastLevel neq 4>
			<!--- If no distributor specified when forecast level = zone/region/market, all distributors are included --->
			LEFT JOIN
			<cfelse>
			INNER JOIN
			</cfif> @tmp_dist dist
			ON		dist.BSA_Foodservice_Customers_ID = pgcm.BSA_Foodservice_Customers_ID
			INNER JOIN BSA_Foodservice_Customers c
			ON		c.BSA_Foodservice_Customers_ID = pgcm.bsa_FoodService_Customers_Id
			WHERE	p.VF_Plan_ID != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
			AND		p.VF_Plan_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.classId#" /> <!--- same class id --->
			AND 	p.VF_Plan_Segment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.segmentId#" /> <!--- same segment id --->
			AND		p.Deleted = 0
			
			UNION
			
			<!--- Return list of duplicate plans --->
			<!--- Query 2: get plans without customer planning groups --->
			SELECT	DISTINCT p.VF_Plan_ID,  
					prod.PG_Product_Category_Name,
					pgpc.PG_Product_Category_Name as other_vf_PG_Product_Category_Name,
					i.Item, i.Description,
					'ALL' as PG_Customer_Category_Name,
					'ALL' as other_vf_PG_Customer_Category_Name,
					'ALL' as Shr_Ship_To, 'ALL' as Name,
					ROW_NUMBER() OVER(PARTITION BY p.VF_Plan_ID ORDER BY i.Item) AS Row_ID
			FROM	VF_Plan p
			
			<!--- Find product planning groups with same members  --->
			INNER JOIN VF_Planning_Groups vfpg
			ON		vfpg.VF_Plan_ID = P.VF_Plan_ID
			AND		vfpg.Deleted = 0
			INNER JOIN PG_Product_Members pgpm
			ON    	pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
			AND		pgpm.Deleted = 0
			INNER JOIN PG_Product_Category pgpc
			ON		pgpc.PG_Product_Category_ID = pgpm.PG_Product_Category_ID
			INNER JOIN @tmp_prod prod
			ON		prod.BSA_Foodservice_Items_Master_ID = pgpm.BSA_Foodservice_Items_Master_ID
			INNER JOIN BSA_Foodservice_Items_Master i
			ON		i.BSA_Foodservice_Items_Master_ID = prod.bsa_FoodService_Items_Master_Id
			WHERE	p.VF_Plan_ID != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#" />
			AND		p.VF_Plan_Class_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.classId#" /> <!--- same class id --->
			AND 	p.VF_Plan_Segment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.segmentId#" /> <!--- same segment id --->
			AND		p.Deleted = 0
			AND		p.Forecast_Level != 4
			AND 	NOT EXISTS(
					SELECT 	vfdg.VF_Plan_ID
					FROM	VF_Distributor_Planning_Groups  vfdg
					WHERE 	vfdg.VF_Plan_ID = P.VF_Plan_ID
      				AND		vfdg.Deleted = 0
      				)
		
			SELECT	temp.*
					 , p.Vf_Plan_Number
		       , p.Vf_Plan_Desc
		       , p.Vf_Plan_Id
		       , VF_CLASS.Vf_Class_Desc
		       , Business_Segment.Business_Unit_Desc
			FROM	##tmp_duplicate_plans temp
			INNER JOIN VF_PLAN p ON p.vf_plan_id = temp.vf_plan_id
				 LEFT JOIN VF_CLASS ON VF_CLASS.VF_Class_ID = p.VF_Plan_Class_ID
		  	 LEFT JOIN Business_Segment ON Business_Segment.Business_Segment_ID = p.VF_Plan_Segment_ID			                   
			WHERE	Row_ID = 1
		</cfquery>

		<cfreturn gGetDuplicatePlan />

	</cffunction>

<!--- This Section contains functions related to invoice research from the volume forcast --->
<!--- //////////////////////////////////////////////////////////////////////////////////////////// --->	
<!--- //////////////////////////////////// invoice research ///////////////////////////////////// --->
<!--- ////////////////////////////////////////////////////////////////////////////////////////// --->

	<cffunction name="getInvoiceMarketSegment" output="false" hint="search invoice market segment" returnformat="JSON" access="remote">

		 <cfquery name="qGetInvoiceMarketSegment" datasource="#application.datasource#">
			SELECT 
				ISNULL(INVOICE_HEADER.ORDER_NUMBER,'') AS ORDER_NUMBER
				,ISNULL(CONVERT(VARCHAR(10), INVOICE_HEADER.INVOICE_DATE, 101),'') AS INVOICE_DATE
				-- ,ISNULL(INVOICE_DETAIL.SEQUENCE_NUMBER,'') AS SEQUENCE_NUMBER
				,ISNULL(INVOICE_DETAIL.ITEM,'') AS ITEM
				,ISNULL(BSA_FOODSERVICE_ITEMS_MASTER.DESCRIPTION,'') AS DESCRIPTION
				,ISNULL(INVOICE_HEADER.CURRENT_SHARED_SHIP_TO,'') AS CURRENT_SHARED_SHIP_TO
				,ISNULL(BSA_FOODSERVICE_CUSTOMERS.NAME,'') AS NAME
				,ISNULL(INVOICE_DETAIL.SALES_ORG,'') AS SALES_ORG
				,ISNULL(BUSINESS_SEGMENT.BUSINESS_UNIT_DESC,'') AS BUSINESS_UNIT_DESC
				,ISNULL(INVOICE_DETAIL.MARKET_NUMBER,'') AS MARKET_NUMBER
				,ISNULL(LTRIM(RTRIM(SERVICE_MARKETS.MARKET_NAME)),'') AS MARKET_NAME
				-- ,ISNULL(INVOICE_DETAIL.CASES_INVOICED,'') AS CASES_INVOICED
				-- ,ISNULL(INVOICE_DETAIL.SALES_DOLLARS,'') AS SALES_DOLLARS
			FROM INVOICE_HEADER
			INNER JOIN INVOICE_DETAIL ON INVOICE_HEADER.INVOICE_HEADER_ID = INVOICE_DETAIL.INVOICE_HEADER_ID
			INNER JOIN BUSINESS_SEGMENT ON BUSINESS_SEGMENT.BUSINESS_SEGMENT_ID = INVOICE_DETAIL.BUSINESS_SEGMENT_ID
			INNER JOIN SERVICE_MARKETS ON SERVICE_MARKETS.SERVICE_MARKET_ID = INVOICE_DETAIL.SERVICE_MARKET_ID
			INNER JOIN BSA_FOODSERVICE_CUSTOMERS ON BSA_FOODSERVICE_CUSTOMERS.BSA_FOODSERVICE_CUSTOMERS_ID = INVOICE_HEADER.BSA_FOODSERVICE_CUSTOMERS_ID
			INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER ON BSA_FOODSERVICE_ITEMS_MASTER.BSA_FOODSERVICE_ITEMS_MASTER_ID = INVOICE_DETAIL.BSA_FOODSERVICE_ITEMS_MASTER_ID
			WHERE 1=1 
			<cfif len(arguments.INVOICENUMBER)> AND INVOICE_HEADER.ORDER_NUMBER 				LIKE  								<cfqueryparam value="%#arguments.INVOICENUMBER#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.INVOICEDATE)> 	AND INVOICE_HEADER.INVOICE_DATE 				#arguments.INVOICEDATEOPERATOR#  	<cfqueryparam value="#arguments.INVOICEDATE#"  cfsqltype="cf_sql_date" /> </cfif>
			<cfif len(arguments.ITEMNUMBER)> 	AND INVOICE_DETAIL.ITEM 						LIKE  								<cfqueryparam value="%#arguments.ITEMNUMBER#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.ITEMDESC)> 		AND BSA_FOODSERVICE_ITEMS_MASTER.DESCRIPTION 	LIKE  								<cfqueryparam value="%#arguments.ITEMDESC#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.SHIPTO)> 		AND INVOICE_HEADER.CURRENT_SHARED_SHIP_TO 		LIKE  								<cfqueryparam value="%#arguments.SHIPTO#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.SHIPTONAME)> 	AND BSA_FOODSERVICE_CUSTOMERS.NAME		 		LIKE  								<cfqueryparam value="%#arguments.SHIPTONAME#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.MARKETID)> 		AND INVOICE_DETAIL.MARKET_NUMBER 				LIKE  								<cfqueryparam value="%#arguments.MARKETID#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.MARKETNAME)> 	AND SERVICE_MARKETS.MARKET_NAME 				LIKE  								<cfqueryparam value="%#arguments.MARKETNAME#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.SEGMENTID)> 	AND INVOICE_DETAIL.SALES_ORG	 				LIKE  								<cfqueryparam value="%#arguments.SEGMENTID#%"  cfsqltype="cf_sql_varchar" /> </cfif>
			<cfif len(arguments.SEGMENTNAME)> 	AND BUSINESS_SEGMENT.BUSINESS_UNIT_DESC			LIKE  								<cfqueryparam value="%#arguments.SEGMENTNAME#%"  cfsqltype="cf_sql_varchar" /> </cfif>			 	
			ORDER BY INVOICE_HEADER.ORDER_NUMBER, INVOICE_DETAIL.SEQUENCE_NUMBER
		 </cfquery>
		
		 <cfreturn serializeJSON(qGetInvoiceMarketSegment) />
	</cffunction>

</cfcomponent>
