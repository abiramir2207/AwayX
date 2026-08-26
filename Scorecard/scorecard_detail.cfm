<cfheader name="Cache-Control" value="no-store">
<CFPARAM NAME="URL.SECTION_TO_OPEN" DEFAULT="ALL">
<CFPARAM NAME="URL.SHEXP" DEFAULT="false">
<CFPARAM NAME="URL.SORTBY" DEFAULT="CN">


<CFSET sql_Sort_By="dbo.contract_main.contract_number">
<CFSWITCH expression="#URL.SORTBY#">
	<CFCASE value="CN">
		<CFSET sql_Sort_By="dbo.contract_main.contract_number">
	</CFCASE>
	<CFCASE value="CT">
		<CFSET sql_Sort_By="dbo.contract_main.contract_Title">
	</CFCASE>
	<CFCASE value="SD">
		<CFSET sql_Sort_By="dbo.contract_main.Contract_Start_Date">
	</CFCASE>
	<CFCASE value="ED">
		<CFSET sql_Sort_By="dbo.contract_main.Contract_End_Date">
	</CFCASE>
</CFSWITCH>


<!--- 
	1: WIP
	2: RFA
	4: PA
	5: ACT
	6: EXP
 --->
 
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<!--- unlock this users contracts --->
<cfquery name="unlockTheirPrograms" datasource="#application.datasource#">
	UPDATE Contract_Main
	Set Contract_Is_Locked = 0 
	WHERE Contract_Is_Locked = 1 AND Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#' and DELETED = 0 and Flagged_As_Purged = 0
</cfquery>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>

<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<CFPARAM NAME="WIP_Count"		DEFAULT="0">
<CFPARAM NAME="RFA_Count"		DEFAULT="0">
<CFPARAM NAME="P_ACTIVE_Count"	DEFAULT="0">
<CFPARAM NAME="ACTIVE_Count"	DEFAULT="0">
<CFPARAM NAME="EXPIRING_Count"	DEFAULT="0">


<CFQUERY NAME="getAllConcernedProgramsWithDistributorsInMyPositionBranch" datasource="#application.datasource#">
SELECT     dbo.User_Positions.User_Positions_ID, dbo.Contract_Distributors.Contract_Main_ID, dbo.Contract_Main.Contract_Status_Type_IDX, 
                      dbo.Contract_Main.Contract_Is_Locked, dbo.Contract_Main.Contract_Locked_By_User_ID
FROM         dbo.User_Positions INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.User_Positions.Service_Market_ID = dbo.BSA_Foodservice_Brokers.Service_Market_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID INNER
                       JOIN
                      dbo.Contract_Distributors ON 
                      dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = dbo.Contract_Distributors.BSA_Foodservice_Customers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Distributors.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID
