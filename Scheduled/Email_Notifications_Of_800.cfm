<!--- Ana: Dev Notes: D13343 
Content from the below files has been copied and put together in Email_Notification_Of_800.cfm file. 
/Scheduled/BB_Vendor_ID_Deleted_Notification.cfm" />
/Scheduled/Rejected_BB_Payment_Notification.cfm" />
/Scheduled/BB_Void_Notification.cfm" />
Duplicate email notification:
1) 	These three files are included in scheduled_tasks.cfm which generates email whenever the Scheduled_Task.cfm is scheduled.
2) 	Email_Notification_OF_800.cfm is being http get as last step in the 800 job from the SQL Server 
	which also generate the same email. 
	
Solution: Comment the three files in Scheduled_Task.cfm
--->

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- VOid Notification --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

 <CFQUERY NAME="GetBBVoid" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT Billback.Billback_ID,
				BB_Code, 
				BB_title,
				BB_Date,
				BB_Void_Date,
				Approved_By,
				Approved_Date, 
				Name_First, 
				Name_Last, 
				User_Email 
				
	FROM 		Billback 
	INNER JOIN	Gl_Code_Allocation ON Gl_Code_Allocation.Billback_ID = Billback.Billback_ID AND Allocation_Saved = 1 AND Gl_Code_Allocation.Deleted = 0
	INNER JOIN 	_users ON _users.User_ID = Gl_Code_Allocation.Approved_By
	WHERE 		Billback_Status_ID = 8 AND BB_Void_Multiplier < 0 AND 
				BB_Void_Notification_Sent = 0 AND Billback.Deleted = 0 AND
				User_Email IS NOT NULL AND LEN(User_Email) > 0
</CFQUERY>

<CFOUTPUT>
<CFLOOP QUERY="GetBBVoid">	
	<CF_EMAILWRAPPER TO		=	"#User_Email#"
        FROM		=	"#Contact_Admin_Email_Address#"
        SUBJECT		=	"Billback Payment Void Notification"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1" 
		apparea="3" >
		
		<TABLE WIDTH="100%">		
		<TR VALIGN="top">
		<TD>
		Check passed for the Billback <B>#BB_Code#</B> "#BB_title#, #DATEFORMAT(BB_Date,"mm/dd/yyyy")#" became VOID and this billback has been set to "APPROVED - VOID" status on #DATEFORMAT(BB_Void_Date,"mm/dd/yyyy")#.
		</TD>
		</TR>		
		</TABLE>	
	</CF_EMAILWRAPPER>
	
	<cfset useLakebaseForUpdateSentBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateSentBit>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"bb_void_notification_sent" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateSentBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateSentBit>
<CFQUERY NAME="UpdateSentBit" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET BB_Void_Notification_Sent = 1
		WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>
</cfif>		
</CFLOOP>
</CFOUTPUT> 
<!--- vvvvvvvvvvvvvvvvvvvvvvvvv End Void Notification vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->


<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Check Rejected Notification --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFQUERY NAME="RejectedBB" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT Billback.Billback_ID,
				BB_Code, 
				BB_title,
				BB_Date,
				BB_Rejected_Date,
				Approved_By,
				Approved_Date, 
				Name_First, 
				Name_Last, 
				User_Email 
				
	FROM 		Billback 
	INNER JOIN	Gl_Code_Allocation ON Gl_Code_Allocation.Billback_ID = Billback.Billback_ID AND Allocation_Saved = 1 AND Gl_Code_Allocation.Deleted = 0
	INNER JOIN 	_users ON _users.User_ID = Gl_Code_Allocation.Approved_By
	WHERE 		BB_Rejected_Indicator = 1 AND 
				BB_Rejected_Notification_Sent = 0 AND Billback.Deleted = 0 AND
				User_Email IS NOT NULL AND LEN(User_Email) > 0
</CFQUERY>

<CFOUTPUT>
<CFLOOP QUERY="RejectedBB">	
	<CF_EMAILWRAPPER TO			=	"#User_Email#"
        FROM		=	"#Contact_Admin_Email_Address#"
        SUBJECT		=	"Rejected Billback Payment and Status Reset Notification"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1" 
		apparea="3" >
		
		<TABLE WIDTH="100%">		
		<TR VALIGN="top">
		<TD>
		Billback <B>#BB_Code#</B> "#BB_title#, #DATEFORMAT(BB_Date,"mm/dd/yyyy")#" Payment Request approved by #Name_First# #Name_Last# on #DATEFORMAT(Approved_Date,"mm/dd/yyyy")# got Rejected on #DATEFORMAT(BB_Rejected_Date,"mm/dd/yyyy")# and changed to Approved Status.
		</TD>
		</TR>		
		</TABLE>
	</CF_EMAILWRAPPER>		
		
	<CFQUERY NAME="UpdateSentBit" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET BB_Rejected_Notification_Sent = 1
		WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>
</CFLOOP>
</CFOUTPUT>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvv End Check Rejected Notification vvvvvvvvvvvvvvvvvvvvvvvv  --->



<!--- xxxxxxxxxxxxxxx		Interface 800 Error Notifications sent here 		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- get this run_date and time...if any errors match this run, let someone know --->

