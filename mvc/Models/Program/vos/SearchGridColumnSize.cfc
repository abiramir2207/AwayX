<cfcomponent output="false" displayname="SearchGridColumnSize" alias="mvc.Models.Program.vos.SearchGridColumnSize">
	<cfproperty name="status" type="int" />
	<cfproperty name="rfaAge" type="int" />
	<cfproperty name="program" type="int" />
	<cfproperty name="title" type="int" />
	<cfproperty name="type" type="int" />
	<cfproperty name="startDate" type="int" />
	<cfproperty name="endDate" type="int" />
	<cfproperty name="rsp" type="int" />
	<cfproperty name="businessSegment" type="int" />
	<cfproperty name="tradeDollars" type="int" />
	<cfproperty name="paymentDollars" type="int" />
	<cfproperty name="volume" type="int" />
	<cfproperty name="moreInfo" type="int" />
	<cfproperty name="includeColumnList" type="array" />
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.status = 0;
		this.rfaAge = 0;
		this.program = 0;
		this.title = 0;
		this.type = 0;
		this.startDate = 0;
		this.endDate = 0;
		this.rsp = 0;
		this.businessSegment = 0;
		this.tradeDollars = 0;
		this.paymentDollars = 0;
		this.volume = 0;
		this.moreInfo = 0;
		this.includeColumnList = ArrayNew(1);
	</cfscript>

	<cffunction name="init" output="false" returntype="SearchGridColumnSize">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>