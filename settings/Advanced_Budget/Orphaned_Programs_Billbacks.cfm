<!----
	Name: Orphaned_Programs_Billbacks.cfm      
	Copyright (c) 2014 Blacksmith Applications, Inc.       
 	Description:This file is used to generate reports with Orphaned Programs and Billbacks information.
	Usage:Settings>>Programs>>Budgets>>Research(tab)
	Label: D42242 :: Create links w/in the application for client to run report to see Orphaned BB's and Programs
---->	

<cfif NOT isDefined("qGetCreateBudget.Create_Budget")>
	<cfset  qGetCreateBudget =  CreateObject("component", "components.user.profile").getCreateViewBudgetSetting(request.Accessstructure.Profiles_ID)>
	<cfset URL.PageTitle="Budget Reports">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfinclude template="/settings/settings_title.cfm">
</cfif>

<cfparam name="url.report_type" default="0" >
<cfinclude template="actionFormat.cfm">
	<script type="text/javascript" src="/script/tTip.js"></script>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />

<cfoutput>
	<table style="margin-top:5px;maring-left:5px;">
		<tr>
			<td>
				<a href="index.cfm?command=research&report_type=1">#ActionText("Generate Orphan Program Report")#</a> &nbsp;
				<span onmouseout="popUpTip(event,'OPText');" onmouseover="popUpTip(event,'OPText');"><img src="/images/help_small.gif"  height="12" width="12"/></span>
				 <div id="OPText" class="tip">
				 	Report will show Orphan Programs.  An orphan program is a program whose entire span is not covered by a budget.
				 </div>
			</td>
		</tr>
		<tr>
			<td>
				<a href="index.cfm?command=research&report_type=2">#ActionText("Generate Orphan Billback Report")#</a> &nbsp;
				<span onmouseout="popUpTip(event,'OBText');" onmouseover="popUpTip(event,'OBText');"><img src="/images/help_small.gif"  height="12" width="12"/></span>
				 <div id="OBText" class="tip">
				 	<ul style="margin:10px 0 10px 19px;">
						Report will show Orphan Billbacks.   An orphan billback is a billback that does not have a budget for its entire span due to one of the following reasons:   
						<li>Billback dates do not match program dates.</li>
						<li>The program associated to the billback does not have a budget.</li>
						<li>The program associated to the billback does not have a budget for its entire span.</li>
					</ul>
				</div>				
			</td>
		</tr>
	</table>
</cfoutput>

<cfif url.report_type>

    <cfset reports = CreateObject("component", "components.reports.orphansreport")/>

	<cfif url.Report_type EQ 1>
			<cfset OrphanProgramsBillbacks = reports.getOrphanPrograms()>
			<cfset Sheetname = "Orphan Programs">
			<cfset filename = "Orphan Programs.xls">
	<cfelseif url.Report_type EQ 2>
			<cfset OrphanProgramsBillbacks = reports.getOrphanBillbacks()>
			<cfset Sheetname = "Orphan Billbacks">
			<cfset filename = "Orphan Billbacks.xls">
	</cfif>



      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(filename) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>

	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "#Sheetname#") />

	  <cfset f = workBook.createFont() />
      <cfset cs = workBook.createCellStyle() />
      <cfset cswrap = workBook.createCellStyle() />
      <cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
      <cfset cs.setFont(f) />
      <cfset cswrap.setFont(f) />
      <cfset cswrap.setWrapText(true) />

<cfif url.report_type EQ 1>

	<cfset cell1Text = "Contract Number">
	<cfset cell2Text = "Contract Title">
	<cfset cell3Text = "Created Type">
	<cfset cell4Text = "Program Start Date">
	<cfset cell5Text = "Program End Date">
	<cfset cell6Text = "Program Dates">
	<cfset cell7Text = "Budget Class">
		
<cfelseif url.report_type EQ 2>

	<cfset cell1Text = "Billback">
	<cfset cell2Text = "Billback  Title">
	<cfset cell3Text = "Billback Start Date">
	<cfset cell4Text = "Billback End Date">
	<cfset cell5Text = "Created Type">
	<cfset cell6Text = "Message">
	<cfset cell7Text = "Contract Number">
	<cfset cell8Text = "Contract Start Date">
	<cfset cell9Text = "Contract End Date">
	<cfset cell10Text = "Billback Program Amount">
	<cfset cell11Text = "Billback Program Actual">
	<cfset cell12Text = "Billback Difference">
	<cfset cell13Text = "Billback Dates">
	<cfset cell14Text = "Program Dates">
	<cfset cell15Text = "Billback Budget Class">
	<cfset cell16Text = "Program Budget Class">
	<cfset cell17Text = "Program Budget Start Date">
	<cfset cell18Text = "Program Budget End Date">
				
