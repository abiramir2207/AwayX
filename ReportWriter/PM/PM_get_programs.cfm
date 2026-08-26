<CFIF isDefined("Form.get_Program_Submit")>
	<CFOUTPUT>
	<cfparam name="Form.Contract_Number" 	default="">
	<script>
		opener.document.all.#Form.ParentFormname#.Contract_Number.value = '#Form.Contract_Number#'
		opener.document.all.#Form.ParentFormname#.submit()
		window.close()		
	</script>
	</CFOUTPUT>
	<CFABORT>
</CFIF>

<!--- 
	1: WIP
	2: RFA
	4: PA
	5: ACT
	6: EXP
 --->

<!---  
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<CFFLUSH>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
 --->
 
 
 
 
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
FROM         dbo.User_Positions  INNER JOIN
                      dbo.BSA_Foodservice_Brokers ON 
                      dbo.User_Positions.Service_Market_ID = dbo.BSA_Foodservice_Brokers.Service_Market_ID INNER JOIN
                      dbo.BSA_Foodservice_Customers ON 
                      dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID INNER
                       JOIN
                      dbo.Contract_Distributors ON 
                      dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = dbo.Contract_Distributors.BSA_Foodservice_Customers_ID INNER JOIN
                      dbo.Contract_Main ON dbo.Contract_Distributors.Contract_Main_ID = dbo.Contract_Main.Contract_Main_ID
