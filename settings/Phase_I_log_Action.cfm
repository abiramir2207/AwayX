<cfparam name="FORM.contractrollback" default="">
<CFIF LEN(FORM.contractrollback) GT 0>
<cfloop index="I" list="#FORM.contractrollback#" delimiters=",">
	 <cfstoredproc datasource="#application.datasource#" procedure="Phase1_Rollback_Status">
		 <cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" dbvarname="@@info" value="#I#" >
	 </cfstoredproc> 
</CFLOOP>	 
</CFIF>
<cflocation url="phase_I_log.cfm?ID=#createUUID()#">
