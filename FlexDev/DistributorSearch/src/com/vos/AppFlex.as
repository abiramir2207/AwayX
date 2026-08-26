package com.vos
{
	/**
	 * AppFlex is the object that hold custom appSettings for this Project
	 * @author msaunders
	 */	
	public class AppFlex
	{
		/*-.........................................Properties..........................................*/
		public var col1 : String;
		public var col2 : String;
		public var col3 : String;
		public var col4 : String;
		public var col5 : String;
		public var col6 : String;
		public var distLabel : String;
		public var oneDistSelection : Boolean;

		
		/*-.........................................Constructor..........................................*/
		public function AppFlex(	col1 : String 	=	"",
									col2 : String 	=	"",
									col3 : String 	=	"",
									col4 : String 	=	"",
									col5 : String 	=	"",
									col6 : String 	=	"",
									distLabel : String 	=	"",
									oneDistSelection : Boolean = false)
		
									
		{
			this.col1 = col1;
			this.col2 = col2;
			this.col3 = col3;
			this.col4 = col4;
			this.col5 = col5;
			this.col6 = col6;
			this.distLabel = distLabel;
			this.oneDistSelection = oneDistSelection;
		}
			
		
		
		/*-.........................................Methods..........................................*/
		public function load(newAppFlex:AppFlex):void 
		{
			this.col1 = newAppFlex.col1;
			this.col2 = newAppFlex.col2;
			this.col3 = newAppFlex.col3;
			this.col4 = newAppFlex.col4;
			this.col5 = newAppFlex.col5;
			this.col6 = newAppFlex.col6;
			this.distLabel = newAppFlex.distLabel;
			this.oneDistSelection = newAppFlex.oneDistSelection;
			
		}

	}
}