<!---
Description: This template parses the 
			 CGI.USER_AGENT for some arcane 
			 information for about 99.9% of all 
			 the browsers this application will 
			 ever see.
--->

<!--- Initialize parameters --->
<CFPARAM NAME="Attributes.browserVerbose" DEFAULT=FALSE>
<CFPARAM NAME="Attributes.versionVerbose" DEFAULT=FALSE>
<CFPARAM NAME="Attributes.osVerbose" DEFAULT=FALSE>
<CFPARAM NAME="Attributes.MSIEVersions" DEFAULT=TRUE>
<CFSET Caller.Version="">
<CFSET Variables.Tag=CGI.USER_AGENT>
<!--- Get browser name - "compatible" clause first to short-circuit the evaluation --->
<CFIF (NOT FindNoCase("compatible", Variables.Tag)) AND (Find("Mozilla", Variables.Tag))>
	<!--- Netscape --->
	<CFIF Attributes.BrowserVerbose>
		<CFSET Caller.Browser="Netscape Navigator">
		<CFELSE><CFSET Caller.Browser="NS"></CFIF>
	<CFSET Variables.Token="/">
	<CFELSEIF Find(" AOL ", Variables.Tag)>
		<!--- AOL --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="America Online">
			<CFELSE><CFSET Caller.Browser="AOL"></CFIF>
		<CFIF Attributes.MSIEVersions>
			<CFSET Variables.Token="IE ">
			<CFELSE><CFSET Variables.Token="AOL "></CFIF>
	<CFELSEIF Find(" MSN ", Variables.Tag)>
		<!--- MSN --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Microsoft Network">
			<CFELSE><CFSET Caller.Browser="MSN"></CFIF>
		<CFIF Attributes.MSIEVersions>
			<CFSET Variables.Token="IE ">
			<CFELSE><CFSET Variables.Token="MSN "></CFIF>
	<CFELSEIF FindNoCase("webtv", Variables.Tag)>
		<!--- WebTv --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Web TV">
			<CFELSE><CFSET Caller.Browser="WebTV"></CFIF>
		<CFIF Attributes.MSIEVersions>
			<CFSET Variables.Token="IE ">
			<CFELSE><CFSET Variables.Token="TV/"></CFIF>
	<CFELSEIF FindNoCase("mosaic", Variables.Tag)>
		<!--- Mosaic --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="NCSA Mosaic">
			<CFELSE><CFSET Caller.Browser="Mosaic"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF FindNoCase("libwww", Variables.Tag)>
		<!--- Lynx --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Lynx">
			<CFELSE><CFSET Caller.Browser="Lynx"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF FindNoCase("nokia", Variables.Tag)>
		<!--- Nokia --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Nokia Communicator">
			<CFELSE><CFSET Caller.Browser="Nokia"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF FindNoCase("hotjava", Variables.Tag)>
		<!--- HotJava --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Hot Java">
			<CFELSE><CFSET Caller.Browser="HotJava"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF FindNoCase("opera", Variables.Tag)>
		<!--- Opera --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Opera">
			<CFELSE><CFSET Caller.Browser="Opera"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF FindNoCase("prodigy", Variables.Tag)>
		<!--- Prodigy --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Prodigy Classic">
			<CFELSE><CFSET Caller.Browser="Prodigy"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF FindNoCase("webview", Variables.Tag)>
		<!--- WebView --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="O'Reilly WebView">
			<CFELSE><CFSET Caller.Browser="WebView"></CFIF>
		<CFSET Variables.Token="/">
	<CFELSEIF Find("IE ", Variables.Tag) OR Find("Explorer/", Variables.Tag)>
		<!--- MSIE --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="MS Internet Explorer">
			<CFELSE><CFSET Caller.Browser="MSIE"></CFIF>
		<CFIF Find("Explorer/", Variables.Tag)>
			<CFSET Variables.Token="Explorer/">
			<CFELSE>
			<CFSET Variables.Token="IE "></CFIF>
	<CFELSEIF FindNoCase("spider", Variables.Tag) OR FindNoCase("crawl", Variables.Tag) OR FindNoCase("bot", Variables.Tag) OR FindNoCase("seek", Variables.Tag) OR FindNoCase("search", Variables.Tag) OR FindNoCase("vista", Variables.Tag) OR FindNoCase("slurp", Variables.Tag)OR FindNoCase("widow", Variables.Tag) OR FindNoCase("netattache", Variables.Tag) OR FindNoCase("crescent", Variables.Tag) OR FindNoCase("check", Variables.Tag) OR FindNoCase("scooter", Variables.Tag) OR FindNoCase("archive", Variables.Tag) OR FindNoCase("webtrends", Variables.Tag)>
		<!--- Various Spiders --->
		<CFIF Attributes.BrowserVerbose>
			<CFSET Caller.Browser="Search Engine Spider">
			<CFELSE><CFSET Caller.Browser="Spider"></CFIF>
		<CFSET Caller.Version="n/a">
	<CFELSE>
		<!--- Others --->
		<CFSET Caller.Browser="Other">
		<CFSET Caller.Version="n/a">
	</CFIF>
