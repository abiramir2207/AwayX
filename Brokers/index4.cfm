<CFSET PAGE_TITLE="Brokers' Action Plan">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>



<!--- Save the basic operator data --->
<CFQUERY NAME="Save_Broker_Data" datasource="#application.datasource#">
SET NOCOUNT ON
	INSERT INTO Broker_Action_Plan
		(
			BSA_Operator_ID,
			User_ID
		)
	VALUES
		(
			#BSA_Operator_ID#,
			'#request.AccessStructure.user_id#'
		)
SELECT Broker_Action_Plan_ID = @@IDENTITY
SET NOCOUNT OFF
</CFQUERY>


<!--- 
<CFOUTPUT>#Save_Broker_Data.Broker_Action_Plan_ID#</CFOUTPUT>
 --->

<!--- Save the notes --->
<cfset useLakebaseForSaveNotesData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan_notes")>
<cfif useLakebaseForSaveNotesData>
	<cftry>
		<cfset application.oLakebase.insertRow("broker_action_plan_notes", {
			"broker_action_plan_id" = Save_Broker_Data.Broker_Action_Plan_ID,
			"date_of_note" = dateTimeFormat(Date_of_Note, "yyyy-mm-dd'T'HH:nn:ss"),
			"broker_action_plan_notes" = Broker_Action_Plan_Notes
		})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForSaveNotesData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveNotesData>
	<CFQUERY NAME="Save_Notes_Data" datasource="#application.datasource#">
		INSERT INTO Broker_Action_Plan_Notes
			(
				Broker_Action_Plan_ID,
				Date_of_Note,
				Broker_Action_Plan_Notes
			)
		VALUES
			(
				#Save_Broker_Data.Broker_Action_Plan_ID#,
				#createodbcdatetime(Date_of_Note)#,
				'#Broker_Action_Plan_Notes#'
			)
	</CFQUERY>
</cfif>




<CFLOOP INDEX="UPC" LIST="#Form.UPC#">

<CFSET cleanUPC=replace(UPC, "-", "_", "all")>


<!--- Build the names of the form fields based on the curretn UPC --->
<CFSET Form.Product_Week_Volume			=	evaluate("Volume_#cleanUPC#")>
<CFSET Form.Product_UOM					=	evaluate("UOM_#cleanUPC#")>
<CFSET Form.Product_Purchasing_Status	=	evaluate("Status_#cleanUPC#")>


<!--- Save the product data --->
<cfset useLakebaseForSaveProductsData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan_products")>
<cfif useLakebaseForSaveProductsData>
	<cftry>
		<cfset application.oLakebase.insertRow("broker_action_plan_products", {
			"broker_action_plan_id" = Save_Broker_Data.Broker_Action_Plan_ID,
			"product_upc" = UPC,
			"product_week_volume" = Form.Product_Week_Volume,
			"product_uom" = Form.Product_UOM,
			"product_purchasing_status" = Form.Product_Purchasing_Status
		})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForSaveProductsData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveProductsData>
	<CFQUERY NAME="Save_Products_Data" datasource="#application.datasource#">
		INSERT INTO Broker_Action_Plan_Products
			(
				Broker_Action_Plan_ID,
				Product_UPC,
				Product_Week_Volume,
				Product_UOM,
				Product_Purchasing_Status
			)
		VALUES
			(
				'#Save_Broker_Data.Broker_Action_Plan_ID#',
				'#UPC#',
				'#Form.Product_Week_Volume#',
				'#Form.Product_UOM#',
				'#Form.Product_Purchasing_Status#'
			)
	</CFQUERY>
</cfif>


</CFLOOP>







<BR><BR><BR><BR><BR>
<CENTER><FONT SIZE="+1">Your Broker Plan has been saved...</FONT></CENTER>

<BR><BR><BR><BR><BR>
<CENTER><A HREF="index.cfm">Review all broker plans...</A></CENTER>















</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



