<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>News Feeds TOC</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/News_Ticker/Headlines/style.css">
</HEAD>


<BODY>


<cfquery name="get_news_feeds"  datasource="#application.datasource#">

SELECT				News_Feeds.News_Feeds_ID,
					News_Feeds.News_Feeds_Name,
                    News_Feeds_Groups.News_Feeds_Groups_Name,
                    News_Feeds.News_Feeds_URL,
                    News_Feeds.News_Feeds_Local_File

FROM				News_Feeds

INNER JOIN 			News_Feeds_Groups ON News_Feeds_Groups.News_Feeds_Groups_ID = News_Feeds.News_Feeds_Groups_ID

WHERE				News_Feeds.Deleted = 0 
					AND
                    News_Feeds_Groups.Deleted = 0

ORDER BY			News_Feeds_Groups.News_Feeds_Groups_Name,
					News_Feeds.News_Feeds_ID
</cfquery>


<cfoutput query="get_news_feeds" group="News_Feeds_Groups_Name">

	<div class="section_title">
    	#News_Feeds_Groups_Name#
	</div>


<ul>


	<cfoutput>
        <li class="toc">
        <A HREF="display_news.cfm?id=#News_Feeds_URL#&title=#News_Feeds_Name#&group=#News_Feeds_Groups_Name#&local=#News_Feeds_Local_File#" TARGET="main">#News_Feeds_Name#</A><br />
        </li>
    </cfoutput>


</ul>

</cfoutput>



</BODY>
</HTML>

