<!---------------------------------------------------------------------------------------------------------------------
   Template: \billbacks\xls_statement.cfm
   Date:     April 25, 2011
   Author:   Chris Nguyen
   Purpose:  Generate Excel Billback statement

   Remarks:
   - This CF template reads an Excel statement template (with custom labels/header/footer), adds billback data,
     then saves the statement under /common_documents/data_files/created/billbacks/  folder and name it as
     <billback_id>.xls
   - Excel statement templates are saved under  \billbacks\templates\  folder

   - User-defined labels on templates would not overwritten.
   - Price protected amount column should be defined in the template. If billback does not have price protected
     in its program the column would be removed and other columns will be shifted automatically.
---------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title></title>
 <style>
 .center { text-align:center; margin:30px; }
 .center a { margin:20px; }
 </style>
</head>
<body>
<cfif not StructKeyExists(URL, "BillBack_ID")>
  <script>
    alert( 'URL.BillBack_ID is missing!' );
  </script>
  <cfabort>
</cfif>

<cfscript>
  // if ( 0 ) {                                                       //TODO: remove this line
  //   application.datasource = "awayx";                              //TODO: remove this line
  //   abort;                                                         //TODO: remove this line
  // }                                                                //TODO: remove this line
  // else if ( 0 ) {                                                  //TODO: remove this line
  //   application.datasource = "Test_Release_V7_0";                  //TODO: remove this line
  //   URL.BillBack_ID = '8b9a5bd5-6031-4bae-9e0f-050977f98fce';      //TODO: remove this line
  // }                                                                //TODO: remove this line
  // else if ( 1 ) {                                                  //TODO: remove this line
  //   application.datasource = "starbucks";                          //TODO: remove this line
  //   URL.BillBack_ID = 'ee099bb2-c66f-435a-be48-2e062a807f9b';      //TODO: remove this line
  // }                                                                //TODO: remove this line
  // else {                                                           //TODO: remove this line
  //   application.datasource = "simplot";                            //TODO: remove this line
  //   URL.BillBack_ID = '8b627f83-6a93-4dfa-8051-906078471284';      //TODO: remove this line
  // }                                                                //TODO: remove this line

  // top-level shared structure for this page
  main = StructNew();

  // locate billback statement template
  main.template = templateFileName();

  // set up folder for billback statements
  main.folder   = initFolder();

  // gather user-defined labels
  main.clientLabels = setClientLabels();

  // gather data
  main.bbrptcfc = CreateObject("component", "components.Billback.BillbackDeviationDetailReport");
  main.billback = main.bbrptcfc.GetSummaryStatementHeader( URL.Billback_ID );

  // determine the main file name
  main.file     = main.folder & '\' & main.billback.BB_Code & '.xls';
  // gather payee information
  main.payee    = main.bbrptcfc.GetSummaryStatementPayeeInfo( URL.Billback_ID, main.billback.Billback_Payee_Type_ID );
  // gather line items
  main.items    = getItems();

  // define all common styles for cells here
  main.format   = StructNew();
  main.format.general    = {fontsize="8", alignment="left", bold="false", dataformat="General"};
  main.format.center     = {fontsize="7", alignment="center", bold="false", dataformat="General", verticalalignment="vertical_top"};
  main.format.label      = {fontsize="8", alignment="left", bold="true", dataformat="General", textwrap="false", underline="false"};
  main.format.numeric    = {fontsize="7", alignment="right", bold="false", dataformat="$##,####0.00_);($##,####0.00)", verticalalignment="vertical_top"};  //$##,####0.00_);($##,####0.00)
  main.format.numericB   = {fontsize="7", alignment="right", bold="false", dataformat="$##,####0.00_);($##,####0.00)"};
  //main.format.numericV1   = {fontsize="7", alignment="right", bold="false", verticalalignment="vertical_top"};
  main.format.numericV   = {fontsize="7", alignment="right", bold="false", dataformat="##,####0.00_);(##,####0.00)", verticalalignment="vertical_top"};
  main.format.wrap       = {fontsize="8", alignment="left", bold="false", dataformat="General", textwrap="true", verticalalignment="vertical_top"};
  main.format.note       = {fontsize="8", alignment="center", bold="false", italic="true", textwrap="true"};
  //main.format.total      = {fontsize="7", alignment="right",  leftborder="thin", rightborder="thin", dataformat="$##,####0.00"};
  main.format.total      = {fontsize="7", alignment="right", bold="false", dataformat="$##,####0.00"};
  main.format.longheader = {fontsize="8", alignment="center", bold="true", color="white", fgcolor="grey_50_percent"
                                          ,verticalalignment="vertical_center"};
  main.format.mainTopheader = {fontsize="14", alignment="center", bold="true" ,verticalalignment="vertical_center"};
  main.header = {fgcolor="black",color="white",fontsize="8", bold="true", textwrap="true"};
  main.topHeader = {fgcolor="white"};

  // generic formula for totals
  main.formula  = "";

  // linefeed delimiter
  main.lineFeed = chr(10);

  /* Create a global variable to store row */
  row_num = 0;

  // price protection indicator
  main.priceProtectionExists = priceProtectionExists();

  main.column = StructNew();
  // define column positions to be used on statement
  if ( main.priceProtectionExists ) {
    main.column.Item_Approved_Volume = atColumn('F');        // approved vol
    main.column.Item_E_Volume        = atColumn('G');        // claimed vol (customer vol)
	main.column.Expected_Rate		 = atColumn('H');
    main.column.Approved_Rate        = atColumn('I');        // approved rate
    main.column.Price_Protected_Amt  = atColumn('J');        // price protect amount
    main.column.Claim_Rate           = atColumn('K');        // claimed rate (customer rate)
    main.column.Expected_Amount      = atColumn('L');        // expected amount
    main.column.Claim_Amount         = atColumn('M');        // claimed amount (customer invoice amount)
    main.column.Variation            = atColumn('N');        // variance (discrepancy amount)
    main.column.Validation_Reason    = atColumn('O');        // deviation code
    main.column.Distributor          = atColumn('P');        // distributor
  }
  else {
    main.column.Item_Approved_Volume = atColumn('G');        // approved vol
    main.column.Item_E_Volume        = atColumn('H');        // claimed vol (customer vol)
	main.column.Expected_Rate		 = atColumn('I');
    main.column.Approved_Rate        = atColumn('J');        // approved rate
    main.column.Price_Protected_Amt  = -1          ;         // price protect amount - not used
    main.column.Claim_Rate           = atColumn('K');        // claimed rate (customer rate)
    main.column.Expected_Amount      = atColumn('L');        // expected amount
    main.column.Claim_Amount         = atColumn('M');        // claimed amount (customer invoice amount)
    main.column.Variation            = atColumn('N');        // variance (discrepancy amount)
    main.column.Validation_Reason    = atColumn('O');        // deviation code
    main.column.Distributor          = atColumn('P');        // distributor
  }


      // Total Expected Amt
     main.totalExpectedAmt = 0;

     // Total Claimed Amt
     main.totalClaimedAmt = 0;


  // generate the excel file
  if(! StructKeyExists(url, "excel_file")){
  	  createXLS();
  }

</cfscript>

<cfif StructKeyExists(url, "excel_file")>
	<cffile action="readBinary" file="#url.excel_file#" variable="main.statement">
	<!--- Give users option to save or open the Excel report --->
	<cfheader name="Content-Disposition" value="attachment; filename=#main.billback.BB_Code#.xls"  />
	<cfcontent type="application/vnd.ms-excel" variable="#main.statement#"  />
	<!--- If needed, we can use: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
	instead of "application/vnd.ms-excel". This is for newer version of Excel.
	--->

	<cfabort>
</cfif>

<cfset vars = structnew()>
<cfset vars.labelSettings = Createobject("component", "components.settings.Labels.Labels") />
<cfset vars.qBBLabels = vars.labelSettings.getBillBackLabels() />

<cfquery name="reportName" dbtype="query">
	SELECT *
	  FROM vars.qBBLabels
	 WHERE Billback_Labels_Label = 'Summary Report'
</cfquery>

<fieldset id="mainfieldset" style="padding:10px; border:1px solid blue;">
  <legend style="font: bold 14px sans-serif; color: red;"><cfoutput>#reportName.Billback_Labels_Desc#</cfoutput></legend>

<!---display heading--->
<div style="margin-top:5px" >
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr>
    <td><font size=2>Billback: <b><cfoutput>#main.billback.BB_Code#</cfoutput></b></font></td>
  </tr>
</table>
<hr width=100%/>
</div>

<div class="center" style="font-size:12px;">
Your report has been exported to an Excel file.&nbsp;&nbsp;&nbsp;Please choose one of these options.
</div>

