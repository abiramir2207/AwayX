<cfcomponent displayname="Service">
	<cffunction name="queryRowToStruct" access="public" returntype="array">
		<cfargument name="query" required="no" type="any" />
		<cfscript>
		        var l = StructNew();
		        var qry = ARGUMENTS.Query;
		        l.ix = 1;
		        l.rCount = qry.RecordCount;
		        // Get the list of columns as an array and the column count.
		        l.Columns = ListToArray( qry.ColumnList );
		        l.colCount = ArrayLen( l.Columns );
		        l.arr = ArrayNew( 1 );
		        // Loop over the rows to create a structure for each row.
		        for (l.RowIndex = l.ix ; l.RowIndex LTE l.rCount ; l.RowIndex = (l.RowIndex + 1)){

		            ArrayAppend( l.arr, StructNew() );
		            l.arrIdx = ArrayLen( l.arr );
		            // Loop over the columns
		            for (l.cIdx = 1 ; l.cIdx LTE l.colCount ; l.cIdx = (l.cIdx + 1)){
		                // Get the value.
		                l.cName = l.Columns[ l.cIdx ];
		                // Set value in struct
		                l.arr[ l.arrIdx ][ l.cName ] = qry[ l.cName ][ l.RowIndex ];
		            }
		        }
				 // Return
		         return( l.arr );
		</cfscript>
	</cffunction>
	
	<cffunction name="log" returntype="string">
		<cfargument name="fname" type="string" required="true" default="">	
		<cfargument name="data" type="string" required="true" default="">	
		<cfargument name="format" type="string" required="false" default="xml">
		<cfargument name="type" type="string" required="false" default="in">
		<cfscript>
			//log it
			tStamp = DateFormat(now(),"YYYYMMDD")&'_' & TimeFormat(now(),"HHMMSS");
			path=ExpandPath("*.*");
			dir=GetDirectoryFromPath(path);
			fullPathName = "#dir#components\Interfaces\Service\Log\#arguments.fname#_#tStamp#.#arguments.format#";
			fileWrite(fullPathName,arguments.data,'UTF-8');
			
			if(arguments.type == 'in'){
				fullPathDestination = '#getDTSPath()#\Inbox\#arguments.fname#_#tStamp#.#arguments.format#';
				FileCopy(fullPathName, fullPathDestination);
			}
			else{
				if(DirectoryExists('#getDTSPath()#\Interface_Backup')){
					fullPathDestination = '#getDTSPath()#\Interface_Backup\#arguments.fname#_#tStamp#.#arguments.format#';
					FileCopy(fullPathName, fullPathDestination);
				}
				else{
					fullPathDestination = '#getDTSPath()#\#arguments.fname#_#tStamp#.#arguments.format#';
				}
					
			}
			
			
			
			if(arguments.type == 'in'){
				return fullPathDestination;
			}
			else{
				return '\components\Interfaces\Service\Log\#arguments.fname#_#tStamp#.#arguments.format#';
			}
			
		</cfscript>
	</cffunction>
	
	<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">	
		<cfdump var="#x#" output="c:\dump.log">
	</cffunction>
	
	<cffunction name="validate" returntype="String" Output="false">
		<cfargument name="apiKey" type="String" required="true" default="">	
		<cfscript>
			if(compare(arguments.apiKey,'D885C71F7FE6751A5E775105E56AF6AFC725BE8143D2299D28739DF39E809162') != 0){ //NOT AUTHORIZED
				return 'NOT AUTHORIZED';
			}
			else{
				return '';
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="updDataInt" access="public" returntype="void" output="false">
		<cfargument name="DataIntegrationUploadId" type="numeric" required="true" default="0">
		<cfargument name="fname" type="string" required="true" default="">
		<cfargument name="category" type="string" required="false" default="">
		<cfquery name="qGetRequestId" datasource="#application.datasource#">
			UPDATE Data_integration_Upload
			SET Unique_File_Name = '#ListLast(fname,'\')#'
			<cfif arguments.category NEQ "">, category = '#arguments.category#'</cfif>
			where Data_integration_Upload_id = #DataIntegrationUploadId#
		</cfquery>
		<cfscript>
			return;
		</cfscript>
	</cffunction>

	<cffunction name="updateActivityLog" access="public" returntype="void" output="false">
		<cfargument name="error" required="false" type="string" default=""/>
		<cfargument name="intraId" required="false" type="string" default="0"/>
		<cfquery name="qUpdateLog" datasource="#application.datasource#">
				DECLARE @Log_WebServices_Activity_ID INT = 0;

				SELECT @Log_WebServices_Activity_ID = Log_WebServices_Activity_ID 
				FROM Log_WebServices_Activity 
				WHERE Intra_ID = '#arguments.intraId#' AND Completion_Status = 0

				UPDATE	Log_WebServices_Activity
				SET		ERROR_TIME = GETDATE(),
						Activity_End = GETDATE(),
						[ERROR_MESSAGE] = '#arguments.error#',
						Completion_Status = 2
				WHERE	Log_WebServices_Activity_ID = @Log_WebServices_Activity_ID
		</cfquery>

	</cffunction>
	
	<cffunction name="getDataIntCount" access="public" returntype="Numeric" output="false">
		<cfargument name="DataIntegrationUploadId" type="numeric" required="true" default="0">

		<cfset useLakebaseForqGeDataIntTotalCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_upload")>
<cfif useLakebaseForqGeDataIntTotalCount>
	<cftry>
		<cfset qGeDataIntTotalCount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration_upload", {
				"data_integration_upload_id" = "eq.#arguments.DataIntegrationUploadId#",
				"select" = "total_count_received"
			}), "total_count_received"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGeDataIntTotalCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGeDataIntTotalCount>
