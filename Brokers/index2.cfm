<CFSET PAGE_TITLE="Brokers' Action Plan">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>



<BR>
<FONT SIZE="3"><B>Step 2: Select the Products</B></FONT>
<HR SIZE="1" COLOR="silver">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the Operator ID																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="de" string ="#newidlist#" key="#request.key#">
<CFSET Operator_ID = cryp.value>

 
<!--- Get the operator --->
<CFQUERY NAME="Get_Operator" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	Select	Operator_Name,
			Operator_Address,
			Operator_City,
			Operator_State,
			Operator_Zip,
			Operator_DBA
	From	BSA_Operator
	Where	BSA_Operator_ID	=	#Operator_ID#
</CFQUERY>




<CFOUTPUT QUERY="Get_Operator">
	<fieldset style="padding: 5px;">
		<legend style="color:Navy; font-weight: bold; font-size: 14px;">Selected #application.returned_customer_setting.operator_label_singular#</legend>
	<TABLE BGCOLOR="FFCE84" WIDTH="100%"><TR><TD><FONT SIZE="3" COLOR="Navy"><B>#Operator_Name# - #Operator_Address# - #Operator_City# - #Operator_State# - #Operator_Zip#</B></FONT></TD></TR></TABLE>
	</fieldset>
</CFOUTPUT>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt the Operator data																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string ="#Operator_ID#" key="#request.key#">
<CFSET Operator_ID = cryp.value>





<SCRIPT>
	var inhibitpopup = true
</SCRIPT>


<CF_GeneralSearchTool
	destination_page		= "/brokers/index3.cfm?OID=#Operator_ID#"
	id						= "#Operator_ID#"
	selection_option		= "checkbox"
	result_code_location	= "/profiles/products/Product_Search_Action.cfm">





</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


