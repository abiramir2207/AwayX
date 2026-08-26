<cfparam name="form.Billback_Product_ID" default="">
<cfparam name="form.Billback_ID" default="">
<cfparam name="form.Billback_Program_ID" default="">

<!--- all the data to delete a product --->
<CFIF len(form.Billback_Product_ID) GT 0>
	<cfset useLakebaseForremoveProductFromBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForremoveProductFromBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product",
			{
				"billback_product_id" = "eq.#form.Billback_Product_ID#",
				"billback_id" = "eq.#form.Billback_ID#",
				"billback_program_id" = "eq.#form.Billback_Program_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForremoveProductFromBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForremoveProductFromBillback>
<cfquery name="removeProductFromBillback" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = 1
		WHERE
			Billback_Product_ID		= '#form.Billback_Product_ID#'
			AND
			Billback_ID				= '#form.Billback_ID#'
			AND
			Billback_Program_ID		= '#form.Billback_Program_ID#'
	</cfquery>
</cfif>
</CFIF>

<CFIF  (len(form.Billback_ID) + len(form.Billback_Program_ID)) GT 0 AND  len(form.Billback_Product_ID) EQ 0>
	<cfset useLakebaseForremoveProgramFromBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForremoveProgramFromBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program",
			{
				"billback_id" = "eq.#form.Billback_ID#",
				"billback_program_id" = "eq.#form.Billback_Program_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForremoveProgramFromBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForremoveProgramFromBillback>
<cfquery name="removeProgramFromBillback" datasource="#Application.Datasource#">
		UPDATE Billback_Program
		SET Deleted = 1
		WHERE
			Billback_ID				= '#form.Billback_ID#'
			AND
			Billback_Program_ID		= '#form.Billback_Program_ID#'
	</cfquery>
</cfif>

	<cfquery name="removeProductFromBillback" datasource="#Application.Datasource#">
		UPDATE Billback_Product
		SET Deleted = 1
		WHERE
			Billback_ID				= '#form.Billback_ID#'
			AND
			Billback_Program_ID		= '#form.Billback_Program_ID#'
	</cfquery>
</CFIF>

<CFLOCATION url="program_form.cfm?BBID=#FORM.Billback_ID#">
