<!---
FILE: 		BA Application - Model: General Functions Component
FILEname:   General_Functions.cfc
CREATED:  	8/14/2008 - Brad Lee MMCP/ACI
EDITED:   	8/14/2008 - Brad Lee MMCP/ACI

FUNCTIONALITY:
- I manage general functions. --->

<!--- COLDFUSION COMPONENT: General Functions Manager --->
<cfcomponent displayname="GeneralFunctionsManager" hint="I manage general functions.">

  <cfproperty name="LabelTET" 	type="string"/>
  <cffunction name="GenerateKey" access="public" output="True" hint="Generates a random hash key.">

	<cfset startString = Session.SessionID />
	<cfif isDefined("request.AccessStructure")>
		<cfif Trim(request.AccessStructure.User_ID) NEQ "">
			<cfset startString = request.AccessStructure.User_ID />
		</cfif>
	</cfif>

	<!--- Was: hash(startString) fed through an evaluate()-based numeric
	      transform to derive "key" -- evaluate() on a dynamically-built
	      numeric string is fragile across CF engine versions (broke here as
	      a ClassCastException, Integer vs UDFMethod, on CF2021). Same
	      contract (a random-ish hash key tied to the session/user), computed
	      directly without evaluate(). --->
	<CFSET key=hash(startString & CreateUUID() & now())>
 	<cfreturn key/>
  </cffunction>

  <cffunction name="Get_Application_Path" access="public" output="True" hint="Gets the application local path.">
    <cfargument name="webrootFolderName" type="string" default="AwayX" required="false">
    <cfscript>
		    	return expandpath("/");
		</cfscript>
  </cffunction>

  <cffunction name="Get_Document_Path" access="public" output="True" hint="Gets the documents path.">
	<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="Doc_Path">

	<cfset Doc_Path = Doc_Path.getDocumentPath()>

	<cfreturn Doc_Path/>
  </cffunction>

     <cffunction name="Get_Document_Mapping" access="public" output="True" hint="Gets the documents Mapping.">
	<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="Doc_Mapping">

	<cfset Doc_Mapping = Doc_Mapping.getDocumentMapping()>

	<cfreturn Doc_Mapping/>
  </cffunction>

  <cffunction name="Get_Fax_Email_Address" access="public" output="True" HINT="Converts to AwayX Fax by Email from address">
  	<cfargument name="Source_Fax_Numbers" type="string" required="true" default="">
	<cfargument name="Name_First" type="string" required="true" default="">
	<cfargument name="Name_Last" type="string" required="true" default="">

	<CFSET Fax_Numbers_List="">
	<CFSET Append_String = "~FR=" & trim(Arguments.Name_First) & "_" & trim(Arguments.Name_Last) & "@Faxmail.com">
	<CFLOOP INDEX="Item" LIST="#Arguments.Source_Fax_Numbers#" DELIMITERS=";">
		<CFSET Item = Trim(item) & Append_String>
		<CFSET Fax_Numbers_List = ListAppend(Fax_Numbers_List, Item, ";")>
	</CFLOOP>

	<cfreturn Fax_Numbers_List>

  </cffunction>

  <cffunction name="replaceHyphen" output="false" hint="Function will take a string with hyphens and replace them with underscores.">

  	<cfargument name="stringToReplace" type="string" required="true" default="" hint="String that will contain the hyphens.">

		<cfset arguments.stringToReplace = Replace(arguments.stringToReplace, "-", "_", "ALL") />

	<cfreturn arguments.stringToReplace />

  </cffunction>

  <cffunction name="Build_Url_String" output="false" hint="Builds URL string out of existing url object.">
  	<cfargument name="Exclude_List" type="string" required="false" default="udf,log" hint="Any values to be excluded">
    <cfargument name="Add_QuestionMark" type="numeric" required="false" default="1" hint="Whether to dd question mark in the front">

		<CFSET URL_STRING = "">
        <CFLOOP COLLECTION="#URL#" ITEM="This_URL">
			<CFIF NOT ListFindNoCase(Exclude_List, This_URL, ",") and listLen(This_URL," ") eq 1 >
				<CFSET URL_STRING = ListAppend(URL_STRING, "#This_URL#=#Evaluate("URL.#This_URL#")#", "&")>
			</CFIF>
		</CFLOOP>
		<CFIF Len(Trim(URL_STRING)) GT 0 AND Arguments.Add_QuestionMark EQ 1>
			<CFSET URL_STRING = "?#URL_STRING#">
		</CFIF>
	<cfreturn URL_STRING />
  </cffunction>

  <cffunction name="convertToAbsolutePath" output="false" returntype="string">
  		<cfargument name="relativeFilePath" type="string" required="true" default="" />

		<cfset arguments.relativeFilePath 	= REReplaceNoCase(arguments.relativeFilePath, "\\$", "")>
		<cfset arguments.relativeFilePath 	= REReplaceNoCase(arguments.relativeFilePath, "^\\", "")>
		<cfset applicationPath 				= this.Get_Application_Path()>
		<cfset completeAbsPath 				= applicationPath & "\" &  arguments.relativeFilePath>

		<cfreturn completeAbsPath>
  </cffunction>

  <cffunction name="getWddxDataFromFile" output="false" returntype="struct">
		<cfargument name="relativeFilePath" type="string" required="true" default="" />

		<cfset wddxFileStruct = StructNew()>

		<!--- <cfset fileLocation = this.convertToAbsolutePath(arguments.relativeFilePath)> --->
		<cfset fileLocation = request.app_general_functions.Get_Document_Path()>
		<cfset fileLocation		= fileLocation&"\"&relativeFilePath>
		<!---read data in from file and set the values before modifying the data structure--->
		<cfif fileExists(fileLocation)>
			<cffile
				action="read"
				file="#fileLocation#"
				variable="fileData">
			<cfwddx action="wddx2cfml" input="#fileData#" output="wddxFileStruct" />
		</cfif>

		<cfreturn wddxFileStruct/>
	</cffunction>

	<cffunction name="writeWddxDataToFile" output="true" returntype="struct">
		<cfargument name="wddxFileStruct" type="struct" required="true" default="" />
		<cfargument name="relativeFilePath" type="string" required="true" default="" />

		<!--- <cfset fileLocation = this.convertToAbsolutePath(arguments.relativeFilePath)> --->
		<cfset fileLocation = request.app_general_functions.Get_Document_Path()>
		<cfset fileLocation		= fileLocation&"\"&relativeFilePath>
		<!---dump data into wddx and pump it out to a file--->
		<cfwddx action="cfml2wddx" input="#arguments.wddxFileStruct#" output="wddxPacket">

		<cffile
			action="write"
			file="#Application.Doc_Path#\#relativeFilePath#"
			output="#wddxPacket#"
			addnewline="no">

		<cfreturn arguments.wddxFileStruct />
	</cffunction>

	<cffunction name="getUOMDesc" output="true" returntype="string">
		<cfargument name="uomId" type="numeric" required="true" default="" />
		<cfargument name="longDesc" type="numeric" required="false" default="1" />

		<cfset uomDesc = "">

		<cfset useLakebaseForgetUOMDesc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForgetUOMDesc>
	<cftry>
		<cfset getUOMDesc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "eq.#arguments.uomId#",
				"select" = "unit_of_measure_desc,abbreviation"
			}), "unit_of_measure_desc,abbreviation"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUOMDesc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUOMDesc>
