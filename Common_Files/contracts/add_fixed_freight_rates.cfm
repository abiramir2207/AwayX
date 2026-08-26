
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>Freight Rates</CFOUTPUT></TITLE>
	<style>
	TABLE.Maintable TD 
	{
		border-bottom:solid #93BEE2 1px; font-size : 10px;
	}
	#header 
	{
		font-size: 12px;font-weight:bold;
	}
</style>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/common_files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/billbacks/common/common_js_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<cfparam name="form.CONTRACT_MAIN_ID" default="0">
<cfparam name="form.product_list" default="">
<cfparam name="form.COMPNAMEID_1" default="0">
<cfparam name="url.product_id" default="">
<cfparam name="url.editproduct" default="0">
<cfparam name="form.distributor_list" default="">
<cfparam name="url.formname" default="">
<cfparam name="form.sortby" default="DS">
<cfparam name="form.sortorder" default="asc">
<cfparam name="form.sql_Sort_By" default="bsa_foodservice_customers.name">
<!--- Dev Note: Milan(12617) - Here "1" means distributor and "2" means operator. I am defaulting it to "1" - distributor. 
			This page is called from the fixed price page --->
<cfparam name="form.paidTo" default="1">
<cfparam name="url.paidTo" default="1">

<CFSWITCH expression="#FORM.sortby#">
	<CFCASE value="DS">
		<CFSET form.sql_Sort_By="bsa_foodservice_customers.name #FORM.sortorder#,bsa_foodservice_customers.bsa_foodservice_customers_id #FORM.sortorder#,bsa_foodservice_items_master.item">
	</CFCASE>
	<CFCASE value="IT">
		<CFSET form.sql_Sort_By="bsa_foodservice_items_master.item #FORM.sortorder#,bsa_foodservice_customers.name">
	</CFCASE>	
	<CFCASE value="PR">
		<CFSET form.sql_Sort_By="bsa_foodservice_items_master.description">
	</CFCASE>	
</CFSWITCH>

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">
<cfset checksortby = FORM.sortby>

<CFIF FORM.sortorder EQ "ASC">
	<CFSET Current_Image = ASC_IMG>
<CFELSE>
	<CFSET Current_Image = DESC_IMG>			
</CFIF>

<cfif url.product_id NEQ "">
<cfset form.product_list = url.product_id> 
</cfif>


<script>
function adjustdiscount(prodId,freightprodId,price)
	{
		var FOB = eval(prodId);	
		var freightvalue = eval("document.all." + freightprodId + ".value");
		var FOBValue = price - freightvalue;
		
		FOB.innerText = '$ ' + formatToDeciamalPlaces(FOBValue,4);
		
	}

function selectall(field)
{
for (i = 0; i < field.length; i++)
	field[i].checked = document.all.prodCheck.checked ;
}
//  End -->



function selectalldist(dist_id)
{
var obj = eval("window.prodndistoapplyrate_" + dist_id);
var distchecked = eval("document.all.distCheck_" + dist_id + ".checked");
			if(obj != null){
				if(obj.length)
				{
					for(var x=0; x<obj.length;x++){
						box = getFirstChild(obj[x])
						if(box.disabled == false)
						{
						box.checked = distchecked
						}
						else
						{
							box.disabled = true
						}
					}
				}
				else
				{
					box = getFirstChild(obj)
					box.checked = distchecked
				}
			}
}	



function ApplyRateToSelectedBoxes(field){

var obj1 = window.checkallprodstoapplyrate; 
var obj2 = window.editFreightrate;
var obj3 = window.Deliveredrate;
var obj4 = window.editFOBrate;

if (field.length)
	{
		for (i = 0; i < field.length; i++)
		{
			if (field[i].checked)
			{
				rate = getFirstChild(obj2[i])
				del_prc = getFirstChild(obj3[i])
				fob_prc = getFirstChild(obj4[i])
				if(getFirstChild(obj2[i]).disabled == false)
					{
						rate.value = document.all.freight_rate.value;
						fob_prc.innerText = '$ ' + formatToDeciamalPlaces((del_prc.value - rate.value),4);
					}
			}
		}
	}
	else
	//if (field.checked)
		//{
			{
					rate = getFirstChild(obj2)
					del_prc = getFirstChild(obj3)
					fob_prc = getFirstChild(obj4)
					rate.value = document.all.freight_rate.value;
					fob_prc.innerText = '$ ' + formatToDeciamalPlaces((del_prc.value - rate.value),4);
			}
		//}

}

function SubmitForm()
{
	document.all.FixedFreight.action = "save_fixed_freight_rates.cfm";
	document.all.FixedFreight.submit();
}

