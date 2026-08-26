package com.shared.vos
{
	import flash.events.EventDispatcher;
	[Bindable]
	[RemoteClass(alias="mvc.Models.Settings.vos.AppSettings")]
	public class AppSettings extends EventDispatcher
	{
		public function AppSettings()
		{
		}
		/*-.........................................Properties..........................................*/
		public var Allow_Multiple_Deduction_Settlement : Number;
		public var BB_2Ref_Num_Max_Length : String;
		public var BB_Fractional_Volume : Number;
		public var BB_LS_Claimed_Rebate_Expected : Number;
		public var BB_PAYEE_OPERATOR_SHIP_TO_REQ : String;
		public var BB_Ref_Num_Max_Length : String;
		public var bbUploadFilePath : String;
		public var Billback_Display_All_Program_Components : Boolean;
		public var BillBack_Statement_Type : String;
		public var Budgets_Functionality_On : Number;
		public var BusinessConsiderations_On : Number;
		public var DD_Restrict_ShipTo_For_BB : Number;
		public var Distributor_Label_Singular : String;
		public var Exact_List_Matching_On : Boolean;
		public var Multiple_BillTos_For_ShipTo : Number;
		public var Operator_Label_Singular : String;
		public var Pullback_Label : String;
		public var Shard_Ship_To_Label : String;
		public var Template_Multiple_Product_Attr_Groups : Number;
		public var View_Program_Volume_UOM : Number;
		public var Original_Buyer_Label : String;
		public var Final_Buyer_Label : String;
		public var BB_Created_Recently_Days : String;
		public var EnableBBDupCheck: Boolean;
		public var SHOW_HOLDING_PEN: Boolean;
		public var Zone_Label : String;
		public var Region_Label : String;
		public var Prod_Var_A : String;
		public var Business_Segment_Label  : String;
		public var Enable_EDI_Upload_Raw_Data_Viewer: Boolean;
	}
}