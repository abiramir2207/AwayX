<style>
.hdr419 { position:relative; top:8px; }
a.save { margin-left: 340px; }
</style>
<cfset qGetCustSetLabels = request.qLabels.GetCustomerSettingsLabels()>
<cfset getAllProductAttributes = request.qLabels.getAllProductAttributes()>
<cfset getAllDistributorAttributes = request.qLabels.getAllDistributorAttributes(excludeList = '1')>
<cfset getAllOperatorAttributes = request.qLabels.getAllOperatorAttributes()>
<cfset getAllDistributorStaticSearchFields = request.qLabels.getAllDistributorStaticSearchFields()>
<cfset getAllProductStaticSearchFields = request.qLabels.getAllProductStaticSearchFields()>
<cfset getAllOperatorStaticSearchFields = request.qLabels.getAllOperatorStaticSearchFields()>
<cfset getActiveTemplateOperatorLabel = request.qLabels.getActiveTemplateSettingLabel(3)>
<cfset getActiveTemplateDistributorLabel = request.qLabels.getActiveTemplateSettingLabel(2)>
<cfset getActiveTemplateProductLabel = request.qLabels.getActiveTemplateSettingLabel(1)>
 
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfset mode = "DPCSettings" />
<cfoutput>
<div id="masterContainer">
<form name="frmSettingsModify" method="post"> <!--- name="customerSettings" programLabelsModify --->
<input type="hidden" name="settingsModify" value="1">
<div>
	<a href="javascript:frmSettingsModify.submit()" class="save">#application.util.string.actionLinkFormat2("save")#</a>
</div>

<cfif isDefined("URL.updated") AND URL.updated EQ 1>
	
	<!--- RENDER APP SETTINGS TO UPDATE THE APP SETTINGS STRUCTURE AND SHOW CHANGES --->
	<cfinclude template="/settings/customer_settings/Memory_Data/Render_Files.cfm" />
	<!--- RELOAD APP SETTINGS INTO THE REQUIRED REQUEST SCOPE --->
	<cfset application.oApplicationAppSettingsManager.loadApplicationAppSettings() />
	<!--- CLEAR THE OBJECT CACHE SO THE APPLICATION CREATES NEW OBJECTS WHEN CALLED --->
	<cfobjectcache action="CLEAR">
	
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">Settings Labels updated successfully.</strong>
	</div>
</cfif>

<!--- DISTRIBUTOR SETTINGS START HERE --->
<!---//////**************************************///////--->
<!--- DISTRIBUTOR FIELDS FOR DISPLAY ON SEARCH --->
<cfset listDistributotAttForSearchResult = "Business Segment,Family,Buying Group">
<cfif appSettings.getDistributorMultiPosition() eq 0>
<!--- If above app setting is OFF, then add "broker". --->
	<CFSET listDistributotAttForSearchResult = ListAppend(listDistributotAttForSearchResult,"broker")>
</cfif>

<!--- ADDITIONAL DISTRIBUTOR FIELDS FOR DISPLAY ON SEARCH --->
<cfset listAdditionalDistributorFieldsForSearchResult = "Address">
<!---///////**************************************////////--->


<fieldset id="border_1" style="border-width:0; border-color:; border-style:solid; width:820"> 
     <legend> 
      <span title="Click here to toggle the view"> 
        <img id="image_1" src="/images/plus4.gif" onclick="switchlayer(1,'Hide Distributor Attribute Labels','Show Distributor Attribute Labels',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" border="0" alt="" style="cursor:pointer"> 
        
       <font face="Arial"> 
        <b style="font-size:10pt"> 
         <span id="title_1" onclick="switchlayer(1,'Hide Distributor Attribute Labels','Show Distributor Attribute Labels',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" style="cursor:pointer;color:Navy">
          Distributor Attribute Labels <span title="" onmouseout="popUpTip(event,'dist_Tip');" onmouseover="popUpTip(event,'dist_Tip');"><img src="/images/help_small.gif" /></span> 
          <div id="dist_Tip" class="tip">
					  <p style="margin:4px;">The column called Active in the distributor settings is a flag to indicate if the client is sending that attribute to Blacksmith.<br/><br/>  If yes, then you should make sure the attribute shows a green checkmark for this setting.  If no, then you should make sure the attribute shows a red X for this setting.<br/><br/>  Also, if the attribute has a green checkmark it means the attribute will appear in the group drop downs as a selection.</p>
      		</div>
          </span> 
        </b> 
       </font> 
      
     </legend> 
    <div id="lyrgroup_1" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 

<div id="masterContainer">
	<input type="hidden" name="DistributorLabelsModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainer" style="width:140px;" class="hdr419">Default Label</div>
		<div id="innerHeaderContainer" style="width:140px" class="hdr419">Client Label</div>
    		<div id="innerHeaderContainer" style="width:140px;" class="hdr419">Plural</div>
    		<div id="innerHeaderContainer" style="width:55px;text-align:center;" class="hdr419">Active?</div>
		<div id="innerHeaderContainer" style="width:170px;text-align:center;">
			<cfset DisplayOtherSearch('distributor')>
		</div>
		<div id="innerHeaderContainer" style="width:65px;" class="hdr419">Order</div>
		<div id="innerHeaderContainer" style="width:80px;">Display in <br>Results List</div>
	</div>
	<cfset rowCounter = 0>
	
	<!--- FIELD DISPLAY STARTS--->
	<cfloop query="getAllDistributorAttributes"><!--- <cfloop query="getAll#mode#Attributes"> --->
		<!---31409 - Display all rows except Market, Region, Zone which will be moved down to the lower section--->
		<cfif NOT (getAllDistributorAttributes.Distributor_group_level_id gte 23 and getAllDistributorAttributes.Distributor_group_level_id lte 26)>
			<cfset DisplayDistributorField()>
		</cfif>
	</cfloop>
	<!--- FIELD DISPLAY ENDS --->

	<!--- ADDITIONAL FIELDS DISPLAY STARTS --->
	<cfset DisplayAdditionalField('distributor',listAdditionalDistributorFieldsForSearchResult)>

	<!---31409 - Moved Market, Region, Zone,(If applicable,then broker) down to this lower section--->
	<cfloop query="getAllDistributorAttributes">
		<cfif (getAllDistributorAttributes.Distributor_group_level_id gte 23 and getAllDistributorAttributes.Distributor_group_level_id lte 26)>
			<cfset DisplayDistributorField()>
		</cfif>
	</cfloop>

