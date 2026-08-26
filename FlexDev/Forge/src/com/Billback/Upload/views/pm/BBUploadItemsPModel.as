package com.Billback.Upload.views.pm
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Upload.events.BBUploadEvent;
	import com.Billback.Upload.models.vos.BBUploadDetail;
	import com.Billback.Upload.models.vos.BBUploadDetailError;
	import com.Billback.Upload.models.vos.BBUploadHeader;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumnMultiSelect;
	import com.shared.components.filters.FilterDatagrid;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.DataGridEvent;
	import mx.utils.ObjectUtil;
	
	public class BBUploadItemsPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBUploadItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var acItemData:ArrayCollection = new ArrayCollection();
		//[Bindable]
		//public var bbUploadHeader:BBUploadHeader = new BBUploadHeader();
		[Bindable]
		public var arrBBUploadItemsDgCols:Array = new Array();
		[Bindable]
		public var sPayeeError:String;
		/*.................bbUploadHeader......................*/
		private var _bbUploadHeader:BBUploadHeader = new BBUploadHeader();
		[Bindable (event="iPMbbUploadHeaderChanged")]
		public function get bbUploadHeader():BBUploadHeader
		{
			return _bbUploadHeader;
		}
		public function set bbUploadHeader(bbh:BBUploadHeader):void
		{
			//For Save (without validation) we do not return detail rows from server
			//if that is the case, do not reload the arrDetailError.  Performance gain for large e-corrections
			var bSetArrError:Boolean = (this.bbUploadHeader.bbUploadDetail != bbh.bbUploadDetail);
			this._bbUploadHeader = bbh;
			if(bbh.bbUploadDetail.length && bSetArrError){
				this.selectRow(this.bbUploadHeader.bbUploadDetail[0]);
				//build the array of all detail level errors.  This is expensive
				this.setArrDetailErrorAll();
			}
			dispatchEvent(new Event('iPMbbUploadHeaderChanged'));
			//verify we can edit the header
			//this.isEditable()
		}
		
		/*.................bbUploadDetail......................*/
		private var _bbUploadDetail:BBUploadDetail = new BBUploadDetail();
		[Bindable (event="bbUploadDetailChanged")]
		public function get bbUploadDetail():BBUploadDetail
		{
			return _bbUploadDetail;
		}
		public function set bbUploadDetail(bbUploadDetail:BBUploadDetail):void
		{
			this._bbUploadDetail = bbUploadDetail;
			dispatchEvent(new Event('bbUploadDetailChanged'));
			this.setArrDetailError();
		}
		
		/*.................bEdit......................*/
		/*private var _bEdit:Boolean = false;
		[Bindable (event="bEditChanged")]
		public function get bEdit():Boolean
		{
			return _bEdit;
		}
		public function set bEdit(b:Boolean):void
		{
			this._bEdit = b;
			dispatchEvent(new Event('bEditChanged'));
		}*/
		
		
		/*...................   arrHeaderError  .....................*/
		/*private var _arrHeaderError:Array = new Array();
		[Bindable (event="arrHeaderErrorChanged")]
		public function get arrHeaderError():Array
		{
			return _arrHeaderError;
		}
		public function set arrHeaderError(inValue:Array):void
		{
			_arrHeaderError = inValue;
			dispatchEvent(new Event('arrHeaderErrorChanged'));
		}*/
		
		/*...................   arrDetailError  .....................*/
		private var _arrDetailError:Array = new Array();
		[Bindable (event="arrDetailErrorChanged")]
		public function get arrDetailError():Array
		{
			return _arrDetailError;
		}
		public function set arrDetailError(inValue:Array):void
		{
			_arrDetailError = inValue;
			dispatchEvent(new Event('arrDetailErrorChanged'));
		}
		
		/*...................   arrDetailErrorAll  .....................*/
		private var _arrDetailErrorAll:Array = new Array();
		[Bindable (event="arrDetailErrorAllChanged")]
		public function get arrDetailErrorAll():Array
		{
			return _arrDetailErrorAll;
		}
		public function set arrDetailErrorAll(inValue:Array):void
		{
			_arrDetailErrorAll = inValue;
			dispatchEvent(new Event('arrDetailErrorAllChanged'));
		}		
		
		
		[Bindable] public var filterInsert:Function =
			function():Boolean{
				return true;
			};
		
		//private function isEditable():void{
			//if(this.bbUploadHeader){
				// bEdit = this.bbUploadHeader.lockedUser && (this.bbUploadHeader.lockedUser.id  == this.oSettings.userId);
				/* TODO: Remove this after adding locking logic */ 
				//bEdit = true;	// BB Flex, Error Correction screen - validate button not enabling
			//}
		//}
		
		
		/*public function resetFilter(dg:FilterDatagrid):void{
			dg.resetFilters();
		}*/
		public function updateCols():void{
			//hello
		}
		/*public function displayHeaderOptions(dg:FilterDatagrid,bFilter:Boolean,bEdit:Boolean):void{
			//var ac:ArrayCollection = dg.dataProvider as ArrayCollection;
			//ac.disableAutoUpdate();
			dg.displayHeaderOptions(bFilter,bEdit);
		}*/
		
		public function selectRow(bbUploadDetail:BBUploadDetail):void{
			this.bbUploadDetail = bbUploadDetail;
		}
		
		public function setArrDetailError():void{
			var arr:Array = new Array();
			var errObj:BBUploadDetailError = this.bbUploadDetail.errObj; 
			var o:Object = ObjectUtil.getClassInfo(errObj);
			for each(var obj:Object in o.properties) {
				var prop:String = obj.localName;
				var s:String = errObj[prop];
				if(s.length){
					s = '[row id: ' + this.bbUploadDetail.rowID.toString() + '] ' + s; // bbDetailID
					arr.push(s);
				}
			}
			this.arrDetailError = arr;
			//DO We need this.  major performance hit.
			//this.setArrDetailErrorAll();
		}
		
		public function setArrDetailErrorAll():void{
			var arr:Array = new Array();
			for each(var bbudObj:BBUploadDetail in this.bbUploadHeader.bbUploadDetail)
			{	
				var errObj:BBUploadDetailError = bbudObj.errObj; 
				var o:Object = ObjectUtil.getClassInfo(errObj);
				for each(var obj:Object in o.properties) {
					var prop:String = obj.localName;
					var s:String = errObj[prop];
					if(s.length){
						// do not change this string as we calculate the focus on click based on this  
						s = '[row id: ' + bbudObj.rowID.toString() + '] ' + s; //bbDetailID
						arr.push(s);
					}
				}
			}
			this.arrDetailErrorAll = arr;
		}
		
		
		public function itemEditEnd(event:DataGridEvent):void{
			
			if(event.dataField!= 'isSelected'){
				
				var ti:TextInput = TextInput(event.currentTarget.itemEditorInstance);
				var s:String = ti.text;
				var bbUploadDetail:BBUploadDetail = event.itemRenderer.data as BBUploadDetail;
				var err:BBUploadDetailError = event.itemRenderer.data.errObj;// new BBUploadDetailError(event.itemRenderer.data.errObj as BBUploadDetailError);
				var bError:Boolean = false;
				var sColName:String = event.currentTarget.columns[event.columnIndex].headerText;
				var sError:String = 'please enter a valid ' + sColName;
				//ONLY run  the edit code if the user changed the value in the textbox.
				//itemEditEnd is fired if a user just clicks in an edit box and then out of it without changing anything
				if(bbUploadDetail[event.dataField] != s){
					//flag this puppy as edited so we can send it to server on save
					bbUploadDetail.bEdited = true;
					//switch event.dataField and run validations
					switch(event.dataField)
					{
						/*case 'BBProductQuantity':
							if(s.length == 0 || isNaN(parseInt(s)) || parseInt(s) < 0){
								//error
								bError = true;
								sError = 'please enter a valid number';
							}
							break;
						case 'caseRate':
							if(s.length == 0 || isNaN(Number(s))){
								//error
								bError = true;
								sError = 'please enter a valid number';
							}
							break;
						case 'BBRate':
							if(s.length == 0 || isNaN(Number(s))){
								//error
								bError = true;
								sError = 'please enter a valid number';
							}
							break;*/
						case 'contractNumber':
							if(s.length == 0){
								//error
								bError = true;
							}
							break
						case 'contractTitle':
							if(s.length == 0){
								//error
								bError = true;
							}
							break
						case 'operatorLegacyId':
							if(s.length == 0){
								//error
								bError = true;
							}
							break
						case 'item':
							if(s.length == 0){
								//error
								bError = true;
							}
							break;
						case 'dupShipTo':
							if(s.length == 0){
								//error
								bError = true;
							}
							break;
						default:
							//trace("Out of range");
							break;
					}
					//update the ui.  check gridLabel.as for other ui stuff.
					if(bError){
						//error
						//event.preventDefault();
						//reset text input (renderer) back to previous value
						//ti.text = event.currentTarget.dataProvider[event.rowIndex][event.dataField];
						/*....  only display the error if the property was previously in error.  for example there 
						   is an item field and an alias field.  only one needs to be valid, so an empty string
						   is ok int other field. ..............................................................*/
						if(err[event.dataField].toString().length > 0){
							err[event.dataField] = sError;
						}
						ti.setStyle('color','red');
						ti.setStyle('backgroundColor','yellow');
						ti.setStyle('font-style','italic');
						ti.toolTip = sError;
						//	highlightError(event.currentTarget.itemEditorInstance as TextInput);
					}
					else{
						//ok
						err[event.dataField] = '';
						ti.setStyle('color','black');
						ti.setStyle('font-style','');
						ti.setStyle('backgroundColor','white');
						ti.toolTip = '';
					}
					this.setArrDetailError();
				}
			}
		}

		private function clearError():void{
			
		}
		
		private function highlightError(rndr:TextInput):void{
			//setStyle("color", 0xFF0000);
		}
		
		/*public function validate():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.VALIDATE);
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			e.bbUploadHeader = this.bbUploadHeader;
			this._dispatcher.dispatchEvent(e)
		}
		public function closeBB():void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.CLOSE_BB_UPLOAD);
			e.bbUploadHeader = this.bbUploadHeader;
			this._dispatcher.dispatchEvent(e);
		}*/
		
		public function deleteBBUploadHeader():void{
			var e:BBUploadEvent = new BBUploadEvent(BBUploadEvent.DELETE_BB_UPLOAD);
			//e.bbId = this.bbHeader.billbackIDInt.toString();
			e.bbUploadHeader = this.bbUploadHeader;
			this._dispatcher.dispatchEvent(e);
		}
		
		public function displayErrors(chkDisplayAll:Boolean):void{
			var bDisplay:Boolean = false; 
			var bbh:BBUploadHeader = new BBUploadHeader(this.bbUploadHeader);
			if(chkDisplayAll)
			{
				bDisplay = true;
			}
			//don't send details in reload event
			bbh.bbUploadDetail = new Array();
			var e:BBUploadEvent= new BBUploadEvent(BBUploadEvent.LOAD_BB_EDIT);
			e.bbUploadHeader = this.bbUploadHeader;
			e.bDisplayAll = bDisplay;
			this._dispatcher.dispatchEvent(e);
		}
	}
}