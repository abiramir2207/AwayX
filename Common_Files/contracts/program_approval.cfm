<html>
<head>
	<title>Approval</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>
<body>

<cfparam name="Program_Is_A_Revision" default=0>
<!---If this ever gets turned to 1, you cannot approve --->
<cfparam name="AreThereAnyFailures" default=0>
<cfset AreThereAnyFailures = 0>
<cf_cryp type="de" string ="#url.CID#" key="#request.key#">
<cfparam name="URL.Group_ID" 	default="">
<cfparam name="massapproval" default = "0">

<cfif IsDefined("Discount_Queries_Called") and Discount_Queries_Called eq 1>
	<cfset Discount_Queries_Called = 0 >
</cfif>

<cfset Contract_Main_ID = cryp.value>
<CFPARAM NAME="useragreed" default="0">
<CFPARAM NAME="displayagreed" default="0">
<cfset useragreed = 0>
<cfset displayagreed = 0>
<!---Check for program status, and that volume has been added --->
<!--- if this user if god no reason to run any analisys --->
<cfset LetUserApprove = 1>
<CFPARAM NAME="Customerrequired" default="0">
<CFPARAM NAME="Operatorrequired" default="0">
<cfset Customerrequired = 0>
<cfset Operatorrequired = 0>
<CFPARAM NAME="showmessage" default="0">

<!---Used only for pricing floor--->
<cfparam name="HasOperator" default="0">
<cfparam name="HasDistributor" default="0">

<!---Discount required--->
<CFPARAM NAME="Discountrequired" default="0">
<CFPARAM NAME="DiscountFound" default="1">

<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<cfset objProgram = CreateObject("component", "components.programs.Program") />

<!---Select and display basic program information such as name and number--->
<cfquery name="BasicProgramInformation" datasource="#application.datasource#">
SELECT *
FROM Contract_Main 
	LEFT JOIN Contract_Main_Aux_Data
	ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
WHERE Contract_Main.Contract_Main_ID = '#Contract_Main_ID#'
</cfquery>

<!---Gets settings for the template--->
<cfset useLakebaseForgetProgramSettngs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetProgramSettngs>
	<cftry>
		<cfset getProgramSettngs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#BasicProgramInformation.ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramSettngs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramSettngs>
<CFQUERY NAME="getProgramSettngs" datasource="#application.datasource#">
	SELECT	*
	FROM    Program_Control_Panel_Options
	WHERE 	ProgramControl_Panel_Options_ID = '#BasicProgramInformation.ProgramType_ID#'
</CFQUERY>
</cfif>

<cfset getSettings = getProgramSettngs>
<cfset GETPROGRAMINFO = BasicProgramInformation>	

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif appSettings.getRFAAgree()>	

<cfset display_business_consideration = 0 ><!--- Dev Note: KAL; 8891 --->
<cfif Get_Profile_Settings.Internal_Notes EQ 1 and appSettings.getbusinessconsiderations_on() EQ 1>
	<cfset display_business_consideration = 1 ><!--- Dev Note: KAL; 9559 --->
</cfif>



<CFSET displayagreed = 1>
<CFINCLUDE template="program_agree.cfm">
</CFIF>

<cfif appSettings.getFloorPrice() IS 1>
	<cfset UseFloorPrice = 1>
<cfelse>
	<cfset UseFloorPrice = 0>
</cfif>
<cfparam name="FailedFloorTest" default="0">

<!---Get growth lump sum and inactive LS approval amounts--->
<cfset useLakebaseForApprovalAmounts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles_settings")>
<cfif useLakebaseForApprovalAmounts>
	<cftry>
		<cfset ApprovalAmounts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles_settings", {
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForApprovalAmounts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForApprovalAmounts>
<cfquery name="ApprovalAmounts" datasource="#application.datasource#">
SELECT *
FROM Profiles_Settings
WHERE Profiles_ID = '#request.AccessStructure.Profiles_ID#'
</cfquery>
</cfif>

<cfset SpendingCapVersion = appSettings.getSpendingCapVersion() />
<cfset doPaging = 0 />
<cfif ApprovalAmounts.Cont_Prog_View_Margins IS 1>

<cfif massapproval EQ 0>

<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>
</cfif>

<!---Can the user even view the margin?--->
<cfparam name="DisplayDetails" default="0">
<cfif URL.Group_ID EQ "">

	<cfif SpendingCapVersion EQ 0>

		<!---Stored proc that updates data used in this page--->
		<CFSTOREDPROC PROCEDURE="GET_PROFIT_MARGIN" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(Contract_Main_ID)#" NULL="No">
		</CFSTOREDPROC>

 	<cfelse>
		
		<!---Stored proc that updates data used in this page--->
		<CFSTOREDPROC PROCEDURE="SPENDING_CAP_MARGIN" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="PGM_ID" VALUE="#trim(Contract_Main_ID)#" NULL="No">
		</CFSTOREDPROC>

 	</cfif>

</cfif>

<!---  the user can only view the margins not trying to approve --->
<CFIF BasicProgramInformation.Contract_Status_Type_IDX GTE 3>
	<CFSET AreThereAnyFailures = 1>
</CFIF> 

<cfset ApprovalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager") />
<cfset approvalGroupType = ApprovalGroupManager.getGroupTypeInfo() />
<cfset prodHierLevel = approvalGroupType.prodHierLevel>

