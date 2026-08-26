<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 11-Mar-2019
  *  @Remarks: New EDI Viewer
  *  Code for the main content area for the Raw EDI tab
  *  Template loaded in EDIViewer_Main
  *
  *
  * ====================================================================================================
--->

<cfset local.arrowDown =  "/images/arrow-d-blue-12.png" />
<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />

<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />

<!-------------------------------------------------------------------------------------->
<!--------------------------------- SEARCH SECTION ------------------------------------->
<!-------------------------------------------------------------------------------------->
	<button id="searchSectionBtn" class="sectionHeader pl-2" onclick="toggleSearchSection(this)">
		<img src=<cfoutput>#local.arrowDown#</cfoutput> alt="expand/collapse" style="padding:5px 3px 0 0"> Search
</button>

	<div class="sectionContents text-xs w-full">
		<form id="EDISearchForm" name="EDISearchForm">
			<fieldset id="EDISearchSection" class="fieldGroup p-2 w-full">
				<cfoutput>
				<div class="flex mb-1">
					<!--- Column 1 --->
					<div class="w-1/3 detail whitespace-no-wrap">
						<label>ID:</label>
						<input type="text" name="upload_id" id="upload_id" class="border rounded mr-1" value=""><br>
						<label>#stBBLabels.Billback# Date:</label>
						<input type="text" id="bb_date" name="bb_date" class="border rounded mr-1" value=""><br>
						<label>#application.returned_customer_setting.shard_ship_to_label#  ##:</label>
						<input type="text" name="payee_number" id="payee_number" class="border rounded mr-1" value=""><br>
						<label>Volume:</label>
						<input type="text" name="volume" id="volume" class="border rounded mr-1" value=""><br>
						<label>Cust Promo Code:</label>
						<input type="text" name="agreement_number" id="agreement_number" class="border rounded mr-1" value=""> 
					</div>
					<!--- Column 2 --->
					<div class="w-1/3 detail whitespace-no-wrap">
						<label>Hdr ID:</label>
						<input type="text" name="hdr_id" id="hdr_id" class="border rounded mr-1" value=""><br>
						<label>#stBBLabels.Vendor# ##:</label>
						<!---  NOTE: The popup which populates this textbox requires the name of the textbox to be "Vendor_ID" (case sensitive) --->
						<input type="text" name="Vendor_ID" id="Vendor_ID" class="border rounded mr-1">
						<a id="vendorPopup"  href="##" onclick="popupVendor();return false;">
								<i class="fa fa-search btn-icon"></i>
							</a>						
						<br>
						<label>#application.returned_customer_setting.shard_ship_to_label# Name:</label>
						<input type="text" name="payee_name" id="payee_name" class="border rounded mr-1" value=""><br>
						<label>Deleted By:</label>
						<input type="text" name="deleted_by" id="deleted_by" class="border rounded mr-1" value=""><br>
						<label>Cust Promo Desc:</label>
						<input type="text" name="agreement_name" id="agreement_name" class="border rounded mr-1" value="">
					</div>
					<!--- Column 3 --->
					<div class="w-1/3 detail whitespace-no-wrap">
						<label>#stBBLabels.Billback# ##:</label>
						<input type="text" name="bb_number" id="bb_number" class="border rounded mr-1" value=""><br>
						<label>#stBBLabels.Vendor# Name:</label>
						<input type="text" name="vendor_name" id="vendor_name" class="border rounded mr-1" value=""><br>
						<label>Total Amount:</label>
						<input type="text" name="total_amt" id="total_amt" class="border rounded mr-1" value=""><br>
						<label>Deleted Date:</label>
						<input type="text" name="deleted_date" id="deleted_date" class="border rounded mr-1" value=""><br>
						<!--- fake to layout buttons under the input boxes  --->
                        <label></label>
                        <span style="display:inline-block;position:relative;top:5px;left:-8px;">
                            <button type="button" onClick="loadRawEDIData()" class="button recommended">Search</button>
                            <button type="button" onClick="clearSearchSection();" class="button">Reset</button>
                            <button type="button" onClick="closeAllEdit();" class="button">Close All Edit</button>
                        </span>
					</div>                    
				</div>
				</cfoutput>
			</fieldset>
		</form>
	</div>


	<div class="sectionBanner pl-2 mt-1">
		Results: <span id="edi_grid_count"></span>  
	</div>

	<!----------------->
	<!-----  GRID ----->
	<!----------------->
	<div id="RawEDI_Grid" class="ag-theme-balham edi_grid"></div>
	<cfinclude template="RawEDIGridManager.cfm">
    

<!-------------------------------------------------------------------------------------->
<!--------------------------------- SCRIPTS -------------------------------------------->
<!-------------------------------------------------------------------------------------->
<script>
	var arrowDown  = '<cfoutput>#local.arrowDown#</cfoutput>';
	var arrowRight = '<cfoutput>#local.arrowRight#</cfoutput>';

	// handler for clicking section header
	var toggleSearchSection = function(el) {
		var imgUrl = $(el).children(0).attr('src');
		if ( imgUrl == arrowDown ) {
			$(el).children(0).attr("src", arrowRight);
		}else {
			$(el).children(0).attr("src", arrowDown);
		}
        $(el).next().toggle();        // show/hide div
        
        resize_ag_grid();        
	};

	<!--- Clear the search "form" data --->
	function clearSearchSection() {
		document.getElementById("EDISearchForm").reset();
	}

	function popupVendor() {
		NewWindowTopLeft("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=EDISearchForm&ReloadForm=0&FieldName=Vendor_ID&PageSource=VendorSearch", "payeesearchwindow", 850, 600, "yes", "yes");
	}

    function closeAllEdit() {
        $("div[id^=content-]").each(function(){
            closeDetailTab($(this).attr("id").replace("content-", ""));
        });
        $('#rawTab').click();
    }

	<!--- Date picker for Billback date search --->
	$( function() {
		$( "#bb_date" ).datepicker({
		changeMonth: true,
		changeYear: true,
		// showOn: "button",
		showOn: "both",
		buttonImage: "/images/calendar.gif",
		buttonImageOnly: true,
		buttonText: "Select date"
		});
	} );
	$( function() {
		$( "#deleted_date" ).datepicker({
		changeMonth: true,
		changeYear: true,
		// showOn: "button",
		showOn: "both",
		buttonImage: "/images/calendar.gif",
		buttonImageOnly: true,
		buttonText: "Select date"
		});
	} );

</script>
