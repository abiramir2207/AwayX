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
<div style="height:5px;Margin:20px 0;">
<cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
	<B><FONT COLOR="##FF0000">[&nbsp;&nbsp;</FONT></B>
		<cfif active>
			<span style="color:blue;font-weight:bold;" onclick="MultiDeActivate()">deactivate selected</span>
		<cfelse>
			<span style="color:blue;font-weight:bold;" onclick="MultiActivate()">activate selected</span>
		</cfif>
	<B><FONT COLOR="##FF0000">&nbsp;&nbsp;]</FONT></B>
</cfif>	
</div>
<table class="datagrid">
  <thead>
    <th style="width:25px;"><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'ChkPGTypeID');"></th>
    <th class="header"><b>Type ID</b></th>
    <th class="header"><b>Type Name</b></th>
    <th class="header"><b>Type Category</b></th>
	<cfif active>
    <th class="header" style="width:50px;text-align:center;"><b>DeActivate</b></th>
	<cfelse>
	<th class="header" style="width:50px;text-align:center;"><b>Activate</b></th>
	</cfif>
    <th class="header" style="width:50px;text-align:center;"><b>Delete</b></th>
    <th class="header" style="width:50px;text-align:center;"><b>Info</b></th>
  </thead>
  <tbody>
	<cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
    <cfoutput>#getdata_message#</cfoutput>
  </tbody>
