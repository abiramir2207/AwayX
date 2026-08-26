
<CFOUTPUT>
<CFSET PAGETITLE = "DISCOUNT IDENTIFICATION CODES">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="discount_id_component.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif Form.action IS "remove">
<!---Turning it off--->

<cftransaction>
	<!---Turns off universal setting--->
	<cfquery name="TurnOffGeneralSettings" datasource="#application.datasource#">
	UPDATE General_Settings
	SET Use_Discount_ID = 0 
	</cfquery>
	
	<!--- <!---Update all the templates with this value--->
	<cfquery name="UpdateAllTemplates" datasource="#application.datasource#">
	UPDATE Program_Control_Panel_Options
	SET Discount_Identifier_ID = NULL
	</cfquery> 
	
	<!---Deletes records in Discount Indentifier table--->
	<cfquery name="DeleteRecordsinDI" datasource="#application.datasource#">
	UPDATE Discount_Identifier
	Set Active = 0
	</cfquery>--->
	
</cftransaction>

	<!---Redirect to home page--->
	<cflocation url="/settings/discount_identifier/index.cfm">

<cfelse>
<!---Turning it on--->

	<cftransaction>
	<!---Insert into database--->
	<cfquery name="InsertValue" datasource="#application.datasource#">
	SET NOCOUNT ON 
	INSERT INTO Discount_Identifier
	(
		Discount_Identifier_Number,
		Discount_Identifier_Desc,
		Active,
		Created_Date,
		Deleted,
		IsDefault
	)
	VALUES
	(
		'#form.Discount_ID_Number#',
		'#form.Discount_ID_Desc#',
		1,
		#Now()#,
		0,
		1
	)
	SELECT Discount_Identifier_ID = @@IDENTITY 
	SET NOCOUNT OFF
	</cfquery>
	
	<!---Update general settings--->
	<cfquery name="UpdateGeneralSettings" datasource="#application.datasource#">
	UPDATE General_Settings
	SET Use_Discount_ID = 1
	</cfquery>
	
	<!---Update all the templates with this value--->
	<cfquery name="UpdateAllTemplates" datasource="#application.datasource#">
	UPDATE Program_Control_Panel_Options
	SET Discount_Identifier_ID = #InsertValue.Discount_Identifier_ID#
	</cfquery>
	</cftransaction>
	
	<cflocation url="/settings/discount_identifier/index.cfm">
	
</cfif>

</body></html>