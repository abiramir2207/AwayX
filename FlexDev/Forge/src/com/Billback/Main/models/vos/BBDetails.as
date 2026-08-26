package com.Billback.Main.models.vos
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;

	/**
	 * @author Milan
	 */

	[Bindable]
	[RemoteClass(alias="mvc.Models.Billback.vos.BBDetails")]
	public class BBDetails extends EventDispatcher		
	{
		/*-.........................................Properties..........................................*/
		public var billbackIDInt: int 			= 0;
		public var lockedBy: String			= '';
		public var documentList:Array;	
		public var domainName:String 			= '';
		public var uniqueFileName:Array;
		public var interfaceMessage:String 	= '';
		public var expectedAmount:Number 		= 0;
		public var paidAmount:Number 			= 0;
		public var claimedVsExpected:Number 	= 0;
		public var claimedVsPaid:Number 		= 0;
		public var expectedVsPaid:Number 		= 0;
		public var CRADetails:ArrayCollection;
		public var workflowAction:ArrayCollection;
		public var NRADetails:ArrayCollection;

		/*-.........................................Constructor..........................................*/
		public function BBDetails( bbDetail:BBDetails = null )
		{
					if( bbDetail ) copy( bbDetail );
		}
		/*-.........................................Methods..........................................*/
		public function copy(bbDetail:BBDetails):void
		{
			this.billbackIDInt = bbDetail.billbackIDInt;
			this.lockedBy = bbDetail.lockedBy;
			this.documentList = bbDetail.documentList;
			this.domainName = bbDetail.domainName;
			this.uniqueFileName = bbDetail.uniqueFileName;
			this.interfaceMessage = bbDetail.interfaceMessage;
			this.expectedAmount = bbDetail.expectedAmount;
			this.paidAmount = bbDetail.paidAmount;
			this.claimedVsExpected = bbDetail.claimedVsExpected;
			this.claimedVsPaid = bbDetail.claimedVsPaid;
			this.expectedVsPaid = bbDetail.expectedVsPaid;
			this.CRADetails = bbDetail.CRADetails != null ? this.clone(bbDetail.CRADetails) : null;
			this.workflowAction = bbDetail.workflowAction != null ? this.clone(bbDetail.workflowAction) : null;
			this.NRADetails = bbDetail.NRADetails != null ? this.clone(bbDetail.NRADetails) : null;
			
		}
		
		private function clone(source:Object):*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			var ret:* = myBA.readObject();
			return(ret);
		}

	}
}		