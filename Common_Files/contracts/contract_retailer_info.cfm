<cfparam name="URL.CID" default="" />
<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
<CFSET URL.program_Id = cryp.value>

<div align="right">
		<span style="font-weight:bold;color:red"> [ </span> <a href="void(0)" OnClick="javascript:window.close();">close window</a>  <span style="font-weight:bold;color:red"> ] </span>
</div>

	<!--- Does the program have groups? (The programs will be set up is such a way 
	that we will either have products or groups) --->
	<cfquery name="getIsGroups" datasource="#application.datasource#"> 
	 SELECT Count(*) As Is_Group
	 FROM Contract_Products
	 WHERE Contract_Main_ID = '#URL.program_Id#' 
	 AND Is_Group = 1
	 AND Deleted = 0 
	</cfquery>

	<cfset IsGroup = getIsGroups.Is_Group>

	<!--- Get the retail data --->
	<cfstoredproc procedure="Contract_Retail_Merchant_products" datasource="#application.datasource#">
  
	  <cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@Program_ID" null="no"  value="#URL.program_Id#">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@IsGroup" null="no"  value="#IsGroup#">
		<cfprocresult name="retail_info">

	</cfstoredproc>

<!--- Get the program info --->
	<cfquery name="getProgramData" datasource="#application.datasource#">
		SELECT cm.Contract_Status_Type_IDX,bsafc.Name,cm.Contract_Start_Date,cm.Contract_End_Date
		,cm.Performance_Start_Date,cm.Performance_End_Date,cm.Contract_Number
		FROM Contract_Main cm INNER JOIN Contract_Distributors cd
		ON cm.Contract_Main_ID = cd.Contract_Main_ID
		INNER JOIN BSA_Foodservice_Customers bsafc
		ON bsafc.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
		AND cd.deleted = 0
		WHERE cm.Contract_Main_ID = '#URL.program_Id#'
	</cfquery>

<cfset CurrentProgramStatus = getProgramData.Contract_Status_Type_IDX>

 <CF_MessageWindow>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Retailer Information</title>
<script language="javascript">

/* Make sure the price and Quantity is entered for all the products */
	function CheckForm()
	{
		var Quantity;
		var Price; 
		var ErrorCount = 0;
		var ElementNumber = 0;

		for (var i=0;i<frm_retailer.length;i++){ // loop through all elements 
				var name_ =frm_retailer[i].name; // get element name 
				var type_ =frm_retailer[i].type; // get element type
					if(type_ = 'text' && name_.indexOf('qty_')!=-1){
							ElementNumber = ElementNumber + 1;
							Quantity = eval('document.frm_retailer.qty_'+ElementNumber);
						if(Quantity.value =='' && Quantity.value <=0){	
								Quantity.focus();		
								ErrorCount++;
								queueMessage("You must enter the Quantity", eval('document.all.error_quantity_'+ElementNumber));	
						}
						else{
							clearQueue(eval('document.all.error_quantity_'+ElementNumber));
						}
					}
				}

				ElementNumber = 0;

				for (var i=0;i<frm_retailer.length;i++){ // loop through all elements 
				var name_ =frm_retailer[i].name; // get element name 
				var type_ =frm_retailer[i].type; // get element type
					if(type_ = 'text' && name_.indexOf('price_')!=-1){
							ElementNumber = ElementNumber + 1;
							Price = eval('document.frm_retailer.price_'+ElementNumber);
						if(Price.value =='' && Price.value <=0){	
								Price.focus();	
								ErrorCount++;
								queueMessage("You must enter the Price", eval('document.all.error_price_'+ElementNumber));	
						}
						else{
							clearQueue(eval('document.all.error_price_'+ElementNumber));
						}	
					}
				}
				if(ErrorCount == 0) {
					document.frm_retailer.submit();
				}
				else{
						showMessageWindow();
						return false;
				}
	}

	/* Make sure the Quantity is the same for all the products */
	function MakeSameQuantity()
	{
	if(document.frm_retailer.Qty_ChBox.checked == true)
	{
		if((document.frm_retailer.qty_1.value =='' || document.frm_retailer.qty_1.value <=0)){
			document.frm_retailer.Qty_ChBox.checked = false;
			queueMessage("You must enter a quantity greater than zero for the first product to use this feature", document.all.error_qty_1);
			showMessageWindow();	
			return false;
		}
		else{
			clearQueue(document.all.error_quantity_1);
		}
	

	var ElementNumber = 0;
			for (var i=0;i<frm_retailer.length;i++){ // loop through all elements 
				var name_ =frm_retailer[i].name; // get element name 
				var type_ =frm_retailer[i].type; // get element type
					if(type_ = 'text' && name_.indexOf('qty_')!=-1){
						ElementNumber = ElementNumber + 1;
						Quantity = eval('document.frm_retailer.qty_'+ElementNumber);
						Quantity.value = eval('document.frm_retailer.qty_1').value;
					}
			}
		}
	}

	/* Make sure the Price is the same for all the products */
	function MakeSamePrice()
	{
	if(document.frm_retailer.Price_ChBox.checked == true)
	{
		if((document.frm_retailer.price_1.value =='' || document.frm_retailer.price_1.value <=0)){
			document.frm_retailer.Price_ChBox.checked = false;
			queueMessage("You must enter a price greater than zero for the first product to use this feature", document.all.error_price_1);
			showMessageWindow();	
			return false;
		}
		else{
			clearQueue(document.all.error_price_1);
		}
	

	var ElementNumber = 0;
			for (var i=0;i<frm_retailer.length;i++){ // loop through all elements 
				var name_ =frm_retailer[i].name; // get element name 
				var type_ =frm_retailer[i].type; // get element type
					if(type_ = 'text' && name_.indexOf('price_')!=-1){
						ElementNumber = ElementNumber + 1;
						Quantity = eval('document.frm_retailer.price_'+ElementNumber);
						Quantity.value = eval('document.frm_retailer.price_1').value;
					}
			}
		}
	}

