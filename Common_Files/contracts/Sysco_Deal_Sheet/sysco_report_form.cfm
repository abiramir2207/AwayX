<CFSET PAGETITLE="Sysco Report">
<cfparam name="form.generatexlsreport" default="0">
<cfparam name="form.generatexlsreportaddheaders" default="1">
<cfparam name="form.contract_price" default="0">
<cfparam name="form.deviated_allowance" default = "0">
<cfparam name="program_type" default="2">
<cfparam name="spacer" default="<br>">
<cfparam name="ReportDate" default="#dateformat(now(), 'mm/dd/yyyy')#">
<cfparam name="ReportError" default="">
<cfparam name="blnSubmit" default="0">
<cfparam name="NumberofRecords" default="0">
<cfparam name="UseDBValues" default="0">
<cfparam name="RecordID" default="">
<cfparam name="FromPriorRevision" default="0">
<cfset FORMVARSFORJS = StructNew() />
<cfset FORMVARSFORJS_FIXEDSTART = "FixedPrice_LineNumbers" />
<cfset FORMVARSFORJS_REBATESTART = "RebatePrice_LineNumbers" />

<!---  <cfif blnSubmit IS 1>
<cfdump var="#form#">
<cfabort>
</cfif> --->

<cfif isDefined("ReportDate")>
	<Cfif NOT isdate(ReportDate)>
		<cfset ReportDate = "#dateformat(now(), 'mm/dd/yyyy')#">
		<cfset ReportError = "You did not enter a valid date">
	</CFIF>
</cfif>

<cfif form.generatexlsreport EQ 1>
	<cfset spacer = " ">
	<cfif form.generatexlsreportaddheaders EQ 1>
		<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=SyscoReport.xls">
	</cfif>
</cfif>

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGETITLE#</CFOUTPUT></TITLE>
	<cfif form.generatexlsreport EQ 0>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
</cfif>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.CID" 	DEFAULT="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "sys"> 
<CFSET FORM.Contract_Main_ID = cryp.value>


	 <cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
	</cfquery>
	
<cfif form.generatexlsreport EQ 0>
	<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
	<cfif application.programlayout EQ 1>
	  <div id="Layer2" style="position:absolute; width: 179px; height: 338px; z-index: 1; left: 10px; top: 0px"> 
	    <CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm"></div>
	 <cfelse>
	<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
	</cfif>
	<BLOCKQUOTE>
	  <cfif application.programlayout EQ 1><div id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; left: 100px; top: 10px;"></cfif>
	 	<!--- <cfinclude template="/common_files/contracts/minimal_contract_info.cfm"> --->
		<CFSET PAGETITLE="Sysco Report  ::  Contract Number  ::  #GetContractInfo.Contract_Number#">
	 	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
 </cfif>
 
 <Cfif GetContractInfo.Is_A_Revision IS 1 AND GetContractInfo.Auto_Renew IS 0>
 	<cfset Program_Type = 3>
 </CFIF>
  <Cfif GetContractInfo.Is_A_Revision IS 1 AND GetContractInfo.Auto_Renew IS 1>
 	<cfset Program_Type = 1>
 </CFIF>
   <Cfif GetContractInfo.Is_A_Revision IS 0>
 	<cfset Program_Type = 2>
 </CFIF>
 
 <!---Show values from db or not?--->
 <cfquery name="SavedValues" datasource="#application.datasource#">
SELECT * FROM Sysco_Deal_Sheet_Programs
WHERE Contract_Main_ID = '#form.Contract_Main_ID#'
AND Deleted = 0
</cfquery>

<cfif SavedValues.Recordcount GT 0 and blnSubmit IS 0>
	<cfset UseDBValues = 1>
</cfif>

<!---End values from db logic--->

 
<cfquery name="IsFixedThere" datasource="#application.datasource#">
SELECT Program_Fixed_Price_Product_Data.Program_ID
FROM Program_Fixed_Price_Product_Data
WHERE Program_Fixed_Price_Product_Data.Program_ID = '#FORM.Contract_Main_ID#'
AND Program_Fixed_Price_Product_Data.Deleted = 0
</cfquery>

