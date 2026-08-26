<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.5.1-min.js"></script>
<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Volume Forecast Groups - List</legend>

<br>

<cfparam name="edit" default = 0>
<!--- This if statement is used to pull info for selected CLASS --->
<cfif form.clicked_edit>
	<cfset one_group_info = VFManager.PVFG(#form.clicked_edit#)>
	<cfset form.nextcommand = "new">
	<cfset form.command = "group">
	<cfset edit = 1>
</cfif>
<!--- This if statement is used to pull info for selected CLASS --->
<!--- This if statement is used to Update info for selected CLASS and redirect to main page with class list--->
<cfif form.save_edit>
	<cfscript>
		VFManager.UVFG(form.save_edit,form.VFGroupNumber, form.VFGroupDesc, form.Active);
	</cfscript>
	<cflocation url="index.cfm?command=group&from=group" >	
</cfif>
<!--- This if statement is used to Update info for selected CLASS and redirect to main page with class list--->
<!--- This if statement is used to DELETE selected CLASS and redirect to main page with class list--->
<cfif form.clicked_delete>
	<cfset VFManager.DVFG(#form.clicked_delete#)>
	<cflocation url="index.cfm?command=group&from=group" >
</cfif>
<!--- This if statement is used to DELETE selected CLASS and redirect to main page with class list--->
<!--- This if statement is used to SAVE NEW CLASS and redirect to main page with class list--->
<cfif form.clicked_save>
	<cfscript>
		VFClass  = VFManager.IVFG(form.VFGroupNumber, form.VFGroupDesc, form.Active);
	</cfscript>
	<cflocation url="index.cfm?command=group&from=group" >
</cfif>
<!--- This if statement is used to SAVE NEW CLASS and redirect to main page with class list--->

<!--- This if statement is used to DISPLAY LIST OF CLASSES with Options like EDIT and DELETE--->

<cfif (form.command EQ "group") AND (form.nextcommand EQ 0)>

<cfoutput>
		<a href="javascript: clickheader('group', 'new');" style="font-weight: bold;">#ActionText("create new volume forecast group")#</a>
<br><br>
<cfset group_list = VFManager.GVFG() />
<cfsavecontent variable="vars.htmlHead">
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
		<style>
		.action { font-weight:bold; margin:0 3px 0 3px; }
		</style>
</cfsavecontent>

<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = StructNew();
</cfscript>

<table id="1" class="datagrid">
<thead>
	<tr>
   		<th>Code</th>
    	<th>Description</th>
    	<th>Action</th>
	</tr>
</thead>
<tbody>
<cfloop Query="group_list">
	<tr>
		 <td>#VF_Group_Number#</td>
		 <td>#VF_Group_Desc#</td>
		 <td><a href="javascript:edit(#VF_Group_ID#);">#ActionText("edit")#</a>&nbsp;<a href="javascript: deleted(#VF_Group_ID#);">#ActionText("delete")#</a></td>
	</tr>
</cfloop>
</tbody>
</table>

</cfoutput>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
var grid = $('#1').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti'
  ,"sScrollXInner": "100%"
  <!---,"sScrollY": "400px"         <!---limit datagrid to 400px in height--->--->
  ,"aaSorting": [[ 0, "asc" ]] <!---default sorting on code column--->
  ,"aoColumns": [   {"sWidth": "35%"}
                  , {"sWidth": "50%"}
                  , {"sWidth": "20%", "bSortable":false, "bSearchable":false} ]
}).fnSetFilteringDelay();
$('table#1 tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);

$('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form input:visible:enabled:first').focus();
<!---new FixedHeader ( grid );--->
function edit(id){
		document.vforecasting.command.value = "EditVFGroup";
		document.vforecasting.clicked_edit.value = id;
		document.vforecasting.submit();
}
function deleted(id){
	if(confirm('Do you really want to delete the selected volume forecast group?')){
		document.vforecasting.command.value = "DeleteVFGroup";
		document.vforecasting.clicked_delete.value = id;
		document.vforecasting.submit();	
	}
}
</script>
<!--- This if statement is used to DISPLAY LIST OF GROUPS with Options like EDIT and DELETE END--->

<!--- This if statement is used to CREATE NEW GROUPS and we also used this section to display info about selected groups--->
<cfelseif (form.command EQ "group") AND (form.nextcommand EQ "new")>
<cfoutput>
<table cellspacing="5">

	<tr>
		<td style="font-weight: bold;">Code:</td>
		<td><input type="text" name="VFGroupNumber" value="<cfif edit AND len(one_group_info.VF_Group_Number)>#one_group_info.VF_Group_Number#<cfelse></cfif>" size="10" maxlength="10"></td>
	</tr>

	<tr>
		<td style="font-weight: bold;">Description:</td>
		<td><input type="text" name="VFGroupDesc" value="<cfif edit AND len(one_group_info.VF_Group_Desc)>#one_group_info.VF_Group_Desc#<cfelse></cfif>" size="50" maxlength="50"></td>
	</tr>

	<tr>
		<td style="font-weight: bold;">Active:</td>
		<td>
			<input type="radio" name="Active" value="1" <cfif edit AND one_group_info.Active>Checked<cfelseif edit EQ 0>Checked</cfif> > Yes
			&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Active" value="0" <cfif edit AND (one_group_info.Active EQ 0)>Checked</cfif>> No
		</td>
	</tr>

</table>



<!----- Save / Cancel / Edit Buttons ----->
<div style="float:left; margin:10px 0 0 20px">

		<a href="javascript:<cfif edit> edit_group(#one_group_info.VF_Group_ID#)<cfelse>save_group()</cfif>" style="font-weight: bold;">#ActionText("save")#</a>
		<a href="index.cfm?command=group&from=group" style="margin:30px;font-weight: bold;">#ActionText("return to volume group list")#</a>

</div>
</cfoutput>
</cfif>
<!--- This if statement is used to CREATE NEW GROUPS and we also used this section to display info about selected groups--->
</fieldset>

