<CFPARAM name="CalledFrom"							default="Checkbook">

<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
	<style>
	<CFINCLUDE TEMPLATE="/Common_Files/main_style.css">
	
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	.tdbodyright	{border-bottom:solid #93BEE2 1px; border-right:solid #93BEE2 1px; font-size : 10px;}
	.tableborder
		{
			border-bottom: solid blue 1px;
			border-top: solid blue 1px;
			border-right: solid blue 1px;
			border-left: solid blue 1px;
		}

		.inactiveMenuItem {
			width : 100px;
			height : 30px;
			cursor : hand;
			background-color: WhiteSmoke;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid red 1px;
			border-top:solid WhiteSmoke 1px;
			border-bottom:solid WhiteSmoke 1px;
			border-left:solid WhiteSmoke 1px;
			border-white:solid White 1px;			
		}
		.activeMenuItem {
			width : 100px;
			height : 30px;
			cursor : hand;
			background-color: silver;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid silver 1px;
			border-top:solid red 1px;
			border-bottom:solid red 1px;
			border-left:solid red 1px;
		}

		.cellaroundIframe {
			border-right:solid red 1px;
			border-top:solid red 1px;
			border-bottom:solid red 1px;
		} 

		.menuItem_idle {
			font-weight: bold;
			background-color: WhiteSmoke;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid red 1px;
			border-top:solid WhiteSmoke 1px;
			border-bottom:solid WhiteSmoke 1px;
			border-left:solid WhiteSmoke 1px;
			border-white:solid White 1px;
		}

					
</style>


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Find Code
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<SCRIPT LANGUAGE="JavaScript">
	function Page_Specific_Before_Find_Code()
	{
		var a_show_all_detailsObj = document.all.a_show_all_details;
		if(a_show_all_detailsObj.innerText.indexOf("Hide") <=0)
		{
			a_show_all_detailsObj.click();
		}
	}
</SCRIPT>
<cfparam name="ShowDetails" default="0">
<cfif ShowDetails IS 0>
<CFINCLUDE TEMPLATE="/Billbacks/Common/Find_In_Page.cfm">
</CFIF>

<cfif isDefined("URL.ShowDetails")>
	<cfset ShowDetails = Url.ShowDetails>
</cfif>

<!---Sets the basic variables from the form--->
<CFPARAM name="FORM.FinalDistributorList"	default="0">
<CFPARAM name="FORM.FinalProgramList"		default="0">
<CFPARAM name="Start_Date"					default="">
<CFPARAM name="End_Date" 					default="">
<CFPARAM name="UOM"							default="">
<CFPARAM name="LumpsumCredit"				default="0">
<CFPARAM name="LumpsumDebit"				default="0">
<CFPARAM name="LumpsumTotal"				default="0">
<CFPARAM name="RebateCredit"				default="0">
<CFPARAM name="RebateDebit"					default="0">
<CFPARAM name="TotalRebate"					default="0">
<CFPARAM name="FixedPriceCredit"			default="0">
<CFPARAM name="FixedPriceDebit"				default="0">
<CFPARAM name="FixedPriceTotal"				default="0">
<CFPARAM name="FormulaPriceCredit"			default="0">
<CFPARAM name="FormulaPriceDebit"			default="0">
<CFPARAM name="FormulaPriceTotal"			default="0">
<CFPARAM name="GrowthCredit"				default="0">
<CFPARAM name="GrowthDebit"					default="0">
<CFPARAM name="TotalGrowth"					default="0">
<CFPARAM name="ReimbursementDebit"			default="0">
<CFPARAM name="DeductionDebit"				default="0">
<CFPARAM name="UseReimbursements"			default="0">
<CFPARAM name="UseDeductions"				default="0">

<!---If a record is returned, then the reimbursements table exists and reimbursements should be included in the bb code--->
<cfquery name="TableExists" datasource="#application.datasource#">
	SELECT * FROM Information_Schema.Tables
	WHERE Table_Name = 'BB_Reimbursement'
</cfquery>

<cfif TableExists.Recordcount GT 0 AND application.appSettingsGet.getBillback_Module() EQ 1 AND application.returned_customer_setting.customer_keyword IS "conagra">
	<cfset UseReimbursements = 1>
</cfif>

<!---Select preferences from Billback Settings--->
<cfset useLakebaseForBB_Preferences = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForBB_Preferences>
	<cftry>
		<cfset BB_Preferences = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "bb_tolerance_tet"
			}), "bb_tolerance_tet"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBB_Preferences = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBB_Preferences>