<cfoutput>
<div class="center">
 <!---
 <a href="xls_Statement.cfm?excel_file=#main.file#&BillBack_ID=#url.BillBack_ID#">#application.util.string.actionLinkFormat("download")#</a>
 --->
<!---  <a href="javascript:window.open('/common_documents/Data_Files/Created/billbacks/#main.billback.BB_Code#.xls');window.close();">#application.util.string.actionLinkFormat("download")#</a> --->
 
 <a href="#application.HTTPVar##CGI.server_name#/GetDocument.cfm?FilePath=/common_documents/Data_Files/Created/billbacks/#main.billback.BB_Code#.xls" onclick="NewWindow(this.href,'Statement','800','600','Yes', 'No');return false;" TITLE="Click on this link to download the file">#application.util.string.actionLinkFormat("download")#</a>
 
 <a href="email_statement.cfm?attachments=#main.file#&BillBack_ID=#url.BillBack_ID#">#application.util.string.actionLinkFormat("email")#</a>
 <a href="javascript:window.close()">#application.util.string.actionLinkFormat("close window")#</a>
</div>
</cfoutput>
</fieldset>
<script>
window.resizeTo(950, 650);
</script>
</body>
</html>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="createXLS" output="true" hint="Generates an Excel billback statement">
  <cfset var udf = StructNew()>
  <!---read in the statement template, store it in a common structure called main.excel--->
  <cfspreadsheet action="read" src="#main.template#" name="main.excel">
  <cfscript>
    // take care of header section
     udf.headerRow = 2;

    // take care of authorized section
     udf.authorizedRow = 8;
     udf.authorizedCount = writeAuthorizedDetails( udf.authorizedRow );

    // take care of rejected section
     udf.rejectRow = udf.authorizedRow + udf.authorizedCount;
     udf.rejectCount = writeRejectedDetails( udf.rejectRow );

    // assign a formula template (e.g. SUM(X10:X15) means there are 6 approved line items)
    // and then we just replace the letter X with the actual column letter
    if ( udf.authorizedCount gt 0 ) {
      main.formula = "SUM(X" & udf.authorizedRow & ":X" & (udf.authorizedRow + udf.authorizedCount - 1) & ")";
    }

    // if there are rejected items, add them to the formula template
    if ( udf.rejectCount gt 0 ) {
      main.formula = main.formula & "+SUM(X" & (udf.rejectRow + 1) & ":X" & (udf.rejectRow + udf.rejectCount) & ")";
    }

    // take care of total section
    if ( udf.rejectCount eq 0 ) {
      udf.totalRow = udf.rejectRow;
    }
    else {
      udf.totalRow = udf.rejectRow + udf.rejectCount + 1;
    }
    writeTotals( udf.totalRow, udf.headerRow );

    // take care of note section
  	udf.noteRow = udf.totalRow + 2;
   	writeNotes( udf.noteRow );

     // (NOT NEEDED) take care of footer section
    //writeFooter();

    // take care of header section
    /* Call the header section at the end. 
    If the header section is called at the beginning rather than the end, it could result in the following:
     - The data rows could inherit the data type of the first few header rows, or perhaps vice-versa.
     - The above would result in some of the data rows being unformatted.
     - The above would also result in the header rows being unformatted.
     - Note: Do not add "border" anywhere on the document. Sometimes, the data rows inherit the border of the header.
     - All of the above typically happens when we have more than 2500 (approximately) records.
    */
    writeHeader( udf.headerRow );

    /* Write the main top header on the first row */
    putValue( 1, 1, 'Billback Statement', main.format.mainTopheader );

    /* For some large documents, when we have authorized and rejected products, the document formatting gets affected, i.e.
    the rejected header's gray color may also become the color of some other rows. It is best to write these headers at
    the end to avoid this issue.
    */
    writeAuthorizedHeader(udf.authorizedCount,udf.authorizedRow);
    writeRejectedHeader(udf.rejectCount,udf.rejectRow);
  </cfscript>

  <!--- adjust column widths --->
  <cfloop index="udf.column" list="A,B,D,F,G,H,I,J,K,L,M,O,P,Q">
    <cfset SpreadsheetSetColumnWidth( main.excel,  atColumn(udf.column), 8 )>
  </cfloop>
  <cfset SpreadsheetSetColumnWidth( main.excel,  atColumn('C'), 10 )>
  <cfset SpreadsheetSetColumnWidth( main.excel,  atColumn('E'), 10 )>
  <cfset SpreadsheetSetColumnWidth( main.excel,  atColumn('N'), 10 )>


  <!--- Write the spreadsheet to a file, replacing any existing file. --->
  <cfspreadsheet action="write"    filename="#main.file#"
                 name="main.excel" overwrite=true
                 sheetname="#application.returned_customer_setting.Company_Name#">
 </cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeHeader" output="true" hint="Generates statement header.">
  <cfargument name="row" required="true">
  <cfscript>
    var udf    = StructNew();    // local structure inside a udf
  	udf.bbdao  = CreateObject("component", "mvc.Models.Billback.BillbackDAO");
    udf.vendor = udf.bbdao.GetVendor( URL.Billback_ID );
  </cfscript>

  <cfscript>
    // take care of Payee section
		if ( IsActive('Payee Name') ) {
	  	putLabel( arguments.row,     atColumn('A'), getClientLabel('Payee Name') );
	  	putValue( arguments.row,     atColumn('B'), main.payee.payee_number );
	  	putValue( arguments.row + 1, atColumn('B'), main.payee.payee_name );
	  	putValue( arguments.row + 2, atColumn('B'), main.payee.address1 );
	  	putValue( arguments.row + 3, atColumn('B'), trim(main.payee.city)
	  	                                            & ', ' & main.payee.state
	  	                                            & ' ' & main.payee.postalcode );
  	}

    // take care of Billback section
		if ( IsActive('BB ##') ) {
  		putLabel( arguments.row,     atColumn('D'), getClientLabel('BB ##') );
  		putValue( arguments.row,     atColumn('E'), main.billback.bb_reference );
  	}
		if ( IsActive('Start Date') ) {
	  	putLabel( arguments.row + 1, atColumn('D'), getClientLabel('Start Date') );
	  	putValue( arguments.row + 1, atColumn('E'), DateFormat(main.billback.bb_start_date, 'm/d/yyyy') );
	  }
		if ( IsActive('End Date') ) {
	  	putLabel( arguments.row + 2, atColumn('D'), getClientLabel('End Date') );
	  	putValue( arguments.row + 2, atColumn('E'), DateFormat(main.billback.bb_end_date, 'm/d/yyyy') );
		}

    // take care of Vendor section
		if ( IsActive('Vendor Name') ) {
	  	putLabel( arguments.row,     atColumn('G'), getClientLabel('Vendor Name') );
	  	putValue( arguments.row,     atColumn('H'), udf.vendor.Vendor_ID);
	  	putValue( arguments.row + 1, atColumn('H'), udf.vendor.Vendor_Name);
	  	putValue( arguments.row + 2, atColumn('H'), udf.vendor.Address_1);
	  	putValue( arguments.row + 3, atColumn('H'), udf.vendor.City
	  	                                            & ' ' & udf.vendor.State
	  	                                            & ' ' & udf.vendor.ZipCode);
		}

  	// take care of Claimed (customer)/Expected/Variance labels (total amounts are taken care in writeTotals())
		if ( IsActive('Claimed Amount') ) {
	  	putLabel( arguments.row,     atColumn('J'), getClientLabel('Claimed Amount') );
	  }
		if ( IsActive('Expected Amount') ) {
  		putLabel( arguments.row + 1, atColumn('J'), getClientLabel('Expected Amount') );
  	}
		if ( IsActive('Variance') ) {
  		putLabel( arguments.row + 2, atColumn('J'), getClientLabel('Variance') );
  	}

  	// take care of payable #, parked doc #
		if ( IsActive('Payable ##') ) {
  		putLabel( arguments.row, atColumn('N'), getClientLabel('Payable ##') );
  		putValue( arguments.row, atColumn('O'), main.billback.bb_code );
  	}
		if ( IsActive('Reference ##') ) {
  		putLabel( arguments.row + 1, atColumn('N'), getClientLabel('Reference ##') );
  	}

  	if ( not main.priceProtectionExists ) {
  	
  	  // eliminate price protected amt column, shift 3 column headings from F,G,H to G,H,I
	/*SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('H') ), 7, atColumn('I') );
  	  SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('G') ), 7, atColumn('H') );
  	  SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('F') ), 7, atColumn('G') ); 
	*/
  	  SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('I') ), 7, atColumn('J') );
  	  SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('H') ), 7, atColumn('I') );
  	  SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('G') ), 7, atColumn('H') );
  	  SpreadsheetSetCellValue( main.excel, SpreadsheetGetCellValue( main.excel, 7, atColumn('F') ), 7, atColumn('G') );

	 SpreadsheetSetCellValue( main.excel, ' ', 7, atColumn('F') );

	 /* format1 = StructNew();
      format1.font="Arial Narrow";
      format1.fontsize="8";
      format1.color="white";
	  format1.fgcolor="black";
      format1.alignment="center";
	  format1.bold = true;
	  format1.textwrap = true;
	*/
	  //SpreadsheetFormatCell( main.excel, format1, 7, atColumn('J'));
  	  //SpreadsheetFormatCell( main.excel, format1, 7, atColumn('I'));
	  //SpreadsheetFormatCell( main.excel, format1, 7, atColumn('H'));
	  //SpreadsheetFormatCell( main.excel, format1, 7, atColumn('G'));
	  //SpreadsheetFormatCell( main.excel, format1, 7, atColumn('F'));


	  //SpreadsheetFormatCell( main.excel, {fgcolor="black"}, 7, atColumn('F'));

  	}
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeEntries" output="false"  returntype="numeric" hint="Generates rows for authorized and rejected, returns the count.">
  <cfargument name="row" required="true">
  <cfargument name="entriesType" required="true">

  <cfscript>
    var udf        = StructNew();     // local structure inside a udf
    udf.lineNumber = 0;
    var startRowNumber = 0;

    // adjust cell position/words count/hyphen for item column
    if ( main.priceProtectionExists ) {
      // span 2 columns, have less room for item
      udf.itemEndingCell = atColumn('E');
      udf.itemWords = 7;
      udf.itemHyphen = '-';
    }
    else {
      // span 3 columns, have more room for item
      udf.itemEndingCell = atColumn('F');
      udf.itemWords = 10;
      udf.itemHyphen = ' - ';
    }
  </cfscript>


  <cfloop query="main.items">
    <!--- filter out items based on selected argument type --->
    <cfif ( arguments.entriesType eq 'Authorized' and main.items.final_payment NEQ 0 )
       or ( arguments.entriesType eq 'Rejected'   and main.items.final_payment eq 0 )>
	
	<!--- Total Claimed and Expected Amount for all the products. This will be displayed on the header.
	Note: We will only display devaited products, but the header will show totals (expected and claimed)
	for all the products.
	--->
       <cfset main.totalExpectedAmt = main.totalExpectedAmt + val(main.items.Expected_Amount)>
       <cfset main.totalClaimedAmt = main.totalClaimedAmt + val(main.items.Claim_Amount)>

    <!--- Display only deviated products. --->
    <cfif main.items.Expected_Amount neq main.items.Claim_Amount>

      <!---get deviation code--->
      <cfset Validation_Reason = "">
      <!--- deviation code will be displayed when we have a deviation - Claimed GT Expected or vice-versa. --->
      <cfif ( main.items.variation neq 0 )>
        <cfinclude template="/billbacks/Find_Deviation_Type.cfm">
      </cfif>

      <cfscript>
        udf.lineNumber = udf.lineNumber + 1;
        udf.row = arguments.row + udf.lineNumber - 1;
	
	/* row_num stores the same value as "udf.row". It is just a global variable */
	row_num = udf.row;

        // merge cells for long fields
        SpreadsheetMergeCells( main.excel, udf.row, udf.row, atColumn('B'), atColumn('C') );       // program
        SpreadsheetMergeCells( main.excel, udf.row, udf.row, atColumn('D'), udf.itemEndingCell );  // item
        SpreadsheetMergeCells( main.excel, udf.row, udf.row, atColumn('P'), atColumn('Q') );       // distributor

        // expand row height based on item description
        udf.description = trim(main.items.Item_Number) & udf.itemHyphen & main.items.Description;
        SpreadsheetSetRowHeight( main.excel, udf.row, rowHeight(udf.description) );

	/* Do not do any formatting now. Formatting takes a lot of procesing time. Do the formatting at the end of the loop */
      // insert a blank character (ascii code 129) at the end of line no so Excel would not see this value as a number and right justify it
        SpreadsheetSetCellValue( main.excel, udf.lineNumber & chr(129), udf.row, atColumn('A') );
         //program, limit program title to a small number of words
        SpreadsheetSetCellValue( main.excel, main.items.Program_Number & main.lineFeed & getWords(trim(main.items.Program_Title),5), udf.row, atColumn('B') );
        // item, limit item description to a small number of words
        SpreadsheetSetCellValue( main.excel, udf.description, udf.row, atColumn('D') );

        SpreadsheetSetCellValue( main.excel, main.items.Item_Approved_Volume, udf.row, main.column.Item_Approved_Volume );    // approved volume
        SpreadsheetSetCellValue( main.excel, main.items.Item_E_Volume, udf.row, main.column.Item_E_Volume        );        // claimed (customer) volume
        SpreadsheetSetCellValue( main.excel, main.items.Expected_Rate, udf.row, main.column.Expected_Rate        );     // expected rate
        SpreadsheetSetCellValue( main.excel, main.items.Approved_Rate, udf.row, main.column.Approved_Rate        );     // approved rate
        // price protected amt (conditionally displayed)
        if ( main.priceProtectionExists ) {
          SpreadsheetSetCellValue( main.excel, main.items.Price_Protected_Amt, udf.row, main.column.Price_Protected_Amt );
        }
        SpreadsheetSetCellValue( main.excel, main.items.Claim_Rate, udf.row, main.column.Claim_Rate        );     // claimed (customer) rate
     //   SpreadsheetSetCellValue( main.excel, main.items.Expected_Amount, udf.row, main.column.Expected_Amount   );     // expected amt
	    SpreadsheetSetCellValue( main.excel, main.items.Final_Payment, udf.row, main.column.Expected_Amount   );     // Final payment amount / Actual Approved amount
        SpreadsheetSetCellValue( main.excel, main.items.Claim_Amount, udf.row, main.column.Claim_Amount      );     // claimed amt
        SpreadsheetSetCellValue( main.excel, main.items.Variation, udf.row, main.column.Variation         );     // variance (discrepancy)
        SpreadsheetSetCellValue( main.excel, Validation_Reason, udf.row, main.column.Validation_Reason  );     // deviation code
        // distributor
        SpreadsheetSetCellValue( main.excel,
                  main.items.Distributor_Name & main.linefeed & main.items.Ship_To, udf.row, main.column.Distributor         );

      </cfscript>
     </cfif>
    </cfif>
  </cfloop>

  <!--- gather lump sum information --->
  <cfset udf.lumpsum = getLumpSum( arguments.entriesType )>

  <!--- display lump sum information --->
  <cfoutput query="udf.lumpsum" group="contract_number">

      <!--- Total Claimed and Expected Amount for all the products. This will be displayed on the header.
	Note: We will only display devaited products, but the header will show totals (expected and claimed)
	for all the products.
       --->
     <cfset main.totalExpectedAmt = main.totalExpectedAmt + val(udf.lumpsum.Expected_Amount)>
     <cfset main.totalClaimedAmt = main.totalClaimedAmt + val(udf.lumpsum.Claim_Amount)>
   
   <!--- Display only deviated products. --->
   <cfif udf.lumpsum.Expected_Amount neq udf.lumpsum.Claim_Amount>

      <!---get deviation code--->
      <cfset Validation_Reason = "">
      <!--- <cfif ( udf.lumpsum.variation gt 0 )>
        <cfinclude template="/billbacks/Find_Deviation_Type.cfm">
      </cfif> --->

      <cfscript>
        lumpsum.count = 0;
        lumpsum.components = "Lump Sump: ";
        lumpsum.Expected_Amount = 0;
        lumpsum.Claim_Amount = 0;
      </cfscript>

      <!--- gather all values within this program group --->
      <cfoutput>
        <cfscript>
          lumpsum.count = lumpsum.count + 1;
          if ( lumpsum.count gt 1 ) {
            lumpsum.components = lumpsum.components & "; ";
          }
          lumpsum.components = lumpsum.components & udf.lumpsum.program_lump_sum_name;
          //lumpsum.Expected_Amount = lumpsum.Expected_Amount + udf.lumpsum.Expected_Amount;
          lumpsum.Expected_Amount = udf.lumpsum.Expected_Amount;
          lumpsum.Claim_Amount = lumpsum.Claim_Amount + udf.lumpsum.Claim_Amount;
        </cfscript>
      </cfoutput>

      <cfscript>
        udf.lineNumber = udf.lineNumber + 1;
        udf.row = arguments.row + udf.lineNumber - 1;

	/* row_num stores the same value as "udf.row". It is just a global variable */
	row_num = udf.row;

        // merge cells for long fields
        SpreadsheetMergeCells( main.excel, udf.row, udf.row, atColumn('B'), atColumn('C') );       // program
        SpreadsheetMergeCells( main.excel, udf.row, udf.row, atColumn('D'), udf.itemEndingCell );  // item
        SpreadsheetMergeCells( main.excel, udf.row, udf.row, atColumn('P'), atColumn('Q') );       // distributor

        // expand row height to accomodate long item description
        SpreadsheetSetRowHeight( main.excel, udf.row, rowHeight(lumpsum.components) );
	
	/* Do not do any formatting now. Formatting takes a lot of procesing time. Do the formatting at the end of the loop */
      	// insert a blank character (ascii code 129) at the end of line no so Excel would not see this value as a number and right justify it
        SpreadsheetSetCellValue( main.excel, udf.lineNumber & chr(129), udf.row, atColumn('A') );
        // program, limit program title to a small number of words
        SpreadsheetSetCellValue( main.excel, udf.lumpsum.Contract_Number & main.lineFeed & getWords(trim(udf.lumpsum.Contract_Title),5), udf.row, atColumn('B') );

        SpreadsheetSetCellValue( main.excel, lumpsum.components, udf.row, atColumn('D') );
        SpreadsheetSetCellValue( main.excel, lumpsum.Expected_Amount, udf.row, main.column.Expected_Amount );     // expected amt
        SpreadsheetSetCellValue( main.excel, lumpsum.Claim_Amount, udf.row, main.column.Claim_Amount );     // claimed(customer) amt
        SpreadsheetSetCellValue( main.excel, (lumpsum.Claim_Amount - lumpsum.Expected_Amount), udf.row, main.column.Variation );     // variance (discrepancy)

        SpreadsheetSetCellValue( main.excel, Validation_Reason, udf.row, main.column.Validation_Reason );     // deviation code
        SpreadsheetSetCellValue( main.excel, main.payee.payee_name & main.linefeed & main.payee.payee_number, udf.row, main.column.Distributor );
      </cfscript>

   </cfif>
  </cfoutput>



