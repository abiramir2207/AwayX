<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset AccrualBudgetDuplicates = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager")/>
<cfset AccrualBudgetDuplicates = AccrualBudgetDuplicates.Accrual_Budget_Duplicates_Excel(#url.category#)>

			<cfif url.category eq 1>
				 <cfset ExcelName = "Accrual_Budgets_Duplicates_Products.xls">
			<cfelseif url.category eq 2>
				<cfset ExcelName  = "Accrual_Budgets_Duplicates_Distributors.xls">
			</cfif>


	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "Volume Forecast Duplicates") />
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
      <cfset cell1.setCellValue("Budget") />
      <cfset cell1.setCellStyle(cswrap) />
   
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Class") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Planning Group 1") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Planning Group 2") />
      <cfset cell4.setCellStyle(cs) />
<cfif url.category EQ 1>
      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Product") />
      <cfset cell5.setCellStyle(cs) />
     
      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Description") />
      <cfset cell6.setCellStyle(cs) />
<cfelseif url.category EQ 2>
      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Account") />
      <cfset cell5.setCellStyle(cs) />
     
      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Distributor") />
      <cfset cell6.setCellStyle(cs) />	
</cfif>		      
 
 	<cfif url.BusinessSegEnabled>
      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("#appSettings.getbusiness_segment_label()#") />
      <cfset cell7.setCellStyle(cs) />			
	</cfif>    
 
     <cfoutput>

	<cfloop query="AccrualBudgetDuplicates">  	  
			
			   <cfset row2 = newSheet.createRow(#currentRow#) />
		
			   <cfset row2.createCell(0).setCellValue(#Budget_Desc#) />
			   <cfset row2.createCell(1).setCellValue(#Budget_Class_Desc#) />
			   <cfset row2.createCell(2).setCellValue(#pg1#) />
			   <cfset row2.createCell(3).setCellValue(#pg2#) />
<cfif url.category EQ 1>
			   <cfset row2.createCell(4).setCellValue(#Item#) />
			   <cfset row2.createCell(5).setCellValue(#Description#) />
<cfelseif url.category EQ 2>
			   <cfset row2.createCell(4).setCellValue(#Shr_Ship_To#) />
			   <cfset row2.createCell(5).setCellValue(#name#) />
</cfif>			   
 <cfif url.BusinessSegEnabled>
				<cfset row2.createCell(6).setCellValue(#Business_Unit_Desc#) />
</cfif>		
  </cfloop>
 	 
    </cfoutput>
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true"  />
	 
	  
	 
	

