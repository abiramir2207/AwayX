<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\datetime.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all date time manipulation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="DateTime" output="false" hint="This has user defined functions for date/time manipulation.">

	<cffunction name="Init" access="public" returntype="any" output="false">
		<cfargument name="Library" type="any" required="true"/>

		<cfscript>
			// The library variable is a reference to the main UDF library. This is
			// going to be used to reference other parts of the library that are not
			// in this specific component.
			variables.Library = arguments.Library;
			return (this);
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="fileVersion" access="public" returntype="string" output="false" hint="">
		<cfargument name="file_name" type="string" required="true" hint="file name and file extension (with relative path)"/>

		<cftry>
			<cfset local.expandPath = ( len(trim(arguments.file_name))
											? expandPath(arguments.file_name)
											: '' )>
			<cfcatch type="any">
				<cfset local.expandPath = ''>
			</cfcatch>
		</cftry>

		<cfreturn ( fileExists(local.expandPath)
						? TimeFormat( getFileInfo(local.expandPath).lastModified, 'hhmmssl' )
						: '000000000' )>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="DateTimeFormat" access="public" returntype="string" output="false" hint="Formats the given date with both a date and time format mask.">
		<cfargument name="Date" type="any" required="true" hint="The date/time stamp that we are formatting."/>
		<cfargument name="DateMask" type="string" required="false" default="mmm-dd-yyyy" hint="The mask used for the DateFormat() method call."/>
		<cfargument name="TimeMask" type="string" required="false" default="h:mm TT" hint="The mask used for the TimeFormat() method call."/>
		<cfargument name="Delimiter" type="string" required="false" default=" at " hint="This is the string that goes between the two formatted parts (date and time)."/>

		<!---
		    Return the date/time format by concatenating the date
		    and time formatting separated by the given delimiter.
		--->
		<cfif isDate(arguments.Date)>
			<cfreturn (DateFormat(arguments.Date, arguments.DateMask) & arguments.Delimiter & TimeFormat(arguments.Date, arguments.TimeMask))/>
		<cfelse>
			<cfreturn ''>
		</cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="DateSpanFormat" access="public" returntype="string" output="false" hint="I take two dates and format their time span.">
		<cfargument name="From" type="date" required="true" hint="I am the from date/time."/>
		<cfargument name="To" type="date" required="true" hint="I am the to date/time."/>
		<cfargument name="MonthFormat" type="string" required="false" default="mmmm" hint="I am the month format."/>

		<cfif (Year(arguments.From) EQ Year(arguments.To))>
			<cfif (Month(arguments.From) EQ Month(arguments.To))>
				<!---
				    Return same-month span.
				    Example: June 12-30, 2009
				--->
				<cfreturn (DateFormat(arguments.From, arguments.MonthFormat & " d") & "-" & DateFormat(arguments.To, "d, yyyy"))/>
			<cfelse>
				<!---
				    Return same-year span.
				    Example: June 12 - December 12, 2009
				--->
				<cfreturn (DateFormat(arguments.From, arguments.MonthFormat & " d") & " - " & DateFormat(arguments.To, arguments.MonthFormat & " d, yyyy"))/>
			</cfif>
		<cfelse>
			<!--- Just return a two-part date span format. --->
			<cfreturn (DateFormat(arguments.From, arguments.MonthFormat & " d, yyyy") & " - " & DateFormat(arguments.To,
			                                                                           arguments.MonthFormat & " d, yyyy"))/>
		</cfif>
	</cffunction>

</cfcomponent>