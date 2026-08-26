<!---
	Name: budget_access_rights.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.
	Author:			Clarence Morse       
    Description:	The file contains all budgets profile management logic.
	Usage:			/settings/budgets/access_rights_matrix.cfm
--->

<cfset Budget_User_Profile = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>

<cfparam name="saveToXl" default="no">
<cfparam name="fName" default="xl">

	<!--- write the header to XL --->
	<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Budgets" nl="yes"></cfif>
	<tr><td id="subheader" class="locked" align="left">Budget Profile Settings</td></tr>
	<cfoutput>
		<!--- Start Budget Access Level code --->
		<TR>
			<TD WIDTH="195" class="locked" nowrap>View All and Create All</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="View All and Create All"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BUDGET_ACCESS_LEVEL_Mass_3" NAME="BUDGET_ACCESS_LEVEL" VALUE="3"><a href="##" OnClick="javascript:massUpdate('radio','BUDGET_ACCESS_LEVEL_Mass_3','3')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Budget_User_Profile"><cfset Counter = Budget_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="BUDGET_ACCESS_LEVEL_#Counter#" MASSUPDATEID="BUDGET_ACCESS_LEVEL_Mass_3" VALUE="3"<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 3> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes">
					<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 2>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		<TR>
			<TD WIDTH="195" class="locked" nowrap>View All and Create Individual</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="View All and Create Individual"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BUDGET_ACCESS_LEVEL_Mass_2" NAME="BUDGET_ACCESS_LEVEL" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','BUDGET_ACCESS_LEVEL_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Budget_User_Profile"><cfset Counter = Budget_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="BUDGET_ACCESS_LEVEL_#Counter#" MASSUPDATEID="BUDGET_ACCESS_LEVEL_Mass_2" VALUE="2"<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 2> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes">
					<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		<TR>
			<TD WIDTH="195" class="locked" nowrap>View Only</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="View Only"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BUDGET_ACCESS_LEVEL_Mass_1" NAME="BUDGET_ACCESS_LEVEL" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','BUDGET_ACCESS_LEVEL_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Budget_User_Profile"><cfset Counter = Budget_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="BUDGET_ACCESS_LEVEL_#Counter#" MASSUPDATEID="BUDGET_ACCESS_LEVEL_Mass_1" VALUE="1"<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes">
					<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		<TR>
			<TD WIDTH="195" class="locked" nowrap>None</TD><cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="None"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BUDGET_ACCESS_LEVEL_Mass_0" NAME="BUDGET_ACCESS_LEVEL" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','BUDGET_ACCESS_LEVEL_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Budget_User_Profile"><cfset Counter = Budget_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="BUDGET_ACCESS_LEVEL_#Counter#"  MASSUPDATEID="BUDGET_ACCESS_LEVEL_Mass_0" VALUE="0"<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 0> CHECKED</CFIF> <!--- onpropertychange="changeDisableOtherCheckBoxes(this, this.form.BUDGET_ACCESS_LEVEL_#i#, 1);"--->  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes">
					<CFIF evaluate("Budget_User_Profile.BUDGET_ACCESS_LEVEL") EQ 0>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		
		<!--- End Budget Access Level Code --->
		
		<!--- Budget Approve --->
		<TR>
			<TD WIDTH="195" class="locked" nowrap>Approve Budget</TD> <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Approve Budget"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="budget_approve" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','budget_approve','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Budget_User_Profile">
			<cfset Counter = Budget_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="budget_approve_#counter#" NAME="budget_approve_#counter#"  MASSUPDATEID="budget_approve" VALUE="1"<CFIF Budget_User_Profile.budget_approve EQ 1> CHECKED</CFIF> onClick="" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>			
			<cfif saveToXl is "yes">
				<CFIF evaluate("Budget_User_Profile.budget_approve") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>

		<!--- Budget Approval with Zero --->
		<TR>
			<TD WIDTH="195" class="locked" nowrap>Approve With Zero Dollars</TD> <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Approve With Zero Dollars"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="budget_approval_with_zero" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','budget_approval_with_zero','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Budget_User_Profile">
			<cfset Counter = Budget_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="budget_approval_with_zero_#counter#"  MASSUPDATEID="budget_approval_with_zero" VALUE="1"<CFIF Budget_User_Profile.budget_approval_with_zero EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>			
			<cfif saveToXl is "yes">
				<CFIF evaluate("Budget_User_Profile.budget_approval_with_zero") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		
		<!--- Budget Commit Tolerance --->		
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();">
			<TD WIDTH="195" class="locked" nowrap>Budget Commitment Tolerance %</TD> <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Budget Commitment Tolerance %"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Budget_Commit_Tolerance" ID="Budget_Commit_Tolerance" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Budget_Commit_Tolerance','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="Budget_Commit_Tolerance_#counter#" SIZE="5"  MASSUPDATEID="Budget_Commit_Tolerance" VALUE="#Budget_Commit_Tolerance#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>			
			<cfif saveToXl is "yes">
				<cf_toFile fname="#fName#" data= ",#Budget_User_Profile.Budget_Commit_Tolerance#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		
		<!--- Budget Settlement Tolerance --->
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();">
			<TD WIDTH="195" class="locked" nowrap>Budget Settlement Tolerance %</TD> <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Budget Settlement Tolerance %"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Budget_Settlement_Tolerance" ID="Budget_Settlement_Tolerance" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Budget_Settlement_Tolerance','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="Budget_Settlement_Tolerance_#counter#" SIZE="5"  MASSUPDATEID="Budget_Settlement_Tolerance" VALUE="#Budget_Settlement_Tolerance#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>			
			<cfif saveToXl is "yes">
				<cf_toFile fname="#fName#" data= ",#Budget_User_Profile.Budget_Settlement_Tolerance#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>			   
	</cfoutput>
