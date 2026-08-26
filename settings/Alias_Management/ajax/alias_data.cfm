<cfsetting showDebugOutput="no">
<cfsilent>
<cfset ObjAliasManager  = CreateObject("component","mvc.Models.Admin.Alias.AliasManager") />
<!--- distributor --->
<cfif url.entityType eq 0>
	<cfset qGetAliasData = ObjAliasManager.getDistributorAliasesQuery(
						sourceType=form.sourceType,sourceID=form.sourceID,startRow=form.startRow,endRow=form.endRow,filterModel=form.filterModel,sortColumn=form.sortColumn,sortOrder=form.sortOrder
						)>
<!--- item --->
<cfelseif url.entityType eq 1> 
	<cfset qGetAliasData = ObjAliasManager.getItemAliasesQuery(
						sourceType=form.sourceType,sourceID=form.sourceID,startRow=form.startRow,endRow=form.endRow,filterModel=form.filterModel,sortColumn=form.sortColumn,sortOrder=form.sortOrder
						)>
<!--- program --->
<cfelseif url.entityType eq 2> 
	<cfset qGetAliasData = ObjAliasManager.getProgramAliasesQuery(
						sourceType=form.sourceType,sourceID=form.sourceID,startRow=form.startRow,endRow=form.endRow,filterModel=form.filterModel,sortColumn=form.sortColumn,sortOrder=form.sortOrder
						)>
<!--- operator --->
<cfelseif url.entityType eq 3> 
	<cfset qGetAliasData = ObjAliasManager.getOperatorAliasesQuery(
						sourceType=form.sourceType,sourceID=form.sourceID,startRow=form.startRow,endRow=form.endRow,filterModel=form.filterModel,sortColumn=form.sortColumn,sortOrder=form.sortOrder
						)>
</cfif>
<cfinclude template="../alias_columns.cfm">
</cfsilent>
<cfoutput>#application.util.query.toDtJSON(qGetAliasData, arrayToList( alias_columns_arr ))#</cfoutput>