<!---
	Created by: Brenda Flynn
	Created on: January 18, 2010
	Label for creation: 21919
	Lowest build available: 6.1
	
	This functionality allows users to create a list of "Divested Items". 
	Those items are marked with an asterisk in several  billback screens.
	There is no app setting for this functionality. It will not be displayed unless items are selected as divested.
 --->


<!--- Code plan

1) Initialize all CFC connections
1.5) Update data returned from search
2) Display standard header
3) Display "last updated by"
4) Display link for item search (which link is variable based on app settings)
5) Write logic (AJAX?) to update the items as Divested (BSA_Foodservice_Items_Master.Is_Divested) and record the change
	in the log. 
6) Display list of divested items returned, including "scissors" which will delete a divested item from BSA_Foodservice_Items_Master,
	update the "last updated by" and update the log table Divested_Item_History
7) Pagination?

 --->

<!--- Define variables --->

<cfparam name="form.blnSubmit" default="0">


<!--- 1) Initialize CFCs --->
	<!--- Initialize application settings --->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	
	<!--- Initialize connection CFC - /components/settings/DivestedItems.cfc --->
	<cfset DivestedItems = CreateObject("component", "components.settings.DivestedItems").init() />
	

<!--- END: 1) Initialize CFCs --->

<!--- 1.5) Update data from product search --->
<cfif form.blnSubmit IS 1 AND isDefined("form.Product_List")>
	<cfset vAddDivestedItems = DivestedItems.addDivestedItems(form.Product_List,request.AccessStructure.User_ID) />
</cfif>

<!--- Return list of divested item information --->
<cfset CurrentItemList = DivestedItems.getAllDivestedItemsDetails() />
<cfset LastUpdatedInfo = DivestedItems.getLastUpdatedBy()>

<cfparam name="form.Product_List" default="#valuelist(CurrentItemList.BSA_Foodservice_Items_Master_ID)#">

<!--- END: 1.5) Update data from product search --->


<!--- 2) Display standard header --->

	<CFSET PAGETITLE = "DIVESTED ITEMS">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
	<HTML>
	<HEAD>
		<TITLE><cfoutput>#PAGETITLE#</cfoutput></TITLE>
	</HEAD>
	<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
		<cfinclude template="/helpsystem/help_link.cfm">
		<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
		<SCRIPT SRC="/Script/javascript/prototype/prototype.js"></SCRIPT>
		<!--- <SCRIPT SRC="/Script/javascript/prototype/scriptaculous.js"></SCRIPT> --->

	

<!--- END 2) Display standard header --->

<!--- 3) Display Last Updated By --->

	
	<cfif LastUpdatedInfo.Recordcount GT 0>
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
		<cfoutput>
		<FONT SIZE="2"><B>The settings were last updated on #dateformat(LastUpdatedInfo.Divested_Updated_Date, 'mm/dd/yyyy')#
			 #timeformat(LastUpdatedInfo.Divested_Updated_Date, 'hh:mm:ss TT')# 
			 by #LastUpdatedInfo.Updated_By#</B></FONT>	
		</cfoutput>
	</TD>
	</TD>
	</TR>
	</TABLE>
	<br>
	</cfif>
<!--- END 3) Display Last Updated By --->

