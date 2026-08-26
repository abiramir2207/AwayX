<!----------------------------------------------------------------------------------
Name         :	index.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/09/2016
Created By   : 	Anand Rao
Description  : 	Add/Edit claim Calendar info. settings
---------------------------------------------------------------------------------->
<!DOCTYPE HTML>

<html lang="en">
<head>
	<cfsavecontent variable="head_content">
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Planner: Calendar Info</title>
		<cfinclude template="/common_files/jQuery.cfm">
		<cf_include file_to_include="/common_files/datatable.css"/>
		<cfset jQueryUI.widgets = "full">
		<cfinclude template="/common_files/jQueryUI.cfm">
		<style>
		  fieldset { margin:0 5px; padding: 7px; border: 1px solid blue; }
		  legend { font: bold 14px sans-serif; color: red; }
		  form, p { margin: 7px 0; }

		  label { font-size: 1em; font-weight: bold; margin-right: 7px; }
		  p { font-size: 1.0em; color: #006400; }
		  #sortable { list-style-type: none; margin: 0 auto; padding: 0; }
		  #sortable td { margin: 0 3px 3px 3px; padding-left: 1.1em; height: 24px; background-color: white !important;}
		  #sortable tr span.ui-displayRow { position: absolute; margin-left: -1.2em; margin-top:-3px; }
		  #sortable th { text-align: left; padding-left: 0.5em; font-family: Verdana, sans-serif; }
		  #sortable input[type=text] { padding-left: 3px;}
		  select[name=templates] { width: 450px; }
		  .actions { margin-top:10px }
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
<!--------------------------------------------------------------------------------------------------------------------->
<CFSET pagetitle = "#Application.PlannerLabel#: Calendar info">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<fieldset>
<cfoutput>
<legend>#Application.PlannerLabel#: Calendar Info</legend>

<cfif cgi.request_method eq "post">
	<cfset saveSettings()>
</cfif>


<cfset vars = {} />
<cfset vars.plannerSettingsManagerCFC = createObject("component", "mvc.Models.Planner.PlannerSettingsManager") />
<cfset calendarInfoSetting= vars.plannerSettingsManagerCFC.GetCalendarInfo()/ >

</cfoutput>

<form name="frmCalendarInfo" method="post">


<p>Click & drag rows using the mouse to place them in a desired sequence. This will control the columns order.</p>
 <br>
	<table id="sortable" border="1" style='table-layout:fixed;width:50%' class="datagrid" align="left">
		<col width="10%">
		<col width="40%">
		<col width="15%">
		<thead>
		<tr>
			<th>Order</th>
			<th>Description</th>
			<th>Include?</th>
		</tr>
		</thead>
		<tbody>
            <cfoutput query="calendarInfoSetting">
                <!---input elements in tr tag would have same prefix which is the arguments.internalName--->
              <tr class="ui-state-default">
                  <td><span class="ui-displayRow ui-icon ui-icon-arrowthick-2-n-s"></span> &nbsp;#calendarInfoSetting.Sort_Order#</td>
                  <td>#ReplaceNoCase(calendarInfoSetting.Description, 'program', '#Application.PlannerPrgLabel#')#</td>
                  <td>
                    <input type="checkbox" name="Include_#calendarInfoSetting.Planner_Calendar_Config_ID#" class="include"
                        <cfif calendarInfoSetting.include_in_Planner eq 1>
                            checked=checked
                        </cfif>
                    >
                        <!---internal hidden input to keep track of soft order to save in db, value gets updated right after clicking on save--->
                          <input type="hidden" name="Sequence_#calendarInfoSetting.Planner_Calendar_Config_ID#" class="seq">
                  </td>
              </tr>
            </cfoutput>
		</tbody>
	</table>

	 <div class="actions" style="clear:both;"> <br>

		<cfoutput><a href="##" class="save default" style="margin-right:30px;" title="Save the changes on this page">#application.util.string.LinkFormat("save")#</a></cfoutput>
		<cfoutput><a href="##" class="cancel opaque-h" title="Cancel the changes made and reload this page">#application.util.string.LinkFormat("cancel changes & reload")#</a></cfoutput>
	</div>

<cfoutput>
<input type="hidden" name="lsCalendarConfigIDs" value="#valueList(calendarInfoSetting.Planner_Calendar_Config_ID)#" >
</cfoutput>
</form>
</fieldset>


<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveSettings" output="false">
	<cfscript>
		vars = {};
		vars.plannerSettingsManagerCFC = createObject("component", "mvc.Models.Planner.PlannerSettingsManager");
		vars.calendarInfoSetting = vars.plannerSettingsManagerCFC.saveCalendarInfoSetting();
	</cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cf_include files="/script/javascript/select2.min.js">
<script>
  $(function() {
	$("#sortable tbody" ).sortable({axis: 'y'});
	$(".cancel").on("click", function() { window.location.href="index.cfm"; });
	$(".save").on("click", function() {
		var errors = [];
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

		if ( errors.length == 0 ) {
			var seq = 0;
			$(".seq").each(function() { seq = seq + 1;
					/*assign sequence value based on position*/
					$(this).val( seq );
			});
			$("form[name=frmCalendarInfo]").submit();
		}
		else {
			alert( errors.join("\n") + "\n\nPlease make the corrections and try again." );
		}
	});
  });
</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>