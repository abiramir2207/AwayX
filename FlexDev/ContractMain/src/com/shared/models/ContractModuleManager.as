package com.shared.models
{
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.vos.Payee;
	import com.asfusion.mate.events.Dispatcher;
	import com.shared.IModuleInterface;
	import com.shared.events.MainEvent;
	import com.shared.vos.Settings;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.system.System;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.managers.PopUpManager;
	import mx.managers.PopUpManagerChildList;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	
	public class ContractModuleManager extends EventDispatcher
	{
		/*-...................................... Constructor.......................................*/
		/* private var _dispatcher:IEventDispatcher;
		public function ContractModuleManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		} */
		/*.......................................  Properties  ......................................*/
		
		
		/*-.........................................Methods..........................................*/
		/*........................ Distributor Search Module ...........................  */
      //  private var _searchDist:IModuleInterface;
		private var _searchDist:IModuleInterface;
        public var m:IModuleInfo;
		public var settings:Settings = new Settings();
        public function showPayeeSearch(e:MainEvent):void {
        	if(e.payeeTypeId == ComponentManager.DISTRIBUTOR_TYPE_ID){
        		showDistributorSearch();
        	}
        	else if(e.payeeTypeId == ComponentManager.VENDOR_TYPE_ID){
        		showVendorSearch();
        	}
        }
        
        public function showDistributorSearch():void {
        	if(m){
        		m.dispatchEvent(new Event(ModuleEvent.READY));
        	}
        	else{
        		m = ModuleManager.getModule('/flex/Program/com/DistributorSearch/DistributorSearch.swf')
        		m.addEventListener(ModuleEvent.READY, modReady,false,0,true);
				m.load();
        	}
		}
		/* TODO: omly load modulel once.  since it does not get GC'ed, we will end up with multiple copies.
		 We will need to check if it is loaded and then just use it.  remove the unload from payeeSearch as well.
		 Cleaner solution will be to find a way to get it to GC */
		public function modReady(e:Event):void {
			if(!_searchDist){
				_searchDist = m.factory.create() as IModuleInterface;
			}
			_searchDist.programId = this.settings.programId;
			_searchDist.oneDistSelection = true;
			//_searchDist.dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
			PopUpManager.addPopUp(_searchDist, Application.application as DisplayObject, true,PopUpManagerChildList.APPLICATION);
			PopUpManager.centerPopUp(_searchDist);	
		}

		public function closePayeeSearch():void {
			PopUpManager.removePopUp(_searchDist);
			/* We are not unloading since some refernce is preventing the SWF from getting GC'ed.  Instead we keep in memory and re-use the existing one*/
			//m.removeEventListener(ModuleEvent.READY,modReady);
			//m.release();
			//m.unload();
			//_searchDist = null;
			//m = null;
			//m.removeEventListener(ModuleEvent.READY, modReady)
			//m.unload();
		}
 
		public function showVendorSearch():void {
			 if (ExternalInterface.available)
		    ExternalInterface.addCallback("saveVendor", saveVendor);
		    var jscommand:String = "window.open('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?RebateRecipient_On=1&FormName=flex&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch','win','height=600,width=800,toolbar=no,scrollbars=yes');";
		    var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
		    navigateToURL(url,'_self');
		}

		public function saveVendor(id:String,name:String):void {
			var p:Payee = new Payee();
			p.name = name;
			p.payeeId = id;
			p.payeeTypeId = ComponentManager.VENDOR_TYPE_ID; //TODO: need a constant from payee object here
			var e_Dispatcher:Dispatcher = new Dispatcher();
			var e:ComponentEvent = new ComponentEvent(ComponentEvent.SET_PAYEE,true);
				e.payee = p;
       		e_Dispatcher.dispatchEvent(e);
			//Alert.show(id + '  ::  ' + name);
		}

	}
}