var sortBy;
var sort_order;
var orderFileName;
	
	initialise();
	function initialise()
	{		
		sortBy = "<cfoutput>#checksortby#</cfoutput>";
		<CFIF FORM.sortorder EQ "ASC">
			sort_order = 1;
		<CFELSE>
			sort_order = 0;		
		</CFIF>
		orderFileName = "<cfoutput>#Current_Image#</cfoutput>";
	}
function setSortHref(sortVal)
	{

		if(sortBy == sortVal)
		{
			sort_order *= -1;
		}
		else
		{
			sort_order = 1;
			sortBy = sortVal;
		}
		var SORTORDER;
		if(sort_order < 0)
		{
			SORTORDER = "DESC";
			orderFileName = "<cfoutput>#DESC_IMG#</cfoutput>";
		}
		else
		{
			SORTORDER = "ASC";
			orderFileName = "<cfoutput>#ASC_IMG#</cfoutput>";
		}
		document.FixedFreight.sortby.value = sortVal;
		document.FixedFreight.sortOrder.value = SORTORDER;
		var thisCell = getParentObject(event.srcElement,"TD");		
		document.FixedFreight.submit();
	}
</script>

<cfif form.CONTRACT_MAIN_ID NEQ "">
<cfif form.product_list NEQ "" OR form.distributor_list NEQ "">
<cfoutput>
<FORM ACTION="add_fixed_freight_rates.cfm?Formname=#url.formname#&editproduct=#url.editproduct#&product_id=#url.product_id#&paidTo=#form.paidTo#" METHOD="post" NAME="FixedFreight" ID="FixedFreight" style="display:inline">
</cfoutput>
<cfset fixedCompObj = CreateObject("component","components.programs.fixed.fixedComponent") />
<!--- Dev Note 12293 Ben: Because I need the component Id and the value is stored
      like 10_2 I need to get just the component Id
 --->
<cfif structKeyExists(form, 'component_id_value') and form.component_id_value neq "">   
   <cfset component_id_val = Find('_',form.component_id_value) />
   <cfset component_id_val = Left(form.component_id_value,component_id_val-1) />
<cfelse>
   <cfset component_id_val = form.COMPNAMEID_1 />
</cfif>
<cfif structKeyExists(url, "paidTo")>
	<cfset paidToNum = url.paidTo />
<cfelse>
   <cfset paidToNum = form.paidTo />
</cfif>
	 
	<cfset getproducts = fixedCompObj.getproducts(form.CONTRACT_MAIN_ID,form.product_list,FORM.sql_Sort_By,FORM.sortorder,0,component_id_val,paidToNum)>
	<cfquery name="getdistinctcustomers" dbtype="query">
	select distinct bsa_foodservice_customers_id
	from getproducts
	</cfquery>
	<cfset productlist = form.product_list>
	<cfset distributor_list = Valuelist(getdistinctcustomers.bsa_foodservice_customers_id)>

<table cellpadding="0" cellspacing="0" width="700"
align="center">
<tr>
<td style="border-bottom:none">&nbsp;</td>
</tr>
<tr>
<td width="30%" id="header" style="border-bottom:none">
<font color="000080" size="2"><strong>Fixed Freight Rates</strong></font>
</td>
<td width="40%" align="center">
<CF_button
	button_name		=	"save and close"
	button_caption	=	"save and close"
	button_action	=	"SubmitForm();"
	button_type		=	"javascript_link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>	
</td>
<td width="30%" style="border-bottom:none">
<B>Freight Rate:</B> <INPUT TYPE="Text" NAME="freight_rate" SIZE="3" ONKEYUP="clenseText(this, '.0123456789');" onblur="this.value = formatToDeciamalPlaces(this.value,4);" maxsize="4">
<FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyRateToSelectedBoxes(document.FixedFreight.checkprod)" STYLE="cursor: pointer;"><strong>apply rate</strong></A><FONT COLOR="Red"><B> ]</B></FONT>
</td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" CLASS="Maintable" width="700"
align="center">
<tr bgcolor="FFCE84">
<td id="header" align="left" width="14%">
<input name="prodCheck" type="checkbox" onClick="selectall(document.FixedFreight.checkprod)">
<A HREF="##" OnClick="javaScript: setSortHref('DS');"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></A><SPAN ID="SP_SP"<CFIF FORM.sortby NEQ "DS"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN></td>
<td id="header" width="15%"><A HREF="##" OnClick="javaScript: setSortHref('IT');">Item</A><SPAN ID="SP_SP"<CFIF FORM.sortby NEQ "IT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN></td>
<td id="header" align="left" width="30%">Description</td>
<td id="header" width="14%" align="right">Delivered Price/LB</td>
<td id="header" align="left" width="14%">Freight/LB</td>
<td id="header" align="left" width="13%">F.O.B/LB</td>
</tr>
</table>
<cfif form.sortby EQ "DS">
<cfset groupbyorder = 1>
<cfset firstgroupby = "bsa_foodservice_customers_id">
<cfset secondgroupby = "bsa_foodservice_items_master_id">
<cfelse>
<cfset groupbyorder = 2>
<cfset firstgroupby = "bsa_foodservice_items_master_id">
<cfset secondgroupby = "bsa_foodservice_customers_id">
</cfif>

