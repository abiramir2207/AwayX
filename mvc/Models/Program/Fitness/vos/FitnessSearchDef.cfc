<cfcomponent displayname="mvc.Models.Program.Fitness.vos.FitnessSearchDef" >
	
	<cfproperty name="BusinessSegment0" type="Array" default=""/>
	<cfproperty name="Area1" type="Array" default=""/>
	<cfproperty name="Region2" type="Array" default=""/>
	<cfproperty name="Customer3" type="Array" default=""/>
	<cfproperty name="Year4" type="Array" default=""/>
	<cfproperty name="Program5" type="Array" default=""/>
	<cfproperty name="Period6" type="Array" default=""/>
	
	<!---<cfproperty name="Category7" type="Array" default=""/>
	<cfproperty name="Family8" type="Array" default=""/>
	<cfproperty name="Finance9" type="Array" default=""/>--->
	<cfproperty name="BusinessSegment0Idx" type="numeric" default="0"/>
	<cfproperty name="Area1Idx" type="numeric" default="0"/>
	<cfproperty name="Region2Idx" type="numeric" default="0"/>
	<cfproperty name="Customer3Idx" type="numeric" default="0"/>
	<cfproperty name="Year4Idx" type="numeric" default="0"/>
	<cfproperty name="Program5Idx" type="numeric" default="0"/>
	<cfproperty name="Period6Idx" type="numeric" default="0"/>
	
	<!---<cfproperty name="Category7Idx" type="numeric" default="0"/>
	<cfproperty name="Family8Idx" type="numeric" default="0"/>
	<cfproperty name="Finance9Idx" type="numeric" default="0"/>--->
	
	<cfproperty name="Current" type="String" default=""/>

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.BusinessSegment0 = ArrayNew(1);
		this.Area1 		=  ArrayNew(1);
		this.Region2 	=  ArrayNew(1);
		this.Customer3	= 	ArrayNew(1);
		this.Year4		= 	ArrayNew(1);
		this.Program5 	= 	ArrayNew(1);
		this.Period6 	= 	ArrayNew(1);
		
		/*this.Category7 	= 	ArrayNew(1);
		this.Family8 	= 	ArrayNew(1);
		this.Finance9 	= 	ArrayNew(1);*/
		
		this.BusinessSegment0Idx = 	0;
		this.Area1Idx 		= 	0;
		this.Region2Idx 	= 	0;
		this.Customer3Idx	= 	0;
		this.Year4Idx		= 	0;
		this.Program5Idx 	= 	0;
		this.Period6Idx 	= 	0;
		
		/*this.Category7Idx 	= 	0;
		this.Family8Idx 	= 	0;
		this.Finance9Idx 	= 	0*/;
		
		this.Current		= '';
	</cfscript>
	
	<cffunction name="init" output="false" returntype="mvc.Models.Program.Fitness.vos.FitnessSearchDef" >
		<cfreturn this>
	</cffunction>

</cfcomponent>