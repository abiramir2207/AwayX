<!--- The goal of this file is to take in a program ID and payee type ID (distributor, broker etc.) and return a valid set of discount types and components to be selected. There should be at least one based on the query in /billbacks/search_programs.cfm. If there's not, see what that page is letting through that this one isn't. --->
<!DOCTYPE HTML PUBLIC>
<html>
<head>
	<title>Billback Program Information</title>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
	<script type="text/javascript" src="/script/tTip.js"></script>
</head>

<style>
	table.productListTableStyle {
		width: 47vw;
	}

	TABLE.productListTableStyle TD	{
		border-bottom:solid #93BEE2 1px;
		font-size : 10px;
		height: 26px;
	}

	.programInformationStyle_Top {
		border-top : 1 solid #ProgramDataBorderColor#;
		border-left : 1 solid #ProgramDataBorderColor#;
		border-right : 1 solid #ProgramDataBorderColor#;
		border-bottom : 0 solid red;
		background-color: WhiteSmoke;
	}

	.tableHeader {
		background-color : #ffce84;
	}

	.ProductTypeLabel {
		font-size: 12px;
		font-weight: bold;
		background-color: #ccffcc;
	}

	.LumpSumRow {
		border-bottom : 1 solid Navy;
	}

	.topMenu {
		border-top : 1 solid blue;
		border-bottom : 1 solid blue;
		border-left : 1 solid blue;
		border-right : 1 solid blue;
		margin: 1%;
	}

	.topMenu th {
		height: 24px;
	}

	h3 {
		height: 24px;
		text-align: center;
		vertical-align: middle;
		width: 98%;
		margin: 10px 1%;
		font-weight: bold;
		font-size: 14px;
		background-color: #ffce84;
		margin-bottom: 10px;
		padding-top: 8px;
	}

	p {
		text-align: center;
		width: 98%;
		font-size: 12px;
		margin-bottom: 10px;
	}

	.redHeader {
		background-color: #8B0000;
	}
</style>
<body>

<cfparam name="Program_ID"		default="">
<cfparam name="Payee_Type_ID"	default="">
<cfparam name="Billback_ID"		default="">
<cfparam name="ParentFormName" 	default="">
<cfparam name="LocationUrl"		default="">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset SoloDiscount = "">
<cfset NumberofOptions = 0>

<cfif isDefined("url.ParentFormName")>
	<Cfset ParentFormName = url.ParentFormName>
</cfif>

<!---
What this is all about:
You need to be able to select any component that was ever on any version of the program -- but you also need a component ID for each component, and there's a new one for each version of the program, so you need to get the most recent component ID.
 --->
<cfquery name="GetContractNumber" datasource="#application.datasource#">
	SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = #Program_ID#
</cfquery>

<cfquery name="IsNegative" datasource="#application.datasource#">
	SELECT <!--- Negative_Billback, ---> BB_End_Date
	FROM Billback
	WHERE Billback_ID = '#Billback_ID#'
</cfquery>

<cfparam name="ContractMainList" default="#Program_ID#">

<cfquery name="GetAllContractMains" datasource="#application.datasource#">
	SELECT 	Contract_Main_ID,
			isnull(Effective_Start_Date, Contract_Start_Date) AS Effective_Start_Date,
			isnull(Effective_End_Date, Contract_End_Date) AS Effective_End_Date
	FROM Contract_Main
	WHERE Contract_Number LIKE '%#GetContractNumber.Contract_Number#%'
	AND Approved = 1
</cfquery>

<cfloop query="GetAllContractMains">
	<Cfif datediff('d',Effective_Start_Date,Effective_End_Date) GT 0>
		<cfset ContractMainList = valuelist(GetAllContractMains.Contract_Main_ID)>
	</CFIF>
</cfloop>

<!--- Gotta get some value back! --->
<cfif listlen(ContractMainList) EQ 0>
	<cfset ContractMainList = valuelist(GetAllContractMains.Contract_Main_ID)>
</cfif>

<cfquery name="PriorEntries" datasource="#application.datasource#">
	Select Discount_List
	FROM Billback_Program
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = '#Program_ID#'
	AND Deleted = 0
