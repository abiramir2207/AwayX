<cfcomponent Displayname="XMLLogGenerator" hint="XML Log Generator">

	<cffunction name="init" output="false" returntype="components.settings.audittrail.audittrail">

		<!--- GET APPLICATION SETTINGS --->
		<cfif NOT isDefined("genSettingsManager")>
			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset appSettings = genSettingsManager.get()>
		</cfif>
			
		<cfscript>
			//Identify folder for XML logs.
			this.xml_file_folder = expandPath("/logs") & "\xml";
			this.dsn = Application.Datasource;
		</cfscript>
		
		<!--- Make sure directory EXISTS --->
		<cfif NOT directoryExists(this.xml_file_folder)>
			<cfdirectory action = "create" directory = "#this.xml_file_folder#">
			<cfscript>
				this.xml_file_folder = expandPath("/logs") & "\xml";
			</cfscript>	
		</cfif>
						
		<cfreturn this />
	
	</cffunction>

<!--- PRIVATE PROCESSOR FUNCTIONS FOR USE IN THIS FILE --->
	<cffunction name="tableColumns" 
					access="private" 
					returntype="string" 
					output="false" 
					displayname="tableColumns" 
					hint="Columns to use for selecting from DB to input into log">
		
		<cfargument name="colType" required="true" type="numeric">
		<!--- ID FIELD FROM TABLE MUST BE FIRST, OR IF '*' IT MUST LOOK LIKE THIS: User_ID,* --->
		<cfswitch expression="#colType#">
			<!--- USER SETTINGS (ALL) --->
			<cfcase value="1">
				<cfset colList = "User_ID,*">
			</cfcase>
			<!--- ALL Columns --->
			<cfcase value="2">
				<cfset colList = "*">
			</cfcase>
			<!--- PROGRAM TEMPLATES --->
			<cfcase value="3">
				<cfset colList = "ProgramControl_Panel_Options_ID">
			</cfcase>
		</cfswitch>
		
		<cfreturn colList>
	
	</cffunction>
	<cffunction name="XMLProccessor" 
					access="private" 
					returntype="string" 
					output="false"
					displayname="XMLProcessor" 
					hint="Processes query information to generate XML">
		
		<cfargument name="queryStruct" required="true" default="" type="struct" hint="Query structure to store in an xml file">
		<cfargument name="logType" required="true" default="" type="string" hint="Name of the log that is being generated">

		<!--- CREATE VARIABLES NEEDED IN XML FILE --->
		<cfset modID = dateformat(now(),"YYYYMMDD") & timeFormat(now(),"HHMMSS")>
		
		<!--- REMOVE ANY SPACES FROM THE TYPE FOR FUTURE NAMING CONCERNS... --->
		<cfset type = replace(logType," ","","ALL")>
				
		<!--- CREATE WDDX FORM OF THE QUERY STRUCTURE TO CREATE XML FILE --->
		<cfwddx action="cfml2wddx" input="#queryStruct#" output="wddxUserMods">
		
		<!--- COMPILE XML FILE PATH STRING --->
		<cfset xml_file_path_string = this.xml_file_folder & "\AuditTrail_" & replace(type,' ','','all') & ".xml">
		<cfset xml_file_path = lCase(xml_file_path_string)>

		<cfoutput>
		<!--- IF WE DO ALREADY HAVE AN XML AUDITTRAIL FILE... --->
		<cfif fileExists(xml_file_path)>
			<cfset xml_file_relative_url = "/logs/xml/" & getFileFromPath(xml_file_path)>
		    
		    <cfxml casesensitive="no" variable="xAuditTrailPreExisting">
		    	<cfinclude template="#xml_file_relative_url#">
		    </cfxml>
		    
		    <cfset sAuditTrailPreExisting = trim(toString(xAuditTrailPreExisting))>
		    <cfset sAuditTrailPreExistingNet = replace(sAuditTrailPreExisting,"</audit_trail>","","ALL")>
		    			
<cfxml variable="xAuditTrailFinal">
#trim(sAuditTrailPreExistingNet)#<modification timestamp="#xmlFormat(createODBCDateTime(now()))#" user_id="#xmlFormat(request.AccessStructure.User_ID)#" mod_id="#modID#">#wddxUserMods#</modification></audit_trail>
</cfxml>
		    		
		<!--- IF WE DO NOT ALREADY HAVE AN XML AUDITTRAIL FILE... --->
		<cfelse>
		
