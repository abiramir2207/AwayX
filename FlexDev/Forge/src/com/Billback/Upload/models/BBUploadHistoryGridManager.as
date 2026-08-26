package com.Billback.Upload.models
	{
		import com.shared.components.*;
		import com.shared.components.filters.DataGridFilterColumn;
		import com.shared.components.filters.DataGridFilterColumnMultiSelect;
		import com.shared.models.GridManager;
		import com.shared.views.renderer.gridCombo;
		
		import com.Billback.Upload.views.renderer.gridLabel;
		
		import flash.events.Event;
		import flash.events.EventDispatcher;
		import flash.events.IEventDispatcher;
		
		import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
		import mx.controls.dataGridClasses.DataGridColumn;
		import mx.core.ClassFactory;
		import mx.core.IFactory;
		import mx.controls.Label;
		
		public class BBUploadHistoryGridManager  extends GridManager
		{
			/*................  Constructor  ...................*/
			private var dispatcher:IEventDispatcher;
			public function BBUploadHistoryGridManager ( dispatcher:IEventDispatcher )
			{
				super();
				this.dispatcher = dispatcher;
				this.buildGridCols();
			}
			/* arrBBUploadHistoryDgCols bound to dgItems.columns */
			private var _arrBBUploadHistoryDgCols:Array = new Array();
			[Bindable (event="arrBBUploadHistoryDgColsChanged")]
			public function get arrBBUploadHistoryDgCols():Array
			{
				return _arrBBUploadHistoryDgCols;
			}
			/*	this.itemGuid = bbProdRate.itemGuid;
			this.isSelected = bbProdRate.isSelected;
			this.itemNumber = bbProdRate.itemNumber;
			this.description = bbProdRate.description;
			this.uom = bbProdRate.uom;
			this.rate = bbProdRate.rate;
			this.volume = bbProdRate.volume;*/
			
			public function buildGridCols():void
			{
				var col:DataGridColumn;
				//var colMulti:DataGridFilterColumnMultiSelect;
				var colMulti:DataGridFilterColumn;
				/*.....	isSelected	.....................  */
				/*col = new DataGridColumn('isSelected');
				col.dataField = 'isSelected';
				col.editable = true;
				col.sortable = false;
				col.width = 40;
				col.rendererIsEditor=true;
				var cf:ClassFactory = new ClassFactory(chBoxSelectAllDg);
				col.headerRenderer = cf;
				col.itemRenderer = new ClassFactory(chBoxIsSelectedDg);
				col.editorDataField = "varCbSelected";
				_arrBBUploadHistoryDgCols.push(col);*/
				
				
				/*.....	uploadID ....................   */
				colMulti = new DataGridFilterColumn("uploadID");
				colMulti.dataField = "uploadID";
				colMulti.headerText = "ID";
				colMulti.width = .05;
				colMulti.editable = false;
 				_arrBBUploadHistoryDgCols.push(colMulti);
 				
				/*.....	userUploaded....................   */
				colMulti = new DataGridFilterColumn("userUploaded");
				colMulti.dataField = "userUploaded.fullName";
				colMulti.headerText = "User";
				colMulti.width = .08;
				//colMulti.labelFunction = labelFunc;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);				
				
				/*.....	totalHeaderCount	....................   */
				colMulti = new DataGridFilterColumn("totalHeaderCount");
				colMulti.dataField = "totalHeaderCount";
				colMulti.headerText = "Header Count";
				colMulti.width = .04;
				
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	totalHeaderCountFailed	....................   */
				colMulti = new DataGridFilterColumn("totalHeaderCountFailed");
				colMulti.dataField = "totalHeaderCountFailed";
				colMulti.headerText = "Header Failed";
				colMulti.width = .04;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	totalHeaderCountLoaded	....................   */
				colMulti = new DataGridFilterColumn("totalHeaderCountLoaded");
				colMulti.dataField = "totalHeaderCountLoaded";
				colMulti.headerText = "Header Loaded";
				colMulti.width = .04;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	totalDetailCount	....................   */
				colMulti = new DataGridFilterColumn("totalDetailCount");
				colMulti.dataField = "totalDetailCount";
				colMulti.headerText = "Detail Count";
				colMulti.width = .04;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	totalDetailCountFailed	....................   */
				colMulti = new DataGridFilterColumn("totalDetailCountFailed");
				colMulti.dataField = "totalDetailCountFailed";
				colMulti.headerText = "Detail Failed";
				colMulti.width = .04;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	totalDetailCountLoaded	....................   */
				colMulti = new DataGridFilterColumn("totalDetailCountLoaded");
				colMulti.dataField = "totalDetailCountLoaded";
				colMulti.headerText = "Detail Loaded";
				colMulti.width = .04;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	uploadStatus	....................   */
				colMulti = new DataGridFilterColumn("uploadStatus");
				colMulti.dataField = "uploadStatus";
				colMulti.headerText = "Status";
				colMulti.width = .24;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
								
				/*.....	uploadDate	....................   */
				colMulti = new DataGridFilterColumn("uploadDate");
				colMulti.dataField = "uploadDate";
				colMulti.headerText = "Upload Date";
				colMulti.labelFunction = formatDateTime;
				colMulti.width = .10;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/*.....	headerFileName	....................   */
				colMulti = new DataGridFilterColumn("headerFileName");
				colMulti.dataField = "headerFileName";
				colMulti.headerText = "File Name";
				colMulti.width = .20;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);

				/*.....	uploadType ....................   */
				colMulti = new DataGridFilterColumn("uploadType");
				colMulti.dataField = "uploadType";
				colMulti.headerText = "Type";
				colMulti.width = .08;
				colMulti.editable = false;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/***** DUMMY COLUMNS FOR FILTERING ONLY *****/
				/*.....	Vendor field  ....................   */
				colMulti = new DataGridFilterColumn("VendorSearchField");
				colMulti.dataField = "VendorSearchField";
				colMulti.headerText = "";
				colMulti.width = .0;
				colMulti.visible = false;
				colMulti.editable = false;
				colMulti.resizable = false;
				_arrBBUploadHistoryDgCols.push(colMulti);				
				/*.....	Billback Title  ....................   */				
				colMulti = new DataGridFilterColumn("BBTitleSearchField");
				colMulti.dataField = "BBTitleSearchField";
				colMulti.headerText = "";
				colMulti.width = .0;
				colMulti.visible = false;
				colMulti.editable = false;
				colMulti.resizable = false;
				_arrBBUploadHistoryDgCols.push(colMulti);
				/*.....	Billback Code  ....................   */				
				colMulti = new DataGridFilterColumn("BBCodeSearchField");
				colMulti.dataField = "BBCodeSearchField";
				colMulti.headerText = "";
				colMulti.width = .0;
				colMulti.visible = false;
				colMulti.editable = false;
				colMulti.resizable = false;
				_arrBBUploadHistoryDgCols.push(colMulti);
				
				/* Empty col so last row is not huge ....................*/
				col = new DataGridColumn("xSpace");
				col.visible = true;
				col.headerText = '';
				col.width = .01;
				col.editable = false;
				col.visible = true;
				colMulti.resizable = true;
				_arrBBUploadHistoryDgCols.push(col); 
				dispatchEvent(new Event('arrBBUploadHistoryDgColsChanged'));
			}
			
			public function uomLabelFunc(item:Object, col:DataGridColumn):String{
				return item.uom.abbreviation;
			}
			
			/*public function errLabelFunc(item:Object, col:DataGridFilterColumn):String{
			var s:String = item[col.dataField].toString();
			//col.setStyle('color','red');
			//col.setStyle('font-style','italic');
			return s;
			}*/
		}
	}