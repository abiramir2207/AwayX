package com.shared.components.spark
{

	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	import spark.components.VGroup;
	
	
	
	public class BorderContainerLabel extends BorderContainer
	{
		public var label:Label = new Label();
		//[Bindable]
		//public var sText:String = '';
		
		/*.................iHeight......................*/
		private var _iHeight:Number = 17;
		[Bindable (event="iHeightBdrCtrChanged")]
		public function get iHeight():Number
		{
			return _iHeight;
		}
		public function set iHeight(i:Number):void
		{			
			this._iHeight = i;
			this.height = i;
			dispatchEvent(new Event('iHeightBdrCtrChanged'));	
		}
		/*.................iWidth......................*/
		private var _iWidth:Number = 240;
		[Bindable (event="iWidthBdrCtrChanged")]
		public function get iWidth():Number
		{
			return _iWidth;
		}
		public function set iWidth(i:Number):void
		{			
			this._iWidth = i-4;
			dispatchEvent(new Event('iWidthBdrCtrChanged'));
			this.width = iWidth;
			this.invalidateDisplayList();		
		}
		
		/* sText for label.text */
		private var _sText:String = '';
		[Bindable (event="sTextChanged")]
		public function get sText():String
		{
			return _sText;
		}
		public function set sText(s:String):void
		{
			this._sText = s;
			this.label.text = s;
			dispatchEvent(new Event('sTextChanged'));
		}
		
		/* sToolTip for label.toolTip */
		private var _sToolTip:String = '';
		[Bindable (event="sToolTipChanged")]
		public function get sToolTip():String
		{
			return _sToolTip;
		}
		public function set sToolTip(s:String):void
		{
			this._sToolTip = s;
			this.label.toolTip = s;
			dispatchEvent(new Event('sToolTipChanged'));
		}
		
		public function BorderContainerLabel()
		{
			super();
		}
		override protected function createChildren():void{
			super.createChildren();
			this.setStyle('borderWeight',0); //borderWeight="0"
			this.setStyle('backgroundColor','0xffbf5f');//backgroundColor="{this.pModel.sLbaleColor}"
			this.setStyle('backgroundAlpha',0.3);//backgroundAlpha="{this.pModel.nBgAlpha}"
			this.setStyle('borderVisible',false);//borderVisible="false"
			this.setStyle('borderColor','white');//borderColor="white"
			this.setStyle('cornerRadius',4);// cornerRadius="4"
			this.height = this.iHeight; //height="{iHeight + 1}"
			this.width = this.iWidth;
			this.percentWidth = 100;
			//if(!label){
				/*var vg:VGroup = new VGroup();
				vg.verticalAlign = 'bottom';
				vg.paddingBottom = 0;
				vg.paddingLeft = 0;
				vg.paddingRight = 0;
				vg.paddingTop = 0;*/
				label = new Label();
				label.setStyle('textAlign',"center");
				label.setStyle('verticalAlign',"bottom");
				label.text= this.sText;
				label.toolTip = this.sToolTip;
				label.width = iWidth;
				//label.percentWidth = 100;
				label.setStyle('fontWeight',"bold");
				label.setStyle('paddingTop',"3");
				label.setStyle('paddingRight',"2");
				label.setStyle('paddingLeft',"2");
				label.setStyle('paddingBottom',"0");
				//vg.addElement(label);
				this.addElement(label);
			//}
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
	}
}