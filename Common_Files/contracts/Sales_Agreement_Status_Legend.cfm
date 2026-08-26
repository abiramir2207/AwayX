<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/ViewModes.css">

<cfparam name="Cache_Control_Header_Already_Added" 	default="0">
<cfparam name="Print_Button_Show" default = "0">
<cfparam name="Email_Button_Show" default = "0">
<cfparam name="Fax_Button_Show" default = "0">
<cfparam name="Renew_Button_Show" default = "0">
<cfparam name="Revise_Button_Show" default = "0">
<cfparam name="Delete_Button_Show" default = "0">
<cfparam name="programagreed" default="0">
<cfparam name="CID" default="">

<CFIF NOT Cache_Control_Header_Already_Added>
	<cfheader name="Cache-Control" value="no-store">
	<cfheader name="expires" value="-100"> 
</CFIF>

<cfparam name="CSL_Export_Sales_Agreement_ID" default="">
<cfparam name="CSL_CallingPageCode" default="">
<cfparam name="CSL_data" default="0">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<CFSET MainLinksNotClickableClass = "Grayed">

<CFIF Len(CID) NEQ 0>
	<cf_cryp type="de" string ="#CID#" key="#request.key#">
	<CFSET CSL_Export_Sales_Agreement_ID = cryp.value>
</CFIF>

<CFIF CSL_CallingPageCode NEQ "ViewSalesAgreement">
	<!--- lock checker --->
	<CFSET LockChecker_CID  = CSL_Export_Sales_Agreement_ID>
	<CFINCLUDE TEMPLATE="Sales_Agreement_Lock_Checker.cfm">
</CFIF>

<CFINCLUDE TEMPLATE="sales_agreement_common_queries.cfm">

<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
<cfparam name="edit_program" default="1">
<cfparam name="user_acess_approval_tabs" default="1">
<cfparam name="modifyingusername" default="">
<cfparam name="checkuom" default="0">

<!--- Form with the data needed to reset the contract to WIP --->
<FORM ACTION="Sales_Agreement_Approval.cfm" METHOD="post" name="WIP_FORM">
	<INPUT TYPE="hidden" NAME="CID" VALUE="<CFOUTPUT>#CID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Status_ID" VALUE="1">
</FORM>

<!--- Form with the data needed to delete the contract --->
<FORM ACTION="sales_agreement_delete.cfm" METHOD="post" NAME="DeleteForm" ID="DeleteForm">
	<INPUT TYPE="hidden" NAME="CID" VALUE="<CFOUTPUT>#CID#</CFOUTPUT>">
</FORM>

<cfset Export_Sales_Agreement_ID = CSLGetContractInfo.Export_Sales_Agreement_ID>
	
<HTML>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
//-->
</script>

<BODY <!---ONLOAD="popupInit()"--->>


<SPAN style="color:red; position:absolute; width:100px; z-index:1; top: 36px; left: 5px;"> 
<TABLE BORDER="0" CELLPADDING="0" STYLE="border-collapse: collapse" ID="table1">

<CFIF (DisAllowAccessBasedOnProfile EQ 1 AND DisAllowApproveBasedOnProfile EQ 1)>
	<TR>
	<TD NOWRAP COLSPAN="2" align="center">
	<cfoutput>
	<IMG BORDER="0" SRC="/images/readonly_mode.gif" ALT="#Cannot_Edit_Program_Msg#">
    <div id="Layer2" align="center" style="position:absolute; width:100px; height:29px; z-index:2; left: 138px; top: -30px; color: RGB(255,0,0); font-weight:bold; font-size:14px">#Cannot_Edit_Program_Msg#</div>
	</cfoutput>
	</TD></TR>

	<CFSET DisAllowAccessBasedOnLockStatus = 1>

