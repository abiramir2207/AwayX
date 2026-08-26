<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/news/rss/style.css">
</HEAD>

<BODY BGCOLOR="White" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="12" TOPMARGIN="12" RIGHTMARGIN="12">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!------
Added by deepa.
----->
<CFINCLUDE template="News_Feed_List.cfm">

<CFOUTPUT><H3>#CGI.SERVER_NAME#</H3></CFOUTPUT>
<CFSET AllValidXML = true>
<CFSET counter=1>
<CFLOOP INDEX="i" LIST="#sourcelist#" DELIMITERS="#listdelimiter#">
	<CFSET URLaddress=listfirst(i,delimiterchar)>
	<CFSET filename=listlast(i,delimiterchar)>

	
	<CFHTTP URL="#URLaddress#" charset="ISO-8859-1"></CFHTTP>
	<cfset File_Content=cfhttp.filecontent>	
	<cfinvoke component="GetNewsFeedCount" method="GetHeadLineCount" returnVariable="Valid_Count" file_content="#File_Content#" type="rss">
	
	<CFIF Valid_Count GT 0>
		<cffile 	action = "write"
					file = "#Application.Doc_Path#\data_files\created\News_Ticker\News_Files\#filename#"
					output = "#File_Content#"
					addNewLine = "No"> 
	<CFELSE>
		<CFSET AllValidXML = false>
	</CFIF>
	<FONT SIZE="1"
	<CFIF Valid_Count LTE 0> COLOR="Red"
	</CFIF>>
	<CFOUTPUT>#counter#. #filename# - <A HREF="#URLaddress#" TARGET="_blank">#URLaddress#</A> #Valid_Count# (#cfhttp.statuscode#)</CFOUTPUT><BR>
	</FONT>
	<CFFLUSH>
	<CFSET counter=counter+1>
</CFLOOP>
<CFIF NOT AllValidXML>
<EMAILERROR></EMAILERROR>
</CFIF>
<H2>Done!!</H2>

<!------
<CFLOCATION URL="/news/news/rss/display_news.cfm" ADDTOKEN="No">
----->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
