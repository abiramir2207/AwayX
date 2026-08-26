package com.shared.models
{
	import com.asfusion.mate.events.Dispatcher;
	import com.shared.events.*;
	import com.shared.vos.Settings;
	import com.shared.views.*;
	import com.shared.vos.GridData;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import flash.net.SharedObject;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;

	public class MainManager extends EventDispatcher 
	{
		/*-.........................................Properties..........................................*/
		/* local references for combo box arrays and item AC */
		private var _acData:ArrayCollection= new ArrayCollection();
		private var _settings:Settings = new Settings();
		
		/*-.........................................Setters and Getters..........................................*/
		// bound to dgItems dataprovider
		[Bindable (event="dataChanged")]
		public function get acData():ArrayCollection
			{
				return _acData;
			}
		public function set acData(ac:ArrayCollection):void
			{
				this._acData = ac;
				dispatchEvent(new Event('dataChanged'));
			}
		public function get settings():Settings 
			{
				return _settings;
			}
		public function set settings(s:Settings):void 
			{
				this._settings = s;
			}

		/*-.........................................Methods..........................................*/

		/* itemresutls() gets called on application load.  we pass results from db to this method */ 
		public function dataResults(arr:Array):void 
			{
				/* loop over arr and cast records as a GridData() object */
				if( arr is Array )
	    		{
		    		for each(var gd:GridData in arr){  }
					/*set the public var*/
					this.acData = new ArrayCollection(arr);
			    }	
			}

	}/* Class end */
}/* Package end */