<script>
	
	<!--- Show new product search --->
	function showProductSearchWindow() 
	{
		 var sURL = "/Flex/search/ItemSearchFx.cfm?Formname=Manage_Divested_Items&StatusFilterOn=1";			 
		 NewWindow(sURL, "productwindow", 1000, 715, "yes", "yes", true)
		 return false;
	}

	<!--- Display old product search --->
	function showProductSearchWindow_old() 
	{
		 NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=Manage_Divested_Items", "productwindow", 800, 600, "yes", "yes", true)
		 return false;
	}

	<!--- Delete an item --->
	function deleteRecord(ItemMasterID)
	{
		updateDivestedItem(ItemMasterID,'<cfoutput>#request.AccessStructure.User_ID#</cfoutput>',1);
	}

	<!--- AJAX updater --->
		<!--- To delete an item, newDeletedStatus = 1, to restore, newDeletedStatus = 0 --->

	updateDivestedItem = function(ItemID,UserID,newDeletedStatus)
	{
		
		var updateArguments = {Item_ID:ItemID,User_ID:UserID,New_Deleted_Status:newDeletedStatus};
		
		var options = {parameters		:	updateArguments
						,evalscripts	:	true
						,onFailure		:	itemListError
						,onLoading		:	showMiniLoader
						,onComplete		:	hideMiniLoader};
		
		if 	(newDeletedStatus == 1)
		{	
			new Ajax.Updater($(ItemID),'/settings/Divested_items/update_item.cfm', options);
			return false;	
		}
	
		/*
		else if (newDeletedStatus == 0)
		{	alert('Restore item')
			new Ajax.Updater($(ItemID),'update_item.cfm', options);
		}
		*/
	}
	
	itemListError = function(request)
	{
		$('itemList').innerHTML='<b><font size="4" color="red">! Sorry. There was an error.<b></font>  ' + request.responseText;
	}
	
	showMiniLoader = function()
	{
		$('miniLoader').style.display = 'block';
		document.body.style.cursor = 'wait';
	}
	hideMiniLoader = function()
	{
		$('miniLoader').style.display = 'none';
		document.body.style.cursor = 'default';
	}

</script>

<!--- BEGIN FORM --->

<form name="Manage_Divested_Items" method="post">
	
	<!--- Required form fields for item search --->
	<input type="hidden" name="ExistingProductList" 	value="<cfoutput>#valuelist(CurrentItemList.BSA_Foodservice_Items_Master_ID)#</cfoutput>"><!--- TO DO: populate value from database --->
	<INPUT TYPE="hidden" NAME="Contract_Main_ID" 		VALUE="0">
	<INPUT TYPE="hidden" NAME="Sort_By" 				VALUE="BSA_Foodservice_Items_Master.Item">
	<INPUT TYPE="hidden" NAME="Program_ID" 				VALUE="0">
	<INPUT TYPE="hidden" NAME="Product_List" 			VALUE="<cfoutput>#form.Product_List#</cfoutput>">
	<INPUT TYPE="hidden" NAME="Is_Like_Product_Exist" 	VALUE="0">
	<input type="hidden" name="component_id_value" 		value="" />
	<input type="hidden" name="blnSubmit" 			value="1">
	
<!--- 4) Item search -- which one is dependent on the app setting --->

<cfif appSettings.getFlexProductSearch()>
	<CF_smallLink
		title = "Add Products"
		url = "##" 
		parameters = "onClick=""javascript: return showProductSearchWindow();"""
	>
	<cfelse>
	<CF_smallLink
		title = "Add Products"
		url = "##"
		parameters = "onClick=""javascript: return showProductSearchWindow_old();"""
	>
	</cfif>

<!--- END 4) Item search -- which one is dependent on the app setting --->

<!--- 5) Ajax for delete and restore --->


<!--- END 5) Ajax for delete and restore --->

<p></p>

<!--- 6) Display product list --->
<cfif CurrentItemList.Recordcount GT 0>
	
	<table name="DivestedItems" width="800" border="0" cellpadding="2" cellspacing="0" CLASS="MAINTABLE">
		<tr bgcolor="orange">
			<th align="left">Item Number</th>
			<th align="left">Item Description</th>
			<th align="left">Action</th>
		</tr>
		
		<cfoutput query="CurrentItemList">
			
			<tr <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> ID="#CurrentItemList.BSA_Foodservice_Items_Master_ID#">
				<td>#Item#</td>
				<td>#Description#</td>
				<td>
					<img id="deleteImage" style="cursor: pointer;" 
						onclick="deleteRecord('#CurrentItemList.BSA_Foodservice_Items_Master_ID#');" 
						src="/Images/scissor.gif" width="14" height="9" title="Remove Item" border="0">
				</td>
			</tr>
		</cfoutput>
		
	</table>
<!--- CurrentItemList.Recordcount GT 0 --->
</cfif>
<div name="Howdy" id="Howdy"></div>
<!--- END 6) Display product list --->


</form>

</BODY>
