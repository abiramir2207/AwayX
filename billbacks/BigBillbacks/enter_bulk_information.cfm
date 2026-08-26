<!---Stuff you always put at the top of the doc --->
<cfset appSettings = application.appSettingsGet>
<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
<SCRIPT LANGUAGE="JavaScript" SRC="bigbillback.js"></SCRIPT>
<script language="javascript">
	window.parent.programs_tab.className="activeMenuItem";
	window.parent.current_menu_item = 'programs';
	window.parent.buildMenu();
</script>

<script>
function deletePriorRecords(BillbackID)
{
	confirm("Do you want to delete all prior big billback entries for this billback?")
	{
		var newLocation = "/billbacks/BigBillbacks/delete_big_billbacks.cfm?Billback_ID=" +  BillbackID;
		window.location = newLocation;
	}
}

function resumeVerification(BillbackID,BigBillbackID)
{
	newLocation = "/billbacks/BigBillbacks/bigbillback_validation.cfm?Billback_ID=" + BillbackID + "&Big_Billback_Summary_ID=" + BigBillbackID;
	window.location = newLocation;
}
</script>

<cfif isDefined("url.BBID")>
	<cfset form.Billback_ID = url.BBID>
</cfif>
<cfif isDefined("url.Billback_ID")>
	<cfset form.Billback_ID = url.Billback_ID>
</cfif>

<!---Queries regarding this page --->
<cfset useLakebaseForgetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetPayeeInfo>
	<cftry>
		<cfset getPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_payee_type_id"
			}), "billback_payee_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeInfo>
<cfquery name="getPayeeInfo" datasource="#Application.Datasource#">
	SELECT 	Billback_Payee_Type_ID
	FROM 	Billback
	WHERE 	Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>

<cfset getPayeeID.Payee_ID = billbackProgramManager.getPayeeID(form.Billback_ID,getPayeeInfo.Billback_Payee_Type_ID) />
<cfif getPayeeInfo.Billback_Payee_Type_ID EQ 4 AND getPayeeID.Payee_ID NEQ "">
	<cfset getPayeeInfo.Billback_Payee_Type_ID = 1 />
</cfif>
<cfset Payee_Type_ID = getPayeeInfo.Billback_Payee_Type_ID>

<cfparam name="form.Program_List" 			default="0">
<cfparam name="form.Discount_Type_ID" 		default="0">
<cfparam name="form.ComponentNameIDs" 			default="0">
<cfparam name="form.Component_Name" 		default="0">

<!---Changes the important values passed back from --->

<html>
<head>
	<title>Enter Big Billback Data Here</title>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<!---NOTE: All javascript is in bigbillback.js file --->

</head>

<body  BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<cfoutput>
<!---- SELECT PROGRAMS --->
<table border="0" width="750" cellpadding="0" cellspacing="2">
<form name="BigBillbackForm" action="enter_bulk_information.cfm" method="post">
<cfif form.Program_List IS 0>
<tr id="Program"><td align="left">

	<table border="0" cellspacing="0" cellpadding="0" align="left" class="topMenu" >
				<TR>

			<td width="50">
			<img src="/images/whitebg_programs.gif" alt="" border="0" onClick="SearchPrograms(1,'#getPayeeInfo.Billback_Payee_Type_ID#','#getPayeeID.Payee_ID#')" style="cursor: pointer;"></TD>
					<TD><a onClick="SearchPrograms(1,'#getPayeeInfo.Billback_Payee_Type_ID#','#getPayeeID.Payee_ID#')" style="cursor: pointer;" nowrap><strong>add&nbsp;program</strong></a><BR></td>

				</TR>
			</table>

		<input type="hidden" name="runsearchonfirstload" value="0">
		<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms" value="0">
		<input type="hidden" name="FilterType" 				value="#getPayeeInfo.Billback_Payee_Type_ID#">
		<input type="hidden" name="FilterDataList"			value="#getPayeeID.Payee_ID#">
		<input type="hidden" name="Data_Action_ID"	 id="Form_Action_ID" value="1">