<cfxml variable="xAuditTrailFinal">
<audit_trail type="#xmlFormat(replace(type,' ','','all'))#" company_id="#xmlFormat(request.AccessStructure.Company_Main_ID)#"><modification timestamp="#xmlFormat(createODBCDateTime(now()))#" user_id="#xmlFormat(request.AccessStructure.User_ID)#" mod_id="#modID#">#wddxUserMods#</modification></audit_trail>
</cfxml>

		</cfif>
	</cfoutput>

	    <!--- CREATE String Version of XML & remove carriage returns from our xml do and convert to a string with which to write our xml file... --->
	    <cfset sAuditTrailXMLFinal=trim(stripCR(toString(xAuditTrailFinal)))>
	    
	    <!--- WRITE THE XML TO A FILE --->
	    <cfset writeXML(sAuditTrailXMLFinal,type)>
	
	</cffunction>
	<cffunction name="deleteOldEntries" 
					access="private" 
					returntype="void" 
					output="false" 
					displayname="deleteOldEntries" 
					hint="Deletes xml entries older than specified number of weeks.">
	
		<cfargument name="xmlUrl" required="true" default="" type="string">
		<cfargument name="logType" required="true" default="" type="string">
		<cfargument name="weeks" required="true" default="" type="numeric">
		
		<!--- IDENTIFY folder --->
		<cfset xml_file_path_string = this.xml_file_folder & "\AuditTrail_" & replace(arguments.logType,' ','','all') & ".xml">
		<cfset xml_file_path = lCase(xml_file_path_string)>
				
	    <!--- CREATE AN XML OUTPUT OF THE INCLUDED FILE --->
	    <cfxml casesensitive="no" variable="xAuditTrail">
	    	<cfinclude template="#arguments.xmlUrl#">
	    </cfxml>
	    
	    <cfscript>
		    //CREATE START TAG OF XML DOCUMENT BY STRIPPING THE <AUDIT_TRAIL> TAG OUT OF THE STRING TO PUT BACK IN LATER
			xmlString = trim(toString(xAuditTrail));
			removeXMLTag = REFindNoCase("<[^>]*>",xmlString,1,true);
			xmlString = trim(removeChars(xmlString,removeXMLTag.pos[1],removeXMLTag.len[1]));
			findAuditTrailTag = REFindNoCase("<[^>]*>",xmlString,1,true);
			xmlStartTag = removeChars(xmlString,findAuditTrailTag.len[1]+1,len(xmlString));

		    //DELETE NODES OLDER THAN THIS DATE
		    oldDate = dateformat(now()-(weeks*7),"MM/DD/YYYY");
		    
		    //CREATE ARRAY OF XML NODES
			xmlModNodes = xAuditTrail.audit_trail.xmlChildren;
			xmlNodeListToDelete = "";
			
			//LOOP THROUGH THE ARRAY TO SEE IF THERE ARE ANY NODES THAT SHOULD BE DELETEDAND CREATE A LIST OF THOSE NODE LOCATIONS IN THE ARRAY
			for (i=1;i LTE arrayLen(xmlModNodes);i=(i+1))
			{
				dateModified = xmlModNodes[i].XmlAttributes.timeStamp;
				date = dateFormat(dateModified, 'MM/DD/YYYY');
	
				if (date < oldDate){
					xmlNodeListToDelete = listappend(xmlNodeListToDelete,i);
				}
			}
			
			//IF NODES EXIST THAT NEED TO BE DELETED, THEN DO SO IN A REVERSE PATTERN SO THAT THE ORDER OF THE ARRAY DOES NOT CHANGE WITH EACH DELETION
			if (xmlNodeListToDelete NEQ ""){
				xmlNodeListToDelete = ListSort(xmlNodeListToDelete,'numeric','DESC');
				
				for (i=1;i LTE listlen(xmlNodeListToDelete);i=(i+1))
				{
					arrayDeleteAt(xmlModNodes,listGetAt(xmlNodeListToDelete,i));
				}
				
				// CONVERT REMAINING NODES TO A LIST WITH NO DELIMETERS
				xmlModNodes = arrayToList(xmlModNodes,"");				
				// REMOVE THE XML DECLARATION FROM THE STRING
				xmlModNodes = replaceNoCase(xmlModNodes,"<?xml version=""1.0"" encoding=""UTF-8""?>","","ALL");
				//REMOVE ALL SPECIAL CHARACTERS TO MAKE THE STRING ONE SINGLE LINE OF CODE
				xmlModNodes = replaceNoCase(xmlModNodes,chr(9),"","ALL");
				xmlModNodes = replaceNoCase(xmlModNodes,chr(10),"","ALL");
				xmlModNodes = replaceNoCase(xmlModNodes,chr(13),"","ALL");
				
				//OUTPUT THE FINAL STRING WITH THE START TAG AND END TAG
				xmlFinalString = xmlStartTag & xmlModNodes & "</audit_trail>";
			}
		</cfscript>

