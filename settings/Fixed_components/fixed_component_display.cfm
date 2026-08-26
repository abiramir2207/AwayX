	<cfif qgetcompfixed.recordcount gt 0>
		<cfoutput>
			<table width="100%" border="0" style="margin-top:10px;margin-bottom:5px;">
				<tr>
					<td align="left" width="130" nowrap>
						<cfif form.display eq "inactive">
							<a HREF="##" onClick="javaScript: return activateSelComps();">#application.util.string.actionLinkFormat("activate selected")#</a>
						<cfelse>
							<a HREF="##" onClick="javaScript: return deactivateSelComps();">#application.util.string.actionLinkFormat("deactivate selected")#</a>
						</cfif>
							<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a>
					</td>
				</tr>
			</table>
		</cfoutput>
	</cfif>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<table class="datagrid" id="datagrid">
	<thead>
		<tr>
		    <th><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this);"></th>
		<cfif application.returned_customer_setting.external_id_on>
			<th>ID</th>
		</cfif>
		    <th>Component Name</th>
		<cfif operatingGroupOn>
			<th>#operatingGroupManager.getLabel(operatingGroupLevel)#</th>
			<th>Allowance ID</th>
			<th>Allowance Code</th>
		</cfif>
		<cfif appSettings.getComponent_Product_Restrictions_On()>
			<th>Restricted Products</th>
		</cfif>
		<cfif form.display eq "active">
		    <th>Profile Restriction</th>
			<th>Business Rules</th>
		</cfif>
			<th>
				<cfif form.display eq "active">
						DeActivate
				<cfelse>
						Activate
				</cfif>
			</th>
			<th>Delete</th>
			<th>Copy</th>
		</tr>
	</thead>

	<tbody>
	<cfoutput query="qGetCompFixed">
		<!---check to see if we can delete this component--->
		<cfscript>
			bCanDelete = compFixed.canDelete(qGetCompFixed.Program_Fixed_Component_Name_ID);
		</cfscript>
		<tr>
		  	<td><input type="checkbox" name="CID" value="#Program_Fixed_Component_Name_ID#"></td>
		<cfif application.returned_customer_setting.external_id_on>
		  	<td><a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Fixed_Component_Name_ID#');">#External_ID#</a></td>
		</cfif>
			<td><a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Fixed_Component_Name_ID#');">#Program_Fixed_Component_Name#</a></td>
		<cfif operatingGroupOn>
			<td><cfif Val(Operating_Group_ID) NEQ 0>#operatingGroupManager.getOperatingGroupDesc(Operating_Group_ID)#</cfif></td>
			<td><cfif Val(Allowance_Code_ID) NEQ 0>#allowanceCodeManager.getAllowanceCodes(Allowance_Code_ID).Allowance_Code_Number#</cfif></td>
			<td><cfif Val(Allowance_Code_ID) NEQ 0>#allowanceCodeManager.getAllowanceCodeDesc(Allowance_Code_ID)#</cfif></td>
		</cfif>
		<cfif appSettings.getComponent_Product_Restrictions_On()>
		  	<td><a href="##" onClick="getRestrictedProducts('1', '#Program_fixed_Component_Name_ID#'); return false;">(Edit)</a>	</td>
		</cfif>
		<cfif form.display EQ "active">
			<td  nowrap>
				<a href="##" onClick="JavaScript: return submitDataForm('editProfileRestrict',  '#Program_fixed_Component_Name_ID#'); return false;">(Edit)</a>
			</td>
			<td>
				<a href="" onClick="JavaScript: return submitDataForm('applyBusRule', '#Program_fixed_Component_Name_ID#');">
					<cfif compfixed.hasRules(qGetCompfixed.Program_fixed_Component_Name_ID)>
						(Edit)
					<cfelse>
						(Add)
					</cfif>
				</a>
			</td>
		</cfif>		
		<cfif form.display EQ "active">
			<td title="Deactivate #Program_Fixed_Component_Name#"><a href="" onClick="JavaScript: return deactivateComp('#Program_fixed_Component_Name_ID#');"><img src="/images/not_allowed.gif" title="Deactivate #Program_Fixed_Component_Name#" border="0"></a></td>
		<cfelse>
			<td title="Activate #Program_Fixed_Component_Name#"><a href="" onClick="JavaScript: return activateComp('#Program_fixed_Component_Name_ID#');"><img src="/images/on_the_program_item.gif" title="Activate #Program_Fixed_Component_Name#" border="0"></a></td>
		</cfif>
		<cfif bCanDelete>
			<td title="Delete #Program_Fixed_Component_Name#"><a href="" onClick="JavaScript: return deleteComp('#Program_fixed_Component_Name_ID#');"><img src="/images/no_small.gif" title="Delete #Program_Fixed_Component_Name#" border="0"></a></td>
		<cfelse>
			<td><font color="Red">N/A</font></td>
		</cfif>	
			<td title="Copy #Program_Fixed_Component_Name#"><a href="javascript:void();" onClick="JavaScript: copyComponent(#Program_fixed_Component_Name_ID#,1);">(Copy)</a></td>
		</tr>
	</cfoutput>
	</tbody>
</table>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script>
var grid = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"aaSorting": [[ 1, "asc" ]] 
    ,"aoColumns": [   
					  {"sWidth": "1%","bSearchable": false, 	"bSortable":false}
                <cfif application.returned_customer_setting.external_id_on>
				    , {"bSearchable": true, 	"bSortable":true}
               </cfif>
			   		, {"bSearchable": false, 	"bSortable":true} 
			//Operating Group START
				<cfif operatingGroupOn>
					, {"bSearchable": false, 	"bSortable":true} 
					, {"bSearchable": false, 	"bSortable":true} 
					, {"bSearchable": false, 	"bSortable":true} 
				</cfif>
			//Operating Group END					
				<cfif appSettings.getComponent_Product_Restrictions_On()>
				 	, {"bSearchable": false, 	"bSortable":true}
				</cfif>
				<cfif form.display EQ "active">
				, {"bSearchable": false, 	"bSortable":false}
				, {"bSearchable": false, 	"bSortable":false}
				</cfif> 
				, {"bSearchable": false, 	"bSortable":false}
				, {"bSearchable": false, 	"bSortable":false}
				, {"bSearchable": false, 	"bSortable":false}
					]
  }).fnSetFilteringDelay();

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>