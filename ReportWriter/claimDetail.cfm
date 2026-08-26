<cfparam name="claimDetailTitle" 	default="Claim Detail Report">
<cfparam name="claimDetailHeader" 	default="Claim Detail Report">
<cfparam name="divHt" 				default="275">
<cfparam name="divlen" 				default="860">
<cfparam name="claimDetailPage" 	default="claimDetail.cfm">
<cfparam name="url.requestFormat" default="html" >
<cfset isTextFormat = false >
<cfif isDefined("url.requestFormat") and url.requestFormat EQ "txt">
	<cfset isTextFormat = true >
	<cfsetting enablecfoutputonly="Yes" showdebugoutput="no">
</cfif>
<LINK Rel = "stylesheet" Type="text/css" media="screen" HREF = "/reportWriter/claimReport.css">
<LINK Rel = "stylesheet" Type="text/css" media="print"	HREF = "/reportWriter/claimReportPrint.css">
<html>
<head>
	<title>Claim Detail Report</title>
	<meta http-equiv="Content-Type" content="text/html;">
</head>
<cfif isTextFormat EQ true >
	<cfset TabChar = Chr(9)>
	<cfset NewLine = Chr(13) & Chr(10)>
	<cfset textDelimiter = "|" />
</cfif>
<cfif Not isDefined("url.billback_id")>
	<cfset billback_id = '1a9dadb3-d97e-42e0-a4ed-58388faec34f' >
<cfelse>
	<cfset billback_id = url.billback_id >
</cfif>
<cfif isDefined("url.end_user") and LCase(trim(url.end_user)) NEQ 'unknown'>
	<cfset this_end_user = url.end_user >
<cfelse>
	<cfset this_end_user = "" >
</cfif>

<cfif isDefined("url.program_id")><cfset this_program_id = url.program_id><cfelse><cfset this_program_id =""></cfif>
<CFSET claimHandle = CreateObject("component", "components.reports.claim").init(billback_id,this_program_id,this_end_user) >
<cfset program_id = claimHandle.getProgramID() />

<cfif program_id EQ "">
	<div align="center" class="error">No program associated with the selected claim.</div><cfabort>
</cfif>
<body>
	<div id="stuff" class="page">
		<div align="center" class="title"><cfoutput><cfif isTextFormat EQ false >#claimDetailHeader#<cfelse>#claimDetailHeader##NewLine##NewLine#</cfif></cfoutput></div><BR>
		<div id="claimHeader">
			<table border="0" cellpadding="1" cellspacing="1" width="100%">
				<tr>
					<td class="header" >
						<cfoutput><cfif isTextFormat EQ false >Operator: #claimHandle.getClaimEndUser()#<cfelse>Operator: #claimHandle.getClaimEndUser()##TabChar#</cfif></cfoutput>
					</td>
					<td class="header" >
						<cfoutput><cfif isTextFormat EQ false >Operator Name: #claimHandle.getClaimUserName()#<cfelse>Operator Name: #claimHandle.getClaimUserName()##TabChar#</cfif></cfoutput>
					</td>
					<td class="header" >
						<cfoutput><cfif isTextFormat EQ false >Distributor Acct: #claimHandle.getClaimCust()#<cfelse>Distributor Acct: #claimHandle.getClaimCust()##TabChar#</cfif></cfoutput>
					</td>
					<td class="header" >
						<cfoutput><cfif isTextFormat EQ false >Vendor ID: #claimHandle.getClaimVendorID()#<cfelse>Vendor ID: #claimHandle.getClaimVendorID()##TabChar#</cfif></cfoutput>
					</td>
				</tr>
				<cfif isTextFormat NEQ false >
					<cfoutput>#NewLine##NewLine#</cfoutput>
				</cfif>
			</table>
		</div>
		<BR>
		<!--- get claim items information --->
		<cfset qClaimItems = claimHandle.getClaimItemsInfo() />
		<cfparam name="claimItemCount" default="1">
		<cfset useExistingClaimHandle = 1 />
		<cfinclude template="claimDetailSummary.cfm">
		<hr width="95%" color="666666" align="left">

		<cfif isTextFormat NEQ false >
			<cfoutput><cfloop from="1" to="127" step="1" index="i">-</cfloop>#NewLine#</cfoutput>
		</cfif>
		<!----- comments ---->
		<!--- item list ---->
		<div id="divClaimDetail">
			<table border="0" cellpadding="1" cellspacing="0" width="95%" style="margin-left:0.5cm">
				<!--- header information ---->
				<tr class="claimHeader">
					<td>
						<cfif isTextFormat EQ false >
							<cfoutput>Line</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(5,"Line")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td>
						<cfif isTextFormat EQ false >
							<cfoutput>Item</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(12,"Item")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td>
						<cfif isTextFormat EQ false >
							<cfoutput>Description</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(25,"Description")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td>
						<cfif isTextFormat EQ false >
							<cfoutput>Program</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(12,"Program")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td align="center">
						<cfif isTextFormat EQ false >
							<cfoutput>Units</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(8,"Units")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td align="center">
						<cfif isTextFormat EQ false >
							<cfoutput>Rebate</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(10,"Rebate")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td align="center">
						<cfif isTextFormat EQ false >
							<cfoutput>Extension</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"Extension")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td align="center">
						<cfif isTextFormat EQ false >
							<cfoutput>Entry Date</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(10,"Entry Date")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
						</cfif>
					</td>
					<td>
						<cfif isTextFormat EQ false >
							<cfoutput>User ID</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(25,"User ID")#</cfoutput>
						</cfif>
					</td>
				</tr>
				<cfif isTextFormat NEQ false>
					<cfoutput>#NewLine#</cfoutput>
				</cfif>
				<!----- item list ---->
