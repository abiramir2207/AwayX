package com.components 
{ 
        import flash.events.Event; 
        import flash.events.KeyboardEvent; 
        import flash.events.MouseEvent; 
        import mx.controls.ComboBox; 
        import mx.events.ListEvent; 
        public class MultiComboBox extends ComboBox
        { 
                private var ctrlKey:Boolean = false;
                private var indices:Array; 
                private var sItems:Array;
                public function MultiComboBox() 
                { 
                        super(); 
                        //dropdown.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler); 
                } 
                public function mouseOutHandler(e:MouseEvent):void 
                { 
                        super.close() 
                } 
                override public function close(trigger:Event=null) : void 
                { 
                        //if(dropdown.mo) 
                         if ( !ctrlKey )
                       // if(dropdown.visible == false) 
                                super.close( trigger ); 
                } 
                override protected function keyDownHandler(event:KeyboardEvent) : void 
                { 
                        super.keyDownHandler( event ); 
                        ctrlKey = event.ctrlKey; 
                        if ( ctrlKey ) 
                                dropdown.allowMultipleSelection = true; 
                } 
                override protected function keyUpHandler(event:KeyboardEvent) : void 
                { 
                        super.keyUpHandler( event ); 
                        ctrlKey = event.ctrlKey; 
                        if ( !ctrlKey ) 
                        { 
                                super.close(); 
                               // var changeEvent:ListEvent = new ListEvent( ListEvent.CHANGE ) 
                                //dispatchEvent( changeEvent ); 
                        } 
                } 
                public function set selectedItems( value:Array ) : void 
                { 
                        if ( dropdown ) 
                                dropdown.selectedItems = value;
                       // else {
						//this.sItems = value; // Save the value in private array	
						//callLater(this.setSelItems); // Request function setIndices be called later
					//} 
                } 
                [Bindable("change")] 
                public function get selectedItems( ) : Array 
                { 
                        if ( dropdown ) 
                                return dropdown.selectedItems; 
                        else 
                                return null; 
                } 

                [Bindable("change")] 
                public function get selectedIndices( ) : Array 
                { 
                        if ( dropdown ) 
                                return dropdown.selectedIndices; 
                        else 
                                return null; 
                }
                public function set selectedIndices( value:Array ) : void
				{
				if ( dropdown ) {
						dropdown.selectedIndices = value;
						/* for each(var i:int in value)
							{
								this.selectedIndex = i;
							} */
					} 
				else {
						this.indices = value; // Save the value in private array	
						callLater(this.setIndices); // Request function setIndices be called later
				}
				}
				public function setIndices():void
				{
					this.selectedIndices = this.indices;
					//this.validateProperties();
				}
				
				/* public function setSelItems():void
				{
					this.selectedItems = this.sItems;
				} */
				/*   override public function set selectedIndex(value:int):void
                { 
                      dropdown.allowMultipleSelection = true;
                       super.selectedIndex = value;
                       this.selectedIndices.push(value);
                       this.validateProperties();
                        
                } */  
               override public function set selectedItem(value:Object):void 
		        { 
		            if (value == null) 
		            { 
		                super.selectedIndex = -1; 
		            } 
		            else 
		            { 
		                super.selectedItem = value;
		               // this.selectedIndices.push(this.selectedIndices.length);
		            } 
		        } 

        override public function set dataProvider(value:Object):void 
	        { 
				var l_savedSelectedItem:Object = super.selectedItem; 
	        	super.dataProvider = value; 
	        	super.selectedItem = l_savedSelectedItem; 
	        } 
	        
        } 
}