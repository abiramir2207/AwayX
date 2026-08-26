<!--- 
FILE: 		
FILENAME: 	Common_Files/contracts/bid_request/bid_request_product_split.cfm
CREATED: 	??/??/200? - ???
EDITED:		10/09/2008 - RBL

FUNCTIONALITY:
- This file displays bid request product splits... RBL --->

<!---bid_request_product_split.cfm--->
 <!--- 
   Dev Notes: 23635/Anand Rao/04-Jun-10
   Competitive Data, Forge changes
  --->
  <cfset useLakebaseForGet_Won_By_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_won_by")>
<cfif useLakebaseForGet_Won_By_Data>
	<cftry>
		<cfset Get_Won_By_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_won_by", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "program_bid_won_by_description.asc",
				"select" = "program_bid_won_by_id,program_bid_won_by_code,program_bid_won_by_description,active,deleted,created_date,updated_date,updated_by"
			}), "program_bid_won_by_id,program_bid_won_by_code,program_bid_won_by_description,active,deleted,created_date,updated_date,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Won_By_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Won_By_Data>
<cfquery name="Get_Won_By_Data" datasource="#application.datasource#">
  	SELECT		Program_Bid_Won_By_ID,
              Program_Bid_Won_By_Code,
              Program_Bid_Won_By_Description,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Updated_By
  	FROM		Program_Bid_Won_By 
    WHERE Deleted = 0  AND Active = 1
  	ORDER BY	Program_Bid_Won_By_Description
  </cfquery>
</cfif>

  <cfset useLakebaseForGet_Category_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_category")>
<cfif useLakebaseForGet_Category_Data>
	<cftry>
		<cfset Get_Category_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_category", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "program_bid_category_description.asc",
				"select" = "program_bid_category_id,program_bid_category_code,program_bid_category_description,active,deleted,created_date,updated_date,updated_by"
			}), "program_bid_category_id,program_bid_category_code,program_bid_category_description,active,deleted,created_date,updated_date,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Category_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Category_Data>
<cfquery name="Get_Category_Data" datasource="#application.datasource#">
  	SELECT		Program_Bid_Category_ID,
              Program_Bid_Category_Code,
              Program_Bid_Category_Description,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Updated_By
  	FROM		Program_Bid_Category 
    WHERE Deleted = 0  AND Active = 1
  	ORDER BY	Program_Bid_Category_Description
  </cfquery>
</cfif>

  <cfset useLakebaseForGet_Package_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_package")>
<cfif useLakebaseForGet_Package_Data>
	<cftry>
		<cfset Get_Package_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_package", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "program_bid_package_description.asc",
				"select" = "program_bid_package_id,program_bid_package_code,program_bid_package_description,active,deleted,created_date,updated_date,updated_by"
			}), "program_bid_package_id,program_bid_package_code,program_bid_package_description,active,deleted,created_date,updated_date,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Package_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Package_Data>
<cfquery name="Get_Package_Data" datasource="#application.datasource#">
  	SELECT		Program_Bid_Package_ID,
              Program_Bid_Package_Code,
              Program_Bid_Package_Description,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Updated_By
  	FROM		Program_Bid_Package 
    WHERE Deleted = 0  AND Active = 1
  	ORDER BY	Program_Bid_Package_Description
  </cfquery>
</cfif>    
  
  <cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
  <cfset qGetWonByLabel 	  = LabelComp.getGeneralLabels('Won By') />
  <cfset qGetCategoryLabel 	= LabelComp.getGeneralLabels('Category') />
  <cfset qGetPackageLabel 	= LabelComp.getGeneralLabels('Package') /> 
 
   
<cfoutput>
<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

<!---default params--->
<cfparam name="form.command" default="" />
<cfparam name="form.init" default="0" />
<cfparam name="form.sort_by" default="Item" />
<cfparam name="form.sort_order" default="asc" />
<cfparam name="url.contract_status" default="0" />
<cfparam name="form.contract_status" default="#url.contract_status#" />
<cfparam name="url.bidStatusId" default="3" />
<cfparam name="form.bidStatusId" default="#url.bidStatusId#" />

<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////CONTROLLER SECTION///////////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!---initialize the BidRequestProductManager--->
<cfset bidRequestProductManager = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />

<!---get bid request spec list--->
<cfset bidRequestSpec = CreateObject("component", "components.programs.bid_request.BidRequestSpec") />
<cfset qGetBidSpec = bidRequestSpec.getBidRequestSpec() />

<!---if the form hasn't been initialized then we know it's the first time in so let's get data from DB --->
<cfif not form.init>
	<cfset bidRequest = bidRequestProductManager.getAllProductsFromDb(cryp.value) />
<!---otherwise set data from form--->
<cfelse>
	<cfset bidRequest = bidRequestProductManager.setFromForm(form) />
