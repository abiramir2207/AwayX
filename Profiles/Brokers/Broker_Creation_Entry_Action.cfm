<CFINSERT datasource="#application.datasource#" tableName="BSA_Foodservice_Brokers">


<HTML><HEAD>
	<TITLE>brokerNew - Entry Action</TITLE>
</HEAD><BODY bgcolor="#FFFFFF">

<FONT size="+1">brokerNew</FONT> <BR>
<FONT size="+2"><B>Entry was successfully submitted</B></FONT>

<TABLE>


    <!--- Field: BSA_Foodservice_Brokers.Region_Shard --->
    <TR>
    <TD valign="top"> Region_Shard: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Region_Shard#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Region_Legcy_Shard --->
    <TR>
    <TD valign="top"> Region_Legcy_Shard: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Region_Legcy_Shard#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Market_Area --->
    <TR>
    <TD valign="top"> Market_Area: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Market_Area#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Broker_Shard --->
    <TR>
    <TD valign="top"> Broker_Shard: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Broker_Shard#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Broker_Legcy_Shard --->
    <TR>
    <TD valign="top"> Broker_Legcy_Shard: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Broker_Legcy_Shard#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Broker_Name --->
    <TR>
    <TD valign="top"> Broker_Name: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Broker_Name#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Address --->
    <TR>
    <TD valign="top"> Address: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Address#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.City --->
    <TR>
    <TD valign="top"> City: </TD>
    <TD>
	
		<CFOUTPUT>#Form.City#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.State --->
    <TR>
    <TD valign="top"> State: </TD>
    <TD>
	
		<CFOUTPUT>#Form.State#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Zip --->
    <TR>
    <TD valign="top"> Postal: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Zip#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Broker_CSR --->
    <TR>
    <TD valign="top"> Broker_CSR: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Broker_CSR#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Account_Exec --->
    <TR>
    <TD valign="top"> Account_Exec: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Account_Exec#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Phone_Number --->
    <TR>
    <TD valign="top"> Phone_Number: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Phone_Number#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Fax_Number --->
    <TR>
    <TD valign="top"> Fax_Number: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Fax_Number#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.E_Mail --->
    <TR>
    <TD valign="top"> E_Mail: </TD>
    <TD>
	
		<CFOUTPUT>#Form.E_Mail#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Line_Of_Business --->
    <TR>
    <TD valign="top"> Line_Of_Business: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Line_Of_Business#</CFOUTPUT>
	
	</TD>
	</TR>

    <!--- Field: BSA_Foodservice_Brokers.Deleted --->
    <TR>
    <TD valign="top"> Deleted: </TD>
    <TD>
	
		<CFIF Form.Deleted is 1> Yes <CFELSE> No </CFIF>
	
	</TD>
	</TR>
</TABLE>


</BODY></HTML>
