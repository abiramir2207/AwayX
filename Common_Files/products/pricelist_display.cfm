<CFPARAM NAME="URL.UPC" DEFAULT="">
<CFPARAM NAME="FORM.BSA_Foodservice_Items_Master_ID" DEFAULT="#URL.UPC#">

<cfset useLakebaseForgetProduct_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForgetProduct_Info>
	<cftry>
		<cfset getProduct_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#FORM.BSA_Foodservice_Items_Master_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProduct_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProduct_Info>
<CFQUERY NAME="getProduct_Info" datasource="#application.datasource#">
	SELECT *
	FROM BSA_Foodservice_Items_Master
	WHERE BSA_Foodservice_Items_Master_ID = '#FORM.BSA_Foodservice_Items_Master_ID#'
</CFQUERY>
</cfif>

<CFQUERY NAME="get_Product_Price_Lists" datasource="#application.datasource#">
	<cfinclude template="#Application.Doc_mapping#/data_files/created/#application.returned_customer_setting.qry_product_price_list_detail#">
</CFQUERY>

<!------ 
<CFQUERY NAME="get_Product_Price_Lists" datasource="#application.datasource#">
	<cfinclude template="#application.returned_customer_setting.qry_product_price_list_detail#">
</CFQUERY> 
----->

<cfif application.returned_customer_setting.show_product_price_list_detail_special EQ 1>
	<CFQUERY NAME="get_Product_Price_Lists_Special" datasource="#application.datasource#">
		<cfinclude template="#Application.Doc_mapping#/data_files/created/#application.returned_customer_setting.qry_product_price_list_detail_special#">
	</CFQUERY>
</cfif>

<cfset ListOfPriceList = "get_Product_Price_Lists">
<cfif application.returned_customer_setting.show_product_price_list_detail_special EQ 1>
	<cfset ListOfPriceList = "get_Product_Price_Lists,get_Product_Price_Lists_Special">
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET PAGE_TITLE="Price List Detail">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>
<BODY LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0">
<HR COLOR="Orange">
<DIV ALIGN="center" STYLE="color: Navy; font-size: 15px; font-weight: bold;"><CFOUTPUT>#getProduct_Info.Description# <CFIF getProduct_Info.UPC NEQ "">- #getProduct_Info.UPC#</CFIF></CFOUTPUT>- Price List</DIV>
<HR COLOR="Orange">
<TABLE CLASS="Maintable" WIDTH="400" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border=0>
	<cfset loopCounter = 1>
	<cfloop index="x" list="#ListOfPriceList#">
		<cfif loopCounter EQ 2>
		</TABLE>

		<BR><HR COLOR="Orange"><div align="center" STYLE="color: Navy; font-size: 15px; font-weight: bold;">Special Price List</div><HR COLOR="Orange"><BR>

		<TABLE CLASS="Maintable" WIDTH="400" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border=0>
		</cfif>
		
		<TR BGCOLOR="#FFCE84" VALIGN="bottom">
			<TD ID="header" NOWRAP><B>PL#/Description</B></TD>
			<TD ID="header" ALIGN="center" NOWRAP><B>FOB</B></TD>
			<!---
			<TD ID="header" ALIGN="center" NOWRAP><B>Bracket 1</B></TD>
			<TD ID="header" ALIGN="center" NOWRAP><B>Bracket 2</B></TD>
			<TD ID="header" ALIGN="center" NOWRAP><B>Bracket 3</B></TD>
			<TD ID="header" ALIGN="center" NOWRAP><B>Bracket 4</B></TD>
			<TD ID="header" ALIGN="center" NOWRAP><B>Bracket 5</B></TD>
			--->
		</TR>
		<cfset get_Product_Price_Lists = Duplicate(evaluate("#x#"))>
		<CFSET FOBOffValue = "<font color=""gray"" title=""n/a""><B>0.00</B></font>">
		<CFOUTPUT QUERY="get_Product_Price_Lists">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD STYLE="border-bottom: 0px;" NOWRAP>#get_Product_Price_Lists.List_Id#</TD>
				<TD STYLE="border-bottom: 0px;" ALIGN="center" NOWRAP><CFIF trim(get_Product_Price_Lists.LB_FOB_Price) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.LB_FOB_Price, '________________.__'))#</CFIF></TD>
				<!---
				<TD STYLE="border-bottom: 0px;" ALIGN="center" NOWRAP><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.LB_Bracket_1) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.LB_Bracket_1, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD STYLE="border-bottom: 0px;" ALIGN="center" NOWRAP><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.LB_Bracket_2) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.LB_Bracket_2, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD STYLE="border-bottom: 0px;" ALIGN="center" NOWRAP><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.LB_Bracket_3) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.LB_Bracket_3, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD STYLE="border-bottom: 0px;" ALIGN="center" NOWRAP><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.LB_Bracket_4) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.LB_Bracket_4, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD STYLE="border-bottom: 0px;" ALIGN="center" NOWRAP><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.LB_Bracket_5) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.LB_Bracket_5, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				--->
			</TR>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
				<TD nowrap>#get_Product_Price_Lists.Price_List_Desc#&nbsp;</TD>
				<TD ALIGN="center"><CFIF trim(get_Product_Price_Lists.CS_FOB_Price) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.CS_FOB_Price, '________________.__'))#</CFIF></TD>
				<!---
				<TD ALIGN="center"><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.CS_Bracket_1) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.CS_Bracket_1, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD ALIGN="center"><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.CS_Bracket_2) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.CS_Bracket_2, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD ALIGN="center"><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.CS_Bracket_3) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.CS_Bracket_3, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD ALIGN="center"><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.CS_Bracket_4) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.CS_Bracket_4, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				<TD ALIGN="center"><cfif application.returned_customer_setting.show_delivered EQ 1><CFIF trim(get_Product_Price_Lists.CS_Bracket_5) EQ 0>N/A<CFELSE>$#trim(numberformat(get_Product_Price_Lists.CS_Bracket_5, '________________.__'))#</CFIF><CFELSE>#FOBOffValue#</CFIF></TD>
				--->
			</TR>
		</CFOUTPUT>
		<CFIF get_Product_Price_Lists.recordcount EQ 0>
			<TR>
				<TD COLSPAN="100%"><BR><DIV ALIGN="center" STYLE="color: Navy; font-size: 20px;"><B>No Price List Data Is Available For This Product</B></DIV><BR><BR></TD>
			</TR>
		</CFIF>
	<cfset loopCounter = loopCounter + 1>
	</CFLOOP>

	
</table>
</BODY>
</HTML>
