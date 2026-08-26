<!---
	Copyright (c)2013 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\ReportWriter\ContractApproval\Periodical_Reports_Excel.cfm
	Created:		10/9/2013
	Developer:		drachala
	Description:	
	Usage:			used to downlad Program Approval Report
	Tip:			dont delete any of "I" variables.
--->
<cfparam name="url.start_date" default="">
<cfparam name="url.end_date" default="">
<cfparam name="url.UserProfileFilter" default="-1">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfinclude TEMPLATE="/includes/header.cfm">

<cfset MyUserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0) />
<!--- Get the Contract Approval Summary Report --->
		<cfquery name="selPeriodSummary" datasource="#application.datasource#">
				SELECT u.User_ID, 
							 u.Name_First +' '+u.Name_Last AS Name, 
							 Count(cm.Contract_Main_ID) As ApprovedDeals,
							 AVG(CAST(DATEDIFF( "dd", cm.Broker_Approved_Date, cm.Approval_Date) AS Numeric(10,1))) As AverageApproval
				FROM Contract_Main cm
				INNER JOIN _Users u
				ON cm.Approved_by_user_ID = u.user_ID
				AND cm.Approved_by_user_ID IN 
																			(SELECT  _Users.User_ID
																			FROM _Users
																			INNER JOIN User_Position_Holders
																			ON User_Position_Holders.Deleted = 0
																			AND User_Position_Holders.User_ID = _Users.User_ID
																			WHERE _Users.Deleted = 0      
																			AND    User_Position_Holders.User_Positions_ID IN 
																																									(
																																									SELECT          DISTINCT Below_User_Positions_ID
																																									FROM Positions_Below_Me
																																									WHERE           User_Positions_ID IN (#MyUserPositionLIst#)
																																									)
																			)
				WHERE cm.Contract_Status_Type_IDX >=3
				AND cm.Approval_Date 
						BETWEEN '#url.start_date#' 
						AND DateAdd("dd",1,'#url.End_date#')
				<cfif isdefined("url.UserProfileFilter") AND url.UserProfileFilter NEQ "-1">
				AND u.Profiles_ID = #url.UserProfileFilter#
				</cfif>
				GROUP BY  u.User_ID, u.Name_Last, u.Name_First
				ORDER BY ApprovedDeals ASC, AverageApproval ASC	
		</cfquery>

<cfset TotalApprovedDeals = 0>
<cfset TotalAverageApproval = 0>
	<cfloop query="selPeriodSummary">
		<cfset TotalApprovedDeals = TotalApprovedDeals + ApprovedDeals>
		<cfset TotalAverageApproval = TotalAverageApproval + AverageApproval>
	</cfloop>
<cfif selPeriodSummary.Recordcount neq 0>
		<cfset TotalAverageApproval = TotalAverageApproval / selPeriodSummary.Recordcount>
</cfif>

	  <!--- Create new Excel File using the java.io.FileOutputStream class
	         Then create an instance of the HSSFWorkbook Class based on
	         Apache's POI library which is available at http://poi.apache.org/
	   --->
      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("Periodical_Reports_Excel.xls") />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "Periodical_Reports_Excel") />
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

      <!--- Name --->
      <cfset cell1 = row1.createCell(0) />
	  <cfset cell1.setCellValue("Name") />
      <cfset cell1.setCellStyle(cswrap) />
      <!--- Address --->
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("## of Approved") />
      <cfset cell2.setCellStyle(cs) />
      <!--- User Name --->
      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("% of Programs Approved") />
      <cfset cell3.setCellStyle(cs) />
      <!--- Email --->
      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Average Days to Approve") />
      <cfset cell4.setCellStyle(cs) />

     <cfoutput>
   <cfset i = 0>
      <cfloop query="selPeriodSummary">
	  	  		<!--- Get the Contract Approval Detailed Report, based on the user --->
      	<cfquery name="selPeriodDetailed" datasource="#application.datasource#">
      		SELECT u.Name_Last
			      		,u.Name_First
			      		,cm.Contract_Number
			      		,Count(cm.Contract_Main_ID) As ApprovedDeals
			      		,AVG(DATEDIFF( "dd", cm.Broker_Approved_Date, cm.Approval_Date)) As AverageApproval
      		FROM Contract_Main cm
      		INNER JOIN _Users u
      		ON cm.Approved_by_user_ID = u.user_ID
      		WHERE cm.Contract_Status_Type_IDX >=3
      		AND cm.Approval_Date
      		BETWEEN '#url.start_date#' AND DateAdd("dd",1,'#url.End_date#')
      		AND cm.Approved_By_User_ID ='#selPeriodSummary.User_ID#'
      		<cfif isdefined("url.UserProfileFilter") AND url.UserProfileFilter NEQ "-1">
      			AND u.Profiles_ID = #url.UserProfileFilter#
      		</cfif>
      		GROUP BY u.Name_Last,u.Name_First,cm.Contract_Number
      		ORDER BY ApprovedDeals ASC, AverageApproval ASC
      	</cfquery>
	  	 
	  	   <cfset i = i + 1>
	  	   <cfset programPercentage = NumberFormat((ApprovedDeals/TotalApprovedDeals)* 100, "99999.99")& " " &"%">
		   <cfset row2 = newSheet.createRow(#i#) />
		   <cfset row2.createCell(0).setCellValue(#trim(Name)#) />
		   <cfset row2.createCell(1).setCellValue(#NumberFormat(ApprovedDeals)#) />
		   <cfset row2.createCell(2).setCellValue(#programPercentage#) />
		   <cfset row2.createCell(3).setCellValue(#NumberFormat(AverageApproval,"99999.9")#) />
		   
		<cfloop query="selPeriodDetailed">
			<cfset i = i + 1>
		   <cfset row2 = newSheet.createRow(#i#) />
		   <cfset row2.createCell(0).setCellValue(#Contract_Number#) />
		   <cfset row2.createCell(1).setCellValue(#selPeriodDetailed.ApprovedDeals#) />
		   <cfset row2.createCell(2).setCellValue("---") />
		   <cfset row2.createCell(3).setCellValue(#selPeriodDetailed.AverageApproval#) />
		 </cfloop>
	
		   <cfset i = i + 1>
		   <cfset row2 = newSheet.createRow(#i#) />
		   <cfset row2.createCell(0).setCellValue("") />
		   <cfset row2.createCell(1).setCellValue("") />
		   <cfset row2.createCell(2).setCellValue("") />
		   <cfset row2.createCell(3).setCellValue("") />
		 
	 </cfloop>
      <!--- Total --->
	 <cfset newrow = i + 1>
     	<cfset row2 = newSheet.createRow(#newrow#) />
      	<cfset row2.createCell(0).setCellValue("Total") />
	  	<cfset row2.createCell(1).setCellValue(#TotalApprovedDeals#) />
	  	<cfset row2.createCell(2).setCellValue(" ") />
	  	<cfset row2.createCell(3).setCellValue(#NumberFormat(TotalAverageApproval,"99999.9")#) />
	  
    </cfoutput>
 

    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=Periodical_Reports_Excel.xls"  />
	 <cfcontent type="application/vnd.ms-excel" file="Periodical_Reports_Excel.xls" deletefile="true"  />
	 


