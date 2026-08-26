<HTML><HEAD>
	<TITLE>Product_Creationn_Entry - Entry Form</TITLE>
</HEAD><BODY bgcolor="#FFFFFF">






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type groups																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetTypeGroupDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	Select	distinct
			Type_Group,
			Type_Group_Desc
	From	BSA_Foodservice_Items_Master
	Where	Type_Group in (Select distinct Type_Group from BSA_Foodservice_Items_Master)
</CFQUERY>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get QBrands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetQBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Q_brand_desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get type codes																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetTypeCodeDesc" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Type_Code_Desc
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get brands																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="GetBrands" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Brand
	FROM BSA_Foodservice_Items_Master
	WHERE deleted = 0
</CFQUERY>











<FORM action="Product_Creation_Entry_Action.cfm" method="post">
<TABLE>
    <TR>
    <TD ALIGN="right"><B>Item Number:</B></TD>
    <TD>
		<INPUT type="text" name="Item" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>UPC Code:</B></TD>
    <TD>
		<INPUT type="text" name="UPC" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Case Count:</B></TD>
    <TD>
		<INPUT type="text" name="Case_Count" maxLength="8">
	</TD>
	<INPUT type="hidden" name="Case_Count_float">
	</TR>
    <TR>
    <TD ALIGN="right"><B>Pack Size:</B></TD>
    <TD>
		<INPUT type="text" name="Pack_Size" maxLength="8">
	</TD>
	<INPUT type="hidden" name="Pack_Size_float">
	</TR>
    <TR>
    <TD ALIGN="right"><B>Pack Size UOM:</B></TD>
    <TD>
		<INPUT type="text" name="Pack_Size_UOM" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Description:</B></TD>
    <TD>
		<INPUT type="text" name="Description" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Brand:</B></TD>
    <TD>
		<SELECT NAME="Brand">
			<OPTION VALUE="All">**ALL** Brands</OPTION>
			<CFOUTPUT QUERY="GetBrands"><OPTION VALUE="#Brand#">#Brand#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Net Weight:</B></TD>
    <TD>
		<INPUT type="text" name="Net_Weight" maxLength="8">
	</TD>
	<INPUT type="hidden" name="Net_Weight_float">
	</TR>
    <TR>
    <TD ALIGN="right"><B>Order UOM:</B></TD>
    <TD>
		<INPUT type="text" name="Order_UoM" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Inventory UOM:</B></TD>
    <TD>
		<INPUT type="text" name="Inven_UoM" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Q Brand:</B></TD>
    <TD>
		<INPUT type="text" name="Q_Brand" maxLength="510">
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Q Brand:</B></TD>
    <TD>
		<SELECT NAME="Q_Brand_Desc">
			<OPTION VALUE="All">**ALL** Q Brand Descriptions</OPTION>
			<CFOUTPUT QUERY="GetQBrands"><OPTION VALUE="#Q_Brand_Desc#">#Q_Brand_Desc#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Type Code:</B></TD>
    <TD>
		<INPUT type="text" name="Type_Code" maxLength="8">
	</TD>
	<INPUT type="hidden" name="Type_Code_float">
	</TR>
    <TR>
    <TD ALIGN="right"><B>Type Code Description:</B></TD>
    <TD>
		<SELECT NAME="Type_Code_Desc">
			<OPTION VALUE="All">**ALL** Type Code Descriptions</OPTION>
			<CFOUTPUT QUERY="GetTypeCodeDesc"><OPTION VALUE="#Type_Code_Desc#">#Type_Code_Desc#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Type Group:</B></TD>
    <TD>
		<INPUT type="text" name="Type_Group" maxLength="8">
	</TD>
	<INPUT type="hidden" name="Type_Group_float">
	</TR>
    <TR>
    <TD ALIGN="right"><B>LEVEL I-Type Group Desc:</B></TD>
    <TD>
		<SELECT NAME="Type_Group_Desc">
			<OPTION VALUE="All">**ALL** Type Group Descriptions</OPTION>
			<CFOUTPUT QUERY="GetTypeGroupDesc"><OPTION VALUE="#Type_Group#">#trim(Type_Group_Desc)#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	</TR>
    <TR>
    <TD ALIGN="right"><B>Style:</B></TD>
    <TD>
		<INPUT type="text" name="Style" maxLength="8">
	</TD>
	<INPUT type="hidden" name="Style_float">
	</TR>
</TABLE>

<INPUT type="hidden" name="Deleted" value="0">

<P>
<INPUT type="submit" value="Insert Data">

</FORM>


</BODY></HTML>