<!--- START: 29392/Anand Rao/05-Dec-2011 --->
<cfloop query="getAllDistributorStaticSearchFields">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		
		<!--- check whether an option to show/hide "display in Results List" be provided for this entry --->
		<cfset displayAdditionalOnDistributorSearchResults = 0>
		<cfif ListFindNocase(listAdditionalDistributorFieldsForSearchResult,getAllDistributorStaticSearchFields.Field_Name) neq 0>
			<cfset displayAdditionalOnDistributorSearchResults = 1>
		</cfif>

		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:140px">
			 <!--- Default Label Column ---> 
      	#getAllDistributorStaticSearchFields.Field_Name#
			</div>
		  	<div id="innerBodyContainer" style="width:140px">
		  	</div>
		  	<div id="innerBodyContainer" style="width:140px">
			</div>
			<div id="innerBodyContainer" nowrap style="width:55px;text-align:center;" > 
         	
			 
        </div>  
	<cfif displayAdditionalOnDistributorSearchResults eq 0>
        <!--- Field in Distributor Search Column --->
			<div id="innerBodyContainer" nowrap
					style="width:170px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgYes = $('imgYes#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#');
								var imgNo = $('imgNo#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#');
								var boxStaticDist = $('boxStaticDist#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#');
								if (imgYes.style.display == 'none') {
									imgYes.style.display='block';
									imgNo.style.display='none';
									boxStaticDist.checked=true;
								} else {
									imgYes.style.display='none';
									imgNo.style.display='block';
									boxStaticDist.checked=false;
								}
							">
					<cfif evaluate("getAllDistributorStaticSearchFields.Display_In_Search")>
						<img id="imgYes#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgYes#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxStaticDist#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#"
							type="checkbox"
							value="1"
							name="boxStaticDist#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#"
							style="display:none;"
							<cfif evaluate("getAllDistributorStaticSearchFields.Display_In_Search")>
								CHECKED
							</cfif>
							>
			</div>
			<!---- List Order Column --->
			<div id="innerBodyContainer" style="width:65px">
				<input type="text" onkeyup="modified();clenseText(this, '0123456789');" name="DistListOrder#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" value="#evaluate('getAllDistributorStaticSearchFields.List_order')#" size="5">
			</div>
	 <cfelse>
			<div id="innerBodyContainer" nowrap style="width:170px;text-align:center;">
				<input type="hidden" id="boxStaticDist#rowCounter#" name="boxStaticDist#rowCounter#" value="0">
				N/A
			</div>
			<div id="innerBodyContainer" style="width:65px">
				<input type="hidden" name="DistListOrder#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" value="0">
				N/A
			</div>
	</cfif>
	<!--- "Display in results list" column --->
	<cfif displayAdditionalOnDistributorSearchResults eq 1>
			<div id="innerBodyContainer" nowrap
					style="width:20px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgDisplayAdditionalDistSearchYes = $('imgDisplayAdditionalDistSearchYes#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#');
								var imgDisplayAdditionalDistSearchNo = $('imgDisplayAdditionalDistSearchNo#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#');
								var boxDisplayAdditionalDistSearch = $('boxDisplayAdditionalDistSearch#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#');
								if (imgDisplayAdditionalDistSearchYes.style.display == 'none') {
									imgDisplayAdditionalDistSearchYes.style.display='block';
									imgDisplayAdditionalDistSearchNo.style.display='none';
									boxDisplayAdditionalDistSearch.checked=true;
								} else {
									imgDisplayAdditionalDistSearchYes.style.display='none';
									imgDisplayAdditionalDistSearchNo.style.display='block';
									boxDisplayAdditionalDistSearch.checked=false;
								}
							">
					<cfif evaluate("getAllDistributorStaticSearchFields.Display_In_Search_Results")>
						<img id="imgDisplayAdditionalDistSearchYes#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgDisplayAdditionalDistSearchNo#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgDisplayAdditionalDistSearchYes#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgDisplayAdditionalDistSearchNo#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxDisplayAdditionalDistSearch#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#"
							type="checkbox"
							value="1"
							name="boxDisplayAdditionalDistSearch#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#"
							style="display:none;"
							<cfif evaluate("getAllDistributorStaticSearchFields.Display_In_Search_Results")>
								CHECKED
							</cfif>
							>
  			</div>
	<cfelse>
			<div id="innerBodyContainer" style="width:40px;text-align:center;">
				<input type="hidden" name="boxDisplayAdditionalDistSearch#rowCounter#_#getAllDistributorStaticSearchFields.Search_Settings_ID#" value="0">				
			</div>
	</cfif>
      </div>
	</cfloop>
	<!--- ADDITIONAL FIELDS DISPLAY ENDS --->
</div>			
<!--- END: 29392/Anand Rao/05-Dec-2011 --->

</div> <!--- Hide/Show DIV ENDS --->  

</fieldset>
<!--- DISTRIBUTOR SETTINGS END HERE --->
<br>
<!--- PRODUCT SETTINGS START HERE --->
<cfset listProductAttForSearchResult = "">

<!------ Type Group ----->
<cfset RemoveTypeGroup = 1>
<cfif application.returned_customer_setting.type_group_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_group_show_column EQ 1><cfset RemoveTypeGroup = 0></cfif></cfif>
<cfif appSettings.getUseProductGroup3() NEQ 1>
	<cfset RemoveTypeGroup = 1>
</cfif>

<!------ Type Code ----->
<cfset RemoveTypeCode = 1>
<cfif application.returned_customer_setting.type_code_show_column NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.type_code_show_column EQ 1><cfset RemoveTypeCode = 0></cfif></cfif>
<cfif appSettings.getUseProductGroup4() NEQ 1>
	<cfset RemoveTypeCode = 1>
</cfif>

<!---//////**************************************///////--->
<!--- PRODUCT FIELDS FOR DISPLAY ON SEARCH --->

<!--- If "Type Group" is ON, add "Type Group' to the list. --->
<cfif RemoveTypeGroup eq 0>
	<cfset listProductAttForSearchResult = ListAppend(listProductAttForSearchResult,"Type Group")>
</cfif>

<!--- If "Type Code" is ON, add "Type Code' to the list. --->
<cfif RemoveTypeCode eq 0>
	<cfset listProductAttForSearchResult = ListAppend(listProductAttForSearchResult,"Type Code")>
</cfif>

<!--- Brand --->
<cfif appSettings.getUseProductGroup1()>
	<cfset listProductAttForSearchResult = ListAppend(listProductAttForSearchResult,"Brand")>
</cfif>

<!--- Business Segment --->
<cfset isBusinessSegEnabledForProduct = businessSegManager.isEnabledForProduct() />

<cfif isBusinessSegEnabledForProduct>
	<cfset listProductAttForSearchResult = ListAppend(listProductAttForSearchResult,"Business Segment")>
</cfif>

<!--- Class Code --->
<!---
<cfif appSettings.getClassCodesOn() AND isBusinessSegEnabledForProduct>
	<cfset listProductAttForSearchResult = ListAppend(listProductAttForSearchResult,"Class Code")>
</cfif>
--->


<!--- ADDITIONAL PRODUCT FIELDS FOR DISPLAY ON SEARCH --->
<cfset listAdditionalProductFieldsForSearchResult = "">

<!--- UPC --->
<cfset RemoveUPC= 1>
<cfif application.returned_customer_setting.type_code_show_column NEQ application.returned_customer_setting.customer_setting_error_string>
	<cfif application.returned_customer_setting.type_code_show_column EQ 1>
		<cfset RemoveUPC= 0>
	</cfif>
</cfif>

<!--- If UPC is ON, add "UPC' to the list. --->
<cfif RemoveUPC eq 0>
	<cfset listAdditionalProductFieldsForSearchResult = ListAppend(listAdditionalProductFieldsForSearchResult,"UPC")>
</cfif>

<!--- "Display in Search results" is applicable for "Hierarchy". Other columns are not. --->
<cfset listAdditionalProductFieldsForSearchResult = ListAppend(listAdditionalProductFieldsForSearchResult,"Hierarchy")>

