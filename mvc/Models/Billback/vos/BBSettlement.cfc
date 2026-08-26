component  output="false" displayname="BBSettlement" alias="mvc.Models.Billback.vos.BBSettlement"  hint="Settlement properties including approval permissions"
{
	/* bbClosingDetail here is actually of type "BBClosingDetail" */
	property name="bbClosingDetail" 			type="array";
	property name="bSpecialHandling" 			type="Boolean";
	property name="bIsBillbackWithinBudget" 	type="Boolean";
	property name="paymentNotes" 				type="string";
	property name="templateApproval" 			type="Boolean";
	property name="lastDateToClaim" 			type="Boolean";
	property name="bIsReversible"				type="Boolean";
	

	//initialize properties
	this.bbClosingDetail 			= arrayNew(1);
	this.bSpecialHandling 			= 0;
	this.bIsBillbackWithinBudget 	= 0;
	this.paymentNotes 				= '';
	this.templateApproval 			= 0;
	this.lastDateToClaim 			= 0;
	this.bIsReversible				= 0;

	
	public function init	(	bbClosingDetail			= arrayNew(1),
								bSpecialHandling 		= 0,
								bIsBillbackWithinBudget = 0,
								paymentNotes 			= '',
								templateApproval 		= 0,
								lastDateToClaim			= 0,
								bIsReversible			= 0
							) output="false" returntype="mvc.Models.Billback.vos.BBSettlement"
	{
		this.bbClosingDetail 			= bbClosingDetail;
		this.bSpecialHandling 			= bSpecialHandling;
		this.bIsBillbackWithinBudget 	= bIsBillbackWithinBudget;
		this.paymentNotes 				= paymentNotes;
		this.templateApproval 			= templateApproval;
		this.lastDateToClaim 			= lastDateToClaim;
		this.bIsReversible				= bIsReversible;
		return this;
	}

}