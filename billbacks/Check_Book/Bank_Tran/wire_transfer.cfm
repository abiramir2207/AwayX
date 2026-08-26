<HTML>

<HEAD>
<TITLE>Silicon Valley Bank CENTRAL CLIENT SERVICE DIVISION</TITLE>
</HEAD>

<BODY>

<CFQUERY name = "fax_bank" datasource="#application.datasource#">
	SELECT * from payment_transaction where payment_trans_ID = '#URL.RID#'
</CFQUERY>

 

<CFSAVECONTENT variable = "fax_content">
<P ALIGN="center"><B><BR>
<FONT SIZE="5">Silicon Valley Bank</FONT></B><BR>
CENTRAL CLIENT SERVICE DIVISION</P>
<P ALIGN="center"><B>PAYMENT REQUEST</B></P>

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" STYLE="border-collapse: collapse" BORDERCOLOR="#111111" ID="AutoNumber1" ALIGN="center" WIDTH="80%">
  <TR>
    <TD STYLE="border-bottom: 3px solid #000080" NOWRAP>FAX TO:&nbsp;&nbsp; 1-800-970-7270</TD>
    <TD STYLE="border-bottom: 3px solid #000080" WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD NOWRAP>&nbsp;</TD>
    <TD WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD NOWRAP COLSPAN="2">
    <P ALIGN="center">Deadline for Domestic Wires 1:00P.M. P.S.T.</TD>
  </TR>
  <TR>
    <TD NOWRAP>AMOUNT TO BE WIRED: (USD)</TD>
    <TD STYLE="border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%"><FONT FACE="Courier"><CFIF "#fax_bank.currency#" EQ "US"><CFOUTPUT><b>#dollarformat(fax_bank.amount)#</b></CFOUTPUT><CFELSE>&nbsp;</CFIF></FONT></TD><!--- xxxxxxxxxxxxxxx --->
  </TR>
  <TR>
    <TD COLSPAN="2" NOWRAP>
    <P ALIGN="center"><BR>
    Deadline for International Wires 12:00 P.S.T.</TD>
  </TR>
<!---   <TR>
    <TD NOWRAP>AMOUNT TO BE WIRED: (USD)</TD>
    <TD STYLE="border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%"><FONT FACE="Courier"><CFIF "#fax_bank.currency#" NEQ ""><CFOUTPUT>#LSCurrencyFormat(fax_bank.amount,"none")#</CFOUTPUT><CFELSE>&nbsp;</CFIF></FONT></TD>
  </TR>
 --->	
  <TR>
    <TD NOWRAP>AMOUNT TO BE WIRED: (FOREIGN CURRENCY)</TD>
    <TD STYLE="border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">
	<CFIF "#fax_bank.currency#" EQ "BP">
		&#163;
		<FONT FACE="Courier"><CFOUTPUT><b>#numberformat(fax_bank.amount,"_.__")#</b></CFOUTPUT>&nbsp;BRP</FONT>
	<CFELSEIF "#Fax_bank.currency#" EQ "CD">
		$
		<FONT FACE="Courier"><CFOUTPUT><b>#numberformat(fax_bank.amount,"_.__")#</b></CFOUTPUT>&nbsp;CAN</FONT>
	<CFELSEIF "#Fax_bank.currency#" EQ "EC">
	 	&#128;
	 	<FONT FACE="Courier"><CFOUTPUT><b>#numberformat(fax_bank.amount,"_.__")#</b></CFOUTPUT>&nbsp;EUR</FONT>
	<CFELSE>
		&nbsp;
	</CFIF>
	
	</TD>
  </TR>

  <TR>
    <TD STYLE="border-bottom: 3px solid #000080" NOWRAP>&nbsp;</TD>
    <TD STYLE="border-bottom: 3px solid #000080" WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD COLSPAN="2" NOWRAP>
    <P ALIGN="center"><b>BENEFICIARY BANK INFORMATION</b></TD>
  </TR>
  <TR>
    <TD NOWRAP>&nbsp;</TD>
    <TD WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" NOWRAP><b>Transit Routing (ABA):</b> <FONT FACE="Courier"><CFOUTPUT>#fax_bank.transit_routing_no#</CFOUTPUT></FONT></TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%"><b>Bank Name:</b> <FONT FACE="Courier"><CFOUTPUT>#fax_bank.Payee_Bank_Name#</CFOUTPUT></FONT></TD>
  </TR>
  <TR>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" NOWRAP><b>Credit Account No.:</b> <FONT FACE="Courier"><CFOUTPUT>#fax_bank.Payee_Account_No#</CFOUTPUT></FONT></TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%"><b>Bank Address:</b> <FONT FACE="Courier"><CFOUTPUT>#fax_bank.Payee_Bank_Address#<CFIF fax_bank.Payee_bank_city NEQ ""><br>#fax_bank.Payee_Bank_city#,&nbsp;#trim(fax_bank.Payee_Bank_State)#&nbsp;-&nbsp;#fax_bank.Payee_Bank_Zipcode#</CFIF></CFOUTPUT></FONT></TD>
  </TR><!---  --->
  <TR>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" NOWRAP><b>For Credit To:</b> <FONT FACE="Courier"><CFOUTPUT>#fax_bank.Payee_Name#</CFOUTPUT></FONT></TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" COLSPAN = "2"><b>Special Instructions:</b> <FONT FACE="Courier"><CFOUTPUT>&nbsp;&nbsp;#fax_bank.note#</CFOUTPUT></FONT></TD>
