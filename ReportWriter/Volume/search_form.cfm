<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Volume Search</title>
<STYLE>
	.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
</STYLE>
<script language="javascript">
 function CheckValid()
 {
 if(document.all.SearchForm.Service_Zone_ID.options[document.all.SearchForm.Service_Zone_ID.selectedIndex].value =='0' 
 && document.all.SearchForm.Service_Region_ID.options[document.all.SearchForm.Service_Region_ID.selectedIndex].value  =='0'
 && document.all.SearchForm.Service_Market_ID.options[document.all.SearchForm.Service_Market_ID.selectedIndex].value  =='0'
 && document.all.SearchForm.Broker_ID.options[document.all.SearchForm.Broker_ID.selectedIndex].value  =='0'
 && document.all.Distributor_shipto.value =='' && document.all.Distributor_Name.value =='')
 {
 alert("You must choose at least one criteria");
 return false;
 }
	
 else
 {
  
	for(i=0; i< SearchForm.DateType.length; i++)
	{
		if(SearchForm.DateType[i].checked == true && SearchForm.DateType[i].value == "OtherPeriod" && SearchForm.Distributor_Name_For_Fiscal_Year.value == "")
		{
			alert("You must choose a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> with the Other Period search option");
			 return false;
		}	
	}
 	SearchForm.submit();
 }
 }
 

function showDistSearchWindow() 
{	
	document.SearchForm.target = "_self";
	document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
	NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchForm", "searchform", 800, 600, "yes", "yes")
}

 
</script>
</head>
<!---
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
--->
<cfparam Name="ErrorMessage" default="">
<cfparam Name="FORM.Distributor_List" default="">
<cfparam Name="Selected_Distributor" default="">
<cfparam Name="FORM.rReportType" 	default="h">
<cfparam Name="FORM.DateType" 	default="FiscalPeriod">

		<CFIF FORM.Distributor_List NEQ "">
			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name 
				FROM BSA_Foodservice_Customers 
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#'
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
		<CFSET Selected_Distributor=Dist_Search_Result.Name>
		</CFIF>
		
		
		<CFIF FORM.Distributor_List NEQ "">
			<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name 
				FROM BSA_Foodservice_Customers 
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#'
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
		<CFSET Selected_Distributor=Dist_Search_Result.Name>
		</CFIF>
		
<body>
<form name="SearchForm" action="sales_comparison.cfm" method="post">
<table>

		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead"><strong>Search Criteria</strong></TD>
		</TR>
		<TR>	
			<TD>&nbsp;</TD>		
			<TD>
			<cfoutput><span ID="searchItemLabel"><B><!--- #application.returned_customer_setting.zone_label_singular# ---></B></span><BR></cfoutput>
			<CFQUERY NAME="GetZones" DATASOURCE="#application.datasource#">
			SELECT Service_Zone_ID, Zone_Name
			FROM Service_Zones
			WHERE Deleted = 0
			AND len(Zone_Name) > 0
			ORDER BY Zone_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Zone_ID" DEFAULT="0">
			<SELECT NAME="Service_Zone_ID">
				<cfoutput><OPTION VALUE="0">**ALL** <!---#application.returned_customer_setting.zone_label_plural#---></OPTION></cfoutput>
				<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(Service_Zone_ID)#"#IIF(trim(FORM.Service_Zone_ID) EQ Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(Zone_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>	
			<TD>
			<cfoutput><span ID="searchItemLabel"><B> <!---#application.returned_customer_setting.region_label_singular#---> </B></span><BR></cfoutput>
			<CFQUERY NAME="GetRegions" DATASOURCE="#application.datasource#">
			SELECT Service_Region_ID, Region_Name
			FROM Service_Regions
			WHERE Deleted = 0
			AND len(Region_Name) > 0
			ORDER BY Region_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="0">
			<SELECT NAME="Service_Region_ID">
				<cfoutput><OPTION VALUE="0">**ALL** <!---#application.returned_customer_setting.region_label_plural# ---></OPTION></cfoutput>
				<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Service_Region_ID) EQ Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B><!---#application.returned_customer_setting.market_label_singular#---></B></span><BR></cfoutput>
			<CFQUERY NAME="GetMarkets" DATASOURCE="#application.datasource#">
			SELECT Service_Market_ID, Market_Name
			FROM Service_Markets
			WHERE Deleted = 0
			AND len(Market_Name) > 0
			ORDER BY Market_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Market_ID" DEFAULT="0">
			<SELECT NAME="Service_Market_ID">
				<cfoutput><OPTION VALUE="0">**ALL** <!---#application.returned_customer_setting.market_label_plural# ---></OPTION></cfoutput>
				<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Service_Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B><!---#application.returned_customer_setting.broker_label_singular# ---></B></span><BR></cfoutput>
			<CFQUERY NAME="GetBrokers" DATASOURCE="#application.datasource#">
			SELECT BSA_Foodservice_Brokers_ID, Broker_Name
			FROM broker_active
			WHERE len(Broker_Name) > 0

			ORDER BY Broker_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
			<SELECT NAME="Broker_ID">
				<cfoutput><OPTION VALUE="0">**ALL** <!---#application.returned_customer_setting.broker_label_plural#---></OPTION></cfoutput>
				<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker_ID) EQ GetBrokers.BSA_Foodservice_Brokers_ID, DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
		</TR>
	</table>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Selection options --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<br/>
