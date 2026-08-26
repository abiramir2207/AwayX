	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.*;
	import mx.events.*; 
	
	[Bindable]
	public var budgetDetailsRoAC:ArrayCollection = null;
	public var budgetBasicInfoRoAC:ArrayCollection = null;
	public var tempBDRO:Array = null;
	public var tempBBRO:Array = null;
	
	public function budgetDetailsReceived(event:ResultEvent):void {
	    budgetDetailsRoAC = new ArrayCollection();
	    tempBDRO = new Array(event.result);
	    budgetDetailsRoAC.source = tempBDRO;
	}
	public function budgetBasicInfoReceived(event:ResultEvent):void {
	    budgetBasicInfoRoAC = new ArrayCollection();
	    tempBBRO = new Array(event.result);
	    budgetBasicInfoRoAC.source = event.result as Array;
	}