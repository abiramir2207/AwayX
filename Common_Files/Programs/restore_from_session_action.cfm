<cfset useLakebaseForGetFileLocation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_variable_storage")>
<cfif useLakebaseForGetFileLocation>
	<cftry>
		<cfset getFileLocation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("session_variable_storage", { "session_variable_storage_id" = "eq.#FORM.RecordToRestore#" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFileLocation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFileLocation>
	<cfquery name="getFileLocation" datasource="#application.datasource#">
		SELECT *
		FROM Session_Variable_Storage
		WHERE Session_Variable_Storage_ID = '#FORM.RecordToRestore#'
	</cfquery>
</cfif>

<CFSET LISTOFSESSIONKEYSTOIGNORE = "CFID,CFTOKEN,SESSIONID,URLTOKEN">

<CFIF getFileLocation.Recordcount GT 0>
	<CFIF FileExists(getFileLocation.WDDXPacket_File_Location)>
		<cffile action="READ" file="#getFileLocation.WDDXPacket_File_Location#" variable="WDDXPacketString">
		<cfwddx action="WDDX2CFML" input="#WDDXPacketString#" output="RestoredSessionStructure">
		<!--- <cfdump var="#RestoredSessionStructure#"> --->

		<cfloop index="CurrentKey" list="#structkeylist(RestoredSessionStructure)#">

			<!--- if one of the restored keys is not to be ignored --->
			<cfif listfindnocase(LISTOFSESSIONKEYSTOIGNORE, CurrentKey) EQ 0>
				<cfif StructKeyExists(SESSION, CurrentKey)>
					<CFSET temp = StructDelete(SESSION, CurrentKey)>
				</cfif>
				<cfset tempStructure="#evaluate("RestoredSessionStructure.#CurrentKey#")#">
				<cfset tempName = CurrentKey>
				<CFSET #currentkey# = StructNew()>
				<CFSET temp = StructInsert(Session,tempName,#currentkey#)>
				<CFSET temp = StructAppend(evaluate("Session.#tempName#"), tempStructure)>
			</cfif>
		</CFLOOP>
	</CFIF>
</CFIF>
<!--- <cfdump var="#RestoredSessionStructure#"> --->


<script>
	if(window.opener != null){
		window.opener.history.go(0);
	}
	
	window.close();


function getAttributesWindow(title, debugObject) {
	/* lists all the attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<' + 'SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">\n');
	msgWindow.document.write('function stopError() {return true}\n');
	msgWindow.document.write('window.onerror = stopError;\n');
	msgWindow.document.write('<' + '/SCRIPT>\n');
	msgWindow.document.write('&lt;' + title + '&gt;\n<OL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			var strValueString = '"' + valueString + '"';
			msgWindow.document.write('\t<LI CLASS="OITEM">' + strValueString + ' <b>[' + i + ']</b><OL TYPE="a">\n');
			if(strValueString!='"null"') {
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(typeof(valueString2) == 'string') {
						// var ltRE = new RegExp(String.fromCharCode(60), "g");
						// if(valueString2.match(ltRE)) {valueString2 = valueString2.replace(ltRE, "&lt;");}
						// var gtRE = new RegExp(String.fromCharCode(62), "g");
						// if(valueString2.match(gtRE)) {valueString2 = valueString2.replace(gtRE, "&gt;");}
						// }
					// msgWindow.document.write('\t\t<LI CLASS="OITEM">"' + valueString2 + '" <b>' + i + '.' + j + '</b></LI>\n');
					// }
				}
			msgWindow.document.write('</OL></LI>\n');
			}
		else {
			if(typeof(valueString) == 'string') {
				var ltRE = new RegExp(String.fromCharCode(60), "g");
				if(valueString.match(ltRE)) {valueString = valueString.replace(ltRE, "&lt;");}
				var gtRE = new RegExp(String.fromCharCode(62), "g");
				if(valueString.match(gtRE)) {valueString = valueString.replace(gtRE, "&gt;");}
				}
			msgWindow.document.write('\t<LI CLASS="OITEM">"' + valueString + '" <b>' + i + '</b></LI>\n');
			}
		}
	msgWindow.document.write('</OL>\n');
	}	
</script>