
<cfcomponent output="false" displayname="BBSettlementAction" alias="mvc.Models.Billback.vos.BBSettlementAction"  hint="extra parameters when a BB is approved/paid">

	<cfproperty name="balance" 			type="numeric" 	hint = "" />
	<cfproperty name="action" 			type="string" 	hint = "save,agree, or approve" />
	
	
	<cfscript>		
		this.balance			= 0;
		this.action 			= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBSettlementAction">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>