<fieldset id="border_2" style="border-width:0; border-color:; border-style:solid; width:820"> 
     <legend> 
      <span title="Click here to toggle the view"> 
        <img id="image_2" src="/images/plus4.gif" onclick="switchlayer(2,'Hide Product Attribute Labels','Show Product Attribute Labels',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" border="0" title="" style="cursor:pointer"> 
        
       <font face="Arial"> 
        <b style="font-size:10pt"> 
         <span id="title_2" onclick="switchlayer(2,'Hide Product Attribute Labels','Show Product Attribute Labels',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" style="cursor:pointer;color:Navy">
          Product Attribute Labels <span title="" onmouseout="popUpTip(event,'prod_Tip');" onmouseover="popUpTip(event,'prod_Tip');"><img src="/images/help_small.gif" /></span> 
          <div id="prod_Tip" class="tip">
            <p style="margin:4px;">The column called Active in the product settings is a flag to indicate if the client is sending that attribute to Blacksmith.<br/><br/>  If yes, then you should make sure the attribute shows a green checkmark for this setting.  If no, then you should make sure the attribute shows a red X for this setting.<br/><br/>  Also, if the attribute has a green checkmark it means the attribute will appear in the group drop downs as a selection.</p>
      		</div>
        </span> 
        </b> 
       </font> 
      </span> 
     </legend> 
    <div id="lyrgroup_2" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">

