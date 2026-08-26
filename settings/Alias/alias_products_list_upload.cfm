<cfsetting enablecfoutputonly="Yes" showdebugoutput="false">
<cfparam name="form.Distributor_Level" default="">
<cfparam name="form.Product_List" default="">

	<!--- Header --->
<cfset csvstr = createObject("java","java.lang.StringBuffer")>
	<cfset csvstr.append("#DistributorSingularLabel# Level" & ",")>
	<cfset csvstr.append("#DistributorSingularLabel# ID" & ",")>
	<cfset csvstr.append("Product Number" & ",")>
	<cfset csvstr.append("#DistributorSingularLabel# Product Number" & ",")>
	<cfset csvstr.append(Chr(13) & Chr(10))>

	<!--- Details --->
<cfloop query="variables.qgetProductInfo">
	<cfset csvstr.append(Group_Level_Desc & ",")>
	<cfset csvstr.append(Distributor_Number & ",")>
	<cfset csvstr.append("'#Item#'" & ",")>
	<cfset csvstr.append(Distributor_Product_Number & ",")>
	<cfset csvstr.append(Chr(13) & Chr(10))>
</cfloop>
	
<cfoutput>#csvstr.toString()#</cfoutput>