</td></tr>
<cfelse>
<!---We have selected the program --->
<cfset useLakebaseForGetBasicProgramInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetBasicProgramInfo>
	<cftry>
		<cfset GetBasicProgramInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#form.Program_List#",
				"select" = "contract_number,contract_title,contract_start_date,contract_end_date"
			}), "contract_number,contract_title,contract_start_date,contract_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBasicProgramInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBasicProgramInfo>
<cfquery name="GetBasicProgramInfo" datasource="#application.datasource#">
Select Contract_Number, Contract_Title, Contract_Start_Date, Contract_End_Date
FROM Contract_Main WHERE Contract_Main_ID = '#form.Program_List#'
</cfquery>
</cfif>

<tr><td valign="top">
<span class="legend">Program:</span><br>
	#GetBasicProgramInfo.Contract_Title# (#GetBasicProgramInfo.Contract_Number#)<br>
	#dateformat(GetBasicProgramInfo.Contract_Start_Date, 'mm/dd/yyyy')# - #dateformat(GetBasicProgramInfo.Contract_End_Date, 'mm/dd/yyyy')#
<br>
<br>

<cfquery name="ExistingBigBillback" datasource="#application.datasource#">
SELECT TOP 1 Big_Billback_Summary.Big_Billback_Summary_ID FROM Big_Billback_Summary
	INNER JOIN Big_Billback
	ON Big_Billback.Big_Billback_Summary_ID = Big_Billback_Summary.Big_Billback_Summary_ID
	AND Big_Billback.Deleted = 0
WHERE Big_Billback_Summary.Program_ID = '#form.Program_List#'
AND Big_Billback_Summary.Billback_ID = '#form.Billback_ID#'
AND Big_Billback_Summary.Uploaded = 0
</cfquery>

<cfif ExistingBigBillback.Recordcount GT 0>

<table border="0" style="border-bottom: 1 solid ##cccccc; border-top: 1 solid ##cccccc; border-right: 1 solid ##cccccc; border-left: 1 solid ##cccccc;">
<tr><td colspan="2" valign="top">There are existing big billback entries for this program anything you enter below will be added to these records. Would you like to:</td></tr>
<tr><td valign="top"><CF_button
		button_name		=	""
		button_caption	=	"delete all prior records"
		button_action	=	"deletePriorRecords('#Billback_ID#')"
		button_type		=	"javascript_link"
		button_width	=	"200"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	></td><td valign="top"><CF_button
		button_name		=	""
		button_caption	=	"resume verifying records"
		button_action	=	"resumeVerification('#Billback_ID#','#ExistingBigBillback.Big_Billback_Summary_ID#')"
		button_type		=	"javascript_link"
		button_width	=	"200"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</td></tr></table>
<p></p>
</cfif>
</td>

</tr>

<cfquery name="GetAllContractMains" datasource="#application.datasource#">

SELECT 	Contract_Main_ID,
		isnull(Effective_Start_Date, Contract_Start_Date) AS Effective_Start_Date,
		isnull(Effective_End_Date, Contract_End_Date) AS Effective_End_Date
FROM Contract_Main
WHERE Contract_Number LIKE '%#GetBasicProgramInfo.Contract_Number#%'
AND Approved = 1
</cfquery>

<cfset ContractMainList = "">
<cfloop query="GetAllContractMains">
		<cfset ContractMainList = listappend(ContractMainList,GetAllContractMains.Contract_Main_ID)>
</cfloop>

<!--- Gotta get some value back! --->
<cfif listlen(ContractMainList) LT 1>
	<cfset ContractMainList = listqualify(GetAllContractMains.Contract_Main_ID, ',')>
</cfif>
<!---- END SELECT PROGRAMS --->
</cfif>

<cfif form.Program_List IS NOT 0 AND form.Discount_Type_ID IS 0>

