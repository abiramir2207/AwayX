<cfquery name="getEmails" datasource="#application.datasource#">
    SELECT Message_Log.Created_Date
        ,  Message_Log.Message_From
        ,  convert(varchar(8000),Message_To)as Message_To
        ,  Message_Log.Message_Subject
        ,  Message
        ,  Sent_Date
     	FROM Message_Log
    	where Message_Log.deleted = 0
    	and	Message_Log.Created_Date >  '#trim(url.fdate)#'
     	ORDER BY  Created_Date  asc
</cfquery>
	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
    <cfoutput>
    <cfset variables.fileName = "email_log_#getTickCount()#.xls">
    <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init( variables.fileName ) />
    </cfoutput>
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "Email_Log") />
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
      <!--- Name --->
	    <cfset cell1.setCellValue("From") />
      <cfset cell1.setCellStyle(cswrap) />
      <!--- Address --->
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("To") />
      <cfset cell2.setCellStyle(cs) />
      <!--- User Name --->
      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Subject") />
      <cfset cell3.setCellStyle(cs) />
      <!--- Email --->
      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Created Date") />
      <cfset cell4.setCellStyle(cs) />
      <!--- Phone/Fax --->
      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Sent Date") />
      <cfset cell5.setCellStyle(cs) />

     <cfoutput>

      <cfloop query="getEmails">
	   <cfset row2 = newSheet.createRow(#currentRow#) />
	   <cfset row2.createCell(0).setCellValue(#trim(Message_From)#) />
	   <cfset row2.createCell(1).setCellValue(#trim(Message_To)#) />
	   <cfset row2.createCell(2).setCellValue(#trim(Message_Subject)#) />
	   <cfset row2.createCell(3).setCellValue(#trim(Created_Date)#) />
	   <cfset row2.createCell(4).setCellValue(#trim(Sent_date)#) />
	 </cfloop>
    </cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() />
	<cfset variables.fileOutStream.close() />

<cfoutput>
   <cfheader name="Content-Disposition" value="attachment;filename=#variables.fileName#"  />
   <cfcontent type="application/vnd.ms-excel" file="#variables.fileName#" deletefile="true"  />
</cfoutput>