<!--- IF THE FINAL STRING VARIABLE EXISTS, THEN CREATE THE XML OBJECT --->
<cfif isDefined("xmlFinalString")>
	
<cfoutput>
<cfxml variable="newXMLfile">
#xmlFinalString#
</cfxml>
</cfoutput>

<!--- WRITE THE FILE USING THIS PRIVATE FUNCTION SO THAT THE XML FILE IS UPDATED WITH OLD DATA REMOVED --->
<cfset writeXML(newXMLfile,logType)>

</cfif>
			
	</cffunction>
	<cffunction name="writeXML" 
					access="private" 
					returntype="void" 
					output="false" 
					displayname="writeXML" 
					hint="Writes an xml file from a string input.">
						
		<cfargument name="xmlObj" required="true" default="" type="XML">
		<cfargument name="logType" required="true" default="" type="string">
		
		<!--- CREATE THE DIRECTORY PATH BASED ON THE LOG TPE ARGUMENT --->
		<cfset xml_file_path = lCase(expandPath("/logs") & "\xml" & "\AuditTrail_" & arguments.logType & ".xml")>
		
		
			<!--- Save the XML document to disk [XML] --->
		  	<cftry>
				<!--- get in line... --->
		        <cflock timeout="20" type="exclusive">
		            <cffile action="write" file="#xml_file_path#" output="#arguments.xmlObj#" nameconflict="overwrite">
		        </cflock>
		    	<!--- IF we have an 'oops'... --->
				<cfcatch type="any">
					<b>#cfcatch.Detail#</b>
				</cfcatch>
			</cftry>
	
	</cffunction>