WHERE    (dbo.User_Positions.Deleted = 0) AND (dbo.Contract_Distributors.Deleted = 0) AND 
                      (dbo.BSA_Foodservice_Customers.Deleted = 0) AND (dbo.Contract_Main.Deleted = 0) AND 
                      (dbo.User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#)) AND (dbo.Contract_Main.Flagged_As_Purged = 0) AND 
                      (dbo.Contract_Main.Force_Expiration_Flag = 0)
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
                      (dbo.User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#)) AND (dbo.Contract_Main.Flagged_As_Purged = 0) AND 
                      (dbo.Contract_Main.Force_Expiration_Flag = 0)
</CFQUERY>








<!--- GET WIP COUNT --->
<CFQUERY NAME="getWIPCount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
WHERE Contract_Status_Type_IDX = '1' AND Creating_User_Position_ID = '#getUserPosition.User_Positions_ID#' AND Deleted = 0
</CFQUERY>



<!--- GET RFA COUNT --->
<CFQUERY NAME="getRFACount" datasource="#application.datasource#">
SELECT     dbo.Contract_Main.*, dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo._Users.Name_First, 
                      dbo._Users.Name_Last
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID INNER JOIN
                      dbo._Users ON dbo.Contract_Main.Broker_User_ID = dbo._Users.User_ID
	WHERE Contract_Status_Type_IDX = '2' AND 
	Creating_User_Position_ID IN(#GP_Position_List_From_My_Position_Down#) AND dbo.Contract_Main.Deleted = 0
</CFQUERY>



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
	ORDER BY dbo.contract_main.contract_number asc
</CFQUERY>



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
	ORDER BY dbo.contract_main.contract_number asc			
</CFQUERY>





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
	ORDER BY dbo.contract_main.contract_number asc
</CFQUERY>







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
<!------<CFQUERY NAME="getEXPIREDCount" datasource="#application.datasource#">
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
	ORDER BY dbo.contract_main.contract_number asc
</CFQUERY>
----->




<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Select Programs</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="10" TOPMARGIN="10" onload="">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFINCLUDE TEMPLATE="/includes/header.cfm"> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!------<FORM NAME="MyForm" ONSUBMIT="this.target=window.opener.name; window.close()" ACTION="PM_create.cfm?RID=<CFOUTPUT>#URL.RID#</CFOUTPUT>" METHOD="post">----->
<FORM NAME="MyForm" ACTION="PM_get_programs.cfm?RID=<CFOUTPUT>#URL.RID#</CFOUTPUT>" METHOD="post">
<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="/help_files/manual/projects/new.cfm#Programs" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Summary">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
<CFOUTPUT>
<INPUT TYPE="hidden" NAME="RID" VALUE="#URL.RID#">
<INPUT TYPE="hidden" NAME="ParentFormname" VALUE="#URL.FormName#">
</CFOUTPUT>


<!--- 
<FONT COLOR="Red" SIZE="2"><CENTER><B><I>To find an item, hit Ctrl+F and a dialog box opens which allows you to enter your search string</I></B></CENTER></FONT>
 --->
	
	<TABLE CLASS="Maintable" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%" CLASS="Maintable">
 
	<TR><TD COLSPAN="100%" STYLE="border-bottom:2px solid red;"><SPAN CLASS="title2"><BR>Work in progress</SPAN></TD></TR>	

	<CFOUTPUT QUERY="getWIPCount">
	<CF_CRYP type="en" key="#request.key#" string="#getWIPCount.contract_main_id#">
	<CFSET CID = cryp.value>
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT TYPE="checkbox" NAME="Contract_Number" VALUE=""></TD>
		<TD NOWRAP>
			#Contract_Number#<!--- <A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">&nbsp;&nbsp;&nbsp;#Contract_Number#</A> --->
		</TD>
		<TD>#Contract_Title#&nbsp;</TD>
	</TR>
	</CFOUTPUT>

	<TR><TD COLSPAN="100%" STYLE="border-bottom:2px solid red;"><SPAN CLASS="title2"><BR>Request for Approval</SPAN></TD></TR>	

	<CFOUTPUT QUERY="getRFACount">
	<CF_CRYP type="en" key="#request.key#" string="#getRFACount.contract_main_id#">
	<CFSET CID = cryp.value>
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT TYPE="checkbox" NAME="Contract_Number" VALUE="#Contract_Number#"></TD>
		<TD NOWRAP WIDTH="90">
			&nbsp;&nbsp;&nbsp;#Contract_Number#<!--- <A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">&nbsp;&nbsp;&nbsp;#Contract_Number#</A> --->
		</TD>
		<TD>#Contract_Title#</TD>
	</TR>
	</CFOUTPUT>

	<TR><TD COLSPAN="100%" STYLE="border-bottom:2px solid red;"><SPAN CLASS="title2"><BR>Pre-Active</SPAN></TD></TR>	

	<CFOUTPUT QUERY="getP_ACTIVECount">
	<CF_CRYP type="en" key="#request.key#" string="#getP_ACTIVECount.contract_main_id#">
	<CFSET CID = cryp.value>
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT TYPE="checkbox" NAME="Contract_Number" VALUE="#Contract_Number#"></TD>
		<TD NOWRAP>
			&nbsp;&nbsp;&nbsp;#Contract_Number#<!--- <A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">&nbsp;&nbsp;&nbsp;#Contract_Number#</A> --->
		</TD>
		<TD>#Contract_Title#</TD>
	</TR>
	</CFOUTPUT>

	<TR><TD COLSPAN="100%" STYLE="border-bottom:2px solid red;"><SPAN CLASS="title2"><BR>Active</SPAN></TD></TR>	

	<CFOUTPUT QUERY="getACTIVECount">
	<CF_CRYP type="en" key="#request.key#" string="#getACTIVECount.contract_main_id#">
	<CFSET CID = cryp.value>
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT TYPE="checkbox" NAME="Contract_Number" VALUE="#Contract_Number#"></TD>
		<TD NOWRAP>
			&nbsp;&nbsp;&nbsp;#Contract_Number#<!--- <A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">&nbsp;&nbsp;&nbsp;#Contract_Number#</A> --->
		</TD>
		<TD>#Contract_Title#</TD>
	</TR>
	</CFOUTPUT>

	<TR><TD COLSPAN="100%" STYLE="border-bottom:2px solid red;"><SPAN CLASS="title2"><BR>Expiring</SPAN></TD></TR>	

	<CFOUTPUT QUERY="getEXPIRINGCount">
	<CF_CRYP type="en" key="#request.key#" string="#getEXPIRINGCount.contract_main_id#">
	<CFSET CID = cryp.value>
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT TYPE="checkbox" NAME="Contract_Number" VALUE="#Contract_Number#"></TD>
		<TD NOWRAP>
			&nbsp;&nbsp;&nbsp;#Contract_Number#<!--- <A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">&nbsp;&nbsp;&nbsp;#Contract_Number#</A> --->
		</TD>
		<TD>#Contract_Title#</TD>
	</TR>
	</CFOUTPUT>
<!------
	<TR><TD COLSPAN="100%" STYLE="border-bottom:2px solid red;"><SPAN CLASS="title2"><BR>Expired</SPAN></TD></TR>	

	<CFOUTPUT QUERY="getEXPIREDCount">
	<CF_CRYP type="en" key="#request.key#" string="#getEXPIREDCount.contract_main_id#">
	<CFSET CID = cryp.value>
		<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT TYPE="checkbox" NAME="Contract_Number" VALUE="#Contract_Number#"></TD>
		<TD NOWRAP>
			&nbsp;&nbsp;&nbsp;#Contract_Number#<!--- <A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Contract_Number#">&nbsp;&nbsp;&nbsp;#Contract_Number#</A> --->
		</TD>
		<TD>#Contract_Title#</TD>
	</TR>
	</CFOUTPUT>
----->	
	</TABLE>

	<BR>
	
	<INPUT TYPE="hidden" ID="get_Program_Submit" NAME="get_Program_Submit" VALUE="import selected programs">
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT>
	<a HREF="#" onClick="javascript: document.all.MyForm.submit()"> import selected programs </a>
	<FONT COLOR="#FF0000">]</FONT></B>
	</FONT>	
	<BR>
	
</FORM>	
	
	
<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->
</BODY>
</HTML>








