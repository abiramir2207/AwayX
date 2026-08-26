<CFSET PageTitle="#ucase(application.returned_customer_setting.broker_label_plural)#: ADD #ucase(application.returned_customer_setting.broker_label_singular)#">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=30>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->

<CFPARAM NAME="URL.Broker_ID"				DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS" 				DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_2" 				DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_CITY" 			DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_STATE" 			DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_ZIP" 			DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_Country_Code" 	DEFAULT="">
<CFPARAM NAME="FORM.BROKER_CSR" 			DEFAULT="">
<CFPARAM NAME="FORM.BROKER_EMAIL" 			DEFAULT="">
<CFPARAM NAME="FORM.BROKER_NAME" 			DEFAULT="">
<CFPARAM NAME="FORM.LINE_OF_BUSINESS" 		DEFAULT="">
<CFPARAM NAME="FORM.ACCOUNT_EXEC" 			DEFAULT="">
<CFPARAM NAME="FORM.PHONE_1" 				DEFAULT="">
<CFPARAM NAME="FORM.PHONE_2" 				DEFAULT="">
<CFPARAM NAME="FORM.PHONE_3" 				DEFAULT="">
<CFPARAM NAME="FORM.PHONE_EXT" 				DEFAULT="">
<CFPARAM NAME="FORM.FAX_1" 					DEFAULT="">
<CFPARAM NAME="FORM.FAX_2" 					DEFAULT="">
<CFPARAM NAME="FORM.FAX_3" 					DEFAULT="">
<CFPARAM NAME="FORM.REGION_SHARD" 			DEFAULT="">
<CFPARAM NAME="FORM.REGION_LEGCY_SHARD" 	DEFAULT="">
<CFPARAM NAME="FORM.ZONE_SHARD" 			DEFAULT="">
<CFPARAM NAME="FORM.ZONE_LEGCY_SHARD"	 	DEFAULT="">
<CFPARAM NAME="FORM.MARKET_AREA_ID" 		DEFAULT="">
<CFPARAM NAME="FORM.BROKER_SHARD" 			DEFAULT="">
<CFPARAM NAME="FORM.BROKER_LEGCY_SHARD" 	DEFAULT="">
<CFPARAM NAME="FORM.BROKER_ID" 				DEFAULT="">
<CFPARAM NAME="FORM.UPDATERECORD" 			DEFAULT="0">
<CFPARAM NAME="FORM.Region_ID"				DEFAULT="0">
<CFPARAM NAME="FORM.Zone_ID"				DEFAULT="0">

