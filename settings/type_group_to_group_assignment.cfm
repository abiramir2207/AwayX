<cfset useLakebaseForgetMarginGroupTypeCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_type_groups")>
<cfif useLakebaseForgetMarginGroupTypeCodes>
	<cftry>
		<cfset getMarginGroupTypeCodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_group_type_groups", {
				"margin_group_id" = "eq.#URL.Group_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetMarginGroupTypeCodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetMarginGroupTypeCodes>
<CFQUERY NAME="getMarginGroupTypeCodes" datasource="#application.datasource#">
	SELECT *
	FROM Margin_Group_Type_Groups
	WHERE Margin_Group_ID = '#URL.Group_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>
<CFSET ExistingTypeCodes = valuelist(getMarginGroupTypeCodes.Type_Group_Desc_ID)>

<cfset useLakebaseForgetOccupiedMarginGroupTypeCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_type_groups")>
<cfif useLakebaseForgetOccupiedMarginGroupTypeCodes>
	<cftry>
		<cfset getOccupiedMarginGroupTypeCodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_group_type_groups", {
				"margin_group_id" = "neq.#URL.Group_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetOccupiedMarginGroupTypeCodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetOccupiedMarginGroupTypeCodes>
<CFQUERY NAME="getOccupiedMarginGroupTypeCodes" datasource="#application.datasource#">
	SELECT *
	FROM Margin_Group_Type_Groups
	WHERE Margin_Group_ID != '#URL.Group_ID#'
	AND Deleted = 0
</CFQUERY>
</cfif>

<CFSET ExcludedTypeCodes = valuelist(getOccupiedMarginGroupTypeCodes.Type_Group_Desc_ID)>

<CFQUERY NAME="getAllTypeCodes" datasource="#application.datasource#">
	SELECT *
	FROM Type_Group_Desc
	WHERE Deleted = 0 <CFIF getOccupiedMarginGroupTypeCodes.Recordcount GT 0>AND Type_Group_Desc_ID NOT IN(#replace(listqualify(ExcludedTypeCodes, "'", ","), '"', "'", "ALL")#)</CFIF>
	AND Type_Group_Desc is not null
	AND Category = '01'
	Order BY Type_Group_Desc
</CFQUERY>
<cfoutput><title>#application.returned_customer_setting.type_group_label_singular# Group Assignment</title></cfoutput>
<FORM ACTION="type_group_to_group_assignment_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<font COLOR="Navy" SIZE="+1">Group <CFOUTPUT>#URL.Group_ID# #application.returned_customer_setting.type_group_label_singular# Assignments</font></CFOUTPUT>
<HR COLOR="orange">

	<CFIF getAllTypeCodes.recordcount GT 0>

	<cfset bgcolor = "ffffff">
	<TABLE BORDER="0" ALIGN="center" CELLPADDING="3" CELLSPACING="0">
	 <TR>
	  <CFSET Mycounter=0>
	  <CFOUTPUT QUERY="getAllTypeCodes">
	  <TD><input TYPE="Checkbox" NAME="Type_Group_Desc_ID" VALUE="#getAllTypeCodes.Type_Group_Desc_ID#" <cfif listfind(ExistingTypeCodes,getAllTypeCodes.Type_Group_Desc_ID, ",")>CHECKED</cfif>></TD>
	  <TD NOWRAP>&nbsp;&nbsp;#Type_Group_Desc#</TD>
	  <CFSET Mycounter=Mycounter+1>
  
	  <CFIF Mycounter Mod 4>
	  <CFELSE>
	  	<CFIF bgcolor EQ "ffffff"><CFSET bgcolor ="C6FFC6"><CFELSE><CFSET bgcolor ="ffffff"></CFIF>
		</TR><TR BGCOLOR=#bgcolor#>
	  </CFIF>

	  </CFOUTPUT>
	</TABLE>
	<input TYPE="Hidden" NAME="Margin_Group_ID" VALUE="<CFOUTPUT>#URL.Group_ID#</CFOUTPUT>">
	<input TYPE="Hidden" NAME="ExistingList" VALUE="<CFOUTPUT>#ExistingTypeCodes#</CFOUTPUT>">
	<cfelse>
		<cfoutput><DIV ALIGN="center" STYLE="color: Navy; font-size: 20px;">All #application.returned_customer_setting.type_group_label_plural# Have Been Assigned To Other</cfoutput> Groups</DIV>
	</CFIF>
<HR COLOR="orange">
<DIV ALIGN="center">
	<CFIF getAllTypeCodes.recordcount GT 0>
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
		
		<!--- <input TYPE="Submit" VALUE="save" ONCLICK=""> --->
	<CFELSE>
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
	</CFIF>
</DIV>
</FORM>

 

