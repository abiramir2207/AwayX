<!---
       Name:          UploadHistoryLog.cfm
       Copyright:     Copyright (c) 2019 Blacksmith Applications, Inc.
       Created Date:  15-Nov-2019
       Created By:    Anand Rao
       Label:		  
       Description:  Code for the main content area for the Upload History
--->

<cfparam name="FORM.showSearchForm"	default="0" />
<cfparam name="FORM.Upload_Type"	default="0" />
<cfparam name="FORM.Uploaded_User"	default="0" />
<cfparam name="FORM.Uploaded_Date"	default="" />
<cfparam name="FORM.BB_Code"	default="" />
<cfparam name="FORM.BB_Reference"	default="" />
<cfparam name="FORM.Vendor_ID"	default="" />
<cfparam name="FORM.Upload_ID"	default="" />
<cfparam name="FORM.File_Name"	default="" />
<cfparam name="FORM.BB_Upload_Status"	default="0" />
<cfparam name="FORM.lnkClick"	default="0" />
<cfparam name="FORM.payable_list" 	default="">
<cfparam name="FORM.Reference_Number_list" 	default="">
<cfparam name="FORM.match_type" default="">

<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
<cfset stBBLabels = objSettingsService.getBBLabels()>

<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset getUniqueMonthDay = uploadUtility.getUniqueMonthDay() />

<cfif getUniqueMonthDay.RecordCount EQ 0>
	<cfquery name="getUniqueMonthDay" datasource="#application.datasource#">
		SELECT
				CAST(YEAR(getdate()) AS Varchar(4)) + ' ' +
				DATENAME(MONTH,getdate()) AS ComboText,
				YEAR(getdate()) AS ComboYear,
				MONTH(getdate()) AS ComboMonth
	</cfquery>
</cfif>
<cfset vars = structnew()>
<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnvariable="vars.appSettings"> 
<!--- 
<cfset component="components.settings.ApplicationSettingsManager" method="get" returnvariable="vars.appSettings">  --->
<!---30227 when app settings “3rd party bb upload”  = Instill and “BB Approve Expected Rate Less Tolerance” = ON turn on audit report--->
<cfset vars.audit_rpt_on = ( vars.appSettings.ThirdPartyBbUpload eq "1" and vars.appSettings.Bb_Approve_Expected_Rate_Less_Tolerance eq "1" )>
<cfif getUniqueMonthDay.Recordcount GT 0>
<cfparam name="Form.UploadMonthYear" default="#CreateDate(getUniqueMonthDay.ComboYear, getUniqueMonthDay.ComboMonth, '01')#">
<cfelse>
<!--- Today's date --->
<cfparam name="Form.UploadMonthYear" default="#now()#">
</cfif>

<cfparam name="Form.SelectedMonthYear" default="#dateFormat(UploadMonthYear,"yyyymmmm")#">
<!---- cfset transactions = uploadUtility.getHistoricUploadLogAjax(datepart("m",Form.UploadMonthYear),datepart("yyyy",Form.UploadMonthYear),FORM) / --->
<cfset qAllUploadingUsers = uploadUtility.getAllUploadingUsers() />

<cfset local.arrowDown =  "/images/arrow-d-blue-12.png" />
<cfset local.arrowRight = "/images/arrow-r-blue-12.png" />

