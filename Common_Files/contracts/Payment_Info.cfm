<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Distributor Payment Details</title>
</head>

<body leftmargin="0" rightmargin="0" topmargin="0">
<!--- <CFDUMP VAR="#URL#"> --->

<CFQUERY NAME="PaymentInfo" DATASOURCE="#Application.Datasource#">
	SELECT 		Contract_Distributors.*, 
				BSA_Foodservice_Customers.Name,
				BSA_Foodservice_Customers.Ship_To,
				Contract_Main.Contract_Number
		
	FROM 		Contract_Distributors 
	INNER JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID AND 
				BSA_Foodservice_Customers.Deleted=0 AND Active_Code = 'A'
	INNER JOIN	Contract_Main ON Contract_Main.Contract_Main_ID = Contract_Distributors.Contract_Main_ID AND Contract_Main.Deleted=0
	
	WHERE 		Contract_Distributors.BSA_Foodservice_Customers_ID = '#URL.DID#' AND 
				Contract_Distributors.Contract_Main_ID = '#URL.Contract_Main_ID#' AND
				Contract_Distributors.Deleted = 0
</CFQUERY>
<!--- <CFDUMP VAR="#PaymentInfo#"> --->

<CFOUTPUT>
<!--- <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
	<TR>
		<TD BGCOLOR="FE9898" ALIGN="Center"><FONT SIZE="3"><B>#application.returned_customer_setting.distributor_label_singular#:</B> &nbsp;#PaymentInfo.Name#</FONT></TD>
	</TR>
</TABLE> --->
<BR><BR>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" STYLE="Border-Left:1px solid Blue;Border-Bottom:1px solid Blue;Border-Top:1px solid Blue;Border-Right:1px solid Blue;">	
	<TR>
		<TD><FONT SIZE="2" COLOR="Navy"><B>Program:</B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#PaymentInfo.Contract_Number# </FONT></TD>
	</TR>	
	<TR>
		<TD><FONT SIZE="2" COLOR="Navy"><B>#application.returned_customer_setting.distributor_label_singular#:</B> &nbsp;#PaymentInfo.Name#</FONT></TD>
	</TR>	
	<TR>
		<TD><FONT SIZE="2" COLOR="Navy"><B>#application.returned_customer_setting.shard_ship_to_label#:</B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#PaymentInfo.Ship_To#</FONT><BR><BR></TD>
	</TR>
	<TR>
		<TD STYLE="Border-Bottom: Solid Orange 1px"><FONT SIZE="2" COLOR="Navy"><B>Payable To:</B></FONT></TD>
	</TR>
	<TR>
		<TD>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="10">
				<TR>
					<TD WIDTH="115"><B>Company Name:</B></TD>
					<TD>#PaymentInfo.Payable_Company#&nbsp;</TD>		
				</TR>
				<TR>
					<TD><B>Attention:</B></TD>
					<TD>#PaymentInfo.Payable_Attention#&nbsp;</TD>
				</TR>
				<TR>
					<TD><B>Address 1:</B></TD>
					<TD>#PaymentInfo.Payable_Address_1#&nbsp;</TD>
				</TR>
				<TR>
					<TD><B>Address 2:</B></TD>
					<TD>#PaymentInfo.Payable_Address_2#&nbsp;</TD>
				</TR>
				<TR>
					<TD><B>City, State and Zip:</B></TD>
					<TD>#PaymentInfo.Payable_City#, #PaymentInfo.Payable_State# - #PaymentInfo.Payable_Zip#&nbsp;</TD>
				</TR>				
			</TABLE>
		</TD>
	</TR>	
	<TR>
		<TD STYLE="Border-Bottom: Solid Orange 1px"><BR><BR><FONT SIZE="2" COLOR="Navy"><B>Send Payment To:</B></FONT></TD>
	</TR>
	<TR>
		<TD>
			<TABLE BORDER="0" CELLPADDING="" CELLSPACING="10">
				<TR>
					<TD WIDTH="115"><B>Company Name:</B></TD>
					<TD>#PaymentInfo.Send_Company#&nbsp;</TD>		
				</TR>
				<TR>
					<TD><B>Attention:</B></TD>
					<TD>#PaymentInfo.Send_Attention#&nbsp;</TD>
				</TR>
				<TR>
					<TD><B>Address 1:</B>&nbsp;&nbsp;</TD>
					<TD>#PaymentInfo.Send_Address_1#&nbsp;</TD>
				</TR>
				<TR>
					<TD><B>Address 2:</B>&nbsp;&nbsp;</TD>
					<TD>#PaymentInfo.Send_Address_2#&nbsp;</TD>
				</TR>
				<TR>
					<TD><B>City, State and Zip:</B>&nbsp;&nbsp;</TD>
					<TD>#PaymentInfo.Send_City#, #PaymentInfo.Send_State# - #PaymentInfo.Send_Zip#&nbsp;</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>	
</TABLE>

</CFOUTPUT>
</body>
</html>