<cfscript>
/* The objective below is to let run the formatting only once, whether we have "authorized" and/or "rejected" rows. Earlier, we used to call the format twice.
Once for the "authorized" rows and once for the "rejected" rows and it seems like when we formatted the "rejected" rows (if any), then the formatting of the
"authorized" rows may get unformatted for larger documents (2500 records approx), though not all large documents.
*/

/* row_num stores the same value as "udf.row". It is just a global variable. So, if a billback has only "authorized" and not "rejected" records, the  "row_num"
variable will store the row num for "authorized". We cannot use "udf.row" because it is not a global variable and will not exist in the case where we have only
"authorized" records.
*/
  if(arguments.entriesType eq 'Rejected' AND IsDefined("row_num"))
  {
	/* Start row is not always 8. It will be 8 when we have "authorized" records ("rejected" or not). When we have only "rejected" records, then start row
	is actually 9, but the formatting of row 8 ("Rejected" header) gets overwritten by the formattting of the "rejected" header which gets called later.
	*/
	formatData(8,row_num);
  }

  </cfscript>

  <cfreturn udf.lineNumber>
</cffunction>

<cffunction name="formatData" output="false" returntype="void" hint="Format the Excel data.">
  <cfargument name="start_row" required="true">
  <cfargument name="end_row" required="true">

