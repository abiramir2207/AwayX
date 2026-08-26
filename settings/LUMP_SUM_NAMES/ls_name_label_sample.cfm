<!---ls_name_label_sample.cfm--->
<TABLE width="60%" BORDER="0" CELLPADDING="3" CELLSPACING="0" CLASS="MAINTABLE" style="margin-top:10px;">
	<!---- HEAD ----->
	<tr ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Description</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Label</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Detailed Description</b>
		</TD>
	</TR>
	<cfoutput>
		<cfloop from="1" to="#arrayLen(variables.lumpSumSampleDatas.sampleCollection)#" index="indx">
			<tr valign="top">
				<td nowrap="nowrap">#variables.lumpSumSampleDatas.sampleCollection[indx].sampleTypeDesc#</td>
				<td><input type="text" name="label_#variables.lumpSumSampleDatas.sampleCollection[indx].sampleTypeId#" value="#variables.lumpSumSampleDatas.sampleCollection[indx].sampleTypelabel#" /></td>
				<td><p>#variables.lumpSumSampleDatas.sampleCollection[indx].sampleTypeDetailedDesc#</p></td>
			</tr>
			<input type="hidden" name="sampleIds" value="#variables.lumpSumSampleDatas.sampleCollection[indx].sampleTypeId#" />
		</cfloop>
	</cfoutput>
</TABLE>
<BR>
<CF_button
	button_name		=	""
	button_caption	=	"Update"
	button_action	=	"document.DataForm.command.value='updateSampleLabel';document.DataForm.submit();"
	button_type		=	"javascript_link"
	button_width	=	"75"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>