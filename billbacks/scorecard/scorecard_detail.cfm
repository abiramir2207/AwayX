<cfheader name="Cache-Control" value="no-store">
<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="ALL">
<CFPARAM NAME="SHEXP" Default="All">
<CFPARAM NAME="URL.SORTBY" DEFAULT="BBI">

<!---Section variables--->
<CFPARAM NAME="SECTION_TITLE" DEFAULT="">
<CFPARAM NAME="QUERY_PREFIX" DEFAULT="WIP">
<CFPARAM NAME="SECTION_RECORDCOUNT" DEFAULT="0">
<CFPARAM NAME="SECTION_IMAGE" DEFAULT="WIP.GIF">

<!---How the data is sorted--->
<CFSET sql_Sort_By="dbo.billback.Billback_ID">
<CFSWITCH expression="#URL.SORTBY#">
	<!---Billback number--->
	<CFCASE value="BBI">
		<CFSET sql_Sort_By="dbo.Billback.BB_Code">
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
	<!--- sort by segment --->
	<CFCASE value="BBSE">
		<CFSET sql_Sort_By="business_unit_desc">
	</CFCASE>
	<CFCASE value="BBDEVIATED">
		<CFSET sql_Sort_By="Billback.Deviated">
	</CFCASE>
	<CFCASE value="BBCLOSURE">
		<CFSET sql_Sort_By="Billback.BB_Closing_Method">
	</CFCASE>
	<CFCASE value="BBREFN">
		<CFSET sql_Sort_By="Billback.referenceNum">
	</CFCASE>
	<CFCASE value="BBANA">
		<CFSET sql_Sort_By="BBanalyst.Name_Last">
	</CFCASE>
</CFSWITCH>

<!--- 
	1: WIP
	2: RFA
	3: Approved
	4: Paid
 --->
 
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!--- unlock this users contracts --->
<cfquery name="up_UnlockBillbacks" datasource="#application.datasource#">
exec up_UnlockBillbacks
@User_ID = '#request.AccessStructure.User_ID#'
</cfquery>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<!---Gets the current user's position--->

<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">

<CFPARAM NAME="WIP_Count"		DEFAULT="0">
<CFPARAM NAME="RFA_Count"		DEFAULT="0">
<CFPARAM NAME="Approved_Count"	DEFAULT="0">
<CFPARAM NAME="Paid_Count"		DEFAULT="0">


<!---WIP--->
<!--- Get all Scorecard Information that a particular user can see--->
<cfif URL.SECTION_TO_OPEN IS 1>
<CFQUERY NAME="WIP_ScorecardInfo" DATASOURCE="#application.datasource#">
SELECT 
	isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where deleted = 0 and contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned') as business_unit_desc,
	Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
	CASE
		WHEN Billback.Billback_Payee_Type_ID=1 OR Billback.Billback_Payee_Type_ID=5 THEN  
		 CASE
			 WHEN Billback_Distributor.Distributor_ID IS NULL THEN
			  Billback_Distributor.BB_Distributor_Name
			 ELSE
			  BSA_Foodservice_Customers.Name  
		 END
		WHEN Billback.Billback_Payee_Type_ID=2 OR Billback.Billback_Payee_Type_ID=7 THEN
		 CASE
			 WHEN Billback_Operator.Operator_ID IS NULL THEN
			  Billback_Operator.BB_Operator_Name
			 ELSE
			  BSA_Operator.Operator_Name  
		 END
		WHEN Billback.Billback_Payee_Type_ID=3 OR Billback.Billback_Payee_Type_ID=8 THEN 
		 CASE
			 WHEN Billback_Broker.Billback_Broker_ID IS NULL THEN
			  Billback_Broker.BB_Broker_Name
			 ELSE
			  BSA_Foodservice_Brokers.Broker_Name
		 END
		WHEN Billback.Billback_Payee_Type_ID=4 THEN
		 Billback_Unidentified_Payee.BB_UP_Name
	END AS Payee_Name
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
(Billback.Billback_Payee_Type_ID = 3)
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
(Billback.Billback_Payee_Type_ID = 1)
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
(Billback.Billback_Payee_Type_ID = 2)
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

WHERE
Billback.Deleted = 0
AND Billback.Billback_Status_ID = 1
AND Billback.Billback_Status_ID = 1  
AND (Billback.BB_Creator_User_Position_ID = '#getUserPosition.User_Positions_ID#'
	<cfif listlen(BillbackIDs) GT 0>
	OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
	</cfif>
	)