<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset stBBLabels = labelSettings.getBBLabels() />



	
		<!--- <form id="EDISearchForm" name="EDISearchForm"> --->
		<form name="frmGetDate" id="frmGetDate" action="index.cfm?showtab=3" method="post">
		<input type="hidden" name="showSearchForm" id="showSearchForm" value="1" />

		<cfoutput>
		<input type="hidden" name="lnkClick" id = "lnkClick" value="#form.lnkClick#" />
		<input type="hidden" name="payable_list" id = "payable_list" value="#form.payable_list#">
		<input type="hidden" name="Reference_Number_list" id = "Reference_Number_list" value="#form.Reference_Number_list#">
		<input type="hidden" name="match_type" id = "match_type" value="#form.match_type#">
		</cfoutput>
		<table border="0">
		<tr>
			<td>
				<span class="subheading">Historic Upload Data</span>&nbsp;&nbsp;
			</td>
			<td>
			<cfoutput>
				<select name="UploadMonthYear" id="UploadMonthYear"
					onchange="getHistory(this.value,'0')"
					class="border rounded mr-1" style="width:120px">
					<cfif getUniqueMonthDay.Recordcount eq 0>
						<option value="">None</option>
					</cfif>
					<cfloop query="getUniqueMonthDay">
						<cfset x = CreateDate(getUniqueMonthDay.ComboYear, getUniqueMonthDay.ComboMonth, "01")>
						<option value="#x#" <cfif ComboText eq UploadMonthYear>selected</cfif>> #ComboText#</option>
						<cfif ComboText eq UploadMonthYear>
							<cfset resetBackDate = x />					
						</cfif>
					</cfloop>
				</select>
				<input type="hidden" name="showTab" id="showTab" value="3">
				</cfoutput>
			</td>
		</tr>
	</table>	

<!-------------------------------------------------------------------------------------->
<!--------------------------------- SEARCH SECTION ------------------------------------->
<!-------------------------------------------------------------------------------------->
<div id="searchSectionBtn" class="sectionHeader pl-2" onclick="toggleSearchSection(this)">
	<img src=<cfoutput>#local.arrowDown#</cfoutput> alt="expand/collapse"> Search <font size="1">[The Search tool will search against all the upload history]</font>
