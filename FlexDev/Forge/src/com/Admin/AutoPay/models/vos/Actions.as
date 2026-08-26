package com.Admin.AutoPay.models.vos
{
	import flash.events.EventDispatcher;

	[Bindable]
	//[RemoteClass(alias="mvc.Models.Admin.AutoPay.vos.AutoPayDetail")]
	public class Actions extends EventDispatcher
	{
		/*-.........................................Properties..........................................
		approve delete copy edit run*/
		/** 
		 * Flag that specifies if the Current Report is "Approvable"
		 */
		public var bApprove:Boolean;
		/** 
		 * Flag that specifies if the Current Report is "Deleteable"
		 */
		public var bDelete:Boolean;
		/** 
		 * Flag that specifies if the Current Report is "Copyable"
		 */
		public var bCopy:Boolean = true;
		/** 
		 * Flag that specifies if the Current Report is "Editable"
		 */
		public var bEdit:Boolean;
		/** 
		 * Flag that specifies if the Current Report is "Runable"
		 */
		public var bRun:Boolean;
		/** 
		 * Flag that specifies if the Admin screen is in "EditMode"...or Locked by current user
		 */
		public var bEditMode:Boolean;
		/** 
		 * Flag that specifies if the Current Report is "Exportable"...can be downloaded to excel
		 */
		public var bExport:Boolean;
		/** 
		 * string that populates the Approve Icon Tooltip
		 */
		public var sApproveTip:String = '';
		/** 
		 * string that populates the Delete Icon Tooltip
		 */
		public var sDeleteTip:String = '';
		/** 
		 * string that populates the Copy Icon Tooltip
		 */
		public var sCopyTip:String = '';
		/** 
		 * string that populates the Edit Icon Tooltip
		 */
		public var sEditTip:String = '';
		/** 
		 * string that populates the Run Icon Tooltip
		 */
		public var sRunTip:String = '';
		/** 
		 * string that populates the Export Icon Tooltip
		 */
		public var sExportTip:String = '';
		
		/*-.........................................Constructor..........................................*/
		public function Actions(a:Actions = null)
		{
			if( a ) copy( a );
		}

		/*-.........................................Methods..........................................*/
		public function copy( a:Actions ):void
		{
			this.bApprove = a.bApprove;
			this.bCopy = a.bCopy;
			this.bDelete = a.bDelete;
			this.bEdit = a.bEdit;
			this.bRun = a.bRun;
			this.bExport = a.bExport;	
		}
		/**
		 * Update the Properties based on the Report status (i:int) passed into the method.
		 * reportId is used to populate the ToolTip Properties
		 */
		public function setPermissions( i:int,reportId:Number = 0 ):void
		{
			var s:String = ''
			//reset tooltip text
			this.sApproveTip = '';
			this.sDeleteTip = '';
			this.sCopyTip = '';
			this.sEditTip = '';
			this.sRunTip = '';
			this.sExportTip = '';
			if(reportId != 0){
				s = reportId.toString();
			}
			//SET the availibilty b:Bool base don status
			//Only set Tooltips s:String if action is available
			switch(i)
			{
				case 1:
					trace("Scheduled");
					this.bApprove = false;
					this.bCopy = true;
					this.sCopyTip = 'Copy Report ' + s;
					this.bDelete = true;
					this.bEdit = true;
					this.sDeleteTip = 'Delete Report ' + s;
					this.sEditTip = 'Edit Report ' + s;
					this.bRun = true;
					this.sRunTip = 'Run Report ' + s;
					this.bExport = false;
					break;
				case 2://DEPRECATED
					trace("Recalc");
					this.bApprove = false;
					this.bCopy = true;
					this.bDelete = false;
					this.bEdit = false;
					this.bRun = true;
					this.sRunTip = 'Run Report ' + s;
					break;
				case 3:
					trace("RFA");
					this.bApprove = true;
					this.sApproveTip = 'Approve Report ' + s;
					this.bCopy = true;
					this.sCopyTip = 'Copy Report ' + s;
					this.bDelete = true;
					this.sDeleteTip = 'Delete Report ' + s;
					this.bEdit = false;
					this.bRun = false;
					this.bExport = true;
					this.sExportTip = 'Download Report ' + s + ' to Excel';
					break;
				case 4:
					trace("Approved");
					this.bApprove = false;
					this.bCopy = true;
					this.sCopyTip = 'Copy Report ' + s;
					this.bDelete = false;
					this.bEdit = false;
					this.bRun = false;
					this.bExport = true;
					this.sExportTip = 'Download Report ' + s + ' to Excel';
					break;
				case 9:
					trace("Deleted");
					this.bApprove = false;
					this.bCopy = false;
					this.bDelete = false;
					this.bEdit = false;
					this.bRun = false;
					this.bExport = false;
					break;
				default:
					trace("Wack!");
					this.bApprove = false;
					this.bCopy = false;
					this.bDelete = false;
					this.bEdit = false;
					this.bRun = false;
					this.bExport = false;
					break;
			}
		}
	}
}