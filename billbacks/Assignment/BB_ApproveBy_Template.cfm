<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager") />

<cfset qGetTemplates = templateManager.getTemplatesByGenericType(coMainId=request.AccessStructure.Company_Main_ID, filterbyUBS=0) />
<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />

<cfif form.subcommand EQ "save">

		<cfquery name="DeleteData" datasource="#application.datasource#">
				DELETE  FROM BB_ApproveBy_Template
		</cfquery>

	<cfloop from="1" to="#listlen(Form.FieldNames)#" index="A">

		<cfset fields = listToArray(listgetat(Form.FieldNames, A), "_", false, true)>

			<cfif arraylen(fields) EQ 2>

				<cfquery name="InsertNewData" datasource="#application.datasource#">
					INSERT INTO BB_ApproveBy_Template (User_ID,First_Parent_ID,updated_by)
					VALUES ('#fields[1]#', #fields[2]#,'#request.accessStructure.User_Id#')

					INSERT INTO BB_ApproveBy_Template_History (User_ID,First_Parent_ID,updated_by, Deleted_By)
					VALUES ('#fields[1]#', #fields[2]#,'#request.accessStructure.User_Id#','#request.accessStructure.User_Id#')

				</cfquery>

			</cfif>

	</cfloop>

</cfif>

<br>

<cfoutput>
<table class="datagrid" id="datagrid">
<thead>
<tr>
	<th align="left" width="150px">Analyst</th>
	<cfloop query="qGetTemplates">
		<th align="center" width="150px" nowrap>#created_type#</th>
	</cfloop>
</tr>
</thead>
<tbody>
<cfloop query="qGetAnalysts">
	<cfset selectedTemplates = ''>
		<cfquery name="checkData" datasource="#application.datasource#">
		SELECT first_parent_id 
		FROM BB_ApproveBy_Template
		WHERE User_ID = '#Analyst_User_ID#'
		</cfquery>
		<cfset selectedTemplates = valueList(checkData.first_parent_id)>
<tr>
	<td style="background-color: ##F8F8F8;">#name_first# #name_last#</td>
	<cfloop query="qGetTemplates">
		<cfset fieldname = #qGetAnalysts.Analyst_User_ID#&'_'&#first_parent_id#>
		<td align="center"><input type="checkbox" name="#fieldname#" value="1" <cfif listfind(selectedTemplates, first_parent_id)> checked </cfif> ></td>
	</cfloop>
</tr>
</cfloop>
</tbody>
</table>
<br>
  <a id="saveLink" >#application.util.string.actionLinkFormat2("save")#</a>
</cfoutput>

<script type="text/javascript" src="/Script/javascript/dataTables.fixedColumns.min.js"></script>
<script>

var oTable = $('table#datagrid').DataTable({
    "bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"bFilter": false
    ,"aoColumns": [   
    									{"bSortable":true, "bSearchable":true }
    									<cfloop from="1" to="#qGetTemplates.recordcount#" index='Templates'>
                    , {"bSortable":false,  "bSearchable":false}
                    	</cfloop>
                    ]
		,"scrollY": Math.floor(jQuery(window).height()) - 150
		,"scrollX": true
		,"scrollCollapse": true
  })

$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

new $.fn.dataTable.FixedColumns( oTable , {
            leftColumns: 1 //specifies how many left columns should be fixed.
        });

$('#saveLink').click(function(){
   submitForm('BBAssignment', 'save');
});

</script>