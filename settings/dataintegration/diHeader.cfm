<CFIF NOT isDefined("DICommon_IncludeFile")>
	<CFINCLUDE template="diCommon.cfm">
</CFIF>
<CFINCLUDE TEMPLATE="diAccessible_Pages.cfm">
<CFPARAM NAME="diThisPage" DEFAULT="#diPage#">
<STYLE TYPE="text/css">
TD.foreground
	{
		border-left :		1px solid #31009C;
		border-right :		1px solid #31009C;
		border-top :		1px solid #31009C;
	}
TD.background
	{
		border-left:		1px solid #FFFFFF;
		border-right:		1px solid #FFFFFF;
		cursor:				pointer;
	}
A.tablink_back
	{
		color: 				#FFFFFF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:VISITED.tablink_back
	{
		color: 				#FFFFFF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:VISITED.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}

</STYLE>

<CFSET BrokersExist=false>
<CFSET DistributorsExist=false>
<CFSET ProductsExist=false>
<CFSET dbBasicInfoExist = false>
<CFSET diLogExist = false>

<!-----------------------------------------
Get DataIntegration Basic Information from database
------------------------------------------>
<CFQUERY NAME="q_Data_Integration_Read" datasource="#application.datasource#">
		Select 		di.Dataint_setting_ID
		From 		DataInt_Settings di
</CFQUERY>

<CFIF q_Data_Integration_Read.recordCount GT 0>
	<CFSET dbBasicInfoExist = true>
</CFIF>
	
<!-----------------------------------------
End - Get DataIntegration Basic Information from database
------------------------------------------>

<!-----------------------------------------
Get DataIntegration Information from database
------------------------------------------>
<cfset useLakebaseForq_Data_Integration_Exists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration")>
<cfif useLakebaseForq_Data_Integration_Exists>
	<cftry>
		<cfset q_Data_Integration_Exists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_integration", {
				"select" = "integration_type"
			}), "integration_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForq_Data_Integration_Exists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForq_Data_Integration_Exists>
<CFQUERY NAME="q_Data_Integration_Exists" datasource="#application.datasource#">
		select distinct Integration_Type
		From Data_Integration
	</CFQUERY>
</cfif>
	
	<cfloop query="q_Data_Integration_Exists">
		<cfswitch expression="#Integration_Type#">
				<cfcase value="Brokers">
					<CFSET BrokersExist=true>
				</cfcase>
				<cfcase value="Distributors">
					<CFSET DistributorsExist=true>
				</cfcase>
				<cfcase value="Products">
					<CFSET ProductsExist=true>
				</cfcase>
		</cfswitch>
</cfloop>
<!-----------------------------------------
End Get DataIntegration Information from database
------------------------------------------>

