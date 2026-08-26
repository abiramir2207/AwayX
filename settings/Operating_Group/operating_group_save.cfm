

<!--- save operating group --->

<cfparam name="form.Parent_Operating_Group_ID" 	default="0">
<cfparam name="form.Allowance_Code_ID" 			default="0">
<cfset form.id = operatingGroupManager.save(
				form.level, 
				form.id, 
				form.Operating_Group_Number, 
				form.Operating_Group_Desc, 
				form.Parent_Operating_Group_ID, 
				form.Allowance_Code_ID) />
				
<cfif operatingGroupManager.getProductGroupSelectLevel() EQ form.level><!------ Save the product Group selection ----->
	<cftransaction action="BEGIN" isolation="READ_UNCOMMITTED">
	<cftry>
	<!------ First delete all ----->
	<cfset operatingGroupManager.deleteProductGroupSelection(form.id) />
	
	<cfparam name="form.perating_Group_Definition_List" 	default="">
	<cfloop list="#form.perating_Group_Definition_List#" index="counter">
		<cfparam name="form.Operating_Group_Definition_Group_#counter#" 	default="">
		<cfparam name="form.Operating_Group_Definition_Value_#counter#" 	default="">
		<cfset Operating_Group_Definition_Group_N = Evaluate("form.Operating_Group_Definition_Group_#counter#") />
		<cfset Operating_Group_Definition_Value_N = Evaluate("form.Operating_Group_Definition_Value_#counter#") />
		<cfif Operating_Group_Definition_Group_N NEQ "" AND Operating_Group_Definition_Value_N NEQ "">
			<!------ Save these ----->
			<cfset operatingGroupManager.addProductGroupSelection(form.id, Operating_Group_Definition_Group_N, Operating_Group_Definition_Value_N) />
		</cfif>
	</cfloop>
	<cftransaction action="COMMIT">
	
	<cfcatch>
		<cftransaction action="ROLLBACK">
		<cfrethrow />
	</cfcatch>
	</cftry>
	</cftransaction>
</cfif>
<cflocation url="index.cfm?level=#form.level#&command=#form.returnCommand#" />