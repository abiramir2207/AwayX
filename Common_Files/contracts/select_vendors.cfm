<!---
	Copyright (c)2016 Blacksmith Applications, Inc.       
	Filename:		Common_Files\contracts\select_vendors.cfm
					copied and modified code from "GL_Code\Vendor_Management\Vendor_Master_Search_from_settings.cfm"
	Created:		7/31/2018
	Developer:		Milan Mushran
	Description:	search and add vendors as a payee
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Select Vendors</TITLE>
<style>
div.saveData {float:left;margin-top:10px;}
</style>
<body>
<CFPARAM NAME="form.Save" DEFAULT= 0 />
<CFPARAM NAME="form.CID" DEFAULT="" />
<CFPARAM NAME="form.SelectedVendorList" DEFAULT="" />
<CFPARAM NAME="Form.Show_All_Records" DEFAULT= "0" />
<CFPARAM NAME="form.Vendor_Name" DEFAULT="">
<CFPARAM NAME="form.Vendor_ID" DEFAULT="">
<CFPARAM NAME="form.Vendor_City" DEFAULT="">
<CFPARAM NAME="form.State" DEFAULT="">
<CFPARAM NAME="form.Country_Code" DEFAULT="">

<cfif FORM.CID neq "">
	<cfset URL.CID = FORM.CID>
</cfif>

<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
<CFSET FORM.Contract_Main_ID = cryp.value>
<CFSET CSL_Contract_Main_ID = FORM.Contract_Main_ID>
<cfset objProgram = CreateObject("component", "components.programs.program") />

<!--- If the user clicked on "save" --->
<cfif form.Save>
	<cfset objProgram.saveProgramVendors(CSL_Contract_Main_ID)>

		<!--- REDIRECTOR --->
		<cfset useLakebaseForgetContractProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractProgramID>
	<cftry>
		<cfset getContractProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#CSL_Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractProgramID>
<cfquery name="getContractProgramID" datasource="#application.datasource#">
				SELECT ProgramType_ID
				FROM Contract_Main
				WHERE COntract_Main_ID = '#CSL_Contract_Main_ID#'
		</cfquery>
</cfif>
			<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>
			<CFSET redirector_FromPage_ID = 11>
		<cfinclude template="internal_redirector_based_on_settings.cfm">
		<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#URL.CID#">

</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET CSL_CallingPageCode = "vn">

<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 130px; height: 400px; z-index: 5; left: 10px; top: 0px">
		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
	</div>
<cfelse>
		<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>

<CFINCLUDE TEMPLATE="commonqueries.cfm">

<cfset qSelectedVendorsOnProgram = objProgram.getSelectedVendorsOnProgram(CSL_Contract_Main_ID)>

<!--- Get the list of selected vendors on the program --->
<cfset form.SelectedVendorList = valueList(qSelectedVendorsOnProgram.Vendor_Master_ID)>

<cfoutput>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; width:200px; z-index:1; left:150px; top: 10px; height:430px;">
</cfif>
<cfset width = '1015'>
<cfinclude template="minimal_contract_info.cfm">

<FORM NAME="SearchForm" ACTION="select_vendors.cfm" METHOD="POST" id="SearchForm">

<FIELDSET STYLE="padding:8px; width: 1000px; border: 1px solid Blue;">
	   <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#variables.VendorLabel#</cfoutput> search </LEGEND>

