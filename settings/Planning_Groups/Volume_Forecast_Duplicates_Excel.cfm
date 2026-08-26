<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset VolumeForecastDuplicates = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager")/>
<cfset VolumeForecastDuplicates = VolumeForecastDuplicates.Volume_Forecast_Duplicates_Excel(#url.category#)>

			<cfif url.category eq 1>
				 <cfset ExcelName = "Volume_Forecast_Duplicates_Products.xls">
			<cfelseif url.category eq 2>
				<cfset ExcelName  = "Volume_Forecast_Duplicates_Distributors.xls">
			<cfelseif url.category eq 0>
				<cfset ExcelName  = "Volume_Forecast_Duplicate_Items_Across_Plan.xls">
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

<cfif url.category eq 1 OR url.category eq 2>
  	  <!--- Create a row and the Header cell --->
      <cfset row1 = newSheet.createRow(0) />
  
      <cfset cell1 = row1.createCell(0) />
      <cfset cell1.setCellValue("Plan") />
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

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Product") />
      <cfset cell5.setCellStyle(cs) />
     
      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Description") />
      <cfset cell6.setCellStyle(cs) />
	  
		 	<cfif url.BusinessSegEnabled>
			      <cfset cell7 = row1.createCell(6) />
			      <cfset cell7.setCellValue("#appSettings.getbusiness_segment_label()#") />
			      <cfset cell7.setCellStyle(cs) />			
			</cfif> 
			   	      
 <cfelseif url.category eq 0>
 
   	  <!--- Create a row and the Header cell --->
      <cfset row1 = newSheet.createRow(0) />
  
      <cfset cell1 = row1.createCell(0) />
      <cfset cell1.setCellValue("Account") />
      <cfset cell1.setCellStyle(cswrap) />
   
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Distributor") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Product") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Description") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Planning Group 1") />
      <cfset cell5.setCellStyle(cs) />
     
      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Product PG 1") />
      <cfset cell6.setCellStyle(cs) />
 
      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("Distributor PG 1") />
      <cfset cell7.setCellStyle(cs) />

      <cfset cell8 = row1.createCell(7) />
      <cfset cell8.setCellValue("Planning Group 2") />
      <cfset cell8.setCellStyle(cs) />
 
      <cfset cell9 = row1.createCell(8) />
      <cfset cell9.setCellValue("Product PG 2") />
      <cfset cell9.setCellStyle(cs) />

      <cfset cell10 = row1.createCell(9) />
      <cfset cell10.setCellValue("Distributor PG 2") />
      <cfset cell10.setCellStyle(cs) />
	  
		 	<cfif url.BusinessSegEnabled>
			      <cfset cell11 = row1.createCell(10) />
			      <cfset cell11.setCellValue("#appSettings.getbusiness_segment_label()#") />
			      <cfset cell11.setCellStyle(cs) />			
			</cfif> 	 
			 	  
</cfif>               
     <cfoutput>
	 	 
      
<cfif url.category eq 1 OR url.category eq 2>	
	<cfloop query="VolumeForecastDuplicates">  	  
			
			   <cfset row2 = newSheet.createRow(#currentRow#) />
		
			   <cfset row2.createCell(0).setCellValue(#VF_Plan_Desc#) />
			   <cfset row2.createCell(1).setCellValue(#VF_Class_Desc#) />
			   <cfset row2.createCell(2).setCellValue(#pg1#) />
			   <cfset row2.createCell(3).setCellValue(#pg2#) />
			   <cfset row2.createCell(4).setCellValue(#Item#) />
			   <cfset row2.createCell(5).setCellValue(#Description#) />
					<cfif url.BusinessSegEnabled>
									<cfset row2.createCell(6).setCellValue(#Business_Unit_Desc#) />
					</cfif>	
			   
  </cfloop>
 <cfelseif url.category eq 0>
 	<cfloop query="VolumeForecastDuplicates">  	  
			
			   <cfset row2 = newSheet.createRow(#currentRow#) />
		
			   <cfset row2.createCell(0).setCellValue(#Shr_Ship_To#) />
			   <cfset row2.createCell(1).setCellValue(#Name#) />
			   <cfset row2.createCell(2).setCellValue(#Item#) />
			   <cfset row2.createCell(3).setCellValue(#Description#) />
			   <cfset row2.createCell(4).setCellValue(#Plan1#) />
			   <cfset row2.createCell(5).setCellValue(#Product_PG1#) />
			   <cfset row2.createCell(6).setCellValue(#Distributor_PG1#) />
			   <cfset row2.createCell(7).setCellValue(#Plan2#) />
			   <cfset row2.createCell(8).setCellValue(#Product_PG2#) />
			   <cfset row2.createCell(9).setCellValue(#Distributor_PG2#) />
				 <cfif url.BusinessSegEnabled>
								<cfset row2.createCell(11).setCellValue(#Business_Unit_Desc#) />
				</cfif>				   			   
  </cfloop>	 
</cfif>	 	
	 
    </cfoutput>
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true"  />
	 
	  
	 
	

