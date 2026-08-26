component alias="mvc.Models.Entity.vos.UserPosition" output="false"
{
	property name="userPositionsId" type="numeric" default="0";
	property name="positionLabel" type="string" default="";

	//initialize
		this.userPositionsId= 1;
		this.positionLabel = "";

	function init (userPositionsId = 0,
					positionLabel = "") output="false" returntype="mvc.Models.Entity.vos.UserPosition"
	{
		this.userPositionsId = arguments.userPositionsId;
		this.positionLabel = arguments.positionLabel;
		return this;
	}
	
}