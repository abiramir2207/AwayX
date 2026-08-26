package {

	import mx.formatters.DateFormatter;
	
	/**
	 * AS2 class containing some static date utility methods.
	 *
	 * @author Dimitrios Gianninas
	 * @since 1.7
	 */
	public class DateUtils {
	
		// constants
		public static const DAY:int		= 0;
		public static const MONTH:int	= 1;
		public static const YEAR:int	= 2;
		
		public static const BEFORE:int	= 1;
		public static const AFTER:int	= -1;
		public static const EQUAL:int	= 0;
		
		// internal fields
		private static var dateFormat:DateFormatter = new DateFormatter();
	
		/**
		 * Date arithmetic method. The value parameter can either positive or negative.		 */
		public static function dateAdd( type:int, value:Number, date:Date ):Date {
			switch( type ) {
				case DAY:
					date.setDate( date.getDate() + value );
					break;
				case MONTH:
					date.setMonth( date.getMonth() + value );
					break;
				case YEAR:
					date.setFullYear( date.getFullYear() + value );
					break;
			}
	
			return date;
		}
	
		/**
		 * Formats the supplied date as a standard date string.		 */
		public static function displayDate( value:Object ):String {
			dateFormat.formatString = "MM/DD/YYYY";
			return dateFormat.format( value );
		}
	
		/**
		 * Formats the supplied date as a standard date/time string.		 */
		public static function displayDateTime( value:Object ):String {
			dateFormat.formatString = "YYYY-MM-DD JJ:NN";
			return dateFormat.format( value );
		}
	
		/**
		 * returns one of the following:
		 * -1 : first date is larger than the second
		 * 1  : first date is smaller than the second
		 * 0  : Both dates are the same
		 */
		public static function compareDates( d1:Date, d2:Date ):int {
			var d1ms:Number = d1.getTime();
			var d2ms:Number = d2.getTime();
	
			if( d1ms > d2ms ) {
				return AFTER;
			}
			else if( d1ms < d2ms ) {
				return BEFORE;
			}
			else {
				return EQUAL;
			}
		}
	}

}