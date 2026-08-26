
<!--- ----------------------------------------------------------------------------------------- --->
<!--- global settings, variables and functions that need to be accessed everywhere ------------ --->
<!--- ----------------------------------------------------------------------------------------- --->



<!--- basic colors identifying operators, distributors and products --------------------------- --->
<cfset oper_color="d1570d"><!--- burnt orange --->
<cfset dist_color="005500"><!--- forest green --->
<cfset prod_color="c30e3b"><!--- scarlet red --->
<!--- ----------------------------------------------------------------------------------------- --->



<!--- function to remove decimals from dollar format because dollarformat always shows 2 decimals --->
<cfscript>
	function mydollarformat(money_string){
		money_string = DollarFormat(money_string);
		money_string = rereplaceNoCase(money_string, '\.\d{2}', '');
		return(money_string);
	}
	/*usage is: #mydollarformat(value goes here)# */
</cfscript>
<!--- ----------------------------------------------------------------------------------------- --->