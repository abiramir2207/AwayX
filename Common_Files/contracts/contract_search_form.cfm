<CFSET PAGE_TITLE="Search Contracts...">
<CFSET GROUP="contracts">


<!--- this code makes sure the implementation of the search from outside is conducted accordingly --->
<CFPARAM NAME="FORM.ES_ExternalSearch_Flag" DEFAULT="0">
<CFIF isdefined("FORM.ES_ExternalSearch")>
	<CFSCRIPT>
		VariableCount = 0;
		if(isdefined("FORM.ES_group")) // check for variable that defines the Group
			VariableCount = VariableCount + 1;

		if(isdefined("FORM.ES_finaldestination")) // check for variable that defines what page the selected contracts return to
			VariableCount = VariableCount + 1;

		if(isdefined("FORM.ES_multipleselections")) // check for variable that defines if multiple contracts can be selected or only one
			VariableCount = VariableCount + 1;
			
		if(isdefined("FORM.ES_tabgroup")) // check for variable that defines what tab group to show up top
			VariableCount = VariableCount + 1;

		if(isdefined("FORM.ES_itemid")) // check for variable that defines what tab group to show up top
			VariableCount = VariableCount + 1;

		if(isdefined("FORM.ES_urlinterfacestring")) // check for variable that defines what tab group to show up top
			VariableCount = VariableCount + 1;
			
		if(VariableCount EQ 6)
			FORM.ES_ExternalSearch_Flag = 1;
	</CFSCRIPT>
</CFIF>

<CFIF FORM.ES_ExternalSearch_Flag EQ 1><CFSET GROUP = FORM.ES_group></CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/top_header.cfm">

<!--- diaplay the right set of tabs --->
<CFIF FORM.ES_ExternalSearch_Flag EQ 1>
	<CFSWITCH EXPRESSION="#FORM.ES_group#">
		<CFCASE VALUE="payables">
			<CF_CRYP type="de" string="#FORM.ES_itemid#" key="#request.key#">
			<CFSET temp = cryp.value>
			<CFSET PSL_Payable_ID = temp>
			<CFSET PSL_CallingPageCode = "ct"> 
			<CFINCLUDE TEMPLATE="../payables2/payable_status_legend.cfm">
		</CFCASE>
	</CFSWITCH>
</CFIF>


<BLOCKQUOTE><BLOCKQUOTE>


<!--- diaplay the right set of minimal info --->
<CFIF FORM.ES_ExternalSearch_Flag EQ 1>
	<CFSWITCH EXPRESSION="#FORM.ES_group#">
		<CFCASE VALUE="payables">
			<CFSET helpfilenumber=5>
			<CFSET MPI_Payable_ID = temp>
			<cfinclude template="../payables2/minimal_payable_info.cfm">
		</CFCASE>
	</CFSWITCH>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get from db all of the Q Brand Description													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Q_Brand_Desc" datasource="#application.datasource#">
Select	distinct	Q_Brand_Desc
From	BSA_Foodservice_Items_Master
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get from db all of the Type Code Description													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Type_Code_Desc" datasource="#application.datasource#">
Select		distinct	Type_Code_Desc
From		BSA_Foodservice_Items_Master
Order by	Type_Code_Desc
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get from db all of the Type Group Description													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Type_Group_Desc" datasource="#application.datasource#">
Select	distinct	Type_Group_Desc
From	BSA_Foodservice_Items_Master
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get from db all of the Brands																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Brand" datasource="#application.datasource#">
Select	distinct	Brand
From	BSA_Foodservice_Items_Master
Where 	Brand IS NOT NULL
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all of the UOM descriptions																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_UOM" datasource="#application.datasource#">
Select	*
From	Units_of_Measure
</CFQUERY>			
			
			
<STYLE TYPE="text/css">
	.red
	{
		font-size:11px;
		width: 200px;
	}
</STYLE>

<!--- 
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=10>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 --->

<FORM ACTION="contract_search_action.cfm" METHOD="post" NAME="MyForm">


