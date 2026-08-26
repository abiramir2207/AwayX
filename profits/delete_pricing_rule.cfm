<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Get the data for the passed rule --->

<CFQUERY NAME="Get_Rule_Data" datasource="#application.datasource#">
	Select		Pricing_Rule.Pricing_Rule_Name
	From		Pricing_Rule
	Where		Pricing_Rule.Pricing_Rule_ID			=	'#URL.PRID#'
</CFQUERY>

<CFSET pagetitle = "View Pricing Rule: "&Get_Rule_Data.Pricing_Rule_Name>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CENTER>
<h2><CFOUTPUT>#ucase(Get_Rule_Data.Pricing_Rule_Name)#</CFOUTPUT></h2>
	<FONT COLOR="#FF0000" SIZE="+1">Are you sure you want to delete this pricing rule?</FONT>
	<BR>
	<BR>
	Please check the "check box" to confirm, and click the "delete this rule" button 
</CENTER>

<BR><BR><BR><BR><BR><BR>


	<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" ALIGN="CENTER" WIDTH="50%">
	  <TR>
	<FORM ACTION="delete_doit.cfm" METHOD="post" ID="MyForm" NAME="MyForm">
		<TD ALIGN="CENTER">
			<INPUT NAME="deleterule" TYPE="checkbox" VALUE="1">
			<BR>Yes, I want to<BR>delete this rule!!!
		</TD>
		<TD ALIGN="CENTER">
	<INPUT NAME="Pricing_Rule_ID" TYPE="hidden" VALUE="<CFOUTPUT>#URL.PRID#</CFOUTPUT>">
	</FORM>

		<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"delete this rule"
		BUTTON_ACTION	=	"javascript:document.all.MyForm.submit();"
		BUTTON_TYPE		=	"link"
		BUTTON_WIDTH	=	"125"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">				
		</TD>
	  </TR>
	</TABLE>

