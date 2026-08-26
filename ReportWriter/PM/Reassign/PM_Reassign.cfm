
<CFSET PAGE_TITLE = "Reassign Projects">

<!--- Get all of the Functioanl Areas of Responsibility --->
<CFQUERY NAME="Get_FAR" datasource="#application.datasource#">
	Select		PM_FAR_ID,
				PM_FAR_Description
	From		PM_FAR
	Where		PM_FAR_Deleted	=	0
	Order by	LTRIM(PM_FAR_Description)
</CFQUERY>

<!--- Get all of the Sponsors --->
<CFQUERY NAME="Get_Sponsor" datasource="#application.datasource#">
	Select		PM_Sponsor_ID,
				PM_Sponsor_Name_First, 
				PM_Sponsor_Name_Last
	From		PM_Sponsor
	Where		PM_Sponsor_Deleted	=	0
	Order by	LTRIM(PM_Sponsor_Name_First)
</CFQUERY>




<!---  initial user position--->
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<!--- list of positions underneath supplied --->
<CFSET ListOfPositionsUnderMine = GP_Position_List_From_My_Position_Down>
<!--- Get all positions under this user--->
<CFQUERY NAME="Get_Positions" datasource="#application.datasource#">
	Select		User_Positions.Position_Label,
				User_Positions.User_Positions_ID
	From		User_Positions
	Where		User_Positions.Deleted=0
				AND
				(len(User_Positions.Position_Label) <> 0)
				AND EXISTS
				(
					SELECT Service_Zones.Service_Zone_ID
					FROM Service_Zones
					WHERE
					User_Positions.Service_Zone_ID IS NULL
					OR
					(Service_Zones.Deleted = 0 AND User_Positions.Service_Zone_ID = Service_Zones.Service_Zone_ID)
				)
				AND EXISTS
				(
					SELECT Service_Regions.Service_Region_ID
					FROM Service_Regions
					WHERE
					User_Positions.Service_Region_ID IS NULL
					OR
					(Service_Regions.Deleted = 0 AND User_Positions.Service_Region_ID = Service_Regions.Service_Region_ID)
				)
				AND EXISTS
				(
					SELECT Service_Markets.Service_Market_ID
					FROM Service_Markets
					WHERE
					User_Positions.Service_Market_ID IS NULL
					OR
					(Service_Markets.Deleted = 0 AND User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID)
				)
				AND
				User_Positions.User_Positions_ID IN (#ListOfPositionsUnderMine#)				
	Order by	User_Positions.Position_Label
</CFQUERY>


<html>
<head>
	<title>Untitled</title>
</head>

<body>

<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody
		{
			border-bottom:solid #93BEE2 1px; 
			font-size : 10px;
		}
</style>




<CFINCLUDE TEMPLATE = "/includes/header.cfm">
<CFPARAM NAME="URL.Owner_Position_ID" DEFAULT="">
<CFPARAM NAME="URL.PM_Sponsor_ID" DEFAULT="">
<CFPARAM NAME="URL.PM_Far_ID" DEFAULT="">
<CFPARAM NAME="URL.To_PM_Sponsor_ID" DEFAULT="">
<CFPARAM NAME="URL.To_Owner_Position_ID" DEFAULT="">
<CFPARAM NAME="URL.To_PM_Far_ID" DEFAULT="">
<CFPARAM NAME="URL.Update" DEFAULT="1">

<CFPARAM NAME="FORM.Update" DEFAULT="#URL.Update#">
<CFPARAM NAME="FORM.From_Owner_Position_ID" DEFAULT="#URL.Owner_Position_ID#">
<CFPARAM NAME="FORM.From_PM_Sponsor_ID" DEFAULT="#URL.PM_Sponsor_ID#">
<CFPARAM NAME="FORM.From_PM_Far_ID" DEFAULT="#URL.PM_Far_ID#">
<CFPARAM NAME="FORM.To_PM_Sponsor_ID" DEFAULT="#URL.To_PM_Sponsor_ID#">
<CFPARAM NAME="FORM.To_Owner_Position_ID" DEFAULT="#URL.To_Owner_Position_ID#">
<CFPARAM NAME="FORM.To_PM_Far_ID" DEFAULT="#URL.To_PM_Far_ID#">

<CFPARAM NAME="FORM.BacktoFrom" DEFAULT="0">


<SCRIPT language="JavaScript">
function Show_Criteria(Occurance)
{
	var x = document.Pro_Ressign;
	var showCriteria = document.all.Select_Criteria;
	x.Step1.checked = true;
	x.Step2.checked = false;	
	x.BacktoFrom.value="";	
	showCriteria.style.display = "";
	Selected_Criteria.style.display="none";	
	Show_Submit.style.display = "none";			
	if (Occurance == 2)
	{
		if (x.From_PM_Sponsor_ID.value == "" && x.From_PM_Far_ID.value == "" && x.From_Owner_Position_ID.value == "" && x.To_PM_Sponsor_ID.value == "" && x.To_PM_Far_ID.value == "" && x.To_Owner_Position_ID.value == "")
		{
			Show_Reset.style.display = "none";	
		}
		else if (Show_Reset.style.display == "none")
		{
			Show_Reset.style.display = "";	
		}
	}
}
	


function Display_Show_Submit(inputNumber)
{
	var x = document.Pro_Ressign;
	
	if (document.all.Show_Submit.style.display == "none")
	{	
		document.all.Show_Reset.style.display="";
		document.all.Show_Submit.style.display="";
		document.all.NotBacktoFrom.style.display="none";	
	}
	else if (x.From_PM_Sponsor_ID.value == "" && x.From_PM_Far_ID.value == "" && x.From_Owner_Position_ID.value == "")
	{
		document.all.Show_Submit.style.display="none";
	}
	if (inputNumber==3)
	{
		Show_Owner_Update_Type()
	}
}

function Show_Owner_Update_Type()
{
	var x = document.Pro_Ressign;
	if(x.From_Owner_Position_ID.value != "" && x.To_Owner_Position_ID.value != "")
	{
		Owner_update.style.display="";
	}
	else
	{
		Owner_update.style.display="none";
	}
}
function submitIntermediate(undo)
{
	if (undo == 0)
	{
		document.Pro_Ressign.Undo_Seletion.value=0;
	}
	else
	{
		document.Pro_Ressign.Undo_Seletion.value=1;
	}
	document.Pro_Ressign.Step2.checked = true;
	var formObj = document.Pro_Ressign;
	var oldTarget = formObj.target;	
	
	
	submit_ok=Validate(formObj);
		
	if (submit_ok == 1)
	{
		formObj.target = "aaa";
		NewWindow("", 'aaa', '870', '600', 'Yes', 'No', true);
		document.Pro_Ressign.submit();
		formObj.target = oldTarget;
	}
	
}


function Validate(formObjPassed)
{
	var submit_ok = 1;
	if(formObjPassed.To_PM_Sponsor_ID.value == "" && formObjPassed.To_PM_Far_ID.value == "" && formObjPassed.To_Owner_Position_ID.value == "")
	{	
		alert("Please select some target criteria.");	
		submit_ok = 0;	
	}
	else
	{	
		
		if (formObjPassed.To_PM_Sponsor_ID.value == formObjPassed.From_PM_Sponsor_ID.value && formObjPassed.From_PM_Sponsor_ID.value != "")
		{
			alert("Please select different 'TARGET' Sponsor.");
			submit_ok = 0;
		}
		
		if(formObjPassed.To_PM_Far_ID.value == formObjPassed.From_PM_Far_ID.value && formObjPassed.From_PM_Far_ID.value != "")
		{
			alert("Please select different 'TARGET' Functional Area.");
			submit_ok = 0;
		}
		
		if (formObjPassed.To_Owner_Position_ID.value == formObjPassed.From_Owner_Position_ID.value && formObjPassed.From_Owner_Position_ID.value != "")
		{
			alert("Please select different 'TARGET' Owner Position.");
			submit_ok = 0;
		}		
	}	
	return submit_ok;
}


function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.PM_Item_Master_ID;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}	
}
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
function submitFinal()
{
	var formObj = document.Pro_Ressign;
	submit_ok=Validate(formObj);
	if(!anyCheckBoxChecked(formObj.PM_Item_Master_ID))	
	{
		alert("Please select alteast a project to reassign.");
		submit_ok = 0;
	}
	if (submit_ok == 1)
	{
		var confirm_reassign = confirm("Press OK to reassign the selected projects.");
		if (confirm_reassign)
		{
			document.Pro_Ressign.action="PM_Reassign_Action.cfm";
			document.Pro_Ressign.submit();
		}
	}
}
function Reset_criteria()
{
	var x = document.Pro_Ressign
	x.From_PM_Sponsor_ID.selectedIndex = 0;
	x.From_PM_Far_ID.selectedIndex = 0;
	x.From_Owner_Position_ID.selectedIndex = 0;
	x.To_PM_Sponsor_ID.selectedIndex = 0;
	x.To_PM_Far_ID.selectedIndex = 0;
	x.To_Owner_Position_ID.selectedIndex = 0;
	Owner_update.style.display="none";
	Show_Submit.style.display="none";
	NotBacktoFrom.style.display="none";	
	Show_Reset.style.display="none";
}
</SCRIPT>