<div id="masterContainer">
	<input type="hidden" name="sModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainer" style="width:140px" class="hdr419">Default Label</div>
		<div id="innerHeaderContainer" style="width:140px" class="hdr419">Client Label</div>
		<div id="innerHeaderContainer"style="width:140px;" class="hdr419">Plural</div>
		<div id="innerHeaderContainer" style="width:55px;text-align:center;" class="hdr419">Active?</div>
		<div id="innerHeaderContainer" style="width:170px;text-align:center;">
			<cfset DisplayOtherSearch('product')>
		</div>
		<div id="innerHeaderContainer" style="width:65px;" class="hdr419">Order</div>
		<div id="innerHeaderContainer" style="width:80px;">Display in <br>Results List</div>
	</div>	
	<cfset rowCounter = 0>

	<cfloop query="getAllProductAttributes">
	<cfset rowCounter = rowCounter + 1>
		<cfset ProductLabelTemplate = 0>
		<cfloop query="getActiveTemplateProductLabel">
			<cfif getAllProductAttributes.Product_group_level_id EQ getActiveTemplateProductLabel.GROUP_LEVEL_ID>
				<cfset ProductLabelTemplate = #getAllProductAttributes.Product_group_level_id# />
			</cfif>
		</cfloop>
		<!--- check whether an option to show/hide "display in Results List" be provided for this entry --->
		<cfset displayOnProductSearchResults = 0>
		<cfif ListFindNocase(listProductAttForSearchResult,getAllProductAttributes.Group_Internal_Label) neq 0>
			<cfset displayOnProductSearchResults = 1>
		</cfif>
		<input type="hidden" name="prodID#rowCounter#" value="#evaluate('getAllProductAttributes.Product_group_level_id')#">
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>

		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:140px">
        <!--- Default Label Column--->
				#evaluate("getAllProductAttributes.group_internal_label")#
				<input type="hidden" name="BALabelProd#rowCounter#" value="#evaluate('getAllProductAttributes.group_internal_label')#">
			</div>
      <!--- Client Label Column --->
			<div id="innerBodyContainer" style="width:140px">
				<input type="text" onkeyup="modified();" name="ProductLabel#rowCounter#" value="#evaluate('getAllProductAttributes.group_level_desc')#" size="20">
			</div>

      <!--- Plural Column --->
      <!----------------------------------------------------------------------------- 
        Dev Notes: D18971 
          I am passing the hidden fields below to update the singular fields 
          that were left out from the customer_settings table in case the code 
          is referring to these columns somewhere.
          -Anand Rao/14-May-09      
      ------------------------------------------------------------------------------>
      <div id="innerBodyContainer" style="width:140px">
        <cfif getAllProductAttributes.Product_Group_Level_ID EQ 8> <!--- id = 8 is for the Type Group Label --->
          <input type="text" onkeyup="modified();" name="type_group_label_plural" value="#evaluate('qGetCustSetLabels.type_group_label_plural')#" size="20">
          <input type="hidden" name="type_group_label_singular_field" value="ProductLabel#rowCounter#"/>
        <cfelseif getAllProductAttributes.Product_Group_Level_ID EQ 11> <!--- id = 11 is for the qBrand Label --->
         <input type="text" onkeyup="modified();" name="q_brand_label_plural" value="#evaluate('qGetCustSetLabels.q_brand_label_plural')#" size="20">
         <input type="hidden" name="q_brand_label_singular_field" value="ProductLabel#rowCounter#"/>
        <cfelseif getAllProductAttributes.Product_Group_Level_ID EQ 12> <!--- id = 12 is for the Type Code Label --->
         <input type="text" onkeyup="modified();" name="type_code_label_plural" value="#evaluate('qGetCustSetLabels.type_code_label_plural')#" size="20">
         <input type="hidden" name="type_code_label_singular_field" value="ProductLabel#rowCounter#"/>
        <cfelse>
        &nbsp;&nbsp;&nbsp; 
        </cfif>
      </div>
     
      <!--- Active Column ---> 			
      <div id="innerBodyContainer" nowrap style="width:55px;text-align:center;"
        onMouseOver="this.style.cursor='pointer';"
				onMouseOut="this.style.cursor='';"
        onClick="
								modified();
								var imgProdActive = $('imgProdActive#rowCounter#');
								var imgProdInActive = $('imgProdInActive#rowCounter#');
								var boxProdActive = $('boxProdActive#rowCounter#');
								if (imgProdActive.style.display == 'none') {
									imgProdActive.style.display='block';
									imgProdInActive.style.display='none';
									boxProdActive.checked=true;
								} else {
									if(#ProductLabelTemplate# == #Product_group_level_id#) {
var newWin = window.open('app_settings_label_settings_validation.cfm?GROUP_LEVEL_ID=#Product_group_level_id#&PGGroupType=1','mywindow','width=800,height=600,scrollbars=yes,resizable=yes'); 
									newWin.focus();
									return false;
									}
									else {
									imgProdActive.style.display='none';
									imgProdInActive.style.display='block';
									boxProdActive.checked=false;
									}
								}
        "> 
          <cfif evaluate("getAllProductAttributes.Active")>
						<img id="imgProdActive#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgProdInActive#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgProdActive#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgProdInActive#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxProdActive#rowCounter#"
							type="checkbox"
							value="1"
							name="boxProdActive#rowCounter#"
							style="display:none;"
							<cfif evaluate("getAllProductAttributes.Active")>
								CHECKED
							</cfif>
							>
        </div> 
    
        
        <div id="innerBodyContainer" nowrap
					style="width:170px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgProdYes = $('imgProdYes#rowCounter#');
								var imgProdNo = $('imgProdNo#rowCounter#');
								var boxProd = $('boxProd#rowCounter#');
								if (imgProdYes.style.display == 'none') {
									imgProdYes.style.display='block';
									imgProdNo.style.display='none';
									boxProd.checked=true;
								} else {
									imgProdYes.style.display='none';
									imgProdNo.style.display='block';
									boxProd.checked=false;
								}
							">
					<cfif evaluate("getAllProductAttributes.search_filter_on")>
						<img id="imgProdYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgProdNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgProdYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgProdNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
						<input id="boxProd#rowCounter#"
							type="checkbox"
							value="1"
							name="boxProd#rowCounter#"
							style="display:none;"
							<cfif evaluate("getAllProductAttributes.search_filter_on")>
								CHECKED
							</cfif>>
				</div>
				<div id="innerBodyContainer" style="width:65px">
					<input type="text" onkeyup="modified();" name="ProductListOrder#rowCounter#" value="#evaluate('getAllProductAttributes.List_Order')#" size="5">
				</div>	
		<!--- "Display in results list" column --->		
		<cfif displayOnProductSearchResults eq 1>
		<div id="innerBodyContainer" nowrap
						style="width:40px;text-align:center;"
						onMouseOver="this.style.cursor='pointer';"
						onMouseOut="this.style.cursor='';"
						onClick="
									modified();
									var imgDisplayProdSearchYes = $('imgDisplayProdSearchYes#rowCounter#');
									var imgDisplayProdSearchNo = $('imgDisplayProdSearchNo#rowCounter#');
									var boxDisplayProdSearch = $('boxDisplayProdSearch#rowCounter#');
									if (imgDisplayProdSearchYes.style.display == 'none') {
										imgDisplayProdSearchYes.style.display='block';
										imgDisplayProdSearchNo.style.display='none';
										boxDisplayProdSearch.checked=true;
									} else {
										imgDisplayProdSearchYes.style.display='none';
										imgDisplayProdSearchNo.style.display='block';
										boxDisplayProdSearch.checked=false;
									}
								">
						<cfif evaluate("getAllProductAttributes.Display_In_Search_Results")>
							<img id="imgDisplayProdSearchYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
							<img id="imgDisplayProdSearchNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
						<cfelse>
							<img id="imgDisplayProdSearchYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
							<img id="imgDisplayProdSearchNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
						</cfif>

						<input id="boxDisplayProdSearch#rowCounter#"
								type="checkbox"
								value="1"
								name="boxDisplayProdSearch#rowCounter#"
								style="display:none;"
								<cfif evaluate("getAllProductAttributes.Display_In_Search_Results")>
									CHECKED
								</cfif>
						>
		</div>
		 <cfelse>
			<div id="innerBodyContainer" nowrap style="width:40px;text-align:center;">
				<input type="hidden" id="boxDisplayProdSearch#rowCounter#" name="boxDisplayProdSearch#rowCounter#" value="0">
			</div>

		</cfif>
		</div>
	</cfloop>

	<cfset DisplayAdditionalField('product',listAdditionalProductFieldsForSearchResult)>

	<cfloop query="getAllProductStaticSearchFields">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<!--- check whether an option to show/hide "display in Results List" be provided for this entry --->
		<cfset displayAdditionalOnProductSearchResults = 0>
		<cfif ListFindNocase(listAdditionalProductFieldsForSearchResult,getAllProductStaticSearchFields.Field_Name) neq 0>
			<cfset displayAdditionalOnProductSearchResults = 1>
		</cfif>		

		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:140px">
				<!--- Default Label Column--->
				#getAllProductStaticSearchFields.Field_Name#
				<!--- <input type="hidden" name="BALabelProd#rowCounter#" value="#getAllProductStaticSearchFields.Search_Settings_ID#"> --->
			</div>
			<div id="innerBodyContainer" style="width:140px">
			</div>
		  	<div id="innerBodyContainer" style="width:140px">
			</div>
	 		<div id="innerBodyContainer" nowrap style="width:55px;text-align:center;">
			</div> 
	   <cfif displayAdditionalOnProductSearchResults eq 0>
			<div id="innerBodyContainer" nowrap
					style="width:170px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgProdYes = $('imgProdYes#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#');
								var imgProdNo = $('imgProdNo#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#');
								var boxStaticProd = $('boxStaticProd#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#');
								if (imgProdYes.style.display == 'none') {
									imgProdYes.style.display='block';
									imgProdNo.style.display='none';
									boxStaticProd.checked=true;
								} else {
									imgProdYes.style.display='none';
									imgProdNo.style.display='block';
									boxStaticProd.checked=false;
								}
							">
					<cfif evaluate("getAllProductStaticSearchFields.Display_In_Search")>
						<img id="imgProdYes#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgProdNo#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgProdYes#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgProdNo#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxStaticProd#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#"
							type="checkbox"
							value="1"
							name="boxStaticProd#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#"
							style="display:none;"
							<cfif evaluate("getAllProductStaticSearchFields.Display_In_Search")>
								CHECKED
							</cfif>>
			</div>
			<div id="innerBodyContainer" style="width:65px">
				<input type="text" onkeyup="modified();" name="ProdListOrder#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" value="#getAllProductStaticSearchFields.List_Order#" size="5">
			</div>		
	 <cfelse>
			<div id="innerBodyContainer" nowrap style="width:170px;text-align:center;">
				<input type="hidden" id="boxStaticProd#rowCounter#" name="boxStaticProd#rowCounter#" value="0">
				N/A
			</div>
			<div id="innerBodyContainer" style="width:65px">
				<input type="hidden" name="ProdListOrder#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" value="0">
				N/A
			</div>
	</cfif>
	<!--- "Display in results list" column --->
	<cfif displayAdditionalOnProductSearchResults eq 1>
			<div id="innerBodyContainer" nowrap
							style="width:40px;text-align:center;"
							onMouseOver="this.style.cursor='pointer';"
							onMouseOut="this.style.cursor='';"
							onClick="
										modified();
										var imgDisplayAdditionalProdSearchYes = $('imgDisplayAdditionalProdSearchYes#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#');
										var imgDisplayAdditionalProdSearchNo = $('imgDisplayAdditionalProdSearchNo#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#');
										var boxDisplayAdditionalProdSearch = $('boxDisplayAdditionalProdSearch#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#');
										if (imgDisplayAdditionalProdSearchYes.style.display == 'none') {
											imgDisplayAdditionalProdSearchYes.style.display='block';
											imgDisplayAdditionalProdSearchNo.style.display='none';
											boxDisplayAdditionalProdSearch.checked=true;
										} else {
											imgDisplayAdditionalProdSearchYes.style.display='none';
											imgDisplayAdditionalProdSearchNo.style.display='block';
											boxDisplayAdditionalProdSearch.checked=false;
										}
									">
							<cfif evaluate("getAllProductStaticSearchFields.Display_In_Search_Results")>
								<img id="imgDisplayAdditionalProdSearchYes#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive"/>
								<img id="imgDisplayAdditionalProdSearchNo#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
							<cfelse>
								<img id="imgDisplayAdditionalProdSearchYes#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
								<img id="imgDisplayAdditionalProdSearchNo#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active"/>
							</cfif>

							<input id="boxDisplayAdditionalProdSearch#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#"
									type="checkbox"
									value="1"
									name="boxDisplayAdditionalProdSearch#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#"
									style="display:none;"
									<cfif evaluate("getAllProductStaticSearchFields.Display_In_Search_Results")>
										CHECKED
									</cfif>>		
			</div>
	<cfelse>
			<div id="innerBodyContainer" style="width:40px;text-align:center;">
				<input type="hidden" name="boxDisplayAdditionalProdSearch#rowCounter#_#getAllProductStaticSearchFields.Search_Settings_ID#" value="0">
			</div>
	</cfif>

      </div>

	 

	</cfloop> 

