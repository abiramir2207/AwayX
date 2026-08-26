<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
</HEAD>

<BODY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE CELLPADDING="5" CELLSPACING="" BORDER="0">
<TR>
	<TD COLSPAN="100%">
		<DIV STYLE="font-weight: bold; font-size:16px; color: navy; border-bottom: 1px solid red;">How to read this report</DIV>
	</TD>
</TR>	
<TR>
	<TD VALIGN="top">
		<IMG SRC="/images/data_integration_help.gif" TITLE="Data integration activity sample" BORDER="0"><BR><BR>
	</TD>
	<TD rowspan="2">
		The intent of this tool, is to give you an overview of the data integration events.
		After selecting the date for which you would like to see the activity that took place, you'll see a screen as depicted:
		
		<OL>
			<LI>Represents the date and time that the file was processed.</LI>
			<LI>This string represents the checksum that has been passed to us.</LI>
			<LI>This string is the checksum of the agreed data column and it is calculated by us. When this column and column described in number 2 match, it means the file received has not been tampered with.</LI>
			<LI>If they do match, we will process the file and integrate the data into the database. If for some reason the two checksums don't match, we will not process.</LI>
			<LI>This represents the number of records received by us.</LI>
			<LI>Only records with complete and valid data will be incorporated into the database. This column will display the number of records accepted by the database.</LI>
			<LI>The difference between the received records and the accepted records represents the number of invalid or incomplete records.</LI>
			<LI>The user can access via this link, the top 100 received records. **This feature is not currently available**</LI>
			<LI>In case the user needs the original file, this will send to Blacksmith Applications an email with the request.</LI>
		</OL>		
		Days with data integration activity are highlighted <span style="color:red">red</span>.
	</TD>
</TR>
<!---
<tr>
 <TD valign="top"><!---<a href="javascript:(void);" onclick="javascript:window.open('DataInt_Alert.cfm','configAlert','toolbar=no,width=800,height=460,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false"><span style="color:red;text-decoration : underline;" title="Configure email notifier">Configure</span></a> notification Recipients for Interface Errors.
<br>--->
<a href="javascript:(void);" onclick="javascript:window.open('DataInt_Alert_Jobs.cfm','configAlertJobs','toolbar=no,width=800,height=460,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false"><span style="color:red;text-decoration : underline;" title="Configure email notifier">Configure</span></a> notification Parameters for Jobs.
 <br><a href="javascript:(void);" onclick="javascript:window.open('ViewLastJobRun.cfm','ViewJobs','toolbar=no,width=1024,height=660,location=no,menubar=yes,resizable=no,scrollbars=no');return false"><span style="color:red;text-decoration : underline;" title="View latest Job Statuses">View</span></a> the status of the most recent run of each Job.
 </TD>
</tr>
--->
</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