<CFIF len(URL.Broker_ID) GT 0>
	<CFQUERY NAME="getBrokerInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Brokers
		WHERE BSA_Foodservice_Brokers_ID = '#URL.Broker_ID#'
	</CFQUERY>

	<CFIF getBrokerInfo.Recordcount GT 0>
		<CFSET FORM.UPDATERECORD			= "1">
		<CFSET FORM.BROKER_NAME 			= "#trim(getBrokerInfo.BROKER_NAME)#">
		<CFSET FORM.ADDRESS 				= "#trim(getBrokerInfo.ADDRESS)#">
		<CFSET FORM.ADDRESS_2 				= "#trim(getBrokerInfo.ADDRESS_2)#">
		<CFSET FORM.ADDRESS_CITY 			= "#trim(getBrokerInfo.CITY)#">
		<CFSET FORM.ADDRESS_STATE			= "#trim(getBrokerInfo.STATE)#">
		<CFSET FORM.ADDRESS_ZIP				= "#trim(getBrokerInfo.ZIP)#">
		<CFSET FORM.Country_Code			= "#trim(getBrokerInfo.Country_Code)#">
		<CFSET FORM.BROKER_CSR 				= "#trim(getBrokerInfo.BROKER_CSR)#">
		<CFSET FORM.BROKER_EMAIL 			= "#trim(getBrokerInfo.E_MAIL)#">
		<CFSET FORM.LINE_OF_BUSINESS 		= "#trim(getBrokerInfo.LINE_OF_BUSINESS)#">
		<CFSET FORM.ACCOUNT_EXEC 			= "#trim(getBrokerInfo.ACCOUNT_EXEC)#">
		<CFSET FORM.PHONE_1 				= "#trim(getBrokerInfo.PHONE_1)#">
		<CFSET FORM.PHONE_2					= "#trim(getBrokerInfo.PHONE_2)#">
		<CFSET FORM.PHONE_3 				= "#trim(getBrokerInfo.PHONE_3)#">
		<CFSET FORM.PHONE_EXT 				= "#trim(getBrokerInfo.PHONE_EXT)#">
		<CFSET FORM.FAX_1 					= "#trim(getBrokerInfo.FAX_1)#">
		<CFSET FORM.FAX_2					= "#trim(getBrokerInfo.FAX_2)#">
		<CFSET FORM.FAX_3 					= "#trim(getBrokerInfo.FAX_3)#">
		<CFSET FORM.REGION_SHARD 			= "#trim(getBrokerInfo.REGION_SHARD)#">
		<CFSET FORM.REGION_LEGCY_SHARD 		= "#trim(getBrokerInfo.REGION_LEGCY_SHARD)#">
		<CFSET FORM.ZONE_SHARD				= "#trim(getBrokerInfo.ZONE_SHARD)#">
		<CFSET FORM.ZONE_LEGCY_SHARD		= "#trim(getBrokerInfo.ZONE_LEGCY_SHARD)#">
		<CFSET FORM.MARKET_AREA_ID 			= "#trim(getBrokerInfo.Service_Market_ID)#">
		<CFSET FORM.BROKER_SHARD 			= "#trim(getBrokerInfo.BROKER_SHARD)#">
		<CFSET FORM.BROKER_LEGCY_SHARD 		= "#trim(getBrokerInfo.BROKER_LEGCY_SHARD)#">
		<CFSET FORM.BROKER_ID 				= "#trim(getBrokerInfo.BSA_Foodservice_Brokers_ID)#">
		<CFSET FORM.Region_ID				= "#trim(getBrokerInfo.Service_Region_ID)#">
		<CFSET FORM.Zone_ID					= "#trim(getBrokerInfo.Service_Zone_ID)#">
	</CFIF>

</CFIF>

<CFQUERY NAME="getStates" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>

<CFQUERY NAME="getMarketAreas" datasource="#application.datasource#">
	SELECT *
	FROM Service_Markets
	WHERE Deleted = 0
	<cfif application.returned_customer_setting.allow_MA_to_more_than_one_broker EQ 0>
		AND NOT EXISTS(SELECT Service_Market_ID FROM BSA_Foodservice_Brokers WHERE BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID AND Deleted = 0)
	</cfif>
	ORDER BY Market_Name ASC
</CFQUERY>

<BODY BGCOLOR="WhiteSmoke">

