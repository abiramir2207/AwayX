



<CFQUERY NAME="DistBrokAddressDetails" DATASOURCE="#Application.Datasource#">
	SELECT 		BSA_Foodservice_Customers.Name DistName,
				BSA_Foodservice_Customers.Address_1 DistAddress_1,
				BSA_Foodservice_Customers.Address_2 DistAddress_2,
				BSA_Foodservice_Customers.City DistCity,
				BSA_Foodservice_Customers.State DistState, 
				BSA_Foodservice_Customers.ZipCode DistZipCode,
				BSA_Foodservice_Brokers.Broker_Name, 
				BSA_Foodservice_Brokers.Address,
				BSA_Foodservice_Brokers.Address_2,
				BSA_Foodservice_Brokers.City,
				BSA_Foodservice_Brokers.State,
				BSA_Foodservice_Brokers.Zip
				
	FROM		BSA_Foodservice_Customers 
	INNER JOIN 	Contract_Distributors ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AND
				Contract_Distributors.Deleted=0
	INNER JOIN	BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID AND
				BSA_Foodservice_Brokers.Deleted = 0
				
	WHERE 		Contract_Distributors.Contract_Main_ID = '#ProgramID#' AND
				BSA_Foodservice_Customers.Deleted = 0
				
	ORDER BY	BSA_Foodservice_Customers.Name
</CFQUERY>

<STYLE>
TABLE.Underlined TD 
{
	border-bottom:solid #93BEE2 1px; 
	font-size : 11px;
}
</STYLE>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="Underlined" ALIGN="Center">
	<TR BGCOLOR="FFE083">
		<TD><B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></B>&nbsp;&nbsp;</TD>
		<CFIF DetailsAbout EQ 1 OR DetailsAbout EQ 2>
		<TD><B>PAYABLE TO</B>&nbsp;&nbsp;</TD>
		</CFIF>
		<CFIF DetailsAbout EQ 1 OR DetailsAbout EQ 3>
		<TD><B>SEND PAYMENT TO</B>&nbsp;&nbsp;</TD>
		</CFIF>
	</TR>
	<CFOUTPUT QUERY="DistBrokAddressDetails">
	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD VALIGN="Top">#DistName#&nbsp;&nbsp;&nbsp;</TD>
		<CFIF DetailsAbout EQ 1 OR DetailsAbout EQ 2>
		<TD VALIGN="Top">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD STYLE="border:None">#DistName#</TD>
				</TR>
				<TR>
					<TD STYLE="border:None">#DistAddress_1#</TD>
				</TR>
				<TR>
					<TD STYLE="border:None">#DistAddress_2#</TD>
				</TR>
				<TR>
					<TD STYLE="border:None">
					<CFIF TRIM(DistCity) NEQ "">#DistCity#,</CFIF> <CFIF TRIM(DistState) NEQ "">#DistState#</CFIF> <CFIF TRIM(DistZipCode) NEQ "">- #DistZipCode#.</CFIF></TD>
				</TR>
			</TABLE>&nbsp;&nbsp;&nbsp;
		</TD>
		</CFIF>
		<CFIF DetailsAbout EQ 1 OR DetailsAbout EQ 3>
		<TD VALIGN="Top">
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">			
				<TR>
					<TD STYLE="border:None">#Broker_Name#</TD>
				</TR>
				<TR>
					<TD STYLE="border:None">#Address#</TD>
				</TR>
				<TR>
					<TD STYLE="border:None">#Address_2#</TD>
				</TR>
				<TR>
					<TD STYLE="border:None"><CFIF TRIM(City) NEQ "">#City#,</CFIF> <CFIF TRIM(State) NEQ "">#State#</CFIF> <CFIF TRIM(Zip) NEQ "">- #Zip#.</CFIF></TD>
				</TR>
			</TABLE>&nbsp;&nbsp;&nbsp;
		</TD>
		</CFIF>
	</TR>
	</CFOUTPUT>
</TABLE>

