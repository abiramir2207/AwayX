<cfcomponent output="false" displayname="BBRawEDIDetail" alias="mvc.Models.Billback.vos.BBRawEDIDetail">

	<cfproperty name="UploadID" type="numeric" hint="" />
	<cfproperty name="BBUploadIIIPHID" type="numeric" hint="" />
	<cfproperty name="BBNumber" type="String" />
	<cfproperty name="BBDate" type="date" />
	<cfproperty name="PeriodStDate" type="String" />
	<cfproperty name="PeriodEndDate" type="String" />
	<cfproperty name="AgreementNum" type="String" />
	<cfproperty name="AgreementName" type="String" />
	<cfproperty name="VendorLocNum" type="String" />
	<cfproperty name="VendorInvNum" type="String" />
	<cfproperty name="DCACName" type="String" />
	<cfproperty name="DCACNum" type="String" />
	<cfproperty name="STAddress1" type="String" />
	<cfproperty name="STCity" type="String" />
	<cfproperty name="STState" type="String" />
	<cfproperty name="STZipCode" type="String" />
	<cfproperty name="CSQTY" type="String" />
	<cfproperty name="UPCCODE" type="String" />
	<cfproperty name="ManufactureItemID" type="String" />
	<cfproperty name="DCProductNum" type="String" />
	<cfproperty name="AwardAmt" type="String" />
	<cfproperty name="DCProductDesc" type="String" />
	<cfproperty name="DeletedBy" type="String" />
	<cfproperty name="DeletedDate" type="date" />
	
	
	
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.UploadID = "";
		this.BBUploadIIIPHID = "";
		this.BBNumber = "";
		this.BBDate = "";
		this.PeriodStDate = "";		// Distributor_ID
		this.PeriodEndDate = "";		// Distributor_Name
		this.AgreementNum = "";// Agreement_Num	
		this.AgreementName = "";
		this.VendorLocNum = "";
		this.VendorInvNum = "";
		this.DCACName = "";
		this.DCACNum = "";
		this.STAddress1 = "";
		this.STCity = "";
		this.STState = "";
		this.STZipCode = "";
		this.CSQTY = "";
		this.UPCCODE = "";
		this.ManufactureItemID = "";
		this.DCProductNum = "";
		this.AwardAmt = "";
		this.DCProductDesc = "";
		this.DeletedBy = "":
		this.DeletedDate = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBRawEDIDetail">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>