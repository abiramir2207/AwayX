<cfparam name="form.Last_Date_To_Claim" default="0" />
<cfparam name="form.Auto_Billback_Approval" default="0" />
<cfset appSettings = application.appSettingsGet />
<cfinclude template="/get_access_profile.cfm">

<!---Can they approve anything?--->

<cfif Get_Profile_Settings.BB_Approve GT 0>

<cfif IsDefined("url.BBID")>
	<CFSET Billback_ID=URL.BBID>
<cfelseif IsDefined("Form.BBID")>
	<CFSET Billback_ID= Form.BBID>
<cfelse>
	<cfset Billback_ID = "">
</cfif>

<!---If the billback has been approved, go to payment page--->
<cfquery name="IsApproved" datasource="#application.datasource#">
	SELECT 	Billback.Billback_Status_ID, 
			Billback.Billback_Payee_Type_ID, 
			Billback.Auto_Billback,
			Billback.BB_Modify_Agree
	FROM 	Billback
	WHERE 	Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<!---Redirect to payment page--->
<cfif IsApproved.Billback_Status_ID GT 2>
	<cflocation url="payment_display.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
</cfif>


<CFSET InfoBar_BBID = Billback_ID>
<cfinclude template="/billbacks/capture/billback_load_infobar.cfm">

<html>
<head>
	<title>Billback Approval</title>
	<cfinclude template="/billbacks/capture/iframe_style.cfm">
</head>

<!------
<script>
	parent.window.Navigate_To_Tab_Location = 0;
	parent.window.menuTabObject[0].fireEvent("onclick")
	parent.window.Navigate_To_Tab_Location = 1;
</script>
------->

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<cfmodule template="/customTags/include.cfm" file_to_include="/billbacks/common/common_js_functions.js, /Script/javascript/dhtml.js"/>
<SCRIPT LANGUAGE="JavaSCript">
	function submitForm(thisobj)
	{
		//check to see if this is beyond the last date to claim
		var lastDTClm = getParentObject(thisobj, 'form').Last_Date_To_Claim.value;

		if(lastDTClm == '1')
		{
			if(confirm("Billback is beyond the last date to claim for some programs. Do you want to continue?"))
			{
				getParentObject(thisobj, 'form').submit();
			}
		}
		else
		{
			getParentObject(thisobj, 'form').submit();
		}
		return false;
	}
</SCRIPT>



<!--- Display The Appropriate Status --->
<CFSET StatusDisplay_CELLSPACING	= 4>
<CFSET StatusDisplay_CELLPADDING	= 0>
<CFSET StatusDisplay_FONTCOLOR		= "white">
<CFSET StatusDisplay_CELLBGCOLOR	= "green">

<CFSET Program_Is_A_Revision 			= 0>
<CFSET ISPROGRAMTEMPLATEAVAILABLE 		= 1>
<CFSEt DisAllowAccessBasedOnPosition 	= 0>

	<cfquery name="UnLockOtherBillbacksLockedByMe" datasource="#Application.Datasource#">
		UPDATE	Billback_Allied
		SET 
			BB_Is_Locked = 0
		WHERE 
			BB_Is_Locked			=	1
			AND
			BB_Locked_By_User_ID	= <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			<CFIF LEN(trim(Billback_ID)) GT 0 AND Billback_ID NEQ 0>
				AND
				Billback_ID <> <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFIF>
			AND BB_Locked_By_Match_Central = 0	
	</cfquery>

	<cfquery name="GetLockStatus" datasource="#Application.Datasource#">
		SELECT BB_Is_Locked,BB_Locked_By_User_ID
		FROM  
			Billback_Allied
		WHERE 
			Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	
	<CFIF GetLockStatus.BB_Is_Locked EQ 1>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 0>
	<CFELSE>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 1>
	</CFIF>
	
	<CFIF GetLockStatus.BB_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 1>
	</CFIF>