<cfscript>

/* DO ALL THE FORMATTING AT THE END OF THE LOOP AS FORMATTING TAKES A LOT OF TIME TO PROCESS */

/* COLUMN-LEVEL DATA FORMATTING. DIFFERENT COLUMNS HAVE DIFFERENT DATA TYPES */

/* Note: 
1) "arguments.row" is the start row because when this function gets called for displaying "Authorized" products, then "arguments.row" is
the starting line for displaying of authorized products, not including the header as the header is above the list of authorized products.

2) "arguments.row" is the start row because when this function gets called for displaying "Rejected" products, then "arguments.row" is
the starting line for displaying of rejected products, not including the header as the header is above the list of rejected products.

3) The above logic is especially important when there are "Authorized" as well as "Rejected" products because as if we try to format all 
the rows starting from the first authorized product row, then we will end of formatting even the header for the "Rejected" row, which is
incorrect. The header for "Rejected" row has got it's own formatting and changing the formatting to be other than that causes formatting
issues for the entire excel document.
*/

/*
For some billbacks, the formatting gets affected for large billbacks (it seems like we need to have authorized and rejected records for this issue
to occur). 
Note: Any random big billbacks's format could be affected. There does not seem to be any specific criteria.
I noticed that for a particular billback while formatting "merged cells" (columns B, D), the code required formatting from "atColumn('B')" to atColumn('C')
and atColumn('D') to  atColumn('F'), instead of "atColumn('B')" to atColumn('B')" and "atColumn('D') to atColumn('D'). I managed to make it work for
"atColumn('B')" to atColumn('B')" and "atColumn('D') to atColumn('D'). It should work this way as Column B is merged with Column C and Column D is merged
with Column F and so we should not need to specify the last columns - C and F in this case.

Some of the billbacks to test for format issues are listed below. Please add more to this list if you do test more billbacks.

BB-3155925
BB-3088515
BB-3108160
BB-3107791
BB-3155916
BB-3131315
BB-3087820
BB-3408778
*/

/*
I have put the document format in a certain order below to avoid issues.
It seems like a certain column's format may affect the other column's format. I chose to put "main.format.numeric and main.format.numericV", followed by 
"main.format.center", followed by main.format.wrap. 
main.format.wrap is called for "merged cells" below and it seems that "merged cells" need to be taken care of at the end. This technique seems to work for 
those big billbacks which have a formatting issue.
*/


/* Milan - (37542) For billbacks with a large number of products (5000+ products. It could happen for lesser products too, but not for billbacks which has few products only), 
the font of the dollar amounts (expected rate to discrepancy amount) gets bold, even when the code does not have set to bold. In my testing I found out that when we format 
data from "Expected Rate" to "Variance" using "main.format.numeric" and then "Approved Volume" & "Claimed Volume" to "main.format.numericV", for some reason the above bold 
font issue happens. The issue does not happen when we just format it once. So, I just used one formatting without the "$" sign for all the columns from "Approved Volume" to "Variance".
I have put the $ sign on the header and removed it from the items.
*/

	/* Format all the rows for columns from "Expected Rate" to "Variance" */
 /*
  SpreadsheetFormatCellRange( main.excel, main.format.numeric, arguments.start_row, main.column.Expected_Rate, arguments.end_row, main.column.Variation );
*/
	/* Format all the rows for column "Approved Volume" & "Claimed Volume" */
/*
  SpreadsheetFormatCellRange( main.excel, main.format.numericV, arguments.start_row, main.column.Item_Approved_Volume, arguments.end_row, main.column.Item_E_Volume );
*/

	/* Format all the rows for columns from "Approved Volume" to "Variance" */
  SpreadsheetFormatCellRange( main.excel, main.format.numericV, arguments.start_row, main.column.Item_Approved_Volume, arguments.end_row, main.column.Variation );

 	/* Format all the rows for column "Deviation Code" (Validation reason) */
  SpreadsheetFormatCellRange( main.excel, main.format.center, arguments.start_row, main.column.Validation_Reason, arguments.end_row, main.column.Validation_Reason );

  SpreadsheetFormatCellRange( main.excel, main.format.center, arguments.start_row, 1, arguments.end_row, 1 );
    
	/* Format all the rows for columns B - C (Span of these 2 columns has the same data). Since "B" and "C" are merged cells, we use only "B". */
  SpreadsheetFormatCellRange( main.excel, main.format.wrap, arguments.start_row, atColumn('B'), arguments.end_row, atColumn('B') );

	/* Format all the rows for columns D - F (Span of there three columns has the same data). Since "D","E" and "F" are merged cells, we use only "D". */
  SpreadsheetFormatCellRange( main.excel, main.format.wrap, arguments.start_row, atColumn('D'), arguments.end_row, atColumn('D') );

	/* Format all the rows for column "Distributor" */
  SpreadsheetFormatCellRange( main.excel, main.format.wrap, arguments.start_row, main.column.Distributor, arguments.end_row, main.column.Distributor );

	/* The Excel file where this data gets written to already has a formatted header, but for a few large billbacks (records more than 3k or 4k), the formatting
	gets altered. The header is on line 7. Below code reformats it to the original format of the header.
	*/
  SpreadsheetFormatCellRange( main.excel, main.header, 7, 1, 7, 16 );
  	/* Above the header are the first 5 lines. On these lines, the background color gets altered a bit for a few large billbacks (4000 to 5000 records or more). 
	Reformatting it below.The reason I use column 20 here, is because the background color gets altered till column 20 (approximately).
	Column 20 is beyond the columns of the report.
	*/
  SpreadsheetFormatCellRange( main.excel, main.topHeader, 1, 1, 5, 20 );