<CFELSEIF LEN(CID) GT 0>
	<!--- if the length is zero than this contract cannot be locked so dont do it --->
	<CFSET TabsAreActive = 1>
	<CFIF isContractCurrentlyLocked.Sales_Agreement_Is_Locked EQ 1 AND isContractCurrentlyLocked.Sales_Agreement_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
		<CFSET DisAllowAccessBasedOnLockStatus = 1>
	</CFIF>
	<SCRIPT>
		Locked = new Image();
		Locked.src = "/images/readonly_mode.gif";	
		
		UnLocked = new Image();
		UnLocked.src = "/images/edit_mode.gif";
	</SCRIPT>

	<CFIF DisAllowAccessBasedOnLockStatus EQ 1>
		<cfsilent>
		<!--- get the information of the user who locked the program --->
		<cfset useLakebaseForLookUpTheLockingUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForLookUpTheLockingUser>
	<cftry>
		<cfset LookUpTheLockingUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#CSLGetContractInfo.Sales_Agreement_Locked_By_User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLookUpTheLockingUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLookUpTheLockingUser>
<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
			SELECT Name_First, Name_Last
			FROM _Users
			WHERE User_ID = '#CSLGetContractInfo.Sales_Agreement_Locked_By_User_ID#'
		</cfquery>
</cfif>
	
		<!--- get the database setting for session timeout and use that for now as the program timeout --->
		<cfset useLakebaseForgetSessionTimeoutSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetSessionTimeoutSetting>
	<cftry>
		<cfset getSessionTimeoutSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "session_expiration_length"
			}), "session_expiration_length"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSessionTimeoutSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSessionTimeoutSetting>
<CFQUERY NAME="getSessionTimeoutSetting" datasource="#application.datasource#">
			SELECT Session_Expiration_Length
			FROM General_Settings
		</CFQUERY>
</cfif>
		
		<CFSET PercentageOfTHeDayInactive = getSessionTimeoutSetting.Session_Expiration_Length + 1>

		<!--- get the time the user sent a request to the system last --->
		<CFQUERY NAME="getSessionTime" datasource="#application.datasource#">
			SELECT DATEDIFF(n, Session_Date_Time_Stamp, GetDate()) AS InactiveTimeSpanInMinutes
			FROM Session_Tracker 
			WHERE Session_User_ID = '#CSLGetContractInfo.Sales_Agreement_Locked_By_User_ID#'
		</CFQUERY>

		<CFIF getSessionTime.RecordCount GT 0>
			<!--- what percentage of the day has the user been inactive for --->
			<CFSET InactiveTimeSpanInMinutes = getSessionTime.InactiveTimeSpanInMinutes>
			<CFSET PercentageOfTHeDayInactive = InactiveTimeSpanInMinutes/1440>
		</CFIF>
	
		<!--- has the user been inactive longer than the setting specified --->
		<CFIF PercentageOfTHeDayInactive GT getSessionTimeoutSetting.Session_Expiration_Length>
			
	 		<cfset useLakebaseForunLockContract = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sales_agreement")>
