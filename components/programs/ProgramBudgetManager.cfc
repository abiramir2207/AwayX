<cfcomponent hint="Program Budget Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.ProgramBudgetManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getDiscountClassCodeBudgetInfo" output="false" returntype="query">
	
		<cfargument name="programId" type="numeric" required="true" />
	
		<cfquery name="qGetDiscountClassCodeBudgetInfo" datasource="#application.datasource#">

			SELECT	Discount_Type.Discount_Type_ID, Discount_Type.Discount_Type_Desc, 
					Budget_Group_Class_Code.Class_Code_ID, Class_Code.Class_Code_Desc,
					Budget_Group_Class_Code.Real_Breakout_percentage,
					Budget_Group_Class_Code.New_Breakout_Percentage,
					ISNULL(SUM(Budget_Group_Class_Code.Group_Amount), 0) Group_Amount, 
					ISNULL(SUM(Budget_Group_Class_Code.Amount), 0) Amount
			FROM	Budget_Group_Class_Code
					INNER JOIN Discount_Type
					ON
					Discount_Type.Discount_Type_ID = Budget_Group_Class_Code.Discount_Type_ID
					INNER JOIN Class_Code
					ON
					Class_Code.Class_Code_ID = Budget_Group_Class_Code.Class_Code_ID
			WHERE	Budget_Group_Class_Code.Deleted = 0
			AND		Budget_Group_Class_Code.Program_ID = #arguments.programId#
			GROUP BY Discount_Type.Discount_Type_ID, Discount_Type.Discount_Type_Desc, 
					Budget_Group_Class_Code.Class_Code_ID, Class_Code.Class_Code_Desc, 
					Budget_Group_Class_Code.Real_Breakout_percentage, Budget_Group_Class_Code.New_Breakout_Percentage
			ORDER BY Class_Code.Class_Code_Desc
		</cfquery>
		
		<cfreturn qGetDiscountClassCodeBudgetInfo />
		
	</cffunction>
	
	<cffunction name="getDiscountClassCodeGroupBudgetInfo" output="false" returntype="query">
	
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="discountTypeID" type="numeric" required="true" />
		<cfargument name="classCodeID" type="numeric" required="true" />
	
		<cfquery name="qGetDiscountClassCodeGroupBudgetInfo" datasource="#application.datasource#">

			SELECT	BSA_Foodservice_Items_master.Description, Discount_Type.Discount_Type_Desc, 
					Class_Code.Class_Code_Desc,					
					Budget_Group_Class_Code.Group_ID,
					Budget_Group_Class_Code.Real_Breakout_Percentage,
					Budget_Group_Class_Code.Group_Breakout_Percentage,
					ISNULL(Budget_Group_Class_Code.Group_Amount, 0) Group_Amount, 
					ISNULL(Budget_Group_Class_Code.Expected_Sales, 0) Expected_Sales,
					ISNULL(Budget_Group_Class_Code.Amount, 0) Amount
			FROM	Budget_Group_Class_Code
					INNER JOIN Discount_Type
					ON
					Discount_Type.Discount_Type_ID = Budget_Group_Class_Code.Discount_Type_ID
					INNER JOIN Class_Code
					ON
					Class_Code.Class_Code_ID = Budget_Group_Class_Code.Class_Code_ID
					INNER JOIN BSA_Foodservice_Items_master
					ON
					CAST(BSA_Foodservice_Items_master.BSA_Foodservice_Items_master_ID AS NVARCHAR(50)) = Budget_Group_Class_Code.Group_ID
			WHERE	Budget_Group_Class_Code.Deleted = 0
			AND		Budget_Group_Class_Code.Program_ID = #arguments.programId#
			AND		Budget_Group_Class_Code.Discount_Type_ID = #arguments.discountTypeID#
			AND		Budget_Group_Class_Code.Class_Code_ID = #arguments.classCodeID#
			ORDER BY Class_Code.Class_Code_Desc
		</cfquery>
		
		<cfreturn qGetDiscountClassCodeGroupBudgetInfo />
		
	</cffunction>
	
</cfcomponent>