</cfscript>

</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeAuthorizedDetails" output="false" returntype="numeric" hint="Generates authorized lines, returns the count.">
  <cfargument name="row" required="true">

  <cfscript>
    udf.authorizedCount = WriteEntries( arguments.row, 'Authorized');
    // pass back number of items processed
    return udf.authorizedCount;
  </cfscript>

</cffunction>

<cffunction name="writeAuthorizedHeader" output="false" returntype="void" hint="Write the header for Authorized products.">
  <cfargument name="rowCount" required="true">
  <cfargument name="row" required="true">

  <cfscript>
    var udf = StructNew();
    udf.headingRow = 6;
    /* No need to merge as the whole row is already merged in the template file - statement.xls. */
     //SpreadsheetMergeCells( main.excel, udf.headingRow, udf.headingRow, 1, 17 );
    // display authorized heading
    if ( arguments.rowCount gt 0 ) {
      udf.heading = 'AUTHORIZED';
    }
    else {
      udf.heading = '';
    }
    putValue( udf.headingRow, 1, udf.heading, main.format.longheader );
  </cfscript>

</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeRejectedDetails" output="true" returntype="numeric" hint="Generates rejected lines, returns the count.">
  <cfargument name="row" required="true">

  <cfscript>
    udf.rejectedCount = WriteEntries( arguments.row + 1, 'Rejected');
    // pass back number of items processed
    return udf.rejectedCount;
  </cfscript>

</cffunction>

<cffunction name="writeRejectedHeader" output="true" returntype="void" hint="Write the header for Rejected products.">
  <cfargument name="rowCount" required="true">
  <cfargument name="row" required="true">

  <cfscript>
    var udf = StructNew();
    // if there are rejected items display Rejected heading
    if ( arguments.rowCount gt 0 ) {
    	SpreadsheetMergeCells( main.excel, arguments.row, arguments.row, 1, 17 );
    	putValue( arguments.row, 1, 'REJECTED', main.format.longheader );
    }
  </cfscript>

