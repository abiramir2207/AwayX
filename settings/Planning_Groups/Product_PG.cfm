<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USED TO MAKE AJAX CALLS TO DB FOR PRODUCT PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.  TAB PRODCUT
---->
<div id="msg55"></div>    <!--- reserve this div for displaying status --->
<div id="whole">
<cfinclude template="_pg_action.cfm">
<table class="datagrid">
  <thead>
    <th style="width:25px;"><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'chkPGProductCatID');"></th>
    <th class="header" style="width:100px;"><b>PG Code</b></th>
    <th class="header" style="width:200px;"><b>PG Name</b></th>
    <th class="header" style="width:200px;"><b>PG Type</b></th>
    <th class="header" style="width:110px;"><b>Include In Other PG</b></th>
	<cfif active>
    <th class="header" style="width:50px;text-align:center;"><b>DeActivate</b></th>
	<cfelse>
	<th class="header" style="width:50px;text-align:center;"><b>Activate</b></th>
	</cfif>
    <th class="header" style="width:50px;text-align:center;"><b>Copy</b></th>
    <th class="header" style="width:50px;text-align:center;"><b>Delete</b></th>
    <th class="header" style="width:50px;text-align:center;"><b>Info</b></th>
	<th class="header" style="width:50px;text-align:center;"><b>Members</b></th>
  </thead>
  <tbody>
  </tbody>
</table>
</div>   <!--- id=whole --->

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 2000
    , "oLanguage": {"sSearch": "<b>Search:</b>"}
    , "sAjaxSource": "ajax/Product_PG_Query.cfm?active=<cfoutput>#active#</cfoutput>"
    , "sDom": "fprti"
  	,"sScrollY": sScrollY
    , "aaSorting": []
    , "aoColumns": [  		{"bSearchable": false,  "bSortable":false}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                    ,	{"bSearchable": false, 	"bSortable":false}
	                 ]
} ).fnSetFilteringDelay();
function deactivate(id){
	ColdFusion.Window.create('EditPlanningGroup', 'Deactivate Planning Group', 'Product_PG_Edit.cfm?Deactivate=1&ID=' + id, {
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
function activate (id){
				ColdFusion.Window.create('EditPlanningGroup', 'Activate Planning Group', 'Product_PG_Edit.cfm?Activate=1&ID=' + id, {
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
function copy(id, isSystem){
				ColdFusion.Window.create('EditPlanningGroup', 'Copy Planning Group', 'Product_PG_Edit.cfm?Copy=1&type=<cfoutput>#active#</cfoutput>&ID='+id+'&System='+isSystem, {
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
   var allVals = [];
   $("input[name=chkPGProductCatID]:checked").each(function() { allVals.push($(this).val()); } );
   var selectedvalue = allVals.join(",");

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
   var allVals = [];
   $("input[name=chkPGProductCatID]:checked").each(function() { allVals.push($(this).val()); } );
   var selectedvalue = allVals.join(",");

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
function removed(id){
				ColdFusion.Window.create('EditPlanningGroup', 'Delete Planning Group', 'Product_PG_Edit.cfm?Delete=1&ID=' + id, {
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
function info(id){

		window.open ("Product_PG_Info.cfm?ID=" + id, "Info_About_Planning_Group","location=0,status=0,scrollbars=1,resizable=1, width=700,height=600");

/*	D34330:Planning Group pop ups
 			ColdFusion.Window.create('EditPlanningGroup', 'Info About Planning Group', 'Product_PG_Edit.cfm?info=1&ID=' + id, {
					height: 620,
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
	window.location.href = "index.cfm?type=Product&deactivate=1&PG_Product_Category_ID="+id;
}
function activated (id){
	window.location.href = "index.cfm?type=Product&activate=1&PG_Product_Category_ID="+id;
}
function deleted (id){
	window.location.href = "index.cfm?type=Product&deleted=1&PG_Product_Category_ID="+id;
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
$("#exm85").click(function() { exportByGroups('product'); });
$("#ebm31").click(function() {
	NewWindow('exportByProduct.cfm', 'exportByProduct', '1000', '750', 'Yes', 'Yes');
});
</script>
<cfparam name="url.deactivate" 			default="0">
<cfparam name="url.activate" 			default="0">
<cfparam name="url.deleted" 			default="0">

<!--- this section is used to deactive product planning groups, this required URL variables(type, deactivate, PG_Product_Category_Id) START --->
<cfif (url.deactivate) AND (url.type IS "Product") AND (isdefined("url.PG_Product_Category_ID"))>
	<cfscript>
    	  PGManager.deActivateProductPG(#url.PG_Product_Category_ID#);
	</cfscript>
</cfif>
<!--- this section is used to deactive product planning groups, this required URL variables(type, deactivate, PG_Product_Category_Id) END --->
<!--- this section is used to active product planning groups, this required URL variables(type, activate, PG_Product_Category_Id) START --->
<cfif (url.activate) AND (url.type IS "Product") AND (isdefined("url.PG_Product_Category_ID"))>
	<cfscript>
    	  PGManager.ActivateProductPG(#url.PG_Product_Category_ID#);
	</cfscript>
</cfif>
<!--- this section is used to active product planning groups, this required URL variables(type, activate, PG_Product_Category_Id) END --->
<!--- this section is used to DELETE product planning groups, this required URL variables(type, deleted, PG_Product_Category_Id) START --->
<cfif (url.deleted) AND (url.type IS "Product") AND (isdefined("url.PG_Product_Category_ID"))>
	<cfscript>
    	  PGManager.delProductPG(#url.PG_Product_Category_ID#);
	</cfscript>
</cfif>
<!--- this section is used to DELETE product planning groups, this required URL variables(type, deleted, PG_Product_Category_Id) END --->
