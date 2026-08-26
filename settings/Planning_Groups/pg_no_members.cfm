<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR PRODUCT PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS. TAB TYPE
---->
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<cfparam name="url.active" default="1">
<cfparam name="url.category" default="1">
<cfoutput>
		<table border="0">
				<tr>
						<td>
								<b>Filter: &nbsp;&nbsp;</b>
						</td>
						<td>
							<select onchange="category(this.value)" style="width:135px; border:none; background-color:##fcf9f9;">
										<option  value="1" <cfif url.category EQ 1>SELECTED</cfif>>#application.returned_customer_setting.Item_Label#</option>
										<option  value="2" <cfif url.category EQ 2>SELECTED</cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
										<option  value="3" <cfif url.category EQ 3>SELECTED</cfif>>#application.returned_customer_setting.Operator_Label_Singular#</option>
							</select>
						</td>
						<td onclick="inactive()" id="inactive" <cfif url.active>style="display:block; color:blue"<cfelse>style="display:none;"</cfif>>#ActionText("In-Active")# </td>
						<td onclick="active()" id="active" <cfif url.active  EQ 0>style="display:block;color:blue"<cfelse>style="display:none;"</cfif>>#ActionText("Active")# </td>
						<td><a href="pg_no_members_excel.cfm?category=#url.category#&active=#url.active#">#ActionText("excel")#</a></td>
				</tr>
		</table>

<table class="datagrid">
  <thead>
    <th class="header"><b>Type ID</b></th>
    <th class="header"><b>Type Name</b></th>
    <th class="header"><b>Type Category</b></th>
	 <th class="header"><b>Category Name</b></th>
  </thead>
  <tbody>
  </tbody>
</table>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>

<script>
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 20
    , "oLanguage": {"sSearch": "<b>Search:</b>"} 
    , "sAjaxSource": "ajax/PG_NoMembers_Query.cfm?active=#trim(url.active)#&category=#url.category#"
    , "sDom": "fprti" 
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": false,  "bSortable":true}
	                   				 ,	{"bSearchable": true, 	"bSortable":true}
	                    			,	{"bSearchable": true, 	"bSortable":true}
	                    			,	{"bSearchable": true, 	"bSortable":true}
	                 ]
} ).fnSetFilteringDelay();
function active(){
window.location.href = "index.cfm?type=Research&subtype=#FORM.display#&active=1&category=#url.category#";
}
function inactive(){
window.location.href = "index.cfm?type=Research&subtype=#FORM.display#&active=0&category=#url.category#";
}
function category(type){
window.location.href = "index.cfm?type=Research&subtype=#FORM.display#&active=#trim(url.active)#&category="+type;
}
</script>
</cfoutput>
