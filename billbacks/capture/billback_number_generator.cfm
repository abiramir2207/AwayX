<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---																									
An exclusive lock single-threads access to the CFML constructs in its body. Single-threaded access 		
implies that the body of the tag can be executed by at most one request at a time. A request executing	
inside a cflock tag has an "exclusive lock" on the tag. No other requests can start executing inside 	
the tag while a request has an exclusive lock. ColdFusion issues exclusive locks on a first-come, 		
first-served basis. 																					
																									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForAliveUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_master")>
<cfif useLakebaseForAliveUpload>
	<cftry>
		<cfset AliveUpload = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_upload_master", {
				"alive_upload" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAliveUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAliveUpload>
<CFQUERY NAME="AliveUpload" DATASOURCE="#Application.Datasource#">
	SELECT * 
	FROM Billback_Upload_Master 
	WHERE Alive_Upload = 1
</CFQUERY>
</cfif>

<cfset useLakebaseForAliveUpload2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_txt_upload_header")>
<cfif useLakebaseForAliveUpload2>
	<cftry>
		<cfset AliveUpload2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_txt_upload_header", {
				"bb_creation_in_process" = "eq.1",
				"limit" = "1",
				"select" = "billback_txt_upload_header_id"
			}), "billback_txt_upload_header_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAliveUpload2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAliveUpload2>
<CFQUERY NAME="AliveUpload2" DATASOURCE="#Application.Datasource#">
	SELECT TOP 1 Billback_Txt_Upload_Header_ID
	FROM Billback_Txt_Upload_Header 
	WHERE BB_Creation_In_Process = 1
</CFQUERY>
</cfif>

<CFIF AliveUpload.RecordCount EQ 0 AND AliveUpload2.RecordCount EQ 0>
<cflock timeout = "15"> 
	
	<!--- Generate new billback number --->
	<cfstoredproc procedure="generate_billback_number" datasource="#application.datasource#">
		<cfprocparam variable="new_number" type="out" cfsqltype="cf_sql_varchar" />
	</cfstoredproc>
	
	<!------ Format the number  ----->
	<cfset generator_billback_number = CreateObject("component", "components.settings.ApplicationNumberManager").getFormatedBANumber
				(
					number = new_number,
					prefix = application.oApplicationAppSettingsManager.getApplicationAppSettings().getBillbackNumberPrefix()
				) />	
</cflock> 
<CFELSE>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="2">Billback Upload is in process. Please wait for few minutes and try again.</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function redirect()
	{
		window.parent.location.href = "/Manufacturers/home.cfm"; 	
	}
	window.setTimeout('redirect();', 3000);	
	</SCRIPT> 
	<CFABORT>
</CFIF>





