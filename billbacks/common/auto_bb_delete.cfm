<!--- This file is used to delete Auto Billbacks. The Auto billback report delete functionality is called from somewhere else. --->
<cfset oBBReportUpdate	= CreateObject("component","components.Billback.BBAutoReportUpdate").init() />

<cfquery name="getReportID" datasource="#application.datasource#">
SELECT P.BB_Auto_Report_ID,P.BB_Auto_Program_Pay_Period_Id AS PayPeriodId
FROM BB_Auto_Program_Pay_Period P 
INNER JOIN
BB_Auto_Pay_Period_Billback PBB
ON PBB.BB_Auto_Program_Pay_Period_Id = P.BB_Auto_Program_Pay_Period_Id
WHERE PBB.BillBack_ID = '#FORM.Billback_ID#'
AND P.Deleted = 0
</cfquery>

<cfset deleteSuccess = oBBReportUpdate.removeBB(getReportID.BB_Auto_Report_ID,request.AccessStructure.User_ID,getReportID.PayPeriodId,1,FORM.Billback_ID)>