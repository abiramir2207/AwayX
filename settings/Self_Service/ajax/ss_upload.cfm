<!---
  * ====================================================================================================
  *    @File:   AwayX\settings\Self_Service\ss_upload.cfm
  *    @Author: Anand Rao
  *    @Date:   16 Sep 2024
  *
  *    @Remarks: Self Serve Upload Page
  *
  * ====================================================================================================
--->
<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfoutput>
<cftry>
	<cfset  final_destination = application.doc_path & "\Data_Files\Uploaded\settings\self_serve\">



	<cfif not DirectoryExists( final_destination )>
		<cfdirectory action="create" directory="#final_destination#">
	</cfif>

	<cffile action="uploadall" destination="#final_destination#" nameconflict="MakeUnique" result="upload_result">

	<cfcatch type="any" >
		#serializeJSON( { STATUS=500, MESSAGE="An unexpected error has occurred, please report it to the technical support department." } )#
	</cfcatch>
</cftry>
<cfsilent>
<cfscript>
	errors = [];
</cfscript>
  <cfset selfServeMgr = createObject("component","mvc.Models.Admin.SelfServe.SelfServeManager") />
  <cfset ActionTypeVal = selfServeMgr.getActionLookup(FORM.selActionType).Action_Type />
<cftry>

<cfloop array="#upload_result#" item="upload">

	<cfspreadsheet action="read" src="#(final_destination & upload.serverFile)#" query="qContent" headerrow="1" excludeHeaderRow="true">

	<cfquery name="qFileData" dbtype="query">
		SELECT *
		FROM qContent
	</cfquery> 

	<cfset missing_columns = 0>
	<!--- add missing columns --->
	<!--- cfloop from="#qFileData.columnList.listLen() + 1#" to="5" index="i">
		<cfset missing_columns++>
		<cfset queryAddColumn( qFileData, "missing_column_" & i, "varchar", repeatString( "Missing,", qFileData.recordCount ).listToArray() )>
	</cfloop --->

	<cfscript>
		header_status = '';
		detail_columns = qFileData.getMetaData().getColumnLabels();

		if ( arrayLen( detail_columns ) neq 11 ) {
			header_status = "Expected 11 columns in upload file";
			errors.append( header_status );
		}
	</cfscript>
 
<!--- /* '#upload.fileSize#', */ to be added in the below query after Upload_FileName --->
	<cfquery name="qSaveSelfServeLog" datasource="#application.datasource#">
		SET NOCOUNT ON
		INSERT INTO	Self_Serve_Log (
							Self_Serve_Action_Category_Type_Lookup_ID, 
							Category_Type,
							Action_type,
							Created_By,
							Created_Date,
							Upload_FileName,
							File_Size,
							Upload_Status,
							Record_Count,
							Error_Count, 
							Success_Count,
							Deleted
						)
		VALUES	(
					'#form.selActionType#',
					'#form.selCategory#',
					'#ActionTypeVal#',
					'#request.AccessStructure.user_id#',
					getDate(),
					'#upload.serverFileName#',
					'#upload.fileSize#',
					'File Uploaded successfully',	
					#qFileData.recordCount#,
					0,
					0,
					0
				)

		SELECT @@Identity AS newId
		SET NOCOUNT OFF
	</cfquery>
	<cfset docId = qSaveSelfServeLog.newId>

    <!--- <cfreturn> --->

    <!--- store multiple detail rows into an array for a speedy batch processing --->
    <cfset batch_values = []>
    <cfloop query="qFileData">
		<cfscript>
			BB_Code			= trim(qFileData[ detail_columns[ 1 ] ][ qFileData.currentRow ]);
			BB_Reference    = trim(qFileData[ detail_columns[ 2 ] ][ qFileData.currentRow ]);
			BB_Start_Date 	= trim(qFileData[ detail_columns[ 3 ] ][ qFileData.currentRow ]);
			BB_End_Date    	= trim(qFileData[ detail_columns[ 4 ] ][ qFileData.currentRow ]);
			Operator    	= trim(qFileData[ detail_columns[ 5 ] ][ qFileData.currentRow ]);
			Distributor     = trim(qFileData[ detail_columns[ 6 ] ][ qFileData.currentRow ]);
			Item    		= trim(qFileData[ detail_columns[ 7 ] ][ qFileData.currentRow ]);
			Program     	= trim(qFileData[ detail_columns[ 8 ] ][ qFileData.currentRow ]);
			ComponentName    = trim(qFileData[ detail_columns[ 9 ] ][ qFileData.currentRow ]);
			Cases 			= trim(qFileData[ detail_columns[ 10 ] ][ qFileData.currentRow ]); 
			Action_By_User_Code  = trim(qFileData[ detail_columns[ 11 ] ][ qFileData.currentRow ]);
		</cfscript>

        <!--- save new value into a short string 
