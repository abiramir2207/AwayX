<!------ clause_program_display.cfm ----->
<CFOUTPUT>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">
<style>
TABLE.Clause TD 
{
	font-size : 10px;
	font-family: arial;
	border-bottom: 2px solid ##C1D0DD;
}
</style>
<cfloop query="getProgramClause">
	<TABLE cellpadding="2" cellspacing="0" width="100%" border="0" class="Clause">	
	<TR>
		<TD>
		#Clause_Library_Body#
		</TD>	
	</TR>	
	</TABLE>
	<br>
</cfloop>

</CFOUTPUT>