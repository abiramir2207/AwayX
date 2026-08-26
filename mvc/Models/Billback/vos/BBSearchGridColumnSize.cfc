<cfcomponent output="false" displayname="BBSearchGridColumnSize" alias="mvc.Models.Billback.vos.BBSearchGridColumnSize">
	<cfproperty name="status" type="int" />
	<cfproperty name="BBCode" type="int" />
	<cfproperty name="BBNumber" type="int" />
	<cfproperty name="title" type="int" />
	<cfproperty name="BBDate" type="int" />
	<cfproperty name="payee" type="int" />
	<cfproperty name="startDate" type="int" />
	<cfproperty name="endDate" type="int" />
	<cfproperty name="claimedAmount" type="int" />
	<cfproperty name="approvedAmount" type="int" />
	<cfproperty name="closingMethod" type="int" />
	<cfproperty name="moreInfo" type="int" />
	<cfproperty name="vendor" type="int" />
	<cfproperty name="BBReceivedDate" type="int" />		

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.status = 0;
		this.BBCode = 0;
		this.BBNumber = 0;
		this.title = 0;
		this.BBDate = 0;
		this.payee = 0;
		this.startDate = 0;
		this.endDate = 0;
		this.claimedAmount = 0;
		this.approvedAmount= 0;
		this.closingMethod = 0;
		this.moreInfo = 0;
		this.vendor = 0;
		this.BBReceivedDate = 0;		
	</cfscript>

	<cffunction name="init" output="false" returntype="BBSearchGridColumnSize">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>