<cfquery name="BB_Preferences" datasource="#application.datasource#">
	SELECT BB_Tolerance_TET
	FROM Billback_Settings
</cfquery>
</cfif>

<cfset BB_Tolerance_TET = BB_Preferences.BB_Tolerance_TET>

<!---See if we should use deductions--->
<!---<cfif application.deductionLinksAvailable IS 1> --->  
<cfif application.appSettingsGet.getDeduction_Module()>
	<cfset UseDeductions = 1>
</cfif>

<cfset ContractID=FinalProgramList>
<cfset DistributorNumber=FinalDistributorList>

<!---Getting Contract Number--->
	<cfset useLakebaseForGetContractNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_program_info")>
<cfif useLakebaseForGetContractNumber>
	<cftry>
		<cfset GetContractNumber = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_program_info", {
				"contract_main_id" = "eq.#ContractID#",
				"select" = "contract_number"
			}), "contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractNumber = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractNumber>
<cfquery name="GetContractNumber" datasource="#application.datasource#">
	SELECT Contract_Number
	FROM BB_Program_Info
	WHERE Contract_Main_ID = #ContractID#
	</cfquery>
</cfif>
	
	<cfset Contract_Number = GetContractNumber.Contract_Number>
	
	<!---Get the rates on the date on the invoice--->
	<cfset useLakebaseForGetContractMain = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_program_info")>
<cfif useLakebaseForGetContractMain>
	<cftry>
		<cfset GetContractMain = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_program_info", {
				"contract_number" = "eq.#Contract_Number#",
				"select" = "contract_main_id,approval_start_date,approval_end_date"
			}), "contract_main_id,approval_start_date,approval_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractMain = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractMain>
<cfquery name="GetContractMain" datasource="#application.datasource#">
	SELECT DISTINCT Contract_Main_ID, Approval_Start_Date, Approval_End_Date 
	FROM BB_Program_Info
	WHERE Contract_Number = '#Contract_Number#'
	</cfquery>
</cfif>
	
	<cfquery name="PopulateTables1" datasource="#application.datasource#">
	exec BB_D_Program_Detail
	@@A_ID = '#ContractID#'
	</cfquery>

	<!--- This code should not be commented!!!!!--->
 <cfloop query="GetContractMain">
	<cfquery name="PopulateTCTables" datasource="#application.datasource#">
	EXEC TC_PROGRAM_PRODUCT_DETAIL 
	@@A_ID = '#GetContractMain.Contract_Main_ID#',
	@@CUSTOMER_ID = '#FinalDistributorList#'
	</cfquery>
</cfloop>


<!---Gets user friendly names--->
<cfset useLakebaseForGetDistributorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetDistributorName>
	<cftry>
		<cfset GetDistributorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#DistributorNumber#",
				"select" = "name"
			}), "name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorName>
<cfquery name="GetDistributorName" datasource="#application.datasource#">
SELECT Name 
FROM BSA_Foodservice_Customers 
WHERE BSA_Foodservice_Customers_ID = '#DistributorNumber#'
</cfquery>
</cfif>

<!---Gets program number--->
<cfquery name="GetProgramNumber" datasource="#application.datasource#">
SELECT Contract_Main.Contract_Quantity_UOM_IDX, Contract_Main.Contract_Title, Contract_Main.Contract_Number, Contract_Main.ClaimMechanics, Contract_Status_Types.Contract_Status_Type_Desc, isnull(Contract_Main.Contract_Quantity, 0) AS Contract_Quantity
FROM Contract_Main
	INNER JOIN Contract_Status_Types
	ON
	Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
WHERE Contract_Main_ID = #ContractID#
</cfquery>

<cfset useLakebaseForGetProgramNumbers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetProgramNumbers>
	<cftry>
		<cfset GetProgramNumbers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#GetProgramNumber.Contract_Number#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProgramNumbers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProgramNumbers>
<cfquery name="GetProgramNumbers" datasource="#application.datasource#">
SELECT Contract_Main_ID
FROM Contract_Main
WHERE Contract_Number = '#GetProgramNumber.Contract_Number#'
</cfquery>
</cfif>

<cfset ProgramNumber = listqualify(valuelist(GetProgramNumbers.Contract_Main_ID), chr(39))>

