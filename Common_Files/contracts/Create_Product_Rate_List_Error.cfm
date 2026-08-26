<!---
Name:        Create_Product_Rate_List_Error.cfm
Copyright (c) 2016 Blacksmith Applications, Inc.
Description: Used to Display Errors in upload items/rate/UOM.
--->
<cfmodule template="/customTags/layout.cfm"  selectedIndex = 0><br>
<cfparam name="url.selectedTab" default="0">
<cfparam name="selectedTab" default="#url.selectedTab#">
<cfparam name="url.programId" default="0" />
<cfparam name="form.PricingLevelSelection" default="0"/>
<cfparam name="filename" default ="Invalid Items"/>
<cfparam name="url.discountype" default ="0"/>

<cfset tablename = '####'&#replace(request.AccessStructure.User_ID,'-','_','ALL')#&'_Program_upload_'&#url.programId#>

<cfquery name="Select_tempdb" datasource="#application.datasource#">
  <cfif selectedTab EQ 0 OR selectedTab EQ 1>
      SELECT  *
      FROM #tablename#
     WHERE
      <CFIF selectedTab EQ 0>
          Invalid = 1 OR Duplicate = 1
      <CFELSE>
         Duplicate = 0 AND Removed = 1
      </CFIF>
  <cfelseif selectedTab EQ 3>
      SELECT  DISTINCT PGL.Group_Level_Desc, PGL.Product_Group_Level_ID
      FROM #tablename# T
      INNER JOIN All_Product_Group_Types APG
      ON APG.Group_GUID = T.BSA_Foodservice_Items_Master_ID
			INNER JOIN Product_Group_Level PGL
			ON PGL.Product_Group_Level_ID = APG.Product_Group_Level_ID
      WHERE T.Removed = 0
      AND APG.Deleted = 0
      AND Isgroup = 1
  <cfelse>
  
  		IF OBJECT_ID('tempdb..##tmp_oldrate') IS NOT NULL
		DROP TABLE ##tmp_oldrate

		SELECT DISTINCT T.Program_ID, T.BSA_Foodservice_Items_Master_ID, T.Comp_ID, PRCD.rate
		INTO	##tmp_oldrate
		FROM #tablename# T
		
		INNER JOIN Contract_Products cp
		ON		cp.Contract_Main_ID = T.Program_ID
		AND		cp.BSA_Foodservice_Items_Master_ID = T.BSA_Foodservice_Items_Master_ID
		AND		cp.Deleted = 0
		AND		cp.Captured_From_Group = 0
		
		INNER JOIN Program_Rebates_Product_Data PRPD 
		ON		PRPD.Contract_Products_ID = cp.Contract_Products_ID
		AND		PRPD.Deleted = 0
		
		INNER JOIN Program_Rebates_Component PRC 
		ON PRC.program_id = T.program_id 
		AND T.Comp_ID = PRC.Program_Rebates_Component_ID
		AND PRC.Deleted =0 
		
		INNER JOIN Program_Rebates_Component_Data PRCD 
		ON PRCD.Program_Rebates_Component_ID = PRC.Program_Rebates_Component_ID 
		AND PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
		AND ISNULL(PRCD.Deleted, 0) = 0 
		
		WHERE T.program_id = #url.programid# 
  
		SELECT T.Products_id,T.rate, isnull(old.rate, 0) AS oldRate
		FROM #tablename# T
		LEFT JOIN ##tmp_oldrate old 
		ON		old.Program_ID = T.Program_ID
		AND		old.BSA_Foodservice_Items_Master_ID = T.BSA_Foodservice_Items_Master_ID
		AND		old.Comp_ID = T.Comp_ID
		WHERE  T.Products_id is not null
  </cfif>
</cfquery>

<cfquery name="CheckItems" datasource="#application.datasource#">
	SELECT  *
	FROM #tablename# T
	WHERE T.Removed = 0
	AND Isgroup = 0
</cfquery>

<cfset LevelCount = Select_tempdb.recordcount />
<cfif request.AccessStructure.numberOfProductGroupLevels eq 3>
	<cfif CheckItems.recordcount>
		<cfset LevelCount = LevelCount + 1 />
	</cfif>	
</cfif>
		  
