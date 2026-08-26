<!---
	Copyright (c)2013 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\billbacks\Auto_BB_Report\Apply_Unapply_Pullbacks_Action.cfm
	Created:		9/20/2013
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->
<cfset filename = "Pullbacks_"&#replace(request.AccessStructure.user_id,'-','_','ALL')#&".txt">
<cfset filepath = "#Application.Doc_Path#\Temp_Files\Billback\AutoPayPullbacks\#filename#">
<cfif FileExists("#filepath#")>
<cffile action="read" file="#filepath#"	variable="selectedlist">
</cfif>

<cfset TableName = "##tmp_Pullbacks_"&#replace(request.AccessStructure.user_id,'-','_','ALL')#>

	<cfquery name="qInsertPullbacks" datasource="#application.datasource#">	
	
			IF OBJECT_ID('tempdb..#TableName#') IS NOT NULL
			DROP TABLE #TableName#
			CREATE TABLE #TableName# (pullback_billback_id uniqueidentifier, customer_id uniqueidentifier, contract_number nvarchar(25))
			
				<cfloop list="#trim(selectedlist)#" index="pullbacksinfo" delimiters=";">	
						<cfset pullbacksinfolist="#replace(pullbacksinfo,'|',',','All')#">
						<cfset pullback_billback_id = "#replace(listgetat(pullbacksinfolist,1), '_','-','ALL')#">
						<cfset customer_id = "#replace(listgetat(pullbacksinfolist,2), '_','-','ALL')#">
								INSERT INTO #TableName# (pullback_billback_id, customer_id, contract_number)
								VALUES 		 ('#trim(pullback_billback_id)#', '#trim(customer_id)#', '#trim(listgetat(pullbacksinfolist,3))#' )
				</cfloop>
	
	</cfquery>

<CFIF UNAPPLYPULLBACKS EQ 1>
	
	<cftransaction>
			<cfquery name="qPullbacklog" datasource="#application.datasource#">
					UPDATE pullbacks_log
							SET   pullback_applied = 0,
									pullback_applied_to_billback_id = NULL,
									pullback_unapplied_by = '#request.AccessStructure.user_id#',
									pullback_unapplied_date = getdate(),
									pullback_expected_dollars = 0,
									pullback_from_program_rate = 0
					FROM pullbacks_log
					INNER JOIN #TableName#  temptable
					ON 			Pullbacks_Log.Pullback_Billback_id = temptable.pullback_billback_id
					AND 		Pullbacks_Log.Pullback_Program_Number = temptable.contract_number
					AND 		Pullbacks_Log.customer_Id = temptable.customer_id
					WHERE 	Pullback_Applied_to_Billback_Id = '#BB_ID#' 
					AND 		Pullbacks_Log.Deleted = 0
		
			</cfquery>
			<cfquery name="qBBApproved" datasource="#application.datasource#">
					DECLARE @Pullback_Expected_Dollars  DECIMAL(20, 2)
					
					SELECT    @Pullback_Expected_Dollars = isNull(SUM(Pullback_Expected_Dollars),0) 
					FROM  	Pullbacks_Log
					WHERE 	Pullback_Applied_to_Billback_Id = '#BB_ID#'
					
					UPDATE  BB_Approved
					SET        	Pullback_Applied_Amount = ISNULL(@Pullback_Expected_Dollars, 0),
					            	Paid_Amount = CASE WHEN Approved_Amount_Before_Pullbacks IS NULL THEN Paid_Amount ELSE Approved_Amount_Before_Pullbacks END - ISNULL(@Pullback_Expected_Dollars, 0),
					            	BB_Pullbacks_Applied = CASE WHEN @Pullback_Expected_Dollars = 0 THEN 0 ELSE 1 END
					WHERE 	BB_Approved.Billback_ID = '#BB_ID#'
			</cfquery>
	</cftransaction>
		
<CFELSEIF UNAPPLYPULLBACKS EQ 0>

	<cfstoredproc procedure="BB_Manual_Apply_Pullbacks" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" 	value = "#BB_ID#"			  null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@TempTable" 	value = "#TableName#"   null="no">
	</cfstoredproc>
	
</CFIF>

<CFQUERY NAME="GetBBReportID" DATASOURCE="#Application.Datasource#">	
    SELECT	pp.BB_Auto_Report_ID 
    FROM	BB_Auto_Pay_Period_Billback pb
    inner join BB_Auto_Program_Pay_Period pp
    ON		pp.BB_Auto_Program_Pay_Period_ID = pb.BB_Auto_Program_Pay_Period_Id
    AND		pp.Deleted = 0
    WHERE	pb.Billback_ID = <cfqueryparam value="#BB_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<cfstoredproc procedure="BB_Auto_Report_Extract_PullBack_Reload" datasource="#application.datasource#">
	<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER " dbVarName = "@BB_Auto_Report_ID" value = "#GetBBReportID.BB_Auto_Report_ID#" null="no">
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR " dbVarName = "@Billback_ID" value = "#BB_ID#" null="no">
</cfstoredproc>