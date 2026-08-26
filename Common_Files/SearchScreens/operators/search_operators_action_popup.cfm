

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#">
Select	distinct Operator_Location_Type
From	BSA_Operator
Where	deleted = 0
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
   <!---------------------------------------------------------------------------- 
    Dev Notes: D19761 -Anand Rao 07/28/09
    Changed to query to have a where clause to look for active = 1 and 
    Deleted = 0 and pick the records from awayx_Operator_type table
 ------------------------------------------------------------------------------>
<CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#">
  SELECT	Distinct Operator_Type
  FROM awayX_Operator_Type
  WHERE Active = 1 AND Deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>
<Form Name="SearchForm">

<BR><BR>

<CENTER>
<FIELDSET STYLE="padding:0px; width: 1%; border: 1px solid Orange;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> search</LEGEND>



<TABLE CELLPADDING="0" CELLSPACING="25" BORDER="0">
	<TR>
		<TD>
			<B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name:</B><BR>
			<INPUT TYPE="text" NAME="Operator_Name" STYLE="width:	200px; font-size: 10px;">
		</TD>
		<TD>
			<B>Doing business as:</B><BR>
			<INPUT TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510" STYLE="width:	200px; font-size: 10px;">
		</TD>
	</TR>
	<TR>
		<TD>
			<B>City:</B><BR>
			<INPUT TYPE="Text" NAME="Operator_City" MAXLENGTH="510" STYLE="width:	200px; font-size: 10px;">
		</TD>
		<TD>
			<B>Type of <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</B><BR>
			<SELECT NAME="Operator_Type" STYLE="width:	200px; font-size: 10px;">
			<OPTION VALUE="All" SELECTED>Select <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Type</OPTION>
			<OPTION VALUE="All">All types</OPTION>
			<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#">#Operator_Type#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD>
			<B>Location Type:</B><BR>
			<SELECT NAME="Operator_Location_Type" STYLE="width:	200px; font-size: 10px;">
			<OPTION VALUE="All" SELECTED>Select Location Types</OPTION>
			<OPTION VALUE="All">All Location Types</OPTION>
			<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#">#Operator_Location_Type#</OPTION></CFOUTPUT>
			</SELECT>	
		</TD>
		<TD>
			<B>State:</B><BR>
			<SELECT NAME="Operator_State" STYLE="width:	200px; font-size: 10px;">
			<OPTION VALUE="All" SELECTED>Select State</OPTION>
			<OPTION VALUE="All">Any State</OPTION>
			<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#">#State_Name#</OPTION></CFOUTPUT>
			</SELECT>	
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
		<br>
		Search String:<BR>
		<INPUT TYPE="Text" NAME="searchstring" SIZE="57" VALUE="">
		<BR><BR>
		<!--- 
		<INPUT TYPE="button" VALUE="Search..." STYLE="width:100px;" ONCLICK="opener.transportFormElementsFromPopupToParentPage()">
		 --->
		<INPUT TYPE="image" NAME="Button" SRC="/images/search_button.gif" ONCLICK="opener.transportFormElementsFromPopupToParentPage()">
		</TD>
	</TR>

</TABLE>


</form>

</FIELDSET>
</CENTER>

<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>