<cfif useLakebaseForunLockContract>
	<cftry>
		<cfset application.oLakebase.updateRows("sales_agreement",
			{
				"export_sales_agreement_id" = "eq.#CSLGetContractInfo.Export_Sales_Agreement_ID#"
			},
			{
				"sales_agreement_is_locked" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunLockContract = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunLockContract>
<CFQUERY NAME="unLockContract" datasource="#application.datasource#">
				UPDATE Sales_Agreement
				SET Sales_Agreement_Is_Locked = 0
				WHERE Export_Sales_Agreement_ID = '#CSLGetContractInfo.Export_Sales_Agreement_ID#'
			</CFQUERY>
</cfif>

			<CFSET DisAllowAccessBasedOnLockStatus = 0>
		</CFIF>
		</cfsilent>

		<CFIF DisAllowAccessBasedOnLockStatus EQ 1>
		<cfoutput>
		<TR>
			<TH NOWRAP COLSPAN="2">
			<IMG BORDER="0" SRC="/images/readonly_mode.gif" ALT="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#"><BR />
      <span style="color:RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br />#ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#</span>
			 </TH>
		</TR>
		</cfoutput>
		</CFIF>

	<CFELSE>
		<cfoutput>
		 <CFIF isContractCurrentlyLocked.Sales_Agreement_Is_Locked EQ 1>
				<!--- if it is locked offer to unlock it --->
		<TR>
			<TD NOWRAP COLSPAN="2" align="center">
			<a href="/common_files/contracts/Sales_Agreement_UnLock.cfm?CID=#EncryptedCID#"><IMG id="UnLocked" SRC="/images/edit_mode.gif" ALT="Edit Mode" ALIGN="absmiddle" border="0"><br>
			<span class="ViewModesBracket">[</span><span class="ViewModes">Click for Read Only</span><span class="ViewModesBracket">]</span>
			</a>
			</TD>
		</TR>	
			<CFELSE>
				<CFSET DisAllowAccessBasedOnLockStatus = 1>
				<!--- if it is unlocked offer to lock it --->
		<TR>
		<TD NOWRAP COLSPAN="2" align="center">
			<a href="/common_files/contracts/Sales_Agreement_Lock.cfm?CID=#EncryptedCID#"><IMG id="UnLocked" SRC="/images/readonly_mode.gif" ALT="Read-Only Mode" ALIGN="absmiddle" border="0"><br>
			<span class="ViewModesBracket">[</span><span class="ViewModes">Click to Edit</span><span class="ViewModesBracket">]</span>
			</a>
			</TD>
		</TR>
			</CFIF> 
		</cfoutput>
	</CFIF>
<CFELSE>
<TD NOWRAP COLSPAN="2">
			<IMG id="Locked" SRC="/images/edit_mode.gif" ALT="Edit Mode" ALIGN="absmiddle"></TD>
</TR>
</CFIF>

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Lock Code End ///////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<CFSET CanEditProgram = 0>
<CFIF 		(
			((CSLGetContractInfo.Contract_Status_Type_IDX LTE 2
			AND 
			DisAllowAccessBasedOnLockStatus EQ 0 
			AND
			DisAllowAccessBasedOnPosition EQ 0) OR len(CID) EQ 0)
			AND
			DisAllowAccessBasedOnProfile EQ 0			
			) 
		>
		<CFSET CanEditProgram = 1>
</CFIF>

<CF_Cryp type="en" key="#request.key#" string="#CSL_Export_Sales_Agreement_ID#" return="CSL_Encryp_Sales_Agreement_ID">

<CFIF NOT CanEditProgram AND len(CID) EQ 0>

	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">

</CFIF>

<!--- Do not show the tabs if CanEditProgram = 0 --->
<CFIF CanEditProgram OR len(CID) EQ 0>
		<cfsilent>
			<CFSET TabsClickable = 1>
		<CFIF len(CID) EQ 0>
			<CFSET TabsClickable = 0>
		</CFIF>
		<!--- View Program Tab --->
		<CFSET CSL_ThisPageCode = "ViewSalesAgreement">
		<CFIF request.TemplateName EQ "Sales_Agreement_Edit_Menu.cfm"><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_Status_legend_tab_styler.cfm">
		</cfsilent>
 		<cfoutput>
		 <CFIF TabsClickable EQ 1>
			<TR>
				<TD NOWRAP>
				<A HREF="/common_files/contracts/Sales_Agreement_Edit_Menu.cfm?CID=#EncryptedCID#" CLASS="#HREF_Class#"><IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle"></A>
				<A HREF="/common_files/contracts/Sales_Agreement_Edit_Menu.cfm?CID=#EncryptedCID#" CLASS="#HREF_Class#">view program</A></TD>
			</TR>
			<cfelse>
			<TR>
				<TD NOWRAP>
				<IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle">
				<A CLASS="#MainLinksNotClickableClass#">view program</A></TD>
			</TR>
		</cfif>	
		</cfoutput>
		<!--- Sales Agreement Tab --->
		<CFSET CSL_ThisPageCode = "gi">
		<CFIF lcase(CSL_CallingPageCode) EQ lcase(CSL_ThisPageCode)><CFSET CSL_there = 1><CFELSE><CFSET CSL_there = 0></CFIF>
		<CFIF CSLGetContractInfo.RecordCount EQ 0><CFSET CSL_data = 0><CFELSE><CFSET CSL_data = 1></CFIF>
		<CFINCLUDE TEMPLATE="/common_files/contracts/contract_Status_legend_tab_styler.cfm">

		<cfoutput>
		<!---The status has to be WIP. It can be seen on RFA when the profile(Approval & Creation Rights) is on --->
		<CFIF (TabsClickable EQ 1 and edit_program EQ 1) AND ((CSLGetContractInfo.Contract_Status_Type_IDX EQ 1) OR (CSLGetContractInfo.Contract_Status_Type_IDX LTE 2 AND Get_Profile_Settings.Create_Approve_Export_Agreements EQ 1))>
			<TR>
				<TD NOWRAP>
				<A HREF="/common_files/contracts/sales_agreement.cfm?CID=#EncryptedCID#"><IMG BORDER="0" SRC="#IMG_SRC#" ALIGN="absmiddle"></A>
				<A HREF="/common_files/contracts/sales_agreement.cfm?CID=#EncryptedCID#" CLASS="#HREF_Class#">edit program</A></TD>
			</TR>
		<cfelse>
			<TR>
				<TD NOWRAP>
				<IMG BORDER="0" SRC="#IMG_SRC#" ALIGN="absmiddle">
				<A CLASS="#MainLinksNotClickableClass#">edit program</A></TD>
			</TR>
		</cfif>
		</cfoutput>
<!---
<CFINCLUDE TEMPLATE="/common_files/contracts/contract_Status_legend_tab_styler.cfm">
--->

<CFELSE><!--- Else for If = Do not show the tabs if CanEditProgram = 0 --->
	<cfset IMG_SRC = "/images/programs/ball_gray_filled.GIF">
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="#IMG_SRC#" ALIGN="absmiddle">
		<span style="color:gray">view program</span></cfoutput>
		</TD>
	</TR>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="#IMG_SRC#" ALIGN="absmiddle">
		edit program</cfoutput></TD>
	</TR>
</CFIF><!--- End Else for If = Do not show the tabs if CanEditProgram = 0 --->

<cfif (CSL_CallingPageCode IS "ViewSalesAgreement")>
<cfsavecontent variable = "var">
	<CFINCLUDE TEMPLATE="/common_files/contracts/sales_agreement_thin_general_display.cfm">
</cfsavecontent>

<!--- Keeps all of the logic to generate email and faxes --->
	<CFINCLUDE TEMPLATE="/common_files/contracts/Sales_Agreement_email_fax_handler.cfm">

	<cfset CHECKFORREVISION = QueryNew("Export_Sales_Agreement_ID")>
	<!--- encrypt the Export_Sales_Agreement_ID --->
	<cf_cryp	type = "en" string = "#filename_email#" key = "#request.key#">
	<CFSET Program_Number=cryp.value>
</cfif>

<cfset APVL_Contract_Status = CSLGetContractInfo.Contract_Status_Type_IDX>
<CFIF CSL_CallingPageCode IS "ViewSalesAgreement">
	<CFSET Print_Button_Show 	= 1>
	<CFSET Fax_Button_Show 	 	= 1>
	<CFSET Email_Button_Show 	= 1>
<CFELSE>
	<CFIF DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "ViewSalesAgreement")>
		<cfif Get_Profile_Settings.Create_Export_Agreements EQ 1 AND Get_Profile_Settings.Create_Approve_Export_Agreements EQ 1>
			<CFSET Delete_Button_Show 	= 1>
		</cfif>		
	</CFIF>
</CFIF>

<!--- show when the contract is a WIP or RFA --->
	<CFIF APVL_Contract_Status GTE 1 AND APVL_Contract_Status LTE 2 AND DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "ViewSalesAgreement")>
		<CFSET Print_Button_Show 	= 1>
		<CFSET Fax_Button_Show 	 	= 1>
		<CFSET Email_Button_Show 	= 1>
		<CFIF DisAllowAccessBasedOnProfile EQ 0>
			<CFSET Renew_Button_Show 	= 1>
		</CFIF>
		<!--- based on the locked status --->
		<CFIF DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "ViewSalesAgreement")>
			<cfif Get_Profile_Settings.Create_Export_Agreements EQ 1 AND Get_Profile_Settings.Create_Approve_Export_Agreements EQ 1>
				<CFSET Delete_Button_Show 	= 1>
			</cfif>
		</CFIF>
	</CFIF>
