<CFSET PAGE_TITLE="Project Management">
<CFSET GROUP="pm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>


<CFIF Get_Profile_Settings.PM_Access NEQ 1>
	<CFLOCATION URL="/manufacturers/home.cfm" ADDTOKEN="No">
</CFIF>


<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>

<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody
		{
			border-bottom:solid #93BEE2 1px; 
			font-size : 10px;
		}
	.dropdown
		{
			width: 270px;
		}
	
	INPUT, SELECT, TEXTAREA
		{
			font: 8pt Arial;
		}
</style>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<TABLE CELLPADDING="0" CELLSPACING="10" WIDTH="92%">
<TR>
	<TD VALIGN="top">
	</TD>
		<TD VALIGN="top">

<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="2">
<TR>
	<TD CLASS="tableheader" COLSPAN="100%"><SPAN CLASS="Title2">Search</SPAN><BR>
	</TD>
</TR>
</TABLE>


<CFIF Get_Profile_Settings.Reports_Access_Level GT 0>
	<B><FONT COLOR="Red">Go <A HREF="/settings/index2.cfm">here</A> to manage the status, priorities, phases, sponsors and functional area lists.</FONT></B>
</CFIF>





<!--- Include the queries used by the lookup tables --->
<CFINCLUDE TEMPLATE="PM_lookup_tables.cfm">


<CFFORM method="POST" action="PM_display.cfm" NAME="MyForm">

<TABLE border="0" cellspacing="3" cellpadding="1">


	<TR>		
		<TD COLSPAN="3">
		<B>Project:</B><BR>
			<INPUT type="text" name="PM_Acct_Project" size="103">&nbsp;
		</TD>
		<TD><B>CER/Acct Number:</B><BR>
			<INPUT type="text" name="PM_CER" SIZE="48">
		</TD>		
	</TR>
	<TR>
		<TD COLSPAN="2">
			<B>Sponsor:</B><BR>
			<SELECT size="1" name="PM_Sponsor_ID" CLASS="dropdown">
				<OPTION VALUE="">All Sponsors</OPTION>
				<CFOUTPUT QUERY="Get_Sponsor"><OPTION VALUE="#PM_Sponsor_ID#">#PM_Sponsor_Name_First# #PM_Sponsor_Name_Last#</OPTION></CFOUTPUT>
			</SELECT>

		</TD>
		<TD>
			<!------<B>Owner:</B><BR>
			<SELECT size="1" name="PM_Owner_ID" CLASS="dropdown">
				<OPTION VALUE="">All Owners</OPTION>
				<CFOUTPUT QUERY="Get_Owners"><OPTION VALUE="#User_ID#">#Name_First# #Name_Last#</OPTION></CFOUTPUT>
			</SELECT>----->
			<B>Owner Position:</B><BR>
			<SELECT size="1" name="PM_Position_ID" CLASS="dropdown">
				<OPTION VALUE="">All Owners</OPTION>
				<CFOUTPUT QUERY="Get_Positions"><OPTION VALUE="#User_Positions_ID#">#Position_Label#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
		<!------<TD>
			<!------<B>Broker Name:</B><BR>
			<INPUT type="text" name="PM_Broker" SIZE="25">----->
		</TD>----->
		<TD>
			<B>Functional Area Responsible:</B><BR>
			<SELECT size="1" name="PM_FAR_ID" CLASS="dropdown">
				<OPTION VALUE="">All Areas</OPTION>
				<CFOUTPUT QUERY="Get_FAR"><OPTION VALUE="#PM_FAR_ID#">#PM_FAR_Description#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			<B>Priority:</B><BR>
			<SELECT size="1" name="PM_Priority_ID"  CLASS="dropdown">
				<OPTION VALUE="">All Priorities</OPTION>
				<CFOUTPUT QUERY="Get_Priority"><OPTION VALUE="#PM_Priority_ID#">#PM_Priority_Description#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
		<TD ROWSPAN="2">
			<B>Status:</B><BR>
			<SELECT size="3" name="PM_Status_ID" CLASS="dropdown" MULTIPLE>
				<OPTION VALUE="">All Status</OPTION>
				<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#PM_Status_ID#">#PM_Status_Description#</OPTION></CFOUTPUT>
			</SELECT>
			<BR>
			<FONT COLOR="#FF0000" SIZE="1"><B>* Hold ctrl and click to select multiple status</B></FONT>
		</TD>
		<TD>
			<B>Phase:</B><BR>
			<SELECT size="1" name="PM_Phase_ID" CLASS="dropdown">
				<OPTION VALUE="">All Phases</OPTION>
				<CFOUTPUT QUERY="Get_Phase"><OPTION VALUE="#PM_Phase_ID#">#PM_Phase_Description#</OPTION></CFOUTPUT>
			</SELECT>
		</TD>
	</TR>
	<TR VALIGN="top">
		
		<!------<TD>
			<B>QBrands:</B><BR>
			<SELECT size="1" name="PM_QBrands_ID" CLASS="dropdown">
				<OPTION VALUE="">All Qbrands</OPTION>
				<CFOUTPUT QUERY="Get_QBrands2"><OPTION VALUE="#q_brand_id#">#q_brand#</OPTION></CFOUTPUT>
			</SELECT>

		</TD>----->
		
		<TD>
			<B>Timeline:</B> (From - To)<BR>
			<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="PM_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="">
		</TD>
		<TD>

			<!------<SELECT size="1" name="PM_Start_Date" CLASS="dropdown">
				<OPTION VALUE="">From Any Period</OPTION>
				<CFOUTPUT QUERY="Get_Fiscal_Calendar"><OPTION VALUE="#Start_Date#">#dateformat(Start_Date, 'm/d/yy')# - #dateformat(End_date, 'm/d/yy')#</OPTION></CFOUTPUT>
			</SELECT>
			<SELECT size="1" name="PM_End_Date" CLASS="dropdown">
				<OPTION VALUE="">To Any Period</OPTION>
				<CFOUTPUT QUERY="Get_Fiscal_Calendar"><OPTION VALUE="#End_date#">#dateformat(Start_Date, 'm/d/yy')# - #dateformat(End_date, 'm/d/yy')#</OPTION></CFOUTPUT>
			</SELECT>----->
			
			<BR>	
			<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="PM_End_Date" FORMAT="mm/dd/yyyy" DEFAULT="">

