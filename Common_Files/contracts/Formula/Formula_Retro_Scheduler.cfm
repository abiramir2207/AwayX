<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Formula Retro Scheduler</title>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<body RIGHTMARGIN="8" LEFTMARGIN="8">


	<style>
		p.i { font-size:13px; color:green; font-weight:bold; }
		p.e { font-size:13px; color:red; font-weight:bold; }
	</style>

<cfparam name="url.Program_ID" default="0" />
<cfparam name="form.Program_ID" default="#url.Program_ID#" />
<cfparam name="form.btnSubmit" default="0" />
<cfparam name="url.bFromProcess" default="0" />

<cfif form.btnSubmit eq 1>
	<cfstoredproc procedure="Formula_Price_Item_Program_Update" datasource="#application.datasource#"> 
		<cfprocparam cfsqltype="CF_SQL_DATE" value="#form.start_date#"> 
		<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#form.Program_Id#">
	</cfstoredproc>
	<cflocation url="Formula_Retro_Scheduler.cfm?Program_ID=#form.Program_ID#&bFromProcess=1" />
</cfif>
<cfset objProgram = createObject("component", "components.programs.Program") />
<cfset qGetProgramData = objProgram.getProgramInfo(form.Program_ID) />

<cfoutput>
<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td colspan="100%" bgcolor="">
						<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
						#application.returned_customer_setting.company_name#</DIV>
						<B><font size="+1" color="Navy">[#qGetProgramData.Contract_Number#] - #qGetProgramData.Contract_Title#</FONT></B>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</cfoutput>

<cfquery NAME="qCheckExistingProgram" DATASOURCE="#application.datasource#">	
	select	cm2.Contract_Number as New_Program, cm2.Contract_Title, cm2.Contract_Start_Date, cm2.Contract_End_Date, l.*
	from   	Contract_Main cm
			inner join Program_Formula_Pricing_Revision_Log l on l.Contract_Main_ID = cm.Contract_Main_ID
			inner join Contract_Main cm2 on cm2.Contract_Main_ID = l.New_Contract_Main_ID
	WHERE  cm.Contract_Number = '#qGetProgramData.Contract_Number#'
</cfquery>
<!-------------------------------------------------------------------------------------->
<!------------------------------- bFromProcess START ----------------------------------->
<!-------------------------------------------------------------------------------------->
<cfif url.bFromProcess eq 1 and !qCheckExistingProgram.RecordCount>

	<p class="e">New program cannot be created at this time.</p>

<cfelse>

	<cfif qCheckExistingProgram.RecordCount>
		<br>
		<p class="i">Program below successfully created.<cfif url.bFromProcess eq 1><cfelse>This program was already used to create the program below.</cfif></p>
		<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="100%" CLASS="datagrid">

			<!---- HEAD ----->
			<TR ID="HEADER" BGCOLOR="#FFCE84">
				<TD STYLE="font-size:11px;" valign="top">
					<b>Program</b>
				</TD>
				<TD STYLE="font-size:11px;" valign="top">
					<b>Title</b>
				</TD>
				<TD STYLE="font-size:11px;" valign="top">
					<b>Start Date</b>
				</TD>
				<TD STYLE="font-size:11px;" valign="top">
					<b>End Date</b>
				</TD>
			</TR>
			<cfoutput query="qCheckExistingProgram">
			<TR>
				<TD>
					#New_Program#
				</TD>
				<TD>
					#Contract_Title#
				</TD>
				<TD>
					#DateFormat(Contract_Start_Date, "mm/dd/yyyy")#
				</TD>
				<TD>
					#DateFormat(Contract_End_Date, "mm/dd/yyyy")#
				</TD>
			</tr>
			</CFOUTPUT>
		</TABLE>
	<cfelse>
		<FORM ACTION="Formula_Retro_Scheduler.cfm" METHOD="post" NAME="DataForm">
		<br>
		<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0">
			<tr>
				<td>
					Process Date:
				</td>
				<td>
					<CF_EASYDATE FORMNAME="DataForm" FIELDNAME="start_date" FORMAT="mm/dd/yyyy">
				</td>
			</tr>
			<tr>
				<td>
					<CF_smallLink
						title = "process"
						url = "JavaScript:submitForm();"
						parameters = ""
					>
				</td>
			</tr>
		</table>
		<cfoutput>
		<INPUT TYPE="hidden" NAME="Program_Id" ID="Program_Id" VALUE="#form.Program_Id#">
		<INPUT TYPE="hidden" NAME="btnSubmit" ID="btnSubmit" VALUE="#form.btnSubmit#">

		</cfoutput>
		</form>
	</cfif>
</cfif>
<!-------------------------------------------------------------------------------------->
<!------------------------------- bFromProcess END ------------------------------------->
<!-------------------------------------------------------------------------------------->
<br>
<CF_smallLink
	title = "close"
	url = "JavaScript:window.close();"
	parameters = ""
>
<script>
	function submitForm(){
		
		if(document.DataForm.start_date.value.length == 0)
		{
			alert("Process Date is required.");
		}
		else
		{
			document.DataForm.btnSubmit.value=1;
			document.DataForm.submit();
		}
	}
</script>
</body>
</html>