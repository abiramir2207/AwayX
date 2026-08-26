<CFSET PAGETITLE="Sysco Report">
<cfparam name="form.generatexlsreport" default="0">
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
<cfcontent type="application/unknown">
<cfheader name="Content-Disposition" value="attachment;filename=SyscoReport.xls">
<!--- <cfdump var="#form.fieldnames#"> --->
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

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.CID" 	DEFAULT="">
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "sys"> 
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfif form.generatexlsreport EQ 0>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<cfif application.programlayout EQ 1>
  <div id="Layer2" style="position:absolute; width: 179px; height: 338px; z-index: 1; left: 10px; top: 0px"> 
    <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
 <cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE>
<cfif application.programlayout EQ 1>
	 <div id="Layer1" style="position:relative; height:430px; width:800px; z-index:1; left: 100px; top: 10px;"></cfif>
 	<cfinclude template="minimal_contract_info.cfm">
 	<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
 <cfelse>
 <cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#FORM.Contract_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
</cfquery>
</cfif>
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
 <cfset useLakebaseForSavedValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sysco_deal_sheet_programs")>
<cfif useLakebaseForSavedValues>
	<cftry>
		<cfset SavedValues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("sysco_deal_sheet_programs", {
				"contract_main_id" = "eq.#form.Contract_Main_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSavedValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSavedValues>
<cfquery name="SavedValues" datasource="#application.datasource#">
SELECT * FROM Sysco_Deal_Sheet_Programs
WHERE Contract_Main_ID = '#form.Contract_Main_ID#'
AND Deleted = 0
</cfquery>
</cfif>

<cfif SavedValues.Recordcount GT 0 and blnSubmit IS 0>
	<cfset UseDBValues = 1>
</cfif>

<!---End values from db logic--->

 
<cfset useLakebaseForIsFixedThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForIsFixedThere>
	<cftry>
		<cfset IsFixedThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_price_product_data", {
				"program_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsFixedThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsFixedThere>
<cfquery name="IsFixedThere" datasource="#application.datasource#">
SELECT Program_Fixed_Price_Product_Data.Program_ID
FROM Program_Fixed_Price_Product_Data
WHERE Program_Fixed_Price_Product_Data.Program_ID = '#FORM.Contract_Main_ID#'
AND Program_Fixed_Price_Product_Data.Deleted = 0
</cfquery>
</cfif>

<Cfif IsFixedThere.Recordcount GT 0>
	<cfset contract_price = 1>
</CFIF>

<cfset useLakebaseForIsRebateThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForIsRebateThere>
	<cftry>
		<cfset IsRebateThere = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_product_data", {
				"program_id" = "eq.#FORM.Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsRebateThere = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsRebateThere>
<cfquery name="IsRebateThere" datasource="#application.datasource#">
SELECT Program_Rebates_Product_Data.Program_ID
FROM Program_Rebates_Product_Data
WHERE Program_Rebates_Product_Data.Program_ID =  '#FORM.Contract_Main_ID#'
AND Program_Rebates_Product_Data.Deleted = 0
</cfquery>
</cfif>

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
 <cfset useLakebaseForgetParentDates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetParentDates>
	<cftry>
		<cfset getParentDates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#GetContractInfo.Revision_of_Contract_Main_ID#",
				"select" = "contract_start_date,contract_end date"
			}), "contract_start_date,contract_end date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetParentDates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetParentDates>
<cfquery name="getParentDates" datasource="#application.datasource#">
			select contract_start_date, contract_end date
			from Contract_main
			where Contract_main.deleted = 0
			and Contract_main.contract_main_id = #GetContractInfo.Revision_of_Contract_Main_ID#
