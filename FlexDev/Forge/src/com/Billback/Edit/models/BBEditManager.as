package com.Billback.Edit.models
{
	import com.Billback.Edit.events.BBEditEvent;
	import com.Billback.Edit.models.vos.BBProdRate;
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Edit.views.BBEditSum;
	import com.Billback.Edit.views.BBEditWorkflow;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBClosingDetail;
	import com.Billback.Main.models.vos.BBComponent;
	import com.Billback.Main.models.vos.BBDetails;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Main.models.vos.BBPrgDistItemRate;
	import com.Billback.Main.models.vos.BBProgram;
	import com.Billback.Main.models.vos.Billback;
	import com.Billback.Main.models.vos.ClosingMethod;
	import com.Billback.Main.models.vos.Payee;
	import com.Billback.Main.models.vos.Status;
	import com.Deduction.Main.models.vos.Deduction;
	import com.shared.components.StringUtils;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.BillTo;
	import com.shared.models.entity.vos.Customer;
	import com.shared.models.entity.vos.Lock;
	import com.shared.models.entity.vos.Operator;
	import com.shared.models.entity.vos.User;
	import com.shared.vos.Component;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	import com.shared.vos.Uom;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.rpc.Fault;
	import mx.utils.ObjectUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	public class BBEditManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function BBEditManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}		
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		//public var bbPrgDistItemRate:BBPrgDistItemRate = new BBPrgDistItemRate();
		//[Bindable] public var acMenuData:ArrayCollection = new ArrayCollection();		
		[Bindable] public var uomDp:Array = new Array();
		[Bindable] public var acProducts:ArrayCollection = new ArrayCollection();
		
		private var _bbLock:Lock = new Lock();
		private var _acGridDataFlat:ArrayCollection = new ArrayCollection();
		private var _closingMethodList:Array = new Array();
		private var _closingMethodListAll:Array = new Array();
		private var _acBBAnalysts:ArrayCollection = new ArrayCollection();
		private var _modifyMenu:Boolean = false;
		private var _acMenuData:ArrayCollection = new ArrayCollection();
		//	private var _reDirector:String = "EDIT";
		private var popUpWorkFlow:BBEditWorkflow = new BBEditWorkflow();
		private var popUpBBSumBy:BBEditSum = new BBEditSum();
		private var _BBToolsLock:BBToolsLock = new BBToolsLock();
		[Bindable] public var panelHeight:int = 0;
		
		private var Notification:Alert;
		private var NotificationTimer:Timer;
		
		// individual entity
		private var _selectedVendor:Payee = new Payee();	// vendor obj same as payee
		private var _selectedPayee:Payee = new Payee();		// payee obj
		private var importedPayee:Payee = new Payee();
		private var _selectedProgram:Program;
		private var _selectedDistributor:Customer;
		// private var _selectedOperator:Operator;
		
		// array collections
		private var _acPayee:ArrayCollection = new ArrayCollection();
		private var _acProgram:ArrayCollection = new ArrayCollection();
		private var _acDistributor:ArrayCollection = new ArrayCollection();
		// private var _acOperator:ArrayCollection= new ArrayCollection();
		private var _acComponent:ArrayCollection= new ArrayCollection();
		private var _billbackHeaderDetail:BBDetails =  new BBDetails();
		//	private var _bbCompExists:Boolean = true;
		//temp place holder for getVendor Alert
		private var _sPayeeId:String= "";
		private var _soAcProducts:SharedObject;
		private var _dSOlastSavedDate:Date = new Date(null);
		private var _dTodayDate:Date = new Date();
		private var bSaving:Boolean = false;
		
		/*.................Grid Data......................*/
		[Bindable (event="GridDataChanged")]
		public function get acGridDataFlat():ArrayCollection
		{
			return _acGridDataFlat;
		}
		public function set acGridDataFlat(acGridDataFlat:ArrayCollection):void
		{
			this._acGridDataFlat = acGridDataFlat;
			dispatchEvent(new Event('GridDataChanged'));
		}
		
		/*.................Billback......................*/
		private var _billback:Billback = new Billback();
		[Bindable (event="editBillbackChanged")]
		public function get billback():Billback
		{
			return _billback;
		}
		public function set billback(billback:Billback):void
		{			
			this._billback = billback;
			if (billback.bbHeader.billbackIDInt > 0 ){
				/* Set the closingDetail object */
				this.acBBClosingDetail = new ArrayCollection(billback.bbHeader.bbSettlement.bbClosingDetail);
			}
			dispatchEvent(new Event('editBillbackChanged'));
		}
		
		/*.................acMenuChanged.....................*/
		[Bindable (event="acMenuDataChanged")]
		public function get acMenuData():ArrayCollection
		{
			return _acMenuData;
		}
		
		public function set acMenuData(acMenuData:ArrayCollection):void
		{
			this._acMenuData = acMenuData;
			dispatchEvent(new Event('acMenuDataChanged'));
			//fire the menu to rebuild -> injectors wil trigger the setter in pModel
			//acMenuData = new ArrayCollection();
		}
		
		/*.................BB Tools.....................*/
		[Bindable (event="objBBToolsLockChanged")]
		public function get objBBToolsLock():BBToolsLock
		{
			return _BBToolsLock;
		}
		
		public function set objBBToolsLock(objBBToolsLock:BBToolsLock):void
		{
			this._BBToolsLock = objBBToolsLock;
			dispatchEvent(new Event('objBBToolsLockChanged'));
			//fire the menu to rebuild -> injectors wil trigger the setter in pModel
			acMenuData = new ArrayCollection();
		}
		
		/*.................closingMethods......................*/
		[Bindable (event="closingMethodChanged")]
		public function get closingMethodList():Array
		{
			return _closingMethodList;
		}
		public function set closingMethodList(closingMethodList:Array):void
		{
			
			var arrCM:Array = new Array();
			var arrCMList:Array = new Array();
			var arrCMFinalList:Array = new Array();
			var bclosingMethodListChanged:Boolean = true;
			
			/* 	If the payee is an operator, set variables for looping through "CLOSING_METHOD_ORDER_OPERATOR", so that the
			the closing methods are ordered correctly.*/
			if(this.billback.bbHeader.payee.payeeTypeId == 2){
				arrCMList = ClosingMethod.CLOSING_METHOD_ORDER_OPERATOR;
				arrCMFinalList = closingMethodList;
			}
				/* 	If the payee is not an operator, set variables for looping through "CLOSING_METHOD_ORDER", so that the
				the closing methods are ordered correctly. Note: "this._closingMethodListAll" has the
				list of all the closing methods. This is important has "closingMethodList" might get set
				to a restricted list based on operator payee*/
			else{
				arrCMList = ClosingMethod.CLOSING_METHOD_ORDER;
				arrCMFinalList = this._closingMethodListAll;
			}
			
			/* Loop through the "ORDERED" list first, so that the closing methods are ordered correctly */
			for each(var i:int in arrCMList){
				for each(var oClosingMethodDis:ClosingMethod in arrCMFinalList)
				{   
					if(oClosingMethodDis.id == i){
						arrCM.push(new ClosingMethod(oClosingMethodDis));
					}
				}
			}	
			
			this._closingMethodList = clone(arrCM);	
			dispatchEvent(new Event('closingMethodChanged'));
			
			/* 	Loop through the available closing method list based on payee type. */
			for each(var oClosingMethod:ClosingMethod in this._closingMethodList){   
				if(oClosingMethod.id == billback.bbHeader.closingMethod.id){
					bclosingMethodListChanged = false;
					break;
				}
			}
			
			/* 	If the selected closing method is not a part of the available list (after payee type change), 
			then reset the closingmethod object. This is useful since the closing method dropdown gets reset
			and we need to validate the existence of a closing method */			
			if(bclosingMethodListChanged){
				billback.bbHeader.closingMethod = new ClosingMethod();
			}
			
			// Dev Note: KAL; 31075; Flex BB - remove 'reinstate' as closing method
			if(this._closingMethodList.length){
				var nPos:Number; 
				//loop and find reinstate and remove it
				for each(var oCM:ClosingMethod in this._closingMethodList){
					if(oCM.id == 10){
						nPos = this._closingMethodList.indexOf(oCM);
						break;
					}
				}
				if(!isNaN(nPos)){this._closingMethodList.splice(nPos, 1);}				
			}
			
		}
		
		/*.................BB Analysts......................*/
		[Bindable (event="bbAnalystsChanged")]
		public function get acBBAnalysts():ArrayCollection
		{
			return _acBBAnalysts;
		}
		public function set acBBAnalysts(acAnalysts:ArrayCollection):void
		{
			this._acBBAnalysts = acAnalysts;
			dispatchEvent(new Event('bbAnalystsChanged'));			
		}
		
		/*... redirecotor to detect if the [val] was clicked on the BBSearch .....*/		
		/*	[Bindable (event="bbRedirectorChanged")]
		public function get reDirector():String
		{
		return _reDirector;
		}
		public function set reDirector(reDirector:String):void
		{
		this._reDirector = reDirector;
		dispatchEvent(new Event('bbRedirectorChanged'));			
		}		
		*/	
		
		/*.................vendor......................*/
		[Bindable (event="vendorChanged")]
		public function get selectedVendor():Payee
		{
			return _selectedVendor;
		}
		public function set selectedVendor(selectedVendor:Payee):void
		{
			this._selectedVendor = selectedVendor;
			dispatchEvent(new Event('vendorChanged'));			
		}
		
		
		/*.................Vendor......................*/
		[Bindable (event="payeeChanged")]
		public function get selectedPayee():Payee
		{
			return _selectedPayee;
		}
		public function set selectedPayee(selectedPayee:Payee):void
		{
			this._selectedPayee = selectedPayee;
			dispatchEvent(new Event('payeeChanged'));			
		}
		
		/*.................acPayee......................*/
		[Bindable (event="payeeListChanged")]
		public function get acPayee():ArrayCollection
		{
			return _acPayee;
		}
		public function set acPayee(acPay:ArrayCollection):void
		{
			this._acPayee = acPay;
			dispatchEvent(new Event('payeeListChanged'));			
		}
		
		/*.................program......................*/
		[Bindable (event="programChanged")]
		public function get selectedProgram():Program
		{
			return _selectedProgram;
		}
		public function set selectedProgram(program:Program):void
		{
			this._selectedProgram = program;
			dispatchEvent(new Event('programChanged'));			
		}
		
		/*.................acProgram......................*/
		[Bindable (event="programListChanged")]
		public function get acProgram():ArrayCollection
		{
			return _acProgram;
		}
		public function set acProgram(acPrg:ArrayCollection):void
		{
			this._acProgram = acPrg;
			dispatchEvent(new Event('programListChanged'));			
		}
		
		/*.................Distributor......................*/
		[Bindable (event="distributorChanged")]
		public function get selectedDistributor():Customer
		{
			return _selectedDistributor;
		}
		public function set selectedDistributor(selectedDistributor:Customer):void
		{
			this._selectedDistributor = selectedDistributor;
			dispatchEvent(new Event('distributorChanged'));			
		}	
		/*.................acDistributor......................*/
		[Bindable (event="distributorListChanged")]
		public function get acDistributor():ArrayCollection
		{
			return _acDistributor;
		}
		public function set acDistributor(acDist:ArrayCollection):void
		{
			this._acDistributor = acDist;
			//if the payee type is Distributor and the Distibutor isn't in the Distributor list then add it
			if (this.billback.bbHeader.payee.payeeTypeId == 1 && this.bPayeeInDistributorList(acDist) == false){
				var objCust:Customer = new Customer();
				//this._acDistributor.addItem(this.billback.bbHeader.payee as Customer());
				objCust.shipTo =  this.billback.bbHeader.payee.payeeId;
				objCust.name = this.billback.bbHeader.payee.name;
				objCust.address = this.billback.bbHeader.payee.address;
				objCust.customerId = this.billback.bbHeader.payee.payeeUUId;
				this._acDistributor.addItem(objCust);
			}
			// if there is only 1 distributor set it selected;  
			if(this._acDistributor.length == 1){this.selectedDistributor = _acDistributor[0];}
			dispatchEvent(new Event('distributorListChanged'));			
		}
		
		/*.................bbPrgDistItemRate......................*/
		private var _bbPrgDistItemRate:BBPrgDistItemRate = new BBPrgDistItemRate();
		[Bindable (event="bbPrgDistItemRateChanged")]
		public function get bbPrgDistItemRate():BBPrgDistItemRate
		{
			return _bbPrgDistItemRate;
		}
		public function set bbPrgDistItemRate(bbPrgDistItemRate:BBPrgDistItemRate):void
		{
			this._bbPrgDistItemRate = bbPrgDistItemRate;
			dispatchEvent(new Event('bbPrgDistItemRateChanged'));			
		}
		
		
		/*.................acComponent......................*/
		[Bindable (event="componentListChanged")]
		public function get acComponent():ArrayCollection
		{
			return _acComponent;
		}
		public function set acComponent(acComp:ArrayCollection):void
		{
			// loop thru the components and add only the comps with matching payee type and the claim mechanism isnt resistricted from BB			
			this._acComponent.removeAll();
			if (acComp.length){
				var bValidComponents:Boolean; // D30341: flag to hold if the program has valid components [no restrict from BB components]
				for each (var prgComp:Component in acComp)
				{
					if ((oSettings.appSettings.Billback_Display_All_Program_Components == true || this.billback.bbHeader.payee.payeeTypeId == prgComp.paidTo.paidToId) && (!prgComp.claimMechanic.restrictBB || prgComp.claimMechanic.bAutoPay))
					{
						bValidComponents = true; // D30341: set there is a valid compoent otherwise diusplay msg 
						// set the existing components from the billback as selected on the program
						for each(var bbComp:BBComponent in this.billback.bbComponent){
							// if the program is same and the componentNameId are same; then set isSelected to true;
							if (
								bbComp.programNumber == this.selectedProgram.number && 
								bbComp.componentNameId == prgComp.componentId.toString() && 
								(bbComp.componentTypeId == 2 ||  bbComp.bIsLatestVersion == false || bbComp.programComponentId.toLowerCase() == prgComp.programComponentId.toLowerCase()) &&
								(bbComp.programID == prgComp.programId || bbComp.bIsLatestVersion == false)
							){
								// Tim Ford - 10/04/2012: Label 34445 - BB Component not staying checked when program is revised
								// if the program version in billbacks is not the latest version then set the programId from billback
								if(bbComp.programID != prgComp.programId && bbComp.bIsLatestVersion == false){
									prgComp.programId = bbComp.programID;
								}
								prgComp.isSelected = true;
								// pass the amount from the BB component into prog component to display for Lumpsum;  
								if (isNaN(parseFloat(bbComp.componentAmount))){
									prgComp.amount = 0; 
								}else{
									prgComp.amount = parseFloat(bbComp.componentAmount);
								}
							}
						}
						// if there is only one component on the program then set it as selected 
						if (acComp.length == 1 && this.billback.bbComponent.length == 0){
							prgComp.isSelected = true;
							if (prgComp.type != 3){
								var evt:MainEvent = new MainEvent(MainEvent.COMPONENT_UPDATE);
								evt.component = prgComp;
								this._dispatcher.dispatchEvent(evt);
							}
						}
						this._acComponent.addItem(prgComp);
					}
				}
				// D30341: Alert the user for no valid components and when the Billback is editable;
				if(!bValidComponents && this.billback.bbHeader.locked == true && (this.billback.bbHeader.status.id == 1 ||  this.billback.bbHeader.status.id == 2)){
					var sMsg:String = 'There are no valid discounts on this program for the payee selected. \nPlease pick a different program or a different payee';
					Alert.show(sMsg,"Error Alert!");
				}
			}
			
			// Add all the other components on the billback to component display    
			for each(var bbComp2:BBComponent in this.billback.bbComponent)
			{
				if (this.selectedProgram.number != bbComp2.programNumber)
				{
					var tmpPrgComp:Component 	= new Component();
					tmpPrgComp.isSelected 		= true;
					tmpPrgComp.type 			= int(bbComp2.componentTypeId);
					tmpPrgComp.componentId 		= int(bbComp2.componentNameId);
					tmpPrgComp.name 			= bbComp2.componentName;
					tmpPrgComp.amount 			= Number(bbComp2.componentAmount);
					tmpPrgComp.programId		= bbComp2.programID;
					tmpPrgComp.programNumber	= bbComp2.programNumber;
					tmpPrgComp.programTitle		= bbComp2.programTitle;
					tmpPrgComp.paidTo			= bbComp2.paidTo;
					tmpPrgComp.compDescription	= bbComp2.compDescription;
					tmpPrgComp.compRate			= bbComp2.compRate;
					tmpPrgComp.programComponentId	= bbComp2.programComponentId;
					this._acComponent.addItem(tmpPrgComp);
				}
			}
			dispatchEvent(new Event('componentListChanged'));
			/* Depending on the number of components, we may need to increase or decrease the height of the panel to see the components */
			this.panelHeight = this._acComponent.length;
		}
		
		/*.................bb lock check......................*/
		[Bindable (event="bbLockObjChanged")]
		public function get BBLock():Lock{
			return _bbLock;
		}
		public function set BBLock(oBBLock:Lock):void{
			this._bbLock = oBBLock;
			dispatchEvent(new Event('bbLockObjChanged'));			
		}
		
		/*.................acBBDeductions......................*/
		private var _acBBDeductions:ArrayCollection = new ArrayCollection();
		[Bindable (event="acBBDeductionsChanged")]
		public function get acBBDeductions():ArrayCollection
		{
			return _acBBDeductions;
		}
		public function set acBBDeductions(ac:ArrayCollection):void
		{
			this._acBBDeductions = ac;
			dispatchEvent(new Event('acBBDeductionsChanged'));
		}
		
		/*.................acBBClosingDetail......................*/
		private var _acBBClosingDetail:ArrayCollection = new ArrayCollection();
		[Bindable (event="acBBClosingDetailChanged")]
		public function get acBBClosingDetail():ArrayCollection
		{
			return _acBBClosingDetail;
		}
		public function set acBBClosingDetail(ac:ArrayCollection):void
		{
			var acSort:ArrayCollection = new ArrayCollection();
			var arrCMList:Array = new Array();
			
			/* 	If the payee is an operator, set variables for looping through "CLOSING_METHOD_ORDER_OPERATOR", so that the
			the closing methods are ordered correctly.*/
			if(this.billback.bbHeader.payee.payeeTypeId == 2){
				arrCMList = ClosingMethod.CLOSING_METHOD_ORDER_OPERATOR;
			}
				/* 	If the payee is not an operator, set variables for looping through "CLOSING_METHOD_ORDER", so that the
				the closing methods are ordered correctly.*/
			else{
				arrCMList = ClosingMethod.CLOSING_METHOD_ORDER;
			}		
			
			/* Loop through the "ORDERED" list first, so that the closing methods are ordered correctly */
			var bDeductionCM:Boolean;
			var bReInstateCM:Boolean;
			var nPos:Number;
			var k:Number = 0;
			for each(var i:int in arrCMList){
				for each(var cd:BBClosingDetail in ac){
					if(cd.closingMethod && cd.closingMethod.id == i){
						if(cd.closingMethod.id == 2){ bDeductionCM = true;} 			// Dev Note: KAL; 31075
						if(cd.closingMethod.id == 10){ bReInstateCM = true; nPos = k;}	// Dev Note: KAL; 31075
						k++;
						acSort.addItem(cd);
						break;
					}
				}
			}
			//  Dev Note: KAL; 31075; If reinstate exisits & no deduction CM; remove reinstate
			if(bReInstateCM && !bDeductionCM){acSort.removeItemAt(nPos);}	
			this._acBBClosingDetail = acSort;
			dispatchEvent(new Event('acBBClosingDetailChanged'));
		}
		
		/*.................
		BBHeader's "detail" property. Here it comes as "BBDetails" only 	
		and not as a property of BBHeader.
		......................*/
		[Bindable (event="BillbackHeaderDetailChanged")]
		public function get billbackHeaderDetail():BBDetails
		{
			return _billbackHeaderDetail;
		}
		public function set billbackHeaderDetail(bbHeaderDetail:BBDetails):void
		{
			this._billbackHeaderDetail = bbHeaderDetail;
			dispatchEvent(new Event('BillbackHeaderDetailChanged'));
		}
		
		/*.................menu entries modified ......................*/
		[Bindable (event="modifyMenuData")]
		public function get modifyMenu():Boolean{
			return _modifyMenu;
		}
		
		public function set modifyMenu(menuModify:Boolean):void
		{
			this._modifyMenu = menuModify;
		}
		
		
		private var _acBillTo:ArrayCollection = new ArrayCollection();
		[Bindable (event="billToListChanged")]
		public function get acBillTo():ArrayCollection
		{
			return _acBillTo;
		}
		public function set acBillTo(acBillTo:ArrayCollection):void
		{
			this._acBillTo = acBillTo;
			dispatchEvent(new Event('billToListChanged'));			
		}
		
		/*.................acProgramProduct......................*/
		private var _acProgramProduct:ArrayCollection = new ArrayCollection();
		[Bindable (event="programProductListChanged")]
		public function get acProgramProduct():ArrayCollection
		{
			return _acProgramProduct;
		}
		public function set acProgramProduct(acPrgProd:ArrayCollection):void
		{
			this._acProgramProduct = acPrgProd;
			dispatchEvent(new Event('programProductListChanged'));			
		}
		
		/*-.........................................Methods..........................................*/	
		// get existing BB 
		public function getBillbackResults(bb:Billback):void{
			
			this.billback = new Billback(bb);
			
			/* When we have the billback data from the db, fire this event, so that the bbheader values are set */
			dispatchEvent(new Event('editBillbackChanged'));
			
			/* 	Initially, I was firing closing method before setting the "BClosingDetail" below. It is not needed as of now. I have just
			commented this line in case it is needed.*/
			//this.closingMethodList = closingMethodList;
			
			/* 	Set the closing detail. "closingdetail" requires new bbheader values set above. Currently, this code is needed so that whenever
			a payee is changed from distributor to operator or vice-versa, the closing method list changes on the settlement page.*/
			this.acBBClosingDetail = new ArrayCollection(this.billback.bbHeader.bbSettlement.bbClosingDetail);
			dispatchEvent(new Event('acBBClosingDetailChanged'));
			
			this.changeModuleLabel(); // call to change the title of the tab
			
			if (bb.bbHeader.billbackIDInt > 0 ){
				this.selectedVendor = bb.bbHeader.vendor;	
				this.setPayeeList(new Array(bb.bbHeader.payee));
				this.selectedPayee = bb.bbHeader.payee;				
				// get the list of programs from this BB 
				this.setBBProgramList();
				
				var e:BBEditEvent	= new BBEditEvent(BBEditEvent.GET_LOCK_BB_EDIT);		
				e.bbId				= ObjectUtil.toString(this.billback.bbHeader.billbackIDInt);
				/* 	Whenever the user clicks on "copy" from the billback edit screen to copy a billback, send "bb.bbHeader.copyAction" of "true".
				This is useful as when the value of true is "passed", the copied billback is locked and the other billbacks are unlocked. */
				e.bbUnlockExistingLockedByUser = bb.bbHeader.copyAction;
				this._dispatcher.dispatchEvent(e);
				
				/* Reset "bb.bbHeader.copyAction" from true to false. We do not want this to be true, once the "copy" action is complete */
				this.billback.bbHeader.copyAction = false;
				dispatchEvent(new Event('editBillbackChanged'));
			}
			else{
				this.billback.uomDp = this.uomDp;
			}
			// TODO: check lock
			
			//set the bb components TODO: possibly move function call because we only want to call this when loading
			this.setBBComponentList();
			/* Depending on the number of components, we may need to increase or decrease the height of the panel to see the components */
			this.panelHeight = this._acComponent.length;
			this.setProgramProduct();
		}
		
		// set the program product list
		public function setProgramProduct():void{
			var e:BBEditEvent	= new BBEditEvent(BBEditEvent.LOAD_PROGRAM_PRODUCT_LIST);		
			e.bbIdInt			= this.billback.bbHeader.billbackIDInt;
			this._dispatcher.dispatchEvent(e);
			
		}
		
		// create a new BB 
		public function createNewBillback(bb:Billback):void{
			// pass a new billback to the getBillbackResults
			
			/* Create a "date" object */
			var objTodayDate:Date = new Date();
			
			/* Get todays date (Month/Day/Year only)*/
			var sTodayDate:String = (objTodayDate.month + 1) + '/' + objTodayDate.date + '/' + objTodayDate.fullYear;
			
			var newBB:Billback = bb;
			newBB.uomDp = this.uomDp;
			/* When we pass "sTodayDate" to "new date", then we do not have any hours/seconds/milliseconds positive value. This makes sure
			that when the data is passed to CF, we reduce any timeoffset issues.
			Note: When a user uses the dataPicker to pick a date, then we already pass the date from the datepicker to "new date" and so
			any issue does not exist, but when a user chooses the default date (code below), then we have issues. The "sTodayDate" variable fixes
			that issue. Using this code, we should always pass the correct timeoffset to CF, so that CF can add or subtract time properly and the 
			time is set to 0:00:00. */
			newBB.bbHeader.BBDate = new Date(sTodayDate);
			newBB.bbHeader.startDate = new Date(sTodayDate);
			newBB.bbHeader.endDate = new Date(sTodayDate);
			newBB.receivedDate = new Date(sTodayDate);
			newBB.postDate =  new Date(sTodayDate);
			
			newBB.bbHeader.creator = new User();
			newBB.bbHeader.creator.id = oSettings.userId;
			// find the default closing method when creating a new billback
			for each (var closeMethod:ClosingMethod in this.closingMethodList){
				if (closeMethod.bDefault){
					newBB.bbHeader.closingMethod = closeMethod;
					break;
				}
			}
			//newBB.bbHeader.closingMethod = this.closingMethodList[4]; //default to payment
			
			// claimed values
			newBB.claimedAmount = 0;
			newBB.claimedCS = 0;
			newBB.claimedLB = 0;
			
			// pass the new BB
			this.getBillbackResults(newBB);
		}
		
		// Called after a Vendor changes [ BBHeaderForm.tiVendor ] and we need to clear out Program, Component Items
		//Then Load the new vendor
		public function clearBBProgCompItems(vendorId:String):void{
			selectedVendor = new Payee();
			this.billback.bbHeader.vendor = selectedVendor;
			
			selectedPayee = new Payee();
			this.billback.bbHeader.payee = selectedPayee;
			
			selectedProgram = new Program();
			
			acProgram = new ArrayCollection();
			
			selectedDistributor = new Customer();
			
			acDistributor = new ArrayCollection();
			
			bbPrgDistItemRate = new BBPrgDistItemRate();
			this.billback.bbPrgDistItemRate = new Array();
			
			this.billback.bbComponent = new Array();
			
			acComponent = new ArrayCollection();
			
			this.billback.expectedAmount = 0;
			this.billback.expectedCS = 0;
			this.billback.expectedLB = 0;
			dispatchEvent(new Event('editBillbackChanged'));
			
			//Load new Vendor
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_VENDOR);
			e.vendorId  = vendorId; 
			this._dispatcher.dispatchEvent(e);
		}
		
		// TAB TITLE
		public function changeModuleLabel():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CHANGE_LABEL);
			if(this.billback){
				e.bbHeader  = this.billback.bbHeader;
			}
			this._dispatcher.dispatchEvent(e);
		}
		
		
		// save existing BB 
		public function getBillbackSave(oBB:Billback):void{
			this.getBillbackResults(oBB);
		}
		
		// get the uomDp List
		public function getUomDp(arrUomDp:Array):void{
			this.uomDp = arrUomDp;
		}
		
		// get the items list
		public function getProductList(arrProducts:Array):void{
			this.acProducts = new ArrayCollection(arrProducts);
			this.saveSOitems();
		}
		
		// get the Analysts list
		public function getBBAnalysts(arrAnalysts:Array):void{
			this.acBBAnalysts = new ArrayCollection(arrAnalysts);
		}
		
		// set the Analyst
		public function setBBAnalyst(analyst:User):void{
			this.billback.bbHeader.analyst = analyst;
			// dispatchEvent(new Event('bbAnalystsChanged'));			
		}
		
		// component Update
		public function bbComponentUpdate(prgComp:Component):void{
			// find the matching bb Component and add/remove it from the billback;
			var tempBBComp:Array = new Array();
			var bbComp:BBComponent;
			
			//if selected add; // adding the amounts to itemized is done in BBEditItemsPModel.saveBillback();
			if (prgComp.isSelected){				
				// check for existing bb components
				for each(bbComp in this.billback.bbComponent){
					var exists:Boolean = false; 
					// if the program is same and the componentNameId are same; then set exists to true;
					if ((bbComp.programNumber ==  prgComp.programNumber) && ((bbComp.componentNameId == prgComp.componentId.toString() && bbComp.programComponentId == prgComp.programComponentId))){
						bbComp.componentAmount	= prgComp.amount.toString();
						exists = true;
						break;
					}
				}
				// if not exists add 
				if (!exists){
					// create a new BB Component to add
					bbComp = new BBComponent();
					bbComp.programID 			= prgComp.programId;
					bbComp.componentTypeId		= prgComp.type;
					bbComp.componentNameId		= prgComp.componentId.toString();		
					bbComp.componentName		= prgComp.name;
					bbComp.componentDesc		= prgComp.name;
					bbComp.componentAmount		= prgComp.amount.toString();
					bbComp.programNumber		= prgComp.programNumber;
					bbComp.programTitle			= prgComp.programTitle;
					bbComp.paidTo				= prgComp.paidTo;
					bbComp.compDescription		= prgComp.compDescription;
					bbComp.compRate				= prgComp.compRate;
					bbComp.programComponentId	= prgComp.programComponentId;
					// add 
					this.billback.bbComponent.push(bbComp);
				}				 
			}
			else{
				//if not selected remove
				for each(bbComp in this.billback.bbComponent){
					// if the programId and componentNameId are same then dont add to keepers >> if they are not same add to keepers;
					if (	!(
						(bbComp.programNumber == prgComp.programNumber) && 
						(
							(bbComp.componentNameId == prgComp.componentId.toString() && bbComp.programComponentId == prgComp.programComponentId)
						)
					)
					){
						tempBBComp.push(bbComp);
					}
				}
				prgComp.amount = 0;
				this.billback.bbComponent = tempBBComp;
			}
		}
		
		
		//user clicks RFA or "Deviations" Button (ie continue).  Save "SAVE_BB_EDIT_SETTLE" is called first and response comes here
		public function runDeviations(bbh:BBHeader):void{
			// TODO: check lock
			this.billback.bbHeader = bbh;
			// Run Deviations if BB is WIP
			if(this.billback.bbHeader.status.id == 1){
				/*
				if (this.billback.bbHeader.strDefaultProgram != '' && this.billback.bbHeader.strDefaultProgram != '0'){
				Alert.show('This billback has the default program ( ' + this.billback.bbHeader.strDefaultProgram + ' ) associated with it. Please transfer all records off of the default program to continue.');
				}
				else{
				var evt:BBEditEvent= new BBEditEvent(BBEditEvent.RUN_DEVIATIONS);
				evt.billback = this.billback;
				evt.bbIdInt	= this.billback.bbHeader.billbackIDInt;
				evt.userId  = this.oSettings.userId;
				this._dispatcher.dispatchEvent(evt);
				}
				*/
				var evt:BBEditEvent= new BBEditEvent(BBEditEvent.RUN_DEVIATIONS);
				evt.billback = this.billback;
				evt.bbIdInt	= this.billback.bbHeader.billbackIDInt;
				evt.userId  = this.oSettings.userId;
				this._dispatcher.dispatchEvent(evt);
			}
			else{
				loadDeviations(this.billback.bbHeader.status);
			}
		}
		
		//Load the deviatoins grid
		public function loadDeviations(bbStatus:Status):void{
			
			this.billback.bbHeader.status = bbStatus;
			dispatchEvent(new Event('editBillbackChanged'));
			// ListenerInjector in BBMainEventMap handle this
			if(this.oSettings.user.stProfileSettings.BB_VIEW_DEVIATION == 1){
				var e:BBMainEvent = new BBMainEvent(BBMainEvent.LOAD_DEVIATIONS);
				e.bbHeader  = this.billback.bbHeader;
				this._dispatcher.dispatchEvent(e);
			}
			else{
				Alert.show('Billback is now RFA.  You do not have permissions to View deviations.');
			}
			
		}
		
		public function saveSettlementResults(bbh:*):void{
			//Alert.show('approval returned from cf.  should return BBHeader but it is null');
			if (bbh.strErrorMessage != ''){
				Alert.show(bbh.strErrorMessage);
			}
			else{
				setBillbackChanged(bbh);	
			}
		}
		
		
		private function setBillbackChanged(bbh:BBHeader):void{
			_billback.bbHeader = bbh;
			this.billback = _billback;
			dispatchEvent(new Event('editBillbackChanged'));
			
			/* After the BBheader is updated, set the BBToolsLock object based the latest BBHeader. 
			This way right after the BB is approved, certain actions can be disabled AND other actions
			(if needed) can be taken.
			*/
			lockBB(bbh.billbackIDInt.toString(),true,false,false,false);				
		}
		
		public function getDeductionsResults(arr:Array):void{
			var dd:Deduction;
			var payee:com.Billback.Main.models.vos.Payee;
			this.acBBDeductions = new ArrayCollection(arr);
		}
		//load array of bbClosingDetail from server
		public function getClosingMethodDetailsResults(arr:Array):void{
			this.billback.bbHeader.bbSettlement.bbClosingDetail = arr;
		}
		
		public function lockDeductionResults(obj:*):void{
			//return from lock DD
			var o:* = obj;
			
		}
		
		// get the closingMethod List
		public function getClosingMethods(closingMethodList:Array):void{
			/* 	This functuon is fired whenever a billback is opened from the search page. "this._closingMethodListAll" has the
			list of all the billbacks."this.closingMethodList" values will change based on payee - operator or not.*/
			this._closingMethodListAll = closingMethodList;
			this.closingMethodList = closingMethodList;
		}
		
		
		// insert a new row; add the selected program and distributor into the new row.
		public function dgBBEditItemInsertRow(iRow:int):void
		{
			var bbPrgItem:BBPrgDistItemRate	= new BBPrgDistItemRate();
			var iBBPrgDistItemRateLen:int	= new int(this.billback.bbPrgDistItemRate.length);
			bbPrgItem.bbProgram				= new BBProgram();	
			bbPrgItem.bbDistributor 		= new Customer();
			bbPrgItem.bbProdRate			= new BBProdRate;
			bbPrgItem.uomDp 				= this.uomDp;
			var uUOM:Uom					= new Uom;
			uUOM.uomId						= 1;
			uUOM.abbreviation				= 'CS';
			uUOM.description				= 'Cases';
			bbPrgItem.bbProdRate.uom 		= uUOM;
			
			// program info
			if(this.selectedProgram){
				bbPrgItem.bbProgram.programId	= this.selectedProgram.programId;
				bbPrgItem.bbProgram.number		= this.selectedProgram.number;
				bbPrgItem.bbProgram.title		= this.selectedProgram.title;
				bbPrgItem.bbProgram.startDate	= new Date(this.selectedProgram.startDate);
				bbPrgItem.bbProgram.endDate		= new Date(this.selectedProgram.endDate);
			}
			else if (iBBPrgDistItemRateLen)
			{
				bbPrgItem.bbProgram.programId	= this.billback.bbPrgDistItemRate[iBBPrgDistItemRateLen-1].bbProgram.programId;
				bbPrgItem.bbProgram.number		= this.billback.bbPrgDistItemRate[iBBPrgDistItemRateLen-1].bbProgram.number;
				bbPrgItem.bbProgram.title		= this.billback.bbPrgDistItemRate[iBBPrgDistItemRateLen-1].bbProgram.title;
				bbPrgItem.bbProgram.startDate	= new Date(this.billback.bbPrgDistItemRate[iBBPrgDistItemRateLen-1].bbProgram.startDate);
				bbPrgItem.bbProgram.endDate		= new Date(this.billback.bbPrgDistItemRate[iBBPrgDistItemRateLen-1].bbProgram.endDate);
			}
			
			// distributor info
			if(this.selectedDistributor){
				bbPrgItem.bbDistributor = this.selectedDistributor;
			}
			else if (iBBPrgDistItemRateLen)
			{
				bbPrgItem.bbDistributor = this.billback.bbPrgDistItemRate[iBBPrgDistItemRateLen-1].bbDistributor;
			}
			
			// "select" and add the new row.  bbPrgDistItemRate is the selected row
			this.bbPrgDistItemRate = bbPrgItem;
			this.billback.bbPrgDistItemRate.push(bbPrgItem);
			dispatchEvent(new Event('editBillbackChanged'));
			
			var evt:MainEvent = new MainEvent(MainEvent.FOCUS_ROW);
			evt.objRowData = bbPrgItem;
			this._dispatcher.dispatchEvent(evt);
		}
		
		// select Row
		public function dgBBEditItemSelectRow(obj:Object):void
		{
			var bbPrgItem:BBPrgDistItemRate	= obj as BBPrgDistItemRate;
			// set the selected row
			this.bbPrgDistItemRate = bbPrgItem;
		}
		
		// set program rates
		public function setProgramRates(arrBBPrgItem:Array):void{
			this.billback.bbPrgDistItemRate = arrBBPrgItem;
			dispatchEvent(new Event('editBillbackChanged'));
		}
		
		// get lockBB object 
		public function getLockBB(obj:Lock,bbClose:Boolean = false):void{
			/* When the user closes a billback, the billback gets unlocked in the db. No need to take any action in flex */
			if(bbClose == false){
				var sMsg:String = "";
				var alertResult:Alert; 
				this.BBLock = obj;
				
				dispatchEvent(new Event('bbLockObjChanged'));
				
				/* set the default lock properties for the BBheader  */
				this.billback.bbHeader.locked = false;
				this.billback.bbHeader.lockedByOther = false;
				this.billback.bbHeader.lockedBy= '';
				
				/* if billbacks are not the same - prompt the user [user has another BB locked]. The user has now the option
				to unlock that billback. Note: We do not execute this code when the user clicks on "save" to create a new billback
				(this.BBLock.objId = '0'). Instead, we unlock existing locked billbacks right before the code to create a new 
				billback is fired.
				*/
				if((this.BBLock.objId != this.BBLock.objIdLocked) && (this.BBLock.objIdLocked.length && this.BBLock.objId != '0')) {					
					sMsg = sMsg + "Please unlock the billbacks you have locked below before continuing: " + this.BBLock.objIdLockedDesc;	
					/* Call "unlockAlreadyLockedBB" to unlock existing opened billbacks (in flex) by the same user. */
					alertResult = Alert.show(sMsg, "Unlock now!", Alert.OK | Alert.CANCEL, null, unlockAlreadyLockedBB);
				}
				
				// if users are not the same
				if((this.oSettings.userId != this.BBLock.userLocked.id) && (this.BBLock.userLocked.id.length)){
					this.billback.bbHeader.locked = true;
					this.billback.bbHeader.lockedByOther = true;
					this.billback.bbHeader.lockedBy = this.BBLock.userLocked.id;	
				}	
				
				// if the billbacks are same and users are same then lock the billback
				if((this.BBLock.objId == this.BBLock.objIdLocked) && (this.BBLock.userId == this.BBLock.userLocked.id)){
					this.billback.bbHeader.locked = true;
					this.billback.bbHeader.lockedBy= this.BBLock.userLocked.id;
					
					/* If the user visited from the "val" link on the search screen, re-direct the user to the "deviation" screen. */
					//var timer:Timer = new Timer(3000);
					//timer.start()
					if(oSettings.sBBDeviationSource == 'bCheckLockToOpenDeviationScreen')
					{
						loadDeviations(this.billback.bbHeader.status);
					}
				}
				
				// unlock
				// if the locked BB and locked user are blank and this BB is still locked, then unlock this BB
				if((this.BBLock.objIdLocked.length == 0) && (this.BBLock.userLocked.id.length == 0) && (this.billback.bbHeader.locked)){
					// unlock	
					this.billback.bbHeader.locked = false;
					this.billback.bbHeader.lockedBy= "";
				}
				
				/* If the billback is locked by the user (not some other user) and the request to lock comes from "toggle lock" 
				(edit/read-only toggle) functionality, then reload the billback information.
				Note: when the user switches from edit to read-only, then "this.billback.bbHeader.locked" is false and so we do not
				fire the code below. There is no need to reload data when the user switches to read-only mode.
				- There is also no need to reload data when a user visits the edit screen from the "val" link on the bb search screen.
				If the BB is not locked, the user gets re-directed to the deviation screen and the lock status gets set to "edit" mode.
				Since the initial call to get products is already made before the user is re-directed to the deviation screen, there is
				no need to make another call to get products after the lockbb() function is called below to lock the billback.
				*/
				if(this.billback.bbHeader.locked == true && this.billback.bbHeader.lockedByOther == false && this.BBLock.toggleLock == true)
				{	
					/* The user has NOT visited from the "val" link on the search grid. */
					if(oSettings.sBBDeviationSource != 'bCheckLockToOpenDeviationScreen')
					{
						 reloadBillbackEdit();
					}
					    /* reset "oSettings.sBBDeviationSource". We do not need it anymore. */
						resetDeviationSource();					
				}
				
				/* If the user visits the bb edit screen from the "val" link:
					- If the BB is not locked by some other user, then re-direct the user to the deviation screen.
					The billback gets automatically locked in this case.
					- If the bb is locked by some other user, then the user stays on the bb edit screen and is not
					re-directed to the deviation screen.The user will be able to see the name of the user who has 
					the bb locked on the bb edit screen.
					- If the BB is not locked by any user, but the user requesting the lock has other billbacks locked,
					  then make the user click either "ok" or "cancel" for the prompt to unlock all existing locked billbacks.
					If the user clicks ok, then unlock locked billbacks and lock the requested billback and re-redirect the
					user to the deviation screen.
				*/
				if(oSettings.sBBDeviationSource == 'Deviation')
				{	
					/* If the bb is not already locked by someone else. */
					if(this.billback.bbHeader.lockedByOther == false)
					{						
						/* This code locks the billback on which the user requested the lock.*/
						lockBB(this.billback.bbHeader.billbackIDInt.toString(),true,true,false,false);

						/* Reset the "oSettings.sBBDeviationSource" to 'bCheckLockToOpenDeviationScreen'. This will be useful to decide whether to load the products
						on the edit screen. If the below value is set, then there is no need to reload products, when a request for lock is made above (LockBB),
						as a request to get products was already just before the "redirect" to the deviation screen.
						Also, since it is not set to "deviation" anymore, the above lock will not be called in an uninterrupted loop.
						*/
						oSettings.sBBDeviationSource = 'bCheckLockToOpenDeviationScreen';						
					}
				}
				
				/*  When the user requests to lock a billback, the other opened and locked billback(s) in flex need to be unlocked.
				Note: "this.BBLock.unlockExistingLockedByUser" =  true means that the code to unlock "opened and locked" billbacks in db has 
				already been executed and now the same billback(s) need to be unlocked (set to read-only) in flex and then 
				the billback on which the user requested the lock needs to be locked.
				*/
				if(this.BBLock.unlockExistingLockedByUser == true)
				{
					/* Unlock (set to read-only) other opened and locked billback(s) (in flex) */
					unlockLockedBB();
					
					/* This code locks the billback on which the user requested the lock. */
					lockBB(this.billback.bbHeader.billbackIDInt.toString(),true,true,false,false);
				}
				
				/* Set the MENU for user selection */
				setObjBBToolsLock(obj);	
			}
		}
		
		private function unlockLockedBB():void{
			/* Unlock (set to read-only) other opened and locked billback(s) (in flex) */
			var e1:BBMainEvent = new BBMainEvent(BBMainEvent.UNLOCK_BB);
			e1.bbHeader  = this.billback.bbHeader;					
			this._dispatcher.dispatchEvent(e1);		
		}
		
		private function unlockAlreadyLockedBB(mesgEventObj:CloseEvent):void
		{	
			/*  If the user clicks on "OK" to unlock existing locked billbacks by the same user. This way the lock can be 
			created on the requested billback. 
			*/
			if (mesgEventObj.detail==Alert.OK){	
				/* "this.BBLock.objIdLocked" is the locked billback which needs to be unlocked, so that the user requested billback can be locked */
				lockBB(this.BBLock.objIdLocked,false,true,true,false);
			}
			else
			{	/* Reset the value. We do not need it anymore. Even if the user clicked on "ok", the value would have been ultimately reset also. */
				resetDeviationSource();
			}
		}
		
		private function resetDeviationSource():void{			
			/* - The initial value of "oSettings.sBBDeviationSource" is "deviation", when a user visits from the "val" link on the search grid.
			   - If the the billback is not locked by any user, a request is made to lock the billback. Now the value of "oSettings.sBBDeviationSource"
				is updated to "bCheckLockToOpenDeviationScreen".
			   - If the user requesting the lock has other billbacks locked, then prompt the user to unlock existing billbacks.
			   - Reset the value to blank as it is not needed anymore.		
			*/
			if(oSettings.sBBDeviationSource == 'bCheckLockToOpenDeviationScreen')
			{
				oSettings.sBBDeviationSource = '';
			}
		}
		
		private function lockBB(objId:String, lock:Boolean,toggleBB:Boolean, bbUnlockExistingLockedByUser:Boolean, bbClose:Boolean):void
		{					 		  
			// event to unlock
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOCK_BB_EDIT);		
			e.bbId		= objId;
			e.userId	= this.oSettings.userId;
			e.lockIt	= lock;
			e.bbtoggle 	= toggleBB; // did the request come from toggle bb (edit/read-only)
			e.bbUnlockExistingLockedByUser = bbUnlockExistingLockedByUser; // when the user's other opened and locked billbacks need to be unlocked
			e.bbClose = bbClose;
			
			// send the event 
			this._dispatcher.dispatchEvent(e);
		}
		
		// save closing detail 
		public function setBBClosingDetail(cd:BBClosingDetail):void{
			this.billback.bbHeader.bbSettlement.bbClosingDetail.push(cd);
			this.billback = _billback;
		}
		
		// validate bb dates
		public function validateBBDates():void{
			
			//var dtFarPast:Date = StringUtils.dateAdd('date',-500,new Date());
			//var dtFarFuture:Date = StringUtils.dateAdd('date',500,new Date());
			var alertResult:Alert;
			var sMsg:String = "";
			var validDates:Boolean = true;
			
			/* Validate bb date range, confirm with users when any of these conditions exists:
			a.   billback span (end date to start date) is greater or equal to 500 days
			b.   billback start date is more than 500 day in the past (from today's date)
			c.   billback start date is more than 500 days in the future (from today's date) */ 
			
			if(((StringUtils.calculateDays(this.billback.bbHeader.startDate,new Date()) + 1) > 500 
				|| (StringUtils.calculateDays(new Date(),this.billback.bbHeader.startDate) + 1) > 500)
				|| (StringUtils.calculateDays(this.billback.bbHeader.startDate,this.billback.bbHeader.endDate) + 1) >= 500)
			{
				validDates = false;
			}
			
			/* invalid dates */
			if(!validDates){
				sMsg = "Please confirm the billback start and end dates are accurate.\nClick OK to continue.  Click Cancel to update the dates.";
				alertResult = Alert.show(sMsg, "", Alert.OK | Alert.CANCEL, null, callBBHeader);
			}	
			else{
				/* valid dates */
				validateBBHeader();
			}
		}
		
		private function callBBHeader(msgEventObj:CloseEvent):void{
			if (msgEventObj.detail==Alert.OK){	
				/* valid dates */
				validateBBHeader();
			}	
		}
		
		public function setSaveCompleted(bbh:BBHeader):void{
			PopUpManager.removePopUp(Notification);
			bSaving = false;
			trace('REMOVE-POPUP');
			this.billback.bbHeader = bbh;
			dispatchEvent(new Event('editBillbackChanged'));
		}
		public function clearSaveMessage(e:Fault):void{
			PopUpManager.removePopUp(Notification);
			bSaving = false;
			//Alert.show(e.faultDetail + ' ' + e.faultString,'SERVER ERROR');
			trace('REMOVE-POPUP: error');
		}
		
		// Validation 
		public function validateBBHeader():void
		{
			var bValid:Boolean = true;
			var bBBNumValid:Boolean = true;
			var bCompError:Boolean = true;
			var sErrorMsg:String = '';
			var d:Date = new Date();
			trace('VALIDATE-BBHEADER        : ' + d.toString());
			if (this.billback.bbHeader.startDate > this.billback.bbHeader.endDate)
			{ 
				bValid = false;
				sErrorMsg = sErrorMsg +  'End Date is before Start Date.';
			}
			
			if (this.billback.bbHeader.closingMethod.id < 1)
			{
				bValid = false;
				sErrorMsg = sErrorMsg + '\n Closing Method is required.';
			}
			
			if (!this.billback.bbHeader.vendor || !this.billback.bbHeader.vendor.payeeId.length)
			{
				bValid = false;
				sErrorMsg = sErrorMsg + '\n Vendor # is required.';
			}
			
			if (!this.billback.bbHeader.payee)
			{
				bValid = false;
				sErrorMsg = sErrorMsg + '\n Payee # is required.';
			}
			
			if (this.billback.bbHeader.BBNumber.length <= 0)
			{
				bValid = false;
				bBBNumValid = false;
				sErrorMsg = sErrorMsg + '\n Please enter the invoice number';
			}
			if (this.billback.bbHeader.title.length <= 0)
			{
				bValid = false;
				if (bBBNumValid)
				{
					sErrorMsg = sErrorMsg + '\n Please enter the invoice title';
				}
				else
				{
					sErrorMsg = sErrorMsg + ' and title';
				}
			}
			
			// call to validate components 
			bCompError = this.validateComponents();
			
			if(bCompError && bValid)
			{
				/*  When the user clicks on "save" to create a new billback, call the code to unlock existing locked billbacks.
				To do the same after creating the billback is quite complicated. */
				if(this.billback.bbHeader.billbackIDInt == 0){
					lockBB(this.billback.bbHeader.billbackIDInt.toString(),false,false,true,false);
				}
				PopUpManager.removePopUp(Notification);
				Notification = 	Alert.show('saving billback data','Saving');
				var buttons:Array = Notification.mx_internal::alertForm.mx_internal::buttons;
				for ( var i:int=0; i<buttons.length; i++ )
				{
					Notification.mx_internal::alertForm.removeChild(Notification.mx_internal::alertForm.mx_internal::buttons[i]);
				}
				if(!bSaving){
					bSaving = true;
					var e:BBEditEvent= new BBEditEvent(BBEditEvent.SAVE_BB_EDIT);
					e.billback  = this.billback;
					this._dispatcher.dispatchEvent(e);
				}
				else{
					trace("TRIED TO SAVE AND STOPPED: " + d.toString());
				}
			}		
			else
			{
				if (!bValid)
				{	
					Alert.show(sErrorMsg,"Error Alert!");
				}
			}
		}
		
		// TODO: Consolidate some of this function with validateBBHeader() since some
		// portions of each function validate the same data
		public function validateBBDetail():void
		{
			var bValid:Boolean = true;
			var bBBNumValid:Boolean = true;
			var sErrorMsg:String = '';
			var bCompError:Boolean = true;
			
			// call to validate components 
			bCompError = this.validateComponents();
			
			if (this.billback.bbHeader.startDate > this.billback.bbHeader.endDate)
			{ 
				bValid = false;
				sErrorMsg = sErrorMsg +  'End Date is before Start Date.';
			}
			
			if (this.billback.bbHeader.vendor.payeeId.length <= 0)
			{
				bValid = false;
				sErrorMsg = sErrorMsg + '\n Vendor # is required.';
			}
			
			if (this.billback.bbHeader.BBNumber.length <= 0)
			{
				bValid = false;
				bBBNumValid = false;
				sErrorMsg = sErrorMsg + '\n Please enter the invoice number';
			}
			if (this.billback.bbHeader.title.length <= 0)
			{
				bValid = false;
				if (bBBNumValid)
				{
					sErrorMsg = sErrorMsg + '\n Please enter the invoice title';
				}
				else
				{
					sErrorMsg = sErrorMsg + ' and title';
				}
			}
			
			if (this.billback.bbHeader.payee.payeeId.length <= 0)
			{
				bValid = false;
				sErrorMsg = sErrorMsg + '\n Please select a Payee';
			}
			
			//  if valid then disptach save else alert error msg 
			if(bCompError && bValid)
			{
				var e:BBEditEvent= new BBEditEvent(BBEditEvent.SAVE_BB_EDIT_SETTLE);
				e.billback  = this.billback;
				this._dispatcher.dispatchEvent(e);
			}
			else
			{
				if (!bValid)
				{	
					Alert.show(sErrorMsg,"Error Alert!");
				}
			}
		}
		
		/* 
		START:	30190:Flex BB is not saving component value correctly/Anand Rao/30-Jan-2012
		Validating to see if a components is added and if right ones include for the program 
		*/
		
		public function validateComponents():Boolean
		{
			var bValid:Boolean = true;
			var sErrorMsg:String = '';
			var sErrorItems:String = '';			
			var bLumpsumComponentError:Boolean = false;
			var bRebateFixedComponentError:Boolean = false;
			var nErrorCount:Number = 1;
			
			if (this.billback.bbComponent.length == 0)
			{
				// no comps on billback, when there are items or amounts 
				// append invalid alert msg [no comp found for the Billback]
				// when there are no items or amounts on BB, dont check comps, so thay can save a new BB with just payee info 
				
				if (this.billback.bbPrgDistItemRate.length || this.billback.expectedAmount || this.billback.expectedCS ){ 
					bValid = false;
					sErrorMsg = sErrorMsg + '\n' + nErrorCount +  '. No Component found for the Billback.';
					nErrorCount++;
				}
			}
			else
			{
				// loop over each BBComp for LumpSum 
				for each(var bbComp:BBComponent in this.billback.bbComponent)
				{
					
					if (bbComp.componentTypeId == 3 && (StringUtils.Trim(bbComp.componentAmount) == "NaN"))
					{
						bValid = false;
						bLumpsumComponentError = true;
						sErrorMsg = sErrorMsg + '\n' + nErrorCount +  '. The lumpsum amount cannot be blank for the component: ' + bbComp.componentName + '['+ bbComp.programNumber+']';
						nErrorCount++;
					}	
					else if (bbComp.componentTypeId == 3 && !isNaN(parseFloat(bbComp.componentAmount)))
					{
						if (!parseFloat(bbComp.componentAmount))
						{
							bValid = false;
							bLumpsumComponentError = true;
							sErrorMsg = sErrorMsg + '\n' + nErrorCount +  '. The lumpsum amount cannot be $0 for the component: ' + bbComp.componentName + '['+ bbComp.programNumber+']';
							nErrorCount++;
						}						                                
					}
				}
				// loop over each BBComp for Rebate and Fixed.
				var lastPrgIDAdded:Number = 0; 
				for each(var bbPDIR:BBPrgDistItemRate in this.billback.bbPrgDistItemRate)		
				{
					
					// find if rebate/fixed components are selected for the program
					var bRebateFixedComponent = 0;
					for each(var bbComp2:BBComponent in this.billback.bbComponent)
					{						
						// find matching program and if rebate/fixed component selected then set no component error 						
						if((bbPDIR.bbProgram.programId == bbComp2.programID) && (bbComp2.componentTypeId == 1 || bbComp2.componentTypeId == 2))
						{
							bRebateFixedComponent = 1;
							break;
						}
					}
					if (bRebateFixedComponent == 0 && lastPrgIDAdded != 0 && lastPrgIDAdded != bbPDIR.bbProgram.programId) 
					{
						bValid = false;
						sErrorMsg = sErrorMsg + '\n'+ nErrorCount +  '. No Rebate/Fixed Component found for the program: ' + bbPDIR.bbProgram.number;
						nErrorCount++;
						lastPrgIDAdded = bbPDIR.bbProgram.programId;
					}					
					
					// 05/20/16 - we now store discountType bbProdRate. Checking for discountType on product also. 
					if(!(bbPDIR.bbProdRate.discountType == 1 || bbPDIR.bbProdRate.discountType == 2))
					{
						// D60837 - See resolution notes. GM folks use items to report volume by applying a rebate/fixed component & then remove it and save.  
						// Compromise fix is to let the users save products after removing fixed/rebate component and use rebate as default discount type. 					
						bbPDIR.bbProdRate.discountType = 2; 
						// bRebateFixedComponentError = true;
						// sErrorItems = bbPDIR.bbProgram.number + ':' + bbPDIR.bbProdRate.itemNumber + '; ' + sErrorItems;					
					}					
					
				}
				// if rebate/fixed component not found on program list the program				
				if(bRebateFixedComponentError){
					bValid = false;
					sErrorMsg =  sErrorMsg + '\n' + nErrorCount +  '. No Rebate/Fixed Component found for the following program products: ' + '\n' + sErrorItems;
					nErrorCount++;	
				}
			}
			if(!bValid)
			{
				Alert.show(sErrorMsg,"Component Error Alert!");
			}
			//	this.bbCompExists = bValid; 
			return bValid;
		}
		
		/* END:	30190:Flex BB is not saving component value correctly/Anand Rao/30-Jan-2012 */
		
		public function copyBillbackHandler(bb:Billback):void
		{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB);
			e.bbHeader = bb.bbHeader;
			e.payeeList = new Array(bb.bbHeader.payee);
			e.closingMethodList = this.closingMethodList;
			e.bbAnalysts = this.acBBAnalysts.source;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function setObjBBToolsLock(obj:Lock):void
		{
			var oBBToolsLock:BBToolsLock = new BBToolsLock();
			
			//adjust
			if (obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.status.id == 5){
				oBBToolsLock.bAdjustEnabled = true;
			}
			else{
				oBBToolsLock.bAdjustEnabled = false;				
			}			
			// business consideration
			if (obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && oSettings.appSettings.BusinessConsiderations_On == 1){
				oBBToolsLock.bBusinessConsiderationsEnabled = true;
			}
			else{
				oBBToolsLock.bBusinessConsiderationsEnabled = false;
			}	
			// reverse BB
			if(obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.status.id == 5 && oSettings.user.stProfileSettings.BB_REVERSE == 1  && this.billback.bbHeader.bbSettlement.bIsReversible){
				oBBToolsLock.bReverseEnabled = true;
			}
			else{
				oBBToolsLock.bReverseEnabled = false;				
			}	
			// reset BB			
			if (obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.resetAllowed){
				oBBToolsLock.bResetEnabled = true;
			}
			else{
				oBBToolsLock.bResetEnabled = false;			
			}	
			// delete
			if(obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.deleteAllowed){
				oBBToolsLock.bDeleteEnabled = true;
			}
			else{
				oBBToolsLock.bDeleteEnabled = false;			
			}
			// summary report - (Discrepancy Report, Deviations report) - Not available on WIP status
			if(this.billback.bbHeader.status.id != 1){
				oBBToolsLock.bSummaryReport = true;
			}
			else{
				oBBToolsLock.bSummaryReport = false;
			}
			// edit bb screen, settlement screen. Enable it only when the BB is in either WIP OR RFA.
			if(obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.status.id < 3){
				oBBToolsLock.bEditScreenEnabled = true;
				oBBToolsLock.bSettlementScreenEnabled 	= true;
				oBBToolsLock.bEditScreenDateSaveEnabled = true;
			}
			else{
				oBBToolsLock.bEditScreenEnabled = false;	
				oBBToolsLock.bSettlementScreenEnabled 	= false;
				oBBToolsLock.bEditScreenDateSaveEnabled = false;
			}
			
			if(obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.status.id >= 3 &&
				this.oSettings.user.stProfileSettings.CHANGE_BB_START_END_DATE == 1){
				oBBToolsLock.bEditScreenDateSaveEnabled = true;
			}
			
			
			// reassign
			if(obj.bLocked == true && this.billback.bbHeader.lockedByOther == false && this.billback.bbHeader.reassignAllowed){
				oBBToolsLock.bReassignEnabled = true;
			}
			else{
				oBBToolsLock.bReassignEnabled = false;			
			}
			
			// deviation (When the billback is locked by the user, enable the button)
			if(obj.bLocked == true && this.billback.bbHeader.lockedByOther == false){
				oBBToolsLock.bDeviationEnabled = true;
			}
			else{
				oBBToolsLock.bDeviationEnabled = false;			
			}
			
			// Set values for reInterface queue
			if(obj.bLocked == true && this.billback.bbHeader.notAcknowledged == true){
				oBBToolsLock.bReinterfaceEnabled = true;
			}
			else{
				oBBToolsLock.bReinterfaceEnabled = false;			
			}		
			
			// Inside the "objBBToolsLock" function, we trigger the call to build the menu
			this.objBBToolsLock = oBBToolsLock;
			
			/* Lock/Unlock the grid. */
			var e1:BBEditEvent	= new BBEditEvent(BBEditEvent.SET_GRID_LOCK_UNLOCK);
			this._dispatcher.dispatchEvent(e1);
		}
		
		/*.................payee/vendor search......................*/
		
		// vendor search
		public function showVendorSearch(vendorSearchType:Number):void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveVendor", saveVendor);
			var winjscommand:String = "/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=flex&FlexAppName="+currentAppName+"&RebateRecipient_On=1&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch&vendorSearchType="+vendorSearchType;
			var jscommand:String = "window.open('"+winjscommand+"', 'vendorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*................. Payee Search ......................*/	
		public function showPayeeSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("appendPayee", appendPayee);
			var winjscommand:String = "/billbacks/search_screens/PM_select_distributors.cfm?Formname=flex&FlexAppName="+currentAppName+"&Type=payee&OnlyDistributorsUnderMe=0";
			var jscommand:String = "window.open('"+winjscommand+"', 'vendorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self'); 
		}		
		
		public function appendPayee(sPayeeID:String):void {
			 
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PAYEE_DISTRIBUTOR);
			e.distributorId = sPayeeID;  
			this._dispatcher.dispatchEvent(e);
		}
		
		public function setPayeeDistributorInfo(aPayee:Array):void {
			importedPayee = new Payee();
			importedPayee.payeeTypeId = 1;
			importedPayee.address 	  = aPayee[0].address;
			importedPayee.name		  =	aPayee[0].name;
			importedPayee.payeeId	  =	aPayee[0].shipTo;
			importedPayee.payeeUUId	  = aPayee[0].customerId;
			if(aPayee.length){
				if (acPayee.length){
					acPayee.addItem(importedPayee);
				}
			}
			acPayee.refresh();
			/* this is set to be the last item as the selected one in the drop down since it is getting inserted at the end. */
			this.setPayeeInfo(acPayee[acPayee.length - 1]);  
		}
		
		
		// Handle vendor search pop up return
		public function saveVendor(id:String,name:String):void {
			/*var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_VENDOR);
			e.vendorId = id;  
			this._dispatcher.dispatchEvent(e);*/
			//Alert the user if they want to Clear Programs, Components and items
			this.setVendorInputChange(id);
		}
		
		// set vendor info Handles result of remote call from [ BBEditEvent.LOAD_VENDOR ]
		public function setVendorInfo(vendor:Payee):void{
			if (vendor && vendor.payeeId.length){
				this.billback.bbHeader.vendor = vendor;
				this.selectedVendor = vendor;
				
				// get payee's for this vendor
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PAYEE_LIST);
				e.vendorId = vendor.payeeId;
				this._dispatcher.dispatchEvent(e);
			}
			else{
				this.billback.bbHeader.vendor = new Payee();
				this.selectedVendor = new Payee();
				dispatchEvent(new Event('editBillbackChanged'));
			}
			// Put Focus in the BBHeaderForm.tiVendor Box (now that search is done.  We end up here when user types in BBHeaderForm.tiVendor as well.
			var evt:BBEditEvent = new BBEditEvent(BBEditEvent.SET_FOCUS_VENDOR_INPUT);
			this._dispatcher.dispatchEvent(evt);
			
		}
		//...............................................................................
		//...............................................................................
		/*.............	vendor	.............*/
		// Alert the user if they want to Clear Programs, Components and items (called from vendor search and direct changes on BBHEaderForm.tiVendor Box
		public function setVendorInputChange(vendorId:String):void{
			//If there is No current selected Vendor, Then we should not have anyhing to clear out
			if( this.selectedVendor.payeeId != '' || this.acProgram.length || this.acComponent.length){
				//if the user has entered an id
				if(vendorId.length){
					//only if the vendor has changed.  this is caled from focusOut on
					if(vendorId != this.selectedVendor.payeeId){
						this._sPayeeId = vendorId;
						var s:String = "By changing the payee on the billback we will remove the program, component, and item level details.   Click OK to continue or Click Cancel to cancel the action."; 
						Alert.show(s,'Payee Update Alert',Alert.OK|Alert.CANCEL,null,getVendorAction,null);
					}
				}//the user has removed vendor (entered an empty string)
				else{
					var e2:BBEditEvent = new BBEditEvent(BBEditEvent.CLEAR_SELECTED_VENDOR);
					e2.vendor  = new Payee(); 
					this._dispatcher.dispatchEvent(e2);
				}
			}
			else if(vendorId != ''){//we have an id and there is no old vendor to clear, so load this one
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_VENDOR);
				e.vendorId  = vendorId; 
				this._dispatcher.dispatchEvent(e);
			}
		}
		// get vendor action handles the response from the getVendor Change Alert pop up
		public function getVendorAction(evt:CloseEvent):void{
			//if the user clicked OK
			if(evt.detail == Alert.OK){
				//After we clear prg comp items, BBEditEvent.LOAD_VENDOR is dispatched from CLEAR_PROG_COMP_ITEMS
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.CLEAR_PROG_COMP_ITEMS);
				e.vendorId  = this._sPayeeId; 
				this._dispatcher.dispatchEvent(e);
			}
			else{ // Alert.CANCEL
				// Put Focus in the BBHEaderForm.tiVendor Box. bSetVendorText flag will put the text back to what it was 
				var evtBBedit:BBEditEvent = new BBEditEvent(BBEditEvent.SET_FOCUS_VENDOR_INPUT);
				evtBBedit.bSetVendorText = true;
				this._dispatcher.dispatchEvent(evtBBedit);
			}
		}
		//......................................................................................
		//......................................................................................
		
		// set the payeeList info
		public function setPayeeList(payeeList:Array):void{
			
			if(payeeList.length){
				acPayee = new ArrayCollection(payeeList);
				if ((payeeList.length == 1 || this.selectedPayee.payeeId != payeeList[0].payeeId) && payeeList[0]){
					this.setPayeeInfo(acPayee[0]);
				}
			}
			else{
				acPayee.removeAll(); // clear the payee list;
			}
		}
		
		// set payee info
		public function setPayeeInfo(payee:Payee):void{
			if(payee){
				// dispatch event to set the analyst, if the payee changes or no analyst is selected			
				// if(!this.billback.bbHeader.analyst || this.selectedPayee.payeeId != payee.payeeId){
				if(!this.billback.bbHeader.analyst){
					var evt:BBEditEvent = new BBEditEvent(BBEditEvent.SET_BB_ANALYST);
					evt.payee	= payee;
					this._dispatcher.dispatchEvent(evt);
				}
				
				// dispatch event to load programs based on payee selected
				// this condition is to prevent getting programs before the billback loads
				if(this.billback.bbHeader.payee) 
				{
					var ev:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PROGRAM_LIST);
					ev.userId 		= this.oSettings.userId;
					ev.billback 		= this.billback;
					ev.payee			= payee;
					ev.programNumber	= '';
					ev.distributorId	= '';
					this._dispatcher.dispatchEvent(ev);
				}
				
				this.billback.bbHeader.payee = payee;
				this.selectedPayee = payee;
				
				var e:BBEditEvent 	= new BBEditEvent(BBEditEvent.LOAD_BILL_TO_LIST);
				e.distributorId 	= this.billback.bbHeader.payee.payeeId;
				this._dispatcher.dispatchEvent(e);
				
				
				/* Whenever a payee changes from distributor to operator or vice-versa, change the closing method list on the billback edit page */
				this.closingMethodList = _closingMethodList;
				dispatchEvent(new Event('closingMethodChanged'));	
				
				/* Whenever a payee changes from distributor to operator or vice-versa, change the closing method list on the settlement page */
				this.acBBClosingDetail = new ArrayCollection(this.billback.bbHeader.bbSettlement.bbClosingDetail);
				dispatchEvent(new Event('acBBClosingDetailChanged'));
			}
		}
		
		public function unlockOtherLockedUser(bbh:BBHeader):void{
			/* if the billback is locked by the current user (not by some other user) and opened in flex, then unlock it */
			if(bbh.locked = true && bbh.lockedByOther == false)
			{
				bbh.locked = false;
				bbh.lockedBy = '';
				bbh.lockedByOther = false;
				dispatchEvent(new Event('bbLockObjChanged'));
				
				/* Unlock the billback. The objective here is to set the billback to "read only" mode in flex. */
				lockBB(bbh.billbackIDInt.toString(),false,true,false,false);
			}
		}
		
		/*.................program search......................*/
		
		// program header search
		public function showProgramSearch():void {
			var currentPayee:String = this._selectedPayee.payeeId;
			var currentPayeeType:Number = this._selectedPayee.payeeTypeId;
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveProgram", saveProgram);
			var winjscommand:String = "/billbacks/search_screens/search_programs.cfm?Formname=flex&FlexAppName="+currentAppName+"&fieldname=Program_List&SELECTSINGLESEARCHRESULTONLY=1&FilterSearchPrograms=1&FilterType="+currentPayeeType+"&FilterDataList="+currentPayee+"";
			var jscommand:String = "window.open('"+winjscommand+"', 'programswindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// program header search return
		public function saveProgram(programId:int):void {
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PROGRAM);
			e.programId = programId;
			if (this.oSettings.appSettings.Billback_Display_All_Program_Components == true){
				e.payeeTypeId = 0;
			}else{
				e.payeeTypeId = this.billback.bbHeader.payee.payeeTypeId;
			}
			this._dispatcher.dispatchEvent(e);
		}
		
		// set the program info
		public function setProgramInfo(program:Program):void{
			/*
			when program changes :
			- clear the selectedProgram, 
			- clear the selectedDistributor 
			- clear the Distributor dropdown [dataProvider]
			*/
			if(program)
			{
				this.selectedProgram		= program;
				this.acDistributor			= new ArrayCollection(program.distributors);
				this.acComponent			= new ArrayCollection(program.components);
				
				this.setProgramProductList2(program.components);
				/* 
				30875 - Default Distributor when Payee = Distributor in flex/Anand Rao/09-Mar-2012
				When the payee is distributor and once the program is picked the distributor # 
				will be populated with the payee#(account # in gm).
				
				*/
				/*if (selectedPayee.payeeTypeId == 1)
				{*/
				//this.selectedDistributor	=  this.billback.bbHeader.payee;
				/*
				D32509: Default Distributor when Program has only one Distributor / Anand Rao / 14-Jun-2012
				when the billback pays to a operator (Account # = operator) 
				1.	If the program selected only has 1 distributor on it, default the Distributor field to that distributor.
				2.	If the program selected has multiple distributors, do not default the distributor field to anything.  The user will need to manually select a distributor from the drop down 
				*/
				for each (var existingDist:Customer in acDistributor){
					if(existingDist.shipTo == this.billback.bbHeader.payee.payeeId){
						this.selectedDistributor = existingDist;
						break;
					}
				} 
			   }
			
			/*}
			else
			{	
			this.selectedDistributor	=  null;
			}
			*/
		}
		
		// set the programList info
		public function setProgramList(prgList:Array):void{
			// clear the programs list;
			acProgram.removeAll();
			// if the programList has records  
			if(prgList.length){
				if (!acProgram.length){
					acProgram.addItem(prgList.shift());
				}
				
				for each (var newProgram:BBProgram in prgList){
					for each (var existingProgram:BBProgram in acProgram){
						var exists:Boolean = false;
						if(newProgram.number == existingProgram.number){
							exists = true;
							break;
						}
					}
					if(!exists){ acProgram.addItem(newProgram); }
				}
			}
			
			// append the programs from the billback;
			this.setBBProgramList();
		}
		
		// add the programs from the BB to the programList
		public function setBBProgramList():void{
			
			if(this.billback.bbPrgDistItemRate && this.billback.bbPrgDistItemRate.length){
				// get the list of programs from this BB 
				for each (var oItem:BBPrgDistItemRate in this.billback.bbPrgDistItemRate){
					var newProgram:BBProgram = oItem.bbProgram;
					// if no existing programs; add first program from BB 
					if (!acProgram.length){acProgram.addItem(newProgram);}
					
					// loop over programlist and find programs from BB 
					for each (var existingProgram:BBProgram in acProgram){
						var exists:Boolean = false;
						if(newProgram.number == existingProgram.number){
							exists = true;
							break;
						}
					}
					//add the program if it doesnt exist
					if(!exists){ acProgram.addItem(newProgram); }
				}
			}
			// if there is only 1 program set it selected;  
			if(acProgram.length == 1){this.saveProgram(acProgram[0].programId);}
			
			/* D32741: Kal: Program Number sort the data in ascending order */
			var dataSortField:SortField = new SortField("number");
			var sort:Sort = new Sort();
			sort.fields = [dataSortField];
			acProgram.sort = sort;
			acProgram.refresh();
			
		}
		
		// add the BB Components from the BB to the component list
		public function setBBComponentList():void{
			
			this._acComponent.removeAll();
			// Add all the components on the billback to component display    
			for each(var bbComp:BBComponent in this.billback.bbComponent)
			{
				var prgComp:Component 	= new Component();
				prgComp.isSelected 		= true;
				prgComp.type 			= int(bbComp.componentTypeId);
				prgComp.componentId 	= int(bbComp.componentNameId);
				prgComp.name 			= bbComp.componentName;
				prgComp.amount 			= Number(bbComp.componentAmount);
				prgComp.programId		= bbComp.programID;
				prgComp.programNumber	= bbComp.programNumber;
				prgComp.programTitle	= bbComp.programTitle;
				prgComp.paidTo			= bbComp.paidTo;
				prgComp.compDescription	= bbComp.compDescription;
				prgComp.compRate		= bbComp.compRate;
				prgComp.programComponentId	= bbComp.programComponentId;
				this._acComponent.addItem(prgComp);
			}
			dispatchEvent(new Event('componentListChanged'));
			this.panelHeight = this._acComponent.length;
		}
		
		
		/*.................distributor search......................*/
		// distributor search 
		public function showDistributorSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveDistributor", saveDistributor);
			var winjscommand:String = "/billbacks/search_screens/PM_select_distributors.cfm?Formname=flex&FlexAppName="+currentAppName+"&OnlyDistributorsUnderMe=0";
			var jscommand:String = "window.open('"+winjscommand+"', 'distributorwindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// distributor search return
		public function saveDistributor(sDistributorID:String):void {
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_DISTRIBUTOR);
			e.distributorId = sDistributorID;  
			this._dispatcher.dispatchEvent(e);
		}
		
		// set distributor info
		public function setDistributorInfo(aDistributor:Array):void{
			// if the aDistributor has records  
			if(aDistributor.length){
				if (!acDistributor.length){
					acDistributor.addItem(aDistributor.shift());
				}
				
				for each (var newDist:Customer in aDistributor){
					for each (var existingDist:Customer in acDistributor){
						var exists:Boolean = false;
						if(newDist.shipTo == existingDist.shipTo){
							exists = true;
							break;
						}
					}
					if(!exists){ acDistributor.addItem(newDist); }
				}
				this.selectedDistributor = Customer(acDistributor.getItemAt(acDistributor.length -1));
			}		
		}
		
		// set existing as selected distributor
		public function setSelectedDistributorInfo(sDistributorId:String):void{
			// loop the acDistributor and find the selected distributor id  
			for each (var existingDist:Customer in acDistributor){
				var exists:Boolean = false;
				if(existingDist.shipTo == sDistributorId){
					exists = true;
					// set the matched distributor to selecteddistributor
					this.selectedDistributor = existingDist;
					break;
				}
			}
			if(!exists){
				// call function to load new customer
				this.saveDistributor(sDistributorId);
			}
		}
		
		// set BillTo List
		public function setBillToList(aBillTo:Array):void{
			var ac:ArrayCollection = new ArrayCollection();
			this._acBillTo.removeAll();
			// add all the records returned if the payee is distributor
			if (this.billback.bbHeader.payee.payeeTypeId == 1)
				for each (var billTo:BillTo in aBillTo){
				ac.addItem(billTo);
			}
			//fire the setter
			this.acBillTo = ac;
		}	
		
		// set Program Product List
		public function setProgramProductList(aProgProd:Array):void{
			var ac:ArrayCollection = new ArrayCollection(aProgProd);
			this._acProgramProduct.removeAll();
			
			//fire the setter
			this.acProgramProduct = ac;
		}	
		
		// set Program Product List
		public function setProgramProductList2(aProgProdList:Array):void{
			
			//set acProgramProduct
			for each (var objCust:Component in aProgProdList){
				for each (var objProdRate:Object in objCust.prodRate){
					if (!this.acProgramProduct.contains(objProdRate)){
						this.acProgramProduct.addItem(objProdRate);	
					}
				}	
			}
		}
		
		//this.acProgramProduct
		public function getBillbackDuplicate(arrBBHeader:Array):void
		{
			var sErrorMsg:String;
			var NewAlert:Alert;
			// Alert.show(ObjectUtil.toString(bbHeader));
			sErrorMsg = 'Another invoice has been found with the same payee and customer invoice number. \n Existing Payable #: \n';
			if (arrBBHeader.length)
			{
				
				for each (var bbHeader:BBHeader in arrBBHeader)
				{
					if (bbHeader.BBCode != null && bbHeader.BBCode.length)
					{
						sErrorMsg = sErrorMsg + bbHeader.BBCode+' - '+bbHeader.title+' - '+StringUtils.getFormatDt(bbHeader.startDate.toString())+' to '+StringUtils.getFormatDt(bbHeader.endDate.toString())+' - '+StringUtils.getDollarDec2(bbHeader.amount.toString())+' - '+bbHeader.creator.fullName+' - '+StringUtils.getFormatDt(bbHeader.createdDate.toString())+'\n';
						sErrorMsg = sErrorMsg  + "-------------------------------------------------------------\n";
						/* sErrorMsg = sErrorMsg + '\n Existing Payable #: ' + bbHeader.BBCode;
						sErrorMsg = sErrorMsg + '\n Invoice Title: ' + bbHeader.title;
						sErrorMsg = sErrorMsg + '\n Start/End Dates: ' + StringUtils.getFormatDt(bbHeader.startDate.toString()) + ' - ' + StringUtils.getFormatDt(bbHeader.endDate.toString());
						sErrorMsg = sErrorMsg + '\n Claimed Amount:' + StringUtils.getDollarDec2(bbHeader.amount.toString());
						sErrorMsg = sErrorMsg + '\n Created By: ' + bbHeader.creator.fullName;
						sErrorMsg = sErrorMsg + '\n Created Date: ' + StringUtils.getFormatDt(bbHeader.createdDate.toString());
						*/
					}	
				}
				Alert.show(sErrorMsg,"Duplicate Warning!");
			}
		}
		
		/* Email function */
		public function openEmailPage() : void{  
			var winjscommand:String ="/billbacks/common/bb_email_create.cfm?BBID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+winjscommand+"','winPrint','height=600,width=900,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"   
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");
		}		
		
		/* Print function */
		public function openPrintPage() : void{  
			var winjscommand:String ="/billbacks/common/bb_printer_friendly.cfm?BBID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+winjscommand+"','winPrint','height=600,width=1000,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"   
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");
		}
		
		/*.................BUSINESS CONSIDERATIONS......................*/
		public function showBizCon(bizConMode:String=null):void {
			var winjscommand:String = "/billbacks/common/BB_Business_Consideration.cfm?EDIT=1&BBID="+this.billback.bbHeader.billbackIDGUID;
			if (bizConMode){
				winjscommand = winjscommand+"&MODE="+bizConMode;
			}
			var jscommand:String = "window.open('"+winjscommand+"', 'bizConWindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*.................BUSINESS CONSIDERATIONS ON ADJUST......................*/
		public function showAdjustBizCon():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("showAdjustProgramSearch", showAdjustProgramSearch);
			var winjscommand:String = "/billbacks/common/BB_Adjust_Business_Consideration.cfm?EDIT=1&mode=11&BBID="+this.billback.bbHeader.billbackIDGUID+"&Formname=flex&FlexAppName="+currentAppName;
			var jscommand:String = "window.open('"+winjscommand+"', 'bizConWindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// program summary display
		public function showProgramSummary(programId:int):void {
			var winjscommand:String ="/CID_Wrapper.cfm?Program_ID="+programId+"&Page_Relocate=/scorecard/program_display.cfm";
			var jscommand:String = "window.open('"+winjscommand+"','programSummary','height=600,width=900,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=yes');"   
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");
		}
		
		// adjust program search
		public function showAdjustProgramSearch(programId:int):void {
			var currentPayee:String = this._selectedPayee.payeeId;
			var currentPayeeType:Number = this._selectedPayee.payeeTypeId;
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("showSwitchPrograms", showSwitchPrograms);
			var winjscommand:String = "/billbacks/search_screens/search_programs.cfm?Formname=flex&FlexAppName="+currentAppName+"&fieldname=Program_List&SELECTSINGLESEARCHRESULTONLY=1&FilterSearchPrograms=1&FilterType="+currentPayeeType+"&FilterDataList="+currentPayee+"&Program_ID="+programId+"&Billback_ID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+winjscommand+"', 'programswindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// switch program search
		public function showSwitchPrograms(programId:int, newProgramId:int):void {
			var currentPayee:String = this._selectedPayee.payeeId;
			var currentPayeeType:Number = this._selectedPayee.payeeTypeId;
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("reloadBillbackEdit", reloadBillbackEdit);
			var winjscommand:String = "/billbacks/capture/switch_program.cfm?ParentFormname=flex&FlexAppName="+currentAppName+"&Program_ID="+programId+"&Billback_ID="+this.billback.bbHeader.billbackIDGUID+"&NewProgram="+newProgramId;
			var jscommand:String = "window.open('"+winjscommand+"', 'programswindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// reload billback edit
		public function reloadBillbackEdit():void {
			var e:BBEditEvent= new BBEditEvent(BBEditEvent.LOAD_BB_EDIT);
			e.bbHeader  = this.billback.bbHeader;
			this._dispatcher.dispatchEvent(e);
		}
		
		/* Handler for data of "billback document attachment" which comes as BBDetails 
		and NOT as "details" property of BBHeader.
		*/
		public function BBAttachmentHandler(docs:BBDetails):void {			
			this.billbackHeaderDetail = docs;
			dispatchEvent(new Event('BillbackHeaderDetailChanged'));	
			this.modifyMenu = true;
			dispatchEvent(new Event('modifyMenuData'));
		}
		
		/*.................HISTORY......................*/
		public function showHistory():void {
			var winjscommand:String = "/billbacks/common/bb_history.cfm?BBID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+winjscommand+"', 'historyWindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*.................product search......................*/
		public function showProductSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (!this.selectedProgram){
				Alert.show("Select a program from the program drop down above.");
				return;
			}
			var iProgramId:int = this.selectedProgram.programId;
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveItem", saveItem);
			var winjscommand:String = "/common_files/contracts/product_Select_V1.cfm?Formname=flex&FlexAppName=" + currentAppName + "&DTPS_Program_ID=" + iProgramId + "&prgID=" + iProgramId;
			var jscommand:String = "window.open('"+winjscommand+"', 'ProductSearch', 'height=600,width=800,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// product search return
		public function saveItem(itemList:String):void {
			
			if (itemList.length){
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_PRODUCTS);
				e.lProducts = itemList;  
				this._dispatcher.dispatchEvent(e);
			}
		}
		
		// get the items list
		public function getProductData(arrProducts:Array):void{
			
			for (var i:int = 0; i < arrProducts.length; i++)
			{
				
				var bbBBPrgDistItemRate:BBPrgDistItemRate;
				
				// check for existing bb products
				for each(bbBBPrgDistItemRate in this.billback.bbPrgDistItemRate){
					var bExists:Boolean	= false;
					// if the item guids match then set bExists to true;
					if (bbBBPrgDistItemRate.bbProdRate.itemGuid == arrProducts[i].itemGuid){
						bExists = true;
						break;
					}
				}
				
				if (!bExists){
					var bbPrgItem:BBPrgDistItemRate	= new BBPrgDistItemRate();
					bbPrgItem.message				= 'Product not on Program';
					bbPrgItem.bbProgram				= new BBProgram();	
					bbPrgItem.bbDistributor 		= new Customer();
					bbPrgItem.bbProdRate			= new BBProdRate();
					bbPrgItem.uomDp 				= this.uomDp;
					var uUOM:Uom					= new Uom;
					uUOM.uomId						= 1;
					uUOM.abbreviation				= 'CS';
					uUOM.description				= 'Cases';
					
					// program info
					bbPrgItem.bbProgram.programId	= this.selectedProgram.programId;
					bbPrgItem.bbProgram.number		= this.selectedProgram.number;
					bbPrgItem.bbProgram.title		= this.selectedProgram.title;
					bbPrgItem.bbProgram.startDate	= new Date(this.selectedProgram.startDate);
					bbPrgItem.bbProgram.endDate		= new Date(this.selectedProgram.endDate);
					
					// distributor info
					bbPrgItem.bbDistributor = this.selectedDistributor;
					
					bbPrgItem.bbProdRate.description	= arrProducts[i].description;
					bbPrgItem.bbProdRate.itemGuid		= arrProducts[i].itemGuid;
					bbPrgItem.bbProdRate.itemNumber		= arrProducts[i].itemNumber;
					bbPrgItem.bbProdRate.netWeight		= arrProducts[i].netWeight;
					bbPrgItem.bbProdRate.uom 			= uUOM;
					bbPrgItem.bbProdRate.bNotOnProgram 	= true;
					
					this.billback.bbPrgDistItemRate.push(bbPrgItem);
				}
			}
			dispatchEvent(new Event('editBillbackChanged'));
		}
		
		/* set BB for ReInterface */
		public function setBBForReinterfaceResult(returnbbHeader:BBHeader): void{ 	
			/* update the bbheader */
			setBillbackChanged(returnbbHeader);
			
			/* 	Once the billback has been set for Reinterface, "returnbbHeader.notAcknowledged" should be false meaning that the action
			is successful and the billback should not be not acknowledged anymore. */
			if(returnbbHeader.notAcknowledged == false){
				Alert.show('Reinterface is successful');
			}
			else{
				Alert.show('Reinterface failed');
			}		
		}
		
		/* open BB Sum By */
		public function bbSumBy(): void{  
			this.popUpBBSumBy = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,BBEditSum, true, null) as BBEditSum;
			PopUpManager.centerPopUp(popUpBBSumBy);
			popUpBBSumBy.billback = this.billback;
		}
		
		/* open BB Workflow */
		public function openBBWorkflow(oBBDetails:BBDetails) : void{  
			this.popUpWorkFlow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject,BBEditWorkflow, true, null) as BBEditWorkflow;
			PopUpManager.centerPopUp(popUpWorkFlow);
			popUpWorkFlow.oBBDetails = oBBDetails;
			popUpWorkFlow.oSettings = oSettings;
		}		
		
		/* open BB statement*/
		public function openBBStatement() : void{
			
			var sBBStatementType:String = this.oSettings.appSettings.BillBack_Statement_Type;
			var sBBStatementFile:String = ""; 
			
			if ( sBBStatementType ==  'claim-summary' ) {
				sBBStatementFile = 'summaryReport.cfm';						// claim auto print setting is on
			}
			else if ( sBBStatementType == 'pdf-v2' ) {
				sBBStatementFile = 'create_summary_statement.cfm';			// Solo statement type
			}
			else if ( sBBStatementType == 'excel-v3' ) {
				sBBStatementFile = 'xls_statement.cfm';						// GM excel statement
			}
			else {
				sBBStatementFile = 'claimsummary_report.cfm';				// Heinz claim summary statement
			}
			
			var winjscommand:String = "/billbacks/"+sBBStatementFile+"?Billback_ID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+winjscommand+"', 'statement', 'location=0,status=0,scrollbars=1,left=0,top=0,width=1030,height=600');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
			
		}		
		
		/* open BB Discrepancy Report */
		public function openBBDiscrepancyReport() : void{
			var winjscommand:String = "/billbacks/deviation/deviation_detail_report.cfm?BBID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+winjscommand+"', 'DiscrepancyReport', 'height=600,width=800,toolbar=no,scrollbars=yes,left=0,top=0,screenX=0,screenY=0,resizable=no');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");   
			navigateToURL(url, "_self");			
		}
		
		private function clone(source:Object):*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			var ret:* = myBA.readObject();
			//return(ret);
			return source;
		}
		
		public function resetConfirmation(msg:String,userId:String):void
		{
			if(msg != '')
			{
				Alert.show(msg);
			}
			else
			{
				Alert.show('The billback was reset successfully.\n\n Refreshing data now.');
				reloadBillbackEdit();
				/* var eventRefreshAfterReset:BBSearchEvent = new BBSearchEvent(BBSearchEvent.LOAD_BB_SEARCH);
				this.objBBFilterParams.loadArchive = '';
				
				eventRefreshAfterReset.eBBFilterParams = this.objBBFilterParams;
				eventRefreshAfterReset.userId = userId;							
				this._dispatcher.dispatchEvent(eventRefreshAfterReset); */
			}	
		}	
		
		/* Billback Reset : Same as disagree from the deviation grid*/
		public function bbReset():void{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("bbDisagreed", bbDisagreed);
			var winjscommand:String = "/Billbacks/common/BB_DisagreeFlx.cfm?bbReset=1&BBID=" + this.billback.bbHeader.billbackIDGUID + "&userID=" + this.oSettings.userId + "&source=flexBB" + "&FlexAppName="+currentAppName + "&IsBillbackApproved=1";
			var jscommand:String = "window.open('"+winjscommand+"', 'bbDisagreeWindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		// callback fn for disagree
		public function bbDisagreed(bbIDInt:String):void {
			/* Get the updated bbheader and reload it on "BB Edit" */
			this.reloadBillbackEdit();
			
			/* Get the updated bbheader and reload it on "BB Search" */
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.GET_UPDATED_BB_HEADER);
			e.bbIdInt = new int(bbIDInt);  
			this._dispatcher.dispatchEvent(e);			
		}
		
		// mass Update
		public function bbMassUpdate(evt:*):void{
			
		}
		
		/* validate the entry that is being mass updated */
		public function validateMassUpdate(e:*):void{
			
			var bValid:Boolean 				= false;
			var sValidateVal:String			= e.editText;
			var sValidateSource:String		= e.sSource;
			var acMassObj:ArrayCollection	= e.objMassUpdate;
			var sAlertMsg:String			= "";
			var iLumpSumDiscType:int		= 0;
			var iFixedRebateDiscType:int	= 0;
			var bFixedRebateError:Boolean 	= false;
			
			if(sValidateSource == 'bbProgram.number'){
				for each(var objBBPrg:BBProgram in this.acProgram){
					if(objBBPrg.number == sValidateVal){
						
						//Look for a selected component.  If it is from the same Program we are mass appying, capture the DiscType so we can apply it to the Item data
						for each(var comp:Component in this.acComponent){
							if(comp.isSelected && (comp.programNumber ==  sValidateVal)){
								iLumpSumDiscType = comp.type;
								if (comp.type == 1 || comp.type == 2 ){
									iFixedRebateDiscType = comp.type;  
								}
							}
						}
						var bbObj:BBProgram = new BBProgram();
						bbObj 				= objBBPrg;
						bValid				= true;
						break;
					}
				}
				// if both LS and Fixed/Component is zero alert user.
				if(iLumpSumDiscType == 0 && iFixedRebateDiscType == 0){
					sAlertMsg = "There is no component selected for the program that is getting applied.\nPlease select a component for " + sValidateVal + ".\nThen apply the mass program change again.";
					Alert.show(sAlertMsg);
					return;
				}
				
				if(!bValid){
					if(this.selectedProgram.number == sValidateVal){
						var bbObj:BBProgram 		= new BBProgram();
						bbObj.programId				= this.selectedProgram.programId;
						bbObj.number				= this.selectedProgram.number;
						bbObj.title					= this.selectedProgram.title;
						bbObj.startDate				= new Date(this.selectedProgram.startDate);
						bbObj.endDate				= new Date(this.selectedProgram.endDate);
						bbObj.effectiveStartDate	= new Date(this.selectedProgram.startDate);
						bbObj.effectiveEndDate		= new Date(this.selectedProgram.endDate);
						bbObj.bIsLatestVersion		= true;
						bValid						= true;
					}
				}
			}
			//END if(sValidateSource == 'bbProgram.number')
			else if(sValidateSource == 'bbDistributor.shipTo' && sValidateSource != this.billback.bbHeader.payee.payeeId){
				for each(var objBBCust:Customer in this.acDistributor){
					if(objBBCust.shipTo == sValidateVal){
						var bbDistObj:Customer	= new Customer();
						bbDistObj 				= objBBCust;
						bValid					= true;
						break;
					}
				}
			}
					
			if(bValid){
				for each(var objPrg:BBPrgDistItemRate in acMassObj.source){
					if (objPrg && objPrg.isSelected){
						if(sValidateSource == 'bbProgram.number'){
							// D60837 - See resolution notes. GM folks use items to report volume by applying a rebate/fixed component & then remove it and save.  
							// Compromise fix is to let the users save products after removing fixed/rebate component and use rebate as default discount type. 
							if(iFixedRebateDiscType == 0){
								iFixedRebateDiscType = 2;
								// bFixedRebateError = true;
								// bValid = false;
								// break;
							}
							objPrg.bbProgram = bbObj;
							objPrg.bbProdRate.discountType = iFixedRebateDiscType; //DiscountType from the selected component if it mataches Mass Apply PRG
						}
						else if(sValidateSource == 'bbDistributor.shipTo'){
							objPrg.bbDistributor = bbDistObj;
						}
					}
				}
			}
			
			if (!bValid){
				if((sValidateSource == 'bbProgram.number' && bFixedRebateError)){
					sAlertMsg = "No Fixed/Rebate components are selected for products of program " + sValidateVal + "\nPlease select a Fixed/Rebate component or remove items for Lumpsum component and mass apply program change";					
				}
				else if(sValidateSource == 'bbProgram.number'){
					sAlertMsg = "program # is not valid.";
				}
				else if(sValidateSource == 'bbDistributor.shipTo'){
					sAlertMsg = "assoc. distributor is not valid.";
				}
				
				Alert.show(sAlertMsg);
				return;				
			}
			
			
		}	// end  function validateMassUpdate
		
		
		public function bPayeeInDistributorList(acDistList:ArrayCollection):Boolean{
			var bExists:Boolean = false;
			for each(var objBBCust:Customer in acDistList){
				if(objBBCust.shipTo == this.billback.bbHeader.payee.payeeId){
					bExists	= true;
					break;
				}
			}
			return bExists;
		}
		
		/* When the bb is deleted from the edit screen, close the BB on delete */
		public function closeonDelete(stReturnData:Object):void
		{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB);
			e.bbHeader  = stReturnData.BBHEADER;
			this._dispatcher.dispatchEvent(e);
		}	
		
		private function saveSOitems():void
		{
			/* save the items to the client */
			var d:Date = new Date();			
			this._soAcProducts.data.dSavedDate = d;
			this._soAcProducts.data.itemList = new ArrayCollection(ObjectUtil.copy( this.acProducts.source ) as Array );
			
			/* If the shared object does not exist, then write the data to it. */		 
			if(!this._soAcProducts.data.customObject)
			{
				this._soAcProducts.flush(10000000);
			}	 	
			this._dSOlastSavedDate = d;
		}
		
		private function setdSOlastSavedDate():void
		{
			/* save shared object for the user based on UserID */
			this._soAcProducts = SharedObject.getLocal("bbAcProducts","/");	
			
			// set our dSOlastSavedDate to our received SO's dSavedDate
			if( ( this._soAcProducts.data.dSavedDate != undefined ) &&
				( this._soAcProducts.data.dSavedDate is Date ) )
			{
				this._dSOlastSavedDate = this._soAcProducts.data.dSavedDate as Date;
				//Alert.show("data from SO::" + this._soItems.data.dSavedDate);
				dispatchEvent(new Event('eSOlastSavedDate'));
			}
			else{			  
				this._dSOlastSavedDate = new Date(_dTodayDate.getFullYear(),_dTodayDate.getMonth(),(_dTodayDate.getDate()-1),0,0,0,0);
			}
		}
		
		public function loadSOitems():void 
		{
			// 1.) go get our SO
			this.setdSOlastSavedDate();
			var b:Boolean;
			// 2.) if we got a keeper
			if (this._soAcProducts.size > 1)
			{
				if(	( this._dSOlastSavedDate.getFullYear() == this._dTodayDate.getFullYear() ) && 
					( this._dSOlastSavedDate.getMonth() == this._dTodayDate.getMonth() ) &&
					( this._dSOlastSavedDate.getDate() == this._dTodayDate.getDate() ) )
				{
					if(
						( this._soAcProducts.data.itemList.length >= 0 ) )
					{
						// 5.) this._itemList from so
						this.acProducts = new ArrayCollection( ObjectUtil.copy( _soAcProducts.data.itemList.source ) as Array );
						
					}
					else
					{
						b=true;
					}
				}
				else
				{
					b=true;	
				}
			}	
			else
			{
				b=true;
			}
			if(b){
				var e:BBEditEvent = new BBEditEvent(BBEditEvent.LOAD_ITEM_LIST);
				this._dispatcher.dispatchEvent(e); 
			}
		}
		
	}
}