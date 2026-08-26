package com.shared.models
{
	import com.shared.events.MainEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.utils.ObjectUtil;
	import flash.net.navigateToURL;
	import spark.components.Label;
	import spark.formatters.NumberFormatter;
	
	public class DownloadManager
	{
		
		public var fileRefModel:Object;
		/* URL of the file to download. */
		private static var FILE_DOWNLOAD_URL:String;
		private var fileRef:FileReference;
		private var urlReq:URLRequest;
		private var urlLdr:URLLoader;
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher = new EventDispatcher();
		public function DownloadManager(dispatcher:IEventDispatcher = null)
		{
			
			if(dispatcher){
				this._dispatcher = dispatcher;
			}
			
			
			/* Define file reference object and add a bunch of event listeners. */
			fileRef = new FileReference();
			fileRef.addEventListener(Event.CANCEL, doEvent);
			fileRef.addEventListener(Event.COMPLETE, doEvent);
			fileRef.addEventListener(Event.OPEN, doEvent);
			fileRef.addEventListener(Event.SELECT, doEvent);
			//fileRef.addEventListener(HTTPStatusEvent.HTTP_STATUS, doEvent);
			//fileRef.addEventListener(IOErrorEvent.IO_ERROR, doEvent);
			fileRef.addEventListener(ProgressEvent.PROGRESS, doEvent);
			//fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, doEvent);
			
			//urlReq = new URLRequest(FILE_DOWNLOAD_URL);
			
			/* Initialize the URLLoader object, assign the various event listeners, and load the specified URLRequest object. */
			urlLdr = new URLLoader();
			urlLdr.dataFormat = URLLoaderDataFormat.TEXT;
			urlLdr.addEventListener(Event.COMPLETE, readFileEvent);
			urlLdr.addEventListener(Event.OPEN, readFileEvent);
			//urlLdr.addEventListener(HTTPStatusEvent.HTTP_STATUS, readFileEvent);
			//urlLdr.addEventListener(IOErrorEvent.IO_ERROR, readFileEvent);
			urlLdr.addEventListener(ProgressEvent.PROGRESS, readFileEvent);
			//urlLdr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, readFileEvent);
			
		}
		
		private function doEvent(evt:Event):void {
			/* Create shortcut to the FileReference object. */
			
			
			try {
				//fileRef = evt.currentTarget as FileReference;
				fileRefModel = new Object();
				/* Update the Model. */
				fileRefModel.creationDate = fileRef.creationDate;
			//	fileRefModel.creator = fileRef.creator;
				fileRefModel.modificationDate = fileRef.modificationDate;
				fileRefModel.name = fileRef.name;
				fileRefModel.size = fileRef.size;
				fileRefModel.type = fileRef.type;
				/* Display the Text control. */
				//txt.visible = true;
			} catch (err:*) {
				if(evt.type == Event.OPEN){
					Alert.show('Unable to download the file [no data].' + ObjectUtil.toString(err) + ObjectUtil.toString(evt) + ' :: ' + FILE_DOWNLOAD_URL,'Download Error');
				}		
			}
			if(evt.type == Event.COMPLETE){
			
				var e:MainEvent = new MainEvent(MainEvent.DOWNLOAD_FILE_COMPLETE);
				e.sState = 'Download complete: ' + fileRef.name + ' :: ' + fileRef.size + ' :: ' + fileRef.type + ' :: ' + fileRef.modificationDate;// + sfileName;
				this._dispatcher.dispatchEvent(e);
			}
		}
		
		private function readFileEvent(evt:Event):void {
			//arrColl.addItem({type:evt.type, idx:arrColl.length+1, eventString:evt.toString()});
			
			switch (evt.type) {
				case Event.COMPLETE:
					/* If the load was successful, create a URLVariables object from the URLLoader.data property and populate the paramColl ArrayCollection object. */
					var ldr:URLLoader = evt.currentTarget as URLLoader;
					var sData:String = ldr.data;
					
					var e:MainEvent = new MainEvent(MainEvent.DOWNLOAD_FILE_COMPLETE);
					e.sState = sData;// + sfileName;
					this._dispatcher.dispatchEvent(e);
					break;
			}
		}
		
		public function downloadFile(event:MainEvent):void {
			var textFilter:FileFilter = new FileFilter("Text Files (*.txt)", "*.txt");
			FILE_DOWNLOAD_URL = event.sURL;
			/* Set up the URL request to download the file specified by the FILE_URL variable. */
			urlReq = new URLRequest(FILE_DOWNLOAD_URL);
			try {
				// The below line is the Flex way of downloading the file.
				// fileRef.download(urlReq,event.sState);
				
				// The path below is also hardcoded in the CFC file  - CF way to download file
				var winjscommand:String = "/getDocument.cfm?filepath=/Data_Files/Settings/Billback_Upload_Files/"+event.sState;
				var jscommand:String = "window.open('"+winjscommand+"', 'FileDownload', 'height=200,width=350,toolbar=no,scrollbars=yes,resizable=yes');"
				var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
				navigateToURL(url,'_self');
				
			} catch (err:*) {
				Alert.show('Unable to download the file.' + event.sURL,'Download Error');
			}
			
		}
		
		public function readFile(event:MainEvent):void {
			var textFilter:FileFilter = new FileFilter("Text Files (*.txt)", "*.txt");
			FILE_DOWNLOAD_URL = event.sURL;
			/* Set up the URL request to download the file specified by the FILE_URL variable. */
			urlReq = new URLRequest(FILE_DOWNLOAD_URL);
			urlLdr.load(urlReq);
		}
		
	}
}