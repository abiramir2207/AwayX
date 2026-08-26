<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Display news feeds</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/News_Ticker/Headlines/style.css">
	<BASE TARGET="_blank"/>
</HEAD>

<BODY>


<!--- If no specific feed is passed, default to ... --->
<CFPARAM NAME="url.title" DEFAULT="Food News">
<CFPARAM NAME="url.id" DEFAULT="http://www.topix.net/rss/business/food.xml">
<CFPARAM NAME="url.group" DEFAULT="Food Industry">
<CFPARAM NAME="url.local" DEFAULT="food_news.xml">

<cfset url.location = application.Doc_Path & "\Data_Files\Created\News_Ticker\News_Files\">

<!--- set how long (in minutes) to cache the newsfeed contents locally... --->
<cfset cacheMinutes = 120>

<!--- check if the required file exists in the local temp directory ... --->
<cfif FileExists("#url.location#\#url.local#")>


	<!--- since the file exists, we test how old the file is by comparing it to the cacheminutes variable --->
    <!--- but first lets get the age of the file ... --->
    <cfdirectory action="list" directory="#url.location#" filter="#url.local#" name="fileInfo">
    <cfset file_date = parseDateTime(fileInfo.dateLastModified)>
    
    <!--- we compare both date/time stamps and look for the difference in minutes --->
    <cfset file_age = dateDiff("n", file_date, now())>
    
    <!--- if the delta is great than the cacheminutes variable, get a fresh copy, save it locally and use it... --->
    <cfif file_age GTE cacheMinutes>
    
        <!--- go get the new copy ... and save it locally --->
		<cfhttp method = "Get" url="#url.id#" path="#url.location#" file="#url.local#">

		<!--- the age of this newsfeed: the newsfeed is as of this date --->
        <cfset refreshed_on	=	DateFormat(now(), "mm/dd/yyyy") & " - " & timeformat(now(), "h:m:ss tt")>

        <!--- display the title of the page --->
        <div class="section_title"><cfoutput>#url.group# :: #url.title#</cfoutput></div>

        <!--- read the contents of the local copy --->
        <cffeed action="read" source="#url.location#\#url.local#" query="entries" properties="info">
        
        <ul>

        <cfoutput query="entries">
        	<li class="toc news">
            <a href="#rsslink#">#title#</a><!--- <div class="news_date">#publisheddate#</div> --->
            </li>
		</cfoutput>		

        	<li style="list-style-type: none; padding-top:10px; color:#999999;"><cfoutput><div class="news_date">Last updated on #refreshed_on#</div></cfoutput></li>		

        </ul>

    <cfelse> 
    
    
        <!--- if it is not old, use what we have locally --->

		<!--- the age of this newsfeed: the newsfeed is as of this date --->
        <cfset refreshed_on	=	DateFormat(file_date, "mm/dd/yyyy") & " - " & timeformat(file_date, "h:m:ss tt")>

        <!--- display the title of the page --->
        <div class="section_title"><cfoutput>#url.group# :: #url.title#</cfoutput></div>

        <!--- read the contents of the local copy --->
        <cffeed action="read" source="#url.location#\#url.local#" query="entries" properties="info">
        
        <ul>
        
        <cfoutput query="entries">
        	<li class="toc news">
            <a href="#rsslink#">#title#</a><!--- <div class="news_date">#publisheddate#</div> --->
            </li>
		</cfoutput>

       	<li style="list-style-type: none; padding-top:10px; color:#999999;"><cfoutput><div class="news_date">Last updated on #refreshed_on#</div></cfoutput></li>		

        </ul>
        
        
        
    </cfif>

<cfelse>


<!--- if the file doesn't exist, we get it from the source and save a copy locally --->

	<!--- go get the new copy ... and save it locally --->
    <cfhttp method = "Get" url="#url.id#" path="#url.location#" file="#url.local#">

	<!--- the age of this newsfeed: the newsfeed is as of this date --->
        <cfset refreshed_on	=	DateFormat(now(), "mm/dd/yyyy") & " - " & timeformat(now(), "h:m:ss tt")>

    <!--- display the title of the page --->
    <div class="section_title"><cfoutput>#url.group# :: #url.title#</cfoutput></div>
    
    <!--- read the contents of the local copy --->
    <cffeed action="read" source="#url.location#\#url.local#" query="entries" properties="info">
        
        <ul>

        <cfoutput query="entries">
        	<li class="toc news">
            <a href="#rsslink#">#title#</a><!--- <div class="news_date">#publisheddate#</div> --->
            </li>
		</cfoutput>		

       	<li style="list-style-type: none; padding-top:10px; color:#999999;"><cfoutput><div class="news_date">Last updated on #refreshed_on#</div></cfoutput></li>		

        </ul>

</cfif>


</BODY>
</HTML>


