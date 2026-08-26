<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<BR><BR>
<CFIF IsDefined("DeleteAllSplit")>
	<CFQUERY NAME="DeleteFromApp" DATASOURCE="#Application.Datasource#">
		DELETE FROM BB_Approved
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback
								WHERE BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>
	
	<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
		DELETE FROM Billback_Distributor
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback
								WHERE BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>
	<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
		DELETE FROM Billback_Operator
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback
								WHERE BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>
	<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
		DELETE FROM Billback_Broker
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback
								WHERE BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>
	<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
		DELETE FROM Billback_Program
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback
								WHERE BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>
	<CFQUERY NAME="DeleteFromSPCA" DATASOURCE="#Application.Datasource#">
		DELETE FROM Billback_Split_Claim_Adjust
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback_Split_Claim_Adjust aaa
								WHERE aaa.BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>
	<CFQUERY NAME="DeleteFromPayee" DATASOURCE="#Application.Datasource#">
		DELETE FROM Billback
		WHERE Billback_ID IN ( 	SELECT Billback_ID FROM Billback aaa
								WHERE aaa.BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> )
	</CFQUERY>	
	<script>
	window.parent.location.href = "/Billbacks/capture/index.cfm?BBID=<CFOUTPUT>#Billback_ID#</CFOUTPUT>";
	</script>
	<CFABORT>
</CFIF>

<CFIF IsDefined("URL.FromLeftMenu")>
	<CFSET Billback_ID = URL.BBID>
</CFIF>

<CFQUERY NAME="Get_BB_Detail" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> 
</CFQUERY>

<CFSET URL_BBID = Billback_ID>
<CFQUERY NAME="Get_All" DATASOURCE="#Application.Datasource#">
	SELECT 	Billback.Billback_ID,BB_Parent_ID,
			ISNULL(Deductions.DD_DedID_SP_Number, '') AS DD_DedID_SP_Number,
			--ISNULL(Deductions.DD_Date, 0) AS DD_Date,
			Deductions.DD_Date,
			BB_Approved.Paid_Amount,
			BB_Approved.Check_Number,
			BB_Approved.Check_Date,
			
			CASE WHEN  Distributor_Bill_To.Name IS NULL THEN
				BSA_Foodservice_Customers.Name
			ELSE
				Distributor_Bill_To.Name 
			END AS Distributor_Name,
			
			CASE WHEN  Distributor_Bill_To.Name IS NULL THEN
				BSA_Foodservice_Customers.Shr_ship_to 
			ELSE
				Distributor_Bill_To.Shr_Bill_To 
			END AS Distributor_Number, 
	
			*	 
	FROM 	Billback 		
			INNER JOIN 	Billback_Status ON 
			Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
			LEFT JOIN DD_Closure_Detail ON
			DD_Closure_Detail.DD_Closure_ID = Billback.Billback_ID
			AND DD_Closure_Detail.Deleted = 0
			LEFT JOIN deductions ON
			Deductions.Deduction_ID = DD_Closure_Detail.Deduction_ID
			LEFT JOIN Distributor_Bill_To ON
			Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID
			LEFT JOIN BSA_Foodservice_Customers ON 
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID AND 
			BSA_Foodservice_Customers.Active_Code = 'A'
			LEFT JOIN _Users ON
			_Users.User_ID = Billback.BB_Creator_ID
			LEFT JOIN BB_Approved ON 
			BB_Approved.Billback_ID = Billback.Billback_ID
	WHERE 	<CFIF Get_BB_Detail.BB_Is_Child EQ 1>
			(Billback.Billback_ID = <cfqueryparam value="#Get_BB_Detail.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> OR BB_Parent_ID = <cfqueryparam value="#Get_BB_Detail.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">) AND 
			<CFELSE>
			(Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> OR BB_Parent_ID = <cfqueryparam value="#Get_BB_Detail.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">) AND
			</CFIF>				 
			Billback.Deleted = 0 		
						
	ORDER BY 	BB_Split_Number 
</CFQUERY>

<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px; 
}
</STYLE>


