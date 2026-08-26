<!------------------------------------------------------------------------
NAME:           CF_ListCompare
FILE:			listCompare.cfm
CREATED:		9/13/2000
LAST MODIFIED:	9/13/2000
VERSION:	    1.0
AUTHOR:         Peter J. Rini (peter@lucid-reality.com)
DESCRIPTION:    CF_ListCompare is a custom tag that will compare 2 given lists
				and return 3 different lists.
				
				Input variables:
				List1: First list for comparison
					Required: YES
					Datatype: List
				List2: Second list for comparison
					Required: YES
					Datatype: List
				CaseSensitive: If the comparison should be case sensitive or not
					Required: NO
					Datatype: string.  Values must be: Yes, Y, 1 (for case sensitive) No, N, 0 (for NON case sensitive)
					Default Value: NO
				Delimiters: The delimiters used in the input lists
					Required: NO
					Datatype: Char
					Default value: , (comma)
				
				Output variables:
				LC_Results1: Will contain values that are in List1 and not in List2
				LC_Results2: Will contain values that are in List2 and not in List1
				LC_Common: Will contain values that are common to both lists
				
COPYRIGHT:		Copyright (C) 2000 by Peter J. Rini, All Rights (and lefts)	Reserved
				This program is free software; you can redistribute it and/or modify
				it under the terms of the GNU General Public License as published by
				the Free Software Foundation; either version 2 of the License, or any
				later version.

				This program is distributed in the hope that it will be
				useful, but WITHOUT ANY WARRANTY; without even the implied
				warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
				PURPOSE.  See the GNU General Public License for more
				details.
				
				You should have received a copy of the GNU General Public
				License along with this program; if not, write to the Free
				Software Foundation, Inc., 59 Temple Place - Suite 330,
				Boston, MA  02111-1307, USA.
KNOWN ISSUES:   None
------------------------------------------------------------------------->
<CFIF NOT isDefined('Attributes.List1') OR NOT isDefined('Attributes.List2')>
	<cfthrow message="An error occurred in chair to keyboard interface. ERROR CODE: ID-10-T" type="Chair to keyboard interface" detail="Chair to Keyboard Interface Exception encountered in trying to access the ListCompare functions.  Please contact the system administrator and inform him/her of this error.">	
</CFIF>
<CFSET L1 = #Attributes.List1#>
<CFSET L2 = #Attributes.List2#>

<CFPARAM name=CS default=0>
<CFPARAM name=Delims default=",">
<CFIF isDefined('Attributes.CaseSensitive')>
	<CFIF Attributes.CaseSensitive IS "Y" OR Attributes.CaseSensitive IS "Yes" OR Attributes.CaseSensitive IS "1">
		<CFSET CS = 1>
	</CFIF>
</CFIF>
<CFIF isDefined('Attributes.Delimiters')>
	<CFSET Delims = #Attributes.Delimiters#>
</CFIF>

<!--- Search the lists --->

<CFSET LCR1 = "">
<CFSET LCR2 = "">
<CFSET LCC = "">

<!--- Run through list1 to find the values in list2 --->
<cfloop index="currVal" list="#L1#" delimiters="#delims#">
	<CFIF CS>
		<CFIF #ListFind(L2, "#currVal#", "#delims#")# EQ 0>
			<CFSET LCR1 = #ListAppend(LCR1, "#currVal#", ",")#>
		<CFELSE>
			<CFSET LCC = #ListAppend(LCC, "#currVal#", ",")#>
		</CFIF>
	<CFELSE>
		<CFIF #ListFindNoCase(L2, "#currVal#", "#delims#")# EQ 0>
			<CFSET LCR1 = #ListAppend(LCR1, "#currVal#", ",")#>
		<CFELSE>
			<CFSET LCC = #ListAppend(LCC, "#currVal#", ",")#>
		</CFIF>
	</CFIF>	
</cfloop>

<!--- Run through list2 to find the values in list1 --->
<cfloop index="currVal" list="#L2#" delimiters="#delims#">
	<CFIF CS>
		<CFIF #ListFind(L1, "#currVal#", "#delims#")# EQ 0>
			<CFSET LCR2 = #ListAppend(LCR2, "#currVal#", ",")#>
		<CFELSEIF NOT #ListContains(LCC, "#currVal#", ",")#>
			<CFSET LCC = #ListAppend(LCC, "#currVal#", ",")#>
		</CFIF>
	<CFELSE>
		<CFIF #ListFindNoCase(L1, "#currVal#", "#delims#")# EQ 0>
			<CFSET LCR2 = #ListAppend(LCR2, "#currVal#", ",")#>
		<CFELSEIF NOT #ListContainsNoCase(LCC, "#currVal#", ",")#>
			<CFSET LCC = #ListAppend(LCC, "#currVal#", ",")#>
		</CFIF>
	</CFIF>	
</cfloop>

<CFSET Caller.LC_Results1 = "#LCR1#">
<CFSET Caller.LC_Results2 = "#LCR2#">
<CFSET Caller.LC_Common = "#LCC#">