<br/>
<CFOUTPUT>
	
<TABLE border="0">

		<TR VALIGN="TOP">	
			<TD ROWSPAN="2">&nbsp;</TD>
			<TD>
			<span ID="searchItemLabel"><B> <!---#application.returned_customer_setting.distributor_label_singular# --->Name</B></span><BR>
			<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
			<SPAN ID="SP_Distributor_Name">
			<INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#Selected_Distributor#" style="background-color: ##E9E9E9" READONLY>
			</SPAN>
			</TD>
			<TD VALIGN="BOTTOM">
			 <a href="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif"></a>
			</TD>
			
			<TD VALIGN="MIDDLE">
			<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript: document.all.SearchForm.Distributor_Name.value=''">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
			<TD>
			<span ID="searchItemLabel"><B> <!---#application.returned_customer_setting.distributor_label_singular# #application.returned_customer_setting.shard_ship_to_label#---></B></span><BR>
			<CFPARAM NAME="FORM.Distributor_shipto" DEFAULT="">
			<SPAN ID="SP_Distributor_shipto">
			<INPUT NAME="Distributor_shipto" ID="Distributor_shipto" VALUE="#FORM.Distributor_shipto#">
			</SPAN>
			</TD>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B>Starting Date:</B>&nbsp;&nbsp;
			<CFPARAM NAME="FORM.Start_date" DEFAULT="">
			<SPAN ID="SP_Start_date">
<!--- Call the "EASYDATE" custom tag for the calendar --->
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
			</SPAN>
		</TD>
		<TD><B>Ending Date:</B>&nbsp;&nbsp;
			<CFPARAM NAME="FORM.End_date" DEFAULT="">
			<SPAN ID="SP_End_date">
<!--- Call the "EASYDATE" custom tag for the calendar --->
			<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
			</SPAN>
		</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
	</TR>
	

	<TR valign="bottom">
		<!---- report output type (email notification or direct---->
		<TD colspan="3">
			<strong>Output Type:</strong>
			<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="h"<cfif Form.rReportType EQ "h"> CHECKED</cfif>>HTML
			<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="e"<cfif Form.rReportType EQ "e"> CHECKED</cfif>>Excel
			<!---
			<INPUT TYPE="radio" ID="rReportType" NAME="rReportType" VALUE="c"<cfif rReportType EQ "c"> CHECKED</cfif>>CSV
			--->
		</TD>
		<TD colspan="3" align="center">
		<strong>Date Type:</strong>
		<input type="radio" name="DateType" value="FiscalPeriod" <cfif Form.DateType EQ "FiscalPeriod"> CHECKED</cfif>>Fiscal Period
		<input type="radio" name="DateType" value="CalendarPeriod" <cfif Form.DateType EQ "CalendarPeriod"> CHECKED</cfif>>Calendar Period
		<input type="radio" name="DateType" value="OtherPeriod" <cfif Form.DateType EQ "OtherPeriod"> CHECKED</cfif> OnClick="window.open('search_period_settings.cfm', 'blank','width=650,height=350')">Other
		</TD>
		<!---- report output type (email notification or direct)---->
		<!---
		<TD>&nbsp;</TD>
		<TD colspan="3">
			<strong>Method:</strong>
			<INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="email_notification"<cfif FORM.rReportOutputType EQ "email_notification"> CHECKED</cfif>>Email Notification
		<INPUT TYPE="radio" ID="rReportOutputType" NAME="rReportOutputType" VALUE="direct"<cfif FORM.rReportOutputType EQ "direct"> CHECKED</cfif>>Direct
		</TD>
		--->
		<TD  colspan="2">
			<CFPARAM NAME="Form.Distributor_Name_For_Fiscal_Year" DEFAULT="">
			<CFPARAM NAME="Form.Distributor_ID_For_Fiscal_Year" DEFAULT="">
			<input type="text" name="Distributor_Name_For_Fiscal_Year" value="#FORM.Distributor_Name_For_Fiscal_Year#">
		</TD>
		<TD valign="bottom">
			<B><FONT COLOR="red">[</FONT> <A HREF="##" ONCLICK="return CheckValid();">run report</A> <FONT COLOR="red">]</FONT></B>
	    </TD>
		
	</tr>
	<cfif ErrorMessage neq "">
	<TR>
		<TD colspan="9" align="center" style='font-family:verdana,arial,,helvetica;
	font-size:11px;color:red'>#ErrorMessage#</span></TD>
	</TR>
	</cfif>
</TABLE>
	</CFOUTPUT>	
	
		<cfoutput>
		<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
		<INPUT TYPE="Hidden" ID="Distributor_ID_For_Fiscal_Year" NAME="Distributor_ID_For_Fiscal_Year" VALUE="#Distributor_ID_For_Fiscal_Year#">
		</cfoutput>
</form>
</body>
</html>
