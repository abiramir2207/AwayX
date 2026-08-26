<cfoutput>
<cfif isDefined("sSaveMsg")>
	<cfoutput>		
	<font color="red" style="font-weight:bold;">*** #sSaveMsg# ***</font><br>
	</cfoutput>	
</cfif>


<CF_MessageWindow>

<cfparam name="form.Item_Replacement_Header_Notes" 				default="">
<cfparam name="form.Product_List" 				default="">
<cfparam name="form.Created_By" 				default="">
<cfparam name="form.Updated_By" 				default="">
<cfparam name="form.Deactivated_By" 				default="">
<cfparam name="form.Created_Date" 				default="">
<cfparam name="form.Updated_Date" 				default="">
<cfparam name="form.Deactivated_Date" 				default="">

<cfparam name="form.Is_First_Time" 				default="1">

<cfif len(trim(RID)) GT 0 and RID neq 0>
	<!--- Edit option --->
	<cfif form.Is_First_Time eq 1>
		<cfset qGetProductReplacement = ProductReplacementManager.getProductReplacement(id=RID,bActive=-1) />
		<cfset form.Item_Replacement_Header_Notes = qGetProductReplacement.Item_Replacement_Header_Notes />
		<cfset form.Product_List = ValueList(qGetProductReplacement.BSA_Foodservice_Items_Master_ID) />
		<cfset form.Created_By = qGetProductReplacement.Created_By_User_Name />
		<cfset form.Updated_By = qGetProductReplacement.Updated_By_User_Name />
		<cfset form.Deactivated_By = qGetProductReplacement.Deactivated_By_User_Name />
		<cfset form.Created_Date = qGetProductReplacement.Created_Date />
		<cfset form.Updated_Date = qGetProductReplacement.Updated_Date />
		<cfset form.Deactivated_Date = qGetProductReplacement.Deactivated_Date />
	</cfif>
	
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Product Replacement Information</LEGEND>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup>
		
	<TR>
	<TD ALIGN="right"><B>Product Replacement Notes:</B></TD>
	<TD>
		<span id="error_Notes"></span>
		<INPUT NAME="Item_Replacement_Header_Notes" TYPE="text" VALUE="#form.Item_Replacement_Header_Notes#" SIZE="30" MAXLENGTH="50"></TD>
	</TR>
	
	<TR>
	<Td align="right">
	<B>Search for products:</B>
	</TD>
	<Td>
	<span id="error_ProductList"></span>
	<CF_smallLink 
	title = "search for product" 
	url = "##"
	parameters = "onClick=""showProductSearchWindow();return false;"""
	>
	<font color="red">please search and select 2 products</font>
	<INPUT NAME="ExistingProductList" TYPE="hidden"  value="#form.Product_List#">
	<INPUT NAME="Product_List" TYPE="hidden"  value="#form.Product_List#">
	</TD>
	</tr>
	
	<cfif len(trim(form.Product_List)) GT 0>
	<tr>	
	<td align="right" valign="top"><strong>Selected products:</strong></td>
		<cfquery name="GetProductInfo" datasource="#application.datasource#">
			select description, item, upc 
			FROM bsa_foodservice_items_master
			WHERE bsa_foodservice_items_master_ID IN (#ListQualify(form.Product_List, "'")#)
		</cfquery>
	<td nowrap>
		<cfloop query="GetProductInfo">
		#GetProductInfo.item# - #trim(GetProductInfo.description)#<br>
		</cfloop>
	</td>
	</tr>
	</cfif>
	

	<tr>
	<td>&nbsp;</td>
	</tr>
<cfif len(trim(RID)) GT 0 and RID neq 0>
	<!--- Display created by/on, updated by/on, deactivated by/on ---->
	<cfif form.Created_Date neq "">
	<tr>
		<td align="right"><B>Created:</B></td>
		<td>by #form.Created_By# on #form.Created_Date#</td>
	</tr>
	</cfif>
	<cfif form.Updated_Date neq "">
	<tr>
		<td align="right"><B>Updated:</B></td>
		<td>by #form.Updated_By# on #form.Updated_Date#</td>
	</tr>
	</cfif>
	<cfif form.Deactivated_Date neq "">
	<tr>
		<td align="right"><B>Deactivated:</B></td>
		<td>by #form.Deactivated_By# on #form.Deactivated_Date#</td>
	</tr>
	</cfif>
</cfif>
	
	<tr>
	<td>&nbsp;</td>
	<Td align="left">
	<p>&nbsp; </p>
	
	<cfif ListLen(form.Product_List) eq 2>
		<cfif len(trim(RID)) GT 0 and RID neq 0>
			<CF_smallLink 
			title = "save product replacement changes" 
			url = "##"
			parameters = "onClick=""confirmProductCompletion('edit');return false;"""
			>
		<cfelse>
			<CF_smallLink 
			title = "save product replacement" 
			url = "##"
			parameters = "onClick=""confirmProductCompletion('add');return false;"""
			>
		</cfif>
	<cfelse>
		<br>
		<font color="red">*** You have selected #ListLen(form.Product_List)# product(s) ***</font><br>
		<cfif len(trim(RID)) GT 0 and RID neq 0>
			<CF_smallLink 
			title = "save product replacement changes" 
			url = "##"
			enabled = "0"
			>
		<cfelse>
			<CF_smallLink 
			title = "save product replacement" 
			url = "##"
			enabled = "0"
			>
		</cfif>
	</cfif>

	</TD>
	</tr>

	</table>
</FIELDSET>

<INPUT NAME="Is_First_Time" TYPE="hidden"  value="0">

<INPUT NAME="Created_By" TYPE="hidden"  value="#form.Created_By#">
<INPUT NAME="Updated_By" TYPE="hidden"  value="#form.Updated_By#">
<INPUT NAME="Deactivated_By" TYPE="hidden"  value="#form.Deactivated_By#">

<INPUT NAME="Created_Date" TYPE="hidden"  value="#form.Created_Date#">
<INPUT NAME="Updated_Date" TYPE="hidden"  value="#form.Updated_Date#">
<INPUT NAME="Deactivated_Date" TYPE="hidden"  value="#form.Deactivated_Date#">
</cfoutput>