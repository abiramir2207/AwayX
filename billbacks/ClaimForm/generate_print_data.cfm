<!---
		Name: 			generate_print_data.cfm
		Copyright:		(c) 2013 Blacksmith Applications, Inc.
		Created Date:	05/31/2013
		Created By:		drachala     
		Description:	This file is responsible for printing the One Page Claim Form
--->	
<cfsavecontent variable="ClaimPrintData">
				<cfoutput>
						<center>
							<img src="/images/Lamb_Weston.png" />
						<center>
				
						<br/><br/>
					
						<cfset totalCasesAmount = 0 />
						<cfset totalExtAmount = 0 />
				
						<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
						<html xmlns="http://www.w3.org/1999/xhtml">
							<head>
								<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
								<title>Claim Print</title>
				
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
											#arguments.ProgramNum#<br />
											#arguments.Desc#<br />
											#arguments.effdate#<br />
											#arguments.enddate#<br />
											#arguments.InvNum#<br />
											#arguments.distributor#<br />
											#arguments.shipnum#<br />
											#arguments.dest#<br />
											#arguments.Statetxt#
										</td>
										
										<td>
											#arguments.bsnum#<br />
											#arguments.PayNum#<br />
											#arguments.PayName#<br />
											#arguments.ClaimAmt#<br />
											<br />
											#arguments.Broker#<br />
											#arguments.BrokerNum#<br />
											Purchasing Group:&nbsp;<br />
											Corp PGM:&nbsp;<br />
										</td>
										
										<td>
											#arguments.ClaimDateFromVis#<br />
											#arguments.ClaimDateToVis#<br />
											<br />
											<br />
											<br />
											<br />
											#arguments.deductAutosF#<br />
											#arguments.deductAutos#<br />
											#arguments.Pullback#<br />
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
									<cfif arraylen(arguments.items)>
										<cfset dollarMask = "$,.____)">   
										<cfloop from="1" to=#arraylen(arguments.items)# index="i">
										<!---tally up the total amount--->
										<cfif isNumeric(arguments.items[i].Cases_Claimed)>
											<cfset totalCasesAmount = totalCasesAmount + arguments.items[i].Cases_Claimed />
										</cfif>
										<cfif isNumeric(arguments.items[i].Adj_Extended_Amt)>
											<cfset totalExtAmount = totalExtAmount + arguments.items[i].Adj_Extended_Amt />
										</cfif>
										<tr>
											<td>#arguments.items[i].Program_ItemId#</td>
											<td>#arguments.items[i].Item_Desc#</td>
											<td>#arguments.items[i].Item_Case_Weight#</td>
											<td>#arguments.items[i].Cases_Claimed#</td>
											<td>#arguments.items[i].Net_Lbs_Claimed#</td>
											<td>#arguments.items[i].STD#</td>
											<td><cfif isNumeric(arguments.items[i].Promo_rate)>#numberFormat(arguments.items[i].Promo_rate, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Invoice_Price)>#numberFormat(arguments.items[i].Invoice_Price, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Promo_Amt)>#numberFormat(arguments.items[i].Promo_Amt, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Price_List)>#numberFormat(arguments.items[i].Price_List, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Less_Corp_Allow)>#numberFormat(arguments.items[i].Less_Corp_Allow, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Less_Local_Allow)>#numberFormat(arguments.items[i].Less_Local_Allow, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Net_Promo_Amt)>#numberFormat(arguments.items[i].Net_Promo_Amt, dollarMask)#</cfif></td>
											<td><cfif isNumeric(arguments.items[i].Adj_Extended_Amt)>#dollarFormat(arguments.items[i].Adj_Extended_Amt)#</cfif></td>
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
												Extended Amount Total:&nbsp;#totalExtAmount#<br />
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
</cfsavecontent>
<cfset printPath="#Application.Doc_Path#\Temp_Files\EmailFaxPrint\#request.AccessStructure.User_ID#.html">
<cffile action="write" file="#printPath#" output="#ClaimPrintData#">