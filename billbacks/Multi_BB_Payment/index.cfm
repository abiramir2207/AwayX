<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<cfset runningBorderColor = "Silver">
<CFSET tabWidth = "80px">
<CFSET tabHeight = "20px">
<STYLE>
.cellaroundIframe {
			border-right:solid #runningBorderColor# 1px;
			<!--- border-top:solid #runningBorderColor# 1px; --->
			border-bottom:solid #runningBorderColor# 1px;
		} 
</STYLE>


<cfoutput>
<!--- /Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/View_Edit_Approve.cfm?BBID=#Billback_ID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID# --->
<table  width="99%" border="0" cellspacing="0" cellpadding="0" align="center">
	<TR>
		<TD width="100" style="border-bottom:solid #runningBorderColor# 1px;"><img src="/images/fill.gif" alt="" width="1" height="1" border="0"></TD>
		<TD colspan="" height="10px" class="statusBarStyle">	
			<TABLE BORDER="0" CELLPADDING="5" STYLE="border-collapse: collapse" BORDERCOLOR="111111" WIDTH="100%" ID="AutoNumber2" CELLSPACING="3" BGCOLOR="FFFFFF">
			  <TR>
			    <TD BGCOLOR="006600" WIDTH="100%" CLASS="titleMain" id="infoBar"><B><FONT COLOR="White">Payment Request For Multiple Billbacks</FONT></B> 
				</TD>
			    <TD ALIGN="center" CLASS="titleAmount" id="infoBar_BB_Amount">
				</TD>

			  </TR>
			</TABLE>		
		</TD>
	</TR>
	<TR>
		<TD width="100" style="border-left:solid #runningBorderColor# 1px;"><img src="/images/fill.gif" alt="" width="1" height="1" border="0"></TD>
		<TD colspan="100%" height="5px" style="border-right:solid #runningBorderColor# 1px;border-left:solid #runningBorderColor# 1px;"><img src="/images/fill.gif" alt="" width="1" height="1" border="0"></TD>
	</TR>
</TABLE>
</cfoutput>

<table height="87%" width="99%" border="0" cellspacing="0" cellpadding="0" align="center">
	<TR>
		<td id="LockCell" align="center" style="<cfoutput>border-left:solid #runningBorderColor# 1px; border-bottom:solid #runningBorderColor# 0px; border-right:solid #runningBorderColor# 1px;</cfoutput>"><img src=/images/Deviations/lock_no.jpg width=40 height=40 border=0 onmouseover=this.src="/images/Deviations/lock_yes.jpg" onmouseout=this.src="/images/Deviations/lock_no.jpg" style="cursor:pointer;" onclick="tabClick('lock')"><BR><font color=red><b>UNLOCKED</b></font></td>
		<TD rowspan="100%" class="cellaroundIframe"><iframe src="" name="contentIFrame" id="contentIFrame" width="100%" height="100%" marginwidth="0" marginheight="0" align="left" frameborder="0" class="iframeStyle"></iframe></TD>
	</TR>
</table>


<CFIF IsDefined("URL.BBID")>
	<CFQUERY NAME="GetPayeeType" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback_Payee_Type_ID,
					CASE 
					WHEN Billback.Billback_Payee_Type_ID = 1 THEN
						CAST(Billback_Distributor.Distributor_ID AS NVARCHAR(100))
					WHEN  Billback.Billback_Payee_Type_ID = 2 THEN
						CAST(Billback_Operator.Operator_ID AS NVARCHAR(100))
					WHEN Billback.Billback_Payee_Type_ID = 3 THEN
						CAST(Billback_Broker.Broker_ID AS NVARCHAR(100))
					END AS Payee_ID
	
		FROM 		Billback 
		LEFT JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Billback.Billback_ID AND Billback_Distributor.Deleted = 0
		LEFT JOIN 	Billback_Operator ON Billback_Operator.Billback_ID = Billback.Billback_ID AND Billback_Operator.Deleted = 0
		LEFT JOIN 	Billback_Broker ON Billback_Broker.Billback_ID = Billback.Billback_ID AND Billback_Broker.Deleted = 0
		WHERE 		Billback.Billback_ID = '#URL.BBID#'
	</CFQUERY>
	
	<CFQUERY NAME="BBList" DATASOURCE="#Application.Datasource#">
		SELECT 	Billback_ID 
		
		FROM 	Pay_Multi_Billbacks_List 
		
		WHERE 	Pay_Multi_Billbacks_ID = '#URL.Pay_Multi_Billbacks_ID#' AND 
				Deleted = 0
	</CFQUERY>
	<CFSET BBIDList = VALUELIST(BBList.Billback_ID)>
	
	<FORM NAME="SRCFormVar" ACTION="Distributor_And_BB_Form.cfm" METHOD="POST" TARGET="contentIFrame">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#BBIDList#">
		<INPUT TYPE="Hidden" NAME="PayeeType" VALUE="#GetPayeeType.Billback_Payee_Type_ID#">
		<CFIF GetPayeeType.Billback_Payee_Type_ID EQ 1>
			<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#GetPayeeType.Payee_ID#">
			<INPUT TYPE="Hidden" NAME="FromDistributorSearch" VALUE="1">
		<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 2>
			<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#GetPayeeType.Payee_ID#">
			<INPUT TYPE="Hidden" NAME="FromOperatorSearch" VALUE="1">
		<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 3>
			<INPUT TYPE="Hidden" NAME="Broker_List" VALUE="#GetPayeeType.Payee_ID#">
			<INPUT TYPE="Hidden" NAME="FromBrokerSearch" VALUE="1">
		</CFIF>
		</CFOUTPUT>	
	</FORM>
	
	<SCRIPT language="JavaScript">
	function submitform()
	{
		document.SRCFormVar.submit()
	}
	submitform()
	</SCRIPT>
</CFIF>

</body>
</html>