<cfset NumberofDaysinProgram = abs(DateDiff('d', BasicProgramInformation.Contract_End_Date, BasicProgramInformation.Contract_Start_Date)) + 1>



<cfoutput query="BasicProgramInformation">
<table width="95%" border="0" cellpadding="0" cellspacing="0">
<tr><td><strong>Program Name:</strong></td><td><strong>#Contract_Title#</strong></td><td>&nbsp; </td></tr>
<tr><td><strong>Program Number:</strong></td><td><strong>#Contract_Number#</strong></td><td>&nbsp; </td></tr>
<tr><td><strong>Program Dates:</strong></td><td> <strong>#dateformat(Contract_Start_Date, 'MM/DD/YYYY')# - #dateformat(Contract_End_Date, 'MM/DD/YYYY')#</strong></td><td><em>All values are per pound</em> </td></tr>
<cfif URL.Group_ID NEQ "">
<cfset groupValues = ApprovalGroupManager.getGroupAccessValues(URL.Group_ID) />
<tr><td><strong>#approvalGroupType.Label#:</strong></td><td> <strong>#groupValues.Group_Name#</strong></td><td>&nbsp;</td></tr>
</cfif>



<!---Is the program a revision?--->
<!--- decide if this program is a revision of an existing one --->
<CFSET Program_Is_A_Revision = 0>
<CFIF len(trim(BasicProgramInformation.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(BasicProgramInformation.Revision_of_Contract_Main_ID)) NEQ 0>
	<CFSET Program_Is_A_Revision = 1>
	<tr><td colspan="3" align="center" style="color:red">*** NOTE: This Is A Revision Of An Existing Program ***
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND getProgramInfo.Auto_Renew><!----- If auto renew is on, check if the parent program had auto renew on, if yes, did it already renew? ----->
		<cfif objProgram.getAutoRenewStatus(getProgramInfo.Contract_Number) EQ 1>
		<br>An auto renewed version of this program already exists. <br>The changes getting approved in this revision will not be reflected in that auto renewed program.
		</cfif>
	</cfif>
	</td></tr>
</CFIF>
</table>
</cfoutput>

<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
<cfset bIsAllProductProgram = ProductGroupManager.isAllProductProgram(Contract_Main_ID) />
<cfset bAllDistributorProgram = CreateObject("component", "components.programs.distributors.DistributorGroupManager").isAllDistributorProgram(Contract_Main_ID)>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////                  ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<hr color="orange" width="95%" align="left">
<cfoutput>
<form action="program_approval.cfm?CID=#URL.CID#&Group_ID=#URL.Group_ID#" method="post" name="frmPaging" style="disply:inline;">
</cfoutput>
<cfif bIsAllProductProgram>
<TABLE WIDTH="99%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="1">
<TR>
	<TD style="color:red;font-size:13px;font-weight:bold;">All products selected. Information not available.</TD>
</TR>
</TABLE>
<cfelse>

<table width="95%" border="0" cellpadding="2" cellspacing="0" class="maintable">
<!---Select all the items in the program--->

<cfset displayAtGroupLevel = SpendingCapVersion />
<cfif URL.Group_ID NEQ "">
	<cfset doPaging = 1 />
	<cfset displayAtGroupLevel = 0 />
</cfif>


<cfif NOT displayAtGroupLevel> 
	<!--- For type code, type group and product hierarchy --->
	<cfquery name="GetAllItems" datasource="#application.datasource#">
		SELECT 	DISTINCT Contract_Products.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, BSA_Foodservice_Items_Master.Net_Weight, Margin_Group_Profile_Approval_Margins.Amount AS ItemApprovalAmount				
		FROM 	Contract_Products
				INNER JOIN BSA_Foodservice_Items_Master
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
				<cfif prodHierLevel GT 0>
				<!------ If the approval is not based on the last product hierarchy level, have to join with parent hierarchies. ----->
				<!------ Only the last level id is stored in the product master ----->
					<cfset qGetProductHierarchyLevels = CreateObject("component", "components.products.Group.DataManager").getDistinctHierarchyLevel(getMaxLevel=1) />
					<cfset maxProdHierLevel = qGetProductHierarchyLevels.Product_Hierarchy_Level>
					<cfif prodHierLevel NEQ maxProdHierLevel>
						<cfloop index="thisProdHierLevel" from="#maxProdHierLevel#" to="#Evaluate(prodHierLevel+1)#" step="-1">
						LEFT JOIN Product_Hierarchy ph#thisProdHierLevel#
						ON	ph#thisProdHierLevel#.Deleted = 0
						AND ph#thisProdHierLevel#.Product_Hierarchy_Level = #thisProdHierLevel#
						AND ph#thisProdHierLevel#.Product_Hierarchy_ID = 
							<CFIF thisProdHierLevel EQ 6>BSA_Foodservice_Items_Master.Product_Hierarchy_ID
							<CFELSE>ph#Evaluate(thisProdHierLevel+1)#.Parent_Product_Hierarchy_ID
							</CFIF>
						</cfloop>
					</cfif>
				</cfif>				
				LEFT JOIN Margin_Group_Any_Group
				ON 
				Margin_Group_Any_Group.Group_ID = 
					<CFIF prodHierLevel EQ 0 OR prodHierLevel EQ maxProdHierLevel>
					BSA_Foodservice_Items_Master.#approvalGroupType.IDField#
					<CFELSE>
					ph#Evaluate(prodHierLevel+1)#.Parent_Product_Hierarchy_ID
					</CFIF>
				AND Margin_Group_Any_Group.Deleted = 0
				AND Margin_Group_Any_Group.Group_Type = #application.returned_customer_setting.approval_on_type_code#
				LEFT JOIN Margin_Group_Profile_Approval_Margins
				ON Margin_Group_Profile_Approval_Margins.Group_ID = Margin_Group_Any_Group.Margin_Group_ID
				AND Approval_Method = 4
				AND Profile_ID = #request.AccessStructure.Profiles_ID#								
		WHERE 	Contract_Products.Contract_Main_ID = #Contract_Main_ID#
				AND Contract_Products.Is_Group = 0
				<cfif URL.Group_ID NEQ "">
				AND Margin_Group_Any_Group.Group_ID = '#URL.Group_ID#'
				</cfif>
		ORDER BY BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, Contract_Products.BSA_Foodservice_Items_Master_ID,  BSA_Foodservice_Items_Master.Net_Weight, ItemApprovalAmount
	</cfquery>


<!---Should get the volume from this somehow--->
<cfsilent>
	<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
	<CFSET Program_Volume.Load_Basic_Information(Contract_Main_ID, request.AccessStructure.Company_Main_ID)>			
</cfsilent>

<CFSET Program_Volume.Get_Product_List(0, 1)>
<cfif NOT Program_Volume.defaultUOT.getMultiplier()>
	<cfset Program_Volume.defaultUOT.setMultiplier(Program_Volume.Contract_Span) />
</cfif>
<!---includes a script used by total_allowance.cfm--->
<!--- <cfinclude template="/common_files/contracts/makeNumeric.cfm"> --->


<!---For each item in the program--->
<cfoutput>
<tr bgcolor="lightsteelblue">
	<td class="tableheaders">#application.returned_customer_setting.item_label#</td>
	<td class="tableheaders" align="right" nowrap>&nbsp; &nbsp; #Program_Volume.defaultUOT.getDesc()# Volume</td>
	<cfif UseFloorPrice IS 1><td class="tableheaders" align="right" nowrap>&nbsp; &nbsp; Floor Price</td></cfif>
	<td class="tableheaders" align="right" nowrap>&nbsp; &nbsp; Total Allowance</td>
	<td class="tableheaders" align="right" nowrap>&nbsp; &nbsp; Approval Amount</td>
	<td class="tableheaders">&nbsp; </td>
</tr>
</cfoutput>
<cfset BGColor = 0>
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// The display Level1 loop ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cfset maxRows = 13 />
<cfif NOT doPaging>
	<cfset maxRows = GetAllItems.recordCount />
</cfif>
<cf_Number_of_Rows maxrows="#maxRows#">
<cfset endRow = StartRow + MaxRows - 1 />
<cfloop query="GetAllItems" startrow="#StartRow#" endrow="#endRow#">
	
	<cfif len(trim(ItemApprovalAmount)) IS 0>
			<cfset IApprovalAmount = 0>
	<cfelse>
			<cfset IApprovalAmount = ItemApprovalAmount>
	</cfif>
	
	<!------ Total_Product_Volume is in the default UOT (Daily/weekly/monthly/etc.) ----->
	<CFSET Total_Product_Volume = Program_Volume.GetProductVolume(GetAllItems.BSA_Foodservice_Items_Master_ID)> 
	
	
	<!---Calculates the allowance for the item--->
	<cfinclude template="/common_files/contracts/total_allowance.cfm">
	
	<cfoutput>
	<cfif GetContractProductInfo.Recordcount GT 0>
	
	<tr BGCOLOR="#IIf(BGColor IS 0, DE('ffffff'), DE('C6FFC6'))#">
	<cfif BGColor IS 0>
		<cfset BGColor=1>
	<cfelse>
		<cfset BGColor=0>
	</cfif>
	<td>#Description#<br>#Item#</td>
	
		
	<!---Volume per week from Saru's current stored proc?--->
	<td align="right">
	<cfif BasicProgramInformation.Contract_Quantity_UOM_IDX IS 1>	
		<cfset Total_Product_Volume = Total_Product_Volume * Net_Weight>
	</cfif>
		#numberformat(round(Total_Product_Volume), '___,___,__,__')# lb/#Program_Volume.defaultUOT.getNounDesc()#
	
	</td>
	
	<cfif UseFloorPrice IS 1>
	<td align="center">
		<cfif FailedFloorTest IS 1>
			<cfset AreThereAnyFailures = 1>
			&nbsp; &nbsp; <img src="/images/no_small.gif">
		<cfelse>
			&nbsp; &nbsp; <img src="/images/yes_small.gif">
		</cfif>
	</td>
	</cfif>
	
	<td align="right" width="100"><a href="javascript:void();" onclick="NewWindow('/common_files/contracts/total_allowance.cfm?Contract_Main_ID=#Contract_Main_ID#&BSA_Foodservice_Items_Master_ID=#BSA_Foodservice_Items_Master_ID#&DisplayDetails=1','allowance','600','250','Yes', 'No');return false;" TITLE="Allowance Calculation..."><cfif TotalAllowance LT 0><font color="red"></cfif>$#numberformat(TotalAllowance, '___,___,___,___.____')#<cfif TotalAllowance LT 0></font></cfif></a></td>
	
	<td align="right" width="100"><cfif isNumeric(IApprovalAmount)>$#numberformat(IApprovalAmount, '___,___,___,___.____')#<cfelse>#IApprovalAmount#</cfif></td>
	
	<!---Spending cap -- if allowance total greater than user's total, fail. Otherwise succeed--->
	<td align="right" >
	<cfif UseFloorPrice IS NOT 1>
				<cfset FailedFloorTest = 0>
		</cfif>
	
	
		<cfif (IApprovalAmount GTE TotalAllowance OR IApprovalAmount IS "*") AND FailedFloorTest IS 0>
			<img src="/images/yes_small.gif">
		<cfelse>
			<img src="/images/no_small.gif">
			<cfset AreThereAnyFailures = 1>
		</cfif></td>
	</tr>		
	</cfif>
	</cfoutput>
</cfloop>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// The display Level1 loop ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfelse>


<!--- For type code, type group and product hierarchy --->
	<cfquery name="GetAllItems" datasource="#application.datasource#">
		SELECT 	DISTINCT 
				#approvalGroupType.tableName#.#approvalGroupType.IDField# As Group_ID,
				#approvalGroupType.tableName#.#approvalGroupType.NameField# As Group_Name,
				Margin_Group_Profile_Approval_Margins.Amount AS ItemApprovalAmount,
				SUM(V_Program_Product_Discount.Total_Discount) Total_Allowance,
				SUM(CASE 
				WHEN Margin_Group_Profile_Approval_Margins.Amount = '*' THEN 0
				WHEN V_Program_Product_Discount.Total_Discount > CAST(Margin_Group_Profile_Approval_Margins.Amount AS Float) THEN 1	
				ELSE 0
				END) As AnyProductWithExtraDiscount
		FROM 	V_Program_Product_Discount
				INNER JOIN BSA_Foodservice_Items_Master
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = V_Program_Product_Discount.BSA_Foodservice_Items_Master_ID
				<cfif prodHierLevel GT 0>
				<!------ If the approval is not based on the last product hierarchy level, have to join with parent hierarchies. ----->
				<!------ Only the last level id is stored in the product master ----->
					<cfset qGetProductHierarchyLevels = CreateObject("component", "components.products.Group.DataManager").getDistinctHierarchyLevel(getMaxLevel=1) />
					<cfset maxProdHierLevel = qGetProductHierarchyLevels.Product_Hierarchy_Level>
					<cfif prodHierLevel NEQ maxProdHierLevel>
						<cfloop index="thisProdHierLevel" from="#maxProdHierLevel#" to="#Evaluate(prodHierLevel+1)#" step="-1">
						INNER JOIN Product_Hierarchy ph#thisProdHierLevel#
						ON	ph#thisProdHierLevel#.Deleted = 0
						AND ph#thisProdHierLevel#.Product_Hierarchy_Level = #thisProdHierLevel#
						AND ph#thisProdHierLevel#.Product_Hierarchy_ID = 
							<CFIF thisProdHierLevel EQ maxProdHierLevel>BSA_Foodservice_Items_Master.Product_Hierarchy_ID
							<CFELSE>ph#Evaluate(thisProdHierLevel+1)#.Parent_Product_Hierarchy_ID
							</CFIF>
						</cfloop>
					</cfif>
				</cfif>
				<!------  ----->
				INNER JOIN #approvalGroupType.tableName#
				ON #approvalGroupType.tableName#.#approvalGroupType.IDField# = 
					<CFIF prodHierLevel EQ 0 OR prodHierLevel EQ maxProdHierLevel>
					BSA_Foodservice_Items_Master.#approvalGroupType.IDField#
					<CFELSE>
					ph#approvalGroupType.prodHierLevel+1#.Parent_Product_Hierarchy_ID
					</CFIF>
				LEFT JOIN Margin_Group_Any_Group
				ON 
				Margin_Group_Any_Group.Group_ID = 
					<CFIF prodHierLevel EQ 0 OR prodHierLevel EQ maxProdHierLevel>
					BSA_Foodservice_Items_Master.#approvalGroupType.IDField#
					<CFELSE>
					ph#Evaluate(prodHierLevel+1)#.Parent_Product_Hierarchy_ID
					</CFIF>
				AND Margin_Group_Any_Group.Deleted = 0
				AND Margin_Group_Any_Group.Group_Type = #application.returned_customer_setting.approval_on_type_code#
				LEFT JOIN Margin_Group_Profile_Approval_Margins
				ON Margin_Group_Profile_Approval_Margins.Group_ID = Margin_Group_Any_Group.Margin_Group_ID
				AND Approval_Method = 4
				AND Profile_ID = #request.AccessStructure.Profiles_ID#				
		WHERE 	V_Program_Product_Discount.Contract_Main_ID = #Contract_Main_ID#
		Group By #approvalGroupType.tableName#.#approvalGroupType.IDField#, #approvalGroupType.tableName#.#approvalGroupType.NameField#, Margin_Group_Profile_Approval_Margins.Amount
		ORDER BY Group_Name
	</cfquery>
	
	<cfoutput>
	<tr bgcolor="lightsteelblue">
		<td class="tableheaders" colspan="2">#approvalGroupType.Label#</td>
		<td class="tableheaders" align="right">&nbsp; Total Allowance</td>
		<td class="tableheaders" align="right" nowrap>&nbsp; &nbsp; Approval Amount</td>
		<td class="tableheaders" align="right">&nbsp; </td>
	</tr>
	
	<cfloop query="GetAllItems">
		<tr style="cursor:pointer;" onclick="NewWindow('/common_files/contracts/program_approval.cfm?CID=#url.CID#&Group_ID=#Group_ID#','Product_Detail_#Replace(Group_ID, "-", "_", "all")#','650','650','Yes', 'Yes');return false;">
			<td colspan="2">#Group_Name#&nbsp;</td>
			<td align="right">#NumberFormat(Total_Allowance, "_.____")#&nbsp;</td>			
			<td align="right"><cfif isNumeric(ItemApprovalAmount)>#NumberFormat(ItemApprovalAmount, "_.____")#<cfelse>*</cfif>&nbsp;</td>
			<td align="right">
			<cfif AnyProductWithExtraDiscount>
			<img src="/images/no_small.gif" title="Some of the products exceed your approval limit, click to see details.">
			<cfset AreThereAnyFailures = 1>
			<cfelse>
			<img src="/images/yes_small.gif">
			</cfif>
			</td>
		</tr>
	</cfloop>
	
	</cfoutput>
</cfif>
<!--- </table> --->


<cfif URL.Group_ID EQ "">

<!------
Addtional profile setting for Program LS Cap approval level (Total_LS_Approval_Amount)
----->
<cfset TotalLSApprovalAmount = ApprovalAmounts.Total_LS_Approval_Amount>
<cfset TotalProgramLS = 0 />

<!---Begin Lump Sums--->

<tr><td colspan="100%" style="border-bottom: none;"><hr color="orange" width="100%" align="left"></td></tr>
<!--- <table width="95%" border="0" cellpadding="2" cellspacing="0" class="maintable"> --->

<!---Get all regular lump sums--->
<cfquery name="GetRegularLumpsums" datasource="#application.datasource#">
SELECT Program_Lump_Sums.Lump_Sum_Amount, Program_Lump_Sum_Name.Program_Lump_Sum_Name, Profile_LS_Approval.Approval_Amount
FROM Program_Lump_Sums
	INNER JOIN Program_Lump_Sum_Name
	ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
	AND Program_Lump_Sum_Name.Active = 1
	INNER JOIN Profile_LS_Approval
	ON Profile_LS_Approval.Program_Lump_Sum_Name_ID = Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID
	AND Profiles_ID = '#request.AccessStructure.Profiles_ID#'
WHERE Program_Lump_Sums.Program_ID = #Contract_Main_ID#
AND Program_Lump_Sums.Deleted = 0
</cfquery>

<cfif GetRegularLumpsums.Recordcount GT 0>
<!----Normal Lump Sums--->
<tr><td colspan="100%" class="tableheaders" bgcolor="lightsteelblue"><strong><cfoutput>#Application.LumpsumLabel#</cfoutput></strong></td></tr>
<cfloop query="GetRegularLumpsums">
<cfoutput>
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td colspan="2">#Program_Lump_Sum_Name#</td>
	<td align="right">$#numberformat(Lump_Sum_Amount, '___,___,___,___.____')#</td>
	<td align="right"><cfif isNumeric(Approval_Amount)>$#numberformat(Approval_Amount, '___,___,___,___.____')#<cfelse>#Approval_Amount#</cfif></td>
	<td align="right" ><cfif Approval_Amount GTE Lump_Sum_Amount OR Approval_Amount IS "*"><img src="/images/yes_small.gif"><cfelse><img src="/images/no_small.gif" title="Your approval amount is #LSCurrencyFormat(Approval_Amount)#"><cfset AreThereAnyFailures = 1></cfif>&nbsp; </td>
</tr>
</cfoutput>
<cfset TotalProgramLS = TotalProgramLS + Lump_Sum_Amount />
</cfloop>

<tr><td colspan="100%"><hr color="orange"></td></tr>

</cfif>

<!---Get all inactive lump sums--->
<cfquery name="GetInactiveLumpsums" datasource="#application.datasource#">
SELECT ISNULL(Program_Lump_Sums.Lump_Sum_Amount, 0) as Lump_Sum_Amount, Program_Lump_Sum_Name.Program_Lump_Sum_Name
FROM Program_Lump_Sums
	INNER JOIN Program_Lump_Sum_Name
	ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
	AND Program_Lump_Sum_Name.Active = 0
WHERE Program_Lump_Sums.Program_ID = #Contract_Main_ID#
AND Program_Lump_Sums.Deleted = 0
</cfquery>

<cfif GetInactiveLumpsums.Recordcount GT 0>
<!----Inactive Lump Sums--->

<cfset InactiveApprovalAmount = ApprovalAmounts.Inactive_LS_Approval_Amount>

<tr><td colspan="100%" class="tableheaders" bgcolor="lightsteelblue"><strong><cfoutput>Inactive #Application.LumpsumLabel#</cfoutput></strong></td></tr>
<cfloop query="GetInactiveLumpsums">
<cfoutput>
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td colspan="2">#Program_Lump_Sum_Name#</td>
	<td align="right">$#numberformat(Lump_Sum_Amount, '___,___,___,___.____')# </td>
	<td align="right"><cfif isNumeric(InactiveApprovalAmount)>$#numberformat(InactiveApprovalAmount, '___,___,___,___.____')#<cfelse>#InactiveApprovalAmount#</cfif></td>
	<td align="right"><cfif InactiveApprovalAmount GTE Lump_Sum_Amount OR InactiveApprovalAmount IS "*"><img src="/images/yes_small.gif"><cfelse><img src="/images/no_small.gif" title="Your approval amount is #LSCurrencyFormat(InactiveApprovalAmount)#"><cfset AreThereAnyFailures = 1></cfif></td>
</tr>
</cfoutput>
<cfset TotalProgramLS = TotalProgramLS + Lump_Sum_Amount />
</cfloop>

<tr><td colspan="100%"><hr color="orange"></td></tr>

</cfif>

<cfif GetRegularLumpsums.Recordcount GT 0 OR GetInactiveLumpsums.Recordcount GT 0>
<!------ Total Program lump sum ----->
<cfoutput>
<tr BGCOLOR="cccccc">
	<td colspan="2" id="header"><B>Total program #LCase(Application.LumpsumLabel)#</B></td>
	<td align="right">$#numberformat(TotalProgramLS, '___,___,___,___.____')# </td>
	<td align="right"><cfif isNumeric(TotalLSApprovalAmount)>$#numberformat(TotalLSApprovalAmount, '___,___,___,___.____')#<cfelse>#TotalLSApprovalAmount#</cfif></td>
	<td align="right"><cfif TotalLSApprovalAmount GTE TotalProgramLS OR TotalLSApprovalAmount IS "*"><img src="/images/yes_small.gif"><cfelse><img src="/images/no_small.gif" title="Your total program #LCase(Application.LumpsumLabel)# approval amount is #LSCurrencyFormat(TotalLSApprovalAmount)#"><cfset AreThereAnyFailures = 1></cfif>&nbsp;</td>
</tr>
<tr><td colspan="100%"><hr color="orange"></td></tr>
</cfoutput>
</cfif>


<cfset GrowthApprovalAmount = ApprovalAmounts.Lump_Sum_Approval_Amount>

<!---Get all growth lump sums--->
<cfquery name="GetGrowthLumpSums" datasource="#application.datasource#">
SELECT Program_Growth_Component_Tiers.Growth_Amount, Program_Growth_Components.Component_Name
FROM Program_Growth_Component_Tiers
	INNER JOIN Program_Growth_Components
	ON Program_Growth_Components.Program_Growth_Component_ID = Program_Growth_Component_Tiers.Program_Growth_Component_ID
	AND Program_Growth_Components.Deleted = 0
WHERE Program_Growth_Component_Tiers.Tier_Number = 1
AND Program_Growth_Component_Tiers.Program_ID = #Contract_Main_ID#
</cfquery>

<cfif GetGrowthLumpSums.Recordcount GT 0>
<!----Growth lump sums--->
<tr><td colspan="100%" class="tableheaders" bgcolor="lightsteelblue"><strong>Growth <cfoutput>#Application.LumpsumLabel#s</cfoutput></strong></td></tr>
<cfloop query="GetGrowthLumpSums">
<cfoutput>
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td colspan="2">#Component_Name#</td>
	<td align="right">$#numberformat(Growth_Amount, '___,___,___,___.____')#</td>
	<td align="right"> <cfif isNumeric(GrowthApprovalAmount)>$#numberformat(GrowthApprovalAmount, '___,___,___,___.____')#<cfelse>#GrowthApprovalAmount#</cfif></td>
	<td align="right" >
	
		<cfif GrowthApprovalAmount GTE Growth_Amount OR GrowthApprovalAmount IS "*">
			<img src="/images/yes_small.gif">
		<cfelse>
			<img src="/images/no_small.gif" title="Your approval amount is #LSCurrencyFormat(GrowthApprovalAmount)#">
			<cfset AreThereAnyFailures = 1>
		</cfif>
	</td>
</tr>
</cfoutput>
</cfloop>

</cfif>

<!---End of growth table--->
</cfif>


</table>
<!---If this is a revision, do the date thing--->
</cfif>
	<cfif doPaging>
	<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
		<CF_Next_Previous_For_Forms
		formname="frmPaging"
		query="GetAllItems"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	<cfoutput>
	<input type="hidden" name="startrow" value="#startrow#" />
	<input type="hidden" name="frompage" value="#frompage#" />
	</cfoutput>
	</cfif>
</form>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////                  ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<FORM ACTION="contract_Approve_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<CFOUTPUT>		
<cfset useLakebaseForGetRevisionParentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetRevisionParentInfo>
	<cftry>
		<cfset GetRevisionParentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#BasicProgramInformation.Revision_of_Contract_Main_ID#",
				"select" = "contract_end_date,contract_start_date"
			}), "contract_end_date,contract_start_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetRevisionParentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetRevisionParentInfo>
