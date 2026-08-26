package
{
    import flash.events.Event; 
    
	public class SimpleItemClickEvent extends Event
	{
		public static var CLICK:String = "simpleClick";
        
        public var vo:*;
        public var voPropertyName:String;
        
        public function SimpleItemClickEvent(a_vo:*, a_voPropertyName:String)
        {
            // pass type and set bubbles (2nd param) to true
            super(CLICK, true, true);
            vo = a_vo;
            voPropertyName = a_voPropertyName;
        }
	}
}