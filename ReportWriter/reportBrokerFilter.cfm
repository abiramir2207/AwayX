<!---- Initialization ------>					
<CFPARAM NAME="FORM.Broker_Zone_ID" 		DEFAULT="0">
<CFPARAM NAME="FORM.Broker_Region_ID" 		DEFAULT="0">
<CFPARAM NAME="FORM.Broker_Line_Of_Biz" 	DEFAULT="0">
<CFPARAM NAME="FORM.Broker_Status" 			DEFAULT="A">
<CFPARAM NAME="FORM.broker_sort_Order" 		DEFAULT="ASC1">
<CFPARAM NAME="FORM.broker_sort_by" 		DEFAULT="">
<CFPARAM NAME="FORM.broker_searchstring" 	DEFAULT="">

<!---- Query Information --->
<CFQUERY NAME="GetZones" datasource="#application.datasource#">
	SELECT *
	FROM Service_Zones
	WHERE len(Zone_Name) != 0 AND Deleted = 0
	ORDER BY Zone_Name
</CFQUERY>

<CFQUERY NAME="GetRegions" datasource="#application.datasource#">
	SELECT *
	FROM Service_Regions
	WHERE len(Region_Name) != 0 AND Deleted = 0
	ORDER BY Region_Name
</CFQUERY>

<cfquery name="GetLinesOfBiz" datasource="#application.datasource#">
	SELECT *
	FROM Line_Of_Business
	WHERE len(Line_Of_Business_Name) != 0
	ORDER BY Line_Of_Business_Name
</cfquery>

<SCRIPT language="JavaScript" src="invoiceCommon.js"></SCRIPT>

<cfoutput>
<DIV ID="filterBroker" STYLE="display:none; visibility:hidden;" <!---ALIGN="center"--->>
	<HR COLOR="Orange" SIZE="1">
	<FIELDSET STYLE="padding:10px; border: 5px outset LightGrey; width:400px">
	    <LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;">#application.returned_customer_setting.broker_label_singular# Criteria</LEGEND>
			<table STYLE="background-color: ##F0F8FF;">
				<TR>
					<TD COLSPAN="2"><!--- Zone --->
						<span ID="searchItemLabel">#application.returned_customer_setting.zone_label_singular#</span><BR>
						<SELECT NAME="Broker_Zone_ID" style="width: 200px;">
							<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION></cfoutput>
							<CFLOOP QUERY="GetZones"><OPTION VALUE="#trim(Service_Zone_ID)#"#IIF(trim(FORM.Broker_Zone_ID) EQ "#trim(Service_Zone_ID)#", DE(" SELECTED"), DE(""))#>#trim(Zone_Name)#</OPTION></CFLOOP>
						</SELECT>	
					</TD>
					<TD><!--- Regions --->
						<span ID="searchItemLabel">#application.returned_customer_setting.region_label_singular#</span><BR>
						<SELECT NAME="Broker_Region_ID" style="width: 200px;">
							<OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION>
							<CFLOOP QUERY="GetRegions"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Broker_Region_ID) EQ "#trim(Service_Region_ID)#", DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></CFLOOP>
						</SELECT>	
					</TD>
					<TD><!--- Line Of Biz --->
						<span ID="searchItemLabel">#application.returned_customer_setting.lob_label_singular#</span><BR>		
						<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
						<SELECT NAME="Broker_Line_Of_Biz" style="width: 200px;">
							<OPTION VALUE="0">**ALL** #application.returned_customer_setting.lob_label_plural#</OPTION>
							<CFLOOP QUERY="GetLinesOfBiz">
							<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
								<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
							</CFIF>
							<OPTION VALUE="#trim(Line_Of_Business_ID)#"#IIF(trim(FORM.Broker_Line_Of_Biz) EQ "#trim(Line_Of_Business_ID)#", DE(" SELECTED"), DE(""))#>#trim(Line_Of_Business_Name)#</OPTION></CFLOOP>
						</SELECT>					
					</TD>
					<TD><!--- Active/Inactive --->
						<span ID="searchItemLabel">Status</span><BR>
						<SELECT NAME="Broker_Status">
							<option VALUE="A" <CFIF FORM.Broker_Status EQ "A">SELECTED</CFIF>>Active</option>
						</SELECT>
					</TD>							
				</TR>
				<TR>
					<TD NOWRAP ALIGN="left">
					Sort By<BR>
					<CFSET sort_By_List="Name,ID,Address,City,State,Zip Code,Region,Zone">
					<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
					<CFSET sort_By_List=ListSort(sort_By_List,"Text")>
					<SELECT ID="broker_sort_by" NAME="broker_sort_by">
					<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
						<CFSET thisItem=Trim(thisItem)>
						<OPTION VALUE="#thisItem#"<CFIF thisItem EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
					</CFLOOP>
					</SELECT>
					</TD>
					<TD NOWRAP ALIGN="left">
					Order<BR>
					<SELECT ID="broker_sort_Order" NAME="broker_sort_Order">
						<OPTION VALUE="ASC"<CFIF FORM.broker_sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
						<OPTION VALUE="DESC"<CFIF FORM.broker_sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
					</SELECT>
					</TD>
					<TD NOWRAP ALIGN="left" COLSPAN="2">
						Name<BR>
						<INPUT TYPE="Text" NAME="broker_searchstring" STYLE="WIDTH:405px" SIZE="64"<CFIF len(trim(FORM.broker_searchstring)) GT 0>VALUE="#trim(FORM.broker_searchstring)#"</CFIF>>
					</TD>
					<!------<TD NOWRAP ALIGN="left">
						<BR>
						<INPUT TYPE="Submit" VALUE="search">
					</TD>----->
					<TD ALIGN="left" NOWRAP>
						<BR>&nbsp;&nbsp;
						<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" ONCLICK="javascript: reset_Form_Fields(4);">reset</a><FONT COLOR="##FF0000">]</FONT></B>
					</TD>
				</TR>
			</table>		
			
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>
</DIV>
</cfoutput>