</div>
 

</div> <!--- Show/Hide DIV Tag Ends --->

</fieldset>
<!--- PRODUCT SETTINGS END HERE --->
<br>
<!--- OPERATOR SETTINGS START HERE --->

<!---//////**************************************///////--->
<!--- DISTRIBUTOR ADDITIONAL FIELDS FOR DISPLAY ON SEARCH --->
<cfset listAdditionalOperatorFieldsForSearchResult = "BSA Operator ID,City,State,Location Type,List Programs">

<cfif appSettings.getShowBSAOperators() EQ 1>
	<cfset listAdditionalOperatorFieldsForSearchResult = ListAppend(listAdditionalOperatorFieldsForSearchResult,"BSA Operator ID")>
</cfif>

<cfif application.returned_customer_setting.Business_Segments_On eq 1>
	<cfset listAdditionalOperatorFieldsForSearchResult = ListAppend(listAdditionalOperatorFieldsForSearchResult,"Business Segment")>
</cfif>

<!--- START: 29392/Anand Rao/05-Dec-2011 --->
<fieldset id="border_4" style="border-width:0; border-color:; border-style:solid; width:820"> 
     <legend> 
      <span title="Click here to toggle the view"> 
        <img id="image_4" src="/images/plus4.gif" onclick="switchlayer(4,'Hide Operator Search Fields','Show Operator Search Fields',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" border="0" title="" style="cursor:pointer"> 
        
       <font face="Arial"> 
        <b style="font-size:10pt"> 
         <span id="title_4"  onclick="switchlayer(4,'Hide Operator Search Fields','Show Operator Search Fields',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" style="cursor:pointer;color:Navy">
          <span>
			      Operator Attribute Labels 
          </span> 
          </span> 
        </b> 
       </font> 
      
     </legend> 
    <div id="lyrgroup_4" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 

<div id="masterContainer">
	<input type="hidden" name="OperatorLabelsModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainer" style="width:140px">Default Label</div>
		<div id="innerHeaderContainer" style="width:140px">Client Label</div>
		<div id="innerHeaderContainer"style="width:140px;">&nbsp;</div>
		<div id="innerHeaderContainer" style="width:55px;text-align:center;">Active?</div>
		<div id="innerHeaderContainer" style="width:170px;text-align:center;">
			<cfset DisplayOtherSearch('operator')>
		</div>
		<div id="innerHeaderContainer" style="width:65px;text-align:center;">Order</div>	
		
	</div>
	<cfset rowCounterOpr = 1000>
 <!--- START: D30185:Label Settings, PG and Operator Search Tool/Anand Rao/26-Jan-2012 --->
	<cfloop query="getAllOperatorAttributes"><!--- <cfloop query="getAll#mode#Attributes"> --->
	<cfset rowCounterOpr = rowCounterOpr + 1>
		<cfset OperatorLabelTemplate = 0>
		<cfloop query="getActiveTemplateOperatorLabel">
			<cfif getAllOperatorAttributes.Operator_group_level_id EQ getActiveTemplateOperatorLabel.GROUP_LEVEL_ID>
				<cfset OperatorLabelTemplate = #getAllOperatorAttributes.Operator_group_level_id# />
			</cfif>
		</cfloop>
		<input type="hidden" name="OprID#rowCounterOpr#" value="#evaluate('getAllOperatorAttributes.Operator_group_level_id')#">
		<cfif rowCounterOpr MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:140px">
			 <!--- Default Label Column ---> 
      	#evaluate("getAllOperatorAttributes.group_level_desc_internal")#
				<input type="hidden" name="BALabelOpr#rowCounterOpr#" value="#evaluate('getAllOperatorAttributes.group_level_desc_internal')#">
			</div>
			  
      <!---- Client Label Column --->
      <div id="innerBodyContainer" style="width:140px">
				<input type="text" onkeyup="modified();" name="OprLabel#rowCounterOpr#" value="#evaluate('getAllOperatorAttributes.group_level_desc')#" size="20">
			</div>
      
      <!--- Plural Column --->
      <div id="innerBodyContainer" style="width:140px">&nbsp;</div>
      <!--- <div id="innerBodyContainer" style="width:140px">
         <cfif getAllOperatorAttributes.Operator_Group_Level_ID EQ 2> <!--- id = 2 is for the Family Name Label --->
          <input type="text" onkeyup="modified();" name="FamilyName_label_plural" value="#evaluate('qGetCustSetLabels.FamilyName_label_plural')#" size="20">
            <input type="hidden" name="FamilyName_label_field" value="OprLabel#rowCounterOpr#"/>
        <cfelseif getAllOperatorAttributes.Oprributor_Group_Level_ID EQ 3> <!--- id = 3 is for the Buying Group Label --->
         <input type="text" onkeyup="modified();" name="buying_group_label_plural" value="#evaluate('qGetCustSetLabels.buying_group_label_plural')#" size="20">
         <input type="hidden" name="buying_group_label_singular_field" value="OprLabel#rowCounterOpr#"/>
        <cfelse>
        &nbsp;&nbsp;&nbsp; 
        </cfif> 
		&nbsp;&nbsp;&nbsp; 
      </div> --->
<!--- 	  <div id="innerBodyContainer" style="width:100px">
	  &nbsp;&nbsp;&nbsp; 
      </div> --->
     
      <!--- Active Column --->  
     <div id="innerBodyContainer" nowrap style="width:55px;text-align:center;"
        onMouseOver="this.style.cursor='pointer';"
				onMouseOut="this.style.cursor='';"
        onClick="
								modified();
								var imgActive = $('imgActive#rowCounterOpr#');
								var imgInActive = $('imgInActive#rowCounterOpr#');
								var boxOprActive = $('boxOprActive#rowCounterOpr#');
								if (imgActive.style.display == 'none') {
									imgActive.style.display='block';
									imgInActive.style.display='none';
									boxOprActive.checked=true;
								} else {
									if(#OperatorLabelTemplate# == #Operator_group_level_id#) {
var newWin = window.open('app_settings_label_settings_validation.cfm?GROUP_LEVEL_ID=#Operator_group_level_id#&PGGroupType=3','mywindow','width=800,height=600,scrollbars=yes,resizable=yes'); 
									newWin.focus();
									return false;
									}
									else {
									imgActive.style.display='none';
									imgInActive.style.display='block';
									boxOprActive.checked=false;
									}
								}
        "> 
          <cfif evaluate("getAllOperatorAttributes.Active")>
						<img id="imgActive#rowCounterOpr#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgInActive#rowCounterOpr#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgActive#rowCounterOpr#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgInActive#rowCounterOpr#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxOprActive#rowCounterOpr#"
							type="checkbox"
							value="1"
							name="boxOprActive#rowCounterOpr#"
							style="display:none;"
							<cfif evaluate("getAllOperatorAttributes.Active")>
								CHECKED
							</cfif>
							>
        </div>      
        <!--- Field in Operator Search Column --->
				<div id="innerBodyContainer" nowrap
					style="width:170px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgYes = $('imgYes#rowCounterOpr#');
								var imgNo = $('imgNo#rowCounterOpr#');
								var boxOpr = $('boxOpr#rowCounterOpr#');
								if (imgYes.style.display == 'none') {
									imgYes.style.display='block';
									imgNo.style.display='none';
									boxOpr.checked=true;
								} else {
									imgYes.style.display='none';
									imgNo.style.display='block';
									boxOpr.checked=false;
								}
							">
					<cfif evaluate("getAllOperatorAttributes.search_filter_on")>
						<img id="imgYes#rowCounterOpr#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#rowCounterOpr#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgYes#rowCounterOpr#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#rowCounterOpr#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxOpr#rowCounterOpr#"
							type="checkbox"
							value="1"
							name="boxOpr#rowCounterOpr#"
							style="display:none;"
							<cfif evaluate("getAllOperatorAttributes.search_filter_on")>
								CHECKED
							</cfif>
							>
  			</div>
			<!---- List Order Column --->
      			<div id="innerBodyContainer" style="width:55px;text-align:center;">
				<input type="text" onkeyup="modified();clenseText(this, '0123456789');" name="OprListOrder#rowCounterOpr#" value="#evaluate('getAllOperatorAttributes.List_order')#" size="5">
			</div>
      </div>
	</cfloop>
 
 <!--- END: D30185:Label Settings, PG and Operator Search Tool/Anand Rao/26-Jan-2012 --->
 
