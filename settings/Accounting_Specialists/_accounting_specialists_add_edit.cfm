<cfoutput>
<!---handle for display--->
<cfif form.display eq "edit">

	<cfset caption = "update" />
	<cfset jsFunction = "editSpecialist()" />
	
<cfelse>

	<cfset caption = "save" />
	<cfset jsFunction = "addSpecialist()" />
	
</cfif>

<cfparam name="form.Accounting_Specialist_Name" default="">

<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Accounting Specialist</LEGEND>
	<table>
	
		<TR>
			<TD><B>Name:</B></TD>
			<TD><INPUT NAME="Accounting_Specialist_Name" TYPE="text" SIZE="30" MAXLENGTH="25" value="#form.Accounting_Specialist_Name#"></TD>
		</TR>	

		<TR>
			<TD COLSPAN="100%">
				<CF_smallLink 
					title = "#caption#" 
					url = ""
					parameters = "onClick=""javascript: return #trim(jsFunction)#;"""
				>
				<CF_smallLink 
					title = "cancel" 
					url = ""
					parameters = "onClick=""javascript: return submitDataForm('list');"""
				>
			</TD>
		</TR>	
	</table>
</FIELDSET>

</cfoutput>