<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="10">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_search_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
			

	<TABLE border="0" cellspacing="10" CELLPADDING="0">
		<TR>
			<TD><B><SPAN CLASS="title2">Contract Number:</SPAN></B><BR>
				<INPUT type="text" name="contract_number" size="32" CLASS="red"></TD>
			<TD><B><SPAN CLASS="title2">Quantity & Unit of Measure:</SPAN></B><BR>
				<SELECT size="1" name="QTY_Compare" CLASS="red" STYLE="width:75px;">
					<OPTION VALUE="All">Any qty...</OPTION>
					<OPTION VALUE="Greater than">Greater than</OPTION>
					<OPTION VALUE="Equal to">Equal to</OPTION>
					<OPTION VALUE="Less than">Less than</OPTION>
				</SELECT>
				<INPUT type="text" name="QTY_Value" CLASS="red" STYLE="width:55px;">
				<SELECT size="1" name="uom" CLASS="red" STYLE="width:70px;">
					<OPTION VALUE="All">Any UOM</OPTION>
					<CFOUTPUT QUERY="Get_UOM"><OPTION VALUE="#Unit_of_Measure_ID#">#Unit_of_Measure_Desc#</OPTION></CFOUTPUT>
				</SELECT></TD>
		</TR>
		<TR>
			<TD><B><SPAN CLASS="title2">Contract Title:</SPAN></B><BR>
				<INPUT type="text" name="contract_title" size="32" CLASS="red"></TD>
			<TD><B><SPAN CLASS="title2">Broker(s):</SPAN></B><BR>
				<INPUT type="text" name="Broker" size="34" CLASS="red"></TD>
		</TR>
		<TR>
			<TD><B><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>(s):</SPAN></B><BR>
				<INPUT type="text" name="Operator" size="32" CLASS="red"></TD>
			<TD><B><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>(s):</SPAN></B><BR>
				<INPUT type="text" name="Distributor" size="34" CLASS="red"></TD>
		</TR>
		<TR>
			<TD>
				<B><SPAN CLASS="title2">Products:</SPAN></B><BR>
				<SELECT size="1" name="Type_Group_Desc" CLASS="red">
					<OPTION VALUE="All">**ALL** Type Group Descriptions</OPTION>
					<CFOUTPUT QUERY="Type_Group_Desc">
					<OPTION VALUE="#trim(Type_Group_Desc)#">#trim(Type_Group_Desc)#</OPTION>
					</CFOUTPUT>
				</SELECT><BR>
			</TD>
			<TD>
				<BR>
				<SELECT size="1" name="Type_Code_Desc" CLASS="red">
					<OPTION VALUE="All">**ALL** Type Code Descriptions</OPTION>
					<CFOUTPUT QUERY="Type_Code_Desc">
					<OPTION VALUE="#trim(Type_Code_Desc)#">#trim(Type_Code_Desc)#</OPTION>
					</CFOUTPUT>
				</SELECT><BR>
			</TD>
		</TR>
		<TR>
			<TD>
				<SELECT size="1" name="Q_Brand_Desc" CLASS="red">
					<OPTION VALUE="All">**ALL** Q Brand Descriptions</OPTION>
					<CFOUTPUT QUERY="Q_Brand_Desc">
					<OPTION VALUE="#trim(Q_Brand_Desc)#">#trim(Q_Brand_Desc)#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<SELECT size="1" name="Brand" CLASS="red">
					<OPTION VALUE="All">**ALL** Brands</OPTION>
					<CFOUTPUT QUERY="Brand">
					<OPTION VALUE="#trim(Brand)#">#trim(Brand)#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
		</TR>
		<TR>
			<TD>
				<B><SPAN CLASS="title2">Contract Status:</SPAN></B><BR>
				<FONT SIZE="2">
				<INPUT TYPE="radio" NAME="contract_status" VALUE="3" CHECKED>Active Contracts<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="1">Work in Progress<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="2">Preactive Contracts
				</FONT>
			</TD>
			<TD>
				<BR>
				<FONT SIZE="2">
				<INPUT TYPE="radio" NAME="contract_status" VALUE="4">Archived/Expired<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="5">Expiring in < 8 weeks<BR>
				<INPUT TYPE="radio" NAME="contract_status" VALUE="0">All Contracts
				</FONT>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="2">
				<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD>
							<B><SPAN CLASS="title2">Contract Types:</SPAN></B><BR>
							<INPUT TYPE="radio" NAME="template" VALUE="0" CHECKED>Contracts Only<BR>
						</TD>
						<TD>
							<BR><INPUT TYPE="radio" NAME="template" VALUE="1">Templates only<BR>
						</TD>
						<TD>
							<BR><INPUT TYPE="radio" NAME="template" VALUE="2">Contracts & Templates<BR>
						</TD>
					</TR>
				</TABLE>
			</TD>
		</TR>
		
	</TABLE>

	<BR>
	
	<CF_button
		button_name		=	""
		button_caption	=	"search contracts"
		button_action	=	"javascript:MyForm.submit();"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Click here to search the contracts database"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">

	
			
		</TD>
	</TR>
</TABLE>

<CFIF FORM.ES_ExternalSearch_Flag EQ 1>
	<CFOUTPUT>
		<INPUT TYPE="hidden" NAME="ES_ExternalSearch_Flag"	VALUE="#FORM.ES_ExternalSearch_Flag#">
		<INPUT TYPE="hidden" NAME="ES_group" 					VALUE="#FORM.ES_group#">
		<INPUT TYPE="hidden" NAME="ES_finaldestination"			VALUE="#FORM.ES_finaldestination#">
		<INPUT TYPE="hidden" NAME="ES_multipleselections"		VALUE="#FORM.ES_multipleselections#">
		<INPUT TYPE="hidden" NAME="ES_itemid"					VALUE="#FORM.ES_itemid#">
		<INPUT TYPE="hidden" NAME="ES_tabgroup"					VALUE="#FORM.ES_tabgroup#">
		<INPUT TYPE="hidden" NAME="ES_urlinterfacestring"		VALUE="#FORM.ES_urlinterfacestring#">
	</CFOUTPUT>
</CFIF>


</FORM>
			
			
			
		

















</BLOCKQUOTE></BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>

