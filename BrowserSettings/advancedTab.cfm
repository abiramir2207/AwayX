<CFINCLUDE template="bsInclude.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> - Browser Settings</title>
	<CFOUTPUT><BASE TARGET="#IMGPageName#"></CFOUTPUT>
</head>

<body>
<BLOCKQUOTE>
<cfset colStr="<colgroup><col width=""#width1#"" span=""1""></col><col width=""#width2#"" span=""1""></col></colgroup>">
<CFOUTPUT>
<!--- <a href="#IMGPage#?IMG=internetoptions"><SPAN>Internet Explorer -> Tools -> Internet Options</SPAN></a><BR><BR> --->
<DIV CLASS="steps">STEP 1 - <a href="index2.cfm" target="_parent">Browser Version</a></DIV>
<BR>
<DIV CLASS="steps">STEP 2 - <a href="index2.cfm?PG=1" target="_parent"><b>Security Settings</b></a></DIV>
<BR>
<DIV CLASS="steps">STEP 3 - Advanced Settings</DIV>
		<OL>
		<LI><a href="#IMGPage#?IMG=internetoptions">Control Panel -> Internet Options</a></LI>
		<LI><a href="#IMGPage#?IMG=advanced0">Click <b>Advanced</b> Tab in the Internet Option dialoge box</a>
		<LI>Verify whether the settings are as given below
		</OL>

<a name="contents"></a>
<table cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td>
			<fieldset>
			<legend>Accessibility</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Always expand ALT text for images</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Move system caret with focus/selection images</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Browsing</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Always send URLs as UTF-8</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Automatically check for Internet Explorer updates</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Close unused folders in History and Favorites</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Disable script debugging</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Display a notification about every script error</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Enable folder view for FTP sites</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Enable Install on Demand</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Enable offline items to be sysnchronized on a schedule</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Enable page transitions</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Enable personalized Favorites Menu</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Notify whend download complete</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced1">Reuse windows for launching shortcuts</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Show friendly HTTP error messages</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Show friendly URLs</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Show Go button in Address bar</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Show Internet Explorer on the descktop</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Underline links</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Use inline AutoComplete</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Use Passive FTP for compatibility with some firewalls and DSL modems</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Use smooth scrolling</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>HTTP 1.1 settings</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced2_5">Use HTTP 1.1</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Use HTTP 1.1 through proxy connections</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Microsoft VM</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced2">Java console enabled</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">Java logging enabled</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">JIT complier for virtual machine enabled</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Multimedia</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">Always show Internet Explorer(5.0 or later) Radio toolbar</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced4">Play animations</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced5">Play sounds</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced6">Play videos</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">Show image download placeholders</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced7">Show pictures</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">Smart image dithering</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Printing</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">Print background colors and images</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>				
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Search from the Address bar</legend>			
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced3">When searching</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>				
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Security</legend>			
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Check for publisher's certificate revocation</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Check for server crtificate revocation</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Do not save encrypted pages to disk</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Empty Temporary Internet Files folder when browser is closed</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Enable Profile Assistant</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Use Fortezza</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Use PCT 1.0</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced9">Use SSL 2.0</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=advanced10">Use SSL 3.0</a>
					</td>
					<td>
					Checked
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Use TLS 1.0</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Warn about invalid site cerificates</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Warn if changing between secure and not secure mode</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=advanced8">Warn if forms submittal is being redirected</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				</table>	
			</fieldset>
		</td>
	</tr>
</table>
<!------<iframe id="oIframe" name="IMG" src="#IMGPage#?IMG=advanced1"  style="position:absolute; top:200; left:550; width:450; height:500; z-index:1" SCROLLING="No" allowTransparency="true"></iframe>----->
</CFOUTPUT>
</BLOCKQUOTE>
</body>
</html>
