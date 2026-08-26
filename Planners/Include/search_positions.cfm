<!-----------------------------------------------------------------------------------------------------------------------------------------
Name         :  /planners/include/search_positions.cfm
Created Date :  2017 July
Created By   :  Chris Nguyen
Description  :  Display search positions criteria

Remarks      :
----------------------------------------------------------------------------------------------------------------------------------------->
<style>
	div#filters, div#actions {
		margin: 0 auto;
		width: 96%;
		float:left;
		min-width: 300px;
	}
	div#filters > div {
		float: left;
		margin: 1.5%;
		width: 30%;
	}
	label {
		display: block;
		font-weight: bold;
		margin-bottom: 4px;
	}
	input[type=text] {
		width: 90%;
	}
	.dropdown {
		min-width: 150px;
	}
	label[for="include_deleted"] {
		display: inline;
		position: relative;
		top: -1px;
	}
	div#actions > a {
		margin: 25px;
	}
</style>

<cf_include files="/styles/jQueryUI_18/jquery.multiselect.css, /styles/jQueryUI_18/jquery-ui-1.8.14.custom.css">

<cf_include files="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js">


<cfscript>
	param name="form.service_zone_id"   default="";
	param name="form.service_region_id" default="";
	param name="form.service_market_id" default="";
	param name="form.search_level"      default=-1;
	param name="form.user_positions_id" default="";
	param name="form.label"             default="";
	param name="form.include_deleted"   default="";
</cfscript>


<cfquery name="qZones" datasource="#application.datasource#">
	SELECT *
	  FROM Service_Zones
	 WHERE Zone_Name > '' AND Deleted = 0
	 ORDER BY Zone_Name
</cfquery>
<cfquery name="qRegions" datasource="#application.datasource#">
	SELECT *
	  FROM Service_Regions
	 WHERE Region_Name > '' AND Deleted = 0
	 ORDER BY Region_Name
</cfquery>
<cfquery name="qMarkets" datasource="#application.datasource#">
	SELECT *
	  FROM Service_Markets
	 WHERE Market_Name > '' AND Deleted = 0
	 ORDER BY Market_Name
</cfquery>

<cfquery name="qPositions" datasource="#application.datasource#">
	SELECT 	*
	  FROM 	User_Positions
	 WHERE 	Position_Label > '' AND Deleted = 0
			<cfswitch expression="#form.search_level#">
				<cfcase value="0"><!--- retrive hq positions only --->
						AND		User_Positions.Service_Zone_ID IS NULL
						AND		User_Positions.Service_Region_ID IS NULL
						AND		User_Positions.Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="1"><!--- retrive zone level positions only --->
						AND		User_Positions.Service_Zone_ID IS NOT NULL
						AND		User_Positions.Service_Region_ID IS NULL
						AND		User_Positions.Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="2"><!--- retrive region level positions only --->
						AND		User_Positions.Service_Zone_ID IS NOT NULL
						AND		User_Positions.Service_Region_ID IS NOT NULL
						AND		User_Positions.Service_Market_ID IS NULL
				</cfcase>
				<cfcase value="3"><!--- retrive market level positions only --->
						AND		User_Positions.Service_Zone_ID IS NOT NULL
						AND		User_Positions.Service_Region_ID IS NOT NULL
						AND		User_Positions.Service_Market_ID IS NOT NULL
				</cfcase>
		</cfswitch>
	ORDER BY Position_Label
</cfquery>

<cfset sales_hier_levels
	   			= ["Headquarters"
	   				, "#application.returned_customer_setting.zone_label_plural#"
	   				, "#application.returned_customer_setting.region_label_plural#"
	   				, "#application.returned_customer_setting.market_label_plural#"
				]>

<cfoutput>
<form name="search_positions" id="search_positions" method="post" style="margin-left: 20px; min-width: 600px;float:left;">
	<cfset saveHiddenValues()>

	<div id="filters">
		<div>
			<label for="service_zone_id">#application.returned_customer_setting.zone_label_singular#</label>
			<select name="service_zone_id" id="service_zone_id" class="dropdown" multiple="multiple">
				<cfloop query="qZones">
					<option value="#qZones.Service_Zone_ID#" <cfif form.service_zone_id eq qZones.Service_Zone_ID>selected</cfif>>#qZones.Zone_Name#</option>
				</cfloop>
			</select>
		</div>

		<div>
			<label for="service_region_id">#application.returned_customer_setting.region_label_singular#</label>
			<select name="service_region_id" id="service_region_id" class="dropdown" multiple="multiple">
				<cfloop query="qRegions">
					<option value="#qRegions.Service_Region_ID#" <cfif form.service_region_id eq qRegions.service_region_id>selected</cfif>>#qRegions.Region_Name#</option>
				</cfloop>
			</select>
		</div>

		<div>
			<label for="service_market_id">#application.returned_customer_setting.market_label_singular#</label>
			<select name="service_market_id" id="service_market_id" class="dropdown" multiple="multiple">
				<cfloop query="qMarkets">
					<option value="#qMarkets.service_market_id#" <cfif form.service_market_id eq qMarkets.service_market_id>selected</cfif>>#qMarkets.Market_Name#</option>
				</cfloop>
			</select>
		</div>


		<div>
			<label for="user_positions_id">Position Under</label>
			<select name="user_positions_id" id="user_positions_id" class="dropdown" multiple="multiple">
				<cfloop query="qPositions">
					<option value="#qPositions.user_positions_id#" <cfif qPositions.user_positions_id eq form.user_positions_id>selected</cfif>>#qPositions.Position_Label#</option>
				</cfloop>
			</select>
		</div>

		<div>
			<label for="search_level">Sales Hierarchy Level</label>
			<select name="search_level" id="search_level" class="dropdown" multiple="multiple">
				<cfset lvlCounter = 0 />
				<cfloop array="#sales_hier_levels#" index="lvl">
				<option value="#lvlCounter#">#lvl#</option>
				<cfset lvlCounter = lvlCounter + 1 />
				</cfloop>
			</select>
		</div>

		<div>
			<label for="label">Label</label>
			<input name="label" id="label" type="text" value="#form.label#">
		</div>

		<div>
			<a href="##" id="search">#application.util.string.linkFormat("search", "primary")#</a>
			<a href="##" id="reset">#application.util.string.linkFormat("reset", "secondary")#</a>
		</div>

		<div>
			<input name="include_deleted" id="include_deleted" type="checkbox" value="1">
			<label for="include_deleted"> Include Deleted Positions</label>
		</div>


	</div>


</form>
</cfoutput>

<script>
	$(document).ready(function() {
		var started = +(new Date);
		$('.dropdown').multiselect({
			 checkAllText:"Select All"
			,uncheckAllText:"Unselect All"
			,selectedText: function(numChecked, numTotal, checkedItems){
				  if (numChecked == numTotal) {
					return 'Selected All';
				  }
				  else {
					return numChecked + ' of ' + numTotal + ' selected';
				  }
			   }
		});
		var ended = +(new Date);
	});

	$("#search").click( function() {
		show_loader();
		$("#search_positions").submit();
	});

	$("#reset").click(function() {
		$("#search_positions").trigger("reset");
	});
</script>