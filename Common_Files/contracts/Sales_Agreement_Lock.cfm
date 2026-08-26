<CFPARAM NAME="FORM.Programs_Unlocked" DEFAULT="0">
<cfparam name="url.CID" default="">

<!--- UnLock all Programs By This User --->
<CFIF FORM.Programs_Unlocked EQ 1>
	<cfset useLakebaseForUnlockProgramsLockedByThisUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForUnlockProgramsLockedByThisUser>
	<cftry>
		<cfset application.oLakebase.updateRows("export_sales_agreement",
			{
				"sales_agreement_is_locked" = "eq.1",
				"sales_agreement_locked_by_user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0"
			},
			{
				"sales_agreement_is_locked" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUnlockProgramsLockedByThisUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUnlockProgramsLockedByThisUser>
<CFQUERY NAME="UnlockProgramsLockedByThisUser" datasource="#application.datasource#">
		UPDATE Export_Sales_Agreement
		SET Sales_Agreement_Is_Locked = 0
		WHERE Sales_Agreement_Is_Locked = 1
		AND Sales_Agreement_Locked_By_User_ID 	= '#request.AccessStructure.user_id#'
		AND Deleted = 0
	</CFQUERY>
</cfif>
</CFIF>

<cfquery name="getProgramLockedByUser" datasource="#application.datasource#">
	SELECT  dbo.Export_Sales_Agreement.Export_Sales_Agreement_ID, dbo.Export_Sales_Agreement.Export_Sales_Agreement_Number
	, dbo.Export_Sales_Agreement.Export_Sales_Agreement_Name, dbo.Export_Sales_Agreement.Export_Start_Date
	, dbo.Export_Sales_Agreement.Export_End_Date
	, dbo.Export_Sales_Agreement.Contract_Status_Type_IDX,Sales_Agreement_Is_Locked,Sales_Agreement_locked_by_user_ID
	,	dbo.Export_Sales_Agreement.Export_Sales_Agreement_Number
	FROM   dbo.Export_Sales_Agreement
	WHERE Sales_Agreement_Is_Locked = 1
	AND Sales_Agreement_Locked_By_User_ID 	= '#request.AccessStructure.user_id#'
	AND dbo.Export_Sales_Agreement.Deleted = 0
	ORDER BY Export_Sales_Agreement_Number
</cfquery>

<CFIF getProgramLockedByUser.recordcount GT 0>
<CFSET PAGE_TITLE="">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>
<TABLE ALIGN="center">
	<TR>
		<TD>
				<CF_button
					button_caption	=	"unlock programs"
					button_action	=	"unlockPrograms()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	"unlock programs"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>			
		</TD>
		<TD STYLE="color:red; font-size:15px;font-weight:bold;">
			Please unlock the programs you have locked below before continuing.
		</TD>
		<TD>
				<CF_button
					button_caption	=	"unlock programs"
					button_action	=	"unlockPrograms()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	"unlock programs"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>			
		</TD>
	</TR>
</TABLE>
<BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>

<TABLE CLASS="Maintable" WIDTH="85%" CELLPADDING="3" CELLSPACING="0">
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
	</TR>
	
	<!--- TABLE DATA QUERY --->
	<CFOUTPUT QUERY="getProgramLockedByUser">
		<!--- DATA OUTPUT --->
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD NOWRAP ALIGN="left">
				<CFSWITCH EXPRESSION="#Contract_Status_Type_IDX#">
					<CFCASE VALUE="1">
						<!--- WIP --->
						<IMG SRC="/images/wip.gif" ALT="Work in progress.">
					</CFCASE>
					<CFCASE VALUE="2">
						<!--- Ready For Approval --->
						<IMG SRC="/images/rfa.gif" ALT="Ready For Approval.">
					</CFCASE>
					<CFCASE VALUE="4">
						<!--- Preactive Programs --->
						<IMG SRC="/images/preactive.gif" ALT="Contract in pre-active state.">
					</CFCASE>
					<CFCASE VALUE="5">
						<!--- Active Programs --->
						<IMG SRC="/images/active.gif" ALT="Contract currently active.">
					</CFCASE>
					<CFCASE VALUE="7">
						<!--- Archived/Expired --->
						<IMG SRC="/images/expired.gif" ALT="Contract has expired.">
					</CFCASE>																		
				</CFSWITCH>
	
				<!--- show a lock for locked contracts --->
				<CFIF Sales_Agreement_Is_Locked EQ 1>
					<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
						SELECT Name_First, Name_Last
						FROM _Users
						WHERE User_ID = '#Sales_Agreement_Locked_By_User_ID#'
					</cfquery>
					<IMG SRC="/images/lock.gif" ALT="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
				</CFIF>		
			</TD>
			<TD NOWRAP>&nbsp;#Export_Sales_Agreement_Number#</TD>
			<TD width="100%">&nbsp;#Export_Sales_Agreement_Name#</TD>
			<TD NOWRAP>&nbsp;#dateformat(Export_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
			<TD NOWRAP>&nbsp;#dateformat(Export_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		</TR>	
	</CFOUTPUT>
</TABLE>
<CFIF getProgramLockedByUser.recordcount GT 25>
	<BR>
	<TABLE ALIGN="center">
		<TR>
			<TD>
				<CF_button
					button_caption	=	"unlock programs"
					button_action	=	"unlockPrograms()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	"unlock programs"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>			
			</TD>
			<TD STYLE="color:red; font-size:15px;font-weight:bold;">
				Please unlock the programs you have locked below before continuing.
			</TD>
			<TD>
				<CF_button
					button_caption	=	"unlock programs"
					button_action	=	"unlockPrograms()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	"unlock programs"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>			
			</TD>
		</TR>
	</TABLE>
</CFIF>

<script>
	function unlockPrograms(){
		document.all.UnlockForm.submit()
	}

</script>
<FORM ACTION="Sales_Agreement_Lock.cfm" METHOD="post" NAME="UnlockForm" ID="UnlockForm">
	<INPUT TYPE="Hidden" NAME="CID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
	<INPUT TYPE="Hidden" NAME="Programs_Unlocked" VALUE="1">
</FORM>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>

<CFELSE>
	
	<cfset this.editMode = 0 />
	<!---TSF: Label 9673 - Fixed check for URL.CID--->
	<CFIF not len(trim(URL.CID)) AND isdefined("FORM.CID")>
		<CFSET URL.CID = FORM.CID>
	</CFIF>
	
	<cfif URL.CID NEQ "" and URL.CID NEQ 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
	<CFSET CTLKR_Sales_Agreement_ID = cryp.value>
	
<cfset useLakebaseForCSLGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForCSLGetContractInfo>
	<cftry>
		<cfset CSLGetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#CTLKR_Sales_Agreement_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCSLGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCSLGetContractInfo>
<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT *
	FROM Export_Sales_Agreement
	WHERE Export_Sales_Agreement_ID = '#CTLKR_Sales_Agreement_ID#'
</CFQUERY>
</cfif>


	<cfset useLakebaseForisContractCurrentlyLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_sales_agreement")>
<cfif useLakebaseForisContractCurrentlyLocked>
	<cftry>
		<cfset isContractCurrentlyLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_sales_agreement", {
				"export_sales_agreement_id" = "eq.#CTLKR_Sales_Agreement_ID#",
				"select" = "sales_agreement_is_locked,sales_agreement_locked_by_user_id"
			}), "sales_agreement_is_locked,sales_agreement_locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisContractCurrentlyLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisContractCurrentlyLocked>
