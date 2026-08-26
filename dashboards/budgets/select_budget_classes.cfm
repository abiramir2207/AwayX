
<!--- ----------------------------------------------------------------------------------------- --->
<!--- get all the budget classes that could be retrieved -------------------------------------  --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif isdefined('form.remember_budget_classes')>
	<cfquery name="Update_budget_classes" datasource="#Application.Datasource#">
		DELETE FROM Budget_Class_Selection
		WHERE User_Id = '#request.AccessStructure.user_id#'
	</cfquery>
	<cfif isdefined('form.budget_class_value') >
		<cfloop list="#form.budget_class_value#" index="i" >
			<cfquery name="Update_budget_classes" datasource="#Application.Datasource#">
				INSERT Budget_Class_Selection
				(
					User_Id,
					Budget_Class_ID
				)
				VALUES
				(
					'#request.AccessStructure.user_id#',
					#i#
				)
			</cfquery>
		</cfloop>
	</cfif>
</cfif>

<cfquery name="Get_budget_Class_Selection" datasource="#Application.Datasource#">
	SELECT  BCS.Budget_Class_ID,
			 BC.Budget_Class_Desc
	FROM Budget_Class_Selection BCS
	INNER JOIN Budget_Class BC ON 
		BC.Budget_Class_ID = BCS.Budget_Class_ID
	WHERE User_Id = '#request.AccessStructure.user_id#'
</cfquery>


<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
	SELECT	DISTINCT 
			Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc
			,Budget_Class.is_fiscal
			,Budget_Class.start_date
			,Budget_Class.end_date
			,Budget_Class.Budget_Class_ID
			,BCS.Budget_Class_ID as Selected_ID
	FROM	dbo.dashboards_budget_weekly_summary
			LEFT JOIN Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
			LEFT JOIN Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
			LEFT JOIN Budget_Class_Selection BCS ON
				BCS.Budget_Class_ID = Budget.Budget_Class_ID AND
				BCS.User_Id = '#request.AccessStructure.user_id#'
	WHERE	dash_budget_type = 3
	ORDER BY Budget_Class.start_date
</cfquery>


<style>
	
	table.selections
	{
		margin:				0px auto 10px auto; 
		width:				600px;
		border-collapse: 	collapse;
	}

	td.selections
	{
		color:				#FFFFFF;
		padding:			8px 10px 8px 10px;
		border-bottom:		1px #33CC33 dotted;
	}
	
	td.notes
	{
		color:				#FFFF00;
		font-size:			13px;
		padding:			8px 10px 8px 10px;
	}
	
	td.table_header
	{
		color:				#FFFFFF;
		font-size:			12px;
		padding:			8px 10px 8px 10px;

		background: #00d800; /* Old browsers */
		/* IE9 SVG, needs conditional override of 'filter' to 'none' */
		background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzAwZDgwMCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMwMDI0MDAiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
		background: -moz-linear-gradient(top, #00d800 0%, #002400 100%); /* FF3.6+ */
		background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#00d800), color-stop(100%,#002400)); /* Chrome,Safari4+ */
		background: -webkit-linear-gradient(top, #00d800 0%,#002400 100%); /* Chrome10+,Safari5.1+ */
		background: -o-linear-gradient(top, #00d800 0%,#002400 100%); /* Opera 11.10+ */
		background: -ms-linear-gradient(top, #00d800 0%,#002400 100%); /* IE10+ */
		background: linear-gradient(to bottom, #00d800 0%,#002400 100%); /* W3C */
		filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#00d800', endColorstr='#002400',GradientType=0 ); /* IE6-8 */
	}

	td.select_all
	{
		color:				#00FF00; 
		font-weight:		bold; 
		font-size:			14px; 
		padding:			5px 5px 5px 5px;
		border-bottom:		3px #FFFFFF solid; 
	}


</style>

<!--- IF USER HAS MADE A SELECTION, USE IT ELSE LIST ALL --->
<cfif Get_budget_Class_Selection.RecordCount GT 0 >
	<cfparam name="form.budget_class_value" default="#ValueList(Get_budget_Class_Selection.Budget_Class_ID,",")#" type="any">
	<cfcookie name="budget_classes" value="#ValueList(Get_budget_Class_Selection.Budget_Class_Desc,",")#">
<cfelse>
	<cfparam name="form.budget_class_value" default="#ValueList(Get_budget_classes.Budget_Class_ID,",")#" type="any">
	<cfcookie name="budget_classes" value="#ValueList(Get_budget_classes.Budget_Class_Desc,",")#">
</cfif>


<!--- <cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_ID,",") /> --->
<cfset budget_classes_list = form.budget_class_value />

<div style="text-align:left; font-size:10px; margin:10px 10px -10px 10px;">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- used to select or unselect all checkboxes --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<script>
function checkAll(bx) {
  var cbs = document.getElementsByTagName('input');
  for(var i=0; i < cbs.length; i++) {
    if(cbs[i].type == 'checkbox') {
      cbs[i].checked = bx.checked;
    }
  }
}
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




    <form action="display.cfm?content=78887-94749-95959-90409" method="post">
    	
    	<BR /><BR />
    	
    <table class="selections">
		
		<tr>
			<td class="notes" colspan="100%">Select the classes to be used by the Budget dashboards.<BR />Please note that only selected classes will be used by the budget dashboards</td>
		</tr>


		<tr>
			<td class="select_all notes" colspan="100%">
								
				
				<cfif Find('78887-94749-95959-90409', HTTP_REFERER) GTE 1>
					BUDGET CLASSES SAVED
				<cfelse>
					<BR />
				</cfif>
				
				
			</td>
		</tr>


		<tr>
			<td class="selections select_all">Select / Unselect all budget classes</td>
	        <td class="selections select_all">&nbsp;</td>
    	    <td class="selections select_all">&nbsp;</td>
    	    <td class="selections select_all">&nbsp;</td>
			<td class="selections select_all" style="text-align:center;"><input type="checkbox" onclick="checkAll(this)"></td>
		</tr>

		<tr>
			<td colspan="100%">&nbsp;</td>
		</tr>
		

		<tr>
			<td class="table_header">Budget Class</td>
			<td class="table_header">Class Type</td>
			<td class="table_header">Start Date</td>
			<td class="table_header">End Date</td>
			<td class="table_header">Selected</td>
		</tr>


        <cfoutput query="Get_budget_classes">
	
	    <tr>

        <td class="selections" style="text-transform:uppercase;">#Budget_Class_Desc#</td>
        <td class="selections"><cfif is_fiscal EQ 1>Fiscal<cfelse>Calendar</cfif></td>
        <td class="selections">#dateformat(start_date, 'mm/dd/yyyy')#</td>
        <td class="selections">#dateformat(end_date, 'mm/dd/yyyy')#</td>
        <td class="selections" style="text-align:center;">
			<input name="budget_class_value" type="checkbox" value="#Get_budget_classes.Budget_Class_ID#" style="width:20px; margin: 2px 0px 0px 0px;" <cfif Get_budget_classes.Budget_Class_Id EQ Get_budget_classes.Selected_ID>checked</cfif> />
		</td>

	    </tr>
        </cfoutput>


		<tr>
        <td colspan="100%" style="text-align:center;">
        	
        	<BR />        	
        	<input name="remember_budget_classes" type="submit" value="Remember Selected Budget Classes" style="margin:3px 0px 0px 0px;" />
        	<BR /><BR />
        	
       	</td>
		</tr>
    </table>
    </form>

      <!--- create the cookie with the budget classes values  --->
  <!---  <cfcookie name="budget_classes" value="#form.budget_class_value#"> --->

</div>