<Cfif IsFixedThere.Recordcount GT 0>
	<cfset contract_price = 1>
</CFIF>

<cfquery name="IsRebateThere" datasource="#application.datasource#">
SELECT Program_Rebates_Product_Data.Program_ID
FROM Program_Rebates_Product_Data
WHERE Program_Rebates_Product_Data.Program_ID =  '#FORM.Contract_Main_ID#'
AND Program_Rebates_Product_Data.Deleted = 0
</cfquery>

<Cfif IsRebateThere.Recordcount GT 0>
	<cfset deviated_allowance = 1>
</CFIF>

 <cfoutput>
 <cfquery name="getDistributor" datasource="#application.datasource#">
			select BSA_Foodservice_Customers.name as Cust_Name, BSA_Foodservice_Customers.Whse, BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS Distributor_ID
			from Contract_Distributors
			INNER JOIN BSA_Foodservice_Customers ON
			Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID and BSA_Foodservice_Customers.deleted = 0
			INNER JOIN Distributor_Family
			ON BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID
			and Distributor_Family.deleted = 0
			INNER JOIN Distributor_Buying_Groups
			ON BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID
			and Distributor_Buying_Groups.deleted = 0
			where Contract_Distributors.deleted = 0
<!--- 			and (BSA_Foodservice_Customers.Name like '%sysco%' OR 
				Distributor_Family.Family_Name like '%sysco%' OR
				Distributor_Buying_Groups.Buying_Group_Name like '%sysco%') --->
			and Contract_Distributors.contract_main_id = '#FORM.Contract_Main_ID#'
			
</cfquery>

	
<cfif GetContractInfo.Is_A_Revision EQ 1>
 <cfquery name="getParentDates" datasource="#application.datasource#">
			select contract_start_date, contract_end_date
			from Contract_main
			where Contract_main.deleted = 0
			and Contract_main.contract_main_id = #GetContractInfo.Revision_of_Contract_Main_ID#
</cfquery>
<cfset startdate = getParentDates.contract_start_date>
<cfset enddate = getParentDates.contract_end_date>
<cfelse>
<cfset startdate = GetContractInfo.contract_start_date>
<cfset enddate = GetContractInfo.contract_end_date>
</cfif>

 <cfset i =1>

  <cfif form.generatexlsreport EQ 0>
<!---   <CFINCLUDE TEMPLATE="sysco_approve_menu.cfm"> --->
 <FORM ACTION="sysco_report_form.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>&" METHOD="post" NAME="MyForm">
 <input type="hidden" name="generatexlsreport" value="1">
 <input type="hidden" name="Contract_Main_ID" value="#FORM.Contract_Main_ID#">
 <input type="hidden" name="UseDBValues" value="#UseDBValues#">
 <input type="hidden" value="0" name="approve">
</cfif>


      <TABLE BORDER="0" ID="table1" CELLSPACING="0" CELLPADDING="2">
	  
        <!-- MSTableType="nolayout" -->
         <TR> 
          <TD width="50">&nbsp; </TD><!---Item code--->
		  <TD  width="55">&nbsp; </TD><!---Volume--->
		  <TD  width="59">&nbsp; </TD><!---SUPC--->
          <TD  width="50">&nbsp; </TD><!---Item ID--->
		  <TD   width="40">&nbsp;</TD><!---Pack size--->
          <TD   width="73">&nbsp;</TD><!---Location--->
          <TD width="80">&nbsp;</TD><!---Description--->
          <TD   width="65">&nbsp;</TD><!---Customer contract size per case--->
          <TD   width="70">&nbsp;</TD><!---Supplier per case--->
          <TD   width="60">&nbsp;</TD><!---BSCC per case--->
          <TD   width="70">&nbsp;</TD><!---Total OC per case--->
          <TD   width="10">&nbsp;</TD><!---Check box--->
          <TD   width="75">&nbsp;</TD><!---OC funding--->
          <TD   width="80">&nbsp;</TD><!---Total allowance--->
        </TR>
		<cfset DistributorCount = 0>
	<cfloop query="GetDistributor">
		<Cfset DistributorID = GetDistributor.Distributor_ID>
		<Cfset DistributorCount = DistributorCount+1>
      
	  <cfinclude template="sysco_report_header_include.cfm">


 <cfquery name="getOperator" datasource="#application.datasource#">
			select BSA_Operator.Operator_Name as Operator_Name
			from Contract_Operators
			INNER JOIN BSA_Operator ON
			Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID 	and BSA_Operator.deleted = 0
			where Contract_Operators.deleted = 0
			and Contract_Operators.contract_main_id = '#FORM.Contract_Main_ID#'
