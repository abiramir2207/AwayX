<CFIF NOT IsDefined("INC_Deviation_Constants")>
	<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation_Constants.CFM">
</CFIF>
<CFSET Table_Width = 650>

<CFPARAM NAME="URL.Billback_Program_ID"								DEFAULT="">
<CFSET Billback_Program_ID=URL.Billback_Program_ID>

<CFIF NOT IsDefined("INC_Date_Graph_Settings")>
	<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Date_Graph_Settings.cfm">
</CFIF>
<CFPARAM NAME="SHOW_DEVIATION_DETAIL_HEADER" 	DEFAULT=True>
<CFPARAM NAME="SHOW_DEVIATION_DETAIL_FOOTER" 	DEFAULT=True>

<CFIF SHOW_DEVIATION_DETAIL_HEADER>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Billback <cfoutput>#DEVIATION_LABEL#</cfoutput> - Growth Total Amount</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>

<!------------------------------show spinner ---------------------------->

<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFIF ADDSCRIPT EQ "Yes">
<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
</CFIF>


<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<CFELSE>
	<BLOCKQUOTE>
</CFIF>



<SPAN CLASS="Title2">Expected Growth Amount Calculation</SPAN>
	<HR COLOR="Orange">
	<BR>
<CFSILENT>
<!--------------------------------------------------------------------------------------
Get Program which was active at Billback End Date
--------------------------------------------------------------------------------------->
<!---  only use cache when it is a billback detail  --->
<cfset variables.cachedWithin = (cgi.script_name contains "billback_detail.cfm" ? CreateTimeSpan(0, 1, 0, 0) : CreateTimeSpan(0, 0, 0, 0))>

