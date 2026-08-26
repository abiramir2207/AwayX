<CFSET PAGE_TITLE="Create New Contract - 6 of 6">
<CFSET GROUP="Contracts">
<CFPARAM name="URL.CID" default="">

<CFIF len(trim(URL.CID)) GT 0 AND URL.RO EQ 1>
	<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
	
	<CFSET FORM.Contract_Main_ID = cryp.value>
</CFIF>


<CFPARAM NAME="FORM.Contract_Main_ID" DEFAULT="">

<CFQUERY NAME="GETUOM" datasource="#application.datasource#">
	SELECT *
	FROM Units_of_Measure
</CFQUERY>


<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Contract_Main
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>



<CFQUERY NAME="GetAllContractsProducts" datasource="#application.datasource#">
	SELECT * 
	FROM Contract_Products
	WHERE Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>


<!--- <cfquery name="GetContractBrokers" datasource="#application.datasource#">
	SELECT *
	FROM BSA_Foodservice_Brokers
	WHERE BSA_Foodservice_Brokers_ID IN(#GetAllContractInfo.Broker_IDs#)
</cfquery>
 --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
SELECT dbo.BSA_Foodservice_Items_Master.*, 
    dbo.Contract_Products.Discount_Value, 
    dbo.Contract_Products.Pricing_Rule, 	
    dbo.Contract_Products.Contract_Main_ID
FROM dbo.Contract_Products INNER JOIN
    dbo.BSA_Foodservice_Items_Master ON 
    dbo.Contract_Products.Product_UPC = dbo.BSA_Foodservice_Items_Master.UPC
WHERE (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
</CFQUERY>

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>

 
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">


</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>

<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "ra"> 

<CFINCLUDE TEMPLATE="contract_status_legend.cfm">



<BLOCKQUOTE><BLOCKQUOTE>
<CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID>
<CFSET HideProductList = 1>

<CFSET helpfilenumber=7>
<cfinclude template="minimal_contract_info.cfm">
 
 
<SCRIPT SRC="/common_files/scripts/numberValidation.js"></SCRIPT>
<SCRIPT>
	function ApplyAmountToSelectedBoxes() {
		for(var x = 0; x<document.all.MyForm.elements.length; x++) {
			if(document.all.MyForm.elements[x].type == "checkbox")	{
				if(document.all.MyForm.elements[x].name.indexOf("UPC_") == 0) {
					if(document.all.MyForm.elements[x].checked) {
						eval("document.all." + document.all.MyForm.elements[x].name + "_rebate.value=" + "'" + document.all.Discount_Amount.value + "'")
					}
				}
			}
		}
	}

</SCRIPT>


<BR><BR>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">To apply the same rate to more than one product:</LEGEND>
	<FONT SIZE="2">
	<OL>
		<LI>Enter here the rate that you would like to apply: <INPUT TYPE="Text" NAME="Discount_Amount" SIZE="3" ONKEYUP="nextBox(this, 'NONE')"></LI>
		<LI>In the table below, select the products that you would like this amount to be applied to</LI>
		<LI>Click <FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;">apply</A><FONT COLOR="Red"><B> ]</B></FONT> to make the rates of the selected products match what you entered above.</LI>
		<LI>Can repeat this process as many times as you need by simply selecting or un-selecting the products in question.</LI>
	</OL>
	</FONT>
</FIELDSET>

<SCRIPT>

		function CA() {
			if(0==0) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}

</SCRIPT>	



<FORM ACTION="contract_products_rebate_entry_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<TABLE border="0" cellspacing="0" cellpadding="3" CLASS="Maintable" WIDTH="800">
	<TR ID="header" BGCOLOR="#ffce84">
		<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products"></TD>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD align="left">UPC Code</TD></cfif></cfif>
		<TD align="left">Item #</TD>
		<TD align="left">Description</TD>
		<!--- <TD align="center">QBrand</TD> --->
		<TD align="left">Type Code Description</TD>
		<!--- <TD align="center">Type Group Description</TD> --->
		<TD align="left">Brand</TD>
		<TD><!--- <INPUT TYPE="Text" NAME="Discount_Amount" SIZE="3"> ---><!--- <A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;"><!--- <IMG SRC="/images/all_selected.gif" BORDER="0" ALT="Click here to fill all selected boxes with this value..."> --->apply</A><BR> ---><CFIF GetAllContractInfo.Discount_Type_ID EQ 1>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fixed <CFOUTPUT>#Application.RebateLabel#</CFOUTPUT><CFELSE>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Net Price</CFIF></TD>
		<TD>Per</TD>
	</TR>
<CFOUTPUT QUERY="TheQuery">
	<cf_cryp type="en" string="#trim(TheQuery.UPC)#" key="#request.key#">
	<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> ONMOUSEOVER="menuID=6;URLstring='';an_ID='#cryp.value#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
		<TD align="center"><INPUT TYPE="hidden" NAME="UPC_#currentrow#_value" VALUE="#trim(TheQuery.UPC)#"><INPUT type="Checkbox" NAME="UPC_#currentrow#" VALUE="#trim(TheQuery.UPC)#"><INPUT TYPE="hidden" NAME="DELETE_#currentrow#" VALUE="#trim(TheQuery.UPC)#"></TD>
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD NOWRAP>#TheQuery.UPC#</TD></cfif></cfif>
		<TD NOWRAP>#TheQuery.ITEM#</TD>
		<TD>#TheQuery.Description#</TD>
		<!--- <TD>#TheQuery.Q_Brand_Desc#</TD> --->
		<TD>#TheQuery.Type_Code_Desc#</TD>
		<!--- <TD NOWRAP>#TheQuery.Type_Group_Desc#</TD> --->
		<TD NOWRAP>#TheQuery.Brand#</TD>
		<TD ALIGN="center">$<INPUT TYPE="text" NAME="UPC_#currentrow#_rebate" SIZE="5" VALUE="<CFIF len(TheQuery.Discount_Value) EQ 0>#trim(numberformat(0, '__.___'))#<CFELSE>#trim(numberformat(TheQuery.Discount_Value, '__.___'))#</CFIF>" ONKEYUP="nextBox(this, 'NONE')"></TD>
		<!--- <TD ALIGN="center">$<INPUT TYPE="text" NAME="UPC_#currentrow#_rebate" SIZE="5" VALUE="<CFIF len(TheQuery.Discount_Value) LTE 0>#trim(numberformat(GetAllContractInfo.fixed_rebate_amount, '__.___'))#<CFELSE>#trim(numberformat(TheQuery.Discount_Value, '__.___'))#</CFIF>"></TD> --->
		<TD><SELECT NAME="UPC_#currentrow#_Pricing_Rule">
				<CFSET temp = TheQuery.Pricing_Rule>
				<CFLOOP QUERY="GETUOM">
					<OPTION VALUE="#GETUOM.Unit_Of_Measure_ID#"<CFIF len(temp) EQ 0><CFSET temp = GetAllContractInfo.Contract_Quantity_UOM_IDX></CFIF>#IIF(GETUOM.Unit_Of_Measure_ID EQ temp, DE(" SELECTED"), DE(""))#>#left(GETUOM.Unit_of_Measure_Desc, (len(GETUOM.Unit_of_Measure_Desc)-1))#</OPTION>
				</CFLOOP>					
			</SELECT>
		</TD>
		</TR>
</CFOUTPUT>
<TR><TD COLSPAN="100%" ALIGN="center"></TD></TR>
</TABLE>

<BR>


<CF_button
	button_name		=	""
	button_caption	=	"save"
	button_action	=	"javascript: MyForm.submit();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	



<INPUT TYPE="hidden" NAME="ProductCount" VALUE="<CFOUTPUT>#TheQuery.Recordcount#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">
</FORM>
</BLOCKQUOTE></BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<SCRIPT SRC="/common_files/scripts/formInputLocationEmphasizer.js"></SCRIPT>
<script>
	//load the name of the select boxes to hide
	findselectboxes()	
	<!--- <cfinclude template="/common_files/scripts/formInputLocationEmphasizer.js"> --->
</script>

</BODY>
</HTML>



