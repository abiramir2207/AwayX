<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Settings/OCR_Settings_display.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Displays the OCR Setting
---------------------------------------------------------------------------------->
<!--- <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.13/css/jquery.dataTables.min.css"> --->
	<script type="text/javascript" language="javascript" src="//code.jquery.com/jquery-1.12.4.js"></script>
	<script type="text/javascript" language="javascript" src="https://cdn.datatables.net/1.10.13/js/jquery.dataTables.min.js"></script>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<table width="60%" border="0" cellpadding="1" cellspacing="0" style="margin-top:10px;margin-bottom:5px;">
	<tr>
	<cfoutput>
			<cfif isdefined("qGetOCRSettings.recordcount") AND qGetOCRSettings.recordcount gt 0>
				<td align="left" width="130" nowrap>
					<cfif form.display eq "inactive">
						<a HREF="##" onClick="javaScript: return activateSelSetting();">#application.util.string.actionLinkFormat("activate selected")#</a>
					<cfelse>
						<a HREF="##" onClick="javaScript: return deactivateSelSetting();">#application.util.string.actionLinkFormat("deactivate selected")#</a>
					</cfif>
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
			<th>ID</th>
 		    <th>Template Name</th>
			<th>File Preprocess Path</th>	<!--- The location where the file will be placed when this template is picked ---> 
			<th>File Postprocess Path</th>
			<th>Text File Postprocess Path</th>
			<th>Search String</th>
			<th>Source Code</th>
			<th>Is OCR Required</th>
			<th>File Ext.</th>
			<th>Search Order</th>
			<th>Rank Order</th>
			<th>OCR Reader</th>
			
			<!--- 	<th>DB File Preprocess Path</th>
			<th>DB File Postprocess Path</th> --->
 			<!--- <cfif form.display eq "active">
				<th>DeActivate</th>
			<cfelse>
				<th>Activate</th>
			</cfif>
			<th>Delete</th> --->
		</tr>
	</thead>
	<tbody>
	<cfoutput query="qGetOCRSettings">
		<tr>
			<!---check to see if we can delete this component--->
			<!--- <cfscript>
				bCanDelete = OCRSettingsManager.canDelete(qGetOCRSettings.Program_Rebates_Component_Name_ID);
			</cfscript> --->
			<td width="10">
				<input type="checkbox" name="CID" value="#qGetOCRSettings.OCR_Template_Settings_ID#"></td>
			<td>
				<!--- <a href="" onClick="JavaScript: return submitDataForm('edit','#Program_Rebates_Component_Name_ID#');"> --->#qGetOCRSettings.OCR_Template_Settings_ID#&nbsp;<!--- </a> --->
			</td>
			<td>
				<a href="" onClick="JavaScript: return submitDataForm('edit', '#qGetOCRSettings.OCR_Template_Settings_ID#');">#qGetOCRSettings.OCR_Template_Name#</a>
			</td>
			<td>
				#qGetOCRSettings.OCR_File_PreProcess_Path#
			</td>
			<td>
				#qGetOCRSettings.OCR_File_PostProcess_Path#
			</td>
			<td>
				#qGetOCRSettings.OCR_File_PostProcess_Txt_Path#
			</td>
			<td>
				#qGetOCRSettings.Search_String#
			</td>
 			<td>
				#qGetOCRSettings.Source_Code#
			</td>
			<td>
				#qGetOCRSettings.IS_OCR_Required#
			</td>
 			<td>
				#qGetOCRSettings.Allowable_File_Ext#
			</td>
 			<td>
				#qGetOCRSettings.Search_Order#
			</td>	
			<td>
				#qGetOCRSettings.Rank_Order#
			</td>	
			<td>
				#qGetOCRSettings.OCR_Reader_Name#
			</td>	 
		<!--- <cfif form.display EQ "active">
			<td  nowrap>
				<a href="" onClick="JavaScript: return submitDataForm('editProfileRestrict', '#Program_Rebates_Component_Name_ID#');">(Edit)</a>
			</td>
			<td style="display:none;">
				<a href="" onClick="JavaScript: return submitDataForm('applyBusRule', '#Program_Rebates_Component_Name_ID#');">
					<cfif compRebate.hasRules(qGetOCRSettings.Program_Rebates_Component_Name_ID)>
						(Edit)
					<cfelse>
						(Add)
					</cfif>
				</a>
			</td>
		</cfif> --->		
		<!--- <cfif form.display EQ "active">
			<td title="Deactivate #Program_Rebates_Component_Name#"><a href="" onClick="JavaScript: return deactivateComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #Program_Rebates_Component_Name#" BORDER="0"></a></TD>
		<cfelse>
			<td title="Activate #Program_Rebates_Component_Name#"><a href="" onClick="JavaScript: return activateComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #Program_Rebates_Component_Name#" BORDER="0"></a></TD>
		</cfif>
		<cfif bcandelete>
			<td title="Delete #Program_Rebates_Component_Name#"><a href="" onClick="JavaScript: return deleteComp('#Program_Rebates_Component_Name_ID#');"><img src="/images/no_small.gif" TITLE="Delete #Program_Rebates_Component_Name#" BORDER="0"></a></TD>
		<cfelse>
			<td>&nbsp;<font color="Red">N/A</font></TD>
		</cfif> --->
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
				        , {"bSearchable": true, 	"bSortable":true}
					    , {"bSearchable": true, 	"bSortable":true}
	 				 	, {"bSearchable": true, 	"bSortable":true}
			        	, {"bSearchable": true, 	"bSortable":true}
						, {"bSearchable": true, 	"bSortable":true}
						, {"bSearchable": true, 	"bSortable":true}
						, {"bSearchable": false, 	"bSortable":true}
						, {"bSearchable": true, 	"bSortable":true}
						, {"bSearchable": false, 	"bSortable":true}	
						, {"bSearchable": true, 	"bSortable":true}					
						] 
	  }).fnSetFilteringDelay();
<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>
