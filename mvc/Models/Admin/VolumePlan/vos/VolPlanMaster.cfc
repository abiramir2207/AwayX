component alias="mvc.Models.Admin.VolumePlan.vos.VolPlanMaster" output="false"
{

	property name="isSelected" type="boolean" default="0";
	property name="volPlanMasterId" type="numeric" default="0";
	property name="description" type="string" default="";
	property name="baseline" type="string" default="";
	property name="source" type="mvc.Models.Admin.VolumePlan.vos.VolPlanSource";
	property name="status" type="mvc.Models.Admin.VolumePlan.vos.volPlanStatus";
	property name="calendar" type="mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar" default="";
	property name="recaptureTemplates" type="array" default="";
	property name="itemPlanGroupType" type="mvc.Models.Admin.PlanGroup.vos.PlanGroupType" default="";
	property name="customerPlanGroupType" type="mvc.Models.Admin.PlanGroup.vos.PlanGroupType" default="";
	property name="volPlans" type="array" default="";
	property name="locked" type="boolean" default="0";
	property name="xxx" type="boolean" default="0";
	property name="createdDate" type="date" default="";

	//initialize
	//this.oVolPlanSource = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanSource');
	//this.ovolPlanStatus = createObject('component','mvc.Models.Admin.VolumePlan.vos.volPlanStatus');
	variables.dao = createObject('component','mvc.Models.Admin.VolumePlan.VolPlanDAO').init();
	variables.oVolPlan = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlan').init();
	variables.oVolPlanSource = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanSource').init();
	variables.oVolPlanStatus = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanStatus').init();
	variables.oVolPlanCalendar = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar').init();
	variables.oVolPlanTemplate = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanTemplate').init();
	variables.oVolPlanCustomer = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanCustomer').init();
	variables.oItemPlanGroupType = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroupType').init();
	variables.oCustomerPlanGroupType = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroupType').init();
	variables.oPlanGroup = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroup').init();
	variables.oUserPosition = createObject('component','mvc.Models.Entity.vos.UserPosition').init();
	
	this.volPlanMasterId = 0;
	this.baseline = "";
	this.source = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanSource').init();
	this.status = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanStatus').init();
	this.locked = 0;
	this.calendar = createObject('component','mvc.Models.Admin.VolumePlan.vos.VolPlanCalendar').init();
	this.recaptureTemplates = arrayNew(1);
	this.planGroupType = createObject('component','mvc.Models.Admin.PlanGroup.vos.PlanGroupType').init();
	this.volPlans = arrayNew(1);
	this.createdDate = '';


	public function init (
							volPlanMasterId = 0,
							isSelected = 0,
							description = "",
							baseline = "",
							source = "",
							status = "",
							calendar = "",
 							recaptureTemplates = arrayNew(1),
 							itemPlanGroupType = "",
							customerPlanGroupType = "",
							volPlans = arrayNew(1),
							locked = 0,
							createdDate = now()) output="false"returntype="mvc.Models.Admin.VolumePlan.vos.VolPlanMaster"
	{
		this.isSelected = arguments.isSelected;
		this.volPlanMasterId = arguments.volPlanMasterId;
		this.description = arguments.description;
		this.baseline = arguments.baseline;
		this.setSource(arguments.source);
		this.setStatus(arguments.status);
		this.locked = arguments.locked;
		this.setCalendar(arguments.calendar);
		this.recaptureTemplates = arguments.recaptureTemplates;//
		this.setItemPlanGroupType(arguments.itemPlanGroupType);//mvc.Models.Admin.PlanGroup.vos.PlanGroupType
		this.setCustomerPlanGroupType(arguments.customerPlanGroupType);//mvc.Models.Admin.PlanGroup.vos.PlanGroupType
		this.volPlans = arguments.volPlans;//mvc.Models.Admin.VolumePlan.vos.VolumePlan
		this.createdDate= arguments.createdDate;
		return this;
	}
	
	public function setSource(source) output="false"
	{
		//call dao to get source details based on ID.  then repopulate
		if(isObject(arguments.source)){
				this.source = arguments.source;
		}
		else{
			this.source = variables.oVolPlanSource;
		}

	}
	
	public function setStatus(status) output="false"
	{
		//call dao to get source details based on ID
		if(isObject(arguments.status)){
				this.status = arguments.status;
		}
		else{
			this.status = variables.oVolPlanStatus;
		}

	}
	
	public function setCalendar(calendar) output="false"
	{
		//call dao to get source details based on ID
		if(isObject(arguments.calendar)){
				this.calendar = arguments.calendar;	
		}
		else{
			this.calendar = variables.oVolPlanCalendar;
		}
	}
	
	public function setItemPlanGroupType(planGroupType) output="false"
	{
		//call dao to get source details based on ID
		if(isObject(arguments.planGroupType)){
				this.itemPlanGroupType = arguments.planGroupType;	
		}
		else{
			this.itemPlanGroupType = variables.oItemPlanGroupType;
		}
	}
	
	public function setCustomerPlanGroupType(planGroupType) output="false"
	{
		//call dao to get source details based on ID
		if(isObject(arguments.planGroupType)){
				this.customerPlanGroupType = arguments.planGroupType;	
		}
		else{
			this.customerPlanGroupType = variables.oCustomerPlanGroupType;
		}
	}
	
	function loadFromDb(string userId) output="false" access="public"
	{
		var stVpmaster = '';
		var stSource = '';
		var stStatus = '';
		var stCalendar = '';
		var stItemGroupType = '';
		var stCustomerGroupType = '';
		var arrRecaptureTemplates = arrayNew(1);
		var arrVolPlans = arrayNew(1);
		var arrVolPlanPosition = arrayNew(1);
		var arrVolPlanCustomer = arrayNew(1);
		var stInnerLoop = '';
		var qdata = '';
		var qdataInner = '';
		var qdataVp = '';
		var stVpLoop = '';
		WriteLog(file="application", text="#this.volPlanMasterId# :: loadFromDb() VPMaster"); 
		//call dao to get source details based on ID
		if(this.volPlanMasterId){
				//this.init(this.volPlanMasterId);
				qData = variables.dao.getVolPlanMaster(this.volPlanMasterId,arguments.userId);
				WriteLog(file="application.log", text="#qData.recordCount# & ' :: qdata in loadFromDb()"); 
				// Loop over the records in the query.
				for (
						intRow = 1 ;
						intRow LTE qData.RecordCount ;
						intRow ++
						){
						/*....................Inner loops for 1:many ARRAYS ................*/
						//recapture
						arrRecaptureTemplates = this.getVolPlanRecaptureDB(qData['volPlanMasterId'][intRow]);
						
						arrVolPlans = this.getVolPlansDB(qData['volPlanMasterId'][intRow]);
						// Output the name some values. When doing so, access the
						stSource = variables.oVolPlanSource.init(		qData['idSource'][intRow],
																		qData['descSource'][intRow]);
																		
						stStatus = variables.oVolPlanStatus.init(		qData['idStatus'][intRow],
																		qData['descStatus'][intRow]);
																		
						stCalendar = variables.oVolPlanCalendar.init(	qData['type'][intRow],
																		qData['year'][intRow],
																		qData['start'][intRow],
																		qData['end'][intRow]);
																		
						stItemGroupType = variables.oItemPlanGroupType.init(	qData['itemTypeId'][intRow],
																				qData['itemCode'][intRow],
																				qData['itemName'][intRow],
																				qData['itemGroupTypeId'][intRow]);
						WriteLog(file="application.log", text="#qData['customerTypeId'][intRow]# & ' :: custGroupType"); 
						stCustomerGroupType = variables.oCustomerPlanGroupType.init(	qData['customerTypeId'][intRow],
																						qData['customerCode'][intRow],
																						qData['customerName'][intRow],
																						qData['customerGroupTypeId'][intRow]);
						//populate array of category members
						stCustomerGroupType.setArrPlanGroupsFromDB();
						// TODO: we may not need this.  members are only for processing the VP
						// stGroupType.setMembers();
						this.volPlanMasterId = qData['volPlanMasterId'][intRow];
						this.description = qData['description'][intRow];
						this.baseline = qData['baseline'][intRow];
						this.setSource(stSource);
						this.setStatus(stStatus);
						this.locked = qData['locked'][intRow];
						this.setCalendar(stCalendar);
						this.recaptureTemplates = arrRecaptureTemplates;//
						this.itemPlanGroupType = stItemGroupType;//mvc.Models.Admin.PlanGroup.vos.PlanGroupType
						this.customerPlanGroupType = stCustomerGroupType;//mvc.Models.Admin.PlanGroup.vos.PlanGroupType
						this.volPlans = arrVolPlans;//mvc.Models.Admin.VolumePlan.vos.VolumePlan
						
						/*vpMaster = this.init(qData['id'],
											qData['baseline'],
											stSource,
											stStatus,
											qData['locked'],
											stCalendar,
											arrRecaptureTemplates,
											stGroupType,
											arrVolPlans);*/
				}
				
		}
	}
	public function getVolPlansDB(numeric volPlanMasterId) output="false" returntype="Array" {
		
		var arrVolPlans = arrayNew(1);
		var arrVolPlanPosition = arrayNew(1);
		var arrVolPlanCustomer = arrayNew(1);
		var arrVolPlanCustomerPg = arrayNew(1);
		var stInnerLoop = '';
		var qdata = '';
		var qdataInner = '';
		var qdataCust = '';
		var qdataPos = '';
		var stCust = '';
		var  stPos = '';
		//VolPlans
		qdataInner = variables.dao.getVolPlans(arguments.volPlanMasterId);
		for (	i=1;
				i LTE qdataInner.RecordCount;
				i++) 
				{
					
					//....................................................................
					//POSITIONS
					qdataPos = variables.dao.getVolPlanPositions(qdataInner['id'][i]);
					for (	x=1;
							x LTE qdataPos.RecordCount;
							x++)
							{
								stPos = variables.oUserPosition.init(qdataPos['userPositionsId'][x],
																		qdataPos['positionLabel'][x] );
								arrayAppend(arrVolPlanPosition,duplicate(stPos));
							}
					
					//....................................................................
					//....................................................................
					//CUSTOMERS PG
					qdataCust = variables.dao.getVolPlanCustomersPg(qdataInner['id'][i]);
					for (	z=1;
							z LTE qdataCust.RecordCount;
							z++)
							{
								stCust = variables.oPlanGroup.init(	qdataCust['typeId'][z],
																		qdataCust['categoryId'][z],
																		qdataCust['code'][z],
																		qdataCust['name'][z]
																		);
								arrayAppend(arrVolPlanCustomerPg,duplicate(stCust));
							}
					//....................................................................
					//CUSTOMERS
					qdataCust = variables.dao.getVolPlanCustomers(qdataInner['id'][i]);
					for (	z=1;
							z LTE qdataCust.RecordCount;
							z++)
							{
								stCust = variables.oVolPlanCustomer.init(0,//qdataCust['typeId'][z],
																		'',//qdataCust['categoryId'][z],
																		qdataCust['customerId'][z],
																		qdataCust['name'][z]
																		);
								arrayAppend(arrVolPlanCustomer,duplicate(stCust));
							}
					
					//....................................................................
					stInnerLoop = variables.oVolPlan.init(	qdataInner['id'][i],
															qdataInner['volPlanMasterId'][i],
															qdataInner['description'][i],
															arrVolPlanPosition,
															arrVolPlanCustomer,
															arrVolPlanCustomerPg,
															ArrayNew(1),//Adjustments
															qdataInner['createdUser'][i],
															qdataInner['createdDate'][i]);
																//qdataInner['adjustments']); array

					arrayAppend(arrVolPlans,duplicate(stInnerLoop));
				}
		return arrVolPlans;
	}
	public function getVolPlanRecaptureDB(numeric volPlanMasterId) output="false" returntype="Array" {
		var arrRecaptureTemplates = arrayNew(1);
		var stInnerLoop = '';
		var qdata = '';
		var qdataInner = '';
		var qdataVp = '';
		var stVpLoop = '';
		//recapture
		qdataInner = variables.dao.getVolPlanRecapture(arguments.volPlanMasterId);
		for (	i=1;
				i LTE qdataInner.RecordCount;
				i++) 
				{
					stInnerLoop = variables.oVolPlanTemplate.init(qdataInner['id'][i],
																qdataInner['genericType'][i],
																qdataInner['createdType'][i],
																qdataInner['firstParentId'][i] );
					
					arrayAppend(arrRecaptureTemplates,duplicate(stInnerLoop));
				}
		return arrRecaptureTemplates;
	}
	
	
}