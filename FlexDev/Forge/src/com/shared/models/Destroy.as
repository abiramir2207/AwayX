package com.shared.models
{
	import mx.binding.utils.BindingUtils;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	public class Destroy
	{
		public function Destroy()
		{
		}
		
		public static function cleanUp(ui:*,mx_internal:*):void{
			var o:Object = ObjectUtil.getClassInfo(ui)
			var sObjName:String = ObjectUtil.getClassInfo(ui).name;
			
			disposeAllCurlyBraceBindings(ui,mx_internal);
			
			//now remove pModel
			if(ui.hasOwnProperty('pModel')){
				var oPmod:Object = ObjectUtil.getClassInfo(ui.pModel)
				for each(var z:* in oPmod.properties){
					try{
						ui.pModel[z.localName] = null;
						trace('pModel:: ' + sObjName + ' :: ' + oPmod + '.' + z.localName.toString() );
					}
					catch(e:Error){
						trace('XpModel:: ' + sObjName + ' :: '  + e.message + ' :: ' + oPmod + '.' + z.localName.toString() );
					}
				}
				ui.pModel = null;
			}
			
			//All Properties...I think this is too much
			/*for each(var x:* in o.properties){
				if(x.localName.toString().indexOf('EventMap') >= 0){
					var obj:Object = ObjectUtil.getClassInfo(ui[x.localName]);
					for each(var y:* in obj.properties){
						try{
							ui[x.localName][y.localName] = null;
							trace('EventMap: ' + x.localName.toString() + '.' + y.localName.toString() );
						}
						catch(e:Error){
							trace('XEventMap: ' + e.message + ' :: ' + x.localName.toString() + '.' + y.localName.toString() );
						}
					}	
				}
				else{
					try{
						ui[x.localName]= null;
						trace('Prop: ' + sObjName + ' :: ' + x.localName.toString() );
					}
					catch(e:Error){
						trace('XProp: ' + sObjName + ' :: ' + e.message + ' :: ' + x.localName.toString() );
					}
				}
			}*/

		}
		
		
		public static function disposeAllCurlyBraceBindings(ui:*,mx_internal:*):void {
			var i:int = 0;
			var len:int = 0;
			
			//tear bindings
			var myBindings:Array;
			var bindDestinations:Object;
			var bindBeginWithWord:Object;
			try {
				myBindings = ui.mx_internal::_bindings;
				bindDestinations = ui.mx_internal::_bindingsByDestination;
				bindBeginWithWord = ui.mx_internal::_bindingsBeginWithWord;
				ui.mx_internal::_bindings = null;
				ui.mx_internal::_bindingsByDestination = null;
				ui.mx_internal::_bindingsBeginWithWord = null;
			} catch (err:Error) {
				trace("TEARDOWNVIEW_ERROR processing bindings");
			} finally {
				if (myBindings) {
					len = myBindings.length;
					for (i = 0; i < len; i++) {
						var binding:Object = myBindings.pop();
						
						if (binding) {
							binding.mx_internal::isExecuting = false;
							binding.mx_internal::isEnabled = false;
							binding.mx_internal::isHandlingEvent = false;
							binding.mx_internal::destFunc = null;
							binding.mx_internal::srcFunc = null;
							binding.mx_internal::destString = null;
							binding.mx_internal::disabledRequests = null;
							binding.twoWayCounterpart = null;
							binding.uiComponentWatcher = -1;
							binding.mx_internal::document = null;
						}
					}
				}
				deleteAllDynamicProperties(bindDestinations);
				deleteAllDynamicProperties(bindBeginWithWord);
			}
			
			//tear watchers
			var myWatchers:Array;
			try {
				myWatchers = ui.mx_internal::_watchers;
				ui.mx_internal::_watchers = null;
			} catch (err:Error) {
				trace("TEARDOWNVIEW_ERROR processing watchers");
			} finally {
				if (myWatchers) {
					len = myWatchers.length;
					for (i = 0; i < len; i++) {
						var watcher:Object = myWatchers.pop();
						
						if (watcher) {
							if (watcher.hasOwnProperty("value")) {
								watcher["value"] = null;
							}
						}
					}
				}
			}
		}
		private static function deleteAllDynamicProperties(obj:Object):void {
			if (!obj) {
				return;
			}
			for (var str:String in obj) {
				delete obj[str];
				trace('DELETE: ' + str);
			}
		}
	}
}