<!--- 				<cfloop collection = "#ClaimItems#" item = "thisItem" > --->
			<cfloop query="qClaimItems">
				<cfif split_billback_flag EQ 1>
					<cfset thisUnits = claimHandle.adjustItemQuantity(units,SPLITADJUSTEDPAIDAMOUNT,paidAmount)>
					<cfset thisExtension = claimHandle.adjustItemQuantity(extension,SPLITADJUSTEDPAIDAMOUNT,paidAmount)>
				<cfelse>
					<cfset thisUnits = units>
					<cfset thisExtension = extension>
				</cfif>
				<tr class="claim">
						<!--- line no ---->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#claimItemCount#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(5,claimItemCount)##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- item ---->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#replace(item,'CAJ', "", 'ALL')#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(12,replace(item,'CAJ', "", 'ALL'))##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- desc --->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#Description#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(25,trim(Description))##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---program ID--->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#program#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(12,program)##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks --->
						<cfif Auto_Billback EQ 1>
							<CFQUERY NAME="qryGetUnitsRebates" DATASOURCE="#application.datasource#">
											SELECT 			SUM(BB_Auto_Accrual_Log.Sales_Dollars) as Sales_Dollars,
																	avg(BB_Auto_Accrual_Log.Discount_Offered) as Discount_Offered
											FROM			 	BB_Auto_Accrual_Log 
											WHERE			BB_Auto_Accrual_Log.BB_ID = '#billback_id#'
											AND				BB_Auto_Accrual_Log.Program_ID = '#qClaimItems.Program_ID#'
											AND				BB_Auto_Accrual_Log.Product_ID = '#qClaimItems.Product_ID#'
											AND				BB_Auto_Accrual_Log.Distributor_ID_Earned = '#qClaimItems.Distributor_id#'
							</CFQUERY>
									<!---units--->
									<td align="right">
										<cfif isTextFormat EQ false >
											<cfoutput>$#NumberFormat(qryGetUnitsRebates.Sales_Dollars, '.99')#</cfoutput>
										<cfelse>
											<cfoutput>$#claimHandle.TextAlignLeft(7,NumberFormat(qryGetUnitsRebates.Sales_Dollars, '.99'))##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
										</cfif>
									</td>
									<!--- rebate --->
									<td align="right">
										<cfif isTextFormat EQ false >
											<cfoutput>
												<cfif Discount_Offered GE 0>
													#NumberFormat(qryGetUnitsRebates.Discount_Offered, '.99')#%
												<cfelse>
													-#NumberFormat(Abs(qryGetUnitsRebates.Discount_Offered), '.99')#%
												</cfif>
											</cfoutput>
										<cfelse>
											<cfoutput>#claimHandle.TextAlignLeft(10, "#trim(ToString(NumberFormat(qryGetUnitsRebates.Discount_Offered, '__,___,___.____') & '%'))#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
										</cfif>
									</td>							
						<cfelse>	
									<!---units--->
									<td align="right">
										<cfif isTextFormat EQ false >
											<cfoutput>#round(thisUnits)#</cfoutput>
										<cfelse>
											<cfoutput>#claimHandle.TextAlignLeft(8,round(thisUnits))##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
										</cfif>
									</td>
									<!--- rebate --->
									<td align="right">
										<cfif isTextFormat EQ false >
											<cfoutput>
												<cfif rebate GE 0>
													#NumberFormat(rebate, '$_,___.____')#
												<cfelse>
													-#NumberFormat(Abs(rebate), '$_,___.____')#
												</cfif>
											</cfoutput>
										<cfelse>
											<cfoutput>#claimHandle.TextAlignLeft(10, "$#trim(ToString(NumberFormat(rebate, '__,___,___.____')))#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
										</cfif>
									</td>
						</cfif>
						<!---D35038: hnz ehancement -- claim summary updates for auto pay billbacks --->
						<!--- extension ---->
						<td align="right" <cfif extension LT 0>style="color:990000"</cfif>>
							<cfif isTextFormat EQ false >
								<cfoutput>#NumberFormat(thisExtension,'$_,___,___,___,___.__')#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(15,"$#trim(ToString(NumberFormat(thisExtension, '__,___,___.__')))#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- entry date --->
						<td align="center">
							<cfif isTextFormat EQ false >
								<cfoutput>#DateFormat(claimEntryDate, "mm/dd/yyyy")#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(10,'#DateFormat(claimEntryDate, "mm/dd/yyyy")#')##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---user id--->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#UserID#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(25,UserID)#</cfoutput>
							</cfif>
						</td>
					</tr>
					<cfif isTextFormat NEQ false ><cfoutput>#NewLine#</cfoutput></cfif>
					<cfset claimItemCount = claimItemCount + 1 >
				</cfloop>
				<cfif trim(claimHandle.getParentBillbackID()) NEQ "">
					<cfset thisClaimID = claimHandle.getParentBillbackID() >
				<cfelse>
					<cfset thisClaimID = billback_id >
				</cfif>
				<!--- count for lump sum ---->
				<cfif claimHandle.hasLumpSum(thisClaimID, program_id) EQ true>
					<cfset claimHandle.setClaimLumpSum(thisClaimID, program_id) />
					<cfset thisLumpSum = claimHandle.getClaimLumpSum() >
					<cfloop collection = #thisLumpSum# item = "thisItem">
						<tr class="claim">
							<!--- line no --->
							<td align="left">
								<cfif isTextFormat EQ false >
									<cfoutput>#claimItemCount#</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(5,claimItemCount)##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!--- fee (item)--->
							<td align="left">
								<cfif isTextFormat EQ false >
									<cfoutput>Fee </cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(12,"Fee")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!---desc--->
							<td align="left">
								<cfif isTextFormat EQ false >
									<cfoutput>#replace(thisItem,"(dup)", "","all")#</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(25,trim(replace(thisItem,"(dup)","","all")))##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!--- program ID --->
							<td align="left">
								<cfif isTextFormat EQ false >
									<cfoutput>#claimHandle.getClaimProgramID()#</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(12,claimHandle.getClaimProgramID())##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!--- units---->
							<td align="right">
								<cfif isTextFormat EQ false >
									<cfoutput>-</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(8,"-----")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!--- rebate --->
							<td align="right">
								<cfif isTextFormat EQ false >
									<cfoutput>-</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(10,"-------")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!---extension--->
							<td align="right">
								<cfif isTextFormat EQ false >
									<cfoutput>#NumberFormat(thisLumpSum[thisItem],'$_,___,___,___,___.__')#</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(15,"$#trim(ToString(NumberFormat(thisLumpSum[thisItem], '__,___,___.__')))#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!---entry date--->
							<td align="center">
								<cfif isTextFormat EQ false >
									<cfoutput>#claimHandle.getClaimEntryDate()#</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(10,"#claimHandle.getClaimEntryDate()#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
								</cfif>
							</td>
							<!--- user id --->
							<td align="left" nowrap>
								<cfif isTextFormat EQ false >
									<cfoutput>#claimHandle.getClaimUserID()#</cfoutput>
								<cfelse>
									<cfoutput>#claimHandle.TextAlignLeft(25,"#claimHandle.getClaimUserID()#")#</cfoutput>
								</cfif>
							</td>
						</tr>
						<cfset claimItemCount = claimItemCount + 1 >
						<cfif isTextFormat NEQ false >
							<cfoutput>#NewLine#</cfoutput>
						</cfif>

					</cfloop>
				</cfif>
				<!--- count for Growth ---->
				<cfif claimHandle.hasGrowth(thisClaimID, program_id) EQ true>
					<cfset claimHandle.setClaimGrowth(thisClaimID, program_id) />
					<tr class="claim">
						<!--- line no --->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#claimItemCount#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(5,claimItemCount)##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- item ---->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>Growth</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(12,"Growth")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- desc ---->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>- </cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(25,"-----")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- program ID --->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#claimHandle.getClaimProgramID()#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(12,claimHandle.getClaimProgramID())##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---units--->
						<td align="right">
							<cfif isTextFormat EQ false >
								<cfoutput>-</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(8,"-----")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---Rebate--->
						<td align="right">
							<cfif isTextFormat EQ false >
								<cfoutput>-</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(10,"-------")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---extension--->
						<td align="right">
							<cfif isTextFormat EQ false >
								<cfoutput>#NumberFormat(claimHandle.getClaimPaidGrowthAmount(),'$_,___,___,___,___.__')#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(15,"$#trim(ToString(NumberFormat(claimHandle.getClaimPaidGrowthAmount(), '__,___,___.__')))#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!---entry Date --->
						<td align="center">
							<cfif isTextFormat EQ false >
								<cfoutput>#claimHandle.getClaimEntryDate()#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(10,"#claimHandle.getClaimEntryDate()#")##claimHandle.TextAlignLeft(2,"#textDelimiter#")#</cfoutput>
							</cfif>
						</td>
						<!--- user id--->
						<td align="left">
							<cfif isTextFormat EQ false >
								<cfoutput>#claimHandle.getClaimUserID()#</cfoutput>
							<cfelse>
								<cfoutput>#claimHandle.TextAlignLeft(25,"#claimHandle.getClaimUserID()#")#</cfoutput>
							</cfif>
						</td>
					</tr>
					<cfset claimItemCount = claimItemCount + 1 >
					<cfif isTextFormat NEQ false >
						<cfoutput>#NewLine##NewLine#</cfoutput>
					</cfif>
				</cfif>
			</table>
		</div>
		<BR>
		<cfif isTextFormat NEQ false >
			<cfoutput>#NewLine##NewLine#</cfoutput>
		</cfif>
		<!--- total case --->
		<cfset qryGetTotal = claimHandle.getTotal(billback_id, program_id)>
		<cfif isNumeric(qryGetTotal.distributorCS) >
			<cfif qryGetTotal.split_billback_flag EQ 1>
				<cfset distTotalCases = claimHandle.adjustItemQuantity(qryGetTotal.distributorCS,qryGetTotal.SPLITPAIDAMONT,qryGetTotal.claimAmount) />
			<cfelse>
				<cfset distTotalCases = qryGetTotal.distributorCS />
			</cfif>
		<cfelse>
			<cfset distTotalCases = 0 />
		</cfif>
		<cfset distTotalCases = round(distTotalCases) />
		<cfif isNumeric(qryGetTotal.distributorAmount) >
			<cfif qryGetTotal.split_billback_flag EQ 1>
				<cfset distTotalAmount = qryGetTotal.splitClaimAmount />
			<cfelse>
				<cfset distTotalAmount = qryGetTotal.distributorAmount />
			</cfif>
		<cfelse>
			<cfset distTotalAmount = 0 />
		</cfif>
		<cfif isNumeric(qryGetTotal.claimCS) >
			<cfif qryGetTotal.split_billback_flag EQ 1>
				<cfset claimTotalCases = claimHandle.adjustItemQuantity(qryGetTotal.claimCS,qryGetTotal.SPLITPAIDAMONT,qryGetTotal.claimAmount) />
			<cfelse>
				<cfset claimTotalCases = qryGetTotal.claimCS />
			</cfif>
		<cfelse>
			<cfset claimTotalCases = 0 />
		</cfif>
		<cfset claimTotalCases = round(claimTotalCases) />
		<cfif isNumeric(qryGetTotal.claimAmount) >
			<cfif qryGetTotal.split_billback_flag EQ 1>
				<cfset claimTotalAmount = qryGetTotal.splitPaidAmont />
			<cfelse>
				<cfset claimTotalAmount = qryGetTotal.claimAmount />
			</cfif>
		<cfelse>
			<cfset claimTotalAmount = 0 />
		</cfif>
		<cfset diffTotalCases = distTotalCases - claimTotalCases />
		<cfset diffTotalCases = round(diffTotalCases) />
		<cfset diffTotalAmount = distTotalAmount - claimTotalAmount />
		<div align="center" id="divClaimTotal" Style="z-index:2; background-color:##CCCCCC; layer-background-color:##CCCCCC;" >
			<table width="80%" class="claimTotal">
				<tr class="claimTotal">
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#application.returned_customer_setting.distributor_label_singular# Total Cases:</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(25,"Distributor Total Cases:")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#NumberFormat(distTotalCases, '_,___,___,___,___')#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"#distTotalCases#")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#application.returned_customer_setting.distributor_label_singular# Total Dollars:</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(27,"#application.returned_customer_setting.distributor_label_singular# Total Dollars:")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#NumberFormat(distTotalAmount, '$_,___,___,___,___.__')#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"$#trim(ToString(NumberFormat(distTotalAmount, '__,___,___.__')))#")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>Total Lines:</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"Total Lines:")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#claimItemCount-1#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(5,claimItemCount-1)#</cfoutput>
						</cfif>
					</td>
				</tr>
				<cfif isTextFormat NEQ false >
					<cfoutput>#NewLine#</cfoutput>
				</cfif>
				<tr class="claimTotal">
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>CLAIM Total Cases:</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(25,"CLAIM Total Cases:")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#NumberFormat(claimTotalCases, '_,___,___,___,___')#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"#round(claimTotalCases)#")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>CLAIM Total Dollars:</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(27,"CLAIM Total Dollars:")#</cfoutput>
						</cfif>
					</td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#NumberFormat(claimTotalAmount, '$_,___,___,___,___.__')#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"$#trim(ToString(NumberFormat(claimTotalAmount, '__,___,___.__')))#")#</cfoutput>
						</cfif>
					</td>
					<td align="right">&nbsp;</td>
					<td align="right">&nbsp;</td>
				</tr>
				<cfif isTextFormat NEQ false >
					<cfoutput>#NewLine#</cfoutput>
				</cfif>
				<tr class="claimTotal">
					<td align="right"><cfif isTextFormat EQ false ><cfoutput>Difference Total Cases:</cfoutput><cfelse><cfoutput>#claimHandle.TextAlignLeft(25,"Difference Total Cases:")#</cfoutput></cfif></td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput>#NumberFormat(diffTotalCases,'_,___,___,___,___')#</cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"#round(diffTotalCases)#")#</cfoutput>
						</cfif>
					</td>
					<td align="right"><cfif isTextFormat EQ false ><cfoutput>Difference Total Dollars:</cfoutput><cfelse><cfoutput>#claimHandle.TextAlignLeft(27,"Difference Total Dollars:")#</cfoutput></cfif></td>
					<td align="right">
						<cfif isTextFormat EQ false >
							<cfoutput> #NumberFormat(diffTotalAmount,'$_,___,___,___,___.__')# </cfoutput>
						<cfelse>
							<cfoutput>#claimHandle.TextAlignLeft(15,"$#trim(ToString(NumberFormat(diffTotalAmount, '__,___,___.__')))#")#</cfoutput>
						</cfif>
					</td>
					<td align="right">&nbsp;</td>
					<td align="right">&nbsp;</td>
				</tr>
				<cfif isTextFormat NEQ false >
					<cfoutput>#NewLine#</cfoutput>
				</cfif>
			</table>
		</div>
		<!--- display the programs for this claim--->
		<cfif isTextFormat EQ false >
			<cfif Not isDefined("url.program_id")>
				<cfset selectedProgram = program_id >
			<cfelse>
				<cfset selectedProgram = url.program_id >
			</cfif>

			<cfset thisClaimPrograms = claimHandle.getClaimProgramsInfo() />
		 	<cfset claimReportList = ValueList(thisClaimPrograms.contract_number) />
			<cfoutput>
				<table border="0" cellspacing="0" cellpadding="1" align="center">
					<tr>
					<cfloop query="thisClaimPrograms">
						<!--- get program id--->
						<td id="#program_id#" <cfif selectedProgram EQ program_id> class="background" <cfelse> CLASS="foreground" BGCOLOR="B9DCFF" onClick="javascript:window.location='#claimDetailPage#?program_id=#program_id#&billback_id=#billback_id#';this.className='foreground'"</cfif>>#contract_number#</td>
						<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="2" HEIGHT="2"></TD>
						<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="2" HEIGHT="2"></TD>
					</cfloop>
					</tr>
				</table>
				<!--- handle print ---->
				<TABLE align="center" CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="176" HEIGHT="35" BACKGROUND="/images/print_button.gif">
					<TR>
						<TD><A HREF="javascript:void(0);" onClick="javascript:window.print();//printpr(6);"><IMG SRC="/images/fill.gif" ALT="" WIDTH="176" HEIGHT="35" BORDER="0"></A></TD>
					</TR>
				</TABLE>
			</cfoutput>
			<script>
				function printpage(v)
				{
					// v = 6 = print
					// v = 7 = print preview
					var w = '<OBJECT ID="x" WIDTH=0 HEIGHT=0 CLASSID="8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
					document.body.insertAdjacentHTML('beforeEnd', w);
					x.ExecWB(v,true);
					//x.ExecWB(6,1);
					x.outerHTML = "";
				}
				function printpr(printWhat)
				{
				  var OLECMDID = printWhat;
					/* OLECMDID values:
					 * 6 - Print
					 * 7 - Print preview
					 * 1 - Open window
					 * 4 - Save As
					*/
				  var PROMPT = 1; // 2 DONTPROMPTUSER
				  var WebBrowser = '<OBJECT ID="WebBrowser1" WIDTH=0 HEIGHT=0 CLASSID="CLSID:8856F961-340A-11D0-A96B-00C04FD705A2"></OBJECT>';
				  document.body.insertAdjacentHTML('beforeEnd', WebBrowser);
				  WebBrowser1.ExecWB(OLECMDID, true);
				  WebBrowser1.outerHTML = "";
				  }

			</script>
			<BR>
		</cfif>
		<!--- reset the counter --->
		<cfset claimItemCount = 1 >
	</div>
 </body>
</html>



