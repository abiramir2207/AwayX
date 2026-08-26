<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init()>
<cfset getAllProductAttributes = qLabels.getAllProductAttributes() />
<cfset labelsValue = structNew() />

<cfloop query="getAllProductAttributes">
	<cfset temp = structInsert(labelsValue, replace(GROUP_INTERNAL_LABEL, ' ', '_', 'all'), GROUP_LEVEL_DESC, 'true') />
</cfloop>

<cfset sBrandLabel = structFind(labelsValue,"brand") />

<cfscript>
    bbAutoReportGet = CreateObject("component","components.Billback.BBAutoReportGet");

    qGetUniproReportSummary = bbAutoReportGet.getUniproReportSummary(URL.BB_Auto_Report_id, URL.ReportLevel, URL.Billback_ID);

    extractFileName = "Unipro_450_AutoPayReport_" & URL.BB_Auto_Report_id & ".csv";
    Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\"  & extractFileName;

    s = 'Format Version,Supplier ##,Member ##,Member Location ##,Member Duns ##,Member Name,Member GLN,Supplier Invoice ##,Member PO ##,Invoice Date,Original Manufacturer DUNs Number,Supplier Product ##,Pack Size,#sBrandLabel#,ITEM DESC,GTIN,UPC,CASES,NET WT,Gross Sales,Net Sales,EDA Rate,EDA Pymt,SPA Rate,SPA Pymt,Show Spec Rate,Show Spec Pymt,Other Rate,Other Pymt,Drop Ship Paid To,Deduction Code,Member Billback Reference,Reason for Deduction,Ship to Address,Ship to City,Ship to State,CaRMA,Unit Price,Product,Internal Vendor Number (ReDistributors Only),Manufacturers Item ## (ReDistributors Only),Manufacturers Name (ReDistributors Only)';
    s = s & chr(10);

    sCols = 'FORMAT,SUPPLIER,MEMBER_NUM,MEMBER_LOCATION,MEMBER_DUNS,MEMBER_NAME,MEMBER_GLN,SUPPLIER_INVOICE,MEMBER_PO,INVOICE_DATE,ORIG_DUNS_NUM,SUPPLIER_PRODUCT,PACK_SIZE,BRAND_NAME,ITEM_DESC,GTIN,UPC,CASES_INVOICED,POUNDS_INVOICED,NET_WT,GROSS_SALES,NET_SALES,EDA_RATE,EDA_PYMT,SPA_RATE,SPA_PYMT,SHOW_SPEC_RATE,SHOW_SPEC_PYMT,OTHER_RATE,OTHER_PYMT,DROP_SHIP_PAID_TO,DEDUCTION_CODE,MEMBER_BILLBACK_REFERENCE,REASON_FOR_DEDUCTION,SHIP_TO_ADDRESS,SHIP_TO_CITY,SHIP_TO_STATE,CARMA,UNIT_PRICE,PRODUCT,INTERNAL_VENDOR_NUMBER,MAN_ITEM_NUM_REDIST,MAN_NAME_REDIST';
    sCharCols = 'MEMBER_NUM,MEMBER_LOCATION,MEMBER_DUNS,MEMBER_NAME,MEMBER_GLN,SUPPLIER_INVOICE,MEMBER_PO,SUPPLIER_PRODUCT,GTIN,UPC';
</cfscript>

<cfsavecontent variable="ResultContent"><cfoutput>#s#</cfoutput><!--- POUNDS COMMENTED OUT --->
	<cfoutput query="qGetUniproReportSummary">#replace(qGetUniproReportSummary.FORMAT,',','','all')#,#replace(URL.Supplier_Number,',','','all')#,="#replace(qGetUniproReportSummary.MEMBER_NUM,',','','all')#",="#replace(qGetUniproReportSummary.MEMBER_LOCATION,',','','all')#",="#replace(qGetUniproReportSummary.MEMBER_DUNS,',','','all')#",="#replace(qGetUniproReportSummary.MEMBER_NAME,',','','all')#",="#replace(qGetUniproReportSummary.MEMBER_GLN,',','','all')#",="#replace(qGetUniproReportSummary.SUPPLIER_INVOICE,',','','all')#",="#replace(qGetUniproReportSummary.MEMBER_PO,',','','all')#",#replace(qGetUniproReportSummary.INVOICE_DATE,',','','all')#,#replace(qGetUniproReportSummary.ORIG_DUNS_NUM,',','','all')#,="#replace(qGetUniproReportSummary.SUPPLIER_PRODUCT,',','','all')#",#replace(qGetUniproReportSummary.PACK_SIZE,',','','all')#,#replace(qGetUniproReportSummary.BRAND_NAME,',','','all')#,#replace(qGetUniproReportSummary.ITEM_DESC,',','','all')#,="#replace(qGetUniproReportSummary.GTIN,',','','all')#",="#replace(qGetUniproReportSummary.UPC,',','','all')#",#replace(qGetUniproReportSummary.CASES_INVOICED,',','','all')#,#replace(qGetUniproReportSummary.NET_WT,',','','all')#,#replace(qGetUniproReportSummary.GROSS_SALES,',','','all')#,#replace(qGetUniproReportSummary.NET_SALES,',','','all')#,#replace(qGetUniproReportSummary.EDA_RATE,',','','all')#,#replace(qGetUniproReportSummary.EDA_PYMT,',','','all')#,#replace(qGetUniproReportSummary.SPA_RATE,',','','all')#,#replace(qGetUniproReportSummary.SPA_PYMT,',','','all')#,#replace(qGetUniproReportSummary.SHOW_SPEC_RATE,',','','all')#,#replace(qGetUniproReportSummary.SHOW_SPEC_PYMT,',','','all')#,#replace(qGetUniproReportSummary.OTHER_RATE,',','','all')#,#replace(qGetUniproReportSummary.OTHER_PYMT,',','','all')#,#replace(qGetUniproReportSummary.DROP_SHIP_PAID_TO,',','','all')#,#replace(qGetUniproReportSummary.DEDUCTION_CODE,',','','all')#,#replace(qGetUniproReportSummary.MEMBER_BILLBACK_REFERENCE,',','','all')#,#replace(qGetUniproReportSummary.REASON_FOR_DEDUCTION,',','','all')#,#replace(qGetUniproReportSummary.SHIP_TO_ADDRESS,',','','all')#,#replace(qGetUniproReportSummary.SHIP_TO_CITY,',','','all')#,#replace(qGetUniproReportSummary.SHIP_TO_STATE,',','','all')#,#replace(qGetUniproReportSummary.CARMA,',','','all')#,#replace(qGetUniproReportSummary.UNIT_PRICE,',','','all')#,#replace(qGetUniproReportSummary.PRODUCT,',','','all')#,#replace(qGetUniproReportSummary.INTERNAL_VENDOR_NUMBER,',','','all')#,#replace(qGetUniproReportSummary.MAN_ITEM_NUM_REDIST,',','','all')#,#replace(qGetUniproReportSummary.MAN_NAME_REDIST,',','','all')##chr(10)#</cfoutput>
</cfsavecontent>

<cffile action = "write" file="#Billbackfilepath#" output="#ResultContent#">		
<cfheader name="Content-Disposition" value="attachment; filename=#extractFileName#" >
<cfcontent type="application/vnd.ms-excel" file="#Billbackfilepath#">
	
		
