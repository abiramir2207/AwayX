<cfparam name="URL.usda_noi_epds_id" default="">

<cfif application.returned_customer_setting.APPROVAL_ON_TYPE_CODE EQ 1>
	<cfset TypeTable = "Type_Code_Desc">
	<cfset TypeTableID = TypeTable & "_ID">
	<cfset TypeTableDescColumn = TypeTable>
<CFELSE>
	<cfset TypeTable = "Type_Group_Desc">
	<cfset TypeTableID = TypeTable & "_ID">
	<cfset TypeTableDescColumn = TypeTable>
</cfif>

<cfif len(trim(URL.usda_noi_epds_id)) EQ 0>
	<cfset url.usda_noi_epds_id = 0>
</cfif>

<cfset useLakebaseForgetCurrentlySelectedTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("usda_noi_epds_type")>
<cfif useLakebaseForgetCurrentlySelectedTypes>
	<cftry>
		<cfset getCurrentlySelectedTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("usda_noi_epds_type", {
				"usda_noi_epds_id" = "eq.#URL.usda_noi_epds_id#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCurrentlySelectedTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCurrentlySelectedTypes>
<cfquery name="getCurrentlySelectedTypes" datasource="#application.datasource#">
	SELECT *
	FROM usda_noi_epds_type
	WHERE usda_noi_epds_ID = '#URL.usda_noi_epds_id#'
	AND Deleted = 0
</cfquery>
</cfif>
<CFSET CurrentlySelectedList = valuelist(getCurrentlySelectedTypes.type_id)>



<CFQUERY NAME="getAllTypes" datasource="#application.datasource#">
	SELECT *
	FROM #TypeTable#
	WHERE Deleted = 0
	AND 
	#TypeTableID#	NOT IN(
		SELECT DISTINCT Type_ID
		FROM usda_noi_epds_type
		WHERE usda_noi_epds_ID <> '#url.usda_noi_epds_id#' AND Deleted = 0
	)
	Order BY #TypeTableDescColumn#
</CFQUERY>

<FORM ACTION="type_code_to_usda_noi_epds_assignment_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">

<font COLOR="Navy" SIZE="+1"><CFOUTPUT>#application.returned_customer_setting.type_code_label_plural# For EPDS</font></CFOUTPUT>
<HR COLOR="orange">

	<CFIF getAllTypes.recordcount GT 0>

	<cfset bgcolor = "ffffff">
	<TABLE BORDER="0" ALIGN="center" CELLPADDING="3" CELLSPACING="0">
	 <TR>
	  <CFSET Mycounter=0>
	  <CFOUTPUT QUERY="getAllTypes">
	  <cfset currentID = evaluate("getAllTypes.#TypeTableID#")>
	  <TD><input TYPE="Checkbox" NAME="Types" VALUE="#currentID#" <cfif listfind(CurrentlySelectedList,currentID) GT 0> CHECKED</cfif> ></TD>
	  <TD NOWRAP>&nbsp;&nbsp;#Type_Code_Desc#</TD>
	  <CFSET Mycounter=Mycounter+1>
  
	  <CFIF Mycounter Mod 4>
	  <CFELSE>
	  	<CFIF bgcolor EQ "ffffff"><CFSET bgcolor ="C6FFC6"><CFELSE><CFSET bgcolor ="ffffff"></CFIF>
		</TR><TR BGCOLOR=#bgcolor#>
	  </CFIF>

	  </CFOUTPUT>
	</TABLE>
	<cfelse>
		<cfoutput><DIV ALIGN="center" STYLE="color: Navy; font-size: 20px;">All #application.returned_customer_setting.type_code_label_plural# Have Been Assigned To Other</cfoutput> Groups</DIV>
	</CFIF>
<HR COLOR="orange">
<DIV ALIGN="center">
	<CFIF getAllTypes.recordcount GT 0>
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

<cfoutput>
	<input type="Hidden" name="usda_noi_epds_id" value="#url.usda_noi_epds_id#">
</cfoutput>

</FORM>