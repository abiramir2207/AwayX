<cfcomponent output="false" displayname="BBHeader" alias="mvc.Models.Billback.vos.BBHeader">
	<cfproperty name="isSelected" type="boolean" />
	<cfproperty name="billbackIDInt" type="int" />
	<cfproperty name="billbackIDGUID" type="String" />
	<cfproperty name="BBCode" type="string" />
	<cfproperty name="BBNumber" type="string" />
	<cfproperty name="referenceNumber" type="string" />
	<cfproperty name="UploadedBillback" type="int" />
	<cfproperty name="searchableBBCode" type="string" />
	<cfproperty name="title" type="string" />
	<cfproperty name="amount" type="numeric" />
	<cfproperty name="approvedAmount" type="numeric" />
	<cfproperty name="finalSelectedAmount" type="numeric" />
	<cfproperty name="expectedAmt" type="numeric" />
	<cfproperty name="createdDate" type="date" />
	<cfproperty name="requestApprovalDate" type="date" />
	<cfproperty name="BBDate" type="date" />
	<cfproperty name="BBReceivedDate" type="date" />
	<cfproperty name="startDate" type="date" />
	<cfproperty name="endDate" type="date" />
	<cfproperty name="approvedDate" type="date" />
	<cfproperty name="paidDate" type="date" />
	<cfproperty name="documentAttached" type="boolean" />
	<cfproperty name="checkNumber" type="String" />
	<cfproperty name="documentNumber1" type="String" />
	<cfproperty name="documentNumber2" type="String" />
	<cfproperty name="status" type="mvc.Models.Billback.vos.Status" />
	<cfproperty name="closingMethod" type="mvc.Models.Billback.vos.ClosingMethod" />
	<cfproperty name="BBtype" type="mvc.Models.Billback.vos.Type" />
	<cfproperty name="analyst" type="mvc.Models.Entity.vos.User" />
	<cfproperty name="creator" type="mvc.Models.Entity.vos.User" />
	<cfproperty name="requestApproval" type="mvc.Models.Entity.vos.User" />
	<cfproperty name="disagree" type="mvc.Models.Entity.vos.User" />
	<cfproperty name="reset" type="mvc.Models.Entity.vos.User" />
	<cfproperty name="approved" type="mvc.Models.Entity.vos.User" />
	<cfproperty name="payee" type="mvc.Models.Entity.vos.Payee" />
	<cfproperty name="vendor" type="mvc.Models.Entity.vos.Payee" />
	<cfproperty name="resetAllowed" type="boolean" />
	<cfproperty name="deleteAllowed" type="boolean" />
	<cfproperty name="releaseAllowed" type="boolean" />
	<cfproperty name="holdAllowed" type="boolean" />
	<cfproperty name="massApproveAllowed" type="boolean" />
	<cfproperty name="deviationAllowed" type="boolean">
	<cfproperty name="locked" type="boolean">
	<cfproperty name="lockedByOther" type="boolean">
	<cfproperty name="lockedBy" type="String">
	<!---<cfproperty name="bSpecialHandling" type="boolean">--->
	<cfproperty name="details" type="mvc.Models.Billback.vos.BBDetails">
	<!---<cfproperty name="bbClosingDetail" type="array" />--->
	<cfproperty name="deviated" type="boolean" />
	<!---<cfproperty name="paymentNotes" type="string" hint="used in settlement to attach notes to a check.  Remittance" />--->
	<cfproperty name="bbSettlement" type="mvc.Models.Billback.vos.BBSettlement" />
	<cfproperty name="checkDate" type="date" />
	<cfproperty name="checkAmount" type="numeric" />
	<cfproperty name="reassignAllowed" type="boolean" />
	<cfproperty name="billTo" type="mvc.Models.Entity.vos.BillTo" />
	<cfproperty name="copyAction" type="boolean">
	<cfproperty name="notAcknowledged" type="boolean">
	<cfproperty name="bDisplaySettlement" type="boolean">
	<cfproperty name="strDefaultProgram" type="string">
	<cfproperty name="UploadID" type="numeric" />
	<cfproperty name="BBUploadDupGroupID" type="numeric" />
	<cfproperty name="strErrorMessage" type="string">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.isSelected = 0;
		this.billbackIDInt= 0;
		this.billbackIDGUID= "";
		this.BBCode= "";
		this.BBNumber= "";
		this.referenceNumber= "";
		this.UploadedBillback = 0;
		this.searchableBBCode = "";
		this.title= "";
		this.amount= 0;
		this.approvedAmount= 0;
		this.finalSelectedAmount = 0;
		this.expectedAmt = 0;
		this.createdDate= "#now()#";
		this.requestApprovalDate= "#now()#";
		this.BBDate= "#now()#";
		this.BBReceivedDate = "#now()#";
		this.startDate= "#now()#";
		this.endDate= "#now()#";
		this.approvedDate= "#now()#";
		this.paidDate= "#now()#";
		this.documentAttached= 0;
		this.checkNumber = "";
		this.documentNumber1 = "";
		this.documentNumber2 = "";
		//(Start) These are of type object. In CF, we can get away with just initializing it like a string or numeric -> NO WE CANT
		this.status = CreateObject("component","mvc.Models.Billback.vos.Status");
		this.closingMethod = CreateObject("component","mvc.Models.Billback.vos.ClosingMethod");
		this.BBtype = CreateObject("component","mvc.Models.Billback.vos.Type");
		this.analyst = CreateObject("component","mvc.Models.Entity.vos.User");
		this.creator = CreateObject("component","mvc.Models.Entity.vos.User");
		this.requestApproval = CreateObject("component","mvc.Models.Entity.vos.User");
		this.disagree = CreateObject("component","mvc.Models.Entity.vos.User");
		this.reset = CreateObject("component","mvc.Models.Entity.vos.User");
		this.approved = CreateObject("component","mvc.Models.Entity.vos.User");
		this.payee = CreateObject("component","mvc.Models.Entity.vos.Payee");
		this.vendor = CreateObject("component","mvc.Models.Entity.vos.Payee");
		this.billTo = CreateObject("component","mvc.Models.Entity.vos.BillTo");

		//(End) These are of type object. In CF, we can get away with just initializing it like a string  -> NO WE CANT
		this.resetAllowed= 0;
		this.deleteAllowed = 0;
		this.massApproveAllowed = 0;
		this.deviationAllowed = 0;
		//this.bSpecialHandling = 0;
		this.details = CreateObject("component","mvc.Models.Billback.vos.BBDetails");
		//this.bbClosingDetail = "";
		this.deviated = 0;
		this.locked = 0;
		this.lockedByOther = 0;
		this.lockedBy = "";
		//this.paymentNotes = "";
		this.bbSettlement = CreateObject("component","mvc.Models.Billback.vos.BBSettlement");
		this.checkDate = "#now()#";
		this.checkAmount = 0;
		this.reassignAllowed = 0;
		this.copyAction = 0;
		this.notAcknowledged = 0;
		this.bDisplaySettlement = 0;
		this.strDefaultProgram = "";
		this.UploadID = 0;
		this.BBUploadDupGroupID = 0;
		this.strErrorMessage = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBHeader">
		<cfreturn this>
	</cffunction>

</cfcomponent>