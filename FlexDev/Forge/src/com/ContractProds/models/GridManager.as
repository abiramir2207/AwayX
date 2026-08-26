package com.ContractProds.models
{
	//import com.ContractProds.components.*;
	//import com.ContractProds.components.StringUtils;
	import com.ContractProds.events.ComponentEvent;
	import com.ContractProds.events.SearchEvent;
	import com.ContractProds.models.ComponentManager;
	//import com.ContractProds.views.pm.GridDataPM;
	import com.ContractProds.views.renderer.BaAdvancedDataGridColumnGroup;
	import com.ContractProds.views.renderer.RateText;
	import com.ContractProds.views.renderer.RateTextCustomer;
	//import com.ContractProds.views.renderer.RateTextMP;
	import com.ContractProds.views.renderer.UomCombo;
	//import com.ContractProds.views.renderer.UomComboMP;
	import com.shared.components.chBoxIsSelected;
	import com.shared.components.chBoxSelectAll;
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.FilterAdvancedDatagrid;
	import com.shared.events.MainEvent;
	import com.shared.models.entity.vos.Customer;
	import com.shared.vos.Component;
	import com.shared.vos.CustomPrint;
	import com.shared.vos.CustomPrintCharge;
	//import com.shared.vos.Payee;
	import com.shared.vos.ProductAttr;
	import com.shared.vos.Program;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	//import mx.collections.ArrayCollection;
	//import mx.controls.ComboBox;
	//import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	import mx.core.ClassFactory;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.NumberBaseRoundType;
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
			_numFormat.rounding = NumberBaseRoundType.NEAREST;
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
		/* Program */
		private var _program:Program = new Program();
		[Bindable (event="gmProgramChange")]
		public function get program():Program
		{
			return _program;
		}
		public function set program(prg:Program):void
		{
			this._program = prg;
			dispatchEvent(new Event('gmProgramChange'));
			/* program defines template level Prod attrs.  add them to grid*/
			insertProdAttrCols();
		}
		/*...................... Component ......................*/
		private var _component:Component = new Component();
		[Bindable (event="GMComponentChange")]
		public function get component():Component
		{
			return _component;
		}
		public function set component(comp:Component):void
		{
			this._component = comp; 
			this.sId = ComponentManager.getSelectedCompId(comp);
			dispatchEvent(new Event('GMComponentChange'));
		}
		public var sId:String = '';
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
		[Bindable]
		public var fadg:FilterAdvancedDatagrid;
		public function setFadg(e:MainEvent):void{
			this.fadg = e.fadg;
		}
		/* build arrDgItemsCols which is boound to dgItems.columns in the view.  Should make this dynamic...poulate it from a vos with static vars*/
        public function buildGridCols():void
    	{
			var colFilter:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn();
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
			colFilter = new AdvancedDataGridFilterColumn("baItemDisplay");
    		//col = new AdvancedDataGridColumn("baItem");
				colFilter.dataField = "baItemDisplay";
				colFilter.headerText = "Item";
				colFilter.visible = true;//NEED TO MAKE DYNAMIC
				colFilter.width = 100;
				colFilter.editable = false;
				colFilter.editVisible = false;
				colFilter.filterVisible = true;
    		_arrDgItemsCols.push(colFilter);
    		/*.....	Description	.....  */
			colFilter = new AdvancedDataGridFilterColumn("Description");
			colFilter.dataField = "Description";
			colFilter.headerText = "Description";
			colFilter.visible = true;//NEED TO MAKE DYNAMIC
			colFilter.width = 217;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = true;
    		_arrDgItemsCols.push(colFilter);
			/*..... Volume	.....  */
			col = new AdvancedDataGridColumn("volume");
			//col.id = "colVolume"
			col.dataField = "volume";
			col.headerText = "Volume";
			col.visible = true;//NEED TO MAKE DYNAMIC
			col.width = 70;
			col.editable = true;
			col.sortable = false;
			col.labelFunction = formatNumber;
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
			var colGroup:BaAdvancedDataGridColumnGroup = new BaAdvancedDataGridColumnGroup();
				colGroup.headerText = comp.name;
				colGroup.component = comp;
			/* rate column */
    		var colRate:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'rate');
    			colRate.itemEditor = new ClassFactory(RateText);
    			colRate.headerText = 'rate';
				/*
				if(comp.fixedType == com.ContractProds.models.ComponentManager.FIXED_CUST_RATE_TYPE_ID){
					colRate.headerText = 'FOB';	
				}
				*/				
    			colRate.dataField = s;
    			colRate.editorDataField = 'value';
    			colRate.editable = true;
    			colRate.labelFunction = this.rateLabelFunc;// formatDecimal;
    			colRate.setStyle('textAlign','right');
    			colRate.minWidth = iWidth;
				colRate.sortable = true;
    			colRate.resizable= false;
    			colRate.width = iWidth;
				colRate.sortCompareFunction = this.rateSortFunc;
				//colRate.
    		/* uom column */	
    		var colUom:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'uom');
    			colUom.itemEditor = new ClassFactory(UomCombo);
    			colUom.headerText = 'uom';
    			colUom.dataField = s;
				colUom.labelFunction = uomLabelFunc;
    			colUom.editorDataField = 'value';
    			colUom.editable = true;
    			colUom.minWidth = iWidth;
    			colUom.resizable= false;
    			colUom.width = iWidth;
				colUom.sortCompareFunction = this.uomSortFunc;
			/* cad rate column */
			var colCACRate:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'rateConverted');
				//colCACRate.itemEditor = new ClassFactory(RateText);
				colCACRate.headerText = 'cad';
				colCACRate.dataField = s;
				colCACRate.editorDataField = 'value';
				colCACRate.editable = false;
				colCACRate.labelFunction = rateConvertedLabelFunc;
				colCACRate.setStyle('textAlign','right');
				colCACRate.minWidth = iWidth;
				colCACRate.resizable= false;
				colCACRate.width = iWidth;
				colCACRate.visible = false;
			/* add new cols to a group */
			colGroup.children.push(colRate);
			colGroup.children.push(colUom);
			colGroup.children.push(colCACRate);
			/* ADD Market Price/ Customer Rate Columns if Needed*/
			if(comp.type == com.ContractProds.models.ComponentManager.FIXED_TYPE_ID || program.bMarketPriceTemplate){
				if(comp.fixedType == com.ContractProds.models.ComponentManager.FIXED_CUST_RATE_TYPE_ID){
					for each(var c:Customer in this.program.distributors){
						var b:Boolean = true;
						//check if the col already exists
						for each(var advCol:AdvancedDataGridColumn in this._arrDgItemsCols){
							if(advCol.dataField == c.customerId){
								b = false;
								break;
							}
						}
						if(b){
							/*.....	Add Customer Level Rate	.....  */
							var sTip:String = '';
							sTip = c.name + '\n' + c.address.city + ', ' + c.address.state + ' ' + c.address.zipCode;
							var colFilter:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn();
							//col.id = "colBrand";
							colFilter.dataField = s;
							colFilter.dataFieldComplex = c.shipTo;
							colFilter.editorDataField = 'value';
							colFilter.labelFunction = rateCustomerLabelFunc;
							colFilter.itemEditor = new ClassFactory(RateTextCustomer);
							colFilter.headerText = c.shipTo;//'rate\n' + 
							colFilter.toolTip = sTip;
							colFilter.width = iWidth;
							colFilter.editable = true;
							colFilter.sortable = true;
							colFilter.visible = true;
							colFilter.filterComboVisible = false;
							colFilter.filterVisible = false;
							colGroup.children.push(colFilter.cloneFC());
							//this._arrDgItemsCols.splice(this._arrDgItemsCols.length - 2,0,colFilter.cloneFC());
							var colFilterCACRate:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn();
							//colCACRate.itemEditor = new ClassFactory(RateText);
							colFilterCACRate.headerText = 'cad';
							colFilterCACRate.dataField = s;
							colFilterCACRate.dataFieldComplex = c.shipTo;
							colFilterCACRate.editorDataField = 'value';
							colFilterCACRate.editable = false;
							colFilterCACRate.filterVisible = false;
							colFilterCACRate.labelFunction = rateCustConvertedLabelFunc;
							colFilterCACRate.setStyle('textAlign','right');
							colFilterCACRate.minWidth = iWidth;
							colFilterCACRate.resizable= false;
							colFilterCACRate.width = iWidth;
							colFilterCACRate.visible = false;
							colGroup.children.push(colFilterCACRate.cloneFC());
						}
						
					}
				}
				if(program.bMarketPriceTemplate  && component.type == ComponentManager.FIXED_TYPE_ID){
					
					/* MARKET PRICE WAS HERE*/
				}
			}
			
			var sRateMP:String = 'price';
			if(program.bMarketPriceTemplate){
				sRateMP = 'MP rate';
			}
			/* rate column */
			var colRateMP:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'rateMP');
			//colRateMP.itemEditor = new ClassFactory(RateTextMP);
			colRateMP.headerText = sRateMP;//price	TODO: populate regular price in this property [rateMP] in DAO.  Then we can remove "If MarketPrice" check and show for all comps
			colRateMP.dataField = s;
			colRateMP.labelFunction = rateMPLabelFunc;
			//colRateMP.editorDataField = 'value';
			colRateMP.editable = false;
			colRateMP.setStyle('textAlign','right');
			colRateMP.minWidth = iWidth;
			colRateMP.resizable= false;
			colRateMP.width = iWidth;
			colRateMP.sortCompareFunction = this.mpRateSortFunc;
			/* absVariance column */
			var colVarianceMP:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'varianceMP');
			//colVarianceMP.itemEditor = new ClassFactory(RateTextMP);
			colVarianceMP.headerText = 'variance';
			colVarianceMP.dataField = s;
			//colVarianceMP.editorDataField = 'value';
			colVarianceMP.editable = false;
			colVarianceMP.labelFunction = varianceMPLabelFunc;
			colVarianceMP.setStyle('textAlign','right');
			colVarianceMP.minWidth = iWidth;
			colVarianceMP.resizable= false;
			colVarianceMP.width = iWidth;
			colVarianceMP.sortCompareFunction = this.mpVarianceSortFunc;
			/* percVariance column */
			var colVariancePercMP:AdvancedDataGridColumn = new AdvancedDataGridColumn(s+'variancePercMP');
			//colVariancePercMP.itemEditor = new ClassFactory(RateTextMP);
			colVariancePercMP.headerText = 'disc %';//'% variance';
			colVariancePercMP.dataField = s;
			//colVariancePercMP.editorDataField = 'value';
			colVariancePercMP.editable = false;
			colVariancePercMP.labelFunction = variancePercMPLabelFunc;
			colVariancePercMP.setStyle('textAlign','right');
			colVariancePercMP.minWidth = iWidth;
			colVariancePercMP.resizable= false;
			colVariancePercMP.width = iWidth;
			colVariancePercMP.sortCompareFunction = this.mpPercentSortFunc;
			/* add new cols to a group */
			colGroup.children.push(colRateMP);
			if(program.bMarketPriceTemplate && component.type == ComponentManager.FIXED_TYPE_ID){
				colGroup.children.push(colVarianceMP);
			}
			colGroup.children.push(colVariancePercMP);
			
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
			var iVolCol:int = 2;
			if(this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups > 0){
				iVolCol = 1;
			}
    		if(comp.type == ComponentManager.FIXED_TYPE_ID){
    			colGroupFix.children.push(colGroup);
    			if(!colGroupFix.headerText){
    				colGroupFix.headerText = ComponentManager.FIXED_NAME;
    				//_arrDgItemsCols.push(colGroupFix); KRAFT Leave Volume as last col
					_arrDgItemsCols.splice(_arrDgItemsCols.length-iVolCol,0,colGroupFix);
    			}	
    		}
    		else if(comp.type == ComponentManager.REBATE_TYPE_ID){
    			colGroupRebate.children.push(colGroup);
    			if(!colGroupRebate.headerText){
    				colGroupRebate.headerText = ComponentManager.REBATE_NAME;
    				//_arrDgItemsCols.push(colGroupRebate); KRAFT Leave Volume as last col
					_arrDgItemsCols.splice(_arrDgItemsCols.length-iVolCol,0,colGroupRebate);
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
				var ix:int = 0;
				for each(var colx:* in _arrDgItemsCols){
					if(colx is AdvancedDataGridColumn && colx.dataField == 'volume'){
						_arrDgItemsCols.splice(ix,1);
						break;
					}
					ix++;
				}
			}
    		dispatchEvent(new Event('arrDgItemsColsChanged'));
			// CUSTOM COLUMNS BASED ON comp.customPrint.bCustomPrint
			var event:ComponentEvent = new ComponentEvent(ComponentEvent.INSERT_CUSTOM_PRINT_COLS);
			event.component = comp;
			event.arr1 = new Array();
			this.insertCustomPrintCols(event);
		}
		
		public function deleteComponent(comp:Component):void
		{
			var i:int = 0;
			var iGrp:int = 0;
			var bDone:Boolean;
			for each(var col:* in _arrDgItemsCols){
				/* if(col.headerText == comp.name){
					_arrDgItemsCols.splice(i,1);
					break;
				}
				i++; */
				if(col is AdvancedDataGridColumnGroup){
					col = col as AdvancedDataGridColumnGroup;
					if(comp.type == ComponentManager.FIXED_TYPE_ID){
						if(col.headerText == ComponentManager.FIXED_NAME){
							for each(var colCompFix:AdvancedDataGridColumn in col.children){
		    					if(colCompFix.headerText == comp.name){
									col.children.splice(i,1);
									break;
								}
								i++;
		    				}
						bDone = true;
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
						bDone = true;;
						}
		    		}//elseif
					//clean up AdvancedDataGridColumnGroup if no children
					if(bDone){
						var x:int =  col.children.length;
						if(!col.children || x == 0){
							_arrDgItemsCols.splice(iGrp,1);
						}
						break;
					}
				}//if group
				iGrp++;
			}//for each cols
			dispatchEvent(new Event('arrDgItemsColsChanged'));
			/* re run filter since data changed */
			var evt:SearchEvent = new SearchEvent(SearchEvent.FILTER);
				/* dispatch the event */
           	this._dispatcher.dispatchEvent(evt);
		}
		
		/* fired after program data arrives with Template specific prod attrs (allow in search, group in search) */
		public function insertProdAttrCols():void
		{
			for each(var pa:ProductAttr in this.program.arrPrdAttr){
				var b:Boolean = true;
				//check if the col already exists
				for each(var col:AdvancedDataGridColumn in this._arrDgItemsCols){
					if(col.dataField == pa.productGroupAttributeNameField){
						b = false;
						break;
					}
				}
				if(b){
					/*.....	Add Prod Attrs	.....  */
					var colFilter:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn(pa.productGroupAttributeNameField);
					//col.id = "colBrand";
					colFilter.dataField = pa.productGroupAttributeNameField;
					colFilter.headerText = pa.groupLevelDesc;
					colFilter.width = 110;
					colFilter.editable = false;
					colFilter.sortable = true;
					colFilter.visible = true;
				/*	if(pa.groupLevelDesc.toLowerCase() =='level 1'){
						colFilter.visible = true;
						colFilter.width = 185;
					}*/
					colFilter.filterComboVisible = true;
					colFilter.filterVisible = true;
					this._arrDgItemsCols.splice(this._arrDgItemsCols.length - 3,0,colFilter.cloneFC());
				}
					
			}
			dispatchEvent(new Event('arrDgItemsColsChanged'));
		}
    	
		public function insertCustomPrintCols(event:ComponentEvent):void
		{
			var comp:Component = event.component;
			var iWidth:int = 60;
			var sColMakeReadyText:String = 'print options';
			/*.....	component	.....  */
			var s:String = '';
			s = s + comp.type as String;
			s = s + comp.componentId as String;
			var colGroup:AdvancedDataGridColumnGroup;
			var b:Boolean;
			//should we insret cust print cols? fixed comp && template Setting
			if(comp.type == 1 && this.program.template.bCustomPrint && !this.oSettings.bMarketPrice && this.oSettings.appSettings.Template_Multiple_Product_Attr_Groups){
				b= true;
			}
			//see if the cols already exist
			for each(var col:* in this._arrDgItemsCols){
				if(col is AdvancedDataGridColumnGroup){
					if(col.headerText == ComponentManager.FIXED_NAME){
						for each(var colGrpFix:* in col.children){
							if(colGrpFix.headerText == comp.name){
								for each(var colData:* in colGrpFix.children){
									if(colData.headerText == sColMakeReadyText){
										b = false;
									}
								}
								if(b){
									colGroup = colGrpFix;
								}
							}
						}
					}
				}
			}
			if(b){  //comp.customPrint.bCustomPrint

				/*var colPrintMakeReady:AdvancedDataGridColumn = new AdvancedDataGridColumn('printMakeReady');
				colPrintMakeReady.headerText = sColMakeReadyText;
				colPrintMakeReady.dataField = 'customPrintCharge';
				colPrintMakeReady.editable = false;
				colPrintMakeReady.labelFunction = makeReadyLabelFunc;
				colPrintMakeReady.setStyle('textAlign','right');
				colPrintMakeReady.minWidth = iWidth;
				colPrintMakeReady.sortable = false;
				colPrintMakeReady.resizable= false;
				colPrintMakeReady.width = iWidth;
				
				var colPrintPlate:AdvancedDataGridColumn = new AdvancedDataGridColumn('printPlate');
				colPrintPlate.headerText = 'plate';
				colPrintPlate.dataField = 'customPrintCharge';
				colPrintPlate.editable = false;
				colPrintPlate.labelFunction = plateLabelFunc;
				colPrintPlate.setStyle('textAlign','right');
				colPrintPlate.minWidth = iWidth;
				colPrintPlate.sortable = false;
				colPrintPlate.resizable= false;
				colPrintPlate.width = iWidth;
				
				var colPrintPrePress:AdvancedDataGridColumn = new AdvancedDataGridColumn('printPrePress');
				colPrintPrePress.headerText = 'pre-press';
				colPrintPrePress.dataField = 'customPrintCharge';
				colPrintPrePress.editable = false;
				colPrintPrePress.labelFunction = prePressLabelFunc;
				colPrintPrePress.setStyle('textAlign','right');
				colPrintPrePress.minWidth = iWidth;
				colPrintPrePress.sortable = false;
				colPrintPrePress.resizable= false;
				colPrintPrePress.width = iWidth;
				
				colGroup.children.push(colPrintMakeReady);
				colGroup.children.push(colPrintPlate);
				colGroup.children.push(colPrintPrePress);
				colGroup.children.push(colPrintMinPrice);*/
				
				/*   HIDE AND USE 1 COL FOR ALL
				
				var colPrintColors:AdvancedDataGridColumn = new AdvancedDataGridColumn('printColors');
				colPrintColors.headerText = sColMakeReadyText;
				colPrintColors.dataField = 'customPrintColors';
				colPrintColors.editable = false;
				colPrintColors.labelFunction = colorsLabelFunc;
				colPrintColors.setStyle('textAlign','right');
				colPrintColors.minWidth = iWidth;
				colPrintColors.sortable = false;
				colPrintColors.resizable= false;
				colPrintColors.width = iWidth;
				
				var colPrintGraphics:AdvancedDataGridColumn = new AdvancedDataGridColumn('printGraphics');
				colPrintGraphics.headerText = 'graphics';
				colPrintGraphics.dataField = 'customPrintGraphics';
				colPrintGraphics.editable = false;
				colPrintGraphics.labelFunction = graphicsLabelFunc;
				colPrintGraphics.setStyle('textAlign','right');
				colPrintGraphics.minWidth = iWidth;
				colPrintGraphics.sortable = false;
				colPrintGraphics.resizable= false;
				colPrintGraphics.width = iWidth;
				
				var colPrintDigital:AdvancedDataGridColumn = new AdvancedDataGridColumn('printDigital');
				colPrintDigital.headerText = 'digital';
				colPrintDigital.dataField = 'customPrintDigital';
				colPrintDigital.editable = false;
				colPrintDigital.labelFunction = digitalLabelFunc;
				colPrintDigital.setStyle('textAlign','right');
				colPrintDigital.minWidth = iWidth;
				colPrintDigital.sortable = false;
				colPrintDigital.resizable= false;
				colPrintDigital.width = iWidth;
				**************************************************/
				var colPrintDigital:AdvancedDataGridColumn = new AdvancedDataGridColumn('printOptions');
				colPrintDigital.headerText = 'print options';
				colPrintDigital.dataField = 'customPrint';
				colPrintDigital.editable = false;
				colPrintDigital.labelFunction = custOptionsLabelFunc;
			//	colPrintDigital.setStyle('textAlign','right');
				colPrintDigital.minWidth = iWidth + 125;
				colPrintDigital.sortable = false;
				colPrintDigital.resizable= false;
				colPrintDigital.width = iWidth + 125;
				
				var colPrintMinPrice:AdvancedDataGridColumn = new AdvancedDataGridColumn('printMinPrice');
				colPrintMinPrice.headerText = 'mkRdy+plate+prePress=min';
				colPrintMinPrice.dataField = 'customPrintCharge';
				colPrintMinPrice.editable = false;
				colPrintMinPrice.labelFunction = minPriceLabelFunc;
				//colPrintMinPrice.setStyle('textAlign','right');
				colPrintMinPrice.minWidth = iWidth + 125;
				colPrintMinPrice.sortable = false;
				colPrintMinPrice.resizable= false;
				colPrintMinPrice.width = iWidth + 125;
				
			//	colGroup.children.push(colPrintColors);
			//	colGroup.children.push(colPrintGraphics);
				colGroup.children.push(colPrintDigital);
				colGroup.children.push(colPrintMinPrice);
				dispatchEvent(new Event('arrDgItemsColsChanged'));
			}
			if(comp.type == 1 && this.program.template.bCustomPrint){
				var e:SearchEvent = new SearchEvent(SearchEvent.GET_PROGRAM_PRODUCTS);
				e.userId = this.oSettings.userId;
				e.programId = this.oSettings.programId;
				e.statusFilterOn = this.oSettings.statusFilterOn;
				e.bMarketPrice = this.oSettings.bMarketPrice;
				e.templateFilterId = this.oSettings.templateFilterId;
				e.customPrint = comp.customPrint;
				e.customPrint.bCustomPrint = true;
				e.aItems = event.arr1;
				//e.aItems = comp.
				this._dispatcher.dispatchEvent(e);
			}
		}
	
		//LABEL FUNCS ********************************************
		public function rateLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			
			return _decFormat.format(item[column.dataField]['prodRate']['rate']);	
		}
		
		public function uomLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return item[column.dataField].prodRate.uom.abbreviation.toString();//'.prodRate.uom'	
		}
		
		public function rateMPLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decFormat.format(item[column.dataField]['prodRate']['rateMP']);//+'.prodRate.rateMP'	
		}
		
		public function rateConvertedLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decFormat.format(item[column.dataField]['prodRate']['rateConverted']);//+'.prodRate.rateConverted'	
		}
		
		public function rateCustConvertedLabelFunc(item:Object, column:AdvancedDataGridFilterColumn):String 
		{
			var sProp:String = column.dataFieldComplex;
			return _decFormat.format(item[column.dataField]['prodRate']['rateCustConverted_' + sProp]);
			
			//return _decFormat.format(item[column.dataField]['prodRate']['rateConverted']);//+'.prodRate.rateConverted'	
		}
		
		public function varianceMPLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decFormat.format(item[column.dataField]['prodRate']['varianceMP']);//+'.prodRate.varianceMP'	
		}
		
		public function variancePercMPLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decTwoFormat.format(item[column.dataField]['prodRate']['variancePercMP']);//+'.prodRate.variancePercMP'	
		}
		public function rateCustomerLabelFunc(item:Object, column:AdvancedDataGridFilterColumn):String 
		{
			var sProp:String = column.dataFieldComplex;
			return _decFormat.format(item[column.dataField]['prodRate']['rateCust_' + sProp]);	
		}
		
		public function custOptionsLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			var cp:CustomPrint = item['customPrint'];
			var s:String = 'color:' + item['customPrint']['iColors'];
			s = s + ' graphics:' + item['customPrint']['sGraphics'];
			
			var s2:String = 'no';
			if(item['customPrint']['bDigital']){
				s2 = 'yes';
			}
			s = s + ' digital:' + s2;
			return s;
			//return item['customPrint']['iColors'];
		}
		
		public function colorsLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return item['customPrint']['iColors'];
		}
		
		public function graphicsLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			return item['customPrint']['sGraphics'];
		}
		
		public function digitalLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			var s:String = 'no';
			if(item['customPrint']['bDigital']){
				s = 'yes';
			}	
			return s;
		}
		public function minPriceLabelFunc(item:Object, column:AdvancedDataGridColumn):String 
		{
			var cpc:CustomPrintCharge = new CustomPrintCharge();
			cpc = item['customPrintCharge'];
			var s:String = _decTwoFormat.format(cpc.printMakeReady);
			s = s + ' + ' + _decTwoFormat.format(cpc.printPlate);
			s = s + ' + ' + _decTwoFormat.format(cpc.printPrePress);
			s = s + ' = ' + _decFormat.format(cpc.printMinPrice);
			return s;
			
			//return _decTwoFormat.format(item['customPrintCharge']['printMinPrice']);
		}
		
		private function rateSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			if (obj1.hasOwnProperty(sId) && obj2.hasOwnProperty(sId)){
				if(!isNaN(obj1[sId]['prodRate']['rate'])){n1 = obj1[sId]['prodRate']['rate'];}
				if(!isNaN(obj2[sId]['prodRate']['rate'])){n2 = obj2[sId]['prodRate']['rate'];}
			}
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}

		private function uomSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;//prodRate.uom.
			var n2:Number = 0;
			if (obj1.hasOwnProperty(sId) && obj2.hasOwnProperty(sId)){
				if(!isNaN(obj1[sId]['prodRate']['uom']['uomId'])){n1 = obj1[sId]['prodRate']['uom']['uomId'];}
				if(!isNaN(obj2[sId]['prodRate']['uom']['uomId'])){n2 = obj2[sId]['prodRate']['uom']['uomId'];}
			}
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function mpRateSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			if (obj1.hasOwnProperty(sId) && obj2.hasOwnProperty(sId)){
				if(!isNaN(obj1[sId]['prodRate']['rateMP'])){n1 = obj1[sId]['prodRate']['rateMP'];}
				if(!isNaN(obj2[sId]['prodRate']['rateMP'])){n2 = obj2[sId]['prodRate']['rateMP'];}
			}
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function mpVarianceSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			if (obj1.hasOwnProperty(sId) && obj2.hasOwnProperty(sId)){
				if(!isNaN(obj1[sId]['prodRate']['varianceMP'])){n1 = obj1[sId]['prodRate']['varianceMP'];}
				if(!isNaN(obj2[sId]['prodRate']['varianceMP'])){n2 = obj2[sId]['prodRate']['varianceMP'];}
			}
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function mpPercentSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			if (obj1.hasOwnProperty(sId) && obj2.hasOwnProperty(sId)){
				if(!isNaN(obj1[sId]['prodRate']['variancePercMP'])){n1 = obj1[sId]['prodRate']['variancePercMP'];}
				if(!isNaN(obj2[sId]['prodRate']['variancePercMP'])){n2 = obj2[sId]['prodRate']['variancePercMP'];}
			}
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		///...............................old
		
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
