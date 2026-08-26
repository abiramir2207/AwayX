<!--- 
///////////////////////////////////////////////////////////////
<cf_EmailWrapperParam> 

Purpose: Nested tag within <cf_EmailWrapper>.
		
ATTRIBUTES:
	file="" - required if name isn't specified.
	name="" - required if file isn't specified.
	value="" - optional. Value of header.
	
///////////////////////////////////////////////////////////////
--->

<!--- ///	verify attributes	/// --->

<cfif not CompareNoCase(thisTag.ExecutionMode, "start")>
	<cfassociate basetag="cf_EmailWrapper" />
</cfif>