<style>
	.paymentTD TD
	{
		border-bottom:2px solid #C2DFF7;
	}
	.ErrorMessage TD
	{
		color: red;
		font-weight: bold;
		border:none;
	}
	.ErrorMessage
	{
		color: red;
		font-weight: bold;
		border:none;
	}
</style>

<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	
	#header 
		{
			font-size: 12px;
		}

	#cellLabel
		{
			<!--- font-family:Arial; --->
			font-size: 11px;
			font-weight: bold;
			vertical-align : top;
		}

	#dataStyle
		{
			font-size: 11px;
		}
		
	TD
		{
			font-family:Arial;
		}	
	HR
		{
			color: Navy;
		}
		
	.LeftRightBorder
	{
		border-left:solid #93BEE2 1px;
		border-right:solid #93BEE2 1px;
		border-top:solid #93BEE2 1px;
		font-size : 10px;
	}
	TABLE.LeftRightBorder TD	
	{
		border-bottom:solid #93BEE2 1px; font-size : 10px;
	}	
</style>

<cfquery name="GetRealBBAmount" datasource="#application.datasource#">
SELECT CAST(BB_Amount As Decimal(18,2)) As BB_Amount
FROM Billback
WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<!---Gets Billback Amount from Database--->
<cfset BillbackTotal = GetRealBBAmount.BB_Amount>
<cfset ExpectedTotal = 0>

<!--- There are queries --->
<cfinclude template="/billbacks/approval/inc_expected_total.cfm">

<!---Add Growth Amounts--->

