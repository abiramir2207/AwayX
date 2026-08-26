<!-----------------------------------------------------------------------------
FILE NAME:		_margin_exclusion_add.cfm
DESCRIPTION:	This is the details file that is used to Add/Edit the Margin exclusion record 
CREATED BY:		10-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
      			Anand Rao	  10-Aug-2010	Created the file
------------------------------------------------------------------------------> 

<style>
.Orangline
{
	border-right: 2px solid orange;
	width:400px;
}
</style>
<cfoutput>
<cfif (FORM.MarginItemExclusionID NEQ "")>
  <cfparam name="FORM.MarginItemExclusionCode" 	default="#qMarginItemExclusion.Margin_Item_Exclusion_Code#">
  <cfparam name="FORM.MarginItemExclusionName" 	default="#qMarginItemExclusion.Margin_Item_Exclusion_Name#">
  <cfparam name="FORM.IncludeOnVolume" 	default="#qMarginItemExclusion.Include_On_Volume#">
  <cfparam name="FORM.ExistingProductList" default="#ValueList(qMarginItemExclusionProducts.Product_Group_ID)#">
  <cfparam name="FORM.Product_List" default="#ValueList(qMarginItemExclusionProducts.Product_Group_ID)#">
  <cfparam name="FORM.ProductListToExcludeFromSelecting" default="">
  <cfparam name="FORM.GroupLevel" default="#qMarginItemExclusionGroups.Product_Group_Level_ID#">
  <cfparam name="FORM.Template_Select" 	default="#ValueList(qMarginItemExclusionTemplates.Program_Template_ID)#">    
  <cfparam name="FORM.pageSource" default="ItemExcludeEdit">
  <cfparam name="FORM.Allow_Approval_group" default="#ValueList(qMarginItemExclusionGroups.Product_Group_ID)#">
  <cfparam name="FORM.MarginItemExclusionID" default = "#FORM.MarginItemExclusionID#" />
  <cfif qMarginItemExclusion.UpdatedByFullName NEQ "">
    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="0"  align="center" width="600">
      <tr>
        <td>
          <cfoutput>
    	      <font size="2"><b>The settings were last updated on #dateformat(qMarginItemExclusion.Updated_On, 'mm/dd/yyyy')# #timeformat(qMarginItemExclusion.Updated_On, 'hh:mm:ss TT')# by #qMarginItemExclusion.UpdatedByFullName#</b></font>
          </cfoutput>  
        </td>
      </tr>
    </table>
  </cfif>
<cfelse>  
  <cfparam name="FORM.MarginItemExclusionCode" default="">
  <cfparam name="FORM.MarginItemExclusionName" default="">
  <cfparam name="FORM.IncludeOnVolume" default="1">
  <cfparam name="FORM.ExistingProductList" default="">
  <cfparam name="FORM.Product_List" default="">
  <cfparam name="FORM.ProductListToExcludeFromSelecting" default="">
  <cfparam name="FORM.GroupLevel" default="">
  <cfparam name="FORM.Template_Select" 	default="">  
  <cfparam name="FORM.pageSource" default="ItemExcludeAdd">
  <cfparam name="FORM.Allow_Approval_group" default="">
  <cfparam name="FORM.MarginItemExclusionID" default="" />
</cfif>


	<cfif NOT isDefined("FORM.Allow_Approval_group")>
		<cfset qGetTemplateAllowApprovalGroups = approvalGroupManager.getTemplateAllowApprovalGroups(ID) />
		<cfset FORM.Allow_Approval_group = ValueList(qGetTemplateAllowApprovalGroups.Group_ID)>
	</cfif>


<input type="hidden" name="pageSource" value="ItemExcludeAdd">
<!--- #Product_List# --->
<cfif (isDefined("FORM.Product_List") AND FORM.Product_List NEQ "")>
  <cfoutput><input type="hidden" name="Product_List" value="#FORM.Product_List#">
  <input type="hidden" visible="false" name="ExistingProductList" value="#FORM.Product_List#">
  </cfoutput>
<cfelse>
<input type="hidden" name="Product_List" value="">
<input type="hidden" visible="false" name="ExistingProductList" value="">
</cfif>

<input type="hidden" name="ProductListToExcludeFromSelecting" value="">
 
