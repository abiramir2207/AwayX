<!---
	Name:          	most_favored_nation_display.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	07/22/2014
	Created By:    	Tim Ford
	Description:   	Page to display for MFN 
	Usage:
--->
<html>
<title>Most Favored Nation Display</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<body>
<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<cfparam name="url.programId" default="0" />

<cfset objProgramMFN = createObject("component", "components.programs.ProgramMostFavoredNation") />
<cfset qGetData = objProgramMFN.getMFNData(url.programId) />

<b>Most Favored Nation Data<b>
<br>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="50%" CLASS="datagrid" id="compList">
	<thead>
	<tr>
		<th>Template</th>
		<th>Component Name</th>
	</tr>
	</thead>
	<tbody>
		<cfoutput query="qGetData">
		<TR>
			<td>#Template_Created_Type#</td>
			<td>#Component_Name#</td>
		</TR>
		</cfoutput>
	</tbody>
</table>

<br>
<table align="center">
	<tr>
		<td>
			<CF_button
				button_name		=	"close"
				button_caption	=	"close"
				button_action	=	"window.close()"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"close"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</td>
	</tr>
</table>

</body>
</html>