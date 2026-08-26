<!----------------------------------------------------------------------------------
Name         :	index.cfm
Created Date : 	2020 May
Created By   : 	Chris Nguyen
Description  : 	Scorecard summary settings
---------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html lang="en">
<head>
	<cfsavecontent variable="head_content">
		<meta charset="utf-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<title>Planner: Scorecard Summary</title>
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
          fieldset {
                width: 550px;
                padding: 10px 15px;
          }
          .last_updated {
                background-color: #ffedd2;
                border-bottom: 1px solid #d8d9dd;
                border-radius: 5px;
                color: #343540;
                font-size: 12px;
                margin-bottom: 10px;
                padding: 7px 0 5px 5px;
          }
        </style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
<!--------------------------------------------------------------------------------------------------------------------->
<CFSET pagetitle = "#Application.PlannerLabel# Scorecard Summary">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<fieldset class="borderbox">
<!--- <legend>Planner: Scorecard Summary</legend> --->

<cfset vars = {}>
<cfset vars.plannerSettingsManager = createObject("component", "mvc.Models.Planner.PlannerSettingsManager")>

<cfparam name="form.action" default="">

<cfif form.action is "post">
    <cfset vars.plannerSettingsManager.setScorecard_Settings( form )>
</cfif>
<cfset qSettings= vars.plannerSettingsManager.getScorecard_Settings()>

<form name="settings" method="post">

<cfif qSettings.Updated_By neq ''>
    <cfoutput>
        <p class="last_updated">The settings were last updated on <b>#dateFormat(qSettings.Updated_Date, "medium")#</b> at #timeFormat(qSettings.Updated_Date, "short")# by <b>#qSettings.Changed_by#</b></p>
    </cfoutput>
</cfif>
<p>Click & drag rows using the mouse to place them in a desired sequence. This will control the column order.</p>
 <br>
	<table id="sortable" border="1" style='table-layout:fixed;width:100%;padding:15px;' class="datagrid" align="left">
		<col width="10%">
		<col width="37%">
		<col width="37%">
		<col width="15%">
		<thead>
		<tr>
			<th>Order</th>
			<th>Blacksmith Label</th>
			<th>Custom Label</th>
			<th>Enabled?</th>
		</tr>
		</thead>
        <tbody>
            <cfoutput query="qSettings">
              <tr class="ui-state-default">
                  <td><span class="ui-displayRow ui-icon ui-icon-arrowthick-2-n-s"></span> &nbsp;#qSettings.Sequence#</td>
                  <td>
                    #qSettings.Blacksmith_Label#
                  </td>
                  <td>
                    <input type="text" class="user_label" blacksmith="#qSettings.Blacksmith_Label#" name="user_label_#qSettings.Internal_ID#" value="#qSettings.User_Label#">
                  </td>
                  <td>

                    <input type="checkbox" name="Enabled_#qSettings.Internal_ID#" class="include" value="1"
                        <cfif qSettings.Enabled eq 1>
                            checked=checked
                        </cfif>
                    >
                    <!---internal hidden input to keep track of soft order to save in db, value gets updated right after clicking on save--->
                    <input type="hidden" name="Sequence_#qSettings.Internal_ID#" class="seq">
                  </td>
              </tr>
            </cfoutput>
		</tbody>
	</table>

     <div class="actions" style="clear:both;"> <br>

        <button class="button recommended save">save</button>
        <button class="button cancel">cancel changes & reload</button>
	</div>

<cfoutput>
<input type="hidden" name="all_ids" value="#valueList(qSettings.Internal_ID)#" >
<input type="hidden" name="action">
</cfoutput>
</form>
</fieldset>


<!--------------------------------------------------------------------------------------------------------------------->

<!--- <cf_include files="/script/javascript/select2.min.js"> --->
<script>
  $(function() {
	$("#sortable tbody" ).sortable({axis: 'y'});
	$(".cancel").on("click", function() { window.location.href="index.cfm"; });
	$(".save").on("click", function() {
		var errors = [];
		$("input.user_label").each(function() {
            $(this).val( $(this).val().trim() );
			if ( $(this).val() == "" ) {
				errors.push( "Please enter a custom label for " + $(this).attr("blacksmith") + ".");
			}
		});

		if ( errors.length ) {
            alert( errors.join("\n")  );
            return false;
        }

        var seq = 0;
        $(".seq").each(function() { seq = seq + 1;
            /*assign sequence value based on position*/
            $(this).val( seq );
        });
        zeroCheckBoxes();
        $("input[name=action]").val("post");
        $("form[name=settings]").submit();
	});
  });

    //   setTimeout(function(){ $("p.feedback").remove(); }, 3000);
</script>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>