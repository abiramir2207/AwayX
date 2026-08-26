<!--- <SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH> 
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
--->
<CFSET PAGE_TITLE="Program Summary">
<CFSET GROUP="Contracts">


<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET URL.Contract_Main_ID = cryp.value>
<!--- 
<CFDIRECTORY ACTION="LIST" DIRECTORY="#driveletter#:\inetpub\wwwroot\awayx\common_files\contracts\contract_documents" NAME="DirInfo" FILTER=".htm">

<CFOUTPUT QUERY="DirInfo">
	<CFIF dateformat(DirInfo.dateLastModified, 'mm/dd/yyyy') LT dateformat(now(), 'mm/dd/yyyy')>
		<CFFILE ACTION="DELETE" FILE="#driveletter#:\inetpub\wwwroot\awayx\common_files\contracts\contract_documents\#DirInfo.name#">
	</CFIF>
</CFOUTPUT> --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="-100"> 
<cfset Cache_Control_Header_Already_Added = 1>
<CFINCLUDE template="/includes/call_please_wait.cfm">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Help_URL="/help_files/manual/createprogram/page14.cfm">
<CFSET CSL_Contract_Main_ID = URL.Contract_Main_ID>
<CFSET CSL_CallingPageCode = "viewcontract"> 
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>


<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=1>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->
	
	
	
<cfsavecontent variable = "var">
	<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
</cfsavecontent>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This section handles the contract Approval								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	

<!--- Display The Appropriate Status --->
<CFSET StatusDisplay_CELLSPACING	= 4>
<CFSET StatusDisplay_CELLPADDING	= 0>
<CFSET StatusDisplay_FONTCOLOR		= "white">
<CFSET StatusDisplay_CELLBGCOLOR	= "green">

<cfset APVL_Contract_Status = CSLGetContractInfo.Contract_Status_Type_IDX>
<CFSWITCH EXPRESSION="#APVL_Contract_Status#">

	<CFCASE VALUE="1">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Work In Progress"> 
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision In Progress"> 
		</CFIF>
		
		<CFSET StatusDisplay_BGCOLOR		= "gray">
		<CFSET StatusDisplay_CELLBGCOLOR	= "gray">
		<SCRIPT>
			function confirmApproval() {
				if(confirm("Are you sure you want this program to be ready for approval?")) {
					document.all.BrokerApprovalForm.submit();
				}
				else {
					document.all.ApproveContractButton.checked = false;
				}
			}
		</SCRIPT>
		<!-- </FORM> -->
	</CFCASE>

	<CFCASE VALUE="2">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Ready For Approval">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision Ready For Approval">
		</CFIF>
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
		<SCRIPT>
			function confirmApproval() 
			{
				NewWindow('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','800','650','Yes', 'Yes');
			}
		</SCRIPT>		
	</CFCASE>


	<CFCASE VALUE="4">
		<CFSET StatusDisplay_DisplayText	= "Pre Active">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
	</CFCASE>

	
	<CFCASE VALUE="5">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText = "Active">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText = "Active Revision">
		</CFIF>
		
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="6">
		<CFSET DayCount = datediff('d', dateformat(now(), 'm/d/yyy'), dateformat(CSLGetContractInfo.Contract_End_Date, 'm/d/yyy'))>
		<CFSET Temp = " Day">
		<cfif DayCount GT 1><CFSET Temp = " Days"></cfif>

		<CFIF DayCount EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Will Expire Today">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Expires In " & DayCount & Temp>
		</CFIF>
		
		
		<CFSET StatusDisplay_BGCOLOR		= "Red">
		<CFSET StatusDisplay_CELLBGCOLOR	= "Red">
	</CFCASE>			
	
	<CFCASE VALUE="7">
		<CFSET StatusDisplay_DisplayText	= "Expired">
		<CFSET StatusDisplay_BGCOLOR		= "black">
		<CFSET StatusDisplay_CELLBGCOLOR	= "black">
	</CFCASE>			
</CFSWITCH>