<STYLE TYPE="text/css">
.labelStyle {
	text-align : right;
	font-weight: bold;
}
</STYLE>

	<SCRIPT SRC="/script/javascript/string_functions.js">
		<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
	</SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/numberValidation.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>
		<CF_MessageWindow>
	<SCRIPT>
		function verifyData(){
			ErrorCount = 0;

 			<CFIF FORM.UPDATERECORD EQ 0>
			//BROKER NAME
			if(document.all.Broker_Name.value.length == 0){
				ErrorCount++;
				queueMessage("Enter The Brokers Name", document.all.error_BrokerName);
			}
			else{
				clearQueue(document.all.error_BrokerName);
			}

			//BROKER ID Shared
			if(document.all.Broker_Shard.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Broker ID", document.all.error_BrokerShard);
			}
			else{
				clearQueue(document.all.error_BrokerShard);
			}
			</CFIF>

<!---
 			//BROKER ID Legacy
			if(document.all.Broker_Legcy_Shard.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Legacy Broker ID", document.all.error_BrokerLegacy);
			}
			else{
				clearQueue(document.all.error_BrokerLegacy);
			}

 			//Region ID Shared
			if(document.all.Region_Shard.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Shared Region ID", document.all.error_RegionShard);
			}
			else{
				clearQueue(document.all.error_RegionShard);
			}

 			//Region ID Legacy
			if(document.all.Region_Legcy_Shard.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Legacy Region ID", document.all.error_RegionLegacy);
			}
			else{
				clearQueue(document.all.error_RegionLegacy);
			}

 			//Zone ID Shared
			if(document.all.Zone_Shard.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Shared Zone ID", document.all.error_ZoneShard);
			}
			else{
				clearQueue(document.all.error_ZoneShard);
			}

 			//Zone ID Legacy
			if(document.all.Zone_Legcy_Shard.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Legacy Zone ID", document.all.error_ZoneLegacy);
			}
			else{
				clearQueue(document.all.error_ZoneLegacy);
			}
--->

			<CFIF FORM.UPDATERECORD EQ 0>
			//Address 1
			if(document.all.Address.value.length == 0){
				ErrorCount++;
				queueMessage("Enter An Address 1", document.all.error_Address_1);
			}
			else{
				clearQueue(document.all.error_Address_1);
			}

 			//City
			if(document.all.Address_City.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A City", document.all.error_City);
			}
			else{
				clearQueue(document.all.error_City);
			}

 			//Zip
			if(document.all.Address_Zip.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Postal Code", document.all.error_Zip);
			}
			else{
				clearQueue(document.all.error_Zip);
			}
			</CFIF>


<!--- DEV NOTE: DAA - D14334
			//Broker CSR
			if(document.all.Broker_CSR.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Broker CSR Person", document.all.error_BrokerCSR);
			}
			else{
				clearQueue(document.all.error_BrokerCSR);
			}

			//Broker E-mail
			if(document.all.Broker_Email.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Broker E-Mail Address", document.all.error_BrokerEmail);
			}
			else{
				clearQueue(document.all.error_BrokerEmail);
			}
 --->


			<CFIF FORM.UPDATERECORD EQ 0>
<!---  			//Line Of Buisness
			if(document.all.Line_Of_Business.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Line Of Business", document.all.error_LineOfBiz);
			}
			else{
				clearQueue(document.all.error_LineOfBiz);
			}  --->

 			//Account Exec
			if(document.all.Account_Exec.value.length == 0){
				ErrorCount++;
				queueMessage("Enter An Account Exec", document.all.error_AccountExec);
			}
			else{
				clearQueue(document.all.error_AccountExec);
			}

 			//Phone
			if(document.all.Phone_1.value.length != 3 || document.all.Phone_2.value.length != 3 || document.all.Phone_3.value.length != 4){
				ErrorCount++;
				queueMessage("Enter A Valid Phone Number", document.all.error_Phone);
			}
			else{
				clearQueue(document.all.error_Phone);
			}
			</CFIF>
			//Fax
			if(document.all.Fax_1.value.length != 3 || document.all.Fax_2.value.length != 3 || document.all.Fax_3.value.length != 4){
				ErrorCount++;
				queueMessage("Enter A Valid Fax Number", document.all.error_Fax);
			}
			else{
				clearQueue(document.all.error_Fax);
			}

			//Region
			if(document.all.Region_ID.selectedIndex == 0){
				ErrorCount++;
				queueMessage("Select A Region", document.all.error_RegionLegacy);
			}
			else{
				clearQueue(document.all.error_RegionLegacy);
			}

			//Zone
			if(document.all.Zone_ID.selectedIndex == 0){
				ErrorCount++;
				queueMessage("Select A Zone", document.all.error_ZoneLegacy);
			}
			else{
				clearQueue(document.all.error_ZoneLegacy);
			}


			//Market Area
			if(document.all.Market_Area_ID.selectedIndex == 0){
				ErrorCount++;
				queueMessage("Select A Market Area", document.all.error_MarketArea);
			}
			else{
				clearQueue(document.all.error_MarketArea);
			}

			if(ErrorCount == 0){
				document.all.MyForm.submit();
			}
			else {
				showMessageWindow()
			}
		}

	</SCRIPT>

	<FORM ACTION="brokers_create_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<CFOUTPUT>
	<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center">
		<TR>
			<TD>
				<TABLE BORDER="0">
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_BrokerName"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput> Name</TD>
						<TD ROWSPAN="100%" BGCOLOR="Navy"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<TD><INPUT NAME="Broker_Name" VALUE="#FORM.Broker_Name#" TYPE="text" SIZE="40"></TD>
						<CFELSE>
							<TD>#FORM.Broker_Name#</TD>
						</CFIF>


					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_BrokerShard"></SPAN>&nbsp;<SPAN ID="error_BrokerLegacy"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput> ID</TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<TD><INPUT NAME="Broker_Shard" VALUE="#FORM.Broker_Shard#" TYPE="text" SIZE="7" onKeyUp="clenseText(this, '0123456789')"><!---  - <INPUT NAME="Broker_Legcy_Shard" VALUE="#FORM.Broker_Legcy_Shard#" TYPE="text" SIZE="7"> ---></TD>
						<CFELSE>
							<TD>#FORM.Broker_Shard#</TD>
						</CFIF>
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_Address_1"></SPAN>&nbsp;Address 1</TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<TD><INPUT NAME="Address" VALUE="#FORM.Address#" TYPE="text" SIZE="40"></TD>
						<CFELSE>
							<TD>#FORM.Address#</TD>
						</CFIF>
					</TR>

					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_"></SPAN>&nbsp;Address 2</TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<TD><INPUT NAME="Address_2" VALUE="#FORM.Address_2#" TYPE="text" SIZE="40"></TD>
						<CFELSE>
							<TD>#FORM.Address_2#</TD>
						</CFIF>
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_City"></SPAN>&nbsp;<SPAN ID="error_Zip"></SPAN>&nbsp;City/State/Postal</TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<TD><INPUT NAME="Address_City" VALUE="#FORM.Address_City#" VALUE="#FORM.ADDRESS_CITY#" TYPE="text"><SELECT NAME="Address_State"><CFLOOP QUERY="getStates"><OPTION VALUE="#getStates.State_ID#" <CFIF getStates.State_ID EQ FORM.ADDRESS_STATE> SELECTED</CFIF>>#getStates.State_Code#</OPTION></CFLOOP></SELECT>, <INPUT NAME="Address_Zip" VALUE="#FORM.ADDRESS_ZIP#" TYPE="text" SIZE="4" MAXLENGTH="10"></TD><!---  onKeyUp="nextBox(this, 'NONE');" --->
						<CFELSE>
							<TD>#FORM.Address_City# #FORM.ADDRESS_STATE#, #FORM.ADDRESS_ZIP#&nbsp;#FORM.Country_Code#</TD>
						</CFIF>
					</TR>

					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_LineOfBiz"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.lob_label_singular#</cfoutput></TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<CFQUERY NAME="getLOBFoodserviceTitle" datasource="#application.datasource#">
								SELECT Line_Of_Business_Name, Line_Of_Business_ID
								FROM Line_Of_Business
								WHERE DELETED = 0
								AND Line_Of_Business = 'F'
							</CFQUERY>
							<TD>#getLOBFoodserviceTitle.Line_Of_Business_Name#<input TYPE="Hidden" NAME="Line_Of_Business_ID" VALUE="#getLOBFoodserviceTitle.Line_Of_Business_ID#"><!--- <INPUT NAME="Line_Of_Business" VALUE="#FORM.Line_Of_Business#" TYPE="text" SIZE="40"> ---></TD>
						<CFELSE>
							<TD>#FORM.Line_Of_Business#</TD>
						</CFIF>
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_AccountExec"></SPAN>&nbsp;Account Exec</TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<TD><INPUT NAME="Account_Exec" VALUE="#FORM.Account_Exec#" TYPE="text" SIZE="40"></TD>
						<CFELSE>
							<TD>#FORM.Account_Exec#</TD>
						</CFIF>
						<!--- Tim Ford - Label D25955 Adding Broker CSR and Email back to the form 
						<INPUT NAME="Broker_CSR" VALUE="#FORM.Broker_CSR#" TYPE="hidden" SIZE="40">
						<INPUT NAME="Broker_Email" VALUE="#FORM.Broker_Email#" TYPE="hidden" SIZE="40">
						--->
					</TR>
