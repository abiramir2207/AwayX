<CFSET PAGE_TITLE = "Company Technology Information">

<CFPARAM NAME="Form.Document_ID" DEFAULT="TechnologyInformation">
<CFPARAM NAME="URL.Company_Main_ID" DEFAULT="">

<cfset useLakebaseForGetCompanyTechnologyInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_technology")>
<cfif useLakebaseForGetCompanyTechnologyInfo>
	<cftry>
		<cfset GetCompanyTechnologyInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_technology", {
				"company_main_id" = "eq.#URL.Company_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCompanyTechnologyInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCompanyTechnologyInfo>
<CFQUERY NAME="GetCompanyTechnologyInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Technology
	WHERE Company_Main_ID = '#URL.Company_Main_ID#'
</CFQUERY>
</cfif>

<CFPARAM NAME="ButtonCaption" DEFAULT="Save Changes">
<CFPARAM NAME="Form.Company_Main_ID" DEFAULT="#URL.Company_Main_ID#">
<CFPARAM NAME="Form.EDI_Version" DEFAULT="#GetCompanyTechnologyInfo.EDI_Version#">
<CFPARAM NAME="Form.EDI_Sets" DEFAULT="#GetCompanyTechnologyInfo.EDI_Sets#">
<CFPARAM NAME="Form.Schedule" DEFAULT="#GetCompanyTechnologyInfo.Schedule#">
<CFPARAM NAME="Form.DB_Platform" DEFAULT="#GetCompanyTechnologyInfo.DB_Platform#">
<CFPARAM NAME="Form.Operating_System" DEFAULT="#GetCompanyTechnologyInfo.Operating_System#">
<CFPARAM NAME="Form.OS_Version" DEFAULT="#GetCompanyTechnologyInfo.Operating_System_Rev#">
<CFPARAM NAME="Form.Email_System" DEFAULT="#GetCompanyTechnologyInfo.Email_System#">
<CFPARAM NAME="Form.Proxy" DEFAULT="#GetCompanyTechnologyInfo.Proxy_Firewall#">

	<CFIF GETCOMPANYTECHNOLOGYINFO.RECORDCOUNT>
		<CFPARAM NAME="Form.HTTP_Port" DEFAULT="#GetCompanyTechnologyInfo.HTTP_Port#">
		<CFPARAM NAME="Form.FTP_Port" DEFAULT="#GetCompanyTechnologyInfo.FTP_Port#">
		<CFPARAM NAME="Form.SMTP_Port" DEFAULT="#GetCompanyTechnologyInfo.SMTP_Port#">
		<CFPARAM NAME="Form.SSL_Port" DEFAULT="#GetCompanyTechnologyInfo.SSL_Port#">
	<CFELSE>
		<CFPARAM NAME="Form.HTTP_Port" DEFAULT="80">
		<CFPARAM NAME="Form.FTP_Port" DEFAULT="21">
		<CFPARAM NAME="Form.SMTP_Port" DEFAULT="25">
		<CFPARAM NAME="Form.SSL_Port" DEFAULT="443">
	</CFIF>

<cfset useLakebaseForGetCompanyInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetCompanyInfo>
	<cftry>
		<cfset GetCompanyInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"company_main_id" = "eq.#URL.Company_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCompanyInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCompanyInfo>
<CFQUERY NAME="GetCompanyInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Main
	WHERE Company_Main_ID ='#URL.Company_Main_ID#'
</CFQUERY>
</cfif>