</cfquery>

<cfquery name="getProducts" datasource="#application.datasource#"> 
			select distinct BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Net_Weight, program_product_volume.Volume_CS,
BSA_Foodservice_Items_Master.item,BSA_Foodservice_Items_Master.upc,Sysco_Deal_Sheet.Pack_Size, Sysco_Deal_Sheet.Item_desc, (Sysco_Deal_Sheet.OC_Amount * BSA_Foodservice_Items_Master.Net_Weight) AS OC_Amount, (Sysco_Deal_Sheet.BSCC_Amount  * BSA_Foodservice_Items_Master.Net_Weight) AS BSCC_Amount, (Sysco_Deal_Sheet.Invoice_Amount * BSA_Foodservice_Items_Master.Net_Weight) AS Invoice_Amount, Sysco_Deal_Sheet.SUPC,   Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID, Program_Fixed_Price_Product_Data.Program_Fixed_Price_Product_Data_ID, Sysco_Deal_Sheet_Geography.WH_Desc, <!--- (Sysco_Deal_Sheet_Geographic_Adjustment.Adjustment_Amount * BSA_Foodservice_Items_Master.Net_Weight) AS Adjustment_Amount,  --->
CASE WHEN Program_Rebates_Component_Data.Unit_of_Measure_ID = 1 
THEN Program_Rebates_Component_Data.Rate
 ELSE 
Program_Rebates_Component_Data.Rate*cast(BSA_Foodservice_Items_Master.Net_Weight as float)
 END AS Rebate_Case,

 CASE WHEN Program_Fixed_Price_Product_Data.Unit_of_Measure_ID = 1 
THEN Program_Fixed_Price_Product_Data.Fixed_Price_Value 
 ELSE 
Program_Fixed_Price_Product_Data.Fixed_Price_Value * cast(BSA_Foodservice_Items_Master.Net_Weight as float)
 END AS Fixed_Case

			from Contract_products
			INNER JOIN BSA_Foodservice_Items_Master ON
			Contract_products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 	and BSA_Foodservice_Items_Master.deleted = 0
			INNER JOIN program_product_volume
			ON program_product_volume.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
			and program_product_volume.DELETED = 0
			AND program_product_volume.Program_ID = Contract_products.contract_main_id
			LEFT JOIN Program_Rebates_Product_Data
			ON Program_Rebates_Product_Data.Contract_products_ID = Contract_products.Contract_products_ID
			AND Program_Rebates_Product_Data.Deleted = 0 
			LEFT JOIN Program_Rebates_Component_Data
			ON Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
			AND Program_Rebates_Component_Data.Deleted = 0
			LEFT JOIN Program_Fixed_Price_Product_Data
			ON Program_Fixed_Price_Product_Data.Contract_products_ID = Contract_products.Contract_products_ID
			AND Program_Fixed_Price_Product_Data.Deleted = 0
			INNER JOIN Sysco_Deal_Sheet
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet.BSA_Foodservice_Items_Master_ID
			AND Sysco_Deal_Sheet.Deleted = 0
			AND Sysco_Deal_Sheet_ID IN (SELECT TOP 1 S.Sysco_Deal_Sheet_ID FROM Sysco_Deal_Sheet S WHERE s.Effective_Date <= '#ReportDate#' 
			AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = S.BSA_Foodservice_Items_Master_ID
			AND S.Deleted = 0 ORDER BY Effective_Date DESC)
			LEFT JOIN Sysco_Deal_Sheet_Geography
			ON Sysco_Deal_Sheet_Geography.WH_Number = '#getDistributor.Whse#'
			<!--- LEFT JOIN Sysco_Deal_Sheet_Geographic_Adjustment
			ON Sysco_Deal_Sheet_Geographic_Adjustment.Sysco_Deal_Sheet_Geography_ID = 
			Sysco_Deal_Sheet_Geography.Sysco_Deal_Sheet_Geography_ID -
			AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 
			Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID--->
			WHERE Contract_products.deleted = 0
			and Contract_products.contract_main_id = '#FORM.Contract_Main_ID#'
			ORDER BY 	BSA_Foodservice_Items_Master.item, BSA_Foodservice_Items_Master.upc, Sysco_Deal_Sheet.Pack_Size, Sysco_Deal_Sheet.Item_Desc