/*Item    		= qFileData[ detail_columns[ 7 ] ][ qFileData.currentRow ]; */
 /* '#application.util.query.stringEncoded( Item )#', */
        --->
        <cfsavecontent variable="new_value">( #docId#, '#application.util.query.stringEncoded( BB_Code )#',
                                                       '#application.util.query.stringEncoded( BB_Reference )#',
                                                       '#application.util.query.stringEncoded( BB_Start_Date )#',
                                                       '#application.util.query.stringEncoded( BB_End_Date )#',
                                                       '#application.util.query.stringEncoded( Operator )#',
                                                       '#application.util.query.stringEncoded( Distributor )#',
                                                       '#application.util.query.stringEncoded( Item )#',
                                                       '#application.util.query.stringEncoded( Program )#',
													   '#application.util.query.stringEncoded( ComponentName )#', 
													   '#application.util.query.stringEncoded( Cases )#', 
													   '#application.util.query.stringEncoded( Action_By_User_Code )#' 
													   )
													</cfsavecontent>
        <!--- save new value to load into the db later --->
        <cfset batch_values.append( new_value )>

         <!--- break large upload into smaller chunks to avoid SQL error --->
        <cfif ( qFileData.currentRow mod 900 eq 0 ) or ( qFileData.currentRow eq qFileData.recordCount )>
            <!--- load multiple detail rows into the database 
/*BB_Item_Final_ID, */ /* change this after confirming the column with PRIYA*/
            --->
            <cfquery datasource="#application.datasource#">
                SET NOCOUNT ON
                INSERT INTO Self_Serve_BB_Update_Data_log(
						Self_Serve_Log_ID,
						BB_Code,
						Reference_Number,
						Start_Date,
						End_Date,
						Operator,
						Distributor,
						Item,
						Program,
						Component,
						Updated_Cases,
						Action_By_User_Code
                    )
                VALUES
                    #batch_values.toList()#
                SET NOCOUNT OFF

				<!--- validate rows in the upload file when all required columns are there --->
				<cfif ( missing_columns eq 0 ) and ( qFileData.currentRow gte qFileData.recordCount )>
						EXEC Self_Serve_Update_Billback #docId#
				</cfif>
            </cfquery>
            <!--- reset our batch processing array for the next chunk --->
            <cfset batch_values = []>
        </cfif>
    </cfloop>
</cfloop>

<cfcatch>
<cfdump var="#cfcatch.type#" output="C:\CFTmpDump\error.txt"/>
<cfdump var="#cfcatch.Message#" output="C:\CFTmpDump\error.txt"/>
<cfdump var="#cfcatch.Detail#" output="C:\CFTmpDump\error.txt"/>
</cfcatch>
</cftry>

</cfsilent>



<cfif arrayLen( errors )>
	<cfdump var="#errors#"  output="C:\CFTmpDump\ErrorAtEnd.txt" />
 
	#serializeJSON( { STATUS=500, MESSAGE="Errors in uploaded file, please review the detailed upload." } )#
<cfelse>
	#serializeJSON( { STATUS=200, MESSAGE="Processed" } )#
</cfif>
</cfoutput>
