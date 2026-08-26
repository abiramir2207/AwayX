<!---------------------------------------------------------------------------------------------------------------------
            Template: \ Common_Files\Contracts\Ajax\getEZRates.cfm
            Date:     20-May-2020
            Author:   Dinesh Rachala
            Purpose:  Get EZ Button Items and rates.
----------------------------------------------------------------------------------------------------------------------->

<cfsetting showDebugOutput="no">
<cfprocessingdirective suppresswhitespace="yes">
<cfsilent>
  <cfparam name="url.iDisplayStart"   default="0">
  <cfparam name="url.iDisplayLength"  default="100">
  <cfparam name="url.sEcho"           default="10">
  <cfparam name="url.iSortCol_0"      default="0">
  <cfparam name="url.SSORTDIR_0"      default="asc">
	<cfparam name='selected_cs' default = ''>
	<cfparam name='selected_lb' default = ''>

  <cfscript>
	reply = {};

	page_size   = val(url.iDisplayLength);
	if ( page_size eq -1) {
	  start_row   = 1;
	  end_row     = -1;
	}
	else {
	  start_row   = url.iDisplayStart + 1;
	  end_row     = url.iDisplayStart + page_size;
	}
	url.sSearch = trim(url.sSearch);
	unknown     = 'unknown';
	dSearch     = ( isDate(url.sSearch) ? dateFormat(parseDateTime(url.sSearch),'short') : unknown );

	// parse search string into an array of words
	if ( len(url.sSearch) ) {
	  arrayOfWords = reMatch( "[[:word:]]+", url.sSearch );
	}
	else {
	  arrayOfWords = [];
	}
	// concatenate array of words into a long string delimited by % ( for SQL LIKE condition )
	listOfWords        = arrayToList(arrayOfWords, "%");
	url.iSortCol_0     = val(url.iSortCol_0);
  </cfscript>

	<cfset appSettings 		= application.oApplicationAppSettingsManager.getApplicationAppSettings()>

	<cfset decimalprecision_CS = appSettings.get_Setting('Decimal_display_for_CS')>
	<cfset decimalprecision_LB = appSettings.get_Setting('Decimal_display_for_LB')>

  <cfoutput>
  <cfquery name="qRows" datasource="#application.datasource#">
			SELECT 	bsa_foodservice_items_master.bsa_foodservice_items_master_id
										, CASE
											WHEN contract_products.IS_Group = 1
																	THEN all_product_group_types.Group_Number
											ELSE  bsa_foodservice_items_master.item END AS item
										,  bsa_foodservice_items_master.description
										,	CASE
											WHEN program_rebates_component_data.unit_of_measure_id = 1
																	THEN Cast(CONVERT(DECIMAL(10,#decimalprecision_CS#),program_rebates_component_data.rate) as DECIMAL(10,#decimalprecision_CS#))
											WHEN program_rebates_component_data.unit_of_measure_id = 2
																	THEN Cast(CONVERT(DECIMAL(10,#decimalprecision_LB#),program_rebates_component_data.rate) as DECIMAL(10,#decimalprecision_LB#))
											ELSE  Cast(CONVERT(DECIMAL(10,4),program_rebates_component_data.rate) as DECIMAL(10,4)) END AS rate
										, program_rebates_component_data.unit_of_measure_id
										, contract_products.Contract_Products_ID
										, program_rebates_product_data.Program_Rebates_Product_Data_ID
										, contract_products.IS_Group
										, contract_products.Pricing_Level_ID
										, all_product_group_types.Product_Group_Level_ID

			FROM   contract_main

			INNER JOIN program_rebates_component
			ON program_rebates_component.deleted = 0
			AND Program_rebates_component.program_id = contract_main.contract_main_id

			INNER JOIN  contract_products
			ON contract_products.contract_main_id = contract_main.contract_main_id
			AND contract_products.captured_from_group = 0
			AND contract_products.product_type_id = 2

			INNER JOIN bsa_foodservice_items_master
			ON bsa_foodservice_items_master.bsa_foodservice_items_master_id = contract_products.bsa_foodservice_items_master_id

			INNER JOIN program_rebates_product_data
			ON program_rebates_product_data.contract_products_id = contract_products.contract_products_id

			INNER JOIN program_rebates_component_data
			ON program_rebates_component_data.program_rebates_product_data_id = program_rebates_product_data.program_rebates_product_data_id
			AND program_rebates_component_data.program_rebates_component_id = program_rebates_component.program_rebates_component_id

			LEFT JOIN all_product_group_types
			ON all_product_group_types.Group_GUID = contract_products.bsa_foodservice_items_master_id

			WHERE  contract_main.contract_main_id = <cfqueryparam value="#url.contract_main_id#" cfsqltype="CF_SQL_INTEGER">
			AND contract_products.deleted = 0
			AND program_rebates_component_data.deleted = 0
			AND program_rebates_product_data.deleted = 0

			<cfif len(url.sSearch)>
				AND (   bsa_foodservice_items_master.item LIKE '%#listOfWords#%'
					  OR bsa_foodservice_items_master.description LIKE '%#listOfWords#%'
						OR all_product_group_types.Group_Number LIKE '%#listOfWords#%'
					)
			 </cfif>

	<cfswitch expression="#url.iSortCol_0#">
	  <cfcase value=1> ORDER BY CASE
									WHEN contract_products.IS_Group = 1 THEN all_product_group_types.Group_Number
									ELSE bsa_foodservice_items_master.item
                                END
                        #url.sSortDir_0# </cfcase>
	  <cfcase value=2> ORDER BY bsa_foodservice_items_master.description #url.sSortDir_0# </cfcase>
	</cfswitch>

  </cfquery>

  </cfoutput>

	<cfset reply.iTotalDisplayRecords = qRows.recordCount>

  <!--- Generate JSON from Query --->
	<cfset reply.aaData = [] >
	<cfset reply.itemList = []>
	<cfset reply.maxPriceListID = []>
	<cfset reply.hasGroups = []>

  <cfif end_row eq -1>
		<cfset start_row = 1>
		<cfset end_row   = qRows.recordCount>
  <cfelse>
		<cfset end_row   = min(end_row, qRows.recordCount)>
  </cfif>

	<cfoutput>

	<cfloop query="qRows" startRow="#start_row#" endRow="#end_row#">

		<cfset compVarReplace = "#request.app_general_functions.replaceHyphen(bsa_foodservice_items_master_id)#"/>
		<cfif unit_of_measure_id EQ 1>
			<cfset selected_cs = 'selected'>
			<cfset selected_lb = ''>
		<cfelseif unit_of_measure_id EQ 2>
			<cfset selected_lb = 'selected'>
			<cfset selected_cs = ''>
		</cfif>

	<cfscript>
	  dArrayTmp = [];
		arrayAppend(dArrayTmp, '
		<img bdelete="true"	name="IMG_Delete_Scissor"	src="/images/scissor.gif" title="click here to delete this product" border="0"
		onclick="deleteItems(#url.contract_main_id#, #Contract_Products_ID#, #Program_Rebates_Product_Data_ID#, 1, ''#item#'', #IS_Group#, #Pricing_Level_ID#)" style="cursor: pointer;">
		');
	  arrayAppend(dArrayTmp, item);
		arrayAppend(dArrayTmp, description);
		arrayAppend(dArrayTmp, '
		<input name="comp_rate_#compVarReplace#" type="text" onkeyup="clenseText(this,"0123456789.")" item="#item#" onfocusout="saveRate(this, 1)" group="#IS_Group#" price="#rate#" bsaid="#bsa_foodservice_items_master_id#" value="#rate#" onChange="this.value = formatToDeciamalPlaces(this.value,4);" size=5/>
		&nbsp;&nbsp;
		<select  name="comp_uom_#compVarReplace#" id="comp_uom_#compVarReplace#" item=#item# onchange="saveRate(this, 2)" group="#IS_Group#" price="" bsaid="#bsa_foodservice_items_master_id#">
			<option value="1" #selected_cs#>CS</option>
			<option value="2" #selected_lb#>LB</option>
		</select>
		');
	</cfscript>

		<cfsavecontent variable="cellContent">
				<a href="javascript:alert()" class="action">
					#application.util.string.actionLinkFormat("save")#
				</a>
		</cfsavecontent>

	<cfscript>
		/*arrayAppend(dArrayTmp, cellContent);*/
		arrayAppend(dArrayTmp, bsa_foodservice_items_master_id);
		arrayAppend(dArrayTmp, Contract_Products_ID);
		arrayAppend(dArrayTmp, IS_Group);
		arrayAppend(dArrayTmp, Pricing_Level_ID);
		arrayAppend(dArrayTmp, Product_Group_Level_ID);
	  arrayAppend(reply.aaData, dArrayTmp);
	</cfscript>

  </cfloop>
	</cfoutput>

<cfset arrayAppend(reply.itemList, valueList(qRows.bsa_foodservice_items_master_id))>


<cfset PricingLevelID=ListToArray(valueList(qRows.Pricing_Level_ID),',')>
<cfset MaxPricingLevelID =ArrayMax(PricingLevelID)>

<cfset arrayAppend(reply.maxPriceListID, MaxPricingLevelID)>

<cfset IS_Group=ListToArray(valueList(qRows.IS_Group),',')>
<cfset IS_Group =ArrayMax(IS_Group)>
<cfset arrayAppend(reply.hasGroups, IS_Group)>

	<cfscript>
	reply.sEcho = javacast('int', url.sEcho);
	sOut        = SerializeJSON( reply );
	sOut        = Replace (sOut, 'SECHO', 'sEcho', 'one');
	sOut        = Replace (sOut, 'ITOTALRECORDS', 'iTotalRecords', 'one');
	sOut        = Replace (sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords', 'one');
	sOut        = Replace (sOut, 'ITEMLIST', 'itemList', 'one');
	sOut        = Replace (sOut, 'MAXPRICELISTID', 'maxPriceListID', 'one');
	sOut        = Replace (sOut, 'HASGROUPS', 'hasGroups', 'one');
	sOut        = Replace (sOut, 'AADATA', 'aaData', 'one');
  </cfscript>
</cfsilent>

<!---send JSON data back to client--->
<cfoutput>#sOut#</cfoutput>
</cfprocessingdirective>
