
<cfparam name="idx" default="0"/>
<!---<script>
	function deleteHandler(id){
		frmTemplateFilter.sAction.value='Delete';
		frmTemplateFilter.TemplateFiltersId.value = id;
		frmTemplateFilter.tiName.value = '';
		frmTemplateFilter.tiDescription.value = '';
		frmTemplateFilter.submit();
		
	}
	function saveHandler(rdoFilter){
		frmTemplateFilter.sAction.value='Save';
		frmTemplateFilter.TemplateFiltersId.value = rdoFilter;
		frmTemplateFilter.submit();
		
	}
	function createHandler(){
		frmTemplateFilter.sAction.value='Save';
		frmTemplateFilter.submit();
	}
/*label D26730  by Dinesh  	function editHandler(n,d){
		frmTemplateFilter.tiName.value = n;
		frmTemplateFilter.tiDescription.value = d;
		frmTemplateFilter.submit();
	} label D26730  by Dinesh */   
	
	<!--- label D26730  by Dinesh Added to Solved nesting form issue --->
	function editHandler(n,d){
		DataForm.tiName.value = n;
		DataForm.tiDescription.value = d;
		DataForm.submit();
	}
	<!--- label D26730  by Dinesh Added to Solved nesting form issue --->
	function openSummaryWin(TemlateFiltersId){
		myRef = window.open('/Program_Wizard/filter/templateFilterSummary.cfm?TemlateFiltersId='+TemlateFiltersId+'&TemlateId='+<cfoutput>#ID#</cfoutput>,
			'TFwin',
			'left=20,top=40,width=1000,height=800,toolbar=0,resizable=1,scrollbars=1');
	}

</script>--->

<table width="100%" class="NoBorder" cellspacing="0" cellpadding="3">
    <tr class="NoBorder">
        <td class="NoBorder">
        	<!---dr <form name="frmTemplateFilter" action="Template_filters.cfm" method="post"> --->
        	<cfoutput>
					Name <input type="text" id="tiName" name="tiName" value="#form.tiName#"<cfif LockedBy_Current_User NEQ 1>disabled</cfif> />
					Description <!---<input type="text" id="tiDescription" name="tiDescription" value="#form.tiDescription#"  />--->
					<TEXTAREA NAME="tiDescription" id="tiDescription" COLS=40 ROWS=1 <cfif LockedBy_Current_User NEQ 1>disabled</cfif>>#form.tiDescription#</TEXTAREA>
					<cfif form.rdoFilter GT 0>
						<input type="button" value="Save Filter" onclick="saveHandler(#form.rdoFilter#);" <cfif LockedBy_Current_User NEQ 1>disabled</cfif>>
						<input type="hidden" id="TemplateFiltersId" name="TemplateFiltersId" value="#form.rdoFilter#"/>
					<cfelse>
						<input type="button" value="Create Filter" onclick="createHandler();"<cfif LockedBy_Current_User NEQ 1>disabled</cfif>>
						<input type="hidden" id="TemplateFiltersId" name="TemplateFiltersId" value="0"/>
					</cfif>
					<input type="hidden" id="ID" name="ID" value="#ID#"/>
					
					<input type="hidden" id="sAction" name="sAction" value=""/>
					<input type="hidden" id="bContinue" name="bContinue" value="0"/>
			</cfoutput>
        </td>
    </tr>
    <tr class="NoBorder">
        <td class="NoBorder">
	        <table width="75%" class="baTable"  cellspacing="0" cellpadding="3">
	        			<tr class="NoBorder">
					        <td class="rowHead">
								Edit&nbsp;
							</td>
							<td class="rowHead">
								Action&nbsp;
							</td>
							<td class="rowHead">
								Filter ID&nbsp;
							</td>
							<td class="rowHead">
					        	Name
					        </td>
							<td class="rowHead">
					        	Desc
					        </td>	
					        <td class="rowHead">
					        	Details
					        </td>
					    </tr>
		        <cfloop array="#template.TemplateFilters#" index="TemplateFilter">
					<cfset idx = idx + 1 />
					<cfif TemplateFilter.Template_Filters_Id EQ form.rdoFilter>
						<cfset editTemplateFilter = TemplateFilter />
					</cfif>
					<cfif TemplateFilter.Template_Filters_Id EQ form.rdoFilter OR form.rdoFilter EQ 0 >
						<cfoutput>
						    <tr <cfif (idx MOD 2) EQ 0>class="white"<cfelse>class="ltgreen"</cfif>>
						        <td class="baTd">
						        <cfif LockedBy_Current_User EQ 1>
									<input type="radio"
										onclick="editHandler('#TemplateFilter.Name#','#TemplateFilter.Desc#');"
										id="rdoFilter"
										name="rdoFilter" 
										<cfif TemplateFilter.Template_Filters_Id EQ form.rdoFilter>checked</cfif>
										value="#TemplateFilter.Template_Filters_Id#" />
									<cfelse>
										&nbsp;
									</cfif>
									
								</td>
								<td class="baTd">
								<cfif LockedBy_Current_User EQ 1>
									<cfif arraylen(TemplateFilter.arrMarketPrice) EQ 0>
										<!---<input type="button" value="Delete" 
											onclick="deleteHandler(#TemplateFilter.Template_Filters_Id#);">--->
										<CF_smallLink 
												title = "delete" 
												url = "##"
												parameters = "onClick=""deleteHandler('#TemplateFilter.Template_Filters_Id#'); return false;""">
									</cfif>
								</cfif>&nbsp;
						        </td>
								<td class="baTd">
						        	#TemplateFilter.Template_Filters_Id#
						        </td>
								<td class="baTd">
						        	#TemplateFilter.Name#&nbsp;
						        </td>
								<td class="baTd">
						        	#TemplateFilter.Desc#&nbsp;
						        </td>	
						        <td class="baTd">
						        	<!---<a href="##" OnClick="openSummaryWin('#TemplateFilter.Template_Filters_Id#'); return false;">Summary</a><br>--->
									<CF_smallLink 
												title = "view" 
												url = "##"
												parameters = "onClick=""openSummaryWin('#TemplateFilter.Template_Filters_Id#'); return false;""">
									<!---<a href="##" OnClick="openPrgWin(#TemplateFilter.Template_Filters_Id#);">Programs</a>--->
						        </td>
						    </tr>
						</cfoutput>
					</cfif>
				</cfloop>
			</table>	
        </td>
    </tr>
</table>
<!--- </form> dr--->