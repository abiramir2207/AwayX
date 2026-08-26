package com.Program.Fitness.models
{
	import com.shared.components.filters.AdvancedDataGridFilterColumn;
	import com.shared.components.filters.DataGridFilterColumn;
	import com.shared.models.GridManager;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;

	
	public class FitnessItemsGridManager  extends GridManager
	{
		/*................  Constructor  ...................*/
		private var dispatcher:IEventDispatcher;
		public function FitnessItemsGridManager ( dispatcher:IEventDispatcher )
		{
			super();
			this.dispatcher = dispatcher;
			this.buildGridCols();
			this.buildGridTotalCols();
		}
		
		
		[Bindable] public var colPlain:AdvancedDataGridColumn;
		[Bindable] public var colFilteritem:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("item");
		[Bindable] public var colFilterdescription:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("description");
		[Bindable] public var colFilterqBrand:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("qBrand");
		[Bindable] public var colFilterprodVarA:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("prodVarA");
		[Bindable] public var colFiltertypeCodeDesc:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("typeCodeDesc");
		[Bindable] public var colFiltersigLabel:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("sigLabel");
		[Bindable] public var colFiltereligibility:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("eligibility");
		
		
		[Bindable] public var colYago:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("yago");
		[Bindable] public var colRev:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("revenue");
		[Bindable] public var colCase:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("cases");
		[Bindable] public var colLb:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("lbs");
		[Bindable] public var colYagoNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("yagoNon");
		[Bindable] public var colRevNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("RevenueNon");
		[Bindable] public var colCaseNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("casesNon");
		[Bindable] public var colLbNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("lbsNon");
		
		/* arrFitnessItemsDgCols bound to dgItems.columns */
		private var _arrFitnessItemsDgCols:Array = new Array();
		[Bindable (event="arrFitnessItemsDgColsChanged")]
		public function get arrFitnessItemsDgCols():Array
		{
			return _arrFitnessItemsDgCols;
		}
		/* arrFitnessTotalsDgCols bound to dgTotals.columns */
		private var _arrFitnessTotalsDgCols:Array = new Array();
		[Bindable (event="arrFitnessTotalsDgColsChanged")]
		public function get arrFitnessTotalsDgCols():Array
		{
			return _arrFitnessTotalsDgCols;
		}
		/*.................oSettings......................*/
		/* Settings Object */
		private var _oSettings2:Settings = new Settings();
		[Bindable (event="gridMansettingsChanged2")]
		public function get oSettings2():Settings
		{
			return _oSettings2;
		}
		public function set oSettings2(s:Settings):void
		{
			this._oSettings2 = s;
			if(s.qBrand != ''){
				colFilterqBrand.headerText = s.qBrand;
				colFilterprodVarA.headerText = s.appSettings.Prod_Var_A;
				colFiltertypeCodeDesc.headerText = s.typeCode;
			}
			//updateGridColsHeaderText();
			dispatchEvent(new Event('gridMansettingsChanged2'));
		}
	/*	this.itemGuid = bbProdRate.itemGuid;
		this.isSelected = bbProdRate.isSelected;
		this.itemNumber = bbProdRate.itemNumber;
		this.description = bbProdRate.description;
		this.uom = bbProdRate.uom;
		this.rate = bbProdRate.rate;
		this.volume = bbProdRate.volume;*/
		
		public function resize(e:Event):void
		{
			var x:Event = e;
		}

		public function buildGridCols():void
		{
			//var col:DataGridFilterColumn;
			//var colPlain:DataGridColumn;
			//var colPlain:AdvancedDataGridColumn;
			//var colFilter:AdvancedDataGridFilterColumn;
			/* column group Eligible*/
			var colGroup:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
			colGroup.headerText = 'Eligible';
			//colGroup.width = 400;
			
			/* column group NON-Eligible */
			var colGroupNon:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
			colGroupNon.headerText = 'Non-Eligible';
			//colGroupNon.width = 400;
			
			/*.....	baItem	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("item");
			//col = new AdvancedDataGridColumn("baItem");
			colFilteritem.dataField = "item";
			colFilteritem.headerText = "Item";
			colFilteritem.visible = true;//NEED TO MAKE DYNAMIC
			colFilteritem.width = 75;
			colFilteritem.editable = false;
			colFilteritem.editVisible = false;
			colFilteritem.filterVisible = true;
			_arrFitnessItemsDgCols.push(colFilteritem);
			/*.....	Description	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("description");
			colFilterdescription.dataField = "description";
			colFilterdescription.headerText = "Description";
			colFilterdescription.visible = true;//NEED TO MAKE DYNAMIC
			colFilterdescription.width = 175;
			colFilterdescription.editable = false;
			colFilterdescription.editVisible = false;
			colFilterdescription.filterVisible = true;
			_arrFitnessItemsDgCols.push(colFilterdescription);
			
			/*.....	qBrand	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("qBrand");
			colFilterqBrand.dataField = "qBrand";
			colFilterqBrand.headerText = this.oSettings.qBrand;
			colFilterqBrand.visible = false;//NEED TO MAKE DYNAMIC
			colFilterqBrand.width = 75;
			colFilterqBrand.editable = false;
			colFilterqBrand.editVisible = false;
			colFilterqBrand.filterVisible = true;
			colFilterqBrand.filterComboVisible = true;
			//colFilterqBrand.addEventListener(Event.RESIZE,this.resize);
			_arrFitnessItemsDgCols.push(colFilterqBrand);
			
			/*.....	prodVarA	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("prodVarA");
			colFilterprodVarA.dataField = "prodVarA";
			colFilterprodVarA.headerText = this.oSettings.appSettings.Prod_Var_A;
			colFilterprodVarA.visible = false;//NEED TO MAKE DYNAMIC
			colFilterprodVarA.width = 150;
			colFilterprodVarA.editable = false;
			colFilterprodVarA.editVisible = false;
			colFilterprodVarA.filterVisible = true;
			colFilterprodVarA.filterComboVisible = true;
			_arrFitnessItemsDgCols.push(colFilterprodVarA);
			
			/*.....	typeCodeDesc	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("typeCodeDesc");
			colFiltertypeCodeDesc.dataField = "typeCodeDesc";
			colFiltertypeCodeDesc.headerText = this.oSettings.typeCode;
			colFiltertypeCodeDesc.visible = false;//NEED TO MAKE DYNAMIC
			colFiltertypeCodeDesc.width = 150;
			colFiltertypeCodeDesc.editable = false;
			colFiltertypeCodeDesc.editVisible = false;
			colFiltertypeCodeDesc.filterVisible = true;
			colFiltertypeCodeDesc.filterComboVisible = true;
			_arrFitnessItemsDgCols.push(colFiltertypeCodeDesc);
			
			
			/*.....	SigLabel	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("sigLabel");
			colFiltersigLabel.dataField = "sigLabel";
			colFiltersigLabel.headerText = "Private Label";
			colFiltersigLabel.visible = true;//NEED TO MAKE DYNAMIC
			colFiltersigLabel.width = 50;
			colFiltersigLabel.editable = false;
			colFiltersigLabel.editVisible = false;
			colFiltersigLabel.filterVisible = false;
			colFiltersigLabel.filterComboVisible = true;
			_arrFitnessItemsDgCols.push(colFiltersigLabel);
			
			/*.....	Eligibility	.....  */
			//colFilter = new AdvancedDataGridFilterColumn("eligibility");
			colFiltereligibility.dataField = "eligibility";
			colFiltereligibility.headerText = "Eligibility";
			colFiltereligibility.visible = true;//NEED TO MAKE DYNAMIC
			colFiltereligibility.width = 50;
			colFiltereligibility.editable = false;
			colFiltereligibility.editVisible = false;
			colFiltereligibility.filterVisible = false;
			colFiltereligibility.filterComboVisible = true;
			_arrFitnessItemsDgCols.push(colFiltereligibility);
			
			/*..........................................................................*/
			/*....................   ELIGIBILE GROUP   .................................*/
			/*.....	YAGORevenue	.....  */
			//var colYago:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("yago");
			colYago.dataField = "yago";
			colYago.headerText = "YAG Rev";
			colYago.visible = true;//NEED TO MAKE DYNAMIC formatDollarDec
			colYago.width = 65;
			colYago.editable = false;
			colYago.editVisible = false;
			colYago.filterVisible = false;
			colYago.labelFunction = formatDollar;
			colYago.setStyle('textAlign','right');
			colYago.sortCompareFunction = yagoSortFunc;
			
			/*.....	Revenue	.....  */
			//var colRev:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("revenue");
			colRev.dataField = "revenue";
			colRev.headerText = "Revenue";
			colRev.visible = true;//NEED TO MAKE DYNAMIC
			colRev.width = 65;
			colRev.editable = false;
			colRev.editVisible = false;
			colRev.filterVisible = false;
			colRev.labelFunction = formatDollar;
			colRev.setStyle('textAlign','right');
			colRev.sortCompareFunction = revenueSortFunc;
			
			/*.....	Case	.....  */
			//var colCase:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("cases");
			colCase.dataField = "cases";
			colCase.headerText = "Cs";
			colCase.visible = true;//NEED TO MAKE DYNAMIC
			colCase.width = 35;
			colCase.editable = false;
			colCase.editVisible = false;
			colCase.filterVisible = false;
			colCase.labelFunction = formatNumberThsnd;
			colCase.setStyle('textAlign','right');
			colCase.sortCompareFunction = casesSortFunc;
			
			/*.....	LB	.....  */
			//var colLb:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("lbs");
			colLb.dataField = "lbs";
			colLb.headerText = "Lbs";
			colLb.visible = true;//NEED TO MAKE DYNAMIC
			colLb.width = 55;
			colLb.editable = false;
			colLb.editVisible = false;
			colLb.filterVisible = false;
			colLb.labelFunction = formatNumberThsnd;
			colLb.setStyle('textAlign','right');
			colLb.sortCompareFunction = lbsSortFunc;
			
			/*...POPULATE GROUP...*/
			colGroup.children.push(colYago);
			colGroup.children.push(colRev);
			colGroup.children.push(colCase);
			colGroup.children.push(colLb);
			
			/*..........................................................................*/
			/*....................   NON ELIGIBILE GROUP   .................................*/
			/*.....	YAGORevenue	.....  */
			//var colYagoNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("yagoNon");
			colYagoNon.dataField = "yagoNon";
			colYagoNon.headerText = "YAG Rev";
			colYagoNon.visible = true;//NEED TO MAKE DYNAMIC
			colYagoNon.width = 65;
			colYagoNon.editable = false;
			colYagoNon.editVisible = false;
			colYagoNon.filterVisible = false;
			colYagoNon.labelFunction = formatDollar;
			colYagoNon.setStyle('textAlign','right');
			colYagoNon.sortCompareFunction = yagoNonSortFunc;
			
			/*.....	Revenue	.....  */
			//var colRevNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("RevenueNon");
			colRevNon.dataField = "revenueNon";
			colRevNon.headerText = "Revenue";
			colRevNon.visible = true;//NEED TO MAKE DYNAMIC
			colRevNon.width = 65;
			colRevNon.editable = false;
			colRevNon.editVisible = false;
			colRevNon.filterVisible = false;
			colRevNon.labelFunction = formatDollar;
			colRevNon.setStyle('textAlign','right');
			colRevNon.sortCompareFunction = revenueNonSortFunc;
			
			/*.....	Case	.....  */
			//var colCaseNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("casesNon");
			colCaseNon.dataField = "casesNon";
			colCaseNon.headerText = "Cs";
			colCaseNon.visible = true;//NEED TO MAKE DYNAMIC
			colCaseNon.width = 35;
			colCaseNon.editable = false;
			colCaseNon.editVisible = false;
			colCaseNon.filterVisible = false;
			colCaseNon.labelFunction = formatNumberThsnd;
			colCaseNon.setStyle('textAlign','right');
			colCaseNon.sortCompareFunction = casesNonSortFunc;
			
			/*.....	LB	.....  */
			//var colLbNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("lbsNon");
			colLbNon.dataField = "lbsNon";
			colLbNon.headerText = "Lbs";
			colLbNon.visible = true;//NEED TO MAKE DYNAMIC
			colLbNon.width = 55;
			colLbNon.editable = false;
			colLbNon.editVisible = false;
			colLbNon.filterVisible = false;
			colLbNon.labelFunction = formatNumberThsnd;
			colLbNon.setStyle('textAlign','right');
			colLbNon.sortCompareFunction = lbsNonSortFunc;
			
			/*...POPULATE GROUP...*/
			colGroupNon.children.push(colYagoNon);
			colGroupNon.children.push(colRevNon);
			colGroupNon.children.push(colCaseNon);
			colGroupNon.children.push(colLbNon);
			
			/*..........................................................................*/
			/*..........................................................................*/
			//colGroupNon.width = 400;
			//colGroup.width = 400;
			_arrFitnessItemsDgCols.push(colGroup); 
			_arrFitnessItemsDgCols.push(colGroupNon); 
			
			/* Empty col so last row is not huge ....................*/
			colPlain = new AdvancedDataGridColumn("xSpace");
			colPlain.visible = true;
			colPlain.headerText = '';
			colPlain.width = .99;
			colPlain.editable = false;
			colPlain.visible = true;
			_arrFitnessItemsDgCols.push(colPlain); 
			dispatchEvent(new Event('arrFitnessItemsDgColsChanged'));
		}
		
		public function buildGridTotalCols():void
		{
			//var col:DataGridFilterColumn;
			//var colPlain:DataGridColumn;
			var colPlain:AdvancedDataGridColumn;
			var colFilter:AdvancedDataGridFilterColumn;
			/* column group Eligible*/
			var colGroupTotal:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
			colGroupTotal.headerText = 'Eligible';
			//colGroupTotal.width = 400;
			
			/* column group NON-Eligible */
			var colGroupTotalNon:AdvancedDataGridColumnGroup = new AdvancedDataGridColumnGroup();
			colGroupTotalNon.headerText = 'Non-Eligible';
			//colGroupTotalNon.width = 400;
			
			/*.....	baItem	.....  */
			colFilter = new AdvancedDataGridFilterColumn("item");
			//col = new AdvancedDataGridColumn("baItem");
			colFilter.dataField = "item";
			colFilter.headerText = "Item";
			colFilter.visible = true;//NEED TO MAKE DYNAMIC
			colFilter.width = 75;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			_arrFitnessTotalsDgCols.push(colFilter);
			/*.....	Description	.....  */
			colFilter = new AdvancedDataGridFilterColumn("description");
			colFilter.dataField = "description";
			colFilter.headerText = "Description";
			colFilter.visible = true;//NEED TO MAKE DYNAMIC
			colFilter.width = 175;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			_arrFitnessTotalsDgCols.push(colFilter);
			
			/*.....	qBrand	.....  */
			colFilter = new AdvancedDataGridFilterColumn("qBrand");
			colFilter.dataField = "qBrand";
			colFilter.headerText = "Category";
			colFilter.visible = false;//NEED TO MAKE DYNAMIC
			colFilter.width = 75;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			colFilter.filterComboVisible = false;
			_arrFitnessTotalsDgCols.push(colFilter);
			
			/*.....	prodVarA	.....  */
			colFilter = new AdvancedDataGridFilterColumn("prodVarA");
			colFilter.dataField = "prodVarA";
			colFilter.headerText = "Family";
			colFilter.visible = false;//NEED TO MAKE DYNAMIC
			colFilter.width = 150;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			colFilter.filterComboVisible = false;
			_arrFitnessTotalsDgCols.push(colFilter);
			
			/*.....	typeCodeDesc	.....  */
			colFilter = new AdvancedDataGridFilterColumn("typeCodeDesc");
			colFilter.dataField = "typeCodeDesc";
			colFilter.headerText = "FPL";
			colFilter.visible = false;//NEED TO MAKE DYNAMIC
			colFilter.width = 150;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			colFilter.filterComboVisible = false;
			_arrFitnessTotalsDgCols.push(colFilter);
			
			
			/*.....	SigLabel	.....  */
			colFilter = new AdvancedDataGridFilterColumn("sigLabel");
			colFilter.dataField = "sigLabel";
			colFilter.headerText = "Private Label";
			colFilter.visible = true;//NEED TO MAKE DYNAMIC
			colFilter.width = 50;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			colFilter.filterComboVisible = false;
			_arrFitnessTotalsDgCols.push(colFilter);
			
			/*.....	Eligibility	.....  */
			colFilter = new AdvancedDataGridFilterColumn("eligibility");
			colFilter.dataField = "eligibility";
			colFilter.headerText = "Eligibility";
			colFilter.visible = true;//NEED TO MAKE DYNAMIC
			colFilter.width = 50;
			colFilter.editable = false;
			colFilter.editVisible = false;
			colFilter.filterVisible = false;
			colFilter.filterComboVisible = false;
			colFilter.labelFunction =  formatNumberThsnd;
			_arrFitnessTotalsDgCols.push(colFilter);
			
			/*..........................................................................*/
			/*....................   ELIGIBILE GROUP   .................................*/
			/*.....	YAGORevenue	.....  */
			var colYago:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("yago");
			colYago.dataField = "yago";
			colYago.headerText = "YAG Rev";
			colYago.visible = true;//NEED TO MAKE DYNAMIC formatDollarDec
			colYago.width = 65;
			colYago.editable = false;
			colYago.editVisible = false;
			colYago.filterVisible = false;
			colYago.labelFunction = formatDollar;
			colYago.setStyle('textAlign','right');
			colYago.sortCompareFunction = yagoSortFunc;
			
			/*.....	Revenue	.....  */
			var colRev:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("revenue");
			colRev.dataField = "revenue";
			colRev.headerText = "Revenue";
			colRev.visible = true;//NEED TO MAKE DYNAMIC
			colRev.width = 65;
			colRev.editable = false;
			colRev.editVisible = false;
			colRev.filterVisible = false;
			colRev.labelFunction = formatDollar;
			colRev.setStyle('textAlign','right');
			colRev.sortCompareFunction = revenueSortFunc;
			
			/*.....	Case	.....  */
			var colCase:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("cases");
			colCase.dataField = "cases";
			colCase.headerText = "Cases";
			colCase.visible = true;//NEED TO MAKE DYNAMIC
			colCase.width = 35;
			colCase.editable = false;
			colCase.editVisible = false;
			colCase.filterVisible = false;
			colCase.labelFunction = formatNumberThsnd;
			colCase.setStyle('textAlign','right');
			colCase.sortCompareFunction = casesSortFunc;
			
			/*.....	LB	.....  */
			var colLb:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("lbs");
			colLb.dataField = "lbs";
			colLb.headerText = "Lbs";
			colLb.visible = true;//NEED TO MAKE DYNAMIC
			colLb.width = 55;
			colLb.editable = false;
			colLb.editVisible = false;
			colLb.filterVisible = false;
			colLb.labelFunction = formatNumberThsnd;
			colLb.setStyle('textAlign','right');
			colLb.sortCompareFunction = lbsSortFunc;
			
			/*...POPULATE GROUP...*/
			colGroupTotal.children.push(colYago);
			colGroupTotal.children.push(colRev);
			colGroupTotal.children.push(colCase);
			colGroupTotal.children.push(colLb);
			
			/*..........................................................................*/
			/*....................   NON ELIGIBILE GROUP   .................................*/
			/*.....	YAGORevenue	.....  */
			var colYagoNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("yagoNon");
			colYagoNon.dataField = "yagoNon";
			colYagoNon.headerText = "YAG Rev";
			colYagoNon.visible = true;//NEED TO MAKE DYNAMIC
			colYagoNon.width = 65;
			colYagoNon.editable = false;
			colYagoNon.editVisible = false;
			colYagoNon.filterVisible = false;
			colYagoNon.labelFunction = formatDollar;
			colYagoNon.setStyle('textAlign','right');
			colYagoNon.sortCompareFunction = yagoNonSortFunc;
			
			/*.....	Revenue	.....  */
			var colRevNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("RevenueNon");
			colRevNon.dataField = "revenueNon";
			colRevNon.headerText = "Revenue";
			colRevNon.visible = true;//NEED TO MAKE DYNAMIC
			colRevNon.width = 65;
			colRevNon.editable = false;
			colRevNon.editVisible = false;
			colRevNon.filterVisible = false;
			colRevNon.labelFunction = formatDollar;
			colRevNon.setStyle('textAlign','right');
			colRevNon.sortCompareFunction = revenueNonSortFunc;
			
			/*.....	Case	.....  */
			var colCaseNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("casesNon");
			colCaseNon.dataField = "casesNon";
			colCaseNon.headerText = "CS";
			colCaseNon.visible = true;//NEED TO MAKE DYNAMIC
			colCaseNon.width = 35;
			colCaseNon.editable = false;
			colCaseNon.editVisible = false;
			colCaseNon.filterVisible = false;
			colCaseNon.labelFunction = formatNumberThsnd;
			colCaseNon.setStyle('textAlign','right');
			colCaseNon.sortCompareFunction = casesNonSortFunc;
			
			/*.....	LB	.....  */
			var colLbNon:AdvancedDataGridFilterColumn = new AdvancedDataGridFilterColumn("lbsNon");
			colLbNon.dataField = "lbsNon";
			colLbNon.headerText = "Lbs";
			colLbNon.visible = true;//NEED TO MAKE DYNAMIC
			colLbNon.width = 65;
			colLbNon.editable = false;
			colLbNon.editVisible = false;
			colLbNon.filterVisible = false;
			colLbNon.labelFunction = formatNumberThsnd;
			colLbNon.setStyle('textAlign','right');
			colLbNon.sortCompareFunction = lbsNonSortFunc;
			
			/*...POPULATE GROUP...*/
			colGroupTotalNon.children.push(colYagoNon);
			colGroupTotalNon.children.push(colRevNon);
			colGroupTotalNon.children.push(colCaseNon);
			colGroupTotalNon.children.push(colLbNon);
			
			/*..........................................................................*/
			/*..........................................................................*/
			//colGroupTotalNon.width = 400;
			//colGroupTotal.width = 400;
			_arrFitnessTotalsDgCols.push(colGroupTotal); 
			_arrFitnessTotalsDgCols.push(colGroupTotalNon); 
			
			/* Empty col so last row is not huge ....................*/
			colPlain = new AdvancedDataGridColumn("xSpace");
			colPlain.visible = true;
			colPlain.headerText = '';
			colPlain.width = .99;
			colPlain.editable = false;
			colPlain.visible = true;
			_arrFitnessTotalsDgCols.push(colPlain); 
			dispatchEvent(new Event('arrFitnessTotalsDgColsChanged'));
		}
		
		public function uomLabelFunc(item:Object, col:DataGridFilterColumn):String{
			return item.uom.abbreviation;
		}
		
		private function yagoSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['yago'])){n1 = obj1['yago'];}
			if(!isNaN(obj2['yago'])){n2 = obj2['yago'];}
		
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function revenueSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['revenue'])){n1 = obj1['revenue'];}
			if(!isNaN(obj2['revenue'])){n2 = obj2['revenue'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function casesSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['cases'])){n1 = obj1['cases'];}
			if(!isNaN(obj2['cases'])){n2 = obj2['cases'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function lbsSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['lbs'])){n1 = obj1['lbs'];}
			if(!isNaN(obj2['lbs'])){n2 = obj2['lbs'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		/*.......   NON  .......*/
		private function yagoNonSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['yagoNon'])){n1 = obj1['yagoNon'];}
			if(!isNaN(obj2['yagoNon'])){n2 = obj2['yagoNon'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function revenueNonSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['revenueNon'])){n1 = obj1['revenueNon'];}
			if(!isNaN(obj2['revenueNon'])){n2 = obj2['revenueNon'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function casesNonSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['casesNon'])){n1 = obj1['casesNon'];}
			if(!isNaN(obj2['casesNon'])){n2 = obj2['casesNon'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
		private function lbsNonSortFunc(obj1:Object, obj2:Object):int{
			var i:int=0;
			var n1:Number = 0;
			var n2:Number = 0;
			
			if(!isNaN(obj1['lbsNon'])){n1 = obj1['lbsNon'];}
			if(!isNaN(obj2['lbsNon'])){n2 = obj2['lbsNon'];}
			
			//comparison logic
			i = n1 > n2?1:(n1 < n2?-1:0);
			return i;
		}
		
	}
}