<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Growth_Program">
	SELECT	Billback.Billback_ID, Billback.BB_Code, Billback.BB_Title, Billback.BB_Start_Date, Billback.BB_End_Date,
		BB_Approved.Date_Approved,
		Contract_Main.Contract_Main_ID,
		CASE
		WHEN Billback_Program.Program_ID IS NULL THEN
			Billback_Program.BB_Program_Number
		ELSE
			Contract_Main.Contract_Number
		END AS Contract_Number,
		CASE
		WHEN Billback_Program.Program_ID IS NULL THEN
			Billback_Program.BB_Program_Title
		ELSE
			Contract_Main.Contract_Title
		END AS Contract_Title,
		Contract_Main.Contract_Quantity_UOM_IDX
		, Program_Control_Panel_Options.Generic_Type
		, (
			SELECT 	MIN(Approval_Start_Date)
			FROM 	BB_Program_Info
			WHERE
				BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
				AND
				BB_Program_Info.Deleted = <cfqueryparam value=0>
			) AS Program_Start_Date
		, (
			SELECT 	MAX(Approval_End_Date)
			FROM 	BB_Program_Info
			WHERE
				BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
				AND
				BB_Program_Info.Deleted = <cfqueryparam value=0>
			) AS Program_End_Date
		, 0 AS BB_Type
	FROM	Billback_Program
	INNER JOIN	Billback
	ON
	(
		(Billback.Billback_ID = Billback_Program.Billback_ID)
		AND
		(Billback.Deleted = 0)
	)
	LEFT JOIN BB_Approved
	ON
	(
		(BB_Approved.Billback_ID = Billback.Billback_ID)
		AND
		(Billback.Billback_Status_ID >= 3)
	)
	LEFT JOIN 	Contract_Main
	ON
	(
		(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
	)
	LEFT JOIN	Program_Control_Panel_Options
	ON
	(
		(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID  = Contract_Main.ProgramType_ID)
		--AND
		--(Program_Control_Panel_Options.Deleted = 0)
	)
	WHERE
	(
		(Billback_Program.Billback_Program_ID = <cfqueryparam value='#Billback_Program_ID#'>)
		AND
		(Billback_Program.Deleted = <cfqueryparam value=0>)
	)
</CFQUERY>

<CFSET Billback_Start_Date 				= Billback_Growth_Program.BB_Start_Date>
<CFSET Billback_End_Date 				= Billback_Growth_Program.BB_End_Date>

<CFSET Program_Start_Date				= Billback_Growth_Program.Program_Start_Date>
<CFSET Program_End_Date					= Billback_Growth_Program.Program_End_Date>

<CFSET Billback_Total_Days 				= DateDiff("d", Billback_Start_Date, Billback_End_Date) + 1>
<CFSET Billback_ID						= Billback_Growth_Program.Billback_ID>
<CFSET Date_Approved					= Billback_Growth_Program.Date_Approved>

<CFSET Payable_Number					= Billback_Growth_Program.BB_Code>
<CFSET Billback_Title					= Billback_Growth_Program.BB_Title>
<CFSET Contract_Main_ID					= Billback_Growth_Program.Contract_Main_ID>
<CFSET Contract_Number					= Billback_Growth_Program.Contract_Number>
<CFSET Contract_Title					= Billback_Growth_Program.Contract_Title>

<CFSET Generic_Type 					= Billback_Growth_Program.Generic_Type>

<CFSET Program_UOM						= Billback_Growth_Program.Contract_Quantity_UOM_IDX>
</CFSILENT>
<CFIF Billback_Growth_Program.recordCount GT 0>
	<CFOUTPUT>


	<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="85%">
	<COLGROUP>
		<COL SPAN=2" NOWRAP STYLE="FONT-WEIGHT:BOLD;"></COL>
		<COL SPAN="5" NOWRAP></COL>
		<COL SPAN="1" WIDTH="20%"></COL>
	</COLGROUP>
	<TR>
		<CFSET BillbackDesc="Billback ## #Payable_Number#">
		<TD>Billback</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD NOWRAP>&nbsp;[#Payable_Number#]</TD>
		<TD>&nbsp;#Billback_Title#</TD>
		<TD>&nbsp;#DateFormat(Billback_Start_Date, "mm/dd/yyyy")#</TD>
		<TD>&nbsp;-&nbsp;</TD>
		<TD>&nbsp;#DateFormat(Billback_End_Date, "mm/dd/yyyy")#</TD>
		<TD>&nbsp;&nbsp;(#Billback_Total_Days# days)</TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR VALIGN="TOP">
		<CFSET pgmDesc="Program ## #Contract_Number#">
		<TD>Program</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD NOWRAP>&nbsp;[#Contract_Number#]</TD>
		<TD>&nbsp;#Contract_Title# &nbsp;&nbsp;&nbsp;
		<CFIF Contract_Main_ID EQ "">
		#DEVIATION_SHOW_PNF#</TD>
		<CFELSE>
		(#ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label)#)</TD>
		<TD>&nbsp;#DateFormat(Program_Start_Date, "mm/dd/yyyy")#</TD>
		<TD>&nbsp;-&nbsp;</TD>
		<TD>&nbsp;#DateFormat(Program_End_Date, "mm/dd/yyyy")#</TD>
		<TD>&nbsp;</TD>
		</CFIF>
	</TR>
	</TABLE>
	</CFOUTPUT>

	<CFSET Total_Program_Growth_Amount = 0>
	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Check_If_Payee_Is_Authorized">
	SELECT	Unauthorized_Payee
	FROM	BB_Program_Deviation_Info
	WHERE	BB_Program_Deviation_Info.Deleted = <cfqueryparam value=0>
	AND		BB_Program_Deviation_Info.Billback_Program_ID = <cfqueryparam value='#Billback_Program_ID#'>
	</CFQUERY>
	<CFIF Contract_Main_ID NEQ "" AND Check_If_Payee_Is_Authorized.Unauthorized_Payee EQ 0>
		<CFSET FromLumpSum = 0>
		<CFINCLUDE TEMPLATE="Growth_Common_Amount_Calc.cfm">
	<CFELSE>
		<CFINCLUDE TEMPLATE="BB_Payee.cfm">
	</CFIF>

	<CFOUTPUT>
	<BR>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="100%" STYLE="border:none">
		<cfif Check_If_Payee_Is_Authorized.Unauthorized_Payee NEQ 0>
		<font color="red">The payee is not authorized to billback against this program<br></font>
		</cfif>
		Total Program Growth Amount = #DollarFormat(Total_Program_Growth_Amount)#
		</TD>
	</TR>
	</TABLE>
	</CFOUTPUT>


	<!-----------------------------------------------------------
Find the Payee
Billback_Payee_Type_ID
Payee_ID
------------------------------------------------------------->
	<!-------------------------------------------------------------------------
	Get previous growth amount paid from
		other approved billbacks,
		same payee,
		same program
	-------------------------------------------------------------------------->
	<CFSET Other_Paid_Billback_Amount = 0>
	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Paid_Growth">
		SELECT	Billback.BB_Code, Billback.BB_Title,
				ISNULL(BB_Growth_Program.Paid_Amount, 0) AS Growth_Paid_Amount
		FROM
				Contract_Main
				INNER JOIN	Billback_Program
				ON
				(
					(Billback_Program.Program_ID = Contract_Main.Contract_Main_ID)
					AND
					(Billback_Program.Deleted = 0)
				)
				INNER JOIN	Billback
				ON
				(
					(Billback.Billback_ID = Billback_Program.Billback_ID)
					AND
					(Billback.Deleted = 0)
					AND
					(Billback.Billback_ID <> '#Billback_ID#')
					AND
					(Billback.Billback_Status_ID >= #DEVIATION_OVERLAPPED_BB_STATUS#)
				)
				<CFIF Date_Approved NEQ "">
					<CFIF IsDate(Date_Approved)>
						INNER JOIN BB_Approved
						ON
						(
							(BB_Approved.Billback_ID = Billback.Billback_ID)
							AND
							--(DATEDIFF(s, BB_Approved.Date_Approved, #CreateODBCDateTime(Date_Approved)#) > 0)
							(dbo.D_DATEDIFF('ms', BB_Approved.Date_Approved, #CreateODBCDateTime(Date_Approved)#) > 0)
						)
					</CFIF>
				</CFIF>
				<CFSWITCH EXPRESSION="#Billback_Payee_Type_ID#">
					<CFCASE VALUE="1">
					INNER JOIN	Billback_Distributor
					ON
					(
						(Billback_Distributor.Distributor_ID = '#Payee_ID#')
						AND
						(Billback_Distributor.Billback_ID = Billback.Billback_ID)
						AND
						(Billback.Billback_Payee_Type_ID = 1)
						AND
						(Billback_Distributor.Deleted = 0)
					)
					</CFCASE>
					<CFCASE VALUE="3">
					INNER JOIN	Billback_Broker
					ON
					(
						(Billback_Broker.Broker_ID = '#Payee_ID#')
						AND
						(Billback_Broker.Billback_ID = Billback.Billback_ID)
						AND
						(Billback.Billback_Payee_Type_ID = 3)
						AND
						(Billback_Broker.Deleted = 0)
					)
					</CFCASE>
					<CFCASE VALUE="2">
					INNER JOIN	Billback_Operator
					ON
					(
						(Billback_Operator.Operator_ID = #Payee_ID#)
						AND
						(Billback_Operator.Billback_ID = Billback.Billback_ID)
						AND
						(Billback.Billback_Payee_Type_ID = 2)
						AND
						(Billback_Operator.Deleted = 0)
					)
					</CFCASE>
					<CFDEFAULTCASE>
						INNER JOIN Billback_Distributor
						ON
						(
							(1=2)
						)
					</CFDEFAULTCASE>
				</CFSWITCH>
				INNER JOIN BB_Growth_Program
				ON
				(
					(BB_Growth_Program.Billback_ID = Billback.Billback_ID)
					AND
					(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(BB_Growth_Program.Deleted = 0)
				)
		WHERE
				Contract_Main.Contract_Number = <cfqueryparam value='#Contract_Number#'>
	</CFQUERY>

	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" CLASS="Maintable">
	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="100%" STYLE="border:none;color:Navy">
		Already Paid Growth
		</TD>
	</TR>
	<CFIF Billback_Paid_Growth.recordCount GT 0>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD">
			<TD>Billback</TD>
			<TD>Title</TD>
			<TD>Amount</TD>
		</TR>
		<CFOUTPUT QUERY="Billback_Paid_Growth">
			<CFSET Other_Paid_Billback_Amount = Other_Paid_Billback_Amount + Growth_Paid_Amount>
			<TR>
				<TD>#BB_Code#</TD>
				<TD>#BB_Title#</TD>
				<TD>#DollarFormat(Growth_Paid_Amount)#</TD>
			</TR>
		</CFOUTPUT>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%" STYLE="border:none">
			<FONT COLOR="Red">No other Paid Billback found</FONT>
			</TD>
		</TR>
	</CFIF>
	<CFOUTPUT>
	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="100%" STYLE="border:none">
		Total Paid Growth Amount (&##931; Amount) = #DollarFormat(Other_Paid_Billback_Amount)#
		</TD>
	</TR>
	</TABLE>
	</CFOUTPUT>

	<CFSET Expected_Growth_Amount = Total_Program_Growth_Amount - Other_Paid_Billback_Amount>


	<CFOUTPUT>
	<BR>
	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="#Table_Width#" CLASS="Maintable">
	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="100%" STYLE="border:none" bgcolor="yellow">
		Total Expected Growth Amount (Total Program Growth Amount - Total Paid Growth Amount) = #DollarFormat(Expected_Growth_Amount)#
		</TD>
	</TR>

	<cfquery cachedWithin="#variables.cachedWithin#"  dataSource="#application.datasource#" NAME="Billback_Program_Capture_Growth">
		SELECT	BB_Growth_Program.BB_Growth_Amount AS Total_Growth_Claimed
				, BB_Growth_Program.Expected_Amount
		FROM
				BB_Growth_Program
		WHERE
				(
					(BB_Growth_Program.Billback_Program_ID = <cfqueryparam value='#Billback_Program_ID#'>)
					AND
					(BB_Growth_Program.Deleted = <cfqueryparam value=0>)
				)
	</CFQUERY>

	<CFSET Total_Growth_Claimed = Billback_Program_Capture_Growth.Total_Growth_Claimed>
	<CFIF Total_Growth_Claimed LT Expected_Growth_Amount>
	<TR CLASS="MaintableTHEAD" bgcolor="yellow">
		<TD COLSPAN="100%" STYLE="border:none">
		Effective Expected Growth Amount = Total Growth Claimed = #DollarFormat(Total_Growth_Claimed)#
		</TD>
	</TR>
	</CFIF>
	</TABLE>
	</CFOUTPUT>




	<CFIF Billback_Program_Capture_Growth.recordCount GT 0>
		<CFSET Total_Growth_Claimed = Billback_Program_Capture_Growth.Total_Growth_Claimed>
		<CFSET Expected_Growth_Amount = Billback_Program_Capture_Growth.Expected_Amount>

		<!------------- Show deviation calculation ------------------>
		<BR><CFOUTPUT>
		<SPAN CLASS="Title2">Growth #DEVIATION_LABEL_SMALL# calculation</SPAN>
		<HR COLOR="Orange">

			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="#Evaluate("Table_Width*2/3")#">
				<TR>
					<TD>Total Growth Claimed</TD>
					<TD>A1</TD>
					<TD>&nbsp:&nbsp;</TD>
					<TD>
					#DollarFormat(Total_Growth_Claimed)#
					</TD>
				</TR>
				<TR>
					<TD><B>Expected Growth Amount</B></TD>
					<TD><B>A2</B></TD>
					<TD>&nbsp:&nbsp;</TD>
					<TD>
					<B>#DollarFormat(Expected_Growth_Amount)#</B>
					</TD>
				</TR>
				<TR>
					<TD>#DEVIATION_LABEL# Amount</TD>
					<TD>A3 = A2 - A1</TD>
					<TD>&nbsp:&nbsp;</TD>
					<TD>
					<CFSET dev_Growth_Amount = Expected_Growth_Amount - Total_Growth_Claimed>
					#DollarFormat(dev_Growth_Amount)#
					</TD>
				</TR>
				<!--------
				<CFIF Billback_Rate_Tolerance.recordCount GT 0>
					<CFSET rate_Tolerance = Billback_Rate_Tolerance.BB_Tolerance_ERT>
				<CFELSE>
					<CFSET rate_Tolerance = 0>
				</CFIF>
				---------->
				<TR>
					<TD>Growth #DEVIATION_LABEL# Percentage</TD>
					<TD>P1 = A3 / A1</TD>
					<TD>&nbsp:&nbsp;</TD>
					<TD>
					<CFSET dev_Growth_Percent = (dev_Growth_Amount * 100) / Total_Growth_Claimed>
					#NumberFormat(dev_Growth_Percent, DEVIATION_PERCENT_FORMAT)#%
					</TD>
				</TR>
			</TABLE>
			</CFOUTPUT>
	</CFIF>
</CFIF>

<CFIF SHOW_DEVIATION_DETAIL_FOOTER>
	<CFIF ADDSCRIPT EQ "Yes">
	<SCRIPT LANGUAGE="JavaScript">
	window.onbeforeprint=new Function ("AllOpenLayers(1);");
	</SCRIPT>
	</CFIF>
<BR><BR>
<TABLE ALIGN="CENTER" WIDTH="50%">
	<TD ALIGN="CENTER">
	<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"printPage();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"print"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
	<TD ALIGN="CENTER">
	<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</TABLE>
		<BR><BR>

</BLOCKQUOTE>
</BODY>
</HTML>
<CFELSE>
	</BLOCKQUOTE>
</CFIF>
