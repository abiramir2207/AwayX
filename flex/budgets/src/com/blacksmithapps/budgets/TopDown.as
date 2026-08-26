package src.com.blacksmithapps.budgets
{
	[RemoteClass(alias="src.com.blacksmithapps.budgets.TopDown_Bean")]

	[Bindable]
	public class TopDown
	{

		public var Budget_Detail_Final_ID:Number = 0;
		public var Budget_ID:Number = 0;
		public var Control_Level_1:Number = 0;
		public var Control_Level_2:Number = 0;
		public var Control_Level_1_ID:String = "";
		public var Control_Level_2_ID:String = "";
		public var Level_Value:Number = 0;
		public var Level_Value_Percentage:Number = 0;
		public var New_Level_Value:Number = 0;
		public var New_Level_Value_Percentage:Number = 0;
		public var Deleted:Number = 0;
		public var Created_Date:Date = null;
		public var Updated_Date:Date = null;


		public function TopDown()
		{
		}

	}
}