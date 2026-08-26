<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFPARAM NAME="URL.active" 	DEFAULT="true">

<CFIF URL.active EQ true>
	<CFSET FORMULA_PAGE_NAME="1">
<CFELSE>
	<CFSET FORMULA_PAGE_NAME="2">
</CFIF>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "formulaPricing"
							formula_page_name = #formula_page_name#
							selectedIndex = "#(formula_page_name - 1)#" >

<!--- <CFINCLUDE TEMPLATE="Formula_Price_Header.cfm"> --->


<CFSET DEFAULT_SORT_BY = "RULE_NAME">
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="#DEFAULT_SORT_BY#">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">

<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
	<CFCASE VALUE="RULE_NAME,NUMBER_OF_COMMS,All_Programs_Count" DELIMITERS=",">
		<CFSET SORT_BY_STR = FORM.SORT_BY>
	</CFCASE>
</CFSWITCH>

<CFPARAM NAME="SORT_BY_STR" 	DEFAULT="#DEFAULT_SORT_BY#">
<CFSET SORT_ORDER_STR = "ASC">
<CFIF FORM.SORT_ORDER EQ "DESC">
	<CFSET SORT_ORDER_STR = "DESC">
</CFIF>



<CFQUERY NAME="Saved_Formula_List" DATASOURCE="#application.datasource#">
	SELECT	*
			,(SELECT COUNT(*)
				FROM 	Program_Formula_Pricing_Rule_Mapped
					INNER JOIN Contract_Main
					ON
					Contract_Main.Contract_Main_ID = Program_Formula_Pricing_Rule_Mapped.Program_ID
					AND
					Contract_Main.Deleted = 0
					AND
					Contract_Status_Type_IDX >= 0
					AND
					Contract_Main.Flagged_As_Purged = 0
					AND
					(
						(Contract_Main.Force_Expiration_Flag = 0)
						OR
						(Contract_Status_Type_IDX = 7)
					)
				WHERE
				Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = Formula_Pricing_Rule.Formula_Pricing_Rule_ID
				AND
				Program_Formula_Pricing_Rule_Mapped.Deleted = 0
			) AS All_Programs_Count
			,(SELECT COUNT(*)
				FROM 	Program_Formula_Pricing_Rule_Mapped
					INNER JOIN Contract_Main
					ON
					Contract_Main.Contract_Main_ID = Program_Formula_Pricing_Rule_Mapped.Program_ID
					AND Contract_Main.Contract_Status_Type_IDX < 7
					AND
					Contract_Main.Deleted = 0
					AND
					Contract_Status_Type_IDX >= 0
					AND
					Contract_Main.Flagged_As_Purged = 0
					AND
					(
						(Contract_Main.Force_Expiration_Flag = 0)
						OR
						(Contract_Status_Type_IDX = 7)
					)
				WHERE
				Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID = Formula_Pricing_Rule.Formula_Pricing_Rule_ID
				AND
				Program_Formula_Pricing_Rule_Mapped.Deleted = 0
			) AS Active_Programs_Count
	FROM	Formula_Pricing_Rule
	WHERE
			Deleted = 0
			<CFIF URL.active EQ true>
			AND
			Active_Code = 1
			<CFELSE>
			AND
			Active_Code = 0
			</CFIF>
	ORDER BY	#SORT_BY_STR# #SORT_ORDER_STR#
</CFQUERY>


<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	function deleteRules()
	{
		var formObj = document.DeleteForm;
		if(!Any_Object_Checked(formObj.RID) && formObj.EXISTING_RID.value.length == 0)
		{
			alert("You haven't select any item.");
			return false;
		}
		if(confirm("Do you really want to delete the selected rules?"))
		{
			formObj.action = "Formula_Price_Delete.cfm";
			formObj.submit();
		}
		return false;
	}

	function deactivateRules()
	{
		var formObj = document.DeleteForm;
		if(!Any_Object_Checked(formObj.RID) && formObj.EXISTING_RID.value.length == 0)
		{
			alert("You haven't select any item.");
			return false;
		}
		if(confirm("Do you really want to deactivate the selected rules?"))
		{
			formObj.action = "Formula_Price_Deactivate.cfm";
			formObj.submit();
		}
		return false;
	}

	function activateRules()
	{
		var formObj = document.DeleteForm;
		if(!Any_Object_Checked(formObj.RID) && formObj.EXISTING_RID.value.length == 0)
		{
			alert("You haven't select any item.");
			return false;
		}
		if(confirm("Do you really want to activate the selected rules?"))
		{
			formObj.action = "Formula_Price_Activate.cfm";
			formObj.submit();
		}
		return false;
	}



	function selectAll(thisObj)
	{
		var chObjs = document.all.RID;
		var bCheck = thisObj.checked;
		var i;
		if(chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					chObjs[i].checked = bCheck;
				}
			}
			else
			{
				chObjs.checked = bCheck;
			}
		}
	}

	function DeleteAllDeletableRules()
	{
		var formObj = document.DeleteForm;
		if(confirm("Do you really want to delete all the rules?"))
		{
			formObj.AlreadySelectedItems.value = "";
			formObj.EXISTING_RID.value = document.DeleteForm.Delete_All_Inactive_Rule_List.value;
			formObj.action = "Formula_Price_Delete.cfm";
			formObj.submit();
		}
		return false;
	}
