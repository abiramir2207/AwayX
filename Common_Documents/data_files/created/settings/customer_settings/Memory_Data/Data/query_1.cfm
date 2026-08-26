<cfoutput>SELECT * FROM type_group_desc 
WHERE len(Type_Group_Desc) != 0 AND Deleted = 0
<cfif isDefined("form.Business_Segment_ID")>
 <cfif form.Business_Segment_ID neq 0 AND form.Business_Segment_ID neq "">
   AND Business_Segment_ID = #attributes.Business_Segment_Id# 
 </cfif>
</cfif>
ORDER BY type_group_desc</cfoutput>
