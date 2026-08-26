<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Data Integration Alert Recipients</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE TYPE="text/css">
		.headbreak
		{
			border-top: Solid 1px red;
			margin-bottom : 10px;
		}
		.lrule
		{
			border-left: Solid 1px gray;
			border-right: Solid 1px gray;
			border-bottom: Solid 1px gray;
		}
		.sectionbreak
		{
			color: Black;
			font-size: 12px;
			font-weight: bold;
			border-bottom: Solid 1px Gray;
		}
		.datattitle
		{
			color: Navy;
			font-size: 16px;
			font-weight: bold;
			border-bottom: Solid 2px red;
			text-align : center;
		}
		.headtext
		{
			color: Navy;
			font-size: 12px;
			font-weight: bold;
			border-bottom: Solid 1px red;

		}
		.nonetext
		{
			color: Black;
			font-size: 12px;
			font-weight: bold;
			text-align : center;

		}

		.datatext
		{
			color: Black;
			font-size: 12px;
			padding-left: 7px;
			text-align : center;
		}
		.mtext
		{
			color: red;
			font-size: 12px;
		}
			A, A:LINK, A:VISITED
		{
			color : Blue;
			text-decoration : none;
		}

			A:FOCUS,A:HOVER
		{
			color : Red;
			text-decoration : underline;
		}
</STYLE>

<SCRIPT language="JavaScript">
	function CellOn(CellName)
		{
			eval("CellName.bgColor = '#EAFFEA'")
		}

	function CellOff(CellName)
		{
			eval("CellName.bgColor = '#FFFFFF'")
		}
</script>
</head>

<body onLoad="window.focus()">
<cfparam name="url.intra_Id" default="800">
<cfparam name="message" default="">
<cfquery name="qGetAlerts" datasource="#application.datasource#">
  Select distinct Job_name, category, intra_id
  From Data_Integration_Jobs
  where Send_Alert > 0
  Group By Job_name, Category, intra_id
  order by intra_id
	<!--- Select *
	From Data_Integration_Alerts
	where active = 1 --->
	<!--- Where intra_Id = #intra_Id# --->
</cfquery>

<cfquery name="qGetContacts" datasource="#application.datasource#">
	Select Distinct email
	From Data_Integration_Contacts

</cfquery>


