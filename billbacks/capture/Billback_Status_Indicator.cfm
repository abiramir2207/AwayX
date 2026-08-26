<cfparam name="thisbbid" default="">
<CFSET tabstoturnon = "">

<CFIF len(trim(thisbbid)) NEQ 0 AND trim(thisbbid) NEQ 0>
	<cfset useLakebaseForBI_Tab_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForBI_Tab_Info>
	<cftry>
		<cfset BI_Tab_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#thisbbid#",
				"deleted" = "eq.0",
				"select" = "billback_id,billback_payee_type_id,billback_status_id"
			}), "billback_id,billback_payee_type_id,billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBI_Tab_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBI_Tab_Info>
<cfquery name="BI_Tab_Info" datasource="#Application.Datasource#" maxrows=1>
		SELECT Billback_ID, Billback_Payee_Type_ID, Billback_Status_ID
		FROM Billback
		WHERE Billback_ID = '#thisbbid#' AND Deleted = 0
	</cfquery>
</cfif>

	<!--- basic information --->
	<CFIF BI_Tab_Info.recordcount GT 0>
		<CFSET tabstoturnon = listappend(tabstoturnon,10)>
	</CFIF>

	<!--- payee --->
	<CFIF len(trim(BI_Tab_Info.Billback_Payee_Type_ID)) NEQ 0 AND trim(BI_Tab_Info.Billback_Payee_Type_ID) NEQ 0>
		<CFSET tabstoturnon = listappend(tabstoturnon,20)>		
	</CFIF>
	
	<cfquery name="getBBPrograms" datasource="#Application.Datasource#">
		SELECT     dbo.Billback_Program.Billback_ID
		FROM         dbo.Billback_Program INNER JOIN
		                      dbo.Billback_Product ON dbo.Billback_Program.Billback_Program_ID = dbo.Billback_Product.Billback_Program_ID
		WHERE     (dbo.Billback_Product.Deleted = 0) AND (dbo.Billback_Program.Deleted = 0) AND (dbo.Billback_Program.Billback_ID = '#thisbbid#')
	</cfquery>
	
	<!--- Program --->
	<CFIF getBBPrograms.recordcount GT 0>
		<CFSET tabstoturnon = listappend(tabstoturnon,30)>		
	</CFIF>
	
	<!--- Program --->
	<CFIF BI_Tab_Info.recordcount GT 0>
		<CFIF BI_Tab_Info.Billback_Status_ID EQ 3>
			<CFSET tabstoturnon = listappend(tabstoturnon,40)>		
		</CFIF>
	</CFIF>
	
</CFIF>

<CFIF listlen(tabstoturnon) GT 0>
	<script>
	<cfloop index="x" list="#tabstoturnon#">
		window.parent.statusFlagControl(<cfoutput>#x#</cfoutput>,3);		
	</CFLOOP>
	</script>
</CFIF>

	