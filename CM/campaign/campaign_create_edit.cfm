<!------ campaign_create_edit.cfm ----->
<cfoutput>

<!------ set defaults ----->
<cfparam name="url.id" default=0 />
<cfparam name="form.id" default="#url.id#" />
<cfparam name="form.state" default="0" />
<cfparam name="form.referer" default="#cgi.HTTP_REFERER#" />

<cfparam name="form.Family_ID" 	default="">
<cfparam name="form.Buying_Group_ID" 	default="">
<cfparam name="form.Operator_Type" 	default="">

<cfset campMang = CreateObject("component","cm.campaign.com.CampaignManager").init() />

<cfset campAll = campMang.getAll()>
<cfset custManager = CreateObject("component","cm.customer.com.CustomerManager").init() />
<cfset allFamily = custManager.getFamilys()>
<cfset allBuyingGroup = custManager.getBuyingGroups()>
<cfset allOperatorType = custManager.getOperatorTypes()>



<cfif form.command eq "sv#commandSuffix#">
	<cfset camp = campMang.get(0) />
	
	<cfset camp.setId(form.id) />
	<cfset camp.setName(form.Campaign_Name) />
	<cfset camp.setDesc(form.Campaign_Description) />
	<cfset camp.setStartDate(form.Campaign_Start_Date) />
	<cfset camp.setEndDate(form.Campaign_End_Date) />
	<cfset camp.setCreatedUserId(request.AccessStructure.user_id) />
	<cfset camp.setUpdatedUserId(request.AccessStructure.user_id) />
	
	<cfset camp.setDistributorList(form.Distributor_List) />
	<cfset camp.setOperatorList(form.Operator_List) />
	<cfset camp.setFamilyList(form.Family_ID) />
	<cfset camp.setBuyingGroupList(form.Buying_Group_ID) />
	<cfset camp.setOperatorTypeList(form.Operator_Type) />
	
	<cfset campMang.save() />
	<cflocation addtoken="No" url="#cmHandler#?command=ce#commandSuffix#" />
	
	<cfabort>
</cfif>

<cfif form.state>
	
	<!---load from form--->
	<cfset camp = campMang.get(0) />
	
	<cfset camp.setId(form.id) />
	<cfset camp.setName(form.Campaign_Name) />
	<cfset camp.setDesc(form.Campaign_Description) />
	<cfset camp.setStartDate(form.Campaign_Start_Date) />
	<cfset camp.setEndDate(form.Campaign_End_Date) />
	
	<cfset camp.setDistributorList(form.Distributor_List) />
	<cfset camp.setQDistributor(campMang.getDistributors()) />
	
	<cfset camp.setOperatorList(form.Operator_List) />
	<cfset camp.setQOperator(campMang.getOperators()) />
	
	<cfset camp.setFamilyList(form.Family_ID) />
	<cfset camp.setBuyingGroupList(form.Buying_Group_ID) />
	<cfset camp.setOperatorTypeList(form.Operator_Type) />

<cfelse>
	<cfset camp = campMang.get(form.id) />
</cfif>


<cfloop query="campAll">
	<a href="#cmHandler#?command=ce#commandSuffix#&id=#CM_Campaign_ID#">#Campaign_Description#</a><br>
</cfloop>
<form action="#cmHandler#" method="post" name="frm#commandSuffix#">

Name: <input type="text" name="Campaign_Name" value="#camp.getName()#" />
Desc: <input type="text" name="Campaign_Description" value="#camp.getDesc()#" />
<br>Start Date: <CF_EASYDATE 
					FORMNAME="frm#commandSuffix#" 
					FIELDNAME="Campaign_Start_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#camp.getStartDate()#">

End Date: <CF_EASYDATE 
					FORMNAME="frm#commandSuffix#" 
					FIELDNAME="Campaign_End_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#camp.getEndDate()#">


<hr>
<a href="void(0)" onClick="return showDistributorSearchWindow('frm#commandSuffix#');">add #application.returned_customer_setting.distributor_label_plural#</a>
<br>
<cfset qDist = camp.getQDistributor() />
<cfloop query="qDist">
#name#<br>
</cfloop>

<hr>
<B>Family</B><br>
<cfset familyList = camp.getFamilyList() />
<select name="Family_ID" multiple size="5">
	<option value="">select family</option>
	<cfloop query="allFamily">
	<option value="#Family_ID#"<cfif ListFindNoCase(familyList, Family_ID, ",")> selected</cfif>>#Family_Name#</option>
	</cfloop>
</select>

<hr>
<B>Buying Group</B><br>
<cfset buyingGroupList = camp.getBuyingGroupList() />
<select name="Buying_Group_ID" multiple size="5">
	<option value="">select Buying Group</option>
	<cfloop query="allBuyingGroup">
	<option value="#Buying_Group_ID#"<cfif ListFindNoCase(buyingGroupList, Buying_Group_ID, ",")> selected</cfif>>#Buying_Group_Name#</option>
	</cfloop>
</select>


<hr>
<a href="void(0)" onClick="return showOperatorSearchWindow('frm#commandSuffix#');">add #application.returned_customer_setting.operator_label_plural#</a>
<br>
<cfset qOp = camp.getQOperator() />
<cfloop query="qOp">
#operator_name#<br>
</cfloop>

<hr>
<B>#application.returned_customer_setting.operator_label_singular# Type</B><br>
<cfset operatorTypeList = camp.getOperatorTypeList() />
<select name="Operator_Type" multiple size="5">
	<option value="">select #application.returned_customer_setting.operator_label_singular# Type</option>
	<cfloop query="allOperatorType">
	<option value="#Operator_Type#"<cfif ListFindNoCase(operatorTypeList, Operator_Type, ",")> selected</cfif>>#Operator_Type#</option>
	</cfloop>
</select>



<!---- relationships ----->
<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#camp.getDistributorList()#" />
<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#camp.getOperatorList()#" />

<!---  common ---->
<input type="submit" name="save" value="Save" onClick="submitForm(this.form, 'sv#commandSuffix#');" />
<input type="hidden" name="id" value="#camp.getId()#" />
<input type="hidden" name="state" value="1" />
<input type="hidden" name="command" value="ce#commandSuffix#" />
</form>
<a href="#cmHandler#?command=ce#commandSuffix#">(new)</a>


</cfoutput>