<!--- when the contract is post approval the print button is shown to those who are in the approval tree or have positions matching the distributors and / or brokers --->
	<CFIF APVL_Contract_Status GTE 3 AND APVL_Contract_Status LTE 8 AND DisAllowAccessBasedOnLockStatus EQ 0 AND (CSL_CallingPageCode IS "ViewSalesAgreement")>
	
		<CFIF DisAllowAccessBasedOnPosition EQ 0>
			<CFIF DisAllowAccessBasedOnProfile EQ 0>
				<CFSET Renew_Button_Show 	= 1>	
				<CFSET Revise_Button_Show 	= 1>
			</CFIF>
		</CFIF>
	</CFIF>

	<!---BJF: Added to make it so you can copy a program which is not locked --->
	<CFIF APVL_Contract_Status LTE 7 AND DisAllowAccessBasedOnLockStatus EQ 1 AND (CSL_CallingPageCode IS "ViewSalesAgreement")>
		<CFIF DisAllowAccessBasedOnPosition EQ 0>
			<CFIF DisAllowAccessBasedOnProfile EQ 0>
				<CFSET Renew_Button_Show 	= 1>	
			</CFIF>
		</CFIF>
	</CFIF>

		<CFSET CSL_there = 0>
    <CFSET CSL_data = 0>

    <CFINCLUDE TEMPLATE="contract_Status_legend_tab_styler.cfm">
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_none.gif"></TD>
		<TD NOWRAP></TD>
	</TR>
	<TR>
		<TD NOWRAP>
			<CFOUTPUT>
			<A HREF="/common_files/contracts/sales_agreement.cfm" TITLE="create a new program" CLASS="#HREF_Class#"><IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle"></A>
			<A HREF="/common_files/contracts/sales_agreement.cfm" TITLE="create a new program" CLASS="#HREF_Class#">create</A>
			</CFOUTPUT>
		</TD>		
	</TR>
	<TR>
		<TD NOWRAP>
			<CFOUTPUT>
			<A HREF="/Scorecard/sales_agreement_Search.cfm" TITLE="search for a program" CLASS="#HREF_Class#"><IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle"></A>
			<A HREF="/Scorecard/sales_agreement_Search.cfm" TITLE="search for a program" CLASS="#HREF_Class#">search</A>
			</CFOUTPUT>
		</TD>		
	</TR>
		<TR>
		<TD NOWRAP>
			<CFOUTPUT>
			<cfif EncryptedCID eq "">
				<TR>
				<TD NOWRAP CLASS="Grayed">
				<IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">Documents</TD>
				</TR>
			 <cfelse>
			<A HREF="/Common_Files/contracts/Sales_Agreement_attachments.cfm?CID=#EncryptedCID#"><IMG BORDER="0" SRC="/images/programs/ball_green.gif" ALIGN="absmiddle"></A>
			<A HREF="/Common_Files/contracts/Sales_Agreement_attachments.cfm?CID=#EncryptedCID#">Documents</A>
			</cfif>
			</CFOUTPUT>
		</TD>		
	</TR>

	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_none.gif"></TD>
		<TD NOWRAP></TD>
	</TR>
