package com.Billback.Edit.views.renderer
{
	import mx.controls.MenuBar;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.ListData;
	import mx.controls.menuClasses.IMenuBarItemRenderer;
	import mx.controls.menuClasses.MenuBarItem;
	import mx.controls.menuClasses.MenuItemRenderer;
	import mx.controls.menuClasses.MenuListData;
	
	public class MenuBarItemRendererBA extends MenuBarItem
	{

		
		public function MenuBarItemRendererBA()
		{
			super();
		}
		
		override public function set data(value:Object):void{
			if(value == null) return;
			super.data = value;
			if(this.label){
				this.label.toolTip = value.toolTip;
			}
			else{
				this.toolTip =  value.toolTip;
			}
			
		}

		
	}
}