component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanMasterDef" output="false"
{

	property name="baseline" type="array" default="";
	property name="source" type="array" default="";
	property name="calendar" type="array" default="";
	property name="recaptureTemplates" type="array" default="";
	property name="itemPlanGroupType" type="array" default="";
	property name="customerPlanGroupType" type="array" default="";
	property name="userPositions" type="array" default="";
	
	variables.dao = createObject('component','mvc.Models.Admin.VolumePlan.VolPlanDAO').init();
	variables.daoPlanGroup = createObject('component','mvc.Models.Admin.PlanGroup.PlanGroupDAO').init();
	variables.oVolPlanSource = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanSource').init();
	variables.oVolPlanStatus = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanStatus').init();
	variables.oVolPlanCalendar = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar').init();
	variables.oVolPlanTemplate = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanTemplate').init();
	variables.oPlanGroupType = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroupType').init();
	variables.oUserPosition = createObject('component','mvc.Models.Entity.vos.UserPosition').init();

	//initialize
	variables.dao = createObject('component','mvc.Models.Admin.VolumePlan.VolPlanDAO').init();
	
	this.baseline= "";
	this.source = "";
	this.calendar = "";
	this.recaptureTemplates = "";
	this.planGroupType = "";
	this.userPositions = "";

	function init (baseline = "",
					source = "",
					calendar = "",
					recaptureTemplates = "",
					itemPlanGroupType = "",
					customerPlanGroupType = "",
					userPositions = "") output="false" returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanMasterDef"
	{
		this.baseline= arguments.baseline;
		this.source = arguments.source;
		this.calendar = arguments.calendar;
		this.recaptureTemplates = arguments.recaptureTemplates;
		this.itemPlanGroupType = arguments.itemPlanGroupType;
		this.customerPlanGroupType = arguments.customerPlanGroupType;
		this.userPositions = arguments.userPositions;
		return this;
	}
	
	public function loadFromDb()
		output="false"
	{

		var arrbaseline = arrayNew(1);
		var arrsource = arrayNew(1);
		var arrcalendar = arrayNew(1);
		var arrRecaptureTemplates = arrayNew(1);
		var arrItemplanGroupType = arrayNew(1);
		var arrCustomerplanGroupType = arrayNew(1);
		var arrUserPositions = arrayNew(1);
		var stInnerLoop = '';
		var qDataInner = '';
		
		
		/*....................populate arrays  ................*/
		//baseline

		stInnerLoop = 'YAG';
		arrayAppend(arrbaseline,duplicate(stInnerLoop));

		//source
		qDataInner = variables.dao.getVolPlanMasterSource();
		for (var i=1;
				i LTE qDataInner.RecordCount;
				i++) 
				{
					stInnerLoop = variables.oVolPlanSource.init( qDataInner['idSource'][i],
																 qDataInner['descSource'][i]);
					arrayAppend(arrsource,duplicate(stInnerLoop));
					
					WriteLog(file="application.log", text="#qDataInner.recordCount# :: #i#  :: #qDataInner['idSource'][i]# :: source"); 
				}
		
		//calendar
		qDataInner = variables.dao.getVolPlanMasterCalendar();
		for (var i=1;
				i LTE qDataInner.RecordCount;
				i++) 
				{
					stInnerLoop = variables.oVolPlanCalendar.init(	qDataInner['Cal_Type'][i],
																	qDataInner['VP_Year'][i],
																	qDataInner['Start_Date'][i],
																	qDataInner['End_Date'][i]);
					arrayAppend(arrCalendar,duplicate(stInnerLoop));
				}
		WriteLog(file="application.log", text="#qDataInner.recordCount# :: #i#  :: calendar"); 
		//recapture
		qDataInner = variables.dao.getVolPlanMasterTemplates();
		for (var i=1;
				i LTE qDataInner.RecordCount;
				i++) 
				{
					stInnerLoop = variables.oVolPlanTemplate.init(	qDataInner['id'][i],
																	qDataInner['genericType'][i],
																	qDataInner['createdType'][i],
																	qDataInner['firstParentId'][i] );
					arrayAppend(arrRecaptureTemplates,duplicate(stInnerLoop));
				}
		WriteLog(file="application.log", text="#qDataInner.recordCount# :: #i# :: recapture"); 
		//product plan group type
		qDataInner = variables.daoPlanGroup.getPlanGroupTypeByGrpType(1); //pass "1" to get items
		for (var 	i=1;
				i LTE qDataInner.RecordCount;
				i++) 
				{
					stInnerLoop = variables.oPlanGroupType.init(	qDataInner['PG_Type_ID'][i],
																qDataInner['PG_Type_Code'][i],
																qDataInner['PG_Type_Name'][i],
																qDataInner['PG_Group_Type'][i]);
					//populate array of category members
					stInnerLoop.setArrPlanGroupsFromDB();
					arrayAppend(arrItemPlanGroupType,duplicate(stInnerLoop));
				}
		//Customer plan group type
		qDataInner = variables.daoPlanGroup.getPlanGroupTypeByGrpType(2); //pass "2" to get customers
		for (var i=1;
				i LTE qDataInner.RecordCount;
				i++) 
				{
					stInnerLoop = variables.oPlanGroupType.init(qDataInner['PG_Type_ID'][i],
													qDataInner['PG_Type_Code'][i],
													qDataInner['PG_Type_Name'][i],
													qDataInner['PG_Group_Type'][i]);
					//populate array of category members
					stInnerLoop.setArrPlanGroupsFromDB();
					arrayAppend(arrCustomerPlanGroupType,duplicate(stInnerLoop));
				}
		//userPositions
		qDataInner = variables.dao.getVolPlanUserPositons();
		for (var i=1;
				i LTE qDataInner.RecordCount;
				i++) 
				{	
					if(trim(qDataInner['Position_Label'][i]) != ''){
						stInnerLoop = variables.oUserPosition.init(	qDataInner['User_Positions_ID'][i],
																	qDataInner['Position_Label'][i]);
																	/*& ' :: ' & qDataInner['Zone_Name'][i] & ' :: ' & qDataInner['Region_Name'][i] & ' :: ' & qDataInner['Market_Name'][i]*/
																	
					}
					
					//WriteLog(file="application.log", text="#qDataInner['Position_Label'][i]# :: #qDataInner['User_Positions_ID'][i]# :: #i#  ::position");
					arrayAppend(arrUserPositions,duplicate(stInnerLoop));
				}
		//SET ALL OF THE PROPERTIES
		this.baseline = arrbaseline;
		this.source = arrsource;
		this.calendar = arrCalendar;
		this.recaptureTemplates = arrRecaptureTemplates;
		this.itemPlanGroupType = arrItemPlanGroupType;
		this.customerPlanGroupType = arrCustomerPlanGroupType;
		this.userPositions = arrUserPositions;
	}
	
}
