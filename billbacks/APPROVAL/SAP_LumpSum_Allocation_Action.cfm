<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFDUMP VAR="#FORM#">

<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
	UPDATE BB_Lump_Sum_Allocation 
	SET Deleted = 1 
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
</CFQUERY>

<CFLOOP LIST="#FORM.Product_Hierarchy_List#" INDEX="Item">
	<CFSET ReplacedHierarchyID = REPLACE(Item,"-","_","All")>
	
	<CFQUERY NAME="InsertNew" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		BB_Lump_Sum_Allocation	(	Billback_ID,
									Product_Hierarchy_ID,
									Allocated_By,
									Allocated_Amount		)
									
		VALUES					(	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#Item#" cfsqltype="CF_SQL_VARCHAR">,
									<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
									<CFIF EVALUATE("FORM.Amount_#ReplacedHierarchyID#") NEQ "">
										<cfqueryparam value="#EVALUATE("FORM.Amount_#ReplacedHierarchyID#")#" cfsqltype="CF_SQL_FLOAT">
									<CFELSE>
										0
									</CFIF>
									)
	</CFQUERY>
</CFLOOP>

<CFLOCATION URL="SAP_Settlement_PayReq.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
</body>
</html>