</SCRIPT>
<BR>
<TABLE WIDTH="95%" ALIGN="center">
	<TR>
		<CFIF Saved_Formula_List.recordCount GT 0>
			<TD ALIGN="left" NOWRAP WIDTH="130">
			<CFIF URL.active EQ false>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return deleteRules();">
			delete selected
			<CFELSE>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return deactivateRules();">
			deactivate selected
			</CFIF>
			</a><FONT COLOR="FF0000">]</FONT></B>
			</TD>
			<CFIF URL.active EQ false>
			<TD ALIGN="left" NOWRAP WIDTH="130">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateRules();">activate selected</a><FONT COLOR="FF0000">]</FONT></B>
			</TD>
			</CFIF>
			<CFIF URL.active EQ false>
			<TD ALIGN="left" NOWRAP WIDTH="130">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return DeleteAllDeletableRules();">delete all</a><FONT COLOR="FF0000">]</FONT></B>
			</TD>
			</CFIF>
		</CFIF>
		<TD WIDTH="">&nbsp;</TD>
	</TR>
</TABLE>

<cfparam name="FORM.startrow"  default="1">
<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
<cfparam name="FORM.pageLength"  default=10>
<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">


<CFINCLUDE TEMPLATE="Paging_Retain_Old_Values.cfm">

<SCRIPT LANGUAGE="JavaScript">
	function sortThisPageBy(sortBy, sortOrder)
	{
		var sortForm = document.DeleteForm;
		sortForm.SORT_BY.value = sortBy;
		sortForm.SORT_ORDER.value = sortOrder;
		sortForm.submit();
		return false;
	}
</SCRIPT>
<!------ACTIVE DELETED FORMULA_PRICING_RULE_ID NUMBER_OF_COMMS RULE_NAME ----->
<FORM ACTION="index.cfm?active=<CFOUTPUT>#URL.active#</CFOUTPUT>" METHOD="post" NAME="DeleteForm">
	<CFOUTPUT>
	<INPUT TYPE="HIDDEN" NAME="active" VALUE="#URL.active#">
	<INPUT TYPE="HIDDEN" NAME="SORT_BY" VALUE="#FORM.SORT_BY#">
	<INPUT TYPE="HIDDEN" NAME="SORT_ORDER" VALUE="#FORM.SORT_ORDER#">
	</CFOUTPUT>

