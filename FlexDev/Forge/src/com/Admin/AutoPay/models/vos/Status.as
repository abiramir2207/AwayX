package com.Admin.AutoPay.models.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Admin.AutoPay.vos.Status")]
	/**
	 * @author
	 */
	public class Status extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var id : int;
		public var description : String = '';
		public var abbreviation : String = '';

		/*-.........................................Constructor..........................................*/
		
		public function Status(st:Status = null){
			
			if( st ) copy( st );
		}
		
		/*-.........................................Methods..........................................*/
		public function copy(st:Status):void
		{
			this.id = st.id;
			this.description = st.description;
			this.abbreviation = st.abbreviation;
			
		}

	}
}