<cfset DisplayAdditionalField('operator',listAdditionalOperatorFieldsForSearchResult)>

<cfloop query="getAllOperatorStaticSearchFields">
		<cfset rowCounterOpr = rowCounterOpr + 1>
		<cfif rowCounterOpr MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<!--- check whether an option to show/hide "display in Results List" be provided for this entry --->
		<cfset displayAdditionalOnOperatorSearchResults = 0>
		<cfif ListFindNocase(listAdditionalOperatorFieldsForSearchResult,getAllOperatorStaticSearchFields.Field_Name) neq 0>
			<cfset displayAdditionalOnOperatorSearchResults = 1>
		</cfif>	

		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:140px">
			 <!--- Default Label Column ---> 
			#getAllOperatorStaticSearchFields.Field_Name#
			</div>

			<div id="innerBodyContainer" style="width:375px"></div>
			<cfif displayAdditionalOnOperatorSearchResults eq 0>
				<div id="innerBodyContainer" nowrap
					style="width:90px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgYes = $('imgYes#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#');
								var imgNo = $('imgNo#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#');
								var boxStaticOpr = $('boxStaticOpr#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#');
								if (imgYes.style.display == 'none') {
									imgYes.style.display='block';
									imgNo.style.display='none';
									boxStaticOpr.checked=true;
								} else {
									imgYes.style.display='none';
									imgNo.style.display='block';
									boxStaticOpr.checked=false;
								}
							">
					<cfif evaluate("getAllOperatorStaticSearchFields.Display_In_Search")>
						<img id="imgYes#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgYes#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxStaticOpr#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#"
							type="checkbox"
							value="1"
							name="boxStaticOpr#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#"
							style="display:none;"
							<cfif evaluate("getAllOperatorStaticSearchFields.Display_In_Search")>
								CHECKED
							</cfif>
							>
  				</div>
			<!---- List Order Column --->
      			<div id="innerBodyContainer" style="width:75px;text-align:center;margin-left:20px;">
				<input type="text" onkeyup="modified();clenseText(this, '0123456789');" name="OprListOrder#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" value="#getAllOperatorStaticSearchFields.List_order#" size="5">
				</div>
			<cfelse>
			<div id="innerBodyContainer" nowrap style="width:90px;text-align:center;">
				<input type="hidden" id="boxStaticOpr#rowCounterOpr#" name="boxStaticOpr#rowCounterOpr#" value="0">
				N/A
			</div>
			<div id="innerBodyContainer" style="width:75px;text-align:center;margin-left:20px;">
				<input type="hidden" name="OprListOrder#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" value="0">
				N/A
			</div>
			</cfif>
			<!--- "Display in results list" column --->
			<cfif displayAdditionalOnOperatorSearchResults eq 1>
				<div id="innerBodyContainer" nowrap
					style="width:40px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgDisplayAdditionalOprSearchYes = $('imgDisplayAdditionalOprSearchYes#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#');
								var imgDisplayAdditionalOprSearchNo = $('imgDisplayAdditionalOprSearchNo#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#');
								var boxDisplayAdditionalOprSearch = $('boxDisplayAdditionalOprSearch#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#');
								if (imgDisplayAdditionalOprSearchYes.style.display == 'none') {
									imgDisplayAdditionalOprSearchYes.style.display='block';
									imgDisplayAdditionalOprSearchNo.style.display='none';
									boxDisplayAdditionalOprSearch.checked=true;
								} else {
									imgDisplayAdditionalOprSearchYes.style.display='none';
									imgDisplayAdditionalOprSearchNo.style.display='block';
									boxDisplayAdditionalOprSearch.checked=false;
								}
							">
					<cfif evaluate("getAllOperatorStaticSearchFields.Display_In_Search_Results")>
						<img id="imgDisplayAdditionalOprSearchYes#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgDisplayAdditionalOprSearchNo#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgDisplayAdditionalOprSearchYes#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgDisplayAdditionalOprSearchNo#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxDisplayAdditionalOprSearch#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#"
							type="checkbox"
							value="1"
							name="boxDisplayAdditionalOprSearch#rowCounterOpr#_#getAllOperatorStaticSearchFields.Search_Settings_ID#"
							style="display:none;"
							<cfif evaluate("getAllOperatorStaticSearchFields.Display_In_Search_Results")>
								CHECKED
							</cfif>>
  				</div>
			<cfelse>

				<div id="innerBodyContainer" style="width:40px;text-align:center;">
					<input type="hidden" name="boxDisplayAdditionalOprSearch#rowCounter#_#getAllOperatorStaticSearchFields.Search_Settings_ID#" value="0">
				</div>

			</cfif>
      </div>	
</cfloop>
</div>			

</div><!--- END: 29392/Anand Rao/05-Dec-2011 --->

</fieldset>
<!--- OPERATOR SETTINGS END HERE --->
<br>

