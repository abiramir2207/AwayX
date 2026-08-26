<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<style>
		body,td
		{
			font-family:		Arial;
			font-size:			12px;
		}

		a,a:visited
		{
			color:				Blue;
			text-decoration:	None;
		}

		a:hover
		{
			color:				Red;
			text-decoration:	Underline;
		}

		td.borders
		{
			border-bottom:		1px Solid blue; 
			font-weight:		Bold;
		}

		TR.highlight
		{
			background-color: #D9FFDB;
			cursor:				pointer;
		}

		TR.nothighlight
		{
			background-color: #FFFFFF;
		}

		TD.maintable
		{
			border-bottom: 1px solid #C1C2FF;
		}
	</style>
</HEAD>

<BODY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Dev Note: KAL; D17007: 5.1 Shorcut Approval Changes : get application settings for freight --->
<cfset appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!--- Get the settings from the database --->
<CFQUERY NAME="Get_Data" DATASOURCE="#application.datasource#">
	SELECT		Revision_Settings.*, _Users.Name_First, Name_Last
	FROM		Revision_Settings 
	INNER JOIN _Users
	ON			Revision_Settings.Revision_Setting_Created_By =  _Users.User_ID
	WHERE		Revision_Setting_Deleted = 0
</CFQUERY>


<SCRIPT LANGUAGE="javascript">
	function showHideRevisionType(thisObj)
	{
		var formObjName		= 	thisObj.name;
		var formObjVal 		= 	thisObj.value;
		
		// Type A,B & C dont affect freight, keep them disabled.
		if(formObjName != 'Freight_Change_Approval')
		{
			for (k= 1;k<=3;k++){
				var formSubObj	=	document.getElementById(formObjName + "_Type"+k);
				if(formObjVal == 1){
					formSubObj.disabled = false;
					if(k==1){
						formSubObj.checked = true;
					}
				}
				else{
					formSubObj.value	= 0;
					formSubObj.checked = false;
					formSubObj.disabled	= true;
				}
			} // End: for(k= 1;k<=3;k++)
		}
	}

	// Switch between the "Products added for Fixed Price at List Price" and "Products added"
	function productAddSelector(thisObj)
	{
		if (thisObj.name == "Products_Added_Approval"){
			var otherObjName	= 	document.getElementsByName("Prod_Add_FixedEqPricelist_Approval");
			var otherSubObjName	= 	document.getElementsByName("Prod_Add_FixedEqPricelist_Approval_Type");								
		}
		
		if (thisObj.name == "Prod_Add_FixedEqPricelist_Approval"){
			var otherObjName	= 	document.getElementsByName("Products_Added_Approval");
			var otherSubObjName	= 	document.getElementsByName("Products_Added_Approval_Type");
		}
		
		// When clicked from the yes section only this condition is true
		if (thisObj.value == 1){
			otherObjName[0].checked = false;
			otherObjName[1].checked = true;
			for (k=0;k<otherSubObjName.length;k++){
				otherSubObjName[k].checked = false;
				otherSubObjName[k].disabled = true;				
			}
		}	
	}

	function submitForm() 
	{
		document.MyForm.submit();		
	}
	
</SCRIPT>

<cfif Get_Data.Recordcount neq 0>
	<CFOUTPUT>
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3" ALIGN="CENTER" STYLE="border:2px orange solid;">
		<TR>
		<TD STYLE="font-weight:bold;font-size:13px;">
		This setting was last updated on #DateFormat(Get_Data.Revision_Setting_Created_On, "mm/dd/yyyy")# #TimeFormat(Get_Data.Revision_Setting_Created_On, "hh:mm:ss tt")# by #Get_Data.Name_First#  #Get_Data.Name_Last#</TD>
		</TR>
	</TABLE>
	</CFOUTPUT>
</cfif>