</cfquery>

<cfset ExistingDiscountList = PriorEntries.Discount_List>

<cfoutput>
<form action="/billbacks/capture/saveallcomponents.cfm" method="post" name="DiscountSelectionForm">

<h3>Discounts and Components</h3>
<p>
	Select the discount type(s) and component(s) that are being billed back.
</p>

<table border="0" cellpadding="2" cellspacing="2" width="98%" class="topMenu">
	<tr>
		<td valign="top">
			<table border="0" cellpadding="2" cellspacing="0"  class="productListTableStyle">
				<!--- Show fixed price or not (radio yes/no)--->
				<cfquery name="HasFixed" datasource="#application.datasource#">
					SELECT DISTINCT Program_Fixed_Component.Program_Fixed_Component_ID, Program_Fixed_Component_Name.Program_Fixed_Component_Name
					FROM Program_Fixed_Component
						INNER JOIN Program_Fixed_Component_Name
						ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
						INNER JOIN Payment_Type
						ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
					WHERE Program_Fixed_Component.Program_ID IN (#ContractMainList#)
					AND Program_Fixed_Component.Deleted = 0
					AND (Program_Fixed_Component.Fixed_Component_Paid_To = #Payee_Type_ID#
						OR
							(Program_Fixed_Component.Fixed_Component_Paid_To = 4
								AND #Payee_Type_ID# != 3)
						)
				</cfquery>

				<cfif HasFixed.Recordcount GT 0>
					<cfset NumberofOptions = NumberofOptions + 1>
					<cfset SoloDiscount = "Fixed">
					<tr><Td colspan="2" class="redHeader"> <span style="color:white; font-weight: bold; padding-left:5px;">Fixed Price</span></TD></tr>
					<cfset PriorFixed = ListContains(PriorEntries.Discount_List,1)>
					<tr>
						<td align="right"><input type="radio" name="IncludeFixedPrice" value="1" <cfif PriorFixed GT 0>checked</cfif>></td>
						<td width="90%">Include</td>
					</tr>
					<tr>
						<td align="right"><input type="radio" name="IncludeFixedPrice" value="0" <cfif PriorFixed IS 0>checked</cfif>></td>
						<td>Do not include</td>
					</tr>
				</cfif>

				<!--- Rebate comps to pay (check boxes) --->
				<!--- Rebate --->
				<cfquery name="Has_Rebate" datasource="#application.datasource#">
					SELECT DISTINCT
					Program_Rebates_Component_Name.Program_Rebates_Component_Name,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
					FROM Program_Rebates_Component
						INNER JOIN Program_Rebates_Component_Name
						ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
						INNER JOIN Payment_Type
						ON Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
					WHERE Program_Rebates_Component.Program_ID IN (#ContractMainList#)
					AND Program_Rebates_Component.Deleted = 0
					AND (Program_Rebates_Component.Component_Paid_To = #Payee_Type_ID#
						OR
							(Program_Rebates_Component.Component_Paid_To = 4
								AND #Payee_Type_ID# != 3)
						)
				</cfquery>

				<cfset RebateList = "">
				<cfif Has_Rebate.Recordcount GT 0>
					<!--- Get prior rebates --->
					<cfquery name="PriorRebates" datasource="#application.datasource#">
						SELECT *
						FROM Billback_Program_Rebate_Component
						WHERE Billback_Program_ID = '#Program_ID#'
						AND Billback_ID = '#Billback_ID#'
						AND Deleted = 0
					</cfquery>
					<cfset ProgramRebatesComponentID = valuelist(PriorRebates.Program_Rebates_Component_Name_ID)>

					<tr><Td colspan="2" class="redheader"><span style="color:white; font-weight: bold; padding-left:5px;">#Application.RebateLabel#</span></TD></tr>
					<cfloop query="Has_Rebate">
						<cfset SoloDiscount = "Rebate">
						<cfset NumberofOptions = NumberofOptions + 1>
						<cfset RebateList = listappend(RebateList, Program_Rebates_Component_Name_ID)>
						<tr>
							<td align="right"><input type="checkbox" name="Program_Rebates_Component_Name_ID" value="#Program_Rebates_Component_Name_ID#" <cfif listcontains(ProgramRebatesComponentID, Program_Rebates_Component_Name_ID)>checked</cfif>></td>
							<td>#Program_Rebates_Component_Name#</td>
						</tr>
					</cfloop>
				</cfif>

				<!--- Show growth or not (radio yes/no) --->
				<cfquery name="Has_Growth" datasource="#application.datasource#">
					SELECT Program_Growth_Components.Program_Growth_Component_ID,
					Program_Growth_Components_Name.Program_Growth_Components_Name
					FROM Program_Growth_Components
						INNER JOIN Program_Growth_Components_Name
						ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
						INNER JOIN Payment_Type
						ON Program_Growth_Components.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
					WHERE Program_Growth_Components.Program_ID IN (#ContractMainList#)
					AND Program_Growth_Components.Deleted = 0
					AND (Program_Growth_Components.Component_Paid_To = #Payee_Type_ID#
						OR
							(Program_Growth_Components.Component_Paid_To = 4
								AND #Payee_Type_ID# != 3)
						)
				</cfquery>

				<cfif Has_Growth.Recordcount GT 0>
					<cfset NumberofOptions = NumberofOptions + 1>
					<cfset SoloDiscount = "Growth">
					<cfset PriorGrowth = ListContains(PriorEntries.Discount_List,4)>
					<tr><Td colspan="2" class="redHeader"> <span style="color:white; font-weight: bold;">Growth</span></TD></tr>
					<tr>
						<td align="right"><input type="radio" name="IncludeGrowth" value="1" <cfif PriorGrowth GT 0>checked</cfif>></td>
						<td>Include</td>
					</tr>
					<tr>
						<td align="right"><input type="radio" name="IncludeGrowth" value="0" <cfif PriorGrowth IS 0>checked</cfif>></td>
						<td>Do not include</td>
					</tr>
				</cfif>

				<!--- Show formula or not (radio yes/no) --->
				<cfquery name="Has_Formula" datasource="#application.datasource#">
					SELECT Program_ID FROM Program_Formula_Pricing_Rule_Mapped PFPRM
						WHERE PFPRM.Deleted = 0
						AND Program_ID = #Program_ID#
				</cfquery>

				<cfif Has_Formula.Recordcount GT 0>
					<cfset NumberofOptions = NumberofOptions + 1>
					<cfset SoloDiscount = "Formula">
					<cfset PriorFormula = ListContains(PriorEntries.Discount_List,5)>
					<tr><Td colspan="2" class="redHeader"> <span style="color:white; font-weight: bold;">Formula Pricing</span></TD></tr>

					<tr>
						<td align="right"><input type="radio" name="IncludeFormula" value="1" <cfif PriorFormula GT 0>checked</cfif>></td>
						<td>Include</td>
					</tr>
					<tr>
						<td align="right"><input type="radio" name="IncludeFormula" value="0" <cfif PriorFormula IS 0>checked</cfif>></td>
						<td>Do not include</td>
					</tr>
				</cfif>

				<!--- Bid request comps to pay --->
				<cfquery name="Has_BidRequest" datasource="#application.datasource#">
					SELECT DISTINCT
					Program_BidRequest_Component_Name.Program_BidRequest_Component_Name,
					Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID
					FROM Program_BidRequest_Component
						INNER JOIN Program_BidRequest_Component_Name
						ON Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID = Program_BidRequest_Component.Program_BidRequest_Component_Name_ID
						INNER JOIN Payment_Type
						ON Program_BidRequest_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
					WHERE Program_BidRequest_Component.Program_ID IN (#ContractMainList#)
					AND Program_BidRequest_Component.Deleted = 0
					AND (Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = #Payee_Type_ID#
						OR
							(Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = 4
								AND #Payee_Type_ID# != 3)
						)
				</cfquery>

				<!--- Get prior rebates --->
				<cfquery name="PriorBidRequest" datasource="#application.datasource#">
					SELECT Program_BidRequest_Component_ID
					FROM Billback_Program_BidRequest_Component
					WHERE Billback_Program_ID = '#Program_ID#'
					AND Billback_ID = '#Billback_ID#'
					AND Deleted = 0
				</cfquery>

				<cfset BidRequestList = "">
				<cfif Has_BidRequest.Recordcount GT 0>
					<cfset SoloDiscount = "Bid">
					<tr><Td colspan="2" class="redHeader"> <span style="color:white; font-weight: bold;">Proposals</span></TD></tr>
					<cfloop query="Has_BidRequest">
						<cfset NumberofOptions = NumberofOptions + 1>
						<cfquery name="GetBidRequestID" datasource="#application.datasource#">
							SELECT TOP 1 Program_BidRequest_Component_ID
							FROM Program_BidRequest_Component
							WHERE Program_BidRequest_Component_Name_ID = '#Has_BidRequest.Program_BidRequest_Component_Name_ID#'
							AND Program_BidRequest_Component.Program_ID IN (#ContractMainList#)
							ORDER BY Program_ID DESC
						</cfquery>

						<cfset BidRequestList = listappend(BidRequestList, GetBidRequestID.Program_BidRequest_Component_ID)>
						<tr>
							<td align="right"><input type="checkbox" name="Program_BidRequest_Component_ID" value="#GetBidRequestID.Program_BidRequest_Component_ID#" <cfif GetBidRequestID.Program_BidRequest_Component_ID IS PriorBidRequest.Program_BidRequest_Component_ID>checked</cfif>></td>
							<td>#Program_BidRequest_Component_Name#</td>
						</tr>
					</cfloop>
				</cfif>
			</table>
		</td>

		<cfset LumpSumNumber=0>
		<td valign="top">
			<table border="0" cellpadding="2" cellspacing="0"  class="productListTableStyle" valign="top">

				<cfquery name="getBBData" datasource="#application.datasource#">
					SELECT BB_Start_Date, BB_End_Date
					FROM Billback
					WHERE Billback_ID = '#Billback_ID#'
				</cfquery>

				<cfquery name="getProgramEffectiveDateSpan" datasource="#application.datasource#">
					SELECT	MIN(Effective_Start_Date) As Effective_Start_Date,
							MAX(Effective_End_Date) As Effective_End_Date
					FROM Contract_Main
					WHERE Contract_Main.Contract_Number = '#GetContractNumber.Contract_Number#'
				</cfquery>

				<!------------------------------------------------------------
				Find Lumpsum Dates to find out which program version to pick
				************************************************************
				If bb end date is between program effective dates, then select bb end date,
				else select effective end date.
				************************************************************
				------------------------------------------------------------->

				<cfif getProgramEffectiveDateSpan.Effective_End_Date neq "">
					<cfif DATEDIFF("d", getProgramEffectiveDateSpan.Effective_Start_Date, getBBData.BB_End_Date) GTE 0
						AND
						DATEDIFF("d", getBBData.BB_End_Date, getProgramEffectiveDateSpan.Effective_End_Date) GTE 0
					>
						<cfset Lumpsum_End_Date = getBBData.BB_End_Date>
					<cfelse>
						<cfset Lumpsum_End_Date = getProgramEffectiveDateSpan.Effective_End_Date>
					</cfif>
				</cfif>

				<cfquery name="Has_Lumpsums" datasource="#application.datasource#">
					SELECT Program_Lump_Sums.Program_Lump_Sum_ID, Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID,
							Program_Lump_Sum_Name.Program_Lump_Sum_Name, Program_Lump_Sums.Lump_Sum_Description,
							Program_Lump_Sums.Lump_Sum_Amount
					  FROM Program_Lump_Sums
								INNER JOIN Program_Lump_Sum_Name
									ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
								INNER JOIN Payment_Type
									ON Program_Lump_Sums.Claim_Mechanics = Payment_Type.Payment_Type_ID
										AND Payment_Type.Restrict_From_Billback = 0
								INNER JOIN Contract_Main
									ON (
											(Contract_Main.Contract_Main_ID = Program_Lump_Sums.Program_ID)
										)
										AND
											<!---
											1) If billback end date is outside the program effective dates, use the latest version of the program.
											2) If billback end date is within the program effective dates, use the version that overlaps bb end date with the effective dates.

											Eg: Version 1 of the program has lumpsum with effective dates from 1/1/2016 - 2/29/2016
											Version 2 of the program has rebates with effective dates from 3/1//2016 - 4/30/2016
											Version 3 of the program has lumpsum with effective dates from 5/1//2016 - 6/30/2016

											- If the billback end date is from 1/1/2016 - 2/29/2016, version 1 will be returned.
											- If the billback end date is from 3/1/1016 to 4/30/2016, then no record will be returned, as that version has rebates only.
											- If the billback end date is 5/1/2016 to 6/30/2016, version 3 will be returned.
											- If the version which overlaps with "billback end date" does not have lumpsum, then no record will be returned
											--->
											(DATEDIFF(d, Contract_Main.Effective_Start_Date, #createodbcdate(Lumpsum_End_Date)#) >= 0)
											AND
											(DATEDIFF(d, #createodbcdate(Lumpsum_End_Date)#, Contract_Main.Effective_End_Date) >= 0)
					WHERE Program_Lump_Sums.Program_ID IN (#ContractMainList#)
							AND Program_Lump_Sums.Deleted = 0
							AND (Program_Lump_Sums.Component_Paid_To = #Payee_Type_ID#
									OR
										(Program_Lump_Sums.Component_Paid_To = 4
											AND #Payee_Type_ID# != 3)
									)
				</cfquery>

				<cfif Has_Lumpsums.Recordcount GT 0>
					<cfset LSList = "">
					<tr>
						<Td colspan="2" class="redHeader">
							<!---32576--->
							<span onmouseout="popUpTip(event,'lstip');" onmouseover="popUpTip(event,'lstip');" style="color:white; font-weight:bold; padding-left:5px;">#Application.LumpsumLabel#s (dollar amount being billed back) &raquo;</span>
							<div id="lstip" class="tip" style="padding:3px;">Mouse over the component name next to the dollar entry box to see the program lump sum component value for each component</div>
						</td>
					</tr>

					<cfquery name="qPrgTemplate" datasource="#application.datasource#">
						SELECT pcpo.Lump_Sum_Allocation_Method
							FROM CONTRACT_MAIN
								INNER JOIN Program_Control_Panel_Options pcpo on pcpo.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
							WHERE Contract_Main_ID = '#URL.Program_ID#'
					</cfquery>

					<cfloop query="Has_Lumpsums">
						<cfset NumberofOptions = NumberofOptions + 1>
						<cfset LumpSumNumber = LumpSumNumber + 1>
						<cfset SoloDiscount = "Lump">

						<!--- Grabs top lumpsum id from the newest contract_main_id from contractmainlist --->
						<cfquery name="GetLSID" datasource="#application.datasource#">
							SELECT TOP 1 Program_Lump_Sum_ID
							  FROM Program_Lump_Sums
							 WHERE Program_Lump_Sum_ID = '#Has_Lumpsums.Program_Lump_Sum_ID#'
									AND Program_Lump_Sums.Program_ID  IN (#ContractMainList#)
									ORDER BY Program_ID DESC
						</cfquery>

						<!--- Get's the value of existing LS components on billback --->
						<cfquery name="ExistingLS" datasource="#application.datasource#">
							SELECT Amount
							  FROM Billback_Program_Lumpsum_Component
							 WHERE Billback_ID = '#Billback_ID#'
									AND Deleted = 0
									AND Component_Type_ID = 1
									AND Billback_Program_Lumpsum_Component.Program_Lump_Sum_ID = '#GetLSID.Program_Lump_Sum_ID#'
						</cfquery>

						<cfset SafeLS = replace(GetLSID.Program_Lump_Sum_ID, "-", "_", "ALL") />
						<cfset LSList = listappend(LSList, SafeLS)>
						<tr>
							<cfset lump_sum_label = Program_Lump_Sum_Name>
							<cfif qPrgTemplate.Lump_Sum_Allocation_Method eq "component_product">
								<cfset lump_sum_label = lump_sum_label & ' ' & left( Has_Lumpsums.Lump_Sum_Description, 20 )>
							</cfif>
							<td align="right" title="#HTMLEditFormat("#Program_Lump_Sum_Name# - #Lump_Sum_Description# $#Lump_Sum_Amount#")#">#lump_sum_label# <b>&raquo;</b>&nbsp;</td>
							<td align="left"><span style="position:relative;top:-2px;">$</span> <input type="text" name="LumpSum_#SafeLS#" value="#ExistingLS.Amount#" maxlength="10" onKeyUp="clenseText(this, '-.0123456789');" ></td>
						</tr>
					</cfloop>
					<input type="hidden" name="LSList" value="#LSList#">
				</cfif>

				<!--- Dev Note: dkunnath;  D13208: HZQ166  Billback - Lump sums for growth not adding correctly --->
				<cfset Has_Growth_Lumpsums = QueryNew("")>
				<!--- Growth amount kickers for eligible comps --->
				<cfquery name="Has_Growth_Lumpsums" datasource="#application.datasource#">
					SELECT 	DISTINCT dbo.Program_Growth_Components_Name.Program_Growth_Components_Name_ID,
							dbo.Program_Growth_Components_Name.Program_Growth_Components_Name,
							dbo.Program_Growth_Component_Tiers.Tier_Number,
							dbo.Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID,
							dbo.Program_Growth_Components.Program_Growth_Component_ID,
							Program_Growth_Components.Component_Description
					FROM  	dbo.Program_Growth_Components
							INNER JOIN	dbo.Program_Growth_Component_Tiers
							ON
							dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
							INNER JOIN Program_Growth_Components_Name
						ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
							INNER JOIN Payment_Type
							ON Program_Growth_Components.Claim_Mechanics = Payment_Type.Payment_Type_ID
							AND Payment_Type.Restrict_From_Billback = 0
							INNER JOIN Contract_Main
							ON
							(
								(Contract_Main.Contract_Main_ID = Program_Growth_Components.Program_ID)
								AND
								(Contract_Main.Deleted = 0)

							)
							INNER JOIN Program_Control_Panel_Options on ( Contract_Main.programtype_id = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
							AND Program_Control_Panel_Options.Bonus_Field = 1 )
					WHERE 	(dbo.Program_Growth_Component_Tiers.Deleted = 0)
							AND (dbo.Program_Growth_Components.Deleted = 0)
							AND (dbo.Program_Growth_Components.IsParent = 1)
							AND (dbo.Program_Growth_Components.Program_ID IN (#ContractMainList#))
							AND CAST(dbo.Program_Growth_Component_Tiers.Growth_Amount AS float(8)) <> 0
							AND len(CAST(dbo.Program_Growth_Component_Tiers.Growth_Amount AS float(8))) <> 0
							AND (Program_Growth_Components.Component_Paid_To = #Payee_Type_ID#
						OR
							(Program_Growth_Components.Component_Paid_To = 4
								AND #Payee_Type_ID# != 3)
						)
					ORDER BY Program_Growth_Components.Program_Growth_Component_ID,
							dbo.Program_Growth_Components_Name.Program_Growth_Components_Name,
							dbo.Program_Growth_Component_Tiers.Tier_Number
				</cfquery>

				<cfif Has_Growth_Lumpsums.Recordcount GT 0>
					<cfset GrowthLSList = "">
					<tr><Td colspan="2" class="redHeader"> <span style="color:white; font-weight: bold;">Growth #Application.LumpsumLabel#</span></TD></tr>

					<cfloop query="Has_Growth_Lumpsums">
						<cfset NumberofOptions = NumberofOptions + 1>
						<cfset LumpSumNumber = LumpSumNumber + 1>
						<cfset SoloDiscount = "GrowthLump">

						<cfset SafeGrowthLS = 	replace(Program_Growth_Component_ID, "-", "_", "ALL") />
						<cfset SafeCompTier = replace(Program_Growth_Component_Tier_ID, "-", "_", "ALL") />
						<cfset GrowthTier = SafeGrowthLS & "__" & SafeCompTier>
						<cfset GrowthLSList = listappend(GrowthLSList, GrowthTier)>

						<cfquery name="ExistingGrowthLS" datasource="#application.datasource#">
							SELECT Program_Lump_Sum_ID, Amount
							FROM Billback_Program_Lumpsum_Component
							WHERE Billback_ID = '#Billback_ID#'
							AND Program_Lump_Sum_ID = '#Program_Growth_Component_ID#'
							AND Deleted = 0
							AND Component_Type_ID = 3
							AND Program_Growth_Component_Tier_ID = '#Program_Growth_Component_Tier_ID#'
						</cfquery>

						<tr>
							<td align="right">#Program_Growth_Components_Name# #Component_Description# - Tier #Tier_Number#</td>
							<td align="left">$ <input type="text" name="GrowthLS_#GrowthTier#"  maxlength="10" onKeyUp="clenseText(this, '-.0123456789');" value="#ExistingGrowthLS.Amount#"></td>
						</tr>
					</cfloop>
					<input type="hidden" name="GrowthLSList" value="#GrowthLSList#">
				</cfif>
			</table>
		</td>
	</tr>
	<input type="hidden" name="Payee_Type_ID" value="#Payee_Type_ID#">
	<input type="hidden" name="Program_ID" value="#Program_ID#">
	<input type="hidden" name="Billback_ID" value="#Billback_ID#">
	<input type="hidden" name="ParentFormName" value="#ParentFormName#">
	<input type="hidden" name="LocationURL"	value="#LocationURL#">
	<input type="hidden" name="ContractMainList" value="#ContractMainList#">

</table>

<cfif NumberofOptions eq 0>
	<p>
		There are no valid discounts on this program for the type of payee you have selected. Please pick a different program or a different payee.
	</p>
<cfelse>
	<br>
	<a href="##" style="display:block;width:100%;text-align:center;" onclick="validateData();">#application.util.string.linkFormat("save")#</a>
</cfif>
</form>
</cfoutput>


<!--- Select and redirect if only one choice --->
<cfif NumberofOptions EQ 1 AND LumpSumNumber EQ 0>
<script>
	<Cfif SoloDiscount IS "Fixed">
		DiscountSelectionForm.IncludeFixedPrice[0].checked = true;
	</CFIF>
	<Cfif SoloDiscount IS "Rebate">
		DiscountSelectionForm.Program_Rebates_Component_Name_ID.checked = true;
	</CFIF>
	<Cfif SoloDiscount IS "Growth">
		DiscountSelectionForm.IncludeGrowth[0].checked = true;
	</CFIF>
	<Cfif SoloDiscount IS "Formula">
		DiscountSelectionForm.IncludeFormula[0].checked = true;
	</CFIF>
	<Cfif SoloDiscount IS "Bid">
		DiscountSelectionForm.Program_BidRequest_Component_ID.checked = true;
	</CFIF>
	DiscountSelectionForm.submit();
</script>
</cfif>



<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<script>
function validateData()
{
	strWarnDupComp = 0;
	totalChecked = 0;
	<cfif (appSettings.get_Setting('Restrict_One_Component_Per_Billback') EQ '1')>
		<cfif HasFixed.Recordcount GT 0>
			if (document.all.IncludeFixedPrice[0].checked == true)
			{
				totalChecked++;
			}
		</cfif>
		<cfif (ListLen(RebateList) GTE 1)>
		 	<cfset Indexcounter = 0>
		 	<cfloop list="#RebateList#" index="Program_Rebates_Component_Name_ID">
			if (document.all.Program_Rebates_Component_Name_ID<cfif Has_Rebate.Recordcount GT 1>[<cfoutput>#Indexcounter#</cfoutput>]</cfif>.checked == true)
			{
				totalChecked++;
			}
			<cfset Indexcounter = Indexcounter + 1>
			</cfloop>
		</cfif>
		<cfif Has_Growth.Recordcount GT 0>
			if (document.all.IncludeGrowth[0].checked == true)
			{
				totalChecked++;
			}

		</cfif>

		<cfif Has_Formula.Recordcount GT 0>
			if(document.all.IncludeFormula[0].checked == true)
			{
				totalChecked++;
			}
		</cfif>

		<cfif Has_BidRequest.Recordcount GT 0>
			<cfset Indexcounter = 0>
			<cfloop list="#BidRequestList#" index="Program_BidRequest_Component_ID">
			if (document.all.Program_BidRequest_Component_ID<cfif Has_BidRequest.Recordcount GT 1>[<cfoutput>#Indexcounter#</cfoutput>]</cfif>.checked == true)
			{
				totalChecked++;
			}
			<cfset Indexcounter = Indexcounter+ 1>
			</cfloop>
		</cfif>
		<cfif Has_LumpSums.Recordcount GT 0>
			<cfloop list="#LSList#" index="SafeLS">
				if (document.all.LumpSum_<cfoutput>#SafeLS#</cfoutput>.value.length >= 1)
				{
					totalChecked++;
				}

			</cfloop>
		</cfif>
		<cfif Has_Growth_Lumpsums.Recordcount GT 0>
			<cfloop list="#GrowthLSList#" index="GrowthTier">
				if (document.all.GrowthLS_<cfoutput>#GrowthTier#</cfoutput>.value.length >= 1)
				{
					totalChecked++;
				}
			</cfloop>
		</cfif>
	</cfif>
	if (totalChecked >=2)
	{
		strWarnDupComp = 1;
	}
	 if( 1 == 1 && strWarnDupComp == 0
	 	<cfif HasFixed.Recordcount GT 0> &&	document.all.IncludeFixedPrice[0].checked == false  </cfif>
	 	<cfset Indexcounter = 0>
	 	<cfloop list="#RebateList#" index="Program_Rebates_Component_Name_ID">
		 	 &&	document.all.Program_Rebates_Component_Name_ID<cfif Has_Rebate.Recordcount GT 1>[<cfoutput>#Indexcounter#</cfoutput>]</cfif>.checked == false
		 	 <cfset Indexcounter = Indexcounter + 1>
		</cfloop>
		<cfif Has_Growth.Recordcount GT 0> && document.all.IncludeGrowth[0].checked == false </cfif>
		<cfif Has_Formula.Recordcount GT 0>	&& document.all.IncludeFormula[0].checked == false </cfif>
		<cfif Has_BidRequest.Recordcount GT 0>
		<cfset Indexcounter = 0>
		<cfloop list="#BidRequestList#" index="Program_BidRequest_Component_ID">
			&&	document.all.Program_BidRequest_Component_ID<cfif Has_BidRequest.Recordcount GT 1>[<cfoutput>#Indexcounter#</cfoutput>]</cfif>.checked == false
			<cfset Indexcounter = Indexcounter+ 1>
		</cfloop>
		</cfif>
		<cfif Has_LumpSums.Recordcount GT 0>
		<cfloop list="#LSList#" index="SafeLS">
			&& document.all.LumpSum_<cfoutput>#SafeLS#</cfoutput>.value.length == 0
		</cfloop>
		</cfif>
		<cfif Has_Growth_Lumpsums.Recordcount GT 0>
		<cfloop list="#GrowthLSList#" index="GrowthTier">
			&&document.all.GrowthLS_<cfoutput>#GrowthTier#</cfoutput>.value.length == 0
		</cfloop>
		</cfif>
		)

		{
			alert("You must choose some kind of discount or component to claim against");
		}
		else if(strWarnDupComp == 1)
		{
			alert("You must pick only one component as the setting 'Restrict one component per Billback' in ON");
		}
		else
		{
			DiscountSelectionForm.submit();
		}
}

	// remove empty tables due to non existence discounts
	let tables = document.querySelectorAll( "table" );
	for ( let i = 0; i < tables.length; i++ ) {
		if ( tables[ i ].rows.length == 0 ) {
			tables[ i ].remove();
		}
	}
</script>
</body>
</html>