<!--- QUERY DB PROCESSOR --->
	<cffunction name="createXMLLogDBTables" 
					access="public" 
					returntype="string" 
					output="true" 
					displayname="retrieveXMLLog" 
					hint="create xml log table if XML file exists.">
						
		<cfargument name="logType" required="true" default="" type="string">
		<cfargument name="logDate" required="true" default="" type="date">
				
		<!--- REFORMAT LOG DATE FOR COMPARISON PURPOSES --->
		<cfset logDate = dateFormat(logDate, 'MM/DD/YYYY')>
		
		<!--- CREATE THE DIRECTORY PATH BASED ON THE LOG TPE ARGUMENT --->
		<cfset xml_file_path = lCase(expandPath("/logs") & "\xml" & "\AuditTrail_" & arguments.logType & ".xml")>

		<!--- CREATE THE URL PATH TO THE ABOVE FILE --->
		<cfset xml_file_relative_url = "/logs/xml/" & getFileFromPath(xml_file_path)>
		
		<!--- DELETE ANY ENTRIES OVER THE WEEK LIMIT FROM THE XML FILE --->
		<cfset deleteOldEntries(xml_file_relative_url,logType,appSettings.getAuditTrailStorage())>
	    
	    <!--- CREATE AN XML OUTPUT OF THE INCLUDED FILE --->
	    <cfxml casesensitive="no" variable="xAuditTrail">
	    	<cfinclude template="#xml_file_relative_url#">
	    </cfxml>
	    
		<!--- 
			CREATE AN ARRAY OF THE WDDX XML NODES AND CREATE A LIST OF NODES TO DELETE FROM 
			THE ARRAY IF IT DOES NOT MATCH THE DATE PASSED TO THIS FUNCTION
		 --->
		<cfscript>
		xmlNodeArray = xAuditTrail.audit_trail.XmlNodes;
		xmlNodeList = "";
		
			for (i = 1;i LTE arrayLen(xmlNodeArray);i = (i + 1)){
				dateModified = xmlNodeArray[i].XmlAttributes.timeStamp;
				date = dateFormat(dateModified, 'MM/DD/YYYY');
	
				if (date NEQ logDate){
					xmlNodeList = listappend(xmlNodeList,i);
				}
			}			
		</cfscript>
		<cfif arrayLen(xmlNodeArray)>
			<cfset xmlWDDXQuery = xAuditTrail.audit_trail.modification[#arrayLen(xmlNodeArray)#].wddxpacket.data.struct.var.recordset.xmlchildren>
		
			<!--- CREATE FIELD NAME AND DATA TYPE LISTS TO DYNAMICALLY GENERATE THE SQL DB TABLES FROM --->
			<cfset fieldNameList = "">
			<cfset fieldDataTypeList = "">
			<cfloop from="1" to="#arrayLen(xmlWDDXQuery)#" index="i">
				<cfset dataArray = xmlWDDXQuery[i].xmlChildren>
				<cfset fieldNameList = listAppend(fieldNameList,xmlWDDXQuery[i].xmlAttributes.name)>
				<cfset fieldDataTypeList = listAppend(fieldDataTypeList,dataArray[1].xmlName)>
			</cfloop>
		</cfif>
		<!--- DELETE THE NODES THAT DO NOT MATCH THE DATE PASSED TO THIS FUNCTION --->
		<cfloop list="#ListSort(xmlNodeList,'numeric','DESC')#" index="xmlNode">
			<cfset xml = arrayDeleteAt(xmlNodeArray,xmlNode)>
		</cfloop>
		
		<!--- CREATE AN XML ARRAY OF THE RECORD SET FIELDS TO USE FOR CREATING A FIELDNAME LIST AND A DATATYPE LIST --->
		
		<!--- IF THE XML ARRAY HAS NODES, DO THE FOLLOWING --->
		<cfif arrayLen(xmlNodeArray)>
			
			<!--- GET THE LATEST NODE IN THE ARRAY AND CREATE A PARSED VERSION OF THE WDDX SO THAT THE QUERY REMAINS AND STORE IT IN VARIABLE qGetQueryfromXML --->
			<cfset latestXMLEntry = xmlNodeArray[arraylen(xmlNodeArray)].XmlChildren[1]>
			<cfwddx action="wddx2cfml" input="#latestXMLEntry#" output="XMLLatest">
			<cfset qGetQueryfromXML = evaluate('XMLLatest.#arguments.logtype#')>
			
			<!--- CHECK TO SEE IF A TABLE EXISTS FOR THE CURRENT XML FILE --->
			<cfquery name="checkForTable" datasource="#this.dsn#">
				IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#')
				BEGIN 
					SELECT TOP 1 *
					FROM AuditTrail_#arguments.logType#		
				END
			</cfquery>
			
			<!--- 
				IF TABLE EXISTS, CREATE A LIST OF THE COLUMNS IT HAS, THEN COMPARE IT TO THE 
				QUERY THAT WAS EMBEDDED IN THE XML FILE, VARIABLE: qGetQueryfromXML
			 --->
			<cfif isDefined("checkForTable")>
				<cfquery name="checkColumnList" datasource="#this.dsn#">
					SELECT COLUMN_NAME 
					FROM INFORMATION_SCHEMA.COLUMNS 
					WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#'
				</cfquery>
				
				<cfset compareCols1 = "AuditTrail_" & arguments.logType & "_ID,AuditTrail_Mod_By,AuditTrail_Mod_Date,AuditTrail_Mod_ID," & qGetQueryfromXML.columnlist>
				<cfset compareCols2 = valueList(checkColumnList.COLUMN_NAME)>
				<cfset colsMatch = compare(compareCols1,compareCols2)>
			<cfelse>
				<cfset colsMatch = 1>
			</cfif>
			
			<!--- 
				IF THE TABLE DOES NOT EXIST, PROCESS THE FOLLOWING QUERY TO GENERATE THE TABLE NEEDED BASED ON THE QUERIES IN THE XML FILE.
				OR IF THE COLUMN LISTS DO NOT MATCH EXACTLY, PROCESS THE FOLLOWING QUERY TO CREATE THE COLUMNS THAT ARE MISSING.
				(THIS WILL ACCOUNT FOR DATABASE CHANGES BY THE DEVELOPERS).
			 --->
			
			<cfif NOT isDefined("checkForTable") OR colsMatch NEQ 0>
				<cfquery name="checkForTable" datasource="#this.dsn#">
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#')
					BEGIN 
						CREATE TABLE AuditTrail_#arguments.logType# (
						AuditTrail_#arguments.logType#_ID INTEGER IDENTITY(1,1) NOT NULL
						) ON [PRIMARY]
		
					END
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#' AND COLUMN_NAME = 'AuditTrail_Mod_By')
						BEGIN 
							ALTER Table [AuditTrail_#arguments.logType#]
							ADD AuditTrail_Mod_By VARCHAR(50) NULL
						END
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#' AND COLUMN_NAME = 'AuditTrail_Mod_Date')
						BEGIN 
							ALTER Table [AuditTrail_#arguments.logType#]
							ADD AuditTrail_Mod_Date VARCHAR(50) NULL
						END
					IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#' AND COLUMN_NAME = 'AuditTrail_Mod_ID')
						BEGIN 
							ALTER Table [AuditTrail_#arguments.logType#]
							ADD AuditTrail_Mod_ID NUMERIC(20,0) NULL
						END
					<cfset row = 0>
					<cfloop list="#fieldNameList#" index="col">
					<cfset row = row + 1>
						<cfset dataType = listGetAt(fieldDataTypeList,row)>
						IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AuditTrail_#arguments.logType#' AND COLUMN_NAME = '#col#')
						BEGIN 
							ALTER Table [AuditTrail_#arguments.logType#]
							ADD #col# 
								<cfswitch expression="#datatype#">
									<cfcase value="string,null">varchar(100) NULL</cfcase>
									<cfcase value="boolean">bit</cfcase>
									<cfcase value="number">numeric(20,0)</cfcase>
									<cfcase value="datetime">datetime</cfcase>
								</cfswitch>
						END
					</cfloop>
				</cfquery>
			</cfif>

			<!--- LOOP THROUGH THE ARRAY OF NODES --->
			<cfloop from="1" to="#arrayLen(xmlNodeArray)#" index="modID">
			<cfset fieldArray = xmlNodeArray[modID].wddxPacket.data.struct.var.recordset.xmlChildren>
			<cfset fieldNameList = "">
			<cfset fieldDataTypeList = "">

				<!--- LOOP TO CREATE BLANK LISTS FOR DATA INSERT --->
				<cfloop from="1" to="#arrayLen(fieldArray)#" index="FA">
					<cfset dataArray = fieldArray[FA].xmlChildren>
					<cfloop from="1" to="#arrayLen(dataArray)#" index="FV">
						<cfset "dataList#FV#" = "">
					</cfloop>
					<cfset fieldNameList = listAppend(fieldNameList,fieldArray[FA].xmlAttributes.name)>
					<cfset fieldDataTypeList = listAppend(fieldDataTypeList,dataArray[1].xmlName)>
				</cfloop>				
				
				<!--- LOOP TO POPULATE DATA LISTS WITH CONDITIONS FOR SPECIAL DATA AND FIELDS --->
				<cfloop from="1" to="#arrayLen(fieldArray)#" index="FA">
					<cfset dataArray = fieldArray[FA].xmlChildren>
						<cfloop from="1" to="#arrayLen(dataArray)#" index="FV">
							<cfif dataArray[FV].xmlName EQ "boolean">
								<cfset "dataList#FV#" = ListAppend(evaluate('dataList#FV#'),dataArray[FV].XMLAttributes.Value,'|')>
							<cfelseif dataArray[FV].xmlText EQ "">
								<cfset "dataList#FV#" = ListAppend(evaluate('dataList#FV#')," ",'|')>
							<cfelse>
								<cfset "dataList#FV#" = ListAppend(evaluate('dataList#FV#'),dataArray[FV].xmlText,'|')>
							</cfif>
							<cfset dataRowListCnt = FV>
						</cfloop>
				</cfloop>
				
				<!--- CREATE MODIFIED BY AND ID FIELDS FOR IDENTIFICATION OF WHO MADE THE CHANGE --->
				<cfset modifiedBy = xmlNodeArray[modID].XmlAttributes.user_id>
				<cfset modifiedID = xmlNodeArray[modID].XmlAttributes.mod_id>
								
				<!--- SEE IF ANY RECORDS EXIST IN THE DB TABLE THAT HAVE THE SAME MODIFIED ID --->
				<cfquery name="chkRecords" datasource="#this.dsn#">
					SELECT *
					FROM AuditTrail_#arguments.logType#
					WHERE AuditTrail_Mod_ID = #modifiedID#
				</cfquery>				
				
				<!--- IF NO RECORDS EXIST WITH THE MODIFIED ID, CREATE THE RECORD IN THE DB --->
				<cfif NOT chkRecords.recordcount>
								
				<!--- LOOPS THROUGH A COUNT OF HOW MANY RECORDS TO ADD --->
				<cfloop from="1" to="#dataRowListCnt#" index="x">
				<cfset rowInsertList = evaluate('dataList#x#')>
								
					
						<cfquery datasource="#this.dsn#">
							INSERT INTO AuditTrail_#arguments.logType#
							(
								AuditTrail_Mod_By
								,AuditTrail_Mod_Date
								,AuditTrail_Mod_ID
								,#fieldNameList#
							)
							VALUES
							(
								<cfqueryparam value="#modifiedBy#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#dateModified#" cfsqltype="cf_sql_timestamp">
								,<cfqueryparam value="#modifiedID#" cfsqltype="cf_sql_numeric">
								<cfset row = 0>
								<cfloop list="#rowInsertList#" index="dataValue" delimiters="|">
									<cfset row = row + 1>
									<cfif dataValue EQ "">
										<cfset dataEntry = " ">
									<cfelse>
										<cfset dataEntry = dataValue>
									</cfif>
									<cfset dataType = listGetAt(fieldDataTypeList,row)>
									<cfif  dataEntry EQ " " and dataType EQ "boolean">
										<cfset dataEntry = 0>
									</cfif>
								,
									<cfswitch expression="#datatype#">
										<cfcase value="string,null"><cfqueryparam value="#dataEntry#" cfsqltype="cf_sql_varchar"></cfcase>
										<cfcase value="boolean"><cfqueryparam value="#dataEntry#" cfsqltype="cf_sql_bit"></cfcase>
										<cfcase value="number"><cfqueryparam value="#dataEntry#" cfsqltype="cf_sql_numeric"></cfcase>
										<cfcase value="datetime">
											<cfscript>
												if(len(dataEntry) GT 1) {
													dataEntry = replace(dataEntry,"T"," ","ALL");
													dataEntry = removechars(dataEntry,len(dataEntry)-3,4);
													dataEntry = createODBCDateTime(dataEntry);
												}
											</cfscript>
											<cfqueryparam value="#dataEntry#" cfsqltype="cf_sql_date">
										</cfcase>
									</cfswitch>
								</cfloop>
							)
						</cfquery>
					</cfloop>
				</cfif>
			</cfloop>
			
			<!--- RETURN A MESSAGE TO THE FUNCTION CALL --->
			<cfset message = "Data entry was successful for '#arguments.logType#'.">
			
		<cfelse>
		
			<!--- RETURN A MESSAGE TO THE FUNCTION CALL --->
			<cfset message = "Data entry was not processed for '#arguments.logType#', no changes have been made.">
			
		</cfif>
		
		
		<cfreturn message>

	</cffunction>
	
<!--- XML FILE LOG GENERATOR --->	
	<cffunction name="createXMLlog" 
					access="public" 
					returntype="void" 
					output="false" 
					displayname="Log Generator" 
					hint="Creates log of settings changes">

		<cfargument name="tableName" required="true" type="string" hint="Table for query">
		<cfargument name="colType" required="true" type="numeric" hint="1 (users [all types]), 2 (All cols), 3 (pgm tmp)">
		<cfargument name="recordID" required="false" type="string" hint="ID Used to pull information from the database">
		
		<cfif listLen(tableColumns(colType)) GT 1>
			<cfset selectClause = listDeleteAt(tableColumns(colType),1)>
		<cfelse>
			<cfset selectClause = tableColumns(colType)>
		</cfif>
		
		<CFQUERY NAME="getRecord" datasource="#this.dsn#">
			SELECT #selectClause#
			FROM #tableName#
			<cfif isDefined("arguments.recordID")>
				WHERE #listFirst(tableColumns(colType),",")# = '#recordID#'
			</cfif>
		</CFQUERY>
		
		<cfscript>
			// CREATE A STRUCTURE OF THE QUERY/QUERIES THAT WILL BE ADDED TO A WDDX PACKET FOR THE XML FILE
			qStruct = structNew();
			structInsert(qStruct,tableName,getRecord,true);
			
			// GENERATE XML FILE
			XMLProccessor(qStruct,tableName);
		</cfscript>
		
	</cffunction>
	
</cfcomponent>