<cfquery name="getUOMDesc" datasource="#application.datasource#">
			SELECT	Unit_Of_Measure_Desc, Abbreviation
			FROM	Units_of_Measure
			WHERE
					Unit_Of_Measure_ID = #arguments.uomId#
		</cfquery>
</cfif>
		<cfif getUOMDesc.recordCount GT 0>
			<cfif arguments.longDesc>
				<cfset uomDesc = getUOMDesc.Unit_Of_Measure_Desc>
			<cfelse>
				<cfset uomDesc = getUOMDesc.Abbreviation>
			</cfif>
		</cfif>

		<cfreturn uomDesc />
	</cffunction>

	<cffunction name="cleanEmailAddress" output="true" returntype="string">
		<cfargument name="EmailList" type="string" required="true" default="" />
		<cfset ReturnEmail = "">

		<cfloop index="thisEmail" list="#arguments.EmailList#" delimiters=";">
			<cfif checkEmail(thisEmail)>
				<cfset ReturnEmail = ListAppend(ReturnEmail, thisEmail, ";")>
			</cfif>
		</cfloop>

		<cfreturn ReturnEmail />
	</cffunction>

	<cffunction name="checkEmail" output="true" returntype="string">
		<cfargument name="EmailAddress" type="string" required="true" default="" />
		<cfset ReturnValue = false>

		<cfif REFindNoCase("^[\w']+([\.-]?[\w']+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$", arguments.EmailAddress) GT 0>
			<cfset ReturnValue = true>
		</cfif>

		<cfreturn ReturnValue />
	</cffunction>

	<cffunction name="roundDecimalPlaces" output="true" returntype="numeric">

		<cfargument name="iVal" type="numeric" required="true" />
		<cfargument name="decimalLen" type="numeric" required="false" default="2" />

		<cfset returnValue = arguments.iVal>

		<cfset divVal = 1 />
		<cfloop index="i" from="1" to="#arguments.decimalLen#">
			<cfset divVal = divVal * 10 />
		</cfloop>
		<cfset returnValue = returnValue * divVal />
		<cfset returnValue = Round(returnValue) />
		<cfset returnValue = returnValue / divVal />

		<cfreturn returnValue />

	</cffunction>
	<cffunction name="getBBToTET" output="true" returntype="numeric">
		<cfset useLakebaseForgetBBToTET = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForgetBBToTET>
	<cftry>
		<cfset getBBToTET = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"limit" = "1",
				"select" = "bb_tolerance_tet"
			}), "bb_tolerance_tet"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBBToTET = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBBToTET>
