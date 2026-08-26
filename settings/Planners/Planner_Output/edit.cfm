<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\Planners\Planner_Output\edit.cfm
			Date:     2017 September
			Author:   Deepa Kunnath (Copied from Settings/Programs/Claim Rates)
			Purpose:  Add/Edit planner output settings

			Parameter:
					URL.Config_ID - required, numeric. When it has a value of -1 it means users wanted to create a new setting.
                    URL.Config_ID_Copy - optional, numeric. When it has a valid value it means users wanted to copy to create a new setting.
----------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Planner Output Settings</title>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<link rel="stylesheet" type="text/css" href="/common_files/select2.css">
	<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />
  <cfset jQueryUI.version = "1.8.23">
  <cfset jQueryUI.widgets = "full">
  <cfinclude template="/common_files/jQuery.cfm">
	<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>
	<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
  <style>
	fieldset { margin:0 5px; padding: 7px; border: 1px solid blue; }
	legend { font: bold 14px sans-serif; color: red; }
	form, p { margin: 7px 0; }

  label { font-size: 1em; font-weight: bold; margin-right: 7px; }
  p { font-size: 1.0em; color: #006400; }

  #sortable { list-style-type: none; margin: 0 auto; padding: 0; }
  #sortable td { margin: 0 3px 3px 3px; padding-left: 1.1em; height: 24px; }
  #sortable tr span.ui-displayRow { position: absolute; margin-left: -1.2em; }
  #sortable th { text-align: left; padding-left: 0.5em; font-family: Verdana, sans-serif; }
  #sortable input[type=text] { padding-left: 3px;}

  select[name=templates] { width: 450px; }
  .actions { margin-top:10px }
  </style>
</head>

<!--------------------------------------------------------------------------------------------------------------------->
<cfparam name="default_setting" default ="">
<cfparam name="url.config_id_copy" default ="">
<body>
<fieldset>
	<cfoutput>
<legend><cfif url.config_id_copy neq "">Copy<cfelseif url.config_id eq "-1">Create New<cfelse>Edit</cfif> #Application.PlannerLabel# Output Setting</legend>
<cfif cgi.request_method eq "post">
	<cfset saveSettings()>
	<cflocation url="list.cfm" addtoken="false">
</cfif>


<cfscript>
	vars = {};
	vars.plannerSettingCFC = createObject("component", "mvc.models.planner.PlannerSettingsManager");
	vars.templates = vars.plannerSettingCFC.getTemplates();
    if(url.config_id_copy neq "")
        vars.plannerOutputSetting = vars.plannerSettingCFC.getPlannerOutputSettings(url.config_id_copy);
    else
	   vars.plannerOutputSetting = vars.plannerSettingCFC.getPlannerOutputSettings(url.config_id);

    vars.columns = vars.plannerSettingCFC.getPlannerOutputColumnList();

	// grab the column sequences from db if they exist otherwise the default sequence will be based on how the array is created
	// if you need to change the default sequence change the columnOrder value ( display after the colon : )

    if(vars.plannerOutputSetting.recordCount){
        for (vars.column in vars.columns) {
            vars.column.columnOrder = vars.plannerOutputSetting["#vars.column.name#_sequence"][1];
        }

        // sort array of columns based on column orders
        vars.sortedColumns = application.util.array.arrayOfStructsSort(vars.columns, "columnOrder");

    }
    else {

        // default sequence will be based on how the array is created
        vars.sortedColumns = vars.columns;

    }

</cfscript>
</cfoutput>
<form name="editConfig" method="post">
<cfoutput>
<input name="config_id" type="hidden" value="#url.config_id#">

<table style='table-layout:fixed;width:940px'>
<col width="40%">
<col width="60%">
<tr>
	<td>
		<label for="config_name">Name</label><br>
		<input name="config_name" type="text" size="50" <cfif url.config_id neq "-1">value="#vars.plannerOutputSetting.config_name#"</cfif>>
	</td>
	<td>
		<label for="templates">Templates</label><br>
		<select name="templates" multiple="multiple">
			<cfloop query="vars.templates">
				<option value="#vars.templates.Planner_Template_ID#" <cfif vars.templates.Planner_Output_Setting_Config_ID eq url.config_id>selected=selected</cfif>>#vars.templates.Planner_Type# - #vars.templates.Planner_Description#</option>
			</cfloop>
		</select>
	</td>
</tr>
<tr>
	<td class="actions">
		<input type="radio" name="By_Group" <cfif val(vars.plannerOutputSetting.by_group) eq 0>checked=checked</cfif> value="0">By Item
        <input type="radio" name="By_Group" <cfif vars.plannerOutputSetting.by_group eq '1'>checked=checked</cfif> value="1">By Group
	</td>

	<td class="actions">
		<table width="100%">
		<tr>
			<td width="60%">
			Default
			<input type="radio" name="default_setting" <cfif val(vars.plannerOutputSetting.default_setting) eq 1 AND url.config_id neq "-1">checked=checked</cfif> value="1">Yes
			<input type="radio" name="default_setting" <cfif vars.plannerOutputSetting.default_setting eq 0 OR url.config_id eq "-1">checked=checked</cfif> value="0">No
			</td>
			<td width="40%">
			<a href="##" class="save">#application.util.string.actionLinkFormat("save")#</a>
			<a href="##" class="cancel">#application.util.string.actionLinkFormat("cancel")#</a>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>

<p>Click & drag rows using the mouse to place them in a desired sequence. This will control the columns order within #Application.PlannerLabel# Output.</p>
</cfoutput>
<table id="sortable" style='table-layout:fixed;width:100%' class="datagrid">
  <col width="30%">
  <col width="45%">
  <col width="25%">
  <thead>
    <th>Output Column</th>
    <th>Column Label</th>
    <th>Include It</th>
  </thead>
  <tbody>
  	<cfloop array="#vars.sortedColumns#" index="vars.column">
				<cfset displayRow(vars.column.label, vars.column.name)>
	</cfloop>
  </tbody>
</table>

<div class="actions">
	<cfoutput><a href="##" class="save" style="margin-right:30px;">#application.util.string.actionLinkFormat("save")#</a></cfoutput>
	<cfoutput><a href="##" class="cancel">#application.util.string.actionLinkFormat("cancel")#</a></cfoutput>
</div>
</form>
</fieldset>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="displayRow" output="true">
	<cfargument name="columnName">
	<cfargument name="internalName">

	<!---input elements in tr tag would have same prefix which is the arguments.internalName--->
  <tr class="ui-state-default">
      <td><span class="ui-displayRow ui-icon ui-icon-arrowthick-2-n-s"></span>#arguments.columnName#</td>
      <!---input with suffix _Label--->
      <td><input type="text" name="#arguments.internalName#_Label" size="60"
      					value="#vars.plannerOutputSetting[ arguments.internalName & '_Label' ][1]#"
      				>
			</td>
			<!---input with suffix _Include--->
      <td><input type="checkbox" name="#arguments.internalName#_Include" class="include"
      					<cfif vars.plannerOutputSetting[ arguments.internalName & "_Include" ][1] eq 1>
      						checked=checked
      					</cfif>
      					>
      		<!---internal hidden input to keep track of sequence to save in db, value gets updated right after clicking on save--->
      		<input type="hidden" name="#arguments.internalName#_Sequence" class="seq">
      </td>
  </tr>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveSettings" output="false">
	<cfscript>
		vars = {};
		vars.plannerSettingCFC = createObject("component", "mvc.models.planner.PlannerSettingsManager");
		vars.plannerOutputSettings = vars.plannerSettingCFC.savePlannerOutputConfig( form );
	</cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript" src="/script/javascript/select2.min.js"></script>
<script>
  $(function() {
    $("#sortable tbody" ).sortable();
    $("select[name=templates]").multiselect({
   			 noneSelectedText: "Select <cfoutput>#Application.PlannerPrgLabel#</cfoutput> templates.."
   			,selectedText: "# <cfoutput>#Application.PlannerPrgLabel#</cfoutput> template(s) selected"
		});
    $(".cancel").on("click", function() { window.location.href="list.cfm"; });
    $(".save").on("click", function() {
    	var errors = [];
    	var name = $("input[name=config_name]").val();

    	if ( name == "" ) {
    		errors.push( "You forgot to enter the setting name." );
    	}
		/* If the user did not click on "create new setting" AND this setting is the default setting. */
		<cfif URL.Config_ID neq "-1" AND default_setting eq 1>
		if($('input:radio[name=default_setting]:checked').val() == 0)
		{
			errors.push( "You have set the default to 'No'. This setting is the 'default setting' and cannot be removed as the default setting. Please set another setting as the default one first." )
		}
		</cfif>
    	// make sure every included column has a label
    	var includeCount = 0;
    	$(".include:checked").each(function() {
    		includeCount++;
    		// locate the column label input
    		var trParent = $(this).parents('tr'),
    		    columnLabel = trParent.find('input[type=text]');
    		// validate column label
    		if ( columnLabel.val() == "" ) {
    			columnLabel.css("background-color", "yellow");
    			var columnName = trParent.find('td:first').text();
    			errors.push( "You forgot to enter a label for " + columnName + ".");
    		}
    	});
    	if (includeCount == 0) {
    		errors.push( "You need to select at least one column." );
    	}

    	var duplicateExists = false;
		$.ajax({ url: "/mvc/models/planner/PlannerSettingsManager.cfc"
		        ,type: "post"
		        ,timeout:60000
		        ,data: 	{ 	method: "duplicatePlannerOutputSettingExists"
						    ,config_id: $("input[name=config_id]").val()
						  	,config_name: $("input[name=config_name]").val()
						}
		        ,dataType: "json"
		        ,async: false
		        ,success: function(json) { duplicateExists = json.DUPLICATEEXISTS; }
	  	});
	  	if (duplicateExists) {
	  		errors.push("The selected name has already been used by others.");
	  	}

    	if ( errors.length == 0 ) {
    		var seq = 100;
    		$(".seq").each(function() { seq = seq + 10;
    				/*assign sequence value based on position*/
    				$(this).val( seq );
    		});

			var defaultSettingSave = 1;
			/* If the user clicked on "create new setting" AND a different default setting already exists. */
			<cfif URL.Config_ID eq "-1" AND default_setting eq 1>
			if($('input:radio[name=default_setting]:checked').val() == 1)
			{
				if( window.confirm("You have set the default to 'Yes'. There is an already an existing default setting. Do you want to make this setting as the default setting instead? ")){
					defaultSettingSave = 1;
				}
				else{
					defaultSettingSave = 0;
				}

			}
			</cfif>
			if(defaultSettingSave == 1){
    			$("form[name=editConfig]").submit();
			}

    	}
    	else {
    		alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
    	}
    });

    $('#clause').select2( { width:"300", placeholder:"Choose..." } );
  });
</script>
</body>
</html>