</table>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 2000
    , "oLanguage": {"sSearch": "<b>Search:</b>"}
    , "sAjaxSource": "ajax/Type_PG_Query.cfm?active=<cfoutput>#active#</cfoutput>"
  	,"sScrollY": sScrollY
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": false,  "bSortable":false}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                 ]
} ).fnSetFilteringDelay();
function deactivate(id, group, active){
	ColdFusion.Window.create('EditPlanningGroup', 'Deactivate Planning Group', 'Type_PG_Edit.cfm?Deactivate=1&ID=' + id + '&Group=' + group + '&active=' + active, {
					height: 200,
					width: 600,
					modal: false,
					closable: true,
					draggable: false,
					resizable: false,
					center: true,
					initshow: true
				});
				ob = ColdFusion.Window.getWindowObject('EditPlanningGroup')
				ob.center()
	ColdFusion.Window.onHide('EditPlanningGroup', cleanup);
}
function activate (id, active){
				ColdFusion.Window.create('EditPlanningGroup', 'Activate Planning Group', 'Type_PG_Edit.cfm?Activate=1&ID=' + id + '&active=' + active, {
					height: 200,
					width: 600,
					modal: false,
					closable: true,
					draggable: false,
					resizable: false,
					center: true,
					initshow: true
				});
				ob = ColdFusion.Window.getWindowObject('EditPlanningGroup')
				ob.center()
				ColdFusion.Window.onHide('EditPlanningGroup', cleanup);
}
function removed(id, active){
				ColdFusion.Window.create('EditPlanningGroup', 'Delete Planning Group', 'Type_PG_Edit.cfm?Delete=1&ID=' + id + '&active=' + active, {
					height: 200,
					width: 600,
					modal: false,
					closable: true,
					draggable: false,
					resizable: false,
					center: true,
					initshow: true
				});
				ob = ColdFusion.Window.getWindowObject('EditPlanningGroup')
				ob.center()
				ColdFusion.Window.onHide('EditPlanningGroup', cleanup);
}
function MultiDeActivate(){
		var checkBoxList  = document.getElementsByName("ChkPGTypeID");
		var selectedvalue = '';
			for (i = 0; i < checkBoxList.length; i++)
			{
				if (checkBoxList[i].checked == true) {
					selectedvalue = selectedvalue.concat(checkBoxList[i].value);
					selectedvalue = selectedvalue.concat(',');
				}
			}
	ColdFusion.Window.create('EditPlanningGroup', 'Edit Planning Group', 'Product_PG_Edit.cfm?MultiDeActivate=1&selectedvalue='+selectedvalue, {
	 	height: 200,
	 	width: 600,
	 	modal: false,
	 	closable: true,
	 	draggable: false,
	 	resizable: false,
	 	center: false,
	 	initshow: true
		 });
		ob = ColdFusion.Window.getWindowObject('EditPlanningGroup')
		ob.center()
		ColdFusion.Window.onHide('EditPlanningGroup', cleanup);
}
function MultiActivate(){
		var checkBoxList  = document.getElementsByName("ChkPGTypeID");
		var selectedvalue = '';
			for (i = 0; i < checkBoxList.length; i++)
			{
				if (checkBoxList[i].checked == true) {
					selectedvalue = selectedvalue.concat(checkBoxList[i].value);
					selectedvalue = selectedvalue.concat(',');
				}
			}
	ColdFusion.Window.create('EditPlanningGroup', 'Edit Planning Group', 'Product_PG_Edit.cfm?MultiActivate=1&selectedvalue='+selectedvalue, {
	 	height: 200,
	 	width: 600,
	 	modal: false,
	 	closable: true,
	 	draggable: false,
	 	resizable: false,
	 	center: false,
	 	initshow: true
		 });
		ob = ColdFusion.Window.getWindowObject('EditPlanningGroup')
		ob.center()
		ColdFusion.Window.onHide('EditPlanningGroup', cleanup);
}
function info(id, group, active){
	window.open ("Type_PG_Info.cfm?ID=" + id + "&Group=" + group + "&active=" + active, "Info_About_Planning_Group","location=0,status=0,scrollbars=1,resizable=1, width=600,height=600");
/*		D34330:Planning Group pop ups
 		ColdFusion.Window.create('EditPlanningGroup', 'Info About Planning Group', 'Type_PG_Edit.cfm?info=1&ID=' + id + '&Group=' + group + '&active=' + active, {
					height: 500,
					width: 810,
					modal: false,
					closable: true,
					draggable: false,
					resizable: false,
					center: true,
					initshow: true
				});
				ob = ColdFusion.Window.getWindowObject('EditPlanningGroup')
				ob.center()
				ColdFusion.Window.onHide('EditPlanningGroup', cleanup);
*/
}
function cleanup() {
	ColdFusion.Window.destroy('EditPlanningGroup',true);
}
function deactivated(id){
	window.location.href = "index.cfm?type=Type&deactivate=1&PG_Type_ID="+id;
}
function activated (id){
	window.location.href = "index.cfm?type=Type&activate=1&PG_Type_ID="+id;
}
function deleted (id){
	window.location.href = "index.cfm?type=Type&deleted=1&PG_Type_ID="+id;
}
getSearchString = function(){
    var s =  ColdFusion.getElementValue('filter');
    return s;
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
</script>
<cfparam name="url.deactivate" 			default="0">
<cfparam name="url.activate" 			default="0">
<cfparam name="url.deleted" 			default="0">

<!--- this section is used to deactive product planning groups, this required URL variables(type, deactivate, PG_Type_ID) START --->
<cfif (url.deactivate) AND (url.type IS "Type") AND (isdefined("url.PG_Type_ID"))>
	<cfscript>
    	  PGManager.deactivateType(#url.PG_Type_ID#);
	</cfscript>
</cfif>
<!--- this section is used to deactive product planning groups, this required URL variables(type, deactivate, PG_Type_ID) END --->
<!--- this section is used to active product planning groups, this required URL variables(type, activate, PG_Type_ID) START --->
<cfif (url.activate) AND (url.type IS "Type") AND (isdefined("url.PG_Type_ID"))>
	<cfscript>
    	  PGManager.activateType(#url.PG_Type_ID#);
	</cfscript>
</cfif>
<!--- this section is used to active product planning groups, this required URL variables(type, activate, PG_Type_ID) END --->
<!--- this section is used to DELETE product planning groups, this required URL variables(type, deleted, PG_Type_ID) START --->
<cfif (url.deleted) AND (url.type IS "Type") AND (isdefined("url.PG_Type_ID"))>
	<cfscript>
    	  PGManager.delType(#url.PG_Type_ID#);
	</cfscript>
</cfif>
<!--- this section is used to DELETE product planning groups, this required URL variables(type, deleted, PG_Type_ID) END --->
