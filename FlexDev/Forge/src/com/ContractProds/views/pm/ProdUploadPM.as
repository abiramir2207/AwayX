package com.ContractProds.views.pm
{
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.models.ComponentManager;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Component;
	import com.shared.vos.Item;
	import com.shared.vos.ProdRate;
	import com.shared.vos.ProductAttr;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import adobe.utils.CustomActions;
	
	public class ProdUploadPM extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function ProdUploadPM( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		/*.......................  Properties  .......................*/
		
		[Bindable] public var prodRateList:String;
		[Bindable] public var items:ArrayCollection = null;
		//FileReference Class well will use to load data
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
		/*...................... Component ......................*/
		private var _component:Component = new Component();
		[Bindable (event="ComponentChange")]
		public function get component():Component
		{
			return _component;
		}
		public function set component(comp:Component):void
		{
			this._component = comp;
			dispatchEvent(new Event('ComponentChange'));
		}
		/* Program */
		private var _program:Program = new Program();
		[Bindable (event="upldProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		public function set program(prg:com.shared.vos.Program):void
		{
			this._program = prg;
			dispatchEvent(new Event('upldProgramChange'));
		}

		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="pmUpldSettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			dispatchEvent(new Event('pmUpldSettingsChanged'));
		}
		//File types which we want the user to open
		private static const FILE_TYPES:Array = [new FileFilter("Text File", "*.csv")];
		private static const DEFAULT_FILE_NAME:String = "Prod_Rates.csv";
		
		/*..........................................................
		........................  Methods  .........................
		............................................................*/

		//called when the user clicks the load file button
		public function onLoadFileClick():void
		{
			//create the FileReference instance
			fileRef = new FileReference();

			//listen for when they select a file
			fileRef.addEventListener(Event.SELECT, onFileSelect);

			//listen for when then cancel out of the browse dialog
			fileRef.addEventListener(Event.CANCEL,onCancel);

			//open a native browse dialog that filters for text files
			fileRef.browse(FILE_TYPES);
		}

		/*................. Browse Event Handlers .....................*/

		//called when the user selects a file from the browse dialog
		public function onFileSelect(e:Event):void
		{
			//listen for when the file has loaded
			fileRef.addEventListener(Event.COMPLETE, onLoadComplete);

			//listen for any errors reading the file
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			//load the content of the file
			fileRef.load();
		}

		//called when the user cancels out of the browser dialog
		public function onCancel(e:Event):void
		{
			trace("File Browse Canceled");
			fileRef = null;
		}

		/*................. Select Event Handlers .....................*/

		//called when the file has completed loading
		public function onLoadComplete(e:Event):void
		{
			//get the data from the file as a ByteArray
			var data:ByteArray = fileRef.data;

			//read the bytes of the file as a string and put it in the
			//textarea
			prodRateList = data.readUTFBytes(data.bytesAvailable);
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.IMPORT_PROD_RATE_LIST);
			event.prodRateList = prodRateList;
			this.dispatcher.dispatchEvent(event);
			//clean up the FileReference instance

			fileRef = null;
		}

		//called if an error occurs while loading the file contents
		public function onLoadError(e:IOErrorEvent):void
		{
			trace("Error loading file : " + e.text);
		}
		
		/*..........................................................
		........................  EXPORT/Download FILE  .........................
		............................................................*/
		
		/********** UI Event Handlers **************/

			//called when the user clicks the load file button
			public function onSaveClick():void
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
				//var cr:String = String.fromCharCode(13, 10);
				var cr:String = '|||';
				var nRate:Number;
				var sUom:String;
				var arrPrdAttr:Array  =  this.program.arrPrdAttr;
				var pattern:RegExp = /,/g;
				s = 'Item,Description,Rate,UOM,Volume,Price' + ',';
				if(this.component.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID){
					for each(var cust:Customer in this.program.distributors){
						s = s + "Cust Rate " + cust.shipTo + ',';
					}
				}
				
				for each (var attr:ProductAttr in arrPrdAttr){
					s = s + attr.groupLevelDesc.toString().replace(pattern," ") + ',';
				}
				if(this.program.template.bGroupDeal == true && this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups){
					s = s + 'Key' + cr;
				}
				else{
					s = s + cr;
				}
				for each(var i:Item in this.items){
					var sId:String = ComponentManager.getSelectedCompId(this.component);
					var prodRate:ProdRate = i[sId]['prodRate'];
					var volume:Number = i.volume;
					
					/* default empty rate to 0 */
					if(isNaN(prodRate.rate))
						{nRate = 0}
					else{nRate = prodRate.rate}
					/* default uom to first one in component */
					if(prodRate.uom.abbreviation == null)
						{sUom = this.component.uom[0].abbreviation}
					else{sUom = prodRate.uom.abbreviation}
					/* write string */
					if(this.program.template.bGroupDeal ==  true && this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups){
						s = s + '="' + i.baItemDisplay + '"' + ',';
					}
					else{
						s = s + '="' + prodRate.itemNumber + '"' + ',';	
					}
					var sDesc:String = i.Description.toString().replace(pattern,"");
					s = s + sDesc + ',';
					s = s + nRate + ',';
					s = s + sUom + ',';
					s = s + i.volume + ',';
					s = s + prodRate.rateMP + ',';					
					if(this.component.fixedType == ComponentManager.FIXED_CUST_RATE_TYPE_ID){
						var rateCust:Number;
						for each(var cust2:Customer in this.program.distributors){
							rateCust = prodRate['rateCust_'+ cust2.shipTo];
							if(isNaN(rateCust))
								{rateCust = 0}
							s = s + rateCust + ',';
						}
					}
					
					for each (var attr2:ProductAttr in arrPrdAttr){
						s = s + i[attr2.productGroupAttributeNameField].toString().replace(pattern," ") + ',';
					}
					
					if(this.program.template.bGroupDeal == false){
						s = s + cr; 
					}
					else{
						s = s + '="' + prodRate.itemNumber + '"' + cr;
					}
					/*if(this.program.template.bGroupDeal == true){
						s = s + '="' + prodRate.itemNumber + '"' + cr; 
					}*/
				}
				prodRateList = s;
				
				var sFilename:String = "Prod_Rates_" + this.program.number + "_" + this.component.name +".csv";
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
				sendRequest.data = prodRateList;
				sendRequest.contentType = 'text/plain';
				flash.net.navigateToURL(sendRequest,'_blank');
				
			}
			private var loader:URLLoader = new URLLoader(); 
			

			//called when the user clicks the load file button
			public function downloadInvalidItems(arrItems:Array):void
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
				var cr:String = String.fromCharCode(13, 10);
				s = 'Item,Rate,UOM,Volume' + cr;
				for each(var i:Object in arrItems){
					s = s + i.item + ',';
					s = s + StringUtils.getDecimal(i.rate) + ',';
					s = s + i.uom + ',';
					s = s + i.volume + cr;
				}
				prodRateList = s;
				//open a native save file dialog, using the default file name
				fileRef.save(prodRateList, DEFAULT_FILE_NAME);
			}

			/***** File Save Event Handlers ******/

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

	}
}