<div class="datattitle">Configure Available Integration Alert Recipients</div>
<table cellpadding="3">
<tr>
		<TD VALIGN="top" width="50%" nowrap style="border-right: Solid 1px Gray;">

		
		
		<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
					<TR>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Email</B></SPAN></TD>
						<TD NOWRAP align="center"><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
		<CFOUTPUT QUERY="qGetContacts">
					<cfset useLakebaseForQGetIntra = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_jobs")>
					<cfif useLakebaseForQGetIntra>
						<cftry>
							<cfset qGetIntra = application.oLakebase.toQuery(
								application.oLakebase.selectRows("data_integration_jobs", {
									"category" = "eq.#qGetAlerts.category#",
									"select" = "intra_id",
									"order" = "intra_id.asc",
									"limit" = "1"
								})
							)>
							<cfcatch type="any">
								<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
								<cfset useLakebaseForQGetIntra = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForQGetIntra>
						<cfquery name="qGetIntra" datasource="#application.datasource#">
							Select top 1 intra_id from Data_integration_Jobs
							where category = '#qGetAlerts.category#'
							order by intra_id asc
						</cfquery>
					</cfif>
					<cfset useLakebaseForQGetAlertEmailStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
					<cfif useLakebaseForQGetAlertEmailStatus>
						<cftry>
							<cfset qGetAlertEmailStatus = application.oLakebase.toQuery(
								application.oLakebase.selectRows("data_integration_contacts", {
									"email" = "eq.#qGetContacts.email#",
									"select" = "active,intra_id,contact_id",
									"order" = "intra_id.asc"
								})
							)>
							<cfcatch type="any">
								<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
								<cfset useLakebaseForQGetAlertEmailStatus = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForQGetAlertEmailStatus>
						<cfquery name="qGetAlertEmailStatus" datasource="#application.datasource#">
							Select Active, Intra_id, contact_id
							From Data_Integration_Contacts
							Where email = '#qGetContacts.email#'
							order by intra_id asc
						</cfquery>
					</cfif>
					
					<TR>
						<TD><A HREF="DataInt_Alert.cfm?em=#email#&Intra_Id=#qGetAlertEmailStatus.Intra_Id#">#email#</A></TD>
						
						<TD align="center">							
							<CFLOOP query="qGetAlertEmailStatus">
								<CFIF qGetAlertEmailStatus.Active EQ 1>
								<IMG SRC="/images/yes_small.gif" TITLE="Active #qGetAlertEmailStatus.intra_id# Series Recipient" align="middle">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="NOT Active #qGetAlertEmailStatus.intra_id# Series Recipient" align="middle">
								</CFIF>	 
							</CFLOOP>
						</TD>
					</TR>
		</CFOUTPUT>
				</TABLE>
				<BR>
					<B>	
		<FONT COLOR="##ff0000" SIZE="2"><B>[</B></FONT>
			<cfoutput><A HREF="DataInt_Alert.cfm?Intra_Id=#Intra_Id#"><B>reset form</B></A></cfoutput>
		<FONT COLOR="##ff0000" SIZE="2"><B>]</B></FONT>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<FONT COLOR="##ff0000" SIZE="2"><B>[</B></FONT>
			<cfoutput><A HREF="javascript:window.close();"><B>close window</B></A></cfoutput>
		<FONT COLOR="##ff0000" SIZE="2"><B>]</B></FONT>
		</B>
				<BR>
	
	
	</td>
	<form name="DIAlert" action="DataInt_Alert_Update.cfm" method="post">
	<CFPARAM NAME="URL.em" DEFAULT="0">
	<cfset useLakebaseForQGetEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
	<cfif useLakebaseForQGetEmail>
		<cftry>
			<cfset qGetEmail = application.oLakebase.toQuery(
				application.oLakebase.selectRows("data_integration_contacts", {
					"email" = "eq.#URL.em#",
					"select" = "email,active,contact_id,intra_id",
					"limit" = "1"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForQGetEmail = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQGetEmail>
		<cfquery name="qGetEmail" datasource="#application.datasource#">
			Select top 1 email, Active, contact_id, intra_id
			From Data_Integration_Contacts
			Where -- intra_Id = #intra_Id# and
			email = '#URL.em#'
		</cfquery>
	</cfif>
	<TD VALIGN="top" width="50%" nowrap>
	<SPAN CLASS="title2">Edit Record</SPAN>
	<HR COLOR="Blue" SIZE="1">
	
			<table>
				<tr>
					<td colspan="2"><strong>Email</strong></td>
				</tr>
				<tr>
					<td colspan="2"><cfoutput><INPUT SIZE="55" NAME="email" VALUE="#qGetEmail.email#" MAXLENGTH="50"></cfoutput></td>
				</tr>
				<tr>
					<td width="50%"><B>Notification Status</B></td>
					<td width="50%"><B>Scheduled Job</B></td>
				</tr>
				<tr>
					<td valign="top" align="left">
						<CFIF qGetEmail.active EQ 0>
							<CFSET inactive=" CHECKED">
							<CFSET active="">
						<CFELSE>
							<CFSET inactive="">
							<CFSET active=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="1" NAME="active"#active#>Active
						<br>
						<INPUT TYPE="radio" VALUE="0" NAME="active"#inactive#>Inactive 
						</CFOUTPUT>
					</td>
					<td><Select NAME="intra_Id" multiple size="19" id="intra_Id">
							<CFOUTPUT QUERY="qGetAlerts">
									<cfset useLakebaseForQGetIntra2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_jobs")>
								<cfif useLakebaseForQGetIntra2>
									<cftry>
										<cfset qGetIntra2 = application.oLakebase.toQuery(
											application.oLakebase.selectRows("data_integration_jobs", {
												"category" = "eq.#qGetAlerts.category#",
												"select" = "intra_id",
												"order" = "intra_id.asc",
												"limit" = "1"
											})
										)>
										<cfcatch type="any">
											<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
											<cfset useLakebaseForQGetIntra2 = false>
										</cfcatch>
									</cftry>
								</cfif>
								<cfif NOT useLakebaseForQGetIntra2>
									<cfquery name="qGetIntra2" datasource="#application.datasource#">
										Select top 1 intra_id from Data_integration_Jobs
										where category = '#qGetAlerts.category#'
										order by intra_id asc
									</cfquery>
								</cfif>
								<cfset useLakebaseForQGetCont = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
								<cfif useLakebaseForQGetCont>
									<cftry>
										<cfset qGetCont = application.oLakebase.toQuery(
											application.oLakebase.selectRows("data_integration_contacts", {
												"email" = "eq.#URL.em#",
												"intra_id" = "eq.#qGetIntra2.intra_Id#",
												"select" = "intra_id,active",
												"order" = "intra_id.asc",
												"limit" = "1"
											})
										)>
										<cfcatch type="any">
											<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
											<cfset useLakebaseForQGetCont = false>
										</cfcatch>
									</cftry>
								</cfif>
								<cfif NOT useLakebaseForQGetCont>
									<cfquery name="qGetCont" datasource="#application.datasource#">
										Select top 1 intra_id, active from Data_integration_Contacts
										where email = '#URL.em#'
										and intra_id = #qGetIntra2.intra_Id#
										order by intra_id asc
									</cfquery>
								</cfif>
									<cfif qGetCont.Active eq 0><cfset aTitle=URL.em&" NOT Active"><CFelseIf qGetCont.Active eq 1><cfset aTitle=URL.em&" Active"><cfelse><cfset aTitle=""></cfif>
								<Option <cfif qGetCont.Active eq 0>style="color : Red;"<CFelseIf qGetCont.Active eq 1>style="color : Green;"</cfif> value="#qGetIntra2.intra_Id#">#Job_Name#<!--- <cfif qGetCont.recordcount gt 0>selected</cfif> --->
							</CFOUTPUT>
							  <!--- 999 is the catch all intra_id...this way we can send alerts for the maint jobs not associated with an interface --->
							         <cfset useLakebaseForQGetCont2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
							         <cfif useLakebaseForQGetCont2>
								         <cftry>
									         <cfset qGetCont2 = application.oLakebase.toQuery(
										         application.oLakebase.selectRows("data_integration_contacts", {
											         "email" = "eq.#URL.em#",
											         "intra_id" = "eq.999",
											         "select" = "intra_id,active",
											         "order" = "intra_id.asc",
											         "limit" = "1"
										         })
									         )>
									         <cfcatch type="any">
										         <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
										         <cfset useLakebaseForQGetCont2 = false>
									         </cfcatch>
								         </cftry>
							         </cfif>
							         <cfif NOT useLakebaseForQGetCont2>
								         <cfquery name="qGetCont2" datasource="#application.datasource#">
											Select top 1 intra_id, active from Data_integration_Contacts
											where email = '#URL.em#'
											and intra_id = 999
											order by intra_id asc
										</cfquery>
							         </cfif>
							<Option <cfif qGetCont2.Active eq 0>style="color : Red;"<CFelseIf qGetCont2.Active eq 1>style="color : Green;"</cfif> value="999">All Maint. Jobs (non-interface)
						</Select>
					</td>
				</tr>
				<tr>
					<TD VALIGN="top" colspan="2">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: Validate()"><B>save/add record</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
									&nbsp;&nbsp;&nbsp;&nbsp;
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete()"><B>delete record</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
									&nbsp;&nbsp;&nbsp;&nbsp;
							<FONT COLOR="##ff0000" SIZE="2"><B>[</B></FONT>
							<A HREF="DataInt_Alert.cfm"><B>reset form</B></A>
							<FONT COLOR="##ff0000" SIZE="2"><B>]</B></FONT>
						
					</TD>
				</tr>
				<tr>
					<td colspan="2" class="mtext"><cfoutput>#message#</cfoutput></td>
				</tr>
			</table>
	
	</td>
		<cfoutput>
				<INPUT TYPE="hidden" NAME="upd_email" VALUE="#qGetEmail.email#">
				<INPUT TYPE="hidden" NAME="contact_id" VALUE="#qGetEmail.contact_id#">
				<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0"></cfoutput>
	</form>
</tr>



<tr>
	<td>
	</td>
	<td></td>
</tr>
</table>




<SCRIPT language="JavaScript">
function alert_and_delete()
{
	var Submit_OK = 1;
	if (isValidEmail(document.all.email.value) == false)
	{
		alert("Please enter a valid email.");
		document.all.email.focus();
		Submit_OK=0;	
		return;	
	}
	
	getMultiple();
	
if (Submit_OK == 1)
	{
		var confirmdelete = confirm("Click OK to delete this record");
		if (confirmdelete == true)
		{
			document.all.DeleteRecord.value=1;
			document.DIAlert.submit();
		}
	}
			
}	
function Validate()
{
	var Submit_OK = 1;
	if (isValidEmail(document.all.email.value) == false)
	{
		alert("Please enter a valid email!");
		document.all.email.focus();
		Submit_OK=0;	
		return;	
	}
    getMultiple();
	if (Submit_OK == 1)
	{	
		document.all.DIAlert.submit()
	}	
}



function getMultiple()
{
  selected = new Array();
  for (var i = 0; i < document.getElementById('intra_id').options.length; i++)
    if (document.getElementById('intra_id').options[i].selected)
      selected.push(document.getElementById('intra_id').options[i].value);
	if (selected.toString() == "")
	     {
	     alert("Please select a Scheduled Job(s)!");
		document.all.intra_id.focus();
		Submit_OK=0;	
		return;	
		}
    // You can use the arSelected array for further processing.
}



//Validates String is not zero length
function isValidString(StringValue) {
	var result = false;
	if ((StringValue != null) && (StringValue.length > 0)) {
		result = true;
	}
	return result;
}

//Validates String data as an Email Address
function isValidEmail(email) {
	var result = false;
	if(isValidString(email)) {
		var theStr = new String(email);
		var index = theStr.indexOf("@");
		if (index > 0)	{
			var pindex = theStr.indexOf(".",index);
			if ((pindex > index+1) && (theStr.length > pindex+2)) {
				result = true;
			}
		}
	}
	return result;
}
</SCRIPT>

</body>
</html>