<!--- 
			<INPUT type="text" name="PM_Start_Period" size="9">
			<INPUT type="text" name="PM_Eding_Period" size="9">
 --->
			
		</TD>
		<TD>
			<cfoutput><B>#application.returned_customer_setting.broker_label_singular#:</B><BR></cfoutput>
			<CFQUERY NAME="GetBrokers" DATASOURCE="#application.datasource#">
			SELECT 	BSA_Foodservice_Brokers_ID, Broker_Name
			--FROM 	broker_active
			FROM 	broker_lob_active
			WHERE 	
					len(Broker_Name) > 0
			ORDER BY Broker_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
			<SELECT NAME="Broker_ID" CLASS="dropdown">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.broker_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker_ID) EQ GetBrokers.BSA_Foodservice_Brokers_ID, DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
			</SELECT>			
		</TD>
	</TR>

	<TR>
		<TD COLSPAN="2">
			<B>Value lbs:</B><BR>
			<SELECT size="1" name="PM_Value_Pounds_Filter">
				<OPTION VALUE="">Any</OPTION>
				<OPTION VALUE="=">=</OPTION>
				<OPTION VALUE=">">></OPTION>
				<OPTION VALUE="<"><</OPTION>
				<OPTION VALUE=">=">>=</OPTION>
				<OPTION VALUE="<="><=</OPTION>
				<OPTION VALUE="<>"><></OPTION>
			</SELECT>
			<INPUT TYPE="Text" NAME="PM_Value_Pounds" SIZE="38" onKeyUp="clenseText(this, '0123456789.');">
		</TD>
		<TD>
			<B>Value $:</B><BR>
			<SELECT size="1" name="PM_Value_Dollars_Filter">
				<OPTION VALUE="">Any</OPTION>
				<OPTION VALUE="=">=</OPTION>
				<OPTION VALUE=">">></OPTION>
				<OPTION VALUE="<"><</OPTION>
				<OPTION VALUE=">=">>=</OPTION>
				<OPTION VALUE="<="><=</OPTION>
				<OPTION VALUE="<>"><></OPTION>
			</SELECT>
			<INPUT TYPE="Text" NAME="PM_Value_Dollars" SIZE="38" onKeyUp="clenseText(this, '0123456789.');">
		</TD>
		 <TD>
			<B>Resources:</B><BR>
			<INPUT type="text" name="PM_Resources" SIZE="48">
		</TD> 
	</TR>
	<TR>
		<TD COLSPAN="2">
			<B>Budget $:</B><BR>
			<SELECT size="1" name="PM_Ext_Budget_Filter">
				<OPTION VALUE="">Any</OPTION>
				<OPTION VALUE="=">=</OPTION>
				<OPTION VALUE=">">></OPTION>
				<OPTION VALUE="<"><</OPTION>
				<OPTION VALUE=">=">>=</OPTION>
				<OPTION VALUE="<="><=</OPTION>
				<OPTION VALUE="<>"><></OPTION>
			</SELECT>
			<INPUT TYPE="Text" NAME="PM_Ext_Budget" SIZE="38" onKeyUp="clenseText(this, '0123456789.');">
		</TD> 
		<TD>
			<B>Actual $:</B><BR>
			<SELECT size="1" name="PM_Actual_Filter">
				<OPTION VALUE="">Any</OPTION>
				<OPTION VALUE="=">=</OPTION>
				<OPTION VALUE=">">></OPTION>
				<OPTION VALUE="<"><</OPTION>
				<OPTION VALUE=">=">>=</OPTION>
				<OPTION VALUE="<="><=</OPTION>
				<OPTION VALUE="<>"><></OPTION>
			</SELECT>
			<INPUT TYPE="Text" NAME="PM_Actual" onKeyUp="clenseText(this, '0123456789.');" SIZE="38">
		</TD>
		<TD>
			<B>Support:</B><BR>
			<INPUT type="text" name="PM_Support" SIZE="48">
		</TD>
	</TR>

	<TR>
		<TD COLSPAN="100%">
			
			<HR COLOR="Orange">
			
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
				<TR>
					<TD>
						<B>Sort by:</B><BR>
						<SELECT size="1" name="Sort_By" STYLE="width:155px;">
							<OPTION VALUE="PM_Item_Master.PM_Acct_Project">Project Name</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_CER">CER/Acct Number</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Sponsor_ID">Sponsor Name</OPTION>
							<!------<OPTION VALUE="PM_Item_Master.PM_Owner">Owner Name</OPTION>----->
							<OPTION VALUE="PM_Item_Master.PM_Position_ID">Owner Position</OPTION>
							<!------<OPTION VALUE="PM_Item_Master.PM_Broker">Broker Name</OPTION>----->
							<OPTION VALUE="PM_Item_Master.PM_Priority_ID">Priority</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Status_ID">Status</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Phase_ID">Phase</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_FAR_ID">Functional Area</OPTION>
							<!------<OPTION VALUE="PM_Item_Master.PM_QBrands_ID">QBrands</OPTION>----->
							<OPTION VALUE="PM_Item_Master.PM_Start_Date">Start Date</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_End_Date">End Date</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Value_Pounds">Value lbs.</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Value_Dollars">Value $</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Resources">Resources $</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Support">Support $</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Ext_Budget">Ext. Budget $</OPTION>
							<OPTION VALUE="PM_Item_Master.PM_Actual">Actual $</OPTION>
						</SELECT>
					</TD>
					<TD>
						<B>Order:</B><BR>
						<SELECT size="1" name="Sort_Order" STYLE="width:155px;">
							<OPTION VALUE="Asc">Ascending Order</OPTION>
							<OPTION VALUE="Desc">Descending Order</OPTION>
						</SELECT>
					</TD>
					<TD>
						<B>Records/page</B><BR>
						<SELECT size="1" name="maxrows" STYLE="width:155px;">
							<OPTION VALUE="5">5 records per page</OPTION>
							<OPTION VALUE="10" selected>10 records per page</OPTION>
							<OPTION VALUE="20">20 records per page</OPTION>
							<OPTION VALUE="50">50 records per page</OPTION>
							<OPTION VALUE="100">100 records per page</OPTION>
						</SELECT>
					</TD>
					<TD>
						<B>Select view:</B><BR>
						<SELECT size="1" name="view" STYLE="width:155px;">
							<OPTION VALUE="0">Summary view</OPTION>
							<OPTION VALUE="1">Detailed view</OPTION>
						</SELECT>
					</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
</TABLE>

<BR><BR>


<B>
<FONT COLOR="Red">[</FONT>
<A HREF="javascript: document.MyForm.submit()">search projects</A>
<FONT COLOR="Red">]</FONT>
&nbsp;&nbsp;
<FONT COLOR="Red">[</FONT>
<A HREF="javascript: MyForm.reset()">reset settings</A>
<FONT COLOR="Red">]</FONT>
&nbsp;&nbsp;
<FONT COLOR="Red">[</FONT>
<A HREF="PM_create.cfm">create new project</A>
<FONT COLOR="Red">]</FONT>
</B>

</CFFORM>

<BR><BR>




	
	</TD>
</TR>
</TABLE>


</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT LANGUAGE="JavaScript">
findselectboxes();
</SCRIPT>
</BODY>
</HTML>



