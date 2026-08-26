<!--- url.Disp = which page to download --->
<!--- url.Del = whether to include deleted records --->
<!--- url.ReportID = the report for details --->
<cfparam name="url.ReportID" default="0">

<title>Auto Billback Reports</title>

<!--- Spinner goes here --->
<cfset PW_DoNotCFFLUSH = 1/>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!---<CFFLUSH>--->
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportAjaxCaller",name="BBReportAjaxCaller",bReload= 1).init() />
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportGet",name="BBReportGet",bReload= 1).init() />
	<cfset application.oController.getObject(path="components.Billback.BB_Auto_Report_Period",name="BBReportPeriod",bReload= 1) />
	<cfset application.oController.getObject(path="components.Billback.BBAutoReportUpdate",name="BBReportUpdate",bReload= 1).init() />

	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	
	<cfset Report_ID = url.ReportID>

	<!--- Call the component that will do execute the query and write it to a file --->
	<Cfif url.Disp NEQ "detail">
	<cfset DisplayLinks = application.oBBReportGet.getExportFile(url.Disp,url.Del,url.ReportID)>
	
	<!---<cfoutput>#DisplayLinks#</cfoutput>--->
		<cfheader name="Content-Disposition" value="attachment; filename=AutoPayReport_Data.csv" >
	<cfcontent type="application/vnd.ms-excel" file="#DisplayLinks#">
	
	<cfelse> 
	<!--- If it is display --->
	<!--- Do the processing and writing inside a silent tag --->

	<cfset qAutoPayExtractComplete = application.oBBReportGet.getAutoPayExtractComplete(url.ReportID)>
		
	<cfquery name="qGetProdVarBLabel" datasource="#application.datasource#">
		SELECT Group_Level_Desc from Product_Group_Level l where l.Product_Group_Level_ID = 16
	</cfquery>
	<cfquery name="qGetProdVarELabel" datasource="#application.datasource#">
		SELECT Group_Level_Desc from Product_Group_Level l where l.Product_Group_Level_ID = 23
	</cfquery>
        
	<cfscript>
		//Use an absolute path for the files.
		Billbackfilepath = application.Doc_Path & "\Temp_Files\Billback\AutoPayReport\AutoPayReport_" & Report_ID & ".csv"; //AutoPayReport\
		DownloadFilePath =  "common_documents/Temp_Files/Billback/AutoPayReport/AutoPayReport_" & Report_ID & ".csv"; //AutoPayReport/
		
		/* Only if the app setting is ON, then show the "credit program title" and "credit program number" columns. */
		if(appSettings.getBB_Inserts_Credit_To_Invoices() eq 1){
			sCols = 'BB_AUTO_REPORT_ID,REPORT_TITLE,START_DATE,END_DATE,CONTRACT_TITLE,CONTRACT_NUMBER,BB_TITLE,BB_CODE,SHR_SHIP_TO,SHR_SHIP_TO_NAME,OPERATOR_ID,ITEM,UPC,DESCRIPTION,BRAND_NAME,INVOICE_DATE,PURCHASE_ORDER,SHARED_INVOICE_NUMBER,CASES_INVOICED,POUNDS_INVOICED,SALES_DOLLARS,GROSS_SALES,REBATEABLE_SALES,UNIT_PRICE,PRICE_UNIT_OF_MEASURE,DISCOUNT_OFFERED,DISCOUNT_UOM,AMOUNT_EARNED,SHR_CUSTID,CREDIT_PROGRAM_TITLE,CREDIT_PROGRAM_NUMBER';
		}
		else{
			sCols = 'BB_AUTO_REPORT_ID,REPORT_TITLE,START_DATE,END_DATE,CONTRACT_TITLE,CONTRACT_NUMBER,BB_TITLE,BB_CODE,SHR_SHIP_TO,SHR_SHIP_TO_NAME,OPERATOR_ID,ITEM,UPC,DESCRIPTION,BRAND_NAME,INVOICE_DATE,PURCHASE_ORDER,SHARED_INVOICE_NUMBER,CASES_INVOICED,POUNDS_INVOICED,SALES_DOLLARS,GROSS_SALES,REBATEABLE_SALES,UNIT_PRICE,PRICE_UNIT_OF_MEASURE,DISCOUNT_OFFERED,DISCOUNT_UOM,AMOUNT_EARNED,SHR_CUSTID';
		}
			sCharCols = 'SHR_SHIP_TO,OPERATOR_ID,ITEM,PURCHASE_ORDER,SHARED_INVOICE_NUMBER';
			arrCols = listToArray(sCols);

        s = "Report ID,Report Title,Report Start Date,Report End Date,Program Title,Program Number,Billback Title,Billback Code,Distributor Number,Distributor Name,Operator ID";
        
        if(appSettings.get_Setting('Display_Item_No') eq "1"){
			s = s & "," & application.returned_customer_setting.item_label;
		}
        
        if(application.returned_customer_setting.UPC_Switch eq 1){
			s = s & "," & application.returned_customer_setting.upc_label;
		}
      	s = s & ",GTIN,Description,Brand,Invoice Date,PO,Invoice Number,Redi Number, Cases Invoiced,Pounds Invoiced,Invoice $,Gross Inv $,Rebateable Inv $,Price,Price UOM,Discount,Discount UOM,$ Earned,Cust ID";
        
		/* Only if the app setting is ON, then show the "credit program title" and "credit program number" columns. */
		if(appSettings.getBB_Inserts_Credit_To_Invoices() eq 1){
			s = s & ",Credit Program Title,Credit Program Number";
		}		
		if (appSettings.get_Setting('Autopay_Brokerage_From_Zipcode') eq '1'){
        	s = s & ",Payee ID,Payee Name,Invoice Zipcode";
			s = s & "," & qGetProdVarBLabel.Group_Level_Desc;
			s = s & "," & qGetProdVarELabel.Group_Level_Desc;
        }

		s = s & chr(10);
	</cfscript> 
	

	<cfsavecontent variable="ResultContent"><cfoutput>#s#</cfoutput>
		<!--- Only if the app setting is ON, then show the "credit program title" and "credit program number" columns. --->
        <cfoutput query="qAutoPayExtractComplete">#qAutoPayExtractComplete.BB_AUTO_REPORT_ID#,#qAutoPayExtractComplete.REPORT_TITLE#,#qAutoPayExtractComplete.START_DATE#,#qAutoPayExtractComplete.END_DATE#,#qAutoPayExtractComplete.CONTRACT_TITLE#,#qAutoPayExtractComplete.CONTRACT_NUMBER#,#qAutoPayExtractComplete.BB_TITLE#,#qAutoPayExtractComplete.BB_CODE#,="#qAutoPayExtractComplete.SHR_SHIP_TO#",#qAutoPayExtractComplete.SHR_SHIP_TO_NAME#,="#qAutoPayExtractComplete.OPERATOR_ID#"<cfif appSettings.get_Setting('Display_Item_No') eq '1'>,="#qAutoPayExtractComplete.ITEM#"</cfif><cfif application.returned_customer_setting.UPC_Switch>,="#qAutoPayExtractComplete.UPC#"</cfif>,="#qAutoPayExtractComplete.GTIN#",#qAutoPayExtractComplete.DESCRIPTION#,#qAutoPayExtractComplete.BRAND_NAME#,#qAutoPayExtractComplete.INVOICE_DATE#,="#qAutoPayExtractComplete.PURCHASE_ORDER#",="#qAutoPayExtractComplete.SHARED_INVOICE_NUMBER#",="#qAutoPayExtractComplete.Pro_Number#",#qAutoPayExtractComplete.CASES_INVOICED#,#qAutoPayExtractComplete.POUNDS_INVOICED#,#qAutoPayExtractComplete.SALES_DOLLARS#,#qAutoPayExtractComplete.GROSS_SALES#,#qAutoPayExtractComplete.REBATEABLE_SALES#,#qAutoPayExtractComplete.UNIT_PRICE#,#qAutoPayExtractComplete.PRICE_UNIT_OF_MEASURE#,#qAutoPayExtractComplete.DISCOUNT_OFFERED#,#qAutoPayExtractComplete.DISCOUNT_UOM#,#qAutoPayExtractComplete.AMOUNT_EARNED#,#qAutoPayExtractComplete.SHR_CUSTID#<cfif appSettings.getBB_Inserts_Credit_To_Invoices() eq 1>,#qAutoPayExtractComplete.CREDIT_PROGRAM_TITLE#,#qAutoPayExtractComplete.CREDIT_PROGRAM_NUMBER#</cfif><cfif appSettings.get_Setting('Autopay_Brokerage_From_Zipcode')>,#qAutoPayExtractComplete.Payee_ID#,#qAutoPayExtractComplete.Payee_Name#,#qAutoPayExtractComplete.Invoice_Zipcode#,#qAutoPayExtractComplete.Prod_Var_B#,#qAutoPayExtractComplete.Prod_Var_E#</cfif>#chr(10)#</cfoutput>
	</cfsavecontent>
 
	<!--- Write the two sheets to a single file ---> 
	<!---	<cfspreadsheet action="write" filename="#Billbackfilepath#" name="theSheet" sheetname="AutoPayReport_#Report_ID#" overwrite=true>--->
	    
	<CFFILE action = "write" file="#Billbackfilepath#" output="#stripCR(ResultContent)#">
	<cfheader name="Cache-Control" value="no-cache" >
	<cfheader name="Content-Disposition" value="attachment; filename=AutoPayReport_#Report_ID#.csv" >
	<cfcontent type="application/vnd.ms-excel" file="#Billbackfilepath#">

	
<!---	<div align="center">
	
	Your reports have been created.
	<p></p>
	<a href="#" onclick="downloadDoc('<cfoutput>#application.HTTPVar##CGI.SERVER_NAME#</cfoutput>/scheduled/getDocument.cfm?filePath=<cfoutput>#DownloadFilePath#</cfoutput>');" style="font-weight:bold;">
		Download</a> invoice level information on all programs in the report
	
	</div>--->
	</cfif>
	
	
<!--- Get rid of spinner --->
<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';

function downloadDoc(documentLocation)
{
	setInterval(function(){window.close},1);
	document.location = documentLocation;
	window.close;
}
</SCRIPT>
