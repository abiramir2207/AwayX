<cfset useLakebaseForGetFamilyNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetFamilyNames>
	<cftry>
		<cfset GetFamilyNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"select" = "family_name"
			}), "family_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFamilyNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFamilyNames>
<cfquery name="GetFamilyNames" datasource="#application.datasource#">
	SELECT DISTINCT Family_Name
	FROM BSA_Foodservice_Customers
</cfquery>
</cfif>

<cfset useLakebaseForGetBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForGetBrokers>
	<cftry>
		<cfset GetBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_brokers", {
				"order" = "broker_name.asc",
				"select" = "broker_legcy_shard,broker_name"
			}), "broker_legcy_shard,broker_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokers>
<cfquery name="GetBrokers" datasource="#application.datasource#">
	SELECT DISTINCT Broker_Legcy_Shard, Broker_Name
	FROM BSA_Foodservice_Brokers
	ORDER BY Broker_Name
</cfquery>
</cfif>

<cfset useLakebaseForGetStates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetStates>
	<cftry>
		<cfset GetStates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"select" = "state"
			}), "state"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStates>
<cfquery name="GetStates" datasource="#application.datasource#">
	SELECT DISTINCT State
	FROM BSA_Foodservice_Customers
</cfquery>
</cfif>

<cfquery name="GetBrokers" datasource="#application.datasource#">
	SELECT DISTINCT Market_Area, Broker_Legcy_Shard, Broker_Name
	FROM BSA_Foodservice_Brokers
	ORDER BY Market_Area
</cfquery>

<BR><BR>

<CENTER>
<FIELDSET STYLE="padding:10px; width: 1%; border: 1px solid Orange;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">search <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></LEGEND>

<BR><BR>
				
<FORM NAME="SearchForm">
	<TABLE CELLPADDING="0" CELLSPACING="25" BORDER="0">
		<TR>
			<TD>
				<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
				<SELECT NAME="Family_Name" style="width: 200px;">
					<OPTION VALUE="0">**ALL** Family Names</OPTION>
					<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_Name)#">#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
			<TD>
				<CFPARAM NAME="FORM.Broker" DEFAULT="0">
				<SELECT NAME="Broker" style="width: 190px;">
					<OPTION VALUE="0">**ALL** Brokers</OPTION>
					<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.Broker_Legcy_Shard)#">#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
				</SELECT>	
			</TD>
			</tr><tr>
			<TD>
				<CFPARAM NAME="FORM.State" DEFAULT="0">
				<SELECT NAME="State" style="width: 182px;">
					<OPTION VALUE="0">**ALL** States</OPTION>
					<CFOUTPUT QUERY="GetStates"><OPTION VALUE="#trim(GetStates.state)#"><CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state)#</CFIF></OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
			<TD>
				<CFPARAM NAME="FORM.Market_Area" DEFAULT="0">
				<SELECT NAME="Market_Area" style="width: 190px;">
					<OPTION VALUE="0">**ALL** Broker Market Areas</OPTION>
					<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.Market_Area)#">#trim(GetBrokers.Market_Area)#</OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2">
				Search String:
				<BR>
				<INPUT TYPE="Text" NAME="searchstring" SIZE="57" VALUE="">
				<br><br>
<!--- 
				<INPUT TYPE="button" VALUE="Search..." STYLE="width:100px;" ONCLICK="opener.transportFormElementsFromPopupToParentPage()">
 --->
				<INPUT TYPE="image" NAME="Button" SRC="/images/search_button.gif"  ONCLICK="opener.transportFormElementsFromPopupToParentPage()">
				
				
			</TD>
		</TR>
	</TABLE>
</FORM>


</FIELDSET>
</CENTER>


	
<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>
