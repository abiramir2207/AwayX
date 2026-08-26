<cfcomponent output="false" displayname="BBFilterDef" alias="mvc.Models.Billback.vos.BBFilterDef">
	<cfproperty name="statusList" type="Array" />
	<cfproperty name="closingMethodList" type="Array" />
	<cfproperty name="analystList" type="Array" />
	<cfproperty name="userList" type="Array" />
	<cfproperty name="typeList" type="Array" />	
	<cfproperty name="dateTypeList" type="Array" />
	<cfproperty name="amountTypeList" type="Array" />
	<cfproperty name="entityTypeList" type="Array" />
	<cfproperty name="historyTypeList" type="Array" />
	<cfproperty name="criteriaList" type="Array" />	
	<cfproperty name="actionList" type="Array" />	
	<cfproperty name="conditionList" type="Array" />

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.statusList;
		this.closingMethodList;
		this.analystList;
		this.userList;
		this.typeList;
		this.dateTypeList;
		this.amountTypeList;
		this.entityTypeList;
		this.historyTypeList;
		this.actionList;
		this.conditionList;
	</cfscript>

	<cffunction name="init" output="false" returntype="BBFilterDef">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>