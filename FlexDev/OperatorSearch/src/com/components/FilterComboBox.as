package com.components 
{ 
        import flash.events.Event; 
        import flash.events.KeyboardEvent; 
        import flash.events.MouseEvent; 
        import mx.controls.ComboBox; 
        import mx.events.ListEvent; 
        public class FilterComboBox extends ComboBox 
        { 
                private var ctrlKey:Boolean = false; 
                public function FilterComboBox() 
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
                                close(); 
                                var changeEvent:ListEvent = new ListEvent( ListEvent.CHANGE ) 
                                dispatchEvent( changeEvent ); 
                        } 
                } 
                public function set selectedItems( value:Array ) : void 
                { 
                        if ( dropdown ) 
                                dropdown.selectedItems = value; 
                } 
                [Bindable("change")] 
                public function get selectedItems( ) : Array 
                { 
                        if ( dropdown ) 
                                return dropdown.selectedItems; 
                        else 
                                return null; 
                } 
                public function set selectedIndices( value:Array ) : void 
                { 
                        if ( dropdown ) 
                                dropdown.selectedIndices = value; 
                } 
                [Bindable("change")] 
                public function get selectedIndices( ) : Array 
                { 
                        if ( dropdown ) 
                                return dropdown.selectedIndices; 
                        else 
                                return null; 
                } 
        } 
}