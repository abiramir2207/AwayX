package com.Billback.Edit.models
{
	import com.Billback.Edit.events.BBEditEvent;
	import com.Billback.Edit.models.vos.BBToolsLock;
	import com.shared.components.*;
	import com.shared.components.filters.AdvDataGridDeleteColumn;
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.renderers.AdvancedDataGridHeaderFilterRenderer;
	import com.shared.components.filters.renderers.GridColumnText;
	import com.shared.components.filters.renderers.InsertRowIconRenderer;
	import com.shared.models.GridManager;
	import com.shared.views.renderer.BBUomDropDown;
	import com.shared.views.renderer.gridCombo;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.profiler.showRedrawRegions;
	
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.AdvancedDataGridBaseEx;
	import mx.controls.Alert;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	import mx.controls.listClasses.AdvancedListBase;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.utils.ObjectUtil;
	
	import spark.components.gridClasses.*;
	
	
	public class BBEditItemsGridManager  extends GridManager
	{

		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function BBEditItemsGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}
		
		
		/*.......................  Properties  .......................*/
		[Bindable] public var objBBToolsLock:BBToolsLock = new BBToolsLock();
		private var colGroup:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
		private var colPrgFilter:AdvancedDataGridFilterColumn;
		private var colDistFilter:AdvancedDataGridFilterColumn;
		private var colItemFilter:AdvancedDataGridFilterColumn;
		private var colItemDescFilter:AdvancedDataGridFilterColumn;
		
		/* arrBBEditItemsDgCols bound to dgItems.columns */
		private var _arrBBEditItemsDgCols:Array = new Array();
		[Bindable (event="arrBBEditItemsDgColsChanged")]
		public function get arrBBEditItemsDgCols():Array
		{
			return _arrBBEditItemsDgCols;
		}
		
		public function setGridLockUnlock():void
		{
				
			/* Loop though the items grid and set the EDITABLE property of the columns to true OR false */
			for each(var col:AdvancedDataGridColumn in arrBBEditItemsDgCols)
			{
				if(col.dataField == 'bbProdRate.itemNumber' || col.dataField == 'bbProdRate.volume'
					|| col.dataField == 'bbProdRate.uom' || col.dataField == 'bbProdRate.rate' || col.dataField == 'bbProdRate.amount'
				)
				{					
					col.editable = objBBToolsLock.bEditScreenEnabled;	
				}
			}
			
			/* 	Loop though the items grid and set the VISIBLE property of the columns to true OR false. We do not want
				the checkboxes or the delete icon to be visible when the billback is in "read-only" mode.
			*/
			for each(var colOther:AdvancedDataGridColumn in arrBBEditItemsDgCols)
			{
				if(colOther.dataField == 'isSelected' || colOther.dataField == 'del')
				{			
					colOther.visible = objBBToolsLock.bEditScreenEnabled;	
				}
			}
			
			/* Loop though the items grid and set the EDITABLE property for rate and amount to true OR false.
			   Note: we are looping through "colGroup.children" here.
			*/
			for each(var colGrp:AdvancedDataGridColumn in colGroup.children)
			{
				if(colGrp.dataField == 'bbProdRate.rate' || colGrp.dataField == 'bbProdRate.amount')
				{				
					colGrp.editable = objBBToolsLock.bEditScreenEnabled;	
				}
			}
						
			dispatchEvent(new Event('arrBBEditItemsDgColsChanged'));
		}
		
		public function buildGridCols():void
		{
			var col:AdvancedDataGridColumn;
			
			/*.....	isSelected	.....................  */
			col = new AdvancedDataGridColumn('isSelected');
			col.dataField = 'isSelected';
			col.editable = true;
			col.sortable = false;
			col.resizable = false;
			col.draggable = false;
			col.width = 40;
			col.rendererIsEditor=true;
			// headerrenderer
			var factory:ClassFactory = new ClassFactory(CheckBoxHeaderRenderer);
			factory.properties = {showAddRow:false}; // true = displays insert row icon;
			col.headerRenderer = factory;
			
			col.itemRenderer = new ClassFactory(chBoxIsSelected);
			col.editorDataField = "varCbSelected";
			_arrBBEditItemsDgCols.push(col);

			
			/*.....	del	....................  */			
			var colDelete:AdvDataGridDeleteColumn;
			colDelete = new AdvDataGridDeleteColumn('del');
			colDelete.width = 40;
			colDelete.editable = false;
			colDelete.sortable = false;
			colDelete.resizable = false;
			colDelete.draggable = false;			
			_arrBBEditItemsDgCols.push(colDelete);

						
			/*.....	itemGuid	....................  */
			/*col = new AdvancedDataGridColumn("itemGuid");
			col.dataField = "itemGuid";
			col.headerText = "id";
			col.width = 150;
			col.editable = false;
			_arrBBEditItemsDgCols.push(col);*/

			/*.....	program #	....................   */
			colPrgFilter = new AdvancedDataGridFilterColumn("bbProgram.number");
			colPrgFilter.dataField = "bbProgram.number";
			colPrgFilter.headerText = "program #";
			colPrgFilter.labelFunction = programLabelFunc;
			colPrgFilter.width = 150;
			colPrgFilter.editable = false;
			colPrgFilter.draggable = false;
			colPrgFilter.sortable = true;
			colPrgFilter.sortCompareFunction = programSortFunc;
			colPrgFilter.editVisible = false;
			colPrgFilter.chkBFilterVisible = true;
			_arrBBEditItemsDgCols.push(colPrgFilter);

			/*.....	assoc distributor	....................   */
			colDistFilter = new AdvancedDataGridFilterColumn("bbDistributor.shipTo");
			colDistFilter.dataField = "bbDistributor.shipTo";
			colDistFilter.headerText = "assoc. distributor";
			colDistFilter.labelFunction = shipToLabelFunc;
			colDistFilter.width = 150;
			colDistFilter.editable = false;
			colDistFilter.draggable = false;
			colDistFilter.sortable = true;
			colDistFilter.sortCompareFunction = distributorSortFunc;
			colDistFilter.editVisible = false;
			colDistFilter.chkBFilterVisible = true;
			_arrBBEditItemsDgCols.push(colDistFilter);

			/*.....	itemNumber	....................   */
			// col = new AdvancedDataGridColumn("bbProdRate.itemNumber");
			colItemFilter = new AdvancedDataGridFilterColumn("bbProdRate.itemNumber");
			colItemFilter.dataField = "bbProdRate.itemNumber";
			colItemFilter.headerText = "item";
			colItemFilter.labelFunction = itemLabelFunc;
			colItemFilter.width = 100;
			colItemFilter.editable = true;
			colItemFilter.draggable = false;
			colItemFilter.sortable = true;
			colItemFilter.sortCompareFunction = itemSortFunc;
			colItemFilter.editVisible = false;
			colItemFilter.chkBFilterVisible = false;
			_arrBBEditItemsDgCols.push(colItemFilter);
			
			/*.....	item description	....................   */
			//col = new AdvancedDataGridColumn("bbProdRate.description");
			colItemDescFilter = new AdvancedDataGridFilterColumn("bbProdRate.description");
			colItemDescFilter.dataField = "bbProdRate.description";
			colItemDescFilter.headerText = "item description";
			colItemDescFilter.labelFunction = itemDescLabelFunc;
			colItemDescFilter.width = 175;
			colItemDescFilter.editable = false;
			colItemDescFilter.draggable = false;
			colItemDescFilter.sortable = true;
			colItemDescFilter.sortCompareFunction = itemDescSortFunc;
			colItemDescFilter.editVisible = false;
			colItemDescFilter.chkBFilterVisible = false;
			_arrBBEditItemsDgCols.push(colItemDescFilter);
			
			/*.....	volume	....................   */
			col = new AdvancedDataGridColumn("volume");
			col.dataField = "bbProdRate.volume";
			col.headerText = "volume";
			col.labelFunction = volumeLabelFunc;
			col.width = 60;
			col.editable = true;
			col.draggable = false;
			col.sortCompareFunction = volSortFunc;
			_arrBBEditItemsDgCols.push(col);
			
			/*.....	uom	....................   */
			col = new AdvancedDataGridColumn("bbProdRate.uom");
			var uomEditor:ClassFactory = new ClassFactory(BBUomDropDown);
			// uomEditor.properties = { uomDp: arrUomDp };
			col.dataField = "bbProdRate.uom";
			col.headerText = "uom";
			col.labelFunction = uomLabelFunc;
			col.width = 60;
			col.editable = true;
			col.resizable= false;
			col.draggable = false;
			col.itemEditor = uomEditor;
			col.editorDataField = 'value';
			_arrBBEditItemsDgCols.push(col);
			
			/*.....	type ....................   */
			/*
			col = new AdvancedDataGridColumn("bbProdRate.discountType");
			col.dataField = "bbProdRate.discountType";
			col.headerText = "type";
			col.labelFunction = discoutTypeLabelFunc;
			col.width = 30;
			col.editable = false;
			col.draggable = false;
			col.sortCompareFunction = discountTypeSortFunc;
			_arrBBEditItemsDgCols.push(col);
			*/
			
			/*.....	column group	....................*/   			
			colGroup.headerText = 'discount';
			// colGroup.children.push(colCal);
			
			/*.....	rate	....................   */
			// col = new AdvancedDataGridColumn("rate");
			var colRate:AdvancedDataGridColumn = new AdvancedDataGridColumn("bbProdRate.rate");
			colRate.dataField = "bbProdRate.rate";
			colRate.headerText = "rate";
			colRate.labelFunction = rateLabelFunc; //comes from extends GridManager in shared.models
			colRate.width = 60;
			colRate.editable = true;
			colRate.draggable = false;
			colRate.sortCompareFunction = rateSortFunc;
			//_arrBBEditItemsDgCols.push(colRate);
			colGroup.children.push(colRate);
			
			/*.....	$ amt ....................   */
			// col = new AdvancedDataGridColumn("amount");
			var colAmount:AdvancedDataGridColumn = new AdvancedDataGridColumn("bbProdRate.amount");
			colAmount.dataField = "bbProdRate.amount";
			colAmount.headerText = "$ amt";
			colAmount.labelFunction = amountLabelFunc; //comes from extends GridManager in shared.models
			colAmount.width = 60;
			colAmount.editable = true;
			colAmount.draggable = false;
			colAmount.sortCompareFunction = amountSortFunc;
			//_arrBBEditItemsDgCols.push(colAmount);
			colGroup.children.push(colAmount);
			
			/*.....	type ....................   */
			/*
			// col = new AdvancedDataGridColumn("type");
			var colDiscountType:AdvancedDataGridColumn = new AdvancedDataGridColumn("bbProdRate.discountType");
			colDiscountType.dataField = "bbProdRate.discountType";
			colDiscountType.headerText = "type";
			colDiscountType.labelFunction = discoutTypeLabelFunc;
			colDiscountType.width = 60;
			colDiscountType.editable = false;
			colDiscountType.draggable = false;
			colDiscountType.sortCompareFunction = discountTypeSortFunc;
			//_arrBBEditItemsDgCols.push(colDiscountType);
			colGroup.children.push(colDiscountType);
			*/

			/*.....	column group ....................   */
			_arrBBEditItemsDgCols.push(colGroup); 

			
			/*.....	add	....................  */			
			col = new AdvancedDataGridColumn('add');
			col.width = 40;
			col.editable = false;
			col.sortable = false;
			col.resizable = false;
			col.draggable = false;
			col.itemRenderer = new ClassFactory(InsertRowIconRenderer);
			//_arrBBEditItemsDgCols.push(col);
			
			/*.....	message ....................   */
			col = new AdvancedDataGridColumn("message");
			col.dataField = "message";
			col.headerText = "message";
			col.width = 160;
			col.editable = false;
			col.draggable = false;
			col.sortable = true;
			col.resizable = false;
			col.sortCompareFunction = messageSortFunc;
			col.itemRenderer = new ClassFactory(GridColumnText);
			_arrBBEditItemsDgCols.push(col);
			
			
			/*......... First time edit only............  */
			col = new AdvancedDataGridColumn("bFirstTime");
			col.dataField = "bFirstTime";
			col.editable = false;
			col.sortable = false;
			col.visible = false;
			col.width = 1;
			_arrBBEditItemsDgCols.push(col);
			
			/* Empty col so last row is not huge ....................*/
			col = new AdvancedDataGridColumn("xSpace");
			col.visible = true;
			col.headerText = '';
			col.width = .99;
			col.editable = false;
			col.visible = true;
			col.draggable = false;
			_arrBBEditItemsDgCols.push(col);
			
			/* dispatch the event */
			dispatchEvent(new Event('arrBBEditItemsDgColsChanged'));
		}
		
		// programNumber
		public function programLabelFunc(obj:Object, col:AdvancedDataGridFilterColumn):String{
			var s:String = '';
			if(obj.bbProgram){
				s = obj.bbProgram.number;
			}
			return s;
		}
		
		// distributor [shipTo]
		public function shipToLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(obj.bbDistributor){
				s = obj.bbDistributor.shipTo;
			}
			return s;
		}
		
		// item
		public function itemLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(obj.bbProdRate){
				s = obj.bbProdRate.itemNumber;
			}
			return s;
		}
		
		// itemDescription
		public function itemDescLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(obj.bbProdRate){
				s = obj.bbProdRate.description;
			}
			return s;
		}
		
		// volume
		public function volumeLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(this.oSettings.appSettings.BB_Fractional_Volume == 0)
			{
				if(obj.bbProdRate){
					s = _numFormat.format(obj.bbProdRate.volume);
				}
			}
			else
			{
				if(obj.bbProdRate){
					s = _decTwoFormat.format(obj.bbProdRate.volume);
				}
			}
			return s;
		}

		// uom
		public function uomLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			return obj.bbProdRate.uom.abbreviation;
		}
		
		// rebate columns
		// prg rate
		public function progRateLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(obj.bbProdRate){
				s = _decTwoFormat.format(obj.bbProdRate.rate);
			}
			return s;
		}
		// rate
		public function rateLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(obj.bbProdRate){
				s = _decTwoFormat.format(obj.bbProdRate.rate);
			}
			return s;
		}
		// $ amount
		public function amountLabelFunc(obj:Object, col:AdvancedDataGridColumn):String{
			var s:String = '';
			if(obj.bbProdRate){
				s = _dlrFormatter.format(obj.bbProdRate.amount);
			}
			return s;
		}
		
		// type
		public function discoutTypeLabelFunc(obj:Object, col:AdvancedDataGridColumn):int{
			return obj.bbProdRate.discoutType;
		}
		
		
		// item sort
		public function itemSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProdRate && obj2.bbProdRate){
				i = ObjectUtil.numericCompare(obj1.bbProdRate.itemNumber, obj2.bbProdRate.itemNumber);
			}
			
			/* If the items being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}

		// item description sort
		public function itemDescSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProdRate && obj2.bbProdRate){
				i = ObjectUtil.stringCompare(obj1.bbProdRate.description, obj2.bbProdRate.description);
			}
			
			/* If the item descriptions being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		
		// program sort
		public function programSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProgram && obj2.bbProgram){
				i = ObjectUtil.stringCompare(obj1.bbProgram.number, obj2.bbProgram.number);
			}
			
			/* If the items being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		
		public function distributorSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbDistributor && obj2.bbDistributor){
				i = ObjectUtil.stringCompare(obj1.bbDistributor.shipTo, obj2.bbDistributor.shipTo);
			}
			
			/* If the items being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		
		public function volSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProdRate && obj2.bbProdRate){
				i = ObjectUtil.numericCompare(obj1.bbProdRate.volume, obj2.bbProdRate.volume);
			}
			
			/* If the volumes being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		
		public function rateSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProdRate && obj2.bbProdRate){
				i = ObjectUtil.numericCompare(obj1.bbProdRate.rate, obj2.bbProdRate.rate);
			}
			
			/* If the rates being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		public function amountSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProdRate && obj2.bbProdRate){
				i = ObjectUtil.numericCompare(obj1.bbProdRate.amount, obj2.bbProdRate.amount);
			}
			
			/* If the amounts being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		
		// discount type sort
		public function discountTypeSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			if(obj1.bbProdRate && obj2.bbProdRate){
				i = ObjectUtil.numericCompare(obj1.bbProdRate.discountType, obj2.bbProdRate.discountType);
			}
			
			/* If the discountType being compared are the same, then do a multi-column sort */
			if(i == 0){
				i = multiColumnSortFunc(obj1,obj2);
			}
			
			return i;
		}
		
		public function messageSortFunc(obj1:Object, obj2:Object):int{
			var i:int = 0;
			/* Since we are sorting by message and then program,distributor,item combination, 
			"PRG-" gets sorted above "product not on program". Adding "a" below prevents that
			behavior and makes sure that the primary sort happens correctly on the "message" column,
			and then the secondary sort on program,distributor,item combination.		
			Note: This issue can be reproduced when we have the same items on multiple programs.
			*/
			var s1:String = obj1.message + 'a' ;
			var s2:String = obj2.message + 'a' ;
			
			if(obj1.bbProgram && obj2.bbProgram){
				s1 = s1 + obj1.bbProgram.number;
				s2 = s2 + obj2.bbProgram.number;	
			}
			if(obj1.bbDistributor && obj2.bbDistributor){
				s1 = s1 + obj1.bbDistributor.shipTo;
				s2 = s2 + obj2.bbDistributor.shipTo;	
			}
			if(obj1.bbProdRate && obj2.bbProdRate){
				s1 = s1 + obj1.bbProdRate.itemNumber;
				s2 = s2 + obj2.bbProdRate.itemNumber;		
			}
			i = ObjectUtil.stringCompare(s1, s2);
			return i;
		}
		
		/* Do a multi-column sort.
		Note: This function is called when two values being compared are the same.
		Since the two values are the same (eg: rate, message etc) and can be sorted in any order, sort by this criteria.
		This makes sure that when we select a record using check box, the curser does not jump.
		Note: This issue can be reproduced when we have the same items on multiple programs.
		*/
		public function multiColumnSortFunc(obj1:Object, obj2:Object):int{			
			var i:int = 0;
			
			var s1:String = '';
			var s2:String = '';
			
			/* Sort by a combination of program,distributor and item. */			
			if(obj1.bbProgram && obj2.bbProgram){
				s1 = s1 + obj1.bbProgram.number;
				s2 = s2 + obj2.bbProgram.number;	
			}
			if(obj1.bbDistributor && obj2.bbDistributor){
				s1 = s1 + obj1.bbDistributor.shipTo;
				s2 = s2 + obj2.bbDistributor.shipTo;	
			}
			if(obj1.bbProdRate && obj2.bbProdRate){
				s1 = s1 + obj1.bbProdRate.itemNumber;
				s2 = s2 + obj2.bbProdRate.itemNumber;		
			}
			if(obj1.bbProdRate && obj2.bbProdRate){
				s1 = s1 + obj1.bbProdRate.description;
				s2 = s2 + obj2.bbProdRate.description;		
			}
			
			i = ObjectUtil.stringCompare(s1, s2);
			
			return i;
		}	
	}
}