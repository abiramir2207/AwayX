<cfset variables.qgetAliasManagementHistory = AliasManager.getAliasManagementHistory()>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Upload History Alias Management</LEGEND>
<table align="center" border="0" cellspacing="0" width="60%">
	<TR>
		<TD style="border-bottom:0px;border-top:0px;">&nbsp;</TD>
	</TR>
	<TR>
		<TD><SPAN STYLE="font-size: 12px;"><B>Uploaded By</B></SPAN></TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>Uploaded File</B></SPAN></TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>Date</B></SPAN></TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>Upload Status</B></SPAN></TD>
		<TD><SPAN STYLE="font-size: 12px;"><B>Error Details</B></SPAN></TD>
	</TR>

	<cfset Upload_Action_Status_Desc = "">
	<CFOUTPUT QUERY="variables.qgetAliasManagementHistory">
	<TR>
		<TD>#Uploaded_By#</TD>
		<TD><A href="OpenFile.cfm?FileName=#Upload_FileName#">open file</a></TD>
		<TD>#Dateformat(Created_Date,'MM/DD/YYYY')# #Timeformat(Created_Date,'hh:mm:ss tt')#</TD>		
		<TD NOWRAP ALIGN="CENTER">	
				<!--- SUCCESSFUL UPLOAD --->
				<cfif Is_Complete eq 1 AND Upload_Action_Status eq 1>
					<IMG SRC="/images/yes_small.gif" TITLE="Successful Upload">
				<!--- UPLOAD ERRORS --->
				<cfelseif Is_Complete eq 0 AND Upload_Action_Status eq 2>
					<IMG SRC="/images/no_small.gif" TITLE="Upload Error(s)">
				<!--- UPLOAD IN PROGRESS --->
				<cfelseif Is_Complete eq 0 AND Upload_Action_Status eq 1>
					<IMG SRC="/images/modify_agree_lock.gif" TITLE="In Progress" width="8" height="12">
				</cfif>
		</TD>
		<TD><cfif Error_Count GT 0><a href="##" onClick="Javascript:getAliasManagementErrorDetails('#Alias_Management_Product_History_ID#')">open details</a><cfelse>None</cfif></TD>
	</TR>
	</CFOUTPUT>
</TABLE>
</FIELDSET>