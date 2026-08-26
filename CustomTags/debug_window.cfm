
<CFSAVECONTENT variable="error_report">
	<cfoutput>
	<cfif isdefined("caller.debugtag.files")>
		<CFSET keylistofstruct = structkeylist(caller.debugtag.files)>
		<CFSET keylistofstruct_reversed = "">
		<cfloop index="n" from="#listlen(keylistofstruct)#" to="1" step="-1">
			<CFSET keylistofstruct_reversed = listappend(keylistofstruct_reversed, listgetat(keylistofstruct,n))>
		</CFLOOP>

		<cfloop index="x" list="#keylistofstruct_reversed#">
			<cfinclude template="/error_files/#x#.cfm">
			<table>
				<TR>
					<td style="color:red; font-weight:bold; font-size: 20px;">#title#</td>
				</TR>
				<TR>
					<td style="color:blue; font-weight:bold; font-size: 15px;">#description#</td>
				</TR>
				<tr>
					<td style="font-weight:bold;">variable: <span style="color:red">#varname#</span></td>
				</tr>
			</table>
			<HR>
			#errortext#
			<BR><BR>
		</CFLOOP>
	</cfif>
	</cfoutput>
</CFSAVECONTENT>
<CFSET tempfilename = "debug_" & createuuid() & createuuid()>
<CFSET tempfilename = replace(tempfilename, "-", "", "ALL")>
<CFSET "caller.debugtag.files.#tempfilename#" = 1>
<CFSET tempfilename = tempfilename & ".html">
<cfif len(trim(error_report)) EQ 0>
	<cfset error_report="<span style=""font-weight:30px;color:red;"">NO DATA TO REPORT</span>">
</cfif>
<cffile action="WRITE" file="c:\inetpub\wwwroot\awayx\error_files\#tempfilename#" output="#error_report#" addnewline="Yes">

<a onclick="loadWindow()" style="font-weight:bold;color:blue;cursor:pointer;font-size:20px;">show debug window</a>
<script>
	function loadWindow(){
		newwind=window.open("/error_files/<cfoutput>#tempfilename#</cfoutput>", 'debug')
	} 
</script>

