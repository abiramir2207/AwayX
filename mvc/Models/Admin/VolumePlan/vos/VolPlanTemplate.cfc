component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanTemplate" output="false"
{

	property name="id" type="numeric" default="0";
	property name="genericType" type="string" default="";
	property name="createdType" type="String" default="";
	property name="firstParentId" type="numeric" default="0";

	//initialize
	variables.dao = createObject('component','mvc.Models.Admin.VolumePlan.VolPlanDAO').init();
	
	this.id= 0;
	this.genericType = "";
	this.createdType = "";
	this.firstParentID= 0;

	function init (id = 0,
					genericType = "",
					createdType = "",
					firstParentId = 0) output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanTemplate"
	{
		this.id = arguments.id;
		this.genericType = arguments.genericType;
		this.createdType = arguments.createdType;
		this.firstParentId = arguments.firstParentId;
		return this;
	}
	
	public function loadFromDb(numeric volPlanMasterId = 0, templateId = 0 )
		output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanTemplate"
	{
		var stCalendar = '';
		var arrRecaptureTemplates = arrayNew(1);
		var arrVolPlans = arrayNew(1);
		var stRecaptureInner = '';
		var qdataInner = '';
		
		qdataInner = variables.dao.getVolPlanRecapture(arguments.volPlanMasterId, arguments.volPlanMasterId);
		/*....................Inner loops for 1:many  ................*/
		//recapture
		/*for (	i=1;
				i LTE qdataInner.RecordCount;
				i++) 
				{
					*/
					this.id = qdataInner['id'];
					this.genericType = qdataInner['genericType'];
					this.createdType = qdataInner['createdType'];
					this.firstParentID = qdataInner['firstParentId'];
					
					arrayAppend(arrRecaptureTemplates,stRecaptureInner);
				/*}*/
		
	}
	
}