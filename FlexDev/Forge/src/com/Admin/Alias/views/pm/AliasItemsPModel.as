package com.Admin.Alias.views.pm
{
	import com.Admin.Alias.events.AliasEvent;
	import com.Admin.Alias.models.vos.AliasDef;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.DataGridEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.utils.ObjectUtil;
	
	import spark.components.DataGrid;
	

	public class AliasItemsPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function AliasItemsPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var userId:String;
		[Bindable]
		public var aliasSourceType:int;
		[Bindable]
		public var aliasSourceID:String = new String();
		[Bindable]
		public var aliasSelectedDef:AliasDef = new AliasDef();
		[Bindable]
		public var aliasCurrentSelectedDef:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var aliasDistributorsDef:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var aliasItemsDef:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var aliasProgramsDef:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var aliasOperatorsDef:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var gridType:String;	
		[Bindable]
		public var labelText1:String = new String();		
		//[Bindable]
		//public var arrAliasItemsDgCols:Array = new Array();	
		
		private var _arrAliasItemsDgCols:Array = new Array();
		[Bindable (event="arrAliasItemsDgColsChanged")]
		public function get arrAliasItemsDgCols():Array
		{
			return _arrAliasItemsDgCols;
		}
		public function set arrAliasItemsDgCols(arr:Array):void
		{
			this._arrAliasItemsDgCols = arr;
			dispatchEvent(new Event('arrAliasItemsDgColsChanged'));
		}
		//[Bindable]
		//public var arrAliasDgCols:Array = new Array();
		//[Bindable]
		//public var arrAliasProgramsDgCols:Array = new Array();
		[Bindable]
		public var dataProviderType:int;	
		[Bindable]
		public var showUnassigned:Boolean = false;
		[Bindable]
		public var showIgnore:Boolean = false
		
		/* Set AliasDef to the selected Alias Record */	
		public function selectAliasDef(aliasDef:AliasDef):void{					
			var eventSetSelectedAlias:AliasEvent = new AliasEvent(AliasEvent.SET_SELECTED_ALIAS);
			eventSetSelectedAlias.aliasDef = aliasDef;
			this._dispatcher.dispatchEvent(eventSetSelectedAlias);
		}
		
		/* Call event to set AliasDef to "new AliasDef()" */
		public function resetSelectedAlias():void{					
			var eventResetAliasSelected:AliasEvent = new AliasEvent(AliasEvent.RESET_ALIAS_SELECTED);
			this._dispatcher.dispatchEvent(eventResetAliasSelected);				
		}
		
		/* Save the Alias - Edit or Save a new one */
		public function saveSelectedAlias(entityType:int):void{	
			var errMessage:String;		
			
			var eventSaveAlias:AliasEvent = new AliasEvent(AliasEvent.SAVE_ALIAS);

			/* These ones one (sourceType and sourceID) has already been set in "AliasPModel" and so we are just using it, i.e. setting the sourceID property of 
			   "aliasSelectedDef" to aliasSourceID and setting the sourceType property of "aliasSelectedDef" to aliasSourceType.
			 */
			//aliasSelectedDef.sourceType = aliasSourceType;
			//aliasSelectedDef.sourceID = aliasSourceID;		
			
			//eventSaveDistributorAlias.iSourceType = sourceType;
			/* Now set the other properties - AliasID, AliasDesc, Distributor ID and Distributor Desc */
			eventSaveAlias.aliasDef = aliasSelectedDef;
			
			eventSaveAlias.iEntityType = entityType;
			
			eventSaveAlias.userId = userId;

			eventSaveAlias.aliasDef.sourceType = aliasSourceType;
			eventSaveAlias.aliasDef.sourceID = aliasSourceID;
			
			/* Make sure the field values are entered. (Do not check for "entityDesc" here as they do not have to enter this value. This value
			   is automatically populated on entering a valid shipTo.
			*/	
			if(aliasSourceType < 1 || aliasSelectedDef.aliasID == '' || aliasSelectedDef.aliasDesc == '' || (aliasSelectedDef.entityID == '' && aliasSelectedDef.Unknown == false)){
				errMessage = 'These fields are required:'
			}	
			/* If a source is not selected. For payee Aliases, a payee should be selected */
			if(aliasSourceType < 1){
				errMessage  = errMessage + '\n' + 'Source';
			}
			if(aliasSelectedDef.aliasID == ''){
				errMessage = errMessage + '\n' + 'Alias ID';				
			}

			if(aliasSelectedDef.entityID == '' && aliasSelectedDef.Unknown == false){
				errMessage = errMessage + '\n' + 'Entity ID';				
			}					
			if(aliasSourceType < 1 || aliasSelectedDef.aliasID == '' || (aliasSelectedDef.entityID == '' && aliasSelectedDef.Unknown == false)){
				Alert.show(errMessage);
			}
			
			/* Now check for a valid entity Description. Above we are not checking for a valid entityID, we are just looking for a value in EntityID field.
			   Since the description here is not populated, we know that it is not a valid entityID.
			 */
			/* "aliasSelectedDef.entityDesc" is automatically populated when "aliasSelectedDef.entityID" is valid (valid entity) */
			else if(aliasSelectedDef.entityDesc == '' && aliasSelectedDef.Unknown == false){
				Alert.show("Please enter a valid entity ID");
			}
			else{
				this._dispatcher.dispatchEvent(eventSaveAlias);	
			}			
		}	
		
		/* Update "aliasID" property of the "aliasSelectedDef" object */
		public function updateAliasID(aliasID:String):void{
				aliasSelectedDef.aliasID = aliasID;
		}
		
		/* Update "aliasDesc" property of the "aliasSelectedDef" object */
		public function updateAliasDesc(aliasDesc:String):void{
			aliasSelectedDef.aliasDesc = aliasDesc;
		}
		
		/* Update "aliasUnipro" property of the "aliasSelectedDef" object */
		public function updateAliasUniproNum(aliasUniproNum:String):void{
			aliasSelectedDef.aliasUniproNum = aliasUniproNum;
		}
		
		/* Update "aliasLoc" property of the "aliasSelectedDef" object */
		public function updateAliasLoc(aliasLoc:String):void{
			aliasSelectedDef.aliasLoc = aliasLoc;
		}
		
		public function updatePayeeID(payeeID:String):void{
			aliasSelectedDef.payeeID = payeeID;
		}
		
		public function updateUnknown(unknown:Boolean):void{
			aliasSelectedDef.Unknown = unknown;
		}
		/* Update "entityID" property of the "aliasSelectedDef" object */
		public function updateID(ID:String):void{
		/* 	When a user clicks on reset (Alias info), and then tabs through to the grid, "aliasSelectedDef" does not exist, as 
			on grid's "focusIn" event, we set "aliasSelectedDef" and then call this function even before  "aliasSelectedDef" is set */
			if(aliasSelectedDef){
				aliasSelectedDef.entityID = ID;
			}
		}
		
		/* Update "entityDesc" property of the "aliasSelectedDef" object */
		public function updateDesc(Desc:String):void{
			aliasSelectedDef.entityDesc = Desc;
		}
		
		/* Get distributor description when the user enters the distributor ID manually */
		public function getDesc(ID:String):void{
			/* distributor */
			if(dataProviderType == 0){
				var eventGetDistributorInfo:AliasEvent = new AliasEvent(AliasEvent.GET_DISTRIBUTOR_INFO);
				eventGetDistributorInfo.sDistributorID = ID;
				eventGetDistributorInfo.bIsDistGUID = false;
				this._dispatcher.dispatchEvent(eventGetDistributorInfo);
			}
			/* item */
			else if(dataProviderType == 1){	
				var eventGetItemInfo:AliasEvent = new AliasEvent(AliasEvent.GET_ITEM_INFO);
				eventGetItemInfo.sItemID = ID;
				eventGetItemInfo.bIsItemGUID = false;
				this._dispatcher.dispatchEvent(eventGetItemInfo);
			}
			/* program */
			else if(dataProviderType == 2){	
				var eventGetProgramInfo:AliasEvent = new AliasEvent(AliasEvent.GET_PROGRAM_INFO);
				eventGetProgramInfo.sProgramID = ID;
				eventGetProgramInfo.bIsContractNumber = true;
				this._dispatcher.dispatchEvent(eventGetProgramInfo);
			}
			/* operator */
			else if(dataProviderType == 3){	
				var eventGetOperatorInfo:AliasEvent = new AliasEvent(AliasEvent.GET_OPERATOR_INFO);
				eventGetOperatorInfo.sOperatorID = ID;
				eventGetOperatorInfo.bIsLegacyID = true;
				this._dispatcher.dispatchEvent(eventGetOperatorInfo);
			}
		}
		
		/* search when the pop up window is being used */
		public function getSearch():void{
		
		  /* distributor */
		  if(dataProviderType == 0){
			var eventLoadDistributorSearch:AliasEvent = new AliasEvent(AliasEvent.LOAD_DISTRIBUTOR_SEARCH);
			this._dispatcher.dispatchEvent(eventLoadDistributorSearch);
		  }
		  /* item */
		  else if(dataProviderType == 1){
		  	var eventLoadItemSearch:AliasEvent = new AliasEvent(AliasEvent.LOAD_ITEM_SEARCH);
			this._dispatcher.dispatchEvent(eventLoadItemSearch);
		  }
		  /* program */
		  else if(dataProviderType == 2){
		  	var eventLoadProgramSearch:AliasEvent = new AliasEvent(AliasEvent.LOAD_PROGRAM_SEARCH);
		
		  	//eventLoadProgramSearch.bIsContractNumber = false;
			this._dispatcher.dispatchEvent(eventLoadProgramSearch);	
		  }
		  /* operator */
		  else if(dataProviderType == 3){
			  var eventLoadOperatorSearch:AliasEvent = new AliasEvent(AliasEvent.LOAD_OPERATOR_SEARCH);
			  this._dispatcher.dispatchEvent(eventLoadOperatorSearch);
		  }
		}
		
		//public function setShowIgnore(checkboxSelected:Boolean):void{
		public function setShowIgnore(rdoSelected:int):void{
			var eventShowUnassigned:AliasEvent = new AliasEvent(AliasEvent.SET_SHOW_IGNORE_ALIASES);
			//eventShowUnassigned.bShowIgnore = checkboxSelected;
			eventShowUnassigned.iShowIgnore = rdoSelected;
			this._dispatcher.dispatchEvent(eventShowUnassigned);
		}
		/* set the "showUnassigned" property of the checkbox to "TRUE" or "FALSE" */
		public function setShowUnassigned(checkboxSelected:Boolean):void{
			var eventShowUnassigned:AliasEvent = new AliasEvent(AliasEvent.SET_SHOW_UNASSIGNED_ALIASES);
			eventShowUnassigned.bShowUnassigned = checkboxSelected;
			this._dispatcher.dispatchEvent(eventShowUnassigned);
		}
		
		/* This function sets all the checked Unassigned rows with the entered value */
 
		public function assignAllUnassigned(dataProviderIndex:int,entityID:String,entityDesc:String):void{
			var eventAssignAllUnassigned:AliasEvent = new AliasEvent(AliasEvent.ASSIGN_ALL_UNASSIGNED_DISTRIBUTORS);
			eventAssignAllUnassigned.iDataProviderIndex = dataProviderIndex;
			eventAssignAllUnassigned.sAssignDistributorID = entityID;
			eventAssignAllUnassigned.sAssignDistributorDesc = entityDesc;
			this._dispatcher.dispatchEvent(eventAssignAllUnassigned);
			
			// After the selected rows are assigned uncheck the filter so that the user can see all the records.
			// setShowUnassigned(false);
			
			var eventResetInitialFilter:AliasEvent = new AliasEvent(AliasEvent.RESET_INITIAL_FILTER);
			this._dispatcher.dispatchEvent(eventResetInitialFilter);
		}
		
		
		public function saveSelectedRows(entityType:int):void{
			var errMessage:String;		
			
			var eventSaveSelectedAlias:AliasEvent = new AliasEvent(AliasEvent.SAVE_SELECTED_ALIAS);
			var counter:int = 0;
			var aliasCurrentSelectedRows:ArrayCollection = new ArrayCollection();
			 /* These ones one (sourceType and sourceID) has already been set in "AliasPModel" and so we are just using it, i.e. setting the sourceID property of 
			"aliasSelectedDef" to aliasSourceID and setting the sourceType property of "aliasSelectedDef" to aliasSourceType.
			*/
									
			for each(var aliasSelectedDef:AliasDef in this.aliasCurrentSelectedDef)
			{
				if(aliasSelectedDef.isSelected == true)
				{
					aliasSelectedDef.sourceType  = aliasSourceType;
					aliasSelectedDef.sourceID = aliasSourceID;		
					aliasCurrentSelectedRows.addItemAt(aliasSelectedDef,counter); 
					counter++;
				}
			}
			
			/* Check whether any record had been checked */
			if(counter == 0){
				Alert.show("Please select (using checkbox) at least one alias record to update.");
			}
			else{
				
				eventSaveSelectedAlias.aliasRowsSelected = aliasCurrentSelectedRows;
				eventSaveSelectedAlias.iEntityType = this.dataProviderType;
				eventSaveSelectedAlias.userId = userId;
				this._dispatcher.dispatchEvent(eventSaveSelectedAlias);
			}
		}	
		
		/* Update "AliasDef" on editing of grid cell */
		public function itemEditEnd(event:DataGridEvent):void{		
			//event.preventDefault();
			
			/* Get modified value from the grid cell */
			if (event.dataField != 'isSelected')
			{
				var ti:mx.controls.TextInput = mx.controls.TextInput(event.currentTarget.itemEditorInstance);
				var s:String = ti.text;
			}
			if(event.dataField == 'aliasID')
			{
				updateAliasID(s);
			}
			else if (event.dataField == 'aliasDesc')
			{
				updateAliasDesc(s);
			}
			else if (event.dataField == 'entityID')
			{
				updateID(s);
				getDesc(s);
			}
			else if (event.dataField == 'entityDesc')
			{
				updateDesc(s);
			}
		
		/* if (event.dataField != 'isSelected')
		{
			var sItem :* = event.currentTarget.selectedItem;
		}

			updateAliasID(sItem.aliasID);
			
			updateAliasDesc(sItem.aliasDesc);

			updateID(sItem.entityID);
			getDesc(sItem.entityID);

			updateDesc(sItem.entityDesc);
		*/
			
		/* If it is the last row and last editable column on the grid */
		/*
		if(event.columnIndex > 2 && 
		event.rowIndex == event.currentTarget.dataProvider.length-1)
		{					
		//event.preventDefault();
		//var first:IFocusManagerComponent = focusManager.getNextFocusManagerComponent(); 
		//first.setFocus(); 
		}
		*/				
	}
	}
}