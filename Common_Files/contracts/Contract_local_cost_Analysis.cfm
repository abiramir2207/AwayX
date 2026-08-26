<cfparam name="URL.CPID" 	default=0>
<cfparam name="url.ItemId" default=0>
<cfparam name="url.type" default="L">
<cfparam name="url.desc" default="">


<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET URL.CID = cryp.value>

<CFSET CID=URL.CID>
<CFSET ItemId = #replace(url.ItemId, "-", "_", "ALL")#>
<CFSET type = url.type>

<CFIF type EQ "L">
<CFSET PAGE_TITLE="Local Costs Calculation">
</CFIF>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		#header {font-size: 12px;}
	</style>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

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

<CFIF (URL.ItemID EQ 0 OR URL.CID EQ 0) OR NOT isNumeric(URL.CID)>
	<BLOCKQUOTE>
	<BR><BR><BR><SPAN CLASS="TITLE2">Invalid Contract/Product information</SPAN>
	</BLOCKQUOTE>
	<CFABORT>
</CFIF>

<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
	SELECT Contract_Number, Contract_Start_Date, Contract_End_Date,
	ProgramType_ID
	FROM Contract_Main WHERE Contract_Main_ID = <CFOUTPUT>#CID#</CFOUTPUT>
</CFQUERY>


<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM 
		Program_Control_Panel_Options
	WHERE 
		ProgramControl_Panel_Options_ID = '#trim(Program_Details.ProgramType_ID)#'
</cfquery>

<CFQUERY NAME="getitemdetails" datasource="#application.datasource#">
select BSA_Foodservice_Items_Master.item,BSA_Foodservice_Items_Master.description
from BSA_Foodservice_Items_Master
where BSA_Foodservice_Items_Master_id = '#replace(ItemId, "_", "-", "ALL")#'
</CFQUERY>

<!------<CFOUTPUT>#FinalTPASum#</CFOUTPUT>----->

<BR><BR>
<SPAN CLASS="TITLE2"><cfoutput>#PAGE_TITLE#</cfoutput></SPAN>
<HR COLOR="Orange">
<CFOUTPUT QUERY="Program_Details">
  <TABLE border="0" WIDTH="366">
    <TR> 
      <TD width="10" ALIGN="Left" STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;</TD>
      <TD width="346" ALIGN="Left" STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Program:</B>&nbsp;&nbsp;[#Contract_Number#]</TD>
    </TR>
    <TR> 
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left">&nbsp;</TD>
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left"><B>Start 
        Date:</B>&nbsp;&nbsp;#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#</TD>
    </TR>
    <TR> 
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left">&nbsp;</TD>
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left"><B>End 
        Date:</B>&nbsp;&nbsp;#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
    </TR>
  </TABLE></CFOUTPUT>
<HR COLOR="Orange">

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<cfoutput><TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD colspan="2" STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#getitemdetails.item# -  #getitemdetails.description#</B></TD>

</TR></cfoutput>
</table>

<cfset useLakebaseForgetlocalcostsvariables = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cost_sequence")>
<cfif useLakebaseForgetlocalcostsvariables>
	<cftry>
		<cfset getlocalcostsvariables = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cost_sequence", {
				"deleted" = "eq.0",
				"order" = "cost_sequence_order.asc",
				"select" = "cost_sequence_name"
			}), "cost_sequence_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetlocalcostsvariables = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetlocalcostsvariables>