<!--- Establish Browser Version --->
<CFIF NOT Len(Caller.Version)>
	<CFSET Variables.TempStr=Mid(Variables.Tag, Find(Variables.Token, Variables.Tag) + Len(Variables.Token), Len(Variables.Tag))>
	<CFSET Variables.EndPosn=FindONEOF(" ;()*/", Variables.TempStr) - 1>
	<CFIF Variables.EndPosn LT 1><CFSET Variables.EndPosn=Len(Variables.TempStr)></CFIF>
	<CFSET Caller.Version=Left(Variables.TempStr, Variables.EndPosn)>
	<CFIF (NOT Attributes.VersionVerbose) AND (Find(".", Caller.Version)) OR (NOT CompareNoCase(Right(Caller.Version, 1), '.'))><CFSET Caller.Version=Left(Caller.Version, Find(".", Caller.Version) - 1)></CFIF></CFIF>
<!--- Get OS --->
<CFIF Find("Windows 95", Variables.Tag) OR Find("Win95", Variables.Tag) OR Find("Win 95", Variables.Tag) OR Find("Win32", Variables.Tag) OR Find("Win 32", Variables.Tag) OR Find("32bit", Variables.Tag) OR Find("Windows x86", Variables.Tag)>
	<!--- Win95 --->
	<CFIF Attributes.osVerbose>
		<CFSET Caller.OS="Windows 95">
		<CFELSE><CFSET Caller.OS="Win95"></CFIF>
	<CFELSEIF Find("Windows 98", Variables.Tag) OR Find("Win98", Variables.Tag) OR Find("Win 98", Variables.Tag)>
		<!--- Win98 --->
		<CFIF Attributes.osVerbose>
			<CFSET Caller.OS="Windows 98">
			<CFELSE><CFSET Caller.OS="Win98"></CFIF>
	<CFELSEIF Find("Windows NT", Variables.Tag) OR Find("WinNT", Variables.Tag) OR Find("Win NT", Variables.Tag)>
		<!--- WinNT --->
		<CFIF Attributes.osVerbose>
			<CFSET Caller.OS="Windows NT">
			<CFELSE><CFSET Caller.OS="WinNT"></CFIF>
	<CFELSEIF FindNoCase("windows", Variables.Tag) OR Find("Windows 3.1", Variables.Tag) OR Find("Win16", Variables.Tag) OR Find("16bit", Variables.Tag)>
		<!--- Win3.1 --->
		<CFIF Attributes.osVerbose>
			<CFSET Caller.OS="Windows 3.1">
			<CFELSE><CFSET Caller.OS="Win3.1"></CFIF>
	<CFELSEIF Find("X11", Variables.Tag) OR Find("Lynx", Variables.Tag)>
		<!--- UNIX --->
		<CFIF Attributes.osVerbose>
			<CFSET Caller.OS="UNIX">
			<CFELSE><CFSET Caller.OS="UNIX"></CFIF>
	<CFELSEIF Find("Mac", Variables.Tag) OR Find("PPC", Variables.Tag)>
		<!--- Mac --->
		<CFIF Attributes.osVerbose>
			<CFSET Caller.OS="Macintosh">
			<CFELSE><CFSET Caller.OS="Mac"></CFIF>
	<CFELSEIF Find("OS/2", Variables.Tag) OR Find("PPC", Variables.Tag)>
		<!--- OS/2 --->
		<CFIF Attributes.osVerbose>
			<CFSET Caller.OS="IBM OS/2">
			<CFELSE><CFSET Caller.OS="OS/2"></CFIF>
	<CFELSE>
		<!--- Others --->
		<CFSET Caller.OS="Other">
	</CFIF>