</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeTotals" output="true" hint="Generates totals line.">
  <cfargument name="totalRow"  required="true">
  <cfargument name="headerRow" required="true">
  <cfscript>
    var udf = StructNew();
    //var volumeFmt = {fontsize="7", alignment="right", dataformat="##,####0.00", leftborder="thin", rightborder="thin"};
    var volumeFmt = {fontsize="7", alignment="right", dataformat="##,####0.00"};

    if ( main.priceProtectionExists ) {
      udf.totalEndingCell = 5;
      udf.column.approved_volume = 'F';
      udf.column.claimed_volume  = 'G';
    }
    else {
      udf.totalEndingCell = 6;
      udf.column.approved_volume = 'G';
      udf.column.claimed_volume  = 'H';
    }

  	SpreadsheetMergeCells( main.excel, arguments.totalRow, arguments.totalRow, 1, udf.totalEndingCell );

  	//putValue( arguments.totalRow, 1, 'Totals', {fontsize="8", alignment="right", leftborder="thin", bottomborder="medium"} );
	putValue( arguments.totalRow, 1, 'Totals', {fontsize="8", alignment="right"} );
  	// approved volume
  	putFormula( arguments.totalRow, main.column.Item_Approved_Volume,
  	            ReplaceNoCase(main.formula, 'X', udf.column.approved_volume, 'all'),
  	            volumeFmt );
  	// claimed (customer) volume
  	putFormula( arguments.totalRow, main.column.Item_E_Volume,
  	            ReplaceNoCase(main.formula, 'X', udf.column.claimed_volume, 'all'),
  	            volumeFmt );
	// expected amt in body
  	putFormula( arguments.totalRow,  main.column.Expected_Amount,
  	            ReplaceNoCase(main.formula, 'X', 'L', 'all') );

  	// total expected amt in header
		if ( IsActive('Expected Amount') ) {
	  	putFormula( arguments.headerRow + 1, atColumn('M'),
	  	            main.totalExpectedAmt,
	  	            main.format.numericB);
	  }

    // claimed (customer) amt in body
  	putFormula( arguments.totalRow, main.column.Claim_Amount,
  	            ReplaceNoCase(main.formula, 'X', 'M', 'all') );
  	// total claimed (customer) amt in header
		if ( IsActive('Claimed Amount') ) {
	  	putFormula( arguments.headerRow, atColumn('M'),
	  	            main.totalClaimedAmt,
	  	            main.format.numericB);
		}
    // variance in body
  	putFormula( arguments.totalRow, main.column.Variation,
  	            ReplaceNoCase(main.formula, 'X', 'N', 'all') );
  	// total variance amt in header
		if ( IsActive('Variance') ) {
	  	putFormula( arguments.headerRow + 2,
	  	            atColumn('M'),
	  	            'N' & arguments.totalRow,
	  	            main.format.numericB);
		}

  	// draw totalRow border
	/*
  	SpreadsheetFormatRow( main.excel,
  	                      {bottomborder="medium", bold="false"},
  	                     arguments.totalRow );
	*/
    // draw border for last cell
    /*SpreadsheetFormatCell( main.excel, {rightborder="thin"}, arguments.totalRow, atColumn('Q') );*/
  </cfscript>
  <!--- draw cell borders --->
  <!---
  <cfloop index="udf.atcolumn" list="B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q">
    <cfset SpreadsheetFormatCell( main.excel, {bottomborder="medium"}, arguments.totalRow, atColumn(udf.atcolumn) )>
  </cfloop>
  --->
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeNotes" output="true" hint="Generates statement notes.">
  <cfargument name="row" required="true">
  <cfscript>
  	putLine( arguments.row, 'Deviation Codes: 1 - Distributor Not Authorized;    2 - Unauthorized Product;    3 - Claim Outside Program Period;    4 - Overlapping Claim;' & main.linefeed & '5 - Volume;    6 - Rate;    7 - Invoice Price less than Contract' );
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="writeFooter" output="true" hint="Generates footer section.">
  <!---don't know how to generate page number, generated date yet!!!
       so dynamic footer info must be preassigned in the template
  --->
  <!---<cfset spreadsheetSetFooter( main.excel, application.returned_customer_setting.Company_Name, "", "Generated on #DateFormat(Now(), 'short')#" )>--->
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="initFolder" output="true" hint="Creates/returns Excel statement output folder.">
  <cfset var common = ExpandPath('/common_documents/data_files/created/')>
  <cfset var xlsFolder = common & 'billbacks'>

  <!---create new folder to store Excel billback statements--->
  <cfif not DirectoryExists(xlsFolder)>
    <cfdirectory directory = #xlsFolder# action = "create">
  </cfif>

  <cfreturn xlsFolder>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="putValue" output="true" hint="Assigns value/format to a cell.">
  <cfargument name="row"    required="true">
  <cfargument name="column" required="true">
  <cfargument name="text"   default="">
  <cfargument name="style"  default="#main.format.general#">

  <cfscript>
	  SpreadsheetSetCellValue( main.excel, arguments.text,  arguments.row, arguments.column );
	  SpreadsheetFormatCell  ( main.excel, arguments.style, arguments.row, arguments.column );
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<!--- Do not format the cell. Calling "SpreadsheetFormatCell" function inside a loop for many products is very resource-intensive --->
<cffunction name="putValueNoFormat" output="true" hint="Assigns value/format to a cell.">
  <cfargument name="row"    required="true">
  <cfargument name="column" required="true">
  <cfargument name="text"   default="">

  <cfscript>
	  SpreadsheetSetCellValue( main.excel, arguments.text,  arguments.row, arguments.column );
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="putFormula" output="false" hint="Assigns formula/format to a cell.">
  <cfargument name="row"    required="true">
  <cfargument name="column" required="true">
  <cfargument name="text"   default="">
  <cfargument name="style"  default="#main.format.total#">

  <cfscript>
    if ( Len(arguments.text) gt 0 ) {
	    SpreadsheetSetCellFormula( main.excel, arguments.text,  arguments.row, arguments.column );
	  }
    SpreadsheetFormatCell( main.excel, arguments.style, arguments.row, arguments.column );
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="putLabel" output="true" hint="Assigns label to a cell.">
  <cfargument name="row"    required="true">
  <cfargument name="column" required="true">
  <cfargument name="text"   default="">
  <cfargument name="style"  default="#main.format.label#">

  <cfscript>
    // write label when cell is empty, allows custom labels to be placed on the template
    if ( Len( Trim ( SpreadsheetGetCellValue( main.excel, arguments.row, arguments.column ) ) ) eq 0 ) {
	    SpreadsheetSetCellValue( main.excel, arguments.text & ':', arguments.row, arguments.column );
      SpreadsheetFormatCell  ( main.excel, arguments.style, arguments.row, arguments.column );
	  }
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="putLine" output="false" hint="Write a string on a row.">
  <cfargument name="row"    required="true">
  <cfargument name="text"   default="">
  <cfargument name="style"  default='#main.format.note#'>

  <cfscript>
  	SpreadsheetMergeCells( main.excel, arguments.row, arguments.row, 1, 17 );
  	putValue( arguments.row, 1, arguments.text, arguments.style );
    SpreadsheetSetRowHeight( main.excel, arguments.row, 26 );
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="setClientLabels" output="false" returntype="struct" hint="Returns client labels in a structure.">
  <cfscript>
    var udf = StructNew();
    udf.rsLabels = CreateObject("component", "components.products.group.ProductGroupAttributeGateway").getAllClaimLabels();
    udf.clientLabels = StructNew();
  </cfscript>

  <!---convert labels query into structure for easier references--->
  <cfloop query="udf.rsLabels">
  	<cfif udf.rsLabels.Deleted>
  		<!---skip inactive labels--->
  	<cfelse>
  		<!---include active labels--->
    	<cfset StructInsert( udf.clientLabels, udf.rsLabels.BALabel, udf.rsLabels.client_Label )>
    </cfif>
  </cfloop>

  <cfreturn udf.clientLabels>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="atColumn" output="false" hint="Returns a column number based on an Excel column letter.">
  <cfargument name="columnLetter" required="true">
  <cfscript>
    switch ( arguments.columnLetter ) {
      case "A":  return 1 ;
      case "B":  return 2 ;
      case "C":  return 3 ;
      case "D":  return 4 ;
      case "E":  return 5 ;
      case "F":  return 6 ;
      case "G":  return 7 ;
      case "H":  return 8 ;
      case "I":  return 9 ;
      case "J":  return 10;
      case "K":  return 11;
      case "L":  return 12;
      case "M":  return 13;
      case "N":  return 14;
      case "O":  return 15;
      case "P":  return 16;
      case "Q":  return 17;
      case "R":  return 18;
      case "S":  return 19;
      case "T":  return 20;
      case "U":  return 21;
      case "V":  return 22;
      case "W":  return 23;
      case "X":  return 24;
      case "Y":  return 25;
      case "Z":  return 26;
      default :  return 0;
  }
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="templateFileName" output="false" returntype="string" hint="Returns the path of the customized statement template if it exists.">
  <cfscript>
    // custom template is not found, use the generic template
    local.fileName = ExpandPath("/billbacks/templates/statement.xls");
    if ( FileExists(local.fileName) )
      return local.fileName;

    // we are in trouble, template is not found at expected location!!
    return "";
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="getLumpSum" output="false" returntype="query">
  <cfargument name="kind" type="string" required="true" hint="Either rejected or approved"/>

  <cfset var udf = StructNew()>

  <cfquery name="udf.result" datasource="#application.datasource#">
	  SELECT *
	  FROM (  SELECT b.bb_code
				           , b.bb_title
				           , lsclaim.billback_program_id AS billback_program_id
				           , Program_lump_sum_name.program_lump_sum_name
				           , Isnull( lsclaim.amount, 0 ) AS claim_amount
				           , Isnull( ls.ls_expected_amount, 0 ) AS expected_amount
					   , Isnull( ls.ls_paid_amount, Isnull(ls.ls_approved_amount, 0) ) AS approved_amount
				           , cm.Contract_Number
				           , cm.Contract_Title
				      FROM Billback b
				           LEFT JOIN Billback_program_lumpsum_component lsclaim ON lsclaim.billback_id = b.billback_id
				                                                                   AND lsclaim.deleted = 0
				           LEFT JOIN Program_lump_sums ON Program_lump_sums.program_lump_sum_id = lsclaim.program_lump_sum_id
				           LEFT JOIN Program_lump_sum_name ON Program_lump_sum_name.program_lump_sum_name_id = Program_lump_sums.program_lump_sum_name_id
				           LEFT JOIN Bb_lump_sums ls ON ls.billback_id = b.billback_id
				                                        AND ls.billback_program_id = lsclaim.billback_program_id
				                                        AND ls.deleted = 0
				           INNER JOIN Contract_Main cm ON Program_lump_sums.Program_Id = cm.Contract_Main_Id
				     WHERE b.billback_id = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength=40 value="#URL.Billback_ID#">
				           AND b.deleted = 0
				           ) subselect

	  WHERE <cfif arguments.kind eq 'Rejected'>
	         approved_amount = 0
	        <cfelseif arguments.kind eq 'Authorized'>
	         approved_amount > 0
	        <cfelse>
	         AND 1 = 0
	        </cfif>
	    		ORDER BY Contract_Number
  </cfquery>

  <cfreturn udf.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="getItems" output="true" returntype="query">
  <cfset var udf = StructNew()>

  <cfquery name="udf.result" datasource="#application.datasource#">
	<!--- The objective here is to break down the query into few manageable pieces so that we do not use a lot of table joins in one query. --->

	<!--- Query 1 --->
	IF OBJECT_ID('tempdb..##TMP_bb_Prod_Info') IS NOT NULL
	DROP TABLE ##TMP_bb_Prod_Info

	SELECT DISTINCT BillBack_Product.Billback_ID, BillBack_Product.BillBack_Product_Id, BillBack_Product.bb_Product_uom
                    ,bsa_FoodService_Items_Master.Net_Weight
                    , bsa_FoodService_Items_Master.Is_Divested
                    ,Contract_Main.Contract_Main_ID
                    , CASE
                        WHEN BillBack_Program.Program_Id IS NULL THEN BillBack_Program.bb_Program_Title
                        ELSE Contract_Main.Contract_Title
                      END                                                                                                                                 AS Program_Title
                    , CASE
                        WHEN BillBack_Program.Program_Id IS NULL THEN BillBack_Program.bb_Program_Number
                        ELSE Contract_Main.Contract_Number
                      END                                                                                                                                 AS Program_Number
                    , CASE
                        WHEN BillBack_Product.Product_Id IS NULL THEN BillBack_Product.bb_Unknown_Product_Item_Number
                        ELSE bsa_FoodService_Items_Master.Item
                      END                                                                                                                                 AS Item_Number
                    , CASE
                        WHEN BillBack_Product.Product_Id IS NULL THEN BillBack_Product.bb_Unknown_Product_Description
                        ELSE bsa_FoodService_Items_Master.Description
                      END                                                                                                                                 AS Description
                    , BillBack_Product_Detail.bb_Product_Type_Id
                    , bb_Rate
                    , BillBack_Product.Distributor_Id
                    , BillBack_Product.Product_Type_Id
		    , BillBack_Product.Product_ID
                    , BillBack_Program.BillBack_Program_Id
                    , BillBack.Billback_Status_ID
	INTO ##TMP_bb_Prod_Info

	FROM BillBack
           INNER JOIN BillBack_Program
             ON BillBack_Program.BillBack_Id = BillBack.BillBack_Id
                AND BillBack_Program.Deleted = 0
           LEFT JOIN Contract_Main
             ON BillBack_Program.Program_Id = Contract_Main.Contract_Main_Id
           LEFT JOIN BillBack_Product -- claimed info at product level
             ON BillBack_Product.BillBack_Id = BillBack_Program.BillBack_Id
                AND BillBack_Product.BillBack_Program_Id = BillBack_Program.BillBack_Program_Id
                AND BillBack_Product.Deleted = 0
           LEFT JOIN bsa_FoodService_Items_Master
             ON bsa_FoodService_Items_Master.bsa_FoodService_Items_Master_Id = BillBack_Product.Product_Id
           LEFT JOIN Units_Of_Measure
             ON Units_Of_Measure.Unit_Of_Measure_Id = BillBack_Product.bb_Product_uom
           LEFT JOIN BillBack_Product_Detail -- claimed info at product - discount type level
             ON BillBack_Product_Detail.BillBack_Id = BillBack_Product.BillBack_Id
                AND BillBack_Product_Detail.bb_Product_Type_Id IN ( 1, 2, 10, 11 )
                AND BillBack_Product_Detail.BillBack_Product_Id = BillBack_Product.BillBack_Product_Id
                AND BillBack_Product_Detail.Deleted = 0
                AND BillBack_Product_Detail.bb_Rate IS NOT NULL
                AND Len( BillBack_Product_Detail.bb_Rate ) > 0
                AND Isnumeric( BillBack_Product_Detail.bb_Rate ) = 1
                AND Cast( BillBack_Product_Detail.bb_Rate AS DECIMAL(12,2) ) <> 0
                
           WHERE BillBack.BillBack_Id = <cfqueryparam cfsqltype="cf_sql_varchar" maxLength=40 value="#URL.Billback_ID#">


        <!--- Query 2 --->           
      	IF OBJECT_ID('tempdb..##TMP_Item_Final_Info') IS NOT NULL
	DROP TABLE ##TMP_Item_Final_Info 
              
                 SELECT ##TMP_bb_Prod_Info.BillBack_Product_Id,               
		      CASE
                        WHEN ##TMP_bb_Prod_Info.bb_Product_uom = 1 THEN Isnull( bb_Item_Final_Detail.Expected_Rate_cs, 0 )
                        ELSE Isnull( bb_Item_Final_Detail.Expected_Rate_lb, 0 )
                      END                                                                                                                                 AS Expected_Rate
                    , CASE
                        WHEN ##TMP_bb_Prod_Info.bb_Product_uom = 1 THEN Isnull( bb_Item_Final_Detail.Paid_Rate_cs, 0 )
                        ELSE Isnull( bb_Item_Final_Detail.Paid_Rate_lb, 0 )
                      END                                                                                                                                 AS Approved_Rate 
                    , CASE
                        WHEN ##TMP_bb_Prod_Info.bb_Product_uom = 1 THEN Isnull( bb_Item_Final.Item_e_Volume_cs, 0 )
                        ELSE Isnull( bb_Item_Final.Item_e_Volume_lb, 0 )
                      END                                                                                                                                 AS Item_e_Volume
                    , CASE
                        WHEN ##TMP_bb_Prod_Info.bb_Product_uom = 1 THEN Isnull( bb_Item_Final.Item_Volume_Paid_cs, 0 )
                        ELSE Isnull( bb_Item_Final.Item_Volume_Paid_lb, 0 )
                      END                                                                                                                                 AS Item_Approved_Volume
                              
                INTO ##TMP_Item_Final_Info
                  FROM ##TMP_bb_Prod_Info
                  
                  LEFT JOIN bb_Item_Final -- approved/paid info at product level
             ON bb_Item_Final.BillBack_Id = ##TMP_bb_Prod_Info.BillBack_Id
                AND bb_Item_Final.BillBack_Program_Id = ##TMP_bb_Prod_Info.BillBack_Program_Id
                AND bb_Item_Final.BillBack_Product_Id = ##TMP_bb_Prod_Info.BillBack_Product_Id
                AND bb_Item_Final.Deleted = 0
           LEFT JOIN bb_Item_Final_Detail -- approved/paid info at product - discount type level
             ON bb_Item_Final_Detail.bb_Item_Final_Id = bb_Item_Final.bb_Item_Final_Id
                AND bb_Item_Final_Detail.bb_Product_Type = ##TMP_bb_Prod_Info.bb_Product_Type_Id
                AND bb_Item_Final_Detail.Deleted = 0   
                
                
        <!--- Query 3 --->        
        IF OBJECT_ID('tempdb..##bb_Item_Invoice_Level_Info') IS NOT NULL
	DROP TABLE ##bb_Item_Invoice_Level_Info    
	
	SELECT ##TMP_bb_Prod_Info.BillBack_Product_Id,Isnull( bb_Item_Invoice_Level.Final_Payment, 0 )                                                    AS Final_Payment
        , Isnull( bb_Item_Invoice_Level.Claimed_Rate_cs, 0 )                                                                                              AS Claim_Rate
        , Isnull( bb_Item_Invoice_Level.Claimed_Amt, 0 )                                                                                                  AS Claim_Amount
	, CASE 
	   WHEN UOM = 1 THEN
		CAST(Isnull(bb_Item_Invoice_Level.Expected_CS,0) * Isnull(bb_Item_Invoice_Level.Expected_Rate_CS,0) As decimal(18,2))
	   ELSE
		CAST(Isnull(bb_Item_Invoice_Level.Expected_LB,0) * Isnull(bb_Item_Invoice_Level.Expected_Rate_LB,0)  As decimal(18,2))
	END                                                                                                                                               AS Expected_Amount
        , CASE WHEN ##TMP_bb_Prod_Info.Billback_Status_ID >= 3 THEN 
			Cast( Isnull( bb_Item_Invoice_Level.Claimed_Amt, 0 ) AS  decimal(18,2) ) - Isnull( bb_Item_Invoice_Level.Final_Payment, 0 )  	
		ELSE

			Cast( Isnull( bb_Item_Invoice_Level.Claimed_Amt, 0 ) AS  decimal(18,2) ) -   		
			CASE WHEN UOM = 1 THEN CAST(Isnull(bb_Item_Invoice_Level.Expected_CS,0) * Isnull(bb_Item_Invoice_Level.Expected_Rate_CS,0) As decimal(18,2))
			ELSE CAST(Isnull(bb_Item_Invoice_Level.Expected_LB,0) * Isnull(bb_Item_Invoice_Level.Expected_Rate_LB,0)  As decimal(18,2))
			END 
		END
		AS Variation
		
        , Isnull( bb_Item_Invoice_Level.Claimed_cs, 0 )                                                                                                   AS Claim_cs
        , Isnull( bb_Item_Invoice_Level.Selected_vol_cs, 0 )                                                                                              AS Approved_cs
        , CASE bb_Item_Invoice_Level.Selected_Program_Price_Type
            WHEN 1 THEN bb_Item_Invoice_Level.Program_Price_cs
            WHEN 2 THEN bb_Item_Invoice_Level.Expected_Program_Price_cs
          END                                                                                                                                             AS Approved_Contract_Price
        , CASE bb_Item_Invoice_Level.Selected_Invoice_Price_Type
            WHEN 1 THEN bb_Item_Invoice_Level.Invoice_Price_cs
            WHEN 2 THEN bb_Item_Invoice_Level.Expected_Invoice_Price_cs
            WHEN 3 THEN bb_Item_Invoice_Level.Manual_Invoice_Price_cs
          END 
                                                                                                                                                          AS Approved_Invoice_Price
          , c.Name                                                                                                                                        AS Distributor_Name
          , c.Ship_To 
          
    INTO ##bb_Item_Invoice_Level_Info
     
    FROM ##TMP_bb_Prod_Info
          
	INNER JOIN bb_Item_Invoice_Level
    ON bb_Item_Invoice_Level.BillBack_Product_Id = ##TMP_bb_Prod_Info.BillBack_Product_Id        
    
	LEFT JOIN bsa_FoodService_Customers c
    ON c.bsa_FoodService_Customers_Id = ##TMP_bb_Prod_Info.Distributor_Id   
    