<cfquery name="qGeDataIntTotalCount" datasource="#application.datasource#">
			Select Total_Count_Received FROM  Data_integration_Upload WHERE Data_integration_Upload_ID = #arguments.DataIntegrationUploadId#
		</cfquery>
</cfif>
		<cfscript>
			return qGeDataIntTotalCount.Total_Count_Received;
		</cfscript>
	</cffunction>
	
	<cffunction name="getDTSPath" access="public" returntype="String" output="false">

		<cfquery name="qgetDTSPath" datasource="#application.datasource#">
			 SELECT DTS_Reference_Path from [DataInt_Settings]
		</cfquery>
		<cfscript>
			return qgetDTSPath.DTS_Reference_Path;
		</cfscript>
	</cffunction>
	<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML with no headers.">
		<cfargument name="data" 		type="array"    required="true" hint="The array to convert">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. False by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>

		<cfscript>
		var buffer = createObject('java','java.lang.StringBuilder').init('');
		var target = arguments.data;
		var x = 1;
		var dataLen = arrayLen(target);
		var thisValue = "";
		var rootElement = "array";
		var itemElement = "item";

		// Root Name
		if( len(arguments.rootName) ){ rootElement = arguments.rootName; }

		//Create Root
		 
		buffer.append("<?xml version='1.0' encoding='UTF-8'?>");
		buffer.append("<#rootElement# Length='#dataLen#'>");
		
		for (i=1;i LTE dataLen;i=i+1) {
			
			buffer.append("<#itemElement# id='#i#'>");
			
			structData = target[i];
			arrStructKeys  = StructKeyArray(structData);
			
			for (x=1;x LTE ArrayLen(arrStructKeys);x=x+1) {
				
				buffer.append("<#arrStructKeys[x]#>#structData[arrStructKeys[x]]#</#arrStructKeys[x]#>");
			}	
			buffer.append("</#itemElement#>");
		}
		buffer.append("</#rootElement#>");
		return buffer.toString();
		</cfscript>
	</cffunction>

	<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts an array into XML with no headers.">
		<cfargument name="data" 		type="struct"   required="true" hint="The struct to convert">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. False by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>

		<cfscript>
			var buffer = createObject('java','java.lang.StringBuilder').init('');
			var target = arguments.data;
			var x = 1;
			var dataLen = [];//arrayLen(target)
			var thisValue = "";
			var rootElement = "array";
			var itemElement = "item";
			var arrStructKeys = [];
			var arrDataKeys = [];
	
			// Root Name
			if( len(arguments.rootName) ){ rootElement = arguments.rootName; }
			
			arrDataKeys = StructKeyArray(data);
			
			//Create Root
			buffer.append("<?xml version='1.0' encoding='UTF-8'?>");
			buffer.append("<#rootElement# length='#arraylen(arrDataKeys)#'>");
			//dmp(arrDataKeys);
			for (n=1;n LTE ArrayLen(arrDataKeys);n=n+1) {
					
				//buffer.append("<#arrStructKeys[x]#>#structData[arrStructKeys[x]]#</#arrStructKeys[x]#>");
				nodeData = data[arrDataKeys[n]];
				if(isArray(nodeData)){
					for (i=1;i LTE ArrayLen(nodeData);i=i+1) {//ARRAY
						
						buffer.append("<#itemElement# id='#i#'>");
						
						structData = nodeData[i];
						arrStructKeys  = StructKeyArray(structData);
						
						for (x=1;x LTE ArrayLen(arrStructKeys);x=x+1) {
							
							buffer.append("<#arrStructKeys[x]#>#structData[arrStructKeys[x]]#</#arrStructKeys[x]#>");
						}	
						buffer.append("</#itemElement#>");
					}
				}
				else if(isStruct(nodeData)){//STRUCT
					arrNodeKeys  = StructKeyArray(nodeData);
					buffer.append("<#arrDataKeys[n]# length='#ArrayLen(arrNodeKeys)#'>");
					//dmp(arrNodeKeys);
						for (c=1;c LTE ArrayLen(arrNodeKeys);c=c+1) {
							innerNodeData = nodeData[arrNodeKeys[c]];
							if(isArray(innerNodeData)){
								buffer.append("<#arrNodeKeys[c]# length='#ArrayLen(innerNodeData)#'>");
								for (j=1;j LTE ArrayLen(innerNodeData);j=j+1) {//ARRAY
									buffer.append("<#itemElement# id='#j#'>");
									jNodeData = innerNodeData[j];
									arrJNodeKeys  = StructKeyArray(jNodeData);
									for (k=1;k LTE ArrayLen(arrJNodeKeys);k=k+1) {
										//dmp(jNodeData[arrJNodeKeys[k]]);
										buffer.append("<#arrJNodeKeys[K]#>#jNodeData[arrJNodeKeys[K]]#</#arrJNodeKeys[K]#>");
									}
									buffer.append("</#itemElement#>");
								}
								buffer.append("</#arrNodeKeys[c]#>");
							}
							else if(isStruct(innerNodeData)){
								arrInnerNodeKeys  = StructKeyArray(innerNodeData);
								for (z=1;z LTE ArrayLen(arrInnerNodeKeys);z=z+1) {
									//dmp(innerNodeData[arrInnerNodeKeys[z]]);
								}
							}
							else{
								buffer.append("<#arrNodeKeys[c]#>#innerNodeData#</#arrNodeKeys[c]#>");
							}
							
						}
					buffer.append("</#arrDataKeys[n]#>");
				}
				else{//STRING?
					//tbd
					//dmp('STRING');
				}
			}
			buffer.append("</#rootElement#>");
			return buffer.toString();
		</cfscript>
	</cffunction>
	
	<cffunction name="structToXMLNew" returnType="string" access="public" output="false" hint="Converts an array into XML with no headers.">
		<cfargument name="data" 		type="struct"   required="true" hint="The struct to convert">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. False by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>

		<cfscript>
			var buffer = createObject('java','java.lang.StringBuilder').init('');
			var target = arguments.data;
			var x = 1;
			var dataLen = [];//arrayLen(target)
			var thisValue = "";
			var rootElement = "array";
			var itemElement = "item";
			var arrStructKeys = [];
			var arrDataKeys = [];
	
			// Root Name
			if( len(arguments.rootName) ){ rootElement = arguments.rootName; }
			
			arrDataKeys = StructKeyArray(data);
			
			//Create Root
			buffer.append("<?xml version='1.0' encoding='UTF-8'?>");
			buffer.append("<#rootElement#>");
			//dmp(arrDataKeys);
			buffer.append(structToXMLRecurse(data));
			buffer.append("</#rootElement#>");
			return buffer.toString();
		</cfscript>
	</cffunction>
	
	<cffunction name="structToXMLRecurse" returnType="string" access="public" output="false" hint="Converts an array into XML with no headers.">
		<cfargument name="data" 		type="any"   required="true" hint="The struct to convert">
		<cfscript>
			var buffer = createObject('java','java.lang.StringBuilder').init('');
			var target = arguments.data;
			var i = 1;
			var n = 1;
			var c = 1;
			var dataLen = [];//arrayLen(target)
			var thisValue = "";
			var rootElement = "array";
			var itemElement = "row";
			var arrStructKeys = [];
			var arrDataKeys = [];
			var arrNodeKeys = [];
			var nodeData = '';
			var innerNodeData = '';
			var structData = '';
			
			if(isarray(data)){
				arrDataKeys = data;
			}
			else{
				arrDataKeys = StructKeyArray(data);
			}
			

			//dmp(arrDataKeys);
			for (n=1;n LTE ArrayLen(arrDataKeys);n=n+1) {
				//buffer.append("<#arrStructKeys[x]#>#structData[arrStructKeys[x]]#</#arrStructKeys[x]#>");
				if(isarray(data)){
					nodeData = data[n];
				}
				else{
					nodeData = data[arrDataKeys[n]];
				}
				
				if(isArray(nodeData)){
					for (i=1;i LTE ArrayLen(nodeData);i=i+1) {//ARRAY
						structData = nodeData[i];
						buffer.append("<#itemElement# id='#i#'>");
						if(isSimpleValue(structData)){
							buffer.append("#structData#");
						}
						else{
							buffer.append(structToXMLRecurse(structData));
						}
						buffer.append("</#itemElement#>");
					}
				}
				else if(isStruct(nodeData)){//STRUCT
					arrNodeKeys  = StructKeyArray(nodeData);
					//this.dmp(arrNodeKeys);
					if(isSimpleValue(arrDataKeys[n])){
						//this.dmp(arrNodeKeys);
						//if(arrDataKeys[n] =='Data'){dmp(data);}
						buffer.append("<#arrDataKeys[n]#>");
					}
					else{
						buffer.append("<#itemElement# id='#n#'>");
					}
						for (c=1;c LTE ArrayLen(arrNodeKeys);c=c+1) {
							innerNodeData = nodeData[arrNodeKeys[c]];
							
							if(isSimpleValue(innerNodeData)){
								buffer.append("<#arrNodeKeys[c]#>#innerNodeData#</#arrNodeKeys[c]#>");
							}
							else{
								buffer.append(structToXMLRecurse(innerNodeData));
							}		
						}
					if(isSimpleValue(arrDataKeys[n])){
						buffer.append("</#arrDataKeys[n]#>");
					}
					else{
						buffer.append("</#itemElement#>");
					}

				}
				else{//STRING?
					//tbd
					buffer.append("#nodeData#");
				}
			}
			return buffer.toString();
		</cfscript>
	</cffunction>
	
	<cffunction name="validateOLD" returntype="String" Output="false">
		<cfargument name="apiKey" type="String" required="true" default="">	
		<cfscript>
			var local = StructNew();