</cfquery>
</cfif>
<cfset startdate = getParentDates.contract_start_date>
<cfset enddate = getParentDates.contract_end_date>
<cfelse>
<cfset startdate = GetContractInfo.contract_start_date>
<cfset enddate = GetContractInfo.contract_end_date>
</cfif>

 <cfset i =1>

  <cfif form.generatexlsreport EQ 0>
 <FORM ACTION="sysco_report_form.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>&" METHOD="post" NAME="MyForm">
 <input type="hidden" name="generatexlsreport" value="1">
 <input type="hidden" name="Contract_Main_ID" value="#FORM.Contract_Main_ID#">
 <input type="hidden" name="UseDBValues" value="#UseDBValues#">
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
        <TR> 
          <TD COLSPAN="3"  ><B>Today's Date:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- today's date goes here --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="4" BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080">&nbsp; &nbsp;#dateformat(now(),"mm/dd/yyyy")#</TD>
			
       		<TD colspan="4" rowspan="3" align="Center" valign="center">&nbsp; </td><TD colspan="3" rowspan="3" align="Center" valign="center"><img src="#application.HTTPVar##cgi.server_name#/images/LW__SPPlogo_borderless.jpg" alt=""  border="0"></TD>
        </TR>
		<TR> 
          <TD COLSPAN="3"  ><B>Report Date:</B></TD>
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <!--- report date goes here --->
          <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
          <TD COLSPAN="4" BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" align="left">
			<cfif form.generatexlsreport EQ 0 AND DistributorCount IS 1>
				<input type="text" name="ReportDate" value="#dateformat(ReportDate, 'mm/dd/yyyy')#" ONKEYUP="clenseText(this,'0123456789/');"><br>
				<CF_smallLink 
				title = "run report with new date" 
				url = "##"
				parameters = "onClick=""javascript: reRunReport();"""
				>
			<cfelse>
				&nbsp; &nbsp;#dateformat(ReportDate, 'mm/dd/yyyy')#
			</cfif>
			<cfif len(trim(ReportError)) GT 0 AND form.generatexlsreport EQ 0 AND DistributorCount IS 1>
				<Br><font color="red"><strong>#ReportError#</strong></font>
			</cfif>
			</TD>
         <td>&nbsp; </td>
         
        </TR>
		
		
  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
      
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		<cfif form.generatexlsreport EQ 1>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
		  <TR> 
          <TD  colspan="3">&nbsp;</TD>
    
          
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
		</cfif>
          <cfif form.generatexlsreport EQ 0>
            <TD COLSPAN="3"  > <input type="radio" name="program_type" value="1" <cfif program_type IS 1>checked</cfif> readonly> 
              &nbsp;<B>Renewal</B></TD>
            <cfelse>
            <TD COLSPAN="2"  ><B>Renewal:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080"  align="center"> 
              <cfif program_type EQ 1>
                X </cfif></TD>
          </cfif>
          
         
          
          <TD  colspan="3" align="right"><B>Begin Date of Contract:&nbsp; </B></TD>
          <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" colspan="1" align="center" valign="Center">#dateformat(startdate,"mm/dd/yyyy")#</TD>
          <TD  >&nbsp;</TD>
		  <TD  >&nbsp;</TD>
          <TD COLSPAN="2"  ><B>Customer Program:</B></TD>
          <cfif form.generatexlsreport EQ 0>
            <TD COLSPAN="3"  ><input type="checkbox" name="contract_price" value="1" <Cfif contract_price IS 1>checked</CFIF> readonly> 
              &nbsp;<B>Contract Price</B></TD>
            <cfelse>
          
            <TD COLSPAN="3"  ><B> <cfif contract_price EQ 1>
              &nbsp;   X&nbsp; </cfif> Contract Price</B></TD>
          </cfif>
        </TR>
        <TR> 
          <cfif form.generatexlsreport EQ 0>
            <TD COLSPAN="3"  ><input type="radio" name="program_type" value="2" <Cfif program_type IS 2> checked</CFIF> readonly> 
              &nbsp;<B>New</B></TD>
            <cfelse>
            <TD COLSPAN="2"  ><B>New:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080"  align="center" valign="Center" ><cfif program_type EQ 2>
               &nbsp;  X&nbsp; </cfif></TD>
          </cfif>
         
         
          <TD  colspan="3" align="right"><B>End Date of Contract:&nbsp; </B></TD>
          <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" colspan="1"  align="center" valign="Center" >#trim(dateformat(enddate,"mm/dd/yyyy"))#</TD>
 <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <cfif form.generatexlsreport EQ 0>
            <TD COLSPAN="3"  ><input type="checkbox" name="deviated_allowance" value="1" <cfif deviated_allowance IS 1> checked</cfif> readonly> 
              &nbsp;<B>Deviated Allowance</B></TD>
            <cfelse>
                <TD COLSPAN="3"  ><B> <cfif deviated_allowance EQ 1>
               &nbsp;  X&nbsp; </cfif>Deviated Allowance</B></TD>
          </cfif>
        </TR>
        <TR> 
          <cfif form.generatexlsreport EQ 0>
            <TD COLSPAN="3"  ><input type="radio" name="program_type" value="3"  <Cfif program_type IS 3> checked</CFIF> readonly> 
              &nbsp;<B>Updated</B></TD>
            <cfelse>
            <TD COLSPAN="2"  ><B>Updated:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080"  ><cfif program_type EQ 3>
                X</cfif></TD>
          </cfif>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <cfif GetContractInfo.Is_A_Revision EQ 1>
            <TD  ><B>Revision Effective Date:</B></TD>
            <TD BGCOLOR="##EFEFEF" STYLE="border: 1px solid ##000080" align="center" valign="Center" >#trim(dateformat(GetContractInfo.contract_start_date,"mm/dd/yyyy"))#</TD>
            <cfelse>
            <TD  >&nbsp;</TD>
            <TD  >&nbsp;</TD>
          </cfif>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
          <TD  >&nbsp;</TD>
        </TR>
        <TR> 
          <TD   COLSPAN="14">&nbsp;</TD>
        </TR>
        <TR> 
          <TD   COLSPAN="14">(Update Codes - AI=Add Item / PC = Price Change)</TD>
        </TR>
        <TR> 


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
          <TD COLSPAN="4"  ><B>#application.returned_customer_setting.distributor_label_singular# Name:</B></TD>
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
		
		<cfset FixedPrice = getProducts.Fixed_Case>
		<cfset ProductID = getProducts.BSA_Foodservice_Items_Master_ID>
		
		<cfquery name="GetWarehouseAllowances" datasource="#application.datasource#">
				
		SELECT DISTINCT Default_WH, WH_Order, Sysco_Deal_Sheet_Geography.WH_Number, Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID, Sysco_Deal_Sheet_Geography.WH_Number, Sysco_Deal_Sheet_Geography.WH_Desc, 
		Sysco_Deal_Sheet_Geographic_Adjustment.Adjustment_Amount,
		Sysco_Deal_Sheet_Geographic_Adjustment.Effective_Date
		FROM Sysco_Deal_Sheet_Geographic_Adjustment
			INNER JOIN Sysco_Deal_Sheet_Geography 
			ON Sysco_Deal_Sheet_Geography.Sysco_Deal_Sheet_Geography_ID = Sysco_Deal_Sheet_Geographic_Adjustment.Sysco_Deal_Sheet_Geography_ID
			AND Sysco_Deal_Sheet_Geography.Deleted = 0
		WHERE Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID = '#ItemID#'
		AND 
		(
			Sysco_Deal_Sheet_Geography.WH_Number = '#Distributor_Warehouse#'
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 1
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			)
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 2
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = Sysco_Deal_Sheet_Geographic_Adjustment.BSA_Foodservice_Items_Master_ID
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 1
			)
			)
		)
		
		UNION
		
		SELECT DISTINCT Default_WH, WH_Order, Sysco_Deal_Sheet_Geography.WH_Number, '#ItemID#', Sysco_Deal_Sheet_Geography.WH_Number, Sysco_Deal_Sheet_Geography.WH_Desc, 
		0,
		getDate()
		FROM 	Sysco_Deal_Sheet_Geography 
		WHERE	Sysco_Deal_Sheet_Geography.Deleted = 0
		AND 
		(
			Sysco_Deal_Sheet_Geography.WH_Number = '#Distributor_Warehouse#'
			/* return only if this item does not have a record for WH_Number = '#Distributor_Warehouse#' */
			AND NOT Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			
		
		
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 1
			)
			/* return only if this item does have a record for WH_Number = '#Distributor_Warehouse#'
			and does not have a record for order=1*/
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			AND NOT Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 1
			)
			)
		
		
			OR 
			(
			(
			Sysco_Deal_Sheet_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND Sysco_Deal_Sheet_Geography.Default_WH = 1
			AND Sysco_Deal_Sheet_Geography.WH_Order = 2
			)
			/* return only if this item does have a record for WH_Number = '#Distributor_Warehouse#' 
			and does have a not null record for order=1
			and does have any record for order=2*/
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND 	ShowSecondDefault_Geography.WH_Number = '#Distributor_Warehouse#'
			)
			AND Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND	ShowSecondDefaultAdj.Adjustment_Amount IS NOT Null
			AND	ShowSecondDefaultAdj.Adjustment_Amount <> 0
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 1
			)
			AND NOT Exists
			(
			SELECT * FROM Sysco_Deal_Sheet_Geographic_Adjustment AS ShowSecondDefaultAdj 
			INNER JOIN Sysco_Deal_Sheet_Geography ShowSecondDefault_Geography
			ON ShowSecondDefault_Geography.Sysco_Deal_Sheet_Geography_ID = ShowSecondDefaultAdj.Sysco_Deal_Sheet_Geography_ID
			AND ShowSecondDefault_Geography.Deleted = 0
			WHERE 	ShowSecondDefaultAdj.BSA_Foodservice_Items_Master_ID = '#ItemID#'
			AND 	ShowSecondDefault_Geography.WH_Number <> '#Distributor_Warehouse#'
			AND 	ShowSecondDefault_Geography.Default_WH = 1
			AND 	ShowSecondDefault_Geography.WH_Order = 2
			)
			)
		)

		</cfquery>
		
		
		
		<Cfset BSCC_Amount = getProducts.BSCC_Amount>
		<Cfset OC_Amount = getProducts.OC_Amount>
		
		<Cfset Fixed_Case = getProducts.Fixed_Case>
		<Cfset Invoice_Amount = getProducts.Invoice_Amount>
		<cfset Volume = getProducts.Volume_CS>
		<cfset SUPC = getProducts.SUPC>
		<cfset Item = getProducts.Item>
		<cfset Pack_Size = getProducts.Pack_Size>
		<cfset Item_Desc = getProducts.Item_Desc>
		
		<Cfloop query="GetWarehouseAllowances">
	
		
		 <cfset "BSCC_CS_#i#" = BSCC_Amount>
		 <cfset "ABC_CS_#i#" = OC_Amount>
		 <cfset "FixedPrice_#i#" = Fixed_Case>
		 <cfset "CC_CS_#i#" = "0.00">
			 	
		<input type="hidden" name="Original_Fixed_#i#" value="#Fixed_Case#">
		<input type="hidden" name="Original_Rebate_#i#" value="0">
		<input type="hidden" name="Product_ID_#i#" value="#ItemID#">
		<input type="hidden" name="Distributor_ID_#i#" value="#DistributorID#">
		<input type="hidden" name="WH_Number_#i#" value="#GetWarehouseAllowances.WH_Number#">
		 
		 <Cfif len(trim(Invoice_Amount)) IS 0>
		 	<cfset InvoiceAmount = 0>		
		<cfelse>
			<cfset InvoiceAmount = Invoice_Amount >
		 </CFIF>
		
			<cfset "Total2_CS_#i#"   =  InvoiceAmount - evaluate("FixedPrice_#i#")  + .001>

		
			<Cfif len(trim(GetWarehouseAllowances.Adjustment_Amount)) IS 0 OR NOT isNumeric(GetWarehouseAllowances.Adjustment_Amount)>
				<cfset AdjustmentAmount = 0>
			<CFELSE>
				<cfset AdjustmentAmount = GetWarehouseAllowances.Adjustment_Amount>
			</CFIF>
			
		<Cfset Adjustment_Cases = AdjustmentAmount*getProducts.Net_Weight>
		 <!---   <Cfif len(trim(Adjustment_Cases)) GT 0>
			  	<cfset "Total2_CS_#i#"   =  evaluate("Total2_CS_#i#") + Adjustment_Cases>
		   </CFIF> --->
		   
		   <cfset "Total_CS_#i#"    =  evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
		   <cfset "Supplier_CS_#i#" =  evaluate("Total_CS_#i#") - evaluate("BSCC_CS_#i#")>
		   <cfset "CC_CS_#i#" = evaluate("FixedPrice_#i#") + Adjustment_Cases>
		   
		   <cfif blnSubmit IS 1>
		   <Cfif i LTE NumberofRecords>
		   	<cfset "Total_CS_#i#" = evaluate("form.Total_CS_#i#")>
			<cfset "Supplier_CS_#i#" = evaluate("form.Supplier_CS_#i#")>
			<cfset "ABC_CS_#i#" = evaluate("form.ABC_CS_#i#")>
			<cfset "CC_CS_#i#" = evaluate("form.CC_CS_#i#")>
			<cfset "Total2_CS_#i#" = evaluate("form.Total2_CS_#i#")>
			<cfset "BSCC_CS_#i#" = evaluate("form.BSCC_CS_#i#")>
			</cfif>
		   </cfif>
			
			<cfif blnSubmit IS 0 AND UseDBValues IS 1>
		  <!---Set the values to the database values--->
		  
		   <cfquery name="ValuesForThisProduct" dbtype="query">
			SELECT * FROM SavedValues
			WHERE Distributor_ID = '#DistributorID#'
			AND Product_ID = '#ProductID#'
			AND Original_Fixed = #FixedPrice#
			AND WH_Number LIKE '%#GetWarehouseAllowances.WH_Number#%' 
			</cfquery>
			
			<Cfif ValuesForThisProduct.Recordcount GT 0>
			
			<!--- <cfdump var="#ValuesForThisProduct#"> --->
			<cfset "Supplier_CS_#i#" = ValuesForThisProduct.Supplier_CS>
		   	 <cfset "BSCC_CS_#i#" = ValuesForThisProduct.BSCC_CS>
			 <cfset "ABC_CS_#i#" = ValuesForThisProduct.ABC_CS>
			 <cfset "FixedPrice_#i#" = ValuesForThisProduct.Original_Fixed>
			 <cfset "CC_CS_#i#" = ValuesForThisProduct.CC_CS>
			  <cfset "Total_CS_#i#"    = evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
			<input type="hidden" name="RecordID_#i#" value="#ValuesForThisProduct.Sysco_DS_Program_ID#">
		  	</CFIF>
		  </cfif>
		
			 
			 <tr> 
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><cfif Volume NEQ "">
#trim(numberformat(Volume,"___,___,___,___,___,___.__"))#&nbsp; 
</cfif>&nbsp;  </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#SUPC#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#Item#&nbsp; </td>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#Pack_Size#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#trim(GetWarehouseAllowances.WH_Desc)#&nbsp; </TD>
            <TD STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#Item_Desc#&nbsp; </td>

			
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><CF_formatnumber
	number = "#evaluate("CC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>&nbsp; <input type="hidden" name="CC_CS_#i#" value="#evaluate("CC_CS_#i#")#"></TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="Supplier_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;"  ONKEYUP="clenseText(this,'0123456789.');addvalues2(#i#);" onChange="this.value = formatToDeciamalPlaces(this.value,2)">
                <cfelse>
               <CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>  &nbsp; </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="BSCC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');addvalues(#i#);" onChange="this.value = formatToDeciamalPlaces(this.value,2)">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
></cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="Total_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" readonly>
                <cfelse>
                <CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>
              </cfif> </TD>
            <TD  >&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="ABC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');addtotals(#i#);" onChange="this.value = formatToDeciamalPlaces(this.value,2)">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>
            </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="Total2_CS_#i#" value=" <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" readonly >

                <cfelse>
               <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>
            </cfif> </TD>
			
			<!--- <Td>#i#</TD> --->
          </TR>
          <cfset i=i+1>
		
        </cfloop>
		
		<!---Rebate--->
		<Cfelse>
		
		
		 <!---Rebate logic--->
		  <cfif trim(getProducts.Rebate_Case) IS NOT "">
		  
		 	<!--- <cfif i IS 2>
			<cfoutput>#i#</cfoutput>
			<cfdump var="#variables#">
			
				<Cfabort>
			</cfif> --->
		  	<cfset "FixedPrice_#i#" = "0.0000">
		     <!---CC always null for rebate--->
			  <cfset "CC_CS_#i#" = "0.0000">
			  <!---far right is total amount offered in program--->
		  	  <cfset "Total2_CS_#i#"   = getProducts.Rebate_Case>
			  <cfset "Total_CS_#i#"    =  evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
		  	  <cfset "Supplier_CS_#i#" =  evaluate("Total_CS_#i#") - evaluate("BSCC_CS_#i#")>
		  <cfelse>
		  	<cfset "Rebate_Case_#i#" = "0.0000">
		  </cfif>
		
		  
		 
		  <cfif blnSubmit IS 0 AND UseDBValues IS 1>
		  
		   <cfquery name="ValuesForThisProduct" dbtype="query">
			SELECT * FROM SavedValues
			WHERE Distributor_ID = '#DistributorID#'
			AND Product_ID = '#getProducts.BSA_Foodservice_Items_Master_ID#'
			AND Original_Rebate = #getProducts.Rebate_Case# 
			</cfquery>
			
			<!--- <cfdump var="#ValuesForThisProduct#"> --->
		  	<Cfif ValuesForThisProduct.Recordcount GT 0>
			<cfset "Supplier_CS_#i#" = ValuesForThisProduct.Supplier_CS>
		   	 <cfset "BSCC_CS_#i#" = ValuesForThisProduct.BSCC_CS>
			 <cfset "ABC_CS_#i#" = ValuesForThisProduct.ABC_CS>
			 <cfset "FixedPrice_#i#" = ValuesForThisProduct.Original_Fixed>
			 <cfset "CC_CS_#i#" = ValuesForThisProduct.CC_CS>
			 <cfif trim(getProducts.Rebate_Case) IS NOT "">
			 	<cfset "Total2_CS_#i#"   = getProducts.Rebate_Case>
			 <cfelse>
			 	<cfset "Total2_CS_#i#"   = 0>
			 </cfif>
			 <cfset "Total_CS_#i#"    =  evaluate("Total2_CS_#i#") - evaluate("ABC_CS_#i#")>
		
			<input type="hidden" name="RecordID_#i#" value="#ValuesForThisProduct.Sysco_DS_Program_ID#">
			
			</CFIF>
		  </cfif>
		<cfset "Rebate_Case_#i#" = getProducts.Rebate_Case>
		
		<input type="hidden" name="Original_Fixed_#i#" value="0">
		<input type="hidden" name="Original_Rebate_#i#" value="#evaluate("Rebate_Case_#i#")#">
		<input type="hidden" name="Product_ID_#i#" value="#ItemID#">
		<input type="hidden" name="Distributor_ID_#i#" value="#DistributorID#">
		<input type="hidden" name="WH_Number_#i#" value="">
		
		<tr> 
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF">&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><cfif getProducts.volume_cs NEQ ""><CF_formatnumber
	number = "#getProducts.volume_cs#" 
	decimals = "2"
	showcurrency = 0
