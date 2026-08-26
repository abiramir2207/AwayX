<CFPARAM NAME="Attributes.selectall" DEFAULT="no">

	<CFIF lcase(Attributes.selectall) EQ "yes">
		<CFIF caller.Attributes.selection_option EQ "checkbox">
				<INPUT TYPE="Checkbox" NAME="allbox" ONCLICK="CA()">
		</CFIF>
	<CFELSE>

	<CFSET Attributes.Internal_ID = lcase(caller.GST_ID)>
	<CFSWITCH EXPRESSION="#caller.Attributes.SELECTION_OPTION#">
		<CFCASE VALUE="CHECKBOX">
			<INPUT NAME="SELECTEDIDLIST" TYPE="Checkbox" VALUE="<CFOUTPUT>#Attributes.Internal_ID#</CFOUTPUT>" 
					<CFIF 
						listfind(caller.FORM.NewIDList, Attributes.Internal_ID)
						OR
						listfind(caller.Attributes.existing_hiddenidlist, lcase(Attributes.Internal_ID))>CHECKED</CFIF>>
			<INPUT TYPE="hidden" NAME="HIDDENIDLIST" VALUE="<CFOUTPUT>#Attributes.Internal_ID#</CFOUTPUT>">
		</CFCASE>
	
		<CFCASE VALUE="RADIO">
			<CFOUTPUT>
				<INPUT NAME="SELECTEDIDLIST" TYPE="Radio" VALUE="#Attributes.Internal_ID#"
					#IIF(caller.FORM.NewIDList EQ Attributes.Internal_ID, DE(" CHECKED"), DE(""))#>
				<INPUT TYPE="hidden" NAME="HIDDENIDLIST" VALUE="#Attributes.Internal_ID#">
			</CFOUTPUT>
		</CFCASE>
	
		<CFCASE VALUE="NONE">
		</CFCASE>
	</CFSWITCH>

</CFIF>