/* Dont let the user change the quantity or price for a single product, if the "All Same" checkbox is selected */
	function CheckValue(InputName,InputNumber)
	{
		if(document.frm_retailer.Qty_ChBox.checked == true)
		{
				var name_ = eval('document.frm_retailer.'+InputName+InputNumber) // get element name 
				if(InputName == 'qty_')
				{	
					var FirstTextBoxValue = document.frm_retailer.qty_1.value // get First Text Box element name (qty)		
						if(name_.value != FirstTextBoxValue){
							queueMessage("The value in all quantity textboxes should be the same.", eval('document.all.error_qty_'+InputNumber));
							showMessageWindow();	
							name_.value = FirstTextBoxValue;
							return false;
						}
						else{
							clearQueue(eval('document.all.error_qty_'+InputNumber));
						}
				}				
		}

		if(document.frm_retailer.Price_ChBox.checked == true)
		{
				var name_ = eval('document.frm_retailer.'+InputName+InputNumber) // get element name 
				if(InputName == 'price_')
				{	
					var FirstTextBoxValue = document.frm_retailer.price_1.value // get First Text Box element name (price)				
						if(name_.value != FirstTextBoxValue){
							queueMessage("The value in all price textboxes should be the same.", eval('document.all.error_price_'+InputNumber));
							showMessageWindow();	
							name_.value = FirstTextBoxValue;
							return false;
						}
						else{
							clearQueue(eval('document.all.error_price_'+InputNumber));
						}
				}				
		}
	}
</script>
</head>

<body>

<cfoutput>
<form name="frm_retailer" action="contract_retailer_info_action.cfm" method="post">
<cfset cols = retail_info.recordcount + 1 />

<cfset GroupRetailFileName = "Group_Retail_Info_#URL.program_Id#.htm" />

<!--- Here I am using a few "CFSAVECONTENT" tags for "Email/Printing/Fax" purpose. I could have used a seperate page to 
			write the file, but that would be a unnecessary overhead. The only reason why I have used seperate tags is that the 
			written file cannot have the "textboxes" etc, in it. It just displays that data.
--->

<!--- Save the "Stle Sheet" --->
<cfsavecontent variable="RetailData_Header">
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<style type="text/css">
.datacell {
	text-align: left;
		}
.headcell {
	text-align: left;
	font-size:12px;
	font-weight:bold
		}
</style>
<table  border="0" cellspacing="0" cellpadding="2">
</cfsavecontent>

