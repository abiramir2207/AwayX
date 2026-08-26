package com.ContractProds.vos
{
	import com.ContractProds.views.Filter;
	
	import flash.events.EventDispatcher;

	/**
	 * FilterParms holds the current selection of Filter parameters use dby the filterfunction on the main datagrid
	 * @author msaunders  
	 */
	[Bindable]
	public class FilterParms extends EventDispatcher
	{
		/*-.........................................Properties..........................................*/
		public var searchFieldText : String;
		public var brand : String;
		public var qBrand : String;
		public var typeCode : String;
		public var typeGroup : String;
		public var bfilterMiniItem : Boolean;
		public var bfilterSelected : Boolean;
		public var bfilterRates : Boolean;
		public var bfilterVarianceMP : Boolean;
		public var bfilterMP : Boolean;
		public var programDiscountTypes : String;
		public var lblStatus : String;
		/*-.........................................Constructor..........................................*/
		public function FilterParms( 	/* searchFieldText:String = '',
										brand : String = '',
										qBrand : String = '',
										typeCode : String = '',
										typeGroup : String = '',
										bfilterMiniItem : Boolean = false,
										bfilterSelected : Boolean = false,
										bfilterRates : Boolean = false,
										programDiscountTypes : String = '',
										lblStatus : String = '' */
										o:FilterParms = null
									)
		{
			if( o ){
				copy( o );
			}
			else{
				this.searchFieldText = '';
				this.brand = '';
				this.qBrand = '';
				this.typeCode = '';
				this.typeGroup = '';
				this.bfilterMiniItem = false;
				this.bfilterSelected = false;
				this.bfilterRates = false;
				this.bfilterVarianceMP = false;
				this.bfilterMP = false;
				this.programDiscountTypes = '';
				this.lblStatus = '';	
			}
			
		}
		/*-.........................................Methods..........................................*/
		public function copy( filterParms:FilterParms ):void
		{
			searchFieldText = filterParms.searchFieldText;
			brand = filterParms.brand;
			qBrand = filterParms.qBrand;
			typeCode = filterParms.typeCode;
			typeGroup = filterParms.typeGroup;
			bfilterMiniItem = filterParms.bfilterMiniItem;
			bfilterSelected = filterParms.bfilterSelected;
			bfilterRates = filterParms.bfilterRates;
			bfilterVarianceMP = filterParms.bfilterVarianceMP;
			bfilterMP = filterParms.bfilterMP;
			programDiscountTypes = filterParms.programDiscountTypes;
			lblStatus = filterParms.lblStatus;
		}

	}
}