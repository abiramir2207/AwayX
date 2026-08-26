<CFSETTING ENABLECFOUTPUTONLY="YES">
<!---// set default attributes //--->
<CFPARAM NAME="Attributes_OUTPUT" DEFAULT="stcFormWizard">

<CFPARAM NAME="Attributes_KEY" DEFAULT="">
<CFPARAM NAME="Attributes_URL" DEFAULT="">
<CFPARAM NAME="Attributes_TITLE" DEFAULT="">
<CFPARAM NAME="Attributes_DEFAULTURL" DEFAULT="">
<CFPARAM NAME="Attributes_EXCLUDE" DEFAULT="">


<!---// make sure "ACTION" attributes is present //--->
<CFIF NOT IsDefined("Attributes_ACTION")>
	<CFOUTPUT><H3>Missing Attribute: ACTION</H3>
	<P>CF_FormWizardTools requires the attribute: <B>ACTION</B>. 
	Please specify this attribute before trying to use CF_FormWizardTools.</P></CFOUTPUT>
	<CFABORT>
</CFIF>

<!---// set default variables //--->
<CFSCRIPT>
// FormWizardTools configuration info
formWizardTools_Version = "1.1b";
formWizardTools_Registered = "YES";

// create a list of valid action statements
lstValidActions = "Serialize,Flatten,Create";

// decide which action is to be used, then get the list of required attributes
if( ListFindNoCase("serialize,flatten", Attributes_ACTION) GT 0 ){
	lstRequiredAttribs = "WDDXPACKET";
} else {
	lstRequiredAttribs = "INPUT";
}
</CFSCRIPT>

<!---// make sure required attributes for the requested ACTION are present //--->
<CFLOOP INDEX="attrib" LIST="#lstRequiredAttribs#">
	<CFIF NOT IsDefined("Attributes_#attrib#")>
		<CFOUTPUT><H3>Missing Attribute: #attrib#</H3>
		<P>CF_FormWizardTools requires the attribute: <B>#attrib#</B>. 
		Please specify this attribute before trying to use CF_FormWizardTools.</P></CFOUTPUT>
		<CFABORT>
	</CFIF>
</CFLOOP>

