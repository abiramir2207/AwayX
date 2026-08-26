<CFPARAM NAME="SUBMIT_TITLE" 	DEFAULT="view graph">

<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
<SCRIPT>
function validate()
{
dateStr1=document.stdt_enddt_data.Start_Date.value
dateStr2=document.stdt_enddt_data.End_Date.value
var dateSplit; 
dateSplit = dateStr1.split("/"); 

if(dateSplit.length > 2)
{
	
  	var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
	dateSplit = dateStr2.split("/"); 
	if(dateSplit.length > 2)
	 {
   		var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
   		diff = days_between(date1, date2, true);
		
		if(diff >=0)
		{
			alert("Start date should be less than end date");
			document.stdt_enddt_data.Start_Date.focus();		
		}
		else
		{
			if(diff < (-365 + 1))
			{
				alert("The period between Start date and end date is more than 365 days. Please try again");
				document.stdt_enddt_data.Start_Date.focus();
			}
			else
			{
				document.stdt_enddt_data.submit();
			}
		}
	 }
	
}	

	
	
	/*else
	{
		document.stdt_enddt_data.submit();
	}*/

	
	
}
</SCRIPT>

<CFOUTPUT>
<FORM NAME = "stdt_enddt_data" ACTION = "view_commodity_chart.cfm" METHOD = "POST" ONSUBMIT = "return validate()" STYLE="DISPLAY:INLINE;">
<INPUT TYPE="HIDDEN" NAME="Symbol" VALUE="#URL.Symbol#">
<TABLE cellpadding="0" cellspacing="0" border="0">
<TR valign="middle">
<TD>
<B>days</B><BR>
<CFSET Days_List = "30,45,60,90,120">
<CFSET Today_Enddate_Diff = DateDiff("d", enddate, Now())>
<SELECT onChange="location.href=this.value;">
	<CFLOOP LIST="#Days_List#" INDEX="This_Day">
		<CFOUTPUT><OPTION VALUE="/profits/view_commodity_chart.cfm?Symbol=#URL.Symbol#&datasize=#This_Day#"<CFIF URL.datasize EQ This_Day AND Today_Enddate_Diff EQ 0> SELECTED</CFIF>>#This_Day#</OPTION></CFOUTPUT>
	</CFLOOP>
</SELECT>
</TD>
<TD>
	<BR>
	&nbsp;<B>or</B>&nbsp;
</TD>
<TD><B>Start Date</B><BR>
<CF_EASYDATE FORMNAME="stdt_enddt_data" FIELDNAME="Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#startdate#"></TD>
<TD>&nbsp;&nbsp;</TD>

<TD><B>End Date</B><BR>
<CF_EASYDATE FORMNAME="stdt_enddt_data" FIELDNAME="End_Date" FORMAT="mm/dd/yyyy" DEFAULT="#enddate#"></TD>
<TD>&nbsp;&nbsp;</TD>
<TD VALIGN="bottom">
	<B><FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="javascript: validate()">#SUBMIT_TITLE#</A>
	<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT></B>

</TD>
</TR>
</TABLE>
</FORM>
</CFOUTPUT>