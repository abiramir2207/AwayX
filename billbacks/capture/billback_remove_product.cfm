<cfparam name="form.Billback_Product_ID" default="">
<cfparam name="form.Billback_ID" default="">
<cfparam name="form.Billback_Program_ID" default="">

<!--- all the data to delete a product --->
<CFIF len(form.Billback_Product_ID) GT 0>
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
</CFIF>

<CFIF  (len(form.Billback_ID) + len(form.Billback_Program_ID)) GT 0 AND  len(form.Billback_Product_ID) EQ 0>
	<cfquery name="removeProgramFromBillback" datasource="#Application.Datasource#">
		UPDATE Billback_Program
		SET Deleted = 1
		WHERE
			Billback_ID				= '#form.Billback_ID#'
			AND
			Billback_Program_ID		= '#form.Billback_Program_ID#'
	</cfquery>

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