<cfset useLakebaseForGetDataSamplingRates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_sampliing_rates")>
<cfif useLakebaseForGetDataSamplingRates>
	<cftry>
		<cfset GetDataSamplingRates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("data_sampliing_rates", {
				"order" = "display_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDataSamplingRates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDataSamplingRates>
<CFQUERY NAME="GetDataSamplingRates" datasource="#application.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	SELECT *
	FROM Data_Sampliing_Rates
	ORDER BY Display_Order ASC
</CFQUERY>
</cfif>

<cfset useLakebaseForGetDatabasePlatforms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("database_platforms")>
<cfif useLakebaseForGetDatabasePlatforms>
	<cftry>
		<cfset GetDatabasePlatforms = application.oLakebase.toQuery(
			application.oLakebase.selectRows("database_platforms", {
				"order" = "display_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDatabasePlatforms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDatabasePlatforms>
<CFQUERY NAME="GetDatabasePlatforms" datasource="#application.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	SELECT *
	FROM Database_Platforms
	ORDER BY Display_Order ASC
</CFQUERY>
</cfif>

<cfset useLakebaseForGetOperatingSystems = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operating_systems")>
<cfif useLakebaseForGetOperatingSystems>
	<cftry>
		<cfset GetOperatingSystems = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operating_systems", {
				"order" = "display_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetOperatingSystems = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetOperatingSystems>
<CFQUERY NAME="GetOperatingSystems" datasource="#application.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	SELECT *
	FROM Operating_Systems
	ORDER BY Display_Order ASC
</CFQUERY>
</cfif>

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<SCRIPT>
	function ChangePortBoxStatus(checkBoxObject, portBoxObject, defaultPort){
		if(checkBoxObject.checked){
			eval("document.all."+portBoxObject+".value = 'N/A'")
			eval("document.all."+portBoxObject+".readOnly = true")
		}
		else{
			eval("document.all."+portBoxObject+".value ="+defaultPort)
			eval("document.all."+portBoxObject+".readOnly = false")
		}
	}
</SCRIPT>
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>

	<DIV CLASS="page_instructions" ALIGN="left">Please Enter the Appropiate Technology Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">
	
<FORM ACTION="UpdateActions.cfm" METHOD="post" NAME="CompanyTech" ID="CompanyTech">
<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="<CFOUTPUT>#Form.Document_ID#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Company_Main_ID" ID="Company_Main_ID" VALUE="<CFOUTPUT>#URL.Company_Main_ID#</CFOUTPUT>">

<CFIF isdefined("URL.RTS")>
	<INPUT TYPE="hidden" NAME="RTS" ID="RTS" VALUE="1">
</CFIF>
			<DIV ALIGN="center">
			<FIELDSET CLASS="fieldset">
			<LEGEND ALIGN="left" CLASS="legend"><CFOUTPUT>#GetCompanyInfo.Company_Name#</CFOUTPUT> - Technology Information</LEGEND>
				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="0" CELLPADDING="3" BORDERCOLORDARK="#000000" ALIGN="left">
					<TR>
						<TD ALIGN="right">EDI Version</TD>
						<TD><INPUT TYPE="text" NAME="EDI_Version" ID="EDI_Version" VALUE="<CFOUTPUT>#Form.EDI_Version#</CFOUTPUT>"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">EDI Sets</TD>
						<TD><INPUT TYPE="text" NAME="EDI_Sets" ID="EDI_Sets" VALUE="<CFOUTPUT>#Form.EDI_Sets#</CFOUTPUT>"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Schedule</TD>
						<TD>
							<SELECT NAME="Schedule">
								<CFOUTPUT QUERY="GetDataSamplingRates">
									<OPTION VALUE="#GetDataSamplingRates.Data_Sampling_Rate_ID#"<CFIF FORM.SCHEDULE EQ GETDATASAMPLINGRATES.DATA_SAMPLING_RATE_ID>SELECTED</CFIF>>#GetDataSamplingRates.Data_Sampling_Rate_Desc#</OPTION>
								</CFOUTPUT>	
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Database Platform</TD>
						<TD>
							<SELECT NAME="DB_Platform">
								<CFOUTPUT QUERY="GetDatabasePlatforms">
									<OPTION VALUE="#GetDatabasePlatforms.Database_Platform_ID#"<CFIF FORM.DB_PLATFORM EQ GETDATABASEPLATFORMS.DATABASE_PLATFORM_ID>SELECTED</CFIF>>#GetDatabasePlatforms.Database_Platform_Desc#</OPTION>
								</CFOUTPUT>	
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Operating System</TD>
						<TD>
							<SELECT NAME="Operating_System">
								<CFOUTPUT QUERY="GetOperatingSystems">
									<OPTION VALUE="#GetOperatingSystems.Operating_System_ID#"<CFIF FORM.OPERATING_SYSTEM EQ GETOPERATINGSYSTEMS.OPERATING_SYSTEM_ID>SELECTED</CFIF>>#GetOperatingSystems.Operating_System_Desc#</OPTION>
								</CFOUTPUT>
								
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Operating System Version</TD>
						<TD><INPUT TYPE="text" NAME="OS_Version" ID="OS_Version" VALUE="<CFOUTPUT>#Form.OS_Version#</CFOUTPUT>"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">E-Mail System</TD>
						<TD><INPUT TYPE="text" NAME="Email_System" ID="Email_System" VALUE="<CFOUTPUT>#Form.Email_System#</CFOUTPUT>"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Proxy or Firewall</TD>
						<TD>
								<INPUT TYPE="radio" NAME="Proxy" VALUE="1"<CFOUTPUT>#IIF(Form.Proxy EQ 1, DE("CHECKED"), DE(""))#</CFOUTPUT>>Yes<INPUT TYPE="radio" NAME="Proxy" VALUE="0"<CFOUTPUT>#IIF(Form.Proxy EQ 0 OR Form.Proxy EQ "", DE("CHECKED"), DE(""))#</CFOUTPUT>>No
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">HTTP Support:</TD>
						<TD><INPUT TYPE="text" NAME="HTTP_Port" ID="HTTP_Port" SIZE="4" VALUE="<CFOUTPUT>#Form.HTTP_Port#</CFOUTPUT>"<CFIF ISNUMERIC(FORM.HTTP_PORT) EQ 0>READONLY</CFIF>><INPUT TYPE="checkbox" NAME="HTTP_Suppport" ONCLICK="ChangePortBoxStatus(this, 'HTTP_Port', '80')" <CFIF ISNUMERIC(FORM.HTTP_PORT) EQ 0>CHECKED</CFIF>>No HTTP Support<BR>(Default:80)</TD>
					</TR>
					<TR>
						<TD ALIGN="right">FTP on Port:</TD>
						<TD><INPUT TYPE="text" NAME="FTP_Port" ID="FTP_Port" SIZE="4" VALUE="<CFOUTPUT>#Form.FTP_Port#</CFOUTPUT>"<CFIF ISNUMERIC(FORM.FTP_PORT) EQ 0>READONLY</CFIF>><INPUT TYPE="checkbox" NAME="HTTP_Suppport" ONCLICK="ChangePortBoxStatus(this, 'FTP_Port', '21')" <CFIF ISNUMERIC(FORM.FTP_PORT) EQ 0>CHECKED</CFIF>>No FTP Support<BR>(Default:21)</TD>
					</TR>
					<TR>
						<TD ALIGN="right">SMTP on Port:</TD>
						<TD><INPUT TYPE="text" NAME="SMTP_Port" ID="SMTP_Port" SIZE="4" VALUE="<CFOUTPUT>#Form.SMTP_Port#</CFOUTPUT>"<CFIF ISNUMERIC(FORM.SMTP_PORT) EQ 0>READONLY</CFIF>><INPUT TYPE="checkbox" NAME="SMTP_Suppport" ONCLICK="ChangePortBoxStatus(this, 'SMTP_Port', '25')" <CFIF ISNUMERIC(FORM.SMTP_PORT) EQ 0>CHECKED</CFIF>>No SMTP Support<BR>(Default:25)</TD>
					</TR>
					<TR>
						<TD ALIGN="right">SSL on Port:</TD>
						<TD><INPUT TYPE="text" NAME="SSL_Port" ID="SSL_Port" SIZE="4" VALUE="<CFOUTPUT>#Form.SSL_Port#</CFOUTPUT>"<CFIF ISNUMERIC(FORM.SSL_PORT) EQ 0>READONLY</CFIF>><INPUT TYPE="checkbox" NAME="SSL_Suppport" ONCLICK="ChangePortBoxStatus(this, 'SSL_Port', '443')" <CFIF ISNUMERIC(FORM.SSL_PORT) EQ 0>CHECKED </CFIF>>No SSL Support<BR>(Default:443)</TD>
					</TR>

				</TABLE>
			</fieldset>
			</DIV>
	<BR>
	<DIV ALIGN="center">
	<CF_button
		button_caption	=	"#ButtonCaption#"
		button_type	=	"submit"
		button_width	=	""
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"13"
		font_weight		=	"bold"
	>
	</DIV>
</FORM>

</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
