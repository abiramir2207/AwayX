<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>

<body>



<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
	
<CFIF FORM.FormSubmitted EQ 1>
 	<cfset useLakebaseForUpdateReject = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateReject>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"dd_rejected" = 1,
					"dd_rejected_by" = request.AccessStructure.User_ID,
					"dd_rejected_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_rejected_reason" = FORM.DD_Rejected_Reason
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateReject = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateReject>
	<CFQUERY NAME="UpdateReject" DATASOURCE="#Application.Datasource#">
		UPDATE Deductions
		SET DD_Rejected = 1,
			DD_Rejected_By = '#request.AccessStructure.User_ID#',
			DD_Rejected_Date = getdate(),
			DD_Rejected_Reason = '#FORM.DD_Rejected_Reason#'
		WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY> 
	</cfif>
	
	<CFQUERY NAME="qCheckIfAllRejected" DATASOURCE="#Application.Datasource#">
		
		select	COUNT(d2.Deduction_ID) - SUM(cast(d2.DD_Rejected as int)) as All_Rejected, d3.DD_Rejected as Parent_DD_rejected, d3.Deduction_ID as Parent_Deduction_ID
		from	Deductions d
				inner join Deductions d2 on d2.DD_Parent_ID = d.DD_Parent_ID and d2.Deduction_ID != d.Deduction_ID and d2.DD_IsChild = 1 and d2.Deleted = 0
				inner join Deductions d3 on d3.Deduction_ID = d.DD_Parent_ID and d3.DD_IsParent = 1 and d3.Deleted = 0
		where	d.Deduction_ID = '#Deduction_ID#'
		and		d.DD_IsChild = 1

		group by  d3.DD_Rejected,  d3.Deduction_ID

	</CFQUERY>
	
	<cfif qCheckIfAllRejected.RecordCount and qCheckIfAllRejected.All_Rejected eq 0 and qCheckIfAllRejected.Parent_DD_rejected eq 0>
	
		<cfset useLakebaseForUpdateRejectParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateRejectParent>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#qCheckIfAllRejected.Parent_Deduction_ID#" },
					{
						"dd_rejected" = 1,
						"dd_rejected_by" = request.AccessStructure.User_ID,
						"dd_rejected_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
						"dd_rejected_reason" = FORM.DD_Rejected_Reason
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateRejectParent = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateRejectParent>
		<CFQUERY NAME="UpdateRejectParent" DATASOURCE="#Application.Datasource#">
			UPDATE	Deductions
			SET 	DD_Rejected = 1,
					DD_Rejected_By = '#request.AccessStructure.User_ID#',
					DD_Rejected_Date = getdate(),
					DD_Rejected_Reason = '#FORM.DD_Rejected_Reason#'
			WHERE 	Deduction_ID = '#qCheckIfAllRejected.Parent_Deduction_ID#'
		</CFQUERY>
		</cfif>
	
	
	</cfif>
	
	<CFIF LEFT(application.returned_customer_setting.customer_keyword,1) IS "H">
		<CFSET Log_1520_DataInsert = CreateObject("Component", "Components.Interfaces.Log1520").init(Deduction_ID) />
		<CFSET Log_1520_DataInsert.AddtoLog()>
		<CFSET Close_1520 = 1>
		<!--- Ana 15454 - Commentting to avoid DeadLock 
		<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_In_Billback/Close_All_Interface_Insert.cfm"> --->
	</CFIF>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">This Deduction has been rejected.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function relocateThis()
	{
		window.parent.location.href = "/deductions/deduction.cfm?deduction_ID=<CFOUTPUT>#FORM.Deduction_ID#</CFOUTPUT>"
	}
	window.setTimeout('relocateThis()', 2000);	
	</SCRIPT>

<CFELSE>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<FORM NAME="RejectDD" ACTION="Reject_This_DD.cfm" METHOD="POST">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Deduction_ID" VALUE="#deduction_ID#">
	</CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD ALIGN="Center"><BR><BR><B><FONT COLOR="Navy" SIZE="2">Reject this deduction</FONT></B><BR><BR></TD>
		</TR>
		<TR>
			<TD><B>Rejection Reason:</B></TD>		
		</TR>
		<TR>
			<TD><TEXTAREA NAME="DD_Rejected_Reason" COLS="80" ROWS="4" onPaste="javaScript: return textareaChecklength('250', this);"  onkeyPress="javaScript: return textareaChecklength('250', this);"></TEXTAREA></TD>
		</TR>
		<TR>
			<TD ALIGN="Center"><BR><BR> 
				<CF_button
					button_name	=	"reject"
					button_caption	=	"Reject"
					button_action	=	"validation()"
					button_type	=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								><BR><BR>
				<CFIF LEFT(application.returned_customer_setting.customer_keyword,1) IS "H"><B><FONT COLOR="Red">** Rejecting a deduction will send a report to your system on nightly basis.</FONT></B></CFIF>
			</TD>
		</TR>
	</TABLE>
	</FORM>
	
	<SCRIPT language="JavaScript">
	function validation()
	{
		if (document.forms['RejectDD'].elements['DD_Rejected_Reason'].value == "")
		{
			alert("Please enter the Rejection Reason.")
			document.forms['RejectDD'].elements['DD_Rejected_Reason'].focus()
		}
		else
		{
			if(confirm("Press OK to reject this deduction."))
			{
				document.forms['RejectDD'].elements['FormSubmitted'].value=1;
				document.forms['RejectDD'].submit()
				disableButton("reject_table", true, false);
			}
		}
	}
	</SCRIPT>
</CFIF>
</body>
</html>
