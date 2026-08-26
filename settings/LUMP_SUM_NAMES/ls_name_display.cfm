<SCRIPT SRC="/settings/component_product_restrictions/component_product_restriction.js"></SCRIPT>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<TABLE width="60%" border="0" cellpadding="1" cellspacing="0" style="margin-top:10px;margin-bottom:5px;">
	<TR>
		<cfif qGetCompRebates.recordCount GT 0>
			<cfoutput>
				<td ALIGN="left" WIDTH="130" nowrap>
					<cfif form.display eq "inActive">
						<a HREF="##" onClick="javaScript: return activateSelComps();">#application.util.string.actionLinkFormat("activate selected")#</a>
					<cfelse>
						<a HREF="##" onClick="javaScript: return deactivateSelComps();">#application.util.string.actionLinkFormat("deactivate selected")#	</a>
					</cfif>
							<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a>
				</td>
			</cfoutput>
		</cfif>
	</TR>
</TABLE>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<table class="datagrid" id="datagrid">
	<thead>
		<tr>
		    <th><INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);"></th>
		<cfif application.returned_customer_setting.external_id_on EQ 1>
			<th>ID</th>
		</cfif>
		    <th><cfoutput>#Application.LumpsumLabel#</cfoutput> Component</th>
		    <th>Samples Related</th>
			<th>Exclude From TPA</th>
		<!--- Operating Group --->
		<cfif operatingGroupOn>
			<th><cfoutput>#operatingGroupManager.getLabel(operatingGroupLevel)#</cfoutput></th>
			<th>Allowance ID</th>
			<th>Allowance Code</th>
		</cfif>
		<cfif appSettings.getComponent_Product_Restrictions_On()>
			<th>Restricted Products</th>
		</cfif>
		<cfif form.display eq "active">
		    <th>Profile Restriction</th>
		</cfif>
		    <th>Allow Negative?</th>
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
				bCanDelete = compRebate.canDelete(qGetCompRebates.Program_Lump_Sum_Name_ID);
			</cfscript>
			<td width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Program_Lump_Sum_Name_ID#"></td>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
			<td>
				<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Lump_Sum_Name_ID#');">#External_ID#&nbsp;</a>
			</td>
		</cfif>
			<td>
				<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Lump_Sum_Name_ID#');">#Program_Lump_Sum_Name#&nbsp;</a>
			</td>
		<td>
			<cfif samples_related><a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Lump_Sum_Name_ID#');">Yes</a></cfif>
		</td>
		<td>
			<cfif Exclude_From_TPA><a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Lump_Sum_Name_ID#');">Yes</a></cfif>
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
		</cfif>
		<cfif appSettings.getComponent_Product_Restrictions_On()>
			<td  nowrap>
					<a href="##" onClick="JavaScript: return getRestrictedProducts('3', '#Program_Lump_Sum_Name_ID#'); return false;">(Edit)</a>
			</td>
		</cfif>
		<!--- --->
		<cfif form.display EQ "active">
			<td  nowrap>
				<a href="##" onClick="JavaScript: return submitDataForm('editProfileRestrict',  '#Program_Lump_Sum_Name_ID#'); return false;">(Edit)</a>
			</td>
		</cfif>
		<!--- --->
		<td  nowrap>
			<cfif Allow_Negative EQ 1>
				<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Lump_Sum_Name_ID#');">Yes</a>
			<cfelseif Allow_Negative EQ 0>
				<a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Lump_Sum_Name_ID#');">No</a>
			</cfif>
		</td>
		<cfif form.display EQ "active">
			<td TITLE="Deactivate #Program_Lump_Sum_Name#" ALIGN="left">&nbsp;&nbsp;<a href="" onClick="JavaScript: return deactivateComp('#Program_Lump_Sum_Name_ID#');"><img src="/images/not_allowed.gif" title="Deactivate #Program_Lump_Sum_Name#" BORDER="0"></a></td>
		<cfelse>
			<td TITLE="Activate #Program_Lump_Sum_Name#" ALIGN="left">&nbsp;&nbsp;<a href="" onClick="JavaScript: return activateComp('#Program_Lump_Sum_Name_ID#');"><img src="/images/on_the_program_item.gif" title="Activate #Program_Lump_Sum_Name#" BORDER="0"></a></td>
		</cfif>
		<cfif bCanDelete>
			<td TITLE="Delete #Program_Lump_Sum_Name#" ALIGN="left">&nbsp;&nbsp;<a href="" onClick="JavaScript: return deleteComp('#Program_Lump_Sum_Name_ID#');"><img src="/images/no_small.gif" title="Delete #Program_Lump_Sum_Name#" BORDER="0"></a></td>
		<cfelse>
			<td ALIGN="left">&nbsp;&nbsp;<FONT COLOR="Red">N/A</FONT></td>
		</cfif>
			<td title="Copy #Program_Lump_Sum_Name#"><a href="javascript:void();" onClick="JavaScript: copyComponent(#Program_Lump_Sum_Name_ID#,3);">(Copy)</a></td>
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
    ,"sScrollY": Math.floor($(window).height()) - 180
    ,"aaSorting": [[ 1, "asc" ]]
    ,"aoColumns": [
															{"bSearchable": false, 	"bSortable":false}
															<cfif application.returned_customer_setting.external_id_on EQ 1>
															, {"bSearchable": true, 	"bSortable":true}
															</cfif>
															, {"bSearchable": true, 	"bSortable":true}
															, {"bSearchable": false, 	"bSortable":true}
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
															</cfif>
															, {"bSearchable": false, 	"bSortable":true}
															, {"bSearchable": false, 	"bSortable":true}
															, {"bSearchable": false, 	"bSortable":false}
															, {"bSearchable": false, 	"bSortable":false}
					]
  }).fnSetFilteringDelay();

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>