<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="underline" WIDTH="80%">	
	<TR>
		<TD STYLE="border:none" COLSPAN="100%">
			<CFIF Not IsDefined("FromLeftMenu")>
				<B><FONT SIZE="2" COLOR="Red">[ </FONT><A Href="Split_BB.cfm?Billback_ID=#URL_BBID#">split</A><FONT SIZE="2" COLOR="Red"> ]</FONT></B>
			</CFIF>
			<CFIF Get_BB_Detail.BB_Is_Child NEQ 1>
				
				<CFQUERY NAME="AnyUnclosedSplit" DATASOURCE="#Application.Datasource#">
					SELECT 	* 
					FROM 	Billback
					WHERE 	BB_Parent_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
							(	(BB_Closing_Method = 2 AND BB_Associated_To_DD = 1) OR
								(BB_Closing_Method = 1 AND Billback_Status_ID IN (4,5))
							) AND
							Deleted = 0												
				</CFQUERY>
				
				<CFQUERY NAME="CheckForPullBackOnAnySplits" DATASOURCE="#Application.Datasource#">
					SELECT * FROM pullbacks_log WHERE pullback_applied = 1 AND pullback_applied_to_billback_id IN (SELECT Billback_ID FROM Billback WHERE BB_Parent_ID = '#Billback_ID#' AND Deleted = 0)
				</CFQUERY>
				<CFIF AnyUnclosedSplit.RecordCount EQ 0 AND CheckForPullBackOnAnySplits.RecordCount EQ 0>
					<B><FONT SIZE="2" COLOR="Red">[ </FONT><A Href="Split_BB_History.cfm?Billback_ID=#URL_BBID#&DeleteAllSplit=1">delete all split</A><FONT SIZE="2" COLOR="Red"> ]</FONT></B>
				</CFIF>
			</CFIF>
		</TD>
	</TR>
	
	<TR>
		<TD STYLE="border:none"><B>SPLIT DETAILS:</B></TD>
	</TR>
	<TR BGCOLOR="FFE083">
		<TD VALIGN="Top"><B>BILLBACK ##</B></TD>
		<!--- <TD>&nbsp;</TD> --->
		<TD VALIGN="Top"><B>AMOUNT<br>CLOSING METHOD</B></TD>
		<!--- <TD VALIGN="Top"><B>SPLIT REASON</B></TD> --->
		<TD VALIGN="Top"><B>STATUS</B></TD>
		<TD VALIGN="Top"><B>TRANSACTION<br>DATE</B></TD>
		<TD VALIGN="Top"><b>CUSTOMER</b></B></TD>
		<TD VALIGN="Top"><b>SPLIT BY</b></B></TD>
	</TR>	
	<TR>
		<TD COLSPAN="100%" STYLE="border:none" BGCOLOR="Silver"><B>Original:</B></TD>
	</TR>
	<CFLOOP QUERY="Get_All" startRow = "1"  endRow = "1">
		<TR>
			<TD <CFIF URL_BBID EQ Billback_ID>title="Currently you are on this Billback"<CFELSE>Title="Click to view this Billback."</CFIF>>			
				<CFIF URL_BBID EQ Billback_ID>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><FONT COLOR="Red">#BB_Code#</FONT><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				<CFELSE>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#" target="_parent">#BB_Code#</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				</CFIF>
				<img src="/Images/parent_New.gif" title="Original Billback" width="13" height="13" border="0"></TD>
			<!--- <TD></TD> --->
			<TD><B>#DollarFormat(Paid_Amount)#</B><BR><CFIF BB_Closing_Method EQ 2>Deduction<CFELSE>Payment</CFIF><!--- <CFIF Get_DD_Detail.Distributor_ID EQ "">None Selected.<CFELSE>#Get_DD_Detail.Name# (#Get_DD_Detail.Ship_To#)</CFIF> ---></TD>
			<!--- <TD>&nbsp;</TD> --->
			<TD>#BB_Status_Description#</TD>
			<TD>&nbsp;<!--- #DD_DedID_SP_Number#<br>#DateFormat(DD_Date, "mm/dd/yyyy")# ---></TD>
			<TD>&nbsp;<!---c<br>#Distributor_Number# ---></TD>
			<TD>&nbsp;<!--- #Name_First# #Name_Last#<br>#DateFormat(BB_Split_Date, "mm/dd/yyyy")# ---></TD>
		</TR>
	</CFLOOP>	
	<TR>
		<TD COLSPAN="100%" STYLE="border:none" BGCOLOR="Silver"><B>Split:</B></TD>
	</TR>
	<CFSET ThisQueryRecordCount = Get_All.RecordCount>
	<CFLOOP QUERY="Get_All" startRow = "2"  endRow = "#ThisQueryRecordCount#">
		<TR>
			<TD <CFIF URL_BBID EQ Billback_ID>title="Currently you are on this Billback"<CFELSE>Title="Click to view this Billback."</CFIF>>
				<CFIF URL_BBID EQ Billback_ID>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><FONT COLOR="Red">#BB_Code#</FONT><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				<CFELSE>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#" target="_parent">#BB_Code#</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				</CFIF>
				<img src="/Images/child_New.gif" title="Split from Original Billback" width="13" height="13" border="0"></TD>
			<!--- <TD></TD> --->
			<TD><B>#DollarFormat(Paid_Amount)#</B><BR><CFIF BB_Closing_Method EQ 2>Deduction<CFELSE>Payment</CFIF><!--- <CFIF Get_DD_Detail.Distributor_ID EQ "">None Selected.<CFELSE>#Get_DD_Detail.Name# (#Get_DD_Detail.Ship_To#)</CFIF> ---></TD>
			<!--- <TD><CFIF BB_Split_Reason EQ "">None.<CFELSE>#BB_Split_Reason#</CFIF></TD> --->
			<TD>#BB_Status_Description#</TD>
			<TD>
			<cfif (Trim(Check_Number) NEQ "")>
			#Check_Number#<br><cfif (Check_Date EQ "")>&nbsp;<cfelse>#DateFormat(Check_Date, "mm/dd/yyyy")#</cfif>
			<cfelseif (DD_DedID_SP_Number NEQ "")>
			#DD_DedID_SP_Number#<br><cfif (DD_Date EQ "")>&nbsp;<cfelse>#DateFormat(DD_Date, "mm/dd/yyyy")#</cfif>
			<cfelse>
			&nbsp;
			</cfif>
			</TD>
			<TD>
			<cfif (BB_Closing_Method EQ 1)><!--- 1 means Payment,  2 means Deduction ---> 
			  <cfset thisPayeeObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(Billback_ID) >
			  <cfset getPayeeInfo = thisPayeeObj.getPayeeInfo() />
 			   #getPayeeInfo.Payee_Name#<br>#getPayeeInfo.Payee_ShipTo#
			<cfelse>
			   #Distributor_Name#<br>#Distributor_Number#
			 </cfif>
		
			</TD>
			<TD>#Name_First# #Name_Last#<br>#DateFormat(BB_Split_Date, "mm/dd/yyyy")#</TD>
		</TR>
	</CFLOOP>	
</TABLE>
</CFOUTPUT>
<!--- Activate the "split detail" link --->
<script language="javascript">
	window.parent.bb_complete_split = true;
	window.parent.buildMenu();
	try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>