<cfquery name="isContractCurrentlyLocked" datasource="#application.datasource#">
		SELECT Sales_Agreement_Is_Locked, Sales_Agreement_Locked_By_User_ID
		FROM Export_Sales_Agreement
		WHERE Export_Sales_Agreement_ID ='#CTLKR_Sales_Agreement_ID#'
	</cfquery>
</cfif>
	
<!--- Lock that particular contract --->
	<CFIF isContractCurrentlyLocked.Sales_Agreement_Is_Locked EQ 0>
		<CFQUERY NAME="lockContractFromOtherUsers" datasource="#application.datasource#">
			UPDATE Export_Sales_Agreement
			Set Sales_Agreement_Is_Locked = 1
			,Sales_Agreement_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
			,Sales_Agreement_Lock_Date = #createodbcdatetime(Now())#
			WHERE Export_Sales_Agreement_ID = '#CTLKR_Sales_Agreement_ID#'
		</CFQUERY>
		<cfset this.editMode = 1 />
	</CFIF>

	<CFLOCATION url="Sales_Agreement_Edit_Menu.cfm?CID=#URL.CID#&editMode=#this.editMode#" ADDTOKEN="No">
<cfelse>
		<TABLE CLASS="Maintable" WIDTH="85%" CELLPADDING="3" CELLSPACING="0">
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		Invalid Sales Agreement Number. Please try again.</TD>
	</TR>
	</TABLE>
</cfif>
</CFIF>