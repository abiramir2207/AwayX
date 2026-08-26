<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<table width="60%" border="0" cellpadding="1" cellspacing="0" style="margin-top:10px;margin-bottom:5px;">
	<tr>
	<cfoutput>
			<cfif qgetcomprebates.recordcount gt 0>
				<td align="left" width="130" nowrap>
					<cfif form.display eq "inactive">
						<a HREF="##" onClick="javaScript: return activateSelComps();">#application.util.string.actionLinkFormat2("activate selected")#</a>
					<cfelse>
						<a HREF="##" onClick="javaScript: return deactivateSelComps();">#application.util.string.actionLinkFormat2("deactivate selected")#</a>
					</cfif>
					<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a>
				</td>
			</cfif>
	</cfoutput>
	</tr>
</table>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<table class="datagrid" id="datagrid">
	<thead>
		<tr>
		    <th><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'CID');"></th>
		<cfif application.returned_customer_setting.external_id_on EQ 1>
			<th>ID</th>
		</cfif>
		    <th>Component Name</th>
		<!--- Operating Group --->
		<cfif operatingGroupOn>
			<th><cfoutput>#operatingGroupManager.getLabel(operatingGroupLevel)#</cfoutput></th>
			<th>Allowance ID</th>
			<th>Allowance Code</th>
			<th>Eff. Rate % Required</th>
		</cfif>
		<cfif appSettings.getComponent_Product_Restrictions_On()>
			<th>Restricted Products</th>
		</cfif>
		<cfif form.display eq "active">
		    <th>Profile Restriction</th>
			<th style="display:none;">Business Rules</th>
		</cfif>
		<cfif form.display eq "active">
			<th>DeActivate</th>
		<cfelse>
			<th>Activate</th>
		</cfif>
			<th>Delete</th>
			<th>Copy</th>
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qGetCompRebates">
		<tr>
			<!---check to see if we can delete this component--->
			<cfscript>
				bCanDelete = compRebate.canDelete(qGetCompRebates.Program_Rebates_Component_Name_ID);
			</cfscript>
			<td width="10"><input type="checkbox" name="CID" value="#Program_Rebates_Component_Name_ID#"></td>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
			<td>
				<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Rebates_Component_Name_ID#');">#External_ID#&nbsp;</a>
			</td>
		</cfif>
			<td>
				<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Rebates_Component_Name_ID#');">#Program_Rebates_Component_Name#&nbsp;</a>
			</td>
		<!--- Operating Group --->
		<cfif operatingGroupOn>
			<td>
				<cfif Val(Operating_Group_ID) NEQ 0>#operatingGroupManager.getOperatingGroupDesc(Operating_Group_ID)#</cfif>&nbsp;
			</td>
			<td>
				<cfif Val(Allowance_Code_ID) NEQ 0>#allowanceCodeManager.getAllowanceCodes(Allowance_Code_ID).Allowance_Code_Number#</cfif>&nbsp;
			</td>
			<td>
				<cfif Val(Allowance_Code_ID) NEQ 0>#allowanceCodeManager.getAllowanceCodeDesc(Allowance_Code_ID)#</cfif>&nbsp;
			</td>
			<td>
				<cfif Val(Required_Effective_Rate_Percent) NEQ 0>Yes<cfelse>No</cfif>&nbsp;
			</td>
		</cfif>
		<cfif appSettings.getComponent_Product_Restrictions_On()>
			<td  nowrap>
					<a href="##" onClick="getRestrictedProducts('2', '#Program_Rebates_Component_Name_ID#'); return false;">(Edit)</a>
			</td>
		</cfif>
		<cfif form.display EQ "active">
			<td  nowrap>
				<a href="" onClick="JavaScript: return submitDataForm('editProfileRestrict', '#Program_Rebates_Component_Name_ID#');">(Edit)</a>
			</td>
			<td style="display:none;">
				<a href="" onClick="JavaScript: return submitDataForm('applyBusRule', '#Program_Rebates_Component_Name_ID#');">
					<cfif compRebate.hasRules(qGetCompRebates.Program_Rebates_Component_Name_ID)>
						(Edit)
					<cfelse>
						(Add)
					</cfif>
				</a>
			</td>
		</cfif>		
		<cfif form.display EQ "active">
			<td title="Deactivate #Program_Rebates_Component_Name#"><a href="" onClick="JavaScript: return deactivateComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #Program_Rebates_Component_Name#" BORDER="0"></a></TD>
		<cfelse>
			<td title="Activate #Program_Rebates_Component_Name#"><a href="" onClick="JavaScript: return activateComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #Program_Rebates_Component_Name#" BORDER="0"></a></TD>
		</cfif>
		<cfif bcandelete>
			<td title="Delete #Program_Rebates_Component_Name#"><a href="" onClick="JavaScript: return deleteComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/no_small.gif" TITLE="Delete #Program_Rebates_Component_Name#" BORDER="0"></a></TD>
		<cfelse>
			<td>&nbsp;<font color="Red">N/A</font></TD>
		</cfif>
			<td title="Copy #Program_Rebates_Component_Name#"><a href="javascript:void();" onClick="JavaScript: copyComponent(#Program_Rebates_Component_Name_ID#,2);">(Copy)</a></td>
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
					  {"bSearchable": false, 	"bSortable":false}
               <cfif application.returned_customer_setting.external_id_on EQ 1>
			        , {"bSearchable": true, 	"bSortable":true}
                </cfif>
				    , {"bSearchable": true, 	"bSortable":true}
			//Operating Group START
				<cfif operatingGroupOn>
					, {"bSearchable": false, 	"bSortable":true} 
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
