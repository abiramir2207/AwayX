<!--- OCRExccelParser  = CreateObject("component","components.Billback.OCRExcelParser"); --->
<cfcomponent hint="Logic for Paseing CIA uploaded Excel files">
	
	<cffunction name="parse" returntype="any" output="true" description="called from OCR_File_Mover">		
 		<cfargument name="srcFile" required="true" type="String"/>
		<cfargument name="q" required="true" type="query"/>
		 
		 <cfscript>
		 	var arrParseResult = [];
			var arrMappedResult = [];
		 	var OCRUploadDAO  = CreateObject("component","components.Billback.OCRUploadDAO");
			try{
				//Parse Excel file in an Array of Arrays  common_documents\data_files\uploaded\documents\uploaded_doc
		 		arrParseResult = this.parseFile(arguments.srcFile,q);
		 		//writedump(arrParseResult);
		 		if((arraylen(arrParseResult)==1 && IsSimpleValue(arrParseResult[1]) == true) || arraylen(arrParseResult)==0){ //there was an error parseing so return it.
					return arrParseResult;
				}
				//Map the columns based on Template
				switch(arguments.q.OCR_Code) {
				    case "PFG_OT13":
				         arrMappedResult = this.cleanMapDataPFGOT13(arrParseResult);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format(arrMappedResult,arguments.q);
				         break;
				   case "PFG_OT2":
				         arrMappedResult = this.cleanMapDataPFGOT2(arrParseResult);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData(arrMappedResult,arguments.q);
				         break;
				    case "PFG_OT5":
				         arrMappedResult = this.cleanMapDataPFGOT5(arrParseResult);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmp_OCR_Trackmax1_Excel_Format(arrMappedResult,arguments.q);
				         break;
				    case "Shamrock_OT1":
				         arrMappedResult = this.cleanMapDataShamrockOT1(arrParseResult);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData(arrMappedResult,arguments.q);
				         break;
				    case "ARAMARK_CA":
				         arrMappedResult = this.cleanMapDataAramarkOT2(arrParseResult);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmp_OCR_Aramark_Excel_Format(arrMappedResult,arguments.q);
				         break;
				    case "Foodbuy_OT1":
				         arrMappedResult = this.cleanMapDataFoodbuyOT1(arrParseResult,arguments.q);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData(arrMappedResult,arguments.q);
				         break;
				    case "Foodbuy_OT2":
				         arrMappedResult = this.cleanMapDataFoodbuyOT2(arrParseResult,arguments.q);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData(arrMappedResult,arguments.q);
				         break;
				    case "Sodexo_OT1":
				         arrMappedResult = this.cleanMapDataSodexoOT1(arrParseResult,arguments.q);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData(arrMappedResult,arguments.q);
				         break;
				    case "Sodexo_OT2":
				         arrMappedResult = this.cleanMapDataSodexoOT2(arrParseResult,arguments.q);
				         // Insert data from parseresults into table #Tmp_OCR_PFG_Operator_PDF_Excel_Format
						 OCRUploadDAO.insTmpOCR_PFG_Operator_PDF_Excel_Format_SructData(arrMappedResult,arguments.q);
				         break;
				         
				    default: 
				         arrMappedResult[1]='The Uploaded File "#ListLast(srcFile,'\')#" was not parsed due to an unrecognized template.  Please verify the configuration.  [error OCR_Code]';
				}
			}
			catch(any eParseFile){ //Parse failed
				arrMappedResult = [];
				arrMappedResult[1]='The Uploaded File "#ListLast(srcFile,'\')#" is not in correct Excel format  [error PARSE FILE]';
				this.log(eParseFile);
				//writedump(eParseFile);
				return arrMappedResult;
			}
			
			if(arraylen(arrMappedResult)==1 && IsSimpleValue(arrMappedResult[1]) == true){ //there was an error parseing so return it.
				return arrMappedResult;
			}
			else if(arraylen(arrMappedResult)==0){
				arrMappedResult[1] = 'Unable to map data in spreadsheet.  The mapping routine returned 0 rows.  Probably wrong file format. [error Map_Data]';
				return arrMappedResult;	
			}
			else{// Continue processing data -> send it to DB
				//Insert data from tmp table to Stageing DB table OCR_PFG_Operator_PDF_Excel_Format
				switch(arguments.q.OCR_Code) {
				    case "Foodbuy_OT1": case "Foodbuy_OT2": case "Sodexo_OT1": case "Sodexo_OT2": 
				         OCRUploadDAO.insOCR_PFG_Operator_PDF_Excel_Format();
				         break;
				    case "PFG_OT13": case "PFG_OT2": case "Shamrock_OT1":
				         OCRUploadDAO.insOCR_Trackmax1_From_PFG_Operator_PDF_Tmp();
				         break;
				    case "PFG_OT5":
				         OCRUploadDAO.insOCR_Trackmax1_Excel_Format();
				         break;
				     case "ARAMARK_CA":
				         OCRUploadDAO.ins_OCR_Aramark_Excel_Format();
				         break;
				    default: 
				         arrMappedResult[1]='The Uploaded File "#ListLast(srcFile,'\')#" was not Inserted into DB.  We should not be here.  [error OCR_Code DB]';
				}
				// Clean up Scientific notation amount/quantity from parser
				OCRUploadDAO.updOCR_Trackmax1_Excel_Format_NumberFormats(arguments.q.OCR_Upload_ID);
				//writedump(arrMappedResult);
				return arrMappedResult; // not the real parsed data which is in a DB table OCR_PFG_Operator_PDF_Excel_Format.  can only return an array in case of an error.
			}
	 	</cfscript>
	</cffunction>
	
	<cffunction name="parseFile" returntype="any" output="true">		
 		<cfargument name="srcFile" required="true" type="String"/>
		 <cfargument name="q" required="true" type="query"/>
 		<cfscript>
		 	var OCRUploadDAO  = CreateObject("component","components.Billback.OCRUploadDAO");
		 	var javaFileObj = createObject('java', 'java.io.File');
			var excelFileObj = createObject('java', 'java.io.FileInputStream');
			var javaReaderObj = createObject('java', 'java.io.FileReader');
			var csvFormat = createObject('java', 'org.apache.commons.csv.CSVFormat');
			//var oldExtractor = createObject('java', 'org.apache.poi.hssf.extractor.OldExcelExtractor');
			//var npoi = createObject('java', 'org.apache.poi.poifs.filesystem.NPOIFSFileSystem');
			var fExt = '';
			var arr = [];
			var isExcel = 1;
			try{
				javaFile = javaFileObj.init(srcFile);
				excelFile = excelFileObj.init(javaFile);
				csvFile = javaReaderObj.init(srcFile);
				DataFormatter = createObject('java', 'org.apache.poi.ss.usermodel.DataFormatter').init();
				//CellType = createObject('java', 'org.apache.poi.ss.usermodel.CellType').init();
				
				if(right(srcFile,5) == '.xlsx'){
					fExt = '.xlsx';
					Workbook = createObject('java', 'org.apache.poi.xssf.usermodel.XSSFWorkbook').init(excelFile);
				}
				else if(right(srcFile,4) == '.xls'){
					fExt = '.xls';
					Workbook = createObject('java', 'org.apache.poi.hssf.usermodel.HSSFWorkbook').init(excelFile);
				}
				else if(right(srcFile,4) == '.csv'){
					fExt = '.csv';
					csvFormat = createObject('java', 'org.apache.commons.csv.CSVParser').parse(csvFile,csvFormat.EXCEL);
					isExcel= 0;
					arrCsv =csvFormat.getRecords();
					arrData = [];
					 for (i=1;i LTE ArrayLen(arrCsv);i=i+1) {
					 	//ArrayAppend(arr,arrCsv[i].iterator());
					 	arrData = [];
					 	thisIteraor = arrCsv[i].iterator();
					 	while (thisIteraor.hasNext()) {
					 		thisVal = thisIteraor.next().toString();
					 		ArrayAppend(arrData,thisVal);
					 	}
					 	ArrayAppend(arr,arrData);
					 }
				}
				// else if(right(srcFile,5) == '.xlsb'){
				// 	isExcel= 0;
				// 	this.cfConvert(srcFile);
				// 	//  update filename to converted name
				// 	OCRUploadDAO.updUploadLogStatusConverted(#q.OCR_Upload_ID#);
				// }
			}
			catch(any e){
				isExcel= 0;
				if(isDefined('excelFile')){excelFile.close();}
				if(e.Message contains 'Invalid header signature'){ //We think it is HTML, Attempt to Parse HTML
					try{
						arr = this.parseHtml(javaFile);
					}
					catch(any eHtmlParse){ //HTML Parse failed
						arr[1]='The Uploaded File "#ListLast(srcFile,'\')#" is not in correct Excel format (it may have been copied data from an HTML web page) and contains unexpected data.  Please open the file and "Save As #fExt#" and then try your upload again.  [error HTML FORMAT]';
						this.log(eHtmlParse);
						//writedump(eHtmlParse);
						return arr;
					}
					
				}//excel 95.  try jexcel
				else if(e.Message contains 'Expected to find a ContinueRecord' ||  e.Message contains 'BIFF5'){
					this.cfConvert(srcFile);
					//  update filename to converted name
					OCRUploadDAO.updUploadLogStatusConverted(#q.OCR_Upload_ID#);
					
				}
				else{//Unrecognized error return the bad news
					arr[1]='The Uploaded File "#ListLast(srcFile,'\')#" is not in correct Excel format or contains unexpected data.  Please open the file and "Save As #fExt#" and then try your upload again. [error EXCEL FORMAT]';
					this.log(e);
					writedump(e);
					return arr;	
				}
			}
			
			if(isExcel){//POI was able to read the spreadsheet so parse results
				// get the first sheet index is 0 based in Java
				try{
					sheet1 = Workbook.getSheetAt(0);
					rowIterator = sheet1.iterator();
					arr = [];
					item = '';
					while (rowIterator.hasNext()) {
						currentRow = rowIterator.next();
						a = [];
						  cellIterator = currentRow.iterator();
						  while (cellIterator.hasNext()) {
						    currentCell = cellIterator.next();

						  //  this.log(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::OOOOO');
						  //  this.log(currentCell.getCellType());
						  //  this.log(DataFormatter.getDefaultFormat(currentCell));
						  //  this.log(DataFormatter.formatCellValue(currentCell));
						  //  this.log(currentCell.getStringCellValue());
						  //  this.log(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::XXXXX');

						    if(!isDate(DataFormatter.formatCellValue(currentCell))){
						    	currentCell.setCellType(currentCell.CELL_TYPE_STRING);
							}
						    ArrayAppend(a,DataFormatter.formatCellValue(currentCell),"true");
						    //ArrayAppend(a,currentCell.toString(),"true");
						    //x = x + 1; 
						  }
							ArrayAppend(arr,a,"false");
							//i = i + 1;
					}
					// this.log(currentCell);
				}
				catch(any eExcelParse){ //HTML Parse failed
						arr = [];
						arr[1]='The Uploaded File "#ListLast(srcFile,'\')#" contains unexpected data.  Please verify the format of the file and the selected Invoice type.  [error EXCEL DATA]';
						this.log(eExcelParse);
						return arr;
				}
				// close the file input stream
				excelFile.close();
			}
		 	return arr;
		 </cfscript>
	</cffunction>
	
	<cffunction name="parseHtml" returntype="any" output="true" hint="called from parseFile() already in a try/catch">		
 		<cfargument name="fileObj" required="true" type="String"/>
 		<cfscript>
		 	jSoup = createObject("java","org.jsoup.Jsoup");
			document = jsoup.parse(fileObj, "UTF-8");
			body = document.body();
			arrRows = body.getElementsByTag('tr');
			//doc = fileReader.init(currentFilePath & currentTemplate);
			//writedump(arrRows[10].getElementsByTag('td'));
			arr=[];
			for (i=1;i LTE ArrayLen(arrRows);i=i+1) {
				a=[];
				arrCells = arrRows[i].getElementsByTag('td');
				for (x=1;x LTE ArrayLen(arrCells);x=x+1) {
					txt = arrCells[x].text();
					//txt = Replace(txt,'  ',' ','all');
					ArrayAppend(a,txt,"true");
					colSpan = arrCells[x].attr('ColSpan');
					//writeOutput();
					//WriteOutput(arrCells[x].attr('ColSpan'));
					// When there is a colspan, fill out the retrurned array with empty "cell data"
					if(isnumeric(colSpan)){
						for (col=x;col LTE colSpan-1;col=col+1) {
							ArrayAppend(a,'',"true");
						}
					}
				}
				ArrayAppend(arr,a,"false");
			}
			if(Arraylen(arr)){ //OK we parsed the HTML
				writeoutput('<br>html parse #arraylen(arr)#');// Not really needed
			}
			else{//return an error we go no data in HTML Parse attempt
			arr[1] = 'No Data was captured';
			}
			
		 	return arr;
		 </cfscript>
	</cffunction>
	
	<cffunction name="cleanMapDataPFGOT13" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var item = '';
			var packSize= '';
			var itemDesc= '';
			var page = '';
			var arr = [];
			var sDate = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var weekEndDate = now();
			var itemQuantity = 0;
			var vendorQuantityTotal = 0;
			var vendorAmountTotal = 0;
			
			//writedump(arguments.arrData);
			//this.log(arrDAta);
			for (i=1;i LTE ArrayLen(arguments.arrDAta);i=i+1) {
				//WriteOutput(array[i]);
				arr = arguments.arrData[i];
				//EXTRA COLUMNS
				while (ArrayLen(arr) GT 14) {
					ArrayDeleteAt(arguments.arrData[i], ArrayLen(arguments.arrData[i]));
					ArrayDeleteAt(arr, ArrayLen(arr));
				}
				if(i == 4){ //week ending
					sDate = trim(listLast(arr[1],':'));
					sDAte = replace(sDAte,chr(160),'','All');
					/*for (q=1;q LTE Len(sDAte);q=q+1) {
						WriteOutput(' :' &asc(sDAte)&': ');
					}*/
					//WriteOutput('|' & sDate & '|');
					weekEndDate = createdate(listGetAt(sDate,3,'/'),listfirst(sDate,'/'),listGetAt(sDate,2,'/'));
					n = DayofWeek(weekEndDate) * -1;
					invStartDate = DateAdd('d' ,n + 1,weekEndDate);
					invDate = DateAdd('d' ,2,weekEndDate);
					invEndDate = weekEndDate;
					
					invDate = dateformat(invDate,"short" );
					invStartDate = dateformat(invStartDate,"short" );
					invEndDate = dateformat(invEndDate,"short" );
				}
				else if(i == 2){//Page
					page = listLast(arr[1],':');
					page = replace(page,chr(160),'','All');
				}
				else if(i > 11){ //Only for Item level data
					ArrayAppend(arguments.arrDAta[i],invDate);
					ArrayAppend(arguments.arrDAta[i],invStartDate);
					ArrayAppend(arguments.arrDAta[i],invEndDate);
					ArrayAppend(arguments.arrDAta[i],page);
					//Program Info
					arguments.arrDAta[i][7] = arguments.arrDAta[i][7];
					arguments.arrDAta[i][8] = Replace(arguments.arrDAta[i][8],ListFirst(arguments.arrDAta[i][8],' '),arguments.arrDAta[i][7]);
					// handle negatives
					if(arguments.arrDAta[i][10] contains ')' and arguments.arrDAta[i][10] contains '('){
							arguments.arrDAta[i][10] = Replace(arguments.arrDAta[i][10],'(','',"all" );
							arguments.arrDAta[i][10] = Replace(arguments.arrDAta[i][10],')','',"all" );
							arguments.arrDAta[i][10] = arguments.arrDAta[i][10] * -1;
					}
					if(arguments.arrDAta[i][14] contains ')' and arguments.arrDAta[i][14] contains '('){
							arguments.arrDAta[i][14] = Replace(arguments.arrDAta[i][14],'(','',"all" );
							arguments.arrDAta[i][14] = Replace(arguments.arrDAta[i][14],')','',"all" );
							arguments.arrDAta[i][14] = arguments.arrDAta[i][14] * -1;
					}
					// Sometimes "Eaches is populated" so add it to the Quantity -> handle negatives
					if( trim(len(arguments.arrDAta[i][11])) GT 0 ){
						if(isnumeric(arguments.arrDAta[i][11])){
							arguments.arrDAta[i][10]  = arguments.arrDAta[i][10] + arguments.arrDAta[i][11];
						}
						else if(arguments.arrDAta[i][11] contains ')' and arguments.arrDAta[i][11] contains '('){
							arguments.arrDAta[i][11] = Replace(arguments.arrDAta[i][11],'(','',"all" );
							arguments.arrDAta[i][11] = Replace(arguments.arrDAta[i][11],')','',"all" );
							arguments.arrDAta[i][11] = arguments.arrDAta[i][11] * -1;
							arguments.arrDAta[i][10] = arguments.arrDAta[i][10] + arguments.arrDAta[i][11];
							arguments.arrDAta[i][10] = arguments.arrDAta[i][10] & ' Broken Cases';
						}
					}
					//Only want fgood item level data.  No subtotals. need numeric qty and Amount
					IF( 
							(!arr[8] contains 'Warehouse Totals:') 
							&& (!arr[8] contains 'Vendor Totals:') 
							&& (!arr[1] == 'Item') 
							&& (isNumeric(arguments.arrDAta[i][10]) || arguments.arrDAta[i][10] contains 'Broken Cases')
							&& isnumeric(arguments.arrDAta[i][14]) 
						){ 		
						//item is sort of header level.  populate the data down
					 	if(len(trim(arr[1]))){
					 		item = #arr[5]#; // use mfgr item # col E
					 		if(len(trim(#arr[4]#)) > 0){ //USE UPC if available
					 			item = #arr[4]#;
					 		}
							item = #arr[4]#;
							packSize = arr[2];
							itemDesc = "#arr[2]# #arr[3]#";
							
							arguments.arrDAta[i][4] = item; // UPC field...stays upc if it has data else mfgr item # gets populated
							arguments.arrDAta[i][3] = itemDesc;
						}
						else{
							arguments.arrDAta[i][4] = item;
							arguments.arrDAta[i][2] = packSize;
							arguments.arrDAta[i][3] = itemDesc;
						}
					 	//ArrayAppend(arr,a,"false"); 
					 }
					 else{//remove it
					 //	writeoutput('<br>Remove #i#');
					 	if(arr[8] contains 'Vendor Totals:'){
							/*if(isNumeric(arguments.arrDAta[i][11])){
								vendorQuantityTotal = arguments.arrDAta[i][10] + arguments.arrDAta[i][11];
							}
							else{
								vendorQuantityTotal = arguments.arrDAta[i][10];
							}*/
							vendorQuantityTotal = arguments.arrDAta[i][10];
							vendorAmountTotal = arguments.arrDAta[i][14];
	
						}
					 	if(ArrayDeleteAt(arguments.arrDAta,i)){
					 		i = i - 1;
					 	}
					  }
					  
				}
			}
			for (z=12;z LTE ArrayLen(arguments.arrDAta);z=z+1) {
				ArrayAppend(arguments.arrDAta[z],vendorQuantityTotal);
				ArrayAppend(arguments.arrDAta[z],vendorAmountTotal);
			}
			//this.log(arrDAta);
		 	return arguments.arrDAta;
		 </cfscript>
	</cffunction>
	
	<cffunction name="cleanMapDataPFGOT2" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var dt = '';
			var location= '';
			var itemDesc= '';
			var page = '';
			var arr = [];
			var sDate = '';
			var invDate = dateformat(now(),"short" );
			var invStartDate = dateformat(now(),"short" );
			var invEndDate = dateformat(now(),"short" );
			var itemQuantity = 0;
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			var tmpAmount = '';
			var tmpQuant = '';
			
			//Get Total
			arr = arguments.arrData[arrayLen(arguments.arrData)];
			if(arr[14] contains 'Total Rebate Due'){
				totalInvoiceAmount = #arr[22]#;
				totalInvoiceQuantity = 0;
			}
			for (i=1;i LTE Arraylen(arguments.arrData);i=i+1) {
				//WriteOutput(array[i]);
				arr = arguments.arrData[i];
				stData = structNew();
				stData.totalInvoiceAmount = totalInvoiceAmount;
				stData.totalInvoiceQuantity = totalInvoiceQuantity;
			/*	DATE LOGIC IS HANDLED IN TMP TABLE INSERT */
				if(i==2){ //Location :: HEADERs
					location = trim(arr[1]);
					location = replace(location,chr(160),'','All');
				}
				tmpAmount = arr[22];
				if(tmpAmount contains(')')){
					tmpAmount = replace(tmpAmount,')','');
					tmpAmount = "-" & replace(tmpAmount,'(','');
				}
				tmpQuant = arr[20];
				if( tmpQuant contains(')')){
					tmpQuant = replace(tmpQuant,')','');
					tmpQuant = "-" & replace(tmpQuant,'(','');
				}
				
				
				if(i > 20 && isnumeric(tmpAmount) && isnumeric(tmpQuant) ){//ROW DATA
					itemDesc = '#arr[12]# #arr[13]# #arr[14]#';
					stData.item = #arr[11]#;;
					stData.itemDesc = itemDesc;
					if(#arr[4]# == ''){
						stData.programInfo = #arr[6]#;
					}
					else{
						stData.programInfo = #arr[4]#;
					}
					stData.oprNumber = #arr[5]#;
					stData.oprInfo = #arr[6]#;
					stData.location = location;
					stData.invoiceNumber = #arr[16]#;
					stData.itemAllowance = #arr[19]#;
					stData.quantity = #tmpQuant#;
					stData.totalAllowance = #tmpAmount#;
					stData.invEndDate = invEndDate;
					stData.invStartDate = invStartDate;
					stData.invDate =  #arr[17]#;
					ArrayAppend(aResult,stData);
				}
				/* else if(i > 20 && (NOT isnumeric(tmpAmount) || NOT isnumeric(tmpQuant) ) ){
					this.log(arr);
				} */
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>
	
	<cffunction name="cleanMapDataPFGOT5" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var dt = '';
			var location= '';
			var programInfo = '';
			var invoiceNumber = '';
			var itemDesc= '';
			var page = '';
			var arr = [];
			var sDate = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var itemQuantity = 0;
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			
			//Get Total
			//writedump(arguments.arrData);
			//abort;
			location = arguments.arrData[2][1];
			programInfo = arguments.arrData[16][2];
			invoiceNumber = arguments.arrData[14][1];
			aDates = arguments.arrData[Arraylen(arguments.arrData) - 5];
			if(aDates[1] contains('This Statement was posted on')){ //DATE :: HEADER
					sDate = aDates[1];
					sDate = trim(replace(sDate,'This Statement was posted on ','',"all" ));
					sDate = trim(replace(sDate,' and covers program activity between ',':',"all" ));
					sDate = trim(replace(sDate,' and ',':',"all" ));

					invDate = trim(ListFirst(sDate,':'));
					invStartDate = trim(ListGetAt(sDate,'2',':'));
					invEndDate = trim(ListLAst(sDate,':'));
					
					invDate = createDate(listLast(invDate,'/'),listfirst(invDate,'/'),listgetAt(invDate,2,'/'));
					invStartDate = createDate(listLast(invStartDate,'/'),listfirst(invStartDate,'/'),listgetAt(invStartDate,2,'/'));
					invEndDate = createDate(listLast(invEndDate,'/'),listfirst(invEndDate,'/'),listgetAt(invEndDate,2,'/'));
					
			}
			else if(arguments.arrData[9][1] contains('This Statement was posted on')){
				sDate = arguments.arrData[9][1];
				sDate = trim(replace(sDate,'This Statement was posted on ','',"all" ));
				sDate = trim(replace(sDate,' and covers','',"all" ));
				invDate = trim(sDate);
				invDate = createDate(listLast(invDate,'/'),listfirst(invDate,'/'),listgetAt(invDate,2,'/'));
				
				sDate = arguments.arrData[10][2];
				sDate = trim(replace(sDate,'program activity between ','',"all" ));
				sDate = trim(replace(sDate,' and ',':',"all" ));
				invStartDate = trim(ListFirst(sDate,':'));
				invEndDate = trim(ListLAst(sDate,':'));
				invStartDate = createDate(listLast(invStartDate,'/'),listfirst(invStartDate,'/'),listgetAt(invStartDate,2,'/'));
				invEndDate = createDate(listLast(invEndDate,'/'),listfirst(invEndDate,'/'),listgetAt(invEndDate,2,'/'));
			}
			invDate = dateformat(invDate,"short" );
			invStartDate = dateformat(invStartDate,"short" );
			invEndDate = dateformat(invEndDate,"short" );
			for (i=1;i LTE Arraylen(arguments.arrData);i=i+1) {
				//WriteOutput(array[i]);
				arr = arguments.arrData[i];
				if( arr[1] == 'Our Invoice Number:'){
					invoiceNumber = arguments.arrData[i+2][1];
				}
				if( arr[1] == 'Program Description:'){
					programInfo = arr[2];
				}
				stData = structNew();
				stData.totalInvoiceAmount = totalInvoiceAmount;
				if(i > 20 && ( (arraylen(arr) == 15 && FindNoCase('Due',arr[15]) == 0  )  || (arraylen(arr) == 17 && FindNoCase('Due',arr[17]) == 0) || (arraylen(arr) == 14 && FindNoCase('Due',arr[14]) == 0)  ) ){//ROW DATA
					if(arraylen(arr) == 15 && FindNoCase('Due',arr[15]) == 0){
						itemDesc = '#arr[7]# #arr[6]#';
						stData.item = #arr[9]#;
						stData.itemDesc = itemDesc;
						stData.packSize = #arr[6]#;
						stData.quantity = #arr[11]#;
						stData.totalAllowance = #arr[15]#;
						stData.itemTotalCharges = #arr[13]#;
						stData.itemTotalWeight = #arr[12]#;
					}
					else if(arraylen(arr) == 17 && FindNoCase('Due',arr[17]) == 0){
						itemDesc = '#arr[8]# #arr[7]#';
						stData.item = #arr[10]#;
						stData.itemDesc = itemDesc;
						stData.packSize = #arr[7]#;
						stData.quantity = #arr[13]#;
						stData.totalAllowance = #arr[17]#;
						stData.itemTotalCharges = #arr[15]#;
						stData.itemTotalWeight = #arr[14]#;
					}
					else if(arraylen(arr) == 14 && FindNoCase('Due',arr[14]) == 0){
						itemDesc = '#arr[7]# #arr[6]#';
						stData.item = #arr[9]#;
						stData.itemDesc = itemDesc;
						stData.packSize = #arr[6]#;
						stData.quantity = #arr[10]#;
						stData.totalAllowance = #arr[14]#;
						stData.itemTotalCharges = #arr[12]#;
						stData.itemTotalWeight = #arr[11]#;
					}
					stData.invEndDate = invEndDate;
					stData.invStartDate = invStartDate;
					stData.invDate = invDate;
					stData.location = location;
					stData.programInfo = programInfo;
					stData.invoiceNumber = invoiceNumber;
					
					stData.totalInvoiceAmount = totalInvoiceAmount;
					stData.TotalInvoiceQuantity = TotalInvoiceQuantity;
					
					stData.oprNumber = '';

					ArrayAppend(aResult,stData);
				}
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>
	
	<cffunction name="cleanMapDataShamrockOT1" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var dt = '';
			var location= '';
			var programInfo = '';
			var invoiceNumber = '';
			var itemDesc= '';
			var page = '';
			var arr = [];
			var sDate = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var itemQuantity = 0;
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			var iOpr = 0;
			
			//Get Total
			//writedump(arguments.arrData);
			//abort;
			location = arguments.arrData[17][1];
			invoiceNumber = arguments.arrData[4][2];
			if(arguments.arrData[6][1] contains('Memo Date:')){ //DATE :: HEADER
					sDate = arguments.arrData[6][2];
					invDate = sDate;
					invDate = createDate(listLast(invDate,'/'),listfirst(invDate,'/'),listgetAt(invDate,2,'/'));
			}
			invDate = dateformat(invDate,"short" );
			n = arraylen(arguments.arrData);
			if(Arraylen(arguments.arrData[n]) == 7 ){
				totalInvoiceAmount = arguments.arrData[n][7];
				TotalInvoiceQuantity = arguments.arrData[n][2];
			}

			for (i=1;i LTE Arraylen(arguments.arrData);i=i+1) {
				//WriteOutput(array[i]);
				arr = arguments.arrData[i];
				stData = structNew();
				stData.totalInvoiceAmount = totalInvoiceAmount;
				stData.TotalInvoiceQuantity = TotalInvoiceQuantity;
				if(i > 17){  //ROW DATA
					if(Arraylen(arr) == 1){ //OPERATOR
						if(i == iOpr + 1 ){//second row in a row with a single col
							location = programInfo; // Location is the previous row that we captured
						}
						stData.programInfo = arr[1];
						programInfo = arr[1]; //struct gets wiped every loop
						iOpr = i;
					}
					else{
						stData.programInfo = programInfo;
					}
					nLen = Arraylen(arr);
					if(nLen >= 13){  // only process rows with item level data
						itemDesc = '#arr[4]# #arr[5]# #arr[3]#';
						stData.item = arr[2];
						stData.itemDesc = itemDesc;
						stData.packSize = arr[3];
						stData.quantity = arr[10];
						stData.totalAllowance = arr[nLen];
						stData.ITEMALLOWANCE = arr[nLen];
						stData.itemTotalCharges = arr[nLen];
						stData.itemTotalWeight = 0;
						
						stData.invDate = invDate;
						stData.location = location;
						stData.invoiceNumber = invoiceNumber;
						
						stData.oprNumber = #arr[9]#;
						stData.oprInfo = #arr[1]#;
						
						invStartDate = arr[8];//we will get min max
						invEndDate = arr[8];  //we will get min max
						invStartDate = createDate(listLast(invStartDate,'/'),listfirst(invStartDate,'/'),listgetAt(invStartDate,2,'/'));
						invEndDate = createDate(listLast(invEndDate,'/'),listfirst(invEndDate,'/'),listgetAt(invEndDate,2,'/'));
						invStartDate = dateformat(invStartDate,"short" );
						invEndDate = dateformat(invEndDate,"short" );
						
						stData.invEndDate = invEndDate;
						stData.invStartDate = invStartDate;
	
						ArrayAppend(aResult,stData);
					}
				}
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>

	<cffunction name="cleanMapDataAramarkOT2" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var iOffSet = 0;
			var aResult = [];
			var arr = [];
			var arrHeader = [];
			var stData = structnew();
			var sHeader = '';
			var item= '';

			var Distributor = 0;
			var ItemName = 0;
			var Brand= 0;
			var PackSize = 0;
			var Qty = 0;
			var Amt = 0;
			var Allowance = 0;
			var PlanName = 0;
			var Unit = 0;
			var Start = 0;
			var End = 0;
			//get header Row to check col names and position
			var arrHeader = arguments.arrData[1];
			// Check header row for required data
			for (n=1;n LTE Arraylen(arrHeader);n=n+1) {
				sHeader = arrHeader[n];
				switch(sHeader) {
				    case "Distributor":
				    	Distributor = n;
				        break; 
				    case "ItemName":
				        ItemName = n;
				        break;
				    case "Brand":
				        Brand = n;
				        break;
				    case "PackSize":
				        PackSize = n;
				        break;
				    case "Unit":
				        Unit = n;
				        break;
				    case "Qty":
				        Qty = n;
				        break;
				    case "Amt":
				        Amt = n;
				        break; 
				    case "Allowance":
				        Allowance = n;
				        break; 
				    case "Start":
				        Start = n;
				        break;    
				    case "End":
				        End = n;
				        break; 
				     case "PlanName":
				        PlanName = n;
				        break; 
				 }
			}
			//this.log(arguments.arrData);
			if(Allowance > 0 && Qty > 0){
				for (i=2;i LTE Arraylen(arguments.arrData);i=i+1) {//start at 2 so we skip the header
					iOffSet = 0;
					arr = arguments.arrData[i];
					if(ArrayLen(arr) != ArrayLen(arrHeader)){ //The division coloumn is present and has no data
						iOffSet = 1;
					}
					if(arraylen(arr) >= 13){
						startDate = trim(arr[start - iOffSet]);
						startDate = replace(startDate,'.0','');
						startDate = this.getMonthStartDate(right(startDate,2), Left(startDate,4));
						endDate = trim(arr[end - iOffSet]);
						endDate = replace(endDate,'.0','');
						endDate = this.getMonthStartDate(right(endDate,2), Left(endDate,4));
						endDate =( DateAdd( "m", 1, endDate ) -1 ); //get last day of month
						stData = structNew();
						itemDesc = '#trim(arr[ItemName - iOffSet])# #trim(arr[Brand - iOffSet])# #trim(arr[PackSize - iOffSet])#';
						stData.item = replace(arr[1],"'","");
						stData.itemDesc = itemDesc;
						stData.start = dateformat(startDate,"short" );
						stData.end = dateformat(endDate,"short" );
						stData.brand = trim(arr[Brand - iOffSet]);
						stData.packSize = arr[PackSize - iOffSet];
						stData.quantity = arr[Qty - iOffSet];
						stData.totalAllowance = arr[Allowance - iOffSet];
						stData.ITEMALLOWANCE = arr[Allowance - iOffSet];
						stData.itemTotalCharges = arr[Amt - iOffSet];
						stData.location = arr[Distributor];// dont need offset
						stData.PlanName = arr[PlanName];// dont need offset
						stData.Unit = arr[Unit - iOffSet];
						//	stData.itemTotalWeight = 0;
						ArrayAppend(aResult,stData);
					}
				}
			}
			//this.log(aResult);
			//abort;
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>

	<cffunction name="cleanMapDataFoodbuyOT1" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfargument name="q" required="false" type="query"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var programInfo = 0;
			var location = 0;
			var item = 0;
			var itemDesc = 0;
			var brand = 0;
			var PackSize = 0;
			var Quantity = 0;
			var totalAllowance = 0;
			var ITEMALLOWANCE = 0;
			var oprNumber = 0;
			var sItemDesc = '';
			var arr = [];
			var arrDataVar = [];
			var sDate = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			var iOpr = 0;
			var sDate = '';
			var sMonth = '';
			var sYear = '';
			var iLen = 0;
			
			arrDataVar = arguments.arrData;
			//location = arguments.arrData[17][1];
			//INVOICE_NUMBER
			if(Arraylen(arrDataVar[5]) >= 2){
				invoiceNumber = arrDataVar[5][2];
			}
			else if(Arraylen(arrDataVar[5]) == 1){
				invoiceNumber = ListLast(arrDataVar[5][1],' ## ');
			}
			//this.log(Arraylen(arrDataVar[3]));
			//this.log(arrDataVar[3]);
			//this.log(arrDataVar[4]);
			//this.log(arrDataVar[5]);
			//Start and end date
			if(LEFT(arrDataVar[3][1],13) == 'For Reporting'){
				iLen = listLen(arrDataVar[3][1],' ');
				sMonth = listgetAt(arrDataVar[3][1],iLen - 1,' ');
				sYear = listgetAt(arrDataVar[3][1],iLen,' ');
			}
			else if(LEFT(arrDataVar[4][1],6) == 'Period'){
				sDate = arrDataVar[4][2];
				sMonth = listFirst(sDate,' ');
				sYear =  listLast(sDate,' ');
			}
			invStartDate = this.getMonthStartDate(sMonth, sYear);
			invEndDate = createdate(DatePart('yyyy',invStartDate),DatePart('m',invStartDate),daysInMonth(invStartDate));
			invStartDate = dateformat(invStartDate,"short" );
			invEndDate = dateformat(invEndDate,"short" );

			// n = arraylen(arrDataVar);
			// if(Arraylen(arrDataVar[n]) == 7){
			// 	totalInvoiceAmount = arrDataVar[n][7];
			// 	TotalInvoiceQuantity = arrDataVar[n][2];
			// }
			var arrHeader = arrDataVar[6];
			// Check header row for required data
			for (n=1;n LTE Arraylen(arrHeader);n=n+1) {
				sHeader = arrHeader[n];
				switch(sHeader) {
				    case "Location Name": case "Unit Name":
				    	programInfo = n;
				        break; 
				    case "Distributor Name":
				        location = n;
				        break;
				    case "Min":  case "Item Min":
				        item = n;
				        break;
				    case "Item Desc": case "Description": 
				        itemDesc = n;
				        break;
				    case "Label": case "Item Label":
				        brand = n;
				        break;
				    case "pack Size":
				        PackSize = n;
				        break; 
				    case "Quantity":
				        Quantity = n;
				        break; 
				     case "Total Invoiced": case "Extended Total":
				        totalAllowance = n;
				        break; 
				    case "Va Per":  case "STD VA PER CODE": 
				        ITEMALLOWANCE = n;
				        break; 
				    case "Location Id":
				        oprNumber = n;
				        break;
				 }
			}
			for (i=1;i LTE Arraylen(arrDataVar);i=i+1) {
				//WriteOutput(array[i]);
				arr = arrDataVar[i];
				nLen = Arraylen(arr);
				stData = structNew();
				//
				if(i > 6 && nLen >= 17 && arr[item] != ''){  //ROW DATA
					stData.PayeeType = 'O';  //Foddbuy is an Operator
					stData.programInfo = arguments.q.Source_Code;//stData.programInfo = arr[programInfo];
					sItemDesc = '#arr[itemDesc]# #arr[brand]# #arr[PackSize]#';
					stData.item = arr[item];
					stData.itemDesc = sItemDesc;
					stData.packSize = arr[PackSize];
					stData.quantity = arr[Quantity];
					stData.totalAllowance = arr[totalAllowance];
					stData.ITEMALLOWANCE = arr[ITEMALLOWANCE];
					stData.itemTotalCharges = 0;
					stData.itemTotalWeight = 0;
					
					stData.invDate = dateformat(now(),"short" ); //comes from user
					stData.location = arr[location];;
					stData.invoiceNumber = invoiceNumber;
					if(oprNumber > 0){
						stData.oprNumber = arr[oprNumber];
					}
					else{
						stData.oprNumber = '';
					}
					
					//stData.oprInfo = #arr[1]#;
					
					// invStartDate = arr[8];//we will get min max
					// invEndDate = arr[8];  //we will get min max
					// invStartDate = createDate(listLast(invStartDate,'/'),listfirst(invStartDate,'/'),listgetAt(invStartDate,2,'/'));
					// invEndDate = createDate(listLast(invEndDate,'/'),listfirst(invEndDate,'/'),listgetAt(invEndDate,2,'/'));
					// invStartDate = dateformat(invStartDate,"short" );
					// invEndDate = dateformat(invEndDate,"short" );
					
					stData.invEndDate = invEndDate;
					stData.invStartDate = invStartDate;

					stData.totalInvoiceAmount = 0;
					stData.TotalInvoiceQuantity = 0;

					ArrayAppend(aResult,stData);
				}
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>

	<cffunction name="cleanMapDataFoodbuyOT2" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfargument name="q" required="false" type="query"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var programInfo = 0;
			var location = 0;
			var item = 0;
			var itemDesc = 0;
			var brand = 0;
			var PackSize = 0;
			var Quantity = 0;
			var totalAllowance = 0;
			var ITEMALLOWANCE = 0;
			var oprNumber = 0;
			var sItemDesc = '';
			var arr = [];
			var arrDataVar = [];
			var sDate = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			var iOpr = 0;
			var sDate = '';
			var sMonth = '';
			var sYear = '';
			var iLen = 0;
			
			arrDataVar = arguments.arrData;
			//location = arguments.arrData[17][1];
			//INVOICE_NUMBER
			// if(Arraylen(arrDataVar[2]) >= 2){
			// 	invoiceNumber = arrDataVar[5][2];
			// }
			// else 
			//if(Arraylen(arrDataVar[5]) == 1){
				invoiceNumber = ListLast(arrDataVar[3][1],' ');
			//}
			//this.log(Arraylen(arrDataVar[3]));
			//this.log(arrDataVar[3]);
			//this.log(arrDataVar[4]);
			//this.log(arrDataVar[5]);
			//Start and end date
			if(LEFT(arrDataVar[2][1],13) == 'For Reporting'){
				iLen = listLen(arrDataVar[2][1],' ');
				sMonth = listgetAt(arrDataVar[2][1],iLen - 1,' ');
				sYear = listgetAt(arrDataVar[2][1],iLen,' ');
			}
			//this.log('#sMonth# :: #sYear#');
			// else if(LEFT(arrDataVar[4][1],6) == 'Period'){
			// 	sDate = arrDataVar[4][2];
			// 	sMonth = listFirst(sDate,' ');
			// 	sYear =  listLast(sDate,' ');
			// }
			invStartDate = this.getMonthStartDate(sMonth, sYear);
			invEndDate = createdate(DatePart('yyyy',invStartDate),DatePart('m',invStartDate),daysInMonth(invStartDate));
			invStartDate = dateformat(invStartDate,"short" );
			invEndDate = dateformat(invEndDate,"short" );

			// n = arraylen(arrDataVar);
			// if(Arraylen(arrDataVar[n]) == 7){
			// 	totalInvoiceAmount = arrDataVar[n][7];
			// 	TotalInvoiceQuantity = arrDataVar[n][2];
			// }
			var arrHeader = arrDataVar[5];
			// Check header row for required data
			for (n=1;n LTE Arraylen(arrHeader);n=n+1) {
				sHeader = arrHeader[n];
				switch(sHeader) {
				    case "Sector":
				    	programInfo = n;
				        break; 
				    case "Distributor":
				        location = n;
				        break;
				    case "Min":  case "Item Min":
				        item = n;
				        break;
				    case "Item Desc": case "Description": 
				        itemDesc = n;
				        break;
				    case "Brand":
				        brand = n;
				        break;
				    case "pack Size":
				        PackSize = n;
				        break; 
				    case "Quantity":
				        Quantity = n;
				        break; 
				     case "Total VA":
				        totalAllowance = n;
				        break; 
				    case "Va":
				        ITEMALLOWANCE = n;
				        break; 
				    case "Location Id":
				        oprNumber = n;
				        break;
				 }
			}
			for (i=1;i LTE Arraylen(arrDataVar);i=i+1) {
				//WriteOutput(array[i]);
				arr = arrDataVar[i];
				nLen = Arraylen(arr);
				stData = structNew();
				//
				if(i > 5 && nLen >= 13 && arr[item] != ''){  //ROW DATA
					stData.PayeeType = 'O';  //Foddbuy is an Operator
					stData.programInfo = arguments.q.Source_Code;//stData.programInfo = arr[programInfo];
					sItemDesc = '#arr[itemDesc]# #arr[brand]# #arr[PackSize]#';
					stData.item = arr[item];
					stData.itemDesc = sItemDesc;
					stData.packSize = arr[PackSize];
					stData.quantity = arr[Quantity];
					stData.totalAllowance = arr[totalAllowance];
					stData.ITEMALLOWANCE = arr[ITEMALLOWANCE];
					stData.itemTotalCharges = 0;
					stData.itemTotalWeight = 0;
					
					stData.invDate = dateformat(now(),"short" ); //comes from user
					stData.location = arr[location];;
					stData.invoiceNumber = invoiceNumber;
					if(oprNumber > 0){
						stData.oprNumber = arr[oprNumber];
					}
					else{
						stData.oprNumber = '';
					}
					
					//stData.oprInfo = #arr[1]#;
					
					// invStartDate = arr[8];//we will get min max
					// invEndDate = arr[8];  //we will get min max
					// invStartDate = createDate(listLast(invStartDate,'/'),listfirst(invStartDate,'/'),listgetAt(invStartDate,2,'/'));
					// invEndDate = createDate(listLast(invEndDate,'/'),listfirst(invEndDate,'/'),listgetAt(invEndDate,2,'/'));
					// invStartDate = dateformat(invStartDate,"short" );
					// invEndDate = dateformat(invEndDate,"short" );
					
					stData.invEndDate = invEndDate;
					stData.invStartDate = invStartDate;

					stData.totalInvoiceAmount = 0;
					stData.TotalInvoiceQuantity = 0;

					ArrayAppend(aResult,stData);
				}
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>

	<cffunction name="cleanMapDataSodexoOT1" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfargument name="q" required="false" type="query"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var programInfo = 0;
			var location = 0;
			var branch = 0;
			var item = 0;
			var itemDesc = 0;
			var brand = 0;
			var Pack = 0;
			var Size = 0;
			var Quantity = 0;
			var totalAllowance = 0;
			var ITEMALLOWANCE = 0;
			var oprNumber = 0;
			var month = 0;
			var year = 0;
			var sItemDesc = '';
			var arr = [];
			var arrDataVar = [];
			var sDate = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			var iOpr = 0;
			var sDate = '';
			var sMonth = '';
			var sYear = '';
			var iLen = 0;
			
			arrDataVar = arguments.arrData;
			invoiceNumber = '';
			var arrHeader = arrDataVar[1];
			// Check header row for required data
			for (n=1;n LTE Arraylen(arrHeader);n=n+1) {
				sHeader = arrHeader[n];
				switch(sHeader) {
				    case "UnitName": case "Purch Unit Nm":
				    	programInfo = n;
				        break; 
				    case "Distributor": case "Distrb Parnt Nm":
				        location = n;
				        break;
				    case "Branch": case "Distrb Nm":
				        Branch = n;
				        break;
				    case "Upc":  case "Prod Upc Cd":
				        item = n;
				        break;
				    case "prod Desc": case "Description": 
				        itemDesc = n;
				        break;
				    case "Brand": case "Brand Desc":
				        brand = n;
				        break;
				    case "pack": case "prod pkg":
				        Pack = n;
				        break; 
				    case "size": case "prod size": case "prod sz":
				        Size = n;
				        break;
				    case "Cases":  case "Sold Case Cnt":
				        Quantity = n;
				        break; 
				     case "Amount": case "Invc Amt": 
				        totalAllowance = n;
				        break; 
				    case "Allowance": case "vda rte":
				        ITEMALLOWANCE = n;
				        break; 
				    case "UnitId": case "Purch Unit Nb":
				        oprNumber = n;
				        break;
				    case "period": case "Pos Calendar Dt":
				        Month = n;
				        break;
				    case "Year": case "Pos Yr Nbr":
				        Year = n;
				        break;
				 }
			}
			for (i=2;i LTE Arraylen(arrDataVar);i=i+1) {
				//WriteOutput(array[i]);
				arr = arrDataVar[i];
				nLen = Arraylen(arr);
				stData = structNew();
				//
				if(nLen >= 20 && len(trim(arr[item])) > 0){  //ROW DATA
					stData.PayeeType = 'O';  //Foddbuy is an Operator
					stData.programInfo = arguments.q.Source_Code;//arr[programInfo];
					sItemDesc = '#arr[itemDesc]# #arr[brand]# #arr[Pack]# #arr[Size]#';
					stData.item = arr[item];
					stData.itemDesc = sItemDesc;
					stData.packSize = '#arr[Pack]# #arr[Size]#';
					stData.quantity = arr[Quantity];
					stData.totalAllowance = arr[totalAllowance];
					stData.ITEMALLOWANCE = arr[ITEMALLOWANCE];
					stData.itemTotalCharges = 0;
					stData.itemTotalWeight = 0;
					
					stData.invDate = dateformat(now(),"short" ); //comes from user
					stData.location = '#arr[location]# #arr[Branch]#';
					stData.invoiceNumber = invoiceNumber;
					if(oprNumber > 0){
						stData.oprNumber = arr[oprNumber];
					}
					else{
						stData.oprNumber = '';
					}
					sMonth = arr[month];
					sYear = arr[year];
					invStartDate = this.getMonthStartDate(sMonth, sYear);
					invEndDate = createdate(DatePart('yyyy',invStartDate),DatePart('m',invStartDate),daysInMonth(invStartDate));
					invStartDate = dateformat(invStartDate,"short" );
					invEndDate = dateformat(invEndDate,"short" );
					
					stData.invEndDate = invEndDate;
					stData.invStartDate = invStartDate;

					stData.totalInvoiceAmount = 0;
					stData.TotalInvoiceQuantity = 0;

					ArrayAppend(aResult,stData);
				}
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>

	<cffunction name="cleanMapDataSodexoOT2" returntype="any" output="true">		
 		<cfargument name="arrDAta" required="true" type="Array"/>
 		<cfargument name="q" required="false" type="query"/>
 		<cfscript>
			var i = 1;
			var n = 1;
			var aResult = [];
			var stData = structnew();
			var programInfo = '';
			var location = '';
			var sItemDesc = '';
			var arr = [];
			var arrDataVar = [];
			var sDate = '';
			var sInvNumber = '';
			var invDate = now();
			var invStartDate = now();
			var invEndDate = now();
			var totalInvoiceQuantity = 0;
			var totalInvoiceAmount = 0;
			
			arrDataVar = arguments.arrData;
			//this.log(arrDataVar);
			//abort;
			sInvNumber = arrDataVar[3][7];
			sInvNumber = Replace(sInvNumber,'Invoice No:' ,'');
			for (i=9;i LTE Arraylen(arrDataVar);i=i+1) {
				//WriteOutput(array[i]);
				arr = arrDataVar[i];
				nLen = Arraylen(arr);
				stData = structNew();
				//Location
				if(nLen == 12 && len(trim(arr[1])) > 0 && Arraylen(arrDataVar[i+1]) == 7 ){ 
					location = arr[1];
					i = i + 4; //after customer info, skip 6 lines to data
					continue;
				}
				if(nLen == 23 && len(trim(arr[9])) > 0 && len(trim(arr[1])) > 0){  //ROW DATA
					stData.location = location;
					stData.PayeeType = 'O';  //Foddbuy is an Operator
					stData.invoiceNumber = sInvNumber;
					stData.item = arr[9];
					stData.itemDesc = arr[3];
					stData.packSize = arr[7];
					stData.quantity = arr[11];
					stData.totalAllowance = arr[22];
					stData.ITEMALLOWANCE = 0; //arr[14];  Not reliable
					stData.programInfo = arguments.q.Source_Code;
					sItemDesc = '';
					stData.itemTotalCharges = 0;
					stData.itemTotalWeight = 0;
					stData.oprNumber = '';
					stData.invEndDate = dateformat(now(),"short" ); //comes from user
					stData.invStartDate = dateformat(now(),"short" ); //comes from user
					stData.invDate = dateformat(now(),"short" ); //comes from user

					stData.totalInvoiceAmount = 0;
					stData.TotalInvoiceQuantity = 0;

					ArrayAppend(aResult,stData);
				}
			}
		 	return aResult;
		 	//return arguments.arrDAta;
		 </cfscript>
	</cffunction>

	<cffunction name="getMonthStartDate" returntype="date">
		<cfargument name="sMonth" type="any" required="true" default="">
		<cfargument name="sYear" type="any" required="true" default="">
		<cfscript>
			var i = 1;
			var sResult = '';

			switch(arguments.sMonth) {
				    case "January": case "Jan": case "01":
				    	i = 1;
				        break; 
				    case "February": case "Feb": case "02":
				        i = 2;
				        break;
				    case "March": case "MAR": case "03":
				        i = 3;
				        break;
				    case "April": case "APR": case "04":
				        i = 4;
				        break;
				    case "May": case "05":
				        i = 5;
				        break;
				    case "June": case "Jun": case "06":
				        i = 6;
				        break;
				    case "July": case "Jul": case "07":
				        i = 7;
				        break; 
				    case "August": case "Aug": case "08":
				        i = 8;
				        break; 
				    case "September": case "Sep": case "09":
				        i = 9;
				        break;
				    case "October": case "Oct": case "10":
				        i = 10;
				        break;
				    case "November": case "Nov": case "11":
				        i = 11;
				        break;
				    case "December": case "Dec": case "12":
				        i = 12;
				        break;
				 }
			sResult = createDate(sYear,i,1);
			return sResult;
		</cfscript>
	</cffunction>


	<cffunction name="cfConvert" returntype="any" output="true">
		<cfargument name="fName" type="any" required="true" default="">
		<cfscript>
			var  outDir = Replace(fName,ListLast(fname,'\'),'');
			n = Len(outDir);
			outDir = RemoveChars(outDir, n, 1);
			//writedump(outDir);
;		</cfscript>
		<cfexecute name='C:\Program Files\LibreOffice 5\program\soffice.exe' arguments = ' --headless --convert-to xlsx "#fName#" --outdir "#outDir#"' outputFile = "C:\output.txt"/>
		<!---<cfexecute name='C:\Windows\System32\cmd.exe' arguments = '"C:\Program Files\LibreOffice 5\program\soffice.exe" --headless --convert-to xlsx "#fName#"' />--->
		<!---<cfexecute name='C:\Windows\System32\cmd.exe' arguments = '/C C:\_site_admin\Clients\BA\CIA\shamrock\test\convert.bat' outputFile = "C:\output.txt"/>--->
		<cfreturn >
	</cffunction>
	 
	<cffunction name="log" returntype="string">
		<cfargument name="error" type="any" required="true" default="">
		<cfdump var="#error#" output="C:\OCR_Error.log">
	</cffunction>

</cfcomponent>