<!--------------------------------------
Get DILogExist from database
--------------------------------------->
<!-----
<CFOUTPUT>
<CFQUERY NAME="q_DILog_Exists" datasource="#application.datasource#">
select (select count(*) from #ListChangeDelims(logTables, " ) + ( select count(*) from ",",")#) as cnt
</CFQUERY>
</CFOUTPUT>
<CFIF q_DILog_Exists.recordCount GT 0>
	<CFIF q_DILog_Exists.cnt>
		<CFSET diLogExist=true>
	</CFIF>
</CFIF>------->
<!--------------------------------------
End Get DILogExist from database
--------------------------------------->

<CFOUTPUT>
<BR>
<BR>
<TABLE border="0" width="100%" cellspacing="0" cellpadding="2">
<COLGROUP>
<COL SPAN="5" WIDTH="130">
</COLGROUP>
	<TR>
		<CFIF ListFindNoCase(DI_Page_List, "dataIntegrationBasicInfo.cfm", ",")>
		<CFIF diThisPage EQ basicInfoPage>
			<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF dbBasicInfoExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><font CLASS="tablink_fore">basic Info</font></B></TD>
		<CFELSE>
			<A HREF="#basicInfoPage#" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF dbBasicInfoExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#basicInfoPage#" CLASS="tablink_back">basic Info</A></B></TD></A>
		</CFIF>
		</CFIF>
		
		<CFIF ListFindNoCase(DI_Page_List, "dataIntegration.cfm", ",")>
		<CFIF diThisPage EQ diPage>
			<CFIF Integration_Type EQ "Brokers">		
				<TD CLASS="foreground" BGCOLOR="FFFFFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Brokers>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><font CLASS="tablink_fore"><CFOUTPUT>#application.returned_customer_setting.broker_label_plural#</CFOUTPUT></font></B></TD>
			<CFELSE>
				<A HREF="#diPage#?diType=Brokers" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Brokers>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Brokers" CLASS="tablink_back"><CFOUTPUT>#lcase(application.returned_customer_setting.broker_label_plural)#</CFOUTPUT><!--- brokers ---></A></B></TD></A>
			</CFIF>
			<CFIF Integration_Type EQ "Distributors">
				<TD CLASS="foreground" BGCOLOR="FFFFFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Distributors>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><font CLASS="tablink_fore"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></font></B></TD>
			<CFELSE>
				<A HREF="#diPage#?diType=Distributors" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Distributors>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Distributors" CLASS="tablink_back"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></A></B></TD></A>
			</CFIF>
			<CFIF Integration_Type EQ "Products">
				<TD CLASS="foreground" BGCOLOR="FFFFFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Products>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><font CLASS="tablink_fore">products</font></B></TD>		
			<CFELSE>
				<A HREF="#diPage#?diType=Products" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF Products>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Products" CLASS="tablink_back">products</A></B></TD></A>
			</CFIF>	
		<CFELSE>
			<A HREF="#diPage#?diType=Brokers" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF BrokersExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Brokers" CLASS="tablink_back"><CFOUTPUT>#lcase(application.returned_customer_setting.broker_label_plural)#</CFOUTPUT><!--- brokers ---></A></B></TD></A>
			<A HREF="#diPage#?diType=Distributors" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF DistributorsExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Distributors" CLASS="tablink_back"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput></A></B></TD></A>
			<A HREF="#diPage#?diType=Products" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<CFIF ProductsExist>yes<CFELSE>no</CFIF>_small.gif" HSPACE="3"><A HREF="#diPage#?diType=Products" CLASS="tablink_back">products</A></B></TD></A>
		</CFIF>
		</CFIF>
		
		<CFIF ListFindNoCase(DI_Page_List, "diLog.cfm", ",")>
		<CFIF diThisPage EQ diLogPage>
			<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><font CLASS="tablink_fore">Log</font></B></TD>
		<CFELSEIF (diThisPage EQ diLogDetailsPage) OR (diThisPage EQ diLogListPage)>
			<A HREF="#diLogPage#" CLASS="tablink_back"><TD STYLE="CURSOR:POINTER;" CLASS="foreground" BGCOLOR="FFFFFF" ALIGN="center" NOWRAP><B><A HREF="#diLogPage#" CLASS="tablink_fore">Log</A></B></TD></A>
		<CFELSE>
			<A HREF="#diLogPage#" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><A HREF="#diLogPage#" CLASS="tablink_back">Log</A></B></TD></A>
		</CFIF>
		</CFIF>
		
		<CFIF ListFindNoCase(DI_Page_List, "di_Weekly_Log.cfm", ",")>
		<CFIF diThisPage EQ "Weekly_Log">
			<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><font CLASS="tablink_fore">Weekly Log</font></B></TD>
		<CFELSEIF diThisPage EQ "Weekly_Log_Details">
			<A HREF="di_Weekly_Log.cfm" CLASS="tablink_back"><TD STYLE="CURSOR:POINTER;" CLASS="foreground" BGCOLOR="FFFFFF" ALIGN="center" NOWRAP><B><A HREF="di_Weekly_Log.cfm" CLASS="tablink_fore">Weekly Log</A></B></TD></A>
		<CFELSE>
			<A HREF="di_Weekly_Log.cfm" CLASS="tablink_back"><TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><A HREF="di_Weekly_Log.cfm" CLASS="tablink_back">Weekly Log</A></B></TD></A>
		</CFIF>
		</CFIF>
		
		<TD WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
</TABLE>
<BR>
</CFOUTPUT>
