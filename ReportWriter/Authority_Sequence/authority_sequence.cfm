 <!---
***********************************************************************
Author: Milan Mushran
Filename: authority_sequence.cfm
Purpose: Users Authority Sequence Report
Custom Tag/s: None
Include Files: None
Date Created: 10/05/2005
Modification:
Modified By:
Modified Date:
***********************************************************************
--->
 <style>
	.heading
	{
		font-family: verdana,arial,helvetica;
		font-size: 20px;
		font-weight: bold;
	}

	.ColumnHeaders
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
		font-weight:bold;
		background: #FFB062;
		text-align:left;
	}

	.SectionHeaders
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:12px;
		font-weight:bold;
		color:brown;
		vertical-align:top;
	}

	.ReportContent
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:10px;
		font-weight:bold;
	}

	.ReportContentDetail
	{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:10px;
	}
</style>

<cfparam name="Type" default="">
<cfparam name="TypeName" default="">

<!--- "HeaderList" is the list of headers to be shown.  "DBFieldList" is the list of db fields used
			for the display of results.  (1- programs), (2- Billbacks) (3- Deductions)--->
<cfif Type eq 1>
	<cfset TypeName = "PROGRAMS">
	<cfset HeaderList="APPROVE ALL PRODUCTS,APPROVE GROUP,APPROVE GROWTH,APPROVE ADVANCED FUNDS">
	<cfset DBFieldList="Approve_Growth_Programs,Approve_Group_Deals,Approve_All_Products_Program,Approve_Upfront_Payments">
<cfelseif type eq 2>
	<cfset TypeName = "BILLBACKS">
	<cfset HeaderList="">
	<cfset DBFieldList="">
<cfelseif type eq 3>
	<cfset TypeName = "DEDUCTIONS">
	<cfset HeaderList="APPROVE REBILL">
	<cfset DBFieldList="DD_Approve_Rebill">
</cfif>

<!--- Pass the appropriate ID to get the results --->
 <cfstoredproc  procedure = "get_Auth_Sequence"  dataSource = "#application.datasource#">
	<cfprocparam type = "in" dbVarName = "@Type" value = "#Type#" CFSQLType = "cf_sql_integer">
		 <cfprocresult name = "get_Auth_Sequence">
 </cfstoredproc>


<p align="center" class="heading"><cfoutput>#TypeName#</cfoutput></p>

<table align="center" cellspacing="0" cellpadding="4" border="0">
		<tr>
			<td class="ColumnHeaders">POSITION</td>
			<td class="ColumnHeaders">AUTH SEQ<span style="padding-left:25">NAME/PROFILE</span></td>
			<cfoutput>
				<cfloop list="#HeaderList#" index="Content">
					<td class="ColumnHeaders"  align="left">#Content#</td>
				</cfloop>
			</cfoutput>
		</tr>

<cfset PositionLabelList = "">

<!--- Add a horizontal line (hr) to differentiate between headquarters, Division, Region and market --->
<cfoutput query="get_Auth_Sequence">
<cfif get_Auth_Sequence.currentrow GT 1>
	<cfif (Service_Zone_ID neq "" AND Service_Zone_ID[get_Auth_Sequence.currentrow-1] eq "")
			OR (Service_Market_ID neq "" AND Service_Market_ID[get_Auth_Sequence.currentrow-1] eq "")
			OR (Service_Region_ID neq "" AND Service_Region_ID[get_Auth_Sequence.currentrow-1] eq "")>
		<tr>
			<td colspan="100%"><hr noshade color="black"></td>
		</tr>
	</cfif>
</cfif>

<!--- Do not repeat the display of same "Position" --->
		<cfif ListFindNoCase(PositionLabelList,Position_Label) eq 0>
			<cfset PositionLabelList = ListAppend(PositionLabelList,Position_Label)>
				<tr>
					<td class="SectionHeaders" colspan="100%">#Position_Label#</td>
				</tr>
		</cfif>

<!--- Do not repeat the display of same "authority sequence" --->
		<cfif User_Positions_ID neq User_Positions_ID[get_Auth_Sequence.currentrow-1] OR Authority_Sequence_ID neq Authority_Sequence_ID[get_Auth_Sequence.currentrow-1]>
				<tr>
					<td width="10%">&nbsp;</td>
					<td width="50%" class="ReportContent">(#Authority_Sequence_Order#) #Authority_Sequence_Name#</td>
				</tr>
		</cfif>

		<tr>
				<td width="10%">&nbsp;</td>
				<td class="ReportContentDetail" style="padding-left:90">#Name_First#&nbsp;#Name_Last#, #Profiles_Desc#</td>
						<cfloop list="#DBFieldList#" index="DbField">
							<td class="ReportContentDetail" style="padding-left:40">
								<cfif DbField eq 1>Y<cfelse>N</cfif>
							</td>
						</cfloop>
	  </tr>
</cfoutput>
</table>