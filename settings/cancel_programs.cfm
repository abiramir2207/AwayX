<!---
***********************************************************************
Author: Milan Mushran
Filename: Cancel_programs.cfm
Purpose: To cancel multiple programs
Date Created: 05/27/2005
Modification:
Modified By: Milan Mushran	
Modified Date:
***********************************************************************
--->
<CFPARAM NAME="FORM.Contract_Number" DEFAULT="">
<CFPARAM NAME="FORM.Contract_Status" DEFAULT="">
<CFPARAM NAME="URL.Cancel" DEFAULT="0">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">

<CFSET PAGE_TITLE="Cancel Programs">
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

<BR><BR>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT language="JavaScript">
function anyCheckBoxChecked(chObj)
{
	var bChecked = false;
	if(chObj.length)
	{
		var i, chLen;
		chLen = chObj.length;
		for(i=0;i<chLen;i++)
		{
			if(chObj[i].checked)
			{
				bChecked = true;
				break;
			}
		}
	}
	else
	{
		if(chObj.checked)
		{
			bChecked = true;
		}		
	}
	return bChecked;
}

function checkbox()
{	
	var submit_ok = true;
	x= document.cancel_program
	
	//if (x.SelectedITEMS.value == "")
	if(!anyCheckBoxChecked(x.SelectedITEMS))
	{
		queueMessage("There must be at least one program selected. Please, select some programs", document.all.ERR_PROG);
		submit_ok = false;
	}
	else
	{
		clearQueue(document.all.ERR_PROG);
	}
	return submit_ok;
}
	
function toaction()
{	
	if (checkbox())
	{
		var confirm_cancel = confirm("Are you sure you want to cancel these programs ?");
		if (confirm_cancel == true)
		{
			document.cancel_program.action="cancel_programs.cfm?Cancel=1";
			document.cancel_program.submit();
			return false;
		}
	}
	else
	{
		showMessageWindow();
	}
}

function toactionERP()
{	
	if (checkbox())
	{
		var confirm_cancel = confirm("Are you sure you want to cancel these programs?");
		if (confirm_cancel == true)
		{
			document.cancel_program.action="cancel_programs.cfm?Cancel=1&CancelERP=1";
			document.cancel_program.submit();
			return false;
		}
	}
	else
	{
		showMessageWindow();
	}
}
</SCRIPT>

<!--- If cancelling programs, cancel the list of programs --->
<cfif URL.Cancel eq 1>
<CFLOOP INDEX="FORM.Program_ID" LIST="#Form.SelectedITEMS#" DELIMITERS=",">
<cf_cryp type="en" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.Program_ID = cryp.value>
<!--- Include the cancel program template and cancel the programs --->
	<cfinclude template="/Common_Files/contracts/contract_cancel_action.cfm">
</CFLOOP>

