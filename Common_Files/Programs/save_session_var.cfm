<cfset useLakebaseForGetExistingWDDXPacketLocations = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_variable_storage")>
<cfif useLakebaseForGetExistingWDDXPacketLocations>
	<cftry>
		<cfset getExistingWDDXPacketLocations = application.oLakebase.toQuery(
			application.oLakebase.selectRows("session_variable_storage", { "user_id" = "eq.#request.AccessStructure.User_ID#", "order" = "timestamp_of_save.desc" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetExistingWDDXPacketLocations = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetExistingWDDXPacketLocations>
	<cfquery name="getExistingWDDXPacketLocations" datasource="#application.datasource#">
		SELECT *
		FROM Session_Variable_Storage
		WHERE User_Id = '#request.AccessStructure.User_ID#'
		ORDER BY Timestamp_Of_Save DESC
	</cfquery>
</cfif>

<cfset MAXIMUMALLOWWEDWDDXPACKETS = 6>

<cfset RecordList = ValueList(getExistingWDDXPacketLocations.Session_Variable_Storage_ID)>
<cfset FileLocationList = ValueList(getExistingWDDXPacketLocations.WDDXPacket_File_Location)>

<cfset ListOfRecordsToDelete = "">
<cfset ListFileLocationsToDelete = "">
<cfset PositionCounter = 1>

<CFIF listlen(RecordList) GTE MAXIMUMALLOWWEDWDDXPACKETS>
	<cfloop index="RecordIDToDelete" list="#RecordList#">
		<cfif PositionCounter GTE MAXIMUMALLOWWEDWDDXPACKETS>
			<cfset ListOfRecordsToDelete = listappend(ListOfRecordsToDelete,RecordIDToDelete)>
			<CFSET tempFileLocation = listgetat(FileLocationList,PositionCounter)>
			<cfset ListFileLocationsToDelete = listappend(ListFileLocationsToDelete,tempFileLocation)>
			<CFIF FileExists(tempFileLocation)>
				<cffile action="DELETE" file="#tempFileLocation#">
			</CFIF>
		</cfif>
		<cfset PositionCounter = PositionCounter + 1>
	</cfloop>

	<cfif listlen(trim(ListOfRecordsToDelete)) GT 0>
		<cfset useLakebaseForDeleteExcessRecords = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_variable_storage")>
		<cfif useLakebaseForDeleteExcessRecords>
			<cftry>
				<cfset application.oLakebase.deleteRows("session_variable_storage", { "session_variable_storage_id" = "in.(#ListOfRecordsToDelete#)" })>
				<cfcatch type="any">
					<cfset useLakebaseForDeleteExcessRecords = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForDeleteExcessRecords>
			<cfquery name="DeleteExcessRecords" datasource="#application.datasource#">
				DELETE FROM Session_Variable_Storage
				WHERE Session_Variable_Storage_ID IN(#ListOfRecordsToDelete#)
			</cfquery>
		</cfif>
	</cfif>
</CFIF>

<cfwddx action="CFML2WDDX" input="#session#" output="sessionWDDXPacket" usetimezoneinfo="Yes">

<CFSET File_Location = "E:\inetpub\wwwroot\awayx\Common_files\Session_WDDX_Files\#CreateUUID()##CreateUUID()#.svp">
<cfset File_Location = ReplaceNoCase(File_Location, "-", "_", 'ALL')>
  
<cffile action="WRITE" file="#File_Location#" output="#sessionWDDXPacket#" addnewline="Yes">


<cfset useLakebaseForSaveWDDXPacketLocation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_variable_storage")>
<cfif useLakebaseForSaveWDDXPacketLocation>
	<cftry>
		<cfset application.oLakebase.insertRow("session_variable_storage", {
			"user_id" = request.AccessStructure.User_ID,
			"wddxpacket_file_location" = File_Location,
			"timestamp_of_save" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSaveWDDXPacketLocation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaveWDDXPacketLocation>
	<cfquery name="SaveWDDXPacketLocation" datasource="#application.datasource#">
		INSERT INTO Session_Variable_Storage
		(User_ID,WDDXPacket_File_Location, Timestamp_Of_Save)
		VALUES
		('#request.AccessStructure.User_ID#','#File_Location#', #createodbcdatetime(Now())#)
	</cfquery>
</cfif>

<cfparam name="URL.ThisCodeExecutedInWindow" default="0">

<cfif URL.ThisCodeExecutedInWindow EQ 1>
	<script>
		window.close();
	</script>
</cfif>

<cfparam name="URL.ReturnToAutomatedSessionSave" default="0">

<cfif URL.ReturnToAutomatedSessionSave EQ 1>
	<cflocation url="automatedSessionSave.cfm">
</cfif>
