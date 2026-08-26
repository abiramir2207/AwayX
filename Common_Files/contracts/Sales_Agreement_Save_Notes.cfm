<html>
<head></head>
<title>Save Notes</title>

<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/fixed_popup.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>

<cfparam name="SaveNotes" default="0">

<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">
<cfparam name="Form.txtNotes" default="">

<!--- Save Notes for the product --->
<cfif SaveNotes eq 1>
	<cfset useLakebaseForInsert_Notes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
<cfif useLakebaseForInsert_Notes>
	<cftry>
		<cfset application.oLakebase.updateRows("export_products",
			{
				"bsa_foodservice_items_master_id" = "eq.#Item_ID#",
				"export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#",
				"deleted" = "eq.0"
			},
			{
				"export_notes" = "#Form.txtNotes#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_Notes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_Notes>
<CFQUERY NAME="Insert_Notes" datasource="#application.datasource#">
		UPDATE Export_Products
		SET Export_Notes = '#Form.txtNotes#'
		WHERE BSA_Foodservice_Items_Master_ID = '#Item_ID#'
		AND Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
		AND Deleted = 0
	</CFQUERY>
</cfif>
</cfif>

<!--- Get Notes for the product --->
<cfset useLakebaseForSelNotes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_products")>
<cfif useLakebaseForSelNotes>
	<cftry>
		<cfset SelNotes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_products", {
				"bsa_foodservice_items_master_id" = "eq.#Item_ID#",
				"export_sales_agreement_id" = "eq.#Export_Sales_Agreement_ID#",
				"deleted" = "eq.0",
				"select" = "export_notes"
			}), "export_notes"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelNotes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelNotes>
<CFQUERY NAME="SelNotes" datasource="#application.datasource#">
	SELECT Export_Notes
	FROM Export_Products
	WHERE BSA_Foodservice_Items_Master_ID = '#Item_ID#'
	AND Export_Sales_Agreement_ID = '#Export_Sales_Agreement_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>

<form action="sales_agreement_save_Notes.cfm" method="post" name="frmNotes">
<div align="right">
<B><FONT COLOR="Red" SIZE="2">[ </FONT><a href="#" onClick="self.close()">close<a><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
</div>
<br />
<div align="center">
<cfoutput>	
<cfset Product_Notes_Max_Length = 40>
	<textarea name="txtNotes" rows="4" cols="30" onfocus="skipcycle=true" onblur="skipcycle=false" onPaste="javaScript: return textareaChecklength(#Product_Notes_Max_Length#, this);"  onkeyPress="javaScript: return textareaChecklength(#Product_Notes_Max_Length#, this);">#SelNotes.Export_Notes#</textarea>
	
		<input type="hidden" name="Export_Sales_Agreement_ID" value="#Export_Sales_Agreement_ID#">
		<input type="hidden" name="Item_ID" value="#Item_ID#">
		<input type="hidden" name="SaveNotes" value="1">
<br />
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><A Href="##" ONCLICK="Javascript:frmNotes.submit();self.close()">Save</A><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>
</cfoutput>
</div>
</form>
</body>
</html>


