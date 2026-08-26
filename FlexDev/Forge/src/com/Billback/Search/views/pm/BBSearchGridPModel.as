package com.Billback.Search.views.pm
{
	import com.Billback.Main.events.BBMainEvent;
	import com.Billback.Main.models.vos.BBHeader;
	import com.Billback.Search.events.BBSearchEvent;
	import com.Billback.Search.vos.BBFilterDef;
	import com.shared.vos.Settings;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	
	public class BBSearchGridPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBSearchGridPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		[Bindable]
		public var acData:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var listCollView:ListCollectionView = new ListCollectionView();
		//[Bindable]
		//public var acLookupData:ArrayCollection = new ArrayCollection;
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var arrBBSearchDgCols:Array = new Array();
		[Bindable]
		public var objLookupData:BBFilterDef;
		
		public function selectBB(bbH:BBHeader,reDirector:String):void{
			var e:BBMainEvent = new BBMainEvent(BBMainEvent.EDIT_BB);
			e.bbHeader = bbH;
			//	e.reDirector = reDirector;
			oSettings.sBBDeviationSource = reDirector;
			e.payeeList = new Array(bbH.payee);
			e.closingMethodList = objLookupData.closingMethodList; // Send in the closingMethod List too for the edit screen dropdown instead of loading from CF.
			e.bbAnalysts = objLookupData.analystList; // Send in the analysts List too for the edit screen dropdown instead of loading from CF.
			this._dispatcher.dispatchEvent(e);
		}
		
		/* "BBHeader" is passed on click from the datagrid. "BBDetails" is then added as a property to it.  */
		public function selectBBHeader(bbH:BBHeader):void{
			var e:BBSearchEvent = new BBSearchEvent(BBSearchEvent.SELECT_BB);
			e.eBBHeader = bbH;
			this._dispatcher.dispatchEvent(e);
		}
		
		
	}
}