Order By #sql_Sort_By# ASC

</CFQUERY>
</cfif>

<cfif URL.SECTION_TO_OPEN IS 2>
<!---RFA--->
<!--- Get all Scorecard Information that a particular user can see--->
<CFQUERY NAME="RFA_ScorecardInfo" DATASOURCE="#application.datasource#">
SELECT 
	isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where deleted = 0 and contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned') as business_unit_desc,
	Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
	CASE
		WHEN Billback.Billback_Payee_Type_ID=1 THEN  
		 CASE
			 WHEN Billback_Distributor.Distributor_ID IS NULL THEN
			  Billback_Distributor.BB_Distributor_Name
			 ELSE
			  BSA_Foodservice_Customers.Name  
		 END
		WHEN Billback.Billback_Payee_Type_ID=2 THEN
		 CASE
			 WHEN Billback_Operator.Operator_ID IS NULL THEN
			  Billback_Operator.BB_Operator_Name
			 ELSE
			  BSA_Operator.Operator_Name  
		 END
		WHEN Billback.Billback_Payee_Type_ID=3 THEN 
		 CASE
			 WHEN Billback_Broker.Billback_Broker_ID IS NULL THEN
			  Billback_Broker.BB_Broker_Name
			 ELSE
			  BSA_Foodservice_Brokers.Broker_Name
		 END
		WHEN Billback.Billback_Payee_Type_ID=4 THEN
		 Billback_Unidentified_Payee.BB_UP_Name
	END AS Payee_Name
FROM Billback
LEFT JOIN Billback_Allied
		ON (Billback_Allied.Billback_ID = Billback.Billback_ID)