<CFQUERY NAME="GetRevisionParentInfo" datasource="#application.datasource#">
		SELECT 	Contract_End_Date, 
				Contract_Start_Date
		FROM 	Contract_Main
		WHERE 	Contract_Main_ID = '#BasicProgramInformation.Revision_of_Contract_Main_ID#'
	</CFQUERY>
</cfif>		
 <CFIF Program_Is_A_Revision EQ 1>
			
		
<cfparam name="form.allowRetroRevision" default=0 />
<cfparam name="form.allowedStartDate" default=0 />

	<cfif BasicProgramInformation.Contract_Status_Type_IDX EQ 2 AND ((NOT bIsAllProductProgram AND NOT bAllDistributorProgram) OR ApprovalAmounts.Approve_All_Products_Program IS 1)>
	
		<!---if program allows retro revisions then show and set valid start date--->
		<cfif getProgramSettngs.Allow_Retro_Revision eq 1>
				
			<cfset form.allowRetroRevision = 1 />
					
			<cfset form.allowedStartDate = DateAdd("d", - getProgramSettngs.Allow_Retro_Revision_Span, Now()) /> 
			<!---if the validStartDate is less than the parent start date then use the revision start date as the valid start date--->
			<!--- The logic below has been taken out due to request by conagra (6/29/2005) --->
			<!--- 
				<cfif DateCompare(form.allowedStartDate, GetRevisionParentInfo.Contract_Start_Date) neq 1>
				<cfset form.allowedStartDate = GetRevisionParentInfo.Contract_Start_Date /> 
			</cfif>
			--->
		</cfif>
	</CFIF>
	
