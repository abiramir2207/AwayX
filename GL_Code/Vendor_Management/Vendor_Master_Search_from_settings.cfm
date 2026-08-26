<!----
	Filename:	GL_Code\Vendor_Management\Vendor_Master_Search_from_settings.cfm
	Created:	10/25/2011
 	Developer:	drachala
	Copyright (c) 2006 Blacksmith Applications, Inc.
	Usage: Vendor Master search, this file is include in Vendor managemnt index file with out flex code..
---->
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="" />
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="" />
<CFPARAM NAME="FORM.SelectedVendor_ID" 	DEFAULT="#FORM.FinalItemList#" />
<CFPARAM NAME="Form.Vendor_Name_Desc" 	DEFAULT="" />
<CFPARAM NAME="FORM.Go" DEFAULT= 0 />
<CFPARAM NAME="ReloadForm" default="1">
<CFPARAM NAME="PageSource" default="">
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="Vendor_ID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFPARAM NAME="FORM.Vendor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_Name_Desc" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_ID" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_City" DEFAULT="">
<CFPARAM NAME="FORM.State" DEFAULT="">
<CFPARAM NAME="FORM.Country_Code" DEFAULT="0">
<CFPARAM NAME="FORM.SelectedVendor_ID" DEFAULT="">
<CFPARAM NAME="FORM.VENDOR_ACTIVE"	DEFAULT="1">
<CFPARAM NAME="FORM.FinalVendor" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="">
<CFPARAM NAME="FORM.FormName" DEFAULT="dataform">
<CFPARAM NAME="FORM.FIELDNAME" DEFAULT="Vendor_ID">
<CFPARAM NAME="FORM.RELOADFORM" DEFAULt=0>
<CFPARAM NAME="FORM.PAGESOURCE" DEFAULT="ProgramVendorSearch">

	<cfinclude template="/Common_Files/jQuery.cfm">
	<cfinclude template="/Common_Files/dataTables.cfm">
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables.js"></script>
    <script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>	
	<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">	

<cfoutput>

<INPUT TYPE="Hidden" NAME="FinalVendor" VALUE="#FORM.FinalVendor#">
<INPUT TYPE="Hidden" NAME="finishedselectingitems" VALUE="#FORM.finishedselectingitems#">
<INPUT TYPE="hidden" NAME="tabvalue" VALUE = "listvendormaster">
<INPUT TYPE="hidden" NAMe="Go" VALUE="0" id="Go">

	<TABLE align="center" BORDER="0" CELLPADDING="5" CELLSPACING="0"  STYLE="border: 1px solid Navy;width:auto">
		<TR id="gm1022" >
			<TD>
				<B>Vendor Name</B><BR>
				<INPUT TYPE="Text" NAME="Vendor_Name" VALUE="#FORM.Vendor_Name#" SIZE="50">
			</TD>
			<TD>
				<B>Vendor Number</B><BR>
				<INPUT TYPE="Text" NAME="Vendor_ID" VALUE="#FORM.Vendor_ID#">
			</TD>
			<TD>
				<CFQUERY NAME="getVendorCity" DATASOURCE="#Application.Datasource#">
					SELECT DISTINCT City FROM Vendor_Master WHERE LEN(City) > 0	ORDER BY City
				</CFQUERY>
				<B>Vendor City</B><BR>
				<cfsavecontent variable="variables.vendor_cities">
				<SELECT NAME="Vendor_City" STYLE="WIDTH:115px">
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
				<B>Vendor State</B><BR>
				<cfsavecontent variable="variables.vendor_states">
				<SELECT NAME="State" STYLE="WIDTH:115px">
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
				<B>Vendor Country</B><BR>
				<cfsavecontent variable="variables.vendor_countries">
					<SELECT NAME="Country_Code" STYLE="WIDTH:115px">
					  <OPTION SELECTED value="0">**ALL** Countries</OPTION>
					  <CFLOOP QUERY="getCountry">
					  <OPTION VALUE="#trim(getCountry.Country_Code)#" <cfif trim(FORM.country_code) EQ trim(GetCountry.country_code)>SELECTED</cfif>>#getCountry.Country_Name#</OPTION>
					  </CFLOOP>
				    </SELECT>
				</cfsavecontent>
				#application.util.string.compress( variables.vendor_countries )#
			</TD>
		  	<TD valign="top"><p><strong>Status</strong><br>
		  		<select name="Vendor_Active" ID="Vendor_Active">
		  			<option value="1" <cfif FORM.Vendor_Active IS "1">selected</cfif>>Active</option>
		  			<option value="0" <cfif FORM.Vendor_Active IS "0">selected</cfif>>Inactive<option>
		  		</select>
  			</TD>
			<TD valign="bottom" >
				<a class="create" style="cursor:pointer;">#application.util.string.actionLinkFormat("create vendor")#</a>&nbsp;&nbsp;
				<a class="reset" style="cursor:pointer;">#application.util.string.actionLinkFormat("reset")#</a>&nbsp;&nbsp;
				<a class="submit" style="cursor:pointer;">#application.util.string.actionLinkFormat("search vendor")#</a>				
			</TD>
		</TR>
	</TABLE>