<!--- Query 4 --->    
IF OBJECT_ID('tempdb..##TMP_bb_Rebate_Info') IS NOT NULL
	DROP TABLE ##TMP_bb_Rebate_Info   
	  
	SELECT ##TMP_bb_Prod_Info.BillBack_Product_Id,
		      CASE
                        WHEN Program_Rebates_Component_Name.Program_Rebates_Component_Name IS NULL THEN 0
                        ELSE Cast( Program_Rebates_Component_Data.Rate AS FLOAT )
                      END   
                       AS Price_Protected_Amt,
		Program_Rebates_Component.Program_Rebates_Component_ID
    INTO ##TMP_bb_Rebate_Info
     
    FROM ##TMP_bb_Prod_Info                 
                       
    <!--- price protection joins start here --->
           LEFT JOIN 
           (Program_Rebates_Component
            INNER JOIN Program_Rebates_Component_Name
            ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_Id = Program_Rebates_Component.Program_Rebates_Component_Name_Id
            AND Program_Rebates_Component_Name.Rebate_Type = 2
           )
            ON Program_Rebates_Component.Deleted = 0
                AND Program_Rebates_Component.Program_Id = ##TMP_bb_Prod_Info.Contract_Main_Id
           LEFT JOIN Contract_Products
             ON Contract_Products.Deleted = 0
                AND Contract_Products.Contract_Main_Id = ##TMP_bb_Prod_Info.Contract_Main_Id
                AND Contract_Products.bsa_FoodService_Items_Master_Id = ##TMP_bb_Prod_Info.Product_Id
                AND Contract_Products.Product_Type_Id = 2
           LEFT JOIN Program_Rebates_Product_Data
             ON Program_Rebates_Product_Data.Deleted = 0
                AND Program_Rebates_Product_Data.Contract_Products_Id = Contract_Products.Contract_Products_Id
           LEFT JOIN Program_Rebates_Component_Data
             ON Program_Rebates_Component_Data.Deleted = 0
                AND Program_Rebates_Component_Data.Program_Rebates_Component_Id = Program_Rebates_Component.Program_Rebates_Component_Id
                AND Program_Rebates_Component_Data.Program_Rebates_Product_Data_Id = Program_Rebates_Product_Data.Program_Rebates_Product_Data_Id
                

  
  <!--- Query 5 ---> 
  IF OBJECT_ID('tempdb..##TMP_bb_deviation_Info') IS NOT NULL
	DROP TABLE ##TMP_bb_deviation_Info    
	
	
	SELECT 	##TMP_bb_Prod_Info.BillBack_Product_Id,
			CASE WHEN (BB_Program_Deviation_Info.Unauthorized_Payee > 0 OR BB_Program_Deviation_Info.Unauthorized_Payee > 0)					 
			THEN 1 ELSE 0 END														         AS DEVIATION_UNAUTHORIZED_PAYEE 
		    , CASE WHEN (BB_Product_Deviation_Info.Unauthorized_Product > 0 OR BB_Product_Deviation_Info.Unknown_Product > 0)					 
			THEN 1 ELSE 0 END														         AS DEVIATION_UNAUTHORIZED_PRODUCT
		    , CASE WHEN BB_Program_Deviation_Info.Dates_Not_Match > 0 
			THEN 1 ELSE 0 END														         AS DEVIATION_PROGRAM_DATES
   		    , CASE WHEN BB_Overlap_Deviation_Info.Overlap > 0
			THEN 1 ELSE 0 END														         AS DEVIATION_BILLBACK_OVERLAP
			
    INTO ##TMP_bb_deviation_Info
     
    FROM ##TMP_bb_Prod_Info        
       
	   LEFT JOIN BB_Overlap_Deviation_Info ON BB_Overlap_Deviation_Info.Deleted = 0 
                AND ##TMP_bb_Prod_Info.Billback_ID = BB_Overlap_Deviation_Info.Billback_ID
                AND ##TMP_bb_Prod_Info.BillBack_Product_Id = BB_Overlap_Deviation_Info.BillBack_Product_Id
           LEFT JOIN BB_Program_Deviation_Info ON BB_Program_Deviation_Info.Deleted = 0 
                AND ##TMP_bb_Prod_Info.Billback_Program_ID = BB_Program_Deviation_Info.Billback_Program_ID
           LEFT JOIN BB_Product_Deviation_Info ON BB_Product_Deviation_Info.Deleted = 0 
                AND ##TMP_bb_Prod_Info.Billback_Product_ID = BB_Product_Deviation_Info.Billback_Product_ID
     
     <!--- Query 6. This is the final query. The link between all the above data sets is  "BillBack_Product_Id" ---> 
     SELECT 
      ##TMP_bb_Prod_Info.Program_Title,##TMP_bb_Prod_Info.Program_Number,##TMP_bb_Prod_Info.Item_Number
     ,##TMP_bb_Prod_Info.Description,##TMP_bb_Prod_Info.bb_Product_Type_Id,##TMP_bb_Prod_Info.Product_Type_Id
     
     ,##TMP_Item_Final_Info.Expected_Rate,##TMP_Item_Final_Info.Approved_Rate,##TMP_Item_Final_Info.Item_e_Volume,##TMP_Item_Final_Info.Item_Approved_Volume
     
     ,##bb_Item_Invoice_Level_Info.Final_Payment,##bb_Item_Invoice_Level_Info.Expected_Amount,##bb_Item_Invoice_Level_Info.Claim_Rate
     ,##bb_Item_Invoice_Level_Info.Claim_Amount,##bb_Item_Invoice_Level_Info.Variation,##bb_Item_Invoice_Level_Info.Claim_cs
     ,##bb_Item_Invoice_Level_Info.Approved_cs,##bb_Item_Invoice_Level_Info.Approved_Contract_Price,##bb_Item_Invoice_Level_Info.Approved_Invoice_Price
     ,##bb_Item_Invoice_Level_Info.Distributor_Name,##bb_Item_Invoice_Level_Info.Ship_To
     
     
     ,##TMP_bb_Rebate_Info.Price_Protected_Amt,##TMP_bb_Rebate_Info.Program_Rebates_Component_ID
     
     
     ,##TMP_bb_deviation_Info.DEVIATION_UNAUTHORIZED_PAYEE,##TMP_bb_deviation_Info.DEVIATION_UNAUTHORIZED_PRODUCT
     ,##TMP_bb_deviation_Info.DEVIATION_PROGRAM_DATES,##TMP_bb_deviation_Info.DEVIATION_BILLBACK_OVERLAP
     
     FROM ##TMP_bb_Prod_Info
	  INNER JOIN ##TMP_Item_Final_Info
     ON ##TMP_bb_Prod_Info.BillBack_Product_Id = ##TMP_Item_Final_Info.BillBack_Product_Id
          INNER JOIN ##bb_Item_Invoice_Level_Info
     ON ##TMP_bb_Prod_Info.BillBack_Product_Id = ##bb_Item_Invoice_Level_Info.BillBack_Product_Id
          INNER JOIN ##TMP_bb_Rebate_Info
     ON ##TMP_bb_Prod_Info.BillBack_Product_Id = ##TMP_bb_Rebate_Info.BillBack_Product_Id
          INNER JOIN ##TMP_bb_deviation_Info
     ON ##TMP_bb_Prod_Info.BillBack_Product_Id = ##TMP_bb_deviation_Info.BillBack_Product_Id

     ORDER BY ##TMP_bb_Prod_Info.Is_Divested
              , ##bb_Item_Invoice_Level_Info.Ship_To
              , ##TMP_bb_Prod_Info.Product_Type_Id
              , ##TMP_bb_Prod_Info.Item_Number
              , ##TMP_bb_Prod_Info.bb_Product_Type_Id            
  </cfquery>

  <cfreturn udf.result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="getClientLabel" output="false" returntype="string" hint="Returns client label based on bsa label.">
  <cfargument name="bsaLabel" required="true">

  <cfscript>
    //suppress any error, return bsa label when error occurs
    try {
      return main.clientLabels[ arguments.bsaLabel ];
    }
    catch (any e) {
      return arguments.bsaLabel;
    }
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="IsActive" output="false" returntype="boolean" hint="Returns true if label is active.">
  <cfargument name="bsaLabel" required="true">

  <cfscript>
    //suppress any error, return false when error occurs
    try {
      return ( len(main.clientLabels[ arguments.bsaLabel ]) gt 0 );
    }
    catch (any e) {
      return false;
    }
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="priceProtectionExists" output="false" returntype="boolean">
  <cfloop query="main.items">
    <cfif Len(Trim(main.items.Program_Rebates_Component_ID)) gt 0>
      <cfreturn true>
    </cfif>
  </cfloop>

  <cfreturn false>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="getWords" output="false">
  <cfargument name="str" required="true">
  <cfargument name="words" required="true">

  <cfscript>
  /**
   * Shortens a string without cutting words in half.
   * Modified by Raymond Camden on July 30, 2001
   *
   * @param str      The string to modify.
   * @param words      The number of words to display.
   * @author David Grant (david@insite.net)
   * @version 2, July 30, 2001
   */
      var numWords = 0;
      var oldPos = 1;
      var i = 1;
      var strPos = 0;

      str = trim(str);
      str = REReplace(str,"[[:space:]]{2,}"," ","ALL");
      numWords = listLen(str," ");
      if (words gte numWords) return str;
      for (i = 1; i lte words; i=i+1) {
          strPos = find(" ",str,oldPos);
          oldPos = strPos + 1;
      }
      if (len(str) lte strPos) return left(str,strPos-1);
      return left(str,strPos-1) & "...";
  </cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="rowHeight" returnType="numeric" access="public" output="false" hint="Return row height in pixels based on the argument text length.">
  <cfargument name="text" type="string"/>

  <cfscript>
    if ( len(arguments.text) gt 320 ) {
      return 130;
    }
    else if ( len(arguments.text) gt 280 ) {
      return 104;
    }
    else if ( len(arguments.text) gt 210 ) {
      return 78;
    }
    else if ( len(arguments.text) gt 140 ) {
      return 52;
    }
    else {
      return 26;
    }
  </cfscript>
</cffunction>