</CFIF> 

</CFOUTPUT>

<CFIF Program_Is_A_Revision EQ 1>			
	<INPUT NAME="Program_Is_A_Revision" TYPE="Hidden" VALUE="1">
<CFELSE>
	<input type="hidden" name="Pay_Brokerage" value="1">
</cfif>
		
	<INPUT NAME="APPROVECONTRACT" TYPE="Hidden" VALUE="<CFOUTPUT>#url.CID#</CFOUTPUT>">
	
</FORM>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif appSettings.getRFAAgree()>	
<cfinclude template="users_agreed.cfm">
</CFIF>



<!------ 
Include file which checks for the program levels checks to
stop the user from requesting approval and also approval.
----->

<cfinclude template="common_approval_check.cfm">
<DIV>
<cfif NOT letUserProceed>
	<cfset AreThereAnyFailures = 1 />
</cfif>

<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2>
	<cfinclude template="contract_lumpsum_balance_info.cfm">	
</cfif>

<cfoutput>
<center>
<font color="red">
<cfif ArrayLen(messageArray) GT 0>
<cfloop index="i" from="1" to="#ArrayLen(messageArray)#">
	#messageArray[i]#<br>
</cfloop>
</cfif>
</font>
</center>
<BR>
<cfif ApprovalAmounts.Cont_Prog_Approval_Rights IS 0>
	<cfset AreThereAnyFailures = 1 />
