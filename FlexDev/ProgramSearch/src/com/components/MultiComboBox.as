package com.components
{
import flash.events.Event;
import flash.events.KeyboardEvent;


import mx.controls.ComboBox;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.controls.Alert;

public class MultiComboBox extends ComboBox
{ 
private var ctrlKey:Boolean = false;

public function MultiComboBox()
{
	super();
}

override public function close(trigger:Event=null) : void
{
	if ( !ctrlKey ) 
	{
	super.close( trigger );
	}
}

override protected function keyDownHandler(event:KeyboardEvent) : void
{
	super.keyDownHandler( event );

	ctrlKey = event.ctrlKey;

	if ( ctrlKey )
	{
	dropdown.allowMultipleSelection = true;
	}
}

override protected function keyUpHandler(event:KeyboardEvent) : void
{	
	super.keyUpHandler( event );

	ctrlKey = event.ctrlKey;
	/* Dev Note: Milan (23553) event.keyCode less than 
	  48 are keyboard keys which are not letters or numbers.
	*/
	if ( (!ctrlKey) && event.keyCode <48) 
	{
	close(); 
	//var changeEvent:ListEvent = new ListEvent( ListEvent.CHANGE )
	//dispatchEvent( changeEvent );
	}
}

public function set selectedItems( value:Array ) : void
{
	if ( dropdown )
	{
	dropdown.selectedItems = value;
	}
}

[Bindable("change")]
public function get selectedItems( ) : Array
{
	if ( dropdown )
	{
		return dropdown.selectedItems;
	}

	else
	{
		return null;
	}
}

public function set selectedIndices( value:Array ) : void
{
	if ( dropdown )
	{
		dropdown.selectedIndices = value;
	}
}

[Bindable("change")]
public function get selectedIndices( ) : Array
{
	if ( dropdown )
	{
		return dropdown.selectedIndices;
	}
	
	else
	{
		return null;
	}
}

override public function itemToLabel(item:Object):String
{
	var label : String = "";
	
		if(!selectedItems || selectedItems.length == 1)
		{
 			return super.itemToLabel(item);
 		}
		else
		{
				for each( var object : Object in selectedItems )
				{
						/* Do not add the default value, starting with "Show All", to the serach string */
						if(super.itemToLabel(object).indexOf('Show All') == -1
						&& super.itemToLabel(object).indexOf('Select') == -1)
						{ 
							label += super.itemToLabel(object) + ",";
						}
				}
		}
		if(selectedItems.length == 1)
		{
			return label.substring(0,label.length);
		}
		else
		{
			return label.substring(0,label.length - 1);
		}
}

}
}