<FORM ACTION="save_revise_program.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<TABLE BORDER="0" WIDTH="100%" ID="table1" CELLSPACING="0" CELLPADDING="2">
	<TR>
		<TD CLASS="maintable" COLSPAN="1" VALIGN="bottom" STYLE="border: none">&nbsp;</TD>
		<TD CLASS="maintable" COLSPAN="4" VALIGN="bottom" STYLE="border: none" ALIGN="center">&nbsp;</TD>
		<TD CLASS="maintable" COLSPAN="3" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>Type of Revision</B></TD>
	</TR>
	<cfset divNoRoutingMessage = "" />
	<cfif appsettings.getShortcutNoRoutingAllowed()>
	<TR>
		<TD CLASS="maintable" COLSPAN="1" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;"><B>General</B></TD>
		<TD CLASS="maintable" COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;" ALIGN="center"><B>&nbsp;</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;A</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;B</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;C</B></TD>
	</TR>

	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">No routing required - immediate approval after RFA
			<cfmodule template="/CustomTags/SmallHelp.cfm"
				width = "360"
				displayShifyX = "0"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"
				imgWidth="12"
				imgHeight="11"
				returnDivId="divNoRoutingMessage"
				>
				<span>
				<span style="color:red;font-weight:bold;">Attention!</span><br><br>
				Enabling this setting will by-pass all existing approval controls and routing logic for program revisions when a given revision exclusively contains the outcomes defined for this Short Cut rule.  For program revisions meeting the appropriate criteria, please note the following prior to enabling this feature:<br><br>
				A.	When the user selects "Click here to approve", the program status will update to Approved.<br><br>
				B.	The program revision will become approved even if the user who is executing the revision: [a] does not have approval rights from their Profile, [b] is set to "Agree Only" for the template or [c] does have approval rights but does not have them for the template involved.<br><br>
				C.	The revision will not route for approval from any user.<br><br>
				D.	The display for "Approved by" will be the user who executed the event.  All other displays, tables and reports will source that user identity.<br><br>
				E.	The program will become approved regardless of the margin, volume, budget balance, presence of duplicates [operators, distributors, items].<br><br>
				<center>
				<CF_smallLink 
					title = "close window" 
					url = "##"
					parameters = "onClick=""javascript: hideNoRoutingRequiredMessage();return false;"""
				>
				</center>
				</span>
			</cfmodule>
		</TD>
		<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>
		<TD CLASS="maintable">&nbsp;</TD>
		<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>
		<TD CLASS="maintable">&nbsp;</TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="checkbox" VALUE="1" ID="No_Routing_Required_A" NAME="No_Routing_Required_A"<CFIF Get_Data.No_Routing_Required_A EQ 1> CHECKED</CFIF> onClick="javascript: displayNoRoutingRequiredMessage(this);"></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="checkbox" VALUE="1" ID="No_Routing_Required_B" NAME="No_Routing_Required_B"<CFIF Get_Data.No_Routing_Required_B EQ 1> CHECKED</CFIF> onClick="javascript: displayNoRoutingRequiredMessage(this);"></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="checkbox" VALUE="1" ID="No_Routing_Required_C" NAME="No_Routing_Required_C"<CFIF Get_Data.No_Routing_Required_C EQ 1> CHECKED</CFIF> onClick="javascript: displayNoRoutingRequiredMessage(this);"></TD>
	</TR>
	
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>
	</cfif>
	
	<TR>
		<TD CLASS="maintable" COLSPAN="1" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;"><B>Program Information</B></TD>
		<TD CLASS="maintable" COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;" ALIGN="center"><B>Shortcut Approval</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;A</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;B</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;C</B></TD>
	</TR>

	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Base changes:  Volume, payment cycle or reference number [Basic Info]</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Other_Program_Changes_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Other_Program_Changes_Approval"<CFIF Get_Data.Other_Program_Changes_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Other_Program_Changes_Approval_Type1" NAME="Other_Program_Changes_Approval_Type"<CFIF Get_Data.Other_Program_Changes_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Other_Program_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Other_Program_Changes_Approval_Type2" NAME="Other_Program_Changes_Approval_Type"<CFIF Get_Data.Other_Program_Changes_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Other_Program_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Other_Program_Changes_Approval_Type3" NAME="Other_Program_Changes_Approval_Type"<CFIF Get_Data.Other_Program_Changes_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Other_Program_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Program Title changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Title_Changes_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Title_Changes_Approval"<CFIF Get_Data.Title_Changes_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Title_Changes_Approval_Type1"  NAME="Title_Changes_Approval_Type"<CFIF Get_Data.Title_Changes_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Title_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Title_Changes_Approval_Type2"  NAME="Title_Changes_Approval_Type"<CFIF Get_Data.Title_Changes_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Title_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Title_Changes_Approval_Type3"  NAME="Title_Changes_Approval_Type"<CFIF Get_Data.Title_Changes_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Title_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Program Start Date changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Start_Date_Change_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Start_Date_Change_Approval"<CFIF Get_Data.Start_Date_Change_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Start_Date_Change_Approval_Type1" NAME="Start_Date_Change_Approval_Type"<CFIF Get_Data.Start_Date_Change_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Start_Date_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Start_Date_Change_Approval_Type2" NAME="Start_Date_Change_Approval_Type"<CFIF Get_Data.Start_Date_Change_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Start_Date_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Start_Date_Change_Approval_Type3" NAME="Start_Date_Change_Approval_Type"<CFIF Get_Data.Start_Date_Change_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Start_Date_Change_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Program End Date changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="End_Date_Change_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="End_Date_Change_Approval"<CFIF Get_Data.End_Date_Change_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="End_Date_Change_Approval_Type1" NAME="End_Date_Change_Approval_Type"<CFIF Get_Data.End_Date_Change_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.End_Date_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="End_Date_Change_Approval_Type2" NAME="End_Date_Change_Approval_Type"<CFIF Get_Data.End_Date_Change_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.End_Date_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="End_Date_Change_Approval_Type3" NAME="End_Date_Change_Approval_Type"<CFIF Get_Data.End_Date_Change_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.End_Date_Change_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Program duration changed
			<CF_SmallHelp
				width = "360"
				displayShifyX = "30"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"
				imgWidth="12"
				imgHeight="11"
				>
				<center>The duration change will only work if the date change options are also on.  If you want to allow date changes, but only if the duration does not change, then turn ON start and end date and turn OFF the duration change.  If you want to allow all date changes even if the duration changes, then turn all 3 settings ON.
				</center>
			</CF_SmallHelp>
		</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Program_Date_Changed_Same_Duration" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Program_Date_Changed_Same_Duration"<CFIF Get_Data.Program_Date_Changed_Same_Duration EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Program_Date_Changed_Same_Duration_Type1" NAME="Program_Date_Changed_Same_Duration_Type"<CFIF Get_Data.Program_Date_Changed_Same_Duration_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Program_Date_Changed_Same_Duration EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Program_Date_Changed_Same_Duration_Type2" NAME="Program_Date_Changed_Same_Duration_Type"<CFIF Get_Data.Program_Date_Changed_Same_Duration_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Program_Date_Changed_Same_Duration EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Program_Date_Changed_Same_Duration_Type3" NAME="Program_Date_Changed_Same_Duration_Type"<CFIF Get_Data.Program_Date_Changed_Same_Duration_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Program_Date_Changed_Same_Duration EQ 2> DISABLED</CFIF>></TD>
	</TR>
	
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Program Reference Number changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Program_Reference_Number_Changes_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Program_Reference_Number_Changes_Approval"<CFIF Get_Data.Program_Reference_Number_Changes_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Program_Reference_Number_Changes_Approval_Type1" NAME="Program_Reference_Number_Changes_Approval_Type"<CFIF Get_Data.Program_Reference_Number_Changes_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Program_Reference_Number_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Program_Reference_Number_Changes_Approval_Type2" NAME="Program_Reference_Number_Changes_Approval_Type"<CFIF Get_Data.Program_Reference_Number_Changes_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Program_Reference_Number_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Program_Reference_Number_Changes_Approval_Type3" NAME="Program_Reference_Number_Changes_Approval_Type"<CFIF Get_Data.Program_Reference_Number_Changes_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Program_Reference_Number_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	
	<!---- Dev Notes: Anand Rao/31-Oct-2011/Program Notes changed --->
		<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Program Notes changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Program_Notes_Change_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Program_Notes_Change_Approval"<CFIF Get_Data.Program_Notes_Change_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Program_Notes_Change_Approval_Type1" NAME="Program_Notes_Change_Approval_Type"<CFIF Get_Data.Program_Notes_Change_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Program_Notes_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Program_Notes_Change_Approval_Type2" NAME="Program_Notes_Change_Approval_Type"<CFIF Get_Data.Program_Notes_Change_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Program_Notes_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Program_Notes_Change_Approval_Type3" NAME="Program_Notes_Change_Approval_Type"<CFIF Get_Data.Program_Notes_Change_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Program_Notes_Change_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	
	<!---- D32785: Shortcut Approval 1010127 --->
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">No Relevant Changes
			<CF_SmallHelp
				width = "360"
				displayShifyX = "30"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"
				imgWidth="12"
				imgHeight="11"
				>
				<center>The revision does not have any changes mentioned on this page, however it may have a non-relevant changes such as a component's payment cycle was changed or a component's pays to was changed.<br>
				Enabling this setting will allow the revision with these non relevant changes to short cut route.
				</center>
			</CF_SmallHelp>
		</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="No_Changes_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="No_Changes_Approval"<CFIF Get_Data.No_Changes_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="No_Changes_Approval_Type1" NAME="No_Changes_Approval_Type"<CFIF Get_Data.No_Changes_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.No_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="No_Changes_Approval_Type2" NAME="No_Changes_Approval_Type"<CFIF Get_Data.No_Changes_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.No_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="No_Changes_Approval_Type3" NAME="No_Changes_Approval_Type"<CFIF Get_Data.No_Changes_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.No_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>	
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>

	<TR>
		<TD CLASS="maintable" COLSPAN="1" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;"><B>Products & Rates</B></TD>
		<TD CLASS="maintable" COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;" ALIGN="center"><B>Shortcut Approval</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;A</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;B</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;C</B></TD>
	</TR>

	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Products added
			<CF_SmallHelp
				width = "360"
				displayShifyX = "30"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"
				imgWidth="12"
				imgHeight="11"
				>
				<center>You can only have one Products Added option as Shortcut approval. When one is selected, the other will be deselected.</center>
			</CF_SmallHelp>
		</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:productAddSelector(this);showHideRevisionType(this)" NAME="Products_Added_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:productAddSelector(this);showHideRevisionType(this)" NAME="Products_Added_Approval"<CFIF Get_Data.Products_Added_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Products_Added_Approval_Type1" NAME="Products_Added_Approval_Type"<CFIF Get_Data.Products_Added_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Products_Added_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Products_Added_Approval_Type2" NAME="Products_Added_Approval_Type"<CFIF Get_Data.Products_Added_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Products_Added_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Products_Added_Approval_Type3" NAME="Products_Added_Approval_Type"<CFIF Get_Data.Products_Added_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Products_Added_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Products added for Fixed Price at List Price
			<cf_smallhelp
				width = "360"
				displayShifyX = "30"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"	
				imgWidth="12"
				imgHeight="11"					
				>
				<center>You can only have one Products Added option as Shortcut approval. When one is selected, the other will be deselected.</center>
			</cf_smallhelp>
		</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:productAddSelector(this);showHideRevisionType(this)" NAME="Prod_Add_FixedEqPricelist_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:productAddSelector(this);showHideRevisionType(this)" NAME="Prod_Add_FixedEqPricelist_Approval"<CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Prod_Add_FixedEqPricelist_Approval_Type1" NAME="Prod_Add_FixedEqPricelist_Approval_Type"<CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Prod_Add_FixedEqPricelist_Approval_Type2" NAME="Prod_Add_FixedEqPricelist_Approval_Type"<CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Prod_Add_FixedEqPricelist_Approval_Type3" NAME="Prod_Add_FixedEqPricelist_Approval_Type"<CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Prod_Add_FixedEqPricelist_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>

	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Products removed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this);" NAME="Products_Removed_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Products_Removed_Approval"<CFIF Get_Data.Products_Removed_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Products_Removed_Approval_Type1" NAME="Products_Removed_Approval_Type"<CFIF Get_Data.Products_Removed_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Products_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Products_Removed_Approval_Type2" NAME="Products_Removed_Approval_Type"<CFIF Get_Data.Products_Removed_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Products_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Products_Removed_Approval_Type3" NAME="Products_Removed_Approval_Type"<CFIF Get_Data.Products_Removed_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Products_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>

	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Product rates increased
		<cf_smallhelp
				width = "360"
				displayShifyX = "30"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"	
				imgWidth="12"
				imgHeight="11"					
				>
				<center>
				Short cut routing for rate changes only apply to Rebate and Fixed Price.  These rules do not consider Growth, Lump Sum or Formula-based pricing.  
				Additionally, unit of measure changes for an existing rate are not considered when determining the short cut rules.
				</center>
			</cf_smallhelp>
		</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Products_Rates_Changes_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Products_Rates_Changes_Approval"<CFIF Get_Data.Products_Rates_Changes_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Products_Rates_Changes_Approval_Type1" NAME="Products_Rates_Changes_Approval_Type"<CFIF Get_Data.Products_Rates_Changes_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Products_Rates_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Products_Rates_Changes_Approval_Type2" NAME="Products_Rates_Changes_Approval_Type"<CFIF Get_Data.Products_Rates_Changes_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Products_Rates_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Products_Rates_Changes_Approval_Type3" NAME="Products_Rates_Changes_Approval_Type"<CFIF Get_Data.Products_Rates_Changes_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Products_Rates_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
