<!---bid_request_history.cfm--->
<cfoutput>
<cfparam name="form.Program_ID" default="" />
<cfparam name="form.product_list" default="" />
<cfparam name="form.operatorList" default="" />
<cfparam name="form.init" default="0" />

<Cfif isDefined("url.Program_ID")>
	<Cfset form.Program_ID = url.Program_ID>
</CFIF>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////CONTROLLER SECTION///////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif form.init eq 1>

	<cfset BidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
	<cfset qGetHistoryData = BidRequestManager.getHistory(form.product_list, form.operatorList, form.Program_ID) />
	<cfset BidRequestSpec = CreateObject("component", "components.programs.bid_request.BidRequestSpec") />
	
</cfif>

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////END CONTROLLER SECTION///////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<CFSET PAGE_TITLE= "Proposal History">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<style>
		.brdrLft td { border-left:1px solid silver }
		.brdrLftTop td { border-left:1px solid silver; border-top:1px solid silver}
		.brdrLftRght td { border-left:1px solid silver; border-right:1px solid silver}
		.brdrRgt { border-right:1px solid silver }
	</style>
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5" ONLOAD="">

<form action="" name="historyForm" method="post">

<cfif isDefined("qGetHistoryData")>

	<font color="##000080" size="+1"><b>Proposal History</b></font>&nbsp;
	<hr color="##000080">
	<FONT SIZE="2">
		<B><FONT COLOR="FF0000">[</FONT><a href="javascript:window.close();"> close </a><FONT COLOR="FF0000">]</FONT></B>
	</FONT>
	<br><br>
	
	<TABLE border="0" cellspacing="0" cellpadding="3" CLASS="Maintable" WIDTH="800">
		<TR ID="header" BGCOLOR="##FFCE84" class="brdrLftTop">
			<td align="left" ID="header"><b>#application.returned_customer_setting.item_label#</b></td>
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="left" ID="header"><b>#application.returned_customer_setting.upc_label#</b></td></cfif></cfif>
			<td align="left" ID="header"><b>Description</b></td>
			<td align="left" ID="header"><b>Contract Title</b></td>
			<td align="left" ID="header"><b>Start Date</b></td>
			<td align="left" ID="header"><b>End Date</b></td>
			<td align="left" ID="header"><b>Spec</b></td>
			<td align="left" ID="header"><b>Allowance</b></td>
			<td align="left" ID="header"><b>UOM</b></td>
			<td align="left" ID="header"><b>Price Offered</b></td>
			<td align="left" ID="header"><b>Won</b></td>
			<td align="left" ID="header"><b>Won By</b></td>
			<td align="left" ID="header" class="brdrRgt"><b>Won Price</b></td>
			<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
			<td align="left" ID="header"><b>Delivery Type</b></td>
			</cfif>
		</tr>
		<cfif qGetHistoryData.RecordCount>
		
			<cfparam name="tmpOpId" default="0" />
			<cfloop query="qGetHistoryData">
				<cfif tmpOpId neq BSA_Operator_ID>
					<tr BGCOLOR="##E2DAFA" class="brdrLftRght">
						<td align="left" colspan="100%" ID="header"><font color="##666666" size="2"><b>#Operator_Name#</b></font></td>
					</tr>
				</cfif>
				<tr <CFIF CurrentRow mod 2>BGCOLOR="##ccffcc"<CFELSE>BGCOLOR="##FFFFFF"</CFIF> class="brdrLft">
					<td align="left">#Item#</td>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="left">#UPC#</td></cfif></cfif>
					<td align="left">#Description#</td>
					<td align="left">#Contract_Title#</td>
					<td align="left">#DateFormat(Contract_Start_Date, "mm/dd/yyyy")#</td>
					<td align="left">#DateFormat(Contract_End_Date, "mm/dd/yyyy")#</td>
					<td align="left">#BidRequestSpec.getBidRequestSpec(Bid_Request_Spec_ID).Bid_Request_Key#</td>
					<td align="left">#NumberFormat(Allowance , "$_.____")#</td>
					<td align="left">#request.app_general_functions.getUomDesc(UOM,0)#</td>
					<td align="left">#NumberFormat(Price , "$_.____")#</td>
					<td align="left"><cfif Won eq 1>yes<cfelse>no</cfif></td>
					<td align="left"><cfif Won eq 1>-<cfelse><cfif Len(trim(Won_By))>#Won_By#<cfelse>N/A</cfif></cfif>&nbsp;</td>
					<td align="left" class="brdrRgt"><cfif Won eq 1>-<cfelse>#NumberFormat(Won_Price , "$_.____")# per <cfif isNumeric(Won_Uom)>#request.app_general_functions.getUomDesc(Won_Uom,0)#<cfelse>N/A</cfif></cfif>&nbsp;</td>
					<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
					<td align="left">
					<cfif Previous_Won_Delivery_Type EQ 1>FOB<cfelse>DEL</cfif>\
					</td>
					</cfif>
				</tr>
				
				<!---set a temp operator id for grouping--->
				<cfset tmpOpId = BSA_Operator_ID />
				
			</cfloop>
		<cfelse>
			<tr>
				<td align="left" colspan="100%">(No Historical Data)</td>
			</tr>
		</cfif>
	</table>
<br>
<FONT SIZE="2">
	<B><FONT COLOR="FF0000">[</FONT><a href="javascript:window.close();"> close </a><FONT COLOR="FF0000">]</FONT></B>
</FONT>
</cfif>

<INPUT TYPE="Hidden" NAME="Program_ID" VALUE="#form.Program_ID#">
<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#form.Product_List#">
<input type="Hidden" name="operatorList" value="#form.operatorList#" />
<input type="Hidden" name="init" value="#form.init#" />

</form>

<script>
	
<cfoutput>
<cfif isDefined("FormName")>	
document.all.historyForm.Program_ID.value = opener.document.all.#URL.FormName#.Contract_Main_ID.value;
document.all.historyForm.operatorList.value = opener.document.all.#URL.FormName#.operatorList.value;
document.all.historyForm.Product_List.value = opener.document.all.#URL.FormName#.Product_List.value;
</cfif>
</cfoutput>
	if (document.all.historyForm.init.value == 0)
	{
		document.all.historyForm.init.value = 1;
		document.all.historyForm.submit();
	}
	
</script>

</BODY>
</HTML>
</cfoutput>