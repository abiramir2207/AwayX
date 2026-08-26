<!------ program_display.cfm ----->
<cfparam name="URL.CID" 	default="">
<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET CSL_Contract_Main_ID = cryp.value>
<cfparam name="url.display_program" default="0">
<cfparam name="getpositionabove" default="0">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="url.CatalogView" default="0">
<cfoutput>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif CSL_Contract_Main_ID EQ "" OR NOT isNumeric(CSL_Contract_Main_ID)>
	<cfabort>
</cfif>

<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">

<!---- from now on, summary view will display the full view except the rate information--->

<cfif GetSettings.Catalog_Type EQ 1 and url.display_program EQ 0>
	<cfset summaryView = true >
<cfelse>
	<cfset summaryView = false >
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<cfif url.EZTemplate EQ 0>
	<title><cfif not summaryView>Program Detail View - <cfelse>Catalog Summary - </cfif>[#CSLGetContractInfo.Contract_Number#] #CSLGetContractInfo.Contract_Title#</title>
<cfelse>
<title>Program Template - EZ Button Settings</title>
</cfif>
</head>
<body>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif NOT isDefined("URL.action_type")>
 <CFINCLUDE TEMPLATE="/includes/top_header.cfm">      <!--- 32512 --->
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif GetSettings.Catalog_Type EQ 4 and url.display_program EQ 0><!------ summary ----->
	<!------
	On show Program ID, Program Title and the first name, last name and phone number of the responsible user?
	----->
	<table BORDER="0" WIDTH="750" BGCOLOR="ffffff" CELLPADDING="0" CELLSPACING="0">
	<cfset col1Width = 191>
	<cfset col2Width = 537>
	<cfset colMidStyle = "border-left: 2px solid ##0000CC;padding-left: 10px;;">
	<TR>
		<TD COLSPAN="100%" BGCOLOR="">
		<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">#application.returned_customer_setting.company_name#</DIV>
		<B><FONT SIZE="+1" COLOR="Navy">#CreateObject("component", "components.programs.Program").getStatusDesc(CSLGetContractInfo.Contract_Status_Type_IDX)#: #CSLGetContractInfo.Contract_Number#</FONT></B>
		<!--- is trade eligible --->
		<cfif GetSettings.Include_Trade EQ 0>
		<font SIZE="2" COLOR="red"><I><cfif len(trim(GetSettings.Trade_Blurb)) GT 0>#GetSettings.Trade_Blurb#<cfelse>* Volumes from this program are not eligible for any other trade or promotional allowances</cfif></I></font>
		</cfif>
		<HR COLOR="Navy">&nbsp;</TD>
	</TR>
	<tr>
		<td width="#col1Width#">&nbsp;</td>
		<td width="#col2Width#" style="#colMidStyle#">&nbsp;
		</td>
	</tr>
	<tr>
		<td width="#col1Width#"><b><font size="2">Title</font></b></td>
		<td width="#col2Width#" style="#colMidStyle#">

		<font size="2">
		<b>#CSLGetContractInfo.Contract_Title#</b>
		</font>&nbsp;
		</td>
	</tr>



	<tr valign="top">
		<td width="#col1Width#"><b><font size="2">Period</font></b><br>&nbsp;</td>
		<td width="#col2Width#" style="#colMidStyle#">
		<b>
		<font size="2">#MonthAsString(datepart('m', CSLGetContractInfo.Contract_Start_Date))#&nbsp;#datepart('d', CSLGetContractInfo.Contract_Start_Date)#,&nbsp;#datepart('yyyy', CSLGetContractInfo.Contract_Start_Date)# to #MonthAsString(datepart('m', CSLGetContractInfo.Contract_End_Date))#&nbsp;#datepart('d', CSLGetContractInfo.Contract_End_Date)#,&nbsp;#datepart('yyyy', CSLGetContractInfo.Contract_End_Date)#</font></b>&nbsp;</td>
	</tr>
	<cfset businessSegmentsOn = 0>
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfif businessSegManager.isEnabled()>
		<cfset businessSegmentsOn = 1 />
		<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(CSLGetContractInfo.Contract_Main_ID) />
		<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
	</cfif>
	<!---display business segments if it's turned on--->
	<cfif businessSegmentsOn eq 1>
	<tr>
		<td width="#col1Width#"><font size="2">#appSettings.getbusiness_segment_label()#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#qGetThisBusSegment.Business_Unit_Desc#</font>&nbsp;
		</td>
	</tr>
	</cfif>
	<tr>
		<td width="#col1Width#"><font size="2">Program Type</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.Created_Type#</font>&nbsp;
		</td>
	</tr>
	<!---Only display if there are discount identifiers--->
	<cfif getGeneralSettings.Use_Discount_ID IS 1 AND len(trim(GetSettings.Discount_Identifier_ID)) GT 0>
	<cfset useLakebaseForGetDiscountIdentifier = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("discount_identifier")>
<cfif useLakebaseForGetDiscountIdentifier>
	<cftry>
		<cfset GetDiscountIdentifier = application.oLakebase.toQuery(
			application.oLakebase.selectRows("discount_identifier", {
				"discount_identifier_id" = "eq.#GetSettings.Discount_Identifier_ID#",
				"select" = "discount_identifier_number,discount_identifier_desc"
			}), "discount_identifier_number,discount_identifier_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDiscountIdentifier = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDiscountIdentifier>
<cfquery name="GetDiscountIdentifier" datasource="#application.datasource#">
		SELECT Discount_Identifier_Number, Discount_Identifier_Desc
		FROM Discount_Identifier
		WHERE Discount_Identifier_ID = '#GetSettings.Discount_Identifier_ID#'
	</cfquery>
</cfif>
	<tr>
		<td width="#col1Width#"><font size="2">Discount Identifier</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">(#GetDiscountIdentifier.Discount_Identifier_Number#)&nbsp;&nbsp;#GetDiscountIdentifier.Discount_Identifier_Desc#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	<tr>
		<td width="#col1Width#"><font size="2">#application.returned_customer_setting.reference_number_label#</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.Contract_Reference_Number#&nbsp;</font>
		</td>
	</tr>
	<!----Display legacy id if it's on--->
	 <!--- Dev Note: Milan 9360 --->
	<cfif appSettings.getView_Legacy_ID() EQ 1>
	<tr>
		<td width="#col1Width#"><font size="2">Legacy ID</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.LEGACY_DEAL_ID#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	<!----Display bid id if it's on--->
	<cfif application.returned_customer_setting.display_bid_id>
	<tr>
		<td width="#col1Width#"><font size="2">Bid ID</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">#CSLGetContractInfo.BID_NUMBER#&nbsp;</font>
		</td>
	</tr>
	</cfif>
	<cfset stSearch = StructNew()>
	<cfset stSearch.userPosition = CSLGetContractInfo.Creating_User_Position_ID>
	<cfset qUsers = CreateObject("component", "components.user.UserManager").search(stSearch) />
	<cfset qUsersByCreator = CreateObject("component", "components.programs.catalog.CataLogMan").init(CSL_Contract_Main_ID,qUsers).getUsersByCreator() />
	<tr valign="top">
		<td width="#col1Width#"><font size="2">Responsible Sales Person</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<table cellpadding="1" cellspacing="1" bgcolor="000000">
		<tr bgcolor="F3F1B1">
			<td><B>Creator</B></td>
			<td><B>Position</B></td>
			<td><B>Position Name</B></td>
			<td><B>Phone</B></td>
			<td><B>Email</B></td>
		</tr>
		<cfloop query="qUsersByCreator">
			<tr bgcolor="ffffff">
			<td><font size="2">#User_Full_Name#&nbsp;</font></td>
			<td>#USER_POSITIONS_ID#</td>
			<td>#POSITION_LABEL#</td>
			<td>#User_Work_Phone# <cfif Len(Work_Phone_Ext) GT 0> Ext: #Work_Phone_Ext#</cfif></td>
			<td><a href="mailto:#User_Email#">#User_Email#</a></td>
			</tr>
		</cfloop>
		</table>
	&nbsp;
	</td>
	</tr>
<tr>
	<td width="#col1Width#"><font size="2">Manager</font></td>
	<td width="#col2Width#" style="#colMidStyle#">
		<cfset getpositionabove = CreateObject("component", "components.geography.position").getFirstPositionAbove(CSLGetContractInfo.Creating_User_Position_ID) />
<cfif getpositionabove neq -1>
<cfset useLakebaseForPositionDescforManager = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_positions")>
<cfif useLakebaseForPositionDescforManager>
	<cftry>
		<cfset PositionDescforManager = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_positions", {
				"user_positions_id" = "eq.#getpositionabove#",
				"select" = "position_label"
			}), "position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForPositionDescforManager = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForPositionDescforManager>
