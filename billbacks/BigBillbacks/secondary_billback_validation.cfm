<!--- <cfdump var="#form#"> --->

<!---Delete deleted entries --->
<cfif isDefined("form.BB_To_Delete")>
	<cfquery name="DeleteBigBillbacks" datasource="#application.datasource#">
	UPDATE Big_Billback
	SET Deleted = 1
	WHERE Big_Billback_ID IN (#form.BB_To_Delete#)
	</cfquery>
</cfif>

<!--- Get list of BBBS we'll be iterating through --->
<cfquery name="BillbacksforIteration" datasource="#application.datasource#">
	SELECT Big_Billback_ID FROM Big_Billback 
	WHERE Big_Billback_ID IN (#form.BigBillbackIDList#)
	AND Deleted = 0
</cfquery>

<!--- Update Big_Billback with new values --->
<cfloop query="BillbacksforIteration">
		
		<cfset DistVal = evaluate("Form.Distributor_#Big_Billback_ID#")>
		<cfset ProdVal = evaluate("Form.Product_#Big_Billback_ID#")>
	

	<cfquery name="Updatevalues" datasource="#application.datasource#">
	UPDATE Big_Billback
	SET Distributor = <cfqueryparam value="#DistVal#" cfsqltype="CF_SQL_VARCHAR">,
		Product		= <cfqueryparam value="#ProdVal#" cfsqltype="CF_SQL_VARCHAR">,
		Volume		= '#evaluate("form.Volume_#Big_Billback_ID#")#',
		Amount		= '#evaluate("form.Amount_#Big_Billback_ID#")#',
		UOM			= '#evaluate("form.UOM_#Big_Billback_ID#")#',
		Has_Error	= 0,
		Distributor_Error = 0,
		Product_Error = 0,
		Amount_Error = 0
	WHERE Big_Billback_ID = '#BillbacksforIteration.Big_Billback_ID#'
	</cfquery> 

</cfloop>

<!--- Create entries in table to be processed by SP_BIG_BILLBACK_VALIDATION --->
<cfquery name="InsertIntoBigBillbackTemp" datasource="#application.datasource#">
INSERT INTO Big_Billback_Temp
(Billback_ID, Big_Billback_ID)
SELECT Billback_ID, Big_Billback_ID FROM Big_Billback WHERE Big_Billback_ID IN (#form.BigBillbackIDList#) AND Deleted = 0
</cfquery>

<!--- Rerun stored proc --->
<cfquery name="ExecuteSP" datasource="#application.datasource#"> 
	exec SP_BIG_BILLBACK_VALIDATION '#Billback_ID#'
	</cfquery> 
	
<!--- Delete entries in table as no longer needed --->	
<cfquery name="DeleteFromBigBillbackTemp" datasource="#application.datasource#">
DELETE Big_Billback_Temp
WHERE Billback_ID = '#Billback_ID#'
</cfquery>

<script>
nextTabToComplete(deviations);
</script>

<!--- Redirect back to bulk bigbillback_validation.cfm --->
<cflocation url="bigbillback_validation.cfm?Billback_ID=#form.Billback_ID#&Big_Billback_Summary_ID=#Big_Billback_Summary_ID#">