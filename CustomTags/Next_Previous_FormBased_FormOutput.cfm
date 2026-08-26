<CFPARAM NAME="Attributes.addparams" DEFAULT="">
<FORM ACTION="<CFOUTPUT>#Attributes.Parentfilename#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
	<INPUT TYPE="hidden" NAME="frompage" VALUE="">
	<INPUT TYPE="hidden" NAME="startrow" VALUE="">
	<INPUT TYPE="hidden" NAME="maxrows" VALUE="<CFOUTPUT>#Attributes.maxrows#</CFOUTPUT>">

	<CFIF len(Attributes.addparams) GT 0>
		<CFOUTPUT>		
		<CFLOOP INDEX="paramName" LIST="#Attributes.addparams#">
			<CFSET periodPosition = find(".", paramName, 1)>
			<CFIF periodPosition GT 0>
				<CFSET paramName = mid(paramName, periodPosition + 1, len(paramName) - periodPosition)>
			</CFIF>
			
			<CFIF isdefined("#paramName#")>
				<INPUT TYPE="hidden" NAME="#paramName#" VALUE="#evaluate("#paramName#")#">
			</CFIF>
			
		</CFLOOP>
		</CFOUTPUT>		
	</CFIF>
</FORM>
<CFPARAM name="FORM.ES_ExternalSearch_Flag" default="0">
<CFIF FORM.ES_ExternalSearch_Flag EQ 1>
<FORM ACTION="../payables2/select_payable_contracts_action.cfm" METHOD="post" NAME="FromA" ID="FromA">
	<INPUT TYPE="hidden" NAME="payable_id" VALUE="<CFOUTPUT>#FORM.ES_itemid#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Contract_List" VALUE="">
</FORM>
</CFIF>

<SCRIPT>
	function NPFB_ChangePage(frompagevalue, startrowvalue) {
		document.all.frompage.value = frompagevalue
		document.all.startrow.value = startrowvalue
		document.all.MyForm.submit()
	}
</SCRIPT>