>
&nbsp; 
</cfif>&nbsp;  </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.SUPC#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.Item#&nbsp; </td>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.Pack_Size#&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">ALL &nbsp; </TD>
            <TD STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center">#getProducts.Item_Desc#&nbsp; </td>

			
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"><CF_formatnumber
	number = "#evaluate("CC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>&nbsp; <input type="hidden" name="CC_CS_#i#" value="#evaluate("CC_CS_#i#")#"></TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="Supplier_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');addvalues2(#i#);" onChange="this.value = formatToDeciamalPlaces(this.value,2)">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("Supplier_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
> &nbsp; </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="BSCC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');addvalues(#i#);" onChange="this.value = formatToDeciamalPlaces(this.value,2)">
                <cfelse>
				<CF_formatnumber
	number = "#evaluate("BSCC_CS_#i#")#" 
	decimals = "2"
	showcurrency =1
> </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="Total_CS_#i#" value=" <CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" readonly>
                <cfelse>
                <CF_formatnumber
	number = "#evaluate("Total_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
> 
              </cfif> </TD>
            <TD  >&nbsp;</TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="ABC_CS_#i#" value="<CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
>" STYLE="WIDTH:50px;" ONKEYUP="clenseText(this,'0123456789.');addtotals(#i#);" onChange="this.value = formatToDeciamalPlaces(this.value,2)">
                <cfelse>
				 <CF_formatnumber
	number = "#evaluate("ABC_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
>  </cfif> </TD>
            <TD   STYLE="border: 1px solid ##000080" BGCOLOR="##EFEFEF" align="center"> 
              <cfif form.generatexlsreport EQ 0>
                <input type="text" name="Total2_CS_#i#" value=" <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 0
> " STYLE="WIDTH:50px;" readonly >
                <cfelse>
               <CF_formatnumber
	number = "#evaluate("Total2_CS_#i#")#" 
	decimals = "2"
	showcurrency = 1
></cfif> </TD>
<!--- <Td>#i#</TD> --->
          </TR>
          
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
	<TABLE>
	<TR>
	<TD colspan="100%">&nbsp;</TD>
	</TR>
	<TR>
	<TD>
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
	font_weight		=	"bold"
>	
	<td>
	
	<CF_button
	button_name		=	""
	button_caption	=	"Save Entered Values"
	button_action	=	"saveData();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	</td>
	</TR>
	</TABLE>
	<input type="hidden" value="1" name="blnSubmit">
	<cfset i = i-1> 
	<input type="hidden" value="#i#" name="NumberofRecords">
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
function addvalues(i)
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
}

function addvalues2(i)
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
}

function addtotals(i)
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
}
</script>
</BODY>
</HTML> 