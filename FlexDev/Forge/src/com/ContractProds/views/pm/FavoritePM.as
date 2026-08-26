package com.ContractProds.views.pm
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.ui.Keyboard;
	import com.ContractProds.events.SearchEvent;
	import com.shared.vos.Settings;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	import mx.collections.ArrayCollection;
	
	public class FavoritePM extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function FavoritePM( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		
		/*.......................  Properties  .......................*/
		[Bindable] public var arrSavedItems:Array = new Array();
		[Bindable] public var arrUserList:Array = new Array();
		[Bindable] public var items:ArrayCollection = null;	
		[Bindable] public var tListName:String = '';
		
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
		
		/*  selectedItem */
		private var _selectedItem:*;
		[Bindable (event="pmSelectedItemChanged")]
		public function get selectedItem():*
		{
			return _selectedItem;
		}
		public function set selectedItem(s:*):void
		{
			this._selectedItem = s;
			dispatchEvent(new Event('pmSelectedItemChanged'));
		}
		
		/*  setSelectedItem*/
		public function setSelectedItem( value:*):void
		{
			this._selectedItem = value;
			dispatchEvent(new Event('pmSelectedItemChanged'));
		}
		/*  update oFilterParms.brand*/
		public function updatetListName(  value:String):void
		{
			this.tListName = value;

		}
		
		/*.......................  Methods  .......................*/
		
		/* Handle the Create List Button click */
			public function callCreateList(txt:String):void
				{
					/* Dispatch Event */
					var event:SearchEvent = new SearchEvent(SearchEvent.CREATE_LIST);
					event.iList = txt;
					this.dispatcher.dispatchEvent(event);
					/* clear the Filter Selected checkbox */
			// NEED this.chBoxReset();
				}
				
			/* Handle the Get List Items Button Click (btnGetListItems)  or (lsUserList) DOUBLE_CLICK */
			public function getUserListItems():void
				{
					if(!this.selectedItem)
					{
						Alert.show("Please select a list to display");
					}
					else
					{
						/* Dispatch Event */
						var event:SearchEvent = new SearchEvent(SearchEvent.GET_USERLIST_ITEMS);
						event.arrUserListItems = this.selectedItem.DATA;
						this.dispatcher.dispatchEvent(event);
				// NEED this.chBoxReset();
						/* flag the items as selected */
						//this.chSelectAll.selected = true;
						//this.selectAll();
					}
				}
			/*  handler for when a user presses enter on a Saved user List row (lsUserList)*/
			 public function enterUserListRow(event:KeyboardEvent):void 
			 	{                
			 		if (event.keyCode == Keyboard.ENTER) 
			 		/* ITEM_DOUBLE_CLICK calls getUserList()   */                   
			 		this.getUserListItems();
			 	}

			/* Handle the Save My Lists Button Click (btnSaveUserList)*/
			public function saveUserList():void
				{
					if(tListName.length == 0)
					{
						Alert.show("Please enter a name for your saved list");
					}
					else
					{
						/* Limit the favorites entries to 25 */
						if(arrUserList.length == 25){
							Alert.show("The limit for the favorites list is 25. Either delete one or edit an existing one.");
						}
						else
						{
						/* First filter so we only see selected items */
						var fEvent:SearchEvent = new SearchEvent(SearchEvent.FILTER_SELECTED);
						this.dispatcher.dispatchEvent(fEvent);
						/* create an array of the selected items */
						var tmpArrItems:Array = new Array();
						for each(var oItem:Object in this.items)
								{
									if(oItem['isSelected'] == 1 && tmpArrItems.indexOf(oItem['baItem']) == -1)
										{tmpArrItems.push(oItem['baItem'])}
								}
						/* Dispatch Event */
						var event:SearchEvent = new SearchEvent(SearchEvent.SAVE_USERLIST);
						event.userId = this.oSettings.userId;
						event.arrUserListItems = tmpArrItems;
						event.userListItemsName = tListName;
						this.dispatcher.dispatchEvent(event);
						}
					}
				}
			/* Handle the Get My Lists Button Click (btnGetLists)*/
			public function deleteUserList():void
				{
					/* update the dp */
					if(this._selectedItem)
					{
						Alert.show("Please select a list to delete");
					}
					else
					{
						/* Dispatch Event */
						var event:SearchEvent = new SearchEvent(SearchEvent.DELETE_USERLIST);
						event.userListId = this._selectedItem.USER_ITEM_LIST_ID;
						this.dispatcher.dispatchEvent(event);
					}
				}

	}
}