<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<STYLE>
TABLE.Underlined TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>
<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>		
<cfset useLakebaseForPendingVendor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForPendingVendor>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"billback_status_id" = "7"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPendingVendor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPendingVendor>
<CFQUERY NAME="PendingVendor" DATASOURCE="#Application.Datasource#">
	UPDATE Billback 
	SET Billback_Status_ID = 7
	WHERE Billback_ID = '#Billback_ID#'
</CFQUERY>
</cfif>
</CFIF>	
<CFIF PayeeType EQ 1>
	<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		Name			PayeeName,
					Address_1		PayeeAdd1,
					Address_2		PayeeAdd2,
					City			PayeeCity,
					State			PayeeState,
					ZipCode			PayeeZip,
					Country_Code  	PayeeCCode,
					Shr_Ship_To		PayeeNumber

		FROM 		BSA_Foodservice_Customers
		INNER JOIN 	Billback_Distributor ON Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID 

		WHERE 		Billback_Distributor.Billback_ID = '#Billback_ID#' AND
					Billback_Distributor.Deleted = 0
	</CFQUERY>
<CFELSEIF PayeeType EQ 2>
	<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		Operator_Name		PayeeName,
					Operator_Address	PayeeAdd1,
					Operator_Address2	PayeeAdd2,
					Operator_City		PayeeCity,
					Operator_State		PayeeState,
					Operator_Zip		PayeeZip,
					Operator_Country_Code  PayeeCCode,
					Legacy_ID			PayeeNumber

		FROM 		BSA_Operator
		INNER JOIN 	Billback_Operator ON Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID 

		WHERE 		Billback_Operator.Billback_ID = '#Billback_ID#' AND
					Billback_Operator.Deleted = 0
	</CFQUERY>
<CFELSEIF PayeeType EQ 4>
	<CFQUERY NAME="GetPayeeInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		BB_UP_Name			PayeeName,
					BB_UP_Address1		PayeeAdd1,
					BB_UP_Address2		PayeeAdd2,
					BB_UP_City			PayeeCity,
					State_Code			PayeeState,
					BB_UP_Zipcode		PayeeZip,
					BB_UP_Country_Code  PayeeCCode,
					''				PayeeNumber

		FROM 		Billback_Unidentified_Payee
		LEFT JOIN 	_states
		ON			_states.State_ID = BB_UP_State
		WHERE 		Billback_Unidentified_Payee.Billback_ID = '#Billback_ID#' AND
					Billback_Unidentified_Payee.Deleted = 0
	</CFQUERY>
<CFELSE>
	<BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">Payee is not a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> and not a <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>...</FONT></B></TD>
		</TR>
	</TABLE>	
</CFIF>

<CFOUTPUT>
<BR><BR><BR><BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" width="50%">
	<CFIF IsDefined("Deduction_ID")>
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" TARGET="_parent">back to deduction</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B><BR><BR></TD>
	</TR>
	</CFIF>

	<TR>
		<TD>
		<B>
		<FONT COLOR="red" SIZE="3">
		Please fill the Vendor ID NULL Notification form and email it to place the request.
		</FONT>
		</B>
		</TD>
	</TR>		
	<TR>
		<TD WIDTH="100%"> <BR><BR>		
			<TABLE width="50%" BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="Border-Bottom: 2px Solid Navy;Border-Left: 2px Solid Navy;Border-Right: 2px Solid Navy;Border-Top: 2px Solid Navy;">
				<TR>
					<TD COLSPAN="2" ALIGN="Center"><FONT COLOR="Navy" SIZE="2"><B>Payee Info</B></FONT><HR COLOR="Orange"></TD>
				</TR>
				<TR>
					<TD><B>Payee Type:</B></TD>
					<TD><B><FONT COLOR="Red"><CFIF PayeeType EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSEIF PayeeType EQ 2>#application.returned_customer_setting.operator_label_singular#<CFELSEIF PayeeType EQ 4>OTHER</CFIF></FONT></B></TD>
				</TR>
				<TR>
					<TD><B>Payee Name:</B></TD>
					<TD>#GetPayeeInfo.PayeeName#</TD>
				</TR>
				<TR>
					<TD><B>Address 1:</B></TD>
					<TD>#GetPayeeInfo.PayeeAdd1#</TD>
				</TR>
				<TR>
					<TD><B>Address 2:</B></TD>
					<TD>#GetPayeeInfo.PayeeAdd2#</TD>
				</TR>
				<TR>
					<TD><B>City:</B></TD>
					<TD>#GetPayeeInfo.PayeeCity#</TD>
				</TR>
				<TR>
					<TD><B>State/Postal Code:</B></TD>
					<TD>#GetPayeeInfo.PayeeState#,#GetPayeeInfo.PayeeZip#&nbsp;#GetPayeeInfo.PayeeCCode#</TD>
				</TR>
				<CFIF PayeeType EQ 1 OR PayeeType EQ 2>
				<TR>
					<TD><B><CFIF PayeeType EQ 1>#application.returned_customer_setting.Shard_Ship_To_Label#<CFELSEIF PayeeType EQ 2>#application.returned_customer_setting.operator_label_singular# ID</CFIF>:</B></TD>
					<TD>#GetPayeeInfo.PayeeNumber#</TD>
				</TR>
				</CFIF>
			</TABLE>
		</TD>
	</TR>
	
	<TR>
		<TD ALIGN="Center"><BR><BR><BR>
		<B>
		<FONT COLOR="Red" SIZE="2">[ </FONT>
		<FONT SIZE="2">
		<A HREF="/GetDocument.cfm?FilePath=gl_code/gl_code_in_billback/payment_request/Vendor_ID Null New Vendor Form FORGE.xls" target="_blank" TITLE="Glossary">click to get a vendor ID NULL Notification form</A><!--- onclick="NewWindow(this.href,'name','1010','800','Yes', 'No');return false;" --->
		</FONT>
		<FONT COLOR="Red" SIZE="2"> ]</FONT>
		</B>
		</TD>
	</TR>
