package com.shared.components
{
	/***************************************************************
	 * @author http://flexoop.com/2009/02/update-to-menuitem-class/
	 **************************************************************/
	
	[Bindable]
	public class MenuItem {
		
		/***********************************
		 * properties
		 **********************************/
		
		private var _enabled:Boolean = true;
		private var _groupName:String = "";
		private var _icon:Class;
		private var _label:String = "";
		private var _menuHandler:Function;
		private var _toggled:Boolean = true;
		private var _type:String = "";
		private var _children:Array = null;
		private var _args:Array = null;
		private var _toolTip:String = null;
		
		/***********************************
		 * getters
		 **********************************/
		
		public function get enabled():Boolean {
			return this._enabled;
		}
		
		public function get groupName():String {
			return this._groupName;
		}
		
		public function get icon():Class {
			return this._icon;
		}
		
		public function get label():String {
			return this._label;
		}
		
		public function get menuHandler():Function {
			return this._menuHandler;
		}
		
		public function get toggled():Boolean {
			return this._toggled;
		}
		
		public function get type():String {
			return this._type;
		}
		
		public function get children():Array {
			return this._children;
		}
		
		public function get args():Array {
			return this._args;
		}
		
		public function get toolTip():String {
			return this._toolTip;
		}
		
		/***********************************
		 * setters
		 **********************************/
		
		public function set enabled( value:Boolean ):void {
			this._enabled = value;
		}
		
		public function set groupName( value:String ):void {
			this._groupName = value;
		}
		
		public function set icon( value:Class ):void {
			this._icon = value;
		}
		
		public function set label( value:String ):void {
			this._label = value;
		}
		
		public function set menuHandler( value:Function ):void {
			this._menuHandler = value;
		}
		
		public function set toggled( value:Boolean ):void {
			this._toggled = value;
		}
		
		[Inspectable(enumeration=separator,check,radio,normal)]
		public function set type( value:String ):void {
			this._type = value;
		}
		
		public function set children( value:Array ):void {
			this._children = value;
		}
		
		public function set args( value:Array ):void {
			this._args = value;
		}
		public function set toolTip( s:String ):void {
			this._toolTip = s;
		}
		
		public function MenuItem( label:String="", menuHandler:Function=null, args:Array=null, enabled:Boolean=true, type:String="normal", toggled:Boolean=true, groupName:String="", icon:Class=null,toolTip:String="") {
			this.enabled = enabled;
			this.groupName = groupName;
			this.icon = icon;
			this.label = label;
			this.menuHandler = menuHandler;
			this.toggled = toggled;
			this.type = type;
			this.args = args;
			this.toolTip = toolTip;
		}
		
	}
}