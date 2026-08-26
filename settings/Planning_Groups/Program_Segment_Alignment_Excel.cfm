<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset ProgramSegmentAligment = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager")/>
<cfset ProgramSegmentAligment = ProgramSegmentAligment.Program_Segment_Aligment_Excel(#url.category#)>

			<cfif url.category eq 1>
				 <cfset ExcelName = "Program_Segment_Aligment_Products.xls">
			<cfelseif url.category eq 2>
				<cfset ExcelName  = "Program_Segment_Aligment_Distributors.xls">
			</cfif>


	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "Program Segment Aligment") />
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
      <cfset cell1.setCellValue("Program Number") />
      <cfset cell1.setCellStyle(cswrap) />
   
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Title") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Created Type") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Product") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Description") />
      <cfset cell5.setCellStyle(cs) />
     
      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Category Name") />
      <cfset cell6.setCellStyle(cs) />	
	  
	<cfif url.BusinessSegEnabled>
      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("#appSettings.getbusiness_segment_label()#") />
      <cfset cell7.setCellStyle(cs) />			
	</cfif>    
 
     <cfoutput>

	<cfloop query="ProgramSegmentAligment">  	  
	
<cfif url.category EQ 1>    
      <cfset catname = #PG_Product_Category_Name# >
<cfelseif url.category EQ 2>
	  <cfset catname = #PG_Customer_Category_Name# >
</cfif> 

<cfif url.category EQ 1>    
      <cfset prod = #Item#>
      <cfset prod_name = #Description#>
<cfelseif url.category EQ 2>
	  <cfset prod = #Shr_Ship_To#>
      <cfset prod_name = #Name#>
</cfif>
			
			   <cfset row2 = newSheet.createRow(#currentRow#) />
		
			   <cfset row2.createCell(0).setCellValue(#Contract_Number#) />
			   <cfset row2.createCell(1).setCellValue(#Contract_Title#) />
			   <cfset row2.createCell(2).setCellValue(#Created_Type#) />
			   <cfset row2.createCell(3).setCellValue(#prod#) />
			   <cfset row2.createCell(4).setCellValue(#prod_name#) />
			   <cfset row2.createCell(5).setCellValue(#catname#) />
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
	 
	  
	 
	

