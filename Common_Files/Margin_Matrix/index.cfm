<CFSET PAGE_TITLE=	"Approval Matrix">
<CFSET GROUP=		"Approval_Matrix">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights NEQ 1>
	<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
	You don't have access rights to this data
	</BLOCKQUOTE></BLOCKQUOTE>
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	</BODY>
	</HTML>
	<CFABORT>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the settings from the DB																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset oProfiles = CreateObject("component","components.settings.profiles.profile") />
<cfset Get_Profile_Settings = oProfiles.getAllProfiles()>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the date last updated and the user that did the update									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFQUERY NAME="Get_Update_Data" datasource="#application.datasource#" MAXROWS="1">
		Select		Profiles_Settings.Last_Changed_Date,
					Profiles_Settings.Last_Changed_User_ID,
					_Users.Name_First,
					_Users.Name_Last
		From		Profiles_Settings,
					_Users
		Where		Profiles_Settings.Last_Changed_User_ID	=	_Users.User_ID
	</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<BR><BR>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD CLASS="Matrix">
	<FONT SIZE="2"><B>The profile settings were last updated on <CFOUTPUT>#dateformat(Get_Update_Data.Last_Changed_Date, 'm/d/yyy')# #timeformat(Get_Update_Data.Last_Changed_Date, 'h:mm:ss TT')# by #Get_Update_Data.name_first# #Get_Update_Data.name_last#</CFOUTPUT></B></FONT>	</TD>
</TD>
</TR>
</TABLE>

<!--- get margin approval method --->
<cfquery name="margin_approval_method" datasource="#application.datasource#">
	SELECT program_margin_approval_method
	FROM General_Settings	
</cfquery>

<cfset fileName = "">
<cfif application.returned_customer_setting.approval_on_type_code EQ 1>
	<cfset fileName = "type_code_to_group_assignment.cfm">
<cfelseif application.returned_customer_setting.approval_on_type_group EQ 1>
	<cfset fileName = "type_group_to_group_assignment.cfm">
<cfelse>
	<cfabort>
</cfif>

<cfscript>
	function formatMargin(oText, approvalMethod){
		var returnValue = "";
		oText = trim(oText);
		
		if(isNumeric(approvalMethod) EQ false) {
			return "Invalid Params Supplied";
		}
		if(oText EQ "*") {
			return "ALL";
		}

		
		switch(approvalMethod) {
			case "1":
				// $/Pound Margin
				returnValue = "$" & trim(numberFormat(oText, '_-_________.___'));
			break;
			
			case "2":
				// $/Margin
				returnValue = trim(numberFormat(oText, '_-___._')) & "%";
			break;
			
			case "3":
				// Total Program % Margin 
				returnValue = trim(numberFormat(oText, '_-___._')) & "%";
			break;
			
			default:
				returnValue = trim(numberFormat(oText, '_-_____________.___'));
			break;
		}
		return returnValue;
	}

</cfscript>
	
	
<CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">

	<CFLOOP query="Get_Profile_Settings">
		<cfset ProfileCount = Get_Profile_Settings.Profiles_ID>
		<cfset useLakebaseForGetApprovalMargin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_profile_approval_margins")>
		<cfif useLakebaseForGetApprovalMargin>
			<cftry>
				<cfset getApprovalMargin = application.oLakebase.toQuery(
					application.oLakebase.selectRows("margin_group_profile_approval_margins", { "group_id" = "eq.#GroupCount#", "profile_id" = "eq.#ProfileCount#", "select" = "amount" })
				, "Amount")>
				<cfcatch type="any">
					<cfset useLakebaseForGetApprovalMargin = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetApprovalMargin>
			<CFQUERY NAME="getApprovalMargin" datasource="#application.datasource#">
				SELECT Amount
				FROM Margin_Group_Profile_Approval_Margins
				WHERE Group_ID='#GroupCount#' AND Profile_ID='#ProfileCount#'
			</CFQUERY>
		</cfif>
		<CFSET "FORM.Group_#GroupCount#_Profile_#ProfileCount#" = formatMargin(getApprovalMargin.Amount, margin_approval_method.program_margin_approval_method)>

		<cfif len(trim(getApprovalMargin.Amount)) EQ 0>
			<CFSET "FORM.Group_#GroupCount#_Profile_#ProfileCount#" = "0.000">
		</cfif>
	</CFLOOP>
