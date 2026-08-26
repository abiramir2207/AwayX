<!---
Name: 			claim_form_email.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	07/17/2009
Created By:		Tim Ford     
Description:	This file is responsible for generating the email attachment for the One Page Claim Form
--->
<cfoutput>
	<!---////////////////////////////////////////////////////////////////////////////////////////////////////
		Tim Ford - 04/30/2013: Label 37419 - ONE PAGE CLAIM FORM -- PDF OUTPUT -- EXTENDED CASES & $ DOUBLING
		Removed param tags and used set for totalCasesAmount and totalExtAmount variables.
		The param tags were causing the totals to double
	//////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<!---
	<cfparam name="totalCasesAmount" 	default="0" />
	<cfparam name="totalExtAmount" 		default="0" />
	--->
	<cfset totalCasesAmount = 0 />
	<cfset totalExtAmount = 0 />

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<title>Claim Email</title>

			<style>
				BODY, TD, BLOCKQUOTE, .normal
				{
					font-family : Arial;
					font-size : 8pt;
					font-weight:500
					color : Black;
				}
			</style>
		</head>

		<body>

			<table width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<td>
						LW Program No:&nbsp;#variables.qGetClaim.Program_Number#<br />
						Description:&nbsp;#variables.qGetClaim.Desc_Number#<br />
						Program Eff Date:&nbsp;#dateFormat(variables.qGetClaim.BeginDate, "mm/dd/yyyy")#<br />
						Program End Date:&nbsp;#dateFormat(variables.qGetClaim.EndDate, "mm/dd/yyyy")#<br />
						Inv/Ref No:&nbsp;#variables.qGetClaimForm.Inv_Ref_Num#<br />
						Distributor:&nbsp;#variables.qGetClaim.Cust_Name#<br />
						Ship-To No:&nbsp;#variables.qGetClaim.Ship_Num#<br />
						Destination:&nbsp;#variables.qGetClaim.Address#<br />
						St:&nbsp;#variables.qGetClaim.State#
					</td>
					
					<td>
						BA Program No:&nbsp;#variables.qGetClaim.Ba_Id#<br />
						Pay To No:&nbsp;#variables.qGetClaim.PayTo_Num#<br />
						Pay To Name:&nbsp;#variables.qGetClaim.PayTo_Name#<br />
						Amount:&nbsp;#dollarFormat(variables.qGetClaimForm.Claim_Amt)#<br />
						<br />
						Broker:&nbsp;#variables.qGetClaim.Broker_Name#<br />
						Broker No:&nbsp;#variables.qGetClaim.Broker_Id#<br />
						Purchasing Group:&nbsp;<br />
						Corp PGM:&nbsp;<br />
					</td>
					
					<td>
						From Date:&nbsp;#dateFormat(variables.qGetClaimForm.Claim_Date_From, "mm/dd/yyyy")#<br />
						To Date:&nbsp;#dateFormat(variables.qGetClaimForm.Claim_Date_To, "mm/dd/yyyy")#<br />
						<br />
						<br />
						<br />
						<br />
						Deduct Autos From F:&nbsp;#variables.qGetClaim.Autos_Fixed#<br />
						Deduct Autos?:&nbsp;#variables.qGetClaim.Autos_Deduct#<br />
						Auto Pullback:&nbsp;#variables.qGetClaim.Autos_Pullback#<br />
					</td>
				</tr>
			</table>
			<p>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr style="font-weight:900">
					<td>CAT NO.</td>
					<td>Desc</td>
					<td>Net Wt</td>
					<td>## Cases Claimed</td>
					<td>Net Lbs Claimed</td>
					<td>STD</td>
					<td>Rebate Rate</td>
					<td>Base Price</td>
					<td>(If Fixed) Promo Amt</td>
					<td>Pricelist</td>
					<td>Less Corp Allow</td>
					<td>Less Local Allow</td>
					<td>Promo Amt</td>
					<td>Adjusted Ext Amt</td>
				</tr>
				<cfif variables.qGetClaimFormDetails.RecordCount>
					<cfset dollarMask = "$,.____)">   <!--- 33438 - allows 4 decimal places --->
					<cfloop query="variables.qGetClaimFormDetails">
					<!---tally up the total amount--->
					<cfif isNumeric(Cases_Claimed)>
						<cfset totalCasesAmount = totalCasesAmount + Cases_Claimed />
					</cfif>
					<cfif isNumeric(Adj_Extended_Amt)>
						<cfset totalExtAmount = totalExtAmount + Adj_Extended_Amt />
					</cfif>
					<tr>
						<td>#Program_ItemId#</td>
						<td>#Item_Desc#</td>
						<td>#Item_Case_Weight#</td>
						<td>#Cases_Claimed#</td>
						<td>#Net_Lbs_Claimed#</td>
						<td>#STD#</td>
						<td><cfif isNumeric(Promo_rate)>#numberFormat(Promo_rate, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Invoice_Price)>#numberFormat(Invoice_Price, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Promo_Amt)>#numberFormat(Promo_Amt, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Price_List)>#numberFormat(Price_List, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Less_Corp_Allow)>#numberFormat(Less_Corp_Allow, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Less_Local_Allow)>#numberFormat(Less_Local_Allow, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Net_Promo_Amt)>#numberFormat(Net_Promo_Amt, dollarMask)#</cfif></td>
						<td><cfif isNumeric(Adj_Extended_Amt)>#dollarFormat(Adj_Extended_Amt)#</cfif></td>
					</tr>
					</cfloop>
				<cfelse>
					<tr>
						<td colspan="100%">
							No Records
						</td>
					</tr>
				</cfif>
			</table>
			<p>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr>
					<td>
						Total ## Cases Claimed:&nbsp;#totalCasesAmount#<br />
						Extended Amount Total:&nbsp;#dollarFormat(totalExtAmount)#<br />
						<br />
						*STD; M=%, P=CENTS P/LB, C=CENTS P/CS, F=FIXEDPRICE PER P/LB<br />
			    		** CYCLE: PAYMENT CYCLE M=MONTHLY, Q=QUARTERLY;<br />
			   		 	*** CORPORATE/LOCAL SME'S DEDUCTED FROM BILLBACKS FOR DEVIATED CONTRACTED BID/PRICING<br />
			   		 	BASE PRICE: Reflects pricing effective when form was printed (date above) and is exclusive of promotions<br />
			    		PRICELISTS: Allowances do not apply to items invoiced with a pricelist unless the program identifies a pricelist.<br />
			   		 	Claims will not be processed w/o proof of performance. Claims over 1 year old will not be honored.<br />
					</td>
				</tr>
			</table>

		</body>
	</html>
</cfoutput>
