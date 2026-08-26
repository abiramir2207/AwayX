<cfsilent>
<cfparam name="url.state" default="0">
<cfparam name="url.county" default="0">
<cfparam name="url.operator" default="0">
<cfparam name="url.distributor" default="0">
<cfparam name="url.distributor_ID" default="">
<cfparam name="AllOperators" default="">

<cfparam name="url.operatorid" default="0">
<cfparam name="url.productid" default="0">
<cfparam name="url.programid" default="0">
<cfparam name="uom_str" default="">
<cfparam name="uom_ptv" default="1">
<cfparam name="where_clause" default="">

<cfset RM_Conversion_Value = .55>

<!---A raw pounds is 55% of a finished pound. So 1 lb raw = .55 lb finished. To convert to raw from finished, divide the finished by .55--->

<cfscript>
	TotalStructCollection = StructNew();
	TotalStructCollection.Count = 0;
	TotalStructCollection.TotalStructs = StructNew();
	
	
	function initTotalStructPrototype(structName) {
		TotalStructCollection.Count = TotalStructCollection.Count+1;
		tempStruct = Duplicate(TotalStructPrototype);
		temp = Evaluate("TotalStructCollection.TotalStructs.Query_#TotalStructCollection.Count#.Name = structName");
		return tempStruct;
	}
	
	function addToTotal(totalStruct, varName, valueToAdd) {
		temp10 = evaluate("totalStruct.#varName#");
		temp20 = temp10 + valueToAdd;
		temp30 = evaluate("totalStruct.#varName# = temp20");
		return temp20;
	}
	
	function EndTotal(totalStruct, varName, valueToAdd) {
		// temp10 = evaluate("totalStruct.#varName#");
		temp20 = valueToAdd;
		temp30 = evaluate("totalStruct.#varName# = temp20");
		return temp20;
	}
</cfscript>

<!--- Query  ---><!---  --->
<CFSET RunQuery= QueryNew("RC,OPID,PID,CURRBAL")>
<cfset temp = queryaddrow(RunQuery)>
<cfset temp = QuerySetCell(RunQuery, "RC", "")>
<cfset temp = QuerySetCell(RunQuery, "OPID", "")>
<cfset temp = QuerySetCell(RunQuery, "PID", "")>
<cfset temp = QuerySetCell(RunQuery, "CURRBAL", "")> 
			
<cfset TotalStructPrototype 			= StructNew()>
<cfset TotalStructPrototype.BegBal 		= 0>
<cfset TotalStructPrototype.Cume 		= 0>
<cfset TotalStructPrototype.BBCurrent 	= 0>
<cfset TotalStructPrototype.BBCume 		= 0>
<cfset TotalStructPrototype.EndBal 		= 0>
<cfset TotalStructPrototype.ValueAvail 	= 0>
<cfset TotalStructPrototype.ValueUsed 	= 0>
<cfset TotalStructPrototype.Cases 		= 0>

</cfsilent>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>USDA NOI</title>
</head>

<body>
<!--- if the user selected a state then an operator and circumvented the county drop down...populate the county id --->
<cfsilent>
<cfif trim(URL.State) NEQ "0" AND trim(URL.Operator) NEQ "0" AND trim(URL.County) EQ "0">
	<cfquery name="getCountyID" datasource="#application.datasource#">
		SELECT     CountyFIPS
		FROM         Operator_ZipCode_Map
		WHERE     (StateFIPS = '#URL.State#') AND (BSA_Operator_ID = '#URL.Operator#')
	</cfquery>
	<cfset URL.County = getCountyID.CountyFIPS>
</cfif>

<cfset criteria = "0_0_0">
<!--- only the state is selected --->
<cfif URL.State NEQ 0 AND URL.County EQ 0 AND URL.Operator EQ 0>
	<cfset where_clause = "WHERE StateFIPS = #URL.State#">
	<cfset criteria = "1_0_0">
</cfif>
<!--- the state and county is selected --->
<cfif URL.State NEQ 0 AND URL.County NEQ 0 AND URL.Operator EQ 0>
	<cfset where_clause = "WHERE StateFIPS = #URL.State# AND CountyFIPS = #URL.County#">
	<cfset criteria = "1_1_0">
	
</cfif>
<!--- the state and county and operator is selected --->
<cfif URL.State NEQ 0 AND URL.County NEQ 0 AND URL.Operator NEQ 0>
	<cfset where_clause = "WHERE StateFIPS = #URL.State# AND CountyFIPS = #URL.County# AND BSA_Operator_ID = #URL.Operator#">
	<cfset criteria = "1_1_1">
</cfif>

<!---It's a distributor--->
<cfif url.Operator NEQ 0 >
	<cfset where_clause = "WHERE BSA_Operator_ID = #URL.Operator#">
	<cfset criteria = "1_1_1">
	
</cfif>

<!---It's a broker--->

