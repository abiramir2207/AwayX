package com.Billback.Main.models.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.Status")]
	/**
	 * @author Milan
	 */
	public class Status extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var id : int;
		public var description : String = '';
		public var abbreviation : String = '';
		public var subStatus : int;
		public var subStatusDescription : String = '';

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
			this.subStatus= st.subStatus;
			this.subStatusDescription = st.subStatusDescription;
			
		}

	}
}