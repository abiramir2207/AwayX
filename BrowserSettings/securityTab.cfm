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
<DIV CLASS="steps">STEP 2 - Security Settings</DIV>
		<OL>
		<LI><a href="#IMGPage#?IMG=internetoptions">Control Panel -> Internet Options</a></LI>
		<LI><a href="#IMGPage#?IMG=security0">Click <b>Security</b> Tab in the Internet Option dialoge box</a>
		<LI>Under "Select a Web content zone to specify its security settings"
		<br><a href="#IMGPage#?IMG=Security1">Select "Local intranet"</a></LI>		
		<LI>Under "Security level for this zone"
		<br><a href="#IMGPage#?IMG=security1_5">Click "Custom Level"</a></LI>
		<LI><a href="##contents" target="_self">Verify whether the settings are as given below</a>	
		</OL>

<a name="contents"></a>
<table cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td>
			<fieldset>
			<legend>ActiveX control and plug-ins</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security2">Download signed ActiveX controls</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security2">Download unsigned ActiveX controls</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security2">Initialize and script ActiveX controls not marked as safe</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security14">Run ActiveX controls and plug-ins</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security14">Script ActiveX controls marked safe for scripting</a>
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
			<legend>Cookies</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=security3">Allow cookies that are stored on your computer</a>
					</td>
					<td>
					Enable
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=security4">Allow per-session cookies (not stored)</a>
					</td>
					<td>
					Enable
					</td>
				</tr>				
				</table>	
			</fieldset>
		</td>
	</tr>
	<tr>
		<td>
			<fieldset>
			<legend>Downloads</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=security5">File Download</a>
					</td>
					<td>
					Enable
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security6">Font Download</a>
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
					<a href="#IMGPage#?IMG=security6">Java permissions</a>
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
			<legend>Miscellaneous</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security7">Access data sources accross domains</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security7">Don't	prompt for client certificate selection when no certificates or only one certificate exists</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security7">Drag and drop or copy and paste files</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security8">Installation of desktop items</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security8">Launching programs and files in an IFRAME</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security8">Navigate sub-frames accross different domains</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security10">Software channel permissions</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=security9">Submit nonencrypted form data</a>
					</td>
					<td>
					Enable
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security10">userdata persistence</a>
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
			<legend>Scripting</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr class="highlight" align="top">
					<td>
					<a href="#IMGPage#?IMG=security11">Active scripting</a>
					</td>
					<td>
					Enable
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security12">Allow paste operations via script</a>
					</td>
					<td>
					<nobr>Not Applicable</nobr>
					</td>
				</tr>
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security13">Scripting of Java applets</a>
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
			<legend>User Authentication</legend>
				<table cellspacing="0" cellpadding="2" border="0" WIDTH="100%">
				#colStr#
				<tr>
					<td>
					<a href="#IMGPage#?IMG=security13">Logon</a>
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
<BR><BR>
<DIV CLASS="steps">STEP 3 - <a href="index2.cfm?PG=2" target="_parent"><b>Advanced Settings</b></a></DIV>

<!------<iframe id="oIframe" name="IMG" src="#IMGPage#?IMG=security1"  style="position:absolute; top:200; left:550; width:450; height:500; z-index:1" SCROLLING="No" allowTransparency="true"></iframe>----->
</CFOUTPUT>

</BLOCKQUOTE>
</body>
</html>
