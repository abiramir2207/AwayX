<!--- budget_class_association_list.cfm --->
<!--- get budget class to display --->
<cfset qGetBudgetClassAssociation = BudgetManager.getBudgetClassAssociation(active=iActive) />
<cfset BudgetManager.loadBudgetLabels() />
<cfset defaultReturnCommand = "listActiveBudgetClassAssociation" />
<cfoutput>
<br>
<cfif Get_Profile_Settings.Create_Budget eq 1>
<!----
<CF_smallLink 
		title = "add" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('ceBudgetClass', 0, '#defaultReturnCommand#');"""
	>
---->
<CF_smallLink 
		title = "deactivate selected" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('deactivateBudgetClassAssociationMulti', 0, '#defaultReturnCommand#');"""
	>
<CF_smallLink 
		title = "activate selected" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('activateBudgetClassAssociationMulti', 0, '#defaultReturnCommand#');"""
	>
<CF_smallLink 
		title = "delete selected" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('deleteBudgetClassAssociationMulti', 0, '#defaultReturnCommand#');"""
	>
</cfif>
<CF_smallLink 
		title = "display active" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('listActiveBudgetClassAssociation', 0, '#defaultReturnCommand#');"""
	>
<CF_smallLink 
		title = "display inactive" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('listInActiveBudgetClassAssociation', 0, '#defaultReturnCommand#');"""
	>
<CF_smallLink 
		title = "display all" 
		url = "##"
		parameters = "onClick=""javascript: return submitForm('listBudgetClassAssociation', 0, '#defaultReturnCommand#');"""
	>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<br>
<CFPARAM NAME="saveMessage" DEFAULT="">
<cfif saveMessage neq "">
	<br>
	<div style="color:red;font-weight:bold;">**** #saveResponse[1]# ****
	<cfif isArray(saveResponse[3])>
		<cfloop from="1" to="#ArrayLen(saveResponse[3])#" index="i">
			<cfset qOnlyBudgetInTemplates = saveResponse[3][i] />
			<cfloop query="qOnlyBudgetInTemplates">
			<br>#Simple_Budget_Class_Association_Number# - #created_type#
			</cfloop>
		</cfloop>
	</cfif>
	</div>
	<br>
</cfif>
<br>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD STYLE="font-size:11px;">
			<input type="checkbox" name="selete_all" title="select/unselect all" onclick="javascript: CHSelectAll('Simple_Budget_Class_Association_ID', this.checked);">
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Class</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Budget</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>#BudgetManager.getBudgetClassAssociationLabel()#</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Activate/DeActivate</b>
		</TD>
		<TD STYLE="font-size:11px;" align="center">
			<b>Delete</b>
		</TD>
	</TR>
	<cfif not qGetBudgetClassAssociation.RecordCount>
		<tr>
			<td colspan="100%">N/A&nbsp;</td>
		</tr>
	</cfif>
	<cfset Prev_Simple_Budget_Class_Number = "" />
	<cfset Counter = 0 />
	<cfloop QUERY="qGetBudgetClassAssociation">
	<cfif Prev_Simple_Budget_Class_Number neq Simple_Budget_Class_Number>
		<cfset Counter = Counter + 1 />
		<cfset Prev_Simple_Budget_Class_Number = Simple_Budget_Class_Number />
	</cfif>
	<cfset bgColor = "FFFFFF">	
	<CFIF Counter MOD 2>	
		<cfset bgColor = "CCFFCC">
	</CFIF>
	<cfif NOT Active>
		<cfset bgColor = "CCCCCC">
	</cfif>
	<TR BGCOLOR="#bgColor#">
		<TD nowrap>
			<input type="checkbox" name="Simple_Budget_Class_Association_ID" value="#Simple_Budget_Class_Association_ID#">
		</TD>
		<TD nowrap>
			#Simple_Budget_Class_Number#-#Simple_Budget_Class_Desc#<br>
			(#DateFormat(Start_Date, "mm/dd/yyyy")# - #DateFormat(End_Date, "mm/dd/yyyy")#)
		</TD>
		<TD nowrap>#Simple_Budget_Number#-#Simple_Budget_Desc#</TD>
		<TD nowrap>
		<cfif Get_Profile_Settings.Create_Budget eq 1>
		<input type="text" name="Simple_Budget_Class_Association_Number_#Simple_Budget_Class_Association_ID#" value="#Simple_Budget_Class_Association_Number#" size="32" maxlength="30">
		<span id="Err_Sp_Simple_Budget_Class_Association_Number_#Simple_Budget_Class_Association_ID#"></span>
		<cfelse>#Simple_Budget_Class_Association_Number#
		</cfif>
		</TD>
		<td align="center">
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<cfif Active>
			<a title="Deactivate this class budget association" href="" onClick="JavaScript: return submitForm('deactivateBudgetClassAssociation','#Simple_Budget_Class_Association_ID#', 'listBudgetClassAssociation');"><img src="/images/not_allowed.gif" border="0"></a>
			<cfelse>
			<a title="Activate this class budget association" href="" onClick="JavaScript: return submitForm('activateBudgetClassAssociation','#Simple_Budget_Class_Association_ID#', 'listBudgetClassAssociation');"><img src="/images/on_the_program_item.gif" border="0" title="Deactivated by #Deactivated_By_Username# on #Deactivated_Date#"></a>
			</cfif>
		<cfelse>&nbsp;
		</cfif>
		</td>
		<td align="center">
		<cfif Get_Profile_Settings.Create_Budget eq 1>
			<!--- allow delete only once it is deactive, so that we can enforce the deactivate rules also ---->
			<cfif not Deleted and not Active>
			<a title="Delete this class budget association" href="" onClick="JavaScript: return submitForm('deleteBudgetClassAssociation','#Simple_Budget_Class_Association_ID#', 'listBudgetClassAssociation');"><img src="/images/no_small.gif" border="0"></a>
			</cfif>
		</cfif>
		&nbsp;
		</td>
	</TR>	
	</cfloop>
	<TR valign="bottom">
		<TD COLSPAN="100%" ALIGN="center">
		<br><br>
		<CF_smallLink 
			title = "save" 
			url = "##"
			parameters = "onClick=""javascript: return verifyAndsubmitBudgetClassAssociationForm('saveBudgetClassAssociationNumber', 0, '', '#BudgetManager.getBudgetClassAssociationLabel()#');"""
		>		
		</TD>
	</TR>
</TABLE>
<input type="hidden" value="#ValueList(qGetBudgetClassAssociation.Simple_Budget_Class_Association_ID)#" name="Simple_Budget_Class_Association_ID_List" />
<cf_MessageWindow />
</cfoutput>
