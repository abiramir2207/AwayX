component alias="mvc.Models.Billback.vos.BBDistributor" output="false"
{
	property name="shipTo" type="string" default="";
	property name="address" type="string" default="";
	property name="arrBBProdRate" type="array";

	// initialize
	this.shipTo = "";
	this.address = "";
	this.arrBBProdRate = arrayNew(1);

	// init function	
	private function init(shipTo="", address="", arrBBProdRate=arrayNew(1)) output="false" returntype="mvc.Models.Billback.vos.BBDistributor"
	{
		this.shipTo = arguments.shipTo;
		this.address = arguments.address;
		this.arrBBProdRate = arguments.arrBBProdRate;
		return this;
	}
	
}