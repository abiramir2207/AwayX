<cfcomponent output="false" displayname="BBRawEDIHeader" alias="mvc.Models.Billback.vos.BBRawEDIHeader">

	<cfproperty name="UploadID" type="numeric" hint="" />
	<cfproperty name="BBUploadIIIPHID" type="numeric" hint="" />
	<cfproperty name="BBNumber" type="String" />
	<cfproperty name="BBDate" type="date" />
	<cfproperty name="vendorNumber" type="String" />
	<cfproperty name="vendorName" type="String" />
	<cfproperty name="payeeNumber" type="String" />
	<cfproperty name="payeeName" type="String" />
	<cfproperty name="agreementNumber" type="String" />
	<cfproperty name="agreementName" type="String" />
	<cfproperty name="ETotalClaimedAmt" type="String" />
	<cfproperty name="TotVolume" type="String" />
	<cfproperty name="DeletedBy" type="String" />
	<cfproperty name="DeletedDate" type="date" />
	<cfproperty name="bbRawEDIDetail" type="Array" />
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.UploadID = "";
		this.BBUploadIIIPHID = "";
		this.BBNumber = "";
		this.BBDate = "";
		this.vendorNumber = "";
		this.vendorName = "";
		this.payeeNumber = "";
		this.payeeName = "";
		this.agreementNumber = "";
		this.agreementName = "";
		this.ETotalClaimedAmt = "";
		this.TotVolume = "";
		this.DeletedBy  = "";
		this.DeletedDate = "";
		this.bbRawEDIDetail= arrayNew(1);
	</cfscript>

	<cffunction name="init" output="false" returntype="BBRawEDIHeader">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>