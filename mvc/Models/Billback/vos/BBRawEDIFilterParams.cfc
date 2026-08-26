<cfcomponent output="false" displayname="BBRawEDIFilterParams" alias="mvc.Models.Billback.vos.BBRawEDIFilterParams">

	<cfproperty name="BBNumberKeyword" type="String" />
	<cfproperty name="BBDateKeyboard" type="date" />
	<cfproperty name="vendorNumber" type="String" />
	<cfproperty name="vendorName" type="String" />
	<cfproperty name="payeeNumber" type="String" />
	<cfproperty name="payeeName" type="String" />
	<cfproperty name="agreementNumber" type="String" />
	<cfproperty name="agreementName" type="String" />
	<cfproperty name="clearRecords" type="Boolean" />
	<cfproperty name="BBRawEDIDetail" type="Array" />
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.BBNumberKeyword = "";
		this.BBDateKeyboard = "";
		this.vendorNumber = "";
		this.vendorName = "";
		this.payeeNumber = "";
		this.payeeName = "";
		this.agreementNumber = "";
		this.agreementName = "";
		this.clearRecords = 0;
		this.BBRawEDIDetail  = ArrayNew(1);
	</cfscript>

	<cffunction name="init" output="false" returntype="BBRawEDIFilterParams">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>