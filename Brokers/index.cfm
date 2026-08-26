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
<FONT SIZE="3"><B>Step 1: Select the <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput></B></FONT>
<HR SIZE="1" COLOR="silver">



<!--- Previously saved broker plans --->
<cfset useLakebaseForGetBrokerPlans = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan")>
<cfif useLakebaseForGetBrokerPlans>
	<cftry>
		<cfset Get_Broker_Plans = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_action_plan", {
				"select" = "broker_action_plan_id,bsa_operator_id,date_created_on,user_id",
				"order" = "date_created_on.desc"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetBrokerPlans = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokerPlans>
	<CFQUERY NAME="Get_Broker_Plans" datasource="#application.datasource#">
		Select		Broker_Action_Plan_ID,
					BSA_Operator_ID,
					Date_Created_On,
					User_ID
		From		Broker_Action_Plan
		Order by	Date_Created_On desc
	</CFQUERY>
</cfif>




<fieldset style="padding: 5px;">
<legend style="color:Navy; font-weight: bold; font-size: 14px;">Previously saved broker plans</legend>

	<TABLE CLASS="MainTable" CELLPADDING="3" CELLSPACING="0" WIDTH="100%">
			<TR VALIGN="bottom" BGCOLOR="FFCE84">
				<TD><SPAN CLASS="title2">Plan Number</SPAN></TD>
				<TD><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</SPAN></TD>
				<TD><SPAN CLASS="title2">Creation Date...</SPAN></TD>
				<TD><SPAN CLASS="title2">Plan created by...</SPAN></TD>
			</TR>

	<CFLOOP QUERY="Get_Broker_Plans">
	
	<!--- Get the name of the Operator --->
	<CFQUERY NAME="Get_Operator_Name" datasource="#application.datasource#">
		Select		Operator_Name
		From		BSA_Operator
		Where		BSA_Operator_ID	=	#BSA_Operator_ID#
	</CFQUERY>
	
	<!--- Get the name of the user that created this broker plan --->
	<CFQUERY NAME="Get_User_Name" datasource="#application.datasource#">
		Select		Name_First,
					Name_Last
		From		_Users
		Where		User_ID	=	'#User_ID#'
	</CFQUERY>
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Encrypt the ID																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cf_cryp type="en" string ="#Broker_Action_Plan_ID#" key="#request.key#">
<CFSET Action_Plan_ID = cryp.value>

	
		<CFOUTPUT>
			<TR VALIGN="top" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD><A HREF="index5.cfm?ID=#Action_Plan_ID#">#Broker_Action_Plan_ID#</A></TD>
				<TD><A HREF="index5.cfm?ID=#Action_Plan_ID#">#Get_Operator_Name.Operator_Name#</A></TD>
				<TD>#dateformat(Date_Created_On, 'mm/dd/yyyy')#</TD>
				<TD>#Get_User_Name.Name_First# #Get_User_Name.Name_Last#</TD>
			</TR>
		</CFOUTPUT>
	
	</CFLOOP>
	</TABLE>
	

</fieldset>











<SCRIPT>
	var inhibitpopup = true
</SCRIPT>

<CF_GeneralSearchTool
	destination_page		= "/brokers/index2.cfm"
	id						= ""
	selection_option		= "radio"
	result_code_location	= "/profiles/operators/Operator_Search_Action.cfm">



</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


