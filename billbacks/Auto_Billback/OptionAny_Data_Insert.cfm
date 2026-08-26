

<CFQUERY NAME="InsertRateInAny" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	Billback_Auto_Any_Option (	Billback_ID,
								Billback_Product_ID,
								BB_Product_Type_ID,
								Unit_Rate,
								Unit_Of_Measure		)
								
	VALUES					(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#BB_Product_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#ProductTypeForAny#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#RateForAny#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#ThisProgramUOM#" cfsqltype="CF_SQL_VARCHAR">)	
</CFQUERY>
