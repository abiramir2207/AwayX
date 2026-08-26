
<CFPARAM name="form.businessSegmentsOn" default="0">
<CFPARAM name="URL.ShowCheckBoxes" default="0">
<CFPARAM name="URL.SearchIsConductedFromOtherWindow" default="0">
<CFPARAM name="Form.SelectedPrograms" default="">
<cfparam name="form.ILPL_PreSubmit" default="">


<!---check to see if the business segment components exist before we run this--->
<!---check whether the directory exists or not--->
<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
<cfif DirectoryExists(theDir)>
	<!---if the directory exists then check the file--->
	<cfset theFile = "#theDir#BusinessSegmentManager.cfc" />
	<!---it the file exists then we can create the component--->
	<cfif FileExists(theFile)>
		<!---create and instance of the BusinessSegmentManager--->
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfif businessSegManager.isEnabled()>
			<cfset form.businessSegmentsOn = 1 />
		</cfif>
	</cfif>
</cfif>

<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
			<TR>
			<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="30"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>
			</TD>
			<TD ALIGN="RIGHT">
				<FONT COLOR="Red" SIZE="2"><B>There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Program<CFELSE>Programs</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</B></FONT>
			</TD>
			</TR>
			</TABLE>

			<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: F5F5DC; z-index: 5000;width:230;height:50;border:1px solid black;">
<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0">
	 	<TR>
			<TD>
				<IMG SRC="/images/wip.gif" ALT="Work in progress.">&nbsp;Work In Progress
			</TD>
			<TD>
				<IMG SRC="/images/rfa.gif" ALT="Ready For Approval.">&nbsp;Ready For Approval
			</TD>
		</TR>
		<TR>
			<TD>
				<IMG SRC="/images/preactive.gif" ALT="pre-active.">&nbsp;Pre-Active
			</TD>
			<TD>
				<IMG SRC="/images/active.gif" ALT="Active.">&nbsp;Active
			</TD>
		</TR>
		<TR>
			<TD>
				<IMG SRC="/images/expiring.gif" ALT="Expiring">&nbsp;Expiring
			</TD>
			<TD>
				<IMG SRC="/images/expired.gif" ALT="Expired">&nbsp;Expired
			</TD>
		</TR>
		<TR>
			<TD>
				<IMG SRC="/images/not_allowed.gif" ALT="Rejected/Lost">&nbsp;Rejected/Lost
			</TD>
		</TR>
	</TABLE>
</DIV>


<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")


function initTheTooltip()
{
	popUp(-1)
}
		
</SCRIPT>

<TABLE border="0" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" cellspacing="0" cellpadding="2" CLASS="Maintable">
<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
	<cf_cryp string="#TheQuery.Contract_Main_ID#" type="en" key="#request.key#">

	<TR <CFIF currentrow mod 2>BGCOLOR="##ccffcc"<CFELSE>BGCOLOR="##FFFFFF"</CFIF> VALIGN="TOP">
		<!--- <cfif URL.ShowCheckBoxes EQ 1><td><img src="/images/fill.gif" width="1" height="1"><input type="Checkbox" name="SelectedPrograms" value="#TheQuery.Contract_Main_ID#" <cfif listfind(form.PL_Final, TheQuery.Contract_Main_ID) NEQ 0> checked <cfset form.ILPL_PreSubmit = listappend(form.ILPL_PreSubmit, TheQuery.Contract_Main_ID)></cfif>></td></cfif> --->
		
		<TD NOWRAP ALIGN="left" WIDTH="#Status_Width#">						
			<CFSWITCH EXPRESSION="#TheQuery.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
<!------
OnMouseOver="javaScript: showLegend(1, this);" onmouseout="javaScript: showLegend(0, this);"
----->
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif"<!--- ALT="Contract expires in #diff# days."---> onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="8">
					<!--- Rejected/Lost --->
					<IMG SRC="/images/not_allowed.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>																		
			</CFSWITCH>
			
			<!--- show a lock for locked contracts --->
			<CFIF TheQuery.Contract_Is_Locked EQ 1>
				<cfset useLakebaseForLookUpTheLockingUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForLookUpTheLockingUser>
	<cftry>
		<cfset LookUpTheLockingUser = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#TheQuery.Contract_Locked_By_User_ID#",
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
					WHERE User_ID = '#TheQuery.Contract_Locked_By_User_ID#'
				</cfquery>