<!--- Show the list of cancelled programs --->
				<CFQUERY NAME="show_cancelled_programs" DATASOURCE="#Application.Datasource#">
					SELECT 		Contract_Main_ID,
								Contract_Reference_Number,
								Contract_Number,
								Contract_Status_Type_Desc,
								Contract_Title,
								Contract_Start_Date,
								Contract_End_Date,
								_Users.Name_First + ' ' + _Users.Name_Last Responsible_User_Name
					FROM 		Contract_Main 
					INNER JOIN 	Contract_Status_Types
					ON 			Contract_Main.Contract_Status_Type_IDX = Contract_Status_Types.Contract_Status_Type_ID
					LEFT JOIN 	_Users
					ON 			_Users.User_ID = Responsible_user_ID
					WHERE 		Contract_Main_ID IN (#Form.SelectedITEMS#)
					ORDER BY 	Contract_Number
				</CFQUERY> 
<cfoutput>
	<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="75%" CLASS="MainTable" align="center">
			<CFIF show_cancelled_programs.recordcount GT 0>
			<TR>
				<TD COLSPAN="4" STYLE="font-size: 12px; font-weight: bold;">The following program/s were cancelled:</TD>
			</TR>
			<TR BGCOLOR= "ffce84">
				<TD STYLE="font-size: 11px; font-weight: bold;">Program</TD>
				<TD STYLE="font-size: 11px; font-weight: bold;">Title[Reference]</TD>
				<TD STYLE="font-size: 11px; font-weight: bold;">Start Date</TD>
				<TD STYLE="font-size: 11px; font-weight: bold;">End Date</TD>
			</TR>
			<cfloop QUERY="show_cancelled_programs">				
			<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">						
				<TD NOWRAP>#Contract_Number#&nbsp;&nbsp;</TD>
				<TD>#Contract_Title# <cfif Len(Contract_Reference_Number)>[#Contract_Reference_Number#]</cfif>
				<cfif application.returned_customer_setting.Responsible_Person EQ 1>
				<br>SP:#Responsible_User_Name#
				</cfif>
				</TD>
				<TD NOWRAP>#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
				<TD NOWRAP>#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
			</TR>
			</cfloop>											
			</CFIF>	
		</TABLE> 
</cfoutput>

<!--- Show the page to select programs or the list of selected programs to cancel --->
<cfelse>

<BLOCKQUOTE><BLOCKQUOTE>

	<FORM NAME="cancel_program" ACTION="Cancel_Programs.cfm" METHOD="POST">

	<cfset col1Len = "7%" />
	<cfoutput>
	<TABLE align="center" border="0" width="80%" CELLSPACING="0">
		<SCRIPT language="JavaScript">
		function dis_program()
		{
			NewWindow("/Search_Screens/Program_Search.cfm?FormName=cancel_program&FieldName=Contract_Number&ReturnFieldName=Contract_Main_ID&AllowImportAll=0&Disable_Locked=1&Contract_Status=1", 'pro_search', '800', '600', 'Yes', 'No', true);		
		}
		</SCRIPT>
		<INPUT TYPE = "hidden" NAME="Contract_Number" VALUE="#FORM.Contract_Number#">
		<INPUT TYPE = "hidden" NAME="Contract_Status" VALUE="#FORM.Contract_Status#">
			<CFIF FORM.Contract_Number EQ "">
				<TR>
					<TD colspan="100%" align="center"><b>Cancel Programs</b><BR><BR>			
							<CF_button
								button_name		=	""
								button_caption	=	"search programs"
								button_action	=	"dis_program()"
								button_type		=	"javascript_link"
								button_width	=	"100"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"
								> 					
					</TD>
				</TR>
			<CFELSE>
				<CFQUERY NAME="List_program" DATASOURCE="#Application.Datasource#">
					SELECT 		Contract_Main_ID,
								Contract_Reference_Number,
								Contract_Number,
								Contract_Status_Type_Desc,
								Contract_Title,
								Contract_Start_Date,
								Contract_End_Date,
								_Users.Name_First + ' ' + _Users.Name_Last Responsible_User_Name
					FROM 		Contract_Main 
					INNER JOIN 	Contract_Status_Types
					ON 			Contract_Main.Contract_Status_Type_IDX = Contract_Status_Types.Contract_Status_Type_ID
					LEFT JOIN 	_Users
					ON 			_Users.User_ID = Responsible_user_ID
					WHERE 		Contract_Main_ID IN (#FORM.Contract_Number#)
					ORDER BY 	Contract_Number
				</CFQUERY> 
				<TR>
					<TD COLSPAN="100%"> <br><SPAN ID="ERR_PROG">&nbsp;</SPAN><b>Cancel Programs :</b>&nbsp;&nbsp;&nbsp;&nbsp;
						<B>
						<FONT COLOR="Red">[</FONT> 
							<A HREF="##" onclick="Javascript:dis_program();" >Search Programs</A> 					
						<FONT COLOR="Red">]</FONT> 
						</B><BR><BR>
						<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%" CLASS="MainTable">
							<CFIF List_Program.recordcount GT 0>
							<TR BGCOLOR= "ffce84">
								<TD><input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);" CHECKED></TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Status</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Program</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Title[Reference]</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">Start Date</TD>
								<TD STYLE="font-size: 11px; font-weight: bold;">End Date</TD>
							</TR>
							<cfloop QUERY="List_program"><!---  startrow="#StartRow#" maxrows="#MaxRows#" --->					
							<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
								<TD><INPUT TYPE="Checkbox" NAME="SelectedITEMS" VALUE="#Contract_Main_ID#" CHECKED>&nbsp;</TD>
								<TD NOWRAP>#Contract_Status_Type_Desc#&nbsp;&nbsp;</TD>								
								<TD NOWRAP>#Contract_Number#&nbsp;&nbsp;</TD>
								<TD>#Contract_Title# <cfif Len(Contract_Reference_Number)>[#Contract_Reference_Number#]</cfif>
								<cfif application.returned_customer_setting.Responsible_Person EQ 1>
								<br>SP:#Responsible_User_Name#
								</cfif>
								</TD>
								<TD NOWRAP>#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
								<TD NOWRAP>#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
							</TR>
							</cfloop>											
							</CFIF>							
						</TABLE> 
						<hr color="orange">
					</TD>
				</TR>
				<TR>
					<TD align="right">
					<BR>
								<CF_button
									button_name		=	""
									button_caption	=	"Cancel and send to ERP"
									button_action	=	"toaction()"
									button_type		=	"javascript_link"
									button_width	=	"50"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>
					 </TD>
					<TD align="left">&nbsp;&nbsp;</TD>
					<TD align="left">
					<BR>
								<CF_button
									button_name		=	""
									button_caption	=	"Cancel"
									button_action	=	"toactionERP()"
									button_type		=	"javascript_link"
									button_width	=	"50"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>			
					</TD>
				</TR>	
			</CFIF>
	</TABLE>
	</cfoutput>
	</FORM>
<CF_MessageWindow>
</BLOCKQUOTE></BLOCKQUOTE>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</body>
</html>

</cfif>

