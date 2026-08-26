<cfsilent>
<cfparam name="form.nextcommand" default="0">
<cfparam name="form.clicked_save" default="0">
<cfparam name="form.clicked_delete" default="0" >
<cfparam name="url.clicked_edit" default="0">
<cfparam name="form.clicked_edit" default="#url.clicked_edit#" >
<cfparam name="form.clicked_copy" default="0" >
<cfparam name="form.save_edit" default = "0">
<cfparam name="url.from" default="class"><!--- D30441:Volume Forecasting -- issues --->
<cfparam name="url.command" default="plan">
<cfparam name="form.command" default=#url.command#>
<cfparam name="form.prodpg_list" default="">
<cfparam name="form.distpg_list" default="">
<cfparam name="form.bsid" default="0">
<cfparam name="form.bsid_remove" default="0">
<cfparam name="GetHelpURL" default="0">
<cfset pagetitle = "PROGRAMS: Volume Forecast">

<cfset selectedIndex = 99>
<cfswitch expression="#form.command#">
  <cfcase value="class,saveVFClass,DeleteVFClass,EditVFClass">
    <cfset selectedIndex = 0>
  </cfcase>
  <cfcase value="group,saveVFGroup,DeleteVFGroup,EditVFGroup">
    <cfset selectedIndex = 1>
  </cfcase>
  <cfcase value="labels">
    <cfset selectedIndex = 2>
  </cfcase>
  <cfcase value="plan,saveVFPlan,DeleteVFPlan,EditVFPlan,CopyVFPlan">
    <cfset selectedIndex = 3>
  </cfcase>
  <cfcase value="research">
    <cfset selectedIndex = 4>
  </cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
              layoutID = "volumeForecastSettings"
              selectedIndex = "#selectedIndex#" >

			<script type="text/javascript" src="/script/tTip.js"></script>
			<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
<style>
	#bold{
		font-weight: bold;
	}
</style>



<cfset VFManager = createObject('component','components.programs.volume.volume_forecast') />
<cfset qFiscalYear = VFManager.getFiscalYear() />
<cfset qCalendarYear = VFManager.getCalendarYear() />


<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">

<div style="width:98%;">
<form method="post" name="vforecasting" style="display:inline;">

	<!--- <cfinclude template="header.cfm">  --->

	<input type="hidden" name="command" value="class">
	<input type="hidden" name="nextcommand" value="0">
	<input type="hidden" name="clicked_save" value="0">
	<input type="hidden" name="clicked_delete" value="0">
	<input type="hidden" name="clicked_edit" value="0">
	<input type="hidden" name="clicked_copy" value="0">
	<input type="hidden" name="save_edit" value="0">
	<input type="hidden" name="prodpg_list" value=<cfoutput>"#form.prodpg_list#"</cfoutput>>
	<input type="hidden" name="distpg_list" value=<cfoutput>"#form.distpg_list#"</cfoutput>>
	<input type="hidden" name="load_fromdb" value="0">
	<input type="hidden" name="bsid" value="0">
	<input type="hidden" name="bsid_remove" value="0">
	<cfswitch expression="#form.command#">
		<cfcase value="class,saveVFClass,DeleteVFClass,EditVFClass">
		<cfinclude template="class.cfm" />
		</cfcase>
		<cfcase value="group,saveVFGroup,DeleteVFGroup,EditVFGroup">
		<cfinclude template="group.cfm" />
		</cfcase>
		<cfcase value="labels">
		<cfinclude template="label.cfm" />
		</cfcase>
		<cfcase value="plan,saveVFPlan,DeleteVFPlan,EditVFPlan,CopyVFPlan">
		<cfinclude template="plan.cfm" />
		</cfcase>
		<cfcase value="research">
		<cfinclude template="research.cfm" />
		</cfcase>
	</cfswitch>
</form>
</div>

<!-- send table data to csv.cfm page  -->
<form action="/Common_Files/csv.cfm" method ="post" id="csv_form">
	<input type="hidden" name="csv_text" id="csv_text">
