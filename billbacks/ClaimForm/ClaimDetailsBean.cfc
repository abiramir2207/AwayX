<cfcomponent output="false" alias="billbacks.BrokerClaimForm.ClaimDetailsBean">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	
	<cfproperty name="item_Id" type="numeric" default="0" /> 
    <cfproperty name="Program_ItemId" type="string" default="" />
    <cfproperty name="Item_Desc" type="string" default="" />
	<cfproperty name="Item_Case_Weight" type="numeric" default="0" />
	<cfproperty name="Cases_Claimed" type="numeric" default="0" />
	<cfproperty name="Net_Lbs_Claimed" type="numeric" default="0" />
	<cfproperty name="STD" type="string" default="" />
	<cfproperty name="Promo_rate" type="numeric" default="0" />
	<cfproperty name="Invoice_Price" type="numeric" default="0" />
	<cfproperty name="Promo_Amt" type="numeric" default="0" />
	<cfproperty name="Price_List" type="string" default="0" />
	<cfproperty name="Less_Corp_Allow" type="numeric" default="0" />
	<cfproperty name="Less_Local_Allow" type="numeric" default="0" />
	<cfproperty name="Net_Promo_Amt" type="numeric" default="0" />
	<cfproperty name="Adj_Extended_Amt" type="numeric" default="0" />
	<cfproperty name="ClaimFormFK" type="numeric" default="0" />

	<cfscript>
		//Initialize the CFC with the default properties values.
		variables.item_Id = 0;
		variables.Program_ItemId = "";
		variables.Item_Desc = "";
		variables.Item_Case_Weight = 0;
		variables.Cases_Claimed = 0;
		variables.Net_Lbs_Claimed = 0;
		variables.STD = "";
		variables.Promo_rate = 0;
		variables.Invoice_Price = 0;
		variables.Promo_Amt = 0;
		variables.Price_List = "";
		variables.Less_Corp_Allow = 0;
		variables.Less_Local_Allow = 0;
		variables.Net_Promo_Amt = 0;
		variables.Adj_Extended_Amt = 0;
		variables.ClaimFormFK = 0;
	</cfscript>
	
	<cffunction name="init" access="public" output="false" returntype="ClaimDetailsBean">
	 <cfreturn this />
	</cffunction>
	
	<cffunction name="getitem_Id" output="false" access="public" returntype="any">
		<cfreturn variables.item_Id>
	</cffunction>

	<cffunction name="setitem_Id" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.item_Id = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getProgram_ItemId" output="false" access="public" returntype="any">
		<cfreturn variables.Program_ItemId>
	</cffunction>

	<cffunction name="setProgram_ItemId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
			<cfset variables.Program_ItemId = arguments.val>
	</cffunction>
	
	<cffunction name="getItem_Desc" output="false" access="public" returntype="any">
		<cfreturn variables.Item_Desc>
	</cffunction>

	<cffunction name="setItem_Desc" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">

			<cfset variables.Item_Desc = arguments.val>

	</cffunction>
	
	<cffunction name="getItem_Case_Weight" output="false" access="public" returntype="any">
		<cfreturn variables.Item_Case_Weight>
	</cffunction>

	<cffunction name="setItem_Case_Weight" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Item_Case_Weight = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getCases_Claimed" output="false" access="public" returntype="any">
		<cfreturn variables.Cases_Claimed>
	</cffunction>

	<cffunction name="setCases_Claimed" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Cases_Claimed = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getNet_Lbs_Claimed" output="false" access="public" returntype="any">
		<cfreturn variables.Net_Lbs_Claimed>
	</cffunction>

	<cffunction name="setNet_Lbs_Claimed" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Net_Lbs_Claimed = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getSTD" output="false" access="public" returntype="any">
		<cfreturn variables.STD>
	</cffunction>

	<cffunction name="setSTD" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">

			<cfset variables.STD = arguments.val>

	</cffunction>
	
	<cffunction name="getPromo_rate" output="false" access="public" returntype="any">
		<cfreturn variables.Promo_rate>
	</cffunction>

	<cffunction name="setPromo_rate" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Promo_rate = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getInvoice_Price" output="false" access="public" returntype="any">
		<cfreturn variables.Invoice_Price>
	</cffunction>

	<cffunction name="setInvoice_Price" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Invoice_Price = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getPromo_Amt" output="false" access="public" returntype="any">
		<cfreturn variables.Promo_Amt>
	</cffunction>

	<cffunction name="setPromo_Amt" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Promo_Amt = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction> 
	
	<cffunction name="getPrice_List" output="false" access="public" returntype="any">
		<cfreturn variables.Price_List>
	</cffunction>

	<cffunction name="setPrice_List" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		
			<cfset variables.Price_List = arguments.val>
		
	</cffunction>
	
	<cffunction name="getLess_Corp_Allow" output="false" access="public" returntype="any">
		<cfreturn variables.Less_Corp_Allow>
	</cffunction>

	<cffunction name="setLess_Corp_Allow" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Less_Corp_Allow = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getLess_Local_Allow" output="false" access="public" returntype="any">
		<cfreturn variables.Less_Local_Allow>
	</cffunction>

	<cffunction name="setLess_Local_Allow" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Less_Local_Allow = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getNet_Promo_Amt" output="false" access="public" returntype="any">
		<cfreturn variables.Net_Promo_Amt>
	</cffunction>

	<cffunction name="setNet_Promo_Amt" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Net_Promo_Amt = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getAdj_Extended_Amt" output="false" access="public" returntype="any">
		<cfreturn variables.Adj_Extended_Amt>
	</cffunction>

	<cffunction name="setAdj_Extended_Amt" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset variables.Adj_Extended_Amt = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>
	
	<cffunction name="getClaimFormFK" output="false" access="public" returntype="any">
		<cfreturn variables.ClaimFormFK>
	</cffunction>

	<cffunction name="setClaimFormFK" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ 0)>
			<cfset variables.ClaimFormFK = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>            
	
</cfcomponent>