<!--- D34880: Max Rate Easy Button and Short Cut Routing START--->
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Product rates decreased
		<cf_smallhelp
				width = "360"
				displayShifyX = "30"
				displayShifyY = "-30"
				imgPath="/Images/i.gif"
				dropdownCheck = "0"	
				imgWidth="12"
				imgHeight="11"					
				>
				<center>
				Short cut routing for rate changes only apply to Rebate and Fixed Price.  These rules do not consider Growth, Lump Sum or Formula-based pricing.  
				Additionally, unit of measure changes for an existing rate are not considered when determining the short cut rules.
				</center>
			</cf_smallhelp>		
		</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Products_Rates_Decreased_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Products_Rates_Decreased_Approval"<CFIF Get_Data.Products_Rates_Decreased_Approval EQ 2> CHECKED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Products_Rates_Decreased_Approval_Type1" NAME="Products_Rates_Decreased_Approval_Type"<CFIF Get_Data.Products_Rates_Decreased_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Products_Rates_Decreased_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Products_Rates_Decreased_Approval_Type2" NAME="Products_Rates_Decreased_Approval_Type"<CFIF Get_Data.Products_Rates_Decreased_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Products_Rates_Decreased_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Products_Rates_Decreased_Approval_Type3" NAME="Products_Rates_Decreased_Approval_Type"<CFIF Get_Data.Products_Rates_Decreased_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Products_Rates_Decreased_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
