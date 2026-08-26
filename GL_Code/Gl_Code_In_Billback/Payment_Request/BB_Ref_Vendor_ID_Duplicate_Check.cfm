
<CFQUERY NAME="DupCheck" DATASOURCE="#Application.Datasource#">
	SELECT TOP 1 Billback.Billback_ID,BB_Code,BB_Reference,Vendor_Master_ID
	FROM Billback
	INNER JOIN BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
	WHERE BB_Reference = (SELECT BB_Reference FROM Billback WHERE Billback_ID = '#Billback_ID#') AND 
	Vendor_Master_ID = '#FORM.Vendor_Master_ID#' AND
	Billback.Billback_ID <> '#Billback_ID#' AND
	BB_Closing_Method = 1 AND
	Deleted = 0
</CFQUERY>

<CFIF DupCheck.RecordCount GT 0>
	<BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD><FONT COLOR="Red" SIZE="2"><B>
			The Vendor ID and Billback Number combination is a duplicate. <BR>
			Please modify the billback number in order to process the payment request.
			</B></FONT>
			</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		</TR>
	</TABLE>
	<CFABORT>
</CFIF>