<!---The distributor didn't pick any operators--->
<!---It's a distributor--->
<cfif URL.State EQ 0 AND URL.County EQ 0 AND url.Operator EQ 0 AND url.Distributor_ID NEQ 0 AND url.Distributor_ID NEQ "">
	<cfquery name="GetOperators" datasource="#application.datasource#">
	SELECT BSA_Operator.Operator_Name, BSA_Operator.BSA_Operator_ID
	FROM BSA_Operator
	WHERE BSA_Operator.BSA_Operator_ID IN 
		(
		SELECT DISTINCT BSA_Operator_ID
	     FROM          dbo.Contract_Operators
	     WHERE      Contract_Main_ID IN
		     (
			 SELECT DISTINCT dbo.Program_Rebates_Product_Data.Program_ID
		     FROM          dbo.Program_Rebates_Component 
			 INNER JOIN    dbo.Program_Rebates_Component_Data ON 
		     dbo.Program_Rebates_Component.Program_Rebates_Component_ID =
			 dbo.Program_Rebates_Component_Data.Program_Rebates_Component_ID
			 AND Program_Rebates_Component_Data.Deleted = 0
		     INNER JOIN	   dbo.Program_Rebates_Component_Name ON 
		     dbo.Program_Rebates_Component.Program_Rebates_Component_Name_ID =
			 dbo.Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
		     INNER JOIN   dbo.Program_Rebates_Product_Data ON 
		  	 dbo.Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID =
			 dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
			 AND Program_Rebates_Product_Data.Deleted = 0
		     INNER JOIN   dbo.Contract_Main ON 
			 dbo.Program_Rebates_Product_Data.Program_ID = dbo.Contract_Main.Contract_Main_ID
			 AND Contract_Main.Deleted = 0
			 INNER JOIN   Contract_Distributors
			 ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			 AND Contract_Distributors.Deleted = 0
			 AND Contract_Distributors.BSA_Foodservice_Customers_ID = '#Distributor_ID#'
		     WHERE      (dbo.Program_Rebates_Component_Name.Is_USDA_NOI_Comp = 1) AND 
			 			(dbo.Contract_Main.Deleted = 0) 		
			 AND (Contract_Main.Contract_Status_Type_IDX >= 3)
			 AND (Contract_Main.Contract_Status_Type_IDX != 7)
			 )
		 
		AND (Contract_Operators.Deleted = 0)
		) 
	AND BSA_Operator.Deleted = 0
	</cfquery>
	<cfset AllOperators = valuelist(GetOperators.BSA_Operator_ID)>
	<cfset where_clause = "WHERE BSA_Operator_ID IN (#AllOperators#)">
	<cfset criteria = "1_1_1">
</cfif>

<cfset useLakebaseForgetUSDAUserStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUSDAUserStatus>
	<cftry>
		<cfset getUSDAUserStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "is_usda_user,user_usda_state_id,user_usda_county_id,user_usda_operator_id,user_usda_distributor_id,user_usda_distributor_id_list,user_usda_broker_id_list,user_usda_operator_id_list"
			}), "is_usda_user,user_usda_state_id,user_usda_county_id,user_usda_operator_id,user_usda_distributor_id,user_usda_distributor_id_list,user_usda_broker_id_list,user_usda_operator_id_list"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUSDAUserStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUSDAUserStatus>
<cfquery name="getUSDAUserStatus" datasource="#application.datasource#">
 	SELECT Is_USDA_User, user_usda_state_id, user_usda_county_id, user_usda_operator_id, user_usda_distributor_id, user_usda_distributor_id_list, user_usda_broker_id_list, user_usda_operator_id_list
	FROM _Users
	WHERE User_ID = '#request.AccessStructure.User_ID#'
  </cfquery>
</cfif>

  <cfif url.Operator EQ 0 AND  ((len(trim(getUSDAUserStatus.user_usda_distributor_ID)) GT 0 AND  getUSDAUserStatus.user_usda_distributor_ID IS NOT 0) OR (len(trim(getUSDAUserStatus.user_usda_distributor_id_list)) GT 0 AND getUSDAUserStatus.user_usda_distributor_id_list IS NOT 0) OR  (len(trim(getUSDAUserStatus.user_usda_operator_id_list)) GT 0 AND getUSDAUserStatus.user_usda_operator_id_list IS NOT 0) OR (len(trim(getUSDAUserStatus.user_usda_broker_id_list)) GT 0 AND getUSDAUserStatus.user_usda_broker_id_list IS NOT 0))>	

	<cfinclude template="getOperatorList.cfm">
	<cfset AllOperators = valuelist(GetOperators.BSA_Operator_ID)>
	<cfset where_clause = "WHERE BSA_Operator_ID IN (#AllOperators#)">
	<cfset criteria = "1_1_1">
	
</cfif>
</cfsilent>
<cfsavecontent variable="Page_Content">

