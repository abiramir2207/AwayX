<CFINCLUDE template="bsInclude.cfm">
<cfparam name="URL.PG" 	default="">

<frameset cols="520,*" border=0>	
	<CFIF URL.PG EQ "2">
		<frame src="AdvancedTab.cfm" noresize></frame>
		<CFOUTPUT><frame src="#IMGPage#?IMG=advanced0" name="IMG" noresize></frame></CFOUTPUT>
	<CFELSEIF URL.PG EQ "1">		
		<frame src="securityTab.cfm" noresize></frame>
		<CFOUTPUT><frame src="#IMGPage#?IMG=security0" name="IMG" noresize></frame></CFOUTPUT>
	<CFELSE>		
		<frame src="about.cfm" noresize></frame>
		<CFOUTPUT><frame src="#IMGPage#?IMG=about1" name="IMG" noresize></frame></CFOUTPUT>
	</CFIF>	
</frameset>