<!--- Save the "Header" and the first few rows  --->
<cfsavecontent variable="RetailData_Content_1">
  <tr bgcolor="##ffce84">
    <td colspan="<cfoutput>#cols#</cfoutput>" align="center"><span style="font-weight:bold;font-size:14">Retailer Information</span></td>
  </tr>
  <tr>
    <td  colspan="<cfoutput>#cols#</cfoutput>" class="headcell">&nbsp;</td>
  </tr>
  <tr class="headcell" bgcolor="##C6FFC6">
    <td class="headcell">Product #RepeatString("&nbsp;", 35)#</td>
	<cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
	<!--- For Groups --->
	<cfif IsGroup neq 0>
		<td class="datacell" valign="top">#retail_info["Product_Hierarchy_Name"][x]#</td>
	<!--- For Products --->
	<cfelse>
		<td class="datacell" valign="top">#retail_info["Item"][x]#</td>
	</cfif>
	</cfloop>
  </tr>
  <tr class="headcell" bgcolor="##C6FFC6">
	<!--- For Groups --->
	<cfif IsGroup neq 0>
    <td class="headcell">Product ID</td>
	<cfelse>
	<!--- For Products --->
		<td class="headcell">Description</td>
	</cfif>
  <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
	<!--- For Groups --->
	<cfif IsGroup neq 0>
		<td class="datacell">#retail_info["Group_ID"][x]#</td>
		<input type="hidden" name="Product_Hierarchy_ID_#x#" value="#retail_info['Product_Hierarchy_ID'][x]#">
	<!--- For Products --->
	<cfelse>
		<td class="datacell">#retail_info["Description"][x]#</td>
		<input type="hidden" name="BSA_Foodservice_Items_Master_ID_#x#" value="#retail_info['BSA_Foodservice_Items_Master_ID'][x]#">
	</cfif>	
		<input type="hidden" name="Inventory_UM_#x#" value="#retail_info['UOM'][x]#">
	</cfloop>
  </tr>
  <tr>
    <td class="headcell">Retail Selling Units</td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">#val(retail_info["EA_Conversion"][x])#&nbsp;</td>
	</cfloop>
  </tr>
  <tr class="headcell" bgcolor="##C6FFC6">
    <td class="headcell">List Price</td>
     <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#val(retail_info["Bracket_Price"][x])#&nbsp;</td>
	</cfloop>
  </tr>
  <tr>
    <td class="headcell">Allowances</td>
     <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#val(retail_info["Allowance"][x])#&nbsp;</td>
	 </cfloop>
  </tr>
  <tr class="headcell" bgcolor="##C6FFC6">
    <td class="headcell">Net Variable Price</td>
   <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#val(retail_info["Net_Variable_Price"][x])#&nbsp;</td>
	 </cfloop>
  </tr>
	</cfsavecontent>

<!--- Save the "Merchant Quantity" and the "Merchant Price" --->
<cfsavecontent variable="RetailData_Content_2_Form">
	<tr>
    <td colspan="100%" align="left">#RepeatString("&nbsp;", 20)# <span style="font-size:10px;">All Same</span></td>
  </tr>
  <tr>
    <td class="headcell">Merch Qty&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="Qty_ChBox" value="checkbox" onClick="MakeSameQuantity();" /></td>
   <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell"><span id="error_quantity_#x#"></span>&nbsp;&nbsp;<input name="qty_#x#" type="text" size="5" value="#retail_info['Merchant_Quantity'][x]#" onkeyup="CheckValue('qty_','#x#')" />&nbsp;</td>
	</cfloop>
  </tr>
  <tr>
    <td class="headcell">Merch Price<input type="checkbox" name="Price_ChBox" value="checkbox" onClick="MakeSamePrice();" /></td>
   <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell"><span id="error_price_#x#"></span>$<input name="price_#x#" type="text" size="5" value="#retail_info['Merchant_Price'][x]#" onkeyup="CheckValue('price_','#x#')" />&nbsp;</td>
	 </cfloop>
  </tr>
</cfsavecontent>

<!--- Save the "Merchant Quantity" and the "Merchant Price" --->
<cfsavecontent variable="RetailData_Content_2_Print_Email_Fax">
  <tr>
    <td class="headcell">Merch Qty</td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#val(retail_info['Merchant_Quantity'][x])#&nbsp;</td>
	</cfloop>
  </tr>
  <tr>
    <td class="headcell">Merch Price</td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#val(retail_info['Merchant_Price'][x])#&nbsp;</td>
	</cfloop>
  </tr>
</cfsavecontent>

