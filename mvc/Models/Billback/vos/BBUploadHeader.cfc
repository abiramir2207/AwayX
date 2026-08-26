<!-----------------------------------------------------------------------------

FILE NAME:		BBUploadHeader.cfc
DESCRIPTION:	BB upload Header fields declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	28-Apr-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent output="false" displayname="BBUploadHeader" alias="mvc.Models.Billback.vos.BBUploadHeader">
	
	<cfproperty name="uploadID" 		type="numeric" 	hint = "" />
	<cfproperty name="bbHeaderID" 		type="numeric" 	hint = "" />
	<cfproperty name="bbHdrCounter" 	type="numeric" 	hint = "" />
	<cfproperty name="vendorId" 		type="string" 	hint = "Vendor_ID" />
	<cfproperty name="vendorName" 		type="string" 	hint = "Vendor_Name" />
	<cfproperty name="shipTo" 		type="string" 	hint = "Claim_Org_ID" />
	<cfproperty name="BBReference" 		type="string" 	hint = "Claim_Num" />
	<cfproperty name="BBDate" 		type="string" 	hint = "Claim_Date" />
	<cfproperty name="startDate" 		type="string" 	hint = "Period_St_Date" />
	<cfproperty name="endDate" 		type="string" 	hint = "Period_End_Date" />
	<cfproperty name="BBAmount" 		type="string" 	hint = "E_Total_Claimed_Amt" />
	<cfproperty name="TotalVolume" 		type="string" 	hint = "Tot_Volume" />
	<cfproperty name="errMsg" 		type="string" 	hint = "" />
	<cfproperty name="errType" 		type="string" 	hint = "" />
	<cfproperty name="errObj" 		type="mvc.Models.Billback.vos.BBUploadHeaderError" 	hint = "" />				
	<cfproperty name="uploadType" 		type="string" 	hint = "" />	
	<cfproperty name="locked" 		type="boolean" 	hint= "locking status finder" />
	<cfproperty name="lockedUser" 		type="mvc.Models.Entity.vos.User" hint= "User who locked the upload_ID" />
	<cfproperty name="lockedByOther" 	type="boolean" hint= "Is the upload_ID locked by another user" />
	<cfproperty name="lockedDateTime" 	type="Date" 	hint= "User who locked the upload_ID" />
	<cfproperty name="uploadUser" 		type="mvc.Models.Entity.vos.User" hint= "User who uploaded the file" />
	<cfproperty name="uploadDateTime" 	type="Date" 	hint= "Date of file upload" />
	<cfproperty name="updatedDate" 		type="Date" 	hint= "updated date" />
 	<cfproperty name="processed" 		type="boolean" 	hint= "locking status finder" />	
	<cfproperty name="bbUploadDetail" 	type="array" 	hint="array of mvc.Models.Billback.vos.BBUploadDetail" />
	<cfproperty name="billbackTitle" 	type="string" 	hint = "" />
	<cfproperty name="operatorLegacyID"	type="string" 	hint = "Header_error_correction.Operator_ID" />	
	<cfproperty name="uploadStatus" 	type="string" 	hint = "" />
	<cfproperty name="agreementNum" 	type="string" 	hint = "agreement_Num" />
	<cfproperty name="agreementName" 	type="string" 	hint = "agreement_Name" />
	<cfproperty name="isSelected" 	type="boolean" 	hint = "" />
	
	 
	<cfscript>													
														
		this.uploadID 			= "";
		this.bbHeaderID 		= "";
		this.bbHdrCounter		= "";
		this.vendorId			= "";
		this.vendorName			= "";
		this.shipTo			= "";
		this.BBReference		= "";
		this.BBDate			= "";
		this.startDate			= "";
		this.endDate			= "";
		this.BBAmount			= "";
		this.TotalVolume		= "";
		this.errMsg 			= "";
		this.errType 			= "";
		this.errObj			= "";
		this.uploadType		 	= "";												
		this.locked 			= 0;
		this.lockedUser 		= "";
		this.lockedByOther		= 0;
		this.lockedDateTime		= "";
	  	this.uploadUser			= "";
		this.uploadDateTime		= "";
		this.updatedDate		= "";
		this.processed			= 0;
		this.bbUploadDetail		= arrayNew(1);
		this.billbackTitle		= "";
		this.operatorLegacyID		= "";
		this.uploadStatus 		= "";
		this.agreementNum		= "";
		this.agreementName		= "";
		this.isSelected = 0;
		//(End) These are of type object. In CF, we can get away with just initializing it like a string 
	</cfscript>

	<cffunction name="init" output="false" returntype="BBUploadHeader">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>