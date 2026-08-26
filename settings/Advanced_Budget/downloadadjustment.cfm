<!-----------------------------------------------------------------------------

FILE NAME:		downloadadjustment.cfm
DESCRIPTION:	Download the accrual budget rows on the page.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	22-Apr-2015	
------------------------------------------------------------------------------>

<cfset BudgetID = URL.budget_id />
<CFSET PAGETITLE = "EDI Download">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


	<cfquery name="local.qBudget" datasource="#application.datasource#">
		SELECT  a.Adjustment_Dollar
		          ,a.Created_Date
		          ,a.Adjustment_Notes
		          ,Customer_Position = CASE
		                                 WHEN (a.BSA_Foodservice_Customers_ID IS NOT NULL) THEN c.Name
		                                 WHEN (a.User_Positions_ID > 0) THEN d.Position_Label
		                                 ELSE ''
		                               END
		          ,Adjustment_Type = b.description
		          ,Created_By = e.name_first + ' ' + e.name_last
		          ,c.Ship_To
		          ,a.Start_Date
		          ,a.End_Date
		     FROM Budget_Adjustment a
		          INNER JOIN Budget_Adjustment_Type b ON a.Budget_Adjustment_Type_Id = b.Budget_Adjustment_Type_Id
		          LEFT JOIN BSA_Foodservice_Customers c ON c.BSA_Foodservice_Customers_ID = a.BSA_Foodservice_Customers_ID
		          LEFT JOIN User_Positions d ON d.User_Positions_Id = a.User_Positions_ID
		          LEFT JOIN _Users e ON e.User_ID = a.Created_By
		    WHERE a.Budget_Id = #BudgetID#
		          AND a.Deleted = 0
	</cfquery>  

<cfset sFilePath= "#Application.Doc_Path#\Data_Files\created\budgets" />
<cfset DownloadFileName = "Accrual_Adj_" & DateFormat(now(), "mm_dd_yyyy") &"_BudgetID_" & BudgetID & ".csv" />	
<cfset pathFileName = "#sFilePath#\" & DownloadFileName  />

	<!--- Create a STRING BUFFER to hold the output --->
	<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >
	
	<!--- 
	/* HEADER ROW WAS NOT REQUIRED */
	<cfset fileOutput.append("Adjustment_Amount" & ",")>
	<cfset fileOutput.append("Adjustment_Type_ID" & ",")>
	<cfset fileOutput.append("Adjustment_Date" & ",")>
	<cfset fileOutput.append("Adjustment_Notes" & ",")>
	<cfset fileOutput.append("Distributor" & ",")>
	<cfset fileOutput.append("Position" & ",")>
	<cfset fileOutput.append(Chr(13) & Chr(10))> 
	--->

	<cfloop query="local.qBudget">
		<cfset fileOutput.append("$#Adjustment_Dollar#" & ",")>
		<cfset fileOutput.append(Adjustment_Type & ",")>
		<cfset fileOutput.append(DateFormat(Created_Date,"mm/dd/yyyy") & ",")>
		<cfset fileOutput.append(Adjustment_Notes & ",")> 
		<cfset fileOutput.append(Ship_To & ",")> 
		<cfset fileOutput.append(Customer_Position & ",")> 
		<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>
	
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<cfheader name="Content-Disposition" value="attachment;filename=#DownloadFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#" deletefile="no"  />

<script language="javascript">
window.close();
</script>

	
	