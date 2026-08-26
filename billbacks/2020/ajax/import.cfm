<!-----------------------------------------------------------------------------------------------------------
	Template : 	/billbacks/2020/ajax/import.cfm
	Author   : 	Tim Ford
	Date     : 	8/21/2020
	Purpose  : 	Upload billbacks from file
------------------------------------------------------------------------------------------------------------>

<cfsetting showdebugoutput="false">
<cfprocessingdirective  suppresswhitespace="true">


<cfset uploadFilePath = '#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files' />
<cfset uploadTempFilePath = '#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files\uploadTemp' />
<cfset proceedProcess = 0 />

<cftry>  
	
	<cffile action="upload" destination="#uploadTempFilePath#" nameconflict="overwrite" result="upload" />
	
	<cfset useLakebaseForqryFileCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForqryFileCheck>
	<cftry>
		<cfset qryFileCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_log", {
				"header_file_name" = "eq.#upload.serverFile#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryFileCheck = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryFileCheck>
<cfquery name="qryFileCheck" datasource="#Application.Datasource#">
		SELECT * FROM BB_upload_log WHERE header_file_name = '#upload.serverFile#' AND Deleted = 0
	</cfquery>
</cfif>
	<cfif (qryFileCheck.RecordCount EQ 0)>
		<cfset proceedProcess = 1 />
		<cffile action="COPY" source = "#uploadTempFilePath#\#upload.serverFile#" destination = "#uploadFilePath#">
		<cffile action = "delete" file = "#uploadTempFilePath#\#upload.serverFile#">
	<cfelse>
		<!--- THROW ERROR FOR DUPLICATE --->
		<cfset filePathTemp = uploadTempFilePath & "\" & upload.serverFile />
		<cffile action = "delete" file = "#filePathTemp#">
	</cfif>	
	
	<cfoutput>#serializeJSON({STATUS=200, MESSAGE=uploadTempFilePath & upload.serverFile})#</cfoutput>
	<cfcatch>
		<cfoutput>#serializeJSON({STATUS=500, MESSAGE=cfcatch.Message})#</cfoutput>
	</cfcatch>

</cftry>			

<cfif (proceedProcess)>

	<!--- path to File that the Parser will digest --->
	<cfset BBFilePath = "#uploadFilePath#\#upload.serverFile#">
	<!--- 
	 	Build struct that will get sent to BillbackUploadManager.logUpload()
	--->
	<cfscript>
	    status = false;
	    props = structNew(); 
	    props.Message = "";
	    props.userStruct = request.accessStructure;
	    props.fileName = upload.serverFile;
	    props.filePath = BBFilePath;
	    props.timeout = '99999';
		props.fileSize = upload.FileSize;
		
	    //WriteOutput('"#upload.serverFile#": File upload and validation in process.');
	</cfscript>

	<!--- Displatch the logUpload() in a thread so it will process in background --->
 	<cfthread action="run" name="bbUpload_#createUUID()#" props="#props#" >
		<cfscript>
			oBillBackUploadMan = createObject('component','mvc.Models.Billback.BillbackUploadManager').init();
			oBillBackUploadMan.logUpload(props);
		</cfscript>
  	</cfthread> 
  
<cfelse>	
	  <cfscript>
		arrCorrections	= ArrayNew(1);
		arrParseResult	= ArrayNew(1);

		message = "DUPLICATE FILE ERROR:: File: #upload.serverFile# already exists!!!" ;
		msg = structNew();
		msg.body = structNew();
		msg.body['message'] =  message;
		msg.body['arrParseResult'] =  arrParseResult;
		msg.body['arrCorrections'] =  arrCorrections;
		msg.body['sFileName'] =  upload.serverFile;
		msg.body['serial'] = timeformat(now(),"long");
		msg.body['user'] = request.accessStructure.user_code;
		msg.body['user_Id'] = request.accessStructure.User_ID;
		msg.destination = "ColdFusionGateway"; 
		//sendGatewayMessage("cfData",msg); 
		WsPublish("cfData",SerializeJSON(msg)); 
	</cfscript>	  
</cfif>
</cfprocessingdirective>  
