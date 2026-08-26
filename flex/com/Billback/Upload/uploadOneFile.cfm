
<!--- uploadOneFile.cfm :: mws 
Called from Flex BB Tool for Uploading Billbacks
	* anything that is outputed by this template gets displayed in Flex
	* After file is uploaded a thread is dispatched that parses file and calls DB to process the data.
	* thread call goes to mvc.Models.Billback.BillbackUploadManager.logUpload().
	* results are sent back to the UI via  sendGatewayMessage("cfData",msg);
 --->

<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfprocessingdirective  suppresswhitespace="true">


<cfset uploadFilePath = '#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files' />
<cfset uploadTempFilePath = '#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files\uploadTemp' />
<cfset proceedProcess = 0 />

<cftry>  
	<!--- <cffile action="upload"
		filefield="Filedata"
		destination="#uploadFilePath#"
		nameconflict="MAKEUNIQUE" /> --->
	<cffile action="upload"
		filefield="Filedata"
		destination="#uploadTempFilePath#"
		nameconflict="Overwrite" />

		<cfset useLakebaseForqryFileCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForqryFileCheck>
	<cftry>
		<cfset qryFileCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_log", {
				"header_file_name" = "eq.#CFFILE.serverFile#",
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
			SELECT * FROM BB_upload_log WHERE header_file_name = '#CFFILE.serverFile#' AND Deleted = 0
		</cfquery>
</cfif>
	<cfif (qryFileCheck.RecordCount EQ 0)>
			<cfset proceedProcess = 1 />
			<cffile action="COPY" 		
				source = "#uploadTempFilePath#\#CFFILE.serverFile#" 
				destination = "#uploadFilePath#">
			<cffile action = "delete" 
				file = "#uploadTempFilePath#">
	<cfelse>
			<!--- THROW ERROR FOR DUPLICATE --->
			<cfset filePathTemp = uploadTempFilePath & "\" & CFFILE.serverFile />
			<cffile action = "delete" 
			file = "#filePathTemp#">
		</cfif>	
		
	<cfcatch>
		<!---   <cfdump var="#cfcatch.Message#" output="C:\temp\fileupload.txt" /> 
		   <cfdump var="#cfcatch.Detail#" output="C:\temp\fileupload.txt" />  --->
		  
<!--- 		<cfoutput>#cfcatch.Message#</cfoutput> --->
	</cfcatch>
</cftry>			

<cfif (proceedProcess)>

	<!--- path to File that the Parser will digest --->
	<cfset BBFilePath = "#uploadFilePath#\#cffile.serverFile#">
	<!--- 
	 	Build struct that will get sent to BillbackUploadManager.logUpload()
 		* cfc path is a gateway used to send info back to flex client
 		* 
	--->
	<cfscript> 
		//variables.oBillBackUploadMan = createObject('component','mvc.Models.Billback.BillbackUploadManager').init(); 
	    status = false;
	    props = structNew(); 
	    props.Message = "";
	    props.userStruct = request.accessStructure;
	    props.fileName = cffile.serverFile;
	    props.filePath = BBFilePath;
	    props.timeout = '99999';
		props.fileSize = cffile.FileSize;
	 	//this gets displayed in flex.
	    WriteOutput('"#cffile.serverFile#": File upload and validation in process.'); 
	</cfscript>
<!--- Displatch the logUpload() in a thread so it will process in background --->
 <cfthread action="run" name="bbUpload_#createUUID()#" 
		   props="#props#" >
		<cfscript>
			oBillBackUploadMan = createObject('component','mvc.Models.Billback.BillbackUploadManager').init();
			oBillBackUploadMan.logUpload(props);
		</cfscript>
  </cfthread> 
 
<cfelse>
	<!--- <cfdump var="In else SEND THE ALERT TO FLEX" output="C:\temp\fileupload.txt" />		 --->
	  <cfscript>
		arrCorrections	= ArrayNew(1);
		arrParseResult	= ArrayNew(1);

		message = "DUPLICATE FILE ERROR:: File: #cffile.serverFile# already exists!!!" ;
		msg = structNew();
		msg.body = structNew();
		msg.body['message'] =  message;
		msg.body['arrParseResult'] =  arrParseResult;
		msg.body['arrCorrections'] =  arrCorrections;
		msg.body['sFileName'] =  cffile.serverFile;
		msg.body['serial'] = timeformat(now(),"long");
		msg.body['user'] = request.accessStructure.user_code;
		msg.body['user_Id'] = request.accessStructure.User_ID;
		msg.destination = "ColdFusionGateway"; 
		//sendGatewayMessage("cfData",msg); 
		WsPublish("cfData",msg); 
	</cfscript>	  
</cfif>
</cfprocessingdirective>  
