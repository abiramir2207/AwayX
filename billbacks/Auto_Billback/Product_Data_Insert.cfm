
<CFIF InsertProduct EQ 1>
<CFQUERY NAME="InsertProducts" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		Billback_Product	(	Billback_ID,
								Product_ID,
								Billback_Program_ID,
								BB_Product_UOM,
								Product_Type_ID,
								BB_Product_Quantity		)
								
		VALUES				(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#BSA_Foodservice_Items_Master_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#BBProgramID.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#ThisProgramUOM#" cfsqltype="CF_SQL_VARCHAR">,
								1,
								<cfqueryparam value="#FinalVolume#" cfsqltype="CF_SQL_FLOAT">)
	</CFQUERY>
	
	<CFSET BB_Product_ID = InsertProducts.Billback_Product_ID> 
<CFELSE>
	<CFQUERY NAME="InsertProdDetails" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		Billback_Product_Detail (	Billback_Product_ID,
									Billback_ID,
									BB_Product_Type_ID,
									BB_Rate					)
									
		VALUES					(	<cfqueryparam value="#BB_Product_ID#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#BB_Product_Type_ID#" cfsqltype="CF_SQL_INTEGER">,
									<cfqueryparam value="#FinalRate#" cfsqltype="CF_SQL_FLOAT">)
	</CFQUERY>
	
</CFIF>