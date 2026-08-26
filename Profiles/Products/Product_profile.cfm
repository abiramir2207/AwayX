<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the URL																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET ID = URL.PID>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all the information for this product														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset stStruct.appSettings = appSettings>
<cfset stStruct.BSA_Foodservice_Items_Master_ID = #ID#>
<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset Get_product_Data = productManager.search(stStruct)>

<CFOUTPUT QUERY="Get_product_Data">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Product Profile</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
</HEAD>
<BODY ONBLUR="self.focus();" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
	<TR>
		<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>#Description#</B></FONT></TD>
	</TR>
	</TABLE>
	<BR>



<TABLE border="0" cellpadding="0" cellspacing="3" WIDTH="350" ALIGN="center">
  <TR>
    <TD colspan="2" nowrap valign="top">
      <DIV class="title2">General</DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.item_label# ##:</B></TD>
    <TD width="100%" valign="top">#Item#</TD>
  </TR>
</cfif>
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
	<cfif application.returned_customer_setting.upc_switch EQ 1>  
		<TR>
			<TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.upc_label#:</B></TD>
			<TD width="100%" valign="top">#UPC#</TD>
		</TR>
	</cfif>
</cfif>
  <TR>
    <TD align="right" nowrap valign="top"><B>Description:</B></TD>
    <TD width="100%" valign="top">#Description#</TD>
  </TR>
  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">Category Alignment</DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Active Code:</B></TD>
    <TD width="100%" valign="top"><CFIF Active_Code EQ "A">Active<CFELSE>Not Active</CFIF> (#Active_Code#)</TD>
  </TR>
  <cfif appSettings.getUseProductGroup3()>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.type_group_label_singular#:</B></TD>
    <TD width="100%" valign="top">#Type_Group_Desc#</TD>
  </TR>
  </cfif>
  <cfif appSettings.getUseProductGroup2()>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.q_brand_label_singular#:</B></TD>
    <TD width="100%" valign="top">#Q_Brand#</TD>
  </TR>
  </cfif>
  <cfif appSettings.getUseProductGroup4()>
  <TR>
    <TD align="right" nowrap valign="top"><B>#application.returned_customer_setting.type_code_label_singular#:</B></TD>
    <TD width="100%" valign="top">#Type_Code_Desc#</TD>
  </TR>
  </cfif>
  <cfif appSettings.getUseProductGroup1()>
  <TR>
    <TD align="right" nowrap valign="top"><B>Brand:</B></TD>
    <TD width="100%" valign="top">#Brand_Name#</TD>
  </TR>
  </cfif>
  <cfif appSettings.getUseProductHierarchy()>
  <cfset productGroupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
  <cfset qGetHierLevelName = productGroupDataManager.getDistinctHierarchyLevel(getMaxLevel=1)>
  <cfif qGetHierLevelName.recordCount>  
  <TR>
    <TD align="right" nowrap valign="top"><B>#qGetHierLevelName.Group_Level_Desc#:</B></TD>
    <TD width="100%" valign="top">#Product_Hierarchy_Name#</TD>
  </TR>
  </cfif>
  </cfif>
  <TR>
    <TD colspan="2" nowrap valign="top">
      <BR>
	  <DIV class="title2">
        Logistics
      </DIV>
      <HR color="Orange" SIZE="1">
    </TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Net Weight:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Net_Weight, ".____")#<CFIF len(trim(Net_Weight)) EQ 0>Not Available</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Gross Weight:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Gross_Weight, ".____")#<CFIF len(trim(Gross_Weight)) EQ 0>Not Available</CFIF></TD>
  </TR>
  <TR>
    <TD align="right" nowrap valign="top"><B>Catch Weight:</B></TD>
    <TD width="100%" valign="top">#Catch_Weight#<CFIF len(trim(Catch_Weight)) EQ 0>Not Available</CFIF></TD>
  </TR>
  <CFIF len(trim(Inven_UoM)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Inventory Units of Measure:</B></TD>
    <TD width="100%" valign="top">#Inven_UoM#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Length)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Length:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Length, ".____")#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Width)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Width:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Width, ".____")#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Height)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Height:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Height, ".____")#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Cases_Layer)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Cases/Layer:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Cases_Layer, ".____")#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Layers_Pallet)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Layers/Pallet:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Layers_Pallet, ".____")#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Cases_Pallet)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Cases/Pallet:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Cases_Pallet, ".____")#</TD>
  </TR>    
  </CFIF>
  <CFIF len(trim(Case_Cube)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Case/Cube:</B></TD>
    <TD width="100%" valign="top">#NumberFormat(Case_Cube, ".____")#</TD>
  </TR>    
  </CFIF>
  <TR>
    <TD align="right" nowrap valign="top" colspan="2"><HR color="Orange" SIZE="1"></TD>
    
  </TR>    
  <CFIF len(trim(Shelf_Life)) NEQ 0>
  <TR>
    <TD align="right" nowrap valign="top"><B>Shelf Life:</B></TD>
    <TD width="100%" valign="top">
    	<cfif IsNumeric(Shelf_Life)> 
    	#NumberFormat(Shelf_Life, "_")# days
    	<cfelse>
    	#Shelf_Life#
    	</cfif>
    </TD>
  </TR>    
  </CFIF>
</TABLE>



</BODY></HTML></CFOUTPUT>




