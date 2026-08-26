<cfparam name="LongTermData_ProgramID" default="0">
<cfparam name="LongTermData_Filaname" default="">
<cfparam name="LongTermData_Packet" default="">
<CFWDDX ACTION="CFML2WDDX" INPUT="#LongTermData_Packet#" OUTPUT="LongTermData_Program_Packet" USETIMEZONEINFO="Yes">

<cfset LongTermWDDXProgramCopy_Directory = "#Application.Doc_Path#\data_files\created\contracts\LongTermWDDXProgramCopy\">
<cfset LongTermWDDXProgramCopy_Filename = "LongTermWDDXProgramCopy_" & Replace(createuuid()&createuuid(), '-', '', 'ALL')& ".tmp">
<cffile action="WRITE" file="#LongTermWDDXProgramCopy_Directory##LongTermWDDXProgramCopy_Filename#" output="#LongTermData_Program_Packet#" addnewline="Yes">

<cfset useLakebaseForCheckForExistingProgramPacket = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("longtermwddxprogramcopy")>
<cfif useLakebaseForCheckForExistingProgramPacket>
	<cftry>
		<cfset checkForExistingProgramPacket = application.oLakebase.toQuery(
			application.oLakebase.selectRows("longtermwddxprogramcopy", { "program_id" = "eq.#LongTermData_ProgramID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCheckForExistingProgramPacket = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForExistingProgramPacket>
	<cfquery name="checkForExistingProgramPacket" datasource="#application.datasource#">
		SELECT *
		FROM LongTermWDDXProgramCopy
		WHERE Program_ID = '#LongTermData_ProgramID#'
	</cfquery>
</cfif>

<CFIF checkForExistingProgramPacket.recordcount EQ 0>
	<cfset useLakebaseForQrySaveLongTermWDDXProgramCopy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("longtermwddxprogramcopy")>
	<cfif useLakebaseForQrySaveLongTermWDDXProgramCopy>
		<cftry>
			<cfset application.oLakebase.insertRow("longtermwddxprogramcopy", { "program_id" = LongTermData_ProgramID, "packetfilename" = LongTermWDDXProgramCopy_Filename, "deleted" = false })>
			<cfcatch type="any">
				<cfset useLakebaseForQrySaveLongTermWDDXProgramCopy = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQrySaveLongTermWDDXProgramCopy>
		<cfquery name="qrySaveLongTermWDDXProgramCopy" datasource="#application.datasource#">
			INSERT INTO LongTermWDDXProgramCopy
			(Program_ID, PacketFilename)
			VALUES
			('#LongTermData_ProgramID#', '#LongTermWDDXProgramCopy_Filename#')
		</cfquery>
	</cfif>
<cfelse>
	<cfset useLakebaseForQrySaveLongTermWDDXProgramCopyUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("longtermwddxprogramcopy")>
	<cfif useLakebaseForQrySaveLongTermWDDXProgramCopyUpdate>
		<cftry>
			<cfset application.oLakebase.updateRows("longtermwddxprogramcopy",
				{ "program_id" = "eq.#LongTermData_ProgramID#" },
				{ "packetfilename" = LongTermWDDXProgramCopy_Filename }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForQrySaveLongTermWDDXProgramCopyUpdate = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQrySaveLongTermWDDXProgramCopyUpdate>
		<cfquery name="qrySaveLongTermWDDXProgramCopy" datasource="#application.datasource#">
			UPDATE LongTermWDDXProgramCopy
			SET PacketFilename = '#LongTermWDDXProgramCopy_Filename#'
			WHERE Program_ID = '#LongTermData_ProgramID#'
		</cfquery>
	</cfif>
</CFIF>
