package com.Admin.Alias.views.pm
{
	import adobe.utils.CustomActions;
	import mx.controls.Alert;
	
	import com.Admin.Alias.events.AliasEvent;
	import com.ContractProds.components.StringUtils;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	public class AliasUpload extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function AliasUpload( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		/*.......................  Properties  .......................*/
		
		[Bindable] public var aliasList:String;
		[Bindable] public var items:ArrayCollection = null;
		//FileReference Class well will use to load data
		private var _fileRef:FileReference;
		[Bindable (event="FileRefChanged")]
		public function get fileRef():FileReference
		{
			return _fileRef;
		}
		public function set fileRef(fr:FileReference):void
		{
			this._fileRef = fr;
			dispatchEvent(new Event('FileRefChanged'));
		}


		//File types which we want the user to open
		private static const FILE_TYPES:Array = [new FileFilter("Text File", "*.csv")];
		private static const DEFAULT_FILE_NAME:String = "Unipro_Alias_List.csv";
		
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
			
			//read the bytes of the file as a string
			aliasList = data.readUTFBytes(data.bytesAvailable);
			var event:AliasEvent = new AliasEvent(AliasEvent.IMPORT_ALIAS_LIST);
			event.sAliasList = aliasList;
			this.dispatcher.dispatchEvent(event);
			//clean up the FileReference instance
			
			fileRef = null;
		}

		//called if an error occurs while loading the file contents
		public function onLoadError(e:IOErrorEvent):void
		{
			trace("Error loading file : " + e.text);
		}
		
	}
}