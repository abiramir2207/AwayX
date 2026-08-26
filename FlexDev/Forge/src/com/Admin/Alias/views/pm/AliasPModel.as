package com.Admin.Alias.views.pm
{
	
	import com.Admin.Alias.events.AliasEvent;
	import com.Admin.Alias.models.vos.AliasDef;
	import com.Billback.Main.models.vos.Payee;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	public class AliasPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function AliasPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}		
		
		/*.......................  Properties  .......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var aliasSelectedDef:AliasDef = new AliasDef();
		[Bindable]
		public var sourceInfo:Payee = new Payee();
		[Bindable]
		public var sourceTypes:Array = new Array();
		[Bindable]
		public var defaultOption:int;
		[Bindable]
		public var enablePayee:Boolean = true;	
		[Bindable]
		public var showPayee:Boolean = false;			
		[Bindable]
		public var enableDownloadData:Boolean = false;	
		[Bindable]
		public var nHeightContainer:Number = 105;		
		[Bindable]
		public var nWidthContainer:Number = 1200;
		
		/* Set the "SOURCE" to the selected source. This value is set in the "AliasDef" when the user clicks on "save Alias" button */
		/* SET_SOURCE is called when "search Alias" button is clicked. If the user selects a vendor from the pop up page without clicking on "search Alias", 
		   then SET_SOURCE is called from "SourceInfoResults" function in AliasManager.
		*/
		public function updateSource(sourceType:int,sourceID:String,sourceCode:String,useSearchTool:int):void{
			var eventSetSource:AliasEvent = new AliasEvent(AliasEvent.SET_SOURCE);
			
			/* useSearchTool is 0 when we do not use a vendor id from the "Payee" textbox as there are no individual vendors with unique id's. In this
			case, we just use the EDI ID. For eg: SYSCO EDI or USFS EDI. sourceType = 100 means All Alias - In this case we do need vendor Id also.
			*/
			if(useSearchTool == 0 && sourceType != 100){
				sourceID = sourceCode;
			}
			
			eventSetSource.iSourceType = sourceType;
			eventSetSource.sSourceID = sourceID;
						
			this._dispatcher.dispatchEvent(eventSetSource);
		}
		
		/* Get the payee description when the user enters the payee ID manually */
		public function getVendorDesc(sourceType:int,sourceID:String,sourceCode:String,useSearchTool:int):void{
			var eventGetSourceInfo:AliasEvent = new AliasEvent(AliasEvent.GET_SOURCE_INFO);
			
			/* useSearchTool is 0 when we do not use a vendor id from the "Payee" textbox as there are no individual vendors with unique id's. In this
			case, we just use the EDI ID. For eg: SYSCO EDI or USFS EDI. sourceType = 100 means All Alias - In this case we do need vendor Id also.
			*/
			if(useSearchTool == 0 && sourceType != 100){
				sourceID = sourceCode;
			}
		
				eventGetSourceInfo.sSourceID = sourceID;	
			
			this._dispatcher.dispatchEvent(eventGetSourceInfo);
		}
		
		/* search payee (source) when the pop up window is being used */
		public function getSourceSearch():void{
			var eventLoadSourceSearch:AliasEvent = new AliasEvent(AliasEvent.LOAD_SOURCE_SEARCH);
			this._dispatcher.dispatchEvent(eventLoadSourceSearch);							
		}
		
		/* search payee (source) when the pop up window is being used */
		public function getSourceTypeOption(useSearchTool:String):void{
			var eventDisableEnablePayee:AliasEvent = new AliasEvent(AliasEvent.DISABLE_ENABLE_PAYEE);
			eventDisableEnablePayee.sUseSearchTool = useSearchTool;
			this._dispatcher.dispatchEvent(eventDisableEnablePayee);
		}	
		
		/* generate report for all aliases 
		public function callExportXLS():void{
			var eventGetAliases:AliasEvent = new AliasEvent(AliasEvent.GET_ALIASES);
			this._dispatcher.dispatchEvent(eventDisableEnablePayee);
		}*/
		
		/* generate report for all aliases */
		public function callExportXLS():void{
			var eventGetAliases:AliasEvent = new AliasEvent(AliasEvent.EXPORT_XLS);
			this._dispatcher.dispatchEvent(eventGetAliases);
		}

	}
}