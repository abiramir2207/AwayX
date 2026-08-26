package com.shared.vos
{
	import com.ContractProds.views.Filter;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

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
		//GENERIC Filters
		public var bfilterA : Boolean;
		public var bfilterB : Boolean;
		public var bfilterC : Boolean;
		//CUSTOM (Legacy) Filters
		public var bfilterMiniItem : Boolean;
		public var bfilterSelected : Boolean;
		public var bfilterRates : Boolean;
		public var bfilterVarianceMP : Boolean;
		public var bfilterMP : Boolean;
		public var bfilterEz : Boolean;
		public var sfilterProductStatus : String;
		public var programDiscountTypes : String;
		public var lblStatus : String;
		public var acData : ArrayCollection; //generic ac property used for passing list data to insertFilterFunc()
		public var acData2 : ArrayCollection; //generic ac property used for passing list data to insertFilterFunc()
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
				//GENERIC Filters
				this.bfilterA = false;
				this.bfilterB = false;
				this.bfilterC = false;
				//CUSTOM (Legacy) Filters
				this.bfilterMiniItem = false;
				this.bfilterSelected = false;
				this.bfilterRates = false;
				this.bfilterVarianceMP = false;
				this.bfilterMP = false;
				this.bfilterEz = false;
				this.sfilterProductStatus = 'Active';
				this.programDiscountTypes = '';
				this.lblStatus = '';
				this.acData = new ArrayCollection();
				this.acData2 = new ArrayCollection();
			}
			
		}
		/*-.........................................Methods..........................................*/
		public function copy( filterParms:FilterParms ):void
		{
			this.searchFieldText = filterParms.searchFieldText;
			this.brand = filterParms.brand;
			this.qBrand = filterParms.qBrand;
			this.typeCode = filterParms.typeCode;
			this.typeGroup = filterParms.typeGroup;
			this.bfilterA = filterParms.bfilterA;
			this.bfilterB = filterParms.bfilterB;
			this.bfilterC = filterParms.bfilterC;
			this.bfilterMiniItem = filterParms.bfilterMiniItem;
			this.bfilterSelected = filterParms.bfilterSelected;
			this.bfilterRates = filterParms.bfilterRates;
			this.bfilterVarianceMP = filterParms.bfilterVarianceMP;
			this.bfilterMP = filterParms.bfilterMP;
			this.bfilterEz = filterParms.bfilterEz;
			this.sfilterProductStatus = filterParms.sfilterProductStatus;
			this.programDiscountTypes = filterParms.programDiscountTypes;
			this.lblStatus = filterParms.lblStatus;
			this.acData = filterParms.acData;
			this.acData2 = filterParms.acData2;
		}

	}
}