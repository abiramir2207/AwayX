<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", {
				"profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery>
</cfif>
<BR><BR>
<CFQUERY NAME="Get_DD_Detail" DATASOURCE="#Application.Datasource#">
	SELECT 		Deduction_ID,
				Distributor_ID,
				DD_DedID,
				SP_Number, 	
				SP_Reason,			
				DD_Amount,
				Name,
				Ship_To,
				DD_Parent_ID,
				Name_First,
				Name_Last,
				Deductions.Analyst_User_ID,
				DD_DedID_SP_Number
	
	FROM 		Deductions 
	LEFT JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
				AND BSA_Foodservice_Customers.Deleted = 0
	<!--- Change users to inner join once saru's code is ready --->			
	LEFT JOIN	_Users ON _Users.User_ID = Deductions.Analyst_User_ID AND _Users.Deleted=0
				
	WHERE 		Deduction_ID = '#URL.Deduction_ID#' AND 
				Deductions.Deleted = 0 
</CFQUERY>

<CFQUERY NAME="Get_All" DATASOURCE="#Application.Datasource#">
	SELECT 		Deduction_ID,
				Distributor_ID,
				DD_DedID,
				SP_Number, 	
				SP_Reason,			
				DD_Amount,
				Name,
				Ship_To,
				Name_First,
				Name_Last,
				Deductions.Analyst_User_ID,
				DD_DedID_SP_Number
				 
	FROM 		Deductions 
	LEFT JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
				AND BSA_Foodservice_Customers.Deleted = 0
	<!--- Change users to inner join once saru's code is ready --->			
	LEFT JOIN	_Users ON _Users.User_ID = Deductions.Analyst_User_ID AND _Users.Deleted=0
				
	WHERE 		DD_DedID = '#Get_DD_Detail.DD_DedID#' AND 
				Deductions.Deleted = 0 
				
	ORDER BY 	CAST ( SP_Number AS Int )
</CFQUERY>


<CFIF Get_DD_Detail.SP_Number NEQ "">
	<CFSET Parent = Get_DD_Detail.DD_Parent_ID>
	<CFQUERY NAME="Get_DD_Detail" DATASOURCE="#Application.Datasource#">
		SELECT 		Deduction_ID,
					Distributor_ID,
					DD_DedID,
					SP_Number, 
					SP_Reason,				
					DD_Amount,
					Name,
					Ship_To,
					Name_First,
					Name_Last,
					Deductions.Analyst_User_ID
					
		FROM 		Deductions 
		LEFT JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
					AND BSA_Foodservice_Customers.Deleted = 0
		<!--- Change users to inner join once saru's code is ready --->			
		LEFT JOIN	_Users ON _Users.User_ID = Deductions.Analyst_User_ID AND _Users.Deleted=0
							
		WHERE 		Deduction_Id = '#Parent#' AND 
					Deductions.Deleted = 0 
	</CFQUERY>	
</CFIF>

<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px; 
}
</STYLE>