</form>

<script type="text/javascript">
function clickheader( action, nextaction ) {
  document.vforecasting.command.value = action;
  document.vforecasting.nextcommand.value = nextaction;
  document.vforecasting.submit();
}
function save_class() {
		var msg = '';
		//D30584:Alert box display in wrong scenario START
		var radios = document.vforecasting.elements["IsFiscal"];
			for (var i=0; i <radios.length; i++) {
  				if (radios[i].checked) {
  					var calender = radios[i].value;
  				}
			 }
		//D30584:Alert box display in wrong scenario END
	if(document.vforecasting.VFClassNumber.value == ''){
		var msg = msg.concat("Code ");
	}
	if(document.vforecasting.VFClassDesc.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Description ");
	}
	//D30584:Alert box display in wrong scenario START
if (calender == 1) {
	if (document.vforecasting.Fiscal_Year.value == '') {
		if (msg.length > 0) {
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Year ");
	}
}
else if (calender == 0){
	if (document.vforecasting.Calendar_Year.value == '') {
		if (msg.length > 0) {
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Year ");
	}
}//D30584:Alert box display in wrong scenario END
  if (msg.length > 0) {
  	alert(msg + 'field(s) cannot be empty.');
  }
  else {
  	document.vforecasting.command.value = "saveVFClass";
  	document.vforecasting.clicked_save.value = "1";
  	document.vforecasting.submit();
  }
}
function edit_class(id) {
  document.vforecasting.command.value = "editVFClass";
  document.vforecasting.save_edit.value = id;
  document.vforecasting.submit();
}
function save_group() {
	var msg = '';
	if(document.vforecasting.VFGroupNumber.value == ''){
		var msg = msg.concat("Code ");
	}
	if(document.vforecasting.VFGroupDesc.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Description ");
	}

  if (msg.length > 0) {
  	alert(msg + 'field(s) cannot be empty.');
  }
  else {
  	document.vforecasting.command.value = "saveVFGroup";
  	document.vforecasting.clicked_save.value = "1";
  	document.vforecasting.submit();
  }
}
function edit_group(id) {
  document.vforecasting.command.value = "editVFGroup";
  document.vforecasting.save_edit.value = id;
  document.vforecasting.submit();
}
function save_plan() {
			var msg = '';
	if(document.vforecasting.VFPlanNumber.value == ''){
		var msg = msg.concat("Code ");
	}
	if(document.vforecasting.VFPlanDesc.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Description ");
	}
  	if(document.vforecasting.VFPlanClass.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Class ");
	}
  	if(document.vforecasting.VFPlanGroup.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Group ");
	}
  	if(document.vforecasting.VFPlanSegment.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Segment ");
	}
  	if(document.vforecasting.VFPlanUOM.value == ''){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("UOM ");
	}
  	if(document.vforecasting.VFPlanForecast.value == '-1'){
		if(msg.length > 0){
			var msg = msg.concat(", ");
		}
		var msg = msg.concat("Forecast Level ");
	}
  if (msg.length > 0) {
  	alert(msg + 'field(s) cannot be empty.');
  }
  else {
  	document.vforecasting.command.value = "saveVFPlan";
  	document.vforecasting.clicked_save.value = "1";
  	document.vforecasting.submit();
  }
}
function edit_plan(id) {
  document.vforecasting.command.value = "editVFPlan";
  document.vforecasting.save_edit.value = id;
  document.vforecasting.prodpg_list.value = <cfoutput>"#form.prodpg_list#"</cfoutput>
  document.vforecasting.distpg_list.value = <cfoutput>"#form.distpg_list#"</cfoutput>
  document.vforecasting.submit();
}
<!--- D30441:Volume Forecasting -- issues START--->
function calculate(id){
	NewWindow('calculate.cfm?id='+id,'Forecast', 'width=200, height=200, top=100, left=100');
}
<!--- D30441:Volume Forecasting -- issues ENd--->
$('form input:visible:enabled:first').focus();
</script>

</cfmodule>