<!--- DEV NOTE: DAA - D14334 Tim Ford - Label D25955 Adding Broker CSR and Email back to the form --->
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_BrokerCSR"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput> CSR</TD>
						<TD><INPUT NAME="Broker_CSR" VALUE="#FORM.Broker_CSR#" TYPE="text" SIZE="40"></TD>
					</TR>
					<TR valign="top">
						<TD CLASS="labelStyle"><SPAN ID="error_BrokerEmail"></SPAN>&nbsp;E-Mail</TD>
						<TD><INPUT NAME="Broker_Email" VALUE="#FORM.Broker_Email#" TYPE="text" SIZE="40">
						<br>
						<FONT COLOR="##FF0000" SIZE="1"><B>separate multiple email addresses with semi-colon (;) or comma (,)</B></FONT>
						</TD>
					</TR>

					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_Phone"></SPAN>&nbsp;Phone</TD>
						<TD>
						<CFIF FORM.UPDATERECORD EQ 0>
							<INPUT NAME="Phone_1" VALUE="#FORM.Phone_1#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Phone_2" VALUE="#FORM.Phone_2#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Phone_3" VALUE="#FORM.Phone_3#" TYPE="text" SIZE="2" MAXLENGTH="4" onKeyUp="nextBox(this, 'NONE');">&nbsp;Ext.<INPUT NAME="Phone_Ext" VALUE="#FORM.Phone_Ext#" TYPE="text" SIZE="2" onKeyUp="nextBox(this, 'NONE');">
						<CFELSE>
							#FORM.Phone_1#-#FORM.Phone_2#-#FORM.Phone_3# <CFIF len(FORM.Phone_Ext) GT 0>&nbsp;Ext.#FORM.Phone_Ext#</CFIF><INPUT TYPE="Hidden" NAME="Phone_1" VALUE="#FORM.Phone_1#"><INPUT TYPE="Hidden" NAME="Phone_1" VALUE=""><INPUT TYPE="Hidden" NAME="Phone_2" VALUE="#FORM.Phone_2#"><INPUT TYPE="Hidden" NAME="Phone_3" VALUE="#FORM.Phone_3#"><INPUT TYPE="Hidden" NAME="Phone_Ext" VALUE="#FORM.Phone_Ext#">
						</CFIF>
						</TD>
						<!--- <TD><INPUT NAME="Phone_1" VALUE="#FORM.Phone_1#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Phone_2" VALUE="#FORM.Phone_2#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Phone_3" VALUE="#FORM.Phone_3#" TYPE="text" SIZE="2" MAXLENGTH="4" onKeyUp="nextBox(this, 'NONE');">&nbsp;Ext.<INPUT NAME="Phone_Ext" VALUE="#FORM.Phone_Ext#" TYPE="text" SIZE="2" onKeyUp="nextBox(this, 'NONE');"></TD> --->
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_Fax"></SPAN>&nbsp;Fax</TD>
						<TD><INPUT NAME="Fax_1" VALUE="#FORM.Fax_1#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Fax_2" VALUE="#FORM.Fax_2#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Fax_3" VALUE="#FORM.Fax_3#" TYPE="text" SIZE="2" MAXLENGTH="4" onKeyUp="nextBox(this, 'NONE');"></TD>
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_RegionShard"></SPAN>&nbsp;<SPAN ID="error_RegionLegacy"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput></TD>
						<cfif FORM.UPDATERECORD EQ 1 AND FORM.Region_ID eq "">
							&nbsp;<input NAME="Region_ID" TYPE="Hidden" VALUE="#FORM.Region_ID#">
						<cfelse>
							<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
								SELECT *
								FROM Service_Regions
								WHERE len(Region_Name) != 0 <CFIF FORM.UPDATERECORD EQ 1>AND Service_Region_ID = '#FORM.Region_ID#'</CFIF>
								ORDER BY Region_Name
							</CFQUERY>
							<TD>
							<CFIF FORM.UPDATERECORD EQ 0>
								<SELECT NAME="Region_ID" style="width: 190px;">
								<OPTION VALUE="0">Select One...</OPTION>
								<CFLOOP QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFLOOP>
								</SELECT>
							<CFELSE>
								#GetRegions.Region_Name#<input NAME="Region_ID" TYPE="Hidden" VALUE="#FORM.Region_ID#">
							</CFIF>
							</TD>
						</cfif>
						<!--- <TD><INPUT NAME="Region_Shard" VALUE="#FORM.Region_Shard#" TYPE="text" SIZE="7"> - <INPUT NAME="Region_Legcy_Shard" VALUE="#FORM.Region_Legcy_Shard#" TYPE="text" SIZE="7"></TD> --->
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_ZoneShard"></SPAN>&nbsp;<SPAN ID="error_ZoneLegacy"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.zone_label_singular#</cfoutput></TD>
						<cfif FORM.UPDATERECORD EQ 1 AND FORM.Zone_ID eq "">
							&nbsp;<input NAME="Zone_ID" TYPE="Hidden" VALUE="#FORM.Zone_ID#">
						<cfelse>
							<CFQUERY NAME="GetZones" datasource="#application.datasource#">
							SELECT *
							FROM Service_Zones
							WHERE len(Zone_Name) != 0 <CFIF FORM.UPDATERECORD EQ 1>AND Service_Zone_ID = '#FORM.Zone_ID#'</CFIF>
							ORDER BY Zone_Name
							</CFQUERY>
							<TD>
							<CFIF FORM.UPDATERECORD EQ 0>
								<SELECT NAME="Zone_ID" style="width: 190px;">
									<OPTION VALUE="0">Select One...</OPTION>
									<CFLOOP QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFLOOP>
								</SELECT>
							<CFELSE>
								#GetZones.Zone_Name#<input NAME="Zone_ID" TYPE="Hidden" VALUE="#FORM.Zone_ID#">
							</CFIF>
							</TD>
						</cfif>
						<!--- <TD><INPUT NAME="Zone_Shard" VALUE="#FORM.Zone_Shard#" TYPE="text" SIZE="7"> - <INPUT NAME="Zone_Legcy_Shard" VALUE="#FORM.Zone_Legcy_Shard#" TYPE="text" SIZE="7"></TD> --->
					</TR>
					<TR>
						<TD CLASS="labelStyle"><SPAN ID="error_MarketArea"></SPAN>&nbsp;<cfoutput>#application.returned_customer_setting.market_label_singular#</cfoutput> Area</TD>
						<TD><SELECT NAME="Market_Area_ID"><OPTION VALUE="0">Select One...</OPTION><CFLOOP QUERY="getMarketAreas"><OPTION VALUE="#getMarketAreas.Service_Market_ID#" <CFIF getMarketAreas.Service_Market_ID EQ FORM.Market_Area_ID> SELECTED</CFIF>>#getMarketAreas.Market_Name#</OPTION></CFLOOP></SELECT></TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD style="padding-left:200;">
				<br /><br />
				<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"save"
					BUTTON_ACTION	=	"javascript:verifyData();"
					BUTTON_TYPE		=	"link"
					BUTTON_WIDTH	=	"150"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">
			</TD>
		</TR>
	</TABLE>



	<INPUT NAME="UPDATERECORD" TYPE="Hidden" VALUE="#FORM.UPDATERECORD#">
	<INPUT NAME="Broker_ID" TYPE="Hidden" VALUE="#URL.Broker_ID#">
	</CFOUTPUT>
	</FORM>

</BODY>


