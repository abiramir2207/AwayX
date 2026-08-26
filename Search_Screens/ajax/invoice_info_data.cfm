<!---------------------------------------------------------------------------------------------------------------------
      Template: \Search_Screens\Invoice\ajax\invoice_info_data.cfm
      Date:     2016 August
      Author:   Milan Mushran
      Purpose:  AJAX processing for loading and searching/filtering invoice data
----------------------------------------------------------------------------------------------------------------------->
<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfparam name="form.iDisplayStart"	default="0">
<cfparam name="form.iDisplayLength"	default="100">
<cfparam name="form.sEcho"			default="10">
<cfparam name="form.iSortCol_0"		default="0">
<cfparam name="form.SSORTDIR_0"		default="asc">
<cfparam name="form.ContractMainID"	default="">
<cfparam name="form.Contract_Number"	default="">
<cfparam name="form.invoiceList"	default="">
<cfparam name="form.Start_Date"		default="">
<cfparam name="form.End_Date"		default="">
<cfparam name="form.distributorList" default="">
<cfparam name="form.Report_ID" default="">
<cfparam name="form.dollar_operator"		default="">
<cfparam name="form.dollar_amount"		default="">
<cfparam name="form.distributor_name"		default="">
<cfparam name="form.ship_to"		default="">
<cfparam name="form.customerPO"		default="">
<cfparam name="form.invoiceNumber"		default="">
<cfparam name="form.orderNumber"		default="">
<cfparam name="form.showSelected"	default="0">	

  <cfscript>
    variables.reply = {};

    variables.page_size   = val(form.iDisplayLength);
    if ( variables.page_size eq -1) {
      variables.start_row   = 1;
      variables.end_row     = -1;
    }
    else {
      variables.start_row   = form.iDisplayStart + 1;
      variables.end_row     = form.iDisplayStart + variables.page_size;
    }
    form.sSearch = trim(form.sSearch);

    // parse search string into an array of words
    if ( len(form.sSearch) ) {
      variables.arrayOfWords = reMatch( "[[:word:]]+", form.sSearch );
    }
    else {
      variables.arrayOfWords = [];
    }
    // concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
    variables.listOfWords = arrayToList(variables.arrayOfWords, "%");

    form.iSortCol_0 = val(form.iSortCol_0);
  </cfscript>

<cfset oBBAutoReportGet = CreateObject("component","components.Billback.BBAutoReportGet") />

<cfset structInvoiceDetails = oBBAutoReportGet.getReportInvoices(ContractNumber = Contract_Number, Auto_Pay_Contract_ID = form.ContractMainID,
																	Start_Date = Form.Start_Date,End_Date = Form.End_Date,distributorIDList = form.distributorList,BBAutoReportID = Form.Report_ID,
																	dollar_operator = form.dollar_operator,dollar_amount = form.dollar_amount,
																	distributor_name = form.distributor_name,ship_to = form.ship_to,customerPO = form.customerPO,
																	invoiceNumber = form.invoiceNumber,orderNumber = form.orderNumber,column_sequence_number = form.iSortCol_0,
																	sort_order = form.SSORTDIR_0,startRow = variables.start_row,endRow = variables.end_row, showCurrentlySelectedOnly = form.showCurrentlySelectedOnly,
																	invoiceList = form.invoiceList
																	)>
 <!--- Generate JSON from Query --->
  <cfset variables.reply.aaData = [] >

    <cfoutput>	
		  <cfloop query="structInvoiceDetails.resultsQueryName">

		  <cfset selectedInv = structInvoiceDetails.resultsQueryName.Selected_Invoice_Header_ID>

		<!--- If a list of invoices is passed to the popup page, then use that list of selected invoices and not the one from the
		database. This list which is passed includes the invoices in the db as well as the ones which where selected, but not saved.
		Eg: A user opens the popup, selects a few invoices, imports the selected invoices, and then reopens the popup.
		--->
		<cfif form.invoiceList neq "-1">
			<cfset selectedInv = form.invoiceList>
		</cfif>
		
		    <cfscript>
			 variables.dArrayTmp = [];
			 /* SELECT THE CHECKBOX OF THE SELECTED RECORDS */
			if(ListFindNoCase(selectedInv,structInvoiceDetails.resultsQueryName.Invoice_Header_ID)!= 0){
			arrayAppend(variables.dArrayTmp, '<input type="checkbox" name="invoiceHeaderID" class="cb" value="#Invoice_Header_ID#" CHECKED ONCLICK="if(!this.checked) document.all.check_all_invoices.checked = false;addRemoveInvoices()">');
			}
			else{
			arrayAppend(variables.dArrayTmp, '<input type="checkbox" name="invoiceHeaderID" class="cb" value="#Invoice_Header_ID#" ONCLICK="if(!this.checked) document.all.check_all_invoices.checked = false;addRemoveInvoices()">');
			}
			
			arrayAppend(variables.dArrayTmp, structInvoiceDetails.resultsQueryName.shared_invoice_number);
			arrayAppend(variables.dArrayTmp, structInvoiceDetails.resultsQueryName.Purchase_Order);
			arrayAppend(variables.dArrayTmp, structInvoiceDetails.resultsQueryName.Pro_Number);
			arrayAppend(variables.dArrayTmp, structInvoiceDetails.resultsQueryName.Name);
			arrayAppend(variables.dArrayTmp, DateFormat(structInvoiceDetails.resultsQueryName.Invoice_Date,"mm/dd/yyyy"));
			arrayAppend(variables.dArrayTmp, structInvoiceDetails.resultsQueryName.Invoice_Number);
			arrayAppend(variables.dArrayTmp, DollarFormat(structInvoiceDetails.resultsQueryName.Total_Dollars));
			arrayAppend(variables.dArrayTmp, NumberFormat(structInvoiceDetails.resultsQueryName.Total_Cases, "_,___,___,___,___"));
			 
			 arrayAppend(variables.reply.aaData, variables.dArrayTmp);
		    </cfscript>
		  </cfloop>	
  </cfoutput>
  
	<cfset variables.reply.iTotalRecords = structInvoiceDetails.recordTotal>
	<cfset variables.reply.iTotalDisplayRecords = structInvoiceDetails.recordTotal>

	<cfset variables.reply.sEcho  = javacast('int', form.sEcho)>
	<cfset variables.sOut = SerializeJSON( variables.reply )>


  <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
  <cfset variables.sOut = Replace (variables.sOut, 'SECHO', 'sEcho', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one')>
  <cfset variables.sOut = Replace (variables.sOut, 'AADATA', 'aaData', 'one')>

<!---send JSON data back to client--->
<cfoutput>#variables.sOut#</cfoutput>

</cfprocessingdirective>