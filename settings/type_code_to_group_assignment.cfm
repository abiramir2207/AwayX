<!------ This file will not be just type code to group assognment,
it will handle any type of group to grouop assignment
For now, type code, type group, product hierarchy

application.returned_customer_setting.approval_on_type_code will give what type of group it is
1=type code, 0=type group, 
21=product hierarchy 1,
22=product hierarchy 2,
etc.
 ----->
<cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />

<CFQUERY NAME="getMarginGroupGroups" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Margin_Group_Any_Group
	WHERE 	Margin_Group_ID = '#URL.Group_ID#'
			AND 	Deleted = 0
			AND		Group_Type = #application.returned_customer_setting.approval_on_type_code#
</CFQUERY>
<CFSET ExistingGroups = valuelist(getMarginGroupGroups.Group_ID)>

<CFQUERY NAME="getOccupiedMarginGroupGroups" datasource="#application.datasource#">
	SELECT 	*
	FROM 	Margin_Group_Any_Group
	WHERE 	Margin_Group_ID != '#URL.Group_ID#'
			AND 	Deleted = 0
			AND		Group_Type = #application.returned_customer_setting.approval_on_type_code#
</CFQUERY>

<CFSET ExcludedGroups = valuelist(getOccupiedMarginGroupGroups.Group_ID)>

<CFQUERY NAME="getAllGroups" datasource="#application.datasource#">
	SELECT 	#approvalGroupType.NameField# As Group_Name, #approvalGroupType.IDField# As Group_ID
	FROM 	#approvalGroupType.tableName#
	WHERE 	Deleted = 0 
			<!------ <CFIF Len(ExcludedGroups) GT 0>
			AND #mt_tableIDField# NOT IN(#replace(listqualify(ExcludedGroups, "'", ","), '"', "'", "ALL")#)
			</CFIF> ----->
			<cfif approvalGroupType.prodHierLevel GT 0>
			AND Product_Hierarchy_Level = #approvalGroupType.prodHierLevel#
			</cfif>
	Order BY #approvalGroupType.NameField#
</CFQUERY>
<cfoutput><title>#approvalGroupType.Label# Group Assignment</title></cfoutput>
<FORM ACTION="type_code_to_group_assignment_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<CFSET GroupCount = URL.Group_ID>
<cfset numCount = 3 - len(GroupCount)>
<CFSET labelIndex = "">
<cfloop index="z" from="1" to="#numCount#" step="1">
	<cfset labelIndex = labelIndex & "0">
</cfloop>
<cfset labelIndex = labelIndex & GroupCount>
<font COLOR="Navy" SIZE="+1"><CFOUTPUT>#evaluate("application.returned_customer_setting.approval_group_count_#labelIndex#_label")# #approvalGroupType.Label# Assignments</font></CFOUTPUT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
Apply for all <input type="Checkbox" onclick="CHSelectAll('Group_ID', this.checked);">
<HR COLOR="orange">
	<cfset anyGroupToSelect = 0>
	<CFIF getAllGroups.recordcount GT 0>

		<cfset bgcolor = "ffffff">
		<TABLE BORDER="0" ALIGN="center" CELLPADDING="3" CELLSPACING="0">
		<TR>
		<CFSET Mycounter=0>
		<CFOUTPUT QUERY="getAllGroups">
			<CFSET CanSelect = 1>
			<cfif ListFindNoCase(ExcludedGroups, Group_ID, ",")>
				<CFSET CanSelect = 0>
			</cfif>
			<TD<CFIF NOT CanSelect> bgCOlor="##cccccc"</CFIF>><input TYPE="Checkbox" <CFIF CanSelect>NAME="Group_ID"</cfif> VALUE="#Group_ID#" <cfif listfind(ExistingGroups, Group_ID, ",")>CHECKED</cfif><CFIF NOT CanSelect> DISABLED<CFELSE><cfset anyGroupToSelect = 1></CFIF>></TD>
			<TD NOWRAP<CFIF NOT CanSelect> bgCOlor="##cccccc"</CFIF>>&nbsp;&nbsp;#Group_Name#</TD>
			<CFSET Mycounter=Mycounter+1>			
			<CFIF Mycounter Mod 4>
			<CFELSE>
				<CFIF bgcolor EQ "ffffff"><CFSET bgcolor ="C6FFC6"><CFELSE><CFSET bgcolor ="ffffff"></CFIF>
				</TR><TR BGCOLOR=#bgcolor#>
			</CFIF>
		
		</CFOUTPUT>
		</TABLE>
		<cfif NOT anyGroupToSelect>
		<cfoutput><DIV ALIGN="center" STYLE="color: Navy; font-size: 20px;">All #approvalGroupType.Label# Have Been Assigned To Other</cfoutput> Groups</DIV>
		</cfif>	
		<input TYPE="Hidden" NAME="Margin_Group_ID" VALUE="<CFOUTPUT>#URL.Group_ID#</CFOUTPUT>">
		<input TYPE="Hidden" NAME="ExistingList" VALUE="<CFOUTPUT>#ExistingGroups#</CFOUTPUT>">
	<cfelse>
		<cfoutput><DIV ALIGN="center" STYLE="color: Navy; font-size: 20px;">No #approvalGroupType.Label# found</cfoutput></DIV>
	</CFIF>
<HR COLOR="orange">
<DIV ALIGN="center">
	<TABLE>
	<TR>
	<CFIF getAllGroups.recordcount GT 0 AND anyGroupToSelect>
		<TD>
		<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"save"
		BUTTON_ACTION	=	"javascript: document.MyForm.submit();"
		BUTTON_TYPE		=	"link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">	
		</TD>
		<!--- <input TYPE="Submit" VALUE="save" ONCLICK=""> --->
	</CFIF>
		<TD>
		<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"close window"
		BUTTON_ACTION	=	"window.close();"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">	
		</TD>
	</TR></TABLE>
</DIV>
</FORM>

 