<cf_include file_to_include="/common_files/tabnav.css"/>
<cfsavecontent variable="linksContent">
	<div align="center">
		<cfoutput>
		<cfif URL.selectedTab NEQ 3>
			<a href="javascript:getCSVData();" class="action">#application.util.string.actionLinkFormat('export')#</a>
		</cfif>
		
		<cfif URL.selectedTab EQ 3 AND LevelCount NEQ 1 AND LevelCount LTE request.AccessStructure.numberOfProductGroupLevels>
			<a href="javascript:PricingLevel();">#application.util.string.actionLinkFormat('Continue')#</a>
		<!---<cfelse>
			<a href="javascript:history.go(-2);">#application.util.string.actionLinkFormat('back')#</a>--->
		</cfif>
			<a href="javascript:self.close();" class="action">#application.util.string.actionLinkFormat('close')#</a>
		</cfoutput>
	</div>
</cfsavecontent>

<cfoutput>
<div class="nav">
    <ul class="nav">
      <cfif selectedTab NEQ 3>
        <!--- HIDE THESE LINKS WHEN USER IS IN PRICING LEVEL SELECTION PAGE --->
        <li <cfif selectedTab EQ 0>class="active"</cfif>>
            <a class="topnav" href="Create_Product_Rate_List_Error.cfm?type=Invalid&discountype=#url.discountype#&selectedTab=0&programId=#url.programId#">Invalid/Duplicate Records</a>
        </li>
        <li <cfif selectedTab EQ 1>class="active"</cfif>>
            <a class="topnav" href="Create_Product_Rate_List_Error.cfm?type=removed&discountype=#url.discountype#&selectedTab=1&programId=#url.programId#">Removed Records</a>
        </li>
        <li <cfif selectedTab EQ 2>class="active"</cfif>>
            <a class="topnav" href="Create_Product_Rate_List_Error.cfm?type=details&discountype=#url.discountype#&selectedTab=2&programId=#url.programId#">Details</a>
        </li>
      <cfelse>
        <!--- HIDE THIS LINK WHEN USER WANTS TO VIEW DATA --->
        <li <cfif selectedTab EQ 3>class="active"</cfif>>
            <a class="topnav" href="Create_Product_Rate_List_Error.cfm?type=details&discountype=#url.discountype#&selectedTab=3&programId=#url.programId#">Pricing Level Picker</a>
        </li>
      </cfif>
    </ul>
</div>
</cfoutput>
<!--- SUBMIT PRICING LEVEL SECTION FORM START --->
<cfif form.PricingLevelSelection>
	<cfloop from="1" to="#listlen(form.Pricinglist)#" index="level">
		<cfset Id = listgetat(form.Pricinglist, level)>
		<cfset selection = evaluate("form.PricingLevelSelection_#id#")>
		<cfquery name="Update_tempdb" datasource="#application.datasource#">
			UPDATE #tablename#
			SET Pricing_Level_Id = #selection#
			WHERE Product_Group_Level_Id = #ID#
			AND IsGroup = 1
			AND Valid = 1
		</cfquery>
	</cfloop>
	<cfif isdefined('form.ItemPricingList')>
		<cfquery name="Update_Items_tempdb" datasource="#application.datasource#">
			UPDATE #tablename#
			SET Pricing_Level_Id = #form.ItemPricingList#
			WHERE IsGroup = 0
			AND Valid = 1
		</cfquery>
	</cfif>

  <cfset uploaddata = createObject("component","components.programs.rebates.Rebate").FinalUploadSave(url.programId,tablename,url.discountype)/>

<script type="text/javascript">
	window.opener.location.reload();	
	self.close();
</script>
</cfif>
<!--- SUBMIT PRICING LEVEL SECTION FORM END --->
<cfif URL.selectedTab EQ 3>
<cfoutput>
	<cfif LevelCount GT request.AccessStructure.numberOfProductGroupLevels>
		<div style="color:red;border:solid; margin:5px;padding:2px;">
			A program cannot have Pricing level greater than #request.AccessStructure.numberOfProductGroupLevels#.<br>You can add only #request.AccessStructure.numberOfProductGroupLevels# different product group id groups to a program.
		</div>
	</cfif>
