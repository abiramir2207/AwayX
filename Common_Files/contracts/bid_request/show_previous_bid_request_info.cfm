<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>
</head>

<body>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<cfoutput><FORM ACTION="" METHOD="post" NAME="PrevBidrequestInfo" ID="PrevBidrequestInfo" style="display:inline">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfset getBidRequestProducts = bidRequestProdMan.getBidrequestpreviousinfo(programId=url.CID,prodid=url.prodid)>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<TR>
	<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Previous Bid Info. for #getBidRequestProducts.Item#(#getBidRequestProducts.description#)</B></TD>
</TR>
</TABLE>
<TABLE BORDER="0" width="350" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<tr>
<td ID="header" align="left" width="150"><b>Previous Won By</b></td>
<td align="left"><input type="text" name="previous_won_by" value="#getBidRequestProducts.Previous_Won_By#" size="20"></td>
</tr>
<tr>
<td ID="header" align="left" width="150"><b>Previous Won Price</b></td>
<td align="left"><input type="text" name="previous_won_price" value="#getBidRequestProducts.Previous_Won_Price#" size="10" ONKEYUP="clenseText(this,'0123456789.')" onChange="this.value = formatToDeciamalPlaces(this.value,4);"></td>
</tr>
<tr>
<td ID="header" align="left" width="150"><b>Previous Won Price UOM</b></td>
<td>
<cfif getBidRequestProducts.Previous_Won_Uom EQ "">
	<cfset setDefaultSelected = 1>
<cfelse>
	<cfset setDefaultSelected = 0>
</cfif>
<cf_uom_dropdown
				program_id				=	"#url.CID#"
				company_main_id			=	""
				default_option_on		=	"0"
				default_option_text		=	""
				default_option_value	=	""
				dropdown_name			=	"previous_won_price_uom"
				option_text_abbreviated	=	"1"
				plural_uom_display		=	""
				product_type_id			=	"10"
				program_template_id		=	""
				selected_uom_id			=	"#getBidRequestProducts.Previous_Won_Uom#"
				text_before_tag_close	=	""
				uom_id_exclusion_list	=	""
				uom_id_inclusion_list	=	""
				setDefaultSelected		= 	"#setDefaultSelected#"	
				Disabled				= 	""
				></td>
</tr>
<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
<tr>
<td ID="header" align="left" width="150">
<b>Delivery Type</b>
</td>
<td><select name="previous_won_delivery_type">
<option value="1" <cfif getBidRequestProducts.Previous_Won_Delivery_Type EQ 1>selected</cfif>>FOB</option>
<option value="2" <cfif getBidRequestProducts.Previous_Won_Delivery_Type EQ 2>selected</cfif>>DEL</option>			
</select></td>
</tr>
</cfif>
</table>
<table align="center">
<tr>
<td><CF_button
	button_name		=	"save"
	button_caption	=	"save"
	button_action	=	"verifyData();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	
</td>
</tr>
</table>
</form>
<script>
function verifyData()
{
		opener.document.all.BidrequestComponents.previous_won_by_#Replace(url.prodid,"-","_", "ALL")#.value = document.all.PrevBidrequestInfo.previous_won_by.value;
		opener.document.all.BidrequestComponents.previous_won_price_#Replace(url.prodid,"-","_", "ALL")#.value = document.all.PrevBidrequestInfo.previous_won_price.value;
		opener.document.all.BidrequestComponents.previous_won_price_uom_#Replace(url.prodid,"-","_", "ALL")#.value = document.all.PrevBidrequestInfo.previous_won_price_uom.value;
	<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
		opener.document.all.BidrequestComponents.previous_won_delivery_type_#Replace(url.prodid,"-","_", "ALL")#.value = document.all.PrevBidrequestInfo.previous_won_delivery_type.value;
	</cfif>
		window.close();
}
</script>

</cfoutput>
</body>
</html>
