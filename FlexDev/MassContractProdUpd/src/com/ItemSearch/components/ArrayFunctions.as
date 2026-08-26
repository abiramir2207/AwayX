package com.components
{
	import mx.controls.Alert;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class ArrayFunctions extends EventDispatcher
	{
		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Properties ~~~~~~~~~~~~~~~~~~~~~~~~*/
		private var _iMin:int = 0;
		private var _iMax:int = 0;

	
		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Getters and Setter ~~~~~~~~~~~~~~~~*/
		/** use the get method instead of a property in case we need to manipulate the property*/
		[Bindable (event="updMin")]
		public function get iMin():int
		{	return _iMin; }

		[Bindable (event="updMax")]
		public function get iMax():int
		{	return _iMax; }
		
 		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Constructor ~~~~~~~~~~~~~~~~~~~~~~~~*/
		public function ArrayFunctions()
		{}

		/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~*/

		public function showMinMax():void
		{
			Alert.show("CALLED FROM ArrayFunctions\n MIN: " + this._iMin + "\n MAX: " + this._iMax);
		}
		
		public function minMaxArray(a:Array):void 
		{
			/* pass the NUMERIC attribute to ovveride the default text sort */
			a.sort(Array.NUMERIC);
			/* set the value of the private _vars */
			this._iMin = a[ 0 ];
			this._iMax = a[ a.length - 1 ];
			/* dispatch Bindable events to the Public Getters for these properties */
			dispatchEvent(new Event('updMin'));
			dispatchEvent(new Event('updMax'));
		}
	}
}