<cfquery name="PositionDescforManager" datasource="#application.datasource#">
				SELECT Position_Label FROM User_Positions
				WHERE User_Positions_ID = '#getpositionabove#'
</cfquery>
</cfif>
<cfif PositionDescforManager.recordcount GT 0>
<cfquery name="getManagerDetails" datasource="#application.datasource#">
				SELECT top 1 name_first, name_last,Work_Phone,Work_Phone_Ext,user_email,title  from
				user_position_holders
				inner join _users on
				_users.user_id = user_position_holders.user_id
				and _users.deleted = 0
				where user_position_holders.user_positions_id = '#getpositionabove#'
				and user_position_type = 'P'
				and user_position_holders.deleted = 0
</cfquery>
</cfif>
<table cellpadding="2" cellspacing="0" border="0" bgcolor="F2F2F2">
<cfif getManagerDetails.recordcount GT 0>
<tr>
<td nowrap><B>Name:</B><font size="2">#getManagerDetails.name_first#  #getManagerDetails.name_last#(#PositionDescforManager.Position_Label#)</font>&nbsp;</td>
						<td width="1px">&nbsp;</td>
						<td><B>Phone:</B> <font size="2">#getManagerDetails.Work_Phone# <cfif Len(getManagerDetails.Work_Phone_Ext) GT 0> Ext: #getManagerDetails.Work_Phone_Ext#</cfif></font></td>
					</tr>
					<tr>
					<!--- <font size="2" color="000099">--->
						<td nowrap><B>Title:</B> &nbsp; <font size="2">#getManagerDetails.title#</font></td>
						<td  width="1px">&nbsp;</td>
						<td><B>Email:</B>&nbsp;&nbsp; <a href="mailto:#getManagerDetails.User_Email#"><font size="2">#getManagerDetails.User_Email#</font></a></td>