</CFLOOP>	

	<BR><BR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Open layer Options																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="White";
	TitleColor="Blue"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";  
	WIDTH="100%";
</CFSCRIPT>
	
	<FONT COLOR="Red"><B><I>Click group name to see its details</I></B></FONT>
	<BR>

	<cfoutput>
	<TABLE BORDER="1" CELLPADDING="10" CELLSPACING="0">
		<TR BGCOLOR="White">
			<TD ALIGN="center" WIDTH="300" BGCOLOR="White">&nbsp;</TD>
			<cfloop query="Get_Profile_Settings">
				<TD ALIGN="center" WIDTH="50" CLASS="Matrix"><B>#Get_Profile_Settings.Profiles_Desc#</B></TD>
			</CFLOOP>
		</TR>
		<TR BGCOLOR="White" ALIGN="center">
			<TD ALIGN="left" WIDTH="150" CLASS="Matrix"><FONT SIZE="2"><B>&nbsp;&nbsp;&nbsp;Approval Rights</B></FONT></TD>
			<cfloop query="Get_Profile_Settings">
				<TD CLASS="Matrix"><CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1><IMG SRC="/images/yes.gif" WIDTH="25" HEIGHT="25" TITLE="Has Approval Rights"><CFELSE><IMG SRC="/images/no.gif" WIDTH="25" HEIGHT="25" ALT="Does Not Have Approval Rights"></CFIF></TD>
			</cfloop>
		</TR>

		<cfif margin_approval_method.program_margin_approval_method EQ 3>
			<cfset RowCounter = 1>
		<cfelse>
			<cfset RowCounter = application.returned_customer_setting.approval_group_count>
		</cfif>
		<cfloop index="x" from="1" to="#RowCounter#" step="1">

			<cfset numCount = 3 - len(x)>
			<CFSET labelIndex = "">
			<cfloop index="z" from="1" to="#numCount#" step="1">
				<cfset labelIndex = labelIndex & "0">
			</cfloop>
			<cfset labelIndex = labelIndex & x>

			<TR BGCOLOR="White" ALIGN="center">
				<TD GROUP_ID="#x#" CLASS="Matrix" align="left">
				<cfset ActualLabel = evaluate('application.returned_customer_setting.approval_group_count_#labelIndex#_label')>
				<cfif margin_approval_method.program_margin_approval_method EQ 3>
					<cfset ActualLabel = "Total Program % Margin">
					&nbsp;&nbsp;&nbsp;<cfoutput><span style="font-size: 13px; font-weight: bold;">#ActualLabel#</span></cfoutput>
				<cfelse>
					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Title="#ActualLabel#"  
						TitleClosed="#ActualLabel#"
						TitleTooltip="Click here to toggle the view"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
		 					<CFSET URL.group_id=x>
							<CFINCLUDE TEMPLATE="/Common_Files/Margin_Matrix/#fileName#">
					</CF_openLayer>
				</cfif>
				
				</TD>
				<cfloop query="Get_Profile_Settings">
					<cfset i = Get_Profile_Settings.profiles_ID>
					<TD CLASS="Matrix"><CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1><CFIF evaluate("FORM.Group_#x#_Profile_#i#") EQ "*">n/a<CFELSE>#evaluate("FORM.Group_#x#_Profile_#i#")#</CFIF><CFELSE>0.000</CFIF></TD>
				</cfloop>
			</TR>
		</CFLOOP>				
		
		<TR BGCOLOR="White" ALIGN="center">
			<TD ALIGN="left" CLASS="Matrix"><FONT SIZE="2"><B>&nbsp;&nbsp;&nbsp;View Margins</B></FONT></TD>
			<cfloop query="Get_Profile_Settings">
				<TD CLASS="Matrix"><CFIF Get_Profile_Settings.Cont_Prog_View_Margins EQ 1><IMG SRC="/images/yes.gif" WIDTH="25" HEIGHT="25" TITLE="Can View Margins"><CFELSE><IMG SRC="/images/no.gif" WIDTH="25" HEIGHT="25" ALT="Can Not View Margins"></CFIF></TD>
			</cfloop>
		</TR>		
	</table>
	</cfoutput>
	
</BLOCKQUOTE></BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>