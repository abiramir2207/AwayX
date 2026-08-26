<cfcomponent displayname="BudgetReport" hint="Queries for budget reporting">

<!--- This is the search query -- the main one returning results --->
<cffunction name="getBudgetSummaryReport" output="true" returntype="query" access="remote">
		<cfargument name="userId" required="true">
		
		<cfset var qGetBudgetSummaryReport = "">
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetSummaryReport" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
			SELECT 	User_Positions_ID
			INTO	##Tmp_User_Positions
			FROM 	User_Position_Holders
			WHERE 	User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
			AND 	Deleted = 0
			AND		User_Positions_ID != 0
			
			SELECT	DISTINCT Below_User_Positions_ID as Allow_User_Positions_ID
			INTO	##Tmp_Allow_User_Positions_ID
			FROM	Positions_Below_Me
			WHERE	User_Positions_ID IN (SELECT User_Positions_ID FROM ##Tmp_User_Positions)
			UNION
			SELECT	DISTINCT Above_User_Positions_ID as Allow_User_Positions_ID
			FROM	Positions_Above_Me
			WHERE	User_Positions_ID IN (SELECT User_Positions_ID FROM ##Tmp_User_Positions)

			SELECT 	Simple_Budget.Simple_Budget_ID, Simple_Budget_Class.Simple_Budget_Class_ID, 
					Simple_Budget_Class.Simple_Budget_Class_Number + ' ' + Simple_Budget_Class_Desc AS Simple_Budget_Class,
					Simple_Budget.Simple_Budget_Number +  ' ' + Simple_Budget_Desc AS Budget,
					Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
					User_Positions.User_Positions_ID, User_Positions.Position_Label,
					ISNULL(SUM(Simple_Budget_Template_Position_Allocation.Allocated_Budget_Dollar), 0) as Sum_Budget_Dollar, 
					ISNULL(SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Committed_Dollar, 0)), 0) as Sum_Committed_Dollar,
					ISNULL(SUM(ISNULL(Simple_Budget_Template_Position_Allocation.Actual_Dollar, 0)), 0) as Sum_Actual_Dollar
			FROM 	Simple_Budget
			
			INNER JOIN Simple_Budget_Class_Association
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Class_Association.Simple_Budget_ID
			AND		Simple_Budget_Class_Association.Deleted = 0
			AND		Simple_Budget_Class_Association.Active = 1
			
			INNER JOIN Simple_Budget_Class
			ON		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Class_Association.Simple_Budget_Class_ID

			INNER JOIN Simple_Budget_Template_Mapping	
			ON		Simple_Budget.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			AND		Simple_Budget_Class.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			AND		Simple_Budget_Template_Mapping.Deleted = 0
			
			INNER JOIN Simple_Budget_Template_Position_Allocation
			ON		Simple_Budget_Template_Position_Allocation.Deleted = 0
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_ID = Simple_Budget_Template_Mapping.Simple_Budget_ID
			AND		Simple_Budget_Template_Position_Allocation.Simple_Budget_Class_ID = Simple_Budget_Template_Mapping.Simple_Budget_Class_ID
			AND		Simple_Budget_Template_Position_Allocation.Template_Parent_ID = Simple_Budget_Template_Mapping.Template_Parent_ID
			AND		Simple_Budget_Template_Position_Allocation.User_Positions_ID IN (SELECT Allow_User_Positions_ID FROM ##Tmp_Allow_User_Positions_ID)
			
			INNER JOIN User_Positions
			ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
			
			WHERE	Simple_Budget.Deleted = 0
			
			GROUP BY 	Simple_Budget.Simple_Budget_ID, Simple_Budget_Class.Simple_Budget_Class_ID,
						Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
						Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc,
						Simple_Budget_Class_Association.Simple_Budget_Class_Association_Number,
						User_Positions.User_Positions_ID, User_Positions.Position_Label
			
			ORDER BY 	Simple_Budget_Class.Simple_Budget_Class_Number, Simple_Budget_Class_Desc,
						Simple_Budget.Simple_Budget_Number, Simple_Budget_Desc,
						User_Positions.Position_Label
						
			drop table ##Tmp_User_Positions
			drop table ##Tmp_Allow_User_Positions_ID
		</cfquery>
		
		<cfreturn qGetBudgetSummaryReport />
		
	</cffunction>

	<!--- This drives the dropdowns --->
	
	<cffunction name="getClasses" output="false" returntype="query" access="remote">
			
		<cfset var qGetClasses = "">		
		<!--- get the template mapping --->
		<cfquery name="qGetClasses" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	Simple_Budget_Class_ID,
					Simple_Budget_Class_Number,
          /* Simple_Budget_Class_Desc  */
					Simple_Budget_Class_Number + ' ' + Simple_Budget_Class_Desc AS Simple_Budget_Class_Desc
			FROM	Simple_Budget_Class
			WHERE	Active 	= 1
			AND		Deleted = 0
			ORDER BY Simple_Budget_Class_Desc
		</cfquery>
		
		<cfreturn qGetClasses />
			
	</cffunction>
		
	<cffunction name="getSimpleBudget" output="false" returntype="query" access="remote">
			
		<cfset var qGetSimpleBudget = "">
		
		<!--- get the template mapping --->
		<cfquery name="qGetSimpleBudget" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	Simple_Budget.Simple_Budget_Number +  ' ' + Simple_Budget_Desc AS SimpleBudget
			FROM	Simple_Budget
			WHERE	Active = 1
			AND		Deleted = 0
			ORDER BY Simple_Budget_Desc
		</cfquery>
		
		<cfreturn qGetSimpleBudget />
			
	</cffunction>
	
	<cffunction name="getBudgetAssociation" output="false" returntype="query" access="remote">
			
		<cfset var qGetBudgetAssociation = "">
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetAssociation" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	Simple_Budget_Class_Association_ID,
					Simple_Budget_Class_Association_Number
			FROM	Simple_Budget_Class_Association
			WHERE	Active = 1
			AND		Deleted = 0
			ORDER BY Simple_Budget_Class_Association_Number
		</cfquery>
		
		<cfreturn qGetBudgetAssociation />
			
	</cffunction>
	
	<cffunction name="getUserPositions" output="false" returntype="query" access="remote">
		<cfset var qGetUserPositions = "">
		
		<!--- get the template mapping --->
		<cfquery name="qGetUserPositions" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	User_Positions.User_Positions_ID,
					User_Positions.Position_Label
			FROM	User_Positions
			INNER JOIN Simple_Budget_Template_Position_Allocation	
				ON		User_Positions.User_Positions_ID = Simple_Budget_Template_Position_Allocation.User_Positions_ID
				AND		Simple_Budget_Template_Position_Allocation.Deleted = 0
			WHERE	User_Positions.Deleted = 0
			AND		User_Positions.Position_Label != ''
			ORDER BY User_Positions.Position_Label
		</cfquery>
		<cfreturn qGetUserPositions />			
	</cffunction>
	
	<cffunction name="getBudgetLabels" output="false" returntype="query" access="remote">
		<cfset var qGetBudgetLabels = "">
		
		<!--- get the template mapping --->
		<cfquery name="qGetBudgetLabels" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	isnull(SBL.Budget_Dollar_Label, 'Budget $') AS Budget_Dollar_Label,
					isnull(SBL.Committed_Dollar_Label, 'Committed $') AS Committed_Dollar_Label,
					isnull(SBL.Budget_Balance_Label, 'Budget Balance') AS Budget_Balance_Label,
					isnull(SBL.Approved_Payment_Dollar_Label, 'Approved Payment $') AS Approved_Payment_Dollar_Label,
					isnull(SBL.Available_Budget_Dollar_Label, 'Approved Payment $') AS Available_Budget_Dollar_Label,
					isnull(SBL.Budget_Class_Association_Label, 'Budget Association') AS Budget_Class_Association_Label
			FROM	Simple_Budget_Labels SBL
		</cfquery>
		<cfreturn qGetBudgetLabels />			
	</cffunction>
	

</cfcomponent>