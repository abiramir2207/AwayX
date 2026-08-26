<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\Claim_Rates\edit.cfm
			Date:     2013 June
			Author:   Chris Nguyen
			Purpose:  Add/Edit claim rates settings

			Parameter:
					URL.Config_ID - required, numeric. When it has a value of -1 it means users wanted to create a new setting.
----------------------------------------------------------------------------------------------------------------------->
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Claim Rates Settings</title>
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
<body>
<fieldset>
<legend><cfif url.config_id eq "-1">Create New<cfelse>Edit</cfif> Claim Rates Setting</legend>
<cfif cgi.request_method eq "post">
	<cfset saveSettings()>
	<cflocation url="list.cfm" addtoken="false">
</cfif>

<cfoutput><cfscript>
	vars = {};
	vars.claimRateCFC = createObject("component", "components.programs.claimRates");
	vars.templates = vars.claimRateCFC.getTemplates();
  vars.claimRateSetting = vars.claimRateCFC.getClaimRates( url.config_id );

	// grap the column sequences from db if they exist otherwise use the default sequence as layout in this array
	// if you need to change the default sequence change the columnOrder value ( display after the colon : )
	// TO DO: make changes to this statement whenever Claim_Rates_Setting schema is changed
  vars.columns = [ {name="program_Number", columnOrder="#vars.claimRateSetting.program_number_sequence#"}
  	              ,{name="program_Title", columnOrder="#vars.claimRateSetting.program_Title_sequence#"}
  	              ,{name="effective_Date", columnOrder="#vars.claimRateSetting.effective_Date_sequence#"}
  	              ,{name="distributor_ID", columnOrder="#vars.claimRateSetting.distributor_ID_sequence#"}
  	              ,{name="distributor_Name", columnOrder="#vars.claimRateSetting.distributor_Name_sequence#"}
  	              ,{name="buying_Group_Id", columnOrder="#vars.claimRateSetting.buying_Group_Id_sequence#"}
  	              ,{name="buying_Group_Name", columnOrder="#vars.claimRateSetting.buying_Group_Name_sequence#"}
  	              ,{name="broker_ID", columnOrder="#vars.claimRateSetting.broker_ID_sequence#"}
  	              ,{name="broker_Name", columnOrder="#vars.claimRateSetting.broker_Name_sequence#"}
  	              ,{name="family_Name", columnOrder="#vars.claimRateSetting.family_Name_sequence#"}
  	              ,{name="start_Date", columnOrder="#vars.claimRateSetting.start_Date_sequence#"}
  	              ,{name="end_Date", columnOrder="#vars.claimRateSetting.end_Date_sequence#"}
  	              ,{name="component_Type", columnOrder="#vars.claimRateSetting.component_Type_sequence#"}
  	              ,{name="component_Name", columnOrder="#vars.claimRateSetting.component_Name_sequence#"}
  	              ,{name="Distributor_Product_Number", columnOrder="#vars.claimRateSetting.Distributor_Product_Number_sequence#"}
  	              ,{name="GTin", columnOrder="#vars.claimRateSetting.GTin_sequence#"}
  	              ,{name="item_Number", columnOrder="#vars.claimRateSetting.item_Number_sequence#"}
  	              ,{name="item_Description", columnOrder="#vars.claimRateSetting.item_Description_sequence#"}
  	              ,{name="distributor_Fob_Price_Per_Case", columnOrder="#vars.claimRateSetting.distributor_Fob_Price_Per_Case_sequence#"}
  	              ,{name="inbound_Freight_Per_Case", columnOrder="#vars.claimRateSetting.inbound_Freight_Per_Case_sequence#"}
  	              ,{name="outbound_Freight_Per_Case", columnOrder="#vars.claimRateSetting.outbound_Freight_Per_Case_sequence#"}
  	              ,{name="distributor_Final_Price_Per_Case", columnOrder="#vars.claimRateSetting.distributor_Final_Price_Per_Case_sequence#"}
  	              ,{name="operator_Contract_Price_Per_Case", columnOrder="#vars.claimRateSetting.operator_Contract_Price_Per_Case_sequence#"}
  	              ,{name="expected_Fixed_Price_Claim_Rate_Per_Case", columnOrder="#vars.claimRateSetting.expected_Fixed_Price_Claim_Rate_Per_Case_sequence#"}
  	              ,{name="expected_Rebate_Rate_Per_Case", columnOrder="#vars.claimRateSetting.expected_Rebate_Rate_Per_Case_sequence#"}
  	              ,{name="Case_Count_Desc", columnOrder="#vars.claimRateSetting.Case_Count_Desc_sequence#"}
  	              ,{name="Program_Fixed_Price_Per_Case", columnOrder="#vars.claimRateSetting.Program_Fixed_Price_Per_Case_sequence#"}
  	              ,{name="Operator_ID", columnOrder="#vars.claimRateSetting.Operator_ID_sequence#"}
  	              ,{name="Operator_Name", columnOrder="#vars.claimRateSetting.Operator_Name_sequence#"}

  	              ,{name="Program_Fixed_Price_Per_Pound", columnOrder="#vars.claimRateSetting.Program_Fixed_Price_Per_Pound_sequence#"}
  	              ,{name="Rebate_Per_Program_Pound", columnOrder="#vars.claimRateSetting.Rebate_Per_Program_Pound_sequence#"}
  	              ,{name="Program_Volume_Per_Pound", columnOrder="#vars.claimRateSetting.Program_Volume_Per_Pound_sequence#"}
  	              ,{name="Program_Volume_Per_Case", columnOrder="#vars.claimRateSetting.Program_Volume_Per_Case_sequence#"}
  	              ,{name="Prod_Var_A", columnOrder="#vars.claimRateSetting.Prod_Var_A_sequence#"}
  	              ,{name="Prod_Var_B", columnOrder="#vars.claimRateSetting.Prod_Var_B_sequence#"}
  	              ,{name="Type_Code", columnOrder="#vars.claimRateSetting.Type_Code_sequence#"}
  	              ,{name="Type_Group", columnOrder="#vars.claimRateSetting.Type_Group_sequence#"}
  	              ,{name="QBrand", columnOrder="#vars.claimRateSetting.QBrand_sequence#"}
  	              ,{name="Brand", columnOrder="#vars.claimRateSetting.Brand_sequence#"}
  	              ,{name="RSP", columnOrder="#vars.claimRateSetting.RSP_sequence#"}
  	              ,{name="RSP_Position", columnOrder="#vars.claimRateSetting.RSP_Position_sequence#"}
  	              ,{name="Currency_Conversion_Factor", columnOrder="#vars.claimRateSetting.Currency_Conversion_Factor_sequence#"}
  	              ,{name="Currency_Code", columnOrder="#vars.claimRateSetting.Currency_Code_Sequence#"}
  	              ,{name="Bid_Open_Date", columnOrder="#vars.claimRateSetting.Bid_Open_Date_Sequence#"}
  	              ,{name="Effective_Date_For_Price", columnOrder="#vars.claimRateSetting.Effective_Date_For_Price_Sequence#"}
  	              ,{name="Legacy_ID", columnOrder="#vars.claimRateSetting.Legacy_ID_Sequence#"}
  	              ,{name="Line_Number", columnOrder="#vars.claimRateSetting.Line_Number_Sequence#"}
 	              ,{name="Program_Percent_Rate", columnOrder="#vars.claimRateSetting.Program_Percent_Rate_sequence#"}
  	            ];

  // sort array of columns based on column orders
  vars.sortedColumns = application.util.array.arrayOfStructsSort(vars.columns, "columnOrder");

  vars.clauseCFC = createObject("component", "components.clause_library.ClauseLibraryManager").init();
  vars.clauses = vars.clauseCFC.search();
