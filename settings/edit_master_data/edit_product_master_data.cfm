<!----
	Filename:	C:\Work\Code\base\AwayX\settings\edit_master_data\index.cfm
	Created:	3/12/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR MASTER DATA
	Usage:
		SETTING>>ADMINISTRATOR>>EDIT_MASTER_DATA.
---->
<cfajaximport tags="cfwindow,cfform,CFINPUT-AUTOSUGGEST" >
<cfparam name="url.active" default="A">
<cfparam name="info" default= "0">
<cfset qLabels = createObject("component", "components.settings.Labels.Labels").init()>
<cfset getAllProductAttributes = qLabels.getAllProductAttributes() />

<cfset labelsValue = structNew() />


<cfloop query="getAllProductAttributes">
	<cfset temp = structInsert(labelsValue, replace(GROUP_INTERNAL_LABEL, ' ', '_', 'all'), GROUP_LEVEL_DESC, 'true') />
</cfloop>

<cffunction name="actionLinkFormat" access="public" returntype="string" output="false">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="style" type="string" required="false" default="classic"/>
	
	<cfscript>
		switch (arguments.style) {
			case "classic": 
				return "<b><font color='red'>[ </font>" & arguments.action & " <font color='red'> ]</font></b>"; break;
			default: 
				return arguments.action;
		}
	</cfscript>
</cffunction>

<cfoutput>
	<div style="width:100%; margin-top:5px; margin-bottom:5px;">
		<a href="#ajaxLink('#cgi.script_name#?active=A')#">#actionLinkFormat('Active')#</a>
		<a href="#ajaxLink('#cgi.script_name#?active=N')#">#actionLinkFormat('InActive')#</a>
	</div>
	
	<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
	<table class="datagrid">
	  <thead>
	    <th width="10%"><b>Item</b></th>
	    <th width="20%"><b>Description</b></th>
	    <th width="10%"><b>#structFind(labelsValue,"brand")# ID</b></th>
	    <th width="15%"><b>#structFind(labelsValue,"Product_Group")#</b></th>
		<th width="10%"><b>#structFind(labelsValue,"Class_Code")#</b></th>
		<th width="10%"><b>#structFind(labelsValue,"Type_Code")#</b></th>
	  </thead>
	  <tbody>
	  </tbody>
	</table>

</cfoutput>

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
    , "sAjaxSource": "ajax/Edit_Product_Master_Data_Query.cfm?active=<cfoutput>#url.active#</cfoutput>"
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": true,  	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
				  ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                 ]
} ).fnSetFilteringDelay();
function navigate(id){
		window.open('Product_Master_Edit.cfm?BSAID=' + id, 'EditItemMaster', 'width=500,height=300,scrollbars=0');
}
</script>