<!---- CUSTOMER SETTINGS START HERE --->

  <fieldset id="border_3" style="border-width:0; border-color:; border-style:solid; width:820"> 
     <legend> 
      <span title="Click here to toggle the view"> 
        <img id="image_3" src="/images/plus4.gif" onclick="switchlayer(3,'Hide Customer Settings ','Show Customer Settings ',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" border="0" title="" style="cursor:pointer"> 
        
       <font face="Arial"> 
        <b style="font-size:10pt"> 
         <span id="title_3" onclick="switchlayer(3,'Hide Customer Settings ','Show Customer Settings ',0,'/images/minus4.gif','/images/plus4.gif','Navy','Navy')" style="cursor:pointer;color:Navy">
           Customer Settings  
        </span> 
        </b> 
       </font> 
      </span> 
     </legend> 
    <div id="lyrgroup_3" style="display:none; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;">

	<div id="headerContainer">
		<div id="innerHeaderContainer" style="width:300px;">Column Name 555</div>
		<div id="innerHeaderContainer">Label</div>
		<div id="innerHeaderContainerSM"></div>
	</div>
	<cfset rowCounter = 0>
  
    <!-------------------------------------------------------------------------- 
       Dev Notes: D18971
       This is the exclude list for the Customer settings, these 
       items will not appear in the customer settings as they have been moved
       to Distributor/Product sections
       - Anand Rao/13-May-2009
    ---------------------------------------------------------------------------->
    <cfset lsExcludeList = #arrayToList(	
										[	"ACCOUNTING_SPECIALIST"
											,"BB_PC_GL_REASON_CODES_ON"
											,"BID_ID_EDITABLE"
											,"BUYING_GROUP_LABEL_PLURAL"
											,"BUYING_GROUP_LABEL_SINGULAR"
											,"CHECK_DUPLICATE_PROGRAM"
											,"CUSTOMER_ID_LABEL"
											,"CUSTOMER_SETTINGS_ID"
											,"DD_ALLOW_TRADE_NON_TRADE_TYPE"
											,"DD_ASSIGNMENT_BASED_ON_CUSTOMER"
											,"DD_SHOW_ISTRADE_BOX_AND_ASSOCIATE_A_PROGRAM"
											,"DD_SHOW_OPERATOR_FOR_RC_OF_ACCRUAL"
											,"DISCOUNT_IDENTIFIER_ON"
											,"FAMILYNAME_LABEL_PLURAL"
											,"FAMILYNAME_LABEL"
											,"INVOICE_ORDER_QUANTITY"
											,"PAYBY_AWAYX"
											,"POWERED_BY_SWITCH"
											,"Q_BRAND_LABEL_PLURAL"
											,"Q_BRAND_LABEL_SINGULAR"
											,"QRY_CUSTOMER_NAME_FONT_START"
											,"QRY_PRODUCT_DETAIL_POPUP"
											,"QRY_PRODUCT_PRICE_LIST_DETAIL_SPECIAL"
											,"QRY_PRODUCT_PRICE_LIST_DETAIL"
											,"QRY_PRODUCT_SEARCH"
											,"QRY_PROFIT_ANALYSIS_CUSTOM_CODE"
											,"QRY_Q_BRAND_LIST"
											,"QRY_Q_BRAND_REPORT_JOIN_CLAUSE"
											,"QRY_QBRAND_JOIN_CLAUSE"
											,"QRY_TYPE_CODE"
											,"QRY_TYPE_GROUP"
											,"RESPONSIBLE_PERSON"
											,"SHOW_DELIVERED"
											,"SHOW_OPERATOR_PROGRAM_SCORECARD"
											,"SHOW_PAY_MULTI_BB_LINK"
											,"SHOW_PDA"
											,"SHOW_PRODUCT_PRICE_LIST_DETAIL_SPECIAL"
											,"SHOW_XM"
											,"TYPE_CODE_LABEL_PLURAL"
											,"TYPE_CODE_LABEL_SINGULAR"
											,"TYPE_GROUP_LABEL_PLURAL"
											,"TYPE_GROUP_LABEL_SINGULAR"
										])#>

  	<cfloop list="#qGetCustSetLabels.columnlist#" index="colName">
      <cfif (ListFindNoCase(lsExcludeList,colName) EQ 0)>
		    <cfset colVal = HTMLEditFormat(evaluate('qGetCustSetLabels.#colName#'))>
				<cfset rowCounter = rowCounter + 1>
		    <cfif rowCounter MOD 2>
			    <cfset rowHilite = "rowBg1">
		    <cfelse>
			    <cfset rowHilite = "rowBg2">
		    </cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:300px;">
				#colName#
				<input type="hidden" name="columnName#rowCounter#" value="#colName#">
			</div>
      <script language="JavaScript1.2">
        function setVal(obj)
        {
          if (obj.checked == true){
            obj.value="1";
          }
          else{
            obj.value="0";
          }
        }
      </script>
			<div id="innerBodyContainer">
				<cfif len(colVal) GT 100>
					<textarea cols="70" rows="10" onKeyUp="modified();" name="data#rowCounter#">#colVal#</textarea>
				<cfelseif isDate(colVal)>
					<input type="text" onKeyUp="modified();" name="data#rowCounter#" value="#dateFormat(colVal)#" size="50">
				<cfelseif isBoolean(colVal)>
					<input type="checkbox" onClick="modified();setVal(this)" name="data#rowCounter#" <cfif colVal>checked </cfif> value="#colVal#" size="50">
				<cfelse>
					<input type="text" onKeyUp="modified();" name="data#rowCounter#" value="#colVal#" size="50">
				</cfif>
			</div>
			<div id="innerBodyContainerSM" nowrap></div>
		</div>
    </cfif>
	</cfloop>
  </div> <!--- Hide/Show DIV--->

  </fieldset>
	<input type="hidden" name="loopCnt" value="#rowCounter#">
<!----------------------------------------------------------------------------- 
  Dev Notes:
  CUSTOMER SETTINGS END HERE 
  CDP is for Customer, Distributor, Product put in Alphabetical order
  - Anand Rao/12-May-09
------------------------------------------------------------------------------>

	<div>
		<a href="javascript:frmSettingsModify.submit()" class="save">#application.util.string.actionLinkFormat2("save")#</a>
	</div>
