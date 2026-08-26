<cfsetting enablecfoutputonly="true" showdebugoutput="false">

<cfoutput>
<cftry>
	<cfset final_destination = application.doc_path & "\Data_Files\Uploaded\settings\planner_indirect_allocation\">
	<cfif not DirectoryExists( final_destination )>
		<cfdirectory action="create" directory="#final_destination#">
	</cfif>

	<cffile action="uploadall" destination="#final_destination#" nameconflict="overwrite" result="upload_result">
	#serializeJSON( {STATUS=200, MESSAGE='Passed' })#

	<cfcatch type="any" >
		#serializeJSON( {STATUS=500, MESSAGE="Failed"} )#
	</cfcatch>
</cftry>
</cfoutput>

<cfsilent>

<cfloop array="#upload_result#" item="upload">

	<cfspreadsheet action="read" src="#(final_destination & upload.serverFile)#" query="qDetail" headerrow="1" excludeHeaderRow="true">
	<cfset missing_columns = 0>
	<!--- add missing columns --->
	<cfloop from="#qDetail.columnList.listLen() + 1#" to="7" index="i">
		<cfset missing_columns++>
		<cfset queryAddColumn( qDetail, "missing_column_" & i, "varchar", repeatString( "Missing,", qDetail.recordCount ).listToArray() )>
	</cfloop>

	<cfset detail_columns = qDetail.getMetaData().getColumnLabels()>

	<cfset header_status = arrayLen( detail_columns ) eq 7 ? '' : "Expected 7 columns in upload file">

	<cfquery name="qSave" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO	Planner_Indirect_Allocation_Upload (
							Planner_Indirect_Allocation_Header_ID,
							Doc_Name,
							Doc_Size,
							Doc_Full_Name,
							Uploaded_By,
							Status
						)
		VALUES	(
					#url.id#,
					'#upload.serverFileName#',
					'#upload.fileSize#',
					'#upload.serverFile#',
					'#request.AccessStructure.user_id#',
					'#header_status#'
				)

		SELECT @@Identity AS newId
		SET NOCOUNT OFF
	</cfquery>
	<cfset docId = qSave.newId>


    <!--- store multiple detail rows into an array for a speedy batch processing --->
    <cfset batch_values = []>
	<cfoutput>
    <cfloop query="qDetail">
		<cfscript>
			query_cfc       = application.util.query;
			Direct_Number   = qDetail[ detail_columns[ 1 ] ][ qDetail.currentRow ];
			Direct_Name     = qDetail[ detail_columns[ 2 ] ][ qDetail.currentRow ];
			Indirect_Number = qDetail[ detail_columns[ 3 ] ][ qDetail.currentRow ];
			Indirect_Name   = qDetail[ detail_columns[ 4 ] ][ qDetail.currentRow ];
			Product         = qDetail[ detail_columns[ 5 ] ][ qDetail.currentRow ];
			Product_Name    = qDetail[ detail_columns[ 6 ] ][ qDetail.currentRow ];
			Allocation_Percentage = qDetail[ detail_columns[ 7 ] ][ qDetail.currentRow ];
		</cfscript>
        <!--- save new value into a short string --->
        <cfsavecontent variable="new_value">(#docId#,'#query_cfc.stringEncoded( Direct_Number )#',
                                                     '#query_cfc.stringEncoded( Direct_Name )#',
                                                     '#query_cfc.stringEncoded( Indirect_Number )#',
                                                     '#query_cfc.stringEncoded( Indirect_Name )#',
                                                     '#query_cfc.stringEncoded( Product )#',
                                                     '#query_cfc.stringEncoded( Product_Name )#',
                                                     '#Allocation_Percentage#')</cfsavecontent>
        <!--- save new value to load into the db later --->
        <cfset batch_values.append( new_value )>

        <!--- break large upload into smaller chunks to avoid SQL error --->
        <cfif ( qDetail.currentRow mod 900 eq 0 ) or ( qDetail.currentRow eq qDetail.recordCount )>
            <!--- load multiple detail rows into the database --->
            <cfquery datasource="#application.datasource#">
                SET NOCOUNT ON
                INSERT INTO
                    Planner_Indirect_Allocation_Upload_Data
                    (
                        Planner_Indirect_Allocation_Upload_ID,
                        Direct_Number,
                        Direct_Name,
                        Indirect_Number,
                        Indirect_Name,
                        Product,
                        Product_Name,
                        Allocation_Percentage
                    )
                VALUES
                    #batch_values.toList()#
                SET NOCOUNT OFF

				<!--- validate rows in the upload file when all required columns are there --->
				<cfif ( missing_columns eq 0 ) and ( qDetail.currentRow eq qDetail.recordCount )>
					EXEC Planner_Indirect_Allocation_Upload_Validation #docId#
				</cfif>
            </cfquery>
            <!--- reset our batch processing array for the next chunk --->
            <cfset batch_values = []>
        </cfif>
    </cfloop>
	</cfoutput>
</cfloop>
</cfsilent>