<cfquery name="GetProgramDates" datasource="#application.datasource#">
SELECT Min(Approval_start_Date) as Start_Date, Max(Approval_End_Date) as End_Date
FROM BB_Program_Info
WHERE Contract_Number = '#GetProgramNumber.Contract_Number#'
</cfquery>

<!----Queries to figure out which segments to shoe--->
<cfinclude template="query_inc_old.cfm">


<!--- <cfdump var="#GetDiscountsforProgram#">
<cfdump var="#GetAllBillbacks#">  --->


<!---Sets program variables--->
<cfset DistributorName = GetDistributorName.Name>
<cfset ProgramName = GetProgramNumber.Contract_Title>
<cfset StartDate = GetProgramDates.Start_Date>
<cfset EndDate = GetProgramDates.End_Date>
<cfset UOM = GetProgramNumber.Contract_Quantity_UOM_IDX>

<cfinclude template="/billbacks/ledger/inc_volume.cfm">

<div align="center">
<cfoutput>
<Table border="0" cellpadding="4" cellspacing="2" BGCOLOR="White" WIDTH="90%">

<tr>
<Td width="100%" BGCOLOR="006600" >
<B>
<FONT SIZE="2" COLOR="White">
#DistributorName# - #ProgramName# (#GetProgramNumber.Contract_Number#)<BR>
</FONT>

<FONT SIZE="2" COLOR="White">
#GetProgramNumber.Contract_Status_Type_Desc#
</FONT>