</div>
			
 		<div class="sectionContents text-xs w-full">		
			<fieldset id="UploadHistorySection" class="fieldGroup p-2">
				<cfoutput>
				<div class="flex mb-1">
					<!--- Column 1 --->
					<div class="w-1/5 detail whitespace-no-wrap">
						<label>Uploaded By:</label>
						<select name="Uploaded_User" id="Uploaded_User" size="1"  class="border rounded mr-1" style="width:45%"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:180px" --->
						<option value="0">Select User</option>
							<cfloop query="qAllUploadingUsers">
								<option value="#User_ID#" <cfif FORM.Uploaded_User EQ User_ID>selected</cfif>>#Name_First# #Name_Last#</option>
							</cfloop>
						</select>
						<br><br>
						<label>File Name:</label>
						<input type="text" name="File_Name"  id="File_Name" <cfif FORM.File_Name NEQ ''>value="#FORM.File_Name#"</cfif> class="border rounded mr-1" style="width:160px"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:180px" --->
					</div>
					<!--- Column 2 --->
					<div class="w-1/6 detail whitespace-no-wrap">
						<label>Type:</label>
						<select name="Upload_Type" id="Upload_Type" size="1" class="border rounded mr-1" style="width:55%"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!---   --->
							<option value="0">Select a Type</option>
							<option value="2" <cfif FORM.Upload_Type EQ "2">selected</cfif>>Application</option>
							<option value="3" <cfif FORM.Upload_Type EQ "3">selected</cfif>>3rd Party</option>
						  </select>
						  <br><br>
						<label>Upload Date:</label>
						<input type="text" name="Uploaded_Date" id="Uploaded_Date"  <cfif FORM.Uploaded_Date NEQ ''>value="#FORM.Uploaded_Date#"</cfif> class="border rounded mr-1"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:100px"  --->
					</div>
					<!--- Column 3 --->
					<div class="w-1/5 detail whitespace-no-wrap">
						<label>#stBBLabels.Reference_Number#:</label>
						<input type="text" name="BB_Reference" id="BB_Reference" <cfif FORM.BB_Reference NEQ ''>value="#FORM.BB_Reference#"</cfif> class="border rounded mr-1"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:90px" ---><br>
						<label></label>
						<FONT COLOR="Red">[</FONT><a href="##" onclick="popupCreatelist('Reference_Number')" title="create list of Reference numbers"> <b>create list</b> </a><FONT COLOR="Red">]</FONT><br>
						<label>Payable ##:</label>
						<input type="text" name="BB_Code" id="BB_Code"  <cfif FORM.BB_Code NEQ ''>value="#FORM.BB_Code#"</cfif> class="border rounded mr-1"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:100px" ---><br>
						<label></label>
						<FONT COLOR="Red">[</FONT><a href="##" onclick="popupCreatelist('BB_Code')" title="create list of Payable ##s"> <b>create list</b> </a><FONT COLOR="Red">]</FONT><br>
					</div>	
					
					<!--- Column 4 --->
					<div class="w-1/6 detail whitespace-no-wrap">
						<label>#stBBLabels.Vendor#<!--- Vendor--->:</label>
						<input type="text" name="Vendor_ID" id="Vendor_ID" <cfif FORM.Vendor_ID NEQ ''>value="#FORM.Vendor_ID#"</cfif> class="border rounded mr-1"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:120px" --->
						<br><br>
						<label>Upload ID:</label>
						<input type="text" name="Upload_ID" id="Upload_ID" <cfif FORM.Upload_ID NEQ ''>value="#FORM.Upload_ID#"</cfif> class="border rounded mr-1"  onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:120px" --->
					</div>	
						
					<!--- Column 5 --->
					<div class="w-1/6 detail whitespace-no-wrap">
						<label>Status:</label>
						<select name="BB_Upload_Status" id="BB_Upload_Status" size="1"  class="border rounded mr-1" style="width:70%" onkeydown="if (event.keyCode == 13) getHistory(this.value,'1');"><!--- style="width:150px" --->
							<option value="0">Select an Upload Status</option>
							<option value="Alias needs to be fixed" <cfif FORM.BB_Upload_Status EQ "Alias needs to be fixed">selected</cfif>>Alias needs to be fixed</option>
							<option value="Atleast One Source is Invalid" <cfif FORM.BB_Upload_Status EQ "Atleast One Source is Invalid">selected</cfif>> Atleast One Source is Invalid</option>
							<option value="Creation Complete" <cfif FORM.BB_Upload_Status EQ "Creation Complete">selected</cfif>>Creation Complete</option>
							<option value="Check for file FORMAT" <cfif FORM.BB_Upload_Status EQ "Check for file FORMAT">selected</cfif>>Check for file FORMAT</option>
							<option value="File received" <cfif FORM.BB_Upload_Status EQ "File received">selected</cfif>>File received</option>
							<option value="File Rejected" <cfif FORM.BB_Upload_Status EQ "File Rejected">selected</cfif>>File Rejected</option>
							<option value="Transferring file data to DB" <cfif FORM.BB_Upload_Status EQ "Transferring file data to DB">selected</cfif>>Transferring file data to DB</option>
							<option value="Validating" <cfif FORM.BB_Upload_Status EQ "Validating">selected</cfif>>Validating</option>
							<option value="Validation Completed" <cfif FORM.BB_Upload_Status EQ "Validation Completed">selected</cfif>>Validation Completed</option>
							<option value="Validation Failed" <cfif FORM.BB_Upload_Status EQ "Validation Failed">selected</cfif>>Validation Failed</option>
						  </select><br>
						<!--- fake to layout buttons under the input boxes  --->
                        <label></label>
						<br>
 						<label></label>
                        <span style="display:inline-block;position:relative;top:5px;left:-8px;">
 
<button type="button" onClick="getHistory(this.value,'1')" class="button recommended">Search</button>

                            <button type="button" onClick="clearSearchSection();" class="button">Reset</button>
                        </span>
					</div>  
					<!---- Adjustment for spacing--->
					<!--- <div class="w-1/6 detail whitespace-no-wrap" style="border-width:1px;></div> --->
					
				</div>
				</cfoutput>
			</fieldset>
	
	</div>
	</form>
	<div class="sectionBanner pl-2 mt-1">
		Results: <span id="upload_history_count"></span>  
	</div>
	<!----------------->
	<!-----  GRID ----->
	<!----------------->
	<div id="UploadHistory_Grid" class="ag-theme-balham edi_grid"></div>
	<cfinclude template="UploadHistoryGridManager.cfm">
	
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
		document.getElementById("frmGetDate").reset();
		getHistory("<cfoutput>#resetBackDate#</cfoutput>","0");
	}

/*	function popupVendor() {
		NewWindowTopLeft("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=EDISearchForm&ReloadForm=0&FieldName=Vendor_ID&PageSource=VendorSearch", "payeesearchwindow", 850, 600, "yes", "yes");
	}*/

