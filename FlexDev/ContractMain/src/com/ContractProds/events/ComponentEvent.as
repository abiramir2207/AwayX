package com.ContractProds.events
{
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.ComponentDef;
	import com.ContractProds.vos.Item;
	import com.ContractProds.vos.Payee;
	import com.ContractProds.vos.ProdRate;
	import com.ContractProds.vos.Uom;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	[Bindable]
	public class ComponentEvent extends Event
	{
		/*-.........................................Constants..........................................*/
		public static const SELECT_COMPONENT_TYPE:String = "selectComponentType";
		public static const SELECT_COMPONENT_DEF:String = "selectComponentDef";
		public static const SELECT_COMPONENT_DEF_BYID:String = "selectComponentDefById";
		public static const GET_COMPONENT_DEFS:String = "getComponentDefs";
		public static const ADD:String = "addComp";
		public static const SELECT:String = "selectComp";
		public static const UPDATE:String = "updateComp";
		public static const DELETE:String = "deleteComp";
		public static const SET_RATE_UOM:String = "setRateUom";
		public static const SET_RATE:String = "setRate";
		public static const SET_UOM:String = "setUom";
		public static const SET_VOL:String = "setVol";
		public static const SET_SINGLE_RATE_UOM:String = "setSingleRateUom";
		public static const IMPORT_PROD_RATE_LIST:String = "importProdRateList";
		public static const EXPORT_PROD_RATE_LIST:String = "exportProdRateList";
		public static const SET_RESULT_LOG:String = "setResultLog";
		public static const LOAD_PROD_RATE:String = "loadProdRate";
		public static const LOAD_COMPONENT:String = "loadComponent";
		public static const LOAD_PROGRAM:String = "loadProgram";
		public static const SET_PAYEE:String = "setPayeeEvent";
		public static const SAVE_DATA:String = "saveData";
		public static const DISPLAY_LIST_RATE:String = "displayListRate";
		public static const DELETE_PROD_RATE:String = "deleteProdRate";
		

		/*-.........................................Properties..........................................*/
		public var compDef:ComponentDef;
		public var typeId:int;
		public var component:Component;
		public var payee:Payee;
		public var programId:int;
		public var prodRate:ProdRate;
		public var item:Item;
		public var prodRateList:String;
		public var sResult:String;
		public var sRate:String;
		public var nRate:Number;
		public var uom:Uom;
		public var sId:String;
		public var acComponents:ArrayCollection;
		public var arr1:Array;
		public var arr2:Array;
		public var arr3:Array;
		public var bMarketPrice:Boolean;
		public var iUomAction:int;

		/*-.........................................Contructor..........................................*/
		public function ComponentEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}

	}
}