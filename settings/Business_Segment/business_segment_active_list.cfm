<!---
  * ==================================================================================================== 
  *    @File: \settings\Business_Segment\business_segment_active_list.cfm
  *  @Author: Unknown
  *    @Date: 2018-07-31 09:43:54
  * 
  * @Remarks: Display active business segments
  *
  *
  * 
  *  
  * ==================================================================================================== 
--->
<cfoutput><a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export')#</a></cfoutput><br><br>
<table border="0" cellpadding="1" cellspacing="0" class="MAINTABLE" width="60%">
	<!-- HEAD -->
	<tr bgcolor="#FFCE84" id="HEADER">
		<td style="font-size:11px;"><b>Business Unit ID</b></td>
		<td style="font-size:11px;"><b><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></b></td>
		<td style="font-size:11px;"><b>Company Code</b></td>
		<td style="font-size:11px;"><b>Edit</b></td>
		<td align="center" style="font-size:11px;"><b>DeActivate</b></td>
		<td><b>Copy</b></td>
	</tr>
	<cfoutput query="qGetBusSegments">
		<tr <cfif currentrow mod 2>bgcolor="ccffcc"</cfif>>
			<td>#Business_Unit_ID#</td>
			<td>#Business_Unit_Desc#</td>
			<td>N/A#Company_Code_ID#&nbsp;</td>
			<td>
				<a href="javascript:submitForm('eaBusinessSegment','#Business_Segment_ID#',%20'dActiveBusinessSegment');">(edit)</a>
			</td>
			<td align="center">
				<a href="" onclick="JavaScript:return submitForm('daBusinessSegment','#Business_Segment_ID#');"><img border="0" src="/images/not_allowed.gif"></a>
			</td>
			<td>
				<a href="javaScript:submitForm('copy', '#Business_Segment_ID#')">(copy)</a>
			</td>
		</tr>
	</cfoutput>
</table><br>
<a href="javascript:submitForm('cBusinessSegment',%200,%20'dActiveBusinessSegment')"><cfoutput>#application.util.string.actionLinkFormat2("add")#</cfoutput></a>