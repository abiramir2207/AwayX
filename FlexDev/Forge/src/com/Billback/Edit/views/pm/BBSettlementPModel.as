package com.Billback.Edit.views.pm
{
	import com.Billback.Edit.events.BBEditEvent;
	import com.Billback.Edit.models.vos.BBDeductionFilterParms;
	import com.Billback.Edit.models.vos.BBProdRate;
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.*;
	import com.Deduction.Main.models.vos.Deduction;
	import com.shared.components.StringUtils;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.BillTo;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.formats.Float;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.Label;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.core.FlexGlobals;
	import mx.events.DataGridEvent;
	import mx.events.ListEvent;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.utils.ObjectUtil;
	
	import spark.components.TextInput;
	
	public class BBSettlementPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBSettlementPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			this.arrSplitAction = [{description:"Write it off", id:"1",data:"writeoff"},
				{description:"RE-Instate", id:"2",data:"reinstate"}];
			//this.addEventListener('deleteEvent',this.tallyClosingRemainder,false,0,true);
		}
		
		
		/*.......................  Properties  .......................*/
		/*.................oSettings......................*/
		[Bindable]	public var oSettings:Settings = new Settings();
		//[Bindable]	public var billback:Billback = new Billback();
		[Bindable]	public var closingMethodList:Array = new Array();
		[Bindable] public var iFrmHeight:int = 15;
		[Bindable] public var arrBBClosingDetailDgCols:Array = new Array();
		[Bindable] public var arrBBDeductionDgCols:Array = new Array();
		[Bindable] public var arrSelectedDeductions:Array = new Array();
		[Bindable] public var acBBDeductions:ArrayCollection = new ArrayCollection();
		[Bindable] public var bbClosingdetail:BBClosingDetail;
		[Bindable] public var bbDeductionFilterParm:BBDeductionFilterParms = new BBDeductionFilterParms();
		[Bindable] public var nClosingRemainder:Number = 0;
		[Bindable] public var arrSplitAction:Array = new Array();
		[Bindable] public var sEditClosingDetailResult:String = '';
		[Bindable] public var sSubmitButtonText:String = 'approve';
		[Bindable] public var sSubmitButtonTip:String = '';
		//[Bindable] public var objBBToolsLock:BBToolsLock = new BBToolsLock();
		[Bindable] public var acBillTo:ArrayCollection = new ArrayCollection();
		[Bindable] public var bbBillTo:BillTo;
		[Bindable] public var bDrpBillToEnabled:Boolean = true;
		/*.................Billback......................*/
		private var _billback:Billback = new Billback();
		[Bindable (event="BillbackChangedSettlement")]
		public function get billback():Billback
		{
			return _billback;
		}
		public function set billback(bb:Billback):void
		{
			this._billback = bb;
			/*OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO*/
			/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  UNCOMMENT :: TEST DATA XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
			this.bbDeductionFilterParm.iBillbackId = bb.bbHeader.billbackIDInt;
			this.tallyClosingRemainder();
			//this.bEditable = false; //fires setter
			dispatchEvent(new Event('BillbackChangedSettlement'));
			dispatchEvent(new Event('budgetLabelChanged'));
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
			this._acBBClosingDetail = ac;
			dispatchEvent(new Event('acBBClosingDetailChanged'));
			
			/* Disable/Enable deduction search/grid */
			dispatchEvent(new Event('bDeductionEditable'));
		}
		
		/*.................bbSettlementAction......................*/
		private var _bbSettlementAction:BBSettlementAction = new BBSettlementAction();
		[Bindable (event="bbSettlementActionChanged")]
		public function get bbSettlementAction():BBSettlementAction
		{
			return _bbSettlementAction;
		}
		public function set bbSettlementAction(bbStlAct:BBSettlementAction):void
		{
			this._bbSettlementAction = bbStlAct;
			dispatchEvent(new Event('bbSettlementActionChanged'));
		}
		/*.................bApprovable......................*/
		private var _bApprovable:Boolean;
		[Bindable (event="bApprovableChanged")]
		public function get bApprovable():Boolean
		{
			return (	this.nClosingRemainder == 0 && //NO Balance left
				this.bEditable	&&	//and user has rights to edit
				objBBToolsLock.bSettlementScreenEnabled == true  && // This includes bb status and user locked status
				this.billback.bbHeader.status.subStatus != 3 // If the logged in user has not agreed to the billback
			)
		}
		
		/*.................bEditable......................*/
		private var _bEditable:Boolean;
		[Bindable (event="bEditableChanged")]
		public function get bEditable():Boolean
		{	
			return (	
				/* Note: 30780 - Milan: For some reason, we still need the "this.billback.bbHeader.status.id < 3" here. Need to test that later.
				We should not need it as "objBBToolsLock.bSettlementScreenEnabled" shoud take care of status.
				*/
				this.billback.bbHeader.status.id < 3 && //BB status < approved
				this.oSettings.user.stProfileSettings.BB_APPROVE && //User Profile BB Approval Rights				
				objBBToolsLock.bSettlementScreenEnabled == true && // This includes bb status and user locked status
				this.billback.bbHeader.status.subStatus != 3 // If the logged in user has not agreed to the billback
			)
		}
		
		/*.................bDeductionEditable......................*/
		private var _bDeductionEditable:Boolean;
		[Bindable (event="bDeductionEditable")]
		public function get bDeductionEditable():Boolean
		{	
			return (			
				this.billback.bbHeader.payee.payeeTypeId != 2 &&  // If the payee is not an operator
				objBBToolsLock.bSettlementScreenEnabled == true // This includes bb status and user locked status
			)
		}
		
		
		
		/*.................budgetLabel......................*/
		private var _budgetLabel:String;
		[Bindable (event="budgetLabelChanged")]
		public function get budgetLabel():String
		{	
			return (	
				(this.billback.bbHeader.bbSettlement.bIsBillbackWithinBudget) ? 'within budget' : 'over budget'
			)
		}
		
		/*.................BB Tools.....................*/
		private var _BBToolsLock:BBToolsLock = new BBToolsLock();
		[Bindable (event="settleObjBBToolsLockChanged")]
		public function get objBBToolsLock():BBToolsLock
		{
			return _BBToolsLock;
		}
		
		public function set objBBToolsLock(objBBToolsLock:BBToolsLock):void
		{
			this._BBToolsLock = objBBToolsLock;
			dispatchEvent(new Event('settleObjBBToolsLockChanged'));
			dispatchEvent(new Event('bEditableChanged'));
			dispatchEvent(new Event('bDeductionEditable'));
		}
		/*.......................  Methods  .......................*/
		
		public function closeBB():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB);
			if(this.billback){
				e.bbHeader  = this.billback.bbHeader;
			}
			this._dispatcher.dispatchEvent(e);
		}
		
		public function approve():void{
			
			if (this.billback.bbHeader.strDefaultProgram != '' && this.billback.bbHeader.strDefaultProgram != '0'){
				Alert.show('This billback has the default program ( ' + this.billback.bbHeader.strDefaultProgram + ' ) associated with it. Please transfer all records off of the default program to continue.');
			}
			else{
				
				if(this.nClosingRemainder <= 0){
					cleanBBClosingDetail();
					var e:BBEditEvent = new BBEditEvent (BBEditEvent.SAVE_SETTLEMENT);
					//e.billback = this.billback;
					e.bbHeader = this.billback.bbHeader;
					e.bbSettlementAction = this.bbSettlementAction;
					this._dispatcher.dispatchEvent(e);
				}
				else{
					Alert.show('There is a balance that must be accounted for.  Please settle the total expected dollars.');
				}	
			}
			
		}
		/* TODO:WORKOUT flag and backend logic to differntiate save and approve*/
		public function save():void{
			if(this.nClosingRemainder <= 0){
				cleanBBClosingDetail();
				this.bbSettlementAction.action = 'save';
				var e:BBEditEvent = new BBEditEvent (BBEditEvent.SAVE_SETTLEMENT);
				//e.billback = this.billback;
				e.bbHeader = this.billback.bbHeader;
				e.bbSettlementAction = this.bbSettlementAction;
				this._dispatcher.dispatchEvent(e)
			}
			else{
				Alert.show('There is a balance that must be accounted for.  Please settle the total expected dollars.');
			}
			
		}
		//Set values to appropriate sign ( + or - )
		private function cleanBBClosingDetail():void{
			var arr:Array = new Array();
			var cmId:int = 0;
			var amount:Number;
			for each(var bbClosingDetail:BBClosingDetail in this.billback.bbHeader.bbSettlement.bbClosingDetail){
				cmId = bbClosingDetail.closingMethod.id;
				if(bbClosingDetail.amount != 0){
					bbClosingDetail.amount = cleanAmountBasedOnClosingMethod(cmId,bbClosingDetail.amount);
					arr.push(bbClosingDetail);
				}
			}
			this.billback.bbHeader.bbSettlement.bbClosingDetail = arr;
		}
		//Set values to appropriate sign ( + or - )
		private function cleanAmountBasedOnClosingMethod(cmId:int,amount:Number):Number{
			//POSITIVE
			if(cmId == ClosingMethod.PAYMENT_ID || cmId == ClosingMethod.PAYMENT_EFT_ID || cmId == ClosingMethod.CREDIT_ID){
				amount = Math.abs(amount);
			}
			//NEGATIVE
			if(cmId == ClosingMethod.REINSTATE_ID || cmId == ClosingMethod.DEBIT_ID){
				amount = (Math.abs(amount) * -1);
			}
			// EITHER WAY: cmId == ClosingMethod.WRITEOFF_ID || 
			return amount;
		}
		
		public function close():void{
			var e:BBEditEvent = new BBEditEvent (BBEditEvent.SELECT_TAB);
			//select the edit tab.  Always first.  0 based index
			e.iIndex = 0;
			this._dispatcher.dispatchEvent(e);	
		}
		
		public function loadDeviations():void
		{
			if(this.billback.bbHeader.status.id == 1){
				var e:BBEditEvent= new BBEditEvent(BBEditEvent.VALIDATE_BB_EDIT_DTL);
				e.billback  = this.billback;
				this._dispatcher.dispatchEvent(e);
			}
			else{
				if(this.oSettings.user.stProfileSettings.BB_VIEW_DEVIATION == 1){
					
					var evt:BBEditEvent= new BBEditEvent(BBEditEvent.RUN_DEVIATIONS);
					evt.billback = this.billback;
					evt.bbIdInt	= this.billback.bbHeader.billbackIDInt;
					evt.userId  = this.oSettings.userId;
					evt.sState = 'settlement';
					this._dispatcher.dispatchEvent(evt);
				}
			}
		}		
		
		public function itemEditEndDgClosing(event:DataGridEvent):void{
			
			var ti:mx.controls.TextInput = new mx.controls.TextInput();
			var dg:DataGrid = event.currentTarget as DataGrid;
			if(event.dataField!= 'closingMethod' && event.dataField!= 'Deduction'){
				ti = mx.controls.TextInput(event.currentTarget.itemEditorInstance);
			}
			var e:* = event;
			
			var s:String = ti.text.replace(',','');
			s = s.replace('(','');
			s = s.replace(')','');
			//s = s.replace('-','');
			var nAmount:Number = StringUtils.roundDec(Number(s),2);
			var bError:Boolean = false;
			var sColName:String = event.currentTarget.columns[event.columnIndex].headerText;
			var sError:String = 'please enter a valid ' + sColName;
			sEditClosingDetailResult = '';
			//sEditClosingDetailResult = 'event: ' + event.reason + ' :: ' + event.rowIndex.toString() + ' :: ' + event.target.id + '\n' + sEditClosingDetailResult ;
			//switch event.dataField and run validations
			
			var bDeductionExists:Boolean = false;
			
			/* Loop over the closing methods and check whether the deduction amount is not zero. */
			for each(var closeDetail:BBClosingDetail  in this.acBBClosingDetail){
				var cm:ClosingMethod = closeDetail.closingMethod;
				var cmAmt:Number = closeDetail.amount;
				if (cm.id == 2 && cmAmt != 0){
					bDeductionExists = true;
					break;
				}
			}
			
			switch(event.dataField)
			{
				case 'amount':
					var data:BBClosingDetail = event.itemRenderer.data as BBClosingDetail;
					
					//adjust the sign
					nAmount = cleanAmountBasedOnClosingMethod(data.closingMethod.id,nAmount);
					
					if(s.length == 0 || isNaN(Number(s))){
						//error
						bError = true;
						sError = 'please enter a valid number';
					}
					else if(Number(s) > billback.bbHeader.finalSelectedAmount && (data.closingMethod.id == ClosingMethod.PAYMENT_ID || data.closingMethod.id == ClosingMethod.PAYMENT_EFT_ID )){
						//error
						bError = true;
						sError = 'please enter a number less than the approved amount: ' + com.shared.components.StringUtils.getDollarDec(billback.bbHeader.finalSelectedAmount.toString());
					}
					else if(data.closingMethod.id == ClosingMethod.REINSTATE_ID && bDeductionExists == false){
						//error
						bError = true;
						//sError = 'please enter a positive number for deduction before entering an amount for reinstate';	
						/* Reinstate goes with deduction only */
						sError = 'please enter a value for deduction before entering an amount for reinstate';	
					}
						/*else if(data.closingMethod.id == ClosingMethod.REINSTATE_ID || data.closingMethod.id == ClosingMethod.WRITEOFF_ID){
						//make negative
						nAmount = Math.abs(nAmount) * -1;
						s = nAmount.toString();
						this.bbClosingdetail.amount = Number(s);
						ti.text = s;
						}
						else if(Number(s) < 0 ){
						//error
						bError = true;
						sError = 'please enter a positive number.';
						}*/
					else{
						this.bbClosingdetail.amount = nAmount;
						ti.text = nAmount.toString();
					}
					break;
				/*	case 'specialHandling':
				if(s.length < 4){
				//error
				bError = true;
				}
				break;*/
				default:
					//trace("Out of range");
					break;
			}
			//update the ui
			if(bError){
				//error
				event.preventDefault();
				ti.setStyle('color','red');
				ti.setStyle('font-style','italic');
				ti.toolTip = sError;
				//Alert.show(sError,'Edit Amount Alert');
				sEditClosingDetailResult = sError + '\n';// + sEditClosingDetailResult 
				//	highlightError(event.currentTarget.itemEditorInstance as TextInput);
			}
			else{
				//ok
				ti.setStyle('color','black');
				ti.setStyle('font-style','');
				ti.toolTip = '';	
			}
			tallyClosingRemainder();
			//this.showAlert(event.reason,'TEST');
		}
		
		public function showAlert(s:String,sTile:String=''):void{
			Alert.show(s,sTile);
		}
		
		public function itemEditBeginDgClosing(event:DataGridEvent):void{
			if( event.itemRenderer){
				var data:BBClosingDetail = event.itemRenderer.data as BBClosingDetail;
				var dgIr:DataGridItemRenderer = event.itemRenderer as DataGridItemRenderer;
				var l:DataGridListData = dgIr.listData as DataGridListData;
				var dg:DataGrid = DataGrid(l.owner);
				dg.selectedItem = data;
				dg.dispatchEvent(new ListEvent(ListEvent.CHANGE));
				if(l.dataField == 'amount' && data.closingMethod.id == ClosingMethod.DEDUCTION_ID){
					var sError:String = '';
					sError = 'Closing amount is not editable for ' + ClosingMethod.DESCRIPTION;
					dgIr.toolTip = sError;
					event.preventDefault();
				}
			}			
		}
		
		public function itemEditEndDgDeduction(event:DataGridEvent):void{
			var e:* = event;
		}
		
		public function selectBBClosingDetail(event:ListEvent):void{
			
			this.bbClosingdetail = event.currentTarget.selectedItem as BBClosingDetail;
			//if a deduction is getting removed then renable the bill to drop down
			if (this.bbClosingdetail.closingMethod.id == 2 && bFilterOnBillTo()){
				this.bDrpBillToEnabled = true;
			}
			
		}
		
		public function setListenerDgBBDeduction(dg:DataGrid):void{
			dg.addEventListener(KeyboardEvent.KEY_UP, keyHandlerDgBBDeduction);
		}
		/* user hits [ENTER] in the deductions grid */
		public function keyHandlerDgBBDeduction(event:KeyboardEvent):void
		{
			
			if(event.keyCode == 13 && event.charCode == 13)
			{
				lockDeductions(event.currentTarget.selectedItems);
			}
		}
		
		//user double clicks a deduction in the deductiongrid
		public function selectDeduction(event:MouseEvent):void{
			var cmDeduction:ClosingMethod;
			//get deduction closing method
			lockDeductions(event.currentTarget.selectedItems);		
		}
		
		public function lockDeductions(arr:Array):void{
			/*set var to be used after we try to lock deductions*/
			this.arrSelectedDeductions = arr;
			var e:BBEditEvent = new BBEditEvent (BBEditEvent.LOCK_DEDUCTION);
			e.arrDeduction = arr;
			e.bLock = true;
			this._dispatcher.dispatchEvent(e);
			//enable or disable bill to drop down based on conditions from bFilterOnBillTo()
			if (bFilterOnBillTo()){
				this.bDrpBillToEnabled = false;	
			}
			
		}
		
		public function unLockDeductions(arr:Array):void{
			/*set var to be used after we try to unlock deductions*/
			var e:BBEditEvent = new BBEditEvent (BBEditEvent.LOCK_DEDUCTION);
			e.arrDeduction = arr;
			e.bLock = false;
			this._dispatcher.dispatchEvent(e);
			//enable or disable bill to drop down based on conditions from bFilterOnBillTo()
			if (bFilterOnBillTo()){
				this.bDrpBillToEnabled = true;	
			}
		}
		
		//result handler for remote call BBEditEvent.LOCK_DEDUCTION
		public function applyDeductions(arr:Array,bLockAction:Boolean):void{
			/*set var to be used after we try to lock deductions*/
			var arrNotLockedDeductions:Array = new Array();
			var s:String = '';
			var cmDeduction:ClosingMethod;
			//get deduction closing method
			for each(var closeDetail:BBClosingDetail  in this.acBBClosingDetail){
				var cm:ClosingMethod = closeDetail.closingMethod;
				if (cm.id == ClosingMethod.DEDUCTION_ID){
					cmDeduction = cm;
					break;
				}
			}
			if(cmDeduction){
				//insert each ded that is selected
				for each(var dd:Deduction in arr){
					//if the deduction is locked and it is locked by me
					if(dd.lockObj.bLocked && dd.lockObj.userLocked.id == this.oSettings.userId){
						//addClosingMethod(cmDeduction,false);
						this.bbClosingdetail = closeDetail;//from loop above
						saveDeduction(dd);
					}
					else{
						arrNotLockedDeductions.push(dd.deductionNumber);
						s = s + dd.deductionNumber + ': locked (' + dd.lockObj.bLocked + ') ' + 'user (' + dd.lockObj.userLocked.fullName + ')' + '\n';
					}
				}	
			}//if we are trying to lock a deduction but it fails (already locked etc) show a message
			if(arrNotLockedDeductions.length && bLockAction){
				Alert.show(s);
			}
			
			this.tallyClosingRemainder();
		}
		//DEPRECATED
		//originally user would "add" the Closing Method hey wanted.  Now it is used only for Deductions.  If they can add Multiple then a new CM would get inserted.
		public function addClosingMethod(closingMethodToAdd:ClosingMethod,bAlert:Boolean=true):void{
			
			var bInsert:Boolean = true;
			var nAmount:Number = 0;
			//clear error text
			sEditClosingDetailResult = '';
			//check if it is in list and get remainder
			for each(var closeDetail:BBClosingDetail in this.acBBClosingDetail){
				var cMeth:ClosingMethod = closeDetail.closingMethod;
				//tally existing
				nAmount = nAmount + closeDetail.amount;
				//set "selected" bbClosingdetail.  Insert New Deductions if Multiple deds is allowed (appsetting)
				if(cMeth.id == closingMethodToAdd.id && (closingMethodToAdd.id != ClosingMethod.DEDUCTION_ID || !this.oSettings.appSettings.Allow_Multiple_Deduction_Settlement) ){
					bInsert = false;
					this.bbClosingdetail = closeDetail;
					break;
					//Alert.show('The closing method ' + closingMethodToAdd.description + ' has already been applied','Settlement Alert');
				}
			}
			if(bInsert){
				var newAmount:Number = 0;
				//deduction amount comws from the deduction applied
				if(closingMethodToAdd.id != ClosingMethod.DEDUCTION_ID){
					newAmount = this.billback.bbHeader.finalSelectedAmount - nAmount;
				}
				var bbClosingDetail:BBClosingDetail =  new BBClosingDetail();//closingMethodToAdd,newAmount
				bbClosingDetail.closingMethod = closingMethodToAdd;
				bbClosingDetail.amount = newAmount;
				var e:BBEditEvent = new BBEditEvent (BBEditEvent.SAVE_CLOSING_DETAIL);
				e.bbClosingDetail = bbClosingDetail;
				this._dispatcher.dispatchEvent(e);
				//select
				this.bbClosingdetail = bbClosingDetail;
			}
			else if(bAlert){
				var s:String = 'Closing Method "' + closeDetail.closingMethod.description + '" has already been added.';
				Alert.show(s,'Closing Method Insert Alert');
			}
			this.tallyClosingRemainder();
			//this.billback.bbClosingDetail.push(new BBClosingDetail(closingMethodToAdd));
		}
		
		public function saveDeduction(dd:Deduction):void{
			var bSave:Boolean = true;
			//check if deduction is already saved
			// COMMENTED OUT.  AUTOMATICALLY TAKE THE NEW ONE
			/*for each(var bbCloseDet:BBClosingDetail in this.acBBClosingDetail){
			if(bbCloseDet.deduction && (bbCloseDet.deduction.deductionID == dd.deductionID || !this.oSettings.appSettings.Allow_Multiple_Deduction_Settlement )){
			bSave = false;
			break;
			}
			}
			if(bSave){
			this.bbClosingdetail.deduction = dd;
			this.bbClosingdetail.amount = dd.amount;
			tallyClosingRemainder();
			}
			else{
			//this.acBBClosingDetail.removeItemAt(this.acBBClosingDetail.getItemIndex(this.bbClosingdetail));
			this.bbClosingdetail = bbCloseDet;
			var s:String = 'Deduction ' + bbCloseDet.deduction.deductionNumber + ' has already been applied';
			Alert.show(s,'Deduction Save Alert');
			}*/
			
			//if we don't allow multimple, unlock the existing ded if(deductionID is not null && not ddid = '') 
			
			if(!this.oSettings.appSettings.Allow_Multiple_Deduction_Settlement && (this.bbClosingdetail.deduction && this.bbClosingdetail.deduction.deductionID != '')){
				//this.unLockDeductions(new Array(this.bbClosingdetail.deduction));
				var event:MainEvent = new MainEvent(MainEvent.CLEAR_ROW);
				event.objRowData = this.bbClosingdetail;
				this.clearRow(event);
			}
			this.bbClosingdetail.deduction = dd;
			this.bbClosingdetail.amount = dd.amount;
			/*for each(var bbClosingDetail:BBClosingDetail in this.billback.bbHeader.bbClosingDetail){
			var i:int = bbClosingDetail.closingMethod.id;
			if( i == ClosingMethod.REINSTATE_ID || i == ClosingMethod.WRITEOFF_ID){
			bbClosingDetail.deduction = dd;
			}
			}*/
			
			this.tallyClosingRemainder();
			
		}
		
		public function callTallyFromDelete(event:MainEvent):void{
			if(event.objRowData is BBClosingDetail){
				this.tallyClosingRemainder();
			}
		}
		//Handle the delete row event dispatched by filterDatagrid.  This is for the Closing Method Grid
		public function clearRow(event:MainEvent):void{
			if(event.objRowData is BBClosingDetail){
				var bbClsToClear:BBClosingDetail = event.objRowData  as BBClosingDetail;
				for each(var bbClosingDetail:BBClosingDetail in this.billback.bbHeader.bbSettlement.bbClosingDetail){
					//if deduction, clear write of and re-instate amounts
					if(bbClsToClear.closingMethod.id == ClosingMethod.DEDUCTION_ID && (bbClosingDetail.closingMethod.id == ClosingMethod.REINSTATE_ID || bbClosingDetail.closingMethod.id == ClosingMethod.WRITEOFF_ID )){
						bbClosingDetail.amount = 0;
						bbClosingDetail.deduction = null;
						bbClosingDetail.bbHeader = null;
					}
					if(bbClsToClear.closingMethod.id == bbClosingDetail.closingMethod.id){
						//bbClosingDetail= new BBClosingDetail();
						//unlock deduction
						if(bbClsToClear.closingMethod.id == ClosingMethod.DEDUCTION_ID && (bbClsToClear.deduction && bbClsToClear.deduction.deductionID == bbClosingDetail.deduction.deductionID)){
							this.unLockDeductions(new Array(bbClsToClear.deduction));
						}
						bbClosingDetail.amount = 0;
						bbClosingDetail.deduction = null;
						bbClosingDetail.bbHeader = null;
					}
				}
				this.tallyClosingRemainder();
			}
		}
		//Called any time a closing method is Modified.  recalc the remainder and decide if things are in an approvable state
		private function tallyClosingRemainder():void{
			var nAmount:Number = 0;
			var dedAmount:Number = 0;
			var nonCloseMethAmount:Number = 0
			var ded:Deduction;
			var dedRemainder:Number = 0;
			var cmId:int = 0;
			// by default the user can approve the DD write off we will check and set it to false so the use can only agree.
			var isDDWriteOffApprovable:Boolean = true;
			var ddWriteOffAmount:Number = 0;
			var stProfileSettings:Object = this.oSettings.user.stProfileSettings;
			var	strDDWriteOffAmt:String = stProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT;
			//determine Save Button text.  Save method will also check 
			var deviAmount:Number = parseFloat((this.billback.bbHeader.finalSelectedAmount - this.billback.bbHeader.expectedAmt).toString());
			var approveAmount:Number = parseFloat(stProfileSettings.BB_TOT_APPROVE_AMOUNT);
			var approveDeviAmount:Number = parseFloat(stProfileSettings.BB_APPROVE_AMOUNT);
			this.sSubmitButtonText = 'agree';
			this.bbSettlementAction.action = 'agree';
			//clear error text
			//sEditClosingDetailResult = '';
			//check if it is in list and get remainder
			
			if (strDDWriteOffAmt == '*')
			{
				// do nothing as isDDWriteOffApprovable is already true 
				
			}
			else if(strDDWriteOffAmt == '0' || strDDWriteOffAmt == '')
			{
				// isDDWriteOffApprovable = false;
				ddWriteOffAmount = 0;
			}
			else
			{
				//isDDWriteOffApprovable = false;
				ddWriteOffAmount = 	parseFloat(stProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT);
			}
			//Loop over Closing Detailsl to sum up Amounts. nAmount = real closing methods.  Not reinstate or writeoff.  dedAmount = deduction Amount.
			//nonCloseMethAmount = writeoff  + Reinstate amounts
			for each(var closeDetail:BBClosingDetail in this.acBBClosingDetail){
				cmId = closeDetail.closingMethod.id;
				closeDetail.amount = StringUtils.roundDec(closeDetail.amount,2);
				/*	Tim Ford 02/13/2012 - Label 30371: BB Settlement - Cannot approve after save as balance does not add up
				Put the code below in place to handle for Re-Instate and Write-Off Split Deductions that have been saved to the DB.
				We don't want to calculate these deductions into the amount because they will cause the balance to not
				add up correctly.
				*/
				if ((cmId != ClosingMethod.WRITEOFF_ID && cmId != ClosingMethod.REINSTATE_ID) || closeDetail.deduction == null || closeDetail.deduction.spNumber == ''){
					nAmount = nAmount + closeDetail.amount;	
				}
				
				//}
				//get deduction info
				if(cmId == ClosingMethod.DEDUCTION_ID && closeDetail.amount != 0){
					dedAmount = closeDetail.amount;
					ded = closeDetail.deduction;
				}
				//sum non closing method amounts writeoff + re-instate
				if((cmId == ClosingMethod.WRITEOFF_ID || cmId == ClosingMethod.REINSTATE_ID) && closeDetail.amount != 0){
					nonCloseMethAmount = nonCloseMethAmount + closeDetail.amount;
				}
				
			}
			//closing Remainder is the Balance of This BB that is not accounted for.
			this.nClosingRemainder = StringUtils.roundDec(this.billback.bbHeader.finalSelectedAmount - nAmount,2);
			this.bbDeductionFilterParm.nBalance = nClosingRemainder;
			this.bbSettlementAction.balance = nClosingRemainder;
			dedRemainder = dedAmount - this.billback.bbHeader.finalSelectedAmount;
			
			/* now set writeoff or reinstate deduction properties
			if the Total Amounts selected [not write off or reinstate] > selectedAmount and a ded exists, then
			write off or reinstate gets applied to the deduction else to the BB  
			....Only update if it is editable */
			if(this.bEditable){
				for each(var closeDetail2:BBClosingDetail in this.acBBClosingDetail){
					var i2:int = closeDetail2.closingMethod.id;
					//reinstate is always associated to deduction
					if(i2 == ClosingMethod.REINSTATE_ID){
						
						closeDetail2.deduction = ded;
					}
					//Handle for Write OFF -> writeoff swings both ways
					if(i2 == ClosingMethod.WRITEOFF_ID){
						//see if we can approve agree based on stProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT
						if(strDDWriteOffAmt != '*' && Math.abs(closeDetail2.amount) > ddWriteOffAmount){
							isDDWriteOffApprovable = false;
						}
						
						//Auto Select the deduction if appropriate
						if(ded && ((nAmount - nonCloseMethAmount) >= this.billback.bbHeader.finalSelectedAmount)){
							closeDetail2.deduction = ded;
						}
						else{
							closeDetail2.deduction = null;
						}
					}
					//now set appropriate
				}
			}
			
			//Check Profile and Template settings to see if User can Approve or Agree.  They Must have BB APPROVE to even Consider this.
			if(stProfileSettings.BB_APPROVE){
				
				if(		// set above -> writeoff amount < DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT
					isDDWriteOffApprovable
					&&
					(//Profile Approval Amount
						(approveAmount && approveAmount >= this.billback.bbHeader.finalSelectedAmount) ||
						(stProfileSettings.BB_TOT_APPROVE_AMOUNT.toString() == '*')
					)
					&&
					(//Profile setting BB_APPROVE_AMOUNT // removed (approveDeviAmount &&) 
						(approveDeviAmount >= (deviAmount)) ||
						(stProfileSettings.BB_APPROVE_AMOUNT.toString() == '*' )
					)
					&&
					(//Profile can approve Last date to Claim or it is NOT BEYOND LAST DATE To CLAIM	
						stProfileSettings.APPROVE_LAST_DATE_TO_CLAIM ||
						!this.billback.bbHeader.bbSettlement.lastDateToClaim 
					)
					&&
					(	//Profile can approve Beyond Budget or BB is Within Budget
						this.oSettings.appSettings.Budgets_Functionality_On == 0 
						||
						(
							stProfileSettings.APPROVE_BB_BEYOND_BUDGET ||
							this.billback.bbHeader.bbSettlement.bIsBillbackWithinBudget
						)
						
					)
					&& //The user has approval rights for this template
					(
						this.billback.bbHeader.bbSettlement.templateApproval
					)
				){
					this.sSubmitButtonText = 'approve';
					this.bbSettlementAction.action = 'approve';
				}
			}
			// leave the staggered formatting below.  It is necessary for proper display
			var strBBApprove:String = stProfileSettings.BB_APPROVE == true ? 'True' : 'False';
			var strTmplApprove:String = this.billback.bbHeader.bbSettlement.templateApproval == true ? 'True' : 'False';
			var strTotApproveAmt:String = stProfileSettings.BB_TOT_APPROVE_AMOUNT.toString() == '*' ? '*' : com.shared.components.StringUtils.getDollarDec(stProfileSettings.BB_TOT_APPROVE_AMOUNT);
			var strApproveAmt:String = stProfileSettings.BB_APPROVE_AMOUNT.toString() == '*' ? '*' : com.shared.components.StringUtils.getDollarDec(stProfileSettings.BB_APPROVE_AMOUNT);
			var strWriteOffAmt:String = stProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT.toString() == '*' ? '*' : com.shared.components.StringUtils.getDollarDec(stProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT);
			var strAppBeyBudgt:String =  stProfileSettings.APPROVE_BB_BEYOND_BUDGET == true ? 'True' : 'False';
			var strAppLstDtClm:String = stProfileSettings.APPROVE_LAST_DATE_TO_CLAIM == true ? 'True' : 'False';
			
			this.sSubmitButtonTip =	
				'User has billback approval rights:								'+strBBApprove+
				'\nUser has approval rights for program template:					'+strTmplApprove+
				'\nTotal billback amount user can approve:						'+strTotApproveAmt+
				'\nTotal deviation amount user can approve:						'+strApproveAmt+
				'\nTotal write off amount user can approve:						'+strWriteOffAmt+
				'\nUser has rights to approve billback beyond budget:				'+strAppBeyBudgt+
				'\nUser has rights to approve billback beyond last date to claim:	'+strAppLstDtClm;	
			
			// '\nBB Last Date To Claim:          ' + this.billback.bbHeader.bbSettlement.lastDateToClaim.toString() + ')';
			this.acBBClosingDetail.refresh();
			dispatchEvent(new Event('acBBClosingDetailChanged'));
			//let the ui know that things might have changed
			dispatchEvent(new Event('bApprovableChanged'));
			dispatchEvent(new Event('bEditableChanged'));
		}
		
		public function tiResultHandler(s:String):void{
			this.sEditClosingDetailResult = s;
		}
		
		public function chkSpecialHandlingHandler(b:Boolean):void{
			this.billback.bbHeader.bbSettlement.bSpecialHandling = b;
		}
		
		public function tiPaymentNotesHandler(s:String):void{
			if(s.length < 45){
				this.billback.bbHeader.bbSettlement.paymentNotes = s;	
			}
			else{
				this.billback.bbHeader.bbSettlement.paymentNotes = s.substring(0,44);
				Alert.show("Max length allowed is 44 charatcters.","Validation Alert")
			}
			dispatchEvent(new Event('BillbackChangedSettlement'));
			
		}
		
		/*..................................................................................*/
		/*...........................  DEDUCTIONS LIST HANDLERS  ...........................*/
		/*..................................................................................*/
		
		
		public function getDeductions():void{
			
			var evt:BBEditEvent = new BBEditEvent ( BBEditEvent.LOAD_BB_DEDUCTIONS );
			//check to see if mutiple bill to and restrict dd from ship on bb are on and a bill to exists
			if(bFilterOnBillTo()){
				this.bbDeductionFilterParm.strDistributorId = this.billback.bbHeader.billTo.shipToId;
			}
				//restrict dd from ship on bb app setting
			else if (this.oSettings.appSettings.DD_Restrict_ShipTo_For_BB){
				this.bbDeductionFilterParm.bDistributor = true;
			}
			evt.bbDeductionFilterParms = this.bbDeductionFilterParm;
			this._dispatcher.dispatchEvent( evt );
		}
		
		public function chkItemAmountHandler(b:Boolean):void{
			this.bbDeductionFilterParm.bAmount = b;
		}
		
		public function chkDistributorHandler(b:Boolean):void{
			this.bbDeductionFilterParm.bDistributor = b;
		}
		
		public function chkBalanceHandler(b:Boolean):void{
			this.bbDeductionFilterParm.bBalance = b;
		}
		
		public function tiKeywordHandler(s:String):void{
			this.bbDeductionFilterParm.sKeyword = s;
		}
		public function cmbSplitActionHandler(s:String):void{
			this.bbSettlementAction.action = s;
		}
		
		public function showDiscrepancyReport():void{
			//window.open("/billbacks/xls_Statement.cfm?Billback_id=" + bb_id + "","statement","location=0,status=0,scrollbars=1,left=0,top=0,width=1030,height=600");
			var jsURL:String = "/billbacks/xls_Statement.cfm?Billback_id="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+ jsURL + "','statement','location=0,status=0,scrollbars=1,left=250,top=250,width=500,height=500');";			
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);"); 
			navigateToURL(url, "_self");
			/*var e:MainEvent = new MainEvent(MainEvent.DOWNLOAD_FILE);
			var s:String = this.oSettings.appSettings.bbUploadFilePath + jsURL;
			e.sState = 'DiscrepancyReport.xls';
			e.sURL = oSettings.sURL + jsURL;// + sfileName;
			this._dispatcher.dispatchEvent(e);*/
		}
		/* This is used to open the pop up for the budget screen */
		public function showBudget():void
		{
			var jsURL:String = "/billbacks/APPROVAL/advanced_budget_billback.cfm?Billback_ID="+this.billback.bbHeader.billbackIDGUID;
			var jscommand:String = "window.open('"+ jsURL + "','winBudget','height=640,width=1300,toolbar=no,scrollbars=yes,resizable=yes');";			
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);"); 
			navigateToURL(url, "_self"); 
		}
		
		/* This function gets called when the Disagree button is clicked */	
		public function fnDisagreeClicked():void
		{
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("bbDisagreed", bbDisagreed);
			
			var winjscommand:String = "/Billbacks/common/BB_DisagreeFlx.cfm?BBID=" + this.billback.bbHeader.billbackIDGUID + "&userID=" + this.oSettings.userId + "&source=flexBB" + "&FlexAppName="+currentAppName;
			var jscommand:String = "window.open('"+winjscommand+"', 'bbDisagreeWindow', 'height=600,width=900,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
			
		} 
		
		/* callback function for disagree.  */
		public function bbDisagreed(bbIDInt:String):void {			
			/* Get the updated bbheader and reload it on "BB Search" */
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.GET_UPDATED_BB_HEADER);
			e.bbIdInt = new int(bbIDInt);  
			this._dispatcher.dispatchEvent(e);
			
			/* Go to the "edit" tab as the "settlement" tab is blank now. */
			close();
		}
		
		public function drpBillToHandler(o:BillTo):void{
			this.billback.bbHeader.billTo = o;
			
		}
		
		public function bFilterOnBillTo():Boolean{
			var b:Boolean = false;
			if(this.oSettings.appSettings.Multiple_BillTos_For_ShipTo && this.oSettings.appSettings.DD_Restrict_ShipTo_For_BB && this.acBillTo.length){
				b = true;
			}
			return b;
		}
		
		public function cmToolTip(item:Object):String{
			var str:String = "";
			if(item != null && item.closingMethod && item.closingMethod.id == 2 && item.deduction != null && item.deduction.amountParent > 0)
			{
				str = str + "Total Deduction Amount $" + item.deduction.amountParent;
			}
			return str;
		}
	}
}