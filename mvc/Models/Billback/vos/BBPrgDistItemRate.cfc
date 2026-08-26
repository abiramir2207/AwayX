component alias="mvc.Models.Billback.vos.BBPrgDistItemRate" output="false"
{
	// BB Program
	property name="bbProgram"		type="mvc.Models.Billback.vos.BBProgram";
	// BB Distributor
	property name="bbDistributor"	type="mvc.Models.Entity.vos.Customer";
	// BB ProdRate
	property name="bbProdRate"		type="mvc.Models.Billback.vos.BBProdRate";
	property name="uomDp"			type="array";
	property name="message"			type="string";
	property name="bFirstTime"		type="Boolean";

	// initialize
	this.bbProgram = CreateObject("component","mvc.Models.Billback.vos.BBProgram");
	this.bbDistributor = CreateObject("component","mvc.Models.Entity.vos.Customer");
	this.bbProdRate = CreateObject("component","mvc.Models.Billback.vos.BBProdRate");
	this.uomDp = arrayNew(1);
	this.message = "";
	this.bFirstTime = 0;

	// init function
	private function init(bbProgram="", bbDistributor="", bbProdRate="", uomDp=arrayNew(1), message="",bFirstTime=0) output="false" returntype="mvc.Models.Billback.vos.BBPrgDistItemRate"
	{
		this.bbProgram 			=	arguments.bbProgram;
		this.bbDistributor 		=	arguments.bbDistributor ;
		this.bbProdRate 		=	arguments.bbProdRate ;
		this.uomDp		 		=	arguments.uomDp ;
		this.message			= 	arguments.message;
		this.bFirstTime			= 	arguments.bFirstTime;
		return this;
	}
}