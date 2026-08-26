package com.vos
{
	import mx.collections.ArrayCollection;
	[Bindable]
	public class OperatorCollection 
	{
		/*-.........................................Properties..........................................*/
		public var iList:ArrayCollection;
		
		static public var currentIndex : uint = 1000;
		
		/*-.........................................Constructor..........................................*/
		public function OperatorCollection(	iList:ArrayCollection = null ) 
		{
			this.iList = iList;
		}
		
		/*-.........................................Methods..........................................*/
		public function copyFrom(newList:OperatorCollection):void 
		{
			this.iList = newList.iList;
			
		}
	}
}