<!--- if the program is a revision than the rules about templates does not apply to this program  --->
<CFIF Program_Is_A_Revision EQ 1 AND IsProgramTemplateAvailable EQ 0>
	<CFSET IsProgramTemplateAvailable = 1>
</CFIF>
<!--- if the template for this program is inactive than let the user know  --->
<CFIF IsProgramTemplateAvailable EQ 0>
		<CFSET StatusDisplay_DisplayText	= "Program Template Is Inactive">
		<CFSET StatusDisplay_BGCOLOR		= "Orange">
		<CFSET StatusDisplay_CELLBGCOLOR	= "Orange">
		<CFSET StatusDisplay_FONTCOLOR		= "Yellow">
</CFIF>

<CFOUTPUT>

<table width="710" border="0" cellspacing="0" cellpadding="0">
</TABLE>
	<TABLE
		BORDER="0"
		CELLSPACING="#StatusDisplay_CELLSPACING#"
		CELLPADDING="#StatusDisplay_CELLPADDING#"
		WIDTH="710"
		BGCOLOR="#StatusDisplay_BGCOLOR#">
	<TR>
		<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%"><FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#StatusDisplay_DisplayText#</B></FONT>
		</TD>			
			<!------ Get voluem Info ----->
			
			<!------ Program_Volume is already loaded in thin contract general display ----->
			<CFIF NOT isDefined("Program_Volume")>
				<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
				<CFSET Program_Volume.Load_Basic_Information(URL.Contract_Main_ID)>
			</CFIF>
			<CFSET Volume_Good = Program_Volume.Check_Any_NULL_Volume()>
			<CFSET volumePacket = Program_Volume.Volume_Packet_Builder.volumePacket>
			<CFSET VolumeTitle = "Apply volume for products">
			<CFIF NOT Volume_Good>
				<CFSET Null_Vol_Prod_Count = Program_Volume.Null_Volume_Products.recordCount>
				<CFSET VolumeTitle = ListAppend(VolumeTitle, "- #Null_Vol_Prod_Count# product#IIF(Null_Vol_Prod_Count GT 1, DE('s'), DE(''))# does not have proper volume", "#chr(13)#")>
			</CFIF>
			<CFSET Forecast_Good = true>
			
			<cfset showVolume = true>
			<cfif ArrayLen(volumePacket.products) LTE 0>
				<cfset showVolume = false>
				<cfset noProductMsg = "There are no products selected">
				<CFSET VolumeTitle = noProductMsg>
			</cfif>
			
			<CFIF Program_Volume.Can_Do_Forecast AND volumePacket.forecastInfo.priorForecast>
				<CFIF volumePacket.proudctsNotInForecast GT 0>
					<CFSET VolumeTitle = ListAppend(VolumeTitle, "- There #IIF(volumePacket.proudctsNotInForecast GT 1, DE('are'), DE('is'))# #volumePacket.proudctsNotInForecast# product#IIF(volumePacket.proudctsNotInForecast GT 1, DE('s'), DE(''))# that exist in the program but does not exist in the recent forecast", "#chr(13)#")>
					<CFSET Forecast_Good = false>
				</CFIF>
				<CFIF volumePacket.distributorsNotInAppArea GT 0>
					<CFSET VolumeTitle = ListAppend(VolumeTitle, "- There #IIF(volumePacket.distributorsNotInAppArea GT 1, DE('are'), DE('is'))# #volumePacket.distributorsNotInAppArea# #IIF(volumePacket.distributorsNotInAppArea GT 1, DE(LCase(application.returned_customer_setting.distributor_label_plural)), DE(LCase(application.returned_customer_setting.distributor_label_singular)))# who exist in the recent forecast but does not exist in the program", "#chr(13)#")>
					<CFSET Forecast_Good = false>
				</CFIF>
				<CFIF volumePacket.distributorsNotInForecast GT 0>
					<CFSET VolumeTitle = ListAppend(VolumeTitle, "- There #IIF(volumePacket.distributorsNotInForecast GT 1, DE('are'), DE('is'))# #volumePacket.distributorsNotInForecast# #IIF(volumePacket.distributorsNotInForecast GT 1, DE(LCase(application.returned_customer_setting.distributor_label_plural)), DE(LCase(application.returned_customer_setting.distributor_label_singular)))# who exist in the program but does not exist in the recent forecast", "#chr(13)#")>
					<CFSET Forecast_Good = false>
				</CFIF>
				<CFIF isDate(volumePacket.forecastInfo.appAreaStartDate) AND IsDate(volumePacket.forecastInfo.appAreaEndDate)>
				<CFIF DATEDIFF("d", volumePacket.forecastInfo.appAreaStartDate, volumePacket.appAreaStartDate) NEQ 0 OR DATEDIFF("d", volumePacket.forecastInfo.appAreaEndDate, volumePacket.appAreaEndDate) NEQ 0>
					<CFSET VolumeTitle = ListAppend(VolumeTitle, "- The program span during last forecast was #DateFormat(volumePacket.forecastInfo.appAreaStartDate, "mm/dd/yyyy")# - #DateFormat(volumePacket.forecastInfo.appAreaEndDate, "mm/dd/yyyy")#", "#chr(13)#")>
					<CFSET Forecast_Good = false>
				</CFIF>
				</CFIF>		
			</CFIF>
			
			<CFSET Volume_Not_Good_Str = "You have to establish the volume for all the products in the program before you can continue..." />
			<CFIF Volume_Good AND APVL_Contract_Status EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnPosition EQ 0 AND DisAllowAccessBasedOnLockStatus EQ 0>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP>
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B>Ready For Approval</B></FONT>
				<INPUT TYPE="checkbox" NAME="ApproveContractButton" TITLE="Click Here to Pre-Approve This Program" VALUE="#URL.CID#" onClick="confirmApproval()">
				&nbsp;&nbsp;&nbsp;
				</TD>
			<CFELSEIF NOT Volume_Good AND (APVL_Contract_Status EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnPosition EQ 0 AND DisAllowAccessBasedOnLockStatus EQ 0)>
				<TD ALIGN="right" BGCOLOR="##DDDDDD" style="cursor:hand;border:2px solid yellow;" NOWRAP onclick="javaScript: alert('#Volume_Not_Good_Str#');" TITLE="#Volume_Not_Good_Str#">
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B>Ready For Approval</B></FONT>
				<INPUT TYPE="checkbox" disabled>
				&nbsp;&nbsp;&nbsp;
				</TD>
			</CFIF>
			
			<CFIF APVL_Contract_Status LT 3 AND DisAllowAccessBasedOnLockStatus EQ 0>
			<TD TITLE="#VolumeTitle#" ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; " <cfif showVolume>STYLE=" cursor: hand;" ONCLICK="NewWindow('Contract_Volume.cfm?Program_ID=#URL.Contract_Main_ID#','name','850','650','Yes', 'Yes')"<cfelse> onClick="alert('#noProductMsg#');"</cfif>>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<CFIF Volume_Good AND Forecast_Good AND showVolume>
					<CFSET Volume_Img = "yes_small.gif">
				<CFELSE>
					<CFSET Volume_Img = "no_small.gif">
				</CFIF><IMG SRC="/Images/#Volume_Img#">&nbsp;Volume
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
			</CFIF>
			
			<CFIF Volume_Good AND APVL_Contract_Status EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 >
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: hand;" ONCLICK="NewWindow('contract_profit_analysis.cfm?CID=#URL.CID#','name','850','650','Yes', 'Yes')">
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;					
				</TD>
			<CFELSEIF NOT Volume_Good AND (APVL_Contract_Status EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1)>
				<TD ALIGN="right"  BGCOLOR="##DDDDDD" style="cursor:hand;border:2px solid yellow;" NOWRAP STYLE="font-size: 15px; font-weight: bold; cursor: hand;" onclick="javaScript: alert('#Volume_Not_Good_Str#');" TITLE="#Volume_Not_Good_Str#">
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;					
				</TD>
			</CFIF>
			
			<!--- this user has full approval abilities --->
			<CFIF Volume_Good AND APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: hand;" ONCLICK="confirmApproval()">
					&nbsp;&nbsp;&nbsp;
					Click Here to Approve This Program
					&nbsp;&nbsp;&nbsp;
				</TD>
			<CFELSEIF NOT Volume_Good AND (APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0)>
				<TD ALIGN="right"  BGCOLOR="##DDDDDD" style="cursor:hand;border:2px solid yellow;" NOWRAP STYLE="font-size: 15px; font-weight: bold; cursor: hand;" onclick="javaScript: alert('#Volume_Not_Good_Str#');" TITLE="#Volume_Not_Good_Str#">
					&nbsp;&nbsp;&nbsp;
					Click Here to Approve This Program
					&nbsp;&nbsp;&nbsp;					
				</TD>
			</CFIF>

			<!--- this user can only view the margins --->
			<CFIF APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 0 AND IsProgramTemplateAvailable EQ 1>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: hand;" ONCLICK="NewWindow('contract_profit_analysis.cfm?CID=#URL.CID#','name','800','400','Yes', 'Yes')">
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;
				</TD>
			</CFIF>
			
			<!--- the contract is now in a post approved state so make the margins avaiable only --->
			<CFIF APVL_Contract_Status GTE 3 AND APVL_Contract_Status LTE 6 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND IsProgramTemplateAvailable EQ 1>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: hand;" ONCLICK="NewWindow('contract_profit_analysis.cfm?CID=#URL.CID#','name','800','400','Yes', 'Yes')">
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;
				</TD>
			</CFIF>
		

	</TR>
	</TABLE>
