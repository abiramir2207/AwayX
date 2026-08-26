<!---
	Name:
		get_trade_plan.cfm
	Created By:
		Tim Ford 04/11/2003 
	Description:
		File will get trade plan reports and list them
--->
<html>
<head>
<title>Get Reports</title>
</head>

<body LEFTMARGIN="0" TOPMARGIN="0">
<style>
	.thickSec td
	{
		border-bottom:2px solid #000080;
	}
	.thinBottom td
	{
		border-bottom:1px solid #000080;
	}
	.thinTop td
	{
		border-top:1px solid #000080;
	}
	.thinTpThickBtm td
	{
		border-top:1px solid #000080;
		border-bottom:2px solid #000080;
	}
</style>

<!---set start and max rows--->
<cfparam name = "MaxRows" default = "20">
<cfparam name = "StartRow" default = "1">

<!---Gets the current user's position--->
<cfscript>
	oUser = createObject("component","components.trade_plan.users");
	getUserPosition = oUser.getUserPosition(request.AccessStructure.user_id);
</cfscript>

 
<!---Includes approval rights stuff--->
<CFSET GP_Supplied_Position = getUserPosition>

<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<!---Get trade plan list--->
<cfscript>
	oTradePlan = createObject("component","components.trade_plan.trade_plan");
	qGetTradePlanList = oTradePlan.getTradePlanList(GP_Position_List_From_My_Position_Down);
</cfscript>

<table ALIGN="center" width="90%" border="0" cellspacing="0" cellpadding="2">
	<tr class="thinBottom">
		<td>&nbsp;</td>
		<td><b><CFOUTPUT>#application.returned_customer_setting.Trade_Label#</CFOUTPUT> Plan Title</b></td>
		<td><b>Date Created</b></td>
		<td><b>Created By</b></td>
		<td><b>Date Last Updated</b></td>
		<td><b>Updated By</b></td>
	</tr>
<cfoutput query="qGetTradePlanList" startrow = "#StartRow#" maxrows = "#MaxRows#">
	
	<!---get user--->
	<cfscript>
		qGetUser = oUser.getUser(Updated_By);
	</cfscript>
	
	<tr>
		<td><B><FONT COLOR="Red">[</FONT>&nbsp;<a href="index.cfm?action=display&Trade_Plan_ID=#Trade_Plan_ID#">display</a>&nbsp;<FONT COLOR="Red">]</FONT></B></td>
		<td>#Trade_Plan_Title#</td>
		<td>#dateFormat(Created_Date, "mm/dd/yyyy")#</td>
		<td>#name_first# #name_last#</td>
		<td>#dateFormat(Updated_Date, "mm/dd/yyyy")#</td>
		<td>#qGetUser.name_first# #qGetUser.name_last#</td>
	</tr>
</cfoutput>

<cfset numCount =  Evaluate(Ceiling(qGetTradePlanList.recordcount / MaxRows)) />
<cfset nextCount =  Evaluate(StartRow + MaxRows) />
<cfset prevCount =  Evaluate(StartRow - MaxRows) />
<cfset linkCount =  1 />

</table>

<cfif qGetTradePlanList.recordcount gt maxRows>
<table>
	<tr>
		<td>
			<cfif maxrows lt startrow>
				<a STYLE="font-size: 16px; cursor:pointer;" TITLE="Previous page..." href="index.cfm?action=list&startrow=<cfoutput>#prevCount#</cfoutput>"><img src="../../Images/previous.gif" align="middle" border="0"></a>
			</cfif>
		</td>
		<cfloop index="index" from="1" to="#numCount#">
		<td>
			<cfoutput>
				<cfif linkCount eq startRow>
					<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
					<B><FONT color="FF0000" SIZE="3">[</FONT>#index#<FONT color="FF0000" SIZE="3">]</FONT></B>
					</div>
				<cfelse>
					<a STYLE="font-size: 12px; cursor:pointer;" href="index.cfm?action=list&startrow=#linkCount#">#index#</a>
				</cfif>
				
			</cfoutput>
		</td>
			<cfset linkCount = linkCount + maxRows />
		</cfloop>
		<td>
			<cfif (startrow + maxrows) lte qGetTradePlanList.recordcount>
				<a STYLE="font-size: 16px; cursor:pointer;" TITLE="Next page..." href="index.cfm?action=list&startrow=<cfoutput>#nextCount#</cfoutput>"><img src="../../Images/next.gif" align="middle" border="0"></a>
			</cfif>	
		</td>
	</tr>
</table>
</cfif>
</body>
</html>