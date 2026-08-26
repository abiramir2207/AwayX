<!--- contract_volume_forecast.cfm --->

<cfif isDefined("URL.Program_ID") and IsNumeric(URL.Program_ID) AND URL.Program_ID NEQ "0">

	<cfset ProgramVolume = CreateObject("component", "components.programs.volume.ProgramVolume") />
	<!-- this function will make sure groups member are capture if program has groups and contract_main.group_processed = 1  --->
	<cfset ProgramVolume.processGroups(programID = URL.Program_ID) />
	
	<cfstoredproc procedure="Get_Program_Product_Volume_Forecast" datasource="#application.datasource#">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@contract_main_id" null="no" value="#URL.Program_ID#">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@mode" null="no" value="EDIT">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@group_by" null="no" value="">
		      
		<cfprocresult name="getProductVolume" resultset="1">
		<cfprocresult name="getForecastId" resultset="2">
	</cfstoredproc>
	
	<cfset colList = getProductVolume.ColumnList />
	<cfset arVolume = ArrayNew(1) />
	<cfloop query="getProductVolume">
		<cfset stVol = StructNew() />
		<cfloop list="#colList#" index="thisColumn">
			<cfset stVol["#thisColumn#"] = getProductVolume["#thisColumn#"][currentRow] />
		</cfloop>
		<cfset arVolume[ArrayLen(arVolume) + 1] = stVol />
	</cfloop>
	
	<cfset volumeApplicator = CreateObject("component", "mvc.Models.Program.Volume.VolumeApplicator") />
	<cfset returnValue = volumeApplicator.updateVolumeDetails(
			ProgramId = URL.Program_ID, 
			updateVolumeData = arVolume,
			UserID = request.AccessStructure.User_ID,
			sReturnType = "struct") />
			
	<cfif not getProductVolume.recordCount>
		<!--- if no products, the result set getProductVolume and thus the array arVolume will be empty
		VolumeApplicator.cfc will not do any update as no data gets passed.
		We need to update the forecast_id
		--->
		<cfquery name="qryUpdateContractForecastId" datasource="#application.datasource#" >
			UPDATE Contract_Main_Aux_Data
			SET    Forecast_ID = <cfqueryparam value="#getForecastId.forecast_id#" cfsqltype="cf_sql_integer">
			WHERE  Contract_Main_ID = <cfqueryparam value="#URL.Program_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
	</cfif>
	
	<cf_cryp type="en" string ="#URL.Program_ID#" key="#request.key#">
	<CFSET CID = cryp.value>

	<!--- 
	if any error, show the message to user
	if no error, take them to view program page
	 --->
	<cfif returnValue.error>
		<center>
			
		<br><br>
		<span style="color:red; font-weight:bold;">
		<cfoutput>#returnValue.message#</cfoutput>
		</span>
		
		<br><br>
		
		<CF_smallLink 
			title = "return to program view" 
			url = "/Common_Files/Contracts/Contract_Edit_Menu.cfm?CID=#CID#"
			parameters = ""
		>
		
		</center>
		
		<cfabort>
	</cfif>
		
	<cflocation addtoken="false" url="/Common_Files/Contracts/Contract_Edit_Menu.cfm?CID=#CID#" />
		
</cfif>