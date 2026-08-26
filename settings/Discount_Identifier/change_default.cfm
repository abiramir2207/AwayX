<cftransaction>
<!---Remove old one--->
	<cfquery name="RemoveOldDefault" datasource="#application.datasource#">
	UPDATE Discount_Identifier
	SET IsDefault = 0
	WHERE IsDefault = 1
	</cfquery>

<!---Add new one--->
	<cfquery name="AddNewDefault" datasource="#application.datasource#">
	UPDATE Discount_Identifier
	SET IsDefault = 1
	WHERE Discount_Identifier_ID = '#FORM.New_Default_ID#'
	</cfquery>

</cftransaction>

<!---Return home--->
<cflocation url="index.cfm">