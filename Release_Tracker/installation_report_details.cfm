<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
	<STYLE TYPE="text/css">
		.filetypeheader{
			font-size: 11px;
			font-weight : bold;
			font-family:verdana;
			background: #FFFFCC;
		}
		.header
		{
			font-size: 11px;
			font-weight : bold;
			font-family:verdana;
			background: #FFCC99;
		}	
		TD.Underlined
		{
			border-bottom: 1px solid #7575FF;
		}
		TR.highlight TD.Underlined
		{
			background-color: #EAFFEA;
			border-bottom: 1px solid #7575FF;
			align: right;
		}
		TR.nothighlight TD.Underlined  
		{
			border-bottom: 1px solid #7575FF;
		}
	</STYLE>

<cfparam name="PageTitle" default="">
<cfparam name="Installed_Date" default="">
<cfparam name="Patch_Number" default="">

<!--- Displays the page title set in the URL --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<table border="0" cellpadding="4" cellspacing="0">
	<tr><td>
		<b><font color="red">[</font></b><a href="installation_report.cfm"><B> back </B></a><b><font color="red">]</font></b>
		<b><font color="red">[</font></b><a href="installation_report.cfm"><B> view installation report </B></a><b><font color="red">]</font></b>
		</td>
	</tr>
	<tr>
		<cfset PatchNumber = Replace(Installed_Date, "-","" , "all")>
		<cfset PatchNumber = right( left(trim(PatchNumber),8), 6)>
		<td><font color = "maroon" SIZE="1"><u><B><cfoutput>Service Pack: #Installed_Date# (#Patch_Number##PatchNumber#):</cfoutput></B></u></font></td>
		</td>
	</tr>
	<cfoutput>
	<CFQUERY NAME="getInstallationDetails" datasource="#application.datasource#">
		SELECT AI.Application_Installation_ID, AI.File_Path, LTRIM(RTRIM(AI.Release_Version)) As Release_Version, AI.Patch_Number, AI.CF_Installation, AI.Object_Type,
		AI.File_Name, AI.Installed_Date, AI.Name, AI.Label_Number, AIAD.Comments
		FROM Application_Installation AI LEFT OUTER JOIN Application_Installation_Aux_Data AIAD
		ON AI.Application_Installation_ID = AIAD.Application_Installation_ID
		WHERE AI.Installed_Date =  '#Installed_Date#'
		AND AI.Patch_Number = '#Patch_Number#'
		ORDER BY  AI.Object_Type, AI.File_Path,  AI.CF_Installation, AI.Installed_Date DESC
	</CFQUERY>
	</cfoutput>
	<tr><td>
		<table id="TB" width="100%"  BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
			<tr>
				<td class="header">&nbsp;Date</td>
				<td class="header">&nbsp;Applied By</td>
				<td class="header">&nbsp;Patch</td>
				<td class="header">&nbsp;Label</td>
				<td class="header">&nbsp;File Name</td>
				<td class="header">&nbsp;File Path</td>
			</tr>
			<cfoutput query="getInstallationDetails">
			<tr>
				<td CLASS="Underlined">&nbsp;#DateFormat(Installed_Date, "m/dd/yyyy")#</td>
				<td CLASS="Underlined">&nbsp;#Name#</td>
				<td CLASS="Underlined">&nbsp;#Patch_Number#</td>
				<td CLASS="Underlined">&nbsp;#Label_Number#</td>
				<td CLASS="Underlined">&nbsp;#getInstallationDetails.File_Name#</td>
				<td CLASS="Underlined">&nbsp;#getInstallationDetails.File_Path#
				<!---
				<CF_SmallHelp
				width="500"
				displayShifyX = "-400"
				
				imgPath="/images/doc.gif"
				imgWidth="11"
				imgHeight="13"
				dropdownCheck="0"
				>
				#getInstallationDetails.File_Path#
				</CF_SmallHelp>--->
				</td>			
			</tr>
			</cfoutput>
		</table>
		</td>
	</tr>
</table>