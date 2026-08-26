<!------
bb_reset.cfm
----->
<cfset variables.Action = "Reset" />
<cfinclude template="Delete_Reset.cfm">
<!--- 
<CFSET reset_This_Billback = 1>

<CFIF NOT isDefined("URL.BBID")>
	<CFSET reset_This_Billback = 0>
</CFIF>


<CFIF reset_This_Billback>
	<CFSET Billback_ID = URL.BBID>
<CFSET variables.BBMan = CreateObject("component", "components.billback.BillbackManager") />
<CFSET variables.qGetReferencedBillbacks = variables.BBMan.getReferencedBillbacks(Billback_ID) />
	<CFIF variables.qGetReferencedBillbacks.recordcount GT 0>
		<CFSET reset_This_Billback = 0>
	</CFIF>
	<CFQUERY name="BB_Info" datasource="#Application.Datasource#">
		SELECT	BB_Code, BB_Title, Billback_Status_ID
		FROM	Billback
		WHERE
				Billback.Billback_ID = '#Billback_ID#'
				AND
				Billback.Deleted = 0
	</CFQUERY>
	<CFIF BB_Info.recordCount GT 0>
		<HTML>
		<HEAD>
		</HEAD>
		<BODY>
		<BLOCKQUOTE>
			<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
			</SCRIPT>
			<SCRIPT LANGUAGE="JavaScript">
			document.body.onload=new Function ("popupInit();")
			
			
			function initTheTooltip()
			{
				popUp(-1)
			}
			
			
			function reset_Goto_NextPage()
			{
				var formObj = document.all.MyForm;
				if(formObj.resetBillback.checked)
				{
					NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=3&Formname=MyForm&BBID='+document.all.Billback_ID.value+'&EDIT=1','BB_BusiConsi','800','400','Yes', 'Yes')		
					//formObj.submit();
				}
			}
			</SCRIPT>
			
			
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
			<IMG SRC="/images/preactive.gif" ALT="Approved.">&nbsp;Approved
		</TD>
	<CFIF LCase(application.returned_customer_setting.customer_keyword) EQ "conagra">
		<TD>
			<IMG SRC="/images/active.gif" ALT="Payment Request">&nbsp;Payment Request
		</TD>
	</TR>
	<TR>
	</CFIF>
		<TD>
			<IMG SRC="/images/expired.gif" ALT="Paid">&nbsp;Paid
		</TD>
	</TR>
	