<FONT SIZE="1" COLOR="White">
[ #DateFormat(StartDate, 'MM/DD/YY')# - #DateFormat(EndDate, 'MM/DD/YY')# ]
</FONT>

</td>
<td nowrap align="Center" BGCOLOR="Red">
<font color="yellow">Volume</font>
<br>
<B><FONT COLOR="Yellow" SIZE="+2"> #numberformat(PercentVolumeCompleted, '___')#% </FONT></B><font color="yellow">
<br><cfif UOM IS 1>#numberformat(GetInvoices.Total_Cases, '___,___,___,___')#<cfelse>#numberformat(GetInvoices.Total_Pounds, '___,___,___,___')#</cfif> <cfif UOM IS 1>cases<cfelse>pounds</cfif> (bought)

<br>#numberformat(GetProgramNumber.Contract_Quantity, '___,___,___,___')# <cfif UOM IS 1>cases<cfelse>pounds</cfif> (program)
</font>
</td>

<td NOWRAP BGCOLOR="Red" ALIGN="center">
<!--- #GetProgramNumber.Contract_Status_Type_Desc# --->
<!--- #DateFormat(StartDate, 'MM/DD/YY')# - #DateFormat(EndDate, 'MM/DD/YY')# --->
<cfset ProgramSpan = EndDate - StartDate>
<cfset AmountLeft = Now() - StartDate>
<cfif ProgramSpan LTE 0>
	<cfset PercentDone = 100>
<cfelseif AmountLeft GTE ProgramSpan>
	<cfset PercentDone = 100>
<cfelse>
	<cfset PercentDone = AmountLeft / ProgramSpan>
	<cfset PercentDone = PercentDone * 100>
</cfif>

<font color="yellow">Time</font><br>
&nbsp;&nbsp;&nbsp;&nbsp;<B><FONT COLOR="Yellow" SIZE="+2">#int(PercentDone)#%</FONT></B>
&nbsp;&nbsp;&nbsp;&nbsp;

<BR>
<FONT COLOR="Yellow" SIZE="1">complete</FONT>

</td>

</B>
</td></tr>
</TABLE>


</cfoutput></div>
<p></p>

<table border="0" width="90%" align="center">

<tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="right"><strong>Credits:</strong></td>
<td align="right"><strong>Debits:</strong></td>
<td align="right"><strong>Balance:</strong> </td>
</tr>

<tr><td colspan="5"><hr color="orange"></td></tr>
<cfinclude template="details/shared_settings.cfm">
<cfif CalledFrom IS NOT "Scheduled" AND ShowDetails IS 0>
<B>
<a href="#" onclick="return AllOpenLayers(1, this, 1)" name="a_show_all_details">[ Show All Details ]</a>
&nbsp;&nbsp;
<a href="#" onclick="return startFind();">[ Find ]</a>
</B>
</cfif>

<!---Lump sum--->
<cfif ShowLumpSum IS 1>
	<tr>
	<Td valign="top" colspan="5">
	
	<cfif ShowDetails IS 0>	
	<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#color1#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="#Application.LumpsumLabel#"  
	TitleClosed="#Application.LumpsumLabel#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="99%"
	Color="white">

	<!--- 	<a href="#" onclick="return AllOpenLayers(1, this)">[ Show All Details ]</a>	 --->	
		<cfinclude template="/billbacks/ledger/details/lump_sum_inc.cfm">
		</cf_Openlayer>
	<cfelse>
		<strong><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>:</strong><br>
		<cfinclude template="/billbacks/ledger/details/lump_sum_inc.cfm">
	</cfif>
	<cfoutput>
	<tr>
	<td>&nbsp; </td>
	<td>&nbsp; </td>
	<td align="right" valign="top">
	<strong>	
	#LSCurrencyFormat(LumpSumCredit)#
	</strong>
	</TD><Td align="right" valign="top">
	<strong>
	-#LSCurrencyFormat(LumpSumDebit)#
</strong>
	</td>
	<td align="right">
	<cfset TotalLumpSum = LumpSumCredit - LumpSumDebit>

	<cfif left(#TotalLumpSum#, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif><strong>=&nbsp; #LSCurrencyFormat(TotalLumpSum)#</strong></font>
	</cfoutput>
	</td>
	</tr>
</cfif>


<!---Rebates--->
<cfif ShowRebate IS 1>
	<tr>
	<Td valign="top" colspan="5">

	<cfif ShowDetails IS 0>
		<CF_openLayer
		Border="#Border#"
		BorderSize="#BorderSize#"  
		BorderColor="#color1#"  
		Image="#Image#"
		ImageOpen="#ImageOpen#"
		Title="#Application.RebateLabel#"  
		TitleClosed="#Application.RebateLabel#"  
		TitleTooltip="Click here to toggle the view"  
		TitleColor="#TitleColor#"  
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="99%"
		Color="white">

	<a href="#" onclick="return AllOpenLayers(1, this)" id="InnerDetails">[ Show All Details ]</a>
		<cfinclude template="/billbacks/ledger/details/rebate_inc_old.cfm">
		</CF_openLayer>
	<cfelse>
		<strong><CFOUTPUT>#Application.RebateLabel#:</CFOUTPUT></strong><br>
		<cfinclude template="/billbacks/ledger/details/rebate_inc_old.cfm">
	</cfif>
	
	<tr>
	<td>&nbsp; </td>
	<td>&nbsp; </td>
	<td align="right" valign="top">
	<strong>
	<cfoutput>
	#LSCurrencyFormat(RebateCredit)#
	</cfoutput>
	</strong>
	</TD><Td align="right" valign="top">
	<strong>
	<cfoutput>
	-#LSCurrencyFormat(RebateDebit)#
	</cfoutput></strong>
	</td>
	<td align="right">
	<cfset TotalRebate = RebateCredit - RebateDebit>
	<cfoutput>
	
	<cfif left(#TotalRebate#, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif><strong>=&nbsp; #LSCurrencyFormat(TotalRebate)#</strong></font>
	</cfoutput>
	</td>
	</tr>
</cfif>
<!---Fixed Price--->
<cfif ShowFixed IS 1>
<tr>

<Td valign="top" colspan="5">
<cfif ShowDetails IS 0>
<CF_openLayer
Border="#Border#"
BorderSize="#BorderSize#"  
BorderColor="#color1#"  
Image="#Image#"
ImageOpen="#ImageOpen#"
Title="Fixed Price"  
TitleClosed="Fixed Price"  
TitleTooltip="Click here to toggle the view"  
TitleColor="#TitleColor#"  
TitleFont="#TitleFont#"
TitleSize="#TitleSize#"
IsClosed="#IsClosed#"
Width="99%"
Color="white">

<a href="#" onclick="return AllOpenLayers(1, this)"  id="InnerDetails">[ Show All Details ]</a>
	<cfinclude template="/billbacks/ledger/details/fixedprice_inc_old.cfm">
</cf_OpenLayer>
<cfelse>
<strong>Fixed Price:</strong><br>
	<cfinclude template="/billbacks/ledger/details/fixedprice_inc_old.cfm">
</cfif>

<tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="right" valign="top">
<strong>
<cfoutput>
#LSCurrencyFormat(FixedPriceCredit)#
</cfoutput>
</strong>
</TD><Td align="right" valign="top">
<strong>
<cfoutput>
-#LSCurrencyFormat(FixedPriceDebit)#
</cfoutput></strong>
</td>
<td align="right">
<cfset FixedPriceTotal = FixedPriceCredit - FixedPriceDebit>
<cfoutput>

<cfif left(#FixedPriceTotal#, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif><strong>=&nbsp; #LSCurrencyFormat(FixedPriceTotal)#</strong></font>
</cfoutput>
</td>
</tr>
</cfif>

<!---Formula Price--->
<cfif ShowFormula IS 1>
<tr>
<Td valign="top" colspan="5">

<cfif ShowDetails IS 0>
<CF_openLayer
Border="#Border#"
BorderSize="#BorderSize#"  
BorderColor="#color1#"  
Image="#Image#"
ImageOpen="#ImageOpen#"
Title="Formula Price"  
TitleClosed="Formula Price"  
TitleTooltip="Click here to toggle the view"  
TitleColor="#TitleColor#"  
TitleFont="#TitleFont#"
TitleSize="#TitleSize#"
IsClosed="#IsClosed#"
Width="99%"
Color="white">

<a href="#" onclick="return AllOpenLayers(1, this)"  id="InnerDetails">[ Show All Details ]</a>
	<cfinclude template="/billbacks/ledger/details/formulaprice_inc_old.cfm">
	
	</cf_openlayer>
<cfelse>
<strong>Formula Price:</strong><br>
	<cfinclude template="/billbacks/ledger/details/formulaprice_inc_old.cfm">
</cfif>
<tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="right" valign="top">
<strong>
<cfoutput>
#LSCurrencyFormat(FormulaPriceCredit)#
</cfoutput>
</strong>
</TD><Td align="right" valign="top">
<strong>
<cfoutput>
-#LSCurrencyFormat(FormulaPriceDebit)#
</cfoutput></strong>
</td>
<td align="right">

<cfset FormulaPriceTotal = FormulaPriceCredit - FormulaPriceDebit>
<cfoutput>

<cfif left(#FormulaPriceTotal#, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif><strong>=&nbsp; #LSCurrencyFormat(FormulaPriceTotal)#</strong></font>
</cfoutput>
</td>
</tr>
</cfif>

<!---Growth--->
<cfif ShowGrowth IS 1>
<tr>
<Td valign="top" colspan="5">

<cfif ShowDetails IS 0>
<CF_openLayer
Border="#Border#"
BorderSize="#BorderSize#"  
BorderColor="#color1#"  
Image="#Image#"
ImageOpen="#ImageOpen#"
Title="Growth"  
TitleClosed="Growth"  
TitleTooltip="Click here to toggle the view"  
TitleColor="#TitleColor#"  
TitleFont="#TitleFont#"
TitleSize="#TitleSize#"
IsClosed="#IsClosed#"
Width="99%"
Color="white">

<a href="#" onclick="return AllOpenLayers(1, this)"  id="InnerDetails">[ Show All Details ]</a>

	<cfinclude template="/billbacks/ledger/details/growth_inc_old.cfm">
	</cf_OpenLayer>
<cfelse>
<strong>Growth:</strong><br>
	<cfinclude template="/billbacks/ledger/details/growth_inc_old.cfm">
</cfif>
</td></tr>
<tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
<td align="right" valign="top">
<strong>
<cfoutput>
#LSCurrencyFormat(GrowthCredit)#
</cfoutput>
</strong>
</TD><Td align="right" valign="top">
<strong>
<cfoutput>
-#LSCurrencyFormat(GrowthDebit)#
</cfoutput></strong>
</td>
<td align="right">
<cfset GrowthTotal = GrowthCredit - GrowthDebit>
<cfoutput>

<cfif left(#GrowthTotal#, 1) IS "-"><font color="red"><cfelse><font color="green"></cfif><strong>=&nbsp; #LSCurrencyFormat(GrowthTotal)#</strong></font>
</cfoutput>
</td>
</tr>
</cfif>

<!---Reimbursements--->
<cfif UseReimbursements IS 1 AND ShowReimbursements IS 1>

<cfif ShowDetails IS 0>
<tr>
		
	<td valign="top" colspan="5">
	<CF_openLayer
		Border="#Border#"
		BorderSize="#BorderSize#"  
		BorderColor="#color1#"  
		Image="#Image#"
		ImageOpen="#ImageOpen#"
		Title="Reimbursements"  
		TitleClosed="Reimbursements"  
		TitleTooltip="Click here to toggle the view"  
		TitleColor="#TitleColor#"  
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="99%"
		Color="white">


	<cfinclude template="/billbacks/ledger/details/reimbursements_inc.cfm">
	</cf_OpenLayer>
	<cfelse>
<strong>Reimbursements:</strong><br>
	<cfinclude template="/billbacks/ledger/details/reimbursements_inc.cfm">
</cfif>
	</td>
	</tr>
	<!---Reimbursement summary--->
	<tr>
	<td>&nbsp; </td>
	<td>&nbsp; </td>
	<td align="right" valign="top">
	&nbsp; 
	</TD><Td align="right" valign="top">
	<strong>
	<cfoutput>
	-#LSCurrencyFormat(ReimbursementDebit)#
	</cfoutput></strong>
	</td>
	<td align="right">
	
	<cfoutput>
	
	<font color="red"><strong>=&nbsp; -#LSCurrencyFormat(ReimbursementDebit)#</strong></font>
	</cfoutput>
	</td>
	</tr>

</cfif>

<!---Deductions--->
<cfif UseDeductions IS 1 AND ShowDeductions IS 1>

<cfif ShowDetails IS 0>
<tr>
		
	<td valign="top" colspan="5">
	<CF_openLayer
		Border="#Border#"
		BorderSize="#BorderSize#"  
		BorderColor="#color1#"  
		Image="#Image#"
		ImageOpen="#ImageOpen#"
		Title="Deductions"  
		TitleClosed="Deductions"  
		TitleTooltip="Click here to toggle the view"  
		TitleColor="#TitleColor#"  
		TitleFont="#TitleFont#"
		TitleSize="#TitleSize#"
		IsClosed="#IsClosed#"
		Width="99%"
		Color="white">


	<cfinclude template="/billbacks/ledger/details/deductions_inc.cfm">
	</cf_OpenLayer>
	<cfelse>
<strong>Reimbursements:</strong><br>
	<cfinclude template="/billbacks/ledger/details/deductions_inc.cfm">
</cfif>
	</td>
	</tr>
	<!---Reimbursement summary--->
	<tr>
	<td>&nbsp; </td>
	<td>&nbsp; </td>
	<td align="right" valign="top">
	&nbsp; 
	</TD><Td align="right" valign="top">
	<strong>
	<cfoutput>
	-#LSCurrencyFormat(DeductionDebit)#
	</cfoutput></strong>
	</td>
	<td align="right">
	
	<cfoutput>
	
	<font color="red"><strong>=&nbsp; -#LSCurrencyFormat(DeductionDebit)#</strong></font>
	</cfoutput>
	</td>
	</tr>

</cfif>


<tr><td colspan="5"><hr color="orange"></td></tr>


<tr>
<td>&nbsp; </td><td>&nbsp; </td>
<td valign="top" align="right">
<cfoutput>
<cfset CreditTotal = LumpSumCredit + RebateCredit + FixedPriceCredit + FormulaPriceCredit + GrowthCredit>
<font size="2">
<strong>Total Earnings: #LSCurrencyFormat(CreditTotal)#</strong></font>
</cfoutput> 
</td>

<td valign="top" align="right">
<cfoutput>
<cfset DebitTotal = LumpSumDebit + RebateDebit + FixedPriceDebit + FormulaPriceDebit + GrowthDebit>
<cfif UseReimbursements IS 1>
	<cfset DebitTotal = DebitTotal + ReimbursementDebit>
</cfif>
<cfif UseDeductions IS 1>
	<cfset DebitTotal = DebitTotal + DeductionDebit>
</cfif>
<font size="2">
<strong>Total Payments: #LSCurrencyFormat(DebitTotal)#</strong></font>
</cfoutput>
</td>

<td valign="top" align="right">
<cfoutput>
<cfset LedgerTotal = CreditTotal - DebitTotal>
<strong>
<cfif left(LedgerTotal, 1) IS "-"><font color="red" size="2"><cfelseif len(LedgerTotal) IS 1 AND LedgerTotal IS "0"><font color="black" size="2"><cfelse><font color="green" size="2"></cfif>
Balance: #LSCurrencyFormat(LedgerTotal)#</font> </strong>
</cfoutput>
</td>


</td>
</tr>

<tr><td colspan="5"><hr color="orange"></td></tr>
</table>