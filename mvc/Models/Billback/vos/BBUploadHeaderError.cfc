<!-----------------------------------------------------------------------------

FILE NAME:		BBUploadHeader.cfc
DESCRIPTION:	BB upload Header fields declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	28-Apr-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent output="false" displayname="BBUploadHeaderError" alias="mvc.Models.Billback.vos.BBUploadHeaderError">
	
	<cfproperty name="vendorId" 			type="string" 	hint = "" />
	<cfproperty name="vendorName" 			type="string" 	hint = "" />
	<cfproperty name="shipTo" 				type="string" 	hint = "" /> 
	<cfproperty name="BBReference" 			type="string" 	hint = "" />
	<cfproperty name="billbackTitle" 		type="string" 	hint = "" />
	<cfproperty name="BBDate" 				type="string" 	hint = "" />
	<cfproperty name="startDate" 			type="string" 	hint = "" />
	<cfproperty name="endDate" 				type="string" 	hint = "" />
	<cfproperty name="BBAmount" 			type="string" 	hint = "" />
	<cfproperty name="operatorLegacyID" 	type="string" 	hint = "" />
	<cfproperty name="others"				type="string" 	hint = "" />
	<cfproperty name="agreementNum"				type="string" 	hint = "" />
	<cfproperty name="agreementName"				type="string" 	hint = "" />
	
	
 
	<cfscript>													
		this.vendorId			= "";
		this.vendorName			= "";
		this.shipTo				= "";
		this.BBReference		= "";
		this.billbackTitle		= "";
		this.BBDate				= "";
		this.startDate			= "";
		this.endDate			= "";
		this.BBAmount			= "";
		this.operatorLegacyID			= "";
		this.others				= "";
		this.agreementNum		= "";
		this.agreementName		= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBUploadHeaderError">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>