</TABLE>
</DIV>
			<BR><BR>
			<CENTER>
			<h2><CFOUTPUT>
			Billback: 
			<CFSWITCH EXPRESSION="#BB_Info.Billback_Status_ID#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>				
				<CFCASE VALUE="3">
					<!--- Active Programs --->
					<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Archived/Expired --->
					<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
				</CFCASE>																	
			</CFSWITCH>
			[#(BB_Info.BB_Code)#] #BB_Info.BB_Title#</CFOUTPUT></h2>
			</CENTER>
			<CFIF reset_This_Billback EQ 1>
			<CENTER>
				<FONT COLOR="#FF0000" SIZE="+1">Are you sure you want to reset this billback to work in progress?</FONT>
			</CENTER>
				<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" ALIGN="CENTER" WIDTH="50%">
				  <TR>
				<FORM ACTION="bb_reset2.cfm" METHOD="post" ID="MyForm" NAME="MyForm">
					<TD ALIGN="CENTER">
						<INPUT NAME="resetBillback" TYPE="checkbox" VALUE="1">
						Yes, I want to reset this billback to WIP.
					</TD>
				</TR>
				<TR>
					<TD ALIGN="CENTER">
				<INPUT NAME="Billback_ID" TYPE="hidden" VALUE="<CFOUTPUT>#Billback_ID#</CFOUTPUT>">
				</FORM>
			
					<CF_BUTTON
					BUTTON_NAME		=	""
					BUTTON_CAPTION	=	"reset this billback"
					BUTTON_ACTION	=	"javascript:reset_Goto_NextPage();"
					BUTTON_TYPE		=	"link"
					BUTTON_WIDTH	=	"125"
					BUTTON_COLOR	=	"Navy"
					BUTTON_TIP		=	""
					FONT_COLOR		=	"White"
					FONT_SIZE		=	"12"
					FONT_WEIGHT		=	"bold">				
					</TD>
				  </TR>
				</TABLE>
			<CFELSE>
				<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;">
							Not Available for Reset.
						</TD>
					</TR>
				</TABLE>
			</CFIF>
			<CFIF BB_Info.Billback_Status_ID GT 2>
				<CFQUERY name="BB_Approved_Info" datasource="#Application.Datasource#">
					SELECT	Date_Approved, _Users.Name_First + ' ' + _Users.Name_Last AS Approved_User, BB_Approved.Paid_Amount
					FROM	BB_Approved
							LEFT JOIN _Users
							ON
							_Users.User_ID = BB_Approved.User_Approved
							AND
							_Users.Deleted = 0
					WHERE
							BB_Approved.Billback_ID = '#Billback_ID#'								
				</CFQUERY>
				<CFOUTPUT>
				<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;border-top:2px orange solid;border-bottom:2px orange solid;">
						This billback approved on <B>#DateFormat(BB_Approved_Info.Date_Approved, "mm/dd/yyyy")#</B> by <B>#BB_Approved_Info.Approved_User#</B> for amount <B>#DollarFormat(BB_Approved_Info.Paid_Amount)#</B>
						</TD>
					</TR>
				</TABLE>
				</CFOUTPUT>
				<!-----------------------------------------------------------
				Find the Payee
				Billback_Payee_Type_ID
				Payee_ID
				------------------------------------------------------------->				
				<CFINCLUDE TEMPLATE="/Billbacks/Deviation/BB_Payee.cfm">
				<CFIF NOT IsDefined("INC_Deviation_Constants")>
					<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Constants.CFM">
				</CFIF>
				<CFQUERY NAME="Get_Affected_Billbacks" DATASOURCE="#application.datasource#">
					SELECT	DISTINCT B2.BB_Code, B2.BB_Title, B2.BB_Start_Date, B2.BB_End_Date, B2.Billback_Status_ID, BA2.Date_Approved
					FROM	Billback B1
							INNER JOIN BB_Approved BA1
							ON
							BA1.Billback_ID = B1.Billback_ID
							INNER JOIN Billback_Program BP1
							ON B1.Billback_ID = BP1.Billback_ID
							AND
							BP1.Deleted = 0
							INNER JOIN Contract_Main CM1
							ON
							CM1.Contract_Main_ID = BP1.Program_ID
							INNER JOIN Program_Control_Panel_Options PT1
							ON
							PT1.ProgramControl_Panel_Options_ID  = CM1.ProgramType_ID
							INNER JOIN Billback_Product BPT1
							ON BP1.Billback_ID = BPT1.Billback_ID
							AND
							BPT1.Deleted = 0
							INNER JOIN Billback_Product BPT2
							ON BPT2.Product_ID = BPT1.Product_ID
							AND
							BPT2.Deleted = 0
							INNER JOIN Billback_Program BP2
							ON
							BP2.Billback_Program_ID = BPT2.Billback_Program_ID
							AND
							BP2.Deleted = 0
							INNER JOIN Contract_Main CM2							
							ON
							CM2.Contract_Main_ID = BP2.Program_ID
							AND
								((
									PT1.Generic_Type =  '#DEVIATION_CONSTANTS_Trade_Shelter#'
									AND
									CM2.Contract_Number = CM1.Contract_Number
								)
								OR
								(
									PT1.Generic_Type IN (#ListQualify(DEVIATION_CONSTANTS_Operator_Deviated, "'")#)
								))
							INNER JOIN Program_Control_Panel_Options PT2
							ON
							PT2.ProgramControl_Panel_Options_ID  = CM2.ProgramType_ID
							AND
							(
								PT2.Generic_Type IN  (#ListQualify(DEVIATION_CONSTANTS_Operator_Deviated, "'")#)
								OR
								CM2.Contract_Number = CM1.Contract_Number
							)
							INNER JOIN Billback B2
							ON
							B2.Billback_ID <> B1.Billback_ID
							AND
							B2.Billback_ID = BP2.Billback_ID
							AND
							B2.Billback_Payee_Type_ID = 1
							AND
							B2.Deleted = 0
							INNER JOIN	Billback_Distributor BD2
							ON
								BD2.Billback_ID = B2.Billback_ID
								AND
								<CFIF Billback_Payee_Type_ID EQ 1>
								BD2.Distributor_ID = '#Payee_ID#'
								<CFELSE>
								1=2
								</CFIF>								
								AND
								BD2.Deleted = 0
							INNER JOIN BB_Approved BA2
							ON
							BA2.Billback_ID = B2.Billback_ID
							AND
							(dbo.D_DATEDIFF('ms', BA1.Date_Approved, BA2.Date_Approved) > 0)
					WHERE
							B1.Billback_ID = '#Billback_ID#'
							AND
							B1.Deleted = 0
					ORDER BY BA2.Date_Approved
				</CFQUERY>
				<CFOUTPUT>
				<CFIF Get_Affected_Billbacks.RecordCOunt GT 0>
					<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0" CLASS="MainTable">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;border:none;"><B>The expected values for the following approved billbacks have been adjusted by this billback.</B></TD>
					</TR>
					<!--- <TR BGCOLOR="FFCE84">
						<TD>&nbsp;&nbsp;</TD>
						<TD>&nbsp;</TD>
						<TD COLSPAN="2" ID="header"><B>Billback</B></TD>
						<TD ID="header"><B>Span</B></TD>
						<TD ID="header"><B>Date Approved</B>&nbsp;<IMG SRC="/Images/down_1.gif"></TD>
					</TR> --->
					<CFLOOP QUERY="Get_Affected_Billbacks">
						<TR>
							<TD>&nbsp;</TD>
							<TD>
							<CFSWITCH EXPRESSION="#Billback_Status_ID#">
								<CFCASE VALUE="1">
									<!--- WIP --->
									<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="2">
									<!--- Ready For Approval --->
									<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>				
								<CFCASE VALUE="3">
									<!--- Active Programs --->
									<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="4">
									<!--- Archived/Expired --->
									<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="5">
									<!--- Archived/Expired --->
									<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>																	
							</CFSWITCH>
							</TD>
							<TD WIDTH="70">[#BB_Code#]</TD>
							<TD>#BB_Title#</TD>
							<TD>#DateFormat(BB_Start_Date, "mm/dd/yyyy")# - #DateFormat(BB_End_Date, "mm/dd/yyyy")#</TD>
							<TD>#DateFormat(Date_Approved, "mm/dd/yyyy")#</TD>
						</TR>
					</CFLOOP>
					</TABLE>
				</CFIF>
				
				

				<CFIF variables.qGetReferencedBillbacks.RecordCOunt GT 0>
					<TABLE WIDTH="90%" BORDER="0" CELLPADDING="2" CELLSPACING="0" CLASS="MainTable">
					<TR>
						<TD COLSPAN="100%" STYLE="font-size:12px;border:none;">
						<B>The approved amount of the following billbacks were adjusted to reflect the adjustments/exclusions created by this billback.</B>
						</TD>
					</TR>
					<TR BGCOLOR="FFCE84">
						<TD>&nbsp;&nbsp;</TD>
						<TD>&nbsp;</TD>
						<TD COLSPAN="2" ID="header"><B>Billback</B></TD>
						<TD ID="header"><B>Span</B></TD>
						<TD ID="header"><B>Date Approved</B>&nbsp;<IMG SRC="/Images/down_1.gif"></TD>
					</TR>
					<CFLOOP QUERY="variables.qGetReferencedBillbacks">
						<TR>
							<TD>&nbsp;</TD>
							<TD>
							<CFSWITCH EXPRESSION="#Billback_Status_ID#">
								<CFCASE VALUE="1">
									<!--- WIP --->
									<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="2">
									<!--- Ready For Approval --->
									<IMG SRC="/images/rfa.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>				
								<CFCASE VALUE="3">
									<!--- Active Programs --->
									<IMG SRC="/images/preactive.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="4">
									<!--- Archived/Expired --->
									<IMG SRC="/images/active.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>
								<CFCASE VALUE="5">
									<!--- Archived/Expired --->
									<IMG SRC="/images/expired.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
								</CFCASE>																	
							</CFSWITCH>
							</TD>
							<TD WIDTH="70">[#BB_Code#]</TD>
							<TD>#BB_Title#</TD>
							<TD>#DateFormat(BB_Start_Date, "mm/dd/yyyy")# - #DateFormat(BB_End_Date, "mm/dd/yyyy")#</TD>
							<TD>#DateFormat(Date_Approved, "mm/dd/yyyy")#</TD>
						</TR>
					</CFLOOP>
					</TABLE>
				</CFIF>
				
				</CFOUTPUT>
				
			</CFIF>
		</BLOCKQUOTE>
		</BODY>
		</HTML>
	<CFELSE>
		<CFSET reset_This_Billback = 0>
	</CFIF>
	
</CFIF>  --->