</cfif>

<cfif Customerrequired EQ 1 OR Operatorrequired EQ 1>
	<cfset displayagreed = 0 />
</cfif>
 
<cfif approvaltype EQ 0>
	<cfif getagreeTypes.recordcount GT 0>
		<cfset AreThereAnyFailures = 1>
		<cfset displayagreed = 1>
	<cfelse>
	<cfset displayagreed = 0>
	</cfif>
</cfif>

<TABLE ALIGN="center"><TR><TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"printPage()"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"print"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</TD>
		<TD>&nbsp; &nbsp;&nbsp;&nbsp;</TD>
		<!------ Does the user have approval rights/ and is the program in approvable status ----->
		<cfif URL.GROUP_ID NEQ "" OR BasicProgramInformation.Contract_Status_Type_IDX NEQ 2 OR AreThereAnyFailures IS 1 OR ((bIsAllProductProgram OR bAllDistributorProgram) AND ApprovalAmounts.Approve_All_Products_Program IS 0)>
			<!------ Even after having approval rights, is the user cannot approve, show agree/agreed ----->

			<CFIF AreThereAnyFailures EQ 1 AND displayagreed EQ 1 and URL.GROUP_ID EQ "" AND BasicProgramInformation.Contract_Status_Type_IDX EQ 2>
			<TD>
			<cfset letuserapprove = 0>
				<cfif useragreed EQ 0>
				<CF_button
					button_name		=	""
					button_caption	=	"I Agree"
					button_action	=   "agreeProgram()"
					button_type		=	"javascript_link"
					button_width	=	"130"
					button_color	=	"Navy"
					button_tip		=	"Agree"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
				<cfelse>
				<cfset letuserapprove = 0>
				<CF_button
					button_name		=	""
					button_caption	=	"Agreed"
					button_action	=   ""
					button_type		=	""
					button_width	=	"130"
					button_color	=	"Navy"
					button_tip		=	"Agree"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
				</cfif>		
			</TD>		
			<TD>&nbsp; &nbsp;&nbsp;&nbsp;</TD>
			</CFIF>
			<TD>

			<CF_button
				button_name		=	""
				button_caption	=	"close this window"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"130"
				button_color	=	"Navy"
				button_tip		=	"close this window"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
			</TD>
		<cfelse>
			<cfset LetUserApprove = 1>
			<TD><span class="error_ContractSpan"></span>
			<CF_button
				button_name		=	"approve"
				button_caption	=	"approve this program"
				button_action	=	"approveProgram(1, 'approve_table')"
				button_type		=	"javascript_link"
				button_width	=	"130"
				button_color	=	"Navy"
				button_tip		=	"approve program"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
			</TD>
		</cfif>
		</TR>		
		</TABLE>
		</DIV>
		
		</cfoutput>
		
