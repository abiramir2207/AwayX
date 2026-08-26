package com.Billback.Edit.views.pm
{
	import com.Billback.Edit.events.BBEditEvent;
	import com.Billback.Edit.models.vos.BBProdRate;
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBComponent;
	import com.Billback.Main.models.vos.BBPrgDistItemRate;
	import com.Billback.Main.models.vos.BBProgram;
	import com.Billback.Main.models.vos.Billback;
	import com.shared.components.StringUtils;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.events.MainEvent;
	import com.shared.models.GridManager;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Component;
	import com.shared.vos.Item;
	import com.shared.vos.ProdRate;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	import com.shared.vos.Uom;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.TextInput;
	import mx.controls.listClasses.AdvancedListBase;
	import mx.events.AdvancedDataGridEvent;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.DataGridEventReason;
	import mx.events.ListEvent;
	import mx.messaging.channels.StreamingAMFChannel;
	import mx.utils.ObjectUtil;
	
	import spark.components.TextInput;
	
	import flashx.textLayout.formats.Float;
	
	public class BBEditItemsPModel extends EventDispatcher
	{
		/*............................................................*/
		/*.......................  Constructor  .......................*/
		/*............................................................*/
		
		private var _dispatcher:IEventDispatcher;
		public function BBEditItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*............................................................*/
		/*.......................  Properties  .......................*/
		/*............................................................*/
		[Bindable] public var objBBToolsLock:BBToolsLock = new BBToolsLock();
		
		/*.................iDgRowCount :: Grid Rows......................*/
		private var _iDgRowCount:int = 10;
		[Bindable (event="iDgRowCountChanged")]
		public function get iDgRowCount():int
		{
			return _iDgRowCount;
		}
		public function set iDgRowCount(iCount:int):void
		{
			this._iDgRowCount = iCount;
			dispatchEvent(new Event('iDgRowCountChanged'));
		}
		
		/*.................Grid Data......................*/
		private var _acGridDataFlat:ArrayCollection = new ArrayCollection();
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
		
		
		/*................  iVerticalScrollPosition ............... */
		private var _iVerticalScrollPosition:int = 10;
		[Bindable (event="iVerticalScrollPositionChg")] 
		public function get iVerticalScrollPosition():int{
			return _iVerticalScrollPosition;
		}
		public function set iVerticalScrollPosition(i:int):void{
			_iVerticalScrollPosition = i;
			dispatchEvent(new Event('iVerticalScrollPositionChg'));
		}
		
		/*.................oSettings......................*/
		[Bindable]	public var oSettings:Settings = new Settings();
		
		private var _billback:Billback = new Billback();
		// [Bindable]	public var billback:Billback = new Billback();
		
		[Bindable]	public var arrBBEditItemsDgCols:Array = new Array();
		[Bindable]	public var selectedProgram:Program = new Program();
		[Bindable]	public var selectedDistributor:Customer = new Customer();
		[Bindable]	public var bbPrgDistItemRate:BBPrgDistItemRate = new BBPrgDistItemRate();
		[Bindable]	public var acProducts:ArrayCollection = new ArrayCollection();
		[Bindable]	public var acComponent:ArrayCollection= new ArrayCollection();
		[Bindable]	public var acProgram:ArrayCollection= new ArrayCollection();
		[Bindable]	public var uomDp:Array = new Array();
		//[Bindable] 	public var bbCompExists:Boolean;
		[Bindable]	public var acProgramProduct:ArrayCollection= new ArrayCollection();
		
		/*.................Billback......................*/
		[Bindable (event="BillbackChanged")]
		public function get billback():Billback
		{
			return _billback;
		}
		public function set billback(billback:Billback):void
		{
			this._billback = billback;
			this.acGridDataFlat = new ArrayCollection(billback.bbPrgDistItemRate);
			dispatchEvent(new Event('BillbackChanged'));
			dispatchEvent(new Event('btnContinueLabelChanged'));
			dispatchEvent(new Event('btnContinueVisibleChanged'));
		}

		/*.................btnContinueLabel......................*/
		private var _btnContinueLabel:String = '';
		[Bindable (event="btnContinueLabelChanged")]
		public function get btnContinueLabel():String
		{
			var s:String;
			if(this.billback.bbHeader.status.id == 1){
				s= 'submit rfa';
			}
			else if(this.oSettings.user.stProfileSettings.BB_VIEW_DEVIATION == 1){
				s = 'deviation';
			}
			return s;
		}
		
		/*.................btnContinueVisible......................*/
		private var _btnContinueVisible:Boolean = false;
		[Bindable (event="btnContinueVisibleChanged")]
		public function get btnContinueVisible():Boolean
		{
			var b:Boolean = false;
			if(this.billback.bbHeader.billbackIDInt > 0
				&& 
				(this.billback.bbHeader.status.id == 1 || this.oSettings.user.stProfileSettings.BB_VIEW_DEVIATION == 1)){
				b = true;
			}
			return b;
		}
		
		private var bRemoveRecords:Boolean = false;
		/*............................................................*/
		/*........................  Methods  .........................*/
		/*............................................................*/
		
		// save billback
		public function saveBillback():void{
			
			var tempDollars:Number 	= 0; 
			var tempCases:Number 	= 0; 
			var tempPounds:Number 	= 0;
			var tempProdRate:Array = new Array();
			
			// loop over lumpsums and add the values to itemized and claimed
			for each(var bbComp:BBComponent in this.billback.bbComponent){
				if (bbComp.componentTypeId == 3 && !isNaN(parseFloat(bbComp.componentAmount))){
					tempDollars = tempDollars + parseFloat(bbComp.componentAmount);
				}
			}
			
			// loop over the items in the grid if there are any and set the values for the itemized and claimed.
			if(this.billback.bbPrgDistItemRate && this.billback.bbPrgDistItemRate.length){
				// loop over grid to calculate the amounts and remove items without volume
				for each(var bbPDIR:BBPrgDistItemRate in this.billback.bbPrgDistItemRate){
					if(bbPDIR.bbProdRate.itemNumber && bbPDIR.bbProdRate.volume){
						tempProdRate.push(bbPDIR);
						tempDollars = tempDollars 	+ (isNaN(bbPDIR.bbProdRate.amount)? 0 : bbPDIR.bbProdRate.amount); 
						tempCases	= tempCases 	+ (isNaN(bbPDIR.bbProdRate.volume)? 0 : bbPDIR.bbProdRate.volume);
						tempPounds	= tempPounds 	+ ((isNaN(bbPDIR.bbProdRate.volume)? 0 : bbPDIR.bbProdRate.volume) * bbPDIR.bbProdRate.netWeight);
					}
				}
			}
			
			// update the claimed values;
			/* 29119  Dont update - claimed $, Cs and Lb fields */
			this.billback.bbPrgDistItemRate = tempProdRate;
			this.billback.expectedAmount 	= tempDollars;
			this.billback.expectedCS 		= tempCases;
			this.billback.expectedLB		= tempPounds;
			
			this.billback.variedAmount 		= this.billback.claimedAmount - this.billback.expectedAmount;
			this.billback.variedCS	 		= this.billback.claimedCS - this.billback.expectedCS;
			this.billback.variedLB			= this.billback.claimedLB - this.billback.expectedLB;
			
			// dispatch event to validate & save is handled in validate
			var e:BBEditEvent= new BBEditEvent(BBEditEvent.VALIDATE_BB_EDIT_HDR);
			this._dispatcher.dispatchEvent(e);
		}
		
		// validate Billback		
		public function validateBillback():void{			
			
			var bInvalidRows:Boolean;		 
			var bItemVolNotRate:Boolean;	// true when item number and volume exists but no rate - alert user;
			var bItemNotVol:Boolean;		// true when item number exists but no volume - warn user;
			var strMsg1:String = 'There are rows with volume and no rate.\nPlease update!';
			var strMsg2:String = 'Rows without volume will be removed. Do you want to continue?'; 
			
			var bInvalidDistributor:Boolean;		// ShipTo is required for BB when operator is payee;  D30568 - Kal: 02/22/2012;
			var bBBPayeeOperatorDistReq:Boolean;	// ShipTo is required for BB when operator is payee;  D30568 - Kal: 02/22/2012;
			var strMsg3:String = 'This ' +  this.oSettings.appFlex.bbLabels.Billback + ' pays to an ' + oSettings.appSettings.Operator_Label_Singular+'. ' 
				+ 'When the ' +  this.oSettings.appFlex.bbLabels.Billback + ' pays to an ' + oSettings.appSettings.Operator_Label_Singular + ','
				+ ' it requires a ' + oSettings.appSettings.Distributor_Label_Singular + ' to be associated to it.';
			
			var strMsg4:String = 'Please select a component for this Billback.';
			var strMsg5:String = '';
			var strMsg6:String = this.oSettings.appFlex.bbLabels.Billback + ' dates are outside of Program dates!';
			var bNoComponents:Boolean;
			var bItemCompMisMatch:Boolean = false;
			var bItemCompMatchLooper:Boolean = false;
			var lastPrgNumber:String = '';
			var bStartDateWithinLimit:Boolean = false;
			var bEndDateWithinLimit:Boolean	= false;
			var selprgStaDate:Date;
			var selprgEndDate:Date;
 			
			if (this.selectedProgram)
			{
				selprgStaDate = new Date(this.selectedProgram.startDate);
				selprgEndDate = new Date(this.selectedProgram.endDate);
			}
			
			if(oSettings.appSettings.BB_PAYEE_OPERATOR_SHIP_TO_REQ && billback.bbHeader.payee.payeeTypeId == 2){
				bBBPayeeOperatorDistReq = true;
			}
			
			for each(var bbPDIR:BBPrgDistItemRate in this.billback.bbPrgDistItemRate){
				// alert for rows with volume and no rate - [prompt to use program rates] 
				if(bbPDIR.bbProdRate.itemNumber && bbPDIR.bbProdRate.volume && isNaN(bbPDIR.bbProdRate.rate)){
					bInvalidRows 	= true;	
					bItemVolNotRate	= true;
				}
				// alert for rows without volume will be removed;
				if(bbPDIR.bbProdRate.itemNumber && isNaN(bbPDIR.bbProdRate.volume)){
					bInvalidRows 	= true;	
					bItemNotVol 	= true;	
				}
				
				/* Dev Note: Milan (30793) When the payee is an operator on a billback and Ship To is required for billback with operator as payee" 
				app setting is OFF, the user does not have to select a distributor from the BB Edit page. In this case, "bbDistributor" is empty.
				*/
				if(bbPDIR.bbDistributor)
				{
					if (bBBPayeeOperatorDistReq && !(bbPDIR.bbDistributor.shipTo.length)){
						bInvalidRows 		= true;	
						bInvalidDistributor =  true;
					}
				}
			}
			
			if (this.billback.bbComponent.length == 0)
			{
				// no comps on billback, when there are items or amounts 
				// append invalid alert msg [no comp found for the Billback]
				// when there are no items or amounts on BB, dont check comps, so thay can save a new BB with just payee info 
				
				if (this.billback.bbPrgDistItemRate.length){ 
					bInvalidRows = true;
					bNoComponents = true;
				}
				// if No components then do not check for the Date Span
				bStartDateWithinLimit = true;
				bEndDateWithinLimit = true;
			}
			else
			{
				for(var i:int = 0; i < this.billback.bbComponent.length; i++){	
					if(this.acProgram.length)
					{
						for each (var acProgram:BBProgram in this.acProgram){					
							if(this.billback.bbComponent[i].programNumber == acProgram.number)
							{
								/* 
								Billback Date Range Checker:: To check, if the BB Dates fall within the Min Program Start Date
								and Maximum Program End Date
								*/
								if (!bStartDateWithinLimit)
								{	
									if (this.billback.bbHeader.startDate >= acProgram.effectiveStartDate)
									{
										bStartDateWithinLimit = true;
									}
								}
								if(!bEndDateWithinLimit)
								{
									if (this.billback.bbHeader.endDate <= acProgram.effectiveEndDate)
									{
										bEndDateWithinLimit = true;
									}
								}
							} // END: if(this.billback.bbComponent[i].programId == acProgram.programId) 
						} // END:for each (var acProgram:BBProgram in this.acProgram){ 
						/*
						Tim Ford - 04/24/2014L Label 42180 BB-3280307, why do we get the inv date msg?
						Added code to check the selected program dates with the Billback program dates to 
						handle for programs that dont have the same payee as the Billback.
						Basically the same code as label 38871 but when acProgram is populated
						*/
						if (!bStartDateWithinLimit)
						{	
							if (this.billback.bbHeader.startDate as Date >= selprgStaDate) // (this.selectedProgram.startDate as Date))
							{
								bStartDateWithinLimit = true;
							}
						}
						if(!bEndDateWithinLimit)
						{
							if (selprgEndDate >= this.billback.bbHeader.endDate)
							{
								bEndDateWithinLimit = true;
							} 	 
						}
					}
					else
					{
						/*
							38871 Flex BB - bb dates outside of program dates incorrectly showing/Anand Rao
							Added the handle when the program is not set in the acProgram strucutue, as the distributor is different 
						*/
						if (!bStartDateWithinLimit)
						{	
							if (this.billback.bbHeader.startDate as Date >= selprgStaDate) // (this.selectedProgram.startDate as Date))
							{
								bStartDateWithinLimit = true;
							}
						}
						if(!bEndDateWithinLimit)
						{
							if (selprgEndDate >= this.billback.bbHeader.endDate)
							{
								bEndDateWithinLimit = true;
							} 	 
						}	
					}
				} // END for(var i:int = 0; i < this.billback.bbComponent.length; i++){	
				
				if (this.billback.bbPrgDistItemRate.length)
						{
							for (var n:int = 0; n < this.billback.bbPrgDistItemRate.length; n++){
								bItemCompMatchLooper = false;
								for(var i:int = 0; i < this.billback.bbComponent.length; i++){
									if (this.billback.bbComponent[i].programNumber == this.billback.bbPrgDistItemRate[n].bbProgram.number)
									{
										bItemCompMatchLooper = true;
										break;
									}
								}
								
								if (!bItemCompMatchLooper)
								{
									bInvalidRows = true; 
									bItemCompMisMatch = true;
									if (lastPrgNumber != this.billback.bbPrgDistItemRate[n].bbProgram.number)
									{
										strMsg5 =  strMsg5 + this.billback.bbPrgDistItemRate[n].bbProgram.number + '\n';
									}
									lastPrgNumber = this.billback.bbPrgDistItemRate[n].bbProgram.number;
								}  // END: if (!bItemCompMatchLooper)
							} // END: for (var n:int = 0; n < this.billback.bbPrgDistItemRate.length; n++)
						}
				strMsg5 = 'The items from below programs do not have a component selected:\n' + strMsg5;
			}
			
			/* 
				D34488: "Inv Dates are outside of Prog dates" save error / If the date are out of program dates,
				then do a soft alert and no hard stop. 
			*/
			if (bStartDateWithinLimit == false || bEndDateWithinLimit == false){
				Alert.show(strMsg6, 'Alert');
			}
			
			// if no error rows then save;
			if (!bInvalidRows){
				this.saveBillback();
			}
			else if (bInvalidRows && bItemVolNotRate){
				Alert.show(strMsg1, 'Alert');
			}
			else if (bInvalidRows && !bItemVolNotRate && bItemNotVol){
				Alert.show(strMsg2, 'Confirm',  Alert.OK | Alert.CANCEL, null, recordsRemovedListener, null, Alert.OK);
			}
			else if (bInvalidRows && bInvalidDistributor){
				Alert.show(strMsg3, 'Alert');
			}
			else if (bInvalidRows && bNoComponents){
				Alert.show(strMsg4, 'Alert');
			}
			else if (bInvalidRows && bItemCompMisMatch){
				Alert.show(strMsg5, 'Alert');
			}
			
		}
		
		// confirm handler
		public function recordsRemovedListener(mesgEventObj:CloseEvent):void {
			if (mesgEventObj.detail==Alert.OK){ this.saveBillback();}
		}
		
		// get program rates for products without rates
		public function getProgramRates():void {
			var event:BBEditEvent = new BBEditEvent(BBEditEvent.GET_PROGRAM_RATES);
			event.billback = this.billback;
			this._dispatcher.dispatchEvent(event);
		}
		
		//btnContinue click handler
		public function loadDeviations():void{
			
			//TODO: If bb is aproved (or can't be edited, don't save.  Just Load deviations
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
					this._dispatcher.dispatchEvent(evt);
					/*					
					var event:BBMainEvent = new BBMainEvent(BBMainEvent.LOAD_DEVIATIONS);
					event.bbHeader  = this.billback.bbHeader;
					this._dispatcher.dispatchEvent(event);
					*/
				}
			}
		}
		
		// Change handler for the selecteditem 
		public function dgBBEditItemChangeHandler(event:ListEvent):void
		{
			//this.bbPrgDistItemRate = event.currentTarget.selectedItem as BBPrgDistItemRate;
			var evt:MainEvent = new MainEvent(MainEvent.SELECT_ROW);
			evt.objRowData = event.currentTarget.selectedItem;
			this._dispatcher.dispatchEvent(evt);
			
		}
		
		
		// add products from program; 
		public function addProgramItems():void
		{
			var oComp:Component;
			var oItem:Object;
			var bbPDIR:BBPrgDistItemRate;
			var exists:Boolean = false;
			
			// search program items and add
			for each (oComp in this.acComponent){
				if (oComp.isSelected){
					for each (oItem in oComp.prodRate){
						exists = false;
						for each (bbPDIR in this.billback.bbPrgDistItemRate){
							if((bbPDIR.bbProgram.number == this.selectedProgram.number) && (oItem.itemNumber == bbPDIR.bbProdRate.itemNumber)
								&& (bbPDIR.bbDistributor.shipTo == this.selectedDistributor.shipTo) ){
								exists = true;
								break;
							}
						}
						if(!exists){
							var bbPrgItem:BBPrgDistItemRate	= new BBPrgDistItemRate();
							bbPrgItem.bbProgram				= new BBProgram();	
							bbPrgItem.bbDistributor 		= new Customer();
							bbPrgItem.bbProdRate			= new BBProdRate;
							bbPrgItem.uomDp 				= this.uomDp;
							
							//uom
							var uUOM:Uom					= new Uom;
							uUOM.uomId						= 1;
							uUOM.abbreviation				= 'CS';
							uUOM.description				= 'Cases';
							bbPrgItem.bbProdRate.uom 		= uUOM;
							
							// program
							bbPrgItem.bbProgram.programId	= this.selectedProgram.programId;
							bbPrgItem.bbProgram.number		= this.selectedProgram.number;
							bbPrgItem.bbProgram.title		= this.selectedProgram.title;
							bbPrgItem.bbProgram.startDate	= new Date(this.selectedProgram.startDate);
							bbPrgItem.bbProgram.endDate		= new Date(this.selectedProgram.endDate);
							
							// distributor
							bbPrgItem.bbDistributor 		= this.selectedDistributor;
							
							// item
							bbPrgItem.bbProdRate.itemNumber 	= oItem.itemNumber;
							bbPrgItem.bbProdRate.itemGuid 		= oItem.itemGuid;
							bbPrgItem.bbProdRate.description 	= oItem.description;
							bbPrgItem.bbProdRate.netWeight 		= parseFloat(oItem.netWeight);
							bbPrgItem.bbProdRate.discountType	= oComp.type;
							bbPrgItem.bbProdRate.volume			= 1;
							
							// add to billback
							this.billback.bbPrgDistItemRate.push(bbPrgItem);
							this.acGridDataFlat = new ArrayCollection(billback.bbPrgDistItemRate);
							dispatchEvent(new Event('BillbackChanged'));
						}
					}
				}
			}
		}
		
		/*........................  click/event handlers for editing in datagrid  .........................*/
		public function itemEditEnd(event:AdvancedDataGridEvent):void
		{				
			var bRefresh:Boolean = false;
			// check to see if the Datafield edited is "ItemNumber" and if there are no rate/amount/Volume then it is a new row, and bFirstTime is set to true.
			if(!(event.dataField == 'isSelected' || event.dataField == 'bbProdRate.uom'))
			{				
				var ti:mx.controls.TextInput = mx.controls.TextInput(event.currentTarget.itemEditorInstance);
				var s:String = ti.text;
				var sPrg:String = event.currentTarget.itemEditorInstance.data.bbProgram.number;
				
				// NOTE: This is the only way I can reference item renderer object without typecasting it. 
				var _bbPrgDistItemRate:BBPrgDistItemRate = event.itemRenderer.data as BBPrgDistItemRate;
				
				var bError:Boolean = false;
				var sColName:String = event.currentTarget.columns[event.columnIndex].headerText;
				var sError:String = 'please enter a valid ' + sColName;
				
				//if the rate begins with a decimal then add a 0 before the decimal to avoid the rate as NaN
				if (event.dataField == 'bbProdRate.rate' && s.length && s.charAt(0) == '.')
				{
					s = '0' + s;
				}
				
				if ((!isNaN(_bbPrgDistItemRate.bbProdRate.rate)) && (!isNaN(_bbPrgDistItemRate.bbProdRate.amount)) && (!isNaN(_bbPrgDistItemRate.bbProdRate.volume)))
				{
					_bbPrgDistItemRate.bFirstTime = false;	
				}
				
				if (event.dataField == 'bbProdRate.itemNumber' && isNaN(_bbPrgDistItemRate.bbProdRate.rate) && isNaN(_bbPrgDistItemRate.bbProdRate.amount) && isNaN(_bbPrgDistItemRate.bbProdRate.volume))
				{
					_bbPrgDistItemRate.bFirstTime = true;	
				}
				/*else if
				(event.dataField == 'bbProdRate.volume' && (_bbPrgDistItemRate.bbProdRate.rate) && isNaN(_bbPrgDistItemRate.bbProdRate.amount) && isNaN(_bbPrgDistItemRate.bbProdRate.volume))
				*/
				
				// switch event.dataField and run validations
				switch(event.dataField)
				{
					case 'bbProdRate.volume':
						s =  s.split(',').join(''); // s.replace('\,','');
						if(s.length == 0 || isNaN(parseFloat(s))){
							bError = true;		//error
						}
						else{
							// if First time then works as before 
							if (_bbPrgDistItemRate.bFirstTime)
							{
								_bbPrgDistItemRate.bbProdRate.volume = parseFloat(s);
								if (!(isNaN(_bbPrgDistItemRate.bbProdRate.amount))){
									_bbPrgDistItemRate.bbProdRate.rate = ((_bbPrgDistItemRate.bbProdRate.amount) / (_bbPrgDistItemRate.bbProdRate.volume));
									bRefresh = true;
								}
								if (!(isNaN(_bbPrgDistItemRate.bbProdRate.rate))){
									_bbPrgDistItemRate.bbProdRate.amount = ((_bbPrgDistItemRate.bbProdRate.rate) * (_bbPrgDistItemRate.bbProdRate.volume));
									bRefresh = true;
								}
							}
							else
							{
								// if NOT First time update only Amt no change to Rate.
								_bbPrgDistItemRate.bbProdRate.volume = parseFloat(s);
								if (!(isNaN(_bbPrgDistItemRate.bbProdRate.rate))){
									_bbPrgDistItemRate.bbProdRate.amount = ((_bbPrgDistItemRate.bbProdRate.rate) * (_bbPrgDistItemRate.bbProdRate.volume));
									bRefresh = true;
								}
							}
							
						}
						break;
					case 'bbProdRate.rate':
						s = s.split(',').join(''); // s.replace('\,','');
						if(s.length == 0 || isNaN(parseFloat(s))){
							bError = true;		//error
						}
						else{
							var nAmnt:Number;
							_bbPrgDistItemRate.bbProdRate.rate = parseFloat(s);
							nAmnt = ((_bbPrgDistItemRate.bbProdRate.rate) * (_bbPrgDistItemRate.bbProdRate.volume));
							_bbPrgDistItemRate.bbProdRate.amount = parseFloat(nAmnt.toFixed(2));
							bRefresh = true;
						}
						break;
					case 'bbProdRate.amount':
						s.replace('\$','');
						s = s.split(',').join(''); // s.replace('\,','');
						if(s.length == 0 || isNaN(parseFloat(s))){
							bError = true;		//error
						}
						else{
							/* 	Dev Note: Tim Ford - Label 32586 - Some partial cases are causing a rate change
							Had to add code below to handle for rate changes based on fractional decimals.
							*/
							var str1:String;
							var str2:String;
							var results:Array = _bbPrgDistItemRate.bbProdRate.amount.toString().split(".");
							if (results.length > 1){
								str1 = results[1];
								if(str1.length == 1){str1 = str1 + "0";}
							}else{
								str1 = "00";
							}
							
							str2 = results[0] + "." + str1.substr(0,2);
							
							_bbPrgDistItemRate.bbProdRate.amount = parseFloat(s);
							s = s.split(',').join('')
							str2 = str2.split(',').join('') 
							if(s != str2){
								if (!(isNaN(_bbPrgDistItemRate.bbProdRate.volume) || _bbPrgDistItemRate.bbProdRate.volume == 0)){
									_bbPrgDistItemRate.bbProdRate.rate = ((_bbPrgDistItemRate.bbProdRate.amount) / (_bbPrgDistItemRate.bbProdRate.volume));
								}
							}
							bRefresh = true;
						}
						break;
					case 'bbProdRate.itemNumber':
						if(s.length == 0){
							bError = true;		//error
						}
						else{
							var oComp:Component;
							var oItem:Object;
							var existsOnProgram:Boolean = false;
							var exists:Boolean = false;
							// 56531: No longer should default discount type to rebate since fixed is also allowed. Take a discount type from the program
							var defaultDiscountType:Number = 0; // Using defaultDiscountType from selected program, otherwise other program to set for products not on program  
							
							
							// search program items
							if (this.selectedProgram){
								for each (oComp in this.selectedProgram.components){
									// 56531: No longer should default discount type to rebate since fixed is also allowed. Take a discount type from the program
									if (oComp.isSelected && defaultDiscountType != oComp.type ){defaultDiscountType = oComp.type;}
									for each (oItem in oComp.prodRate){
										if(oItem.itemNumber == s){
											_bbPrgDistItemRate.bbProdRate.itemNumber 	= oItem.itemNumber;
											_bbPrgDistItemRate.bbProdRate.itemGuid 		= oItem.itemGuid;
											_bbPrgDistItemRate.bbProdRate.description 	= oItem.description;
											_bbPrgDistItemRate.bbProdRate.discountType	= oComp.type;
											_bbPrgDistItemRate.bbProdRate.netWeight 	= parseFloat(oItem.netWeight);
											_bbPrgDistItemRate.message					= '';
											existsOnProgram 							= true;
											exists 										= true;
											break;
										}
									}
								}
							}
							else{
								for each (oComp in this.acComponent){
									// 56531: No longer should default discount type to rebate since fixed is also allowed. Take a discount type from the program
									if (oComp.isSelected && defaultDiscountType == 0 ){defaultDiscountType = oComp.type;}
									for each (oItem in oComp.prodRate){
										if(oItem.itemNumber == s){
											_bbPrgDistItemRate.bbProdRate.itemNumber 	= oItem.itemNumber;
											_bbPrgDistItemRate.bbProdRate.itemGuid 		= oItem.itemGuid;
											_bbPrgDistItemRate.bbProdRate.description 	= oItem.description;
											_bbPrgDistItemRate.bbProdRate.discountType	= oComp.type;
											_bbPrgDistItemRate.bbProdRate.netWeight 	= parseFloat(oItem.netWeight);
											_bbPrgDistItemRate.message					= '';
											existsOnProgram 							= true;
											exists 										= true;
											break;
										}
									}
									//}
								}
							}
							
							// search program items not selected yet
							if(!existsOnProgram){
								
								for each (var oPrgProd:Object in this.acProgramProduct){									
								
									if(oPrgProd.itemNumber == s && oPrgProd.number == sPrg){
										
										_bbPrgDistItemRate.bbProdRate.itemNumber 	= oPrgProd.itemNumber;
										_bbPrgDistItemRate.bbProdRate.itemGuid 		= oPrgProd.itemGuid;
										_bbPrgDistItemRate.bbProdRate.description 	= oPrgProd.description;
										_bbPrgDistItemRate.bbProdRate.discountType	= defaultDiscountType;
										_bbPrgDistItemRate.bbProdRate.netWeight 	= parseFloat(oPrgProd.netWeight);
										_bbPrgDistItemRate.message					= '';
										existsOnProgram 							= true;
										exists 										= true;
										break;
									}
								}
							}
							
							// search item master
							if(!existsOnProgram){
								for each (oItem in acProducts){
									if(oItem.itemNumber == s){
										_bbPrgDistItemRate.bbProdRate.itemNumber 	= oItem.itemNumber;
										_bbPrgDistItemRate.bbProdRate.itemGuid 		= oItem.itemGuid;
										_bbPrgDistItemRate.bbProdRate.description 	= oItem.description;										
										_bbPrgDistItemRate.bbProdRate.discountType	= defaultDiscountType;
										_bbPrgDistItemRate.bbProdRate.netWeight 	= parseFloat(oItem.netWeight);
										_bbPrgDistItemRate.message					= '';
										exists 										= true;
										break;
									}
								}
							}
							
							// Alert the error messages
							/* For some reason, this function is called twice everytime. The first time it gets called, it has "DataGridEventReason.NEW_COLUMN",
							but not so when called the second time. Getting called the second time is an issue because now we are using  "dispatchEvent(new Event('GridDataChanged'))"
							to refresh the data grid at the end of this function. When we were using "this.acGridDataFlat.refresh()", then it would have worked fine, but using 
							"this.acGridDataFlat.refresh()" causes the cursor to jump.
							*/
							if (!exists){ // && event.reason == DataGridEventReason.NEW_COLUMN
								_bbPrgDistItemRate.message = 'Invalid Item'; 
								bError = true;
							}
							/* See note above for removing "DataGridEventReason.NEW_COLUMN". */
							else if(exists && !existsOnProgram){// && event.reason == DataGridEventReason.NEW_COLUMN
								_bbPrgDistItemRate.message = 'Product not on Program';
								bError = true;
							}
							bRefresh = true;
						}
						break;
					default:
						break;
				}
				//update the ui
				if(bError){
					ti.setStyle("color", '0xDD0000');
					ti.setStyle('font-style','italic');
					ti.toolTip = sError;
				}				
				else{
					ti.setStyle('color','black');
					ti.setStyle('font-style','');
					ti.toolTip = '';
				}
				if(	event.columnIndex == 9 && 
					event.rowIndex == event.currentTarget.dataProvider.length-1)
				{
					var evt:MainEvent = new MainEvent(MainEvent.INSERT_ROW);
					this._dispatcher.dispatchEvent(evt);
				}
				
				//this.acGridDataFlat.itemUpdated(_bbPrgDistItemRate);
				
				var dg:FilterAdvancedDatagrid = event.currentTarget as FilterAdvancedDatagrid;
				var ac:ArrayCollection = dg.dataProvider as ArrayCollection;
				var colEvent:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,true,false, CollectionEventKind.UPDATE);
				colEvent.items = [_bbPrgDistItemRate];
				colEvent.location =  dg.selectedIndex;
				ac.dispatchEvent(colEvent);
			}
			//Tim Ford - 09/17/2012: Label 34077 - Line Item check Boxes moving
			//removed refresh on the dataProvider since dataProviders are now automatically refreshed.
			//Tim Ford - 10/08/2012: Label 34463 - Product Desc not flowing in until vol/rate entered
			//added refresh on the dataProvider only when the item number is being updated
			/*
			if (event.dataField == 'bbProdRate.itemNumber'){
				this.acGridDataFlat.refresh();	
			}
			*/	
			if (bRefresh){
				//this.acGridDataFlat.refresh();
				/* Adding "refresh" above causes the cursor to jump. Instead, call event to fire data binding below. */
				//dispatchEvent(new Event('GridDataChanged'));
			}	
			
		}
		
		// search product
		public function getProductSearch():void{
			var e:BBEditEvent = new BBEditEvent(BBEditEvent.GET_PRODUCT_SEARCH);
			this._dispatcher.dispatchEvent(e);
		}
		
		/* 	Call this function to get the latest program version 
		TODO: Refactor this function to remove nested loops and make it cleaner and easier to read
		*/
		public function getLatestProgramVersion():void{
			
			var bLatestVersionUpdate:Boolean = false;
			
			//throw an alert if the user didn't select a program from the drop down
			//Removed per label 32246 - Inquiry about how to manage a program change - REWORK
			/*
			if (this.selectedProgram == null){
			Alert.show('Please select from Program # drop down');
			return;
			}
			*/
			//loop over each billback component
			for each(var acComp:Component in this.acComponent){
				
				//only grab latest version for selected components
				if (acComp.isSelected){
					
					//call addProgramItems() to populate all products for this program component
					//this.addProgramItems(); Removed per label 32246 - Inquiry about how to manage a program change - REWORK
					
					//loop over each billback component
					for(var i:int = 0; i < this.billback.bbComponent.length; i++){
						
						//if the program for each compoent isn't the latest version then get the latest version of the program
						if (this.billback.bbComponent[i].bIsLatestVersion == false && this.billback.bbComponent[i].programNumber == acComp.programNumber){
							
							var iProgramId:Number;
							var strProgramNumber:String;
							
							strProgramNumber = acComp.programNumber;
							iProgramId = getLatestProgramNumber(strProgramNumber);
							
							//flag indicator saying that a programs latest version has been applied
							if (bLatestVersionUpdate == false){
								bLatestVersionUpdate = true;
							}
							
							this.billback.bbComponent[i].programID = iProgramId;
							this.billback.bbComponent[i].bIsLatestVersion = true;
							
							//now loop over the billback prod rates in the billback and update with the latest
							for (var n:int = 0; n < this.billback.bbPrgDistItemRate.length; n++){
								
								//if the program numbers match then update program properties with latest
								if (this.billback.bbPrgDistItemRate[n].bbProgram.number == acComp.programNumber){
									
									//set program id and is latest version
									this.billback.bbPrgDistItemRate[n].bbProgram.programId = iProgramId;
									this.billback.bbPrgDistItemRate[n].bbProgram.bIsLatestVersion = true;
									
									//now loop over each prod rate in this component
									//Removed per label 32246 - Inquiry about how to manage a program change - REWORK
									/*
									for(var indx:int = 0; indx < acComp.prodRate.length; indx++){
									
									//if the program numbers match then update program product rate properties with latest
									if(acComp.prodRate[indx].itemNumber == this.billback.bbPrgDistItemRate[n].bbProdRate.itemNumber){
									this.billback.bbPrgDistItemRate[n].bbProdRate.rate = acComp.prodRate[indx].rate;
									this.billback.bbPrgDistItemRate[n].bbProdRate.amount = acComp.prodRate[indx].rate * this.billback.bbPrgDistItemRate[n].bbProdRate.volume;
									}
									}
									*/
								}
							}
						}
					}
				}
			}
			
			//if (bLatestVersionUpdate == true){
			this.validateBillback();
			//}
		}
		
		public function getLatestProgramNumber(programNumber:String):Number{
			
			var i:Number = 0;
			
			for each (var acProgram:BBProgram in this.acProgram){
				
				if (acProgram.number == programNumber){
					i = acProgram.programId;
					break;
				}
				
			}
			return i;
		}
	}
}