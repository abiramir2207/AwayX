package com.ContractProds.models
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class ProdUploadManager extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var dispatcher:IEventDispatcher;
		public function ProdUploadManager( dispatcher:IEventDispatcher ):void
		{
			this.dispatcher = dispatcher;
		}
		/*.......................  Properties  .......................*/
		
		
		/*.......................  Methods  .......................*/

	}
}