<BR>


<CFSET Show_Criteria_First=0>
<CFSET Show_ToCriteria_First=0>
<FORM NAME="Pro_Ressign" ACTION="PM_ReassignSearch.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="Undo_Seletion" VALUE="1">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="85%" ALIGN="Center">
	<TR>
		<TD COLSPAN="100%">
			<TABLE BORDER="0" WIDTH="100%" CELLSPACING="0" CELLPADDING="0">
				<TR>
					<TD><FONT COLOR="navy" SIZE="3"><B>Reassign Projects</B></FONT></TD>					
					<TD ALIGN="Right">
					<B><FONT COLOR="Red">Steps involved:</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;
					<INPUT TYPE="Checkbox" NAME="Step1" <CFIF FORM.From_Owner_Position_ID NEQ "" OR FORM.From_PM_Sponsor_ID NEQ "" OR FORM.From_PM_Far_ID NEQ "">CHECKED</CFIF> DISABLED> <FONT COLOR="Red">Criteria Selection</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<!--- <INPUT TYPE="Checkbox" NAME="Step3" <CFIF isdefined("URL.Selected_Projects")>CHECKED</CFIF>> <FONT COLOR="Red">To</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --->
					<INPUT TYPE="Checkbox" NAME="Step2" <CFIF isdefined("URL.Selected_Projects")>CHECKED</CFIF> DISABLED> <FONT COLOR="Red">Project Selection</FONT>&nbsp;&nbsp;&nbsp;
					</TD>					
				</TR>
			</TABLE>
			<HR COLOR="Orange">
		</TD>		
	</TR>	
	<TR>
		<TD COLSPAN="100%">&nbsp;&nbsp;<B>Criteria for Project Reassignment&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<FONT SIZE="2" COLOR="Red">[</FONT>
			<CFIF not isdefined("URL.Selected_Projects")>
				<A Href = "##" ONCLICK="javaScript: Show_Criteria('1');">Select Criteria</A> 
			<CFELSE>
				<A Href = "##" ONCLICK="javaScript: Show_Criteria('2');">Select Criteria</A> 
			</CFIF>
			<FONT SIZE="2" COLOR="Red">]</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<SPAN ID="Show_Reset" <CFIF Show_Criteria_First EQ 0 OR isdefined("URL.Selected_Projects")>STYLE="DISPLAY:NONE"</CFIF>>
			<FONT SIZE="2" COLOR="Red">[</FONT>
			<A Href = "##" ONCLICK="javaScript: Reset_criteria();">Reset</A> 
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</SPAN>
			</B>	
		</TD>
	</TR>	
</TABLE>



<INPUT TYPE="Hidden" NAME="BacktoFrom" VALUE="0">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="4" WIDTH="85%" ID="Select_Criteria" <CFIF Show_Criteria_First EQ 0>STYLE="DISPLAY:NONE"</CFIF> ALIGN="Center">
	<TR>
		<TD WIDTH="45%" BGCOLOR="ffce84">&nbsp;&nbsp;&nbsp;<B>Source:</B><BR></TD>
		
		<TD WIDTH="50%" BGCOLOR="ffce84">&nbsp;&nbsp;&nbsp;<B>Target:</B><BR></TD>
	</TR>
	<TR>
		<TD WIDTH="50%" VALIGN="Top" BGCOLOR="C6FFC6">
			<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD WIDTH="120" ALIGN="Right"><B>Sponsor:</B></TD>
					<TD>
						<SELECT NAME="From_PM_Sponsor_ID" STYLE="WIDTH:90%;" ONCHANGE="Javascript: Display_Show_Submit('1')">
							<OPTION VALUE=""></OPTION>
							<CFOUTPUT QUERY="Get_Sponsor">
							<OPTION VALUE="#PM_Sponsor_ID#" <CFIF FORM.From_PM_Sponsor_ID EQ PM_Sponsor_ID>SELECTED</CFIF> >#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>				
				<TR>
					<TD ALIGN="Right"><B>Functional Area:</B></TD>
					<TD>
						<SELECT NAME="From_PM_Far_ID" STYLE="WIDTH:90%;" ONCHANGE="Javascript: Display_Show_Submit('2')">
							<OPTION VALUE=""></OPTION>
							<CFOUTPUT QUERY="Get_FAR">
							<OPTION VALUE="#PM_FAR_ID#" <CFIF FORM.From_PM_Far_ID EQ PM_FAR_ID>SELECTED</CFIF>>#PM_FAR_Description#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>
				<TR>
					<TD ALIGN="Right"><B>Owner Position:</B></TD>
					<TD>
						<SELECT NAME="From_Owner_Position_ID" STYLE="WIDTH:90%;" ONCHANGE="Javascript: Display_Show_Submit('3')"<!--- ONCHANGE="Javascript: Show_Owner_update('1')" --->>
							<OPTION VALUE=""></OPTION>
							<CFOUTPUT QUERY="Get_Positions">
							<OPTION VALUE="#User_Positions_ID#" <CFIF FORM.From_Owner_Position_ID EQ User_Positions_ID>SELECTED</CFIF>>#Position_Label#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>
			</TABLE>
		</TD>
		
		<CFSET Show_This_For_Fisrt_Time=0>
		<TD WIDTH="50%" VALIGN="Top" BGCOLOR="C6FFC6">
			<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD WIDTH="120" ALIGN="Right"><B>Sponsor:</B></TD>
					<TD>
						<SELECT NAME="To_PM_Sponsor_ID" STYLE="WIDTH:90%;"<!---  ONCLICK="Javascript: Check_Step2()" ONBLUR="Javascript: Confirm_Checked('1')" ONCHANGE="Javascript: Confirm_Checked('1')" --->>
							<OPTION VALUE=""></OPTION>
							<CFOUTPUT QUERY="Get_Sponsor">
							<OPTION VALUE="#PM_Sponsor_ID#" <CFIF FORM.To_PM_Sponsor_ID EQ PM_Sponsor_ID>SELECTED</CFIF> >#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>							
				<TR>
					<TD ALIGN="Right"><B>Functional Area:</B></TD>
					<TD>
						<SELECT NAME="To_PM_Far_ID" STYLE="WIDTH:90%;" <!--- ONCLICK="Javascript: Check_Step2()" ONCHANGE="Javascript: Confirm_Checked('2')" --->>
							<OPTION VALUE=""></OPTION>
							<CFOUTPUT QUERY="Get_FAR">
							<OPTION VALUE="#PM_FAR_ID#" <CFIF FORM.To_PM_Far_ID EQ PM_FAR_ID>SELECTED</CFIF>>#PM_FAR_Description#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>
				<TR>
					<TD ALIGN="Right"><B>Owner Position:</B></TD>
					<TD>
						<SELECT NAME="To_Owner_Position_ID" STYLE="WIDTH:90%;" <!--- ONCLICK="Javascript: Check_Step2()" ---> ONCHANGE="Javascript: Show_Owner_Update_Type()">
							<OPTION VALUE=""></OPTION>
							<CFOUTPUT QUERY="Get_Positions">							
							<OPTION VALUE="#User_Positions_ID#" <CFIF FORM.To_Owner_Position_ID EQ User_Positions_ID>SELECTED</CFIF>>#Position_Label#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>	
				<CFSET Owner_update_Style = 0>
				
				<TR ID="Owner_update" <CFIF FORM.To_Owner_Position_ID EQ "" OR FORM.From_Owner_Position_ID EQ "">STYLE="DISPLAY:NONE"</CFIF>>
					<TD ALIGN="Right"><B>Owner Update Type:</B></TD>
					<TD>
						<INPUT TYPE="Radio" NAME="Update" VALUE="1" <CFIF FORM.Update EQ 1>CHECKED</CFIF>><B>Replace</B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="Radio" NAME="Update" VALUE="0" <CFIF FORM.Update EQ 0>CHECKED</CFIF>><B>Add</B>
					</TD>
				</TR>
				
			</TABLE>
		</TD>
	</TR>	
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><BR><HR COLOR="Orange"><BR>
		<SPAN ID="Show_Submit" <CFIF Show_This_For_Fisrt_Time EQ 0>STYLE="DISPLAY:NONE"</CFIF>>
			<CFOUTPUT>
				<CF_button
				button_name		=	""
				button_caption	=	"Search Projects"
				button_action	=	"submitIntermediate('1')"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold" >
			</CFOUTPUT>		
		</SPAN>	
		</TD>
	</TR>
</TABLE>


<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="4" ID="Selected_Criteria" WIDTH="85%" ALIGN="Center">
<CFIF FORM.From_Owner_Position_ID NEQ "" OR FORM.From_PM_Sponsor_ID NEQ "" OR FORM.From_PM_Far_ID NEQ "">
	<CFOUTPUT>
		<CFIF FORM.From_PM_Far_ID NEQ "">
			<CFQUERY NAME="Get_FAR_Sel" datasource="#application.datasource#">
				Select		PM_FAR_Description
				From		PM_FAR
				Where		PM_FAR_Deleted	=	0 AND PM_Far_ID = '#FORM.From_PM_Far_ID#'
				
			</CFQUERY>
		</CFIF>
		<CFIF FORM.To_PM_Far_ID NEQ "">
			<CFQUERY NAME="Get_ToFAR_Sel" datasource="#application.datasource#">
				Select		PM_FAR_Description
				From		PM_FAR
				Where		PM_FAR_Deleted	=	0 AND PM_Far_ID = '#FORM.To_PM_Far_ID#'
				
			</CFQUERY>
		</CFIF>
		
		<CFIF FORM.From_PM_Sponsor_ID NEQ "">
			<CFQUERY NAME="Get_Sponsor_Sel" datasource="#application.datasource#">
				Select		PM_Sponsor_Name_First, 
							PM_Sponsor_Name_Last
				From		PM_Sponsor
				Where		PM_Sponsor_Deleted	=	0 AND PM_Sponsor_ID = '#FORM.From_PM_Sponsor_ID#'
			</CFQUERY>
		</CFIF>
		<CFIF FORM.To_PM_Sponsor_ID NEQ "">
			<CFQUERY NAME="Get_ToSponsor_Sel" datasource="#application.datasource#">
				Select		PM_Sponsor_Name_First, 
							PM_Sponsor_Name_Last
				From		PM_Sponsor
				Where		PM_Sponsor_Deleted	=	0 AND PM_Sponsor_ID = '#FORM.To_PM_Sponsor_ID#'
			</CFQUERY>
		</CFIF>
		
		<CFIF FORM.From_Owner_Position_ID NEQ "">
		<CFQUERY NAME="Get_Position_Sel" DATASOURCE="#Application.Datasource#">
			SELECT 	Position_Label 
			FROM	User_Positions 
			WHERE 	User_Positions_ID = #FORM.From_Owner_Position_ID#
		</CFQUERY>
		</CFIF>
		<CFIF FORM.To_Owner_Position_ID NEQ "">
		<CFQUERY NAME="Get_ToPosition_Sel" DATASOURCE="#Application.Datasource#">
			SELECT 	Position_Label 
			FROM	User_Positions 
			WHERE 	User_Positions_ID = #FORM.To_Owner_Position_ID#
		</CFQUERY>
		</CFIF>
		<TR BGCOLOR="ffce84">
			<TD>&nbsp;&nbsp;&nbsp;<B>Source:</B></TD>
			<TD>&nbsp;&nbsp;&nbsp;<B>Target:</B></TD>
		</TR>
		<TR>
			<TD WIDTH="50%" BGCOLOR="C6FFC6">
				<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
					<TR>
						<TD WIDTH="120" ALIGN="Right"><B>Sponsor:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.From_PM_Sponsor_ID NEQ "">#Get_Sponsor_Sel.PM_Sponsor_Name_First# #Get_Sponsor_Sel.PM_Sponsor_Name_Last#<CFELSE>None.</CFIF></TD>						
					</TR>
					<TR>
						<TD ALIGN="Right"><B>Functional Area:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.From_PM_Far_ID NEQ "">#Get_FAR_Sel.PM_FAR_Description#<CFELSE>None.</CFIF></TD>
					</TR>
					<TR>
						<TD ALIGN="Right"><B>Owner Position:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.From_Owner_Position_ID NEQ "">#Get_Position_Sel.Position_Label#<CFELSE>None</CFIF></TD>
					</TR>					
				</TABLE>
			</TD>
			
			<TD WIDTH="50%" BGCOLOR="C6FFC6"><SPAN ID="DonotshowWhileEdit" <CFIF isdefined("JustDummy")>STYLE="DISPLAY:NONE"</CFIF>>
				<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
					<TR>
						<TD WIDTH="120" ALIGN="Right"><B>Sponsor:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.To_PM_Sponsor_ID NEQ "">#Get_ToSponsor_Sel.PM_Sponsor_Name_First# #Get_ToSponsor_Sel.PM_Sponsor_Name_Last#<CFELSE>None.</CFIF></TD>						
					</TR>
					<TR>
						<TD ALIGN="Right"><B>Functional Area:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.To_PM_Far_ID NEQ "">#Get_ToFAR_Sel.PM_FAR_Description#<CFELSE>None.</CFIF></TD>
					</TR>
					<TR>
						<TD ALIGN="Right"><B>Owner Position:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.To_Owner_Position_ID NEQ "">#Get_ToPosition_Sel.Position_Label#<CFELSE>None</CFIF></TD>
					</TR>					
					<CFIF FORM.To_Owner_Position_ID NEQ "" AND FORM.From_Owner_Position_ID NEQ "">
					<TR>
						<TD ALIGN="Right"><B>Owner Update Type:</B></TD>
						<TD>&nbsp;&nbsp;<CFIF FORM.Update EQ 1>Update<CFELSEIF FORM.Update EQ 0>Add</CFIF></TD>
					</TR>
					</CFIF>
				</TABLE></SPAN>
			</TD>
		</TR>
		
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><HR COLOR="Orange"><BR>
				<CFIF not isdefined("URL.Selected_Projects")>
				<CF_button
					button_name		=	""
					button_caption	=	"search projects"
					button_action	=	"openSearchPage()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold">		
				</CFIF> 								
			</TD>
		</TR>	
		
	</CFOUTPUT>
</CFIF>
</TABLE>
<SPAN ID="NotBacktoFrom" <CFIF Not isdefined("URL.Selected_Projects")>STYLE="DISPLAY:NONE"</CFIF>>
<CFIF isdefined("URL.Selected_Projects")>
<INPUT TYPE="Hidden" NAME="Selected_Projects" VALUE=<CFOUTPUT>"#URL.Selected_Projects#"</CFOUTPUT>>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="85%" ALIGN="Center">
	<TR>
		<TD COLSPAN="100%"><B>Reassign selected projects:</B> &nbsp;&nbsp;&nbsp;<B><FONT SIZE="2" COLOR="Red">[ </FONT><A Href="##" ONCLICK="Javascript: submitIntermediate('0');">back to project search</A><FONT SIZE="2" COLOR="Red"> ]</FONT></B></TD>
	</TR>
	<TR BGCOLOR="ffce84">
			<TD CLASS="tableheader">
				<input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);">
			</TD>
			<TD CLASS="tableheader"><B>ACCT/PROJECT</B></TD>
			<TD CLASS="tableheader"><B>PRIORITY</B></TD>
			<TD CLASS="tableheader"><B>STATUS</B></TD>
			<TD CLASS="tableheader"><B>SPONSOR</B></TD>
			<TD CLASS="tableheader"><B>FUNCTIONAL AREA</B></TD>
			<TD CLASS="tableheader"><B>OWNER POSITION</B></TD>	
	</TR>