<div ID="Search_Result" name="Search_Result" ALIGN="RIGHT"  style="border: 0px none ##000000;position:relative;height:auto;overflow-y:auto;width:720px;left:38px">
<table border="0" cellpadding="0" cellspacing="0" CLASS="Maintable" width="99%"
align="center">
<cfoutput query="getproducts" group="#firstgroupby#">
<cfif groupbyorder EQ 1>
<cfset recustomer_id = replace(getproducts.bsa_foodservice_customers_id, "-", "_", "ALL")>
<cfset customer_id = getproducts.bsa_foodservice_customers_id>
<cfset shr_shipto = trim(getproducts.Shr_Ship_To)>
	<tr BGCOLOR="FFFACD">
	<td id="header" colspan="6" align="left">
	<input name="distCheck_#shr_shipto#" type="checkbox" onClick="selectalldist('#shr_shipto#')">
	<strong>#getproducts.Shr_Ship_To# : #getproducts.Name#</strong></td>
	</tr>
<cfelse>
<cfset reproduct_id = replace(getproducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
<cfset deliveredprice = 0>
<cfif structKeyExists(form, 'component_id_value') and form.component_id_value neq "">
   <cfset getCompNum = listlast(form.component_id_value,'_') />
   <cfset compIdvalue = Find('_',form.component_id_value) />
   <cfset compIdvalue = Left(form.component_id_value,compIdvalue-1) />
 <cfparam name="form.FIXED_C#compIdvalue#_P#replace(reproduct_id, "-", "_", "ALL")#_#getCompNum#_RATE" default="#getproducts.delivered_price#">
 <cfset deliveredprice = evaluate("form.FIXED_C#compIdvalue#_P#replace(reproduct_id, "-", "_", "ALL")#_#getCompNum#_RATE") />	
<cfoutput>delivered values = #compIdvalue# - #getCompNum#</cfoutput>
<cfelse>
  <cfparam name="form.FIXED_C#form.COMPNAMEID_1#_P#replace(reproduct_id, "-", "_", "ALL")#_1_RATE" default="#getproducts.delivered_price#">
<cfset deliveredprice = evaluate("form.FIXED_C#form.COMPNAMEID_1#_P#replace(reproduct_id, "-", "_", "ALL")#_1_RATE")>
</cfif>

	<tr BGCOLOR="FFFACD">
	<td id="header" colspan="6" align="left">
	<!--- <input name="distCheck_#shr_shipto#" type="checkbox" onClick="selectalldist('#shr_shipto#')"> --->
	<strong>#getproducts.item# : #getproducts.description#</strong></td>
	</tr>
</cfif>
<cfoutput group="#secondgroupby#">
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<cfif groupbyorder EQ 1>
<cfset reproduct_id = replace(getproducts.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
<cfset deliveredprice = 0>
<cfif structKeyExists(form, 'component_id_value') and form.component_id_value neq "">
 <cfset getCompNum2 = listlast(form.component_id_value,'_') />
   <cfset compIdvalue2 = Find('_',form.component_id_value) />
   <cfset compIdvalue2 = Left(form.component_id_value,compIdvalue2-1) />
 <cfparam name="form.FIXED_C#compIdvalue2#_P#replace(reproduct_id, "-", "_", "ALL")#_#getCompNum2#_RATE" default="#getproducts.delivered_price#">
 <cfset deliveredprice = evaluate("form.FIXED_C#compIdvalue2#_P#replace(reproduct_id, "-", "_", "ALL")#_#getCompNum2#_RATE")>	
<cfelse>
  <cfparam name="form.FIXED_C#form.COMPNAMEID_1#_P#replace(reproduct_id, "-", "_", "ALL")#_1_RATE" default="#getproducts.delivered_price#">
<cfset deliveredprice = evaluate("form.FIXED_C#form.COMPNAMEID_1#_P#replace(reproduct_id, "-", "_", "ALL")#_1_RATE")>
</cfif>
<!--- <cfparam name="form.FIXED_C#form.COMPNAMEID_1#_P#replace(reproduct_id, "-", "_", "ALL")#_1_RATE" default="#getproducts.delivered_price#">
<cfset deliveredprice = evaluate("form.FIXED_C#form.COMPNAMEID_1#_P#replace(reproduct_id, "-", "_", "ALL")#_1_RATE")> --->
	<td width="14%">
	<span id="checkallprodstoapplyrate">
	<span ID="prodndistoapplyrate_#shr_shipto#">
	<input id="prodndistoapplyrate_#shr_shipto#" name="checkprod" type="checkbox" value="1">
	</span> 
	</span>
	</td>
	<td width="15%">#item#</td>
	<td align="left" width="30%">#description#</td>
<cfelse>
<cfset recustomer_id = replace(getproducts.bsa_foodservice_customers_id, "-", "_", "ALL")>
<cfset customer_id = getproducts.bsa_foodservice_customers_id>
<cfset shr_shipto = trim(getproducts.Shr_Ship_To)>
	<td width="15%">
	<span id="checkallprodstoapplyrate">
	<span ID="prodndistoapplyrate_#shr_shipto#">
	<input id="prodndistoapplyrate_#shr_shipto#" name="checkprod" type="checkbox" value="1">
	</span> 
	</span>
	</td>
	<td>#shr_ship_to#</td>
	<td align="left">#name#</td>
</cfif>
<cfparam name="form.freight_C#recustomer_id#_P#reproduct_id#" default="#getproducts.Freight_rate#">
<cfparam name="fobvalue" default="0">
<cfif deliveredprice EQ "">
<cfset deliveredprice = 0>
</cfif>
<cfif isdefined("form.delv_prc_#recustomer_id#_#reproduct_id#")>
<cfset deliveredprice = evaluate("form.delv_prc_#recustomer_id#_#reproduct_id#")>
</cfif>
<td width="14%">
$#numberformat(deliveredprice,"_,___,____.____")#</td>
<span ID="Deliveredrate"><input type="hidden" name="delv_prc_#recustomer_id#_#reproduct_id#" value="#deliveredprice#"></span>
<td align="left" width="14%">
<span ID="editFreightrate">
<input type="textbox" name="freight_C#recustomer_id#_P#reproduct_id#" 
<cfif evaluate("form.freight_C#recustomer_id#_P#reproduct_id#") EQ 0>
style="background-color:cccccc;"</cfif><cfif deliveredprice eq "" OR deliveredprice LTE 0>disabled</cfif>
value="#evaluate("form.freight_C#recustomer_id#_P#reproduct_id#")#" size="5" ONKEYUP="clenseText(this,'0123456789.');" onChange="this.value = formatToDeciamalPlaces(this.value,4);adjustdiscount('fixed_C#recustomer_id#_P#reproduct_id#','freight_C#recustomer_id#_P#reproduct_id#',#deliveredprice#);">
</span>
</td>

<cfset fobvalue = deliveredprice - evaluate("form.freight_C#recustomer_id#_P#reproduct_id#")>

<td align="left" width="12%"><span ID="editFOBrate"><span id="fixed_C#recustomer_id#_P#reproduct_id#">$#numberformat(fobvalue,"_,___,____.____")#</span></span></td>
</tr>
</cfoutput>
</cfoutput>
</tbody>
</table>
</div>
<cfoutput>
<input type="hidden" name="product_list" value="#productlist#">
<input type="hidden" name="contract_main_id" value="#form.contract_main_id#">
<input type="hidden" name="distributor_list" value="#distributor_list#">
<cfif structKeyExists(url,"paidTo")>
 <input type="hidden" name="paidTo" value="#url.paidTo#" />
<cfelse>
 <input type="hidden" name="paidTo" value="#form.paidTo#" />
</cfif>

<!--- Dev Note 12293 Ben: Added this check to see if the form field
	  component_id_value exists in the contract_discount_fixed_component.cfm
	  file. This value is set in the freightpopup() function. This was added
	  so that a unique component Id can be passed into the Program_Freight_Rates
	  table.
	  If the form field doesn't exist then we use the existing component_id
	  field which gets a list of values
 --->
<cfif structKeyExists(form, 'component_id_value') and form.component_id_value neq "">
<input type="hidden" name="component_id" value="#component_id_val#" />

<!--- Dev Note 12293 Ben: Added this so that when we go to save_fixed_freight_rates.cfm
      it checks to see if this is a new component being added or an existing one.
 --->
<cfif not fixedCompObj.isNewComponent(form.contract_main_id,component_id_val,form.paidTo)>
<input type="hidden" name="newComponent" value="1" />
<cfelse>
<input type="hidden" name="newComponent" value="0" />
</cfif>
<cfelse>	
<input type="hidden" name="component_id" value="#form.COMPNAMEID_1#">
</cfif>

<input type="hidden" name="editproduct" value="#url.editproduct#">
<input type="hidden" name="parentformname" value="#url.formname#">
<input type="hidden" name="sortby" value="#form.sortby#">
<input type="hidden" name="sortOrder" value="#form.sortOrder#">
</cfoutput>
</form>
<cfelse>
Add products for fixed price before applying freight rates.
</cfif>

</cfif>
</body>
</html>