<CFQUERY NAME="getlocalcostsvariables" datasource="#application.datasource#">
select Cost_Sequence_name from Cost_Sequence where deleted = 0
order by Cost_Sequence_Order
</CFQUERY>
</cfif>
<cfset i= 1>
<CFQUERY NAME="getlocalcosts" datasource="#application.datasource#">
select 
<cfloop query="getlocalcostsvariables">
cost#i#_rate,cost#i#_uom,
case when cost#i#_uom = 1 then
'CS'
when cost#i#_uom =  2 then
'LB'
else
'%'
end as cost#i#_uom_label,
<cfset i = i+1>
</cfloop>
<cfif getSettings.approval_uom EQ 1>isnull(base_sales_cs,0) as base_price,cash_discount_cs as cash_discount</cfif>
<cfif getSettings.approval_uom EQ 2>isnull(base_sales_lb,0) as base_price,cash_discount_lb as cash_discount</cfif>,net_weight from
group_local_costs 
inner join contract_product_margin
on contract_product_margin.group_id = group_local_costs.group_id
where contract_main_id = #CID#
and product_id =  '#replace(ItemId, "_", "-", "ALL")#'
</CFQUERY>

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<TR VALIGN="bottom" bgcolor="Orange">
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>CostVariable</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Rate</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>UOM</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Calculated Price</B></TD>
</TR>
<cfset index=1>
<cfset cal_base_price =  #val(getlocalcosts.base_price)#>
<cfset new_base_price =  #val(getlocalcosts.base_price)#>
<cfoutput><cfloop query="getlocalcostsvariables">
<TR VALIGN="bottom">
	<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#getlocalcostsvariables.Cost_Sequence_name# </B></TD>
	<cfif (getlocalcosts.RecordCount EQ 0)>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;" align="center"><B>0.00</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;" align="center"><B>0</B></TD>
		<cfset cost = 0.00 />
	<cfelse>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;" align="center"><B>#trim(numberformat((evaluate("getlocalcosts.cost#index#_rate")),'_-___,___,___,___,___.__'))#</B></TD>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;" align="center"><B>#(evaluate("getlocalcosts.cost#index#_uom_label"))#</B></TD>
		<cfif getSettings.approval_uom EQ 1>
			<cfif evaluate(("getlocalcosts.cost#index#_uom")) EQ 1>
				<cfset cost = evaluate(("getlocalcosts.cost#index#_rate"))>
			<cfelseif evaluate(("getlocalcosts.cost#index#_uom")) EQ 2>
				<cfset cost = evaluate(("getlocalcosts.cost#index#_rate")) * getlocalcosts.net_weight>
			<cfelse>
				<cfset cost = (evaluate(("getlocalcosts.cost#index#_rate")) * cal_base_price)/100>
			</cfif>
		<cfelse>
			<cfif evaluate(("getlocalcosts.cost#index#_uom")) EQ 1>
				<cfset cost = evaluate(("getlocalcosts.cost#index#_rate")) / getlocalcosts.net_weight>
			<cfelseif evaluate(("getlocalcosts.cost#index#_uom")) EQ 2>
				<cfset cost = evaluate(("getlocalcosts.cost#index#_rate"))>
			<cfelse>
				<cfset cost = (evaluate(("getlocalcosts.cost#index#_rate")) * cal_base_price)/100>
			</cfif>
		</cfif>
	</cfif>
	
<cfset cal_base_price = cal_base_price - cost>
		<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#trim(numberformat(new_base_price,'_-___,___,___,___,___.___'))# - #trim(numberformat(cost,'_-___,___,___,___,___.___'))# = #trim(numberformat(cal_base_price,'_-___,___,___,___,___.___'))#</B></TD>
		</TR>
<cfset new_base_price = #new_base_price# - cost>
<cfset index= index+1>
</cfloop></cfoutput>
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
	<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Local Costs:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<B><cfoutput>$#trim(numberformat(getlocalcosts.cash_discount,'_-___,___,___,___,___.___'))#</cfoutput></B></TD>
	</TR>
	<tr>
	<td>&nbsp;</td>
	</tr>
</TABLE>
<br>
<!--- Dev Note: Clay 9980 Close Window --->
<HR color="Orange">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<TR>
	<TD><div align="center"><B><font color="FF0000">[</font> <a onclick="javascript:closeWindow()" STYLE="cursor: pointer;">Close Window</a> <font color="FF0000">]</font></B></div></TD>
	</TR>
</TABLE>

<script type="text/javascript" language="JavaScript">
	function closeWindow()
	{
		window.close();
		if(!top.opener.closed)
		{		
			top.opener.focus();
		}
		return true;	
		}
</script>