</CFOUTPUT>
<BR>

<table BORDER="0">
	<TR>
		<TD>
			<!------<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">----->
			<CFOUTPUT>#var#</CFOUTPUT>
		</TD>
	</TR>
<TR><TD>



	<!--- Keeps all of the logic to generate email and faxes --->
	<CFINCLUDE TEMPLATE="email_fax_handler.cfm">
	<!--- Keeps all of the logic to generate email and faxes --->












<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Button bar at the bottom																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="1%">
		<TR>
<cfset CHECKFORREVISION = QueryNew("Contract_Main_ID")>
<!--- encrypt the contract main ID --->
<cf_cryp	type = "en" string = "#filename_email#" key = "#request.key#">
<CFSET Program_Number=cryp.value>

<CFSET Print_Button_Show 	= 0>
<CFSET Email_Button_Show 	= 0>
<CFSET Fax_Button_Show 		= 0>
<CFSET History_Button_Show 	= 0>
<CFSET Cancel_Button_Show 	= 0>
<CFSET Renew_Button_Show 	= 0>
<CFSET Revise_Button_Show 	= 0>
<CFSET Delete_Button_Show 	= 0>
<CFSET Purge_Button_Show 	= 0>

<CFIF IsProgramTemplateAvailable EQ 1>
	<CFSET Print_Button_Show 	= 1>
	<CFSET Fax_Button_Show 	 	= 1>
	<CFSET Email_Button_Show 	= 1>
