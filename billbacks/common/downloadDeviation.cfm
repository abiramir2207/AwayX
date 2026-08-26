<!-----------------------------------------------------------------------------

FILE NAME:		downloadDeviation.cfm
DESCRIPTION:	Download the deviation from the Deviation Grid.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	23-Nov-2015		 

------------------------------------------------------------------------------>

<cfparam name="URL.BBID" 	default="">
<cfparam name="URL.UserID" 	default="">
 
<cfset BBDetails = CreateObject("component","mvc.models.Billback.BillbackDevAppManager").getBillbackHeader(BBID = URL.BBID,UserID = URL.UserID) />   
 
<cfsetting enablecfoutputonly="Yes">

	<cfstoredproc procedure="BB_Claimed_Expted_Selected_DTL" datasource="#application.datasource#">
    	<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#URL.BBID#">      
		  <cfprocresult name="qryDeviationData">  
    </cfstoredproc>
	<cfset strDeliveryPeriod = BBDetails.BB_Start_Date & " to " & BBDetails.BB_End_Date />
	<cfset currentDate = "#DateFormat(Now(),'dd-mmm-yyyy')#" />	 
	<cfset ExcelName = "Deviation_#BBDetails.BB_Code#.xls">
	<CFSET DEVIATION_RATE_FORMAT = "(_$_.____)">
	<cfset operatorLabel = Ucase(application.returned_customer_setting.Operator_Label_Singular) />
	<cfset distLabel = Ucase(application.returned_customer_setting.Distributor_Label_Singular)  />
	<cfset prodLabel = Ucase(application.returned_customer_setting.Item_Label) />
	
	<cfset iBBDevOverridePrice = 0 />
	<cfif application.appSettingsGet.getBB_Deviations_Override_Price() eq 1 OR BBDetails.BB_Level_Deviations_Override_Price_Flag eq 1>
		<cfset iBBDevOverridePrice = 1 />
	</cfif>
	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
	<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	<!--- Create a new Worksheet and name it --->
	<cfset newSheet = workBook.createSheet() />
	<cfset workBook.setSheetName(0, "Deviation #BBDetails.BB_Code#") />
	<!--- Creates the default Font --->

	<cfset f = workBook.createFont() />
	<cfset f2 = workBook.createFont() />
	<cfset f3 = workBook.createFont() />
	<cfset f4 = workBook.createFont() />
	<cfset f5 = workBook.createFont() />
	
	<cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
	<!--- <cfset f4.setBoldweight(f4.BOLDWEIGHT_BOLD) /> --->
	
		
	<cfset f.setFontHeightInPoints(8) />
	<cfset f.setFontName("Century Gothic") />
	
	<cfset f2.setFontHeightInPoints(8) />
	<cfset f2.setFontName("Century Gothic") />
	 
	<cfset f3.setFontHeightInPoints(8) />
	<cfset f3.setFontName("Century Gothic") />
	 
	<cfset f3.setFontHeightInPoints(8) />
	<cfset f3.setFontName("Century Gothic") />
	 
	<cfset f4.setFontHeightInPoints(8) />
	<cfset f4.setFontName("Century Gothic") />
	
	<cfset f5.setFontHeightInPoints(8) />
	<cfset f5.setFontName("Century Gothic") />

	<cfset cs = workBook.createCellStyle() />
	<cfset csBoldCenter = workBook.createCellStyle() />
	<cfset csCenter = workBook.createCellStyle() />
	<cfset csBoldRight = workBook.createCellStyle() />
	<cfset csRight = workBook.createCellStyle() />
	
	
	<cfset cs2 = workBook.createCellStyle() />
	<cfset cswrap = workBook.createCellStyle() />
	<cfset cswrap2 = workBook.createCellStyle() />
	
	<cfset cs.setFont(f) />
	<cfset cswrap.setFont(f3) />
	<cfset cswrap.setWrapText(true) />
	<!--- <cfset csBoldCenter.setAlignment(csCenter.ALIGN_CENTER) /> --->
	<cfset csBoldCenter.setFont(f) />
	
	<!--- <cfset csCenter.setAlignment(csBoldCenter.ALIGN_CENTER) /> --->
	<cfset csCenter.setFont(f2) />
	
	<cfset cs2.setFont(f3) />
	
	<!--- <cfset csBoldRight.setAlignment(csBoldCenter.ALIGN_RIGHT) /> --->
	<cfset csBoldRight.setFont(f4) />
	
	<!--- <cfset csRight.setAlignment(csBoldCenter.ALIGN_RIGHT) /> --->
	<cfset csRight.setFont(f5) />
 
	<!--- Create a row and the Header cell --->
	<!--- BB Info Rows --->
	
	<cfset colCount = 0 />
	<cfset constVal = 265 />
	<cfset row1 = newSheet.createRow(0) /> 
	
	
	<cfset cell_1 = row1.createCell(0) />
	<cfset newSheet.setColumnWidth(0,5565) /> <!--- width: 21 OK --->
	<cfset cell_1.setCellValue("Payable Number") />
	<cfset cell_1.setCellStyle(cs) />
	
	<cfset cell_2 = row1.createCell(1) />
	<cfset newSheet.setColumnWidth(1,5565) /> <!--- width: 21 OK --->
	<cfset cell_2.setCellValue("Payable Title") />
	<cfset cell_2.setCellStyle(cs) />
	
	<cfset cell_3 = row1.createCell(2) />
	<cfset newSheet.setColumnWidth(2,5565) /> <!--- width: 21 OK --->
	<cfset cell_3.setCellValue("Delivery Period") />
	<cfset cell_3.setCellStyle(cs) />
	
	
		<!--- DEVIATION ROWS --->
	
	<cfset cell1 = row1.createCell(3) />
	<cfset newSheet.setColumnWidth(3,5565) /> <!--- width: 21 OK ---> 
	<cfset cell1.setCellValue("Program") />
	<cfset cell1.setCellStyle(cs) />
	
	<cfset cell2 = row1.createCell(4) />
	<cfset newSheet.setColumnWidth(4,5565) /><!--- width: 21 OK --->
	<cfset cell2.setCellValue("Distributor") />
	<cfset cell2.setCellStyle(cs) />
	
	<cfset cell3 = row1.createCell(5) />
	<cfset newSheet.setColumnWidth(5,4800) /> <!--- width: 18 	OK --->
	<cfset cell3.setCellValue("Item") />
	<cfset cell3.setCellStyle(cs) />
	
	<cfset cell4 = row1.createCell(6) />
	<cfset newSheet.setColumnWidth(6,2750) />	<!--- width: 10 OK --->
	<cfset cell4.setCellValue("Type") />
	<cfset cell4.setCellStyle(csBoldCenter) />
	
	<cfset cell5 = row1.createCell(7) />
	<cfset newSheet.setColumnWidth(7,4800) />	<!--- width: 18 OK --->
	<cfset cell5.setCellValue("Unauthorized Payee") />
	<cfset cell5.setCellStyle(csBoldCenter) />
	
	<cfset cell6 = row1.createCell(8) />
	<cfset newSheet.setColumnWidth(8,3270) /> <!--- width: 12 OK --->
	<cfset cell6.setCellValue("Date Match") />
	<cfset cell6.setCellStyle(csBoldCenter) />	
	
	<cfset cell7 = row1.createCell(9) />
	<cfset newSheet.setColumnWidth(9,3525) /> <!--- width: 13 OK --->
	<cfset cell7.setCellValue("Date Overlap ") />
	<cfset cell7.setCellStyle(csBoldCenter) />
	
	<cfset cell8 = row1.createCell(10) />
	<cfset newSheet.setColumnWidth(10,3525) /> <!--- width: 13 OK --->
	<cfset cell8.setCellValue("Authorization") />
	<cfset cell8.setCellStyle(csBoldCenter) />      
	
	<cfset cell9 = row1.createCell(11) />
	<cfset newSheet.setColumnWidth(11,2475) /> <!--- width: 9 OK --->
	<cfset cell9.setCellValue("Volume") />
	<cfset cell9.setCellStyle(csBoldCenter) />
	
	<cfset cell10 = row1.createCell(12) />
	<cfset newSheet.setColumnWidth(12,1960) /> <!--- width: 7 OK --->
	<cfset cell10.setCellValue("Rate") />
	<cfset cell10.setCellStyle(csBoldCenter) />
	
	<cfset cell11 = row1.createCell(13) />
	<cfset newSheet.setColumnWidth(13,3525) />	<!--- width: 13 OK --->
	<cfset cell11.setCellValue("Total Deviation") />
	<cfset cell11.setCellStyle(cs) />
	
	<!--- Rate --->
	<cfset cell12 = row1.createCell(14) />
	<cfset newSheet.setColumnWidth(14,2220) />	<!--- width: 8 OK --->
	<cfset cell12.setCellValue("Exp Rate") />
	<cfset cell12.setCellStyle(csBoldCenter) />
	
	<cfset cell13 = row1.createCell(15) />
	<cfset newSheet.setColumnWidth(15,3000) />	<!--- width: 11 OK --->
	<cfset cell13.setCellValue("Claimed Rate") />
	<cfset cell13.setCellStyle(csBoldCenter) />
	
	<cfset cell14 = row1.createCell(16) />
	<cfset newSheet.setColumnWidth(16,3000) />	<!--- width: 11  OK --->	
	<cfset cell14.setCellValue("Manual Rate") />
	<cfset cell14.setCellStyle(csBoldCenter) />
	
	<!--- Volume --->
	<cfset cell15 = row1.createCell(17) />
	<cfset newSheet.setColumnWidth(17,3000) />		<!--- width: 11 OK --->
	<cfset cell15.setCellValue("Exp Volume") />
	<cfset cell15.setCellStyle(csBoldCenter) />
	
	<cfset cell16 = row1.createCell(18) />
	<cfset newSheet.setColumnWidth(18,4010) />	<!--- width: 15 OK --->
	<cfset cell16.setCellValue("Claimed Volume") />
	<cfset cell16.setCellStyle(csBoldCenter) />
	
	<cfset colCount = 19 />
	<cfset cell17 = row1.createCell(19) />
	<cfset newSheet.setColumnWidth(19,3525) />	<!--- width: 13 OK --->
	<cfset cell17.setCellValue("Manual Volume") />
	<cfset cell17.setCellStyle(csBoldCenter) />
		
