<CFIF url.Show_Tab EQ 5>
	<CFSET url.filetype = 1>
<CFELSEIF url.Show_Tab EQ 6>
	<CFSET url.filetype = 2>
</CFIF>

<CFIF url.filetype NEQ "">
<CFSET qFileFormatErrors.recordcount =0>
<!--- <cfset qFileFormatErrors = uploadmargintargetManager.FileFormatErrors(url.filetype)> --->

<!--- <CFIF qFileFormatErrors.recordcount EQ 0> --->
<CFIF isdefined("url.Generic_Files_Upload_ID")>
<CFSET Generic_Files_Upload_ID = url.Generic_Files_Upload_ID>
<CFELSE>
<cfset qgetCurrentActiveProcess = uploadmargintargetManager.getCurrentActiveProcess(url.filetype)>
<CFSET Generic_Files_Upload_ID = qgetCurrentActiveProcess.Generic_Files_Upload_ID>
</cfif>

<CFIF Generic_Files_Upload_ID GT 0>
	<cfset qAnyErrors = uploadmargintargetManager.AnyErrors(url.filetype,Generic_Files_Upload_ID)>
</CFIF>
	


<!--- </CFIF> --->

<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>

<br>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="98%" CLASS="UnderLine">	
	<TR BGCOLOR="FFE083">
		<CFIF url.filetype EQ 1>
		<TD><B>GDW4</B></TD>	
		<CFELSEIF url.filetype EQ 2>
		<TD><B>Item Number</B></TD>	
		</CFIF>
		<TD><B>Invalid Reason</B></TD>
		<TD><B>Uploaded By</B></TD>
		<TD><B>Uploaded On</B></TD>
	</TR>
<CFIF qFileFormatErrors.recordcount GT 0>
		<CFOUTPUT QUERY="qFileFormatErrors">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="index.cfm?Show_Tab=#URL.Show_Tab#&ShowLogDetails=1&Generic_Files_Upload_Log_ID=#Generic_Files_Upload_Log_ID#&Generic_Files_Upload_ID=#Generic_Files_Upload_ID#">
<CFIF url.filetype EQ 1>#GDWL4_ID#
<CFELSEIF url.filetype EQ 2>
<cfif ITEM_NUMBER EQ "">
NULL
<cfelse>
#ITEM_NUMBER#
</cfif>
</CFIF>
</A><FONT COLOR="red" SIZE="2"> ]</FONT></B></TD>
			<TD>File Format Error</TD>
			<TD>#Name_First# #Name_Last#</TD>
			<TD>#DATEFORMAT(Created_Date,"mm/dd/yyyy")# #TIMEFORMAT(Created_Date,"HH:mm:ss")#</TD>
		</TR>
	</CFOUTPUT>
<CFELSE>
<CFIF isdefined("qAnyErrors")>
	<CFQUERY name="Errors" dbtype="query">
		select * from 
		qAnyErrors
		where ItemsNotFound = 0
	</CFQUERY>
	<CFIF Errors.recordcount GT 0>
	<CFOUTPUT QUERY="Errors">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="index.cfm?Show_Tab=#URL.Show_Tab#&ShowLogDetails=1&Generic_Files_Upload_Log_ID=#Generic_Files_Upload_Log_ID#&Generic_Files_Upload_ID=#Generic_Files_Upload_ID#">
<CFIF url.filetype EQ 1>#GDWL4_ID#
<CFELSEIF url.filetype EQ 2>
#ITEM_NUMBER#
</CFIF></A><FONT COLOR="red" SIZE="2"> ]</FONT></B></TD>
			<TD>#InvalidReason#</TD>
			<TD>#Name_First# #Name_Last#</TD>
			<TD>#DATEFORMAT(Created_Date,"mm/dd/yyyy")# #TIMEFORMAT(Created_Date,"HH:mm:ss")#</TD>
		</TR>
	</CFOUTPUT>
	</CFIF>
	<CFQUERY name="ItemErrors" dbtype="query">
		select * from 
		qAnyErrors
		where ItemsNotFound = 1
	</CFQUERY>
<CFIF ItemErrors.recordcount GT 0>
	<cfset qItemsNotFound = uploadmargintargetManager.ItemsNotFound(url.filetype,Generic_Files_Upload_ID)>
<CFIF qItemsNotFound.recordcount GT 0>
	<CFOUTPUT query="qItemsNotFound">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD><B><FONT COLOR="red" SIZE="2">[ </FONT>
			<CFIF url.filetype EQ 1><A HREF="index.cfm?Show_Tab=#URL.Show_Tab#&ShowLogDetails=1&Margin_Target_Temp_Valid_Id=#GDWL4_Margin_Target_Temp_Valid_Id#&filetype=1">
#GDWL4_ID#
<CFELSEIF url.filetype EQ 2>
<A HREF="index.cfm?Show_Tab=#URL.Show_Tab#&ShowLogDetails=1&Margin_Target_TEMP_Valid_Id=#Item_Margin_Target_VALID_TEMP_Id#&filetype=2">#ITEM_NUMBER#
</CFIF></A><FONT COLOR="red" SIZE="2"> ]</FONT></B></TD>
			<TD>Item not found in our DB.</TD>
			<TD>#Name_First# #Name_Last#</TD>
			<TD>#DATEFORMAT(Created_Date,"mm/dd/yyyy")# #TIMEFORMAT(Created_Date,"HH:mm:ss")#</TD>
		</TR>
	</CFOUTPUT>
</CFIF>
</CFIF>
</CFIF>
</CFIF>


</TABLE>
</CFIF>