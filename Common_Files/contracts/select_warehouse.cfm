<cfparam name="url.Default_Warehouse" default="">
<cfparam name="sort_order" default=" ASC">
<cfparam name="sort_by" default="Warehouse_Name">
<cfparam name="url.CallWHSEChange" default="0">

<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/contracts/freight/program_freight.css">
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

<cfparam name="url.Warehouse_Master_ID" default=""> 
<cfif Sort_Order eq ' ASC'>
	<cfset desc_img ="down_1.gif">
	<cfset Sort_Order = ' DESC'>
<cfelseif Sort_Order eq ' DESC'>
	<cfset desc_img ="up_1.gif">
	<cfset Sort_Order = ' ASC'>
</cfif>

<script language="javascript">
	function getSelectedWHSE()
	{
		for (var i=0; i<document.frmWarehouse.Warehouse_Master_ID.length; i++)  
		{ 
			if (document.frmWarehouse.Warehouse_Master_ID[i].checked)  
			{
				SelectedWarehouse = document.frmWarehouse.Warehouse_Master_ID[i].value;	
				return SelectedWarehouse;
			} 
		}
		return 0; 
	}
	
	function finishedSearching()
	{
		var SelectedWarehouse;
		var WarehouseInfo = '';
		var SelectedDistributor;
		var Selected_Dist;
	
		SelectedDistributor = <cfoutput>'#url.BSA_Foodservice_Customers_ID#'</cfoutput>
		DefaultWarehouse    = <cfoutput>'#url.Default_Warehouse#'</cfoutput>
        CallWHSEChange      = <cfoutput>'#url.CallWHSEChange#'</cfoutput>
        
        /* Get the selected warehouse details and pass this info to the opener page for display purpose */	
		SelectedWarehouse = getSelectedWHSE();
		if(SelectedWarehouse != 0) {	
            WarehouseInfo = '(' + document.getElementById("whse_Code_"+SelectedWarehouse).innerHTML + ')'
                            + document.getElementById("whse_Name_"+SelectedWarehouse).innerHTML + "&nbsp;&nbsp;";

			if(SelectedWarehouse != DefaultWarehouse && CallWHSEChange == 0) {
			    WarehouseInfo = WarehouseInfo + "<span class='overriddenShow'>*</span>";
			}
			
            WarehouseInfo = WarehouseInfo + "<br>"
		                                  + document.getElementById("whse_Address_"+SelectedWarehouse).innerHTML
		                                  + document.getElementById("whse_City_"+SelectedWarehouse).innerHTML  +","
		                                  + document.getElementById("whse_State_"+SelectedWarehouse).innerHTML + " "
		                                  + document.getElementById("whse_Zip_"+SelectedWarehouse).innerHTML;
		
            opener.document.getElementById("Warehouse_details_"+SelectedDistributor).innerHTML  = WarehouseInfo;
            
			// Change the warehouse on the opener page 
            opener.document.getElementById("SelectedWarehouse_"+SelectedDistributor).value = SelectedWarehouse;
            
			<cfif isDefined("url.callWHSEChange") and url.callWHSEChange EQ 1>
			    opener.warehouseChanged(SelectedDistributor);
			</cfif>
			window.close();
		}
		return false;
	}
	
	function doSort(sortBy)
	{
		<cfoutput>
		SelectedWarehouse = getSelectedWHSE();
		var sURL = "select_warehouse.cfm?sort_by=" + sortBy + "&sort_order=#Sort_Order#&BSA_Foodservice_Customers_ID=#URL.BSA_Foodservice_Customers_ID#&Default_Warehouse=#Default_Warehouse#&callWHSEChange=#url.callWHSEChange#&Warehouse_Master_ID=" + SelectedWarehouse;
		window.location.href = sURL;
		</cfoutput>
		return false;
	}
</script>



