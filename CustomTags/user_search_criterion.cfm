<!---
Id: /CustomTags/user_search_criterion.cfm, v1.2.3 11/13/00 12:16:28 PM dbabbitt
Description: This module creates the SQL to fulfill a 
			 complex search criterion.
--->


<CFSET Variables.Criteria="#Attributes.FieldName#">
<CFSET Variables.Value="#Attributes.Value#">

<!--- Is the field type not datetime? --->
<CFIF Compare(Attributes.FieldType, 'DATETIME')>
	<!--- escape quotes --->
	<CFSET Variables.Value="#Replace(Variables.Value, Chr(72), '#Chr(72)##Chr(72)#', 'ALL')#"></CFIF>

<!--- Is the field type simple text? --->
<CFIF ListFindNoCase('CHAR,MEMO', Attributes.FieldType)>
	<!--- Is it the "equals" operator? --->
	<CFIF NOT CompareNoCase(Attributes.operator, 'EQUAL')>
		<CFSET Variables.Criteria="#Variables.Criteria# = '#Variables.Value#' ">
		<!--- Is it the "not equals" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'NOT_EQUAL')><CFSET Variables.Criteria="#Variables.Criteria# #Chr(60)##Chr(62)# '#Variables.Value#' ">
		<!--- Is it the "greater than" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'GREATER_THAN')><CFSET Variables.Criteria="#Variables.Criteria# #Chr(62)# '#Variables.Value#' ">
		<!--- Is it the "less than" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'SMALLER_THAN')><CFSET Variables.Criteria="#Variables.Criteria# #Chr(60)# '#Variables.Value#' ">
		<!--- Is it the "contains" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'CONTAINS')><CFIF Len(Variables.Value)>
			<CFSET Variables.Criteria="#Variables.Criteria# LIKE '%#Variables.Value#%' ">
			<CFELSE><CFSET Variables.Criteria=" "></CFIF>
		<!--- Is it the "not contains" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'NOT_CONTAINS')><CFIF Len(Variables.Value)>
			<CFSET Variables.Criteria="#Variables.Criteria# NOT LIKE '%#Variables.Value#%' ">
			<CFELSE><CFSET Variables.Criteria=" "></CFIF>
		<!--- Is it the "begins with" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'BEGINS_WITH')>
			<CFIF Len(Variables.Value)><CFSET Variables.Criteria="#Variables.Criteria# LIKE '#Variables.Value#%' ">
			<CFELSE><CFSET Variables.Criteria=" "></CFIF>
		<!--- Is it the "ends with" operator? --->
		<CFELSEIF NOT CompareNoCase(Attributes.operator, 'ENDS_WITH')>
			<CFIF Len(Variables.Value)><CFSET Variables.Criteria="#Variables.Criteria# LIKE '%#Variables.Value#' ">
			<CFELSE><CFSET Variables.Criteria=" "></CFIF></CFIF>
			
	<!--- Is the field type a more complicated type? --->
	<CFELSEIF ListFindNoCase('INT,FLOAT,BIT,DATETIME', Attributes.FieldType)>
		<!--- Is it the "equals" operator? --->
		<CFIF NOT CompareNoCase(Attributes.operator, 'EQUAL')>
				<CFIF ListLen(Variables.Value) GT 1>
					<CFSET Variables.Criteria=Variables.Criteria & " IN (#Variables.Value#) ">
					<CFELSE>
					<CFIF Attributes.FieldType IS "DATETIME">
						<CFSET Variables.Criteria="DATEDIFF(dd, #Variables.Criteria#, #CreateODBCDateTime(Variables.Value)#) = 0 ">
						<CFELSE>
						<CFSET Variables.Criteria=Variables.Criteria & " = #Variables.Value# "></CFIF></CFIF>
		<!--- Is it the "not equals" operator? --->
			<CFELSEIF NOT CompareNoCase(Attributes.operator, 'NOT_EQUAL')>
				<CFIF Attributes.FieldType IS "DATETIME">
					<CFSET Variables.Criteria="DATEDIFF(dd, #Variables.Criteria#, #CreateODBCDateTime(Variables.Value)#) #Chr(60)##Chr(62)# 0 ">
					<CFELSE>
					<CFSET Variables.Criteria="#Variables.Criteria# #Chr(60)##Chr(62)# #Variables.Value# "></CFIF>
		<!--- Is it the "greater than" operator? --->
			<CFELSEIF ListFindNoCase('GREATER_THAN,AFTER', Attributes.operator)>
				<CFIF Attributes.FieldType IS "DATETIME">
					<CFSET Variables.Criteria="#Variables.Criteria# #Chr(62)#= #CreateODBCDateTime(DateAdd('d', 1, Variables.Value))# ">
					<CFELSE>
					<CFSET Variables.Criteria="#Variables.Criteria# #Chr(62)# #Variables.Value# "></CFIF>
		<!--- Is it the "lesser than" operator? --->
			<CFELSEIF ListFindNoCase('SMALLER_THAN,BEFORE', Attributes.operator)>
				<CFIF Attributes.FieldType IS "DATETIME">
					<CFSET Variables.Criteria="#Variables.Criteria# #Chr(60)# #CreateODBCDateTime(Variables.Value)# ">
					<CFELSE>
					<CFSET Variables.Criteria="#Variables.Criteria# #Chr(60)# #Variables.Value# "></CFIF></CFIF>

	</CFIF>
<!--- Is there any field name associated with this? --->
<CFIF Len(Trim(Variables.Criteria))>
	<CFSET Caller.Criteria="#Caller.Criteria# AND #Variables.Criteria#">
	<!--- There is no field name associated with this. --->
	<CFELSE><CFSET Caller.Criteria="#Caller.Criteria##Variables.Criteria#"></CFIF>

<!---
	Log: user_search_criterion.cfm
	Revision 1.2 11/10/00 5:43:43 PM dbabbitt
	Now it handles dates and multiple ints 
	properly.
	
	Revision 1.1 10/9/00 4:41:33 PM dbabbitt
	If value is blank in contains, the 
	criteria doesn't end up checking for 
	anything.
	
	Revision 1.0 6/21/00 4:35:05 PM dbabbitt
	This module creates the SQL to fulfill 
	a complex search criterion.
	--->