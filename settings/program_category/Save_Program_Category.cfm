<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Save Program Category</title>
</head>

<body>

<CFIF Form.Program_Category_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_category")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("program_category", {
			"program_category" = "#Form.Category_Name#",
			"deleted" = "#Form.Deleted#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		Program_Category
						(
							Program_Category,
							Deleted
						)
		Values			(
							'#Form.Category_Name#',
							 #Form.Deleted#
						)
	</CFQUERY>
</cfif>

	<CFELSE>

	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 	Program_Category
		SET 	Program_Category = '#Form.Category_Name#',
					Updated_Date = getDate(),
					Deleted = #Form.Deleted#
		WHERE		Program_Category_ID		=	#Form.Program_Category_ID#
	</CFQUERY>

</CFIF>

<CFLOCATION URL="index.cfm" ADDTOKEN="No">

</body>
</html>