<!---View margins--->
<cfelse>
	You do not have permission to view margins.
</cfif>
</body></html>
		<CF_MessageWindow>			
		<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
		<script>
			function approveProgram(disableClickedButton, disableClickedButtonName){
				ErrorCount = 0;
				<CFIF Program_Is_A_Revision EQ 1>

					FromDate = new Date(<CFOUTPUT>#datepart('yyyy',BasicProgramInformation.Contract_Start_Date)#,#evaluate(datepart('m',BasicProgramInformation.Contract_Start_Date)-1)#,#datepart('d',BasicProgramInformation.Contract_Start_Date)#</CFOUTPUT>)
					ToDate = new Date(<CFOUTPUT>#datepart('yyyy',BasicProgramInformation.Contract_End_Date)#,#evaluate(datepart('m',BasicProgramInformation.Contract_End_Date)-1)#,#datepart('d',BasicProgramInformation.Contract_End_Date)#</CFOUTPUT>)
					
					DateToday = new Date()
					DateToday = new Date(DateToday.getFullYear(), DateToday.getMonth(),DateToday.getDate())
					
					//is retro revision allowed
					var bAllowRetroRevision = <cfoutput>#form.allowRetroRevision#</cfoutput>;
					
					ParentEndDate = new Date(<CFOUTPUT>#datepart('yyyy',GetRevisionParentInfo.Contract_End_Date)#,#evaluate(datepart('m',GetRevisionParentInfo.Contract_End_Date)-1)#,#datepart('d',GetRevisionParentInfo.Contract_End_Date)#</CFOUTPUT>)
					//alert('<CFOUTPUT>#GetRevisionParentInfo.Contract_End_Date#</CFOUTPUT>')
					//alert(ParentEndDate)
					
					
					
					{	
						//TSF: Modification Retro Revision
						//if retroactive revisions are allowed then we must validate start date off of the allowd retroactive date
						if(bAllowRetroRevision != 1)
					<!--- 	{
							validDate = new Date(<CFOUTPUT>#datepart('yyyy',form.allowedStartDate)#,#evaluate(datepart('m',form.allowedStartDate)-1)#,#datepart('d',form.allowedStartDate)#</CFOUTPUT>)
							
							//is the from date before the allowed start date
							if(FromDate < validDate)
							{	
								ErrorCount++;
								queueMessage("Your program revision start date cannot be less than <cfoutput>#DateFormat(form.allowedStartDate, "mm/dd/yyyy")#</cfoutput>.", document.all.error_ContractSpan);
							
							}
							else
							{
								clearQueue(document.all.error_ContractSpan);
							}
						
						}
						else
						This logic scrapped by client request
						 --->
						{
							//is the from date before today
							if(FromDate < DateToday)
							{
								ErrorCount++;
								queueMessage("Your program revision must start today or later.", document.all.error_ContractSpan);
							}
							else
							{
								clearQueue(document.all.error_ContractSpan);
							}
						}
						
						if(ErrorCount == 0){
							<!--- The To Date Must Be After The From Date --->
							if(ToDate < FromDate){
								ErrorCount++;
								queueMessage("Your start date must be after your end date.", document.all.error_ContractSpan);
							}
							else{
								clearQueue(document.all.error_ContractSpan);
							}
						}
					

						if(ErrorCount == 0){												
							if(ToDate < FromDate){
								ErrorCount++;
								queueMessage("The end date must be after the start date", document.all.error_ContractSpan);
							}
							else{
								clearQueue(document.all.error_ContractSpan);
							}
						}
						<cfif trim(getProgramSettngs.Max_Duration) EQ 1>
							<CFOUTPUT>
							//var real_Program_Start_Date = new Date(#datepart('yyyy',GetRevisionParentInfo.Contract_Start_Date)#,#evaluate(datepart('m',GetRevisionParentInfo.Contract_Start_Date)-1)#,#datepart('d',GetRevisionParentInfo.Contract_Start_Date)#);							
							if(ErrorCount == 0)
							{
								numberOfDays = days_between(FromDate,ToDate);
								if(numberOfDays > parseInt(#trim(listgetat(getProgramSettngs.Max_Duration_Length, 1, "."))#)) {	
									ErrorCount++;
									queueMessage("The length of the program cannot exceed  #listgetat(trim(getProgramSettngs.Max_Duration_Length), 1, ".")# day(s)", document.all.error_ContractSpan)
								}
								else{
									clearQueue(document.all.error_ContractSpan);
								}
							}
							</CFOUTPUT>
						</CFIF>
					}
				<CFELSE>
				</CFIF>
				
				if(ErrorCount == 0){

					var ConfirmMessage = "Are you sure you want to approve this program?";
					
					if(confirm(ConfirmMessage)) 
					{
						programGettingApproved = 1;
						<cfif display_business_consideration >
							NewWindow('evaluationnotes.cfm?mode=6&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
						<cfelse>
							document.MyForm.submit()
						</cfif>
						if(disableClickedButton)
						{
							disableButton(disableClickedButtonName, true, false);		
						}
					}
				}
				else {
				
					showMessageWindow()
				}
			}

		<!--- Dev Note: KAL; 8891 ---> 
		function agreeProgram(){
			if(confirm("Are you sure you want to agree to this program ?")) {
				<cfif display_business_consideration>
					NewWindow('evaluationnotes.cfm?mode=7&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&agree=1&ProgramAgree=1','EvaluationNotes','1050','600','Yes', 'Yes');
				<cfelse>
					window.location.href = "program_agree_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>";
				</cfif>
			}
		}			
				
			
		function printPage()
		{
			window.print();
		}
		</script>