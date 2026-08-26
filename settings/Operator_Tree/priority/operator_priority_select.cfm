<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Select - operator priority</title>
</head>

<body>
<!------ select_operator_priority.cfm ----->
<CFSET thisPage = CGI.SCRIPT_NAME>
<CFSET formName = "frmOperatorPriority">


<CFPARAM NAME="FORM.state" 	DEFAULT="0">
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">
<CFPARAM NAME="FORM.Operator_Priority_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 	DEFAULT="">
<CFPARAM NAME="FORM.FinisedSearching" 	DEFAULT="0">
<CFPARAM NAME="URL.importType" 	DEFAULT="multiple">
<CFPARAM NAME="FORM.importType" 	DEFAULT="#URL.importType#">
<CFMODULE template="/Search_Screens/Popup_Search.cfm"
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.Operator_Priority_ID#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			importType="#FORM.importType#">
			

<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=15>		

<cfset priority = CreateObject("component", "components.customer.operator.priority") />
<cfset qGetPriority = priority.getPriority() />
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script language="JavaScript">
	function finishedSearching(searchForm)
	{
		searchForm.FinisedSearching.value = 1;
		searchForm.submit();			
	}		
</script>
<FORM ACTION="#thisPage#" METHOD="post" name="#formName#">

<cfif qGetPriority.recordCount GT 0>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD>
			<CFIF FORM.importType NEQ "single">
			<INPUT TYPE="checkbox" VALUE="" onClick="javaScript: CHSelectAll('Operator_Priority_ID', this.checked);">			
			<CFELSE>&nbsp;</CFIF>
			</TD>
		<TD STYLE="font-size:11px;"><b>Priority Name</b></TD>
		<td>&nbsp;</td>
	</TR>
	<CFSET AlreadySelectedItems = "">
	<CFLOOP QUERY="qGetPriority" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD>
			<INPUT TYPE="<CFIF FORM.importType NEQ "single">checkbox<CFELSE>radio</CFIF>" NAME="Operator_Priority_ID" VALUE="#Operator_Priority_ID#"
			<CFIF listfind(FORM.FinalItemList, Operator_Priority_ID) NEQ 0>CHECKED
				<CFSET AlreadySelectedItems = listappend(AlreadySelectedItems, Operator_Priority_ID, ",")>
			</CFIF>
			></TD>
		<TD>#Priority_Label#</TD>
		<TD><cfif isDefault>(Default)<cfelse>&nbsp;</cfif></TD>	
	</TR>	
	</CFLOOP>
</TABLE>
	<DIV STYLE="font-size: 12px; color: Red;">
		<CF_Next_Previous_For_Forms
		formname="#formName#"
		query="qGetPriority"
		maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	
	<!------ popup search code ----->
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#FORM.FormName#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#FORM.FieldName#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#FORM.FinalItemList#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">	
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
	<INPUT NAME="state" TYPE="hidden" value="1">
	<INPUT NAME="importType" TYPE="HIDDEN" VALUE="#FORM.importType#">
	
	<FONT SIZE="2">
	<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: finishedSearching(document.#formName#)"> import selected record(s) </a><FONT COLOR="##FF0000">]</FONT></B>
	</FONT>
<cfelse>
	<BR><BR><SPAN CLASS="Title2">No record found</SPAN>
</cfif>
</form>
</body>
</html>

</CFOUTPUT>