<!--- Sum up the data --->
<cfset ProdVolume = StructNew()>
<cfoutput>
	<cfset ArrayIndex = replace(getGeoBasedReport.BSA_Foodservice_Items_Master_ID, "-", "_", "ALL")>
	<cfset ArrayIndex ="A_" & ArrayIndex>

	<cfif NOT isdefined("ProdVolumeStruct.#ArrayIndex#")>
		<cfset "ProdVolumeStruct.#ArrayIndex#" 				= StructNew()>
		<cfset "ProdVolumeStruct.#ArrayIndex#.Volume" 		= 0>
		<cfset "ProdVolumeStruct.#ArrayIndex#.Program_List" = "">
	</cfif>	
	
	<cfset temp_CurrentVolume 						= evaluate("ProdVolumeStruct.#ArrayIndex#.Volume")>
	<cfset temp_WeeklyVolume 						= getGeoBasedReport.Volume_CS>
	<cfset temp_ProgramDurationDays 				= getGeoBasedReport.PROGRAMDATESPANINDAYS>
	<cfset tempFinalVolume 							= (temp_WeeklyVolume*temp_ProgramDurationDays)/7>
	<cfset "ProdVolumeStruct.#ArrayIndex#.Volume" 	= temp_CurrentVolume + tempFinalVolume>
	
	<cfif listfind(evaluate("ProdVolumeStruct.#ArrayIndex#.Program_List"), getGeoBasedReport.program_id) EQ 0>
		<cfset "ProdVolumeStruct.#ArrayIndex#.Program_List" = listappend(evaluate("ProdVolumeStruct.#ArrayIndex#.Program_List"), getGeoBasedReport.program_id)>
	</cfif>
</cfoutput>		