<cfif iBBDevOverridePrice>
	<!--- Invoice Price --->
	<cfset colCount = colCount + 1 />
	<cfset cellInvPrice1 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3000) />
	<cfset cellInvPrice1.setCellValue("Exp Inv Price") />
	<cfset cellInvPrice1.setCellStyle(csBoldCenter) />
	
	<cfset colCount = colCount + 1 />
	<cfset cellInvPrice2 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,4010) />
	<cfset cellInvPrice2.setCellValue("Claimed Inv Price") />
	<cfset cellInvPrice2.setCellStyle(csBoldCenter) />
	
	<cfset colCount = colCount + 1 />
	<cfset cellInvPrice3 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3525) />
	<cfset cellInvPrice3.setCellValue("Manual Inv Price") />
	<cfset cellInvPrice3.setCellStyle(csBoldCenter) />
	
	<!--- Program Price --->
	<cfset colCount = colCount + 1 />
	<cfset cellPgmPrice1 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3000) />
	<cfset cellPgmPrice1.setCellValue("Exp Pgm Price") />
	<cfset cellPgmPrice1.setCellStyle(csBoldCenter) />
	
	<cfset colCount = colCount + 1 />
	<cfset cellPgmPrice2 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,4010) />
	<cfset cellPgmPrice2.setCellValue("Claimed Pgm Price") />
	<cfset cellPgmPrice2.setCellStyle(csBoldCenter) />
	
	<cfset colCount = colCount + 1 />
	<cfset cellPgmPrice3 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3525) />
	<cfset cellPgmPrice3.setCellValue("Manual Pgm Price") />
	<cfset cellPgmPrice3.setCellStyle(csBoldCenter) />