//			dmp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! START START');
//			dmp(cookie.cfid);
//			dmp(cookie.cftoken);
//			dmp('ok ok ok ok');
			//local.threadArrray = arrayNew(1);
			local.adminObject = createobject("component","cfide.adminapi.administrator");
			local.monitorObject = createobject("component","cfide.adminapi.servermonitoring");
			local.adminObject.login('Mws4bks!');
			if(local.monitorObject.GETMONITORSTATUS().isEnabled == false){
				local.monitorObject.StartMonitoring();
			} 
			//dmp(local.monitorObject.GETALLACTIVEREQUESTS());
			//dmp(local.monitorObject.GETALLACTIVECFTHREADS());
			a = local.monitorObject.GETALLACTIVEREQUESTS();
			TemplatePathList = '';
			FunctionList = '';
			UriList = '';
			thisTemplatePath = '';
			thisFunction = '';
			thisUri = '';
			thisCFID = '';
			thisToken = '';
			for (i = 1; i LTE Arraylen(a); i = i + 1) { 
				st = a[i];
//				dmp(st.TEMPLATEPATH);
//				dmp(st.FUNCTIONNAME);
//				dmp(st.URI);
				aVars = st.VARIABLELIST;
				for (x = 1; x LTE Arraylen(aVars); x = x + 1) {
					//dmp(aVars[x]);
					if(aVars[x].scope == 'Cookie'){
						aScopeVars = aVars[x].SCOPEVARIABLES;
						for (y = 1; y LTE Arraylen(aScopeVars); y = y + 1) {
							if(aScopeVars[y].VARIABLENAME == 'CFID'){
								//dmp(aScopeVars[y].VARIABLEVALUE);
								thisCFID = aScopeVars[y].VARIABLEVALUE;
							}
							if(aScopeVars[y].VARIABLENAME == 'CFTOKEN'){
								//dmp(aScopeVars[y].VARIABLEVALUE);
								thisToken = aScopeVars[y].VARIABLEVALUE;
							}
						}
					}
				}
				if(thisCFID == cookie.cfid && thisToken == cookie.cftoken){
					thisTempatePath = 	st.TEMPLATEPATH;
					thisUri = st.URI;
				}
				else{
					TemplatePathList =ListAppend(TemplatePathList,st.TEMPLATEPATH);
					UriList = ListAppend(UriList,st.URI);
				}

			}
			if(compare(arguments.apiKey,'D885C71F7FE6751A5E775105E56AF6AFC725BE8143D2299D28739DF39E809162') != 0){ //NOT AUTHORIZED
//				dmp(reqData.headers);
				return 'NOT AUTHORIZED';
			}else if(ListFindNoCase(TemplatePathList, thisTemplatePath) > 0 && ListFindNoCase(UriList, thisUri) > 0){//ALREADY RUNNING!!
				return 'SERVICE ALREADY RUNNING';
			}
			else{
				return '';
			}
		</cfscript>
	</cffunction>
</cfcomponent>