</tr></table>
<cfelse>
<cfif PositionDescforManager.recordcount GT 0>
<font size="2">#PositionDescforManager.Position_Label#</font>
</cfif>&nbsp;
</cfif>
<cfelse>&nbsp;
</cfif>
</td>
	</tr>

	<tr>
		<td width="#col1Width#"><font size="2">Notes</font></td>
		<td width="#col2Width#" style="#colMidStyle#">
		<font size="2">
		<!---FILTER: If there aren't any notes then say so--->
		<cfif Len(trim(CSLGetContractInfo.Notes))>#CSLGetContractInfo.Notes#<cfelse>(None)</cfif>&nbsp;</font>
		</td>
	</tr>
	</table>
<cfelse><!------ detail ----->
<!--- D12831: we do not want to display the cached view if it is catalog summary view, the cached file might have details which we don't want to display in the catalog summary view --->
<cfif url.EZTemplate EQ 0 and not summaryView>
	<cfset url.forceCachedView = 1 />
</cfif>
<!--- D12831: we do not want the calaog summary view to create a cached file, so that it won't be used by a regular view erroneously --->
<cfif summaryView>
	<cfset url.doNotCacheThisView = 1 />
</cfif>

<cfquery name="getContractNumber" datasource="#application.datasource#">
	SELECT CM.Contract_number, count(CM.Contract_number) AS TotalVersions
	FROM Contract_Main
	INNER JOIN Contract_Main CM
	ON          	CM.Contract_Number = Contract_Main.Contract_Number
	AND         CM.Approved = 1
	WHERE Contract_Main.Contract_Main_ID = #CSL_Contract_Main_ID#
	GROUP BY CM.Contract_number
</cfquery>

    <!--- skip displaying this option when parent page is contract revision history (access via revision history option on left panel inside a program)--->
    <cfif not cgi.http_referer contains "contract_revision_history.cfm"
          and getContractNumber.recordcount and getContractNumber.TotalVersions gt 1 and  request.AccessStructure.External_Customer_Profile_Access NEQ "1">
        <div style="width:775"><div align="right"> <strong><font color="Red">[</font><a href="##" onclick="javascript:window.open('/common_files/contracts/contract_revision_history.cfm?CID=#URL.CID#&Contract_Number=#getContractNumber.Contract_number#','RevisionHistory','location=1,status=1,scrollbars=1,resizable=1,width=1300,height=800,left=0');return false;"> view program versions </a><font color="Red">]</font><strong>&nbsp;&nbsp;&nbsp;</div></div>
    </cfif>
	<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
</cfif>

<br><br>
<div align="center">
<table><tr>
<cfif url.EZTemplate EQ 1>
<cfset url.Contract_Main_ID = CSL_Contract_Main_ID>
<CFINCLUDE TEMPLATE="\common_files\contracts\email_fax_handler.cfm">
<cf_cryp	type = "en" string = "#filename_email#" key = "#request.key#">
<CFSET Program_Number=cryp.value>
<td>
<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"print"
		BUTTON_ACTION	=	"NewWindow('/common_files/contracts/printer_friendly.cfm?id=#Program_Number#','help','800','600','Yes', 'No');return false;"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
</td>
<td>
<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"email"
		BUTTON_ACTION	=	"NewWindow('/common_files/contracts/contract_email_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#&EZTemplate=1','help','800','600','Yes', 'No');return false;"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
</td>
</cfif>
<td>
<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"close window"
		BUTTON_ACTION	=	"window.close();"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
</td>
</tr></table>
</div>

<cfinclude template="/common_files/focus.cfm">
</body>
</html>
</cfoutput>


