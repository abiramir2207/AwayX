<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 11-Mar-2019
  *  @Remarks: New EDI Viewer
  *  Code for the detail content area for the optional details tabs
  *  Loaded in EDIViewer_Main via ajax, due to dynamic tabs
  *
  *
  * ====================================================================================================
--->
<cfparam name="URL.id" default="0">
<cfparam name="URL.BBNum" default="">
<cfparam name="URL.BBDate" default="">
<cfparam name="URL.SoldToName" default="">
<cfparam name="URL.SoldToNum" default="">
<cfparam name="URL.TotalAmt" default="">
<cfparam name="URL.VendorName" default="">
<cfparam name="URL.VendorNum" default="">
<cfparam name="URL.Volume" default="">

<cfset local.arrowDown =  "/images/arrow-d-blue-12.png" />
<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />

<!--- The ID is a combination of uploadID and BBUploadIIIPHID. --->
<cfset uploadID = ListFirst(URL.ID, "_")>
<cfset BBUploadIIIPHID = ListLast(URL.ID, "_")>

<button type="button" onClick="closeDetailTab('<cfoutput>#URL.id#</cfoutput>');" class="button recommended">Close</button>
<button type="button" onClick="downloadDetails('<cfoutput>#URL.BBNum#</cfoutput>');" class="button">Download</button>

<!-------------------------------------------------------------------------------------->
<!--------------------------------- DETAILS SECTION ------------------------------------>
<!-------------------------------------------------------------------------------------->
<button id="detailSectionBtn" class="sectionHeader pl-2 mt-2" onclick="toggleSection(this)">
	<img src=<cfoutput>#local.arrowDown#</cfoutput> alt="expand/collapse" style="padding:5px 3px 0 0;"> Details
</button>
<div class="sectionContents text-xs">
	<fieldset id="EDIDetailsSection" class="fieldGroup viewOnly p-2 w-full">
		<!--- TODO: All these "label"s should be from the labels table --->
		<!--- TODO: All the data is fake, should be from the db --->
		<div class="flex mb-2">
		<cfoutput>
			<div class="w-1/2 detail viewOnly">
				<label>Billback ##:</label>
					<span>#URL.BBNum#</span><br>
				<label>Pymt Recipient Name:</label>
					<span>#URL.VendorName#</span><br>
				<label>Total Amount:</label>
					<span>#URL.TotalAmt#</span><br>
			</div>
			<div class="w-1/2 detail viewOnly">
				<label>Billback Date:</label>
					<span>#URL.BBDate#</span><br>
				<label>Sold To Number:</label>
					<span>#URL.SoldToNum#</span><br>
				<label>Volume:</label>
					<span>#URL.Volume#</span><br>
			</div>
			<div class="w-1/2 detail viewOnly">
				<label>Pymt Recipient Number:</label>
					<span>#URL.VendorNum#</span><br>
				<label>Sold To Name:</label>
					<span>#URL.SoldToName#</span><br>
			</div>
		</cfoutput>	
		</div>
	</fieldset>
</div>


<cfoutput> 
<div class="sectionBanner pl-2 mt-1">
	Results: <span id="edi_detail_grid_count_#URL.id#"></span> 
</div>
<!----------------->
<!-----  GRID ----->
<!----------------->
<!--- Use a unique ID as part of the DIV ID, so that every tab can have it's own grid. --->
<div id="RawEDIDetail_Grid_#URL.id#" class="ag-theme-balham edi_grid"></div>
</cfoutput>
<cfinclude template="RawEDIDetailGridManager.cfm">


<!-------------------------------------------------------------------------------------->
<!--------------------------------- SCRIPTS -------------------------------------------->
<!-------------------------------------------------------------------------------------->
<script>
	function downloadDetails(BBNum) {
		NewWindowTopLeft("/downloadEDIFile.cfm?BBNumber=" + BBNum, "EDIDetails", 300, 200, "yes", "yes");
	}

	var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
	var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';

	// handler for clicking section headers
	var toggleSection = function(el) {
		var imgUrl = $(el).children(0).attr('src');
		if ( imgUrl == arrowDown ) {
			$(el).children(0).attr("src", arrowRight);
		}else {
			$(el).children(0).attr("src", arrowDown);
		}
        $(el).next().toggle();        // show/hide div
        resize_ag_grid();
	};

	// Init Noty
	Noty.overrideDefaults({
		closeWith: ["click", "button"],
		layout: "center",
		killer: true,
		theme: "metroui",
		timeout: false,
		type: "error"
	});

    resize_ag_grid();
</script>