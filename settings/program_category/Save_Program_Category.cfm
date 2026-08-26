<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Save Program Category</title>
</head>

<body>

<CFIF Form.Program_Category_ID EQ "">
<!--- Insert the record --->
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
