<!--- _accounting_specialists_profiles.cfm --->
<cfoutput>
<TABLE width="70%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<TD>
			Check which profiles you want to allow <b>Payment Processor</b> modification rights.
		</TD>
	</TR>
</TABLE>
<br>
<CF_smallLink 
	title = "save" 
	url = ""
	parameters = "onClick=""javascript: return applyProfileAccess();"""
>
<!--- <CF_smallLink 
	title = "cancel" 
	url = ""
	parameters = "onClick=""javascript: return submitDataForm('list');"""
> --->
<br><br>

<TABLE width="70%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="##FFCE84">
		<TD STYLE="font-size:11px;">&nbsp;
			
		</TD>
		<TD STYLE="font-size:11px;" width="100%" nowrap>
			<b>Profiles</b>
		</TD>
	</TR>
	<cfloop query="qGetProfiles">
	
		<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
			<TD>
				<INPUT NAME="Profiles_ID" TYPE="checkbox" value="#Profiles_ID#" <cfif ListFindNoCase(lProfileAccess, Profiles_ID)>checked</cfif> />
			</td>
			<TD STYLE="font-size:11px;" width="100%" nowrap>
				#Profiles_Desc#
			</TD>	
		</TR>
		
	</cfloop>
</TABLE>
<br>
<CF_smallLink 
	title = "save" 
	url = ""
	parameters = "onClick=""javascript: return applyProfileAccess();"""
>
<!--- <CF_smallLink 
	title = "cancel" 
	url = ""
	parameters = "onClick=""javascript: return submitDataForm('list');"""
> --->
</cfoutput>