</cfif>
				<IMG SRC="/images/lock.gif" ALT="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			<CFELSE>
				<IMG SRC="/images/fill.gif" height="16" width="12">
			</CFIF>
			<CFIF TheQuery.Contract_Attachments_Count GT 0>
				<IMG SRC="/images/doc.gif" width="13" height="16" ALT="This program has #TheQuery.Contract_Attachments_Count# attached document(s)" height="16" width="13">
			<CFELSE>
				<IMG SRC="/images/fill.gif" width="13" height="16">
			</CFIF>
			<CFQUERY NAME="Get_Auto_Renew_Info" DATASOURCE="#application.datasource#">
				SELECT	DATEDIFF(d, GetDate(), AR_Notification_Date) AS After_Days, AR_Notification_Date
				FROM	Program_Auto_Renew
				WHERE
						Program_Auto_Renew.Renewed = 0
						AND
						Program_Auto_Renew.Program_ID = #TheQuery.contract_main_id#
						AND
						#TheQuery.Contract_Status_Type_IDX# > 2
			</CFQUERY>
			<CFIF Get_Auto_Renew_Info.RecordCount GT 0>
				<IMG SRC="/images/recycle1.gif" width="12" height="12" ALT="This program will be automatically renewed on #DateFormat(Get_Auto_Renew_Info.AR_Notification_Date, "mm/dd/yyyy")# (#Get_Auto_Renew_Info.After_Days# day(s))">
			<CFELSE>
				<IMG SRC="/images/fill.gif" width="12" height="12">
			</CFIF>	
		</TD>
		<TD NOWRAP ALIGN="left" WIDTH="#Status_Width#">						
			#TheQuery.Status_Desc#
		</TD>
		
		<TD NOWRAP WIDTH="#Number_Width#">
		<CF_CRYP type="en" key="#request.key#" string="#TheQuery.contract_main_id#">
		<CFSET CID = cryp.value>
		<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
		<cfif URL.SearchIsConductedFromOtherWindow EQ 0>
		<A TARGET="_parent" HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>
		<cfelse>
		#Contract_Number#
		</cfif>

		<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

		<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
			<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" ALT="This is a Revision...">
		</CFIF>
		
		</TD>
				
		<TD width="#Title_Width#" TITLE="#Contract_Title#">
		<CFIF Contract_Reference_Number NEQ "">
			<CFSET Ref_Num_Len=len(Contract_Reference_Number) + 5>
		<CFELSE>
			<CFSET Ref_Num_Len=0>
		</CFIF>
		<CFIF Ref_Num_Len GTE Title_Len>
			<CFSET Title_Len=Ref_Num_Len+2>
		</CFIF>
		<CFSET display_Title=Left(Contract_Title,Title_Len-Ref_Num_Len)>
		<CFIF LEN(display_Title) LT Len(Contract_Title)>
			<CFSET display_Title="#display_Title#...">
		</CFIF>
		#display_Title#<CFIF Contract_Reference_Number NEQ "">&nbsp;( #Contract_Reference_Number# )</CFIF>
		<BR>
		<CFIF TheQuery.Contract_Status_Type_IDX EQ 2>
			<B>Requesting Approval</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Broker_Approved_Date, 'mm/dd/yyyy')#
		<CFELSEIF TheQuery.Contract_Status_Type_IDX GTE 4>
			<B>Approver</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Approval_date, 'mm/dd/yyyy')#
		<CFELSE>
			&nbsp;
		</CFIF>
		</TD>
		<!------<TD NOWRAP width="#SD_Width#">#DateFormat(TheQuery.Contract_Start_Date,"mm/dd/yyyy")#</TD>
		<TD NOWRAP width="#ED_Width#">#DateFormat(TheQuery.Contract_End_Date,"mm/dd/yyyy")#</TD>----->
		<TD NOWRAP width="#Evaluate(SD_Width+ED_Width)#">#DateFormat(TheQuery.Contract_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(TheQuery.Contract_End_Date,"mm/dd/yyyy")#</TD>
		<TD NOWRAP width="#Evaluate(SD_Width+ED_Width)#">#DateFormat(TheQuery.Date_Needed,"mm/dd/yyyy")#<BR>#DateFormat(TheQuery.Open_Date,"mm/dd/yyyy")#</TD>

		<TD NOWRAP width="#Quantity_Width#">#numberformat(Contract_Quantity, '_,___,___,___,___')# #Abbreviation#&nbsp;</TD>
		<cfif form.businessSegmentsOn eq 1>
			<!------ <cfset qGetThisBusSegment = businessSegManager.get(Business_Segment_ID) />
			<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc /> ----->
			<TD width="#BusSeg_Width#" nowrap align="center" title="#HTMLEditFormat(Business_Unit_Desc)#">#Left(Business_Unit_Desc, 8)#<cfif Len(Business_Unit_Desc) gt 8>...</cfif></TD>
		</cfif>
		<TD width="#SCISSOR_Width#"><cfif Contract_Status_Type_IDX LTE 2 AND URL.SearchIsConductedFromOtherWindow EQ 0><a href="delete_program.cfm?CID=#CID#" target="_blank" onclick="return doScissors(this, '#Contract_Number#');"><img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" alt="click here to delete this record" border="0" style="cursor: pointer;"></a><cfelse>&nbsp;</cfif></TD>
		</TR>
</CFOUTPUT>			
</TABLE>