<cfsavecontent variable="PRINTER_FRIENDLY_PAGE_BUFFER_1">
		<table align="center" border="<cfif url.ReportType EQ "export_to_excel" or url.SummaryExport eq "summaryexportexcel">1<cfelse>0</cfif>" cellpadding="3" cellspacing="0" style="width: 90%" id="table1">
		<!--- <table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0"> --->

	<!--- Dev Note: KAL - D8021 --->
		<!--- Query Data For the Report --->
		<cfquery name="TheQuery" datasource="#application.datasource#">
			SELECT *
			FROM USDANOI_Output
			#where_clause#
			<cfif url.Distributor NEQ 0 and url.Distributor NEQ "">
			and Distributor_ID = '#url.Distributor#'
			</cfif>
			ORDER BY  Operator_Name, BB_Date_Year, BB_Date_Month_Number, Item, BB_Title
		</cfquery>		
		<cfif url.ReportType NEQ "export_to_excel" and url.SummaryExport neq "summaryexportexcel">
		<cfinclude template="selReportUOM_tblrow.cfm">
		</cfif>
		
		<cfif url.ReportType EQ "operator" OR url.ReportType EQ "verification">
				<cfinclude template="table_header_operator_summary.cfm">
			<cfelseif url.ReportType EQ "export_to_excel">
				<cfinclude template="excel_report_header.cfm">
			<cfelseif url.ReportType NEQ "Summary">
				<cfinclude template="table_header.cfm">
		  </cfif>
		<!---There aren't any records returned, so go do a report that doesn't expect any billbacks--->
		<cfif theQuery.Recordcount IS 0>
			<cfinclude template="report_without_billbacks.cfm">
		<cfelse>					
		 <cfswitch expression="#url.ReportType#">
			 <!---  REPORT : Operator ---> 
			 <cfcase value="operator">
	 			<cfinclude template="operator_report_include.cfm">
		 	</cfcase>
			 <!---  REPORT : Verification ---> 
			 <cfcase value="verification">
 				<cfinclude template="operator_report_include.cfm">
		 	</cfcase>

			<!--- REPORT: ITEM ---> 
			<cfcase value="item"> 
				<cfinclude template="item_report_include.cfm">	
		 	</cfcase>		

			 <!---  REPORT : Operator/Item ---> 
			<cfcase value="operator-item"> 
				<cfinclude template="operator_item_report_include.cfm">
			</cfcase>

			 <!---  REPORT : Operator/Month/Item ---> 
			<cfcase value="operator-month-item"> 
				<cfinclude template="operator_month_item_report_include.cfm">
			</cfcase>
			
			<!---  REPORT : Summary---> 
			<cfcase value="summary"> 
				<cfinclude template="summary_include.cfm">
			</cfcase>
			
			<!---  REPORT : Summary---> 
			<cfcase value="Available_item_report"> 
				<cfinclude template="report_without_billbacks.cfm">
			</cfcase>
			
				<!---  REPORT : Summary---> 
			<cfcase value="export_to_excel"> 
				<cfinclude template="excel_report_include.cfm">
			</cfcase>
		</cfswitch>
		
		<!---TheQuery.Recordcount GT 0--->
		</cfif>
		</table>
			<!--- <cfdump var="#variables#"> --->
<script>
function summaryexporttoexcel()
	{
	document.all.frmChangeReportUOM.SummaryExport.value="summaryexportexcel";
	document.all.frmChangeReportUOM.AllOperators.value="";
	document.all.frmChangeReportUOM.submit();
	}
</script>
</cfsavecontent>

<cfoutput>#PRINTER_FRIENDLY_PAGE_BUFFER_1#</cfoutput>

<cfsavecontent variable="PRINTER_FRIENDLY_PAGE_BUFFER_2">

</cfsavecontent>	
<cfif url.ReportType NEQ "export_to_excel" and url.SummaryExport neq "summaryexportexcel">
		<table align="center">
			<tr bgcolor="#FFFFFF">
				<td align="right" style="cursor: hand;" onclick="window.location.href = '/settings/usdanoi/search.cfm'"><b><font color="#FF0000">[</font> 
				<font color="#0000FF">change report criteria</font>
				<font color="#FF0000">]</font></b></td>
				<td>&nbsp;</td>
		<cfif url.ReportType EQ "Summary">
		<TD align="center">
			<CF_button
				button_name		=	""
				button_caption	=	"export to excel"
				button_action	=	"summaryexporttoexcel()"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Export to Excel"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>	
		</cfif>	
				<td>&nbsp;</td>
			</tr>		
		</table>
</cfif>
</cfsavecontent>

<cfoutput>#Page_Content#</cfoutput>

<cfif url.ReportType NEQ "export_to_excel" and url.SummaryExport neq "summaryexportexcel">
<cffile action="WRITE" file="#APPPATH#\#url.file_printer_friendly#" output="#Printer_Friendly_Page_Buffer_1##Printer_Friendly_Page_Buffer_2#" addnewline="Yes">
</cfif>

