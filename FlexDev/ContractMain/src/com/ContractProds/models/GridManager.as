package com.ContractProds.models
{
	import com.ContractProds.components.*;
	import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	import com.ContractProds.views.pm.GridDataPM;
	import com.ContractProds.views.renderer.RateText;
	import com.ContractProds.views.renderer.RateTextMP;
	import com.ContractProds.views.renderer.UomCombo;
	import com.ContractProds.views.renderer.UomComboMP;
	import com.ContractProds.vos.Component;
	import com.ContractProds.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	import mx.core.ClassFactory;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.NumberFormatter;
	
	
	public class GridManager extends EventDispatcher
	{

		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		public function GridManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
			/* Populate the array arrDgItemsCols bound to dgItems.columns */
			this.buildGridCols();
		/* set formatter precision */
	    	_decFormat.precision = 4;
	    	_decFormat.useNegativeSign = false;
	    	/* set formatter precision */
	    	_numFormat.precision = 0;
			_numFormat.useThousandsSeparator = false;
	    	_numFormat.useNegativeSign = false;
	    	
	    	_dlrFormatter.precision = 0;
	    	_dlrFormatter.currencySymbol = '$';
	    	_dlrFormatter.useNegativeSign = false;
	    	
	    	_dlrFormatterDec.precision = 4;
	    	//_dlrFormatterDec.currencySymbol = '$';
	    	_dlrFormatterDec.useNegativeSign = false;
			
			_decTwoFormat.precision = 2;
			_decTwoFormat.useNegativeSign = false;
		}
		
		/*.......................  Properties  .......................*/
		public var _numFormat:NumberFormatter =  new NumberFormatter();
		public var _decFormat:NumberFormatter =  new NumberFormatter();
		public var _decTwoFormat:NumberFormatter =  new NumberFormatter();
		public var _dlrFormatter:CurrencyFormatter = new CurrencyFormatter();
		public var _dlrFormatterDec:CurrencyFormatter = new CurrencyFormatter();
		/*.......................................  Properties  ......................................*/
		[Bindable]
		public var program:Program;
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="pmsettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			updateGridColsHeaderText();
			dispatchEvent(new Event('pmsettingsChanged'));
		}
		/* arrDgItemsCols bound to dgItems.columns */
		private var _arrDgItemsCols:Array = new Array();
		[Bindable (event="arrDgItemsColsChanged")]
		public function get arrDgItemsCols():Array
		{
			return _arrDgItemsCols;
		}
		/* public function set arrDgItemsCols(arr:Array):void
		{
			this._arrDgItemsCols = arr;
			dispatchEvent(new Event('arrDgItemsColsChanged'));
		} */
		/* build arrDgItemsCols which is boound to dgItems.columns in the view.  Should make this dynamic...poulate it from a vos with static vars*/
        public function buildGridCols():void
    	{
    		/*.....	empty for tabbing	.....  */
    		var col:AdvancedDataGridColumn = new AdvancedDataGridColumn('xTab');
    			/* col.dataField = 'isSelected';
    			col.visible = false;
    		_arrDgItemsCols.push(col); */
    		/*.....	isSelected	.....  */
    		col = new AdvancedDataGridColumn('isSelected');
    			col.dataField = 'isSelected';
    			col.editable = true;
    			col.sortable = false;
    			col.width = 20;
    			col.rendererIsEditor=true;
				col.headerRenderer = new ClassFactory(chBoxSelectAll);
				col.itemRenderer = new ClassFactory(chBoxIsSelected); 
        		col.editorDataField = "varCbSelected";
    		_arrDgItemsCols.push(col);
    		/*.....	baItem	.....  */
    		col = new AdvancedDataGridColumn("baItem");
    			col.dataField = "baItem";
    			col.headerText = "Item";
    			col.width = 100;
    			col.editable = false;
    		_arrDgItemsCols.push(col);
    		/*.....	Description	.....  */
    		col = new AdvancedDataGridColumn("Description");
    			col.dataField = "Description";
    			col.headerText = "Description";
    			col.width = 250;
    			col.editable = false;
    		_arrDgItemsCols.push(col);
			/*..... Volume	.....  */
			col = new AdvancedDataGridColumn("volume");
			//col.id = "colVolume"
			col.dataField = "volume";
			col.headerText = "Volume";
			col.width = 70;
			col.editable = true;
			col.visible = true;
			col.sortable = false;
			col.labelFunction = formatNumber;
			_arrDgItemsCols.push(col);
    		/*.....	Brand_Name	.....  */
    		col = new AdvancedDataGridColumn("colBrand");
    			//col.id = "colBrand";
    			col.dataField = "Brand_Name";
    			col.headerText = oSettings.brand;
    			col.width = 100;
    			col.editable = false;
    			col.visible = false;
    		_arrDgItemsCols.push(col);
    		/*.....	Q_Brand	.....  */
    		col = new AdvancedDataGridColumn("colQBrand");
    			//col.id = "colQBrand";
    			col.dataField = "Q_Brand";
    			col.headerText = oSettings.qBrand;
    			col.width = 100;
    			col.editable = false;
    			col.visible = false;
    		_arrDgItemsCols.push(col);
    		/*.....	Type_Code_Desc	.....  */
    		col = new AdvancedDataGridColumn("colTypeGroup");
    			//col.id = "colTypeGroup";
    			col.dataField = "Type_Code_Desc";
    			col.headerText =  oSettings.typeCode ;
    			col.width = 100;
    			col.editable = false;
    			col.visible = false;
    		_arrDgItemsCols.push(col);
    		/*.....	Type_Group_Desc	.....  */
    		col = new AdvancedDataGridColumn("colTypeCode");
    			//col.id = "colTypeCode"
    			col.dataField = "Type_Group_Desc";
    			col.headerText = oSettings.typeGroup;
    			col.width = 100;
    			col.editable = false;
    			col.visible = false;
    		_arrDgItemsCols.push(col);
    		/*.....	Item_Status	.....  */
    		col = new AdvancedDataGridColumn("colStatus");
    			//col.id = "colStatus";
    			col.dataField = "Item_Status";
    			col.headerText = oSettings.lblStatus;
    			col.width = 100;
    			col.editable = false;
    			col.visible = false;
    		_arrDgItemsCols.push(col);
    		/* Empty col so last row is not huge */
    		col = new AdvancedDataGridColumn("xSpace");
    			col.visible = true;
    			col.headerText = '';
    			col.width = .99;
    			col.editable = false;
    			col.visible = true;
    		_arrDgItemsCols.push(col); 
    		dispatchEvent(new Event('arrDgItemsColsChanged'));
    	}    
		public function addComponent(comp:Component):void
		{
			var iWidth:int = 75;
			/* remove the Spacer col and add it at end */
			var i:int = 0;
			for each(var column:* in _arrDgItemsCols){
			 if(column.headerText == ''){
					_arrDgItemsCols.splice(i,1);
					break;
				}
				i++;
			}
			/*.....	component	.....  */
			var s:String = '';
				s = s + comp.type as String;
				s = s + comp.componentId as String;
			/* column group */
			var colGroup:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
				colGroup.headerText = comp.name;
			/* rate column */
    		var colRate:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'rate');
    			colRate.itemEditor = new ClassFactory(RateText);
    			colRate.headerText = 'rate';
    			colRate.dataField = s+'.prodRate.rate'
    			colRate.editorDataField = 'value';
    			colRate.editable = true;
    			colRate.labelFunction = formatDecimal;
    			colRate.setStyle('textAlign','right');
    			colRate.minWidth = iWidth;
    			colRate.resizable= false;
    			colRate.width = iWidth;
    		/* uom column */	
    		var colUom:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'uom');
    			colUom.itemEditor = new ClassFactory(UomCombo);
    			colUom.headerText = 'uom';
    			colUom.dataField = s+'.prodRate.uom';
    			colUom.editorDataField = 'value';
    			colUom.editable = true;
    			colUom.minWidth = iWidth;
    			colUom.resizable= false;
    			colUom.width = iWidth;
			/* add new cols to a group */
			colGroup.children.push(colRate);
			colGroup.children.push(colUom);
			/* ADD Market Price Columns if Needed*/
			if(comp.type == com.ContractProds.models.ComponentManager.FIXED_TYPE_ID && program.bMarketPriceTemplate){
				/* rate column */
				var colRateMPCS:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'rateMPCS');
				//colRateMP.itemEditor = new ClassFactory(RateTextMP);
				colRateMPCS.headerText = 'MP/CS';
				colRateMPCS.dataField = s+'.prodRate.rateMPCS';
				//colRateMPCS.editorDataField = 'value';
				colRateMPCS.editable = false;
				colRateMPCS.labelFunction = formatDecimal;
				colRateMPCS.setStyle('textAlign','right');
				colRateMPCS.minWidth = iWidth;
				colRateMPCS.resizable= false;
				colRateMPCS.width = iWidth;
				
				var colRateMPLB:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'rateMPLB');
				//colRateMP.itemEditor = new ClassFactory(RateTextMP);
				colRateMPLB.headerText = 'MP/LB';
				colRateMPLB.dataField = s+'.prodRate.rateMPLB';
				//colRateMPLB.editorDataField = 'value';
				colRateMPLB.editable = false;
				colRateMPLB.labelFunction = formatDecimal;
				colRateMPLB.setStyle('textAlign','right');
				colRateMPLB.minWidth = iWidth;
				colRateMPLB.resizable= false;
				colRateMPLB.width = iWidth;
				/* uom column */	
				/*var colUomMP:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'uomMP');
					//colUomMP.itemEditor = new ClassFactory(UomComboMP);
				colUomMP.headerText = 'MP uom';
				colUomMP.dataField = s+'.prodRate.uomMP';
					//colUomMP.editorDataField = 'value';
				colUomMP.editable = false;
				colUomMP.minWidth = iWidth;
				colUomMP.resizable= false;
				colUomMP.width = iWidth;*/
				
				/* absVariance column */
				var colVarianceMP:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'varianceMP');
				//colVarianceMP.itemEditor = new ClassFactory(RateTextMP);
				colVarianceMP.headerText = 'variance';
				colVarianceMP.dataField = s+'.prodRate.varianceMP'
				//colVarianceMP.editorDataField = 'value';
				colVarianceMP.editable = false;
				colVarianceMP.labelFunction = formatDecimal;
				colVarianceMP.setStyle('textAlign','right');
				colVarianceMP.minWidth = iWidth;
				colVarianceMP.resizable= false;
				colVarianceMP.width = iWidth;
				/* percVariance column */
				var colVariancePercMP:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'variancePercMP');
				//colVariancePercMP.itemEditor = new ClassFactory(RateTextMP);
				colVariancePercMP.headerText = '% variance';
				colVariancePercMP.dataField = s+'.prodRate.variancePercMP'
				//colVariancePercMP.editorDataField = 'value';
				colVariancePercMP.editable = false;
				colVariancePercMP.labelFunction = formatTwoDecimal;
				colVariancePercMP.setStyle('textAlign','right');
				colVariancePercMP.minWidth = iWidth;
				colVariancePercMP.resizable= false;
				colVariancePercMP.width = iWidth;
				/* add new cols to a group */
				colGroup.children.push(colRateMPCS);
				colGroup.children.push(colRateMPLB);
				//colGroup.children.push(colUomMP);
				colGroup.children.push(colVarianceMP);
				colGroup.children.push(colVariancePercMP);
			}	

    		/* empty column for tabbing */
    		/* var colX:AdvancedDataGridColumn = new AdvancedDataGridColumn(s);
    			colX.visible = false; */
    		
    	/* column groups for component types */
    		var colGroupFix:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
    		var colGroupRebate:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
    		var colGroupComp:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
    		for each(var col:* in this._arrDgItemsCols){
				if(col is AdvancedDataGridColumnGroup){
					if(col.headerText == ComponentManager.REBATE_NAME){
						colGroupRebate = col;
					}
					else if(col.headerText == ComponentManager.FIXED_NAME){
						colGroupFix = col;
					}
				}
    		}
    		if(comp.type == ComponentManager.FIXED_TYPE_ID){
    			colGroupFix.children.push(colGroup);
    			if(!colGroupFix.headerText){
    				colGroupFix.headerText = ComponentManager.FIXED_NAME;
    				_arrDgItemsCols.push(colGroupFix);
    			}	
    		}
    		else if(comp.type == ComponentManager.REBATE_TYPE_ID){
    			colGroupRebate.children.push(colGroup);
    			if(!colGroupRebate.headerText){
    				colGroupRebate.headerText = ComponentManager.REBATE_NAME;
    				_arrDgItemsCols.push(colGroupRebate);
    			}
    		}
    	/* Empty col so last row is not huge */
    		col = new AdvancedDataGridColumn("xSpace");
    			col.visible = true;
    			col.headerText = "";
    			col.width = .99;
    			col.editable = false;
    			col.visible = true;
    		_arrDgItemsCols.push(col); 
    	/* 	colGroup.children.push(colX); */
    		/* addd the group to the dg */
    		//_arrDgItemsCols.push(colGroup);
			//remove volume column if MP Rates tool
			if(this.oSettings.bMarketPrice){
				var i:int = 0;
				for each(var col:* in _arrDgItemsCols){
					if(col is AdvancedDataGridColumn && col.dataField == 'volume'){
						_arrDgItemsCols.splice(i,1);
						break;
					}
					i++;
				}
				
			}
			
    		dispatchEvent(new Event('arrDgItemsColsChanged'));
		}
		
		public function deleteComponent(comp:Component):void
		{
			var i:int = 0;
			for each(var col:* in _arrDgItemsCols){
				/* if(col.headerText == comp.name){
					_arrDgItemsCols.splice(i,1);
					break;
				}
				i++; */
				if(col is AdvancedDataGridColumnGroup){
					if(comp.type == ComponentManager.FIXED_TYPE_ID){
						if(col.headerText == ComponentManager.FIXED_NAME){
							for each(var colCompFix:AdvancedDataGridColumn in col.children){
		    					if(colCompFix.headerText == comp.name){
									col.children.splice(i,1);
									break;
								}
								i++;
		    				}
		    			break;
						}
		    		}//if
		    		else if(comp.type == ComponentManager.REBATE_TYPE_ID){
		    			if(col.headerText == ComponentManager.REBATE_NAME){
							for each(var colCompReb:AdvancedDataGridColumn in col.children){
		    					if(colCompReb.headerText == comp.name){
									col.children.splice(i,1);
									break;
								}
								i++;
		    				}
		    			break;
						}
		    		}//elseif	
				}//if group
				
			}//for each cols
			dispatchEvent(new Event('arrDgItemsColsChanged'));
			/* re run filter since data changed */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
				/* dispatch the event */
           	this._dispatcher.dispatchEvent(evt);
		}
		
		 /* fired when oSettings gets updated -> update the headertext in dgItems.columns */
        public function updateGridColsHeaderText():void
    	{
    		for each(var col:AdvancedDataGridColumn in this._arrDgItemsCols){
				switch(col.dataField)
				{
					case 'Brand_Name':
						col.headerText = this.oSettings.brand;
						break;
					case 'Q_Brand':
						col.headerText = this.oSettings.qBrand;
						break;
					case 'Type_Code_Desc':
						col.headerText = this.oSettings.typeCode;
						break;
					case 'Type_Group_Desc':
						col.headerText = this.oSettings.typeGroup;
						break;
					case 'Item_Status':
						col.headerText = this.oSettings.lblStatus;
						break;
				}
    		}
    	}
    	
    	public function formatDecimal(item:Object, column:AdvancedDataGridColumn):String 
	    {
			return _decFormat.format(item[column.dataField]);
	    }
		public function formatTwoDecimal(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decTwoFormat.format(item[column.dataField]);
		}
	    public function formatNumber(item:Object, column:AdvancedDataGridColumn):String 
	    {
			return _numFormat.format(item[column.dataField]);
	    }
	    public function formatDollar(item:Object, column:AdvancedDataGridColumn):String 
	    {
	    	return this._dlrFormatter.format(item[column.dataField]);
			
	    }
	    public function formatDollarDec(item:Object, column:AdvancedDataGridColumn):String 
	    {
	    		return this._dlrFormatterDec.format(item[column.dataField]);
	
	    }

	}
}