<cfset distributorManager = CreateObject("component", "components.customer.DistributorManager")>
<cfset qryWarehouselist = distributorManager.getWarehouses(sort_by,sort_Order)>

<form name="frmWarehouse">
<table class="Maintable" width="700" cellpadding="3" cellspacing="0" border="0">
	<!--- TABLE HEADERS --->
	<cfoutput>
	<tr id="header" bgcolor="##ffce84">
		<td id="header" valign="middle" width="2%">&nbsp;</td>
		<td id="header" valign="middle"><B>&nbsp;<a HREF="##" onClick="return doSort('WareHouse_Code');">Code</a></B>&nbsp;<cfif sort_by eq 'WareHouse_Code'><img src="/images/#desc_img#" border="0"></cfif></td>
		<td id="header" valign="middle"><B>&nbsp;<a HREF="##" onClick="return doSort('WareHouse_Name');" OnClick="javaScript: SortHeaders('WareHouse_Name','ASC');">Name</B>&nbsp;<cfif sort_by eq 'WareHouse_Name'><img src="/images/#desc_img#" border="0"></cfif></td>
		<td id="header" valign="middle"><B>&nbsp;Address</B></td>
		<td id="header" valign="middle"><B>&nbsp;<a HREF="##" onClick="return doSort('WareHouse_City');">City</B>&nbsp;<cfif sort_by eq 'WareHouse_City'><img src="/images/#desc_img#" border="0"></cfif></td>
		<td id="header" valign="middle"><B>&nbsp;<a HREF="##" onClick="return doSort('WareHouse_State');" OnClick="javaScript: SortHeaders('WareHouse_State','ASC');">State</B>&nbsp;<cfif sort_by eq 'WareHouse_State'><img src="/images/#desc_img#" border="0"></cfif></td>
		<td id="header" valign="middle"><B>&nbsp;<a HREF="##" onClick="return doSort('WareHouse_Zip');">Zip</B>&nbsp;<cfif sort_by eq 'WareHouse_Zip'><img src="/images/#desc_img#" border="0"></cfif></td>
		<td id="header" valign="middle"><B>&nbsp;Country</B></td>
	</tr>
	</cfoutput>
	<cfoutput query="qryWarehouselist">
	<tr>
		<td><input type="radio" name="Warehouse_Master_ID" value="#Warehouse_Master_ID#" onclick="if(this.checked){finishedSearching();}" <cfif Warehouse_Master_ID eq url.Warehouse_Master_ID>checked</cfif>></td>
		<td id ="whse_Code_#Warehouse_Master_ID#">&nbsp;#Warehouse_Code#</td>
		<td id ="whse_Name_#Warehouse_Master_ID#">&nbsp;#Warehouse_Name#</td>
		<td id ="whse_Address_#Warehouse_Master_ID#">&nbsp;#Warehouse_Address_1#<br />#Warehouse_Address_2#</td>
		<td id ="whse_City_#Warehouse_Master_ID#">&nbsp;#Warehouse_City#</td>
		<td id ="whse_State_#Warehouse_Master_ID#">&nbsp;#Warehouse_State#</td>
		<td id ="whse_Zip_#Warehouse_Master_ID#">&nbsp;#Warehouse_Zip#</td>
		<td id ="whse_Country_Code_#Warehouse_Master_ID#">&nbsp;#Warehouse_Country_Code#</td>
	</tr>
	</cfoutput>
</table>
</form>

<cfif qryWarehouselist.recordcount GT 0>
    <cfset request.custom_rfp_process = application.util.query.get_Setting('Custom_RFP_Process',0)>
    <cfset request.warehouse_label    = request.custom_rfp_process ? "default facility" : "warehouse">

    <cfoutput>
        <div style="text-align: center;">
            <a HREF="##" onClick="javascript: return finishedSearching()"> #application.util.string.linkFormat("import selected #request.warehouse_label#")# </a>
        </div>
    </cfoutput>
</cfif>

