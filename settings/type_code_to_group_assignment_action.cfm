<!------ This file will not be just type code to group assognment,
it will handle any type of group to grouop assignment
For now, type code, type group, product hierarchy

application.returned_customer_setting.approval_on_type_code will give what type of group it is
1=type code, 0=type group, 
21=product hierarchy 1,
22=product hierarchy 2,
etc.
 ----->
 
<CFPARAM NAME="FORM.Group_ID" DEFAULT="">
<CFPARAM NAME="FORM.ExistingList" DEFAULT="">


<cf_list_compare list1="#FORM.ExistingList#" list2="#FORM.Group_ID#">
<CFSET deletelist 	= LC_Results1>
<CFSET addlist 		= LC_Results2>

<CFIF listlen(deletelist) GT 0>
	<CFQUERY NAME="saveGroupToGroup" datasource="#application.datasource#">
		UPDATE 	Margin_Group_Any_Group
		SET 	Deleted = 1
		WHERE 	Group_ID IN(#replace(listqualify(deletelist, "'", ","), '"', "'", "ALL")#)
				AND Deleted = 0
				AND	Group_Type = #application.returned_customer_setting.approval_on_type_code#
	</CFQUERY>
</CFIF>

<CFLOOP INDEX="Supplied_Group_ID" LIST="#addlist#" DELIMITERS=",">
	<cfset useLakebaseForsaveTypeCodeToGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_any_group")>
<cfif useLakebaseForsaveTypeCodeToGroup>
	<cftry>
		<cfset application.oLakebase.insertRow("margin_group_any_group", {
			"group_id" = "#Supplied_Group_ID#",
			"margin_group_id" = "#MARGIN_GROUP_ID#",
			"group_type" = "#application.returned_customer_setting.approval_on_type_code#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveTypeCodeToGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveTypeCodeToGroup>
<CFQUERY NAME="saveTypeCodeToGroup" datasource="#application.datasource#">
		INSERT INTO Margin_Group_Any_Group
		(Group_ID, Margin_Group_ID, Group_Type)
		VALUES
		('#Supplied_Group_ID#', '#MARGIN_GROUP_ID#', #application.returned_customer_setting.approval_on_type_code#)
	</CFQUERY>
</cfif>
</CFLOOP>

<script>
	window.close();
</script>