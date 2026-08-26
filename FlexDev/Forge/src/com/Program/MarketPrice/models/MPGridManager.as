package com.Program.MarketPrice.models
{
	import com.shared.models.GridManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	
	public class MPGridManager extends GridManager
	{
		private var dispatcher:IEventDispatcher;
		public function MPGridManager( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
		}
		/* arrDgItemsCols bound to dgItems.columns */
		private var _arrDgItemsCols:Array = new Array();
		[Bindable (event="arrDgItemsColsChanged")]
		public function get arrDgItemsCols():Array
		{
			return _arrDgItemsCols;
		}
		/* build arrDgItemsCols which is boound to dgItems.columns in the view.  Should make this dynamic...poulate it from a vos with static vars*/
		public function buildGridCols():void
		{
			/*.....	baItem	.....  */
			var col:AdvancedDataGridColumn = new AdvancedDataGridColumn("baItem");
			col.dataField = "itemNumber";
			col.headerText = "item";
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	Description	.....  */
			col = new AdvancedDataGridColumn("Description");
			col.dataField = "description";
			col.headerText = "description";
			col.width = 275;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	UOM	.....  */
			col = new AdvancedDataGridColumn("UOM");
			col.dataField = "uom.abbreviation";
			col.headerText = "uom";
			col.labelFunction = uomLabelFunc;
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	Rate	.....  */
			col = new AdvancedDataGridColumn("Rate");
			col.dataField = "rate";
			col.headerText = "rate";
			col.labelFunction = formatDollarDecFour;
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	Rate MP	.....  */
			col = new AdvancedDataGridColumn("rateMPCS");
			col.dataField = "rateMPCS";
			col.headerText = "MP/CS";
			col.labelFunction = formatDollarDecFour;
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	Rate MP/LB	.....  */
			col = new AdvancedDataGridColumn("rateMPLB");
			col.dataField = "rateMPLB";
			col.headerText = "MP/LB";
			col.labelFunction = formatDollarDecFour;
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	Rate MP	Variance.....  */
			col = new AdvancedDataGridColumn("rateVarianceMP");
			col.dataField = "varianceMP";
			col.headerText = "MP var.";
			col.labelFunction = formatDollarDecFour;
			col.width = 150;
			col.editable = false;
			_arrDgItemsCols.push(col);
			/*.....	Rate MP Perc Variance	.....  */
			col = new AdvancedDataGridColumn("rateVarPercMP");
			col.dataField = "variancePercMP";
			col.headerText = "MP % var.";
			col.labelFunction = rateVarPercLabelFunc;
			col.width = 150;
			col.editable = false;
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
		
		public function uomLabelFunc(item:Object, col:AdvancedDataGridColumn):String{
			return item.uom.abbreviation;
		}
		
		public function rateVarLabelFunc(item:Object, col:AdvancedDataGridColumn):String{
			return _decFormat.format(item.rateMP - item.rate);
		}
		
		public function rateVarPercLabelFunc(item:Object, col:AdvancedDataGridColumn):String{
			if(item.rateMP){
				return _decTwoFormat.format((item.rateMP - item.rate)/item.rateMP*100).toString() + '%';
			}
			else{
				return _decTwoFormat.format(0).toString() + '%';
			}
			
		}
	}
}