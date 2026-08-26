<!------------------------------------------------------------------------------
NAME:           GetNewsFeed
FILE:           GetNewsFeed.cfc
CREATED:	 01/09/2003
MODIFIED:	 01/09/2003
VERSION:	 1.0

AUTHOR:         Ian Mitchell (mitcheli@aftermagic.com)
                Header comments skanked in a nasty manner from Macromedia's web site

DESCRIPTION:    This CFC uses CFHTTP to retrieve an XML news feed from
                any RSS or RDF standard newsfeed.  The XML file is then parsed into
                a CF query object.                  

ARGUMENTS:      url:       URL of the newsfeed to grab
                type:      RDF or RSS
                           RDF handles RDF 1.0 standard news feeds
                           RSS handls RSS 0.91 standard news feeds
                           Both formats are locatable on Netscapes website.

RETURNS:        Returns False if any errors occur, otherwise a query with the 
		following structure is returned:
			title	
				string containing the title of an article
			description
				string containing the description of an article
			link
				URL to the article
				
COPYRIGHT:	 Copyright (C) 2003 by Ian Mitchell, All Rights Reserved
        	 This program is free software; you can redistribute it
        	 and/or modify it under the terms of the GNU General Public
        	 License as published by the Free Software Foundation;
        	 either version 2 of the License, or any later version.
               
                This program is distributed in the hope that it will be
        	 useful, but WITHOUT ANY WARRANTY; without even the implied
        	 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
        	 PURPOSE.  See the GNU General Public License for more details.
        				
                You should have received a copy of the GNU General Public
        	 License along with this program; if not, write to the Free
        	 Software Foundation, Inc., 59 Temple Place - Suite 330,
        	 Boston, MA  02111-1307, USA.

KNOWN ISSUES:   You should first test the query returned with an IsQuery in
		case an error is returned.
		
------------------------------------------------------------------------------->

<!---BJF: There are two cfcs with this name, that are mostly identical. It appears that this is the one which is used. --->

<cfcomponent>	
  <cffunction name="GetHeadlines" access="public" output="True">

    <cfargument name="url" type="string" required="true"/>
    <cfargument name="type" type="string" required="true"/>
	<cfargument name="url_type" type="string" required="false" default="file"/>

	<CFSET articles = QueryNew("title, link, description")>
	
<cfif arguments.url_type EQ "file">
	<cfset arguments.url=Replace(arguments.url, "/", "\", "ALL")>
	<cfset file_complete_path =
	 "#Application.Doc_path#\data_files\created\news_ticker\#arguments.url#">
	<cfif NOT FileExists(file_complete_path)>
		<cfhttp URL="http://#CGI.HTTP_HOST#/news_ticker/News_Files/Get_News/get_news_feeds.cfm">		
	</cfif>
	<cfif NOT FileExists(file_complete_path)>
		<cfreturn articles/>
	</cfif>
	<cffile action = "read"
  			file = "#file_complete_path#"
  			variable = "New_File_Content"> 
<cfelse>
  	<cfhttp url="#arguments.url#"/>
  	<cfset New_File_Content=cfhttp.filecontent>
</cfif>
	
	<cftry>
		<!---- check for RSS --->
		<CFSET selectedElements = XmlSearch(xmlparse(New_File_Content), "/rss/channel/item")>
		<CFIF ArrayLen(selectedElements) LTE 0>
			<!---- check for RDF --->
			<CFSET selectedElements = XmlSearch(xmlparse(New_File_Content), "/rdf:RDF/:item")>
		</CFIF>
		<cfcatch>
			 <cfreturn articles/>
		</cfcatch>
	</cftry>
	<CFSET index=1>
	<CFLOOP CONDITION="index LTE ArrayLen(selectedElements)">		
		<cftry>
			<CFSET title= "#selectedElements[index].title.XmlText#">
			<CFSET link=selectedElements[index].link.XmlText>
			<CFSET description=selectedElements[index].description.XmlText>
			<CFSET drk = QueryAddRow(articles)>
			<CFSET drk = QuerySetCell(articles,"title", title)>
			<CFSET drk = QuerySetCell(articles,"link", link)>		
			<CFSET drk = QuerySetCell(articles,"description", description)>		
			
			<cfcatch>			
			</cfcatch>
		</cftry>
		<CFSET index=index+1>
	</CFLOOP>

    <cfreturn articles/>
    
  </cffunction>
</cfcomponent>
