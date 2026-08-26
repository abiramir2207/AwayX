<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<!------ Get the positions of the user ----->
<cfset crucibleFileManager = CreateObject("component", "components.crucble.crucibleFileManager").init() />
<cfset qGetCrucibleFileSettings = crucibleFileManager.getCrucibleFileSettings() />
<cfset sAPP_Relative_Path = qGetCrucibleFileSettings.APP_Relative_Path />
<cfset sCompressed_File_Extension = qGetCrucibleFileSettings.Compressed_File_Extension />

<cfparam name="form.subcommand" 	default="">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFSET PAGE_TITLE="GAUGE">
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<center><font style="color:maroon;font-weight:bold;font-size:20px;font-family:'century gothic'">GAUGE<SUP style="font-size:13px">SM</SUP></font></center>
	<cfoutput>
	<br>
	
	<table align="center" width="70%" border="0">
		<tr>
			<td colspan="3">
				<cfinclude template="header.cfm" />
			</td>
		</tr>
		<tr>
			<td colspan="3">
				<cfswitch expression="#url.command#">
				<cfcase value="current">
					<cfinclude template="current_file.cfm">
				</cfcase>
				<cfcase value="search">
					<cfinclude template="search_file.cfm">
				</cfcase>
				</cfswitch>
				<br><br><br>
			</td>
		</tr>
		<tr>
			<td colspan="3" style="border-top:2px solid black;font-size:12px;">
				<br><br>
				If you do not have the GAUGE<SUP style="font-size:10px">SM</SUP> installed on your machine, <a href="Install/gauge_install.exe">click here to download the setup</a>.
				<br><br><br>
			</td>
		</tr>
		<tr>
			<td style="color:black;font-weight:bold;font-size:12px;" width="50%">
				A new version (1.0.15) of Gauge is available since 02/21/2012. <br>
				Please download the new version, if: <br>
					&nbsp;&nbsp;- you are downloading your Dataset after 02/21/2012, <br>
					&nbsp;&nbsp;- your version of Gauge is older than version 1.0.15
			</td>
			<td style="border-left:2px solid black;" width="10%">&nbsp;</td> 
			<td style="color:black;font-weight:bold;font-size:12px;">
				To find the version of your Gauge:<br>
					&nbsp;&nbsp;- Open Gauge <br>
					&nbsp;&nbsp;- In the Help menu - Click About
			</td>
		</tr>
		
	</table>
	
	</cfoutput>
</body>
</html>