</cfscript>
</cfoutput>

<!---<cfdump var="#vars.clauses#">--->

<form name="editClaimRate" method="post">
<cfoutput>
<input name="config_id" type="hidden" value="#url.config_id#">
<!---<div id="topSection">
	<label for="config_name">Name:</label>
	<input name="config_name" type="text" size="50" <cfif url.config_id neq "-1">value="#vars.claimRateSetting.config_name#"</cfif> <cfif vars.claimRateSetting.config_name eq "default" and url.config_id neq "-1">disabled</cfif>>
	<select name="templates" multiple="multiple" <cfif url.config_id neq "-1" and vars.claimRateSetting.config_name eq "default">disabled</cfif>>
		<cfloop query="vars.templates">
			<option value="#vars.templates.first_parent_id#" <cfif vars.templates.Claim_Rates_Config_ID eq url.config_id>selected=selected</cfif>>#vars.templates.created_type# - #vars.templates.program_description#</option>
		</cfloop>
	</select><br>
	<div class="actions">
	<label for="clause">Clause:</label>
	<select name="clause" id="clause">
		<!---<option value="">Select a clause</option>--->
		<option></option>   // this option is required for placeholder text to work
		<cfloop query="vars.clauses">
			<option value="#vars.clauses.clause_library_id#">#vars.clauses.clause_Category_Name#</option>
		</cfloop>
	</select>
	<a href="##" class="save">#application.util.string.actionLinkFormat("save")#</a>
	<a href="##" class="cancel">#application.util.string.actionLinkFormat("cancel")#</a>
	</div>
