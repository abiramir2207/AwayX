<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Data Integration Alert Jobs</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE TYPE="text/css">
				.headbreak
		{
			border-top: Solid 1px red;
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
			text-align : left;
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
				.subButton
		{
			font-size: 11px;
			WIDTH: 45px;
			background-color : transparent;
			color : blue;
			border-style : none none none none;
			font-weight : bold;

		}
		.subButtonOver
		{
			font-size: 11px;
			WIDTH: 45px;
			background-color : transparent;
			color : red;
			border-style : none none none none;
			font-weight : bold;
			text-decoration : underline;
			cursor:pointer;
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
<cfif isdefined("Form.fieldnames")>
   <cfloop list="#Form.fieldnames#" index="i">
     <cfif left(i,9) eq "AlertTime">
		 <cfset useLakebaseForUpdAlertJobs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_jobs")>
		 <cfif useLakebaseForUpdAlertJobs>
			<cftry>
				<cfset application.oLakebase.updateRows("data_integration_jobs",
					{ "intra_id" = "eq.#gettoken(i,2,'_')#", "send_alert" = "eq.true" },
					{ "alert_time" = evaluate(i) }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdAlertJobs = false>
				</cfcatch>
			</cftry>
		 </cfif>
		 <cfif NOT useLakebaseForUpdAlertJobs>
		 <cfquery name="updAlertJobs" datasource="#application.datasource#">
		  update data_integration_Jobs
		   Set Alert_time = <cfoutput>#evaluate(i)#</cfoutput>
		   where intra_id = <cfoutput>'#gettoken(i,2,"_")#'</cfoutput>
		   and send_alert = 1
		</cfquery><!---  <cfoutput>#gettoken(i,2,"_")#  ::  #evaluate(i)#</cfoutput>  --->
		 </cfif>
	 </cfif>
   </cfloop>
 </cfif>
<body onLoad="window.focus()">
<cfparam name="url.intra_Id" default="800">
<cfparam name="message" default="">
<cfset useLakebaseForQGetAlerts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_jobs")>
<cfif useLakebaseForQGetAlerts>
	<cftry>
		<cfset qGetAlerts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration_jobs", {
				"send_alert" = "eq.true",
				"select" = "intra_id,job_name,alert_time"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForQGetAlerts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForQGetAlerts>
	<cfquery name="qGetAlerts" datasource="#application.datasource#">
	  Select Intra_id, Job_Name, Alert_time
	  From Data_Integration_Jobs
	  where Send_Alert = 1
	</cfquery>
</cfif>


<cfform action="DataInt_Alert_Jobs.cfm" name="DAJ" method="POST">

<div class="datattitle">Configure Jobs to Send Alerts</div>
<table cellspacing="0" cellpadding="5">
<tr class="headbreak">
	<td valign="top" class="headtext">Job</td>
	<td valign="top" nowrap class="headtext">Time Bufffer</td>
	<!---
	<td valign="top" class="headtext">Recipients</td>
	--->
</tr>
<!--- <tr><td colspan="3" width="100%"><div class="headbreak"></div></td></tr> --->
<cfset i = 1>
<cfoutput query="qgetAlerts">
<tr class="datatext" bgcolor="###Iif(((i MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#">
	<td>#qgetAlerts.Job_Name#</td>
	<td width="75"><cfinput type="Text" name="AlertTime_#qGetAlerts.intra_id#" value="#qgetAlerts.Alert_time#" size="1" required="Yes" validate="integer" message="Please Enter a valid integer for #qgetAlerts.Job_Name#."> Hours</td>
	<!---
	<cfquery name="qGetContacts" datasource="#application.datasource#">
	Select Distinct email
	From Data_Integration_Contacts
	where intra_id = #qGetAlerts.intra_id#
</cfquery>
	<td><cfloop query="qGetContacts"><a href="javascript:(void);" onclick="javascript:window.open('DataInt_Alert.cfm?em=#email#&Intra_Id=#qGetAlerts.intra_id#','configAlert','toolbar=no,width=800,height=460,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false">#email#</a>; </cfloop></td>
	--->
</tr><cfset i = i +1>
</cfoutput>
<tr><td align="left" colspan="3"><FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>&nbsp;<input type="submit" value="Submit"  name="submit" class="subbutton"onmouseover="this.className='subbuttonover'" onmouseout="this.className='subbutton'">&nbsp;<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
		<br>* Please note:  In order to turn off notifications for an interface, set the Alert time to 0 (zero).
							
							</td></tr>
</table>
</cfform>

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
	if (!((!isNaN(document.all.AlertTime.value)) && (document.all.AlertTime.value != null) && (document.all.AlertTime.value.length > 0)))
	{
		alert("Please enter a valid Number!");
		document.all.AlertTime.focus();
		Submit_OK=0;	
		return;	
	}
	if (Submit_OK == 1)
	{	
		document.all.DAJ.submit()
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
