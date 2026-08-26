
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the primary code that will be used in the application to retrieve the correct help file    
when the user clicks the get help here link and/or button											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- FIRST - Retrieve the XML file from disk.--->

<cfset FilePath = getdirectoryfrompath(CF_TEMPLATE_PATH)>

<cffile action="read" file="#FilePath#helprelations.xml" variable="myxml">

<cfset mydoc = XmlParse(myxml)>

<!--- SECOND - Get an array of relationships --->
<cfset doc1 = mydoc.relations.XmlChildren>
<cfset size = ArrayLen(doc1)>

<!--- THIRD - Create a query object with the data --->
<cfset myquery = QueryNew("systemid, description,source_url,help_url,deleted") >
<cfset temp = QueryAddRow(myquery, #size#)>
<cfloop index="i" from = "1" to = #size#>
	<cfset temp = QuerySetCell(myquery, "systemid", #mydoc.relations.relationship[i].XmlAttributes.helpsystem_id#, #i#)>
	<cfset temp = QuerySetCell(myquery, "description", #mydoc.relations.relationship[i].XmlAttributes.functionality_description#, #i#)>
	<cfset temp = QuerySetCell(myquery, "source_url", #mydoc.relations.relationship[i].XmlAttributes.source_url#, #i#)>
	<cfset temp = QuerySetCell(myquery, "help_url", #mydoc.relations.relationship[i].XmlAttributes.help_url#, #i#)>
	<cfset temp = QuerySetCell(myquery, "deleted", #mydoc.relations.relationship[i].XmlAttributes.deleted#, #i#)>
</cfloop>

<!--- Select relationships with the appropriate criteria... --->
<cfquery name="HelpData" dbType="query">
	SELECT source_url,help_url
	FROM myquery 
	WHERE Lower(source_url) = '#LCase(url.help)#'
</cfquery>	

<cfinclude template="index.cfm">