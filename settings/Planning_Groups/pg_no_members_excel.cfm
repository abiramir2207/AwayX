
<cfset noMembers = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager")/>
<cfset noMembers = noMembers.PG_No_Members_Excel(#url.category#, #url.active#)>

			<cfif url.category eq 1>
				 <cfset ExcelName = "PG_No_Members_Products.xls">
			<cfelseif url.category eq 2>
				<cfset ExcelName  = "PG_No_Members_Distributors.xls">
			<cfelseif url.category eq 3>
				<cfset ExcelName  = "PG_No_Members_Operators.xls">
			</cfif>


	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "EMPTY MEMBERSHIP") />
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
  
	    <cfset cell1.setCellValue("TypeID") />
      <cfset cell1.setCellStyle(cswrap) />
   
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Type Name") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Type Category") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Category Name") />
      <cfset cell4.setCellStyle(cs) />


     
      
                 
     <cfoutput>
	 	 
      <cfloop query="noMembers">
	  	  
			  <cfif PG_Group_Type EQ "1">
		        	<cfset PGTypeCategory = application.returned_customer_setting.Item_Label />
		      <cfelseif PG_Group_Type EQ "2">
		        	<cfset PGTypeCategory = application.returned_customer_setting.distributor_label_singular />
		      <cfelseif PG_Group_Type EQ "3">
		        	<cfset PGTypeCategory = application.returned_customer_setting.Operator_Label_Singular  />
		      </cfif>

			<cfif url.category eq 1>
				 <cfset name = #PG_Product_Category_Name#>
			<cfelseif url.category eq 2>
				<cfset name  = #PG_Customer_Category_Name#>
			<cfelseif url.category eq 3>
				<cfset name  = #PG_Operator_Category_Name#>
			</cfif>
		      
			   <cfset row2 = newSheet.createRow(#currentRow#) />
		
			   <cfset row2.createCell(0).setCellValue(#pg_type_code#) />
			   <cfset row2.createCell(1).setCellValue(#pg_type_name#) />
			   <cfset row2.createCell(2).setCellValue(#pgtypecategory#) />
			   <cfset row2.createCell(3).setCellValue(#name#) />
	
	 </cfloop>
    </cfoutput>
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true"  />
	 
	  
	 
	

