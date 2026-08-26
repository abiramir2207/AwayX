<CFSET PAGETITLE = "PROGRAMS: FORMULA PRICING - PROGRAMS">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFPARAM NAME="URL.RID" 	DEFAULT="">

<CFSET FORMULA_PAGE_NAME="4">
<CFINCLUDE TEMPLATE="Formula_Price_Header.cfm">

<CFSET URL.RID = Trim(URL.RID)>
<CFSET URL.SORT_BY = "ContractNumber">
<CFSET STR_SORT_BY = "Contract_Number">
<CFSWITCH EXPRESSION="#URL.SORT_BY#">
	<CFCASE VALUE="ContractNumber">
		<CFSET STR_SORT_BY = "Contract_Number">
	</CFCASE>
</CFSWITCH>

<CFIF URL.RID NEQ "">
	<CFQUERY NAME="Programs_Attached_To_This_Formula" DATASOURCE="#application.datasource#">
		SELECT	Contract_Main.Contract_Status_Type_IDX, Contract_Main.Contract_Number, Contract_Main.Contract_Title,
				Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date
		FROM	Program_Formula_Pricing_Rule_Mapped
			INNER JOIN	Contract_Main
			ON
			Contract_Main.Contract_Main_ID = Program_Formula_Pricing_Rule_Mapped.Program_ID
			AND
			Contract_Main.Deleted = 0
			AND
			Contract_Status_Type_IDX >= 0
			AND
			Contract_Main.Flagged_As_Purged = 0				
			AND
			(
				(Contract_Main.Force_Expiration_Flag = 0)
				OR
				(Contract_Status_Type_IDX = 7)
			)	
		WHERE
			Program_Formula_Pricing_Rule_Mapped.Deleted = 0
			AND
			Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = '#URL.RID#'
		ORDER BY #STR_SORT_BY#
	</CFQUERY>
<CFELSE>
	<CFSET Programs_Attached_To_This_Formula = QueryNew("")>
</CFIF>


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
	</TABLE>
</DIV>
<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")


function initTheTooltip()
{
	popUp(-1)
}
		
</SCRIPT>


<!------ACTIVE DELETED FORMULA_PRICING_RULE_ID NUMBER_OF_COMMS RULE_NAME ----->
<BR>
<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3" ALIGN="CENTER" WIDTH="90%" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD>&nbsp;</TD>
		<TD WIDTH="50"><B>Status</B></TD>
		<TD WIDTH="150"><B>#</B></TD>
		<TD WIDTH="70%"><B>Title</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	<CFOUTPUT QUERY="Programs_Attached_To_This_Formula">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
		<TD>&nbsp;</TD>
		<TD>
		<CFSWITCH EXPRESSION="#Contract_Status_Type_IDX#">
		<CFCASE VALUE="1">
			<!--- WIP --->
			<IMG SRC="/images/wip.gif" onmouseover="initTheTooltip('')" onmouseout="popOut()">
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
	</CFSWITCH>
		</TD>
		<TD>[#Contract_Number#]</TD>
		<TD>#Contract_Title#</TD>
		<TD>&nbsp;</TD>
	</TR>
	</CFOUTPUT>
</TABLE>

</BODY>
</HTML>
