<cfparam name="url.state" default="0">
<cfparam name="url.county" default="0">
<cfparam name="url.operator" default="0">

<cfparam name="url.operatorid" default="0">
<cfparam name="url.productid" default="0">
<cfparam name="url.programid" default="0">


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
</cfscript>

<!--- Query  --->
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





<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>USDA NOI</title>
</head>

<body>
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

<cfsavecontent variable="Page_Content">

<cfsavecontent variable="PRINTER_FRIENDLY_PAGE_BUFFER_1">
		<table align="center" border="0" cellpadding="3" cellspacing="0" style="width: 90%" id="table1">
		<!--- <table align="center" border="0" cellpadding="3" cellspacing="1" style="width: 90%" id="table1" bgcolor="#C0C0C0"> --->
		<cfinclude template="selReportUOM_tblrow.cfm">
				<!--- <cfif url.ReportBBDetail EQ 1> --->
				<cfif 1 EQ 1>
				<cfif url.ReportType EQ "operator">
					<cfinclude template="table_header_operator_summary.cfm">
				<cfelse>
					<cfinclude template="table_header.cfm">
				</cfif>
				</cfif>
	 
		<cfswitch expression="#url.ReportType#">
			<!--- <!---  REPORT : Operator ---> --->
			<cfcase value="operator">

			<CFSET QueryTotalStructName = "QueryTotalStructName_1">
			<cfset #QueryTotalStructName# = initTotalStructPrototype("QueryTotalStructName_1")>

			<cfquery name="TheQuery" datasource="#application.datasource#">
				SELECT * 
				FROM USDANOI_OP_BB_ITEM
				#where_clause#
			</cfquery>
			
			<!--- operator --->
			<cfset thisCurrentrow = 0>
			<cfoutput query="TheQuery" group="Operator_Name">
			<CFSET OPTotalStructName = "OPTotalStructName_#TheQuery.BSA_Operator_ID#">
			<cfset #OPTotalStructName# = initTotalStructPrototype("BBTotalStruct_#TheQuery.BSA_Operator_ID#")>

				<cfif url.ReportBBDetail EQ 0>
					<cfset thisCurrentrow = thisCurrentrow + 1>
				</cfif>
				<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##ffffcc</cfif>"><b style="font-size: 11px;">
					<td colspan="<cfif url.ReportBBDetail EQ 1>100%<cfelse>3</cfif>" nowrap><cfif url.ReportBBDetail EQ 1><b><font size="2">#TheQuery.Operator_Name#</font></b><cfelse>#TheQuery.Operator_Name#</cfif></b></td>
				<cfif url.ReportBBDetail EQ 1></tr></cfif>
				
				<cfif 1 EQ 1><!--- <cfif url.ReportBBDetail EQ 1> --->
				<!--- Billback --->
				<cfoutput group="BB_Title">
				
					<cfset tempBBID = replace(TheQuery.Billback_ID, "-", "_", "ALL")>
					<CFSET thisTotalStructName = "BBTotalStruct_#tempBBID#">
					<cfset #thisTotalStructName# = initTotalStructPrototype("BBTotalStruct_#tempBBID#")>
				
				<cfif url.ReportBBDetail EQ 1>
				<tr>
					<td colspan="100%" bgcolor="##f0fff0">&nbsp;&nbsp;<a href="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#">#TheQuery.BB_Title# - #TheQuery.BB_Reference#</a></td>
				</tr>
				</cfif>

				<!--- Item --->
				<cfset uom_TotalClaimAmount = 0>
				<cfoutput group="Item">
		
					<cfquery name="getRowCount" dbtype="query">
						SELECT count(*) AS TotalRows
						FROM RunQuery
					</cfquery>
					
					<CFSET TotalRowCount = getRowCount.TotalRows>
					
					<cfif len(trim(TotalRowCount)) EQ 0>
						<CFSET TotalRowCount = 0>
					</cfif>
					<CFSET NextTotalRowCount = TotalRowCount + 1>
					
					<CFIF TotalRowCount GT 0>
						<cfquery name="checkRunQuery" dbtype="query">
							SELECT * 
							FROM RunQuery
							WHERE 
							OPID = '#TheQuery.BSA_Operator_ID#'
 							AND
							PID = '#toString(TheQuery.BSA_Foodservice_Items_Master_ID)#'
						</cfquery>
					<cfelse>
						<CFSET checkRunQuery.recordcount = 0>
					</CFIF>
					
					<cfif checkRunQuery.recordcount EQ 0>
						<!--- <cfdump var="#RunQuery#"> --->
						<cfset uom_LastBBClaim	 = 0>
						
						<cfswitch expression="#lcase(url.ReportUOM)#">
							<cfcase value="1"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_CS></cfcase>
							<cfcase value="2"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_LB></cfcase>
							<cfcase value="rm"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_RM></cfcase>
						</cfswitch>							
						
						
						
						<cfset temp = queryaddrow(RunQuery)>
						<cfset temp = QuerySetCell(RunQuery, "RC", NextTotalRowCount)>
						<cfset temp = QuerySetCell(RunQuery, "OPID", toString(trim(TheQuery.BSA_Operator_ID)))>
						<cfset temp = QuerySetCell(RunQuery, "PID", toString(trim(TheQuery.BSA_Foodservice_Items_Master_ID)))>
						<cfset temp = QuerySetCell(RunQuery, "CURRBAL", uom_BegBal)>
						<!--- <cfdump var="#RunQuery#"> --->
					<cfelse>
						<cfswitch expression="#lcase(url.ReportUOM)#">
							<cfcase value="1"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_CS></cfcase>
							<cfcase value="2"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_LB></cfcase>
							<cfcase value="rm"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_RM></cfcase>
						</cfswitch>							

						<cfset uom_BegBal 		= checkRunQuery.CURRBAL - uom_LastBBClaim>
						<cfset temp 			= QuerySetCell(RunQuery, "CURRBAL", uom_BegBal, checkRunQuery.RC)>
					</cfif>
		
					
					<cfswitch expression="#lcase(url.ReportUOM)#">
						<cfcase value="1"><!--- cs --->
							<cfset uom_PTV 							= TheQuery.PTV_CS>
							<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
							<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_CS>
							<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_CS>
							<cfset uom_str = "&nbsp;cs">
						</cfcase>
						<cfcase value="2"><!--- lb --->
							<cfset uom_PTV 							= TheQuery.PTV_LB>
							<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
							<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_LB>
							<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_LB>
							<cfset uom_str = "&nbsp;lbs">
						</cfcase>
						<cfcase value="rm"><!--- rm --->
							<cfset uom_PTV 							= TheQuery.PTV_RM>
							<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
							<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_RM>
							<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_RM>
							<cfset uom_str = "&nbsp;lbs">
						</cfcase>
					</cfswitch>

					<cfset uom_TotalClaimAmount 			= uom_TotalClaimAmount + uom_LastBBClaim>
					<cfset uom_EndingBalance				= uom_BegBal-uom_TotalClaimAmount>
					
					<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
					
					<cfset temp = addToTotal(thisTotalStructName, "BEGBAL", uom_BegBal)>
					<cfset temp = addToTotal(thisTotalStructName, "BBCURRENT", uom_LastBBClaim)>
					<cfset temp = addToTotal(thisTotalStructName, "BBCUME", uom_TotalClaimAmount)>
					<cfset temp = addToTotal(thisTotalStructName, "ENDBAL", uom_EndingBalance)>
					<cfset temp = addToTotal(thisTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>
					
				<cfif url.ReportBBDetail EQ 1>
					<cfset thisCurrentrow = thisCurrentrow + 1>
					<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
						<td colspan="2" align="right">&nbsp;&nbsp;&nbsp;&nbsp;#TheQuery.Item#</td>
								<Td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</TD>
								
								<td align="right">
								<!--- Beggining Volume --->
								#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#
								</td>

								<Td align="right">#trim(NumberFormat(0, '___,___,___,___,___'))#</TD>
								<td align="right">#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#</td>
								<td align="right">
									#trim(NumberFormat(uom_LastBBClaim, '___,___,___,___,___'))#						
								</td>
								<td align="right">
									#trim(NumberFormat(uom_TotalClaimAmount, '___,___,___,___,___'))#								
								</td>
								<td align="right">
									#trim(NumberFormat(uom_EndingBalance, '___,___,___,___,___'))#
								</td>
								<td align="right">$#trim(NumberFormat(uom_ValueAvailable, '___,___,___,___,___.__'))#</td> 							
					</tr>
				</cfif>
				</cfoutput><!---  end item --->
				
				<cfif url.ReportBBDetail EQ 1>
				<!--- BILLBACK TOTAL --->
				<tr bgcolor="##4169e1">	
					<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="color: white;" nowrap><b><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Delivery Total:</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(thisTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>0#uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(thisTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(thisTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(thisTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(thisTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>$#trim(NumberFormat(thisTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				</cfif>
				<cfset temp = addToTotal(OPTotalStructName, "BEGBAL", thisTotalStructName.BEGBAL)>
				<cfset temp = addToTotal(OPTotalStructName, "BBCURRENT", thisTotalStructName.BBCURRENT)>
				<cfset temp = addToTotal(OPTotalStructName, "BBCUME", thisTotalStructName.BBCUME)>
				<cfset temp = addToTotal(OPTotalStructName, "ENDBAL", thisTotalStructName.ENDBAL)>
				<cfset temp = addToTotal(OPTotalStructName, "VALUEAVAIL", thisTotalStructName.VALUEAVAIL)>
				</cfoutput><!--- end billback --->
				</cfif>
				
				<!--- Operator Sums --->
				<cfif url.ReportBBDetail EQ 0>
						<cfset tempuom_str = uom_str>
						<cfset uom_str = "">
						<td align="right">#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</td>
						<td align="right">0#uom_str#</td>
						<td align="right">#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</td>
						<td align="right">#trim(NumberFormat(OPTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</td>
						<td align="right">#trim(NumberFormat(OPTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</td>
						<td align="right">#trim(NumberFormat(OPTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</td>
						<td align="right"d>$#trim(NumberFormat(OPTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</td>
					</tr>

					<cfset uom_str = tempuom_str>
				<cfelse>							
					<tr bgcolor="##6a5acd">	
						<cfset thisStrLen = len(TheQuery.Operator_Name)>
						<cfset maxStrLen = 40>
						<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="color: white;" nowrap><b>#MID(TheQuery.Operator_Name, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b></td>
						<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right" style="color: white;"><b>0#uom_str#</b></td>
						<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
						<td align="right" style="color: white;"><b>$#trim(NumberFormat(OPTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
					</tr>
					<tr>
						<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
					</tr>						
				</cfif>

				<!--- SUM UP OPERATORS for Report Total--->
				<cfset temp = addToTotal(QueryTotalStructName, "BEGBAL", OPTotalStructName.BEGBAL)>
				<cfset temp = addToTotal(QueryTotalStructName, "BBCURRENT", OPTotalStructName.BBCURRENT)>
				<cfset temp = addToTotal(QueryTotalStructName, "BBCUME", OPTotalStructName.BBCUME)>
				<cfset temp = addToTotal(QueryTotalStructName, "ENDBAL", OPTotalStructName.ENDBAL)>
				<cfset temp = addToTotal(QueryTotalStructName, "VALUEAVAIL", OPTotalStructName.VALUEAVAIL)>
			</cfoutput><!--- end operator --->
			
			
			<!--- <!--- SHOW REPORT TOTAL ---> --->
			<cfoutput>		
			<tr>	
				<td colspan="3" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>0#uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(QueryTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
				<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>$#trim(NumberFormat(QueryTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>
			<tr>
				<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
			</tr>		
			</cfoutput>
			
			</cfcase>
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			<!--- REPORT: ITEM ---> 
			<cfcase value="item">
				<cfset thisCurrentrow = 0>
				<CFSET TotalItemTotalStructName = "TotalItemTotalStructName">
				<cfset #TotalItemTotalStructName# = initTotalStructPrototype("TotalItemTotalStructName")>

				<cfquery name="TheQuery" datasource="#application.datasource#">
					SELECT * 
					FROM USDANOI_ITEM_OP_BB
					#where_clause#
				</cfquery>
			
				<cfoutput query="TheQuery" group="Item">
				<cfswitch expression="#lcase(url.ReportUOM)#">
					<cfcase value="1"><!--- cs --->
						<cfset uom_PTV 							= TheQuery.PTV_CS>
						<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
						<cfset uom_str = "&nbsp;cs">
					</cfcase>
					<cfcase value="2"><!--- lb --->
						<cfset uom_PTV 							= TheQuery.PTV_LB>
						<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
						<cfset uom_str = "&nbsp;lbs">
					</cfcase>
					<cfcase value="rm"><!--- rm --->
						<cfset uom_PTV 							= TheQuery.PTV_RM>
						<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
						<cfset uom_str = "&nbsp;lbs">
					</cfcase>
				</cfswitch>

				<CFSET ItemTotalStructName = "ItemTotalStructName_#TheQuery.BSA_Foodservice_Items_Master_ID#">
				<cfset #ItemTotalStructName# = initTotalStructPrototype("ItemTotalStructName_#TheQuery.BSA_Foodservice_Items_Master_ID#")>

				<cfif url.ReportBBDetail EQ 0>
					<cfset thisCurrentrow = thisCurrentrow + 1>
				</cfif>
					<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##ffffcc</cfif>"><b style="font-size: 11px;">
						<td  nowrap><cfif url.ReportBBDetail EQ 1><b><font size="2">#TheQuery.Item#</font></b><cfelse>#TheQuery.Item#</cfif></td>
						<td colspan="<cfif url.ReportBBDetail EQ 1>99%<cfelse>1</cfif>" nowrap><cfif url.ReportBBDetail EQ 1><b><font size="2">#TheQuery.Description#</font></b><cfelse>#TheQuery.Description#</cfif></td>
						<cfif url.ReportBBDetail EQ 0><td align="right"><b>#trim(numberformat(uom_PTV, '___,___,___.____'))##uom_str#</b></td></cfif>
					<cfif url.ReportBBDetail EQ 1></tr></cfif>
					
 					<cfoutput group="Operator_Name">
					<CFSET OpItemTotalStructName = "OpItemTotalStructName_#replace(TheQuery.BSA_Foodservice_Items_Master_ID, '-','_','ALL')#">
					<cfset #OpItemTotalStructName# = initTotalStructPrototype("OpItemTotalStructName_#replace(TheQuery.BSA_Foodservice_Items_Master_ID, '-','_','ALL')#")>
						
						<cfif url.ReportBBDetail EQ 1>
						<tr>
							<td colspan="100%">&nbsp;&nbsp;<b><font size="2">#TheQuery.Operator_Name#</font></b></td>
						</tr>
						</cfif>
						
						<cfset uom_TotalClaimAmount = 0>
						<cfoutput group="BB_Title">
							
								<cfquery name="getRowCount" dbtype="query">
									SELECT count(*) AS TotalRows
									FROM RunQuery
								</cfquery>
								
								<CFSET TotalRowCount = getRowCount.TotalRows>
								
								<cfif len(trim(TotalRowCount)) EQ 0>
									<CFSET TotalRowCount = 0>
								</cfif>
								<CFSET NextTotalRowCount = TotalRowCount + 1>
								
								<CFIF TotalRowCount GT 0>
									<cfquery name="checkRunQuery" dbtype="query">
										SELECT * 
										FROM RunQuery
										WHERE 
										OPID = '#TheQuery.BSA_Operator_ID#'
			 							AND
										PID = '#toString(TheQuery.BSA_Foodservice_Items_Master_ID)#'
									</cfquery>
								<cfelse>
									<CFSET checkRunQuery.recordcount = 0>
								</CFIF>
								
								<cfif checkRunQuery.recordcount EQ 0>
									<!--- <cfdump var="#RunQuery#"> --->
									<cfset uom_LastBBClaim	 = 0>
									
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_CS></cfcase>
										<cfcase value="2"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_LB></cfcase>
										<cfcase value="rm"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_RM></cfcase>
									</cfswitch>							
									
									
									
									<cfset temp = queryaddrow(RunQuery)>
									<cfset temp = QuerySetCell(RunQuery, "RC", NextTotalRowCount)>
									<cfset temp = QuerySetCell(RunQuery, "OPID", toString(trim(TheQuery.BSA_Operator_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "PID", toString(trim(TheQuery.BSA_Foodservice_Items_Master_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "CURRBAL", uom_BegBal)>
									<!--- <cfdump var="#RunQuery#"> --->
								<cfelse>
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_CS></cfcase>
										<cfcase value="2"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_LB></cfcase>
										<cfcase value="rm"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_RM></cfcase>
									</cfswitch>							
			
									<cfset uom_BegBal 		= checkRunQuery.CURRBAL - uom_LastBBClaim>
									<cfset temp 			= QuerySetCell(RunQuery, "CURRBAL", uom_BegBal, checkRunQuery.RC)>
								</cfif>
					
								
								<cfswitch expression="#lcase(url.ReportUOM)#">
									<cfcase value="1"><!--- cs --->
										<cfset uom_PTV 							= TheQuery.PTV_CS>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_CS>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_CS>
										<cfset uom_str = "&nbsp;cs">
									</cfcase>
									<cfcase value="2"><!--- lb --->
										<cfset uom_PTV 							= TheQuery.PTV_LB>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_LB>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_LB>
										<cfset uom_str = "&nbsp;lbs">
									</cfcase>
									<cfcase value="rm"><!--- rm --->
										<cfset uom_PTV 							= TheQuery.PTV_RM>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_RM>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_RM>
										<cfset uom_str = "&nbsp;lbs">
									</cfcase>
								</cfswitch>
			
								<cfset uom_TotalClaimAmount 			= uom_TotalClaimAmount + uom_LastBBClaim>
								<cfset uom_EndingBalance				= uom_BegBal-uom_TotalClaimAmount>
								<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
								
								<cfset temp = addToTotal(OpItemTotalStructName, "BEGBAL", uom_BegBal)>
								<cfset temp = addToTotal(OpItemTotalStructName, "BBCURRENT", uom_LastBBClaim)>
								<cfset temp = addToTotal(OpItemTotalStructName, "BBCUME", uom_TotalClaimAmount)>
								<cfset temp = addToTotal(OpItemTotalStructName, "ENDBAL", uom_EndingBalance)>
								<cfset temp = addToTotal(OpItemTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>
							<cfif url.ReportBBDetail EQ 1>
								<cfset thisCurrentrow = thisCurrentrow + 1>
								<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
									<td colspan="2" align="right">&nbsp;&nbsp;&nbsp;&nbsp;<a href="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#">#TheQuery.BB_Title# - #TheQuery.BB_Reference#</a></td>
									<Td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</TD>
									
									<td align="right">
									<!--- Beggining Volume --->
									#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#
									</td>
	
									<Td align="right">#trim(NumberFormat(0, '___,___,___,___,___'))#</TD>
									<td align="right">#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#</td>
									<td align="right">
										#trim(NumberFormat(uom_LastBBClaim, '___,___,___,___,___'))#						
									</td>
									<td align="right">
										#trim(NumberFormat(uom_TotalClaimAmount, '___,___,___,___,___'))#								
									</td>
									<td align="right">
										#trim(NumberFormat(uom_EndingBalance, '___,___,___,___,___'))#
									</td>
									<td align="right">$#trim(NumberFormat(uom_ValueAvailable, '___,___,___,___,___.__'))#</td> 							
								</tr>
							</cfif>
						</cfoutput>
					<cfif url.ReportBBDetail EQ 1>
						<cfset thisStrLen1 = len(TheQuery.Operator_Name)>
						<cfset thisStrLen2 = len(TheQuery.Item)>
						<cfset maxStrLen = 20>
						<tr bgcolor="##4169e1">	
							<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="color: white;" nowrap><b>#MID(TheQuery.Operator_Name, 1, maxStrLen)#<cfif thisStrLen1 GT maxStrLen>...</cfif>&nbsp;#MID(TheQuery.Item, 1, maxStrLen)#<cfif thisStrLen2 GT maxStrLen>...</cfif> Total:</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>0#uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>$#trim(NumberFormat(OpItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
						</tr>
						<tr>
							<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
						</tr>
					</cfif>
					<cfset temp = addToTotal(ItemTotalStructName, "BEGBAL", OpItemTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(ItemTotalStructName, "BBCURRENT", OpItemTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(ItemTotalStructName, "BBCUME", OpItemTotalStructName.BBCUME)>
					<cfset temp = addToTotal(ItemTotalStructName, "ENDBAL", OpItemTotalStructName.ENDBAL)>
					<cfset temp = addToTotal(ItemTotalStructName, "VALUEAVAIL", OpItemTotalStructName.VALUEAVAIL)>
					</cfoutput> 
						<!--- Item Sums --->
						<cfif url.ReportBBDetail EQ 0>
								<cfset tempuom_str = uom_str>
								<cfset uom_str = "">
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"><b>0#uom_str#</b></td>
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"><b>#trim(NumberFormat(ItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right"d><b>$#trim(NumberFormat(ItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
							</tr>
		
							<cfset uom_str = tempuom_str>
						<cfelse>
							<tr bgcolor="##6a5acd">	
								<cfset thisStrLen = len(TheQuery.Item)>
								<cfset maxStrLen = 40>
								<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="color: white;" nowrap><b>#MID(TheQuery.Item, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>0#uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(ItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>$#trim(NumberFormat(ItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
							</tr>
							<tr>
								<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
							</tr>
						</cfif>
							<cfset temp = addToTotal(TotalItemTotalStructName, "BEGBAL", ItemTotalStructName.BEGBAL)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "BBCURRENT", ItemTotalStructName.BBCURRENT)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "BBCUME", ItemTotalStructName.BBCUME)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "ENDBAL", ItemTotalStructName.ENDBAL)>
							<cfset temp = addToTotal(TotalItemTotalStructName, "VALUEAVAIL", ItemTotalStructName.VALUEAVAIL)>
				</cfoutput>
				
				<cfoutput>
				<tr>	
					<td colspan="3" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>0#uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>$#trim(NumberFormat(TotalItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				</cfoutput>			
			</cfcase>		
			
			
			
			
			
			
			

			<cfcase value="operator-item">
			<cfset thisCurrentrow = 0>
				<cfquery name="TheQuery" datasource="#application.datasource#">
					SELECT * 
					FROM USDANOI_OP_ITEM_BB
					#where_clause#
				</cfquery>
				<CFSET TotalStructName = "TotalStructName">
				<cfset #TotalStructName# = initTotalStructPrototype("TotalStructName")>
				<cfset thisCurrentrow = 0>
				<cfoutput query="TheQuery" group="Operator_Name">
				<CFSET OPTotalStructName = "OPTotalStructName_#TheQuery.BSA_Operator_ID#">
				<cfset #OPTotalStructName# = initTotalStructPrototype("OPTotalStructName_#TheQuery.BSA_Operator_ID#")>

	
				<tr>
					<td colspan="100%" nowrap><FONT size="3"><b>#TheQuery.Operator_Name#</b></FONT></b></td>
				</tr>

					<cfoutput group="Item">
	
					<cfif url.ReportBBDetail EQ 0>
						<cfset thisCurrentrow = thisCurrentrow + 1>
					</cfif>
	
					<CFSET OpItemTotalStructName = "OpItemTotalStructName_#BSA_operator_id##replace(TheQuery.BSA_Foodservice_Items_Master_ID, '-','_','ALL')#">
					<cfset #OpItemTotalStructName# = initTotalStructPrototype("OpItemTotalStructName_#BSA_operator_id##replace(TheQuery.BSA_Foodservice_Items_Master_ID, '-','_','ALL')#")>
					
					<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##f0fff0</cfif>"><b style="font-size: 11px;">
						<td  nowrap><FONT size="2"><b>#TheQuery.Item#</b></FONT></td>
						<td  colspan="<cfif url.ReportBBDetail EQ 1>99%<cfelse>1</cfif>" nowrap><FONT size="2">#TheQuery.Description#</FONT></td>
						<cfif url.ReportBBDetail EQ 1></tr></cfif>
						
						<cfset UOM_TOTALCLAIMAMOUNT = 0>
						
						<cfoutput group="BB_Title">
								<cfquery name="getRowCount" dbtype="query">
									SELECT count(*) AS TotalRows
									FROM RunQuery
								</cfquery>
								
								<CFSET TotalRowCount = getRowCount.TotalRows>
								
								<cfif len(trim(TotalRowCount)) EQ 0>
									<CFSET TotalRowCount = 0>
								</cfif>
								<CFSET NextTotalRowCount = TotalRowCount + 1>
								
								<CFIF TotalRowCount GT 0>
									<cfquery name="checkRunQuery" dbtype="query">
										SELECT * 
										FROM RunQuery
										WHERE 
										OPID = '#TheQuery.BSA_Operator_ID#'
			 							AND
										PID = '#toString(TheQuery.BSA_Foodservice_Items_Master_ID)#'
									</cfquery>
								<cfelse>
									<CFSET checkRunQuery.recordcount = 0>
								</CFIF>
								
								<cfif checkRunQuery.recordcount EQ 0>
									<!--- <cfdump var="#RunQuery#"> --->
									<cfset uom_LastBBClaim	 = 0>
									
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_CS></cfcase>
										<cfcase value="2"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_LB></cfcase>
										<cfcase value="rm"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_RM></cfcase>
									</cfswitch>							
									
									
									
									<cfset temp = queryaddrow(RunQuery)>
									<cfset temp = QuerySetCell(RunQuery, "RC", NextTotalRowCount)>
									<cfset temp = QuerySetCell(RunQuery, "OPID", toString(trim(TheQuery.BSA_Operator_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "PID", toString(trim(TheQuery.BSA_Foodservice_Items_Master_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "CURRBAL", uom_BegBal)>
									<!--- <cfdump var="#RunQuery#"> --->
								<cfelse>
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_CS></cfcase>
										<cfcase value="2"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_LB></cfcase>
										<cfcase value="rm"><cfset uom_LastBBClaim = TheQuery.LastBBClaim_RM></cfcase>
									</cfswitch>							
			
									<cfset uom_BegBal 		= checkRunQuery.CURRBAL - uom_LastBBClaim>
									<cfset temp 			= QuerySetCell(RunQuery, "CURRBAL", uom_BegBal, checkRunQuery.RC)>
								</cfif>
					
								
								<cfswitch expression="#lcase(url.ReportUOM)#">
									<cfcase value="1"><!--- cs --->
										<cfset uom_PTV 							= TheQuery.PTV_CS>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_CS>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_CS>
										<cfset uom_str = "&nbsp;cs">
									</cfcase>
									<cfcase value="2"><!--- lb --->
										<cfset uom_PTV 							= TheQuery.PTV_LB>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_LB>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_LB>
										<cfset uom_str = "&nbsp;lbs">
									</cfcase>
									<cfcase value="rm"><!--- rm --->
										<cfset uom_PTV 							= TheQuery.PTV_RM>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_RM>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_RM>
										<cfset uom_str = "&nbsp;lbs">
									</cfcase>
								</cfswitch>
			
								<cfset uom_TotalClaimAmount 			= uom_TotalClaimAmount + uom_LastBBClaim>
								<cfset uom_EndingBalance				= uom_BegBal-uom_TotalClaimAmount>
								<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
								
								<cfset temp = addToTotal(OpItemTotalStructName, "BEGBAL", uom_BegBal)>
								<cfset temp = addToTotal(OpItemTotalStructName, "BBCURRENT", uom_LastBBClaim)>
								<cfset temp = addToTotal(OpItemTotalStructName, "BBCUME", uom_TotalClaimAmount)>
								<cfset temp = addToTotal(OpItemTotalStructName, "ENDBAL", uom_EndingBalance)>
								<cfset temp = addToTotal(OpItemTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>
							<cfif url.ReportBBDetail EQ 1>
								<cfset thisCurrentrow = thisCurrentrow + 1>
								<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
									<td colspan="2" align="right">&nbsp;&nbsp;&nbsp;&nbsp;<a href="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#">#TheQuery.BB_Title# - #TheQuery.BB_Reference#</a></td>

									<Td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</TD>
									
									<td align="right">
									<!--- Beggining Volume --->
									#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#
									</td>
	
									<Td align="right">#trim(NumberFormat(0, '___,___,___,___,___'))#</TD>
									<td align="right">#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#</td>
									<td align="right">
										#trim(NumberFormat(uom_LastBBClaim, '___,___,___,___,___'))#						
									</td>
									<td align="right">
										#trim(NumberFormat(uom_TotalClaimAmount, '___,___,___,___,___'))#								
									</td>
									<td align="right">
										#trim(NumberFormat(uom_EndingBalance, '___,___,___,___,___'))#
									</td>
									<td align="right">$#trim(NumberFormat(uom_ValueAvailable, '___,___,___,___,___.__'))#</td> 							
								</tr>
							</cfif>
						</cfoutput>
					
						<cfset thisStrLen1 = len(TheQuery.Operator_Name)>
						<cfset thisStrLen2 = len(TheQuery.Item)>
						<cfset maxStrLen = 20>
						<!--- Item Sums --->
						<cfif url.ReportBBDetail EQ 0>
								<cfset tempuom_str = uom_str>
								<cfset uom_str = "">
								<td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
								<td align="right">#trim(NumberFormat(OpItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">0#uom_str#</b></td>
								<td align="right">#trim(NumberFormat(OpItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</td>
								<td align="right"d>$#trim(NumberFormat(OpItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</td>
							</tr>
							<cfset uom_str = tempuom_str>
						<cfelse>
							<tr bgcolor="##4169e1">	
								<cfset thisStrLen = len(TheQuery.Operator_Name)>
								<cfset maxStrLen = 40>
								<td colspan="3" align="right" title="#TheQuery.Operator_Name# #TheQuery.BB_Date_Month_String# Results" style="color: white;" nowrap><b>#TheQuery.BB_Date_Month_String# #MID(TheQuery.Item, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>0#uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>$#trim(NumberFormat(OpItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
							</tr>						
							<tr>
								<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
							</tr>
						</cfif>
						
						<cfset temp = addToTotal(OPTotalStructName, "BEGBAL", OpItemTotalStructName.BEGBAL)>
						<cfset temp = addToTotal(OPTotalStructName, "BBCURRENT", OpItemTotalStructName.BBCURRENT)>
						<cfset temp = addToTotal(OPTotalStructName, "BBCUME", OpItemTotalStructName.BBCUME)>
						<cfset temp = addToTotal(OPTotalStructName, "ENDBAL", OpItemTotalStructName.ENDBAL)>
						<cfset temp = addToTotal(OPTotalStructName, "VALUEAVAIL", OpItemTotalStructName.VALUEAVAIL)>
										
					</cfoutput>
		
					<cfset temp = addToTotal(TotalStructName, "BEGBAL", OPTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(TotalStructName, "BBCURRENT", OPTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(TotalStructName, "BBCUME", OPTotalStructName.BBCUME)>
					<cfset temp = addToTotal(TotalStructName, "ENDBAL", OPTotalStructName.ENDBAL)>
					<cfset temp = addToTotal(TotalStructName, "VALUEAVAIL", OPTotalStructName.VALUEAVAIL)>
				<!--- <cfif url.ReportBBDetail EQ 1> --->
				<cfset thisStrLen1 = len(TheQuery.Operator_Name)>
				<cfset thisStrLen2 = len(TheQuery.Item)>
				<cfset maxStrLen = 20>
				
				<tr bgcolor="##6a5acd">	
					<cfset thisStrLen = len(TheQuery.Operator_Name)>
					<cfset maxStrLen = 40>
					<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="color: white;" nowrap><b>#MID(TheQuery.Operator_Name, 1, maxStrLen)#<cfif thisStrLen1 GT maxStrLen>...</cfif> Total:</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>0#uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="color: white;"><b>$#trim(NumberFormat(OPTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				<!--- </cfif> --->
				</cfoutput>
					
				<cfoutput>
				<tr>	
					<td colspan="3" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>0#uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>$#trim(NumberFormat(TotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>

				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				</cfoutput>
			</cfcase>
			
			
			
					
			
			
			
			
			
			
			
			
			<cfcase value="operator-month-item">
			<cfset thisCurrentrow = 0>

			<!--- Query Data For the Report --->
			<cfquery name="TheQuery" datasource="#application.datasource#">
				SELECT * 
				FROM USDANOI_OP_MONTH_ITEM_BB
				#where_clause#
				ORDER BY  Operator_Name, BB_Date_Month_Number, Item, BB_Title
			</cfquery>

			<!--- Init Variable to tally up Report Total --->
			<CFSET TotalStructName = "TotalStructName">
			<cfset #TotalStructName# = initTotalStructPrototype("TotalStructName")>
			<cfset thisCurrentrow = 0>
			
			
			<!--- Begin Report Output --->
			<cfoutput query="TheQuery" group="Operator_Name">

				<!--- Init Variable to tally up OPERATOR Total --->
				<CFSET OPTotalStructName = "OPTotalStructName_#TheQuery.BSA_Operator_ID#">
				<cfset #OPTotalStructName# = initTotalStructPrototype("OPTotalStructName_#TheQuery.BSA_Operator_ID#")>

					
					<!--- Operator Row --->
					<tr>
						<td colspan="100%" nowrap align="left"><FONT FACE="Arial" size="3"><b>#TheQuery.Operator_Name#</b></FONT><hr color="Navy" width="50%"></td>
					</tr>
					<!--- Init Variable to tally up OPERATOR/MONTH Total --->
					<CFSET OPMonthTotalStructName = "OPMonthTotalStructName_#BSA_operator_id##BB_Date_Month_String#">
					<cfset #OPMonthTotalStructName# = initTotalStructPrototype("OPMonthTotalStructName_#BSA_operator_id##BB_Date_Month_String#")>

					<!--- Begin Month Output --->
					<cfoutput group="BB_Date_Month_Number">

						<!--- Month Row --->
						<tr>
							<td colspan="100%" nowrap><FONT FACE="Arial" size="2"><b>#TheQuery.BB_Date_Month_String#</b></td>
						</tr>
						
					<!--- Begin Item Output --->
					
					<cfoutput group="Item">
					<!--- Init Variable to tally up OPERATOR/MONTH/Item Total --->
					<cfset OpMonthItemTotalStructName = "">
					<cfset OpMonthItemTotalStructName = initTotalStructPrototype("OpMonthItemTotalStructName_#createuuid()#")>

					<cfif url.ReportBBDetail EQ 0>
						<cfset thisCurrentrow = thisCurrentrow + 1>
					</cfif>
					
					<tr bgcolor="<cfif url.ReportBBDetail EQ 0><CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF><cfelse>##f0fff0</cfif>"><b style="font-size: 11px;">
						<td  nowrap>#TheQuery.Item#</b></td>
						<td  colspan="<cfif url.ReportBBDetail EQ 1>99%<cfelse>1</cfif>" nowrap>#TheQuery.Description#</b></td>
						<cfif url.ReportBBDetail EQ 1></tr></cfif>
						
						<cfset UOM_TOTALCLAIMAMOUNT = 0>
						
						<cfoutput group="BB_Title">
								<cfquery name="getRowCount" dbtype="query">
									SELECT count(*) AS TotalRows
									FROM RunQuery
								</cfquery>
								
								<CFSET TotalRowCount = getRowCount.TotalRows>
								
								<cfif len(trim(TotalRowCount)) EQ 0>
									<CFSET TotalRowCount = 0>
								</cfif>
								<CFSET NextTotalRowCount = TotalRowCount + 1>
								
								<CFIF TotalRowCount GT 0>
									<cfquery name="checkRunQuery" dbtype="query">
										SELECT * 
										FROM RunQuery
										WHERE 
										OPID = '#TheQuery.BSA_Operator_ID#'
			 							AND
										PID = '#toString(TheQuery.BSA_Foodservice_Items_Master_ID)#'
									</cfquery>
								<cfelse>
									<CFSET checkRunQuery.recordcount = 0>
								</CFIF>
								
								<cfif checkRunQuery.recordcount EQ 0>
									<!--- <cfdump var="#RunQuery#"> --->
									<cfset uom_LastBBClaim	 = 0>
									
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1"><cfset uom_BegBal = Round(TheQuery.TotalProductProgramVolume_CS)></cfcase>
										<cfcase value="2"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_LB></cfcase>
										<cfcase value="rm"><cfset uom_BegBal = TheQuery.TotalProductProgramVolume_RM></cfcase>
									</cfswitch>							
									
									
									
									<cfset temp = queryaddrow(RunQuery)>
									<cfset temp = QuerySetCell(RunQuery, "RC", NextTotalRowCount)>
									<cfset temp = QuerySetCell(RunQuery, "OPID", toString(trim(TheQuery.BSA_Operator_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "PID", toString(trim(TheQuery.BSA_Foodservice_Items_Master_ID)))>
									<cfset temp = QuerySetCell(RunQuery, "CURRBAL", uom_BegBal)>
									<!--- <cfdump var="#RunQuery#"> --->
								<cfelse>
									<cfswitch expression="#lcase(url.ReportUOM)#">
										<cfcase value="1">
											<cfset uom_LastBBClaim 	= Round(TheQuery.LastBBClaim_CS)>
											<cfset uom_BegBal		= Round(checkRunQuery.CURRBAL - uom_LastBBClaim)>
										</cfcase>
										
										<cfcase value="2">
											<cfset uom_LastBBClaim 	= TheQuery.LastBBClaim_LB>
											<cfset uom_BegBal		= checkRunQuery.CURRBAL - uom_LastBBClaim>
										</cfcase>
										
										<cfcase value="rm">
											<cfset uom_LastBBClaim 	= TheQuery.LastBBClaim_RM>
											<cfset uom_BegBal		= checkRunQuery.CURRBAL - uom_LastBBClaim>
										</cfcase>
									</cfswitch>							
			

									<cfset temp 			= QuerySetCell(RunQuery, "CURRBAL", uom_BegBal, checkRunQuery.RC)>
								</cfif>
					
								
								<cfswitch expression="#lcase(url.ReportUOM)#">
									<cfcase value="1"><!--- cs --->
										<cfset uom_PTV 							= TheQuery.PTV_CS>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_CS>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_CS>

										<cfset uom_TotalClaimAmount 			= Round(uom_TotalClaimAmount + uom_LastBBClaim)>
										<cfset uom_EndingBalance				= Round(uom_BegBal-uom_LastBBClaim)>
										<cfset uom_ValueAvailable				= Round(uom_PTV*uom_EndingBalance)>
										
										<cfset uom_str = "&nbsp;cs">
									</cfcase>
									<cfcase value="2"><!--- lb --->
										<cfset uom_PTV 							= TheQuery.PTV_LB>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_LB>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_LB>

										<cfset uom_TotalClaimAmount 			= uom_TotalClaimAmount + uom_LastBBClaim>
										<cfset uom_EndingBalance				= uom_BegBal-uom_TotalClaimAmount>
										<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>
										
										<cfset uom_str = "&nbsp;lbs">
									</cfcase>
									<cfcase value="rm"><!--- rm --->
										<cfset uom_PTV 							= TheQuery.PTV_RM>
										<cfset uom_PTV = trim(NumberFormat(uom_PTV, '______.____'))>
										<cfset uom_TotalProductProgramVolume 	= TheQuery.TotalProductProgramVolume_RM>
										<cfset uom_LastBBClaim	 				= TheQuery.LastBBClaim_RM>

										<cfset uom_TotalClaimAmount				= uom_TotalClaimAmount + uom_LastBBClaim>
										<cfset uom_EndingBalance				= uom_BegBal-uom_TotalClaimAmount>
										<cfset uom_ValueAvailable				= uom_PTV*uom_EndingBalance>

										<cfset uom_str = "&nbsp;lbs">
									</cfcase>
								</cfswitch>
<!--- 											<tr>
											<td colspan="100%" ed=1># uom_PTV# * #uom_EndingBalance# = #evaluate(uom_ptv*uom_EndingBalance)#</td>
										</tr>							 --->		

							<cfif url.ReportBBDetail EQ 1>
								<cfset thisCurrentrow = thisCurrentrow + 1>
								<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>WhiteSmoke</CFIF>">
									<td colspan="2" align="right">&nbsp;&nbsp;&nbsp;&nbsp;<a href="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#">#TheQuery.BB_Title# - #TheQuery.BB_Reference#</a></td>
									<Td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</TD>
									
									<td align="right">
									<!--- Beggining Volume --->
									#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#
									</td>
	
									<Td align="right">#trim(NumberFormat(0, '___,___,___,___,___'))#</TD>
									<td align="right">#trim(NumberFormat(uom_BegBal, '___,___,___,___,___'))#</td>
									<td align="right">
										#trim(NumberFormat(uom_LastBBClaim, '___,___,___,___,___'))#						
									</td>
									<td align="right">
										#trim(NumberFormat(uom_TotalClaimAmount, '___,___,___,___,___'))#								
									</td>
									<td align="right">
										#trim(NumberFormat(uom_EndingBalance, '___,___,___,___,___'))#
									</td>
									<td align="right">$#trim(NumberFormat(uom_ValueAvailable, '___,___,___,___,___.__'))#</td> 							
								</tr>
							</cfif>	

							<!--- add to item total --->
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "BEGBAL", uom_BegBal)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "BBCURRENT", uom_LastBBClaim)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "BBCUME", uom_TotalClaimAmount)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "ENDBAL", uom_EndingBalance)>
							<cfset temp = addToTotal(OpMonthItemTotalStructName, "VALUEAVAIL", uom_ValueAvailable)>

						</cfoutput><!--- end bb --->
						
						<cfset thisStrLen1 = len(TheQuery.Operator_Name)>
						<cfset thisStrLen2 = len(TheQuery.Item)>
						<cfset maxStrLen = 40>
						
						<!--- Item Total --->
						<cfif url.ReportBBDetail EQ 0>
								<cfset tempuom_str = uom_str>
								<cfset uom_str = "">
								<td align="right">#trim(numberformat(uom_PTV, '___,___,___.____'))#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">0#uom_str#</b></td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</td>
								<td align="right">#trim(NumberFormat(OpMonthItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</td>
								<td align="right"d>$#trim(NumberFormat(OpMonthItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</td>
							</tr>
							<cfset uom_str = tempuom_str>
						<cfelse>
							<tr bgcolor="##4169e1">	
								<cfset thisStrLen = len(TheQuery.Operator_Name)>
								<cfset maxStrLen = 40>
								<td colspan="3" align="right" title="#TheQuery.Operator_Name# #TheQuery.BB_Date_Month_String# Results" style="color: white;" nowrap><b>#TheQuery.BB_Date_Month_String# #MID(TheQuery.Item, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>0#uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>#trim(NumberFormat(OpMonthItemTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
								<td align="right" style="color: white;"><b>$#trim(NumberFormat(OpMonthItemTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
							</tr>
							<tr>
								<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
							</tr>
						</cfif>
						<cfset temp = addToTotal(OPTotalStructName, "BEGBAL", OpMonthItemTotalStructName.BEGBAL)>
						<cfset temp = addToTotal(OPTotalStructName, "BBCURRENT", OpMonthItemTotalStructName.BBCURRENT)>
						<cfset temp = addToTotal(OPTotalStructName, "BBCUME", OpMonthItemTotalStructName.BBCUME)>
						<cfset temp = addToTotal(OPTotalStructName, "ENDBAL", OpMonthItemTotalStructName.ENDBAL)>
						<cfset temp = addToTotal(OPTotalStructName, "VALUEAVAIL", OpMonthItemTotalStructName.VALUEAVAIL)>
						</cfoutput><!--- end item --->

						<tr bgcolor="##6a5acd">	
							<cfset thisStrLen = len(TheQuery.Operator_Name)>
							<cfset maxStrLen = 40>
							<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="color: white;" nowrap><b>#TheQuery.BB_Date_Month_String# - #MID(TheQuery.Operator_Name, 1, maxStrLen)#<cfif thisStrLen GT maxStrLen>...</cfif> Total:</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>0#uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>#trim(NumberFormat(OPTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
							<td align="right" style="color: white;"><b>$#trim(NumberFormat(OPTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
						</tr>
						<tr>
							<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
						</tr>						
					<!--- <CFDUMP var="#OPMonthTotalStructName#"> --->
					<cfset temp = addToTotal(OPMonthTotalStructName, "BEGBAL", OPTotalStructName.BEGBAL)>
					<cfset temp = addToTotal(OPMonthTotalStructName, "BBCURRENT", OPTotalStructName.BBCURRENT)>
					<cfset temp = addToTotal(OPMonthTotalStructName, "BBCUME", OPTotalStructName.BBCUME)>
					<cfset temp = addToTotal(OPMonthTotalStructName, "ENDBAL", OPTotalStructName.ENDBAL)>
					<cfset temp = addToTotal(OPMonthTotalStructName, "VALUEAVAIL", OPTotalStructName.VALUEAVAIL)>

										
					</cfoutput><!--- end month --->
				<!--- <cfif url.ReportBBDetail EQ 1> --->
				<cfset thisStrLen1 = len(TheQuery.Operator_Name)>
				<cfset thisStrLen2 = len(TheQuery.Item)>
				<cfset maxStrLen = 40>
 				<tr bgcolor="##000080">
					<td colspan="3" align="right" title="#TheQuery.Operator_Name#" style="border-top: 1 solid Black; color: white;" nowrap><b>#MID(TheQuery.Operator_Name, 1, maxStrLen)#<cfif thisStrLen1 GT maxStrLen>...</cfif> Total:</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>0#uom_str#</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>#trim(NumberFormat(OPMonthTotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-top: 1 solid Black; color: white;"><b>$#trim(NumberFormat(OPMonthTotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				
				<cfset temp = addToTotal(TotalStructName, "BEGBAL", OPMonthTotalStructName.BEGBAL)>
				<cfset temp = addToTotal(TotalStructName, "BBCURRENT", OPMonthTotalStructName.BBCURRENT)>
				<cfset temp = addToTotal(TotalStructName, "BBCUME", OPMonthTotalStructName.BBCUME)>
				<cfset temp = addToTotal(TotalStructName, "ENDBAL", OPMonthTotalStructName.ENDBAL)>
				<cfset temp = addToTotal(TotalStructName, "VALUEAVAIL", OPMonthTotalStructName.VALUEAVAIL)>		

				<!--- </cfif> --->
				</cfoutput>

					
				<cfoutput>
				<tr>	
					<td colspan="3" align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>Report Total:</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>0#uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BegBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BBCurrent, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.BBCume, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>#trim(NumberFormat(TotalStructName.EndBal, '___,___,___,___,___'))##uom_str#</b></td>
					<td align="right" style="border-bottom:3px double ##000080; border-top:3px double ##000080;"><b>$#trim(NumberFormat(TotalStructName.ValueAvail, '___,___,___,___,___.__'))#</b></td>
				</tr>
				<tr>
					<td bgcolor="##ffffff" colspan="100%" height="10px">&nbsp;</td>
				</tr>
				</cfoutput>				
								
			</cfcase>
		</cfswitch>
	
		</table>
			<!--- <cfdump var="#variables#"> --->
</cfsavecontent>

<cfoutput>#PRINTER_FRIENDLY_PAGE_BUFFER_1#</cfoutput>

<cfsavecontent variable="PRINTER_FRIENDLY_PAGE_BUFFER_2">

</cfsavecontent>	

		<table align="center">
			<tr bgcolor="#FFFFFF">
				<td align="right" style="cursor: pointer;" onclick="window.location.href = '/settings/usdanoi/search.cfm'"><b><font color="#FF0000">[</font> 
				<font color="#0000FF">change report criteria</font>
				<font color="#FF0000">]</font></b></td>
				<td>&nbsp;</td>
				<td align="right">&nbsp;</td>
				<td>&nbsp;</td>
			</tr>		
		</table>

</cfsavecontent>

<cfoutput>#Page_Content#</cfoutput>

<cffile action="WRITE" file="#APPPATH#\#url.file_printer_friendly#" output="#Printer_Friendly_Page_Buffer_1##Printer_Friendly_Page_Buffer_2#" addnewline="Yes">