</cfquery> 
<!--- <cfdump var="#getProducts#"> --->


	
<cfset CustomerList =  #valueList(getDistributor.Cust_Name)#>
<cfset OperatorList =  #valueList(getOperator.Operator_Name)#>
<cfset Distributor_Warehouse = getDistributor.Whse>


        <TR> 
          <TD COLSPAN="4"  ><B>Sysco Operating Company:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- the name of the distributor --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="9" BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" valign="center">#getDistributor.Cust_Name#&nbsp;</TD>
   
          <TD   colspan="2">&nbsp;</TD>
        </TR>
        <TR> 
          <TD COLSPAN="4"  ><B>Customer Name:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- the name of the distributor --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="9" BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080">#OperatorList#&nbsp;</TD>
        <TD   colspan="2">&nbsp;</TD>
        </TR>
      
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Update Item Code</b></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom" ROWSPAN="2"><B>Volume 
            cs/wk</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- sysco upc number --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>SUPC</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- product number --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Mfg. 
            ID</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- the pack size might be part of the description, we may have to parse it before displaying it --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Pack Size</B></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Pick 
            Up Location</B></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Description</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- null for now --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Customer FOB Price per Case</B></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   COLSPAN="2"><B>BSCC 
            Accounting</B></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Total $/Case
            OC Allowable
            Billback to BSCC</B></TD>
          <TD ALIGN="center" VALIGN="bottom"   ROWSPAN="2">&nbsp;</TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Operating Company $/Case
            Funding</B></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"   ROWSPAN="2"><B>Total $/Case
            Customer
            Deviated Allowance</B></TD>
        </TR>
        <TR> 
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"  ><B>Supplier $/Case
            Funding</B></TD>
          <TD ALIGN="center" STYLE="border: 1px solid ##000080" VALIGN="bottom"  ><B>BSCC $/Case
            Funding</B></TD>
        </TR>
    
	
		<cfset "Supplier_CS_#i#" = "0.00">
		<cfset "BSCC_CS_#i#" = "0.00">
		<cfset "Total_CS_#i#" = "0.00">
		<cfset "ABC_CS_#i#" = "0.00">
		<cfset "FixedPrice_#i#" = "0.00">
		<cfset "CC_CS_#i#" = "0.00">
		<cfset "Rebate_Case_#i#" = "0.0000">
				
		<!--- <cfdump var="#getProducts#"> --->
		
        <cfloop query="getProducts">
		 
		 
		<Cfset ItemID = getProducts.BSA_Foodservice_Items_Master_ID>
		<cfset Warehouse = getProducts.WH_Desc>
		
		<!---Get values from database--->
		 <cfset "BSCC_CS_#i#" = getProducts.BSCC_Amount>
		 <cfset "ABC_CS_#i#" = getProducts.OC_Amount>
		 <cfset "FixedPrice_#i#" = getProducts.Fixed_Case>
		 <cfset "CC_CS_#i#" = "0.00">
		
		<!---Always use values if they exist in the form scope--->
		 <cfif blnSubmit IS 1>
		   <Cfif i LTE NumberofRecords>
		   	<cfset "Total_CS_#i#" = evaluate("form.Total_CS_#i#")>
			<cfset "Supplier_CS_#i#" = evaluate("form.Supplier_CS_#i#")>
			<cfset "ABC_CS_#i#" = evaluate("form.ABC_CS_#i#")>
			<cfset "CC_CS_#i#" = evaluate("form.CC_CS_#i#")>
			<cfset "Total2_CS_#i#" = evaluate("form.Total2_CS_#i#")>
			<cfset "BSCC_CS_#i#" = evaluate("form.BSCC_CS_#i#")>
					
			</CFIF>
		   </cfif>
		 	  
		
				  
		<!---Do this for fixed price only--->
		<!---You only need the warehouse logic for fixed price data--->
		<Cfif getProducts.Fixed_Case IS NOT "" AND getProducts.Fixed_Case IS NOT 0>
		
		
		<cfinclude template="sysco_report_fp_include.cfm">
		
		<!---Rebate--->
		<Cfelse>
		
		<cfinclude template="sysco_report_reb_include.cfm">
          
		   <cfset i=i+1>
		  </cfif>
		  
		 
		</cfloop>
		
        <TR> 
          <TD   COLSPAN="14">&nbsp;</TD>
        </TR>
        <TR> 
          <TD COLSPAN="5"  ><B>Supplier Representative - Accepted By:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- stays blank so he can be signed later on --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="6" STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
          <TD COLSPAN="5"  ><B>Supplier Notes/Program Details:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- our notes field contents goes here --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="6" STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">#GetContractInfo.Notes#&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
          <TD COLSPAN="5"  ><B>BSCC Potato Dept Representative:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- stays blank so he can be signed later on --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="6" STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
          <TD COLSPAN="5"  ><B>BSCC Accounting</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- standard blurb --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="9" STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">Use 
            this document as authorization to bill back supplier for dollar amount 
            shown in Supplier Funding column. Use this document as a supplier 
            authorized deduction to pay the Operating Company amount shown in 
            TOTALS ALLOWABLE BILLBACK to BSCC column</TD>
        </TR>
        <TR> 
          <TD COLSPAN="5"  ><B>Operating Company</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- standard blurb --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="9" STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">To 
            claim allowances on items sold scan this document through Lotus Notes 
            along with a tracking report for the approved time period as a Correction 
            Debit Memo - Supplier Authorized Deduction. All claims must be completed 
            within 90 days of the effective ending date. SUS deviations need to 
            beset up with a DC Basis for correct calculation purposes.</TD>
        </TR>
      <tr><td colspan="100%">&nbsp;<hr color="orange">&nbsp;  </td></tr>
	  </cfloop>
	  
	  </TABLE>
	  <cfif form.generatexlsreport EQ 0>
	<TABLE border="0" width="350">
	<TR>
	<TD colspan="100%">&nbsp;</TD>
	</TR>
	<TR align="center">
		<TD width="25%">
			<CF_button
			button_name		=	""
			button_caption	=	"Generate Report"
			button_action	=	"verifyData();"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">	
		</td>
  <cfif form.generatexlsreport EQ 0 and CanEditProgram>
		<td width="25%">
			<CF_button
			button_name		=	""
			button_caption	=	"Save Data"
			button_action	=	"saveData();"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">	
	
	    </td>
   </cfif>
   <cfif form.generatexlsreport EQ 0 and CanEditProgram and getProducts.recordcount gt 0 and Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnPosition EQ 0>
		  <td width="25%">
		
				<CF_button
				button_name		=	""
				button_caption	=	"Save and Approve"
				button_action	=	"saveApproveData();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">	
		  </td>
    </cfif>
    <cfif form.generatexlsreport EQ 0 and not CanEditProgram and FromPriorRevision IS NOT 1>
		   <td width="25%">
				<CF_button
				button_name		=	""
				button_caption	=	"View Program"
				button_action	=	"/common_files/contracts/contract_edit_menu.cfm?CID=#URL.CID#"
				button_type		=	"link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">	
		    </td>
      </cfif>
	  
	  <cfif GetContractInfo.Is_A_Revision IS 1 OR FromPriorRevision IS 1>
	  		   <td width="25%">
				<CF_button
				button_name		=	""
				button_caption	=	"Report for Prior Revisions"
				button_action	=	"/common_files/contracts/sysco_deal_sheet/view_prior_revisions.cfm?CID=#URL.CID#"
				button_type		=	"link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">	
		    </td>
	  </cfif>
	</TR>
	</TABLE>
	<input type="hidden" value="1" name="blnSubmit">
	<cfset i = i-1> 
	<input type="hidden" value="#i#" name="NumberofRecords">
	
	<!------ Output the variables for tracking which line # corresponds to which product ----->
	<cfloop collection = #FORMVARSFORJS# item = "STRUCTITEM">
		<input type="hidden" name="#STRUCTITEM#" value="#Evaluate("FORMVARSFORJS.#STRUCTITEM#")#">	  
	</cfloop>