<!--- D34880: Max Rate Easy Button and Short Cut Routing END--->
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Product UOM changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Products_UOM_Changes_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Products_UOM_Changes_Approval"<CFIF Get_Data.Products_UOM_Changes_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Products_UOM_Changes_Approval_Type1" NAME="Products_UOM_Changes_Approval_Type"<CFIF Get_Data.Products_UOM_Changes_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Products_UOM_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Products_UOM_Changes_Approval_Type2" NAME="Products_UOM_Changes_Approval_Type"<CFIF Get_Data.Products_UOM_Changes_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Products_UOM_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Products_UOM_Changes_Approval_Type3" NAME="Products_UOM_Changes_Approval_Type"<CFIF Get_Data.Products_UOM_Changes_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Products_UOM_Changes_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Fixed Price Claim Mechanism changed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Component_ClaimMech_Change_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Component_ClaimMech_Change_Approval"<CFIF Get_Data.Component_ClaimMech_Change_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Component_ClaimMech_Change_Approval_Type1" NAME="Component_ClaimMech_Change_Approval_Type"<CFIF Get_Data.Component_ClaimMech_Change_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Component_ClaimMech_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Component_ClaimMech_Change_Approval_Type2" NAME="Component_ClaimMech_Change_Approval_Type"<CFIF Get_Data.Component_ClaimMech_Change_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Component_ClaimMech_Change_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Component_ClaimMech_Change_Approval_Type3" NAME="Component_ClaimMech_Change_Approval_Type"<CFIF Get_Data.Component_ClaimMech_Change_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Component_ClaimMech_Change_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>

	<TR>
		<TD CLASS="maintable" COLSPAN="1" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;"><B>Customers & Freight</B></TD>
		<TD CLASS="maintable" COLSPAN="4" VALIGN="bottom" STYLE="border-bottom: 2px solid #0000FF;" ALIGN="center"><B>Shortcut Approval</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;A</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;B</B></TD>
		<TD CLASS="maintable" COLSPAN="1" STYLE="border-bottom: 2px solid #0000FF" ALIGN="center"><B>&nbsp;C</B></TD>
	</TR>

	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Distributors added</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Distributors_Added_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Distributors_Added_Approval"<CFIF Get_Data.Distributors_Added_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Distributors_Added_Approval_Type1" NAME="Distributors_Added_Approval_Type"<CFIF Get_Data.Distributors_Added_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Distributors_Added_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Distributors_Added_Approval_Type2" NAME="Distributors_Added_Approval_Type"<CFIF Get_Data.Distributors_Added_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Distributors_Added_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Distributors_Added_Approval_Type3" NAME="Distributors_Added_Approval_Type"<CFIF Get_Data.Distributors_Added_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Distributors_Added_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Distributors removed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Distributors_Removed_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Distributors_Removed_Approval"<CFIF Get_Data.Distributors_Removed_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Distributors_Removed_Approval_Type1" NAME="Distributors_Removed_Approval_Type"<CFIF Get_Data.Distributors_Removed_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Distributors_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Distributors_Removed_Approval_Type2" NAME="Distributors_Removed_Approval_Type"<CFIF Get_Data.Distributors_Removed_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Distributors_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Distributors_Removed_Approval_Type3" NAME="Distributors_Removed_Approval_Type"<CFIF Get_Data.Distributors_Removed_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Distributors_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Operators added</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Operators_Added_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Operators_Added_Approval"<CFIF Get_Data.Operators_Added_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Operators_Added_Approval_Type1" NAME="Operators_Added_Approval_Type"<CFIF Get_Data.Operators_Added_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Operators_Added_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Operators_Added_Approval_Type2" NAME="Operators_Added_Approval_Type"<CFIF Get_Data.Operators_Added_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Operators_Added_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Operators_Added_Approval_Type3" NAME="Operators_Added_Approval_Type"<CFIF Get_Data.Operators_Added_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Operators_Added_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<TD CLASS="maintable">Operators removed</TD>
		<TD CLASS="maintable" ALIGN="right">Yes</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Operators_Removed_Approval" CHECKED></TD>
		<TD CLASS="maintable" ALIGN="right">No</TD>
		<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Operators_Removed_Approval"<CFIF Get_Data.Operators_Removed_Approval EQ 2> CHECKED</CFIF>></TD>
		<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Operators_Removed_Approval_Type1" NAME="Operators_Removed_Approval_Type"<CFIF Get_Data.Operators_Removed_Approval_Type EQ 1> CHECKED</CFIF> <CFIF Get_Data.Operators_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Operators_Removed_Approval_Type2" NAME="Operators_Removed_Approval_Type"<CFIF Get_Data.Operators_Removed_Approval_Type EQ 2> CHECKED</CFIF> <CFIF Get_Data.Operators_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
		<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Operators_Removed_Approval_Type3" NAME="Operators_Removed_Approval_Type"<CFIF Get_Data.Operators_Removed_Approval_Type EQ 3> CHECKED</CFIF> <CFIF Get_Data.Operators_Removed_Approval EQ 2> DISABLED</CFIF>></TD>
	</TR>
	<cfif appSettings.getShow_Fixed_Freight()>
		<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
			<TD CLASS="maintable">Freight changed</TD>
			<TD CLASS="maintable" ALIGN="right">Yes</TD>
			<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="1" onclick="javascript:showHideRevisionType(this)" NAME="Freight_Change_Approval" CHECKED></TD>
			<TD CLASS="maintable" ALIGN="right">No</TD>
			<TD CLASS="maintable"><INPUT TYPE="radio" VALUE="2" onclick="javascript:showHideRevisionType(this)" NAME="Freight_Change_Approval"<CFIF Get_Data.Freight_Change_Approval EQ 2> CHECKED</CFIF>></TD>
			<!---<TD CLASS="maintable" ALIGN="right">&nbsp;</TD>--->
			<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="1" ID="Freight_Change_Approval_Type1" NAME="Freight_Change_Approval_Type" DISABLED></TD>
			<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="2" ID="Freight_Change_Approval_Type2" NAME="Freight_Change_Approval_Type" DISABLED></TD>
			<TD CLASS="maintable" ALIGN="center"><INPUT TYPE="radio" VALUE="3" ID="Freight_Change_Approval_Type3" NAME="Freight_Change_Approval_Type" DISABLED></TD>
		</TR>
	<cfelse>
		<INPUT TYPE="Hidden" VALUE="2" NAME="Freight_Change_Approval">
	</cfif>
	<TR>
		<TD COLSPAN="100%">&nbsp;</TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" align="center">
			<FONT COLOR="#ff0000"><B>[</B></FONT>
				<A HREF="javascript:submitForm();"><B>Save</B></A>
			<FONT COLOR="#ff0000"><B>]</B></FONT>
		</TD>
	</TR>
</TABLE>
<!---<BR>
<INPUT TYPE="submit" VALUE="Save Settings...">--->
</FORM>	

<script language="javascript">

function displayNoRoutingRequiredMessage(oThis)
{
	if(oThis.checked)
	{
		<cfoutput>
		showSmallHelp('#divNoRoutingMessage#', true, 1);
		</cfoutput>	
	}
}

function hideNoRoutingRequiredMessage()
{
	<cfoutput>
	showSmallHelp('#divNoRoutingMessage#', false);
	</cfoutput>
}
</script> 
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