<CFIF Print_Button_Show EQ 1>
	<CFIF CSLGetContractInfo.Contract_Status_Type_IDX LT 3>
		<cfset showimage =1>
	<CFELSE>
		<cfset showimage =0>
	</CFIF>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle"><cfoutput>
<A HREF="/common_files/contracts/sales_agreement_action_type.cfm?id=#Program_Number#&bgimage=#showimage#&ProgramType=ExportProgram&ActionType=PrintProgram&CID=#Encoded_Export_Sales_Agreement_ID#" onClick="NewWindow(this.href,'help','180','100','Yes', 'No');return false;">print</A></cfoutput></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">print</TD>
	</TR>
</CFIF>

<CFIF Email_Button_Show EQ 1>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<cfoutput><A HREF="/common_files/contracts/sales_agreement_action_type.cfm?PID=#Encoded_Export_Sales_Agreement_ID#&FID_Private=#Encoded_completepath_email_private#&FID_Public=#Encoded_completepath_email_public#&ProgramType=ExportProgram&ActionType=EmailProgram" onClick="NewWindow(this.href,'help','180','100','Yes', 'No');return false;">email</A></cfoutput></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">email</TD>
	</TR>
</CFIF>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
<CFIF Fax_Button_Show EQ 1>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<cfoutput><A HREF="/common_files/contracts/sales_agreement_action_type.cfm?PID=#Encoded_Export_Sales_Agreement_ID#&FID_Private=#Encoded_completepath_email_private#&FID_Public=#Encoded_completepath_email_public#&ProgramType=ExportProgram&ActionType=FaxProgram" onClick="NewWindow(this.href,'help','180','100','Yes', 'No');return false;">fax</A></cfoutput></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed"><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">fax</TD>
	</TR>