<cfset useLakebaseForqGetAlertEmails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
<cfif useLakebaseForqGetAlertEmails>
	<cftry>
		<cfset qGetAlertEmails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration_contacts", {
				"intra_id" = "eq.800",
				"active" = "eq.1",
				"select" = "email,active"
			}), "email,active"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAlertEmails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAlertEmails>
<cfquery name="qGetAlertEmails" datasource="#application.datasource#">
	Select email, Active
	From Data_Integration_Contacts
	Where intra_Id = 800
	and active = 1
</cfquery>
</cfif>
<cfset useLakebaseForqGetLastRun = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_upload")>
<cfif useLakebaseForqGetLastRun>
	<cftry>
		<cfset qGetLastRun = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration_upload", {
				"intra_id" = "eq.800",
				"order" = "data_integration_upload_id.desc",
				"limit" = "1",
				"select" = "run_date,run_time"
			}), "run_date,run_time"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLastRun = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLastRun>
<cfquery name="qGetLastRun" datasource="#application.datasource#">
	select top 1 run_date, run_time from data_integration_upload
	where intra_id = 800
	order by data_Integration_upload_id
	desc
</cfquery>
</cfif>

<cfset lastrd = qGetLastRun.run_date>
<cfset lastrt = qGetLastRun.run_time>

<cfset useLakebaseForqGet800Errors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("log_cf_800")>
<cfif useLakebaseForqGet800Errors>
	<cftry>
		<cfset qGet800Errors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("log_cf_800", {
				"run_date" = "eq.#lastrd#",
				"run_time" = "eq.#lastrt#",
				"order" = "reason_code_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGet800Errors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGet800Errors>
<cfquery name="qGet800Errors" datasource="#application.datasource#">
	Select * from Log_cf_800
 	where run_date = '#lastrd#'
	and run_time = '#lastrt#'
	order by Reason_Code_Id
</cfquery>
</cfif>

<cfset elist = "">
<cfoutput query="qGetAlertEmails">
	<cfset elist = elist&qGetAlertEmails.email&";">	<!--- #elist# --->
</cfoutput>

<cfif qGet800Errors.recordcount gt 0 and trim(elist) neq ""> <!--- only write email if there are errors and someone to send to--->

	<CF_EMAILWRAPPER TO		=	"#elist#"
        FROM		=	"#Contact_Admin_Email_Address#"
        SUBJECT		=	"800 Payment Interface Error"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1" 
		apparea="3" >
		<STYLE TYPE="text/css">
		.datatext
		{
			color: Black;
			font-size: 12px;
			padding-left: 7px;
			text-align : center;
			font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;

		}

		.tbord {
			border-bottom : solid 2px red;
			border-left : solid 2px red;
			border-right : solid 2px red;
			border-top : solid 2px red;
		}

		.headertext
		{
			color: navy;
			font-size: 12px;
			padding-left: 7px;
			text-align : center;
			font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
			border-bottom: Solid 2px red;
			font-weight : bold;
		}
		.copytext
		{
			color: Black;
			font-size: 12px;
			padding-left: 7px;
			text-align : left;
			font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;

		}
</style>
	
		<table width="100%">
			<tr>
				<td class="copytext"><strong>The 800 payment interface had errors</strong>.  In addition to the details below, you may find more info in the <strong>Data Integration Viewer Error log</strong> for this interface.  Please investigate the following 800 payment interface inconsistencies:</td>
			</tr>
			<tr>
				<td class="copytext">Imported to Forge:&nbsp; <cfoutput>#lastrd# #lastrt#</cfoutput></td>
			</tr>
		</table>&nbsp;
		<table cellpadding="8" cellspacing="0" class="tbord" width="100%">
			<tr>
				<td class="headertext">Check Date/Time</td>
				<td class="headertext">Check Number</td>
				<td class="headertext">Bill Back Number</td>
				<td class="headertext">Check Amount</td>
				<td class="headertext">Claim Amount</td>
				<td class="headertext">Bill Back Check Date</td>
				<td class="headertext">Error Description</td>
			</tr>
			<cfoutput query="qGet800Errors">
			  <cfset chkdt = CreateDateTime(left(Check_Run_Date,4), mid(Check_Run_Date,5,2), right(Check_Run_Date,2), left(Check_Run_Time,2), mid(Check_Run_Time,3,2), right(Check_Run_Time,2))>
			  <cfset bbdt = CreateDate(left(BB_Check_Date,4), mid(BB_Check_Date,5,2), right(BB_Check_Date,2))>
			<tr bgcolor="###Iif(((qGet800Errors.CurrentRow MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#">
				<td class="datatext">#DATEFORMAT(chkdt)# #timeformat(chkdt)#</td>
				<td class="datatext">#Check_Number#</td>
				<td class="datatext">#BB_Code#</td>
				<td class="datatext">#Check_Amount#</td>
				<td class="datatext">#Claim_Amount#</td>
				<td class="datatext">#DATEFORMAT(bbdt)#</td>
				<td class="datatext">#Reason_Code#</td>
			</tr>
			</cfoutput>
			<tr>
				<td></td>
			</tr>
		</table>
	</CF_EMAILWRAPPER>

</cfif>

