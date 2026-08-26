<cfsilent>
<cfif isDefined("form.Show_Step")>
	<cfset url.Show_Step = form.Show_Step>
</cfif>

<CFSET URL.PageTitle="Deductions: Manage Deduction Assignment">

<cfset useLakebaseForDecide_Location = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_assignment")>
<cfif useLakebaseForDecide_Location>
	<cftry>
		<cfset Decide_Location = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_assignment", {
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDecide_Location = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDecide_Location>
<CFQUERY NAME="Decide_Location" DATASOURCE="#Application.Datasource#">
	SELECT Top 1 * FROM DD_Assignment WHERE Deleted=0
</CFQUERY>
</cfif>
<CFIF Decide_Location.recordcount GT 0>
	<CFPARAM NAME="URL.Show_Step" DEFAULT="1">
<CFELSE>
	<CFPARAM NAME="URL.Show_Step" DEFAULT="2">
</CFIF>
<cfset useLakebaseForAnalyst_Exist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForAnalyst_Exist>
	<cftry>
		<cfset Analyst_Exist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForAnalyst_Exist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAnalyst_Exist>
<CFQUERY NAME="Analyst_Exist" DATASOURCE="#Application.Datasource#">
	SELECT * FROM DD_Analyst WHERE Deleted = 0 
</CFQUERY>
</cfif>

<!--- Dev Note(71408) If there are no analysts, then the user should be taken to the "supervisor" tab --->
<CFIF Analyst_Exist.recordcount EQ 0>
	<CFIF URL.Show_Step NEQ 2>
		<CFSET URL.Show_Step = 5>
	</CFIF>	
</CFIF>
</cfsilent>

<cfmodule template="/customTags/layout.cfm" 
							layoutID = "deductionAssignment" 
							helpLink = "true"
							selectedIndex = "#(URL.Show_Step - 1)#" >

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!---<CFINCLUDE TEMPLATE="index.cfm"> --->
<input type="Hidden" name="BBAssignmentByTemplate" id="BBAssignmentByTemplate" value="#val(appSettings.get_Setting('BB_Assignment_By_Template'))#" />
<CFIF URL.Show_Step EQ 1>
	<CFINCLUDE TEMPLATE="View_Assignment.cfm">
<CFELSEIF URL.Show_Step EQ 2>
	<CFINCLUDE TEMPLATE="Ass_Pick_Analyst.cfm">	
<CFELSEIF URL.Show_Step EQ 3>
	<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>	
		<CFINCLUDE TEMPLATE="Pop_Analyst.cfm">
	<CFELSE>
		<CFINCLUDE TEMPLATE="Ass_Pick_Market.cfm">	
	</CFIF>
<CFELSEIF URL.Show_Step EQ 4>
	<CFIF appSettings.getDDAssignmentBasedOnShrShipto()>
		<CFINCLUDE TEMPLATE="Assign_Ship_to.cfm">
	<CFELSE>
		<CFINCLUDE TEMPLATE="Ass_Pick_Customer.cfm">
	</CFIF>	
<CFELSEIF URL.Show_Step EQ 5>
	<CFINCLUDE TEMPLATE="Assign_Supervisor.cfm">	
<CFELSEIF URL.Show_Step EQ 6>
	<CFINCLUDE TEMPLATE="Pop_Analyst.cfm">
<CFELSEIF URL.Show_Step EQ 7>
	<CFINCLUDE TEMPLATE="Pick_Supervisor_For_Analyst.cfm">
</CFIF>

<!---
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">	
	<TR>
		<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><CFIF Analyst_Exist.recordcount GT 0><A HREF="View_Assignment.cfm">view</A><CFELSE>view</CFIF><B><FONT COLOR="red" SIZE="2"> ]</FONT><BR><BR></TD>
	</TR>
	<TR>
		<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="/deductions/Assignment/Ass_Pick_Analyst.cfm">pick analyst</A><FONT COLOR="red" SIZE="2"> ]</FONT></B><BR><BR></TD>
	</TR>
	<TR>
		<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><CFIF Analyst_Exist.recordcount GT 0><A HREF="/deductions/Assignment/Ass_Pick_Market.cfm">assign market</A><CFELSE>assign market</CFIF><FONT COLOR="red" SIZE="2"> ]</FONT></B><BR><BR></TD>
	</TR>
	<TR>
		<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><CFIF Analyst_Exist.recordcount GT 0><A HREF="/deductions/Assignment/Ass_Pick_Customer.cfm">assign customer</A><CFELSE>assign customer</CFIF><FONT COLOR="red" SIZE="2"> ]</FONT></B><BR><BR></TD>
	</TR>
	<TR>
		<TD><B><FONT COLOR="red" SIZE="2">[ </FONT><CFIF Analyst_Exist.recordcount GT 0><A HREF="/deductions/Assignment/Pop_Analyst.cfm?Step=4"onclick="NewWindow(this.href,'Ana','400','500','Yes', 'No');return false;">pick default analyst</A><CFELSE>pick default analyst</CFIF><FONT COLOR="red" SIZE="2"> ]</FONT></B><BR><BR></TD>
	</TR>
</TABLE> --->

</cfmodule>