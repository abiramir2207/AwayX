<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>
<!--- Dev Note: Milan;11363- There used to be a "Payment_Notes" fields recording the notes of the approver, but now those notes
			are a part of business_considerations and so that field is not being used anymore --->
<body>
<CFPARAM NAME="FORM.Submitted" DEFAULT="0">

<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />

<CFIF FORM.Submitted EQ 0>

	<cfset useLakebaseForgetBBStats = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetBBStats>
	<cftry>
		<cfset getBBStats = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#BBID#",
				"select" = "bb_amount,negative_billback"
			}), "bb_amount,negative_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBBStats = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBBStats>
<cfquery name="getBBStats" datasource="#application.datasource#">
		SELECT    BB_Amount,Negative_Billback
		FROM      Billback 
		WHERE     Billback_ID = '#BBID#'
	</cfquery>
</cfif>
	
	<cfset variables.itemized_total = CreateObject("component", "components.billback.BillbackManager").getBillbackItemizedAmount(BBID) />
	<cfset BB_Total_Amount = getBBStats.BB_Amount>
	<CFIF len(trim(BB_Total_Amount)) EQ 0>
		<cfset BB_Total_Amount = 0>
	</CFIF>
	
	<cfif trim(itemized_total) NEQ trim(BB_Total_Amount) OR trim(itemized_total) EQ "" OR trim(itemized_total) EQ "0">
	<BR><BR><BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD ALIGN ="Center"><FONT COLOR="Red" SIZE="2"><B>Claim Summary Amount is not equal to the Itemized Total.</B></FONT>
			
			</TD>
		</TR>
		</TABLE>
		<CFABORT>
	</cfif>
	
	<cfinclude template="/get_access_profile.cfm">
	
	<CFIF Get_Profile_Settings.BB_Approve GT 0>

	<cfset CheckTemplateApprovalRights = BBProgramManager.getTemplateApprovalRights(Billback_ID)>
	
	<cfset useLakebaseForGetFA_AppSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetFA_AppSetting>
	<cftry>
		<cfset GetFA_AppSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "forbidallowprofilesintemplates"
			}), "forbidallowprofilesintemplates"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFA_AppSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFA_AppSetting>
<CFQUERY NAME="GetFA_AppSetting" DATASOURCE="#Application.Datasource#">
		SELECT ForbidAllowProfilesInTemplates FROM _Application_Settings
	</CFQUERY>
</cfif>
	
	<CFSET TemplateApprovalRight = 0>
	
	<CFIF GetFA_AppSetting.ForbidAllowProfilesInTemplates EQ 1 AND CheckTemplateApprovalRights.RecordCount EQ 0>
		<CFSET TemplateApprovalRight = 1>
	<CFELSEIF GetFA_AppSetting.ForbidAllowProfilesInTemplates EQ 0 AND CheckTemplateApprovalRights.RecordCount GT 0>
		<CFSET TemplateApprovalRight = 1>
	</CFIF>
	
	<BR><BR>
	<form action="Approve_Negative_BB.cfm" method="post" name="MakePayment" ONSUBMIT="javaScript: return checkApprovedAmount(this);">
	<INPUT TYPE="Hidden" NAME="Billback_ID" <CFOUTPUT>VALUE="#URL.BBID#"</CFOUTPUT>>
	<INPUT TYPE="Hidden" NAME="Submitted" VALUE="1">
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD ALIGN ="Center"><B><FONT COLOR="NAVY" SIZE="2">Negative Billback Approval</FONT></B><BR><BR></TD>
	</TR>
	<CFIF TemplateApprovalRight EQ 1>
		<tr>		
			<td align="Center"><input type="button" value="Approve this Billback" onclick="ApprovalProcess()" style="background: ffe4b5; border-right: solid navy 1px; border-left: solid navy 1px; border-top: solid navy 1px; border-bottom: solid navy 1px;"></td>		
		</tr>
	<CFELSE>			
		<TR>
			<TD align="Center"><B><FONT COLOR="Red" SIZE="2">You don't have approval rights for this program template.</FONT></B></TD>
		</TR>
	</CFIF>
	</TABLE>
	<CFELSE>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="2">You don't have approval rights.</FONT></B></TD>
		</TR>
	</TABLE>
	</CFIF>
<CFELSE>

<cfquery name="BBDetails" datasource="#application.datasource#">
	SELECT * FROM Billback WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>
<!---Update all the Approved stuff--->
<cfquery name="UpdateOrInsert" datasource="#application.datasource#">
SELECT * 
FROM BB_Approved
WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfif UpdateOrInsert.Recordcount IS 0>
<cfquery name="MarkApproved" datasource="#application.datasource#">
INSERT INTO BB_Approved
	(
	Billback_ID,
	Paid_Amount,
	BB_Amount,
	Date_Approved,
	User_Approved, 	
	Approved_Amt_Type
	)
	VALUES
	(
	<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,	
	#BBDetails.BB_Amount#,
	#BBDetails.BB_Amount#,
	GetDate(),
	<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
	1
	)
</cfquery>
<cfelse>
	<cfquery name="MarkApproved" datasource="#application.datasource#">
	UPDATE BB_Approved
	SET Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
		Paid_Amount = #BBDetails.BB_Amount#,				
		BB_Amount = #BBDetails.BB_Amount#,
		Date_Approved = GetDate(),
		User_Approved = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
	WHERE BB_Approved_ID = <cfqueryparam value="#UpdateOrInsert.BB_Approved_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery> 
<!---Update instead of insert--->
</cfif>

<cfset useLakebaseForUpdateStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"billback_status_id" = "3"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateStatus>
<cfquery name="UpdateStatus" datasource="#application.datasource#">
	UPDATE Billback SET Billback_Status_ID = 3 WHERE Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>

<!--- simulate button click --->
<cfset local_bbid = Billback_ID>
<cfinclude template="/billbacks/capture/bb_menu_stats.cfm">
<SCRIPT LANGUAGE="JavaScript">
	window.parent.tabClick('payment');
</SCRIPT>

<CFLOCATION URL="/billbacks/approval/Payment_display.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
</CFIF>


<SCRIPT>
<!--- Dev Note: Milan;11363 - Now the approval process has to go through business considerations --->
function ApprovalProcess() {
NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=10&EDIT=1&Formname=MakePayment&BBID='+document.MakePayment.Billback_ID.value,'BB_BusiConsi','800','600','Yes', 'Yes');
return false;
}
function checkApprovedAmount()
{
	var bOK = false;
	var NegBB = "<CFOUTPUT>#getBBStats.Negative_Billback#</CFOUTPUT>"
	var Approving_Amount = "<CFOUTPUT>#getBBStats.BB_Amount#</CFOUTPUT>";
	Approving_Amount = parseFloat(Approving_Amount);	
	if (NegBB == 1)
	{
		if(Approving_Amount < 0)
		{
			bOK = true;
		}
		if(!bOK)
		{
			alert("Amount to be paid : $" + formatWithComma(formatToDeciamalPlaces(Approving_Amount, 2), 3) + " should be less than zero");
		}
	}
	else
	{
		alert("This billback is not a Negative Billback.");	
	}
	return bOK;		
}
</SCRIPT>
</body>
</html>