/*    function closeAllEdit() {
        $("div[id^=content-]").each(function(){
            closeDetailTab($(this).attr("id").replace("content-", ""));
        });
        $('#rawTab').click();
    }*/
	
	function viewbillbacks(id,cnt,uploadTypeID)
	{
		if (cnt < 4000)
// 			window.location.href = 'index.cfm?show_tab=6&upload_id=' + id + '&tab_title=billbacks&upload_type_id=' + uploadTypeID;
window.open('generated_billbacks.cfm?show_tab=6&upload_id=' + id + '&tab_title=billbacks&upload_type_id=' + uploadTypeID ,null,"height=600,width=1000,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
		else
			window.open('billback_listing_printerfriendly.cfm?printable=1&upload_id=' + id + '&upload_type_id=' + uploadTypeID,null,"height=480,width=800,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=yes,location=no");

		return false;
	}
		
 	function viewHeader(fileName)
	{
		window.open("auditreport.cfm?fileName=" + fileName,"Header_Report", "height=480,width=800,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
	}

	function viewDetail(fileName)
	{
		window.open("auditreport.cfm?fileName=" + fileName,"Detail_Report", "height=480,width=800,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
	}		
		
	function getHistory(d,clicked)
	{
	// alert(clicked);
		if (clicked == '1')
		{
	//		frmGetDate.lnkClick.value = '1';
//			document.getElementById("lnkClick").val('1');
			$( "#lnkClick" ).val('1');
			// alert(frmGetDate.Upload_Type.options[frmGetDate.Upload_Type.selectedIndex].value);
// 			alert('lnkclick: ' & $( "#lnkClick" ).val());
			    if (frmGetDate.Upload_Type.options[frmGetDate.Upload_Type.selectedIndex].value == '0' && 
				frmGetDate.Uploaded_User.options[frmGetDate.Uploaded_User.selectedIndex].value == '0' &&
				frmGetDate.Uploaded_Date.value == '' &&
				frmGetDate.BB_Code.value == '' &&
				frmGetDate.BB_Reference.value == '' &&
				frmGetDate.Vendor_ID.value == '' &&
				frmGetDate.Upload_ID.value == '' &&
				frmGetDate.File_Name.value == '' &&
				frmGetDate.BB_Upload_Status.options[frmGetDate.BB_Upload_Status.selectedIndex].value == '0')  
			/*	if ( $( "#Upload_Type" ).val() == '0' && 
					$( "#Uploaded_User" ).val() == '0' && 
					$( "#Uploaded_Date" ).val() == '' && 
					$( "#BB_Code.value" ).val() == '' && 
					$( "#BB_Reference" ).val() == '' && 
					$( "#Vendor_ID" ).val() == '' && 
					$( "#Upload_ID" ).val() == '' && 				
					$( "#File_Name" ).val() == '' && 
					$( "#BB_Upload_Status" ).val() == '0' ) */
				{	
					 alert('Pick/Enter a criteria to search');
					 return;   
				 }
			}
			else
			{
//			frmGetDate.lnkClick.value = '0';
	//		document.getElementById("lnkClick").val('0');
			$( "#lnkClick" ).val('0');
		}
		// frmGetDate.submit();
//  	alert($( "#UploadMonthYear" ).val());
		loadUploadHistoryData();
		// show_loader( "LOADING, PLEASE WAIT...", 1000 );
	}	
	
	function popupCreatelist(option)
	{
		frmGetDate.lnkClick.value = '1';
		if(option=='BB_Code')
		{
			frmGetDate.Reference_Number_list.value='';
			window.open('/common_files/createList2.cfm?parent=BB_Code', 'bb_search_create_list', "height=520,width=450,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
		}
		else if(option=='Reference_Number')
		{
			frmGetDate.payable_list.value='';
			window.open('/common_files/createList2.cfm?parent=Reference_Number', 'bb_search_create_list', "height=520,width=450,scrollbars=yes,status=yes,resizable=yes,toolbar=no,menubar=no,location=no");
		}
	}
		
	<!--- Date picker for Billback date search --->
	$( function() {
		$( "#Uploaded_Date" ).datepicker({
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