<cfif isDefined("FORM")>
  <cfset SESSION.FormData = FORM />
</cfif>

<cfif isDefined("SESSION.FormData")>
  <cfset FORM.MarginItemExclusionCode           = SESSION.FormData.MarginItemExclusionCode />
  <cfset FORM.MarginItemExclusionName           = SESSION.FormData.MarginItemExclusionName />
  <cfset FORM.IncludeOnVolume                   = SESSION.FormData.IncludeOnVolume />
  <cfset FORM.Template_Select                   = SESSION.FormData.Template_Select />
  <cfset FORM.ExistingProductList               = SESSION.FormData.ExistingProductList />
  <cfset FORM.Product_List                      = SESSION.FormData.Product_List />
  <cfset FORM.ProductListToExcludeFromSelecting = SESSION.FormData.ProductListToExcludeFromSelecting />    
</cfif>
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Items Exclusion Information</LEGEND>
    <table width="100%" border="0"   cellpadding="3" cellspacing="0">
		<!------ external id ----->
  		<tr>
  			<td align="right" width="20%" class="Orangline" ><b>ID:</b></td>
  			<td><input name="MarginItemExclusionCode" type="text" value="#FORM.MarginItemExclusionCode#" size="30" maxlength="50"></td>
  		</tr>
  		<tr>
  			<td align="right" class="Orangline" width="20%"><B>Name:</B></td>
  			<td><input name="MarginItemExclusionName" type="text" maxlength="100" value="#FORM.MarginItemExclusionName#" style="width:220px" ></td>
  		</tr>	
  		<tr>
  			<td align="right" width="20%" class="Orangline"><B>Include On volume page:</b></td>
  			<td  align="left"><input name="IncludeOnVolume" type="checkbox" maxlength="100" value="1" <cfif FORM.IncludeOnVolume EQ "1">checked</cfif>></td>
  		</tr>	
      <tr>
        <td align="right"  class="Orangline" width="20%" valign="top"> 
          <strong>Search Products:</strong>
        </td>
        <td>
        <cfif isDefined("application.returned_customer_setting.group_deals") AND application.returned_customer_setting.group_deals EQ 1>
      	  <cfset addGroupLabel = "add groups" />
  				<select name="GroupLevel" id="GroupLevel">
  					<option value="">Select Group...</option>
  					<cfloop query="qGetTopLevelGroups">
  						<option value="#Product_Group_Level_ID#" <cfif FORM.GroupLevel EQ Product_Group_Level_ID>selected</cfif>>#Group_Level_Desc#</option>
  					</cfloop>
  				</select>
          &nbsp;
  			<cfset extraParameter = " onClick=""javascript: return showSearchWindow('/Search_Screens/ApprovalGroup_Search.cfm?groupLevelId=' + document.DataForm.GroupLevel.options[document.DataForm.GroupLevel.selectedIndex].value, 'Allow_Approval_group',document.DataForm.GroupLevel.options[document.DataForm.GroupLevel.selectedIndex].value,document.DataForm);""" />
  		 		<CF_smallLink 
  					title = "select group"
  					url = "##"
  					parameters = "#extraParameter#"
  					> 
      <cfelse>
        <input type="hidden" name="GroupLevel" value="" />
      </cfif>
      <cfset addProductLabel = "add products" />
      <cfif appSettings.getFlexProductSearch()>
  		<CF_smallLink 
  			title = "#addProductLabel#" 
  			url = "##"
  			parameters = "onClick=""javascript: return showProductSearchWindow();"""
  		>
  		<cfelse>
  		<CF_smallLink 
  			title = "#addProductLabel#" 
  			url = "##"
  			parameters = "onClick=""javascript: return showProductSearchWindow_old();"""
  		>
  		</cfif>
      
      <cfif Len(FORM.product_List) GT 0 >
      <cfset qProductList = ProductManager.getproducts(FORM.product_List) />
      </cfif>
      <cfif Len(FORM.Allow_Approval_group) GT 0>
        <cfset approvalGroupManager.getGroupTypeInfo(FORM.GroupLevel)/>
  			<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(FORM.Allow_Approval_group)>		
      </cfif>
    
      <cfif (Len(FORM.Allow_Approval_group) GT 0 OR (isDefined("qProductList") AND qProductList.RecordCount GT 0))>
  			<cfset maxCols = 3>
  			<table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
          <tr>
          <td id="header" WIDTH="20" rowspan="1">
  			    <NOBR>
  				  <img bDelete="true" sMessage="delete all products in this page" src="/images/scissor.gif" title="delete all products in this page" border="0" onclick="if(confirm('Please confirm that you would like to DELETE all checked products!')){deleteAll('prodChkBx_');};" style="cursor: pointer;">
  			    </NOBR>
  		    </td>
      		<!--- <td width="20" rowspan="1">
            <input name="prodCheck" type="checkbox" onClick="checkAllProd()" checked>
          </td> --->
      		<td width="90" rowspan="1">
      		  <b>Item ## </b> 
      		</td>
      		<td width="80" rowspan="1">
      		  <b>
              LEVEL/GROUP
            </b>
      		</td>
      		<td width="80" rowspan="1">
      			<b>DESCRIPTION</b>&nbsp;
      		</td>
         </tr> 
    <cfif (isDefined("qGetApprovalGroups") AND	qGetApprovalGroups.RecordCount GTE 1)>
      <cfloop query="qGetApprovalGroups">
        <tr>
          <td width="15">
  				  <img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="deleteThisProduct('', '', 'ccffcc', '#Group_ID#')" style="cursor: pointer;">
  			  </td>
         <!---  <td>
            <input name="groupChkBx_#Group_ID#" type="checkbox" value="#Group_ID#" checked> 
          </td> --->
  				<td bgcolor="eeeeee">Group Product</td>
          <td bgcolor="eeeeee">Level 1/<script>document.write(document.DataForm.GroupLevel.options[document.DataForm.GroupLevel.selectedIndex].text)</script> </td>
          <td bgcolor="eeeeee">#Group_Name#</td> 
        </tr>
      </cfloop>
    </cfif>    
    </cfif>
      <cfif isDefined("qProductList") AND qProductList.RecordCount GT 0>
        <cfloop query="qProductList">
          <tr>
            <td width="15">
  				    <img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif"  title="click here to delete this product" border="0" onclick="deleteThisProduct('', '#qProductList.BSA_Foodservice_Items_Master_ID#', 'ccffcc', '')" style="cursor: pointer;">
  			    </td>
           <!---  <td>
              <input name="prodChkBx_#qProductList.BSA_Foodservice_Items_Master_ID#" type="checkbox" value="#qProductList.BSA_Foodservice_Items_Master_ID#" checked> 
            </td> --->
  				  <td bgcolor="eeeeee">#qProductList.Item#</td>
            <td bgcolor="eeeeee">Level 2/Product</td>
  				  <td bgcolor="eeeeee">#qProductList.Description#</td>
          </tr>
        </cfloop>
      </cfif> 
    </table>        
  </td>
  </tr>
 
		<!--- ***************************** select templates ***************************** --->
		<tr>
  		<td colspan="2">
        <div>
      		<cfinclude template="/program_wizard/Select_Template_All.cfm" />
        </div>
  		</td>
		</tr>
	</table>
  <div align="center" width="100%">
    <cfif Trim(FORM.MarginItemExclusionID) EQ "">
      <CF_button
  		  button_name		=	""
  			button_caption	=	"Add"
  			button_action	=	"return chkExclusionItems('add');"
  			button_type		=	"javascript_link"
  			button_width	=	"75"
  			button_color	=	"Navy"
  			button_tip		=	""
  			font_color		=	"White"
  			font_size		=	"12"
  			font_weight		=	"bold"
  		>
    <cfelse>
      <CF_button
  			button_name		=	""
  			button_caption	=	"Update"
  			button_action	=	"return chkExclusionItems('edit');"
  			button_type		=	"javascript_link"
  			button_width	=	"75"
  			button_color	=	"Navy"
  			button_tip		=	""
  			font_color		=	"White"
  			font_size		=	"12"
  			font_weight		=	"bold"
  		>
    </cfif>    
  </div>        
