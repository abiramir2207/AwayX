<!--
  * ==================================================================================================== 
  *  @Author: Chris Nguyen
  *    @Date: 2018-06-25 09:24:55
  * 
  * @Parameters:   
  *		- url.program_id: required, numeric
  *		- url.product_group_level_id: required, numeric
  * 	- url.product_group_level_list: required, string, comma-delimited list
  *  
  * ==================================================================================================== 
-->
<!doctype html>
<html lang="en">
<head>
	<style>
		input[type=checkbox] {
			position: relative;
			top: 2px;
		}
	</style>
</head>
<body>
<cfsilent>
	<cfquery name="qGroups" datasource="#application.datasource#">
	SELECT DISTINCT gt.Group_GUID, gt.Group_Number, gt.Group_Desc
	  FROM Contract_Products cp
			INNER JOIN All_Product_Group_Type_Members gm ON gm.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
															AND gm.Product_Group_Level_ID = #url.product_group_level_id#
			INNER JOIN All_Product_Group_Types gt ON gt.Group_GUID = gm.Product_Group_ID
														AND gt.Product_Group_Level_ID = gm.Product_Group_Level_ID
	  WHERE cp.Contract_Main_ID = #url.program_id#
	  AND   cp.Deleted          = 0
	  AND   cp.Is_Group         = 0
</cfquery>
</cfsilent>
<cfset jQueryUI.widgets = "full">
<cfinclude template="/common_Files/jQuery.cfm">
<cf_include files="/common_files/main_style.css, /script/javascript/default.js, /common_files/datatable2.css, /common_Files/dataTables2.cfm">

<table class="row-border hover dataTable material">
    <thead>
        <tr>
            <cfoutput><th>#url.text#</th></cfoutput>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>

<div style="margin:5px">
    <a href="javaScript:apply_selection();"><cfoutput>#application.util.string.linkFormat("apply selection")#</cfoutput></a>
    <a href="javaScript:parent.dhx_window_close();"><cfoutput>#application.util.string.linkFormat("cancel")#</cfoutput></a>
</div>

<script>
	/* replace white spaces and convert the current list into a JS array */
    <cfoutput>const product_groups_level_array = "#url.product_group_level_list#".replace(/\s/g, "X").split(",");</cfoutput>
    $("table.dataTable").DataTable({
                                     "columns": [ 
													{ "orderable": false
														,"render": function(data, type, row, meta) { return "<label><input type='checkbox' id='" 
																													+ row[1] 
																													+ "'"
																													+ ($.inArray(row[1], product_groups_level_array) == -1 ? "" : " checked")
																													+ ">"
																													+ data 
																													+ "</label>"; } 
													} 
                                                    , {"visible": false}
                                                ]
                                     , "data" : <cfoutput>#application.util.query.toDtJSON(qGroups, "group_desc, group_guid")#</cfoutput>
                                     , "dom" : 't'
                                     , "order" : []
                                     , "paging" : false
                                     , "scrollY": "75vh"
                                });

	function apply_selection() {
		/* validate/save selection */
		let selection = [];
		$("input[type=checkbox]:checked").each(function(){
			selection.push( $(this).attr("id"));
		});
		if (selection.length == 0) {
			alert("Please select at least one check box.");
			return false;
		}
		/* save selection in parent hidden element */
		$("input[name=product_group_level_list]", parent.document).val( selection.join() );
		/* reload parent page */
		parent.refresh();
		/* close this window */
		parent.dhx_window_close();
	}
</script>
</body>
</html>
