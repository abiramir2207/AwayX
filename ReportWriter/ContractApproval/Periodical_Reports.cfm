<!---
***********************************************************************
Author: Milan Mushran
Filename: Periodical_Reports.cfm
Purpose: For Summary and Detailed Contract Approval Reports
Input Parameters (form): form.start_date, form.end_date
Input Parameters (query): UserID
Output Parameters (form): form.start_date, form.end_date
Custom Tag/s: CF_EASYDATE
Date Created: 08/20/2004
Modification:
Modified By: Brenda Flynn
Modified Date:9-15-2004
Modified to show only reports for users who are in the same position or under the viewing user

Modification: Added help link
Modified By: Milan Mushran
Modified Date: 02/23/2005

Modification: Added header, user profile dropdown, page title, and resorted the results
Modified By: Clarence Morse
Modified Date: 08/07/2006
***********************************************************************
--->

<cfset PAGE_TITLE="Program Approval Report">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfinclude TEMPLATE="/includes/header.cfm">
<cfset MyUserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0) />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Periodical Contract Approval Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<SCRIPT language="JavaScript">
/* Click on Summary Report and get the detailed report. */
/* This function accepts the number of detailed report records and the UserID of the person. */
function ClickToOpenLayer(TotalRows,UniqueID)
{
var DisplayObject;

/* Loop through the rows of the Detailed report */
for (i=1; i<=TotalRows; i++)
{
/* Get the row's ID */
DisplayObject = document.getElementById("SummaryData"+UniqueID+i)

/* Show/Hide based on its visible status */
		if(DisplayObject.style.display == 'none')
		{
		DisplayObject.style.display = '';
		}
		else
		{
		DisplayObject.style.display = 'none';
		}

}

}
</SCRIPT>

<!--- Style sheet for report headers, content, title and for report row highlighting  --->
<style type="text/css">
.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
.heading 	
	{
	font-family: verdana,arial,helvetica; 
	font-size: 11px;
	font-weight: bold; 
	background: #FFCC00;
	}
.content	
	{
	font-family: verdana,arial,helvetica;
	font-size: 11px; 
	text-align: left; 
	border-bottom: 1px solid blue;
	}
.reporttitle
	{
	font-family: verdana,arial;
	font-size: 14px;
	font-weight: bold;
	text-align: center;
	}			
TD.UNDERLINED
	{
	border-bottom: 1px solid #7575FF;
	}
TR.highlight TD.UNDERLINED
	{
	background-color: #EAFFEA;
	border-bottom: 1px solid #7575FF;
	align: right;
	}
TR.nothighlight TD.UNDERLINED  
	{
	border-bottom: 1px solid #7575FF;
	}
</style>
</head>
<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"><br><br>
<table width="100%">
	<TR VALIGN="TOP">
		<TD COLSPAN="100%" CLASS="sectionHead"><strong>Program Approval Report</strong></TD>
	</TR>
</table>
<!--- Default date parameters, passed from the text box --->
<cfparam name="form.start_date" default="">
<cfparam name="form.end_date" default="">
<cfparam name="ViewReport" default="">

<!--- On Date selection --->
<cfif form.start_date neq "" AND form.end_date neq "">

