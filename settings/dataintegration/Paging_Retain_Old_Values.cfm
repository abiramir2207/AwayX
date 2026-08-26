<!------Paging_Retain_Old_Values.cfm----->
<CFPARAM NAME="FORM.ID" 	DEFAULT="">
<CFPARAM NAME="FORM.EXISTING_ID" 	DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.ID, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.ID#" DELIMITERS=",">
	<CFIF listfind(Form.EXISTING_ID, ListItem, ",") EQ 0>
		<CFSET Form.EXISTING_ID = listappend(Form.EXISTING_ID, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.EXISTING_ID,ListItem, ",") GT 0>
		<CFSET Form.EXISTING_ID = listdeleteat(FORM.EXISTING_ID, listfind(FORM.EXISTING_ID,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>
<CFSET FORM.AlreadySelectedItems = "">