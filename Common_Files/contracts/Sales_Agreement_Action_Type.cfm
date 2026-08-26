<script language="javascript">
function Close_Window(){
	self.close();
	}
</script>

<cfparam name="ActionType" default="">

<cfoutput>
<!--- On Print request --->
<cfif ActionType eq "PrintProgram">
<a href="/common_files/contracts/sales_agreement_printer_friendly.cfm?id=#id#&bgimage=#bgimage#&ProgramType=#ProgramType#&Type=Internal&CID=#CID#" onClick="NewWindow(this.href,'printpage','800','600','Yes', 'No');Close_Window();return false;"><span style='font-size:10px'>INTERNAL</span></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="/common_files/contracts/sales_agreement_printer_friendly.cfm?id=#id#&bgimage=#bgimage#&ProgramType=#ProgramType#&Type=External&CID=#CID#" onClick="NewWindow(this.href,'printpage','800','600','Yes', 'No');Close_Window();return false;"><span style='font-size:10px'>EXTERNAL</span></a>

<!--- On Email request --->
<cfelseif ActionType eq "EmailProgram">
<a href="void(0)" onClick="opener.location.href='/common_files/contracts/sales_agreement_email_create.cfm?fid_private=#fid_private#&pid=#pid#&ProgramType=#ProgramType#&Type=Internal';Close_Window();return false;"><span style='font-size:10px'>INTERNAL</span></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="void(0)" onClick="opener.location.href='/common_files/contracts/sales_agreement_email_create.cfm?fid_public=#fid_public#&pid=#pid#&ProgramType=#ProgramType#&Type=External';Close_Window();return false;"><span style='font-size:10px'>EXTERNAL</span></a>

<!--- On Fax request --->
<cfelseif ActionType eq "FaxProgram">
<a href="void(0)" onClick="opener.location.href='/common_files/contracts/sales_agreement_fax_create.cfm?fid_private=#fid_private#&pid=#pid#&ProgramType=#ProgramType#&Type=Internal';Close_Window();return false;"><span style='font-size:10px'>INTERNAL</span></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="void(0)" onClick="opener.location.href='/common_files/contracts/sales_agreement_fax_create.cfm?fid_public=#fid_public#&pid=#pid#&ProgramType=#ProgramType#&Type=External';Close_Window();return false;"><span style='font-size:10px'>EXTERNAL</span></a>
</cfif>
</cfoutput>