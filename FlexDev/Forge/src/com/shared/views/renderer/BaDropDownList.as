package com.shared.views.renderer
{
	import flash.events.Event;
	
	import mx.collections.IList;
	import mx.utils.ObjectUtil;
	
	import spark.components.DropDownList;

	public class BaDropDownList extends DropDownList
	{
		/*.......................  Constructor  .......................*/
		public function BaDropDownList()
		{
			super();
			super.height = 15;
		}
		/*.......................  Properties  .......................*/
		private var tmpSelectedItem:*;
		public var sIdField:String = '';
		
		/* defaultSingle = true will set the requireSelection property to true only if there is 1 item in the dp*/
		private var _defaultSingle:Boolean= false;
		public function set defaultSingle(b:Boolean):void{
			this._defaultSingle = b;
			if(b && this.dataProvider && this.dataProvider.length == 1){
				super.requireSelection = true;
			}
			dispatchEvent(new Event('defaultSingleChanged'));
		}
		[Bindable (event="defaultSingleChanged")]
		public function get defaultSingle():Boolean{
			return _defaultSingle;
		}
		
		//TODO::  Add custom IdField Property.  Then Use it to valiudate the selection.  The labelfield may not be unique
		/*.......................  Methods  .......................*/
		public function set currentSelection(obj:*):void{
			var bSimpleType:Boolean = ObjectUtil.isSimple(obj);
			this.tmpSelectedItem = obj;
			//simple data type: string,number...be carefull, an array is simple (but will break in either condition
			if(bSimpleType){//currentselection passed in is simple type.
				if(sIdField != ''){//dataprovider items are complex and the sIdfield has been set to tell us name of Property to compare
					for each(var objItem:* in this.dataProvider.toArray()){
						if(objItem[this.sIdField] == obj){
							this.selectedItem = objItem;
							break;
						}
					}
				}
				else{//dataprovider items are simple and so is currentselection passed in
					for each(var sItem:* in this.dataProvider.toArray()){
						if(sItem == obj){
							this.selectedItem = sItem;
							break;
						}
					}
				}
			}
			//complex object.  Use labelField to inspect obj
			else{
				if(sIdField != ''){//sIdfield tells us the name of property to compare to currentselection
					for each(var objItem:* in this.dataProvider.toArray()){
						if(objItem[this.sIdField] == obj[this.sIdField]){
							this.selectedItem = objItem;
							break;
						}
					}
				}
				else{//use default labelfield
					for each(var objItem:* in this.dataProvider.toArray()){
						if(objItem[this.labelField] == obj[this.labelField]){
							this.selectedItem = objItem;
							break;
						}
					}
				}	
			}
		}
		
		override public function set dataProvider(value:IList):void
		{   
			super.dataProvider = value;
			//default to an item if only one choice. fire the setter executes the logic 
			this.defaultSingle = _defaultSingle;
			//reset any selections taht may have been programatically set before dp updated
			this.currentSelection = tmpSelectedItem;
		}
		
	}
}