</TABLE>
</CFOUTPUT>

<script>
 try { window.parent.dyniframesize(); } catch (err) { };
</script>

<!--- 
NewWindow('http://<CFOUTPUT>#CGI.server_name#</CFOUTPUT>/common_files/documents/uploaded_doc/<cfoutput>#Get_Item.Doc_Uni_Name#</cfoutput>', 'name', '800', '600', 'Yes', 'Yes');
http://artemis2/gl_code/gl_code_in_billback/payment_request/Vendor_ID Null New Vendor Form FORGE.xls
http://<CFOUTPUT>#CGI.server_name#</CFOUTPUT>/common_files/documents/uploaded_doc/<cfoutput>#Get_Item.Doc_Uni_Name#</cfoutput>
 --->
</body>
</html>

<!--- 


<BR><BR><BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="3">Vendor ID NULL Notification</FONT></B></TD>
	</TR>
</TABLE>

<TABLE BORDER="1" CELLPADDING="5" CELLSPACING="0" WIDTH="850" CLASS="Underlined" ALIGN="Center">
	<TR>
		<TD><B>Requestor:</B></TD>
		<TD>&nbsp;</TD>
		<TD><B>Approver:</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>Requested On:</B></TD>
		<TD>&nbsp;</TD>
		<TD><B>Approved On:</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>Requestor Email:</B></TD>
		<TD>&nbsp;</TD>
		<TD><B>Vendor Number:</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>Requestor Phone:</B></TD>
		<TD>&nbsp;</TD>
		<TD><B>Select Action:</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><B>REMIT - TO INFORMATION</B></TD>
	</TR>
	<TR>
		<TD><B>PAY-TO NAME:</B></TD>
		<TD COLSPAN="3">&nbsp;</TD>		
	</TR>
	<TR>
		<TD><B>CONTACT NAME:</B></TD>
		<TD>&nbsp;</TD>
		<TD><B>EMAIL:</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>ADDRESS 1:</B></TD>
		<TD COLSPAN="3">&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>ADDRESS 2:</B></TD>
		<TD COLSPAN="3">&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>CITY:</B></TD>
		<TD>&nbsp;</TD>
		<TD COLSPAN="2">
			<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD STYLE="Border-Bottom:none;"><B>STATE:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
					<TD STYLE="Border-Bottom:none;"><B>ZIP:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD><B>COUNTRY:</B></TD>
		<TD>&nbsp;</TD>
		<TD COLSPAN="2">
			<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD STYLE="Border-Bottom:none;"><B>PHONE:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
					<TD STYLE="Border-Bottom:none;"><B>FAX:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><B>PURCHASING ADDRESS</B></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><B>PURCHASING ADDRESS SAME AS ABOVE (Will default to remit-to information if left blank)</B></TD>
	</TR>
	<TR>
		<TD><B>CONTACT NAME:</B></TD>
		<TD>&nbsp;</TD>
		<TD><B>EMAIL:</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>ADDRESS 1:</B></TD>
		<TD COLSPAN="3">&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>ADDRESS 2:</B></TD>
		<TD COLSPAN="3">&nbsp;</TD>
	</TR>
	<TR>
		<TD><B>CITY:</B></TD>
		<TD>&nbsp;</TD>
		<TD COLSPAN="2">
			<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD STYLE="Border-Bottom:none;"><B>STATE:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
					<TD STYLE="Border-Bottom:none;"><B>ZIP:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD><B>COUNTRY:</B></TD>
		<TD>&nbsp;</TD>
		<TD COLSPAN="2">
			<TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD STYLE="Border-Bottom:none;"><B>PHONE:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
					<TD STYLE="Border-Bottom:none;"><B>FAX:</B></TD>
					<TD STYLE="Border-Bottom:none;">&nbsp;</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><B>TAX AND MINORITY - OWNED STATUS (REQUIRED)</B></TD>		
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD><B>TAX STATUS</B></TD>
					<TD>&nbsp;</TD>
					<TD><B>TIN OR SS NUMBER</B></TD>
					<TD>&nbsp;</TD>
				</TR>				
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD></TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
</TABLE>
 --->
