<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      Template:  \Common_Files\contracts\bid_request\variables.competitiveInfo.cfm
          Date:  October 2013
        Author:  Chris Nguyen
       Purpose:  Manages competitive data

         Notes:  There could be 3 levels of elements on this page:

         Level 1 = At the top, outside data grid table, optional, separated from data grid table with a horizontal bar

         Level 2 = One for each product, inside data grid table, required, CSS class = 'l2'
                   ONLY the changed elements on these rows are passed to the form action page - quicker saving process
                   Element names are prefixed with "l2.item", and suffixed with a current row number.

                          l2.itemN.id
                          l2.itemN.comp
                          l2.itemN.won
                          l2.itemN.rate
                          l2.itemN.uom
                          l2.itemN.deli
                          l2.itemN.cat
                          l2.itemN.pack
                          l2.itemN.shar
                          l2.itemN.incr
                          l2.itemN.spec

         Level 3 = Multiple records for each product, inside data grid table, CSS class = 'l3'
                   ALWAYS pass these rows to form action page. Why? Because users have ability to delete these rows & we
                   have no way knowing which rows are newly added!!
                   Element names are prefixed with "l3.item", and suffixed with a unique number

                          l3.itemN.id
                          l3.itemN.comp
                          l3.itemN.rate
                          l3.itemN.uom

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE8" />
<title>Competitive Data</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/feedback.css">
<link rel="stylesheet" href="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css" type="text/css" />
<style>

    ::-ms-clear {
        display: none;
    }
	
  #program {
    background-color: #FFCE84;
    height: 26px;
    border-top:1px solid black;
    border-bottom:1px solid black;
    width: 100%;
  }
  #programTable {
    margin-top:3px;
	width: 100%;
  }
	  #programTable td {
	    font-size: 1.15em;
		padding: 0 15px;
		width: 50%;
	  }
	  #programTable td.right {
	  	text-align:right;
	  }
  .g17 {
    text-align:center !important;
  }
  .plus4, .cut {
    margin-left:5px;
  }
  .competitor {
    width: 78%;
  }
  .rate {
    width: 90%;
    text-align: right;
  }
  .center {
    text-align: center;
  }
  #mass1425a th {
    background-color: #208C8C;
    color: white;
  }
  #mass1425 th {
    background-color: #BDC694;
  }
  #datesource {
    margin:0 0 0 0;
    font-size: 1.05em;
    width:100%;
  }
    #datesource label {
      font-weight: bold;
    }
    #datesource input, #datesource select {
      margin-right: 18px;
    }
  #datagrid input[type=text], #datagrid select {
    width:95%;
  }
  .l2 {
    background-color: #eeffee;
  }
  #actions {
		margin-top:13px;
		display:none;
		margin-left:70%;
		width:30%;
		text-align:right;
  }
  #mainForm {
  	margin:0;
    padding:0;
    display:none;
  }
  #loading {
    margin-top:15px;
    width:100%;
		text-align:center;
		font-size:1.3em;
		font-weight:bold;
		color:#00529B;
  }
</style>
</head>
<body>
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "ci">
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfscript>
    variables.components = {};
    variables.components.competitive = createObject("component", "components.programs.bid_request.CompetitiveDataManager");

    if ( cgi.request_method eq "post" ) {
      	//writedump(form);
    	variables.components.competitive.saveAllData();
    }

    // get the optional columns from program template settings
    variables.templateSettings = variables.components.competitive.getTemplateSettings( form.Contract_Main_ID );

    // get all products on this program
    variables.allProducts = variables.components.competitive.getProducts( form.Contract_Main_ID );

    variables.productBidInfo = variables.components.competitive.getProductBidInfo( form.Contract_Main_ID );
    variables.competitiveInfo = variables.components.competitive.getCompetitiveData( form.Contract_Main_ID );

    variables.competitors = variables.components.competitive.getCompetitors();

	 variables.defaultUOM = variables.components.competitive.getProgramUOM(form.Contract_Main_ID);
    // components.labels = createObject("component", "components.settings.labels.labels").init();
    // vars.labels = components.labels.getGeneralLabels();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<cfquery name="variables.contractInfo" datasource="#application.datasource#">
    SELECT Program_Control_Panel_Options.Created_Type as CreatedType, Contract_Main.Contract_Number
    FROM Contract_Main
    INNER JOIN Program_Control_Panel_Options
    ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
    WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
    AND Program_Control_Panel_Options.deleted = 0
</cfquery>