WHERE     (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Distributors.Deleted = 0) AND 
                      (dbo.BSA_Foodservice_Customers.Deleted = 0) AND (dbo.Contract_Main.Deleted = 0) AND 
                      (dbo.User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#)) AND (dbo.Contract_Main.Flagged_As_Purged = 0) 
					  --AND (dbo.Contract_Main.Force_Expiration_Flag = 0)
</CFQUERY>


<!--- find programs with brokers in positions that concern me --->
<CFQUERY NAME="getAllConcernedProgramsWithBrokersInMyPositionBranch" datasource="#application.datasource#">
SELECT     dbo.User_Positions.User_Positions_ID, dbo.Contract_Main.Contract_Status_Type_IDX, dbo.Contract_Brokers.Contract_Main_ID, 
                      dbo.Contract_Main.Contract_Locked_By_User_ID, dbo.Contract_Main.Flagged_As_Purged
FROM         dbo.User_Positions INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Service_Market_ID = dbo.Service_Markets.Service_Market_ID INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.Service_Markets.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID INNER JOIN
                      dbo.Contract_Brokers ON 
                      dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = dbo.Contract_Brokers.BSA_Foodservice_Brokers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Brokers.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID
WHERE     (dbo.Service_Markets.Deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Main.Deleted = 0) AND 
                      (dbo.User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#)) AND (dbo.Contract_Main.Flagged_As_Purged = 0) 
					  --AND (dbo.Contract_Main.Force_Expiration_Flag = 0)
</CFQUERY>









<CFIF URL.SECTION_TO_OPEN EQ 1>
	<!--- GET WIP COUNT --->
	<CFQUERY NAME="getWIPCount" datasource="#application.datasource#">
	SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation
	FROM         dbo.Contract_Main INNER JOIN
	                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE Contract_Status_Type_IDX = '1' AND Creating_User_Position_ID = '#getUserPosition.User_Positions_ID#' AND Deleted = 0
	ORDER BY #sql_Sort_By# ASC
	</CFQUERY>
</CFIF>

<CFIF URL.SECTION_TO_OPEN EQ 2>
<!--- GET RFA COUNT --->
<CFQUERY NAME="getRFACount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo._Users.Name_First, 
                      dbo._Users.Name_Last
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID INNER JOIN
                      dbo._Users ON dbo.Contract_Main.Broker_User_ID = dbo._Users.User_ID
	WHERE Contract_Status_Type_IDX = '2' AND 
	Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#) AND dbo.Contract_Main.Deleted = 0
ORDER BY #sql_Sort_By# ASC
</CFQUERY>
</CFIF>

<CFIF URL.SECTION_TO_OPEN EQ 4>
<!--- GET P_ACTIVE COUNT --->
<!--- find programs with distributors in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithDistributorsInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithDistributorsInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 4
	</cfquery>
<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = valuelist(getProgramsWithDistributorsInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = "">
</CFIF>
<!--- find programs with brokers in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithBrokersInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithBrokersInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 4
	</cfquery>
<CFSET ProgramsWithBrokersInPositionsThatConcernMe = valuelist(getProgramsWithBrokersInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithBrokersInPositionsThatConcernMe = "">
</CFIF>

<CFQUERY NAME="getP_ACTIVECount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo._Users.Name_First, 
                      dbo._Users.Name_Last
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID INNER JOIN
                      dbo._Users ON dbo.Contract_Main.Approved_By_User_ID = dbo._Users.User_ID
	WHERE Contract_Status_Type_IDX = '4' AND 
	Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#) AND dbo.Contract_Main.Deleted = 0
	AND dbo.Contract_Main.Flagged_As_Purged = 0 AND dbo.Contract_Main.Force_Expiration_Flag = 0
			<CFIF listlen(ProgramsWithDistributorsInPositionsThatConcernMe) GT 0>
				OR dbo.Contract_Main.Contract_Main_ID IN(#ProgramsWithDistributorsInPositionsThatConcernMe#)
			</CFIF>
			<CFIF listlen(ProgramsWithBrokersInPositionsThatConcernMe) GT 0>
				OR dbo.Contract_Main.Contract_Main_ID IN(#ProgramsWithBrokersInPositionsThatConcernMe#)
			</CFIF>
ORDER BY #sql_Sort_By# ASC
</CFQUERY>
</CFIF>
<CFIF URL.SECTION_TO_OPEN EQ 5>
<!--- GET ACTIVE COUNT --->
<!--- find programs with distributors in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithDistributorsInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithDistributorsInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 5
	</cfquery>
<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = valuelist(getProgramsWithDistributorsInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = "">
</CFIF>

<!--- find programs with brokers in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithBrokersInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithBrokersInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 5
	</cfquery>
<CFSET ProgramsWithBrokersInPositionsThatConcernMe = valuelist(getProgramsWithBrokersInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithBrokersInPositionsThatConcernMe = "">
</CFIF>
<CFQUERY NAME="getACTIVECount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo._Users.Name_First, 
                      dbo._Users.Name_Last
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID INNER JOIN
                      dbo._Users ON dbo.Contract_Main.Approved_By_User_ID = dbo._Users.User_ID
	WHERE Contract_Status_Type_IDX = '5' AND 
	Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#) AND dbo.Contract_Main.Deleted = 0
	AND dbo.Contract_Main.Flagged_As_Purged = 0 AND dbo.Contract_Main.Force_Expiration_Flag = 0
			<CFIF listlen(ProgramsWithDistributorsInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithDistributorsInPositionsThatConcernMe#)
			</CFIF>
			<CFIF listlen(ProgramsWithBrokersInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithBrokersInPositionsThatConcernMe#)
			</CFIF>
ORDER BY #sql_Sort_By# ASC
</CFQUERY>
</CFIF>
<CFIF URL.SECTION_TO_OPEN EQ 6>
<!--- GET EXP COUNT --->
<!--- find programs with distributors in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithDistributorsInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithDistributorsInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 6
	</cfquery>
<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = valuelist(getProgramsWithDistributorsInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = "">
</CFIF>

<!--- find programs with brokers in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithBrokersInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithBrokersInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 6
	</cfquery>
<CFSET ProgramsWithBrokersInPositionsThatConcernMe = valuelist(getProgramsWithBrokersInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithBrokersInPositionsThatConcernMe = "">
</CFIF>
<CFQUERY NAME="getEXPIRINGCount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo._Users.Name_First, 
                      dbo._Users.Name_Last
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID INNER JOIN
                      dbo._Users ON dbo.Contract_Main.Approved_By_User_ID = dbo._Users.User_ID
	WHERE Contract_Status_Type_IDX = '6' AND 
	Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#) AND dbo.Contract_Main.Deleted = 0
	AND dbo.Contract_Main.Flagged_As_Purged = 0 AND dbo.Contract_Main.Force_Expiration_Flag = 0
			<CFIF listlen(ProgramsWithDistributorsInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithDistributorsInPositionsThatConcernMe#)
			</CFIF>
			<CFIF listlen(ProgramsWithBrokersInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithBrokersInPositionsThatConcernMe#)
			</CFIF>			
ORDER BY #sql_Sort_By# ASC
</CFQUERY>
</CFIF>
<CFIF URL.SHEXP EQ "true">

<!--- GET EXPIRED COUNT --->
<!--- find programs with distributors in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithDistributorsInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithDistributorsInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 7
	</cfquery>
<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = valuelist(getProgramsWithDistributorsInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithDistributorsInPositionsThatConcernMe = "">
</CFIF>

<!--- find programs with brokers in positions that concern me --->
<CFIF listlen(GP_Position_List_From_My_Position_Down)GT 0>
	<cfquery name="getProgramsWithBrokersInMyPositionBranch" dbtype="query">
		SELECT Contract_Main_ID FROM getAllConcernedProgramsWithBrokersInMyPositionBranch
		WHERE Contract_Status_Type_IDX = 7
	</cfquery>
<CFSET ProgramsWithBrokersInPositionsThatConcernMe = valuelist(getProgramsWithBrokersInMyPositionBranch.Contract_Main_ID)>
<CFELSE>
	<CFSET ProgramsWithBrokersInPositionsThatConcernMe = "">
</CFIF>
<CFQUERY NAME="getEXPIREDCount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo._Users.Name_First, 
                      dbo._Users.Name_Last
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID INNER JOIN
                      dbo._Users ON dbo.Contract_Main.Approved_By_User_ID = dbo._Users.User_ID
	WHERE Contract_Status_Type_IDX = '7' AND 
	Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#) AND dbo.Contract_Main.Deleted = 0 AND dbo.Contract_Main.Flagged_As_Purged = 0 AND dbo.Contract_Main.Approved = 1
	AND dbo.Contract_Main.Flagged_As_Purged = 0 
	--AND dbo.Contract_Main.Force_Expiration_Flag = 0
			<CFIF listlen(ProgramsWithDistributorsInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithDistributorsInPositionsThatConcernMe#)
			</CFIF>
			<CFIF listlen(ProgramsWithBrokersInPositionsThatConcernMe) GT 0>
				OR Contract_Main_ID IN(#ProgramsWithBrokersInPositionsThatConcernMe#)
			</CFIF>			
ORDER BY #sql_Sort_By# ASC
</CFQUERY>
</CFIF>
<CFSET PAGE_TITLE="Scorecard Detail">
<CFSET group="reports">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET helpfilenumber= 2>
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Open layer Options																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
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
	WIDTH="100%";
</CFSCRIPT>


<CFIF URL.SECTION_TO_OPEN EQ 1 OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>


<FONT COLOR="Red" SIZE="2"><CENTER><B><I>To find an item, hit Ctrl+F and a dialog box opens which allows you to enter your search string</I></B></CENTER></FONT>
<BR>
<CFOUTPUT>
<CFSET SCURL="scorecard_detail.cfm?SECTION_TO_OPEN=#URL.SECTION_TO_OPEN#&SHEXP=#URL.SHEXP#">

<fieldset style="border-width:0; width:#width#;">
     <DIV STYLE="margin-left: 12px;">
	<TABLE WIDTH="95%" CELLPADDING="0" CELLSPACING="0">
	<TR VALIGN="bottom" ALIGN="CENTER">
		<TD NOWRAP><B>Sort By :&nbsp;</B></TD>
		<TD NOWRAP><B><CFIF URL.SORTBY EQ "CN"><FONT SIZE="2" COLOR="Red">[ </FONT></CFIF><A HREF="#SCURL#&SORTBY=CN">Program Number</A><CFIF URL.SORTBY EQ "CN"><FONT SIZE="2" COLOR="Red"> ]</FONT></CFIF></B></TD>
		<TD width="100%"><B><CFIF URL.SORTBY EQ "CT"><FONT SIZE="2" COLOR="Red">[ </FONT></CFIF><A HREF="#SCURL#&SORTBY=CT">Program Title</A><CFIF URL.SORTBY EQ "CT"><FONT SIZE="2" COLOR="Red"> ]</FONT></CFIF></B></TD>
		<TD><B><CFIF URL.SORTBY EQ "SD"><FONT SIZE="2" COLOR="Red">[ </FONT></CFIF><A HREF="#SCURL#&SORTBY=SD">Start Date</A><CFIF URL.SORTBY EQ "SD"><FONT SIZE="2" COLOR="Red"> ]</FONT></CFIF></B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD><B><CFIF URL.SORTBY EQ "ED"><FONT SIZE="2" COLOR="Red">[ </FONT></CFIF><A HREF="#SCURL#&SORTBY=ED">End Date</A><CFIF URL.SORTBY EQ "ED"><FONT SIZE="2" COLOR="Red"> ]</FONT></CFIF></B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD><B>&nbsp;</B><BR><IMG SRC="/images/fill.gif" WIDTH="120" HEIGHT="1"></TD>
		<TD>&nbsp;<IMG SRC="/images/fill.gif" WIDTH="14" HEIGHT="1"></TD>
	</TR>
	</TABLE>
	</DIV>
</fieldset>
<HR COLOR="Orange">
</CFOUTPUT>
<CFIF URL.SECTION_TO_OPEN EQ 1>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Work in Progress - #getWIPCount.recordcount#"  
	TitleClosed="Work in Progress - #getWIPCount.recordcount#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
<DIV STYLE="margin-left: 12px;">
	
	
	<TABLE CLASS="Maintable" WIDTH="95%" CELLPADDING="3" CELLSPACING="0">
	
	<CFIF getWIPCount.Recordcount NEQ 0>
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>Quantity</B><BR><IMG SRC="/images/fill.gif" WIDTH="90" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="10"></TD>
	</TR>
	</CFIF>

	<CFOUTPUT QUERY="getWIPCount">
	<CF_CRYP type="en" key="#request.key#" string="#getWIPCount.contract_main_id#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<CFSWITCH EXPRESSION="#getWIPCount.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" TITLE="Program in pre-active state.">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" TITLE="Program currently active.">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif" TITLE="Program expires in #diff# days.">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" TITLE="Program has expired.">
				</CFCASE>																		
			</CFSWITCH>

			<!--- show a lock for locked contracts --->
			<CFIF getWIPCount.Contract_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#getWIPCount.Contract_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			</CFIF>
		</TD>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

			<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>


			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

			<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" TITLE="This is a Revision...">
			</CFIF>

		</TD>
		<TD width="100%">#Contract_Title#&nbsp;( <CFIF Contract_Reference_Number EQ "">No Reference ##<CFELSE>#Contract_Reference_Number#</CFIF> )</TD>
		<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')# #Unit_of_Measure_Desc#&nbsp;&nbsp;</TD>
		
	</TR>
	</CFOUTPUT>
	</TABLE>
</DIV>
</CF_openLayer>

<BR>
<BR>
</CFIF>

<CFIF URL.SECTION_TO_OPEN EQ 2>

<CFIF URL.SECTION_TO_OPEN EQ 2 OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Request for approval - #getRFACount.recordcount#"  
	TitleClosed="Request for approval - #getRFACount.recordcount#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
<DIV STYLE="margin-left: 12px;">
	<TABLE CLASS="Maintable" WIDTH="95%" CELLPADDING="3" CELLSPACING="0">
	
	<CFIF getRFACount.Recordcount NEQ 0>
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header" WIDTH="100%"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header" WIDTH="90"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header" WIDTH="90"><B>Quantity</B><BR><IMG SRC="/images/fill.gif" WIDTH="90" HEIGHT="1"></TD>
		<TD ID="header">&nbsp;</TD>		
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="10"></TD>
	</TR>
	</CFIF>

	<CFOUTPUT QUERY="getRFACount">
	<CF_CRYP type="en" key="#request.key#" string="#getRFACount.contract_main_id#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<CFSWITCH EXPRESSION="#getRFACount.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" TITLE="Contract in pre-active state.">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" TITLE="Contract currently active.">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif" TITLE="Contract expires in #diff# days.">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" TITLE="Contract has expired.">
				</CFCASE>																		
			</CFSWITCH>
			
			<!--- show a lock for locked contracts --->
			<CFIF getRFACount.Contract_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#getRFACount.Contract_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			</CFIF>
		</TD>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
			
			<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>

			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

			<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" TITLE="This is a Revision...">
			</CFIF>

		</TD>
		<TD width="100%">#Contract_Title#&nbsp;( <CFIF Contract_Reference_Number EQ "">No Reference ##<CFELSE>#Contract_Reference_Number#</CFIF> ) <BR> <B>Requesting Approval</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Broker_Approved_Date, 'mm/dd/yyyy')#</TD>
		<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')# #Unit_of_Measure_Desc#&nbsp;</TD>
		
	</TR>
	</CFOUTPUT>
	</TABLE>
</DIV>
</CF_openLayer>
<BR>
<BR>
</CFIF>
<CFIF URL.SECTION_TO_OPEN EQ 4>
<CFIF URL.SECTION_TO_OPEN EQ 4 OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Pre-Active - #getP_ACTIVECount.recordcount#"  
	TitleClosed="Pre-Active - #getP_ACTIVECount.recordcount#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
<DIV STYLE="margin-left: 12px;">
	<TABLE CLASS="Maintable" WIDTH="95%" CELLPADDING="3" CELLSPACING="0">
	
	<CFIF getP_ACTIVECount.Recordcount NEQ 0>
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>Quantity</B><BR><IMG SRC="/images/fill.gif" WIDTH="90" HEIGHT="1"></TD>
		<TD ID="header">&nbsp;</TD>		
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="10"></TD>
	</TR>
	</CFIF>

	<CFOUTPUT QUERY="getP_ACTIVECount">
	<CF_CRYP type="en" key="#request.key#" string="#getP_ACTIVECount.contract_main_id#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<CFSWITCH EXPRESSION="#getP_ACTIVECount.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" TITLE="Contract in pre-active state.">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" TITLE="Contract currently active.">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif" TITLE="Contract expires in #diff# days.">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" TITLE="Contract has expired.">
				</CFCASE>																		
			</CFSWITCH>

			<!--- show a lock for locked contracts --->
			<CFIF getP_ACTIVECount.Contract_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#getP_ACTIVECount.Contract_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			</CFIF>		
		</TD>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

			<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>

			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

			<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" TITLE="This is a Revision...">
			</CFIF>

		</TD>
		<TD width="100%">#Contract_Title#&nbsp;( <CFIF Contract_Reference_Number EQ "">No Reference ##<CFELSE>#Contract_Reference_Number#</CFIF> ) <BR> <B>Approver</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Approval_date, 'mm/dd/yyyy')#</TD>
		<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')# #Unit_of_Measure_Desc#&nbsp;</TD>
		
	</TR>
	</CFOUTPUT>
	</TABLE>
</DIV>
</CF_openLayer>
<BR>
<BR>
</CFIF>
<CFIF URL.SECTION_TO_OPEN EQ 5>
<CFIF URL.SECTION_TO_OPEN EQ 5 OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Active - #getACTIVECount.recordcount#"  
	TitleClosed="Active - #getACTIVECount.recordcount#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
<DIV STYLE="margin-left: 12px;">
	<TABLE CLASS="Maintable" WIDTH="95%" CELLPADDING="3" CELLSPACING="0">
	
	<CFIF getACTIVECount.Recordcount NEQ 0>
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>Quantity</B><BR><IMG SRC="/images/fill.gif" WIDTH="90" HEIGHT="1"></TD>
		<TD ID="header">&nbsp;</TD>		
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="10"></TD>
	</TR>
	</CFIF>

	<CFOUTPUT QUERY="getACTIVECount">
	<CF_CRYP type="en" key="#request.key#" string="#getACTIVECount.contract_main_id#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<CFSWITCH EXPRESSION="#getACTIVECount.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" TITLE="Contract in pre-active state.">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" TITLE="Contract currently active.">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif" TITLE="Contract expires in #diff# days.">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" TITLE="Contract has expired.">
				</CFCASE>																		
			</CFSWITCH>

			<!--- show a lock for locked contracts --->
			<CFIF getACTIVECount.Contract_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#getACTIVECount.Contract_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			</CFIF>			
		</TD>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

			<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>


			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

			<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" TITLE="This is a Revision...">
			</CFIF>

		</TD>
		<TD width="100%">#Contract_Title#&nbsp; ( <CFIF Contract_Reference_Number EQ "">No Reference ##<CFELSE>#Contract_Reference_Number#</CFIF> )<BR> <B>Approver</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Approval_date, 'mm/dd/yyyy')#</TD>
		<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')# #Unit_of_Measure_Desc#&nbsp;</TD>
		
	</TR>
	</CFOUTPUT>
	</TABLE>
</DIV>
</CF_openLayer>
<BR>
<BR>
</CFIF>
<CFIF URL.SECTION_TO_OPEN EQ 6>
<CFIF URL.SECTION_TO_OPEN EQ 6 OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Expiring - #getEXPIRINGCount.recordcount#"  
	TitleClosed="Expiring - #getEXPIRINGCount.recordcount#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
<DIV STYLE="margin-left: 12px;">
	<TABLE CLASS="Maintable" WIDTH="95%" CELLPADDING="3" CELLSPACING="0">
	
	<CFIF getEXPIRINGCount.Recordcount NEQ 0>
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>Quantity</B><BR><IMG SRC="/images/fill.gif" WIDTH="90" HEIGHT="1"></TD>
		<TD ID="header">&nbsp;</TD>		
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="10"></TD>
	</TR>
	</CFIF>

	<CFOUTPUT QUERY="getEXPIRINGCount">
	<CF_CRYP type="en" key="#request.key#" string="#getEXPIRINGCount.contract_main_id#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<CFSWITCH EXPRESSION="#getEXPIRINGCount.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" TITLE="Contract in pre-active state.">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" TITLE="Contract currently active.">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif" TITLE="Contract expires in #diff# days.">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" TITLE="Contract has expired.">
				</CFCASE>																		
			</CFSWITCH>

			<!--- show a lock for locked contracts --->
			<CFIF getEXPIRINGCount.Contract_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#getEXPIRINGCount.Contract_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			</CFIF>			
		</TD>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
			
			<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>


			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

			<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" TITLE="This is a Revision...">
			</CFIF>

		</TD>
		<TD width="100%">#Contract_Title#&nbsp;( <CFIF Contract_Reference_Number EQ "">No Reference ##<CFELSE>#Contract_Reference_Number#</CFIF> ) <BR> <B>Approver</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Approval_date, 'mm/dd/yyyy')#</TD>
		<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')# #Unit_of_Measure_Desc#&nbsp;</TD>
		
	</TR>
	</CFOUTPUT>
	</TABLE>
</DIV>
</CF_openLayer>
</CFIF>
<CFIF URL.SHEXP EQ "true">

<BR>
<BR>

<CFIF URL.SECTION_TO_OPEN EQ 7 OR URL.SECTION_TO_OPEN EQ "ALL">
	<CFSET IsClosed = "No">
<CFELSE>
	<CFSET IsClosed = "Yes">
</CFIF>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Expired - #getEXPIREDCount.recordcount#"  
	TitleClosed="Expired - #getEXPIREDCount.recordcount#"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
<DIV STYLE="margin-left: 12px;">
	<TABLE CLASS="Maintable" WIDTH="95%" CELLPADDING="3" CELLSPACING="0">
	
	<CFIF getEXPIREDCount.Recordcount NEQ 0>
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header" ALIGN="center" WIDTH="1"><B>Status</B></TD>
		<TD ID="header" NOWRAP><B>Program</B></TD>
		<TD ID="header"><B>Title</B></TD>
		<TD ID="header"><B>Start</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>End</B><BR><IMG SRC="/images/fill.gif" WIDTH="75" HEIGHT="1"></TD>
		<TD ID="header"><B>Quantity</B><BR><IMG SRC="/images/fill.gif" WIDTH="90" HEIGHT="1"></TD>
		<TD ID="header">&nbsp;</TD>		
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="10"></TD>
	</TR>
	</CFIF>

	<CFOUTPUT QUERY="getEXPIREDCount">
	<CF_CRYP type="en" key="#request.key#" string="#getEXPIREDCount.contract_main_id#">
	<CFSET CID = cryp.value>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">

		<TD NOWRAP ALIGN="left">
			<CFSWITCH EXPRESSION="#getEXPIREDCount.Contract_Status_Type_IDX#">
				<CFCASE VALUE="1">
					<!--- WIP --->
					<IMG SRC="/images/wip.gif" TITLE="Work in progress.">
				</CFCASE>
				<CFCASE VALUE="2">
					<!--- Ready For Approval --->
					<IMG SRC="/images/rfa.gif" TITLE="Ready For Approval.">
				</CFCASE>
				<CFCASE VALUE="4">
					<!--- Preactive Programs --->
					<IMG SRC="/images/preactive.gif" TITLE="Contract in pre-active state.">
				</CFCASE>
				<CFCASE VALUE="5">
					<!--- Active Programs --->
					<IMG SRC="/images/active.gif" TITLE="Contract currently active.">
				</CFCASE>
				<CFCASE VALUE="6">
					<!--- Expiring --->
					<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
					<IMG SRC="/images/expiring.gif" TITLE="Contract expires in #diff# days.">
				</CFCASE>
				<CFCASE VALUE="7">
					<!--- Archived/Expired --->
					<IMG SRC="/images/expired.gif" TITLE="Contract has expired.">
				</CFCASE>																		
			</CFSWITCH>

			<!--- show a lock for locked contracts --->
			<CFIF getEXPIREDCount.Contract_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#getEXPIREDCount.Contract_Locked_By_User_ID#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This program is currently being viewed by #ucase(LookUpTheLockingUser.Name_First)# #ucase(LookUpTheLockingUser.Name_Last)#" height="16" width="12">
			</CFIF>			
		</TD>
		<TD NOWRAP>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>

			<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">#Contract_Number#</A>

			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>

			<CFIF Revision_of_Contract_Main_ID NEQ "" AND Is_A_Revision EQ 1>
				<IMG SRC="/images/repeat.gif" WIDTH="7" HEIGHT="7" BORDER="0" TITLE="This is a Revision...">
			</CFIF>

		</TD>
		<TD width="100%">#Contract_Title#&nbsp;( <CFIF Contract_Reference_Number EQ "">No Reference ##<CFELSE>#Contract_Reference_Number#</CFIF> ) <BR> <B>Approver</B>:&nbsp;#Name_First# #Name_Last# - #dateformat(Approval_date, 'mm/dd/yyyy')#</TD>
		<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
		<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')# #Unit_of_Measure_Desc#&nbsp;</TD>
		
	</TR>
	</CFOUTPUT>
	</TABLE>
</DIV>
</CF_openLayer>
<BR>
<BR>
</CFIF>
</BLOCKQUOTE>
<BLOCKQUOTE>
<BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE>
</BLOCKQUOTE>
</BODY>
</HTML>


