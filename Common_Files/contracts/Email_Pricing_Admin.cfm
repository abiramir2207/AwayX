<!------ Email_Pricing_Admin.cfm ----->
<cfparam name="URL.CID" 	default="">
<cfset Include_File_path = "/common_files/contracts/thin_contract_general_display_header.cfm" />

<CFQUERY name="GetOperatorAdmin" datasource="#application.datasource#">
	SELECT 	Operator_Admin_ID, Pricing_Admin_ID
	FROM 	General_Settings
</CFQUERY>

<cfset Pricing_Admin_ID 	= GetOperatorAdmin.Pricing_Admin_ID>
<cfset Pricing_Admin_Email_ID = "" />

<cfif Trim(Pricing_Admin_ID) GT 0>

	<cfset userManager = CreateObject("component", "components.user.UserManager").init() />
	<cfset Pricing_Admin_Email_ID = userManager.getUserEmail(Pricing_Admin_ID) />

</cfif>


<cfif Trim(Pricing_Admin_Email_ID) GT 0><!------ Yes Pricing Admin ----->

	<cfmodule 	
		template="/Customtags/Email_Common_Form.cfm"
		Include_File_path="#Include_File_path#" 
		Document_Title="Pricing request" 
		Document_Number_Variable="CSLGetContractInfo.Contract_Number" 
		Document_Title_Variable="CSLGetContractInfo.Contract_Title"
		Document_Title_File_Prefix="Program_Details_" 
		CID="#URL.CID#"
		Key="#request.key#"
		Provide_Close_Link="1"
		FAX_EMAIL="EMAIL"
		displayoutput="1"
		Use_To_Email_Address_Instead_Of_Lookup="#Pricing_Admin_Email_ID#"
		BothTypes="1">
	
<cfelse><!------ No Pricing Admin ----->

	<BR><BR><BR><BR><BR>
	
	<center>
	<B>
	<font color="red" size="2">There is no pricing administrator set up. Please contact the system administrator.</font>
	</B>
	
	<BR><BR>
	<CF_button
		button_name		=	""
		button_caption	=	"close window"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Click here to close this window ..."
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"> 
		
	</center>


</cfif>