<!---     <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">&nbsp;</TD>  --->
  </TR>
  <TR>
    <TD STYLE="border-bottom: 3px solid #000080" NOWRAP>&nbsp;</TD>
    <TD STYLE="border-bottom: 3px solid #000080" WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD COLSPAN="2" NOWRAP>
    <P ALIGN="center">ORIGINATOR ACCOUNT INFORMATION (SILICON VALLEY BANK)</TD>
  </TR>
  <TR>
    <TD NOWRAP>&nbsp;</TD>
    <TD WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD NOWRAP>By Order of: <FONT FACE="Courier"></FONT></TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%"><FONT FACE="Courier"><CFOUTPUT>#fax_bank.Pay_By_Order_Of#</CFOUTPUT></FONT></TD>
  </TR>
  <TR>
    <TD NOWRAP>SVB Debit Account No.: <FONT FACE="Courier"></FONT></TD>
	<cfset p_key= hash("abcdefgh")>
	<cf_cryp type="de" key="#p_key#" string="#fax_bank.Debit_Account_No#">
	<CFSET fax_bank.Debit_Account_No = cryp.value> 
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%"><FONT FACE="Courier"><CFOUTPUT>#fax_bank.debit_account_No#</CFOUTPUT></FONT></TD>
  </TR>
 <!---  <TR>
    <TD NOWRAP>Authorized Signature:</TD>
	
	<CFSET rh=randrange(800,1200)*60/1000>
	<CFSET rw=randrange(800,1200)*135/1000>
	
	
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">(1)&nbsp;&nbsp;&nbsp;&nbsp;<CFOUTPUT><IMG SRC="signature.jpg" WIDTH="#rw#" HEIGHT="#rh#" ALIGN="middle"></CFOUTPUT></TD><!--- xxxxxxxxxxxxxxxxxxxx --->
  </TR> 
  <TR>
    <TD NOWRAP>&nbsp;</TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">(2<FONT FACE="Courier">)</FONT></TD>
  </TR>--->
  <TR>
    <TD NOWRAP>Printed Name/Title: <FONT FACE="Courier"></FONT></TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">(1) <FONT FACE="Courier"><CFOUTPUT>#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#</CFOUTPUT></FONT></TD><!--- xxxxxxxxxxxxxxxxx --->
  </TR>
  <TR>
    <TD NOWRAP>&nbsp;</TD>
    <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="50%">(2) <FONT FACE="Courier">Paul Wietecha</FONT></TD><!--- xxxxxxxxxxxxxxxxxxxx --->
  </TR>
  <TR>
    <TD STYLE="border-bottom: 3px solid #000080" NOWRAP>&nbsp;</TD>
    <TD STYLE="border-bottom: 3px solid #000080" WIDTH="50%">&nbsp;</TD>
  </TR>
  <TR>
    <TD COLSPAN="2" NOWRAP>
    <BR>
    <DIV ALIGN="center">
      <CENTER>
      <TABLE BORDER="1" CELLPADDING="20" CELLSPACING="0" STYLE="border-collapse: collapse" BORDERCOLOR="#111111" ID="AutoNumber3">
        <TR>
          <TD WIDTH="100%">
			  <TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" STYLE="border-collapse: collapse" BORDERCOLOR="#111111" WIDTH="500" ID="AutoNumber6">
			    <TR>
			      <TD WIDTH="100%" COLSPAN="5">
			      <P ALIGN="center">BANK USE ONLY</TD>
			    </TR>
			    <TR>
			      <TD NOWRAP>Date Received:</TD>
			      <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="150"><FONT FACE="Courier">&nbsp;</FONT></TD>
			      <TD>&nbsp;</TD>
			      <TD NOWRAP>Foreign Wires Only:</TD>
			      <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="150"><FONT FACE="Courier">&nbsp;</FONT></TD>
			    </TR>
			    <TR>
			      <TD NOWRAP>Time Received:</TD>
			      <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="150"><FONT FACE="Courier">&nbsp;</FONT></TD>
			      <TD>&nbsp;</TD>
			      <TD NOWRAP>Exchange Rate:</TD>
			      <TD STYLE="border-left-width: 1; border-right-width: 1; border-top-width: 1; border-bottom-style: solid; border-bottom-width: 1" WIDTH="150"><FONT FACE="Courier">&nbsp;</FONT></TD>
			    </TR>
			  </TABLE>
		</TD>
        </TR>
      </TABLE>
      </CENTER>
    </DIV>
    </TD>
  </TR>
  <TR>
    <TD NOWRAP>&nbsp;</TD>
    <TD WIDTH="50%">&nbsp;</TD>
  </TR>