</cfoutput>	
<cfif form.Go>
	
<cfoutput>
	<cfif FORM.VENDOR_ACTIVE>
		<a style="cursor:pointer;" onclick="multiselected(1)">#application.util.string.actionLinkFormat("deactivate selected ")#</a>		
	<cfelse>
		<a style="cursor:pointer;" onclick="multiselected(0)">#application.util.string.actionLinkFormat("activate selected")#</a>		
	</cfif>
</cfoutput>
	
	<table class="datagrid">
	  <thead>
	  	<th class="header"><!---<input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'VendorMasterID');">---></th>
	    <th class="header"><b>Vendor ID</b></th>
	    <th class="header"><b>Vendor Name</b></th>
	    <th class="header"><b>Vendor Address</b></th>
	    <cfif form.Vendor_Active><th class="header"></th></cfif>
	  </thead>
	  <tbody>
	  </tbody>
	</table>	


<cfif appSettings.getModifyVendorRecords() AND Get_Profile_Settings.Modify_Vendors_VendorManagement>	
	<cfset editfield = 1>
<cfelse>
	<cfset editfield = 0>
</cfif>

<cfset urlVariable = "Vendor_Name=#form.Vendor_Name#&Vendor_ID=#form.Vendor_ID#&Vendor_City=#urlEncodedFormat(form.Vendor_City)#&State=#form.State#&Vendor_country=#form.Country_Code#&Vendor_Active=#form.Vendor_Active#&editfield=#editfield#">

	<script>
		var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
		oTable = $('.datagrid').dataTable( {
			  "bServerSide": true
			, "bFilter": false
			, "bSortClasses": false
			, "bAutoWidth": false
			, "bPaginate": true
			, "bProcessing": true
			, "sAjaxSource": "ajax/Vendor_Master_search_ajax.cfm?<cfoutput>#urlVariable#</cfoutput>"
			, "sScrollY": sScrollY
			, "sDom": "rpti"
			, "iDisplayLength": 100
			, "aaSorting": []
			, "aoColumns": [  
									{"sWidth": "3%", "bSortable":false}
								,	{"sWidth": "15%", "bSortable":true}	
			                    ,	{"sWidth": "30%", "bSortable":true}
								,	{"sWidth": "30%", "bSortable":true}
			                    <cfif form.Vendor_Active>,	{"sWidth": "22%", "bSortable":false}</cfif>
								]	 
		} ).fnSetFilteringDelay();
	</script>
</cfif>		



<SCRIPT language="JavaScript">	
	$(document).ready(function() {
	$( ".submit" ).click(function() {
	  $("#Go").val("1");
	  $("#SearchForm" ).submit();
	});
	
	$(".reset").on("click", function(event){
		event.returnValue = false;
		document.all.Vendor_Name.value = "";
		document.all.Vendor_ID.value = "";
		document.all.Vendor_City.value="";
		document.all.State.value="";
		document.all.Vendor_Active.value = "1";
		});
	});
	
	$( ".create" ).click(function() {
		NewWindow("Create_Vendor.cfm?create=1", "Create_Vendor", 800, 400, 'yes', 'yes');
	});
	
	function multiselected(id) {
		var checkBoxList  = document.getElementsByName("VendorMasterID");
		var selectedvalue = '';
		for (i = 0; i < checkBoxList.length; i++){
			if (checkBoxList[i].checked == true) {
				selectedvalue = selectedvalue.concat(checkBoxList[i].value);
				selectedvalue = selectedvalue.concat(',');
			}
		}
      if (id == 0) {
	  	var tet = ' Activate ';
	  }
	  else {
	  	var tet = ' De-Activate ';
	  }

		 if (selectedvalue ==''){
			alert("please select a vendor to"+tet);
			return false
		 }

		var go = confirm("Do you want to"+ tet+ " selected vendor(s)?");
		
		if (go == true) {
        	NewWindow("Create_Vendor.cfm?vmi=" +selectedvalue+'&deactivate='+id, "edit_vendor", 800, 400, 'yes', 'yes');
   		 } 		
}
	function editbank(vendor) {
		NewWindow("edit_bank.cfm?vmi=" +vendor, "edit_vendor_bank", 800, 400, 'yes', 'yes');
	}
	function editvendor(vendor) {
		NewWindow("Create_Vendor.cfm?vmi=" +vendor+'&create=0', "edit_vendor", 800, 400, 'yes', 'yes');
	}
function selectAll(thisObj, objToChk)
{
	var chObjs = eval("document.all." + objToChk);
	var bCheck = thisObj.checked;
	var i;
	if(chObjs)
	{
		if(chObjs.length)
		{
			for(i=0;i<chObjs.length;i++)
			{
				chObjs[i].checked = bCheck;
			}
		}
		else
		{
			chObjs.checked = bCheck;
		}
	}
}
</SCRIPT>