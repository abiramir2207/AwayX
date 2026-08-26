<!---
	FILENAME: 	Program_Alert_Display.cfm
	Copyright 	(c) 2008 Blacksmith Applications, Inc.
	CREATED: 	Tim Ford
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfset PAGE_TITLE = "Program Alerts">
<cfparam name="URL.Program_ID" default="0" />

<cfset variables.oProgramAlertManager = createObject("component", "components.settings.ProgramAlerts.ProgramAlertManager") />
<cfset variables.qGetDistributorMessage = variables.oProgramAlertManager.getProgramAlertMessage(URL.Program_ID, 1) />
<cfset variables.qGetOperatorPrograms = variables.oProgramAlertManager.getProgramAlertOperatorPrograms(URL.Program_ID) />



<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>

	<style type="text/css">
		table {
				margin-right:10px;
				border-collapse:collapse;
				}
		th 	  { font-size:9pt;
				color:#000000;
				font-weight:550;
				font-family:verdana;
				text-align:left;
				padding-left:5px;
				padding-right:5px;
				background-color:#FFCE84;
				}
		td 	  {	font-size:8pt;
				color:#000000;
				padding-left:5px;
				padding-right:5px;
				font-family:verdana;
				vertical-align:top;
				}
		pre	  {
				font-size:8pt;
				color:#000000;
				font-family:verdana;
			  }
		td.norecords  {	font-size:8pt;
						color:#770022;
						font-family:verdana;
						padding-left:5px;
						text-align:center;
						}
		.header { font-size:11pt;
				  font-weight:bold;
				  color:#000000;
				  font-family:verdana;
				  text-align:left;
				  }
		textarea { width:725px;
				   height:75;
				   margin-top:5px;
				   margin-bottom:5px;
				   margin-right:10px;
				   margin-left:10px;
				   font-family:verdana;
				   }
		p.bodyheader 	{ font-size:10pt;
						  color:#22006F;
						  font-family:verdana;
						  font-weight:bold;
						  }
	  
						  
		a	{ font-family:verdana;
			  font-size:10pt;
			  font-weight:700;
			  color:dark blue;
			  }
		.likelink	{ font-family:verdana;
					  font-size:9pt;
					  font-weight:700;
					  color:blue;
					  background-color:white;
					  }
	</style>
	
	
</head>
<body>

<table align="center" border="1">

	<tr>
		<td colspan="100%">
			<cfoutput>Program <b>#variables.qGetDistributorMessage.Contract_Number#</b> Triggered By <b>#variables.qGetDistributorMessage.User_Name#</b> on <b>#DateFormat(variables.qGetDistributorMessage.Pickedup_Date, "mm/dd/yyyy")#</b></cfoutput>
			<br>
			<br>
			<b>PROGRAMS ALERTED</b>
		</td>
	</tr>
	<tr>
		<th>Template Name</th>
		<th>Program Number</th>
		<th>Title</th>
		<th>RSP</th>
		<th>Email Address</th>
	</tr>
	<cfif variables.qGetOperatorPrograms.recordCount>
	<cfoutput query="variables.qGetOperatorPrograms">
	<tr>
		<td>#Operator_Template_Type#</td>
		<td>#Operator_Contract_Number#</td>
		<td>#Operator_Contract_Title#</td>
		<td>#User_Name#</td>
		<td>#User_Email#</td>
	</tr>
	</cfoutput>
	<cfelse>
		<tr><td colspan="100%" align="center">No Programs Alerted</td></tr>
	</cfif>
	<tr>
		<td colspan="100%" align="center">
			<span style="font-weight:bold;color:red"> [ </span> <a href="##" OnClick="javascript:window.close();">close window</a>  <span style="font-weight:bold;color:red"> ] </span>
		</td>
	</tr>
	
</table>

</body>
</html>