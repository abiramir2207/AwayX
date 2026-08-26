<cfinclude template="/common_files/jQuery.cfm">
<cfsilent>
<cfparam name="form.command" default="">
<cfparam name="form.nextCommand" default="">
<cfparam name="edit" default = 0>

<!--- This if statement is used to pull info for selected CLASS --->
<cfif form.clicked_edit>
	<cfset one_class_info = VFManager.PVFC(#form.clicked_edit#)>
	<cfset form.nextcommand = "new">
	<cfset form.command = "class">
	<cfset edit = 1>
</cfif>

<cfset vars.action = "List">
<cfif edit>
	<cfset vars.action = "Edit">
<cfelseif form.nextCommand eq 'new'>
	<cfset vars.action = "Add">
</cfif>
</cfsilent>
<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Volume Forecast Classes - <cfoutput>#vars.action#</cfoutput></legend>

<br>
<!--- This if statement is used to pull info for selected CLASS --->
<!--- This if statement is used to Update info for selected CLASS and redirect to main page with class list--->
<cfif form.save_edit>
	<cfif form.isFiscal>
		<cfset form.year = form.Fiscal_Year>
	<cfelse>
		<cfset form.year = form.Calendar_Year>
	</cfif>
	<cfscript>
		VFManager.UVFC(form.save_edit,form.VFClassNumber, form.VFClassDesc, form.IsFiscal, form.year, form.Active);
	</cfscript>
	<cflocation url="index.cfm?command=class&from=class" >
</cfif>
<!--- This if statement is used to Update info for selected CLASS and redirect to main page with class list--->
<!--- This if statement is used to DELETE selected CLASS and redirect to main page with class list--->
<cfif form.clicked_delete>
	<cfset VFManager.DVFC(#form.clicked_delete#)>
	<cflocation url="index.cfm?command=class&from=class" >
</cfif>
<!--- This if statement is used to DELETE selected CLASS and redirect to main page with class list--->
<!--- This if statement is used to SAVE NEW CLASS and redirect to main page with class list--->
<cfif form.clicked_save>
	<cfif form.isFiscal>
		<cfset form.year = form.Fiscal_Year>
	<cfelse>
		<cfset form.year = form.Calendar_Year>
	</cfif>
	<cfscript>
		VFClass  = VFManager.IVFC(form.VFClassNumber, form.VFClassDesc, form.IsFiscal, form.year, form.Active);
	</cfscript>
	<cflocation url="index.cfm?command=class&from=class" >
</cfif>
<!--- This if statement is used to SAVE NEW CLASS and redirect to main page with class list--->

<!--- This if statement is used to DISPLAY LIST OF CLASSES with Options like EDIT and DELETE--->
<cfif (form.command EQ "class") AND (form.nextcommand EQ 0)>


<cfoutput>
	<cfset class_list = VFManager.GVFC() />
	<a href="javascript: clickheader('class', 'new');" style="font-weight: bold;">#ActionText("create new volume forecast class")#</a>
<br><br>

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
    <th>Year Type</th>
    <th>Action</th>
</tr>
</thead>
<tbody>

<cfloop query="class_list">
<tr>
 <td>#VF_Class_Number#</td>
 <td>#VF_Class_Desc#</td>
 <td><cfif is_fiscal> Fiscal<cfelse>Calendar</cfif></td>
 <td><a href="javascript:edit(#VF_Class_ID#);">#ActionText("edit")#</a>&nbsp;<a href="javascript: deleted(#VF_Class_ID#);">#ActionText("delete")#</a></td>
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
  ,"aoColumns": [   {"sWidth": "25%"}
                  , {"sWidth": "45%"}
                  , {"sWidth": "15%", "bSortable":true,  "bSearchable":false}
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
		document.vforecasting.command.value = "EditVFClass";
		document.vforecasting.clicked_edit.value = id;
		document.vforecasting.submit();
}
function deleted(id){
	if(confirm('Do you really want to delete the selected volume forecast class?')){
		document.vforecasting.command.value = "DeleteVFClass";
		document.vforecasting.clicked_delete.value = id;
		document.vforecasting.submit();
	}
}
</script>

<!--- This if statement is used to DISPLAY LIST OF CLASSES with Options like EDIT and DELETE END--->

<!--- This if statement is used to CREATE NEW CLASSES and we also used this section to display info about selected class--->

<cfelseif (form.command EQ "class") AND (form.nextcommand EQ "new")>
<cfoutput>
<table cellspacing="5">

	<tr>
		<td style="font-weight: bold;">Code:</td>
		<td><input type="text" name="VFClassNumber" value=<cfif edit AND len(one_class_info.VF_Class_Number)>#one_class_info.VF_Class_Number#<cfelse>""</cfif> size=10 maxlength=10></td>
	</tr>

	<tr>
		<td style="font-weight: bold;">Description:</td>
		<td><input type="text" name="VFClassDesc" value=<cfif edit AND len(one_class_info.VF_Class_Desc)>#one_class_info.VF_Class_Desc#<cfelse>""</cfif> size=50 maxlength=50></td>
	</tr>

	<tr>
		<td style="font-weight: bold;">Year Type</td>
		<!--- default fiscal year to yes on new class --->
		<cfset vars.isFiscal = ( edit AND (one_class_info.Is_Fiscal EQ 0) ? 0 : 1 )>
		<td><input type="radio" name="IsFiscal" value="1" <cfif vars.isFiscal>checked="checked"</cfif> onClick="show_year_type()">Fiscal
			&nbsp;&nbsp;&nbsp;
			<input type="radio" name="IsFiscal" value="0" <cfif not vars.isFiscal>checked="checked"</cfif> onClick="show_year_type()">Calendar
		</td>
	</tr>
	<tr id="id_fiscal_year">
		<td style="font-weight: bold;">Year</td>
		<td>
			<select name="Fiscal_Year">
				<option value="">*** Select Fiscal Year ***</option>
				<cfloop query="qFiscalYear">
					<option value="#Fiscal_Year#" <cfif edit AND (one_class_info.Year_Selection EQ Fiscal_Year)>SELECTED</cfif>>#Fiscal_Year#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr  id="id_calendar_year">
		<td style="font-weight: bold;">Year</td>
		<td>
			<select name="Calendar_Year">
				<option value="">*** Select Calendar Year ***</option>
				<cfloop query="qCalendarYear">
					<option value="#year#" <cfif edit AND (one_class_info.Year_Selection EQ year)>SELECTED</cfif>>#year#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;">Active:</td>
		<!--- default active to yes on new class --->
		<cfset vars.isActive = ( edit AND (one_class_info.Active EQ 0) ? 0 : 1 )>
		<td>
			<input type="radio" name="Active" value="1" <cfif vars.isActive>checked</cfif>> Yes
			&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Active" value="0" <cfif not vars.isActive>checked</cfif>> No
		</td>
	</tr>

</table>
</cfoutput>

<!----- Save / Cancel / Edit Buttons ----->
<div style="float:left; margin:10px 0 0 20px">
	<cfoutput>
	<cfif edit>
		<a href="javascript:edit_class(#one_class_info.VF_Class_ID#)" style="font-weight: bold;">#ActionText("save")#</a>
	<cfelse>
		<a href="javascript:save_class()" style="font-weight: bold;">#ActionText("save")#</a>
	</cfif>
		<a href="index.cfm?command=class&from=class" style="margin:30px;font-weight: bold;">#ActionText("return to budget classes list")#</a>
	</cfoutput>
</div>
</cfif>
<!--- This if statement is used to CREATE NEW CLASSES and we also used this section to display info about selected class--->
</fieldset>

<script language="javascript">
  function show_year_type(){
	if(document.all.IsFiscal[0].checked){
		document.getElementById('id_fiscal_year').style.display = '';
		document.getElementById('id_calendar_year').style.display = 'none';
	}
	else{
		document.getElementById('id_calendar_year').style.display = '';
		document.getElementById('id_fiscal_year').style.display = 'none';
	}	
  }
  show_year_type();
</script>