<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="CENTER" WIDTH="100%" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD>&nbsp;</TD>
		<TD>
		<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<CFSET Sort_By_list_Name = "Rule Name,## Commodites,Programs">
		<CFSET Sort_By_list_Value = "RULE_NAME,NUMBER_OF_COMMS,All_Programs_Count">
		<CFSET EachFieldWidth = "45,*,*">
		<CFSET Counter = 1>
		<CFOUTPUT>
		<CFLOOP LIST="#Sort_By_list_Value#" INDEX="This_Value">
			<CFSET sortImage="">
			<CFIF This_Value EQ Form.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "DESC">
					<CFSET New_Sort_Order="ASC">
					<CFSET sortImage="up_1.gif">
				<CFELSE>
					<CFSET New_Sort_Order="DESC">
					<CFSET sortImage="down_1.gif">
				</CFIF>
			<CFELSE>
				<CFSET New_Sort_Order="ASC">
			</CFIF>
			<CFSET This_Width = ListGetAt(EachFieldWidth, Counter, ",")>
			<CFSET This_Name = ListGetAt(Sort_By_list_Name, Counter, ",")>
			<TD<CFIF IsNumeric(This_Width)> WIDTH="#This_Width#%"</CFIF> STYLE="font-size:11px;"><A HREF="" OnClick="javaScript: return sortThisPageBy('#This_Value#', '#New_Sort_Order#')"><B>#This_Name#</B></A><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></TD>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
		<CFIF URL.active>
			<TD WIDTH="65" STYLE="font-size:11px;"><B>DeActivate&nbsp;</B></TD>
			<TD WIDTH="65" STYLE="font-size:11px;"><B>Delete&nbsp;</B></TD>
		<CFELSE>
			<TD WIDTH="65" STYLE="font-size:11px;"><B>Activate&nbsp;</B></TD>
			<TD WIDTH="65" STYLE="font-size:11px;"><B>Delete&nbsp;</B></TD>
		</CFIF>
	</TR>
	<CFOUTPUT QUERY="Saved_Formula_List" startrow="#StartRow#" maxrows="#MaxRows#">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>&nbsp;</TD>
		<TD>
		<CFIF Active_Programs_Count EQ 0 OR Active_Code EQ 1>
			<INPUT TYPE="checkbox" NAME="RID" VALUE="#Formula_Pricing_Rule_ID#"<CFIF ListFindNoCase(FORM.EXISTING_RID, Formula_Pricing_Rule_ID, ",")> CHECKED<CFSET FORM.AlreadySelectedItems=ListAppend(FORM.AlreadySelectedItems, Formula_Pricing_Rule_ID, ",")></CFIF>>
		<CFELSE>
			<INPUT TYPE="checkbox" DISABLED>
		</CFIF>
		</TD>
		<TD><A HREF="Formula_Price_Display.cfm?RID=#Formula_Pricing_Rule_ID#">#RULE_NAME#</A></TD>
		<TD>#NUMBER_OF_COMMS#</TD>
		<TD><A HREF="Formula_Price_Programs.cfm?RID=#Formula_Pricing_Rule_ID#">Programs
		<CFIF All_Programs_Count GT 0>(#All_Programs_Count#)</CFIF>
		</A></TD>
		<CFIF Saved_Formula_List.Active_Code EQ 0>
			<TD TITLE="Activate #RULE_NAME#" ALIGN="center"><a href="Formula_Price_Activate.cfm?RID=#Formula_Pricing_Rule_ID#&active=#URL.Active#" onClick="javascript:return confirm('Do you want to activate the rule \'' + '#ReplaceNOCase(RULE_NAME,"'","\'","All")#' + '\'?');"><img src="/images/on_the_program_item.gif" ALT="Activate #RULE_NAME#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Deactivate #RULE_NAME#" ALIGN="center"><a href="Formula_Price_Deactivate.cfm?RID=#Formula_Pricing_Rule_ID#&active=#URL.Active#" onClick="javascript:return confirm('Do you want to deactivate the rule \'' + '#ReplaceNOCase(RULE_NAME,"'","\'","All")#' + '\'?');"><img src="/images/not_allowed.gif" ALT="Deactivate #RULE_NAME#" BORDER="0"></a></TD>
		</CFIF>
		<CFIF Active_Programs_Count EQ 0>
			<TD TITLE="Delete #RULE_NAME#" ALIGN="center"><a href="Formula_Price_Delete.cfm?RID=#Formula_Pricing_Rule_ID#&active=#URL.Active#" onClick="javascript:return confirm('Do you want to delete the rule \'' + '#ReplaceNOCase(RULE_NAME,"'","\'","All")#' + '\'?');"><img src="/images/no_small.gif" ALT="Delete #RULE_NAME#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>
	</TR>
	</CFOUTPUT>
	<CFSET Delete_All_Inactive_Rule_List = ValueList(Saved_Formula_List.Formula_Pricing_Rule_ID, ",")>
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#FORM.startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="#FORM.frompage#">
	<INPUT TYPE="HIDDEN" NAME="EXISTING_RID" VALUE="#FORM.EXISTING_RID#">
	<INPUT TYPE="HIDDEN" NAME="Delete_All_Inactive_Rule_List" VALUE="#Delete_All_Inactive_Rule_List#">
	<INPUT TYPE="HIDDEN" NAME="AlreadySelectedItems" VALUE="#FORM.AlreadySelectedItems#">
	</CFOUTPUT>
</TABLE>
</FORM>
<CFOUTPUT>
<!------<FORM ACTION="index.cfm?active=#URL.active#" METHOD="post" NAME="MyForm">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#FORM.startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="#FORM.frompage#">
	</CFOUTPUT>
</FORM>----->
</CFOUTPUT>
<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <CF_Next_Previous_For_Forms
    formname="DeleteForm"
    query="Saved_Formula_List"
    maxpages="40"
    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
    addparams="">
   </DIV>

</cfmodule>