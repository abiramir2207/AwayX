<cfoutput>

<!---set default values--->
<cfparam name="url.id" default=0 />
<cfparam name="form.id" default="#url.id#" />
<cfparam name="form.state" default="0" />
<cfparam name="form.referer" default="#cgi.HTTP_REFERER#" /><br>

<cfset activityMang = CreateObject("component","cm.activity.com.ActivityManager").init() />

<!---call functions to get lookup data--->
<cfset qGetObjectives = CreateObject("component","cm.activity.com.ActivityObjectiveManager").getAll() />
<cfset qGetTypes = CreateObject("component","cm.activity.com.ActivityTypeManager").getAll() />
<cfset qGetResults = CreateObject("component","cm.activity.com.ActivityResultManager").getAll() />

<cfif form.command eq "sv#commandSuffix#">
	
	
	<cfset activity = activityMang.get(0) />
	
	<cfset activity.setId(form.id) />
	<cfset activity.setName(form.Activity_Name) />
	<cfset activity.setNotes(form.Activity_Notes) />
	<cfset activity.setStartDate(form.Activity_Start_Date) />
	<cfset activity.setEndDate(form.Activity_End_Date) />
	<cfset activity.setObjectiveId(form.CM_Activity_Objective_ID) />
	<cfset activity.setTypeId(form.CM_Activity_Type_ID) />
	<cfset activity.setResultId(form.CM_Activity_Result_ID) />	
	<cfset activity.setOwnerId(request.AccessStructure.user_id) />
	<cfset activity.setCreatedUserId(request.AccessStructure.user_id) />
	<cfset activity.setUpdatedUserId(request.AccessStructure.user_id) />
	<cfset activity.setProductList(form.Product_List) />
	<cfset activity.setDistributorList(form.Distributor_List) />
	<cfset activity.setOperatorList(form.Operator_List) />

	<cfset activityMang.save() />
	<cflocation addtoken="No" url="#form.referer#" />

<cfelse>

<!------ <cfset qAllActivity = activityMang.getAll() /> ----->

<cfif form.state>
	
	<!---load from form--->
	<cfset activity = activityMang.get(0) />
	
	<cfset activity.setId(form.id) />
	<cfset activity.setName(form.Activity_Name) />
	<cfset activity.setNotes(form.Activity_Notes) />
	<cfset activity.setStartDate(form.Activity_Start_Date) />
	<cfset activity.setEndDate(form.Activity_End_Date) />
	<cfset activity.setObjectiveId(form.CM_Activity_Objective_ID) />
	<cfset activity.setTypeId(form.CM_Activity_Type_ID) />
	<cfset activity.setResultId(form.CM_Activity_Result_ID) />	
	<cfset activity.setProductList(form.Product_List) />
	<cfset activity.setDistributorList(form.Distributor_List) />
	<cfset activity.setOperatorList(form.Operator_List) />
	
	<cfset activity.setQProduct(activityMang.getProducts()) />
	<cfset activity.setQDistributor(activityMang.getDistributors()) />
	<cfset activity.setQOperator(activityMang.getOperators()) />
				
<cfelse>
	<cfset activity = activityMang.get(form.id) />
	
	<CFPARAM NAME="url.Operator_List" 	DEFAULT="#activity.getOperatorList()#">
	<CFPARAM NAME="form.Operator_List" 	DEFAULT="#url.Operator_List#">
	<CFPARAM NAME="url.Distributor_List" 	DEFAULT="#activity.getDistributorList()#">
	<CFPARAM NAME="form.Distributor_List" 	DEFAULT="#url.Distributor_List#">

	<cfif form.Operator_List NEQ activity.getOperatorList()>
		<cfset activity.setOperatorList(form.Operator_List) />		
		<cfset activity.setDistributorList(form.Distributor_List) />
	</cfif>
	
	<cfif form.Distributor_List NEQ activity.getDistributorList()>
		<cfset activity.setQOperator(activityMang.getOperators()) />
		<cfset activity.setQDistributor(activityMang.getDistributors()) />
	</cfif>
	
</cfif>

<!------ 
<cfloop query="qAllActivity">
	<a href="#cmHandler#?command=ce#commandSuffix#&id=#CM_Activity_ID#">#Activity_Name#</a>
	<br>
</cfloop>
 ----->
<form action="#cmHandler#" method="post" name="frmActivity">

Name: <input type="text" name="Activity_Name" value="#activity.getName()#" />
Notes: <input type="text" name="Activity_Notes" value="#activity.getNotes()#" />
<br>Start Date: <CF_EASYDATE 
					FORMNAME="frmActivity" 
					FIELDNAME="Activity_Start_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#activity.getStartDate()#">

End Date: <CF_EASYDATE 
					FORMNAME="frmActivity" 
					FIELDNAME="Activity_End_Date" 
					FORMAT="mm/dd/yyyy" 
					DEFAULT="#activity.getEndDate()#">
<br>Objective: 	<select name="CM_Activity_Objective_ID">
					<option>Select Objective...</option>
					<cfloop query="qGetObjectives">
						<option value="#CM_Activity_Objective_ID#" <cfif CM_Activity_Objective_ID eq activity.getObjectiveId()>selected</cfif>>#Activity_Objective_Name#</option>
					</cfloop>
				</select>

Type: 	<select name="CM_Activity_Type_ID">
					<option>Select Status...</option>
					<cfloop query="qGetTypes">
						<option value="#CM_Activity_Type_ID#" <cfif CM_Activity_Type_ID eq activity.getTypeId()>selected</cfif>>#Activity_Type_Name#</option>
					</cfloop>
				</select>
Result: 	<select name="CM_Activity_Result_ID">
					<option>Select Result...</option>
					<cfloop query="qGetResults">
						<option value="#CM_Activity_Result_ID#" <cfif CM_Activity_Result_ID eq activity.getResultId()>selected</cfif>>#Activity_Result_Name#</option>
					</cfloop>
				</select>
				
<hr>
<a href="void(0)" onClick="return showProductSearchWindow('frmActivity');">add products</a>
<br>
<cfset qProd = activity.getQProduct() />

<cfloop query="qProd">
#description#<br>
</cfloop>
<hr>
<a href="void(0)" onClick="return showDistributorSearchWindow('frmActivity');">add #application.returned_customer_setting.distributor_label_plural#</a>
<br>
<cfset qDist = activity.getQDistributor() />

<cfloop query="qDist">
#name#<br>
</cfloop>
<hr>
<a href="void(0)" onClick="return showOperatorSearchWindow('frmActivity');">add #application.returned_customer_setting.operator_label_plural#</a>
<br>
<cfset qOp = activity.getQOperator() />
<cfloop query="qOp">
#operator_name#<br>
</cfloop>
<hr>
<br>
<!---- relationships ----->
<input type="hidden" name="Product_List" value="#activity.getProductList()#" />
<input type="hidden" name="ExistingProductList" value="#activity.getProductList()#" />
<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#activity.getDistributorList()#" />
<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#activity.getOperatorList()#" />

<!---  common ---->
<input type="submit" name="save" value="Save" onClick="submitForm(this.form, 'sv#commandSuffix#');" />
<input type="hidden" name="id" value="#activity.getId()#" />
<input type="hidden" name="state" value="1" />
<input type="hidden" name="command" value="ce#commandSuffix#" />
<input type="hidden" name="referer" value="#form.referer#" />
</form>
<a href="#cmHandler#?command=ce#commandSuffix#">(new)</a>

</cfif>
</cfoutput>