</form>
</div>
</cfoutput>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cffunction name="DisplayDistributorField" access="public" output="true" hint="">
	<cfset rowCounter = rowCounter + 1>
		<cfset DistributorLabelTemplate = 0>
		<cfloop query="getActiveTemplateDistributorLabel">
			<cfif getAllDistributorAttributes.Distributor_group_level_id EQ getActiveTemplateDistributorLabel.GROUP_LEVEL_ID>
				<cfset DistributorLabelTemplate = #getAllDistributorAttributes.Distributor_group_level_id# />
			</cfif>
		</cfloop>
		<!--- check whether an option to show/hide "display in Results List" be provided for this entry --->
		<cfset displayOnDistributorSearchResults = 0>
		<cfif ListFindNocase(listDistributotAttForSearchResult,getAllDistributorAttributes.Group_Level_Desc_Internal) neq 0>
			<cfset displayOnDistributorSearchResults = 1>
		</cfif>

		<input type="hidden" name="DistID#rowCounter#" value="#evaluate('getAllDistributorAttributes.Distributor_group_level_id')#">
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer" style="width:140px">
			 <!--- Default Label Column ---> 
				<cfset default_label = evaluate("getAllDistributorAttributes.group_level_desc_internal")>
				#default_label#  
				<input type="hidden" name="BALabelDist#rowCounter#" value="#default_label#">
			</div>
			  
      <!---- Client Label Column --->
      <div id="innerBodyContainer" style="width:140px">
				<input type="text" onkeyup="modified();" name="DistLabel#rowCounter#" value="#evaluate('getAllDistributorAttributes.group_level_desc')#" size="20">
			</div>
      
      <!--- Plural Column --->
      <div id="innerBodyContainer" style="width:140px">
        <cfif getAllDistributorAttributes.Distributor_Group_Level_ID EQ 2> <!--- id = 2 is for the Family Name Label --->
          <input type="text" onkeyup="modified();" name="FamilyName_label_plural" value="#evaluate('qGetCustSetLabels.FamilyName_label_plural')#" size="20">
            <input type="hidden" name="FamilyName_label_field" value="DistLabel#rowCounter#"/>
        <cfelseif getAllDistributorAttributes.Distributor_Group_Level_ID EQ 3> <!--- id = 3 is for the Buying Group Label --->
         <input type="text" onkeyup="modified();" name="buying_group_label_plural" value="#evaluate('qGetCustSetLabels.buying_group_label_plural')#" size="20">
         <input type="hidden" name="buying_group_label_singular_field" value="DistLabel#rowCounter#"/>
        <cfelse>
        &nbsp;&nbsp;&nbsp; 
        </cfif>
      </div>
     
      <!--- Active Column --->  
     <div id="innerBodyContainer" nowrap style="width:55px;text-align:center;"
        onMouseOver="this.style.cursor='pointer';"
				onMouseOut="this.style.cursor='';"
        onClick="
								modified();
								var imgActive = $('imgActive#rowCounter#');
								var imgInActive = $('imgInActive#rowCounter#');
								var boxDistActive = $('boxDistActive#rowCounter#');
								if (imgActive.style.display == 'none') {
									imgActive.style.display='block';
									imgInActive.style.display='none';
									boxDistActive.checked=true;
								} else {
									if(#DistributorLabelTemplate# == #Distributor_group_level_id#) {
var newWin = window.open('app_settings_label_settings_validation.cfm?GROUP_LEVEL_ID=#Distributor_group_level_id#&PGGroupType=2','mywindow','width=800,height=600,scrollbars=yes,resizable=yes'); 
									newWin.focus();
									return false;
									}
									else {
									imgActive.style.display='none';
									imgInActive.style.display='block';
									boxDistActive.checked=false;
									}
								}
        "> 
          <cfif evaluate("getAllDistributorAttributes.Active")>
						<img id="imgActive#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgInActive#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgActive#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgInActive#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxDistActive#rowCounter#"
							type="checkbox"
							value="1"
							name="boxDistActive#rowCounter#"
							style="display:none;"
							<cfif evaluate("getAllDistributorAttributes.Active")>
								CHECKED
							</cfif>
							>
        </div>      
        <!--- Field in Distributor Search Column --->
				<div id="innerBodyContainer" nowrap
					style="width:170px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgYes = $('imgYes#rowCounter#');
								var imgNo = $('imgNo#rowCounter#');
								var boxDist = $('boxDist#rowCounter#');
								if (imgYes.style.display == 'none') {
									imgYes.style.display='block';
									imgNo.style.display='none';
									boxDist.checked=true;
								} else {
									imgYes.style.display='none';
									imgNo.style.display='block';
									boxDist.checked=false;
								}
							">
					<cfif evaluate("getAllDistributorAttributes.search_filter_on")>
						<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxDist#rowCounter#"
							type="checkbox"
							value="1"
							name="boxDist#rowCounter#"
							style="display:none;"
							<cfif evaluate("getAllDistributorAttributes.search_filter_on")>
								CHECKED
							</cfif>
							>
			</div>
			<!---- List Order Column --->
				<div id="innerBodyContainer" style="width:55px">
				<input type="text" onkeyup="modified();clenseText(this, '0123456789');" name="DistListOrder#rowCounter#" value="#evaluate('getAllDistributorAttributes.List_order')#" size="5">
				</div>
			<!--- "Display in results list" column --->
			<cfif displayOnDistributorSearchResults eq 1>
			<div id="innerBodyContainer" nowrap
					style="width:40px;text-align:center;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgDisplayDistSearchYes = $('imgDisplayDistSearchYes#rowCounter#');
								var imgDisplayDistSearchNo = $('imgDisplayDistSearchNo#rowCounter#');
								var boxDisplayDistSearch = $('boxDisplayDistSearch#rowCounter#');
								if (imgDisplayDistSearchYes.style.display == 'none') {
									imgDisplayDistSearchYes.style.display='block';
									imgDisplayDistSearchNo.style.display='none';
									boxDisplayDistSearch.checked=true;
								} else {
									imgDisplayDistSearchYes.style.display='none';
									imgDisplayDistSearchNo.style.display='block';
									boxDisplayDistSearch.checked=false;
								}
							">
					<cfif evaluate("getAllDistributorAttributes.Display_In_Search_Results")>
						<img id="imgDisplayDistSearchYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgDisplayDistSearchNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					<cfelse>
						<img id="imgDisplayDistSearchYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgDisplayDistSearchNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					</cfif>
					<input id="boxDisplayDistSearch#rowCounter#"
							type="checkbox"
							value="1"
							name="boxDisplayDistSearch#rowCounter#"
							style="display:none;"
							<cfif evaluate("getAllDistributorAttributes.Display_In_Search_Results")>
								CHECKED
							</cfif>
							>
  			</div>
			<cfelse>
			<div id="innerBodyContainer" nowrap style="width:40px;text-align:center;">
				<input type="hidden" id="boxDisplayDistSearch#rowCounter#" name="boxDisplayDistSearch#rowCounter#" value="0">
			</div>
			</cfif>
      </div>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cffunction name="DisplayAdditionalField" access="public" output="true" hint="">
<cfargument name="kind" type="string">
<cfargument name="displayAdditionalFieldsforSearchResult" type="string" default="">

<cfset var l = structnew()>
<div id="headerContainer">
	<div id="innerHeaderContainer" style="width:140px">Additional Fields</div>
	<div id="innerHeaderContainer" style="width:140px">&nbsp;</div>
		<div id="innerHeaderContainer" style="width:140px;">&nbsp;</div>
		<div id="innerHeaderContainer" style="width:55px;text-align:center;"><cfif arguments.kind eq "distributor">Active?<cfelse>&nbsp;</cfif></div>
	<div id="innerHeaderContainer" style="width:170px;text-align:center;">
			<cfset l.tooltip = 'ttip418' & arguments.kind>
			Field in All Search? <span title="" onmouseout="popUpTip(event, '#l.tooltip#');" onmouseover="popUpTip(event, '#l.tooltip#');"><img src="/images/help_small.gif"/></span> 
	<div id='#l.tooltip#' class="tip">
			  <p style="text-align:left;margin:4px;">The fields in this section are common fields that are displayed in all the search tools <i>(with the exception of groups search)</i> regardless if the search tool is within a program or not.<br/><br/>  A green check indicates the field will display in all search tools.  A red X indicates the field will not display at all in the search tools.</p>
	</div>
	</div>
	<div id="innerHeaderContainer" style="width:65px;">Order</div>
	<cfif arguments.displayAdditionalFieldsforSearchResult neq "">
		<div id="innerHeaderContainer" style="width:80px;">Display in <br>Results List</div>
	</cfif>
</div>
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cffunction name="DisplayOtherSearch" access="public" output="true" hint="">
<cfargument name="kind" type="string">

<cfset var l = structnew()>
<cfset l.tooltip = 'ttip418a' & arguments.kind>
Field in Other Search <span title="" onmouseout="popUpTip(event,'#l.tooltip#');" onmouseover="popUpTip(event,'#l.tooltip#');"><img src="/images/help_small.gif"/></span><br/>(unrelated to program)?
<div id="#l.tooltip#" class="tip">
	<p style="text-align:left;margin:4px;">Within the application we display product / customer / operator search tools that are outside of the program, such as settings pages or within the billback module.<br/><br/> Field in Other Search allows you to control the fields to display in the search tools that are not within a program.<br/><br/>  A green check indicates the field will display.  A red X indicates the field will not display. To control the fields to display in the search tools within a program, use the filters from the program template.</p>
</div>
</cffunction>