<!--- Discounts to check> --->
<cfquery name="GetDistinctDiscountTypes" datasource="#application.datasource#">
SELECT DISTINCT Product_Type_ID
FROM Contract_Products
WHERE Contract_Products.Contract_Main_ID IN (#ContractMainList#)
AND Contract_Products.Deleted = 0
</cfquery>

<!--- This only returns discount types where there is a component with that payee type --->
<cfset programDiscountTypes = "">
<cfloop query="GetDistinctDiscountTypes">
	<cfswitch expression="#Product_Type_ID#">
		<!--- Has fixed --->
		<cfcase value="1">
			<cfquery name="HasFixed" datasource="#application.datasource#">
			SELECT DISTINCT Program_Fixed_Component.Program_Fixed_Component_ID, Program_Fixed_Component_Name.Program_Fixed_Component_Name
				FROM Program_Fixed_Component
					INNER JOIN Program_Fixed_Component_Name
					ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
				WHERE Program_Fixed_Component.Program_ID IN (#ContractMainList#)
				AND Program_Fixed_Component.Deleted = 0
				AND (Program_Fixed_Component.Fixed_Component_Paid_To = #Payee_Type_ID#
					OR
						(Program_Fixed_Component.Fixed_Component_Paid_To = 4
							AND #Payee_Type_ID# != 3)
					)
			</cfquery>
			<cfif HasFixed.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "1")>
			</cfif>
		</cfcase>

		<!--- Has rebate --->
		<cfcase value="2">
			<cfquery name="Has_Rebate" datasource="#application.datasource#">
			SELECT DISTINCT
			Program_Rebates_Component_Name.Program_Rebates_Component_Name,
			Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component
				INNER JOIN Program_Rebates_Component_Name
				ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
			WHERE Program_Rebates_Component.Program_ID IN (#ContractMainList#)
			AND Program_Rebates_Component.Deleted = 0
			AND (Program_Rebates_Component.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Rebates_Component.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>
			<cfif Has_Rebate.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "2")>
			</cfif>
		</cfcase>

	<!--- 	<!--- Has lumpsum --->
		<cfcase value="3">
			<cfquery name="Has_Lumpsums" datasource="#application.datasource#">
			SELECT DISTINCT Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID,
			Program_Lump_Sum_Name.Program_Lump_Sum_Name
			FROM Program_Lump_Sums
				INNER JOIN Program_Lump_Sum_Name
				ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE Program_Lump_Sums.Program_ID IN (#ContractMainList#)
			AND Program_Lump_Sums.Deleted = 0
			AND (Program_Lump_Sums.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Lump_Sums.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>
			<Cfif Has_Lumpsums.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "3")>
			</CFIF>
		</cfcase> --->

		<!--- Has growth --->
		<cfcase value="4">
			<cfquery name="Has_Growth" datasource="#application.datasource#">
			SELECT Program_Growth_Components.Program_Growth_Component_ID,
			Program_Growth_Components_Name.Program_Growth_Components_Name
			FROM Program_Growth_Components
				INNER JOIN Program_Growth_Components_Name
				ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
			WHERE Program_Growth_Components.Program_ID IN (#ContractMainList#)
			AND Program_Growth_Components.Deleted = 0
			AND (Program_Growth_Components.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Growth_Components.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>
			<Cfif Has_Growth.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "4")>
			</CFIF>
		</cfcase>

		<!--- Has formula --->
		<cfcase value="5">
			<Cfset programDiscountTypes = listappend(programDiscountTypes, "5")>
		</cfcase>

		<cfcase value="10">
			<cfquery name="Has_BidRequest" datasource="#application.datasource#">
			SELECT DISTINCT
			Program_BidRequest_Component_Name.Program_BidRequest_Component_Name,
			Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID
			FROM Program_BidRequest_Component
				INNER JOIN Program_BidRequest_Component_Name
				ON Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID = Program_BidRequest_Component.Program_BidRequest_Component_Name_ID
			WHERE Program_BidRequest_Component.Program_ID IN (#ContractMainList#)
			AND Program_BidRequest_Component.Deleted = 0
			AND (Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>

			<Cfif Has_BidRequest.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "10")>
			</CFIF>

		</cfcase>

	</cfswitch>
</cfloop>

	<cfif len(Trim(programDiscountTypes)) LT 1>

	<tr id="Program"><td align="left">

	<table border="0" cellspacing="0" cellpadding="0" align="left" class="topMenu" >
	<tr><td colspan="100%"><font color="red"><strong>There were no discount types on this program that had a component where the payee type of this billback was also the payee of at least one component. Therefore there are no eligible discounts for this program. Please select a different program.</strong></font></td></tr>
				<TR>

			<td width="50">
			<img src="/images/whitebg_programs.gif" alt="" border="0" onClick="SearchPrograms(1,'#getPayeeInfo.Billback_Payee_Type_ID#','#getPayeeID.Payee_ID#')" style="cursor: pointer;"></TD>
					<TD><a onClick="SearchPrograms(1,'#getPayeeInfo.Billback_Payee_Type_ID#','#getPayeeID.Payee_ID#')" style="cursor: pointer;" nowrap><strong>add&nbsp;program</strong></a><BR></td>

				</TR>
			</table>

		<input type="hidden" name="runsearchonfirstload" value="0">
		<input type="hidden" name="FilterSearchPrograms" id="FilterSearchPrograms" value="0">
		<input type="hidden" name="FilterType" 				value="#getPayeeInfo.Billback_Payee_Type_ID#">
		<input type="hidden" name="FilterDataList"			value="#getPayeeID.Payee_ID#">
		<input type="hidden" name="Data_Action_ID"	 id="Form_Action_ID" value="1">
		<input type="hidden" name="Billback_ID" value="#form.Billback_ID#">
		<input type="hidden" name="Program_List" value="#form.Program_List#">

</td></tr>
</table>
</body></html>
<script>

 try { window.parent.dyniframesize(); } catch (err) { };

</script>
	<cfabort>
	</cfif>


	<cfquery name="DisplayProgramDiscountTypes" datasource="#application.datasource#">
	SELECT Discount_Type_ID, Discount_Type_Desc FROM Discount_Type
	WHERE Discount_Type_ID IN (#programDiscountTypes#)
	ORDER BY Discount_Type_ID DESC
	</cfquery>

<tr id="DiscountType"><td>


	<cfif DisplayProgramDiscountTypes.Recordcount GT 1>
	<span class="legend">Discount Type:</span><br>
	<!--- More than one discount type -- they have to pick --->
	<select name="Discount_Type_ID">
	<cfloop query="DisplayProgramDiscountTypes">
		<option value="#Discount_Type_ID#">#Discount_Type_Desc#</option>
	</cfloop>
	</select>
	<br><CF_smallLink
					title = "save discount type"
					url = "##"
					parameters = "onClick=""javascript: BigBillbackForm.submit();return false;"""
					>
	<cfelse>
	<!--- Only one discount type, automatically save --->
		<cfset form.Discount_Type_ID = DisplayProgramDiscountTypes.Discount_Type_ID>
	</cfif>
</td></tr>
</cfif>
<cfif form.Discount_Type_ID GT 0>
<tr><td>
	<cfquery name="DiscountDescription" datasource="#application.datasource#">
	SELECT Discount_Type_Desc FROM Discount_Type
	WHERE Discount_Type_ID = #form.Discount_Type_ID#
	ORDER BY Discount_Type_ID DESC
	</cfquery>
<span class="legend">Discount Type:</span><br>
	#DiscountDescription.Discount_Type_Desc#
	<br>
</td></tr>
</cfif>
<!--- End of discount type selection --->

<!--- Select component --->
<tr id="Component"><td>
<cfif form.Program_List IS NOT 0 AND form.Discount_Type_ID IS NOT 0>

 	<!---Go find the component --->
	<CFSWITCH expression="#form.Discount_Type_ID#">

		<!--- 1 = fixed price --->
		<cfcase value="1">
			<cfquery name="FindComponent" datasource="#application.datasource#">
			SELECT DISTINCT Program_Fixed_Component.Program_Fixed_Component_Name_ID AS Component_Name_ID, Program_Fixed_Component_Name.Program_Fixed_Component_Name AS Component_Name
			FROM Program_Fixed_Component
				INNER JOIN Program_Fixed_Component_Name
				ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID =
				Program_Fixed_Component.Program_Fixed_Component_Name_ID
			WHERE Program_Fixed_Component.Program_ID IN (#ContractMainList#)
			AND Program_Fixed_Component.Deleted = 0
			AND (Program_Fixed_Component.Fixed_Component_Paid_To = #Payee_Type_ID#
					OR
						(Program_Fixed_Component.Fixed_Component_Paid_To = 4
							AND #Payee_Type_ID# != 3)
					)
			<cfif form.ComponentNameIDs IS NOT 0>
			AND Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID IN (#form.ComponentNameIDs#)
			</cfif>
			</cfquery>
		</cfcase>
		<!--- end fixed price --->

		<!--- 2 = rebate --->
		<cfcase value="2">
			<cfquery name="FindComponent" datasource="#application.datasource#">
			SELECT DISTINCT Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID AS Component_Name_ID, Program_Rebates_Component_Name.Program_Rebates_Component_Name AS Component_Name
			FROM Program_Rebates_Component
				INNER JOIN Program_Rebates_Component_Name
				ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID =
				Program_Rebates_Component.Program_Rebates_Component_Name_ID
			WHERE Program_Rebates_Component.Program_ID IN (#ContractMainList#)
			AND Program_Rebates_Component.Deleted = 0
			AND (Program_Rebates_Component.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Rebates_Component.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			<cfif form.ComponentNameIDs IS NOT 0>
			AND Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID IN (#form.ComponentNameIDs#)
			</cfif>
			</cfquery>
		</cfcase>
		<!--- end rebate --->


		<!--- 4 = growth --->
		<cfcase value="4">
			<cfquery name="FindComponent" datasource="#application.datasource#">
			SELECT DISTINCT Program_Growth_Components_Name.Program_Growth_Components_Name_ID AS Component_Name_ID,
			Program_Growth_Components_Name.Program_Growth_Components_Name AS Component_Name
			FROM Program_Growth_Components
				INNER JOIN Program_Growth_Components_Name
				ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID =
				Program_Growth_Components.Program_Growth_Components_Name_ID
			WHERE Program_Growth_Components.Program_ID IN (#ContractMainList#)
			AND Program_Growth_Components.Deleted = 0
			AND (Program_Growth_Components.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Growth_Components.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			<cfif form.ComponentNameIDs IS NOT 0>
			AND Program_Growth_Components_Name.Program_Growth_Components_Name_ID IN (#form.ComponentNameIDs#)
			</cfif>
			</cfquery>
		</cfcase>
		<!--- end growth --->

		<!--- 10 = bid request --->
		<cfcase value="10">
			<cfquery name="FindComponent" datasource="#application.datasource#">
			SELECT DISTINCT program_bidrequest_component_Name.program_bidrequest_component_name_ID AS Component_Name_ID, program_bidrequest_component_Name.program_bidrequest_component_Name AS Component_Name
			FROM program_bidrequest_component
				INNER JOIN program_bidrequest_component_Name
				ON program_bidrequest_component_Name.program_bidrequest_component_Name_ID =
				program_bidrequest_component.program_bidrequest_component_Name_ID
			WHERE program_bidrequest_component.Program_ID IN (#ContractMainList#)
			AND program_bidrequest_component.Deleted = 0
			AND (Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			<cfif form.ComponentNameIDs IS NOT 0>
			AND program_bidrequest_component_Name.program_bidrequest_component_name_ID IN (#form.ComponentNameIDs#)
			</cfif>
			</cfquery>
		</cfcase>
		<!--- end formula --->

		<!--- Any other input has no component id --->
		<cfdefaultcase>
		<cfset FindComponent = QueryNew("Component_Name_ID, Component_Name")>
		<cfset temp = QueryAddRow(FindComponent)>
		 <cfset Temp = QuerySetCell(FindComponent, "Component_Name_ID", "1")>
		 <cfset Temp = QuerySetCell(FindComponent, "Component_Name", "NA")>

		</cfdefaultcase>
	</cfswitch>


	<cfif FindComponent.Recordcount GT 1 AND form.ComponentNameIDs IS 0>
	<span class="legend">Component/s:</span><br>

	<!--- More than one discount type -- they have to pick --->
	<table>
	<tr>
	<cfloop query="FindComponent">
	<td>
		<input type="checkbox" value="#Component_Name_ID#" name="ComponentNameIDs">#FindComponent.Component_Name#
	</td>
		<CFIF FindComponent.CURRENTROW MOD 4></TR><TR></CFIF>
	</cfloop>
	</table>
	<br><CF_smallLink
					title = "save component"
					url = "##"
					parameters = "onClick=""javascript: BigBillbackForm.submit();return false;"""
					>
	<cfelseif form.ComponentNameIDs IS 0>
	<!--- Only one discount type, automatically save --->
			<cfset form.ComponentNameIDs = FindComponent.Component_Name_ID>
	</cfif>
	</cfif>
	<!---Go find the component --->

	<cfif form.ComponentNameIDs IS NOT 0>
	<!--- seperates out the component name and ID --->
	<cfif len(trim(form.ComponentNameIDs)) GT 0 >

		<span class="legend">Component:</span><br>
		<table>
	<tr>
	<cfloop query="FindComponent">
	<td>
		#Component_Name#
	</td>
		<CFIF FindComponent.CURRENTROW MOD 4></TR><TR></CFIF>
	</cfloop>
	</table>

		<cfset form.ComponentNameIDs = ComponentNameIDs>
	</cfif>


</td></tr>
<!--- End component selection --->
</cfif>

<cfif form.Program_List IS NOT 0 AND form.Discount_Type_ID IS NOT 0 AND form.ComponentNameIDs IS NOT 0>
<tr id="BulkData"><td>
<span class="legend">Detail Data:</span> Copy and paste the data from your excel document here. (
<A href="BlacksmithBigBillbackEntry.xls" target="_blank">Click here to download</A> a blank excel meeting the format requirements)
<Br>
	<table width="700">
		<tr>
			<td align="center" ><strong>#application.returned_customer_setting.distributor_label_singular# Name</strong></td>
			<td align="center"><strong>Product Description</strong></td>
			<td align="center"><strong>
				Volume <!--- in 	<select name="Entry_UOM">
								<option value="1">Cases</option>
								<option value="2">Pounds</option>
							</select> --->
			</strong></td>
			<td align="center"><strong>UOM(CS/LB only)</strong></td>
			<td align="center"><strong>Dollars claimed (Extended Amount)</strong></td>
		</tr>
	</table>
	<textarea name="BulkData" cols="140" rows="15"></textarea>
	<p></p>
	<input type="button" value="Validate data" name="validate_data">
	<p></p>
	<font color="red"><strong>Note: if your data is not formatted correctly and copied from excel, it may cause an error</strong></font>
</td></tr>
</cfif>

	<!---Hidden fields to pass on --->
	<input type="hidden" name="Billback_ID" value="#form.Billback_ID#">
	<input type="hidden" name="Program_List" value="#form.Program_List#">
	<cfif form.Discount_Type_ID IS NOT 0>
	<input type="hidden" name="Discount_Type_ID" value="#form.Discount_Type_ID#">
	</cfif>
	<cfif form.ComponentNameIDs IS NOT 0>
	<input type="hidden" name="ComponentNameIDs" value="#form.ComponentNameIDs#">
	</cfif>

	<input type="hidden" name="Data_Action_ID"	 id="Form_Action_ID" value="1">
	<!--- END  Hidden fields to pass on--->




<script language="javascript">
function reSubmitForm()
{
	 BigBillbackForm.submit();
}
</script>

</form>
</table>
</cfoutput>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
 var isValidating = 0;

 $('input[name=validate_data]').click(function() {
 	// bail out if button was clicked previously
 	if (isValidating) {
 		return;
 	}
 	// make sure there is data to validate
 	if ( !$.trim( $('textarea[name=BulkData]').val() ) ) {
 		noty( { text: "There is no data to be validated. Please copy & paste the data from your Excel document into the Detail box."
		        ,layout:'center'
		        ,type:'warning'
		        ,timeout:5000
		      });
 		$('textarea[name=BulkData]').focus();
 		return;
 	}
 	// keep track of clicking to prevent multiple clicking
 	isValidating = 1;
 	$(this).prop("value", "Validating...");
 	submitBulkData();
 });

 try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>
</html>
