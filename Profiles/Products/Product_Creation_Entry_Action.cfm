<CFINSERT datasource="#application.datasource#" tableName="BSA_Foodservice_Items_Master">


<HTML><HEAD>
	<TITLE>Product_Creationn_Entry - Entry Action</TITLE>
</HEAD><BODY bgcolor="#FFFFFF">

<FONT size="+1">Product_Creationn_Entry</FONT> <BR>
<FONT size="+2"><B>Entry was successfully submitted</B></FONT>

<TABLE>


    <!--- Field: BSA_Foodservice_Items_Master.Item --->
    <TR>
    <TD valign="top"> Item: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Item#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.UPC --->
    <TR>
    <TD valign="top"> UPC: </TD>
    <TD>
	
		<CFOUTPUT>#Form.UPC#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Case_Count --->
    <TR>
    <TD valign="top"> Case_Count: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Case_Count#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Pack_Size --->
    <TR>
    <TD valign="top"> Pack_Size: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Pack_Size#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Pack_Size_UOM --->
    <TR>
    <TD valign="top"> Pack_Size_UOM: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Pack_Size_UOM#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Description --->
    <TR>
    <TD valign="top"> Description: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Description#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Brand --->
    <TR>
    <TD valign="top"> Brand: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Brand#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Net_Weight --->
    <TR>
    <TD valign="top"> Net_Weight: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Net_Weight#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Order_UoM --->
    <TR>
    <TD valign="top"> Order_UoM: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Order_UoM#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Inven_UoM --->
    <TR>
    <TD valign="top"> Inven_UoM: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Inven_UoM#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Q_Brand --->
    <TR>
    <TD valign="top"> Q_Brand: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Q_Brand#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Q_Brand_Desc --->
    <TR>
    <TD valign="top"> Q_Brand_Desc: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Q_Brand_Desc#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Type_Code --->
    <TR>
    <TD valign="top"> Type_Code: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Type_Code#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Type_Code_Desc --->
    <TR>
    <TD valign="top"> Type_Code_Desc: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Type_Code_Desc#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Type_Group --->
    <TR>
    <TD valign="top"> Type_Group: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Type_Group#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Type_Group_Desc --->
    <TR>
    <TD valign="top"> Type_Group_Desc: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Type_Group_Desc#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Style --->
    <TR>
    <TD valign="top"> Style: </TD>
    <TD>
	
		<CFOUTPUT>#Form.Style#</CFOUTPUT>
	
	</TD>
	</TR>


    <!--- Field: BSA_Foodservice_Items_Master.Deleted --->
    <TR>
    <TD valign="top"> Deleted: </TD>
    <TD>
	
		<CFIF Form.Deleted is 1> Yes <CFELSE> No </CFIF>
	
	</TD>
	</TR>

</TABLE>


</BODY></HTML>