</CFIF>
--->

<CFIF Renew_Button_Show EQ 1>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<A href="Sales_Agreement.cfm?CID=<cfoutput>#Encoded_Export_Sales_Agreement_ID#</cfoutput>&Action=Copy"><span style="cursor:hand;">copy</span></A></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">copy</TD>
	</TR>
</CFIF>

<CFIF Revise_Button_Show EQ 1>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<A href="Sales_Agreement.cfm?CID=<cfoutput>#Encoded_Export_Sales_Agreement_ID#</cfoutput>&Action=Revise"><span style="cursor:hand;">revise</span></A></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
		revise</cfoutput></TD>
	</TR>
</CFIF>

<CFIF DisAllowAccessBasedOnLockStatus eq 0 AND CSLGetContractInfo.Contract_Status_Type_IDX LTE 2>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<A href="##"><span style="cursor:hand;" onClick="verifyDelete()">delete</span></A></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
		delete</cfoutput></TD>
	</TR>
</CFIF>

<CFIF DisAllowAccessBasedOnLockStatus eq 0 AND CSLGetContractInfo.Contract_Status_Type_IDX EQ 2>
	<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<A href="##" onClick="document.WIP_FORM.submit();">reset</A></TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
		reset</cfoutput></TD>
	</TR>
</CFIF>

<cfset createdByString = "" />
<!------ get the created by user name ----->
<cfset useLakebaseForCreatedUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForCreatedUser>
	<cftry>
		<cfset CreatedUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#CSLGetContractInfo.Creator_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCreatedUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreatedUser>
<cfquery name="CreatedUser" datasource="#application.datasource#">
	SELECT Name_First, Name_Last
	FROM _Users
	WHERE User_ID = '#CSLGetContractInfo.Creator_ID#'
</cfquery>
</cfif>
<CFIF CreatedUser.recordcount GT 0>
	<cfset createdByString = "#CreatedUser.Name_First# #CreatedUser.Name_Last# #Dateformat(CSLGetContractInfo.Agreement_Created_Date,'mm/dd/yyyy')#" />
</CFIF>
<CFIF Len(createdByString) GT 0>
	<TR>
		<TD NOWRAP style="cursor:hand;">
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<cf_smallHelp
			borderColor="black"
			backgroundColor="WhiteSMoke"
			showImage="0"
			showText="Created By"
			showTextColor="blue"
			borderWidth="1"
			dropdownCheck="0">
			<cfoutput><span style="color:RGB(0,0,255)">#JSStringFormat(createdByString)#</span></cfoutput>
		</cf_smallHelp>
		</TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
		created by</cfoutput></TD>
	</TR>
</CFIF>
		<cfset useLakebaseForApprovedUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForApprovedUser>
	<cftry>
		<cfset ApprovedUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#CSLGetContractInfo.Approved_By_User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForApprovedUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForApprovedUser>
