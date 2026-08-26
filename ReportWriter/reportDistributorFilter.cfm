<!---%%%%%%%%% initialization %%%%%%%%%%%%%%%%---->
	<CFPARAM name="FORM.button_caption"					default="continue">
	<CFPARAM NAME="FORM.searchstring" 					DEFAULT="">
	<CFPARAM NAME="FORM.SelectedITEMS" 					DEFAULT="">
	<CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
	<CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
	<CFPARAM NAME="FORM.finishedselectingitems" 		DEFAULT="0">
	<CFPARAM NAME="FORM.LoadSavedDistributors"			Default="1">
	<CFPARAM NAME="Form.editcurrentweight"				Default="0">
	<CFPARAM NAME="FORM.Distributor_Status" 			DEFAULT="A">
	<CFPARAM NAME="Form.Ship_To" 						DEFAULT="">
	<CFPARAM NAME="FORM.sort_Order" 					DEFAULT="ASC1">
	<CFPARAM NAME="FORM.Family_Name" 					DEFAULT="">
	<CFPARAM NAME="FORM.Buying_Group" 					DEFAULT="">
	<CFPARAM NAME="FORM.Line_Of_Biz" 					DEFAULT="0">
	<CFPARAM NAME="FORM.Zone_ID"						DEFAULT="0"> 		
	<CFPARAM NAME="FORM.Region_ID"						DEFAULT="0"> 		
	<CFPARAM NAME="FORM.Family_Name_Text"				DEFAULT="">
	<CFPARAM NAME="FORM.Zone_Name_Text"					DEFAULT="">
	<CFPARAM NAME="FORM.Region_Name_Text"					DEFAULT="">
	<CFPARAM NAME="FORM.Buying_Group_Text"				DEFAULT="">
	<CFPARAM NAME="Line_Of_Business"					DEFAULT="0">
	<CFPARAM NAME="ZONE_NAME" 							DEFAULT="">
	<CFPARAM NAME="REGION_NAME" 						DEFAULT=""> 
	<CFPARAM NAME="BROKER_NAME" 						DEFAULT="">  
	 
	
	<SCRIPT language="JavaScript" src="invoiceCommon.js"></SCRIPT>
	<!---- Query information ---->
	<cfquery name="GetFamilyNames" datasource="#application.datasource#">
		SELECT *
		FROM Distributor_Family
		WHERE Deleted = 0
		ORDER BY Family_Name
	</cfquery>
	<!--- Buying Groups --->
	<cfquery name="GetBuyingGroups" datasource="#application.datasource#">
		SELECT *
		FROM Distributor_Buying_Groups
		WHERE Deleted = 0
		ORDER BY Buying_Group_Name
	</cfquery>
	<!--- Zone --->
	<CFQUERY NAME="GetZones" datasource="#application.datasource#">
		SELECT distinct *
		FROM Service_Zones
		WHERE len(Zone_Name) != 0 AND Deleted = 0
		ORDER BY Zone_Name
	</CFQUERY>
	<!--- Regions --->
	<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
		SELECT distinct *
		FROM Service_Regions
		WHERE len(Region_Name) != 0 AND Deleted = 0
		ORDER BY Region_Name
	</CFQUERY>

	<!--- hidden variables --->
		<INPUT TYPE="Hidden" NAME="Family_Name_Text" ID="Family_Name_Text" VALUE=""> 
		<INPUT TYPE="Hidden" NAME="Buying_Group_Text" ID="Buying_Group_Text" VALUE="">	
		<INPUT TYPE="Hidden" NAME="Region_Name_Text" ID="Region_Name_Text" VALUE=""> 
		<INPUT TYPE="Hidden" NAME="Zone_Name_Text" ID="Zone_Name_Text" VALUE="">	
	<!-----  Distributor Filter --->
	<cfoutput>
		<DIV ID="filterDistributor" STYLE="visibility:visible;"  <!---ALIGN="center"--->>
			<FIELDSET STYLE="padding:10px; border: 5px outset LightGrey;">
			    <LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;">#application.returned_customer_setting.distributor_label_plural# Criteria</LEGEND>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="5" STYLE="background-color: ##F0F8FF;">
						<TR>
							<TD COLSPAN="1">
								<span ID="searchItemLabel">#application.returned_customer_setting.zone_label_singular#</span><BR>
								<SELECT NAME="Zone_ID" style="width: 200px;" ONCHANGE="javascript:set_hidden_value(document.MyInvoiceForm.Zone_Name_Text, document.MyInvoiceForm.Zone_ID);">
									<OPTION VALUE="0">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION>
									<cfloop query="GetZones"><OPTION VALUE="#trim(Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ "#trim(Service_Zone_ID)#", DE(" SELECTED"), DE(""))#>#trim(Zone_Name)#</OPTION></cfloop>
								</SELECT>	
							</TD>
							<TD>
								<span ID="searchItemLabel">#application.returned_customer_setting.region_label_singular#</span><BR>
								<SELECT NAME="Region_ID" style="width: 200px;" ONCHANGE="javascript:set_hidden_value(document.MyInvoiceForm.Region_Name_Text, document.MyInvoiceForm.Region_ID);">
									<OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION>
									<cfloop query="GetRegions"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ "#trim(Service_Region_ID)#", DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></cfloop>
								</SELECT>	
							</TD>		
							<TD>
								<span ID="searchItemLabel">#application.returned_customer_setting.shard_ship_to_label#</span><BR>
								<INPUT SIZE="7" TYPE="TEXT" NAME="Ship_To" VALUE="#Form.Ship_To#">
							</TD>
		 				</TR>
						<TR>
							<TD COLSPAN="1">
								<span ID="searchItemLabel">#application.returned_customer_setting.family_name_label_singular#</span><BR>
								<SELECT NAME="Family_Name" ONCHANGE="javascript:set_hidden_value(document.MyInvoiceForm.Family_Name_Text, document.MyInvoiceForm.Family_Name);">
									<OPTION VALUE="0">**ALL** #application.returned_customer_setting.family_name_label_plural#</OPTION>
									<cfloop query="GetFamilyNames"><OPTION VALUE="#trim(Family_ID)#"#IIF(trim(FORM.Family_Name) EQ "#trim(Family_ID)#", DE(" SELECTED"), DE(""))#>#trim(Family_Name)#</OPTION></cfloop>
								</SELECT>	
							</TD>
							<TD>
								<span ID="searchItemLabel">#application.returned_customer_setting.buying_group_label_singular#</span><BR>
								<SELECT NAME="Buying_Group" ONCHANGE="javascript:set_hidden_value(document.MyInvoiceForm.Buying_Group_Text, document.MyInvoiceForm.Buying_Group);">
									<OPTION VALUE="0">**ALL** #application.returned_customer_setting.buying_group_label_plural#</OPTION>
									<cfloop query="GetBuyingGroups"><OPTION VALUE="#trim(Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ "#trim(Buying_Group_ID)#", DE(" SELECTED"), DE(""))#>#trim(Buying_Group_Name)#</OPTION></cfloop>
								</SELECT>	
							</TD>
							<TD ALIGN="left" NOWRAP>
								<BR>
								<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10">
								<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" ONCLICK="javascript: reset_Form_Fields(2);">reset</a><FONT COLOR="##FF0000">]</FONT></B>
							</TD>
						</TR>
					</TABLE>	
			</FIELDSET>
		</DIV>
	</cfoutput>
	
	<script>
		function set_hidden_value(currObj, fromObj)
		{
			var sel_index = fromObj.selectedIndex;  
			currObj.value = fromObj.options[sel_index].text;
		}
	</script>