<!--- Get the Contract Approval Summary Report --->
		<cfquery name="selPeriodSummary" datasource="#application.datasource#">
				SELECT u.User_ID
							,u.Name_First
							,u.Name_Last
							,Count(cm.Contract_Main_ID) As ApprovedDeals
							,AVG(CAST(DATEDIFF( "dd", cm.Broker_Approved_Date, cm.Approval_Date) AS Numeric(10,1))) As AverageApproval
				FROM Contract_Main cm
				INNER JOIN _Users u
				ON cm.Approved_by_user_ID = u.user_ID
				AND cm.Approved_by_user_ID IN (
																				SELECT          _Users.User_ID
																				FROM _Users
																		        INNER JOIN User_Position_Holders
																		        ON User_Position_Holders.Deleted = 0
																		        AND User_Position_Holders.User_ID = _Users.User_ID
																				WHERE _Users.Deleted = 0      
																				AND    User_Position_Holders.User_Positions_ID IN (
																																												SELECT DISTINCT Below_User_Positions_ID
																																												FROM Positions_Below_Me
																																												WHERE  User_Positions_ID IN (#MyUserPositionLIst#)
																																												)
																					)
				WHERE cm.Contract_Status_Type_IDX >=3
				AND cm.Approval_Date BETWEEN '#start_date#' AND DateAdd("dd",1,'#End_date#')
				<cfif isdefined("UserProfileFilter") AND UserProfileFilter NEQ "-1">
					AND u.Profiles_ID = '#UserProfileFilter#'
				</cfif>
				GROUP BY  u.User_ID, u.Name_Last, u.Name_First
				ORDER BY ApprovedDeals ASC, AverageApproval ASC	
		</cfquery>
</cfif>

<!--- Dev Note: Clay 10389 - Add Drop-Down Selection to Filter Report Results   --->
<cfinvoke component="components.settings.profiles.profile" method="getdistinctProfiles" returnvariable="UserProfiles">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Selection options --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
	<form name="SearchForm" action="<cfoutput>#cgi.script_name#</cfoutput>" method="post">
<TABLE ALIGN="center" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD class="heading"><B>Choose Dates:</B></TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TD>
			<CFPARAM NAME="FORM.Start_date" DEFAULT="#Now()#">
			<SPAN ID="SP_Start_date">
<!--- Call the "EASYDATE" custom tag for the calendar --->
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
			</SPAN>
		</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD><B>Ending Date:</B>&nbsp;&nbsp;</TD>
		<TD>
			<CFPARAM NAME="FORM.End_date" DEFAULT="#Now()#">
			<SPAN ID="SP_End_date">
<!--- Call the "EASYDATE" custom tag for the calendar --->
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
			</SPAN>
		</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD>
			<B><FONT COLOR="red">[</FONT> <A HREF="##" ONCLICK="submit();">run report</A> <FONT COLOR="red">]</FONT></B>
	    </TD>
	</TR></CFOUTPUT>	
	<TR>
		<TD class="heading"><B>Filter By Profile:</B></TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TD colspan="100%">
			<select name="UserProfileFilter" style="font-size:12px;">
				<option value="-1">ALL PROFILES</option>
				<cfoutput query="UserProfiles">
				<option value="#profiles_id#" <cfif isdefined("UserProfileFilter") AND UserProfileFilter EQ profiles_id>SELECTED</cfif>>#Ucase(profiles_desc)#</option></cfoutput>
			</select>
		</TD>
	</TR>
</TABLE>
		<input type="hidden" name="ViewReport" value="view">
	</form>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> 
 
<!--- Start Error messages --->
 
<!--- Error message  for "No date selection" --->
 <cfif ViewReport neq ""> 	
 	<cfif form.start_date eq "" OR form.end_date eq "">
	<cfset ErrorMessage = "You must choose the search <span style='font-family:verdana,arial,,helvetica;
	font-size:11px;color:red'>Starting Date</span> and the search <span style='font-family:verdana,arial,helvetica;
	font-size:11px;color:red'>Ending Date</span> for the Report"> 
	<p align="center">
		<cfoutput>#ErrorMessage#</cfoutput>
	<cfabort>
	</p>
<!--- Error message for "search starting date falling after the search ending date" --->
	<cfelseif DateDiff("d", form.start_date, form.end_date) LT 0>
		<cfset ErrorMessage = "The search <span style='font-family:verdana,arial,,helvetica;
	font-size:11px;color:red'>Ending Date</span> must be after the search <span style='font-family:verdana,arial,,helvetica;
	font-size:11px;color:red'>Starting Date</span>."> 
	<p align="center">
		<cfoutput>#ErrorMessage#</cfoutput>
	<cfabort>
	</p>

<!--- Error message  for "No Records found" --->
 	<cfelseif selPeriodSummary.RecordCount eq 0>
		<cfset ErrorMessage = "<span style='font-family:verdana,arial,helvetica;
		font-size:11px;'>There are no matching records for your search criteria.</span>"> 
	<p align="center">
		<cfoutput>#ErrorMessage#</cfoutput>
	<cfabort>
	</p>	

	</cfif> 
</cfif>

<!--- End Error messages --->

<!--- On Date selection --->
<cfif form.start_date neq "" AND form.end_date neq "">

<!--- Get the total number and average of approved deals for the company --->
			<cfset TotalApprovedDeals = 0>
			<cfset TotalAverageApproval = 0>
		<cfloop query="selPeriodSummary">
			<cfset TotalApprovedDeals = TotalApprovedDeals + ApprovedDeals>
			<cfset TotalAverageApproval = TotalAverageApproval + AverageApproval>
		</cfloop>
		
<!---  We use the conditional logic here to avoid "Division by zero not allowed" error --->
		<cfif selPeriodSummary.Recordcount neq 0>
			<cfset TotalAverageApproval = TotalAverageApproval / selPeriodSummary.Recordcount>
		</cfif>
		
<!--- On Report selection --->
	
	<TABLE ALIGN="CENTER" WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0">
<!--- D38333 : Program Approval Report - Download to Excel START --->
		<tr>
			<td colspan="3" CLASS="reporttitle" width="90%">Average Days to Approve</td>
			<td style="font-weight:bold;" nowrap>
				<FONT COLOR="#FF0000">[</FONT>
					<a HREF="javascript:xls(<cfoutput>'#form.start_date#','#form.end_Date#','#form.UserProfileFilter#'</cfoutput>);">Create XL file </a>
				<FONT COLOR="#FF0000">]</FONT>
			</td>					
		</tr>
<!---D38333 : Program Approval Report - Download to Excel END --->
			<TR>
				<TD class="heading">Name</TD>
				<TD class="heading" WIDTH="25%" align="center"># of Approved</TD>
				<TD class="heading" WIDTH="25%" align="center">Percent of Programs<BR>Approved</TD>
				<TD class="heading" WIDTH="25%" align="center">Average Days<BR>to Approve</TD>
			</TR>
			
<!--- Summary Report Contents --->	
			<cfoutput query="selPeriodSummary">

		<!--- Get the Contract Approval Detailed Report, based on the user --->
				<cfquery name="selPeriodDetailed" datasource="#application.datasource#">
				SELECT u.Name_First, u.Name_Last,cm.Contract_Number, Count(cm.Contract_Main_ID) As ApprovedDeals 
				, AVG(DATEDIFF( "dd", cm.Broker_Approved_Date, cm.Approval_Date)) As AverageApproval
				FROM Contract_Main cm
						INNER JOIN
					_Users u
				ON cm.Approved_by_user_ID = u.user_ID
				WHERE cm.Contract_Status_Type_IDX >=3
				AND cm.Approval_Date 
						BETWEEN '#start_date#' 
						AND DateAdd("dd",1,'#End_date#')
				AND cm.Approved_By_User_ID = '#selPeriodSummary.User_ID#'
				<cfif isdefined("UserProfileFilter") AND UserProfileFilter NEQ "-1">
					AND u.Profiles_ID = '#UserProfileFilter#'
				</cfif>
				GROUP BY u.Name_Last,u.Name_First,cm.Contract_Number	
				ORDER BY ApprovedDeals ASC, AverageApproval ASC
				</cfquery>
<!--- Click on this row to view the detaile report of the user. Pass the Drtailed report recordcount and the UserID of the person --->	
	<TR onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'" onClick="ClickToOpenLayer(#selPeriodDetailed.RecordCount#,'#selPeriodSummary.User_ID#');">
		<TD CLASS="UNDERLINED"><a href="##"><B>#Name_First# #Name_Last#</B></a></TD>
		<TD CLASS="UNDERLINED" align="center">#ApprovedDeals#</TD>
		<TD class="UNDERLINED" align="center">#NumberFormat((ApprovedDeals/TotalApprovedDeals)* 100, "99999.99")# %</TD>
		<TD class="UNDERLINED" align="center">#NumberFormat(AverageApproval,"99999.9")#</TD>
	</TR>
	
	<cfset Current_User_ID = selPeriodSummary.User_ID>
	
		<cfloop query="selPeriodDetailed">
		
		<cfset UniqueID='SummaryData'&Current_User_ID&selPeriodDetailed.currentrow>
	<!--- Show/Hide the rows based on the request --->	
		<TR onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'" id="#UniqueID#" style="display:none;">
			<TD CLASS="UNDERLINED">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#selPeriodDetailed.Contract_Number#</TD>
			<TD CLASS="UNDERLINED" align="center">#selPeriodDetailed.ApprovedDeals#</TD>
			<TD class="UNDERLINED" align="center" >-</TD>
			<TD class="UNDERLINED" align="center">#selPeriodDetailed.AverageApproval#</TD>
		</TR>
	</cfloop>
			</cfoutput>
		</TABLE>

	<p>
			<TABLE ALIGN="CENTER" WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0">	
				<cfoutput>
				<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
					<TD CLASS="UNDERLINED" width="25%"><strong>Total</strong></TD>
					<TD CLASS="UNDERLINED" width="25%" align="center"><strong>#TotalapprovedDeals#</strong></TD>
					<TD CLASS="UNDERLINED" width="25%">&nbsp;</TD>
					<TD CLASS="UNDERLINED" width="25%" align="center"><strong>#NumberFormat(TotalAverageApproval,"99999.9")#</strong></TD>
				</TR>
				</cfoutput>
			</TABLE>
	</p>
</cfif>
<!---D38333 : Program Approval Report - Download to Excel START --->
<script>
function xls(sdate,edate,profile){
	window.open("Periodical_Reports_Excel.cfm?start_date="+sdate+"&end_date="+edate+"&UserProfileFilter="+profile);
}
</script>
<!---D38333 : Program Approval Report - Download to Excel END --->
</body>
</html>