</div>
--->
<table style='table-layout:fixed;width:940px'>
<col width="40%">
<col width="60%">
<tr>
	<td>
		<label for="config_name">Name</label><br>
		<!---Tim Ford - 08/04/2014: Label 44209 - Claim Rates Settings - enable Name & Template fields. Always allow name and template to be editable.
		<input name="config_name" type="text" size="50" <cfif url.config_id neq "-1">value="#vars.claimRateSetting.config_name#"</cfif> <cfif vars.claimRateSetting.config_name eq "default" and url.config_id neq "-1">disabled</cfif>>
		--->
		<input name="config_name" type="text" size="50" <cfif url.config_id neq "-1">value="#vars.claimRateSetting.config_name#"</cfif>>
	</td>
	<td>
		<label for="templates">Templates</label><br>
		<!---Tim Ford - 08/04/2014: Label 44209 - Claim Rates Settings - enable Name & Template fields. Always allow name and template to be editable.
		<select name="templates" multiple="multiple" <cfif url.config_id neq "-1" and vars.claimRateSetting.config_name eq "default">disabled</cfif>>
		--->
		<select name="templates" multiple="multiple">
			<cfloop query="vars.templates">
				<option value="#vars.templates.first_parent_id#" <cfif vars.templates.Claim_Rates_Config_ID eq url.config_id>selected=selected</cfif>>#vars.templates.created_type# - #vars.templates.program_description#</option>
			</cfloop>
		</select>
	</td>
</tr>
<tr>
	<td>
		<label for="clause">Clause</label><br>
		<select name="clause_library_id" id="clause" style="width:300px;">
			<!---<option value="">Select a clause</option>--->
			<option></option>   // this option is required for placeholder text to work
			<option value="0">Do Not Include Clause</option>
			<cfloop query="vars.clauses">
				<option <cfif vars.clauses.clause_library_id eq vars.claimRateSetting.clause_library_id>selected=selected</cfif> value="#vars.clauses.clause_library_id#">� #vars.clauses.clause_Category_Name# � #application.util.string.fullLeft(REReplace(vars.clauses.Clause_Library_Body,'<[^>]*>','','all'),250)#</option>
			</cfloop>
		</select>
	</td>
	<td class="actions">
		<table width="100%">
		<tr>
			<td width="33%">
			<input type="radio" name="By_Group" <cfif val(vars.claimRateSetting.by_group) eq 0>checked=checked</cfif> value="0">By Item
			<input type="radio" name="By_Group" <cfif vars.claimRateSetting.by_group eq '1'>checked=checked</cfif> value="1">By Group
			</td>
			<td width="33%">
			Default
			<input type="radio" name="default_setting" <cfif val(vars.claimRateSetting.default_setting) eq 1 AND url.config_id neq "-1">checked=checked</cfif> value="1">Yes
			<input type="radio" name="default_setting" <cfif vars.claimRateSetting.default_setting eq 0 OR url.config_id eq "-1">checked=checked</cfif> value="0">No
			</td>
			<td width="34%">
			<a href="##" class="save">#application.util.string.actionLinkFormat("save")#</a>
			<a href="##" class="cancel">#application.util.string.actionLinkFormat("cancel")#</a>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
