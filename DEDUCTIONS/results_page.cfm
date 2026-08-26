<cfheader name="Cache-Control" value="no-store">
<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="ALL">
<CFPARAM NAME="SHEXP" Default="All">
<CFPARAM NAME="Source" default="Search">


<!---Section variables--->
<CFPARAM NAME="SECTION_TITLE" DEFAULT="">
<CFPARAM NAME="QUERY_PREFIX" DEFAULT="WIP">
<CFPARAM NAME="SECTION_RECORDCOUNT" DEFAULT="0">
<CFPARAM NAME="SECTION_IMAGE" DEFAULT="WIP.GIF">

<CFPARAM NAME="URL.SORTBY" DEFAULT="#Default_Sort#">
<cfparam name="URL.SORTORDER" 	default="#Default_Sort_Order#">

<!---How the data is sorted--->
<CFSET sql_Sort_By="dbo.billback.Billback_ID">
<CFSWITCH expression="#URL.SORTBY#">
	<!---Payable number--->
	<CFCASE value="BBI">
		<CFSET sql_Sort_By="dbo.Billback.BB_Code">
	</CFCASE>
	<!---Billback number--->
	<CFCASE value="BBNUM">
		<CFSET sql_Sort_By="dbo.Billback.BB_Reference">
	</CFCASE>	
	<!---Billback title--->
	<CFCASE value="BBT">
		<CFSET sql_Sort_By="dbo.Billback.BB_Title">
	</CFCASE>
	<!---Billback title--->
	<CFCASE value="Pay">
		<CFSET sql_Sort_By="Payee_Name">
	</CFCASE>
	<!---Billback Date--->
	<CFCASE value="BBD">
		<CFSET sql_Sort_By="dbo.Billback.BB_Date">
	</CFCASE>
	<!---Billback Start Date--->
	<CFCASE value="BBSD">
		<CFSET sql_Sort_By="dbo.Billback.BB_Start_Date">
	</CFCASE>
	<!---Billback End Date--->
	<CFCASE value="BBED">
		<CFSET sql_Sort_By="dbo.Billback.BB_End_Date">
	</CFCASE>
	<!---Billback Amount--->
	<CFCASE value="BBA">
		<CFSET sql_Sort_By="dbo.Billback.BB_Amount">
	</CFCASE>
	<!---Deviation Amount--->
	<CFCASE value="BBDev">
		<CFSET sql_Sort_By="dbo.Billback.BB_Deviation">
	</CFCASE>
</CFSWITCH>



<CFIF URL.SORTORDER EQ "DESC">
	<CFSET sql_Sort_By="#sql_Sort_By# DESC">
<CFELSE>
	<CFSET sql_Sort_By="#sql_Sort_By# ASC">
</CFIF>
 
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFINCLUDE TEMPLATE="unlock_billbacks.cfm">

<CFINCLUDE TEMPLATE="../../billbacks/Billback_Access_Permission.cfm">

<CFPARAM NAME="WIP_Count"		DEFAULT="0">
<CFPARAM NAME="RFA_Count"		DEFAULT="0">
<CFPARAM NAME="Approved_Count"	DEFAULT="0">
<CFPARAM NAME="Paid_Count"		DEFAULT="0">


<!---WIP--->
<!--- Get all Scorecard Information that a particular user can see--->
<CFQUERY NAME="BB_ScorecardInfo" DATASOURCE="#application.datasource#">
#PreserveSingleQuotes(AllowBillbackIDs)#

SELECT DISTINCT Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
CASE
	WHEN Billback.Billback_Payee_Type_ID=1 THEN  
	BSA_Foodservice_Customers.Name  
	
	WHEN Billback.Billback_Payee_Type_ID=2 THEN
	BSA_Operator.Operator_Name  
	
	WHEN Billback.Billback_Payee_Type_ID=3 THEN 
	BSA_Foodservice_Brokers.Broker_Name
	 
	WHEN Billback.Billback_Payee_Type_ID=4 THEN
	Billback_Unidentified_Payee.BB_UP_Name
	
	WHEN Billback.Billback_Payee_Type_ID=5 THEN
	Billback_Distributor.BB_Distributor_Name
	
	WHEN Billback.Billback_Payee_Type_ID=6 THEN
	Billback_Operator.BB_Operator_Name
	
	WHEN Billback.Billback_Payee_Type_ID=7 THEN
	Billback_Broker.BB_Broker_Name
	 