<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" CLASS="underline" WIDTH="100%">
	<TR>
		<TD STYLE="border:none"><B>SPLIT DETAILS:</B></TD>
	</TR>
	<TR BGCOLOR="FFE083">
		<TD VALIGN="Top"><B>DEDUCTION #</B></TD>
		<!--- <TD>&nbsp;</TD> --->
		<TD VALIGN="Top"><B>AMOUNT<br>SPLIT REASON</B></TD>
		<TD VALIGN="Top"><B>ANALYST</B></TD>
	</TR>	
	<TR>
		<TD COLSPAN="100%" STYLE="border:none" BGCOLOR="Silver"><B>Original:</B></TD>
	</TR>
	<CFOUTPUT>
	<TR>
		<TD <CFIF isdefined("FORM.Comm_Type")><CFELSE><CFIF DeductionsProfilesSettings.DD_Approve NEQ 1 AND Get_DD_Detail.Analyst_User_ID NEQ request.AccessStructure.User_ID>TITLE="You have no access to this deduction."<CFELSE><CFIF URL.Deduction_ID EQ Get_DD_Detail.Deduction_ID>title="Currently you are on this deduction"<CFELSE>Title="Click to view this deduction."</CFIF></CFIF></CFIF>>
			<CFIF DeductionsProfilesSettings.DD_Approve NEQ 1 AND Get_DD_Detail.Analyst_User_ID NEQ request.AccessStructure.User_ID>
				<B><FONT COLOR="Red" SIZE="2">[ </FONT>#Get_DD_Detail.DD_DedID# - 000<FONT COLOR="Red" SIZE="2"> ]</FONT></B>
			<CFELSE>
				<CFIF URL.Deduction_ID EQ Get_DD_Detail.Deduction_ID>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><CFIF NOT isdefined("FORM.Comm_Type")><FONT COLOR="Red"></CFIF>#Get_DD_Detail.DD_DedID# - 000<CFIF NOT isdefined("FORM.Comm_Type")></FONT></CFIF><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				<CFELSE>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><CFIF isdefined("FORM.Comm_Type")>#Get_DD_Detail.DD_DedID# - 000<CFELSE><A HREF="/Deductions/deduction.cfm?CenterToShow=Details&Deduction_ID=#Get_DD_Detail.Deduction_ID#" target="_parent">#Get_DD_Detail.DD_DedID# - 000</A></CFIF><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				</CFIF>
			</CFIF>
			<CFIF NOT isdefined("FORM.Comm_Type")><img src="/Images/parent_New.gif" title="Original Deduction" width="13" height="13" border="0"></CFIF></TD>
		<!--- <TD></TD> --->
		<TD>#DollarFormat(Get_DD_Detail.DD_Amount)#<BR><CFIF Get_DD_Detail.SP_Reason EQ "">None.<CFELSE>#SP_Reason#</CFIF><!--- <CFIF Get_DD_Detail.Distributor_ID EQ "">None Selected.<CFELSE>#Get_DD_Detail.Name# (#Get_DD_Detail.Ship_To#)</CFIF> ---></TD>
		<TD>#Get_DD_Detail.Name_First# #Get_DD_Detail.Name_Last#&nbsp;</TD>
	</TR>
	</CFOUTPUT>
	<TR>
		<TD COLSPAN="100%" STYLE="border:none" BGCOLOR="Silver"><B>Split:</B></TD>
	</TR>
	<CFSET Count = 0>
	<CFOUTPUT QUERY="Get_All">
	<CFIF SP_Number NEQ "">
	<CFSET Count = Count + 1>
	<TR BGCOLOR="#IIf(Count Mod 2,DE('ffffff'), DE('C6FFC6'))#">
		<TD <CFIF isdefined("FORM.Comm_Type")><CFELSE><CFIF DeductionsProfilesSettings.DD_Approve NEQ 1 AND Analyst_User_ID NEQ request.AccessStructure.User_ID>TITLE="You have no permission to access this deduction."<CFELSEIF URL.Deduction_ID EQ Deduction_ID>title="Currently you are on this deduction."<CFELSE>Title="Click to view this deduction."</CFIF></CFIF>><!--- --->
			<CFIF DeductionsProfilesSettings.DD_Approve NEQ 1 AND Analyst_User_ID NEQ request.AccessStructure.User_ID>
				<B><FONT COLOR="Red" SIZE="2">[ </FONT>#Get_DD_Detail.DD_DedID# - 000<FONT COLOR="Red" SIZE="2"> ]</FONT></B>
			<CFELSE>
				<CFIF URL.Deduction_ID EQ Deduction_ID>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><CFIF NOT isdefined("FORM.Comm_Type")><FONT COLOR="Red"></CFIF>#DD_DedID_SP_Number#<CFIF NOT isdefined("FORM.Comm_Type")></FONT></CFIF><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				<CFELSE>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><CFIF isdefined("FORM.Comm_Type")>#DD_DedID_SP_Number#<CFELSE><A HREF="/deductions/deduction.cfm?CenterToShow=Details&Deduction_ID=#Deduction_ID#" target="_parent">#DD_DedID_SP_Number#</A></CFIF><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				</CFIF>
			</CFIF>
			<CFIF NOT isdefined("FORM.Comm_Type")><img src="/Images/child_New.gif" title="Split from Original deduction" width="13" height="13" border="0"></CFIF></TD>
		<!--- <TD></TD> --->
		<TD>#DollarFormat(DD_Amount)#<BR><CFIF SP_Reason NEQ "">#SP_Reason#<CFELSE>None.</CFIF><!--- <CFIF Name NEQ "">#Name# (#Ship_To#)<CFELSE>None Selected.</CFIF> --->&nbsp;</TD>
		<TD>#Name_First# #Name_Last#&nbsp;</TD>
	</TR>
	</CFIF>
	</CFOUTPUT>
</TABLE>
</body>
</html>