</cfoutput>

<p>Click & drag rows using the mouse to place them in a desired sequence. This will control the columns order within Claim Rates Report.</p>
<table id="sortable" style='table-layout:fixed;width:100%' class="datagrid">
  <col width="30%">
  <col width="45%">
  <col width="25%">
  <thead>
    <th>Claim Rates Column</th>
    <th>Column Label</th>
    <th>Include It</th>
  </thead>
  <tbody>
		<!---TO DO: make changes to this statement whenever Claim_Rates_Setting schema is changed--->
  	<cfloop array="#vars.sortedColumns#" index="vars.column">
  		<cfswitch expression="#vars.column.name#">
		  	<cfcase value="program_Number">  <cfset displayRow("Program Number", vars.column.name)>  </cfcase>
		  	<cfcase value="program_Title">  <cfset displayRow("Program Title", vars.column.name)>  </cfcase>
		  	<cfcase value="effective_Date">  <cfset displayRow("Effective Date", vars.column.name)>  </cfcase>
		  	<cfcase value="distributor_ID">  <cfset displayRow("Distributor ID", vars.column.name)>  </cfcase>
		  	<cfcase value="distributor_Name">  <cfset displayRow("Distributor Name", vars.column.name)>  </cfcase>
		  	<cfcase value="buying_Group_Id">  <cfset displayRow("Buying Group ID", vars.column.name)>  </cfcase>
		  	<cfcase value="buying_Group_Name">  <cfset displayRow("Buying Group Name", vars.column.name)>  </cfcase>
		  	<cfcase value="broker_ID">  <cfset displayRow("Broker ID", vars.column.name)>  </cfcase>
		  	<cfcase value="broker_Name">  <cfset displayRow("Broker Name", vars.column.name)>  </cfcase>
		  	<cfcase value="family_Name">  <cfset displayRow("Family Name", vars.column.name)>  </cfcase>
		  	<cfcase value="start_Date">  <cfset displayRow("Start Date", vars.column.name)>  </cfcase>
		  	<cfcase value="end_Date">  <cfset displayRow("End Date", vars.column.name)>  </cfcase>
		  	<cfcase value="component_Type">  <cfset displayRow("Component Type", vars.column.name)>  </cfcase>
		  	<cfcase value="component_Name">  <cfset displayRow("Component Name", vars.column.name)>  </cfcase>
		  	<cfcase value="Distributor_Product_Number">  <cfset displayRow("Distributor Product Number", vars.column.name)>  </cfcase>
		  	<cfcase value="GTin">  <cfset displayRow("GTIN", vars.column.name)>  </cfcase>
		  	<cfcase value="item_Number">  <cfset displayRow("Item Number", vars.column.name)>  </cfcase>
		  	<cfcase value="item_Description">  <cfset displayRow("Item Description", vars.column.name)>  </cfcase>
		  	<cfcase value="distributor_Fob_Price_Per_Case">  <cfset displayRow("Distributor Fob Price Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="inbound_Freight_Per_Case">  <cfset displayRow("Inbound Freight Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="outbound_Freight_Per_Case">  <cfset displayRow("Outbound Freight Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="distributor_Final_Price_Per_Case">  <cfset displayRow("Distributor Final Price Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="operator_Contract_Price_Per_Case">  <cfset displayRow("Operator Contract Price Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="expected_Fixed_Price_Claim_Rate_Per_Case">  <cfset displayRow("Expected Fixed Price Claim Rate Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="expected_Rebate_Rate_Per_Case">  <cfset displayRow("Expected Rebate Rate Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="Case_Count_Desc">  <cfset displayRow("Case Count Description", vars.column.name)>  </cfcase>
		  	<cfcase value="Program_Fixed_Price_Per_Case">  <cfset displayRow("Program Fixed Price Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="Operator_ID">  <cfset displayRow("Operator ID", vars.column.name)>  </cfcase>
		  	<cfcase value="Operator_Name">  <cfset displayRow("Operator Name", vars.column.name)>  </cfcase>

		  	<cfcase value="Program_Fixed_Price_Per_Pound">  <cfset displayRow("Program Fixed Price Per Pound", vars.column.name)>  </cfcase>
		  	<cfcase value="Rebate_Per_Program_Pound">  <cfset displayRow("Rebate Per Program Pound", vars.column.name)>  </cfcase>
		  	<cfcase value="Program_Volume_Per_Pound">  <cfset displayRow("Program Volume Per Pound", vars.column.name)>  </cfcase>
		  	<cfcase value="Program_Volume_Per_Case">  <cfset displayRow("Program Volume Per Case", vars.column.name)>  </cfcase>
		  	<cfcase value="Prod_Var_A">  <cfset displayRow("Prod Var A", vars.column.name)>  </cfcase>
		  	<cfcase value="Prod_Var_B">  <cfset displayRow("Prod Var B", vars.column.name)>  </cfcase>
		  	<cfcase value="Type_Code">  <cfset displayRow("Type Code", vars.column.name)>  </cfcase>
		  	<cfcase value="Type_Group">  <cfset displayRow("Type Group", vars.column.name)>  </cfcase>
		  	<cfcase value="QBrand">  <cfset displayRow("Q Brand", vars.column.name)>  </cfcase>
		  	<cfcase value="Brand">  <cfset displayRow("Brand", vars.column.name)>  </cfcase>
		  	<cfcase value="RSP">  <cfset displayRow("RSP", vars.column.name)>  </cfcase>
		  	<cfcase value="RSP_Position">  <cfset displayRow("RSP Position", vars.column.name)>  </cfcase>
		  	<cfcase value="Currency_Conversion_Factor">  <cfset displayRow("Currency Conversion Factor", vars.column.name)>  </cfcase>
			<cfcase value="Currency_Code">  <cfset displayRow("Currency Code", vars.column.name)>  </cfcase>
			<cfcase value="Bid_Open_Date">  <cfset displayRow("Bid Open Date", vars.column.name)>  </cfcase>
			<cfcase value="Effective_Date_For_Price">  <cfset displayRow("Effective Date For Price", vars.column.name)>  </cfcase>
			<cfcase value="Legacy_ID">  <cfset displayRow("Legacy ID", vars.column.name)>  </cfcase>
			<cfcase value="Line_Number">  <cfset displayRow("Line_Number", vars.column.name)>  </cfcase>
			<cfcase value="Program_Percent_Rate">  <cfset displayRow("Program_Percent_Rate", vars.column.name)>  </cfcase>

  		</cfswitch> <!---expression="#vars.column.name#">--->
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
      					value="#vars.claimRateSetting[ arguments.internalName & '_Label' ][1]#"
      				>
			</td>
			<!---input with suffix _Include--->
      <td><input type="checkbox" name="#arguments.internalName#_Include" class="include"
      					<cfif vars.claimRateSetting[ arguments.internalName & "_Include" ][1] eq 1>
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
		vars.claimRateCFC = createObject("component", "components.programs.claimRates");
		vars.claimRateSettings = vars.claimRateCFC.saveClaimRateConfig( form );
	</cfscript>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<script type="text/javascript" src="/script/javascript/select2.min.js"></script>
<script>
  $(function() {
    $("#sortable tbody" ).sortable();
    $("select[name=templates]").multiselect({
   			 noneSelectedText: "Select program templates.."
   			,selectedText: "# program template(s) selected"
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
		$.ajax({ url: "/components/programs/claimRates.cfc"
		        ,type: "post"
		        ,timeout:60000
		        ,data: 	{ 	method: "duplicateExists"
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
    			$("form[name=editClaimRate]").submit();
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