<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<div id="content">
  <div id="program">
	<table id="programTable">
		<tr>
			<td>Program Number: <B>#variables.contractInfo.Contract_Number#</B></td>
			<td class="right">Program Template: <B>#application.util.string.fullLeft(variables.contractInfo.CreatedType, 50)#</B></td>
		</tr>
	</table>
  </div>

  <cfif cgi.request_method eq "post">
    <div class="success" style="height:15px;">
      <p>Your changes have been saved succesfully.</p>
    </div>
  </cfif>

  <div id="loading">Loading competitive data, please wait...</div>
  <cfset displayActions()>

  <form id="mainForm" method="post">

  <!----------------  T O P   L E V E L  -------------------------------------------------------------------------------------->
  <div id="datesource">
    <cfset variables.topLevel = 0
                                + (variables.templateSettings.Source eq '1' ? 1 : 0)
                                + (variables.templateSettings.Source_type eq '1' ? 1 : 0)
                                + (variables.templateSettings.Date_source_received eq '1' ? 1 : 0)>

    <!--- if header level column is needed get the header information from the db --->
    <cfif variables.topLevel gt 0>
      <cfset variables.headerInfo = variables.components.competitive.getProductBidRequest( form.Contract_Main_ID )>
    </cfif>

    <!--- if source is enabled in program template setting display them --->
    <cfif variables.templateSettings.Source eq '1'>
      <cfset variables.qSources = variables.components.competitive.getSources()>
      <label for="source">Source: </label>
      <select name="source" style="width:21%">
        <option value="">Select option</option>
        <cfloop query="variables.qSources">
          <option <cfif variables.qSources.Program_Bid_Source_Id eq variables.headerInfo.Program_Bid_Source_Id> selected=selected </cfif>value="#variables.qSources.Program_Bid_Source_Id#">
		  #variables.qSources.Program_Bid_Source_Description#
		  </option>
        </cfloop>
      </select>
    </cfif>

    <!--- if source type is enabled in program template setting display them --->
    <cfif variables.templateSettings.Source_type eq '1'>
      <cfset variables.qSourceTypes = variables.components.competitive.getSourceTypes()>
      <label for="source_type">Source Type: </label>
      <select name="source_type" style="width:21%">
        <option value="">Select option</option>
        <cfloop query="variables.qSourceTypes">
          <option <cfif variables.qSourceTypes.Program_Bid_Source_Type_Id eq variables.headerInfo.Program_Bid_Source_Type_Id> selected=selected </cfif>value="#variables.qSourceTypes.Program_Bid_Source_Type_Id#">
		  #variables.qSourceTypes.Program_Bid_Source_Type_Description#
		  </option>
        </cfloop>
      </select>
    </cfif>

    <!--- if source date is enabled in program template setting display it --->
    <cfif variables.templateSettings.Date_source_received eq '1'>
      <label for="date_source_received">Date: </label>
	  <input type="text" name="date_source_received" id="date_source_received" value="#dateFormat(variables.headerInfo.Program_Bid_Source_Date, 'm/d/yyyy')#">
    </cfif>

    <!--- display a horizontal bar if there is at least one component in the top level --->
    <cfif variables.topLevel gt 0>
      <hr/>
    </cfif>
  </div>


  <!----------------  D A T A G R I D   L E V E L  ---------------------------------------------------------------------------->
  <!--- set up an array with required columns (item, competitor, won, rate uom) and custom columns defined in program template settings --->
  <!--- size attribute determines how much space is reserved for the column (1=small, 4=large, 5=x-large)--->
  <cfset variables.columns = [  { name="item", size="5" }
                               ,{ name="won", size="1" }
                               ,{ name="competitor", size="5" }
                               ,{ name="rate", size="2" }
                               ,{ name="uom", size="1" }
                             ]>
							 

  <cfscript>
    variables.names             = {};
    variables.names.Delivery    = "Delivery";
    variables.names.Category    = "Category";
    variables.names.Package     = "Package";
    variables.names.Shared      = "Shared";
    variables.names.Incremental = "Incr";
    variables.names.Specd       = "Spec'd";

    // is delivery type flagged as included?
    if (variables.templateSettings.Delivery_type eq '1') {
      arrayAppend(variables.columns, { name=variables.names.Delivery, size="1.5" });
    }

    // is incremental flagged as included?
    if (variables.templateSettings.Incremental eq '1')
      arrayAppend(variables.columns, { name=variables.names.Incremental, size="1" });

    // is shared flagged as included?
    if (variables.templateSettings.Shared eq '1')
      arrayAppend(variables.columns, { name=variables.names.Shared, size="1" });

    // is specd flagged as included?
    if (variables.templateSettings.Specd eq '1')
      arrayAppend(variables.columns, { name=variables.names.Specd, size="1" });

    // is category flagged as included?
    if (variables.templateSettings.category eq '1') {
      variables.qCategories = variables.components.competitive.getCategories();
      arrayAppend(variables.columns, { name=variables.names.Category, size="3" });
    }

    // is package flagged as included?
    if (variables.templateSettings.Package eq '1') {
      variables.qPackages = variables.components.competitive.getPackages();
      arrayAppend(variables.columns, { name=variables.names.Package, size="3" });
    }

    // gather all sizes and place them inside an array
    variables.estimatedSizes = [];
    for (variables.counter=1; variables.counter lte arrayLen(variables.columns); variables.counter++)
      arrayAppend(variables.estimatedSizes, variables.columns[variables.counter].size);

    // get the exact column width percentages based on estimated sizes and screen width
    variables.columnSizeInPercent = application.util.array.dtColumnSizeInPercent(variables.estimatedSizes);
  </cfscript>

  <!--- gather a list of distinct type codes --->
  <cfquery name="variables.qTypeCodes" dbtype="query">
    SELECT DISTINCT group_desc
      FROM variables.allProducts
      ORDER BY group_desc
  </cfquery>

	<div style="padding-bottom:10px">
		<a href="##" class="massapply">#application.util.string.actionLinkFormat('mass apply')#</a>
	</div>

  <div id="datagridwrapper">
    <input type="hidden" name="L2.item.recordCount" value="#variables.allProducts.recordCount#">
    <input type="hidden" name="L3.item.recordCount" value="#variables.competitiveInfo.recordCount#">

    <table id="datagrid" class="datagrid" style='table-layout:fixed'>

    <!--- allocate space to columns with the calculated width percentages --->
    <cfloop array="#variables.columnSizeInPercent#" index="variables.column">
      <col width="#variables.column#%">
    </cfloop>

	<thead>
		<tr>
			<th>
				<cfif len(variables.allProducts.Product_Group_ID) OR variables.allProducts.Product_Group_ID EQ 'NULL'>
				Groups
				<cfelse>
				#application.returned_customer_setting.Item_Label# #application.returned_customer_setting.type_code_label_singular#
				</cfif>
				<select name="productKind">
				<option value="">All</option>
				<cfloop query="variables.qTypeCodes">
				<option>#variables.qTypeCodes.group_desc#</option>
				</cfloop>
				</select>
			</th>
			<th style="text-align:center">W/L/P</th>
			<th>Competitor</th>
			<th style="text-align:center">Rate</th>
			<th style="text-align:center">UOM</th>
			<!--- display custom columns defined in program template settings --->
			<cfloop from="6" to="#arrayLen(variables.columns)#" index="variables.counter">
				<th style="text-align:center">#variables.columns[ variables.counter ].name#</th>
			</cfloop>
		</tr>
	</thead>

	<tbody>
		<cfset variables.competitiveCounter = 0>
		<cfset l3Moved2L2 = 0>