</form></cfif>
 </cfoutput>
 
 </BLOCKQUOTE>
  <cfif form.generatexlsreport EQ 0>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script>
function verifyData()
{
	MyForm.submit();
}
function reRunReport()
{
	document.MyForm.generatexlsreport.value = 0;
	MyForm.submit();
}
function saveData()
{
	document.MyForm.action = "sysco_report_form_action.cfm";
	MyForm.submit();
}
function saveApproveData()
{
    if(confirm("Are you sure you want to approve this program?")) 
	  {
	    document.MyForm.approve.value = 1;
		document.MyForm.action = "sysco_report_form_action.cfm";
		MyForm.submit();
	  }
}

function addvalues(i, iPropogate)
{  	
	var obj1,obj2,obj3,val1,val2,val3;
	obj1 = eval("document.MyForm.Supplier_CS_" + i);
	obj2 = eval("document.MyForm.BSCC_CS_" + i);
	obj3 = eval("document.MyForm.Total_CS_" + i);
	
	val1 = parseFloat(obj1.value);
	val2 = parseFloat(obj2.value);
	val3 = parseFloat(obj3.value);
	
	if(isNaN(val1))
	{
		val1 = 0;
	}
	if(isNaN(val2))
	{
		val2 = 0;
	}
	if(isNaN(val3))
	{
		val3 = 0;
	}
	
	obj1.value = val3 - val2;
	obj1.value = formatToDeciamalPlaces(obj1.value,2);	
	val1 = parseFloat(obj1.value);
	
	checkSupplierCaseNegative(obj1, obj2, obj3, val1, val2, val3);
	
	<!------ Call the function whicl loops thru and change the value for same product, same discount type ----->
	if(iPropogate)
	{
		callSameFunctionForOtherLineItems(i, val2, "BSCC_CS_", 2);
	}
}