<INPUT TYPE="hidden" NAME="SelectedVendorList" value="#form.SelectedVendorList#">
<INPUT TYPE="hidden" NAME="Show_All_Records" VALUE="0" id="Show_All_Records">
<INPUT TYPE="hidden" NAME="Save" VALUE="0" id="Save">
<INPUT TYPE="hidden" NAME="CID" VALUE="#URL.CID#">

	<TABLE align="center" BORDER="0" CELLPADDING="5" CELLSPACING="0"  STYLE="width:1000px;">
		<TR id="gm1022" >
			<TD>
				<B>#variables.VendorLabel# Name</B><BR>
				<INPUT TYPE="Text" NAME="Vendor_Name" VALUE="#FORM.Vendor_Name#" SIZE="30" onkeydown="if(event.keyCode == 13){$('.submit').click();}">
			</TD>
			<TD>
				<B>#variables.VendorLabel# Number</B><BR>
				<INPUT TYPE="Text" NAME="Vendor_ID" VALUE="#FORM.Vendor_ID#">
			</TD>
			<TD>
				<CFQUERY NAME="getVendorCity" DATASOURCE="#Application.Datasource#">
					SELECT DISTINCT City FROM Vendor_Master WHERE LEN(City) > 0	ORDER BY City
				</CFQUERY>
				<B>#variables.VendorLabel# City</B><BR>
				<cfsavecontent variable="variables.vendor_cities">
				<SELECT NAME="Vendor_City" STYLE="WIDTH:115px"  onkeydown="if(event.keyCode == 13){$('.submit').click();}">
					<OPTION VALUE="">**ALL** City</OPTION>
					<CFLOOP QUERY="getVendorCity">
					<OPTION VALUE="#trim(getVendorCity.City)#" <CFIF FORM.Vendor_City EQ getVendorCity.City>SELECTED </CFIF>><CFIF len(trim(getVendorCity.City)) EQ 0>City Not Specified<CFELSE>#trim(getVendorCity.City)#</CFIF></OPTION>
					</CFLOOP>
				</SELECT>
				</cfsavecontent>
				#application.util.string.compress( variables.vendor_cities )#
			</TD>
			<TD>
				<cfquery name="GetStates" datasource="#application.datasource#">
					SELECT DISTINCT State, State_Name, Country_Sort_Order
					FROM Vendor_Master V
					join _States s on s.State_Code =  V.state
					join _Country c on s.Country_ID = c.Country_ID
					WHERE	LEN(State) > 0
					ORDER BY Country_Sort_Order, State_Name
				</cfquery>
				<B>#variables.VendorLabel# State</B><BR>
				<cfsavecontent variable="variables.vendor_states">
				<SELECT NAME="State" STYLE="WIDTH:115px"  onkeydown="if(event.keyCode == 13){$('.submit').click();}">
					<OPTION VALUE="">**ALL** States</OPTION>
					<CFLOOP QUERY="GetStates">
					<OPTION VALUE="#trim(GetStates.state)#" <cfif trim(FORM.state) EQ trim(GetStates.state)> SELECTED</cfif>><CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state_name)#</CFIF></OPTION>
					</CFLOOP>
				</SELECT>
				</cfsavecontent>
				#application.util.string.compress( variables.vendor_states )#
			</TD>
			<TD>
				<CFQUERY NAME="getCountry" DATASOURCE="#Application.Datasource#">
					SELECT DISTINCT (isnull(V.country_code, 'N')) AS country_code, ISNULL(C.Country_Name, '**NONE**') AS Country_Name
					FROM Vendor_Master V
					LEFT JOIN _Country C
					ON C.Country_code = V.Country_Code OR C.Country_code2 = V.Country_Code
					WHERE V.Deleted = 0
					AND (LEN(V.country_code) = 2 OR V.country_code IS NULL)
					ORDER BY Country_Name
				</CFQUERY>
				<B>#variables.VendorLabel# Country</B><BR>
				<cfsavecontent variable="variables.vendor_countries">
					<SELECT NAME="Country_Code" STYLE="WIDTH:115px"  onkeydown="if(event.keyCode == 13){$('.submit').click();}">
					  <OPTION SELECTED value="">**ALL** Countries</OPTION>
					  <CFLOOP QUERY="getCountry">
					  <OPTION VALUE="#trim(getCountry.Country_Code)#" <cfif trim(FORM.country_code) EQ trim(GetCountry.country_code)>SELECTED</cfif>>#getCountry.Country_Name#</OPTION>
					  </CFLOOP>
				    </SELECT>
				</cfsavecontent>
				#application.util.string.compress( variables.vendor_countries )#
			</TD>
			<TD valign="bottom" >
				<a class="reset" style="cursor:pointer;">#application.util.string.actionLinkFormat("reset")#</a>&nbsp;&nbsp;
				<a class="submit" style="cursor:pointer;">#application.util.string.actionLinkFormat("search #variables.VendorLabel#")#</a>				
			</TD>
		</TR>
	</TABLE>
	</FIELDSET>
<form>
</cfoutput>	

<cfset datatables.version = "1.9.3">
<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>	
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">	
<!--- Please Wait Indicator --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- Please Wait Indicator --->

<!--- Please Wait Indicator --->
<div class="customContainer" style="display:none;margin-left:250px;"></div>
<!--- Please Wait Indicator --->	

<!--- (Start) If there are already vendors in the program, or the user clicks on "search, show the datagrid --->
<cfif ListLen(form.SelectedVendorList) GT 0 OR Show_All_Records EQ 1>

<FIELDSET STYLE="width:1010px;">
<TABLE CLASS="datagrid" border="0" cellspacing="0" cellpadding="0">
  <thead>
	<th class="header"></th>
	<cfoutput>
	<th class="header"><b>#variables.VendorLabel# ID</b></th>
	<th class="header"><b>#variables.VendorLabel# Name</b></th>
	<th class="header"><b>#variables.VendorLabel# Address</b></th>
	</cfoutput>
  </thead>
  <tbody>
  </tbody>
