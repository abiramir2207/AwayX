<!-----------------------------------------------------------------------------

FILE NAME:		overLapReport.cfm
DESCRIPTION:	Over Lap Report file
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	13-May-2013		 

------------------------------------------------------------------------------>

<cfparam name="URL.BBID" 	default="">
<cfparam name="URL.ProdID" 	default="">

<cfsetting enablecfoutputonly="Yes">

<cfstoredproc procedure="BB_Operator_Based_Overlap" datasource="#application.datasource#">
	<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value="#URL.BBID#">
	<cfif (isDefined("URL.BBProdID") AND URL.BBProdID NEQ "")>
		<cfprocparam type="IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Product_ID" value="#URL.ProdID#">
	</cfif>
	<cfprocresult name="OverLapDetails">  
</cfstoredproc>
		  
	<cfset currentDate = "#DateFormat(Now(),'dd-mmm-yyyy')#" />	 
	<cfset ExcelName = "OverLapReport.xls">
	<cfset operatorLabel = Ucase(application.returned_customer_setting.Operator_Label_Singular) />
	<cfset distLabel = Ucase(application.returned_customer_setting.Distributor_Label_Singular)  />
	<cfset prodLabel = Ucase(application.returned_customer_setting.Item_Label) />
		 
	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
	<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	<!--- Create a new Worksheet and name it --->
	<cfset newSheet = workBook.createSheet() />
	<cfset workBook.setSheetName(0, "OverLap Report #currentDate#") />
	<!--- Creates the default Font --->
	<cfset f = workBook.createFont() />
	<cfset cs = workBook.createCellStyle() />
	<cfset cswrap = workBook.createCellStyle() />
	<cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
	<cfset cs.setFont(f) />
	<cfset cswrap.setFont(f) />
	<cfset cswrap.setWrapText(true) />
	
	
	<!--- Create a row and the Header cell --->
	<cfset row1 = newSheet.createRow(0) />
	
	<cfset cell1 = row1.createCell(0) />
	<cfset cell1.setCellValue("SUSPECTED BB") />
	<cfset cell1.setCellStyle(cswrap) />
	
	<cfset cell201 = row1.createCell(1) />
	<cfset cell201.setCellValue("SUSPECTED BILLBACK NUMBER") />
	<cfset cell201.setCellStyle(cs) />
	
	<cfset cell2 = row1.createCell(2) />
	<cfset cell2.setCellValue("SUSPECTED BB START DATE") />
	<cfset cell2.setCellStyle(cs) />
	
	<cfset cell3 = row1.createCell(3) />
	<cfset cell3.setCellValue("SUSPECTED BB END DATE") />
	<cfset cell3.setCellStyle(cs) />
	
	<cfset cell4 = row1.createCell(4) />
	<cfset cell4.setCellValue("ORIGINAL BB") />
	<cfset cell4.setCellStyle(cs) />
	
	<cfset cell4 = row1.createCell(5) />
	<cfset cell4.setCellValue("ORIGINAL BILLBACK NUMBER") />
	<cfset cell4.setCellStyle(cs) />	
	
	<cfset cell5 = row1.createCell(6) />
	<cfset cell5.setCellValue("ORIGINAL BB START DATE") />
	<cfset cell5.setCellStyle(cs) />
	
	<cfset cell6 = row1.createCell(7) />
	<cfset cell6.setCellValue("ORIGINAL BB END DATE") />
	<cfset cell6.setCellStyle(cs) />      
	
	<cfset cell7 = row1.createCell(8) />
	<cfset cell7.setCellValue("OVERLAP %") />
	<cfset cell7.setCellStyle(cs) />
	
	<cfset cell8 = row1.createCell(9) />
	<cfset cell8.setCellValue("TOTAL VOLUME") />
	<cfset cell8.setCellStyle(cs) />
	
	<cfset cell9 = row1.createCell(10) />
	<cfset cell9.setCellValue("CONTRACT ID") />
	<cfset cell9.setCellStyle(cs) />
	
	<cfset cell10 = row1.createCell(11) />
	<cfset cell10.setCellValue("CONTRACT") />
	<cfset cell10.setCellStyle(cs) />
	
	<cfset cell11 = row1.createCell(12) />
	<cfset cell11.setCellValue("ORIGINAL CONTRACT ID") />
	<cfset cell11.setCellStyle(cs) />
	
	<cfset cell12 = row1.createCell(13) />
	<cfset cell12.setCellValue("ORIGINAL CONTRACT") />
	<cfset cell12.setCellStyle(cs) />
	
	<cfset cell13 = row1.createCell(14) />
	<cfset cell13.setCellValue("#operatorLabel# ID") />
	<cfset cell13.setCellStyle(cs) />
	
	<cfset cell14 = row1.createCell(15) />
	<cfset cell14.setCellValue("#operatorLabel#") />
	<cfset cell14.setCellStyle(cs) />
	
	<cfset cell15 = row1.createCell(16) />
	<cfset cell15.setCellValue("#operatorLabel# ADDRESS") />
	<cfset cell15.setCellStyle(cs) />
	
	<cfset cell16 = row1.createCell(17) />
	<cfset cell16.setCellValue("#operatorLabel# CITY") />
	<cfset cell16.setCellStyle(cs) />
	
	<cfset cell17 = row1.createCell(18) />
	<cfset cell17.setCellValue("#operatorLabel# STATE") />
	<cfset cell17.setCellStyle(cs) />
	
	<cfset cell18 = row1.createCell(19) />
	<cfset cell18.setCellValue("#operatorLabel# ZIP CODE") />
	<cfset cell18.setCellStyle(cs) />
	
	<cfset cell19 = row1.createCell(20) />
	<cfset cell19.setCellValue("#distLabel# ID") />
	<cfset cell19.setCellStyle(cs) />
	
	<cfset cell20 = row1.createCell(21) />
	<cfset cell20.setCellValue("#distLabel#") />
	<cfset cell20.setCellStyle(cs) />
	
	<cfset cell21 = row1.createCell(22) />
	<cfset cell21.setCellValue("#distLabel# ADDRESS") />
	<cfset cell21.setCellStyle(cs) />
	
	<cfset cell22 = row1.createCell(23) />
	<cfset cell22.setCellValue("#distLabel# CITY") />
	<cfset cell22.setCellStyle(cs) />
	
	<cfset cell23 = row1.createCell(24) />
	<cfset cell23.setCellValue("#distLabel# STATE") />
	<cfset cell23.setCellStyle(cs) />  
	
	<cfset cell24 = row1.createCell(25) />
	<cfset cell24.setCellValue("#distLabel# ZIP CODE") />
	<cfset cell24.setCellStyle(cs) />  
	
	<cfset cell25 = row1.createCell(26) />
	<cfset cell25.setCellValue("#prodLabel# CODE") />
	<cfset cell25.setCellStyle(cs) /> 	    

	<cfset cell26 = row1.createCell(27) />
	<cfset cell26.setCellValue("#prodLabel# DESC") />
	<cfset cell26.setCellStyle(cs) /> 	    

	 	 
	<cfloop query="OverLapDetails">
		<cfset row2 = newSheet.createRow(currentRow) />
		<cfset row2.createCell(0).setCellValue(SUS_BB) />
		<cfset row2.createCell(1).setCellValue(SUS_BB_REFERENCE) />
		<cfset row2.createCell(2).setCellValue(DateFormat(SUS_BB_Start_Date,"mm/dd/yyyy")) />
		<cfset row2.createCell(3).setCellValue(DateFormat(SUS_BB_End_Date,"mm/dd/yyyy")) />
		<cfset row2.createCell(4).setCellValue(ORG_BB) />
		<cfset row2.createCell(5).setCellValue(ORG_BB_REFERENCE) />
		<cfset row2.createCell(6).setCellValue(DateFormat(ORG_BB_Start_Date,"mm/dd/yyyy")) />			   
		<cfset row2.createCell(7).setCellValue(DateFormat(ORG_BB_End_Date,"mm/dd/yyyy")) />
		<cfset row2.createCell(8).setCellValue(javacast('string',Overlap_Percent)) /> 
		<cfset row2.createCell(9).setCellValue(SUS_Total_Volume) />
		<cfset row2.createCell(10).setCellValue(SUS_Contract_ID) />
		<cfset row2.createCell(11).setCellValue(SUS_Contract_Name) />
		<cfset row2.createCell(12).setCellValue(ORG_Contract_ID) />
		<cfset row2.createCell(13).setCellValue(ORG_Contract_Name) />
		<cfset row2.createCell(14).setCellValue(Operator_Legacy_ID) />
		<cfset row2.createCell(15).setCellValue(Operator_Name) />
		<cfset row2.createCell(16).setCellValue(Operator_Address) />			   
		<cfset row2.createCell(17).setCellValue(Operator_City) />	
		<cfset row2.createCell(18).setCellValue(Operator_State) />
		<cfset row2.createCell(19).setCellValue(Operator_ZIP) />
		<cfset row2.createCell(20).setCellValue(Distributor_ID) />
		<cfset row2.createCell(21).setCellValue(Distributor_Name) />
		<cfset row2.createCell(22).setCellValue(Distributor_Address) />
		<cfset row2.createCell(23).setCellValue(Distributor_City) />
		<cfset row2.createCell(24).setCellValue(Distributor_State) />
		<cfset row2.createCell(25).setCellValue(Distributor_ZIP) /> 
		<cfset row2.createCell(26).setCellValue(Item) />  		
		<cfset row2.createCell(27).setCellValue(Product_Description) />  
	</cfloop>
 
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true"  />
	 
	  
	 
	