</FIELDSET>

  <input type="hidden" name="Allow_Approval_group" value="#FORM.Allow_Approval_group#">      
	<input type="hidden" name="bSubmit" value="0" />
  <cfif FORM.display EQ "add">
      <input type="hidden" name="productRefresh" value = "0" /> 
  </cfif>  
	<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////
	function chkExclusionItems(operation)
	{
		var actionFrm = document.DataForm;
		var templateArr = checkTemplateSelected(actionFrm.Template_Select);
		if (templateArr.length == 0) { 
			alert("Select a Template for the Item exclusion"); 
			return false;
		}
		if (trim(actionFrm.MarginItemExclusionName.value) == "") {
			alert("Please provide a Name for the Item exclusion");
			return false;
		}
		if (actionFrm.Allow_Approval_group.value == "" && actionFrm.Product_List.value == "") {
			alert("Select a product for the Item exclusions");
			return false;
		}		
		//set hidden form fields and submit
	    if (operation == 'add') {		
	      actionFrm.command.value = 'addExclusionItems';
		} else {
	      actionFrm.command.value = 'updateExclusionItems';
	    }		
	    
    	actionFrm.bSubmit.value = 1;
	    actionFrm.display.value = 'active';
		actionFrm.submit();
		return false;	

	}
 
	function checkTemplateSelected(buttonGroup) {
	   // Go through all the check boxes. 
	   // if no boxes were checked,array will be empty
	   var retArr = new Array(); // start with zero length array
	   var lastElement = 0;
	   if (buttonGroup[0]) { // if the button group is an array (one check box is not an array)
	      for (var i=0; i<buttonGroup.length; i++) {
	         if (buttonGroup[i].checked) {
	            retArr.length = lastElement;
	            retArr[lastElement] = i;
	            lastElement++;
	         }
	      }
	   } 
	   else { // There is only one check box (it's not an array)
	      if (buttonGroup.checked) { // if the one check box is checked
	         retArr.length = lastElement;
	         retArr[lastElement] = 0; // return zero as the only array value
	      }
	   }
	   return retArr;
	} // End the checkTemplateSelected function
	 
  
  function deleteThisProduct(FieldNameRe, prodID, bgCol, GroupID)//,realGroupLevelId
	{	
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.DataForm.Product_List.value;
		var FINALGROUPLIST = document.DataForm.Allow_Approval_group.value;
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var grpResultString = ListDeleteItem(FINALGROUPLIST, ",", GroupID);
		var bDelete = true;
		var objGroupLevel;
		var itemCount = FINALITEMLIST.split(",");
		var groupCount = FINALGROUPLIST.split(",");
		
      if (prodID != "") 
      {
        if (resultString == FINALITEMLIST)
        {
          resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
          bDelete = false;
        }
      }
      if (GroupID != "")
      {
        if (grpResultString == FINALGROUPLIST)
        {
          grpResultString = ListAppendItem(FINALGROUPLIST, ",", GroupID);
          bDelete = false;
        }
      }
			document.DataForm.Product_List.value = resultString;
		  	document.DataForm.Allow_Approval_group.value = grpResultString;
			var empty_String = "<IMG SRC=\"/Images/fill.gif\" width=\"1\" height=\"1\">";	
			if(trObj)
			{			
			  if(bDelete)
				{ 
					trObj.height = trObj.offsetHeight;
					//trObj.cells[trObj.cells.length-1].innerHTML = empty_String;
					propogateProperty(trObj, "style.backgroundColor", "##DDDDDD", false);
					propogateProperty(trObj, "style.textDecoration", "line-through", true);				
					srcObj.title = "Deleted";
					srcObj.src = undodeleteImg.src;
				}
 				else
				{
					propogateProperty(trObj, "style.backgroundColor", "##eeeeee", false);
					propogateProperty(trObj, "style.textDecoration", "none", false);
					// unDeleteProduct(prodCompId);//prodCompId=contract_product_id
					srcObj.title = "delete this product";
					srcObj.src = deleteImg.src;
					propogateProperty(trObj, "style.backgroundColor", "FFFFFF", false, true);
			 	}
				srcObj.bDelete = !bDelete;
				trObj.bDelete = (bDelete?1:0);
				}
		}

  	function getParentObject(thisObj, tagName)
	  {
		  if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		  {
			  return thisObj;
		  }
		  else if(thisObj.tagName.toLowerCase() == "body")
		  {
			  return null;
		  }
		  else
		  {
			  return getParentObject(thisObj.parentElement, tagName);
		  }
	  }
  </script> 

</cfoutput>