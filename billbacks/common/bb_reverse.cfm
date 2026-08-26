<!DOCTYPE HTML>
<html>
<cfparam name="URL.BBID" default="">
<cfparam name="URL.ManualVoid" default="0">

<head>
<script>
function closeWin(){
	/* reload the opener page to get the "Voided By" option in blue with mouse over info */
	window.opener.location.reload();
	window.close();	
}
</script>
</head>

<cfset BBManager = CreateObject("component", "components.Billback.BillbackManager") />
<cfset qAssociatedDeductionForBillback = BBManager.getAssociatedDeductionForBillback(URL.BBID)>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<body>
<!--- When this popup opens - 
if there is an associated deduction for the billback, show the details below.
--->
<cfif URL.ManualVoid eq 0 AND qAssociatedDeductionForBillback.RecordCount GT 0>

<cfif (appSettings.get_Setting('BB_Manual_VOID_Detach_DD') eq '1')>
		<div>On "Manual void", the following deduction will be unassociated from this billback and the deduction will be reopened.</div>
<cfelse>
		<div>On "Manual void", the following deductions will remain attached to this Billback</div>
</cfif>
		<br />

		<table width="50%" border="1" cellspacing="0" cellpadding="0">
			<tr>
				<td><b>Deduction</b></td>
				<td><b>Reference</b></td>
				<td><b>Amount</b></td>
				<td><b>Date</b></td>
			</tr>
			<cfoutput>
			<tr>
				<td>#qAssociatedDeductionForBillback.DD_DedId#</td>
				<td>#qAssociatedDeductionForBillback.DD_Reference#</td>
				<td>#qAssociatedDeductionForBillback.DD_Amount#</td>
				<td>#qAssociatedDeductionForBillback.DD_Date#</td>
			</tr>
			</cfoutput>
		</table>

		<br />

		<div>
		<cfoutput>
		To continue, please click on the "continue with Manual Void" link.
		<a href="bb_reverse.cfm?BBID=#BBID#&ManualVoid=1">#application.util.string.actionLinkFormat("continue with Manual Void")#</a>

		<br/><br/>

		To cancel "Manual Void", click on the "close window" link.
		<a onClick="window.close()">#application.util.string.actionLinkFormat("close window")#</a>
		</cfoutput>
		</div>
<cfelse>
<!--- When there is no associated deduction for the billback OR when a user clicks on "continue with Manual Void" on this popup (when there
is an associated deduction)
--->
	<cfset BBManager.setBillbackToApprovedVoid(URL.BBID)>
<script>
closeWin();
</script>
</cfif>

</body>
</html>