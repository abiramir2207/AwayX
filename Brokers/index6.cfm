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



<!--- Get the broker plan data --->
<cfset useLakebaseForGetPlanData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan")>
<cfif useLakebaseForGetPlanData>
	<cftry>
		<cfset Get_Plan_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_action_plan", { "broker_action_plan_id" = "eq.#APID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetPlanData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPlanData>
	<CFQUERY NAME="Get_Plan_Data" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 24, 0, 0)#">
		Select	*
		From	Broker_Action_Plan
		Where	Broker_Action_Plan_ID	=	#APID#
	</CFQUERY>
</cfif>

<!--- Get the name of the operator --->
<CFQUERY NAME="Get_Operator_Name" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 24, 0, 0)#">
	Select		Operator_Name
	From		BSA_Operator
	Where		BSA_Operator_ID	=	#Get_Plan_Data.BSA_Operator_ID#
</CFQUERY>

<!--- Get the name of the user that created this broker plan --->
<CFQUERY NAME="Get_User_Name" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 24, 0, 0)#">
	Select		Name_First,
				Name_Last
	From		_Users
	Where		User_ID	=	'#Get_Plan_Data.User_ID#'
</CFQUERY>

<!--- Get the product data --->
<cfset useLakebaseForGetProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("broker_action_plan_products")>
<cfif useLakebaseForGetProducts>
	<cftry>
		<cfset Get_Products = application.oLakebase.toQuery(
			application.oLakebase.selectRows("broker_action_plan_products", { "broker_action_plan_id" = "eq.#APID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProducts>
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
		Select	*
		From	Broker_Action_Plan_Products
		Where	Broker_Action_Plan_ID	=	#APID#
	</CFQUERY>
</cfif>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FIELDSET STYLE="padding: 5px;">
<legend style="color:Navy; font-weight: bold; font-size: 14px;">Broker Plan</legend>

	<TABLE CLASS="MainTable" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
			<TR VALIGN="bottom" BGCOLOR="FFCE84">
				<TD WIDTH="120"><SPAN CLASS="title2">Plan Number</SPAN></TD>
				<TD WIDTH="350"><SPAN CLASS="title2"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</SPAN></TD>
				<TD WIDTH="150"><SPAN CLASS="title2">Creation Date...</SPAN></TD>
				<TD><SPAN CLASS="title2">Plan created by...</SPAN></TD>
			</TR>
		<CFOUTPUT>
			<TR VALIGN="top">
				<TD>#Get_Plan_Data.Broker_Action_Plan_ID#</TD>
				<TD>#Get_Operator_Name.Operator_Name#</TD>
				<TD>#dateformat(Get_Plan_Data.Date_Created_On, 'mm/dd/yyyy')#</TD>
				<TD>#Get_User_Name.Name_First# #Get_User_Name.Name_Last#</TD>
			</TR>
		</CFOUTPUT>
	</TABLE>

</fieldset>

<BR>









<CFOUTPUT>


#Form.APID#

<BR><BR>

#PRID#

</CFOUTPUT>






</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>