</table>

<div style="margin-top:25px">
	<cfoutput><a href="javascript:void();" onClick="saveVendors();">#application.util.string.actionLinkFormat2("save")#</a></cfoutput>	
</div>


<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
var jTable = $(".datagrid");
mydatagrid =  jTable.dataTable({
	  "bServerSide": true
	, "bFilter": false
	, "bSortClasses": false
	, "bAutoWidth": false
	, "bPaginate": true
	, "bProcessing": true
	, "sAjaxSource": "ajax/select_vendors_ajax.cfm"
	, "sScrollY": sScrollY
	, "sDom": "<'saveData'>rpti"
	, "iDisplayLength": 100
	, "sServerMethod": "POST"
	,"aaSorting": [[ 1, "asc" ]]
	, "aoColumns": [  
					{"sWidth": "3%", "bSortable":false}
					,{"sWidth": "20%", "bSortable":true}	
					,{"sWidth": "32%", "bSortable":true}
					,{"sWidth": "35%", "bSortable":true}
					]
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
	<cfoutput>			
	aoData.push( { "name": "Contract_Main_ID", "value": '#CSL_Contract_Main_ID#' } );
	aoData.push( { "name": "Vendor_Name", "value": '#form.Vendor_Name#' } );
	aoData.push( { "name": "Vendor_ID", "value": '#form.Vendor_ID#' } );
	aoData.push( { "name": "Vendor_City", "value": '#urlEncodedFormat(form.Vendor_City)#' } );
	aoData.push( { "name": "State", "value": '#form.State#' } );
	aoData.push( { "name": "Vendor_country", "value": '#form.Country_Code#' } );
	aoData.push( { "name": "Show_All_Records", "value": '#form.Show_All_Records#' } );
	</cfoutput>
	<!--- SINCE WE MAY HAVE RECORDS ON MULTIPLE PAGES, WE NEED TO PASS "SelectedVendorList" TO THE AJAX PROCESSING PAGE --->
	aoData.push( { "name": "SelectedVendorList", "value": $('input[name=SelectedVendorList]').val() } );
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json){fnCallback(json);}
		 } );
		}

} ).fnSetFilteringDelay();

<cfoutput>
$('div.saveData').html("<a href='javascript:saveVendors();'>#application.util.string.actionLinkFormat2('save')#</a> &nbsp;");
</cfoutput>
</script>
</cfif><!--- (End) If there are already vendors in the program, or the user clicks on "search, show the datagrid --->

<SCRIPT language="JavaScript">	
function saveVendors(){
 $("#Save").val("1");
 $("#SearchForm" ).submit();
}

$(document).ready(function() {
$( ".submit" ).click(function() {
	 processingPopUpDisplay('div.customContainer');
	 $("#Show_All_Records").val("1");
	 $("#SearchForm" ).submit();
});

$(".reset").on("click", function(event){
	event.returnValue = false;
	document.all.Vendor_Name.value = "";
	document.all.Vendor_ID.value = "";
	document.all.Vendor_City.value="";
	document.all.State.value="";
	document.all.Country_Code.value="";
	});
});

function addRemoveVendors(){
	 /* all checked rows are saved in a hidden input with a name of 'SelectedVendorList' */
	var hiddenCBoxes = $('input[name=SelectedVendorList]').val().toLowerCase();

	/* convert the list into an array for easy manipulation */
	if (hiddenCBoxes.length == 0)
		var aVendorList = [];
	else
		var aVendorList = hiddenCBoxes.split(",");

	/* scan thru all checkboxes on the page */
	$('input.vendorCheckbox').each( function() {
		var VendorMasterID = $(this).val().toLowerCase();

		if ( $(this).prop('checked') ) {

			 /* checked box is not in the array, add it */
			if($.inArray(VendorMasterID, aVendorList) == -1){
				aVendorList.push( VendorMasterID );
			}
		}
		else {
			 /* box is not checked so we need to remove it */
			while($.inArray(VendorMasterID, aVendorList) != -1) {
				aVendorList.splice($.inArray(VendorMasterID, aVendorList),1);
			}
		}
	});

	/* convert array back to a list for usage in form action */
	hiddenCBoxes = aVendorList.join(",");

	/* refresh the hidden input with ALL selected rows */
	$('input[name=SelectedVendorList]').val( hiddenCBoxes );
}

</SCRIPT>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif application.programlayout EQ 1></div></cfif>
</body>
</html>