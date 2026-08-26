<CFCOMPONENT HINT="Log 1520 Data Insert" DISPLAYNAME="Log1520DataInsert">	
	<cfset this.Deduction_ID = ""> 

	<cffunction name="init" output="false" returntype="components.Interfaces.log1520">
		<cfargument name="Deduction_ID" required="true" default="" />
		<cfset setDeduction_ID(arguments.Deduction_ID) />
		<cfreturn this />		
	</cffunction>
		
	<!--- Deduction_ID setter --->
	<cffunction name="setDeduction_ID" access="public" output="false">
		<cfargument name="Deduction_ID" required="true" default="" />
		<cfset this.Deduction_ID = arguments.Deduction_ID />
	</cffunction>
	
	<!--- Deduction_ID getter --->
	<cffunction name="getDeduction_ID" access="public" output="false">
		<cfreturn this.Deduction_ID/>
	</cffunction>
	
	<cffunction name="AddtoLog" output="false" returntype="void">
		<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
			UPDATE Log_1520 SET Deleted = 1 WHERE Deduction_ID = '#getDeduction_ID()#' AND Current_Insert = 1 AND Deleted = 0
		</CFQUERY>	
		<CFQUERY NAME="InsertData" DATASOURCE="#Application.Datasource#">
			INSERT INTO
			Log_1520	(	Deduction_ID,
							DD_DedID,	
							Business,													
							Distributor_ID,
							Shr_Ship_To,							
							DD_Rejected_Date,
							DD_Rejected_By,
							DD_Rejected_Name_First,
							DD_Rejected_Name_Last,
							Current_Insert	)
							
			SELECT 			Deductions.Deduction_ID,							
							DD_DedID,
							'2',
							CASE WHEN Deductions.Distributor_ID IS NULL THEN Deductions.Distributor_Bill_To_ID ELSE Deductions.Distributor_ID END,
							CASE WHEN Deductions.Distributor_ID IS NULL THEN Distributor_Bill_To.Shr_Bill_To ELSE BSA_Foodservice_Customers.Shr_Ship_To END,		
							DD_Rejected_Date,
							DD_Rejected_By,
							Name_First,
							Name_Last,
							<!--- Ana 15454 - Commentting to avoid DeadLock --->							
							0
														
			FROM 		Deductions
			LEFT JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
			LEFT JOIN 	Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
			INNER JOIN 	_Users ON _Users.User_ID = Deductions.DD_Rejected_By			

			WHERE 		Deductions.Deduction_ID = '#getDeduction_ID()#'
		</CFQUERY>				
	</cffunction>
	
</CFCOMPONENT>