</cfif>

      <cfset row1 = newSheet.createRow(0) />
      <cfset cell1 = row1.createCell(0) />
      <cfset cell1.setCellValue(#cell1Text#) />
      <cfset cell1.setCellStyle(cswrap) />

      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue(#cell2Text#) />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue(#cell3Text#) />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue(#cell4Text#) />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue(#cell5Text#) />
      <cfset cell5.setCellStyle(cs) />

      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue(#cell6Text#) />
      <cfset cell6.setCellStyle(cs) />
  
      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue(#cell7Text#) />
      <cfset cell7.setCellStyle(cs) />

<cfif url.report_type EQ 2>
	
	  <cfset cell8 = row1.createCell(7) />
      <cfset cell8.setCellValue(#cell8Text#) />
      <cfset cell8.setCellStyle(cs) />

      <cfset cell9 = row1.createCell(8) />
      <cfset cell9.setCellValue(#cell9Text#) />
      <cfset cell9.setCellStyle(cs) />

      <cfset cell10 = row1.createCell(9) />
      <cfset cell10.setCellValue(#cell10Text#) />
      <cfset cell10.setCellStyle(cs) />

      <cfset cell11 = row1.createCell(10) />
      <cfset cell11.setCellValue(#cell11Text#) />
      <cfset cell11.setCellStyle(cs) />

      <cfset cell12 = row1.createCell(11) />
      <cfset cell12.setCellValue(#cell12Text#) />
      <cfset cell12.setCellStyle(cs) />

      <cfset cell13 = row1.createCell(12) />
      <cfset cell13.setCellValue(#cell13Text#) />
      <cfset cell13.setCellStyle(cs) />

      <cfset cell14 = row1.createCell(13) />
      <cfset cell14.setCellValue(#cell14Text#) />
      <cfset cell14.setCellStyle(cs) />
  
      <cfset cell15 = row1.createCell(14) />
      <cfset cell15.setCellValue(#cell15Text#) />
      <cfset cell15.setCellStyle(cs) />
      
      <cfset cell16 = row1.createCell(15) />
      <cfset cell16.setCellValue(#cell16Text#) />
      <cfset cell16.setCellStyle(cs) />

      <cfset cell17 = row1.createCell(16) />
      <cfset cell17.setCellValue(#cell17Text#) />
      <cfset cell17.setCellStyle(cs) />
 
      <cfset cell18 = row1.createCell(17) />
      <cfset cell18.setCellValue(#cell18Text#) />
      <cfset cell18.setCellStyle(cs) />
      
</cfif>
     <cfoutput>
	 	 
      <cfloop query="OrphanProgramsBillbacks">

<cfif url.report_type EQ 1>

	<cfset cell1value = #Contract_Number#>
	<cfset cell2value = #Contract_Title#>
	<cfset cell3value = #Created_Type#>
	<cfset cell4value = #DateFormat(Program_Start, "mm/dd/yyyy")#>
	<cfset cell5value = #DateFormat(Program_End, "mm/dd/yyyy")#>
	<cfset cell6value = #Pgm_Dates#>
	<cfset cell7value = #Budget_Class#>
		
<cfelseif url.report_type EQ 2>

	<cfset cell1value = #BB_Code#>
	<cfset cell2value =#BB_Title#>
	<cfset cell3value = #DateFormat(BB_Start_Date, "mm/dd/yyyy")#>
	<cfset cell4value = #DateFormat(BB_End_Date, "mm/dd/yyyy")#>
	<cfset cell5value = #Create_Type#>
	<cfset cell6value = #Msg#>
	<cfset cell7value = #Contract_Number#>
	<cfset cell8value =#DateFormat(Contract_Start_Date, "mm/dd/yyyy")#>
	<cfset cell9value = #DateFormat(Contract_End_Date, "mm/dd/yyyy")#>
	<cfset cell10value = #DollarFormat(BB_PGM_Amount)#>
	<cfset cell11value = #DollarFormat(BB_PGM_Actual)#>
	<cfset cell12value = #DollarFormat(Diff)#>
	<cfset cell13value = #BB_Dates#>	
	<cfset cell14value = #PGM_Dates#>
	<cfset cell15value =#Billback_Budget_Class#>
	<cfset cell16value = #Program_Budget_Class#>
	<cfset cell17value = #DateFormat(Program_Budget_Start, "mm/dd/yyyy")#>
	<cfset cell18value = #DateFormat(Program_Budget_End, "mm/dd/yyyy")#>
				
</cfif>	
					
	
		   		<cfset row2 = newSheet.createRow(#currentRow#) />

				<cfset row2.createCell(0).setCellValue(#cell1value#) />
				<cfset row2.createCell(1).setCellValue(#cell2value#) />
				<cfset row2.createCell(2).setCellValue(#cell3value#) />
				<cfset row2.createCell(3).setCellValue(#cell4value#) />
				<cfset row2.createCell(4).setCellValue(#cell5value#) />
				<cfset row2.createCell(5).setCellValue(#cell6value#) />
				<cfset row2.createCell(6).setCellValue(#cell7value#) />

<cfif url.report_type EQ 2>
				<cfset row2.createCell(7).setCellValue(#cell8value#) />
				<cfset row2.createCell(8).setCellValue(#cell9value#) />
				<cfset row2.createCell(9).setCellValue(#cell10value#) />
				<cfset row2.createCell(10).setCellValue(#cell11value#) />
				<cfset row2.createCell(11).setCellValue(#cell12value#) />
				<cfset row2.createCell(12).setCellValue(#cell13value#) />
				<cfset row2.createCell(13).setCellValue(#cell14value#) />
				<cfset row2.createCell(14).setCellValue(#cell15value#) />
				<cfset row2.createCell(15).setCellValue(#cell16value#) />   
				<cfset row2.createCell(16).setCellValue(#cell17value#) />
				<cfset row2.createCell(17).setCellValue(#cell18value#) />
</cfif>

	 </cfloop>

    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=#filename#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#filename#" deletefile="true"  />
    </cfoutput>	 
</cfif>

