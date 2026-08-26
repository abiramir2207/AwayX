<cfcomponent>	
  <cffunction name="GetHeadLineCount" access="public" output="True">

    <cfargument name="file_content" type="string" required="true"/>
	
	<cfset New_File_Content = arguments.file_content>

	<CFSET article_count = 0>	
	<cftry>
		<!---- check for RSS --->
		<CFSET selectedElements = XmlSearch(xmlparse(New_File_Content), "/rss/channel/item")>
		<CFIF ArrayLen(selectedElements) LTE 0>
			<!---- check for RDF --->
			<CFSET selectedElements = XmlSearch(xmlparse(New_File_Content), "/rdf:RDF/:item")>
		</CFIF>
		<cfcatch>
		
			 <cfreturn article_count/>			
		</cfcatch>
	</cftry>
	
	<CFSET index=1>


	<CFLOOP CONDITION="index LTE ArrayLen(selectedElements)">		
		
		
		<cftry>
			<CFSET title= "#selectedElements[index].title.XmlText#">
			<CFSET link=selectedElements[index].link.XmlText>
			<CFSET description=selectedElements[index].description.XmlText>
			<CFSET article_count = article_count + 1>						
			<cfcatch>			
			</cfcatch>
		</cftry>

		<CFSET index=index+1>
	</CFLOOP>

    <cfreturn article_count/>    
  </cffunction>
</cfcomponent>