END AS Payee_Name,
(SELECT Count(Deleted) FROM Contract_Attachments WHERE Contract_Attachments.Billback_ID = Billback.Billback_ID AND Contract_Attachments.Deleted = 0) AS Document_Count,
<CFIF URL.SECTION_TO_OPEN GT 2>
ISNull(BB_Approved.Paid_Amount, 0) AS BB_Approved_Amount
<CFELSE>
'' AS BB_Approved_Amount
</CFIF>
FROM 
Billback
LEFT JOIN
Billback_Allied
ON (Billback_Allied.Billback_ID = Billback.Billback_ID)
LEFT JOIN 
(
Billback_Broker
LEFT JOIN
BSA_Foodservice_Brokers
ON
(Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
)
ON
(
(Billback_Broker.Billback_ID = Billback.Billback_ID)
AND
(
	(Billback.Billback_Payee_Type_ID = 3)
	OR
	(Billback.Billback_Payee_Type_ID = 7)
)
AND
(Billback_Broker.Deleted = 0)
)
 
LEFT JOIN 
(
Billback_Distributor
LEFT JOIN 
BSA_Foodservice_Customers
ON 
(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
)
ON
(
(Billback_Distributor.Billback_ID = Billback.Billback_ID)
AND
(
	(Billback.Billback_Payee_Type_ID = 1)
	OR
	(Billback.Billback_Payee_Type_ID = 5)
)
AND
(Billback_Distributor.Deleted = 0)
)
 

LEFT JOIN 
(
Billback_Operator
LEFT JOIN
BSA_Operator
ON
(Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
)
ON
(
(Billback_Operator.Billback_ID = Billback.Billback_ID)
AND
(
	(Billback.Billback_Payee_Type_ID = 2)
	OR
	(Billback.Billback_Payee_Type_ID = 6)
)
AND
(Billback_Operator.Deleted = 0)
)
 
LEFT JOIN Billback_Unidentified_Payee
ON
(
(Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID)
AND
(Billback.Billback_Payee_Type_ID = 4)
AND
(Billback_Unidentified_Payee.Deleted = 0)
)
<CFIF URL.SECTION_TO_OPEN GT 2>
LEFT JOIN BB_Approved
ON
BB_Approved.Billback_ID = Billback.Billback_ID
AND
Billback.Billback_Status_ID > 2
</CFIF>
WHERE
Billback.Deleted = 0
AND Billback.Billback_Status_ID = #URL.SECTION_TO_OPEN#  
AND (Billback.BB_Creator_User_Position_ID = '#getUserPosition.User_Positions_ID#'
	<cfif listlen(BillbackIDs) GT 0>
	OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
	</cfif>
	)

Order By #sql_Sort_By#

</CFQUERY>



<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>

<!--- Open layer Options--->
<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="Silver";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";  
	WIDTH="95%";
</CFSCRIPT>

<!---Sort by header--->

<CFSET SCURL="scorecard_detail.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#">

<cfset Section_Number = URL.SECTION_TO_OPEN>



<!---Set section variables--->
<CFIF Section_Number IS 1>
	<cfset SECTION_TITLE="Work In Progress">
<CFELSEIF Section_Number IS 2>
	<cfset SECTION_TITLE="Request for Approval">
<CFELSEIF Section_Number IS 3>
	<cfset SECTION_TITLE="Approved">
<CFELSE>
	<cfset SECTION_TITLE="Paid">
</CFIF>


<CFSET Table_Width=910>



<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">

<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">


<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=12>

	<CFSET SC_QUERY=BB_ScorecardInfo>
	<CFINCLUDE TEMPLATE="display_Billback_List.cfm">

	<TABLE WIDTH="98%" CELLSPACING="0" CELLPADDING="0">
	<TR>
		<TD>
		<CF_Next_Previous_For_Forms
		formname="MyForm"
		query="BB_ScorecardInfo"
		maxpages="30"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
		lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
		addparams="">
		</TD>
		<TD ALIGN="RIGHT">
			<FONT COLOR="Red" SIZE="2"><B>There <CFIF SECTION_RECORDCOUNT EQ 1>Is<CFELSE>Are</CFIF><CFOUTPUT>&nbsp;#SECTION_RECORDCOUNT#</CFOUTPUT> <CFIF SECTION_RECORDCOUNT EQ 1>Billback<CFELSE>Billbacks</CFIF> In This Status</B></FONT>
		</TD>
	</TR>
	</TABLE>
<CFOUTPUT>
<FORM ACTION="#CGI.SCRIPT_NAME#?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&SORTBY=#URL.SORTBY#&SORTORDER=#SORTORDER#" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">	
</FORM>
</CFOUTPUT>
</BODY>
</HTML>
