package com.shared.models
{
	import com.shared.components.StringUtils;
	import com.shared.components.chBoxIsSelected;
	import com.shared.components.chBoxSelectAll;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.formatters.NumberFormatter;
	
	public class GridManager extends EventDispatcher
	{
		
		/*-...................................... Constructor.......................................*/
		public function GridManager():void
		{
			//this._dispatcher = dispatcher;
			/* Populate the array arrDgItemsCols bound to dgItems.columns */
			//this.buildGridCols();
			/* set formatter precision */
			_decFormat.precision = 4;
			_decFormat.useNegativeSign = false;
			/* set formatter precision */
			_numFormat.precision = 0;
			_numFormat.useThousandsSeparator = false;
			_numFormat.useNegativeSign = false;
			
			_numFormatThsnd.precision = 0;
			_numFormatThsnd.useThousandsSeparator = true;
			_numFormatThsnd.useNegativeSign = false;
			_numFormatThsnd.rounding = "nearest";
			
			_dlrFormatter.precision = 2;
			_dlrFormatter.currencySymbol = '$';
			_dlrFormatter.useNegativeSign = false;
			
			_dlrFormatterDec.precision = 4;
			//_dlrFormatterDec.currencySymbol = '$';
			_dlrFormatterDec.useNegativeSign = false;
			
			_dlrFormatterDecFour.precision = 4;
			_dlrFormatterDecFour.currencySymbol = '$';
			_dlrFormatterDecFour.useNegativeSign = false;
			
			_decTwoFormat.precision = 2;
			_decTwoFormat.useNegativeSign = false;
			_decTwoFormat.rounding = "nearest";
			
			_decThreeFormat.precision = 3;
			_decThreeFormat.useNegativeSign = false;
			
			//DATE
			_dtFormatterDay.formatString 	= 'EEE, MMM. D, YYYY';
			_dtFormat.formatString 			= 'MM/DD/YYYY';
			_dtFormatDateTime.formatString 	= 'MM/DD/YYYY L:NN A';
		}
		
		/*.......................  Properties  .......................*/
		public var _numFormat:NumberFormatter =  new NumberFormatter();
		public var _numFormatThsnd:NumberFormatter =  new NumberFormatter();
		public var _decFormat:NumberFormatter =  new NumberFormatter();
		public var _decTwoFormat:NumberFormatter =  new NumberFormatter();
		public var _decThreeFormat:NumberFormatter =  new NumberFormatter();
		public var _dlrFormatter:CurrencyFormatter = new CurrencyFormatter();
		public var _dlrFormatterDec:CurrencyFormatter = new CurrencyFormatter();
		public var _dlrFormatterDecFour:CurrencyFormatter = new CurrencyFormatter();
		public var _dtFormatterDay:DateFormatter = new DateFormatter();
		public var _dtFormat:DateFormatter = new DateFormatter();
		public var _dtFormatDateTime:DateFormatter = new DateFormatter();
		/*.......................................  Properties  ......................................*/
		/* Settings Object */
		private var _oSettings:Settings = new Settings();
		[Bindable (event="gridMansettingsChanged")]
		public function get oSettings():Settings
		{
			return _oSettings;
		}
		public function set oSettings(s:Settings):void
		{
			this._oSettings = s;
			//updateGridColsHeaderText();
			dispatchEvent(new Event('gridMansettingsChanged'));
		}
		
		public function labelFunc(item:Object, col:DataGridColumn):String{
			var sLabel:String = '';
			var arr:Array;
			arr = col.dataField.toString().split(".");
			if(arr.length == 1){
				sLabel = item[arr[0]];
			}
			else if(arr.length == 2 && item[arr[0]]){
				sLabel = item[arr[0]][arr[1]];
			}
			else if(arr.length == 3 && item[arr[0]] && item[arr[1]]){
				sLabel = item[arr[0]][arr[1]][arr[2]];
			}
			return sLabel;
		}
		
		public function adgLabelFunc(item:Object, col:AdvancedDataGridColumn):String{
			var sLabel:String = '';
			var arr:Array;
			arr = col.dataField.toString().split(".");
			if(arr.length == 1){
				sLabel = item[arr[0]];
			}
			else if(arr.length == 2){
				sLabel = item[arr[0]][arr[1]];
			}
			else if(arr.length == 3){
				sLabel = item[arr[0]][arr[1]][arr[2]];
			}
			return sLabel;
		}
		
		public function labelFuncTwoDecimal(item:Object, col:DataGridColumn):String{
			var sLabel:String = '';
			var arr:Array;
			arr = col.dataField.toString().split(".");
			if(arr.length == 1){
				sLabel = item[arr[0]];
			}
			else if(arr.length == 2 && item[arr[0]]){
				sLabel = item[arr[0]][arr[1]];
			}
			else if(arr.length == 3 && item[arr[0]] && item[arr[1]]){
				sLabel = item[arr[0]][arr[1]][arr[2]];
			}
			return _decTwoFormat.format(sLabel);
		}
		
		public function adgLabelFuncTwoDecimal(item:Object, col:AdvancedDataGridColumn):String{
			var sLabel:String = '';
			var arr:Array;
			arr = col.dataField.toString().split(".");
			if(arr.length == 1){
				sLabel = item[arr[0]];
			}
			else if(arr.length == 2){
				sLabel = item[arr[0]][arr[1]];
			}
			else if(arr.length == 3){
				sLabel = item[arr[0]][arr[1]][arr[2]];
			}
			return _decTwoFormat.format(sLabel);
		}
		
		public function formatDecimal(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decFormat.format(item[column.dataField]);
		}
		public function formatTwoDecimal(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _decTwoFormat.format(StringUtils.roundDec(item[column.dataField],2));
		}
		public function formatNumber(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _numFormat.format(item[column.dataField]);
		}
		public function formatNumberThsnd(item:Object, column:AdvancedDataGridColumn):String 
		{
			return _numFormatThsnd.format(item[column.dataField]);
		}
		public function formatDollar(item:Object, column:AdvancedDataGridColumn):String 
		{
			return this._dlrFormatter.format(item[column.dataField]);
			
		}
		public function formatDollarDec(item:Object, column:AdvancedDataGridColumn):String 
		{
			return this._dlrFormatterDec.format(item[column.dataField]);
			
		}	
		public function formatDollarDecFour(item:Object, column:AdvancedDataGridColumn):String 
		{
			return this._dlrFormatterDecFour.format(item[column.dataField]);
			
		}
		public function formatDt(item:Object, column:AdvancedDataGridColumn):String
		{   
			return _dtFormat.format(item[column.dataField]);
		}
		public function formatDateDay(item:Object, column:AdvancedDataGridColumn):String 
		{
			return this._dtFormatterDay.format(item[column.dataField]);
			
		}
		public function adgFormatDateTime(item:Object, column:AdvancedDataGridColumn):String 
		{
			return this._dtFormatDateTime.format(item[column.dataField]);
			
		}
		
		public function formatDateTime(item:Object, column:DataGridColumn):String 
		{
			return this._dtFormatDateTime.format(item[column.dataField]);
			
		}
		
		public function formatDtDg(item:Object, column:DataGridColumn):String
		{   
			return _dtFormat.format(item[column.dataField]);
		}
		
	}
}