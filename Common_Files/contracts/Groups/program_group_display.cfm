<cfoutput>

<cfparam name="url.Program_ID" default="" />
<cfparam name="form.Program_ID" default="#url.Program_ID#" />

<!---initialize program group--->
<cfset ProgramGroup = CreateObject("component", "components.products.Group.ProgramGroup").getProgramGroups(form.Program_ID) />
<cfset aDiscountGroups = ProgramGroup.getDiscountGroup() />

<html>
<head>
<title>Group Item Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<style type="text/css">
	<CFINCLUDE template="/Common_Files/main_style.css">
</style>
</head>

<body>
<font color="##000066" size="4">Group Items</font>
<hr color="##000066">

<cfloop index="discIndx" from="1" to="#ArrayLen(aDiscountGroups)#">

	<!---handle label for rebate--->
	<cfif aDiscountGroups[discIndx].getDiscountType() eq 2>
		<cfset request.Discount_Label = Application.RebateLabel />
	<!---lump sum--->
	<cfelseif aDiscountGroups[discIndx].getDiscountType() eq 3>
		<cfset request.Discount_Label = Application.LumpsumLabel />
	<!---growth--->
	<cfelseif aDiscountGroups[discIndx].getDiscountType() eq 4>
		<cfset request.Discount_Label = "Growth" />
	<!---default--->
	<cfelse>
		<cfset request.Discount_Label = "" />
	</cfif>
	<table border="1" cellpadding="1" cellspacing="0" bgcolor="##F1FBDB">
		<tr>
			<td colspan="100%" style="border-bottom:none"><font color="##000066" size="2"><b>#request.Discount_Label#</b></font></td>
		</tr>
		<tr>
			<td bgcolor="##FFFFFF" style="border-bottom:none">
				<!---get group object--->
				<cfset aDiscGroupObj = aDiscountGroups[discIndx].getGroups() />

				<cfloop index="grpIndx" from="1" to="#ArrayLen(aDiscGroupObj)#">

				<cfset group = aDiscGroupObj[grpIndx]>

				<cfset form.Group_Level_ID = group.GetGroupLevelID()>
				<cfset form.Group_ID = group.getProductGroupId()>
				<cfset form.programID = form.Program_ID >
				<cfset form.showProgramItems = 1>
				<cfset ShowTitles = 0>

				<cfinclude template="group_items_Lite.cfm">

				</cfloop>
			</td>
		</tr>
	</table>
<p>
</cfloop>

</body>
</html>
</cfoutput>
