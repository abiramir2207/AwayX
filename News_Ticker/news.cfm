
<html>
<head>
	<meta http-equiv="Cache-Control" content="no-cache">
	<meta http-equiv="pragma" content="no-cache">
</head>

<STYLE>
	.tickerText, .tickerText:link
	{
		font-family : arial;
		font-weight : bold;
		font-size : 10px;
		color:blue;
		text-decoration:none;
	}
	
	.tickerText, .tickerText:hover
	{
		font-family : arial;
		font-weight : bold;
		font-size : 10px;
		color:red;
		text-decoration:underline;
	}

</STYLE>



<!--- When no specific feed is passed, default to general news... --->
<CFPARAM NAME="url.title" DEFAULT="Headline News">
<CFPARAM NAME="url.file" DEFAULT="News_Files/food_industry.xml">

<cfinvoke component="GetNewsFeed" method="getheadlines" returnVariable="newsfeed" url="#url.file#" type="RSS">

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<cfoutput>
<script language="JavaScript">
	var arNews = new Array();

	function buildNews(sTitle, sUrl)
	{
		this.title = sTitle;
		this.url = sUrl;
		return this;
	}
	function addNews(sTitle, sUrl)
	{
		arNews[arNews.length] = new buildNews(sTitle, sUrl);
	}
	<cfloop query="newsfeed">
	<!--- Dev Note: Milan:10823 - Remove the single quotes and the double quotes --->
		addNews("#Replace(Replace(ucase(title),chr(34),"", "ALL"),chr(39),"","ALL")#", "#link#");
    </cfloop>
	var newsIndex = 0;
	function changeNews()
	{
		newsIndex++;		
		if(newsIndex >= arNews.length)
		{
			newsIndex = 0;
		}
		if(newsIndex < arNews.length)
		{	
			var tdNews = document.all.TDNews;
			tdNews.innerHTML = "<a href=\"" + arNews[newsIndex].url + "\" target=\"_blank\" CLASS=\"tickerText\">" + arNews[newsIndex].title + "</a>";
		}
	}
	
	window.setInterval("changeNews()", 3000);
</script>
<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%" HEIGHT="25">
	<TR>
		<TD VALIGN="Middle" ID="TDNews" align="center">
		<a href="#newsfeed.link#" target="_blank" CLASS="tickerText">#ucase(newsfeed.title)#</a>
			<!------
			<MARQUEE 
			 WIDTH="100%" 
			 SCROLLDELAY=5
			 SCROLLAMOUNT=1
			 TRUESPEED=1
			 ONMOUSEOVER="stop();" 
			 ONMOUSEOUT="start();">
						   <cfloop query="newsfeed">
						      <CFOUTPUT><a href="#link#" target="_blank" CLASS="tickerText">#ucase(title)#</a></CFOUTPUT>
							  &nbsp;&nbsp;&nbsp;&nbsp;
						    </cfloop>
			</MARQUEE>
			----->
		</TD>		
	</TR>
</TABLE>
</cfoutput>

</body>
</html>
