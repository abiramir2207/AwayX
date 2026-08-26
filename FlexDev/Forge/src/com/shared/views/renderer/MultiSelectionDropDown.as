package com.shared.views.renderer
{
    import com.shared.components.MultiSelectItemRenderer;
    import com.shared.components.MultiSelectionDropDownListSkin;
    
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import mx.collections.ArrayList;
    import mx.collections.ItemWrapper;
    import mx.controls.Alert;
    import mx.controls.CheckBox;
    import mx.controls.LinkButton;
    import mx.core.IFactory;
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.utils.ObjectUtil;
    
    import spark.components.CheckBox;
    import spark.components.DataRenderer;
    import spark.components.DropDownList;
    import spark.components.Label;
    import spark.events.DropDownEvent;
	
	[Event(name="selectionChange", type="flash.events.Event")] 
	public class MultiSelectionDropDown extends DropDownList
	{
		[SkinPart(required="true")]
		public var lnkSelectAll:LinkButton;
		[SkinPart(required="true")]
		public var lnkDeSelectAll:LinkButton;
		[SkinPart(required="true")]
		public var labelDisplayBa:Label;
		//[SkinPart(required="true")]
		public var checkbox:spark.components.CheckBox;

		/* display text for dropdown
		.................currentlySelectedCheckBoxes......................*/
		private var _slabelDisplay:String = '';
		[Bindable (event="labelChange")]
		public function get slabelDisplay():String
		{
			return _slabelDisplay;
		}
		public function set slabelDisplay(s:String):void
		{
			
			this._slabelDisplay = s;
			this.labelDisplayBa.text = s;
			super.labelDisplay.text = s;
			dispatchEvent(new Event("labelChange"));
		}
		
		/**
		 * constructor
		 */
		public function MultiSelectionDropDown()
		{
			super();
			var chk:spark.components.CheckBox = new spark.components.CheckBox();
			this.addEventListener(DropDownEvent.OPEN, onOpen, false, 0, true);
		}
		
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle("skinClass",Class(com.shared.components.MultiSelectionDropDownListSkin));
		}
		
		/** selected check boxes */
		//public var currentlySelectedCheckBoxes:Array = new Array();
		
		/* keeps track of check box selections
		.................currentlySelectedCheckBoxes......................*/
		private var _currentlySelectedCheckBoxes:Array = new Array();
		[Bindable (event="currentlySelectedCheckBoxesChange")]
		public function get currentlySelectedCheckBoxes():Array
		{
			return _currentlySelectedCheckBoxes;
		}
		public function set currentlySelectedCheckBoxes(arr:Array):void
		{

			this._currentlySelectedCheckBoxes = arr;	
			dispatchEvent(new Event("currentlySelectedCheckBoxesChange"));
			//dispatchEvent(new Event("selectionChange"));
			this.callLater(setLableDisplay);
			//this.setLableDisplay();
		}
		
		/**
		 * selectedItems getter (inclusive of check boxes on item renderer)
		 * 
		 * @return array
		 * used in renderer binding for setting selections (selectedItem or currentlySelectedCheckBoxes).
		 * accepts a 1 item array and sets that as selected Item as opposed to checking the box
		 */
		public function set currentSelection(arr:Array):void
		{
			//refresh the dp so updates are recognized :: Hack! is there a better way?
			if(this.dataProvider){
				this.dataProvider = new ArrayList(this.dataProvider.toArray().concat());
			}
			
			if(arr){
				if(arr.length > 1){
					this.currentlySelectedCheckBoxes = arr;
				}
				else if(arr.length == 1){
					for each(var o:* in this.dataProvider.toArray()){
						var bSimpleType:Boolean = ObjectUtil.isSimple(o);
						if(bSimpleType){
							if (o == arr[0]){
								this.selectedItem = o;
								break;
							}
						}
						else{
							if (o[this.labelField] == arr[0][this.labelField]){
								this.selectedItem = o;
								break;
							}	
						}	
					}
					this.currentlySelectedCheckBoxes = [];
				}
				else{
					this.currentlySelectedCheckBoxes = [];
				}
			}
		}

		/**
		 * selectedItems getter (inclusive of check boxes on item renderer)
		 * 
		 * @return array
		 * Used in renderer for selection updates
		 * Dispatched on dropdown close only
		 */
		[Bindable (event="selectionChange")]
		public function get arrSelectedItems():Array {
			if (currentlySelectedCheckBoxes.length > 0) {
				return this.currentlySelectedCheckBoxes;
			} 
			else if(this.selectedItem) {
				return [this.selectedItem];
			}
			else {
				return new Array();
			}
		}
		
		
		/**
		 *  handler for opening the dropdown
		 *  
		 *  @param dropdown event
		 */ 
		public function onOpen(event:DropDownEvent):void {
			//add listeners for select all and deselect all (link is declared in SKIN)
			lnkSelectAll.addEventListener(MouseEvent.CLICK, selectAll, false, 0, true);
			lnkDeSelectAll.addEventListener(MouseEvent.CLICK, deSelectAll, false, 0, true);
		}

		
		/**
		 * item mouse down handler
		 * 
		 * @param mouse event
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void {
			
			if (currentlySelectedCheckBoxes.length == 0) {
				super.item_mouseDownHandler(event);
			} else {
				//if target == RichText (click from an item and not a check box) -> add to selected list
				if(event.target.className == 'RichText'){
					
					setCurrentlySelectedCheckBoxes(event.currentTarget.data);
				}
				closeDropDown(true);
			}
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void{
			//super.keyDownHandler(event);
			/*if(!event.ctrlKey){
				if(event.keyCode == 40 && event.keyLocation == 0 && event.currentTarget.caretIndex < this.dataProvider.toArray().length - 1)// (super.selectedIndex != -1)
				{
					this.currentlySelectedCheckBoxes = new Array();
					this.selectedIndex = event.currentTarget.caretIndex + 1;
					dispatchEvent(new Event("selectionChange"));
					//this.invalidateProperties();
					this.callLater(setLableDisplay);
				}
				else if(event.keyCode == 38 && event.keyLocation == 0 && event.currentTarget.caretIndex > 0)// (super.selectedIndex != -1)
				{
					this.currentlySelectedCheckBoxes = new Array();
					this.selectedIndex = event.currentTarget.caretIndex - 1;
					dispatchEvent(new Event("selectionChange"));
					//this.invalidateProperties();
					this.callLater(setLableDisplay);
				}
			}*/
			super.keyDownHandler(event);
			if(this.selectedIndex != -1){
				dispatchEvent(new Event("selectionChange"));
				this.callLater(setLableDisplay);
			}
			
				
		}
		/*override protected function itemSelected(index:int, selected:Boolean):void{
			if(selected && index != -1){
				setCurrentlySelectedCheckBoxes(this.dataProvider.toArray()[index]);
			}
			else{
				var arr:Array = this._currentlySelectedCheckBoxes;
				arr.splice(index,1);
				//set the property -> fires setter
				this.currentlySelectedCheckBoxes = arr;
			}
			super.itemSelected(index,selected);
		}*/

		/**
		 *  @private
		 *  Event handler for the <code>dropDownController</code> 
		 *  <code>DropDownEvent.CLOSE</code> event. Updates the skin's state.
		 */
		protected override function dropDownController_closeHandler(event:DropDownEvent):void
		{
			//if (currentlySelectedCheckBoxes.length > 1) {// || selectedIndex == -1
				// if checkboxes are selected prevent the default behavior, which is to set a selection index
				event.preventDefault();
			//}
			//isDefaultPrevented
			super.dropDownController_closeHandler(event);
			//ONLY DISPATCH ON CLOSE (PREVENT EVENT FIRESTORM)
			dispatchEvent(new Event("selectionChange"));
			this.callLater(setLableDisplay);
			//this.setLableDisplay();
		}

		/**
		 * togglecheck Box selection (chkSelectAll eventlistener)
		 */
		protected function selectAll(event:Event):void {
			selectedIndex = -1;
			this._currentlySelectedCheckBoxes = new Array();
			var arr:Array = this._currentlySelectedCheckBoxes;
			for each(var obj:* in this.dataProvider.toArray()) {
				//if selected
				arr.push(obj);
				//let view (checkboxes) know we are updated
				this.dataProvider.itemUpdated(obj);
			}
			//set the property -> fires setter
			this.currentlySelectedCheckBoxes = arr;

		}
		
		protected function deSelectAll(event:Event):void {
			selectedIndex = -1;
			this.currentlySelectedCheckBoxes = new Array();

			for each(var obj:* in this.dataProvider.toArray()) {
				//let view (checkboxes) know we are updated
				this.dataProvider.itemUpdated(obj);
			}
			this.commitSelection(true);
		}
		
		/**
		 * on click checkbox (stop event from going to underlying item renderer)
		 * 
		 * @param change event
		 */
		public function mouseCheckBox(event:Event):void {
			event.stopImmediatePropagation();
		}
		
		public function setLableDisplay():void{
			if (currentlySelectedCheckBoxes){
				// multiple selected check boxes
				if (currentlySelectedCheckBoxes.length > 1 ) {
					
					slabelDisplay = currentlySelectedCheckBoxes.length.toString() + " selections";
					selectedIndex = -1;
				}
				//only 1 check box so display that item in labelField
				else if(currentlySelectedCheckBoxes.length == 1){
					/* Added "this.labelField != 'label'" for dropdowns which dor have a label field. We probably do not need slabelDisplay
					   at all even for dropdowns which have a labelField.
					 */
					if(this.labelField != 'label'){
						slabelDisplay = this.currentlySelectedCheckBoxes[0][this.labelField];
					}
					else{
						slabelDisplay = this.currentlySelectedCheckBoxes[0];
					}
					selectedIndex = this.dataProvider.toArray().indexOf(this.currentlySelectedCheckBoxes[0]);
				}
				/*else if(selectedIndex != -1){
					// Added "this.labelField != 'label'" for dropdowns which dor have a label field. We probably do not need slabelDisplay
				  // at all even for dropdowns which have a labelField. 
					if(this.labelField != 'label'){
						slabelDisplay = this.dataProvider.toArray()[selectedIndex][this.labelField];
					}
				}*/
				else if(this.arrSelectedItems.length == 1){
					if(this.labelField != 'label'){
						slabelDisplay = this.arrSelectedItems[0][this.labelField];
					}
					else{
						slabelDisplay = this.arrSelectedItems[0];
					}
					selectedIndex = this.dataProvider.toArray().indexOf(this.arrSelectedItems[0]);
				}
				else if(currentlySelectedCheckBoxes.length == 0){
					slabelDisplay = "";
					selectedIndex = -1;
				}
			}
			else{
				slabelDisplay = "";
				selectedIndex = -1;
			}
			this.invalidateDisplayList();
		}
		
		private function setCurrentlySelectedCheckBoxes(data:*):void{
			var arr:Array = this._currentlySelectedCheckBoxes;
			var i:int = currentlySelectedCheckBoxes.indexOf(data,arr);
			//if not already in the selected list
			if(this.getIx(data) == -1){
				arr.push(data);
				//set the property -> fires setter
				this.currentlySelectedCheckBoxes = arr;
			}
		}
		//get index of an item (when selected items come from db and they are complex objects)->find ix is needed base don labelfield
		private function getIx(data:*):int{
			var i:int = 0;
			var ix:int = -1;
			//loop to find item (currentlySelectedCheckBoxes can come from db)
			for each(var o:* in this._currentlySelectedCheckBoxes){
				var bSimpleType:Boolean = ObjectUtil.isSimple(o);
				if(bSimpleType){
					if (o == data){
						ix = i;
						break;
					}
				}
				else{
					if (o[this.labelField] == data[this.labelField]){
						ix = i;
						break;
					}	
				}
				i++
			}
			return ix;
		}
		
		/**
		 * on change checkbox
		 * 
		 * @param change event
		 */
		
		public function changeCheckBoxSelection(event:Event):void {
			var obj:MultiSelectItemRenderer = event.currentTarget.document as MultiSelectItemRenderer;
			var data:* = obj.data;
			var b:Boolean = obj.checkbox.selected;
			//if checked -> add to selected array
			if(b){
				setCurrentlySelectedCheckBoxes(data);
			}
			//else -> unchecked remove from selected array
			else{
				// get index of item from selectedItems
				var i:int = this.getIx(data);
				if(i != -1){
					var arr:Array = this._currentlySelectedCheckBoxes;
					arr.splice(i,1);
					//set the property -> fires setter
					this.currentlySelectedCheckBoxes = arr;
				}
			}
			this.dataProvider.itemUpdated(data);
	
		}
	}
    
    
}