<CFSET Count = 0>	
<!--- <CFLOOP LIST="#URL.Selected_Projects#" INDEX="Item"> --->
<CFSET Selected_Projects_List = ListQualify(URL.Selected_Projects,"'",",","All")>
	<CFQUERY NAME="Get_Details_For_ListItems" DATASOURCE="#Application.Datasource#">
		SELECT 		PM_Item_Master.Pm_Item_Master_ID,
					PM_Item_Master.PM_Acct_Project,
					PM_Priority.PM_Priority_Description,
					PM_Status.PM_Status_Description,
					PM_Sponsor.PM_Sponsor_Name_First,
					PM_Sponsor.PM_Sponsor_Name_Last,
					PM_FAR.PM_Far_Description
					
		FROM		PM_Item_Master 
		INNER JOIN	PM_Priority ON PM_Priority.PM_Priority_ID = PM_Item_Master.PM_Priority_ID
		INNER JOIN 	PM_Status ON PM_Status.PM_Status_ID = PM_Item_Master.PM_Status_ID
		INNER JOIN 	PM_Sponsor ON PM_Sponsor.PM_Sponsor_ID = PM_Item_master.PM_Sponsor_ID
		INNER JOIN 	PM_FAR ON PM_FAR.PM_Far_ID = PM_Item_master.PM_Far_ID
		
		WHERE 		PM_Item_Master_ID IN (#PreserveSingleQuotes(Selected_Projects_List)#)
		ORDER BY 	PM_Item_Master.PM_Acct_Project
	</CFQUERY>


		
		
	<CFOUTPUT QUERY="Get_Details_For_ListItems">
	<TR BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<TD WIDTH="21" CLASS="tdbody">			
			<input TYPE="Checkbox" NAME="PM_Item_Master_ID" VALUE="#PM_Item_Master_ID#" CHECKED>
		</TD>
		<TD CLASS="tdbody">#PM_Acct_Project#</TD>
		<TD CLASS="tdbody">#PM_Priority_Description#</TD>
		<TD CLASS="tdbody">#PM_Status_Description#</TD>
		<TD CLASS="tdbody" NOWRAP>#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</TD>
		<TD CLASS="tdbody">#PM_Far_Description#</TD>			
		<CFQUERY NAME="Get_Ower_Label" DATASOURCE="#Application.Datasource#">
			SELECT 		Position_Label 
			FROM 		User_Positions 
			INNER JOIN 	PM_Owner_Position ON User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
			WHERE 		PM_Owner_Position.PM_Item_Master_ID = '#PM_Item_Master_ID#'
		</CFQUERY>
		<TD CLASS="tdbody">&nbsp;<CFIF Get_Ower_Label.Recordcount GT 1>Several...<CFELSE>#Get_Ower_Label.Position_Label#</CFIF></TD>
	</TR>
	</CFOUTPUT>
<!--- </CFLOOP> --->	
	
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
			<CFOUTPUT>
				<CF_button
				button_name		=	""
				button_caption	=	"Reassign Projects"
				button_action	=	"submitFinal()"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold" >
			</CFOUTPUT>			
		</TD>
	</TR>
</TABLE>

</CFIF>
</SPAN>

</FORM>

</body>
</html>

