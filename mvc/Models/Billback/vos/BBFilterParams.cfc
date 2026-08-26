<cfcomponent output="false" displayname="BBFilterParams" alias="mvc.Models.Billback.vos.BBFilterParams">
	<cfproperty name="BBCodeKeyword" type="String" />
	<cfproperty name="BBNumberKeyword" type="String" />
	<cfproperty name="programKeyword" type="String" />
	<cfproperty name="checkNoKeyword" type="String" />
	<cfproperty name="amountTypeSelect" type="String" />	
	<cfproperty name="amountCriteriaSelect" type="String" />
	<cfproperty name="amountValueKeyword" type="numeric" />
	<cfproperty name="dateTypeSelect" type="String" />
	<cfproperty name="dateCriteriaSelect" type="String" />
	<cfproperty name="dateValueKeyword" type="date" />	
	<cfproperty name="entitySelect" type="String" />	
	<cfproperty name="entityKeyword" type="String" />
	<cfproperty name="historySelect" type="String" />
	<cfproperty name="historyUsernameSelect" type="Array" />
	<cfproperty name="actionSelect" type="String" />
	<cfproperty name="conditionSelect" type="String" />
	<cfproperty name="statusListSelect" type="Array" />
	<cfproperty name="closingMethodSelect" type="Array" />
	<cfproperty name="typeListSelect" type="Array" />
	<cfproperty name="analystListSelect" type="Array" />
	<cfproperty name="bSearchDate" type="Boolean" />
	<cfproperty name="bSearchAmount" type="Boolean" />
	<cfproperty name="payeeKeyword" type="String" />
	<cfproperty name="userBillbackListId" type="integer" />
	<cfproperty name="userId" type="String" />
	<cfproperty name="listName" type="String" />
	<cfproperty name="currentIncludingPaid" type="Boolean" />
	<cfproperty name="reassignBBUserSelect" type="Array" />
	<cfproperty name="clearRecords" type="Boolean" />
	<cfproperty name="BBIDIntList" type="Array" />
	<cfproperty name="bChkDuplicate" type="Boolean" />
	

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.BBCodeKeyword = "";
		this.BBNumberKeyword = "";
		this.programKeyword = "";
		this.checkNoKeyword = "";
		this.amountTypeSelect = "";
		this.amountCriteriaSelect = "";
		this.amountValueKeyword = 0;
		this.dateTypeSelect = "";
		this.dateCriteriaSelect = "";
		this.dateValueKeyword= "#now()#";
		this.entitySelect = "";
		this.entityKeyword = "";
		this.historySelect = "";
		this.historyUsernameSelect = ArrayNew(1);
		this.actionSelect = "";
		this.conditionSelect = "";
		this.statusListSelect = ArrayNew(1);
		this.closingMethodSelect = ArrayNew(1);
		this.typeListSelect = ArrayNew(1);
		this.analystListSelect = ArrayNew(1);
		this.bSearchDate = 0;
		this.bSearchAmount = 0;
		this.payeeKeyword = "";
		this.userBillbackListId = 0;
		this.userId = "";
		this.listName = "";
		this.currentIncludingPaid = 0;
		this.reassignBBUserSelect = ArrayNew(1);
		this.clearRecords = 0;
		this.BBIDIntList = ArrayNew(1);
		this.bChkDuplicate = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="BBFilterParams">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>