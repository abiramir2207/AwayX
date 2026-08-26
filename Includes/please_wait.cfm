<!------------------------------------------
Inputs that can be provided are the following

PW_DoNotCFFLUSH : Some pages which has Easy data in it has problem with CFFlush, so this won't be flushed

OR

PW_Type : "1" (Shows the messages and check boxes)
PW.Total_Time : Sets the Total Estimated Time 
PW_DoNotCFFLUSH : Some pages which has Easy data in it has problem with CFFlush, so this won't be flushed
PW.Message_List : Default messages can be overrided by providing a list of messages.
PW.Show_Last_Check : 0 - does not show the last check
					 NEQ 0 - Will show the last check 
------------------------------------------->

<CFPARAM NAME="PW_DoNotCFFLUSH" DEFAULT="0">
<CFPARAM NAME="PW_Type" DEFAULT="0">

<CFIF PW_Type EQ "volume_applicator">
	<TABLE ALIGN="center" BORDER="0" CELLPADDING="0" CELLSPACING="0" HEIGHT="50%">
	<TR>
		<TD HEIGHT="50%"><IMG SRC="/Images/Animation/images/spinner.gif"></TD>
	</TR>	
	</TABLE>
<CFELSE>
	<TABLE ALIGN="center" BORDER="0" CELLPADDING="0" CELLSPACING="0" HEIGHT="50%">
	<TR>
		<TD HEIGHT="50%"><IMG SRC="/Images/Animation/images/progress.gif"></TD>
	</TR>	
	</TABLE>
</CFIF>
<cfif PW_DoNotCFFLUSH eq 0>
	<CFFLUSH>
</cfif>
