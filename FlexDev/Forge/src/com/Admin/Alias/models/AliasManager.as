package com.Admin.Alias.models
{
	import com.Admin.Alias.events.AliasEvent;
	import com.Admin.Alias.models.vos.AliasDef;
	import com.Billback.Main.models.vos.Payee;
	import com.ContractProds.components.StringUtils;
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.utils.ObjectUtil;
	
	public class AliasManager extends EventDispatcher 
	{
		/*-...................................... Constructor.......................................*/
		private var _dispatcher:IEventDispatcher;
		private var bShowUnassigned:Boolean;
		// private var bShowIgnore:Boolean;
		private var iShowIgnore:int;
		private var iEntityCount:int = 0;
		/* For xls export and file download */
		private var downloadFileRef:FileReference = new FileReference();
		
		public function AliasManager( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		/*.......................................  Properties  ......................................*/
		/*.................oSettings......................*/
		public var oSettings:Settings = new Settings();
		
		/*.................Source Types......................*/
		private var _initialDataProvider:Boolean;
		[Bindable (event="initialDataProviderChanged")]
		public function get initialDataProvider():Boolean
		{
			return _initialDataProvider;
		}
		public function set initialDataProvider(initialDataProvider:Boolean):void
		{
			this._initialDataProvider = initialDataProvider;
			dispatchEvent(new Event('initialDataProviderChanged'));
		}	
		
		/*.................Source Types......................*/
		private var _sourceTypes:Array = new Array();
		[Bindable (event="sourceTypesChanged")]
		public function get sourceTypes():Array
		{
			return _sourceTypes;
		}
		public function set sourceTypes(sourceTypes:Array):void
		{
			this._sourceTypes = sourceTypes;
			dispatchEvent(new Event('sourceTypesChanged'));
		}	
		
		/*.................Enable Payee......................*/
		private var _enablePayee:Boolean;
		[Bindable (event="enablePayeeChanged")]
		public function get enablePayee():Boolean
		{
			return _enablePayee;
		}
		public function set enablePayee(enablePayee:Boolean):void
		{
			this._enablePayee = enablePayee;
			dispatchEvent(new Event('enablePayeeChanged'));
		}
		
		private var _showPayee:Boolean;
		[Bindable (event="showPayeeChanged")]
		public function get showPayee():Boolean
		{
			return _showPayee;
		}
		public function set showPayee(showPayee:Boolean):void
		{
			this._showPayee = showPayee;
			dispatchEvent(new Event('showPayeeChanged'));
		}
		
		private var _gridType:String;
		[Bindable (event="gridTypeChanged")]
		public function get gridType():String
		{
			return _gridType;
		}
		public function set gridType(gridType:String):void
		{
			this._gridType = gridType;
			dispatchEvent(new Event('gridTypeChanged'));
		}
		
		/*.................Enable Download Data......................*/
		private var _enableDownloadData:Boolean;
		[Bindable (event="enableDownloadDataChanged")]
		public function get enableDownloadData():Boolean
		{
			return _enableDownloadData;
		}
		public function set enableDownloadData(enableDownloadData:Boolean):void
		{
			this._enableDownloadData = enableDownloadData;
			dispatchEvent(new Event('enableDownloadDataChanged'));
		}
		
		/*.................AliasDef current data provider......................*/
		private var _aliasCurrentSelectedDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasCurrentSelectedDefChanged")]
		public function get aliasCurrentSelectedDef():ArrayCollection
		{
			return _aliasCurrentSelectedDef;
		}
		public function set aliasCurrentSelectedDef(aliasCurrentSelectedDef:ArrayCollection):void
		{
			this._aliasCurrentSelectedDef = aliasCurrentSelectedDef;
			dispatchEvent(new Event('aliasCurrentSelectedDefChanged'));
		}
				
		/*.................AliasDistributorsDef......................*/
		private var _aliasDistributorsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasDistributorsDefChanged")]
		public function get aliasDistributorsDef():ArrayCollection
		{
			return _aliasDistributorsDef;
		}
		public function set aliasDistributorsDef(aliasDistributorsDef:ArrayCollection):void
		{
			this._aliasDistributorsDef = aliasDistributorsDef;
			dispatchEvent(new Event('aliasDistributorsDefChanged'));
		}
		
		/*.................AliasItemsDef......................*/
		private var _aliasItemsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasItemsDefChanged")]
		public function get aliasItemsDef():ArrayCollection
		{
			return _aliasItemsDef;
		}
		public function set aliasItemsDef(aliasItemsDef:ArrayCollection):void
		{
			this._aliasItemsDef = aliasItemsDef;
			dispatchEvent(new Event('aliasItemsDefChanged'));
		}
		
		/*.................AliasProgramsDef......................*/
		private var _aliasProgramsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasProgramsDefChanged")]
		public function get aliasProgramsDef():ArrayCollection
		{
			return _aliasProgramsDef;
		}
		public function set aliasProgramsDef(aliasProgramsDef:ArrayCollection):void
		{
			this._aliasProgramsDef = aliasProgramsDef;
			dispatchEvent(new Event('aliasProgramsDefChanged'));
		}
		
		/*.................AliasOperatorsDef......................*/
		private var _aliasOperatorsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasOperatorsDefChanged")]
		public function get aliasOperatorsDef():ArrayCollection
		{
			return _aliasOperatorsDef;
		}
		public function set aliasOperatorsDef(aliasOperatorsDef:ArrayCollection):void
		{
			this._aliasOperatorsDef = aliasOperatorsDef;
			dispatchEvent(new Event('aliasOperatorsDefChanged'));
		}
		
		/*.................AliasAllDistributorsDef......................*/
		private var _aliasAllDistributorsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasAllDistributorsDefChanged")]
		public function get aliasAllDistributorsDef():ArrayCollection
		{
			return _aliasAllDistributorsDef;
		}
		public function set aliasAllDistributorsDef(aliasAllDistributorsDef:ArrayCollection):void
		{
			this._aliasAllDistributorsDef = aliasAllDistributorsDef;
			dispatchEvent(new Event('aliasAllDistributorsDefChanged'));
		}
		
		/*.................AliasAllItemsDef......................*/
		private var _aliasAllItemsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasAllItemsDefChanged")]
		public function get aliasAllItemsDef():ArrayCollection
		{
			return _aliasAllItemsDef;
		}
		public function set aliasAllItemsDef(aliasAllItemsDef:ArrayCollection):void
		{
			this._aliasAllItemsDef = aliasAllItemsDef;
			dispatchEvent(new Event('aliasAllItemsDefChanged'));
		}
		
		/*.................AliasAllProgramsDef......................*/
		private var _aliasAllProgramsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasAllProgramsDefChanged")]
		public function get aliasAllProgramsDef():ArrayCollection
		{
			return _aliasAllProgramsDef;
		}
		public function set aliasAllProgramsDef(aliasAllProgramsDef:ArrayCollection):void
		{
			this._aliasAllProgramsDef = aliasAllProgramsDef;
			dispatchEvent(new Event('aliasAllProgramsDefChanged'));
		}
		
		/*.................AliasAllOperatorsDef......................*/
		private var _aliasAllOperatorsDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasAllOperatorsDefChanged")]
		public function get aliasAllOperatorsDef():ArrayCollection
		{
			return _aliasAllOperatorsDef;
		}
		public function set aliasAllOperatorsDef(aliasAllOperatorsDef:ArrayCollection):void
		{
			this._aliasAllOperatorsDef = aliasAllOperatorsDef;
			dispatchEvent(new Event('aliasAllOperatorsDefChanged'));
		}
		
		/*.................AliasAllDef......................*/
		private var _aliasAllDef:ArrayCollection = new ArrayCollection();
		[Bindable (event="aliasAllDefChanged")]
		public function get aliasAllDef():ArrayCollection
		{
			return _aliasAllDef;
		}
		public function set aliasAllDef(aliasAllDef:ArrayCollection):void
		{
			this._aliasAllDef = aliasAllDef;
			dispatchEvent(new Event('aliasAllDefChanged'));
		}
		
		/*.................AliasSelectedDef......................*/
		private var _aliasSelectedDef:AliasDef = new AliasDef();
		[Bindable (event="aliasSelectedDefChanged")]
		public function get aliasSelectedDef():AliasDef
		{
			return _aliasSelectedDef;
		}
		public function set aliasSelectedDef(aliasSelectedDef:AliasDef):void
		{
			this._aliasSelectedDef = aliasSelectedDef;
			dispatchEvent(new Event('aliasSelectedDefChanged'));
		}
				
		/*.................DataProvider Type......................*/
		private var _dataProviderType:int;
		[Bindable (event="dataProviderTypeChanged")]
		public function get dataProviderType():int
		{
			return _dataProviderType;
		}
		public function set dataProviderType(dataProviderType:int):void
		{
			this._dataProviderType = dataProviderType;
			dispatchEvent(new Event('dataProviderTypeChanged'));
		}			
		
		/*.................RefreshSelectedAliasOnly ......................*/
		private var _refreshSelectedAliasOnly:Boolean = false;
		[Bindable (event="refreshSelectedAliasOnlyChanged")]
		public function get refreshSelectedAliasOnly():Boolean
		{
			return _refreshSelectedAliasOnly;
		}
		public function set refreshSelectedAliasOnly(refreshSelectedAliasOnly:Boolean):void
		{
			this._refreshSelectedAliasOnly = refreshSelectedAliasOnly;
			dispatchEvent(new Event('refreshSelectedAliasOnlyChanged'));
		}	
		
		/*.................SourceInfo......................*/
		private var _sourceInfo:Payee = new Payee();
		[Bindable (event="sourceInfoChanged")]
		public function get sourceInfo():Payee
		{
			return _sourceInfo;
		}
		public function set sourceInfo(sourceInfo:Payee):void
		{
			this._sourceInfo = sourceInfo;
			dispatchEvent(new Event('sourceInfoChanged'));
		}
		
		/*.................AliasSourceID......................*/		
		private var _aliasSourceID:String = new String();
		[Bindable (event="aliasSourceIDChanged")]
		public function get aliasSourceID():String
		{
			return _aliasSourceID;
		}
		public function set aliasSourceID(sourceID:String):void
		{
			this._aliasSourceID = sourceID;
			dispatchEvent(new Event('aliasSourceIDChanged'));
		}
		
		/*.................AliasSourceType......................*/		
		private var _aliasSourceType:int;
		[Bindable (event="aliasSourceTypeChanged")]
		public function get aliasSourceType():int
		{
			return _aliasSourceType;
		}
		public function set aliasSourceType(sourceType:int):void
		{
			this._aliasSourceType = sourceType;
			dispatchEvent(new Event('aliasSourceTypeChanged'));
		}		
		
		/*.................Set show unassigned......................*/
		private var _showUnassigned:Boolean;
		[Bindable (event="showUnassignedChanged")]
		public function get showUnassigned():Boolean
		{
			return _showUnassigned;
		}
		public function set showUnassigned(showUnassigned:Boolean):void
		{
			this._showUnassigned = showUnassigned;
			dispatchEvent(new Event('showUnassignedChanged'));
		}
		
		/*.................Set show Ignore......................*/
		private var _showIgnore:int;
		[Bindable (event="showIgnoreChanged")]
		public function get showIgnore():int
		{
			return _showIgnore;
		}
		public function set showIgnore(showIgnore:int):void
		{
			this._showIgnore = showIgnore;
			dispatchEvent(new Event('showIgnoreChanged'));
		}
		
		/*.................Set label change......................*/
		private var _labelText1:String;
		[Bindable (event="labelText1Changed")]
		public function get labelText1():String
		{
			return _labelText1;
		}
		public function set labelText1(labelText1:String):void
		{
			this._labelText1 = labelText1;
			dispatchEvent(new Event('labelText1Changed'));
		}
		
		/*-.........................................Methods..........................................*/
		public function test(x:*):void{
			Alert.show('here:  + {ObjectUtil.toString(x)}' );
			
		}
		
		/* Keep this function here so that, the "ObjectUtil" library is not removed from flex */
		public function testObj(x:*):void{
			ObjectUtil.toString(x);			
		}
		
		/*.................Alias Distributor Results......................*/
		public function AliasDistributorResults(sourceType:int,aliasDistributors:Array):void{
			
			/* Disable the "download data" link. This is by default. It gets enabled when the user selects "ALL ALIAS" from the source
			dropdown and then all the entity data gets returned - distributor,item,program and operator. I could have used 
			"this._enableDownloadData = false;" in any other entity function also, but it just needs to be set once and so I am setting
			it here - distributor function.			
			*/
			this.enableDownloadData = false;
			
			/* sourceID is a property of AliasDef Object. It is also a property of "StructErrorMessage" sent from CF.
			It is only populated when there are no "SOURCES" found, else it is blank.When the searched source is not found, show
			an alert - "Source not found".
			*/						
						/* Not a valid "SOURCE" */
						if(aliasDistributors[0].sourceID != '')
						{   
							/* For Display, we need to show "SOURCEID" in CAPS. "SOURCEID" here is the error message ("Source Not Found") */
							Alert.show(aliasDistributors[0].SOURCEID);
							this.aliasDistributorsDef = new ArrayCollection(new Array());
						}
						/* No Aliases found for a Valid Source OR EDI OR No Aliases found at all */			
						else if(aliasDistributors[0].aliasID == '') 
						{
							/* No results */
							this.aliasDistributorsDef = new ArrayCollection(new Array());
							/* Call the function to let the function know that distributor data has been loaded, though in this case there are no records */
							checkAllEntityData(1,sourceType);
							
							/* Set the dataprovider to "distributor" */
							//if(initialDataProvider == false || dataProviderType == 0)
							//{
							//changeDataProvider(0);
							//}
						}
							/* Aliases found for a valid source */
						else
						{
							/* If "All Aliases" option is not selected */
							if(sourceType != 100)
							{
								this.aliasDistributorsDef = new ArrayCollection(aliasDistributors);		
							}
								/* If "All Aliases" option is selected */
							else
							{
								this.aliasAllDistributorsDef = new ArrayCollection(aliasDistributors);
							}							
							
							/* Call the function to let the function know that distributor data has been loaded */
							checkAllEntityData(1,sourceType);
							
						}

					//this._dataProviderType = 0;
					//dispatchEvent(new Event('dataProviderTypeChanged'));
					
					/* If this is the first search OR the dataprovider is already set to "distributor and the request is not for "ALL" aliases, 
					set the dataprovider to "distributor" for the new search.
					*/
					if((initialDataProvider == false || dataProviderType == 0) && sourceType != 100)
					{
						changeDataProvider(this.dataProviderType);
						
						/* Set "initialDataProvider" to true. Now we know that the first search has been already made. */
						this._initialDataProvider =  true;
						dispatchEvent(new Event('initialDataProviderChanged'));
					}
			
		}
		
		/*.................Alias Item Results......................*/
		public function AliasItemResults(sourceType:int,aliasItems:Array):void{
			/* sourceID is a property of AliasDef Object. It is also a property of "StructErrorMessage" sent from CF.
			It is only populated when there are no "SOURCES" found, else it is blank.When the searched source is not found,
			clear the datagrid.
			*/
			
			/* Not a valid "SOURCE". Clear the grid result */
			if(aliasItems[0].sourceID  != '')
			{   
				this.aliasItemsDef = new ArrayCollection(new Array());
			}
				
				/* No Aliases found for a Valid Source OR EDI OR No Aliases found at all */			
			else if(aliasItems[0].aliasID == '') 
			{
				/* No results */
				this.aliasItemsDef = new ArrayCollection(new Array());	
				/* Call the function to let the function know that item data has been loaded, though in this case there are no records */
				checkAllEntityData(1,sourceType);
			}
				
				/* Aliases found for a valid source */
			else
			{	
				/* If "All Aliases" option is not selected */
				if(sourceType != 100)
				{
					this.aliasItemsDef = new ArrayCollection(aliasItems);			
				}
					/* If "All Aliases" option is selected */
				else
				{
					this.aliasAllItemsDef = new ArrayCollection(aliasItems);	
				}
				
				/* Call the function to let the function know that items data has been loaded */
				checkAllEntityData(1,sourceType);
			}
			
			/* If the dataprovider is already items  and the request is not for "ALL" aliases, set the dataprovider to "items" for the new search. */
			if(dataProviderType == 1 && sourceType != 100)
			{
				changeDataProvider(1);		
			}
		}
		
		/*.................Alias Program Results......................*/
		public function AliasProgramResults(sourceType:int,aliasPrograms:Array):void{
			/* sourceID is a property of AliasDef Object. It is also a property of "StructErrorMessage" sent from CF.
			It is only populated when there are no "SOURCES" found, else it is blank.When the searched source is not found, 
			clear the datagrid.
			*/
			
			/* Not a valid "SOURCE". Clear the grid result */
			if(aliasPrograms[0].sourceID != '')
			{ 
				this.aliasProgramsDef = new ArrayCollection(new Array());
			}
				
				/* No Aliases found for a Valid Source OR EDI OR No Aliases found at all */				
			else if(aliasPrograms[0].aliasID == '') 
			{
				/* No results */
				this.aliasProgramsDef = new ArrayCollection(new Array());
				/* Call the function to let the function know that program data has been loaded, though in this case there are no records */
				checkAllEntityData(1,sourceType);
			}
				
				/* Aliases found for a valid source */
			else
			{	
				/* If "All Aliases" option is not selected */
				if(sourceType != 100)
				{
					this.aliasProgramsDef = new ArrayCollection(aliasPrograms);	
				}
					/* If "All Aliases" option is selected */
				else
				{
					this.aliasAllProgramsDef = new ArrayCollection(aliasPrograms);
				}
				
				/* Call the function to let the function know that program data has been loaded */
				checkAllEntityData(1,sourceType);
			}
			
			/* If the dataprovider is already programs and the request is not for "ALL" aliases, set the dataprovider to "programs" for the new search. */
			if(dataProviderType == 2 && sourceType != 100)
			{
				changeDataProvider(2);
			}
		}
		
		/*.................Alias Operator Results......................*/
		public function AliasOperatorResults(sourceType:int,aliasOperators:Array):void{
			/* sourceID is a property of AliasDef Object. It is also a property of "StructErrorMessage" sent from CF.
			It is only populated when there are no "SOURCES" found, else it is blank.When the searched source is not found, 
			clear the datagrid.
			*/
			
			/* Not a valid "SOURCE". Clear the grid result */
			if(aliasOperators[0].sourceID != '')
			{ 
				this.aliasOperatorsDef = new ArrayCollection(new Array());
			}
				
				/* No Aliases found for a Valid Source OR EDI OR No Aliases found at all */				
			else if(aliasOperators[0].aliasID == '') 
			{
				/* No results */
				this.aliasOperatorsDef = new ArrayCollection(new Array());
				/* Call the function to let the function know that operator data has been loaded, though in this case there are no records */
				checkAllEntityData(1,sourceType);
			}
				
				/* Aliases found for a valid source */
			else
			{	
				/* If "All Aliases" option is not selected */
				if(sourceType != 100)
				{
					this.aliasOperatorsDef = new ArrayCollection(aliasOperators);	
				}
					/* If "All Aliases" option is selected */
				else
				{
					this.aliasAllOperatorsDef = new ArrayCollection(aliasOperators);
				}
				
				/* Call the function to let the function know that operator data has been loaded */
				checkAllEntityData(1,sourceType);
			}
			
			/* If the dataprovider is already programs and the request is not for "ALL" aliases, set the dataprovider to "programs" for the new search. */
			if(dataProviderType == 3 && sourceType != 100)
			{
				changeDataProvider(3);
			}
		}
		
		/*.................Alias Selected Results......................*/
		public function AliasSelectedResults(aliasSelected:AliasDef):void{
				this.aliasSelectedDef = aliasSelected;
			}			
		
		/*.................Alias Source ID......................*/
		public function AliasSource(sourceType:int,sourceID:String):void{	
			this._aliasSourceType = sourceType;
			this._aliasSourceID = sourceID;			
			dispatchEvent(new Event('aliasSourceIDChanged'));
			dispatchEvent(new Event('aliasSourceTypeChanged'));
		}
		
		public function refreshSelectedAlias(entityType:int,aliasSelectedSaved:Array):void{
			
			/* set the boolean */
			this.refreshSelectedAliasOnly = true;
			
			/* refresh the grid with the updated records. */
			refreshAlias(entityType,aliasSelectedSaved);
			
			/* If there are any previously checked items in the shared object, uncheck them */
			var eventUncheckSelected:AliasEvent = new AliasEvent(AliasEvent.UNCHECK_SELECTED);
			this._dispatcher.dispatchEvent(eventUncheckSelected);
			
			/* reset the bolean */
			this.refreshSelectedAliasOnly = false;
		}
		
		public function showSaveMessage(entityType:int,alias:Array,e:AliasEvent):void{
			e.stopPropagation();
			e.stopImmediatePropagation();
			/* show message */
			if(alias.length == 0){
				Alert.show("0 Alias records have been saved.");
			}
			else if(alias.length == 1){
				Alert.show("Alias record " + alias[0].aliasDesc + " has been saved.");
				//Alert.show(alias[0].aliasDesc);
			}
			else{
				var s:String = '';
				var i:int = 1;
				for each(var a:AliasDef in alias){
					if(i == alias.length){
//						if(alias.length > 2){
//							s = s + " and " + a.aliasDesc.toString();
//						}
//						else{
//							s = s.slice(0,s.indexOf(',',0))
//							s = s + " and " + a.aliasDesc.toString();
//						}
						
						s = s + "  * " + a.aliasDesc.toString() + '\n';
						
					}
					else{
						s = s + "  * " + a.aliasDesc.toString() + '\n';
						//s = s + a.aliasDesc.toString() + ', ';
					}
					
					i = i+1;
				}
				Alert.show(alias.length + " Alias records updated:\n" + s + " ");
			}
			
		}
		
		
		/* This function is called when an existing alias record is edited OR a new alias record is added. */
		public function refreshAlias(entityType:int,alias:Array):void{

			var recordExists:Boolean = false;
			
			/* sourceID is a property of AliasDef Object. It is also a property of "StructErrorMessage" sent from CF.
			It is only populated when there are no "SOURCES" found, else it is blank. When the searched source is not found, show
			an alert - "Source not found".
			*/			
			if(alias[0].sourceID != '')
			{   
				//if(this.refreshSelectedAliasOnly == false)
				//{
				/* For Display, we need to show "SOURCEID" in CAPS. "SOURCEID" here is the error message ("Source Not Found") */
				Alert.show(alias[0].SOURCEID);
				//}
			}				
			else
			{
				/* The aliasDef object from the db passes a "recordID". If we can find it in the flex grid, that means the record has been edited
				and so "DO NOT ADD ANY NEW RECORD TO THE GRID".
				*/
				if(alias.length != 0)
				{	
					/* When only one record is updated */
					if(this.refreshSelectedAliasOnly == false)
					{
						for each(var aliasDp:AliasDef in this.aliasCurrentSelectedDef.source){
							if(alias[0]){
								if(aliasDp.aliasID == alias[0].aliasID){
									/* The record already exists, i.e. the record was edited */
									recordExists = true;
									break;
								}
							}
						} 
					 }
					
					/* When multiple records are updated */
					if(this.refreshSelectedAliasOnly == true)
					{				
						recordExists = true;
					}
					
					/* When only one record is updated */
					if(this.refreshSelectedAliasOnly == false)
					{					
						/* If it is a new alias record */
						if(recordExists == false && alias[0].recordID != 0){	 
							
							/* Add the existing records to the new record - This way the new record comes out on the top of the flex grid.
							Existing records are "this.aliasDistributorsDef.source" and new record is "alias".
							*/
							
							/* DISTRIBUTOR */
							if(entityType == 0){
								this.aliasDistributorsDef = new ArrayCollection(alias.concat(this.aliasDistributorsDef.source));
								this.aliasCurrentSelectedDef = this.aliasDistributorsDef;
								dispatchEvent(new Event('aliasDistributorsDefChanged'));
							}
								/* ITEM */
							else if(entityType == 1){ 
								this.aliasItemsDef = new ArrayCollection(alias.concat(this.aliasItemsDef.source));
								this.aliasCurrentSelectedDef = this.aliasItemsDef;
								dispatchEvent(new Event('aliasItemsDefChanged'));
							}
								/* PROGRAM */
							else if(entityType == 2){ 
								this.aliasProgramsDef = new ArrayCollection(alias.concat(this.aliasProgramsDef.source));
								this.aliasCurrentSelectedDef = this.aliasProgramsDef;
								dispatchEvent(new Event('aliasProgramsDefChanged'));
							}
								/* OPERATOR */
							else if(entityType == 3){ 
								this.aliasOperatorsDef = new ArrayCollection(alias.concat(this.aliasOperatorsDef.source));
								this.aliasCurrentSelectedDef = this.aliasOperatorsDef;
								dispatchEvent(new Event('aliasOperatorsDefChanged'));
							}
							
							/* Since only one record gets returned as an array of objects, set that record to be the aliasSelectedDef */
							aliasSelectedDef = alias[0];
							
						 }
					  }
					
					var iCtr:int;
					
					/* When existing records or records are updated */
					if (recordExists == true)
					{
						/*  DISTRIBUTOR */
						if(entityType == 0){
							
							/* loop through the records which have been updated (one or more) */
							for each(var AliasSelectedDist:AliasDef in alias){
								iCtr = 0;
								
								/* loop through the entire dataset */
								for each(var aliasDistDp:AliasDef in this.aliasDistributorsDef.source){
									if((aliasDistDp.recordID == AliasSelectedDist.recordID) || aliasDistDp.recordID == 0){
										/* If the updated record already exists, then delete that record. 
										If "aliasDistDp.recordID == 0" - This will happen when the user loads the records using a csv file
										and the records are not saved as yet. In this case, the records will exist in "aliasDistributorsDef",
										but with a recordID of 0. Once the record(s) are saved in the db, the recordID is assigned. So, since we
										do not want to duplicate the records by using "concat" below, delete the record(s) with recordID of 0.										
										*/
										this.aliasDistributorsDef.source.splice(iCtr,1); 
										break;
									}
									iCtr = iCtr + 1;
								}
							}
							/* Add the existing records to the refreshed records.
							Existing records are "this.aliasDistributorsDef.source" and new record is "alias".*/
							this.aliasDistributorsDef = new ArrayCollection(alias.concat(this.aliasDistributorsDef.source));
							this.aliasCurrentSelectedDef = this.aliasDistributorsDef;
							dispatchEvent(new Event('aliasDistributorsDefChanged'));
						}
						
						/* ITEM */
						if(entityType == 1){
							
							/* loop through the records which have been updated (one or more) */
							for each(var AliasSelectedItems:AliasDef in alias){
								iCtr = 0;
								
								/* loop through the entire dataset */
								for each(var aliasItemsDp:AliasDef in this.aliasItemsDef.source){
									if(aliasItemsDp.recordID == AliasSelectedItems.recordID){
										/* If the updated record already exists, then delete that record */
										this.aliasItemsDef.source.splice(iCtr,1); 
										break;
									}
									iCtr = iCtr + 1;
								}
							}
							/* Add the existing records to the refreshed records.
							Existing records are "this.aliasItemsDef.source" and new record is "alias".*/
							this.aliasItemsDef = new ArrayCollection(alias.concat(this.aliasItemsDef.source));
							this.aliasCurrentSelectedDef = this.aliasItemsDef;
							dispatchEvent(new Event('aliasItemsDefChanged'));
						}
						
						/* PROGRAM */
						if(entityType == 2){ 
							
							/* loop through the records which have been updated (one or more) */
							for each(var AliasSelectedPrograms:AliasDef in alias){
								iCtr = 0;				
								
								/* loop through the entire dataset */
								for each(var aliasProgramsDp:AliasDef in this.aliasProgramsDef.source){
									if(aliasProgramsDp.recordID == AliasSelectedPrograms.recordID){
										/* If the updated record already exists, then delete that record */
										this.aliasProgramsDef.source.splice(iCtr,1); 
										break;
									}
									iCtr = iCtr + 1;
								}
							}
							/* Add the existing records to the refreshed records.
							Existing records are "this.aliasProgramsDef.source" and new record is "alias".*/
							this.aliasProgramsDef = new ArrayCollection(alias.concat(this.aliasProgramsDef.source));
							this.aliasCurrentSelectedDef = this.aliasProgramsDef;
							dispatchEvent(new Event('aliasProgramsDefChanged'));
						}
						
						/* OPERATOR */
						if(entityType == 3){ 
							
							/* loop through the records which have been updated (one or more) */
							for each(var AliasSelectedOperators:AliasDef in alias){
								iCtr = 0;
								
								/* loop through the entire dataset */
								for each(var aliasOperatorsDp:AliasDef in this.aliasOperatorsDef.source){								
									if(aliasOperatorsDp.recordID == AliasSelectedOperators.recordID){
										/* If the updated record already exists, then delete that record */
										this.aliasOperatorsDef.source.splice(iCtr,1); 	
										break;
									}
									iCtr = iCtr + 1;
								}
							}
							/* Add the existing records to the refreshed records.
							Existing records are "this.aliasOperatorsDef.source" and new record is "alias".*/
							this.aliasOperatorsDef = new ArrayCollection(alias.concat(this.aliasOperatorsDef.source));
							this.aliasCurrentSelectedDef = this.aliasOperatorsDef;
							dispatchEvent(new Event('aliasOperatorsDefChanged'));
						}
					}
					
					/* Reset the "selected Def". Now there is no selected record. */
					ResetAliasSelectedDef();
				}
			}
		}
		
		/*.................Distributor Info Results......................*/
		public function DistributorInfoResults(distributor:Array):void
		{		
			var strAddress:String = '';
			
			if(distributor[0].address != ','){
				strAddress = '\n' + distributor[0].address;
			}
					
					if(distributor[0].shipTo != ''){
						aliasSelectedDef.entityID = distributor[0].shipTo;
						aliasSelectedDef.entityDesc = distributor[0].name + strAddress;	
					}
					else
					{   /* When the distributor ship to is blank, set entityDesc to blank.
						Do not set entityID to blank. entityID should be shown on the textbox. */
						aliasSelectedDef.entityDesc = '';
					}
					dispatchEvent(new Event('aliasSelectedDefChanged'));
			}
		
		/*.................Item Info Results......................*/
		public function ItemInfoResults(item:Array):void
		{
			if(item[0].ItemID != ''){
				aliasSelectedDef.entityID = item[0].ItemID;
				aliasSelectedDef.entityDesc = item[0].desc;
				aliasSelectedDef.Unknown = item[0].unknown;
			}
			else
			{   /* When the description is blank (just in case), set it to blank.
				Do not set entityID to blank. entityID should be shown on the textbox. */
				aliasSelectedDef.entityDesc = '';
			}
			dispatchEvent(new Event('aliasSelectedDefChanged'));
		}
		
		/*.................Program Info Results......................*/
		public function ProgramInfoResults(program:Array):void
		{
			if(program[0].contractID != ''){
				aliasSelectedDef.entityID = program[0].contractID;
				aliasSelectedDef.entityDesc = program[0].desc;			
			}
			else
			{   /* When the title is blank (just in case), set it to blank.
				Do not set entityID to blank. entityID should be shown on the textbox. */
				aliasSelectedDef.entityDesc = '';
			}
			dispatchEvent(new Event('aliasSelectedDefChanged'));
		}
		
		/*.................Operator Info Results......................*/
		public function OperatorInfoResults(operator:Array):void
		{			
			var strAddress:String = '';
			
			if(operator[0].address != ','){
				strAddress = '\n' + operator[0].address;
			}
			
			if(operator[0].legacyID != ''){
				aliasSelectedDef.entityID = operator[0].legacyID;
				aliasSelectedDef.entityDesc = operator[0].name + strAddress;
				aliasSelectedDef.bsaId = operator[0].BSA_Operator_ID;
			}
			else
			{   /* When the operatorID is blank, set entityDesc to blank.
				Do not set entityID to blank. entityID should be shown on the textbox. */
				aliasSelectedDef.entityDesc = '';
			}
			dispatchEvent(new Event('aliasSelectedDefChanged'));
		}
		
		/*.................Source Info Results......................*/
		public function SourceInfoResults(source:Payee):void
		{	
			/* Name has "address" too */
			this._sourceInfo.name = source.name;
			
			/* If the payeeID is updated always, then while changing the payeeID manually (CHANGE EVENT), the payeeID becomes blank, 
			as the payeeID is not found.
			*/
			if(source.payeeId != '')
			{
				this._sourceInfo.payeeId = source.payeeId;	
			}
			
			dispatchEvent(new Event('sourceInfoChanged'));
			
			/* set the source. SourceType of 2 means vendor. If the user changes the sourceType from the dropdown, that
			selected value will update this one from "updateSource. 2 (vendor) is by default.
			*/
			var eventSetSource:AliasEvent = new AliasEvent(AliasEvent.SET_SOURCE);
			eventSetSource.iSourceType = this.aliasSourceType;
			//eventSetSource.iSourceType = this.sourceType;
			
			/* payeeId will exist only for "Payee Alias" option.aliasSourceType == 2 means "vendor" */
			if(this._sourceInfo.payeeId != '' && this.aliasSourceType == 2){
				eventSetSource.sSourceID = this._sourceInfo.payeeId;	
			}
			else{
				eventSetSource.sSourceID = this.aliasSourceID;	
			}		
			
			this._dispatcher.dispatchEvent(eventSetSource);
		}
		
		/*.................Reset aliasSelectedDef to a new instance of AliasDef......................*/
		public function ResetAliasSelectedDef():void
		{
			this._aliasSelectedDef = new AliasDef();
			dispatchEvent(new Event('aliasSelectedDefChanged'));
		}
				
		/*.................uncheck selected billbacks in the shared object......................*/	
		public function uncheckSelectedItems():void
		{
			for each(var oItem:Object in this.aliasCurrentSelectedDef.source)
			{
				if(oItem['isSelected'] == true)
				{
					oItem['isSelected'] = false;
				}
			}	
		}
		
		/*................. Call the vendor search popup page ......................*/
		public function showVendorSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveVendor", saveVendor);
			var winjscommand:String = "/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?FormName=flex&FlexAppName="+currentAppName+"&RebateRecipient_On=1&ReloadForm=0&FieldName=Vendor_ID&PageSource=ProgramVendorSearch";
			var jscommand:String = "window.open('"+winjscommand+"','vendorwindow','height=600,width=800,left=400,toolbar=no,scrollbars=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*................. Get the vendor info after the "vendor ID" is returned from the popup page.......................*/
		public function saveVendor(sourceID:String,name:String):void {
			var eventGetSourceInfo:AliasEvent = new AliasEvent(AliasEvent.GET_SOURCE_INFO);
			eventGetSourceInfo.sSourceID = sourceID;
			this._dispatcher.dispatchEvent(eventGetSourceInfo);
		}
		
		/*................. Call the distributor search popup page ......................*/
		public function showDistributorSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveDistributor", saveDistributor);
			var winjscommand:String = "/billbacks/search_screens/PM_select_distributors.cfm?FormName=flex&FlexAppName="+currentAppName+"&OnlyDistributorsUnderMe=0";
			var jscommand:String = "window.open('"+winjscommand+"', 'distributorwindow', 'height=600,width=800,left=400,toolbar=no,scrollbars=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*................. Get the distributor info after the "item GUID" is returned from the popup page. Note: What is passed here is the distributor GUID ......................*/
		public function saveDistributor(sDistributorGUID:String):void {
			var eventGetDistributorInfo:AliasEvent = new AliasEvent(AliasEvent.GET_DISTRIBUTOR_INFO);
			eventGetDistributorInfo.sDistributorID = sDistributorGUID;
			eventGetDistributorInfo.bIsDistGUID = true;
			this._dispatcher.dispatchEvent(eventGetDistributorInfo);
		}
		
		/*................. Call the item search popup page ......................*/
		public function showItemSearch():void {			
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveItem", saveItem);
			var winjscommand:String = "/common_files/contracts/product_Select_V1.cfm?Formname=flex&FlexAppName="+currentAppName+"&SelectSingleSearchResultOnly=1";
			var jscommand:String = "window.open('"+winjscommand+"', 'itemwindow', 'height=600,width=800,left=400,toolbar=no,scrollbars=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*................. Get the item info after the "item GUID" is returned from the popup page. Note: What is passed here is the Item GUID ......................*/
		public function saveItem(sItemGUID:String):void {
			var eventGetItemInfo:AliasEvent = new AliasEvent(AliasEvent.GET_ITEM_INFO);
			eventGetItemInfo.sItemID = sItemGUID;
			eventGetItemInfo.bIsItemGUID = true;
			this._dispatcher.dispatchEvent(eventGetItemInfo);
		}
		
		/*................. Call the program search popup page ......................*/
		public function showProgramSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveProgram", saveProgram);
			/* "ProgramRestrictions" variable allows access to all programs and does not look at profile and other restrictions */
			var winjscommand:String = "/billbacks/search_screens/search_programs.cfm?Formname=flex&FlexAppName="+currentAppName+"&fieldname=Program_List&SELECTSINGLESEARCHRESULTONLY=1&ProgramRestrictions=0";
			var jscommand:String = "window.open('"+winjscommand+"', 'programswindow', 'height=600,width=800,toolbar=no,scrollbars=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*................. Get the program info after the program ID is returned from the popup page ......................*/
		public function saveProgram(id:int):void {
			var eventGetProgramInfo:AliasEvent = new AliasEvent(AliasEvent.GET_PROGRAM_INFO);
			eventGetProgramInfo.sProgramID = id.toString();  
			this._dispatcher.dispatchEvent(eventGetProgramInfo);
		}
		
		/*................. Call the operator search popup page ......................*/
		public function showOperatorSearch():void {
			var currentAppName:String = FlexGlobals.topLevelApplication.toString();
			if (ExternalInterface.available)
				ExternalInterface.addCallback("saveOperator", saveOperator);
			/* "ProgramRestrictions" variable allows access to all programs and does not look at profile and other restrictions */
			var winjscommand:String = "/billbacks/search_screens/pm_select_operators.cfm?Formname=flex&FlexAppName="+currentAppName+"&gpokey="+this._aliasSelectedDef.sourceTypeDesc+"&zip="+this._aliasSelectedDef.aliasZIP;
			var jscommand:String = "window.open('"+winjscommand+"', 'operatorswindow', 'height=750,width=1000,toolbar=no,scrollbars=yes,resizable=yes');"
			var url:URLRequest = new URLRequest("javascript:" + jscommand + " void(0);");
			navigateToURL(url,'_self');
		}
		
		/*................. Get the operator info after the operator ID is returned from the popup page ......................*/
		public function saveOperator(id:int):void {
			var eventGetOperatorInfo:AliasEvent = new AliasEvent(AliasEvent.GET_OPERATOR_INFO);
			eventGetOperatorInfo.sOperatorID = id.toString();  
			eventGetOperatorInfo.bIsLegacyID = false;
			this._dispatcher.dispatchEvent(eventGetOperatorInfo);
		}
		
		public function assignAllUnassigned(dataProviderIndex:int,entityID:String,entityDesc:String):void
		{
			
			var iRecord:int;
			if(dataProviderIndex == 0){
				if(entityID != ''){
					iRecord = 0;
					for each(var aliasDistDp:AliasDef in this.aliasDistributorsDef.source){
						iRecord = iRecord + 1;
						if(aliasDistDp.isSelected == true){
							aliasDistDp.entityID = entityID;
							aliasDistDp.entityDesc = entityDesc;			
						}
					}
				}
			}
			else if (dataProviderIndex == 1){
				if(entityID != ''){
					
					iRecord = 0;
					for each(var aliasItemsDp:AliasDef in this.aliasItemsDef.source){
						iRecord = iRecord + 1;
						if(aliasItemsDp.isSelected == true){
							aliasItemsDp.entityID = entityID;
							aliasItemsDp.entityDesc = entityDesc;			
						}
					}
				}
			}
			else if (dataProviderIndex == 2){
				if(entityID != ''){
					iRecord = 0;
					for each(var aliasProgramsDp:AliasDef in this.aliasProgramsDef.source){
						iRecord = iRecord + 1;
						if(aliasProgramsDp.isSelected == true){
							aliasProgramsDp.entityID = entityID;
							aliasProgramsDp.entityDesc = entityDesc;			
						}
					}
				}
			}
			else if (dataProviderIndex == 3){
				if(entityID != ''){
					iRecord = 0;
					for each(var aliasOperatorsDp:AliasDef in this.aliasOperatorsDef.source){
						iRecord = iRecord + 1;
						if(aliasOperatorsDp.isSelected == true){
							aliasOperatorsDp.entityID = entityID;
							aliasOperatorsDp.entityDesc = entityDesc;			
						}
					}
				}
			}
		} 
		
		
		/*.................Get a list of sources and the "Payee" textbox is enabled by default ......................*/
		public function SourceTypesResults(sourceTypes:Array):void
		{				
			this._sourceTypes = sourceTypes;
			dispatchEvent(new Event('sourceTypesChanged'));
			
			this._showPayee	 = false;
			
			/* loop through the "source type" dropdown */
			for each(var source_Type:Object in sourceTypes){
				/* If "vendor" exists as a payee */
				if(source_Type.sourceType == 2){
					this._showPayee	 = true;
					dispatchEvent(new Event('showPayeeChanged'));
					break;
				}
			}	
			
			this._enablePayee = true;
			dispatchEvent(new Event('enablePayeeChanged'));
		}
		
		/*.................Disable or Enable Payee textbox. ......................*/
		public function DisableEnablePayee(useSearchTool:String):void
		{			
			if(useSearchTool == '1'){
				this._enablePayee = true;
			}
			else{
				/* Disable the "payee" textbox, if the search is for EDI aliases OR if the "All Alias" option is selected. */	
				this._enablePayee = false;
			}
			
			dispatchEvent(new Event('enablePayeeChanged'));
		}
		
		/*.................After deleting a specific Alias record, reset the "selected Def". Now there is no selected record......................*/
		public function deleteAliasResults(rowDeleted:Boolean):void
		{
			ResetAliasSelectedDef();
		}
		
		/*.................Based on the tab clicked, set the dataprovider of the grid to either distributor, item, program or operator......................*/
		public function changeDataProvider(dataProviderIndex:int):void
		{
			var bShowAddressCols:Boolean = false;
			
			if(dataProviderIndex >=0 && dataProviderIndex <= 3){
				switch(dataProviderIndex)
				{
					case 0: /* distributor */
						this.aliasCurrentSelectedDef = this.aliasDistributorsDef;
						if(this.aliasSourceType == 12){
							bShowAddressCols = true;
						}
						break;
					case 1: /* item */
						this.aliasCurrentSelectedDef = this.aliasItemsDef;
						break;
					case 2: /* program */
						this.aliasCurrentSelectedDef = this.aliasProgramsDef;
						break;
					case 3: /* operator */
						this.aliasCurrentSelectedDef = this.aliasOperatorsDef;
						bShowAddressCols = true;
						break;
					default:
						trace("Out of range");
						break;
				}
				this._dataProviderType = dataProviderIndex;
				dispatchEvent(new Event('dataProviderTypeChanged'));
			}	
				/* reset (When the user clicks on "reset" on the alias header, the alias grid data gets reset) */
			if(dataProviderIndex == -100){
				/* Reset the current selected alias data */
				this.aliasCurrentSelectedDef = new ArrayCollection();
				
				/* Reset all the data which sets the current selected alias data */
				this.aliasDistributorsDef = new ArrayCollection();
				this.aliasItemsDef = new ArrayCollection();
				this.aliasProgramsDef = new ArrayCollection();
				this.aliasOperatorsDef = new ArrayCollection();
			}
			
			if(dataProviderIndex != -1){
				var eOpr:AliasEvent = new AliasEvent(AliasEvent.SHOW_HIDE_ADDRESS_COLS);
				eOpr.bShowAddressCols = bShowAddressCols;
				eOpr.iSelectedTab	 = dataProviderIndex;
				eOpr.sSourceType	 = this.aliasSourceType.toString();//    "100";
				this._dispatcher.dispatchEvent(eOpr);
			}

			/* Reset the "selected Def". Now there is no selected record. */
			ResetAliasSelectedDef();
			
			/* refresh the dataprovider */
			aliasCurrentSelectedDef.refresh();			
			
			/* Whenever a tab is clicked, "show unassigned" checkbox should be unchecked */
			var eventSetShowUnassignedAliases:AliasEvent = new AliasEvent(AliasEvent.SET_SHOW_UNASSIGNED_ALIASES);
			eventSetShowUnassignedAliases.bShowUnassigned = false;
			this._dispatcher.dispatchEvent(eventSetShowUnassignedAliases);
			
			/* 
			whenever a tab is clicked, apart from clearing the checkbox we also need to
			reset the values in the Datagrid so that it does not filter on checkbox. 
			*/ 
			var eventResetInitialFilter:AliasEvent = new AliasEvent(AliasEvent.RESET_INITIAL_FILTER);
			this._dispatcher.dispatchEvent(eventResetInitialFilter);
					
		}		
		
		/* Set the "showUnassigned" property of the checkbox to "TRUE" or "FALSE" */
		public function setShowUnAssigned(showUnassigned:Boolean):void
		{			  
			this._showUnassigned = showUnassigned;
			dispatchEvent(new Event('showUnassignedChanged'));
		}
		
		/* Set the "showUnassigned" property of the checkbox to "TRUE" or "FALSE" */
		public function setShowIgnore(showIgnore:int):void
		{			  
			this._showIgnore = showIgnore;
			dispatchEvent(new Event('showIgnoreChanged'));
		}
		
		/*.................check if all entities have the data ......................*/
		public function checkAllEntityData(entity:int,sourceType:int):void
		{
			iEntityCount = iEntityCount + entity;
			
			/* currently, there are 4 entities - distributors, items, programs and operators. Check whether all the 4 entities have been loaded.
			sourceType = 100 means "All Aliases".
			*/
			if(iEntityCount/4 == 1)
			{			
				this._enableDownloadData = true;
				dispatchEvent(new Event('enableDownloadDataChanged'));
				
				if(sourceType == 100)
				{
					Alert.show('Please click on "download data" for complete Alias information.');
				}
				
				/* Reset the variable */
				iEntityCount = 0;
				
			}
		}
		
		/*.................Call function to generate Excel File......................*/
		/*public function generateExcelFile(entity:int):void
		{
		iEntityCount = iEntityCount + entity;
		
		if(iEntityCount/3 == 1)
		{			
		var eventExportXLS:AliasEvent = new AliasEvent(AliasEvent.EXPORT_XLS);
		this._dispatcher.dispatchEvent(eventExportXLS);	
		iEntityCount = 0;
		}
		}*/
		
		/*.................Generate Excel file......................*/
		
		private function replaceAll( replace_with:String, replace:String, original:String ):String
		{
			var array:Array = original.split(replace_with);
			return array.join(replace);
		}
		
		public function fnExportXLS():void
		{	
			var aliasAllDef:ArrayCollection = new ArrayCollection();
			
			if(this.aliasSourceType == 100){				
				this.aliasAllDef = new ArrayCollection(this.aliasAllDistributorsDef.source.concat(this.aliasAllProgramsDef.source).concat(this.aliasAllItemsDef.source).concat(this.aliasAllOperatorsDef.source));
			}
			else{
				this.aliasAllDef = new ArrayCollection(this.aliasDistributorsDef.source.concat(this.aliasProgramsDef.source).concat(this.aliasItemsDef.source).concat(this.aliasOperatorsDef.source));
			}
			var strAliasList:String  ='';	
			var sEntityType:String = '';
			
			/* (String.fromCharCode(9) means tab) */
			// var strAliasheader:String = 'Type' + String.fromCharCode(9) + 'Alias' + String.fromCharCode(9) + 'Alias Desc' + String.fromCharCode(9) + 'ID' + String.fromCharCode(9) + 'Desc' + String.fromCharCode(9) + 'Source Type' + String.fromCharCode(9) + 'Payee ID';
			var strAliasheader:String = 'Type,Alias,Alias Desc,ID,Desc,Source Type,Payee ID';
			/* Loop through all the aliases. These aliases (as of now) are not a part of the grid. Then a "save" option 
			will appear where the user can save the records as an Excel file on their local machine.
			*/
			for each(var o:Object in this.aliasAllDef)
			{					
				
				if(o.entityType == 0){
					sEntityType = 'distributor';
				}
				else if(o.entityType == 1){
					sEntityType = 'product';				
				}
				else if(o.entityType == 2){
					sEntityType = 'program';					
				}
				else if(o.entityType == 3){
					sEntityType = 'operator';					
				}
				
				//strAliasList = strAliasList + sEntityType + String.fromCharCode(9) + o.aliasID + String.fromCharCode(9) + o.aliasDesc + String.fromCharCode(9) + o.entityID + String.fromCharCode(9) + o.entityDesc + String.fromCharCode(9) + o.sourceTypeDesc + String.fromCharCode(9) + o.payeeID + String.fromCharCode(9) + String.fromCharCode(13) + String.fromCharCode(10);
				strAliasList = strAliasList +  sEntityType + ',="' + o.aliasID + '",' + replaceAll(","," ",o.aliasDesc) + ',="' + o.entityID + '",' + replaceAll(","," ",o.entityDesc) + ',' + replaceAll(","," ",o.sourceTypeDesc) + ',="' + o.payeeID + '",' + String.fromCharCode(13) + String.fromCharCode(10);	
				//strAliasList = strAliasList + sEntityType + ',="' + o.aliasID + '"' + o.aliasDesc + ',"' + o.entityID + ',' + o.entityDesc + ',' + o.sourceTypeDesc + ',="' + o.payeeID + '",' + String.fromCharCode(13) + String.fromCharCode(10);
			}
			
			strAliasList = strAliasheader +  String.fromCharCode(13) + String.fromCharCode(10) + strAliasList;
			downloadFileRef.save(strAliasList,"Alias_List.csv");
		}
		
		public function changeDataGrid(dataGridType:String):void
		{
			this.gridType = dataGridType;
		}
		
		public function setLabelChange(labelText1:String):void{
			this.labelText1 = labelText1;
		}
		
		/**
		 *  Handler for loading data 
		 * @param  String holds the list of items from the csv file */	
		public function loadData(txt:String):void
		{
			var arrItemsToAdd:Array = new Array();

			
			var arrTxtList:Array = StringUtils.listToArray(txt);
			arrTxtList.shift(); // remove the first element (header)
			
			//comma regular expression
			var regExComma:RegExp = /,/g;
			
			/* loop over list and trim whitespace*/
			for each(var i:String in arrTxtList)
			{	
				
				/* The issue was that the data had commas in a CSV file. For a CSV file, double quotes are around the entire row of data.
				Double quotes are also around those entries whihc have a comma.
				Data eg: 
				Data with commas for "Costa Fruit & Produce, Inc.":
				"19671730000, REGION 1 JOH, "Costa Fruit & Produce, Inc.", 18 Bunker Hill Ind. Park,  Boston, MA,  2129, 2059, 0, 03401".
				Data without commas:
				"19671730000, REGION 1 JOH, MaperVille Inc, 18 Bunker Hill Ind. Park,  Boston, MA,  2129, 2059, 0, 03401".
				The objective is to remove the comma in the csv file which is not data separator.
				I tried to use the following regular expression but could not find a complte solution -
				//i.match('\"[a-zA-Z\ 0-9\&\,\.]*\"'));
				//i.match('/"[^"]*"/');		
				
				The current solution is the following:
				First, the row is made into an array with double quotes being the delimter.
				For the above data row (example of data), where there is no comma in the data, flex will create one entry in the array for the entire
				row, but for the row with one or more commas, there will be at least 3 entries in the array. The middle element in 3 element array will 
				have the comma. 
				Below logic will consider extra commas for all elements except the first one and the last one.
				Coomas will be removed from all the elements of the array except the first and the last element.				
				*/
				
				var tmpArr:Array = new Array();				
				var uAliasDef:AliasDef = new AliasDef();
				var counter:int = 0;
				var strData:String = '';
				
				/* If data exists, make an array of the data with double quotes being the delimiter. */
				if(i != '' && i != null){
					tmpArr = StringUtils.listToArray(i,'"');
				}
				
				/* If the data has a comma. Eg: "19671730000, REGION 1 JOH, "Costa Fruit & Produce, Inc.", 18 Bunker Hill Ind. Park,  Boston, MA,  2129, 2059, 0, 03401".
				(Notice the comma for "Costa Fruit & Produce, Inc.").
				*/
				if(tmpArr.length > 1)
				{
					for each(var str:String in tmpArr){
						counter = counter + 1;
						/* Remove the commas from all the elements of the array except the first and the last elment of the array. */
						if(counter != 1 && counter != tmpArr.length){
							strData = strData + str.replace(regExComma,'');
						}
						else{
							strData = strData + str;
						}
						
					}
				}
				else{
					strData = i;
				}
				
				/* Now the data row is cleaned. There are no commas in the data and so an array can be created with commas being the separator. */
				var arr:Array = StringUtils.listToArray(strData,',');
															
				if(arr.length > 0){
					//double quotes regular expression
					var regEx:RegExp = /"/g;

					/* The alias ID (DUN) must exist. */
					if(StringUtils.Trim(arr[0].toString()).length > 0){
						/* update the alias object with the contents of the array. */
							uAliasDef.aliasID = arr[0];
							uAliasDef.aliasRegion =  arr[1];
							uAliasDef.aliasDesc =  arr[2];
							uAliasDef.aliasAddress =  arr[3];
							uAliasDef.aliasCity =  arr[4];
							uAliasDef.aliasState =  arr[5];
							uAliasDef.aliasZIP =  arr[6];
							uAliasDef.aliasUniproNum =  arr[7];
							uAliasDef.aliasLoc =  arr[8];
							uAliasDef.entityID =  arr[9];	
							
						/* create an array of alias objects. */
						arrItemsToAdd.push(uAliasDef);	
					}
				}
				
			}

			var bEntryFound:Boolean = false;
			
			/* Loop through the array which has the alias objects (entries from the file). */
			for each(var objItemAliasLoad:AliasDef in arrItemsToAdd){
				
				bEntryFound = false;
				
				/* Loop through the current data set. */
				for each(var objItemAlias:AliasDef in this.aliasCurrentSelectedDef.source){
					
					/* If the ID matches, then update the alias data on the grid */
					if(objItemAliasLoad.aliasID == objItemAlias.aliasID){
						objItemAlias.aliasRegion = objItemAliasLoad.aliasRegion;
						objItemAlias.aliasDesc = objItemAliasLoad.aliasDesc;
						objItemAlias.aliasAddress = objItemAliasLoad.aliasAddress;								
						objItemAlias.aliasCity = objItemAliasLoad.aliasCity;							
						objItemAlias.aliasState = objItemAliasLoad.aliasState;							
						objItemAlias.aliasZIP = objItemAliasLoad.aliasZIP;
						objItemAlias.aliasUniproNum = objItemAliasLoad.aliasUniproNum;						
						objItemAlias.aliasLoc = objItemAliasLoad.aliasLoc;								
						objItemAlias.entityID = objItemAliasLoad.entityID;	
						
						bEntryFound = true;
						
						break;
					}
				}
				
				/* If the entry from the file does not exist on the grid, then add that entry. */
				if(bEntryFound == false){		
					this.aliasCurrentSelectedDef = new ArrayCollection(this.aliasCurrentSelectedDef.source.concat(objItemAliasLoad));
				}
			}
			/* update "aliasDistributorsDef". */
			this.aliasDistributorsDef = this.aliasCurrentSelectedDef;			
		}
		
	}
}