</TABLE>

</CFSAVECONTENT>
<!--- <CFOUTPUT>#fax_content#</CFOUTPUT>  --->
<CFSET Wire_FileName = createuuid()>
<CFSET Wire_FileName = "WR_#Replace(Wire_FileName,"-","_","all")#.html">


<CFFILE action = "write"
		file="#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\Wire_Fax\#Wire_FileName#"
		output="#fax_content#">
<!--- HAVE TO CHANGE THE FAX NO --->		
<CFSET Fax_Numbers_List = "19789881277" &"~FR=Ana_Shnakar@Faxmail.com;">
 <CFMAIL TO="#Fax_Numbers_List#"
        FROM="#application.CompanyFaxFromEmail#" 
		SUBJECT="Test Subject"
		MIMEATTACH="#Application.Doc_Path#\temp_files\billback\Check_Book\Bank_Tran\Wire_Fax\#Wire_FileName#">		
</CFMAIL> 
 <CFQUERY name = "confirm_payment" datasource="#Application.datasource#">
	UPDATE Ledger_Table 
	SET		Paid = 1
	WHERE Ledger_ID = #URL.LRID#
</CFQUERY>
<CFTRANSACTION ACTION="BEGIN">
<!--- <CFLOCATION url="../index.cfm" addtoken="No">    --->
 <CFOUTPUT>
 <STYLE>
 .BigFont TD
 {
 	font-size: 12px;
	font-weight:bold;	
 }
 </STYLE>
<TABLE ALIGN="CENTER"HEIGHT="100%">
<TR>
<TD>
<TABLE ALIGN="CENTER" BORDER="0" CLASS="BigFont">
	<COLGROUP>
		<COL SPAN="1" ALIGN="left" width="50%"></COL>
	</COLGROUP>
	<TR>
		<TD COLSPAN="100%" ALIGN="left" STYLE="border-bottom:2px solid darkblue">
		A payment request has been generated:
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%"><BR>&nbsp;</TD>
	</TR>
	<TR>
		<TD>Bank:</TD>
		<TD NOWRAP>#UCase(fax_bank.Payee_Bank_Name)#</TD>
	</TR>
	<TR>
		<TD>Amount:</TD>
		<TD NOWRAP>#NumberFormat(fax_bank.Amount, "_,___,___,___.00")#
		<CFIF fax_bank.currency EQ "BP">
			BRP
		<CFELSEIF fax_bank.Currency EQ "CD">
			CAN 
		<CFELSEIF fax_bank.Currency EQ "EC">
			EUR
		<CFELSE>
			USD
		</CFIF>
		</TD>
	</TR>
	</TR>
		<TR>
		<TD>Payee:</TD>
		<TD NOWRAP>#fax_bank.Payee_Name#</TD>
	</TR>
</TABLE>
</TD>
</TR>
<TR>
	<TD VALIGN="TOP">
	<font SIZE="2">Please wait while we bring you back to the <CFIF fax_bank.Billback_id NEQ "">billback...<CFELSE>Ledger...</CFIF></font>
	</TD>
</TR>
<TR>
	<TD VALIGN="TOP" HEIGHT="70">&nbsp;
	</TD>
</TR>
</TABLE>
</CFOUTPUT>
<CFTRANSACTION action = "commit">
</CFTRANSACTION>

<!------------
Set Billback Status
------------>
<CFIF fax_bank.billback_id NEQ "">
<CFSET Billback_ID = fax_bank.billback_id>
<CFINCLUDE TEMPLATE="bb_set_status_to_paid.cfm">
</CFIF>

<!--- <CFLOCATION url="../index.cfm" addtoken="No">   ---> 

<!--- <SCRIPT LANGUAGE="JavaScript">
function goBackToOtherPage()
{
	window.location.href = "../index.cfm";
}
window.setTimeout('goBackToOtherPage()', 4000);
</SCRIPT>
 --->

<SCRIPT LANGUAGE="JavaScript">
var isfrombillback = "<cfoutput>#fax_bank.billback_id#</cfoutput>";
function goBackToOtherPage()
{
	if (isfrombillback == "")
	{
		window.location.href = "../index.cfm";
	}
	else
	{
		window.parent.tabClick('summary');
	}
}
window.setTimeout('goBackToOtherPage()', 4000);
</SCRIPT>

		
</BODY>

</HTML>