<cfquery name="GrowthTotal" datasource="#application.datasource#">
SELECT 	Round(ISNull(Sum(Expected_Amount), 0), 2) AS Expected_Amount
FROM 	Billback_Program	
	INNER JOIN BB_Growth_Program
	ON
	(
		(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND
		(BB_Growth_Program.Deleted = 0)
	)	

WHERE Billback_Program.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
AND Billback_Program.Deleted = 0
AND Exists
( 	SELECT Billback_Program.Billback_Program_ID
	FROM Billback_Program
	WHERE (BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
	AND	(BB_Growth_Program.Deleted = 0)
)
</cfquery>


<cfoutput>
<cfif GrowthTotal.Recordcount GT 0>
<cfset ExpectedTotal = ExpectedTotal + GrowthTotal.Expected_Amount>
</cfif>

</cfoutput>

<!---Add Lump Sum Totals--->

<cfquery name="GetLSTotals" datasource="#application.datasource#">
SELECT 	Round(ISNull(Sum(LS_Expected_Amount), 0), 2) AS LS_Expected_Amount
FROM BB_Lump_Sums	
WHERE BB_Lump_Sums.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
AND BB_Lump_Sums.Deleted = 0
AND Exists
(
	SELECT  Billback_Program_Lumpsum_Component.Billback_Program_Lumpsum_Component_ID
	FROM	Billback_Program_Lumpsum_Component
	WHERE
	Billback_Program_Lumpsum_Component.Billback_Program_ID = BB_Lump_Sums.Billback_Program_ID
	AND
	Billback_Program_Lumpsum_Component.Deleted = 0
	AND
	(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
	AND
	(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
	AND
	(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
	AND
	(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
)
</cfquery>
	<cfset ExpectedTotal = ExpectedTotal + GetLSTotals.LS_Expected_Amount>
<html>
<head><title>Make Payment Selection</title></head>
<body>

<cfoutput>

<cfquery name="qIsCritical" datasource="#application.datasource#">
SELECT BB_PNF, BB_UP, Scheduled_Auto_BB
FROM Billback
WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>
<!--- 
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||		For Auto BB, deviations are not run...the expected total will come from the sum									|||||||||||||||
||||||||||||||||		of BB_rates in the BB_Product Table.  The Billback Total is the original BB_Amount from the BillBack Table		|||||||||||||||
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| --->
<cfif qIsCritical.Scheduled_Auto_BB>
			<CFQUERY NAME="getRateInfo" DATASOURCE="#Application.Datasource#">
				SELECT 	
							sum(cast(BB_Rate as decimal(18,2)))) as bb_rate
				FROM 		Billback_Product 
				INNER JOIN 	Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID 
				WHERE 		Billback_Product.Billback_ID = '#Billback_ID#' AND
							Billback_Product.Deleted = 0 AND
							--Billback_Product_Detail.BB_Product_Type_ID != 10 AND
							Billback_Product_Detail.Deleted = 0 
			</CFQUERY>

<cfset ExpectedTotal = getRateInfo.bb_rate>



</cfif>
<cfset IsCritical = StructNew() />
<cfset IsCritical.BB_PNF = qIsCritical.BB_PNF />
<cfset IsCritical.BB_UP = qIsCritical.BB_UP />
<cfset IsCritical.BB_ALTERNATEPAYEE = 0 />

<cfif IsCritical.BB_UP>
	<cfif IsApproved.Billback_Payee_Type_ID EQ 4><!------ Check if payee is other ----->
		<cfset Get_Dist_Info = CreateObject("component", "components.billback.BillbackDeviationManager").getBillbackDistributor(Billback_ID, 4) />
		<cfif Get_Dist_Info.BSA_Foodservice_Customers_ID NEQ ""><!------ Is a distributor is associated, it is no longer critical in this page ----->
			<cfset IsCritical.BB_ALTERNATEPAYEE = 1 />
		</cfif>
	</cfif>
</cfif>

<CFSET SHOW_BILLBACK_PAY 	= 0>
<CFSET SHOW_EXPECTED_PAY 	= 0>
<CFSET SHOW_NONE_PAY 		= 0>
<CFSET SHOW_DETAILED_PAY 	= 0>
<CFSET SHOW_CONTINUE		= 0>

<CFSET SHOW_BILLBACK_MSG 	= "">
<CFSET SHOW_EXPECTED_MSG 	= "">
<CFSET SHOW_DETAILED_MSG 	= "">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
	<p></p>

<CFSET Approve_Tot_Amount = Get_Profile_Settings.BB_Tot_Approve_Amount>
		
<CFSET IsBBTot_In_Range = 0>
<CFSET ISExpected_In_Range = 0>

<CFIF Approve_Tot_Amount NEQ "*">
	<CFIF BillbackTotal LTE Approve_Tot_Amount>
		<CFSET IsBBTot_In_Range = 1>
	</CFIF>
	<CFIF ExpectedTotal LTE Approve_Tot_Amount>
		<CFSET ISExpected_In_Range = 1>
	</CFIF>
<CFELSE>
	<CFSET IsBBTot_In_Range = 1>
	<CFSET ISExpected_In_Range = 1>
</CFIF>


<cfif IsCritical.BB_PNF IS 0 AND ISCritical.BB_UP IS 0>
<!------ If not Critical ----->

	<CFSET SHOW_BILLBACK_PAY = 1>
	
	<CFSET SHOW_EXPECTED_PAY = 1>
	
	<CFSET SHOW_DETAILED_PAY = 1>
		
<cfelse>
<!------ If Critical ----->
	<div align="center" class="ErrorMessage">
		This billback
		<!---Both are wrong--->
		<Cfif IsCritical.BB_PNF IS 1 AND IsCritical.BB_UP IS 1> 
		 	does not have a known payee and has unknown program(s) 
		</CFIF> 
		<!---Payee Not found--->
		<cfif IsCritical.BB_PNF IS 0 AND IsCritical.BB_UP IS 1>
			does not have a known payee
		</cfif>
		<!---Payee Not found--->
		<cfif IsCritical.BB_PNF IS 1 AND IsCritical.BB_UP IS 0>
			has unknown program(s)
		</cfif>
	</div>
	
	<cfif Get_Profile_Settings.BB_Approve_Critical IS 0>
		<br>
		<div align="center" class="ErrorMessage">
		You do not have permission to approve a billback with a critical deviation. 
		<br>Please contact an administrator.
		</div>
	
	<cfelse>
		
		<CFSET SHOW_BILLBACK_PAY = 1>
			
		<cfif ExpectedTotal LT BillbackTotal>
			<cfif ExpectedTotal GT 0>
				<CFSET SHOW_EXPECTED_PAY 	= 1>			
			<cfelse>
				<!---Expected amount is negative--->			
				<CFSET SHOW_NONE_PAY 		= 1>
			</cfif>
		</cfif>
		
		<cfif IsCritical.BB_UP IS 0 OR IsCritical.BB_ALTERNATEPAYEE EQ 1>
			<CFSET SHOW_DETAILED_PAY = 1>			
		</cfif>
		</table>		
	<!---Has permissions to approve critical--->
	</cfif>
<!---Critical--->
</cfif>

<!---- BJF: Programs that have been to agreed to, when Modify Agree is on, should not allow users to make decisions
on this page without clicking modify agree. So under those circumstances, lock down everything but approving prior values and disagreeing --->
<cfif appsettings.getBillbackModifyAgree() EQ 1 >

	<cfquery name="HasBeenAgreed" datasource="#application.datasource#">
	SELECT BB_Agreed_Info.Agreed_Amount
	FROM BB_Agreed_Info
	WHERE BB_Agreed_Info.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND BB_Agreed_Info.Deleted = 0
	</cfquery>
	
	<cfif HasBeenAgreed.Recordcount GT 0 AND IsApproved.BB_Modify_Agree EQ 0>
		<!---Hide most choices but add a "Continue" button --->
		<cfset SHOW_BILLBACK_PAY = 0>
		<CFSET SHOW_EXPECTED_PAY = 0>
		<CFSET SHOW_DETAILED_PAY = 0>
		<CFSET SHOW_NONE_PAY 	 = 0>
		<CFSET SHOW_CONTINUE	 = 1>
		
		<!--- Figure out what the last user picked and select that --->
		<CFSET AgreedSelectionType = "">
		<CFSET AgreedAmount = "">
		
		<!--- If the Agreed Amount EQ the Billback Amount, set it to be Billback Amount --->
		<Cfif HasBeenAgreed.Agreed_Amount EQ BillbackTotal>
			<CFSET AgreedSelectionType = "BB">
			<CFSET AgreedAmount =  BillbackTotal>
		<!--- If the Agreed Amount EQ the Expected Amount, set it to be Expected Amount (if BB and expected are smae, this will overwrite the previous select) --->
		<Cfelseif HasBeenAgreed.Agreed_Amount EQ ExpectedTotal>
			<CFSET AgreedSelectionType = "E">
			<CFSET AgreedAmount =  ExpectedTotal>
		<!--- If it's not one of those two, it must be manual --->
		<cfelse>
			<CFSET AgreedSelectionType = "M">
			<CFSET AgreedAmount =  HasBeenAgreed.Agreed_Amount>
		</cfif>
		
	</cfif>
<!--- Checking app setting for modify agree --->
</cfif>

<!--- End modify agree modifications --->

<!---initialize BillbackProgramManager--->
<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
<cfset billbackProgramManager.setBillbackID(Billback_ID) >

<!---check to see if the billback date is greater than the last date to claim for any programs--->
<cfquery name="qGetBillBackPrograms" datasource="#application.datasource#">
	SELECT	Program_ID
	FROM	Billback_Program
	WHERE  	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 	Deleted = 0
</cfquery>
<cfloop query="qGetBillBackPrograms">
	<cfset billbackProgramManager.setBillbackProgramID(Program_ID) >
	<!---check for last date to claim--->
	<cfif billbackProgramManager.getLastDateToClaim().RecordCount>
		<cfset form.Last_Date_To_Claim = 1 />
		<cfbreak />
	</cfif>
</cfloop>

<!---if the billback date is greater than the last date to claim from a program and they don't have rights to approve then don't allow approval--->	
<cfif Get_Profile_Settings.Approve_Last_Date_To_Claim eq 0 and form.Last_Date_To_Claim eq 1>
	<br>
	<div align="center" class="ErrorMessage">
	You do not have permission to approve billbacks that are beyond the last date to claim.<br>
	Billback is beyond the last date to claim for some programs.
	<br>Please contact an administrator.
	</div>
	<CFSET SHOW_BILLBACK_PAY = 0>
	<CFSET SHOW_EXPECTED_PAY = 0>
	<CFSET SHOW_DETAILED_PAY = 0>
</cfif>

</td></tr>

</table>
<script language="javascript">
			function DisagreeBillback(DisagreeFormName) {
			NewWindow("/billbacks/common/BB_Business_Consideration.cfm?MODE=9&ParentFormname="+DisagreeFormName+"&BBID="+eval("document."+DisagreeFormName+".Billback_ID.value"),'BB_BusiConsi','800','600','Yes', 'Yes');
			}
			function DisableDisagreeLink() {
				disableButton("td_disagree_link", true, false);
			}
</script>

<table width="75%" cellpadding="0" cellspacing="0" border="0" align="center">
	<colgroup>
		<col span="1" width="1" align="left"></col>
	</colgroup>	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Billback ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cfif (SHOW_BILLBACK_PAY EQ 1 AND (Get_Profile_Settings.BB_Devgrid_Claimed EQ 1 OR Get_Profile_Settings.BB_Devgrid_Selected EQ 1))>
	<tr>
	<td <CFIF SHOW_EXPECTED_PAY EQ 0 AND SHOW_NONE_PAY EQ 0 AND SHOW_DETAILED_PAY EQ 0>style="Border-Bottom: none"</CFIF>>	
		<form action="payment.cfm" name="BillbackAmountfrm" method="post">
			<input type="hidden" name="Rate_Paid_Type" value="BB">
			<input type="hidden" name="Payment_Amount" value="#BillbackTotal#">
			<input type="hidden" name="E_Amount_Total" value="#ExpectedTotal#">
			<input type="hidden" name="Billback_Amount_Total" value="#BillbackTotal#">
			<input type="hidden" name="Billback_ID" value="#Billback_ID#">
			<input type="hidden" name="Last_Date_To_Claim" value="#trim(form.Last_Date_To_Claim)#">
			<INPUT TYPE="IMAGE" SRC="/Images/Deviations/pay_all.jpg" width="80" height="80" HSPACE="25" ALIGN="absmiddle" TITLE="approve billback amount of #LSCurrencyFormat(BillbackTotal)#">
			<input type="hidden" name="SCHEDULED_AUTO_BB" value="#qIsCritical.Scheduled_Auto_BB#">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="approve billback amount of #LSCurrencyFormat(BillbackTotal)#">
							approve <cfif qIsCritical.Scheduled_Auto_BB>calculated </cfif>billback amount of #LSCurrencyFormat(BillbackTotal)#
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</form>	
	</td>
	</tr>
	</cfif>
	
	
	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Auto BB ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cfif qIsCritical.Scheduled_Auto_BB and trim(ExpectedTotal) neq trim(BillbackTotal)>
	<tr>		
		<td <CFIF SHOW_NONE_PAY EQ 0 AND SHOW_DETAILED_PAY EQ 0>style="Border-Bottom: none"</CFIF>>	
		<form action="payment.cfm" method="post">
			<input type="hidden" name="Rate_Paid_Type" value="E">
			<input type="hidden" name="Payment_Amount" value="#BillbackTotal#">
			<input type="hidden" name="E_Amount_Total" value="#ExpectedTotal#">
			<input type="hidden" name="Billback_Amount_Total" value="#BillbackTotal#">
			<input type="hidden" name="Billback_ID" value="#Billback_ID#">
			<input type="hidden" name="Last_Date_To_Claim" value="#trim(form.Last_Date_To_Claim)#">
			<INPUT TYPE="IMAGE" SRC="/Images/Deviations/pay_expect.jpg" width="80" height="80" HSPACE="25" ALIGN="absmiddle" TITLE="approve expected amount of #LSCurrencyFormat(ExpectedTotal)#">	
			<input type="hidden" name="SCHEDULED_AUTO_BB" value="#qIsCritical.Scheduled_Auto_BB#">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="approve expected amount of #LSCurrencyFormat(ExpectedTotal)#">
							approve adjusted amount of #LSCurrencyFormat(ExpectedTotal)#
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</form>
		</td>
	</tr>	
	</cfif>
	
	
	
	
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Expected ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<cfif (SHOW_EXPECTED_PAY EQ 1 AND (Not qIsCritical.Scheduled_Auto_BB) AND (Get_Profile_Settings.BB_Devgrid_Expected EQ 1 OR Get_Profile_Settings.BB_Devgrid_Selected EQ 1)) >
	<tr>		
		<td <CFIF SHOW_NONE_PAY EQ 0 AND SHOW_DETAILED_PAY EQ 0>style="Border-Bottom: none"</CFIF>>	
		<form action="payment.cfm" method="post" name="frmPayment">
			<input type="hidden" name="Rate_Paid_Type" value="E">
			<input type="hidden" name="Payment_Amount" value="#ExpectedTotal#">
			<input type="hidden" name="E_Amount_Total" value="#ExpectedTotal#">
			<input type="hidden" name="Billback_Amount_Total" value="#BillbackTotal#">
			<input type="hidden" name="Billback_ID" value="#Billback_ID#">
			<input type="hidden" name="Last_Date_To_Claim" value="#trim(form.Last_Date_To_Claim)#">
			<INPUT TYPE="IMAGE" SRC="/Images/Deviations/pay_expect.jpg" width="80" height="80" HSPACE="25" ALIGN="absmiddle" TITLE="approve expected amount of #LSCurrencyFormat(ExpectedTotal)#">	
			<input type="hidden" name="SCHEDULED_AUTO_BB" value="#qIsCritical.Scheduled_Auto_BB#">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="approve expected amount of #LSCurrencyFormat(ExpectedTotal)#">
							approve expected amount of #LSCurrencyFormat(ExpectedTotal)#
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</form>
		</td>
	</tr>	
	<!--- If it is an auto billback, submit the form without user interaction. It should behave as if "approve expected amount 
	of XXX" was clicked. 
	--->
	<script>
	<cfif IsApproved.Auto_Billback eq 1>
		frmPayment.submit();
	</cfif>
	</script>
	</cfif>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// None ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	
	<cfif SHOW_NONE_PAY EQ 1>
	<tr>
		<td <CFIF SHOW_DETAILED_PAY EQ 0>style="Border-Bottom: none"</CFIF>>	
		<form action="payment.cfm" method="post">
			<input type="hidden" name="Rate_Paid_Type" value="None">
			<input type="hidden" name="Payment_Amount" value="0">
			<input type="hidden" name="E_Amount_Total" value="#ExpectedTotal#">
			<input type="hidden" name="Billback_Amount_Total" value="#BillbackTotal#">
			<input type="hidden" name="Billback_ID" value="#Billback_ID#">
			<input type="hidden" name="Last_Date_To_Claim" value="#trim(form.Last_Date_To_Claim)#">
			<INPUT TYPE="IMAGE" SRC="/Images/Deviations/pay_expect.jpg" width="80" height="80" HSPACE="25" ALIGN="absmiddle" TITLE="approve a payment of $0">	
			<input type="hidden" name="SCHEDULED_AUTO_BB" value="#qIsCritical.Scheduled_Auto_BB#">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="approve a payment of $0">
							approve a payment of $0
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</form>
		</td>
	</tr>	
	</cfif>


<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Detail ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	
	<cfif (SHOW_DETAILED_PAY EQ 1 and (Not qIsCritical.Scheduled_Auto_BB) AND  
	(Get_Profile_Settings.BB_Devgrid_Expected EQ 1 OR Get_Profile_Settings.BB_Devgrid_ELT EQ 1 OR Get_Profile_Settings.BB_Devgrid_Claimed EQ 1 OR Get_Profile_Settings.BB_Devgrid_Selected EQ 1))>
	<tr>
		<td style="border:none;">
		<form action="/Billbacks/Deviation/Deviation.cfm" method="post">
			<input type="hidden" name="BBID" value="#billback_ID#">
			<input type="hidden" name="E_Amount_Total" value="#ExpectedTotal#">
			<input type="hidden" name="Billback_Amount_Total" value="#BillbackTotal#">
			<input type="hidden" name="Deviation_Show_Expected_Values" value="1">
			<input type="hidden" name="Last_Date_To_Claim" value="#trim(form.Last_Date_To_Claim)#">		
			<INPUT TYPE="IMAGE" SRC="/Images/Deviations/pay_pick.jpg" width="80" height="80" HSPACE="25" ALIGN="absmiddle" TITLE="make detailed decisions on what amounts to approve">	
			<input type="hidden" name="SCHEDULED_AUTO_BB" value="#qIsCritical.Scheduled_Auto_BB#">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="make detailed decisions on what amounts to approve">
						make detailed decisions on what amounts to approve
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</form>
		</td>
	</tr>
	</cfif>

	

	<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Continue ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->	
	<cfif SHOW_CONTINUE EQ 1>
	<tr>
		<td <CFIF SHOW_DETAILED_PAY EQ 0>style="Border-Bottom: none"</CFIF>>	
		<form action="payment.cfm" method="post">
			<input type="hidden" name="Rate_Paid_Type" value="#AgreedSelectionType#">
			<input type="hidden" name="Payment_Amount" value="#AgreedAmount#">
			<input type="hidden" name="E_Amount_Total" value="#ExpectedTotal#">
			<input type="hidden" name="Billback_Amount_Total" value="#BillbackTotal#">
			<input type="hidden" name="Billback_ID" value="#Billback_ID#">
			<input type="hidden" name="Last_Date_To_Claim" value="#trim(form.Last_Date_To_Claim)#">
			<INPUT TYPE="IMAGE" SRC="/Images/Deviations/pay_expect.jpg" width="80" height="80" HSPACE="25" ALIGN="absmiddle" TITLE="approve a payment of $0">	
			<input type="hidden" name="SCHEDULED_AUTO_BB" value="#qIsCritical.Scheduled_Auto_BB#">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="javaScript: return submitForm(this);" TITLE="approve a payment of $0">
							continue
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</form>
		</td>
	</tr>	
	</cfif>	
	
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Disagree ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	<tr>
	<td style="border:none;" id="td_disagree_link">	
		<form name="DisagreeBillbackFrm" method="Post" action="payment.cfm">
			<img src="/Images/Deviations/pay_disagree.jpg" width="80" height="80" vspace="5" hspace="25" align="absmiddle" title="disagree to entire billback">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue">
						<A HREF="##" onClick="DisagreeBillback('DisagreeBillbackFrm');return false;"  TITLE="disagree to entire billback">
							disagree to entire billback
						</A>
				</FONT>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>	
				<input type="hidden" name="Billback_ID" value="#Billback_ID#">
		</form>
	</td>
	</tr>	

</table>

</cfoutput>
</BODY>
</html>
<!---They have no permission to approve anything--->
<cfelse>
<BR><BR><BR>
<CFOUTPUT>
<font color="red" size="2"><div align="Center"><strong>You do not have approval rights to continue.  Click [<A Href="/Billbacks/capture/Billback_Summary.cfm?BBID=#BBID#">here</A>] to return to View Summary.</strong></div></font>
</CFOUTPUT>
</cfif>
<!--- BSD 11544 --->
<script>
 try { window.parent.dyniframesize(); } catch (err) { };
</script>