<cfquery name="getBBToTET" datasource="#application.datasource#">
			select top 1 BB_Tolerance_TET
			from Billback_Settings
		</cfquery>
</cfif>
		<cfreturn getBBToTET.BB_Tolerance_TET>
	</cffunction>
	<cffunction name="getBBToTETLabel" output="true" returntype="string">
		<cfquery name="getBBToTET" datasource="#application.datasource#">
			select top 1 BB_Tolerance_TET
			from Billback_Settings
		</cfquery>
		<cfset this.LabelTET = "Invoice Date">
		<cfif getBBToTET.BB_Tolerance_TET EQ 2>
			<cfset this.LabelTET = "Ship Date">
		</cfif>
		<cfreturn this.LabelTET>
	</cffunction>

	<!------ Find whether the directory and file exists ----->
	<cffunction name="checkDirectoryAndFile" output="true" returntype="string">

		<cfargument name="dirRelativePath" required="true" type="string" hint="like components\programs\business_segment">
		<cfargument name="fileName" required="true" type="string">

		<cfset fileExists = false />

		<!---check whether the directory exists or not--->
		<cfset theDir = "#request.app_general_functions.get_Application_Path()#\#arguments.dirRelativePath#\" />
		<cfif DirectoryExists(theDir)>
			<!---if the directory exists then check the file--->
			<cfset theFile = "#theDir##arguments.fileName#" />
			<!---it the file exists then we can create the component--->
			<cfif FileExists(theFile)>
				<cfset fileExists = true />
			</cfif>
		</cfif>

		<cfreturn fileExists />

	</cffunction>

	<!------ Returns a list of months ----->
	<cffunction name="getMonths" output="false" hint="Function will return a list of months.">

		<cfargument name="getBy" required="true" default="1" hint="1 - Default get all, 2 - by quarter" />

		<cfif arguments.getBy eq 2>

			<cfset this.months = "January,April,July,October" />

		<cfelse>

			<cfset this.months = "January,February,March,April,May,June,July,August,September,October,November,December" />

		</cfif>

		<cfreturn this.months />

	</cffunction>

	<!------ Returns a list of years ----->
	<cffunction name="getYears" output="false" hint="Function will return a list of the number of years passed to it starting at the goBack parameter.">

		<cfargument name="numberOfYears" required="true" default="10" hint="The number of years to return." />
		<cfargument name="goBack" required="true" default="5" hint="Prior year to start at based on the current year." />

		<cfset rYear = "" />

		<cfset startYear = DateAdd("yyyy", -arguments.goBack, now())  />

		<cfset tmpStartYear = Year(startYear) />
		<cfset rYear = ListAppend(rYear, tmpStartYear) />

		<cfloop index="yearIndx" from="1" to="#arguments.numberOfYears#">
			<cfset incrementYear = DateAdd("yyyy", yearIndx, startYear) />
			<cfset incrementYear = Year(incrementYear) />
			<cfset rYear = ListAppend(rYear, incrementYear) />
		</cfloop>

		<cfreturn rYear />

	</cffunction>

	<cffunction name="specialDateAdd" output="false" returntype="string">

		<cfargument name="datePart" type="string" required="true" />
		<cfargument name="number" type="numeric" required="true" />
		<cfargument name="dDate" type="date" required="true" />

		<cfset dDate = arguments.dDate />
		<cfif IsLeapYear(Year(dDate)) AND Month(dDate) EQ 12 AND Day(dDate) EQ 31 AND arguments.datePart EQ "yyyy" AND arguments.number EQ -1>
			<cfreturn DateAdd(arguments.datePart, arguments.number, DateAdd("d", -1, dDate))>
		<cfelse>
			<cfreturn DateAdd(arguments.datePart, arguments.number, dDate)>
		</cfif>

	</cffunction>

    <!--- METHOD: getUniqueList [begin] --->
	<cffunction name="getUniqueList" access="public" returntype="string" output="false">
		<!--- legacy <cfargument name="sList" type="string" required="true"  />
		<cfset var listStruct = StructNew() />
		<cfloop from="1" to="#ListLen(arguments.sList)#" index="i">
		   <cfset listStruct[ListGetAt(arguments.sList, i)]="">
		</cfloop>
		<cfreturn StructKeyList(listStruct) /> legacy --->

        <!--- Brad D16586 [begin] --->
        <cfargument name="sList" 		type="string" required="true" />
        <cfargument name="delimiter" 	type="string" required="false" default="," />

        <cfset var var_lsInitialList 	= trim(arguments.sList)>
        <cfset var var_currentListItem 	= ''>
        <cfset var var_stList 			= structNew()>
        <cfset var var_lsUniqueList 	= ''>

        <cfloop list="#var_lsInitialList#" index="var_currentListItem" delimiters="#arguments.delimiter#">
            <cfset structInsert(var_stList,var_currentListItem,'',true)>
        </cfloop>

        <cfset var_lsUniqueList = structKeyList(var_stList)>

        <cfreturn var_lsUniqueList>
        <!--- Brad D16586 [end] --->

        <!--- TEST [begin] <cfset variables.lsInitialList = "12345,67890,12345">
		<cfset variables.delimiter = ",">
        <cfset variables.stList = structNew()>
        <cfset variables.lsUniqueList = "">
        <cfloop list="#variables.lsInitialList#" index="currentListItem" delimiters="#variables.delimiter#">
            <cfset structInsert(variables.stList,currentListItem,'',true)>
        </cfloop>
        <cfset variables.lsUniqueList = structKeyList(variables.stList)>
        <cfdump var="#variables.lsUniqueList#"> TEST [end] --->

	</cffunction>
    <!--- METHOD: getUniqueList [end] --->

	<cffunction name="NumericRoundDecimal" output="false" returntype="string">
		<cfargument name="iValue" type="numeric" required="true" />
		<cfargument name="iDecimalLen" type="numeric" required="true" />
		<cfset var divVal = 10 ^ arguments.iDecimalLen />
		<cfset var newAmount = arguments.iValue />
		<cfset newAmount = newAmount * divVal />
		<cfset newAmount = Round(val(newAmount)) />
		<cfset newAmount = newAmount / divVal />
		<cfreturn newAmount />
	</cffunction>

	<cfscript>
		string function getBrowserVersion( HTTPuserAgent = cgi.http_user_agent ) output="false" {
			if ( arguments.HTTPuserAgent.findNoCase( "Edg" ) )
				return "Edge";

			if ( arguments.HTTPuserAgent.findNoCase( "Chrome" ) )
				return "Chrome";

			if ( arguments.HTTPuserAgent.findNoCase( "Firefox" ) )
				return "Firefox";

			if ( arguments.HTTPuserAgent.findNoCase( "Safari" ) )
				return "Safari";

			if ( arguments.HTTPuserAgent.findNoCase( "trident/7" ) )
				return "IE 11";

			if ( arguments.HTTPuserAgent.findNoCase( "MSIE 10" ) or ( arguments.HTTPuserAgent.findNoCase( "MSIE 7" ) and arguments.HTTPuserAgent.findNoCase( "trident/6" ) ) )
				return "IE 10";

			if ( arguments.HTTPuserAgent.findNoCase( "MSIE 9" ) or ( arguments.HTTPuserAgent.findNoCase( "MSIE 7" ) and arguments.HTTPuserAgent.findNoCase( "trident/5" ) ) )
				return "IE 9";

			if ( arguments.HTTPuserAgent.findNoCase( "MSIE 8" ) or ( arguments.HTTPuserAgent.findNoCase( "MSIE 7" ) and arguments.HTTPuserAgent.findNoCase( "trident/4" ) ) )
				return "IE 8";

			if ( arguments.HTTPuserAgent.findNoCase( "MSIE 7" ) )
				return "IE 7";

			return "";
		}
	</cfscript>

      <cffunction name="getOperatingSystem" returntype="String">
		<cfargument name="HTTPuserAgent" type="string" default="#HTTP_USER_AGENT#">

		<cfset var operatingSystem = "">

		<cfif FindNoCase('Windows NT 10.0', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "Win 10">
		<cfelseif FindNoCase('Windows NT 6.2', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "Win 8">
		<cfelseif FindNoCase('Windows NT 6.1', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "Win 7">
		<cfelseif FindNoCase('Windows XP', arguments.HTTPuserAgent ) neq 0 OR FindNoCase('Windows NT 5.1', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "Win XP">
		<cfelseif FindNoCase('Mac_PowerPC', arguments.HTTPuserAgent ) neq 0 OR FindNoCase('Macintosh', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "Mac">
		<cfelseif FindNoCase('iPhone', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "iPhone">
		<cfelseif FindNoCase('Android', arguments.HTTPuserAgent ) neq 0>
			<cfset operatingSystem = "Android">
		<cfelse>
			<cfset operatingSystem = "Unknown">
		</cfif>

		<cfreturn operatingSystem>
      </cffunction>

	<cffunction name="spreadsheetAddRowsForceTextFormat">
		<!--- Excel (sheet object) --->
		<cfargument name="spreadsheetObject" required="yes">
		<!--- Query data--->
		<cfargument name="data" required="yes">
		<!--- array of "column numbers" which need to be converted to Text format--->
		<cfargument name="columnNumbersToFormatAsText" type="array" required="yes">
		<!--- Whether header needs to be added or not. The query columns
		are used as a header.
		--->
		<cfargument name="addHeaderRow" default="true" type="boolean">

	<cfscript>
	local.columns = arguments.data.getMetaData().getColumnLabels();
	if( arguments.addHeaderRow )
	{
		// Get a list of the query column names in the order they appear, as opposed to the alphabetical columnList
		local.listColumnHeaders	=	ArrayToList( local.columns );
		SpreadSheetAddRow( arguments.spreadsheetObject,local.listColumnHeaders );
	}
	// Add the data: the numbers will be inserted as numeric for now
	SpreadSheetAddRows( arguments.spreadsheetObject,arguments.data );

	for(i=1; i LTE Arraylen(arguments.columnNumbersToFormatAsText); i=i+1)
	{
		// Now we format the column as text
			SpreadSheetFormatColumn( arguments.spreadsheetObject,{ dataformat="text" },arguments.columnNumbersToFormatAsText[i]);
			// Having formatted the column, add the column from our query again so the values correct
			while( arguments.data.next() )
			{
				local.rownumber	=	arguments.data.currentrow;
				if( arguments.addHeaderRow )
					local.rownumber++; // start one row below to allow for header
				// Get the value of column at the current row in the loop
				local.value	=	arguments.data[ local.columns[ arguments.columnNumbersToFormatAsText[i] ] ][ arguments.data.currentrow ];
				// replace the previously added numeric value which will now be treated as text
				SpreadsheetSetCellValue( arguments.spreadsheetObject,local.value,local.rownumber,arguments.columnNumbersToFormatAsText[i] );
			}
	}
	</cfscript>

	<cfreturn arguments.spreadsheetObject>
	</cffunction>

	<cffunction name="listRemoveDupes" output="false" returntype="string">
		<cfargument name="inList" type="string">
		<cfargument name="delim" type="string">

		<cfscript>
		var listStruct = {};
		var i = 1;

		for(i=1;i<=listlen(inList, delim);i++)
		{
			listStruct[listgetat(inList,i)] = listgetat(inList,i);
		}
		</cfscript>

		<cfreturn structkeylist(listStruct)>
	</cffunction>

</cfcomponent>