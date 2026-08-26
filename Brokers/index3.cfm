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
<FONT SIZE="3"><B>Step 3: Create the activity for these products</B></FONT>
<HR SIZE="1" COLOR="silver">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decrypt the Operator ID																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="de" string ="#URL.OID#" key="#request.key#">
<CFSET Operator_ID = cryp.value>



<!--- Get the operator --->
<cfset useLakebaseForGet_Operator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Operator>
	<cftry>
		<cfset Get_Operator = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#Operator_ID#",
				"select" = "operator_name,operator_address,operator_city,operator_state,operator_zip,operator_dba"
			}), "operator_name,operator_address,operator_city,operator_state,operator_zip,operator_dba"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator>
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
</cfif>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT QUERY="Get_Operator">
	<fieldset style="padding: 5px;">
		<legend style="color:Navy; font-weight: bold; font-size: 14px;">Selected #application.returned_customer_setting.operator_label_singular#</legend>
	<TABLE BGCOLOR="FFCE84" WIDTH="100%"><TR><TD><SPAN CLASS="title2">#Operator_Name# - #Operator_Address# - #Operator_City# - #Operator_State# - #Operator_Zip#</SPAN></TD></TR></TABLE>
	</fieldset>
</CFOUTPUT>




<!--- newidlist is the name of the variable that comes from the previous page --->
<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
	Select	UPC,
			Description
	From	BSA_Foodservice_Items_Master
	Where	UPC	in	(#ListQualify(newidlist, "'")#)
</CFQUERY>

<BR>
<FORM ACTION="index4.cfm" METHOD="post" NAME="MyForm">

<INPUT TYPE="hidden" NAME="BSA_Operator_ID" VALUE="<CFOUTPUT>#Operator_ID#</CFOUTPUT>">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<fieldset style="padding: 5px;">
	<legend style="color:Navy; font-weight: bold; font-size: 14px;">Selected Products</legend>
		<TABLE border="0" CELLSPACING="0" cellpadding="1" width="100%" CLASS="MainTable" >

			<TR BGCOLOR="FFCE84">
				<TD HEIGHT="25"><SPAN CLASS="title2">UPC</SPAN></TD>
				<TD><SPAN CLASS="title2">Description</SPAN></TD>
				<TD><SPAN CLASS="title2">Weekly Volume</SPAN></TD>
				<TD><SPAN CLASS="title2">Unit of Measure</SPAN></TD>
				<TD><SPAN CLASS="title2">Purchasing Status</SPAN></TD>
			</TR>
		
			<CFOUTPUT QUERY="Get_Products">
				<CFSET cleanUPC=replace(UPC, "-", "_", "all")>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD>#UPC#</TD>
					<TD>#Description#</TD>
					<TD><INPUT TYPE="hidden"	NAME="UPC" VALUE="#UPC#">
						<INPUT TYPE="text"		NAME="Volume_#cleanUPC#" STYLE="width:75px;"></TD>
					<TD>
						<INPUT TYPE="radio"		NAME="UOM_#cleanUPC#" VALUE="lbs" CHECKED>lbs.
						&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio"		NAME="UOM_#cleanUPC#" VALUE="cs">cs.
					</TD>
					<TD>
						<INPUT TYPE="radio"		NAME="Status_#cleanUPC#" VALUE="1" CHECKED>Active
						&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio"		NAME="Status_#cleanUPC#" VALUE="0">Inactive
					</TD>
				</TR>
			</CFOUTPUT>

		</TABLE>
</fieldset>


<BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<fieldset style="padding: 5px;">
	<legend style="color:Navy; font-weight: bold; font-size: 14px;">Notes</legend>
	
<TABLE BORDER="0" CELLPADDING="4" CELLSPACING="0">
	<TR BGCOLOR="FFCE84">
		<TD STYLE="border-bottom:solid #93BEE2 1px; font-size : 10px;"><SPAN CLASS="title2">Date</SPAN></TD>
		<TD WIDTH="100%" STYLE="border-bottom:solid #93BEE2 1px; font-size : 10px;"><SPAN CLASS="title2">Notes</SPAN></TD>
	</TR>
	<TR BGCOLOR="Whitesmoke">
		<TD VALIGN="top">
			<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="5" BORDER="0" ALT=""><BR>
			<cf_easydate 
				formname="MyForm" 
				fieldname="Date_of_Note" 
				default="#now()#">
		</TD>
		<TD VALIGN="top">
			<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="5" BORDER="0" ALT=""><BR>
			<TEXTAREA ROWS="8" NAME="Broker_Action_Plan_Notes" STYLE="width:100%;"></TEXTAREA>
		</TD>
	</TR>
</TABLE>

	
</fieldset>


<BR><BR>

<CF_button
	button_name		=	"MyButton"
	button_caption	=	"save this plan"
	button_action	=	"javascript:document.all.MyForm.submit();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">


	
<BR><BR>

<!--- 	
<INPUT TYPE="submit" VALUE="save data...">
 --->

	
</FORM>	
</BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