<cfloop query="variables.allProducts">
			<cfquery name="variables.bidInfo" dbtype="query">
				SELECT *
				FROM variables.productBidInfo
				WHERE Product_Id = <cfoutput>'#variables.allProducts.BSA_FOODSERVICE_ITEMS_MASTER_ID#'</cfoutput>
			</cfquery>
			<cfquery name="variables.competitive" dbtype="query">
				SELECT *
				FROM variables.competitiveInfo
				WHERE Product_Id = <cfoutput>'#variables.allProducts.BSA_FOODSERVICE_ITEMS_MASTER_ID#'</cfoutput>
			</cfquery>

			<cfset competitorStartRow = 1 />
			<!---
			<cfif variables.bidInfo.Won_by EQ '' AND variables.competitive.recordCount>
				<!--- Get the first competitiveInfo and populate in bidInfo --->
				<cfset QuerySetCell(variables.bidInfo, "Program_Bid_Won_By_ID", variables.competitive.Program_Bid_Won_By_ID)>
				<cfset QuerySetCell(variables.bidInfo, "Won_Price", variables.competitive.Won_Price)>
				<cfset QuerySetCell(variables.bidInfo, "Won_UOM", variables.competitive.Won_UOM)>
				<cfset QuerySetCell(variables.bidInfo, "Won_Delivery_Type", variables.competitive.Won_Delivery_Type)>
				<cfset competitorStartRow = 2 />
				<cfset l3Moved2L2 = 1>
			</cfif>
			--->

         <!---------- ATTENTION: all product bid info rows have l2.item prefix and current row number suffix -------->
         <cfset variables.level2Prefix = "l2.item" & variables.allProducts.currentRow>
         <!---------------------------------------------------------------------------------------------------------->

         <!--- display required columns for product bid info row --->
         <tr class="l2">
			<!--- item description --->
			<td>
				<input type="checkbox" class="massOne" style="display:none;">
				#trim(variables.allProducts.item)# #trim(variables.allProducts.description)#<br>
				<cfif len(variables.allProducts.Product_Group_ID) OR variables.allProducts.Product_Group_ID EQ 'NULL'>
					[ Group Desc ] #variables.allProducts.group_desc#
				<cfelse>
					[ #application.returned_customer_setting.Item_Label# #application.returned_customer_setting.type_code_label_singular# ] #variables.allProducts.group_desc#
				</cfif>
				<input type="hidden" class="item" name="#variables.level2Prefix#.id" value="#variables.allProducts.BSA_FOODSERVICE_ITEMS_MASTER_ID#">
			</td>
			<!--- won column --->
			<td>
				<select name="#variables.level2Prefix#.won" class="won">
					<option <cfif variables.bidInfo.won eq "1">selected=selected</cfif> value="won">won</option>
					<option <cfif variables.bidInfo.won eq "0">selected=selected</cfif> value="lost">lost</option>
					<option <cfif variables.bidInfo.won neq "0" and variables.bidInfo.won neq "1">selected=selected</cfif> value="pending">pend</option>
				</select>
			</td>
			<!--- competitor column --->
			<td style="text-align:left;">
				<select name="#variables.level2Prefix#.comp" class="competitor" style="width:82%;">
					<!--- 45759 Unable to remove competitor
					<cfif variables.bidInfo.Is_Client EQ 1>
					<option value="#trim(variables.bidInfo.Program_Bid_Won_By_Id)#" SELECTED>#trim(variables.bidInfo.Program_Bid_Won_By_Description)#</option>
					<cfelse>
					<option></option>
					</cfif>
					--->
					<option></option>

					<cfloop query="variables.competitors">
					<option value="#variables.competitors.Program_Bid_Won_By_Id#" <cfif variables.bidInfo.Program_Bid_Won_By_ID eq variables.competitors.Program_Bid_Won_By_Id>selected</cfif>>
						#variables.competitors.Program_Bid_Won_By_Description#
					</option>
					</cfloop>
				</select> <img class="plus4" src="/images/plus4.gif" border="0">
			</td>
			<!--- rate column --->
			<td>
				<input name="#variables.level2Prefix#.rate" type="text" class="rate" <cfif val(variables.bidInfo.Won_Price) neq 0>value="#NumberFormat(variables.bidInfo.Won_Price, ',.99')#"</cfif>>
			</td>
			<!--- uom column --->
			<td>
				<select name="#variables.level2Prefix#.uom" class="uom">
					<option></option>
					<option value="1" <cfif variables.bidInfo.won_UOM eq 1 or (variables.bidInfo.won_UOM neq 2 and variables.defaultUOM eq 1)>selected</cfif>>CS</option>
					<option value="2" <cfif variables.bidInfo.won_UOM eq 2 or (variables.bidInfo.won_UOM neq 1 and variables.defaultUOM eq 2)>selected</cfif>>LB</option>
				</select>
			</td>
         <!--- display custom columns defined in program template settings --->
         <cfloop from="6" to="#arrayLen(variables.columns)#" index="variables.counter">
            <!--- incremental column --->
            <cfif variables.columns[ variables.counter ].name eq variables.names.Incremental>
             <td>
             	<input name="#variables.level2Prefix#.incr" type="checkbox" class="inc" <cfif variables.bidInfo.incremental eq "1">checked</cfif>>
			 </td>
            <!--- specd column --->
            <cfelseif variables.columns[ variables.counter ].name eq variables.names.Specd>
              <td>
              	<input name="#variables.level2Prefix#.spec" type="checkbox" class="spec" <cfif variables.bidInfo.specd eq "1">checked</cfif>>
			</td>
            <!--- shared column --->
            <cfelseif variables.columns[ variables.counter ].name eq variables.names.Shared>
              <td>
              	<input name="#variables.level2Prefix#.shar" type="checkbox" class="shared" <cfif variables.bidInfo.shared eq "1">checked</cfif>>
			 </td>
            <!--- delivery column --->
            <cfelseif variables.columns[ variables.counter ].name eq variables.names.Delivery>
              <td>
				<select name="#variables.level2Prefix#.deli">
					<option value="">Select Delivery</option>
					<option <cfif variables.bidInfo.Won_Delivery_Type eq "1">selected</cfif> value="1">FOB</option>
					<option <cfif variables.bidInfo.Won_Delivery_Type eq "2">selected</cfif> value="2">DEL</option>
				</select>
			  </td>
            <!--- category column --->
            <cfelseif variables.columns[ variables.counter ].name eq variables.names.Category>
              <td>
				<select name="#variables.level2Prefix#.cat">
					<option value="">Select Category</option>
					<cfloop query="variables.qCategories">
					<option <cfif variables.bidInfo.Program_Bid_Category_ID eq variables.qCategories.Program_Bid_Category_ID>selected</cfif> value="#variables.qCategories.Program_Bid_Category_Id#">
						#variables.qCategories.Program_Bid_Category_Description#
					</option>
					</cfloop>
				</select>
			  </td>
            <!--- package column --->
            <cfelseif variables.columns[ variables.counter ].name eq variables.names.Package>
              <td>
				<select name="#variables.level2Prefix#.pack">
					<option value="">Select Package</option>
					<cfloop query="variables.qPackages">
					<option <cfif variables.bidInfo.Program_Bid_Package_Id eq variables.qPackages.Program_Bid_Package_Id>selected=selected</cfif> value="#variables.qPackages.Program_Bid_Package_Id#">
						#variables.qPackages.Program_Bid_Package_Description#
					</option>
					</cfloop>
				</select>
			  </td>
            <!--- unknown column --->
            <cfelse>
              <td>&nbsp;</td>
            </cfif>
         </cfloop>   <!--- from="6" to="#arrayLen(variables.columns)#" index="variables.counter"> --->
         </tr>
         <!------------------------------------------------------->
         <!--- display level 3 entries = competitive data rows --->
         <!------------------------------------------------------->
         <cfloop query="variables.competitive" startrow="#competitorStartRow#" endrow="#variables.competitive.recordcount#">
           <cfset variables.competitiveCounter++>
           <!---------- ATTENTION: all product bid info rows have l3.item prefix and current row number suffix -------->
           <cfset variables.level3Prefix = "l3.item" & variables.competitiveCounter>
           <!---------------------------------------------------------------------------------------------------------->
           <tr class="l3">
			<!--- item description --->
				<td>
					<input type="checkbox" class="massOne" style="display:none;">
					#trim(variables.allProducts.item)# #trim(variables.allProducts.description)#<br>
					<cfif len(variables.allProducts.Product_Group_ID) OR variables.allProducts.Product_Group_ID EQ 'NULL'>
						[ Group Desc ] #variables.allProducts.group_desc#
					<cfelse>
						[ #application.returned_customer_setting.Item_Label# #application.returned_customer_setting.type_code_label_singular# ] #variables.allProducts.group_desc#
					</cfif>
					<input type="hidden" class="item" name="#variables.level3Prefix#.id" value="#variables.allProducts.BSA_FOODSERVICE_ITEMS_MASTER_ID#">
				</td>
			<!--- won column --->
				<td>
				<select name="#variables.level3Prefix#.won" class="won">
					<option <cfif variables.competitive.won eq "1">selected=selected</cfif> value="won">won</option>
					<option <cfif variables.competitive.won eq "0">selected=selected</cfif> value="lost">lost</option>
					<option <cfif variables.competitive.won neq "0" and variables.competitive.won neq "1">selected=selected</cfif> value="pending">pend</option>
				</select>
				</td>
			<!--- <td><select name="#variables.level3Prefix#.won" class="won"> <option value="won">won</option> <option value="lost">lost</option> <option value="pending" selected="selected">pend</option> </select></td> --->
			<!--- competitor column --->
				<td style="text-align:left;">
					<select name="#variables.level3Prefix#.comp" class="competitor" style="width:82%;">
						<option></option>
						<cfloop query="variables.competitors">
						<option value="#variables.competitors.Program_Bid_Won_By_Id#" <cfif variables.competitive.Program_Bid_Won_By_ID eq variables.competitors.Program_Bid_Won_By_Id>selected</cfif>>
							#variables.competitors.Program_Bid_Won_By_Description#
						</option>
						</cfloop>
					</select> <img class="plus4" src="/images/plus4.gif" border="0"> <img src="/images/scissor_blue.gif" border="0" class="cut">
				</td>
			<!--- rate column --->
				<td>
					<input name="#variables.level3Prefix#.rate" type="text" class="rate" <cfif val(variables.competitive.Won_Price) neq 0>value="#NumberFormat(variables.competitive.Won_Price, ',.99')#"</cfif>>
				</td>
			<!--- uom column --->
				<td>
					<select name="#variables.level3Prefix#.uom" class="uom">
						<option></option>
						<option value="1" <cfif variables.competitive.won_UOM eq 1 or (variables.competitive.won_UOM neq 2 and variables.defaultUOM eq 1)>selected</cfif>>CS</option>
						<option value="2" <cfif variables.competitive.won_UOM eq 2 or (variables.competitive.won_UOM neq 1 and variables.defaultUOM eq 2)>selected</cfif>>LB</option>
					</select>
				</td>

			<!--- display custom columns defined in program template settings --->
			<cfloop from="6" to="#arrayLen(variables.columns)#" index="variables.counter">
				<!--- delivery column --->
				<cfif variables.columns[ variables.counter ].name eq variables.names.Delivery>
				<td>
					<cfif variables.templateSettings.Delivery_type>
						<select name="#variables.level3Prefix#.deli" class="deli">
							<option value="">Select Delivery</option>
							<option <cfif variables.competitive.Won_Delivery_Type eq "1">selected</cfif> value="1">FOB</option>
							<option <cfif variables.competitive.Won_Delivery_Type eq "2">selected</cfif> value="2">DEL</option>
						</select>
					</cfif>
				</td>
				<!--- incremental column --->
				<cfelseif variables.columns[ variables.counter ].name eq variables.names.Incremental>
					<td>
						<input name="#variables.level3Prefix#.incr" type="checkbox" class="inc" <cfif variables.competitive.incremental eq "1">checked</cfif>>
					</td>
				<!--- specd column --->
				<cfelseif variables.columns[ variables.counter ].name eq variables.names.Specd>
					<td>
						<input name="#variables.level3Prefix#.spec" type="checkbox" class="spec" <cfif variables.competitive.specd eq "1">checked</cfif>>
					</td>
				<!--- shared column --->
				<cfelseif variables.columns[ variables.counter ].name eq variables.names.Shared>
					<td>
						<input name="#variables.level3Prefix#.shar" type="checkbox" class="shared" <cfif variables.competitive.shared eq "1">checked</cfif>>
					</td>
				<cfelse>
					<td>&nbsp;</td>
				</cfif>
			</cfloop> <!--- from="6" to="#arrayLen(variables.columns)#" index="variables.counter"> --->
           </tr>
         </cfloop>  <!--- query="variables.competitive"> --->
</cfloop>    <!--- query="variables.allProducts"> --->
    </tbody>

    </table>

	<input type="hidden" name="l3Moved2L2" value="#l3Moved2L2#">
	<cfset competitiveCounter = #variables.competitiveCounter# + 1>
	<input type="hidden" name="l3Moved2L2No" value="#competitiveCounter#">

  <div> <!---class="datagridwrapper"--->
  <cfif variables.allProducts.recordCount gt 50>
  </cfif>

  </form>
<div> <!---id="content"--->

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="displayActions" output="true">
  <div id="actions" class="actions">
    <a href="##" class="save">#application.util.string.actionLinkFormat("save")#</a>
    <!---<a href="##" class="reload" style="margin-left:10px;">#application.util.string.actionLinkFormat("start over")#</a>--->
    <a href="##" class="closewindow" style="margin-left:10px;">#application.util.string.actionLinkFormat("close window")#</a>
    <cfif variables.templateSettings.Download_comp_data_history eq '1'>
      <a href="JavaScript:NewWindow('competitive_data_history_download.cfm?contract_number=#trim(variables.contractInfo.Contract_Number)#', 'CompetitiveHistroyDownload', 800, 600, 'yes', 'yes')" style="margin-left:10px;" id="download_comp_data_history">#application.util.string.actionLinkFormat("download history")#</a>
    </cfif>
  </div>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="findCustomLabel" output="true">
  <cfargument name="label" required="true">
	  <cfquery dbtype="query" name="local.query">
	    	SELECT *
	      	FROM vars.labels
	      	WHERE General_Labels_Desc = '#arguments.label#'
	  </cfquery>
  <!--- if there is custom label use the custom label otherwise use BSA label --->
  <cfreturn ( local.query.recordCount gt 0 ? local.query.general_labels_label : arguments.label )>
</cffunction>

 </cfoutput>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js?2014-06-06"></script>

<script type="text/javascript">
var plusMinusCount = 0,
    l3ItemRecordCount = <cfoutput>#variables.competitiveInfo.recordCount#</cfoutput>;

/**********************************************/
/************* Document Ready()  **************/
/**********************************************/
$(function() {
  /**********************************************/
  /****************** Data Grid *****************/
  /**********************************************/
  mydatagrid = $('#datagrid').dataTable({
       "bAutoWidth": false
      ,"bPaginate": false
      ,"bSortClasses": false
      ,"bScrollCollapse": true
      ,"sDom": 'fti'
      ,aaSorting: [ [ 0, "asc"] ]
      ,"aoColumnDefs": [ { "aTargets": [0], "bSearchable": true  },
                         { "aTargets": [1], "bSearchable": true,  "bSortable": true, "sSortDataType": "dom-select", "sClass": "center2" },
                         { "aTargets": [2], "bSearchable": false, "bSortable": false, "sClass": "center2"  },
                         { "aTargets": [3], "bSearchable": false, "bSortable": false, "sClass": "center"  },
                         { "aTargets": [4], "bSearchable": false, "bSortable": false, "sClass": "center"  }
                         // display custom columns without search, without sorting
                         <cfoutput>
                         <cfloop from="6" to="#arrayLen(variables.columns)#" index="variables.counter">
						 	<cfif variables.columns[ variables.counter ].name eq variables.names.Incremental or variables.columns[ variables.counter ].name eq variables.names.Specd or variables.columns[ variables.counter ].name eq variables.names.Shared>
                            ,{ "aTargets": [#(variables.counter - 1)#], "bSearchable": false, "bSortable": false, "sClass": "center"  }
							</cfif>
                         </cfloop>
                         </cfoutput>
                       ]
    }).fnSetFilteringDelay();

  $('select[name=productKind]', this).change( function () {
      mydatagrid.fnFilter( $(this).val(), 0 );
  } );

  /**********************************************/
  /**************** Mass Applying ***************/
  /**********************************************/
  massApply = function() {
      var newCompetitor = $('#mass_competitor option:selected').val()
          ,newRate = $('#mass_rate').val()
          ,newUOM = $('#mass_uom option:selected').val();

      // alert($('.massOne:checked').length)
      $('.massOne:checked').each( function() {

        var trParent = $(this).closest('tr');
        // alert(trParent.html())

        if ( newCompetitor ) {
          $('select.competitor', trParent).val( newCompetitor );
        }


        $('select.won', trParent).val( $('#mass_won').val() );
        $('input.inc', trParent).prop( 'checked', $('#mass_incr').prop('checked') );
        $('input.shared', trParent).prop( 'checked', $('#mass_shared').prop('checked') );
        $('input.spec', trParent).prop( 'checked', $('#mass_specd').prop('checked') );

        if ( newRate ) {
          $('input.rate', trParent).val( newRate );
        }

        if ( newUOM ) {
          $('select.uom', trParent).val( newUOM );
        }

        // flag all level 2 rows as changed (level 3 rows are always passed to form action so no need to flag)
        $('tr.l2').addClass("changed");
      });

      /*reset mass values*/
      if ( 0 ) {
        massReset();
      }
      return false;
    };

    massReset = function() {
      $('#mass_competitor, #mass_rate, #mass_uom, #mass_won').val('');
      $('#mass_won, #mass_incr, #mass_shared, #mass_specd, input.massOne, input[name=massAll]').prop('checked', false);
      return false;
  };

  /***************************************************************/
  /************ hide elements, display progress message **********/
  /***************************************************************/
  hideShow = function( msg ){
      $('div.success, #actions, #mainForm').hide();
      $('#loading').html( msg ).show();
  };

  /**********************************************************/
  /************ events for action links at the top **********/
  /**********************************************************/
  $('a.reload').click( function() {
	 hideShow('Reloading competitive data, please wait...');
	 window.location.href = window.location.href;
	});
  $('a.closewindow').click( function() {
    if (($("tr.l2.changed").length || plusMinusCount) && !confirm("You have not saved your competitive data.\n\n Do you wish to ignore your changes?")) {
      return false;
    };
    window.close();
	});
  $('a.save').click( function() {
      // provides instant feedback on save request
      hideShow("Saving competitive data, please wait...");

      // bring back all elements
      mydatagrid.fnFilter('', 0);
      mydatagrid.fnFilter('');

      // disable level 2 rows that did not change - for faster saving data process
      $("tr.l2").each(function() {
        if ( $(this).hasClass("changed")) {
        }
        else {
         	//$(this).find('input, select').attr("disabled", "disabled");
        }
      });

      $('#mainForm').submit();
  });

  /**********************************************/
  /************** Show info on page *************/
  /**********************************************/
  $('#loading').hide();
  $('#mainForm, div.actions').show();


  /**********************************************/
  /************** Adding of a row ***************/
  /**********************************************/
  plus4 = function( t ) {
    // grap the current tr row & save it into a jQuery object
    var $trParent = $(t).closest('tr');

    var item = $trParent.find('td:first').html().replace('CHECKED', '');
    var competitor = $trParent.find('td:nth-child(3)').html().replace('selected', '');

    // add scissor icon if it does not exist
    if ( competitor.search('scissor_blue.gif') == -1)
      competitor = competitor + ' <img src="/images/scissor_blue.gif" border="0" class="cut">';

    var won = $trParent.find('td:nth-child(2)').html().replace('selected', '').replace('value=pending', 'selected value=pending');
    var rate = $trParent.find('td:nth-child(4)').html().replace('value', 'foo');
    var uom = $trParent.find('td:nth-child(5)').html().replace('selected', '').replace('value=<cfoutput>#variables.defaultUOM#</cfoutput>', 'selected value=<cfoutput>#variables.defaultUOM#</cfoutput>');

	var s = $trParent.find('td:nth-child(6)').html();
	//var delivery = $trParent.find('td:nth-child(6)').html().replace('selected', '');
    var newEntry = mydatagrid.fnAddData([	item,
 											won,//'&nbsp;',
                                           	competitor,
                                            rate,
                                           	uom
											//delivery
                                           <cfloop from="6" to="#arrayLen(variables.columns)#" index="variables.counter">
                                                <cfoutput>,$trParent.find('td:nth-child(#variables.counter#)').html().replace('CHECKED', '').replace('selected', '').replace('value', 'foo')</cfoutput>
                                           </cfloop>
                                        ]);
	
    var nTr = mydatagrid.fnSettings().aoData[ newEntry[0] ].nTr;
    l3ItemRecordCount++;
    plusMinusCount++;         // keep track of number of clicks on plus icon
    nTr.setAttribute('id', 'tr' + l3ItemRecordCount);

    // add click events to the new row
    var $newEntry = $('#tr' + l3ItemRecordCount)
        ,newPrefix = 'l3.item' + l3ItemRecordCount;

    // assign new unique names to elements of this new row
    //$newEntry.find('input:eq(1)').attr('name',  newPrefix + '.id');
	//$newEntry.find('input:eq(2)').attr('name',  newPrefix + '.rate');
	//$newEntry.find('select:eq(0)').attr('name', newPrefix + '.comp');
    //$newEntry.find('select:eq(1)').attr('name', newPrefix + '.uom');
    //$newEntry.find('select:eq(2)').attr('name', newPrefix + '.deli');
	
	$newEntry.find("input[name*='id']").attr('name',  newPrefix + '.id');
	$newEntry.find("input[name*='rate']").attr('name',  newPrefix + '.rate');
	$newEntry.find("select[name*='won']").attr('name',  newPrefix + '.won');
	$newEntry.find("select[name*='comp']").attr('name',  newPrefix + '.comp');
   	$newEntry.find("select[name*='uom']").attr('name',  newPrefix + '.uom');
    $newEntry.find("select[name*='deli']").attr('name',  newPrefix + '.deli');
	$newEntry.find("input[name*='incr']").attr('name',  newPrefix + '.incr');
	$newEntry.find("input[name*='spec']").attr('name',  newPrefix + '.spec');
	$newEntry.find("input[name*='shar']").attr('name',  newPrefix + '.shar');
    // keep track of number of level 3 entries, to pass to the form action page
    $('input[name="L3.item.recordCount"]').val( l3ItemRecordCount );
  };

  /**********************************************/
  /************* Deleting of a row **************/
  /**********************************************/
  cut = function( t ) {
    var $trParent = $(t).closest('tr');
    mydatagrid.fnDeleteRow( $trParent[0] );
	plusMinusCount++;         // keep track of number of clicks on scissor icon
  };

  /**********************************************/
  /**************** Date Picker *****************/
  /**********************************************/
  $('#date_source_received').datepicker( { numberOfMonths: 2 } );

  /**********************************************/
  /************NEW Mass Apply*************/
  /*********************************************/

  $('a.massapply').click( function() {
  	 //var datasave = confirm("Did you save changes you made?");
	 var datasave = true;
	 var id = <cfoutput>#form.Contract_Main_ID#</cfoutput>;
		 if(datasave){
			window.open ('competitive_data_mass_apply.cfm?Contract_Main_ID=' + id, 'CompetitiveDataMassApply','location=0,status=0,scrollbars=1,resizable=1, width=750,height=600');
		 }
  	});

  /**********************************************/
  /*************  EVENT DELEGATIONS *************/
  /**********************************************/
  // flag level 2 rows that have changes - unchanged level 2 rows are disabled for quicker saving data
  // level 3 rows are NOT disabled due to deletion is allowed on them
  $('tbody').on('change', 'tr.l2 input, tr.l2 select', function(e) {
                  $(e.target).closest('tr').addClass("changed");
                });

  // allow only numeric keys on rate inputs
  $('table').on('keydown', 'input.rate', function(e) {
                  var key = e.which || e.keyCode;
                  if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
                     ( key >= 48 && key <= 57 ) ||    <!---numbers--->
                     ( key >= 96 && key <= 105 ) ||   <!---Numeric keypad--->
                     key == 190 || key == 188 || key == 109 ||  key == 189 || <!---comma, period and minus--->
                     key == 8 || key == 9 || key == 13 ||  <!---Backspace and Tab and Enter--->
                     key == 35 || key == 36 ||             <!---Home and End--->
                     ( key >= 37 && key <= 40 ) ||         <!---left, up and right, down arrows--->
                     key == 110 ||                         <!---Decimal point on numeric keypad--->
                     key == 46 || key == 45) {             <!---Del and Ins--->
                    return true;
                  }
                  return false;
                });

  $('tbody').on('click', 'img', function(e) {
                  var target = e.target;
                  switch( target.className.toLowerCase()) {
                    case 'plus4': plus4( target ); break;
                    case 'cut': cut( target ); break;
                    default:
                  }
                })
            .on('change', 'input.massOne', function(e) {
              var target = e.target;
              // this product is not checked flip the check all box at the top to not checked
              if ( !$(target).prop('checked') ) {
                $('input[name=massAll]').prop('checked', false );
              }
            });
});
<cfif ( cgi.request_method eq "post" )>
  // refresh view program with newly saved data
  if (window.opener)
    window.opener.location.reload();

  setTimeout(function() { $("div.success").hide('slow'); }, 1750);
</cfif>

 // disable column sorting when user clicks on the 1st column filter dropdown
 $("thead select").click( function (e) {
    stopTableSorting(e);
    this.focus();
  });

 $('input[name=massAll]').change( function(e) {
  $('input.massOne').prop('checked', this.checked );
  e.stopPropagation();
 });
</script>
</body>
</html>