</cfif>
		
	<!--- Amount fields --->
	<cfset colCount = colCount + 1 />
	<cfset cell18 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3270) />	<!--- width: 12 OK --->
	<cfset cell18.setCellValue("Exp Amount") />
	<cfset cell18.setCellStyle(csBoldRight) />
	
	<cfset colCount = colCount + 1 />
	<cfset cell19 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3525) />	<!--- width: 13 OK --->
	<cfset cell19.setCellValue("Claimed Amt") />
	<cfset cell19.setCellStyle(csBoldRight) />
	
	<cfset colCount = colCount + 1 />
	<cfset cell20 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,3525) />	<!--- width: 13 OK --->
	<cfset cell20.setCellValue("Final Payment") />
	<cfset cell20.setCellStyle(csBoldRight) />
	
	<cfset colCount = colCount + 1 />
	<cfset cell21 = row1.createCell(colCount) />
	<cfset newSheet.setColumnWidth(colCount,1960) />	<!--- width: 7 OK --->
	<cfset cell21.setCellValue("Count") />
	<cfset cell21.setCellStyle(csBoldCenter) />
<!--- <cfdump var="#qryDeviationData#" /> <cfabort> --->
	<cfloop query="qryDeviationData">
	
		<cfset strUP = "FAIL" />
		<cfset strPD = "FAIL" />
		<cfset strBO = "FAIL" />
		<cfset strUI = "FAIL" />
		<cfset strDV = "FAIL" />
		<cfset strDR = "FAIL" />
		<cfset strIDone = "NO" />
	
		<cfif qryDeviationData.DEVIATION_UNAUTHORIZED_PAYEE EQ "0">
			<cfset strUP = "PASS" />
		</cfif>
		<cfif qryDeviationData.DEVIATION_PROGRAM_DATES EQ "0">
			<cfset strPD = "PASS" />
		</cfif>
		<cfif qryDeviationData.DEVIATION_BILLBACK_OVERLAP EQ "0">
			<cfset strBO = "PASS" />
		</cfif>
		<cfif qryDeviationData.DEVIATION_UNAUTHORIZED_PRODUCT EQ "0">
			<cfset strUI = "PASS" />
		</cfif>
		<cfif qryDeviationData.DEVIATION_VOLUME EQ "0">
			<cfset strDV = "PASS" />
		</cfif>
		<cfif qryDeviationData.DEVIATION_RATE EQ "0">
			<cfset strDR = "PASS" />
		</cfif>
		<cfif qryDeviationData.iDone EQ "1">
			<cfset strDR = "YES" />
		</cfif>
	
		<cfset row2 = newSheet.createRow(currentRow) />

		<!--- <cfset row2.createCell(0).setCellValue(BBDetails.BB_Code) /> --->
		<cfset cell_0 = row2.createCell(0) />
		<cfset cell_0.setCellValue(BBDetails.BB_Code) />
		<cfset cell_0.setCellStyle(cs2) />	

		<!--- <cfset row2.createCell(1).setCellValue(UCase(BBDetails.BB_Title)) /> --->
		<cfset cell_1 = row2.createCell(1) />
		<cfset cell_1.setCellValue(UCase(BBDetails.BB_Title)) />
		<cfset cell_1.setCellStyle(cs2) />	
		
		<!--- <cfset row2.createCell(2).setCellValue(strDeliveryPeriod) /> --->
		<cfset cell_2 = row2.createCell(2) />
		<cfset cell_2.setCellValue(strDeliveryPeriod) />
		<cfset cell_2.setCellStyle(cs2) />	

		<!--- <cfset row2.createCell(3).setCellValue(UCase(qryDeviationData.Program)) /> --->
		<cfset cell_3 = row2.createCell(3) />
		<cfset cell_3.setCellValue(UCase(qryDeviationData.Program)) />
		<cfset cell_3.setCellStyle(cs2) />	
		<!--- <cfset cell_3.setCellStyle(csWrap) />	 --->

		<!--- <cfset row2.createCell(4).setCellValue(qryDeviationData.Distributor) /> --->
		<cfset cell_4 = row2.createCell(4) />
		<cfset cell_4.setCellValue(qryDeviationData.Distributor) />
		<cfset cell_4.setCellStyle(cs2) />			

		<!--- <cfset row2.createCell(5).setCellValue(qryDeviationData.Item) /> --->
		<cfset cell_5 = row2.createCell(5) />
		<cfset cell_5.setCellValue(qryDeviationData.Item) />
		<cfset cell_5.setCellStyle(cs2) />			
		
		<cfset cell_6 = row2.createCell(6) />
		<cfset cell_6.setCellValue(qryDeviationData.Discount_Type_Desc) />
		<cfset cell_6.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(7).setCellValue(strUP) /> ---> <!--- qryDeviationData.DEVIATION_UNAUTHORIZED_PAYEE) --->
		<cfset cell_7 = row2.createCell(7) />
		<cfset cell_7.setCellValue(strUP) />
		<cfset cell_7.setCellStyle(csCenter) />
		
		<!--- 	<cfset row2.createCell(8).setCellValue(strPD) /> ---> <!--- qryDeviationData.DEVIATION_PROGRAM_DATES --->
		<cfset cell_8 = row2.createCell(8) />
		<cfset cell_8.setCellValue(strPD) />
		<cfset cell_8.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(9).setCellValue(strBO) /> --->  <!--- qryDeviationData.DEVIATION_BILLBACK_OVERLAP ---> <!--- DateFormat(ORG_BB_Start_Date,"mm/dd/yyyy")) />		 --->	   
		<cfset cell_9 = row2.createCell(9) />
		<cfset cell_9.setCellValue(strBO) />
		<cfset cell_9.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(10).setCellValue(strUI) /> --->  <!--- qryDeviationData.DEVIATION_UNAUTHORIZED_PRODUCT ---> <!--- DateFormat(ORG_BB_End_Date,"mm/dd/yyyy")) /> --->
		<cfset cell_10 = row2.createCell(10) />
		<cfset cell_10.setCellValue(strUI) />
		<cfset cell_10.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(11).setCellValue(strDV) />  ---> <!--- qryDeviationData.DEVIATION_VOLUME --->
		<cfset cell_11 = row2.createCell(11) />
		<cfset cell_11.setCellValue(strDV) />
		<cfset cell_11.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(12).setCellValue(strDR) /> ---> <!--- qryDeviationData.DEVIATION_RATE --->
		<cfset cell_12 = row2.createCell(12) />
		<cfset cell_12.setCellValue(strDR) />
		<cfset cell_12.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(13).setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Variation_Claim_Expected))) /> --->
		<cfset cell_13 = row2.createCell(13) />
		<cfset cell_13.setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Variation_Claim_Expected))) />
		<cfset cell_13.setCellStyle(cs2) />
		
		<!--- Rate --->
		<!--- <cfset row2.createCell(14).setCellValue(JavaCast("string",NumberFormat(qryDeviationData.E_Rate,DEVIATION_RATE_FORMAT))) />  --->
		<cfset cell_14 = row2.createCell(14) />
		<cfset cell_14.setCellValue(JavaCast("string",NumberFormat(qryDeviationData.E_Rate,DEVIATION_RATE_FORMAT))) />
		<cfset cell_14.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(15).setCellValue(JavaCast("string",NumberFormat(qryDeviationData.Claimed_Rate,DEVIATION_RATE_FORMAT))) /> --->
		<cfset cell_15 = row2.createCell(15) />
		<cfset cell_15.setCellValue(JavaCast("string",NumberFormat(qryDeviationData.Claimed_Rate,DEVIATION_RATE_FORMAT))) />
		<cfset cell_15.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(16).setCellValue(JavaCast("string",NumberFormat(qryDeviationData.Manual_Rate,DEVIATION_RATE_FORMAT))) /> --->
		<cfset cell_16 = row2.createCell(16) />
		<cfset cell_16.setCellValue(JavaCast("string",NumberFormat(qryDeviationData.Manual_Rate,DEVIATION_RATE_FORMAT))) />
		<cfset cell_16.setCellStyle(csCenter) />

		<!--- Volume --->
		<!--- <cfset row2.createCell(17).setCellValue(JavaCast("string",NumberFormat(qryDeviationData.E_Volume,'____.__'))) /> --->
		<cfset cell_17 = row2.createCell(17) />
		<cfset cell_17.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.E_Volume,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_17.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(18).setCellValue(JavaCast("string",NumberFormat(qryDeviationData.Claimed_Volume,'____.__'))) /> --->
		<cfset cell_18 = row2.createCell(18) />
		<cfset cell_18.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Claimed_Volume,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_18.setCellStyle(csCenter) />
		
		<!--- <cfset row2.createCell(19).setCellValue(JavaCast("string",NumberFormat(qryDeviationData.Manual_Vol,'____.__'))) />	 --->		   
		<cfset colCount = 19 />
		<cfset cell_19 = row2.createCell(19) />
		<cfset cell_19.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Manual_Vol,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_19.setCellStyle(csCenter) />
		
	<cfif iBBDevOverridePrice>
		<!--- Invoice Price --->
		<cfset colCount = colCount + 1 />
		<cfset cell_InvPrice1 = row2.createCell(colCount) />
		<cfset cell_InvPrice1.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Expected_Invoice_Price,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_InvPrice1.setCellStyle(csCenter) />
		
		<cfset colCount = colCount + 1 />
		<cfset cell_InvPrice2 = row2.createCell(colCount) />
		<cfset cell_InvPrice2.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Claim_Invoice_Price,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_InvPrice2.setCellStyle(csCenter) />
		
		<cfset colCount = colCount + 1 />
		<cfset cell_InvPrice3 = row2.createCell(colCount) />
		<cfset cell_InvPrice3.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Manual_Invoice_Price,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_InvPrice3.setCellStyle(csCenter) />
		
		<!--- Program Price --->
		<cfset colCount = colCount + 1 />
		<cfset cell_PgmPrice1 = row2.createCell(colCount) />
		<cfset cell_PgmPrice1.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Expected_Program_Price,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_PgmPrice1.setCellStyle(csCenter) />
		
		<cfset colCount = colCount + 1 />
		<cfset cell_PgmPrice2 = row2.createCell(colCount) />
		<cfset cell_PgmPrice2.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Claimed_Program_Price,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_PgmPrice2.setCellStyle(csCenter) />
		
		<cfset colCount = colCount + 1 />
		<cfset cell_PgmPrice3 = row2.createCell(colCount) />
		<cfset cell_PgmPrice3.setCellValue(JavaCast("string",(NumberFormat(qryDeviationData.Manual_Program_Price,'____.__') & " #qryDeviationData.UOM_Short#"))) />
		<cfset cell_PgmPrice3.setCellStyle(csCenter) />
		
	</cfif>
		
		<!--- Amount fields --->
		<!--- <cfset row2.createCell(20).setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Expected_Amount))) /> --->	
		<cfset colCount = colCount + 1 />
		<cfset cell_20 = row2.createCell(colCount) />
		<cfset cell_20.setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Expected_Amount))) />
		<cfset cell_20.setCellStyle(csRight) />
		
		<!--- <cfset row2.createCell(21).setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Claimed_Amount))) /> --->
		<cfset colCount = colCount + 1 />
		<cfset cell_21 = row2.createCell(colCount) />
		<cfset cell_21.setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Claimed_Amount))) />
		<cfset cell_21.setCellStyle(csRight) />
		
		<!--- <cfset row2.createCell(22).setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Final_Payment))) /> --->
		<cfset colCount = colCount + 1 />
		<cfset cell_22 = row2.createCell(colCount) />
		<cfset cell_22.setCellValue(JavaCast("string",DollarFormat(qryDeviationData.Final_Payment))) />
		<cfset cell_22.setCellStyle(csRight) />
		
		<!--- <cfset row2.createCell(23).setCellValue(JavaCast("string",qryDeviationData.iDone)) /> --->
		<cfset colCount = colCount + 1 />
		<cfset cell_23 = row2.createCell(colCount) />
		<cfset cell_23.setCellValue(JavaCast("string",strIDone)) />
		<cfset cell_23.setCellStyle(csCenter) />
		
	</cfloop>
 
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	<cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	<cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true"  />
	 
	  
	 
	

