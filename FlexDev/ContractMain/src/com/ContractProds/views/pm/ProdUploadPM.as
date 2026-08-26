package com.ContractProds.views.pm
{
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.Item;
	import com.ContractProds.vos.ProdRate;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
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
				var cr:String = String.fromCharCode(13, 10);
				var nRate:Number;
				var sUom:String;
				s = 'Item,Rate,UOM,Volume' + cr;
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
					s = s + prodRate.itemNumber + ',';
					s = s + nRate + ',';
					s = s + sUom + ',';
					s = s + i.volume + cr;
				}
				prodRateList = s;
				//open a native save file dialog, using the default file name
				fileRef.save(prodRateList, DEFAULT_FILE_NAME);
			}
			
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