</cfif>

<!---set the bid request products--->
<cfset aBidRequestProducts = bidRequest.getBidRequestProducts() />

<!---set the bid request products list for form.product_list--->
<cfset form.Product_List = bidRequest.getLBidRequestProductIds() />

<cfif form.command eq "save">
 
	<cfset BidRequestProductStatusManager = CreateObject("component", "components.programs.bid_request.BidRequestProductStatusManager").init() />
	<cfset BidRequestProductStatusManager.saveBidRequestProductSplits(bidRequest, form.bidStatusId) />
	<!---once we save reload the contract page a close window--->
	<script>
		 opener.location.href = opener.location.href;
  // window.close();
	  	self.close();
	</script>
</cfif>


<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---///////////////////////////////////////////////////END CONTROLLER SECTION///////////////////////////////////////////////////////////////--->
<!---////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

<CFSET PAGE_TITLE= "Proposal Product Split">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<TITLE>#PAGE_TITLE#</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<script src="/billbacks/common/common_js_functions.js"></script>
	<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js"></script>
	<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
	<script src="bid_request.js"></script>
	<style>
		.brdrLft td { border-left:1px solid silver }
		.brdrLftTop td { border-left:1px solid silver; border-top:1px solid silver}
		.brdrRgt { border-right:1px solid silver }
		.disable {background-color:##CCCCCC}
		.enable {background-color:##FFFFFF}
	</style>
</head>

<body BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="5" ONLOAD="">

<FORM ACTION="" METHOD="post" NAME="dataForm" ID="dataForm" STYLE="DISPLAY:INLINE;">
<B><FONT SIZE="2" COLOR="Navy">Apply Won/Lost</FONT></B><HR COLOR="Navy">
<b><font color="FF0000">[</font> <a href="javascript:submitForm('save');">save</a><font color="FF0000">]</font></b>&nbsp;&nbsp;
<b><font color="FF0000">[</font> <a href="javascript:window.close();">cancel</a><font color="FF0000">]</font></b>
<br><br>
<!---table header--->
<!--- <table border="0" cellspacing="0" cellpadding="3" class="MainTable" width="785"> --->
	<!--- <!--- <TR ID="header" BGCOLOR="##ffce84"> ---> --->
<!--- 	<tr id="header" bgcolor="##FFCE84" class="brdrLftTop">
		<td valign="middle" width="15%" align="left" ID="header"><A HREF="javaScript:sortByThis('Item');"><b>Item ##</b>&nbsp;<cfif form.sort_by eq "item"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></td>
		<td valign="middle" width="30%" align="left" ID="header"><A HREF="javaScript:sortByThis('Description');"><b>Description</b>&nbsp;<cfif form.sort_by eq "description"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></td>
		<td valign"middle" width="10%" align="left" ID="header"><b>Won/Lost</b></td>
    <td valign"middle" width="15%" align="left" ID="header"><b>Category<br>Package</b></td>    
		<td valign"middle" width="15%" align="left" ID="header"><b>Won By</b></td>
		<td valign"middle" width="15%" align="left" ID="header" class="brdrRgt"><b>Won Price</b></td>
		<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
		<td valign"middle" width="10%" align="left" ID="header" class="brdrRgt"><b>Delivery Type</b></td>
		</cfif>
	</tr>
	</table>
 --->
<table border="0" cellspacing="0" cellpadding="3" class="MainTable" width="785">	 
 	<tr id="header" bgcolor="##FFCE84" class="brdrLftTop">
		<td valign="middle" align="left" ID="header"><div style="width:70px;"><A HREF="javaScript:sortByThis('Item');"><b>Item ##</b>&nbsp;<cfif form.sort_by eq "item"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></div></td>
		<td valign="middle" align="left" ID="header"><div style="width:190px;"><A HREF="javaScript:sortByThis('Description');"><b>Description</b>&nbsp;<cfif form.sort_by eq "description"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></div></td>
		<td valign"middle" align="left" ID="header"><div style="width:60px;"><b>Won/Lost</b></div></td>
    <td valign"middle"  align="left" ID="header"><div style="width:145px;"><b>Category<br>Package</b></div></div></td>    
		<td valign"middle"  align="left" ID="header"><div style="width:110px;"><b>Won By</b></div></td>
		<td valign"middle"  align="left" ID="header"><div style="width:110px;"><b>Won Price</b></div></td>
		<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
		<td valign"middle"  align="left" ID="header" class="brdrRgt"><div style="width:55px;"><b>Delivery Type</b></div></td>
		</cfif>
	</tr>
</table> 
<cfif arrayLen(aBidRequestProducts) gt 13>
	<cfset divHght = "height:500px;" />
<cfelse>
	<cfset divHght = "" />
</cfif>

<div style="position:relative;overflow:auto;#divHght#">
<table border="0" cellspacing="0" cellpadding="3" class="MainTable" width="785">	
<!--- 	<tr id="header" bgcolor="##FFCE84" class="brdrLftTop">
		<td valign="middle" width="15%" align="left" ID="header"><A HREF="javaScript:sortByThis('Item');"><b>Item ##</b>&nbsp;<cfif form.sort_by eq "item"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></td>
		<td valign="middle" width="30%" align="left" ID="header"><A HREF="javaScript:sortByThis('Description');"><b>Description</b>&nbsp;<cfif form.sort_by eq "description"><cfif form.sort_order eq "desc"><font face="Webdings">5</font><cfelse><font face="Webdings">6</font></cfif></cfif></A></td>
		<td valign"middle" width="10%" align="left" ID="header"><b>Won/Lost</b></td>
    <td valign"middle" width="15%" align="left" ID="header"><b>Category<br>Package</b></td>    
		<td valign"middle" width="15%" align="left" ID="header"><b>Won By</b></td>
		<td valign"middle" width="15%" align="left" ID="header" class="brdrRgt"><b>Won Price</b></td>
		<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
		<td valign"middle" width="10%" align="left" ID="header" class="brdrRgt"><b>Delivery Type</b></td>
		</cfif>
	</tr> --->
	<cfloop index="prodIndx" from="1" to="#arrayLen(aBidRequestProducts)#">
	
		<!---replace hyphens with underscores in prodId--->
		<cfset scrubbedProdId = request.app_general_functions.replaceHyphen(aBidRequestProducts[prodIndx].getItemMasterId()) />
		
		<!---set this spec id--->
		<cfset thisSpecId = aBidRequestProducts[prodIndx].getSpecId() />
		
		<!---set disabled/enabled for won by fields based won/lost--->
		<cfset bWon = aBidRequestProducts[prodIndx].getWon() />
		<cfif (bWon eq 1 and form.contract_status neq 8) and form.bidStatusId neq 4>
			<cfset class = "disable" />
			<cfset bDisable = "disabled='true'" />
		<cfelse>
			<cfset class = "enable" />
			<cfset bDisable = "" />
		</cfif>
		
		<tr class="brdrLft" <CFIF prodIndx mod 2>bgcolor="white"<CFELSE>bgcolor="ccffcc"</CFIF> onMouseOver="menuID=6;URLstring='';an_ID='#aBidRequestProducts[prodIndx].getItemMasterId()#';doNotRelocate=1;" onMouseOut="menuID=0;doNotRelocate=0;" style="cursor: help;" height="30">
			<td valign="middle" <!--- width="10%" --->><div style="width:70px;">#aBidRequestProducts[prodIndx].getItem()#</div></td>
			<td valign="middle" <!--- width="25%" --->><div style="width:190px;">#aBidRequestProducts[prodIndx].getDesc()#</div></td>
			<td valign="middle" <!--- width="10%" --->><div style="width:60px;">
				<!---if the contract status is 8 then display lost--->
				<cfif form.contract_status eq 8 or form.bidStatusId eq 4>
					Lost
					<input name="Won_#scrubbedProdId#" type="hidden" value="0" />
					<cfset form.bidStatusId = 4 />
				<cfelse>
					<select name="Won_#scrubbedProdId#" onChange="setWonFields('#scrubbedProdId#')">
						<option value="1" <cfif bWon>selected</cfif>>Won</option>
						<option value="0" <cfif not bWon>selected</cfif>>Lost</option>
					</select>
				</cfif>
        </div>
			</td>
      
      
			<td valign="middle" <!--- width="19%" --->>
      <div style="width:145px;">
        <select name="category_id_#scrubbedProdId#" #bDisable# class="#class#" style="width:145px;">
          <option value="" title="Select a <cfoutput>#qGetCategoryLabel.General_Labels_Label#</cfoutput>">Select a <cfoutput>#qGetCategoryLabel.General_Labels_Label#</cfoutput></option>
          <cfloop query="Get_Category_Data">
            <option value="#Get_Category_Data.Program_Bid_Category_ID#" title="#Get_Category_Data.Program_Bid_Category_Description#" <cfif (aBidRequestProducts[prodIndx].getCategoryID() EQ Get_Category_Data.Program_Bid_Category_ID)>selected</cfif>>#Get_Category_Data.Program_Bid_Category_Description#</option>
          </cfloop>
        </select><br>
        <select name="package_id_#scrubbedProdId#" #bDisable# class="#class#" style="width:145px;">
          <option value="" title="Select a <cfoutput>#qGetPackageLabel.General_Labels_Label#</cfoutput>">Select a <cfoutput>#qGetPackageLabel.General_Labels_Label#</cfoutput>&nbsp;</option>
          <cfloop query="Get_Package_Data">
            <option value="#Get_Package_Data.Program_Bid_Package_ID#" value="#Get_Package_Data.Program_Bid_Package_Description#" <cfif (aBidRequestProducts[prodIndx].getPackageID() EQ Get_Package_Data.Program_Bid_Package_ID)>selected</cfif>>#Get_Package_Data.Program_Bid_Package_Description#</option>
          </cfloop>
        </select>        
        <!--- <input name="won_by_#scrubbedProdId#" type="text" #bDisable# class="#class#" value="#aBidRequestProducts[prodIndx].getWonBy()#" size="15" maxlength="20"/> --->
        </div>
     </td>
        <td valign="middle" <!--- width="15%" --->>
        <div style="width:110px;">
          <select name="won_by_id_#scrubbedProdId#" #bDisable# class="#class#" style="width:107px;">
            <option value="" title="Select a <cfoutput>#qGetWonByLabel.General_Labels_Label#</cfoutput>">Select a <cfoutput>#qGetWonByLabel.General_Labels_Label#</cfoutput></option>
            <cfloop query="Get_Won_By_Data">
              <option value="#Get_Won_By_Data.Program_Bid_Won_By_ID#" title="#Get_Won_By_Data.Program_Bid_Won_By_Description#" <cfif (aBidRequestProducts[prodIndx].getWonByID() EQ Get_Won_By_Data.Program_Bid_Won_By_ID)>selected</cfif>>#Get_Won_By_Data.Program_Bid_Won_By_Description#</option>
            </cfloop>
          </select>      
          </div>  
        </td>
			<td nowrap  valign="middle" <!---class="brdrRgt" width="6%" --->>
      <div style="width:110px;">
				<input name="won_price_#scrubbedProdId#" type="text" #bDisable# class="#class#" value="#aBidRequestProducts[prodIndx].getWonPrice()#" size="3" maxlength="9" onChange="this.value = formatToDeciamalPlaces(this.value, 2);" onKeyUp="clenseText(this, '0123456789.');" /> 
				per
				<cf_uom_dropdown
					program_id				=	"#bidRequest.getProgramId()#"
					company_main_id			=	""
					default_option_on		=	"0"
					default_option_text		=	""
					default_option_value	=	""
					dropdown_name			=	"won_uom_#scrubbedProdId#"
					option_text_abbreviated	=	"1"
					plural_uom_display		=	""
					product_type_id			=	"#bidRequest.getDiscountTypeId()#"
					program_template_id		=	""
					selected_uom_id			=	"#aBidRequestProducts[prodIndx].getWonUom()#"
					text_before_tag_close	=	"class='#class#' #bDisable#"
					uom_id_exclusion_list	=	""
					uom_id_inclusion_list	=	""
					>
          </div>
			</td>	
			<cfif appSettings.getBidRequestUsePriceByDate() EQ 0>
			<td valign="middle" class="brdrRgt"<!--- width="10%" --->>
      <div style="width:55px;">
      <select name="won_delivery_type_#scrubbedProdId#" #bDisable# class="#class#">
			<option value="1" <cfif aBidRequestProducts[prodIndx].getWonDeliveryType() EQ 1>selected</cfif>>FOB</option>
			<option value="2" <cfif aBidRequestProducts[prodIndx].getWonDeliveryType() EQ 2>selected</cfif>>DEL</option>			
			</select></td>
			</cfif>
      </div>
		</tr>
		<!---hold values in hidden form variables--->
		<input name="default_price_#scrubbedProdId#" type="hidden" value="#aBidRequestProducts[prodIndx].getDefaultPrice()#" />
		<input name="allowance_#scrubbedProdId#" type="hidden" value="#aBidRequestProducts[prodIndx].getAllowance()#" />
		
	</cfloop>
	
</table>
</div>
<br>
<b><font color="FF0000">[</font> <a href="javascript:submitForm('save');">save</a><font color="FF0000">]</font></b>&nbsp;&nbsp;
<b><font color="FF0000">[</font> <a href="javascript:window.close();">cancel</a><font color="FF0000">]</font></b>

<INPUT TYPE="Hidden" NAME="Product_List" VALUE="#form.Product_List#">
<input type="Hidden" name="Program_ID" value="#cryp.value#" />
<INPUT TYPE="Hidden" NAME="command" VALUE="#form.command#">
<input type="Hidden" name="init" value="1" />
<input type="Hidden" name="sort_by" value="#form.sort_by#" />
<input type="Hidden" name="sort_order" value="#form.sort_order#" />
<input type="Hidden" name="bidStatusId" value="#form.bidStatusId#" />
<input type="hidden" name="ThereisMinorMax" value="0">
</form>	

</body>
</html>
</cfoutput>