<CFOUTPUT>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>

<CFSET thisPage = CGI.SCRIPT_NAME>
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.Group_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="URL.ExcludeListFieldname" 	DEFAULT="">
<CFPARAM NAME="URL.groupLevelId" 	DEFAULT="0">

<cfmodule template="\Search_Screens\Popup_Search.cfm"
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.Group_ID#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			ExcludeListFieldname="#URL.ExcludeListFieldname#"
			groupLevelId="#URL.groupLevelId#"
			/>
			
<cfset BudgetGroupLevelManager = CreateObject("component", "components.settings.budget.BudgetGroupLevelManager").init() />
<cfset budgetGroupLevels = BudgetGroupLevelManager.getBudgetGroupLevel(budgetGroupLevelId = form.groupLevelId) />
<cfset BudgetGroupLevel = budgetGroupLevels[1] />

<HEAD>
	<TITLE>Search - #BudgetGroupLevel.description#</TITLE>
</HEAD>

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">


<CFPARAM NAME="FORM.ExcludeList" 	DEFAULT="">
<cfparam name="FORM.state" 	default="1">
<cfset formName = "frmApprovalGroups">
<FORM ACTION="#thisPage#" METHOD="post" name="#formName#">

<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="Blue";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";  
	WIDTH="500px";
</CFSCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=12>

<CFIF FORM.state EQ 1>
		
		<STYLE TYPE="text/css">
			body,td
				{
					font: 11px Arial;
				}
			A
				{
					color: blue;
					text-decoration: none;	
				}
			A:HOVER
				{
					color: red;
					text-decoration: underline;	
				}
		</STYLE>
		

		
		<!--- Get the records that match the selected criterria --->
		<cfset qGetBudgetGroupValues = BudgetGroupLevelManager.getBudgetGroupLevelValues(BudgetGroupLevel = BudgetGroupLevel) />

		<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">		
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF qGetBudgetGroupValues.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#qGetBudgetGroupValues.recordcount#</CFOUTPUT> #BudgetGroupLevel.description# That <CFIF qGetBudgetGroupValues.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<TABLE CELLPADDING="2" CELLSPACING="0" WIDTH="90%" CLASS="MainTable">
		<TR BGCOLOR="##ffce84">
			<TD>
			<INPUT TYPE="checkbox" NAME="AllItems" VALUE="" onClick="javaScript: CHSelectAll('Group_ID', this.checked);">			
			</TD>
			<TD ID="Header"><B>#BudgetGroupLevel.description#</B></TD>
		</TR>
		
		<CFSET AllList = ValueList(qGetBudgetGroupValues.Group_ID)>
		<CFSET AlreadySelectedItems = "">
		<CFLOOP QUERY="qGetBudgetGroupValues" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
		<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
			<TD>
			<INPUT TYPE="checkbox" NAME="Group_ID" VALUE="#Group_ID#"
			<CFIF listfind(FORM.FinalItemList, Group_ID) NEQ 0>CHECKED
				<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, Group_ID, ",")>
			</CFIF>
			></TD>
			<TD>#Group_Name#&nbsp;</TD>
		</TR>
		</CFLOOP>
		</TABLE>
		</FIELDSET>
	
	<DIV STYLE="font-size: 12px; color: Red;">
		<CF_Next_Previous_For_Forms
		formname="#formName#"
		query="qGetBudgetGroupValues"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: return finishedSearching(document.#formName#)"> import selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: return importAll(document.#formName#)"> import all record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: return removeAll(document.#formName#)"> removed selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
	<script language="JavaScript">
		function finishedSearching(searchForm)
		{
			searchForm.FinisedSearching.value = 1;
			searchForm.submit();
			return false;
		}
		function importAll(searchForm)
		{
			var AllList = "#AllList#";
			if(window.confirm("Do you want to import all the records from the search result?"))
			{
				searchForm.AlreadySelectedItems.value = "";
				searchForm.FinalItemList.value = AllList;
				finishedSearching(searchForm);
			}
			return false;
		}
		function removeAll(searchForm)
		{
			searchForm.AlreadySelectedItems.value = "";
			searchForm.FinalItemList.value = "";
			searchForm.AllItems.checked = true;
			searchForm.AllItems.click();
			return false;
		}
	</script>
</CFIF>
	<!------ popup search code ----->
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#FORM.ExcludeList#">	
	<INPUT NAME="groupLevelId" TYPE="HIDDEN" VALUE="#FORM.groupLevelId#">	
</FORM>
</BODY>
</HTML>
</CFOUTPUT>
