<!------Paging_Retain_Old_Values.cfm----->
<CFPARAM NAME="FORM.RID" 	DEFAULT="">
<CFPARAM NAME="FORM.EXISTING_RID" 	DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="">

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.RID, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.RID#" DELIMITERS=",">
	<CFIF listfind(Form.EXISTING_RID, ListItem, ",") EQ 0>
		<CFSET Form.EXISTING_RID = listappend(Form.EXISTING_RID, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.EXISTING_RID,ListItem, ",") GT 0>
		<CFSET Form.EXISTING_RID = listdeleteat(FORM.EXISTING_RID, listfind(FORM.EXISTING_RID,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>
<CFSET FORM.AlreadySelectedItems = "">