<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Planning_Groups\PG_Download_Eff_Dates.cfm
      Date:     05-Sep-2019
      Author:   Anand Rao
      Purpose:  Download the member data to reupload with corrected effective dates

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="URL.fileParam" default="" />
<cfparam name="URL.PGType" default=0 />
<cfparam name="URL.PG_Category_ID" default=0 />
<cfparam name="URL.Keyword" default="" />
<cfparam name="URL.OrderByField" default="" />
<cfparam name="URL.OrderBy" default="" />

<cfif URL.PGType EQ "1">
	<cfset PGTypeName = 'Product' />
	<cfquery name="qryPGProductCategoryDefinitionByID" datasource="#application.datasource#">
	EXEC Get_Product_Group_Info_For_PG '#URL.PG_Category_ID#','#URL.Keyword#','#URL.OrderByField#','#URL.OrderBy#'
	</cfquery>
	<cfquery dbtype="query" name="qryMacroData">
		SELECT
		 PG_Product_Category_ID,
		 PG_Type_ID,
		 Product_Group_ID,
		 PG_Product_Category_Definition_ID,
		 PG_Product_Category_Code,
		 PG_Product_Category_Name,
		 Group_Number,
		 Group_Name,
		 Inclusion_Exclusion,
		 PG_Effective_Start_Date,
		 PG_Effective_End_Date
	 FROM 
	 qryPGProductCategoryDefinitionByID
	</cfquery>
	 
<cfelseif URL.PGType EQ "2">
	<cfset PGTypeName = 'Distributor' />
	<cfquery name="qryPGCustomerCategoryDefinitionByID" datasource="#application.datasource#">
	EXEC Get_Customer_Group_Info_For_PG '#URL.PG_Category_ID#','#URL.Keyword#','#URL.OrderByField#','#URL.OrderBy#'
	</cfquery>
	
	<cfquery dbtype="query" name="qryMacroData">
		SELECT
		 PG_Customer_Category_ID,
		 PG_Type_ID,
		 Distributor_Group_ID,
		 PG_Customer_Category_Definition_ID,
		 PG_Customer_Category_Code,
		 PG_Customer_Category_Name,
		 Group_Number,
		 Group_Name,
		 Inclusion_Exclusion,
		 PG_Effective_Start_Date,
		 PG_Effective_End_Date
	 FROM 
	 qryPGCustomerCategoryDefinitionByID
	</cfquery>
<cfelseif URL.PGType EQ "3">	
	<cfset PGTypeName = 'Operator' />
	<cfquery name="qryPGOperatorCategoryDefinitionByID" datasource="#application.datasource#">
	EXEC Get_Operator_Group_Info_For_PG '#URL.PG_Category_ID#','#URL.Keyword#','#URL.OrderByField#','#URL.OrderBy#'
	</cfquery>
	<cfquery dbtype="query" name="qryMacroData">
		SELECT
		 PG_Operator_Category_ID,
		 PG_Type_ID,
		 Operator_Group_ID,
		 PG_Operator_Category_Definition_ID,
		 PG_Operator_Category_Code,
		 PG_Operator_Category_Name,
		 Group_Number,
		 Group_Name,
		 Inclusion_Exclusion,
		 PG_Effective_Start_Date,
		 PG_Effective_End_Date
	 FROM 
	 qryPGOperatorCategoryDefinitionByID
	</cfquery>
</cfif>

<cfoutput>
<cfscript>
	XLSXOutputFile  = "#PGTypeName#_#URL.PG_Category_ID#_" & UCase(dateformat(now(), "mmm-d-yyyy")); //& '-' & lcase(replace(timeFormat(now(), "h:mm:ss"), ":", "", "all"))

	// pass true in the 2nd parameter to use the new XML format on XLSX file
	XLSXNew         = spreadSheetNew('PG_Eff_Dates_Download', true);

	spreadSheetAddRow(XLSXNew, arrayToList(qryMacroData.getColumnNames()));
	spreadSheetFormatRow(XLSXNew, {bold=TRUE, fgcolor="black", color="white"}, 1);

	// add rows in query
	spreadSheetAddRows(XLSXNew, qryMacroData);
	// hide Group_GUID
	spreadSheetSetColumnWidth(XLSXNew, listLen(qryMacroData.columnList)+1, 0 );

	// center UOM columns

	XLSXOutputFileFullPath = (application.doc_path & "\temp_files\" & XLSXOutputFile & ".xlsx");
</cfscript>


</cfoutput>


<cfspreadsheet action="write" name = "XLSXNew" filename = #XLSXOutputFileFullPath# overwrite = "true">

<!--- Download spreadsheet --->
<cfheader name="Content-Disposition" value="attachment;filename=#XLSXOutputFile#.xlsx">
<cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#XLSXOutputFileFullPath#" deletefile="no">