<form action="create_product_rate_list_error.cfm?type=details&selectedTab=3&programId=#url.programId#&discountype=#url.discountype#" method="post" name="PricingLevelSelection" id="PricingLevelSelection">
	<table class="datagrid">
		<thead>
		<tr>
			<th>Group Level ID</th>
			<th>Group Description</th>
			<th>Pricing Level</th>
		</tr>
		</thead>
		<cfset PricingLevelList = ''>
		<cfset i = 1>
		<cfloop query="Select_tempdb" >
		<cfset PricingLevelList = listappend(PricingLevelList, #Product_Group_Level_ID#)>
		<tr>
			<td>#Product_Group_Level_ID#</td>
			<td>#Group_Level_Desc#</td>
			<td>
				<cfif Select_tempdb.recordcount EQ 1>
					Pricing Level  #Select_tempdb.recordcount#
				<cfelse>
				<select name="PricingLevelSelection_#Product_Group_Level_ID#" id="PricingLevelSelection_#i#">
					<option value="0">Select Pricing Level</option>
				<cfloop from="1" to="#Select_tempdb.recordcount#" index="levels">
					<option value="#levels#">#levels#</option>
				</cfloop>
				</select>
				</cfif>
			</td>
		</tr>
		<cfset i = i +1>
		</cfloop>
		<cfif CheckItems.recordcount>
		<tr>
			<td>All Items</td>
			<td>All Items</td>
			<td>
				<cfset ItemPricingList = #Select_tempdb.recordcount# + 1>
				Pricing Level  #ItemPricingList#
				<input type="hidden" value="#ItemPricingList#" name="ItemPricingList"/>
			</td>
		</tr>
		</cfif>
	</table>
	<input type="hidden" value="#PricingLevelList#" name="PricingList"/>
	<input type="hidden" value="1" name="PricingLevelSelection"/>
</form>
</cfoutput>
<cfelse>
	<table class="datagrid">
		<thead>
		<tr>
			<th><b>Product ID</b></th>
			<th><b>Rate</b></th>
		<cfif selectedTab EQ 0 OR selectedTab EQ 1>
			<th><b>UOM</b></th>
			<th><b>Reason</b></th>
		<cfelse>
			<th><b>Previous Rate</b></th>
			<th><b>Program Change</b></th>
		</cfif>
		</tr>
		</thead>
		<tbody>
		<cfoutput query="Select_tempdb" >
		<tr>
			<td>#Products_ID#</td>
			<td>
				<cfif IsNumeric(Rate)>
					#dollarformat(Rate)#
				<cfelse>
					#trim(Rate)#
				</cfif>
			</td>
		<cfif selectedTab EQ 0 OR selectedTab EQ 1>
			<td><cfif UOM EQ 1>CS<cfelseif  UOM EQ 2>LB<cfelse>#UOM#</cfif></td>
			<td>#Reason#</td>
		<cfelse>
		<cfif IsNumeric(Rate)>
			<cfset variance = rate - oldRate>
		<cfelse>
			<cfset variance = oldRate>
		</cfif>
			<td>#dollarformat(oldRate)#</td>
			<td>#dollarformat(variance)#</td>
		</cfif>
		</tr>
		</cfoutput>
		</tbody>
	</table>
</cfif>

	<cfoutput>#linksContent#</cfoutput>

<form action="/common_files/csv.cfm" method ="post" id="csv_form">
	<input type="hidden" name="csv_text" id="csv_text">
	<input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

	<cfif URL.selectedTab EQ 0>
		<cfset filename ="Invalid Items">
	<cfelseif URL.selectedTab EQ 1>
		<cfset filename ="Removed Items">
	<cfelseif URL.selectedTab EQ 2>
		<cfset filename ="Details">
	</cfif>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css,/Script/javascript/jquery.dataTables-api.js,/script/javascript/table2csv.js"/>
<script>
	var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
	oTable = $('.datagrid').dataTable( {
						  "bServerSide": false
						, "bProcessing": false
						, "bSortClasses": false
						, "bAutoWidth": false
						, "oLanguage": {"sSearch": "<b>Search:</b>"}
						, "sScrollY": sScrollY
						, "sDom": "prt"
						, "iDisplayLength":500
						, "bPaginate":true
						, "aaSorting": []
						, "aoColumns": [  {"bSearchable": true,  "bSortable":true}
								, {"bSearchable": false,   "bSortable":true}
								, {"bSearchable": false,   "bSortable":true}
							<cfif URL.selectedTab NEQ 3>
								, {"bSearchable": false,   "bSortable":true}
							</cfif>
							]
					    } ).fnSetFilteringDelay();
	getCSVData = function() {
		var csv_value = $('.datagrid').table2CSV({ sScrollY: 1 });
		$("#csv_file_name").val("<cfoutput>#replace(filename,' ', '_', 'all')#</cfoutput>_" + random367() + ".csv");
		$("#csv_text").val(csv_value);
		$("#csv_form").submit();
	}
	function updatePL(){
		document.getElementById("PricingLevelSelection").submit();
	}
	function validation(){
		window.location = 'Create_Product_Rate_List.cfm?programId=<cfoutput>#url.programId#</cfoutput>';
	}
	function PricingLevel(){
		document.getElementById('PricingLevelSelection').submit();
	}
</script>
</cfmodule>