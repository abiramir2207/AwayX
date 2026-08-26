<CFPARAM NAME="FORM.TYPE_GROUP_DESC_ID" DEFAULT="">
<CFPARAM NAME="FORM.ExistingList" DEFAULT="">


<cf_list_compare list1="#FORM.ExistingList#" list2="#FORM.TYPE_GROUP_DESC_ID#">
<CFSET deletelist 	= LC_Results1>
<CFSET addlist 		= LC_Results2>

<CFIF listlen(deletelist) GT 0>
	<CFQUERY NAME="saveTypeCodeToGroup" datasource="#application.datasource#">
		UPDATE Margin_Group_Type_Groups
		SET Deleted = 1
		WHERE Type_Group_Desc_ID IN(#replace(listqualify(deletelist, "'", ","), '"', "'", "ALL")#)
	</CFQUERY>
</CFIF>

<CFLOOP INDEX="Supplied_Type_Code_ID" LIST="#addlist#" DELIMITERS=",">
	<CFQUERY NAME="saveTypeCodeToGroup" datasource="#application.datasource#">
		INSERT INTO Margin_Group_Type_Groups
		(Type_Group_Desc_ID, Margin_Group_ID)
		VALUES
		('#Supplied_Type_Code_ID#', '#MARGIN_GROUP_ID#')
	</CFQUERY>
</CFLOOP>

<script>
	window.close();
</script>