<cfquery name="ApprovedUser" datasource="#application.datasource#">
			SELECT Name_First, Name_Last
			FROM _Users
			WHERE User_ID = '#CSLGetContractInfo.Approved_By_User_ID#'
</cfquery>
</cfif>
<CFIF ApprovedUser.recordcount GT 0>
	<TR>
		<TD NOWRAP style="cursor:hand;">
		<IMG BORDER="0" SRC="/images/programs/ball_blue.gif" ALIGN="absmiddle">
		<cf_smallHelp
			borderColor="black"
			backgroundColor="WhiteSMoke"
			showImage="0"
			showText="Approved By"
			showTextColor="blue"
			borderWidth="1"
			dropdownCheck="0">
			<cfoutput><span style="color:RGB(0,0,255)">#ApprovedUser.Name_First# #ApprovedUser.Name_Last# #Dateformat(CSLGetContractInfo.Approval_Date,'mm/dd/yyyy')#</span></cfoutput>
		</cf_smallHelp>
		</TD>
	</TR>
<CFELSE>
	<TR>
		<TD NOWRAP CLASS="Grayed">
		<cfoutput><IMG BORDER="0" SRC="/images/programs/ball_gray_filled.gif" ALIGN="absmiddle">
		Approved By</cfoutput></TD>
	</TR>
</CFIF>
<!------ 
if the current program is an autorenewed program - get the autorenewed from program information
else if the current program is a copied program - get the copied from program information 
----->
<cfif CSLGetContractInfo.Renewal_Of_Export_Sales_Agreement_ID NEQ ""><!------ this is a copy ----->
	<cfquery name="qGetCopyParentInfo" datasource="#application.datasource#">
		SELECT 	Export_Sales_Agreement_Number, Export_Sales_Agreement_Name
		FROM 		Export_Sales_Agreement
		WHERE 	Export_Sales_Agreement_ID = <cfqueryparam value="#CSLGetContractInfo.Renewal_Of_Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>	
		<cfset createdByString = "#createdByString#<br/><nobr>Copied from: #qGetCopyParentInfo.Export_Sales_Agreement_Number#</nobr>" />
</cfif>
<TR>
		<TD NOWRAP>
		<IMG BORDER="0" SRC="/images/programs/finial.gif" ALIGN="absmiddle">
		<TD NOWRAP></TD>
</TR>
	<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->
	
	</TABLE>
</span>
<STYLE TYPE="text/css">
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Red;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Blue;
		font-family:		Arial;
		font-size :			11px; 
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Blue;
		font-family:		Arial;
		font-size :			11px; 
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
.Grayed
	{
		color: 				gray;
		font-family:		Arial;
		font-size :			11px;
	}
</STYLE>

<style type="text/css">
		/* POPup tooltip style*/
		#divTooltip {
			position:absolute; 
			top:0px;
			width:100px;
			visibility:hidden;
			z-index:200;
			background:#FFFFFF;
			layer-background-color:#FFFFFF;
			text-align:left;
		}
		.normalStyle {
			padding:2px;
			text-align:center;
			font-weight:500;
			width:175px;
			color:#000000;
			top:100px;
			font-family:verdana,arial,helvetica;
			font-size:11px;
			background-color:#f3f3f3;
			layer-background-color:#f3f3f3;
			border-width:1px;
			border-style:solid;
			border-color:#000000;
			cursor:default;
		}
	</style>
<script>
function initTheTooltip(ToolTipText){
	textHolder = ToolTipText;
	messages[0]="";
	messages[0]= "" + textHolder + ""

	popUp(0)
}
/* Extending the Tooltip to control text alignment */
function showtooltip(showToolTipText)
{
	var tipobj = document.all.divTooltip;
	tipobj.style.textAlign="left";
	initTheTooltip(showToolTipText);
}

function hidetooltip(){
	var tipobj = document.all.divTooltip;
	tipobj.innerHTML = "";
	tipobj.style.textAlign="center";
	popOut();
}
function verifyDelete(){
	if(confirm("Are you sure you want to delete this program?")){
			document.all.DeleteForm.submit();
	}
}
</script>
</BODY>
</HTML>