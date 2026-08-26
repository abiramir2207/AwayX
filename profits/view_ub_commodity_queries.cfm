<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the Urner Barry commodity data --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_UB_Data" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
Select	*	from	Urner_Barry_Symbols where ub_symbol	=	#URL.ub_symbol#
</CFQUERY>
