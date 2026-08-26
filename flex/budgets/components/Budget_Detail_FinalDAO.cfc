<cfcomponent output="false">

	<cffunction name="read" output="false" access="public" returntype="flex.budgets.components.Budget_Detail_FinalBean">
		<cfargument name="id" required="true">
		<cfset var obj="">

		<cfquery name="qGetControlLevelMetaData" datasource="#application.datasource#">
			SELECT	Budget.Control_Level_1, Budget.Control_Level_2
			FROM	Budget
			LEFT JOIN Budget_Detail_Allocation
			On Budget.Budget_ID = Budget_Detail_Allocation.Budget_ID
			Where Budget_Detail_Allocation.Budget_Detail_Allocation_ID = '#arguments.id#'
		</cfquery>
		
		<cfset BudgetGroupLevelManager = CreateObject("component", "components.settings.budget.BudgetGroupLevelManager").init() />
		<cfset controlLevel1MetaData = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = qGetControlLevelMetaData.Control_Level_1, active = -1) /> 
		<cfset controlLevel2MetaData = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = qGetControlLevelMetaData.Control_Level_2, active = -1) /> 
		
		<cfif ArrayLen(controlLevel1MetaData) AND ArrayLen(controlLevel2MetaData)>
			<!------ TODO: handle for the case where there is no level 2 selected ----->
				<cfset BudgetGroupLevel_1 = controlLevel1MetaData[1] />
				<cfset BudgetGroupLevel_2 = controlLevel2MetaData[1] />
			
			<cfquery name="qRead" datasource="#application.datasource#">
				SELECT		Budget_Detail_Allocation.Budget_ID, 
							Budget_Detail_Allocation.Budget_Detail_Allocation_ID,
							Control_Level_1.#BudgetGroupLevel_1.numberField# as Control_Level_1_Number, 
							Control_Level_1.#BudgetGroupLevel_1.nameField# as Control_Level_1_Name, 
							Control_Level_2.#BudgetGroupLevel_2.numberField# as Control_Level_2_Number, 
							Control_Level_2.#BudgetGroupLevel_2.nameField# as Control_Level_2_Name,
							Budget_Detail_Allocation.Level_Value, 
							Budget_Detail_Allocation.Level_Value_Percentage,
							Budget_Detail_Allocation.New_Level_Value, 
							Budget_Detail_Allocation.New_Level_Value_Percentage,
							ISNULL(Total_Manual_Quantity,0) AS Manual_Qty, 
							ISNULL(Total_Manual_Percentage,0) AS Manual_Percentage, 
							'' AS Manual_Comments,
							'100' AS Budget_Adjustment_Change,
							BUDGET.BUDGET_VALUE
				FROM		Budget_Detail_Allocation
				LEFT JOIN 	#BudgetGroupLevel_1.tableName# AS Control_Level_1
							ON	Control_Level_1.#BudgetGroupLevel_1.iDField# = Budget_Detail_Allocation.Control_Level_1_ID
				LEFT JOIN 	#BudgetGroupLevel_2.tableName# AS Control_Level_2
							ON	Control_Level_2.#BudgetGroupLevel_2.iDField# = Budget_Detail_Allocation.Control_Level_2_ID
				LEFT JOIN 	BUDGET
							ON BUDGET.BUDGET_ID = BUDGET_DETAIL_ALLOCATION.BUDGET_ID
				WHERE		Budget_Detail_Allocation.BUDGET_DETAIL_ALLOCATION_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				ORDER BY	Control_Level_1.#BudgetGroupLevel_1.nameField#, 
							Control_Level_2.#BudgetGroupLevel_2.nameField#	
			</cfquery>
		</cfif>

		<cfscript>
			obj = createObject("component", "flex.budgets.components.Budget_Detail_FinalBean").init();
			obj.setBudget_Detail_Allocation_ID(qRead.Budget_Detail_Allocation_ID);
			obj.setBudget_ID(qRead.Budget_ID);
			obj.setControl_Level_1_Number(qRead.Control_Level_1_Number);
			obj.setControl_Level_2_Number(qRead.Control_Level_2_Number);
			obj.setControl_Level_1_Name(qRead.Control_Level_1_Name);
			obj.setControl_Level_2_Name(qRead.Control_Level_2_Name);
			obj.setLevel_Value(qRead.Level_Value);
			obj.setLevel_Value_Percentage(qRead.Level_Value_Percentage);
			obj.setNew_Level_Value(qRead.New_Level_Value);
			obj.setNew_Level_Value_Percentage(qRead.New_Level_Value_Percentage);
			obj.setManual_Qty(qRead.Manual_Qty);
			obj.setManual_Percentage(qRead.Manual_Percentage);
			obj.setManual_Comments(qRead.Manual_Comments);
			obj.setBudget_Adjustment_Change(qRead.Budget_Adjustment_Change);
			obj.setBudget_Value(qRead.Budget_Value);
			return obj;
		</cfscript>
	</cffunction>



	<cffunction name="create" output="false" access="public" returntype="void">
		<cfargument name="bean" required="true" type="flex.budgets.components.Budget_Detail_FinalBean">
		<cfset var qCreate="">
		<cfset var qGetId="">
		<cfset var local1=arguments.bean.getBudget_ID()>
		<cfset var local2=arguments.bean.getControl_Level_1()>
		<cfset var local3=arguments.bean.getControl_Level_2()>
		<cfset var local4=arguments.bean.getControl_Level_1_ID()>
		<cfset var local5=arguments.bean.getControl_Level_2_ID()>
		<cfset var local6=arguments.bean.getLevel_Value()>
		<cfset var local7=arguments.bean.getLevel_Value_Percentage()>
		<cfset var local8=arguments.bean.getNew_Level_Value()>
		<cfset var local9=arguments.bean.getNew_Level_Value_Percentage()>
		<cfset var local13=arguments.bean.getManual_Qty()>
		<cfset var local14=arguments.bean.getManual_Percentage()>
		<cfset var local15=arguments.bean.getManual_Comments()>
		<cfset var local16=arguments.bean.getBudget_Adjustment_Change()>
		<cfset var local17=arguments.bean.getBudget_Value()>		

		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				insert into Budget_Detail_Allocation
						(	Budget_ID, 
							Control_Level_1, 
							Control_Level_2, 
							Control_Level_1_ID, 
							Control_Level_2_ID, 
							Level_Value, 
							Level_Value_Percentage, 
							New_Level_Value, 
							New_Level_Value_Percentage, 
							Manual_Qty,
							Manual_Percentage,
							Manual_Comments, 
							Budget_Adjustment_Change, 
							Budget_Value)
				values (
					<cfqueryparam value="#local1#" cfsqltype="CF_SQL_INTEGER" null="#iif((local1 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local2#" cfsqltype="CF_SQL_CHAR" />,
					<cfqueryparam value="#local3#" cfsqltype="CF_SQL_CHAR" />,
					<cfqueryparam value="#local4#" cfsqltype="CF_SQL_CHAR" />,
					<cfqueryparam value="#local5#" cfsqltype="CF_SQL_CHAR" />,
					<cfqueryparam value="#local6#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local6 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local7#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local7 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local8#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local8 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local9#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local9 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local13#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local13 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local14#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local14 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local15#" cfsqltype="CF_SQL_CHAR" />,
					<cfqueryparam value="#local16#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local16 eq ""), de("yes"), de("no"))#" />,
					<cfqueryparam value="#local17#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local17 eq ""), de("yes"), de("no"))#" />
				)
			</cfquery>

			<!--- If your server has a better way to get the ID that is more reliable, use that instead --->
			<cfquery name="qGetID" datasource="#application.datasource#">
				select Budget_Detail_Allocation_ID
				from dbo.Budget_Detail_Allocation
				where Budget_ID = <cfqueryparam value="#local1#" cfsqltype="CF_SQL_INTEGER" null="#iif((local1 eq ""), de("yes"), de("no"))#" />
				  and Control_Level_1 = <cfqueryparam value="#local2#" cfsqltype="CF_SQL_CHAR" />
				  and Control_Level_2 = <cfqueryparam value="#local3#" cfsqltype="CF_SQL_CHAR" />
				  and Control_Level_1_ID = <cfqueryparam value="#local4#" cfsqltype="CF_SQL_CHAR" />
				  and Control_Level_2_ID = <cfqueryparam value="#local5#" cfsqltype="CF_SQL_CHAR" />
				  and Level_Value = <cfqueryparam value="#local6#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local6 eq ""), de("yes"), de("no"))#" />
				  and Level_Value_Percentage = <cfqueryparam value="#local7#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local7 eq ""), de("yes"), de("no"))#" />
				  and New_Level_Value = <cfqueryparam value="#local8#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local8 eq ""), de("yes"), de("no"))#" />
				  and New_Level_Value_Percentage = <cfqueryparam value="#local9#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local9 eq ""), de("yes"), de("no"))#" />
				  and Manual_Qty = <cfqueryparam value="#local13#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local13 eq ""), de("yes"), de("no"))#" />
				  and Manual_Percentage = <cfqueryparam value="#local14#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local14 eq ""), de("yes"), de("no"))#" />
				  and Manual_Comments = <cfqueryparam value="#local15#" cfsqltype="CF_SQL_CHAR" />
				  and Budget_Adjustment_Change = <cfqueryparam value="#local16#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local16 eq ""), de("yes"), de("no"))#" />
				  and Budget_Value = <cfqueryparam value="#local17#" cfsqltype="CF_SQL_DECIMAL" null="#iif((local17 eq ""), de("yes"), de("no"))#" />
				order by Budget_Detail_Allocation_ID desc
			</cfquery>
		</cftransaction>

		<cfscript>
			arguments.bean.setBudget_Detail_Allocation_ID(qGetID.Budget_Allocation_Detail_ID);
		</cfscript>
	</cffunction>



	<cffunction name="update" output="false" access="public" returntype="void">
		<cfargument name="bean" required="true" type="flex.budgets.components.Budget_Detail_FinalBean">
		<cfset var qUpdate="">

		<cfquery name="qUpdate" datasource="#application.datasource#" result="status">
			update dbo.Budget_Detail_Allocation_
			set Budget_ID = <cfqueryparam value="#arguments.bean.getBudget_ID()#" cfsqltype="CF_SQL_INTEGER" null="#iif((arguments.bean.getBudget_ID() eq ""), de("yes"), de("no"))#" />,
				Control_Level_1 = <cfqueryparam value="#arguments.bean.getControl_Level_1()#" cfsqltype="CF_SQL_CHAR" />,
				Control_Level_2 = <cfqueryparam value="#arguments.bean.getControl_Level_2()#" cfsqltype="CF_SQL_CHAR" />,
				Control_Level_1_ID = <cfqueryparam value="#arguments.bean.getControl_Level_1_ID()#" cfsqltype="CF_SQL_CHAR" />,
				Control_Level_2_ID = <cfqueryparam value="#arguments.bean.getControl_Level_2_ID()#" cfsqltype="CF_SQL_CHAR" />,
				Level_Value = <cfqueryparam value="#arguments.bean.getLevel_Value()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getLevel_Value() eq ""), de("yes"), de("no"))#" />,
				Level_Value_Percentage = <cfqueryparam value="#arguments.bean.getLevel_Value_Percentage()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getLevel_Value_Percentage() eq ""), de("yes"), de("no"))#" />,
				New_Level_Value = <cfqueryparam value="#arguments.bean.getNew_Level_Value()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getNew_Level_Value() eq ""), de("yes"), de("no"))#" />,
				New_Level_Value_Percentage = <cfqueryparam value="#arguments.bean.getNew_Level_Value_Percentage()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getNew_Level_Value_Percentage() eq ""), de("yes"), de("no"))#" />,
				Manual_Qty = <cfqueryparam value="#arguments.bean.getManual_Qty()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getManual_Qty() eq ""), de("yes"), de("no"))#" />,
				Manual_Percentage = <cfqueryparam value="#arguments.bean.getManual_Percentage()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getManual_Percentage() eq ""), de("yes"), de("no"))#" />,
				Manual_Comments = <cfqueryparam value="#arguments.bean.getManual_Comments()#" cfsqltype="CF_SQL_CHAR" />,
				Budget_Adjustment_Change = <cfqueryparam value="#arguments.bean.getBudget_Adjustment_Change()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getBudget_Adjustment_Change() eq ""), de("yes"), de("no"))#" />,
				Budget_Value = <cfqueryparam value="#arguments.bean.getBudget_Value()#" cfsqltype="CF_SQL_DECIMAL" null="#iif((arguments.bean.getBudget_Value() eq ""), de("yes"), de("no"))#" />
			where Budget_Detail_Allocation_ID = <cfqueryparam value="#arguments.bean.getBudget_Detail_Allocation_ID()#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
	</cffunction>



	<cffunction name="delete" output="false" access="public" returntype="void">
		<cfargument name="bean" required="true" type="flex.budgets.components.Budget_Detail_FinalBean">
		<cfset var qDelete="">

		<cfquery name="qDelete" datasource="#application.datasource#" result="status">
			delete
			from dbo.Budget_Detail_Allocation
			where Budget_Detail_Allocation = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.bean.getBudget_Detail_Allocation_ID()#" />
		</cfquery>

	</cffunction>


</cfcomponent>