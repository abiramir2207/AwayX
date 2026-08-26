package com.shared.models
{
	import com.shared.events.MainEvent;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	
	import spark.components.Label;
	import spark.formatters.NumberFormatter;

	public class UploadManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function UploadManager(dispatcher:IEventDispatcher):void
		{
			this._dispatcher = dispatcher;
			fileRef = new FileReference;
			fileRef.addEventListener(Event.SELECT, fileRef_select);
			fileRef.addEventListener(ProgressEvent.PROGRESS, fileRef_progress);
			fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, fileRefDataComplete);
			fileRef.addEventListener(Event.COMPLETE, fileRef_complete);
			progressBar.visible = false;
		}
		
		private var fileRef:FileReference;
		private var numberFormatter:NumberFormatter = new NumberFormatter();
		
		public var message:Label = new Label();
		
		public var progressBar:ProgressBar = new ProgressBar();;
		
		private var FILE_UPLOAD_URL:String;
		
		
		public function browseAndUpload(event:MainEvent):void {
			var textFilter:FileFilter = new FileFilter("BB Upload Files (*.txt; *.csv;*.xls;*.xlsx)", "*.txt;*.csv;*.xls;*.xlsx");
			FILE_UPLOAD_URL = event.sURL;
			fileRef.browse(new Array(textFilter));
			message.text = "";
		}
		
		private function fileRef_select(evt:Event):void {
			try {
				
				message.text = "size (bytes): " + numberFormatter.format(fileRef.size);
				try
				{
					fileRef.upload(new URLRequest(FILE_UPLOAD_URL));
				}
				catch (error:Error)
				{
					Alert.show('Error occured while uploading file to the server: ' + error.toString());
				}

				
				
			} catch (err:Error) {
				message.text = "ERROR: zero-byte file";
			}
		}
		
		private function fileRef_progress(evt:ProgressEvent):void {
			progressBar.visible = true;
		}
		
		private function fileRef_complete(evt:Event):void { 
			//Alert.show('File Successfully Uploaded!');
			message.text += " (complete)";
			progressBar.visible = false;
		}
		
		private function fileRefDataComplete(evt:DataEvent):void {
			//var result:XML = new XML(evt.data);
			var status_txt:String = '';
			status_txt = evt.data;
			/*status_txt += 'Upload Data Complete. ';
			status_txt += 'RESULT: ' + result.toString()  + ' ';
			status_txt += 'STATUS: ' + result.status + ' ';
			status_txt += 'MESSAGE: '+ result.message;*/
			Alert.show(status_txt);
			progressBar.visible = false;
		}
	}
}