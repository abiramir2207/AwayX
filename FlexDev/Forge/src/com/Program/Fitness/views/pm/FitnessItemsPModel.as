package com.Program.Fitness.views.pm
{
	import com.Billback.Main.models.vos.BBHeader;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	import com.Program.Fitness.models.vos.FitnessDetail;
	import com.Program.Fitness.models.vos.FitnessSearchDef;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.FilterParms;
	import com.shared.vos.Item;
	import com.shared.vos.ProdRate;
	import com.shared.vos.ProductAttr;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.CheckBox;
	
	public class FitnessItemsPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function FitnessItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var acItemData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var bbHeader:BBHeader = new BBHeader();
		[Bindable]
		public var arrFitnessItemsDgCols:Array = new Array();
		[Bindable]
		public var arrFitnessTotalsDgCols:Array = new Array();
		
		/*[Bindable]
		public var acFitnessItems:ArrayCollection = new ArrayCollection();*/
		
		/*[Bindable]
		public var acFitnessTotals:ArrayCollection = new ArrayCollection();*/
		
		/*.................acFitnessItems......................*/
		private var _acFitnessItems:ArrayCollection = new ArrayCollection();
		[Bindable (event="acFitnessItemsChangedPM")]
		public function get acFitnessItems():ArrayCollection
		{
			return _acFitnessItems;
		}
		public function set acFitnessItems(ac:ArrayCollection):void
		{			
			this._acFitnessItems = ac;
			this.getSumresult();
			dispatchEvent(new Event('acFitnessItemsChangedPM'));	
		}
		
		/*.................acFitnessTotals......................*/
		private var _acFitnessTotals:ArrayCollection = new ArrayCollection();
		[Bindable (event="acFitnessTotalsChangedPM")]
		public function get acFitnessTotals():ArrayCollection
		{
			return _acFitnessTotals;
		}
		public function set acFitnessTotals(ac:ArrayCollection):void
		{			
			this._acFitnessTotals = ac;
			dispatchEvent(new Event('acFitnessTotalsChangedPM'));	
		}
		
		/*.................fitnessSearchDef......................*/
		private var _fitnessSearchDef:FitnessSearchDef = new FitnessSearchDef();
		[Bindable (event="fitnessSearchDefChangedPM")]
		public function get fitnessSearchDef():FitnessSearchDef
		{
			return _fitnessSearchDef;
		}
		public function set fitnessSearchDef(fitnessSearchDef:FitnessSearchDef):void
		{			
			this._fitnessSearchDef = fitnessSearchDef;
			dispatchEvent(new Event('fitnessSearchDefChangedPM'));	
		}
		
		/*.................funcFilterInsert......................*/
		private var _funcFilterInsert:Function = function(inObject:Object):Boolean{return true;};
		[Bindable (event="funcFilterInsertChange")]
		public function get funcFilterInsert():Function
		{
			return _funcFilterInsert;
		}
		public function set funcFilterInsert(func:Function):void
		{
			this._funcFilterInsert = func;
			dispatchEvent(new Event('funcFilterInsertChange'));
		}
		
		/*  FilterParms From FilterPM*/
		private var _oFilterParms:FilterParms = new FilterParms();
		[Bindable (event="smFilterParmsChanged")]
		public function get oFilterParms():FilterParms
		{
			return _oFilterParms;
		}
		public function set oFilterParms(f:FilterParms):void
		{
			this._oFilterParms = f;
			dispatchEvent(new Event('smFilterParmsChanged'));
		}
		/*.................fileRef......................*/
		private var _fileRef:FileReference;
		[Bindable (event="pmFileRefChanged")]
		public function get fileRef():FileReference
		{
			return _fileRef;
		}
		public function set fileRef(fr:FileReference):void
		{
			this._fileRef = fr;
			dispatchEvent(new Event('pmFileRefChanged'));
		}
		/*..........................................................................................................*/
		/*..............................................  Properties  ..............................................*/
		/*..........................................................................................................*/
		[Bindable (event="getSumresultChangedPM")]
		public function getSumresult():ArrayCollection
		{
			_acFitnessTotals = new ArrayCollection();
			var fdNew:FitnessDetail = new FitnessDetail();
			for each (var d:FitnessDetail in this.acFitnessItems){
				fdNew.cases		+= d.cases;
				fdNew.casesNon	+= d.casesNon;
				fdNew.lbs		+= d.lbs;
				fdNew.lbsNon	+= d.lbsNon;
				fdNew.yago		+= d.yago;
				fdNew.yagoNon	+= d.yagoNon;
				fdNew.revenue	+= d.revenue;
				fdNew.revenueNon += d.revenueNon;
			}
			var s:String = '';
			s = s + String.fromCharCode('32');
			s = s + String.fromCharCode('32');
			s = s + String.fromCharCode('32');
			fdNew.eligibility = acFitnessItems.length.toString();  //'Sum:  ' + 
			_acFitnessTotals.addItem(fdNew);
			acFitnessTotals = _acFitnessTotals;
			acFitnessTotals.refresh();
			return acFitnessTotals;
		}
		public function filterVolume(b:Boolean):void
		{
			this.oFilterParms.bfilterA = b;
			var event:SearchEvent = new SearchEvent(SearchEvent.SAVE_FILTER_PARMS);
			event.oFilterParms = this._oFilterParms;
			this._dispatcher.dispatchEvent(event);
			dispatchEvent(new Event('pmFilterParmsChanged'));
			
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
			evt.oFilterParms = this.oFilterParms;
			/* dispatch the event */
			this._dispatcher.dispatchEvent(evt);
			
		}
		
		public function onSaveClick(arr:Array):void
		{
			//create the FileReference instance
			fileRef = new FileReference();
			
			//listen for the file has been saved
			fileRef.addEventListener(Event.COMPLETE, onFileSave);
			
			//listen for when then cancel out of the save dialog
			fileRef.addEventListener(Event.CANCEL,onCancel);
			
			//listen for any errors that occur while writing the file
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			/* Build the string */
			var s:String = new String();
			var sTmp:String = new String();
			//var cr:String = String.fromCharCode(13, 10);
			var cr:String = '|||';
			var pattern:RegExp = /,/g;
			//var sDesc:String = i.Description.toString().replace(pattern,"");
			var classInfo:XML = describeType(FitnessDetail);
			
			for each (var c:* in arr) {
				if(c.dataField != 'xSpace'){
					var ss:String = c.headerText;
					s = s + ss + ',';
				}
			}
			//remove last comma and add cr
			s = s.slice(0,s.length-1);
			s = s + cr;
			
			for each (var d:FitnessDetail in this.acFitnessItems){
				for each (var cc:* in arr) {
					var v:String = cc.dataField;
					if(v != 'xSpace'){
						switch(v)
						{
							case 'item':
								sTmp = sTmp + '="' + d[v].toString().replace(pattern,"") + '"' + ',';
								break;
							case 'qBrand' :
							case 'prodVarA' :
							case 'typeCodeDesc' :
							case 'description' :
								sTmp = sTmp + d[v].toString().replace(pattern,"") + ',';
								break;
							default:
								sTmp = sTmp + d[v] + ',';
								break;
						}	
					}
				}
				//remove last comma and add cr
				sTmp = sTmp.slice(0,sTmp.length-1);
				s = s + sTmp + cr;
				sTmp = '';
			}
			
			
			//s = 'Item,Description,Rate,UOM,Volume,Price' + ',';
			
			//s = s + '="' + 'item HERE' + '"' + cr;
			var sPrg:String = this.fitnessSearchDef.Program5[this.fitnessSearchDef.Program5Idx].LABEL;
			sPrg = sPrg.toString().slice(sTmp.length-11);
			
			var sFilename:String = "Trade_Eligibilty_" + sPrg + '_' + this.fitnessSearchDef.Customer3[this.fitnessSearchDef.Customer3Idx].LABEL;
			// Remove chars not allowed in Windows filename \ / : * ? " < > |
			sFilename = sFilename.replace(/[~\\\/:\*\?"<>\|]/g, "");
			
			// Trim leading and trailing whitespace.
			sFilename = sFilename.replace(/^\s+|\s+$/gs, "");
			//Alert.show(sFilename);
			//open a native save file dialog, using the default file name
			//fileRef.save(prodRateList,sFilename );
			
			var bytesTemp : ByteArray = new ByteArray();
			//bytesTemp.writeUTFBytes(prodRateList);
			var sendRequest:URLRequest = null;
			
			sendRequest=new URLRequest("/flex/csv_Report.cfm?fileName=" + sFilename);
			
			sendRequest.method = URLRequestMethod.POST;
			sendRequest.data = s;
			sendRequest.contentType = 'text/plain';
			flash.net.navigateToURL(sendRequest,'_blank');
			
		}
		
		//called once the file has been saved
		private function onFileSave(e:Event):void
		{
			trace("File Saved");
			fileRef = null;
		}
		
		//called if an error occurs while saving the file
		private function onSaveError(e:IOErrorEvent):void
		{
			trace("Error Saving File : " + e.text);
			fileRef = null;
		}
		
		public function onCancel(e:Event):void
		{
			trace("File Browse Canceled");
			fileRef = null;
		}
		
		

	}
}