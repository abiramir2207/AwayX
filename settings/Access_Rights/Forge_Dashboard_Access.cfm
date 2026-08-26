<!----------------------------------------------------------------------------------
Name         :  AwayX/Settings/Access_Rights/Forge_Dashboard_Access.cfm
Copyright    :  (c) 2022 Blacksmith Applications, Inc.
Created Date :  13-January-2022
Created By   :  Dinesh Rachala
Description  :  Forge Dashboard Access settings
---------------------------------------------------------------------------------->

<font COLOR="Navy" SIZE="+1">Home Page Dashboards Access</font>
<HR COLOR="orange">
<style>
	table{
		margin: 0 auto;
		width: auto;
		clear: both;
		border-collapse: collapse;
		table-layout: fixed; // ***********add this
		word-wrap:break-word; // ***********and this
		}
		td{
			font-family: Arial;
    font-size: 8pt;
    font-weight:bold;
		}
	</style>
	<cfparam name="form.Prg_Dashboard" default="0">
	<cfparam name="form.BB_Dashboard" default="0">
	<cfparam name="form.DD_Dashboard" default="0">
	<cfparam name="form.PLNR_Dashboard" default="0">
	<cfparam name="form.save" default="0">

	<cfif form.save>
		<cfquery name="qDashboardAccessInfo" datasource="#application.datasource#">
		SELECT *
		FROM Home_Dashboard_Access
		WHERE Profiles_ID = #url.profileId#
		AND Deleted = 0
		</cfquery>

<cfquery name="qDashboardSave" datasource="#application.datasource#">
		<cfif qDashboardAccessInfo.recordCount>
			UPDATE Home_Dashboard_Access
			SET BB_Dashboard_Access = #form.BB_Dashboard#
						,DD_Dashboard_Access = #form.DD_Dashboard#
						,PLNR_Dashboard_Access = #form.PLNR_Dashboard#
						,PRG_Dashboard_Access = #form.Prg_Dashboard#
						,Updated_Date = getdate()
			WHERE Profiles_ID = #url.profileId#
			AND Deleted = 0
		<cfelse>
			INSERT INTO Home_Dashboard_Access (Profiles_ID, BB_Dashboard_Access, DD_Dashboard_Access, PLNR_Dashboard_Access, PRG_Dashboard_Access, Created_Date)
			VALUES (#url.profileId#, #form.BB_Dashboard#, #form.DD_Dashboard#, #form.PLNR_Dashboard#, #form.Prg_Dashboard#, getdate())
		</cfif>
	</cfquery>
	</cfif>

	<cfquery name="qDashboardAccessInfo" datasource="#application.datasource#">
		SELECT BB_Dashboard_Access, DD_Dashboard_Access, PLNR_Dashboard_Access, PRG_Dashboard_Access
		FROM Home_Dashboard_Access
		WHERE Profiles_ID = #url.profileId#
		AND Deleted = 0
	</cfquery>

	<cfoutput>
<form name="HomeDasboard" action="Forge_Dashboard_Access.cfm?profileId=#url.profileId#" method="POST">
<table align="center" cellpadding="3" cellspacing="1" border="1">
	<thead bgcolor="c0c0c0">
	<td align="left" width="200"><B>Dashboard Type</B></td>
	<td align="left"><B>Approve</B></td>
	</thead>
	<tr>
		<td>Program</td>
		<td><input type="checkbox" name="Prg_Dashboard" value="1" <cfif qDashboardAccessInfo.recordCount AND qDashboardAccessInfo.Prg_Dashboard_Access>checked</cfif>></td>
	</tr>
	<tr>
		<td>Billback</td>
		<td><input type="checkbox" name="BB_Dashboard" value="1" <cfif qDashboardAccessInfo.recordCount AND qDashboardAccessInfo.BB_Dashboard_Access>checked</cfif>></td>
	</tr>
	<tr>
		<td>Deduction</td>
		<td><input type="checkbox" name="DD_Dashboard" value="1" <cfif qDashboardAccessInfo.recordCount AND qDashboardAccessInfo.DD_Dashboard_Access>checked</cfif>></td>
	</tr>
	<tr>
		<td>#Application.PlannerLabel#</td>
		<td><input type="checkbox" name="PLNR_Dashboard" value="1" <cfif qDashboardAccessInfo.recordCount AND qDashboardAccessInfo.PLNR_Dashboard_Access>checked</cfif>></td>
	</tr>
</table>
<input type="Hidden" name="profileId" value="#url.profileId#" />
<input type="Hidden" name="save" value="1" />
</form>
<br>
<div align="center">
	<CF_BUTTON
	BUTTON_NAME		=	""
	BUTTON_CAPTION	=	"save settings"
	BUTTON_ACTION	=	"document.HomeDasboard.submit();"
	BUTTON_TYPE		=	"javascript_link"
	BUTTON_WIDTH	=	"100"
	BUTTON_COLOR	=	"Navy"
	BUTTON_TIP		=	""
	FONT_COLOR		=	"White"
	FONT_SIZE		=	"12"
	FONT_WEIGHT		=	"bold">
</div>

</cfoutput>