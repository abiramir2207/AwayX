<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">
<CFINCLUDE TEMPLATE="Date_Graph_Settings.cfm">

<CFPARAM NAME="URL.Billback_Program_ID"								DEFAULT="">
<CFSET Billback_Program_ID=URL.Billback_Program_ID>

<html>
<head>
	<title>Billback <cfoutput>#appSettings.getDeviationLabel()#</cfoutput> - Date</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>

<!------------------------------show spinner ---------------------------->
<!-----
<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
------->

<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Program_Dates">
	SELECT	Billback.BB_Start_Date, Billback.BB_End_Date, Billback.BB_Code, Billback.BB_Title
	,Contract_Main.Contract_Number,Contract_Main.Contract_Title
	, (
		<!--- Dev Note: (46562) - When "Date Tolerance" app setting has a positive number, then extend the program start day by x (appSettings.getDateTolerance)  days.
		This is just an easier solution than writing logic to look for date within x (appSettings.getDateTolerance)  days - That logic can get tricky.
		There should be no deviation, if the date is within the date tolerance limit.
		Note: Both program start date and end date should be within x (appSettings.getDateTolerance) days (overlap or not) of the program start date.
		--->
		SELECT DateAdd(d, -#appSettings.getDateTolerance()#, MIN(Approval_Start_Date))
		FROM 	BB_Program_Info 
		WHERE	
			BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
			AND
			BB_Program_Info.Deleted = 0
	) AS Program_Start_Date
	, (
		<!--- Dev Note: (46562) - When "Date Tolerance" app setting has a positive number, then extend the program end day by x (appSettings.getDateTolerance) days.
		This is just an easier solution than writing logic to look for date within x (appSettings.getDateTolerance) days - That logic can get tricky.
		There should be no deviation, if the date is within the date tolerance limit.
		Note: Both program start date and end date should be within x (appSettings.getDateTolerance) days (overlap or not) of the program end date.
		--->
		SELECT DateAdd(d,#appSettings.getDateTolerance()#,MAX(Approval_End_Date))
		FROM 	BB_Program_Info 
		WHERE	
			BB_Program_Info.Contract_Number = Contract_Main.Contract_Number
			AND
			BB_Program_Info.Deleted = 0
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
	INNER JOIN 	Contract_Main
	ON
	(
		(Contract_Main.Contract_Main_ID = Billback_Program.Program_ID)
		--AND
		--(Contract_Main.Deleted = 0)
	)	
	WHERE	
		Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
		AND
		Billback_Program.Deleted = 0
</CFQUERY>

<CFIF Billback_Program_Dates.recordCount GT 0>
<CFQUERY DBTYPE="QUERY" NAME="All_Unordered_Dates">
	SELECT	Program_Start_Date AS Start_Date, Program_End_Date AS End_Date, Contract_Number AS Code, (BB_Type + 0) AS THIS_BILLBACK
	FROM	Billback_Program_Dates
	UNION
	SELECT	BB_Start_Date AS Start_Date, BB_End_Date AS End_Date, BB_Code AS Code, (BB_Type + 1) AS THIS_BILLBACK
	FROM	Billback_Program_Dates
</CFQUERY>

<CFQUERY DBTYPE="QUERY" NAME="All_Dates">
	SELECT	*
	FROM	All_Unordered_Dates
	ORDER BY Start_Date
</CFQUERY>


<CFQUERY DBTYPE="QUERY" NAME="Last_Date">
	SELECT	End_Date AS This_Date
	FROM	All_Dates
	ORDER BY End_Date DESC
</CFQUERY>

<CFQUERY DBTYPE="QUERY" NAME="First_Date">
	SELECT	Start_Date AS This_Date
	FROM	All_Dates
	ORDER BY Start_Date ASC
</CFQUERY>



<CFSET first_Date = First_Date.This_Date>
<CFSET last_Date = Last_Date.This_Date>

<cfset Total_date_Span = 1 />
<cfif (first_Date NEQ "" and last_date NEQ "")>
	<CFSET Total_date_Span=DateDiff("d", first_Date, last_Date) + 1>
</cfif>

<CFOUTPUT>
<STYLE>
	TABLE.Date_Dev_Table
	{
		/*border-left:solid blue 1px;
		border-bottom:solid blue 1px;*/
	}
	
	TR.This_Billback TD
	{
		font-weight:bold;
	}
</STYLE>
<BR><BR>

<CFQUERY DBTYPE="QUERY" NAME="Get_All_Dates">
	SELECT	Start_Date AS This_Date, THIS_BILLBACK + 0 AS Date_Type
	FROM	All_Unordered_Dates
	UNION
	SELECT	End_Date AS This_Date, THIS_BILLBACK + 2 AS Date_Type
	FROM	All_Unordered_Dates	
</CFQUERY>

<CFQUERY DBTYPE="QUERY" NAME="Get_All_Dates_Ordered">
	SELECT	This_Date, Date_Type
	FROM	Get_All_Dates
	ORDER BY 	This_Date, Date_Type
</CFQUERY>

<cfset Billback_interval = 0 />
<cfif (isDefined("Billback_Program_Dates.BB_Start_Date") AND Billback_Program_Dates.BB_Start_Date NEQ "" AND isDefined("Billback_Program_Dates.BB_End_Date") AND Billback_Program_Dates.BB_End_Date NEQ "")>
	<CFSET Billback_interval=DATEDIFF("d", Billback_Program_Dates.BB_Start_Date, Billback_Program_Dates.BB_End_Date) + 1>
</cfif>
<CFSET This_Billback_Intervals="">
<CFSET Other_Billbacks_Started 	= 0>
<CFSET This_Billback_Started 	= false>
<CFSET Start_Counting			= false>
<CFSET Total_Overlap			= 0>
<CFSET D_First_Date				= "">
<CFSET D_Last_Date				= "">
<CFSET Stop_Loop				= false>
<CFSET last_Mile_Stone			= "">

<CFLOOP QUERY="Get_All_Dates_Ordered">	
	<CFIF Get_All_Dates_Ordered.Date_Type EQ 0>
		<!----- Other Billback STart ---->
		<CFIF This_Billback_Started EQ true>
			<CFSET Start_Counting = true>
			<CFIF Other_Billbacks_Started LTE 0>
				<CFSET D_First_Date	= Get_All_Dates_Ordered.This_Date>
				<CFIF DATEDIFF("d", last_Mile_Stone, Get_All_Dates_Ordered.This_Date) GTE 0>
					<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#last_Mile_Stone#~#DateAdd("d", -1, Get_All_Dates_Ordered.This_Date)#~A", ",")>
				</CFIF>
			</CFIF>
		</CFIF>
		<CFSET Other_Billbacks_Started 	= Other_Billbacks_Started + 1>
	<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 1>
		<!---- This Billback Start ---->
		<CFSET This_Billback_Started 	= true>
		<CFIF Other_Billbacks_Started GT 0>
			<CFSET Start_Counting = true>
			<CFSET D_First_Date	= Get_All_Dates_Ordered.This_Date>
		</CFIF>
		<CFSET last_Mile_Stone			= Get_All_Dates_Ordered.This_Date>
	<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 2>
		<!---- Other billback End ---->
		<CFSET Other_Billbacks_Started 	= Other_Billbacks_Started - 1>
		<CFIF Other_Billbacks_Started LTE 0>
			<CFIF Start_Counting>
				<CFSET D_Last_Date	= Get_All_Dates_Ordered.This_Date>
				<CFIF IsDate(D_First_Date) AND IsDate(D_Last_Date)>				
					<CFSET Total_Overlap = Total_Overlap + DateDiff("d", D_First_Date, D_Last_Date) + 1>
					<CFIF DATEDIFF("d", D_First_Date, D_Last_Date) GTE 0>
						<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#D_First_Date#~#D_Last_Date#~B", ",")>						
					</CFIF>
					<CFSET last_Mile_Stone			= DateAdd("d", 1, Get_All_Dates_Ordered.This_Date)>
				</CFIF>
			</CFIF>
			<CFSET Start_Counting = false>
		</CFIF>
	<CFELSEIF Get_All_Dates_Ordered.Date_Type EQ 3>
		<!----- This Billback End ---->
		<CFIF Start_Counting>
			<CFSET D_Last_Date	= Get_All_Dates_Ordered.This_Date>
			<CFIF IsDate(D_First_Date) AND IsDate(D_Last_Date)>				
				<CFSET Total_Overlap = Total_Overlap + DateDiff("d", D_First_Date, D_Last_Date) + 1>
				<CFIF DATEDIFF("d", D_First_Date, D_Last_Date) GTE 0>
					<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#D_First_Date#~#D_Last_Date#~B", ",")>								
				</CFIF>
			</CFIF>
		<CFELSE>
			<CFIF DATEDIFF("d", last_Mile_Stone, Get_All_Dates_Ordered.This_Date) GTE 0>
				<CFSET This_Billback_Intervals = ListAppend(This_Billback_Intervals, "#last_Mile_Stone#~#Get_All_Dates_Ordered.This_Date#~A", ",")>	
			</CFIF>
		</CFIF>
		<CFSET This_Billback_Started 	= false>
		<CFSET Stop_Loop				= true>
		<CFSET Start_Counting			= false>		
	</CFIF>
	<!----
	#Get_All_Dates_Ordered.This_Date# - #Get_All_Dates_Ordered.Date_Type# <BR>
	Start_Counting - #Start_Counting#<BR>
	First_Date - #D_First_Date# <BR>
	Last_Date - #D_Last_Date# <BR>
	Total_Overlap - #Total_Overlap#<BR>	
	last_Mile_Stone - #last_Mile_Stone#<BR>
	#This_Billback_Intervals#<BR>	
	<HR>
	------>
	
	<CFIF Stop_Loop>
		<CFBREAK>
	</CFIF>	
</CFLOOP>

<CFSET datesDeviated	=	Billback_interval - Total_Overlap>

<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0">
	<COLGROUP>
		<COL SPAN="2" NOWARAP STYLE="FONT-WEIGHT:BOLD;"></COL>
		<COL SPAN="2" NOWARAP></COL>
		<COL SPAN="1" WIDTH=""></COL>
	</COLGROUP>
	<TR>
		<CFSET BillbackDesc="Billback ## #Billback_Program_Dates.BB_Code#">
		<TD>Billback</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD>&nbsp;[#Billback_Program_Dates.BB_Code#]</TD>
		<TD>&nbsp;#Billback_Program_Dates.BB_Title#</TD>
		<TD>&nbsp;#DateFormat(Billback_Program_Dates.BB_Start_Date, "mm/dd/yy")#</TD>
		<TD>&nbsp;-&nbsp;</TD>
		<TD>&nbsp;#DateFormat(Billback_Program_Dates.BB_End_Date, "mm/dd/yy")#</TD>
		<TD>&nbsp;</TD>
	</TR>
	<TR>
		<CFSET pgmDesc="Program ## #Billback_Program_Dates.Contract_Number#">
		<TD>Program</TD>
		<TD>&nbsp;:&nbsp;</TD>
		<TD>&nbsp;[#Billback_Program_Dates.Contract_Number#]</TD>
		<TD>&nbsp;#Billback_Program_Dates.Contract_Title#</TD>
		<TD>&nbsp;#DateFormat(Billback_Program_Dates.Program_Start_Date, "mm/dd/yy")#</TD>
		<TD>&nbsp;-&nbsp;</TD>
		<TD>&nbsp;#DateFormat(Billback_Program_Dates.Program_End_Date, "mm/dd/yy")#</TD>
	</TR>
</TABLE>
</CFOUTPUT>


<HR COLOR="Orange">
<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" CLASS="Date_Dev_Table" ALIGN="CENTER" ID="Date_Overlap_Table" BACKGROUND="/Images/Grid_Blue.gif">
	<cfsetting enableCFoutputOnly = "Yes"> 
	
	<CFLOOP QUERY="All_Dates">
		<CFSET Graph_Legend1 = "">
		<CFSET Graph_Legend2 = "">
		<CFSET Graph_Legend3 = "">
		<CFSET Graph_Legend_Script = "">
		<CFSILENT>
		<CFSET thisItem = All_Dates.CurrentRow>
		<CFSET Start_Date=Start_Date>
		<CFSET End_Date=End_Date>
		<CFIF THIS_BILLBACK EQ 1>
			<CFSET Image_Name="blue.gif">
			<CFSET GRAPH_SPAN_CLASS="GRAPHSPAN_BLUE">
		<CFELSE>
			<CFSET Image_Name="black.gif">
			<CFSET GRAPH_SPAN_CLASS="GRAPHSPAN_BLACK">
		</CFIF>
		<CFIF THIS_BILLBACK EQ 0>
			<CFSET sDesc="Program ## #Code#">
		<CFELSE>
			<CFSET sDesc="Billback ## #Code#">
		</CFIF>

		<cfset This_Item_Empty_Span = 0 />
		<cfif (first_Date NEQ "" AND Start_Date NEQ "")>
			<CFSET This_Item_Empty_Span=DateDiff("d", first_Date, Start_Date)>
		</cfif>
		<CFSET Empty_Image_len=(This_Item_Empty_Span * Max_Length)/Total_date_Span>
		
		</CFSILENT>
		<CFOUTPUT><TR><TD>&nbsp;</TD></TR></CFOUTPUT>

			<CF_Graph_Full
							THIS_BILLBACK = "#THIS_BILLBACK#"
							This_Billback_Intervals = "#This_Billback_Intervals#"
							A_IMG="red.gif"
							B_IMG="blue.gif"
							A_CLASS="GRAPHSPAN_RED"
							B_CLASS="GRAPHSPAN_BLUE"
							Empty_Image_len="#Empty_Image_len#"
							Max_Length="#Max_Length#"
							Total_date_Span="#Total_date_Span#"
							thisItem="#thisItem#"
							START_DATE="#START_DATE#"
							END_DATE="#END_DATE#"
							GRAPH_SPAN_CLASS="#GRAPH_SPAN_CLASS#"
							sDesc="#sDesc#">
		<CFOUTPUT><TR><TD>&nbsp;</TD></TR></CFOUTPUT>
	</CFLOOP>
	<cfsetting enableCFoutputOnly = "No"> 
<CFOUTPUT>
	<TR>
		<TD>&nbsp;
		</TD>
	</TR>
	<TFOOT>
		<TR COLSPAN="100%" ALIGN="RIGHT" BGCOLOR="White">
			<TD>&nbsp;
			</TD>
		</TR>
		<TR>
			<!--- STYLE="border-top:solid cccccc 1px;"---->
			<TD COLSPAN="50%" ALIGN="LEFT" BGCOLOR="White">
			<!---
			<IMG SRC="/Images/Blue.gif" WIDTH="10" HEIGHT="#DATE_GRAPH_HEIGHT#">
			----->
			<!------<SPAN CLASS="GRAPHSPAN_BLUE" STYLE="WIDTH:30px"></SPAN>----->
			<TABLE ALIGN="LEFT" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
			<TD CLASS="GRAPHSPAN_BLUE" STYLE="WIDTH:30px"></TD>
			</TR></TABLE>
			&nbsp;&nbsp;No #appSettings.getDeviationLabel()# portion of current billback<BR>
			<!---
			<IMG SRC="/Images/Red.gif" WIDTH="10" HEIGHT="#DATE_GRAPH_HEIGHT#"> 
			---->
			<!------<SPAN CLASS="GRAPHSPAN_RED" STYLE="WIDTH:30px"></SPAN>----->
			<TABLE ALIGN="LEFT" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
			<TD CLASS="GRAPHSPAN_RED" STYLE="WIDTH:30px"></TD>
			</TR></TABLE>
			&nbsp;&nbsp;#appSettings.getDeviationLabel()# portion of current billback<BR>
			
			<!---
			<IMG SRC="/Images/Black.gif" WIDTH="10" HEIGHT="#DATE_GRAPH_HEIGHT#">
			---->
			<!------<SPAN CLASS="GRAPHSPAN_BLACK" STYLE="WIDTH:30px"></SPAN>----->
			<TABLE ALIGN="LEFT" CELLPADDING="0" CELLSPACING="0" BORDER="0" STYLE="border-collapse: collapse"><TR>
			<TD CLASS="GRAPHSPAN_BLACK" STYLE="WIDTH:30px"></TD>
			</TR></TABLE>
			&nbsp;&nbsp; Program
			</TD>
			<TD COLSPAN="5%" ALIGN="RIGHT" BGCOLOR="White">
			<CFIF USEIMGGRAPH>
			<CFSET scale=(Total_date_Span/Max_Length) * 20>
			<IMG SRC="/Images/Grid_Scale_Square.gif" BORDER="0" WIDTH="20" HEIGHT="20" ALIGN="absmiddle">&nbsp;=&nbsp;#scale# days</TD>
			</CFIF>
		</TR>
	</TFOOT>
</TABLE>


<!----
This_Billback_Start_Date
---->


<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Program_Date_Deviation_Info">
SELECT	
		BB_Program_Deviation_Info.Dates_Not_Match
		-----------------Total Amount claimed for this program
		, (IsNUll((SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
			FROM	Billback_Program
				INNER JOIN	Billback_Product
				ON
				(	(Billback_Product.Billback_ID = Billback_Program.Billback_ID) 
					AND
					(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					(Billback_Product.Deleted = 0)
				)
				INNER JOIN	Billback_Product_Detail
				ON
				(	(Billback_Product_Detail.Billback_ID = Billback_Product.Billback_id)
					AND
					(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
					AND
					(Billback_Product_Detail.Deleted = 0)
					AND
					(Billback_Product_Detail.BB_Rate IS NOT NULL)
					AND
					(LEN(Billback_Product_Detail.BB_Rate) > 0)
					AND
					(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
					AND
					(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
				)
			WHERE
				Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
			GROUP BY Billback_Program.Billback_Program_ID
			), 0)  + 
			IsNull((SELECT	SUM(CAST(Billback_Program_Lumpsum_Component.Amount AS FLOAT))
			FROM	Billback_Program
				INNER JOIN	 Billback_Program_Lumpsum_Component
				ON
				(
					(Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID)
					AND
					( Billback_Program_Lumpsum_Component.Deleted = 0)
				)
			WHERE
				Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
			GROUP BY Billback_Program.Billback_Program_ID), 0)
			) AS BB_Dollar_Amount
			-----------------Total Amount claimed for this program
	FROM	Billback_Program	
	INNER JOIN BB_Program_Deviation_Info
		ON
		(
			(BB_Program_Deviation_Info.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Program_Deviation_Info.Deleted = 0)
		)
	WHERE	
		Billback_Program.Billback_Program_ID = '#Billback_Program_ID#'
		AND
		Billback_Program.Deleted = 0
</CFQUERY>

<BR>
<B>Date mismatch #appSettings.getDeviationLabel()# calculation</B>
<HR COLOR="Orange">


<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="60%">	
	<TR>
		<TD>Total Billback Interval</TD>
		<TD>D1</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>		
		#Billback_interval# days
		</TD>
	</TR>
	<TR>
		<TD>Dates #appSettings.getDeviationLabel()#</TD>
		<TD>D2</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>		
		#datesDeviated#
		</TD>
	</TR>
	<CFIF appSettings.getDateTolerance()>
		<TR>
			<TD>Date Tolerance</TD>
			<TD>S1</TD>
			<TD>&nbsp:&nbsp;</TD>		
			<TD>		
			#appSettings.getDateTolerance()#
			</TD>
		</TR>
	</CFIF>
	<TR>
		<TD>Dates #appSettings.getDeviationLabel()# percentage</TD>
		<TD>D3 = D2 / D1</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>		
		<CFSET dates_Deviated_Percent=(datesDeviated * 100)/Billback_interval>
		#NumberFormat(dates_Deviated_Percent, DEVIATION_PERCENT_FORMAT)#%
		</TD>
	</TR>
	<TR>
		<TD>Total Amount claimed</TD>
		<TD>A1</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>#DollarFormat(Billback_Program_Date_Deviation_Info.BB_Dollar_Amount)#</TD>
	</TR>
	<TR>
		<TD>#appSettings.getDeviationLabel()# Amount</TD>
		<TD>A2 = A1 * D3</TD>
		<TD>&nbsp:&nbsp;</TD>		
		<TD>
		<CFSET dev_Claim_Amount = Val(Billback_Program_Date_Deviation_Info.BB_Dollar_Amount) * Val(dates_Deviated_Percent) / 100>
		#DollarFormat(dev_Claim_Amount)#
		</TD>
	</TR>
</TABLE>

</CFOUTPUT>
<CFIF ADDSCRIPT EQ "Yes">
<SCRIPT LANGUAGE="javaScript">
showDates();
</SCRIPT>
</CFIF>
</CFIF>
	<BR><BR>
<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
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