<!--- Save the last few rows (Let's call it a footer) --->
<cfsavecontent variable="RetailData_Content_3">
  <tr>
    <td class="headcell">Lump Sum </td>
   <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#val(retail_info["Lumpsum"][x])#&nbsp;</td>
	 </cfloop>
  </tr>
  <tr>
    <td class="headcell">Volume</td>
   <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">#NumberFormat(Round(val(retail_info["Volume"][x])),',999')# &nbsp;</td>
	 </cfloop>
  </tr>
  <tr>
    <td  colspan="#cols#" class="headcell">&nbsp;</td>
  </tr>
  <tr>
    <td class="headcell">Gross Sales </td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#NumberFormat(Round(val(retail_info["Gross_Sales"][x])),',999')#&nbsp;</td>
	 </cfloop>
  </tr>
  <tr>
    <td class="headcell">Profit</td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#NumberFormat(val(retail_info["Profit"][x]),',999')#&nbsp;</td>
	 </cfloop>
  </tr>
  <tr>
    <td class="headcell">Store Del Margin </td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">#val(retail_info["Store_Delivered_Margin"][x])#%&nbsp;</td>
	 </cfloop>
  </tr>
  <tr>
    <td class="headcell">Profit w/ Fixed </td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">$#NumberFormat(val(retail_info["Profit_With_Fixed"][x]),',999')#&nbsp;</td>
	 </cfloop>
  </tr>
  <tr>
    <td class="headcell">Margin w/ Fixed </td>
    <cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<td class="datacell">#val(retail_info["Margin_With_Fixed"][x])#%&nbsp;</td>
	 </cfloop>
  </tr>
</table>
</cfsavecontent>

<!--- Save the variable to show the info on this page --->
<cfset ShowDataonPage = RetailData_Header&RetailData_Content_1&RetailData_Content_2_Form&RetailData_Content_3>

<!--- Save the variable to write the file for print/email/fax --->
<cfset ShowDataforPrintFaxEmail = RetailData_Header&RetailData_Content_1&RetailData_Content_2_Print_Email_Fax&RetailData_Content_3>

#ShowDataonPage#

		<input type="hidden" name="Program_ID" value="#program_Id#">
		<!--- For Groups --->
		<cfif IsGroup neq 0>
		<input type="hidden" name="GroupCount" value="#retail_info.recordcount#">
		<!--- For Products --->
		<cfelse>
		<input type="hidden" name="ProductCount" value="#retail_info.recordcount#">
		</cfif>

		<P align="center"> 
			<span style="font-weight:bold;color:red"> [ </span> 
				<a href="##" OnClick="javascript:return CheckForm();return false;" style="font-weight:bold;">Save</a>
			<span style="font-weight:bold;color:red"> ] </span>
		</P>
</form>
</cfoutput>

<!--- Write the file --->
<cfinclude template="Group_Retail_Info_Email_Fax_Handler.cfm">

<!--- These products do not have a list price --->
<p align="left">
<cfoutput>
<span><b>Note:</b> The following products have no list price:<br />				
	<cfloop from="1" to="#retail_info.recordcount#" step="1" index="x">
		<cfif val(retail_info["Bracket_Price"][x]) eq 0>
		<!--- For Groups --->
		<cfif IsGroup neq 0>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #retail_info["Product_Hierarchy_Name"][x]#<br />
		<!--- For Products --->
		<cfelse>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #retail_info["Item"][x]#<br />
		</cfif>
		</cfif>
	</cfloop>
</span>
</cfoutput>
</p>

<!--- Parse data to get the path to the file --->
	<CFSET reversed_completepath_print=reverse(completepath_email)>
	<CFSET filename_print=reverse(left(reversed_completepath_print, find("\", reversed_completepath_print)-1))>

<cfoutput>
<p align="left">
<!--- Only when the program is in "active" status and beyond --->
	<cfif CurrentProgramStatus GTE 3>	
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="/common_files/contracts/Group_Retail_Info_printer_friendly.cfm?ID=#filename_print#&CID=#CID#" onClick="NewWindow(this.href,'printpage','800','600','Yes', 'No');return false;">Print</a><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>	
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="/common_files/contracts/Group_Retail_Info_Email_Create.cfm?CID=#CID#&FID=#Encoded_completepath_email#" onClick="NewWindow(this.href,'emailpage','800','600','Yes', 'No');return false;">Email</a><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>
	<B>
		<FONT SIZE="2" COLOR="red">[ </FONT><a href="/common_files/contracts/Group_Retail_Info_Fax_Create.cfm?CID=#CID#&FID=#Encoded_completepath_email#" onClick="NewWindow(this.href,'faxpage','800','600','Yes', 'No');return false;">Fax</a><FONT SIZE="2" COLOR="red"> ]</FONT>
	</B>
	</cfif>
</p>
</cfoutput>
</body>
</html>