<CFELSE>
	<CFIF DisAllowAccessBasedOnLockStatus EQ 0>
		<CFSET Delete_Button_Show 	= 1>	
	</CFIF>
</CFIF>

<CFSET ThisUserPositionID = getUserInformation.User_Positions_ID>

<!--- assemble the positions of all the brokers on this contract --->
<CFSET getBrokerPositions 	= 	QueryNew("BSA_Foodservice_Brokers_ID")>
<CFSET BrokerPositionsList	=	"">

<CFIF checkForBrokers.recordcount GT 0>
	<CFQUERY NAME="getBrokerPositions" datasource="#application.datasource#">
	SELECT     dbo.User_Positions.User_Positions_ID
	FROM         dbo.User_Positions INNER JOIN
	                      dbo.BSA_Foodservice_Brokers ON dbo.User_Positions.Service_Zone_ID = dbo.BSA_Foodservice_Brokers.Service_Zone_ID AND 
	                      dbo.User_Positions.Service_Region_ID = dbo.BSA_Foodservice_Brokers.Service_Region_ID
	WHERE 		dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID IN(#replace(listqualify(valuelist(checkForBrokers.BSA_Foodservice_Brokers_ID), "'", ","), '"', "'", "ALL")#)
	</CFQUERY>
	<CFSET BrokerPositionsList = valuelist(getBrokerPositions.User_Positions_ID)>
</CFIF>
<!--- END assemble the positions of all the brokers on this contract --->

<!--- assemble the positions of all the distributors on this contract --->
<CFSET getDistributorPositions 	= 	QueryNew("BSA_Foodservice_Brokers_ID")>
<CFSET DistributorPositionsList	=	"">

<CFIF checkForDistributors.recordcount GT 0>
	<CFQUERY NAME="getDistributorPositions" datasource="#application.datasource#">
SELECT     dbo.User_Positions.User_Positions_ID
FROM         dbo.User_Positions INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON dbo.User_Positions.Service_Zone_ID = dbo.BSA_Foodservice_Brokers.Service_Zone_ID AND 
                      dbo.User_Positions.Service_Region_ID = dbo.BSA_Foodservice_Brokers.Service_Region_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
WHERE 		dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN(#replace(listqualify(valuelist(checkForDistributors.BSA_Foodservice_Customers_ID), "'", ","), '"', "'", "ALL")#)
	</CFQUERY>
	<CFSET DistributorPositionsList = valuelist(getDistributorPositions.User_Positions_ID)>
</CFIF>
<!--- END assemble the positions of all the distributors on this contract --->

<!--- print button logic --->
<CFSET WIP_Kickback_Show	= 0>

	<!--- show when the contract is a WIP or RFA --->
	<CFIF APVL_Contract_Status GTE 1 AND APVL_Contract_Status LTE 2 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0>
		<CFSET Print_Button_Show 	= 1>
		<CFSET Fax_Button_Show 	 	= 1>
		<CFSET Email_Button_Show 	= 1>
		<CFSET Renew_Button_Show 	= 1>

		<!--- kickback button --->
		<CFIF APVL_Contract_Status EQ 2>
			<CFSET WIP_Kickback_Show	= 1>
		</CFIF>

		
		<!--- based on the locked status --->
		<CFIF DisAllowAccessBasedOnLockStatus EQ 0>
			<CFSET Delete_Button_Show 	= 1>
		</CFIF>
	</CFIF>
	
	<!--- when the contract is post approval the print button is shown to those who are in the approval tree or have positions matching the distributors and / or brokers --->
	<CFIF APVL_Contract_Status GTE 3 AND APVL_Contract_Status LTE 7 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0>
		<CFIF DisAllowAccessBasedOnPosition EQ 0>
			<CFSET History_Button_Show 	= 1>
			<CFSET Renew_Button_Show 	= 1>	
			<CFSET Revise_Button_Show 	= 1>
			
			<!--- if the contract has expired --->
			<CFIF APVL_Contract_Status EQ 7>
				<CFSET Purge_Button_Show 	= 1>
				<CFSET Revise_Button_Show 	= 0>
			<CFELSE>
				<CFSET Cancel_Button_Show 	= 1>	 
			</CFIF>

			<!--- if the program is a revision do not show the renew button --->
			<CFIF Program_Is_A_Revision EQ 1 AND APVL_Contract_Status EQ 4>
				<CFSET Renew_Button_Show 	= 0>	
				<CFSET Revise_Button_Show 	= 0>
			</CFIF>

			<!--- if is revision show extra buttons --->
			<CFIF Program_Is_A_Revision EQ 1 AND APVL_Contract_Status GTE 3>
				<CFSET History_Button_Show 	= 1>
			</CFIF>
		</CFIF>
	</CFIF>
<!--- END print button logic --->


<!--- email button logic 	 --->
	<!--- in print button login since its the same --->
<!--- END email button logic --->

<!--- fax button logic 	   --->
		<!--- in print button login since its the same --->
<!--- END fax button logic --->

<!--- history button logic     --->
		<!--- in print button login since its the same --->
<!--- END history button logic --->

<!--- cancel button logic --->
	<!--- <CFIF CSLGetContractInfo.Contract_Status_Type_IDX GTE 3 AND CSLGetContractInfo.Force_Expiration_Flag EQ 0 AND CSLGetContractInfo.Contract_Status_Type_IDX NEQ 7> --->
<!--- END cancel button logic --->

<!--- Renew Button Logic --->
	<!--- <CFIF CSLGetContractInfo.Contract_Status_Type_IDX GTE 4 AND IsProgramTemplateAvailable EQ 1 AND Program_Is_A_Revision EQ 0> --->
<!--- END Renew Button Logic --->

<!--- revise button logic --->
		<!--- check for existing revisions that arent yet active. --->
		<CFQUERY NAME="checkForRevision" datasource="#application.datasource#">
			SELECT *
			FROM Contract_Main
			WHERE 	Revision_Of_Contract_Main_ID = '#CSLGetContractInfo.Contract_Main_ID#' 
					AND Deleted = 0
					AND Force_Expiration_Flag = 0
					AND Flagged_As_Purged = 0
		</CFQUERY>
		<!--- <CFIF IsProgramTemplateAvailable EQ 1 AND CSLGetContractInfo.Contract_Status_Type_IDX NEQ 7> --->
<!--- END revise button logic --->

<!--- Delete button logic --->
	<!--- <CFIF (CSLGetContractInfo.Contract_Status_Type_IDX EQ "1" OR CSLGetContractInfo.Contract_Status_Type_IDX EQ "2")  AND IsProgramTemplateAvailable EQ 1> --->
<!--- END Delete button logic --->

<!--- purge button logic --->
	<!--- <CFIF CSLGetContractInfo.Contract_Status_Type_IDX EQ 7 AND IsProgramTemplateAvailable EQ 1> --->
<!--- END purge button logic --->


<CFIF Print_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('printer_friendly.cfm?id=#Program_Number#','name','800','600','Yes', 'No')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare an email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>

<CFIF Email_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='contract_email_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare an email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
<CFIF Fax_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='contract_fax_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>
--->
<CFIF History_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"history"
			button_action	=	"window.location.href='view_contract_history.cfm?CID=#URL.CID#&RO=1'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"View program changes"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>

<CFIF Cancel_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"cancel"
			button_action	=	"verifyCancelation()"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"click here cancel this program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>

<CFIF Renew_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"copy"
			button_action	=	"verifyRenewal()"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"copy the program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>			
</CFIF>

<CFIF Revise_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"revise"
			button_action	=	"verifyRevision()"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"revise the program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>
			
<CFIF Delete_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"delete"
			button_action	=	"verifyDelete()"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"delete program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>

<CFIF Purge_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"purge"
			button_action	=	"verifyPurge()"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"delete program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>

<CFIF WIP_Kickback_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"reset to WIP"
			button_action	=	"verifyKB()"
			button_type		=	"javascript_link"
			button_color	=	"Navy"
			button_tip		=	"delete program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>				
	</TD>
</CFIF>
			<TD WIDTH="100%">&nbsp;</TD>
		</TR>
	</TABLE>	
	</TD>
	</TR>
</table>

</BLOCKQUOTE></BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Form with the data needed to approve the contract --->
<FORM ACTION="contract_approve_broker_action.cfm" METHOD="post" NAME="BrokerApprovalForm" ID="BrokerApprovalForm">
	<INPUT TYPE="hidden" NAME="ApproveContract" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>" >
</FORM>

<!--- Form with the data needed to delete the contract --->
<FORM ACTION="delete_program.cfm" METHOD="post" NAME="DeleteForm" ID="DeleteForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>" >
</FORM>

<!--- Form with the data needed to purge the contract --->
<FORM ACTION="contract_purge_action.cfm" METHOD="post" NAME="PurgeForm" ID="PurgeForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>" >
</FORM>

<!--- Form with the data needed to cancel the contract --->
<FORM ACTION="contract_cancel_action.cfm" METHOD="post" NAME="CancelForm" ID="CancelForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>" >
</FORM>

<!--- Form with the data needed to cancel the contract --->
<FORM ACTION="contract_renewal_action.cfm" METHOD="post" NAME="RenewForm" ID="RenewForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>" >
	<INPUT TYPE="hidden" NAME="IsRevisionOfExistingContract" VALUE="0" >
</FORM>

<!--- Form with the data needed to cancel the contract --->
<FORM ACTION="contract_kickback_action.cfm" METHOD="post" NAME="KBForm" ID="KBForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
</FORM>

<cfparam name="url.emailFax" 	default="0">
<cfif url.emailFax>
	<CF_displayLayer
			layerName="divEmailFax"
			width="400"
			bgColor="FFEFD5"
			scroll="1"
			>
		<table width="100%" cellpadding="3" cellspacing="0" border="0" background="Images/yellow.gif">
		<tr>
			<td align="right" colspan="100%"><a href="void(0);" onClick="javaScript: return closeDivWindow();"><img src="/Images/close_1.gif" border="0" width="16" height="14"></a></td>
		</tr>
		<tr>
			<td colspan="100%">
			&nbsp;&nbsp;&nbsp;&nbsp;
			<B>Please select your next action.</B>
			<br><br><br>
			</td>
		</tr>
		<tr>
			<CFIF Print_Button_Show EQ 1>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"NewWindow('printer_friendly.cfm?id=#Program_Number#','name','800','600','Yes', 'No')"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			</CFIF>
			
			<CFIF Email_Button_Show EQ 1>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"window.location.href='contract_email_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			</CFIF>
	<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK		
			<CFIF Fax_Button_Show EQ 1>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"fax"
						button_action	=	"window.location.href='contract_fax_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare the contents of a fax to be sent"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>				
				</TD>
			</CFIF>		
	--->
		</tr>	
		<tr>
			<td align="center" colspan="100%">
			<br><br>
			<cf_smallLink
					title="close"
					url="void(0);"
					parameters=" onClick=""javaScript: return closeDivWindow();"""
					>
			</td>
		</tr>
	</table>
	</CF_displayLayer>

</cfif>

<script>
	function verifyDelete(){
		if(confirm("Are you sure you want to delete this program?")){
			document.all.DeleteForm.submit()
		}
	}
	
	function verifyPurge(){
		if(confirm("Are you sure you want to purge this program?")){
			document.all.PurgeForm.submit()
		}
	}	
	
	function verifyCancelation(){
		if(confirm("Are you sure you want to cancel this program?")){
			document.all.CancelForm.submit()
		}
	}
	
	function verifyRenewal(){
		if(confirm("Are you sure you want to copy this program?")){
			document.all.RenewForm.submit()
		}
	}	
		
	function verifyRevision(){
		<CFIF checkForRevision.recordcount EQ 0 OR GetSettings.Discount_Formula_Pricing EQ 1>
			if(confirm("Are you sure you want to revise this program?")){
					document.all.RenewForm.IsRevisionOfExistingContract.value = 1;
					document.all.RenewForm.submit();
			}
		<CFELSE>
			<CF_cryp type="en" key="#request.key#" string="#checkForRevision.Contract_main_Id#" return="enc">
			document.location.href="contract_edit_menu.cfm?CID=<CFOUTPUT>#enc.value#</CFOUTPUT>"
		</CFIF>
	}
	
	function verifyKB(){
		if(confirm("Are you sure you want to reset this to Work in Progress status?")){
			document.all.KBForm.submit();
		}
	}	
</script>

</BODY>
</HTML>