function addvalues2(i, iPropogate)
{  	
	var obj1,obj2,obj3,val1,val2,val3,valA;
	obj1 = eval("document.MyForm.Supplier_CS_" + i);
	obj2 = eval("document.MyForm.BSCC_CS_" + i);
	obj3 = eval("document.MyForm.Total_CS_" + i);
	
	val1 = parseFloat(obj1.value);
	val2 = parseFloat(obj2.value);
	val3 = parseFloat(obj3.value);

	if(isNaN(val1))
	{
		val1 = 0;
	}
	if(isNaN(val2))
	{
		val2 = 0;
	}
	if(isNaN(val3))
	{
		val3 = 0;
	}

	obj2.value = val3 - val1;
	obj2.value = formatToDeciamalPlaces(obj2.value,2);
	val2 = parseFloat(obj2.value);
	
	checkSupplierCaseNegative(obj1, obj2, obj3, val1, val2, val3);
	
	<!------ Call the function whicl loops thru and change the value for same product, same discount type ----->
	if(iPropogate)
	{
		callSameFunctionForOtherLineItems(i, val1, "Supplier_CS_", 1);
	}
}

function addtotals(i, iPropogate)
{
	
var obj4,obj5,obj6,obj7,obj8,val3,val4,val5,val6,val7;
	
	obj4 = eval("document.MyForm.Total_CS_" + i);
	obj5 = eval("document.MyForm.ABC_CS_" + i);
	obj6 = eval("document.MyForm.Total2_CS_" + i);
	obj7 = eval("document.MyForm.Supplier_CS_" + i);
	obj8 = eval("document.MyForm.BSCC_CS_" + i);
	val4 = parseFloat(obj4.value);
	val5 = parseFloat(obj5.value);
	val6 = parseFloat(obj6.value);
	val7 = parseFloat(obj7.value);
	val8 = parseFloat(obj8.value);
	
	if(isNaN(val4))
	{
		val4 = 0;
	}
	if(isNaN(val5))
	{
		val5 = 0;
	}
	if(isNaN(val6))
	{
		val6 = 0;
	}
	if(isNaN(val7))
	{
		val7 = 0;
	}
	if(isNaN(val8))
	{
		val8 = 0;
	}
	
	val4 = val6 - val5;
	obj4.value = val4;
	obj7.value = val4 - val8;
	obj4.value = formatToDeciamalPlaces(obj4.value,2);
	obj7.value = formatToDeciamalPlaces(obj7.value,2);
	obj6.value = formatToDeciamalPlaces(obj6.value,2);
	<!------ Call the function whicl loops thru and change the value for same product, same discount type ----->
	if(iPropogate)
	{
		callSameFunctionForOtherLineItems(i, val5, "ABC_CS_", 3);
	}
}