LEFT JOIN 	(	Billback_Broker
				LEFT JOIN  BSA_Foodservice_Brokers
						ON (Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
		  	)
		ON	(	(Billback_Broker.Billback_ID = Billback.Billback_ID)
				AND	(Billback.Billback_Payee_Type_ID = 3)
				AND	(Billback_Broker.Deleted = 0)
			)
LEFT JOIN 	(	Billback_Distributor
				LEFT JOIN 	BSA_Foodservice_Customers
						ON (Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
			)
		ON	(	(Billback_Distributor.Billback_ID = Billback.Billback_ID)
				AND	(Billback.Billback_Payee_Type_ID = 1)
				AND	(Billback_Distributor.Deleted = 0)
			)
LEFT JOIN 	(	Billback_Operator
				LEFT JOIN 	BSA_Operator
						ON	(Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
			)
		ON	(	(Billback_Operator.Billback_ID = Billback.Billback_ID)
				AND	(Billback.Billback_Payee_Type_ID = 2)
				AND	(Billback_Operator.Deleted = 0)
			)
LEFT JOIN Billback_Unidentified_Payee
		ON	(	(Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID)
				AND	(Billback.Billback_Payee_Type_ID = 4)
				AND	(Billback_Unidentified_Payee.Deleted = 0)
			)
WHERE	Billback.Deleted = 0
AND 	Billback.Billback_Status_ID = 2
AND 	(Billback.BB_Creator_User_Position_ID = '#getUserPosition.User_Positions_ID#'
	<cfif listlen(BillbackIDs) GT 0>
	OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
	</cfif>
	)

Order By #sql_Sort_By# ASC
</CFQUERY>
</cfif>

<cfif URL.SECTION_TO_OPEN IS 3>
<!---Approved--->
<!--- Get all Scorecard Information that a particular user can see--->
<CFQUERY NAME="Approved_ScorecardInfo" DATASOURCE="#application.datasource#">
SELECT 
	isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where deleted = 0 and contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned') as business_unit_desc,
	Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
	CASE
		WHEN Billback.Billback_Payee_Type_ID=1 THEN  
		 CASE
			 WHEN Billback_Distributor.Distributor_ID IS NULL THEN
			  Billback_Distributor.BB_Distributor_Name
			 ELSE
			  BSA_Foodservice_Customers.Name  
		 END
		WHEN Billback.Billback_Payee_Type_ID=2 THEN
		 CASE
			 WHEN Billback_Operator.Operator_ID IS NULL THEN
			  Billback_Operator.BB_Operator_Name
			 ELSE
			  BSA_Operator.Operator_Name  
		 END
		WHEN Billback.Billback_Payee_Type_ID=3 THEN 
		 CASE
			 WHEN Billback_Broker.Billback_Broker_ID IS NULL THEN
			  Billback_Broker.BB_Broker_Name
			 ELSE
			  BSA_Foodservice_Brokers.Broker_Name
		 END
		WHEN Billback.Billback_Payee_Type_ID=4 THEN
		 Billback_Unidentified_Payee.BB_UP_Name
	END AS Payee_Name
FROM Billback
LEFT JOIN 	Billback_Allied
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
(Billback.Billback_Payee_Type_ID = 3)
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
(Billback.Billback_Payee_Type_ID = 1)
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
(Billback.Billback_Payee_Type_ID = 2)
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

WHERE
Billback.Deleted = 0
AND Billback.Billback_Status_ID = 3
AND (Billback.BB_Creator_User_Position_ID = '#getUserPosition.User_Positions_ID#'
	<cfif listlen(BillbackIDs) GT 0>
	OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
	</cfif>
	)

Order By #sql_Sort_By# ASC
</CFQUERY>
</cfif>

<!---Paid--->
<!--- Get all Scorecard Information that a particular user can see--->
<cfif URL.SECTION_TO_OPEN IS 4>
<CFQUERY NAME="Paid_ScorecardInfo" DATASOURCE="#application.datasource#">
SELECT 
	isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where deleted = 0 and contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned') as business_unit_desc,
	Billback_Allied.BB_Is_Locked, Billback_Allied.BB_Locked_By_User_ID, Billback.*,
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
		WHEN Billback.Billback_Payee_Type_ID=5 THEN
		Billback_Broker.BB_Broker_Name
	END AS Payee_Name
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
(Billback.Billback_Payee_Type_ID = 3)
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
(Billback.Billback_Payee_Type_ID = 1)
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
(Billback.Billback_Payee_Type_ID = 2)
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

WHERE
Billback.Deleted = 0
AND Billback.Billback_Status_ID = 4
AND (Billback.BB_Creator_User_Position_ID = '#getUserPosition.User_Positions_ID#'
	<cfif listlen(BillbackIDs) GT 0>
	OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
	</cfif>
	)

Order By #sql_Sort_By# ASC
</CFQUERY>
</cfif>

<CFSET PAGE_TITLE="Billback Scorecard Detail">
<CFSET group="reports">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>

<!---Include header--->
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<BR>

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

<FONT COLOR="Red" SIZE="2"><CENTER><B><I>To find an item, hit Ctrl+F and a dialog box opens which allows you to enter your search string</I></B></CENTER></FONT>
<BR>
<p align="Center">
<strong>
[<cfif url.Section_To_Open IS 1>Work In Progress<cfelse><A href="scorecard_detail.cfm?Section_To_Open=1">Work In Progress</A> </cfif>]&nbsp; 
[<cfif url.Section_To_Open IS 2>Request For Approval<cfelse><A href="scorecard_detail.cfm?Section_To_OPen=2">Request For Approval</A></cfif> ]&nbsp; 
[<cfif url.Section_To_Open IS 3>Approved<cfelse><A href="scorecard_detail.cfm?Section_To_Open=3">Approved</A></cfif> ]&nbsp; 
[<cfif url.Section_To_Open IS 4>Paid<cfelse><A href="scorecard_detail.cfm?Section_To_Open=4">Paid</A></cfif> ]&nbsp; 
</strong>
</p>

<!---Sort by header--->

<CFSET SCURL="scorecard_detail.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#">

<cfset Section_Number = URL.SECTION_TO_OPEN>



<!---Set section variables--->
<CFIF Section_Number IS 1>

	<cfset SECTION_TITLE="Work In Progress">
	<cfset QUERY_PREFIX="WIP">
	<cfset SECTION_RECORDCOUNT = WIP_ScorecardInfo.RecordCount>

<CFELSEIF Section_Number IS 2>

	<cfset SECTION_TITLE="Request for Approval">
	<cfset QUERY_PREFIX="RFA">
	<cfset SECTION_RECORDCOUNT = RFA_ScorecardInfo.RecordCount>

<CFELSEIF Section_Number IS 3>
	
	<cfset SECTION_TITLE="Approved">
	<cfset QUERY_PREFIX="Approved">
	<cfset SECTION_RECORDCOUNT = Approved_ScorecardInfo.RecordCount>
	
<CFELSE>

	<cfset SECTION_TITLE="Paid">
	<cfset QUERY_PREFIX="Paid">
	<cfset SECTION_RECORDCOUNT = Paid_ScorecardInfo.RecordCount>
	
</CFIF>

<CFIF URL.SECTION_TO_OPEN EQ SECTION_NUMBER OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>

<blockquote>
<CF_openLayer
	bEnabled="0"
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="#SECTION_TITLE# - #SECTION_RECORDCOUNT#"  
	TitleClosed="#SECTION_TITLE# - #SECTION_RECORDCOUNT#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
	

	<TABLE CLASS="Maintable" WIDTH="99%" align="center" CELLPADDING="3" CELLSPACING="0" border="0"> 
 

	<CFIF #SECTION_RECORDCOUNT# NEQ 0>
	<cfoutput>
	<TR BGCOLOR="##FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1" nowrap><B>&nbsp; </B></TD>
		<TD ID="header" ALIGN="center" nowrap><B>UP &nbsp;  PNF</B></TD>
		<TD ID="header" NOWRAP><B><A HREF="#SCURL#&SORTBY=BBI">Payable ##</a></B></TD>
		<TD ID="header" nowrap><b>Billback ##</b></TD>
		<TD ID="header" nowrap><B><A HREF="#SCURL#&SORTBY=BBT">Title</A></B></TD>
		<TD ID="header" nowrap><B><A HREF="#SCURL#&SORTBY=Pay">Payee Name</A></B></TD>
		<TD ID="header" nowrap><B><A HREF="#SCURL#&SORTBY=BBD">Billback Date</a></B></TD>
		<TD ID="header" nowrap><B><A HREF="#SCURL#&SORTBY=BBSD">Start Date</a></B><BR></TD>
		<TD ID="header" nowrap><B><A HREF="#SCURL#&SORTBY=BBED">End Date</a></B><BR></TD>
		<TD ID="header" nowrap><B><A HREF="#SCURL#&SORTBY=BBA">$ Claimed</a></B><BR></TD>
		<TD ID="header" nowrap><b><A HREF="##">$ Deviation</a></b></TD>
	</TR>
	</cfoutput>
	</CFIF>

	<CFOUTPUT QUERY="#QUERY_PREFIX#_ScorecardInfo">
	<CF_CRYP type="en" key="#request.key#" string="#Billback_ID#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<!---warning and lock images--->	
			
			<cfset expiring = DateFormat(Now(),  'MM/DD/YYYY')  - DateFormat(BB_Date, 'MM/DD/YYYY')>
			<cfif expiring GT 12><img src="/images/redbutton.gif" title="This billback is in danger of being deducted.  It is now #expiring# since the billback date."><cfelse><img src="/Images/fill.gif" alt="" width="20" height="20" border="0"></cfif>&nbsp; 
		
			<!--- show a lock for locked contracts --->
			<CFIF BB_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#BB_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #LookUpTheLockingUser.Name_First# #LookUpTheLockingUser.Name_Last#" height="16" width="12">
<cfelse><img src="/images/fill.gif" width="12">
			</CFIF>
		</TD>
		
		<td align="center" nowrap>
		
		<!---No Payee--->
		<cfif BB_UP EQ 1>
		<img src="/images/yes_small.gif" title="Known payee...">
		<cfelse>
		<img src="/images/no_small.gif" title="Unknown payee...">
		</cfif>&nbsp; 
		<!---No program--->
		<cfif BB_PNF EQ 1>
		<img src="/images/yes_small.gif" title="Known program...">
		<cfelse>
		<img src="/images/no_small.gif" title="Unknown program...">
		</cfif>
		 
		</td>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

			<A HREF="../capture/INDEX.CFM?bbid=#Billback_ID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for billback #BB_Code#">#left(BB_Code, 50)#</A>


			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

		</TD>
		<td nowrap><cfif len(trim(#BB_Reference#)) EQ 0>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
		<cfelse>
		#left(BB_Reference, 25)#
		</cfif> &nbsp; </td>
		<TD width="50%">#left(BB_Title, 50)#&nbsp;<br></TD>
		<TD width="50%">#Payee_Name#&nbsp;<br></TD>

		<TD NOWRAP>#dateformat(BB_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(BB_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(BB_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>$#numberformat(BB_Amount, '_,___,___,___,___')# &nbsp;&nbsp;</TD>
		<td nowrap>$???</td>
		
	</TR>
	</CFOUTPUT>
	</table>
	
</CF_openLayer>	</blockquote>	
<BR>
<BR>



<!---Footer--->

<CFINCLUDE TEMPLATE="/includes/footer.cfm">

</BODY>
</HTML>
