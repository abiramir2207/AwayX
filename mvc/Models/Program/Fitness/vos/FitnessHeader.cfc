<cfcomponent displayname="mvc.Models.Admin.Redi.vos.RediCorrectionHeader" >
	
	<cfproperty name="rediCorrectionHeaderId" type="numeric" default="0"/><!--- unique id in DB --->
	<cfproperty name="uploadId" type="numeric" default="0"/>
	<cfproperty name="isSelected" type="Boolean" default="0" />
	<cfproperty name="lock" type="mvc.Models.Entity.vos.Lock" default="" />
	<cfproperty name="sourceType" type="String" default=""/>
	<cfproperty name="sourceTypeDesc" type="String" default="" /><!---DOT, Sysco, Honor--->
	<cfproperty name="originalCustomer" type="mvc.Models.Entity.vos.Customer" default=""/><!---Original Buyer--->
	<cfproperty name="finalCustomer" type="mvc.Models.Entity.vos.Customer" default=""/><!---Final Buyer--->
	<cfproperty name="invoiceNumber" type="String" default=""/><!---Orig--->
	<cfproperty name="invoiceDate" type="Date" default=""/><!---Orig--->
	<cfproperty name="poNum" type="String" default=""/>
	<cfproperty name="InvCases" type="numeric" default=""/><!---total for file--->
	<cfproperty name="InvDollars" type="numeric" default=""/><!---total for file--->
	<cfproperty name="errorMessage" type="String" default=""/>
	<cfproperty name="arrRediCorrectionItems" type="array" default=""/>
	<cfproperty name="originalCustomerShipToNew" type="String" default=""/>  
	<cfproperty name="finalCustomerShipToNew" type="String" default="" /> 
	<cfproperty name="bReprocess" type="Boolean" default="0" /> 
	<cfproperty name="bFixable" type="Boolean" default="0" />

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.rediCorrectionHeaderId = 0;
		this.uploadId = 0;
		this.lock = '';
		this.isSelected = 0;
		this.sourceType= '';
		this.sourceTypeDesc = '';
		this.originalCustomer = '';
		this.finalCustomer = '';
		this.invoiceNumber = '';
		this.invoiceDate= '';
		this.poNum = ''; 
		this.InvCases = 0;
		this.InvDollars = 0;
		this.errorMessage = '';
		this.arrRediCorrectionItems = [];
		this.originalCustomerShipToNew = ''; //new shipto for alias (via another process)
		this.finalCustomerShipToNew = ''; //new shipto for alias (via another process)
		this.bReprocess= 0; //all Aliases have been corrected (by another process)
		this.bFixable = 0; //some errors cannot be fixed (duplicate invoice or invalid price)
	</cfscript>
	
	<cffunction name="init" output="false" returntype="AutoPayDetail" >
		<cfreturn this>
	</cffunction>

</cfcomponent>