/*
If the total $/Case OC Allowable Billback to BSCC is less than the BSCC $/case funding,  (val1 < 0 or val2 < val3)
change the BSCC $/case funding to be the $/Case OC Allowable amount and set the Supplier $/case funding to $0. 
*/
function checkSupplierCaseNegative(obj1, obj2, obj3, val1, val2, val3)
{
	if(val1 < 0)
	{
		obj2.value = formatToDeciamalPlaces(val3, 2);
		obj1.value = 0;
	}
}

function callSameFunctionForOtherLineItems(i, iVal, changeObjName, functionId)
{
	var currObjName, oCurrObj;
	//get the line # information of cuttent item (product ID, discount type)
	var currentLineNumInfo = eval("document.MyForm.Line_Number_Info_" + i);	
	var productId = currentLineNumInfo.value;
	var dicountId = currentLineNumInfo.discountType;
	
	// find the form variable in which the line item # is stored 
	var varName = "";
	if(dicountId == 1)
	{
		<cfoutput>varName = "#FORMVARSFORJS_FIXEDSTART#";</cfoutput>
	}
	else
	{
		<cfoutput>varName = "#FORMVARSFORJS_REBATESTART#";</cfoutput>		
	}
	varName = varName + "_" + productId;
	
	if(changeObjName != "" && varName != "")
	{		
		// get line item # list
		var oLineNumList = eval("document.MyForm." + varName);
		var sLineNumList = oLineNumList.value;
		var arrLineNumList = sLineNumList.split(",");
		var arLen = arrLineNumList.length;
		var currentI = 0;
		
		for(var j=0;j<arLen;j++)
		{
			currentI = arrLineNumList[j];
			if(currentI.length > 0 && currentI != i)
			{
				currObjName = "document.MyForm." + changeObjName + currentI;
				oCurrObj = eval(currObjName);
				oCurrObj.value = formatToDeciamalPlaces(iVal, 2);
				
				switch(functionId)
				{
					case 1:
							addvalues2(currentI, 0);
							break;
					case 2:
							addvalues(currentI, 0);
							break;
					case 3:
							addtotals(currentI, 0);
							break;
				}			
			}
		}		
	}
}
</script>
</BODY>
</HTML> 