<CFSWITCH EXPRESSION="#Lcase(Attributes_Action)#">
	<!---// if "serializing" a packet, convert the packet to CF and return the output //--->
	<CFCASE VALUE="serialize">
		<!---// serialize the WDDX packet //--->
		<CFWDDX ACTION="WDDX2CFML" INPUT="#Attributes_WDDXPACKET#" OUTPUT="stcWDDX">
		<!---// return the serialized WDDX packet //--->
		<CFSET SetVariable("Caller.#Attributes_OUTPUT#", stcWDDX)>
	</CFCASE>

	<!---// if "flattening" a packet, convert the packet to CF, loop through each form's 
	        content, grabbing the unique keys, and store them into a single structure //--->
	<CFCASE VALUE="flatten">
		<!---// serialize the WDDX packet //--->
		<CFWDDX ACTION="WDDX2CFML" INPUT="#Attributes_WDDXPACKET#" OUTPUT="stcWDDX">
		<CFSET stcFlatten = StructNew()>
		<CFLOOP INDEX="i" FROM="1" TO="#stcWDDX.TotalForms#">
			<CFSET stcTemp = stcWDDX["Form#i#"].Form>
			<CFLOOP ITEM="thisKey" COLLECTION="#stcTemp#">
				<CFSET stcFlatten[thisKey] = stcTemp[thisKey]>
			</CFLOOP>
		</CFLOOP>
	
		<!---// return the flatten WDDX packet //--->
		<CFSET SetVariable("Caller.#Attributes_OUTPUT#", stcFlatten)>
	</CFCASE>

	<!---// if "creating" a packet, decided whether the packet is a query or a structure. 
	        if it's a query, then you need to create the a fully qualified multi-node 
					form tree. if it's structure, then only the current tree will be returned //--->
	<CFCASE VALUE="create">
		<!---// create a pointer to the object being used //--->
		<CFSET objTemp = Attributes_INPUT>
		<!---// create a new structure to store the tree in //--->
		<CFSET stcFormTree = StructNew()>

		<!---// if the object is a query, loop through each row creating a branch in the tree //--->
		<CFIF IsQuery(objTemp)>
			<!---// get the total number of forms which will be created //--->
			<CFSET stcFormTree.TotalForms = objTemp.RecordCount>
			<!---// get the columns of the query--these will become the form's "keys" //--->
			<CFSET lstColumns = objTemp.ColumnList>

			<!---// if current KEY attribute is blank, then set it equal to Attribute.URL //--->
			<CFIF Len(Attributes_URL) EQ 0>
				<CFSET Attributes_URL = ListFirst(lstColumns)>
			</CFIF>

			<!---// if current KEY attribute is blank, then set it equal to Attribute.URL //--->
			<CFIF Len(Attributes_KEY) EQ 0>
				<CFSET Attributes_KEY = Attributes_URL>
			</CFIF>

			<!---// if current TITLE attribute is blank, then set it equal to Attribute.URL //--->
			<CFIF Len(Attributes_TITLE) EQ 0>
				<CFSET Attributes_TITLE = Attributes_URL>
			</CFIF>

			<CFLOOP QUERY="objTemp">
				<!---// initialize the current branch of the form tree and store it's values //--->
				<CFSET strFormName = "Form" & objTemp.CurrentRow>
				<CFSET stcFormTree[strFormName] = StructNew()>
				<CFSET stcFormTree[strFormName].KEY = Attributes_DEFAULTURL & objTemp[Attributes_KEY][CurrentRow]>
				<CFSET stcFormTree[strFormName].URL = Attributes_DEFAULTURL & objTemp[Attributes_URL][CurrentRow]>
				<CFSET stcFormTree[strFormName].TITLE = objTemp[Attributes_TITLE][CurrentRow]>
				<CFSET stcFormTree[strFormName].FORM = StructNew()>
				<CFLOOP INDEX="column" LIST="#lstColumns#">
					<CFIF ListFindNoCase(Attributes_EXCLUDE, column) EQ 0>
						<CFSET stcFormTree[strFormName].FORM[column] = objTemp[column][CurrentRow]>
					</CFIF>
				</CFLOOP>
			</CFLOOP>

		<!---// if the object is a structure, then grab all of it's keys and store them single level tree //--->
		<CFELSEIF IsStruct(objTemp)>
			<!---// if current URL attribute is blank, then set it equal to the current page's URL //--->
			<CFIF Len(Attributes_URL) EQ 0>
				<CFSET Attributes_URL = IIf(CGI.SERVER_PORT NEQ "443", DE("http://"), DE("https://")) & CGI.HTTP_HOST & CGI.SCRIPT_NAME & IIf(Len(CGI.QUERY_STRING) GT 0, DE("?"), DE("")) & CGI.QUERY_STRING>
			</CFIF>
			
			<!---// if current KEY attribute is blank, then set it equal to Attribute.URL //--->
			<CFIF Len(Attributes_KEY) EQ 0>
				<CFSET Attributes_KEY = Attributes_URL>
			</CFIF>
		
			<CFSET stcFormTree.TotalForms = 1>
			<CFSET stcFormTree.Form1 = StructNew()>
			<CFSET stcFormTree.Form1.KEY = Attributes_KEY>
			<CFSET stcFormTree.Form1.URL = Attributes_URL>
			<CFSET stcFormTree.Form1.TITLE = Attributes_TITLE>
			<CFSET stcFormTree.Form1.FORM = StructNew()>
			<CFLOOP ITEM="thisKey" COLLECTION="#objTemp#">
				<CFIF ListFindNoCase(Attributes_EXCLUDE, thisKey) EQ 0>
					<CFSET stcFormTree.Form1.FORM[thisKey] = objTemp[thisKey]>
				</CFIF>
			</CFLOOP>
		</CFIF>

		<!---// serialize the newly create packet //--->
		<CFWDDX ACTION="CFML2WDDX" INPUT="#stcFormTree#" OUTPUT="wddxPacket" USETIMEZONEINFO="Yes">
		<!---// return the new WDDX packet //--->
		<CFSET SetVariable("Caller.#Attributes_OUTPUT#", wddxPacket)>
	</CFCASE>

	<CFDEFAULTCASE>
		<CFOUTPUT><H3>Invalid Action: #Attributes_ACTION#</H3>
		<P>The ACTION you specified is invalid. Valid ACTIONs include: #lstValidActions#.
		Please provide a valid action and try your request again.</P></CFOUTPUT>
		<CFABORT>
	</CFDEFAULTCASE>
</CFSWITCH>

<CFSETTING ENABLECFOUTPUTONLY="NO">
