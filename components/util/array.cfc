<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\array.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all array manipulation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="Array" output="false" hint="This has user defined functions for array manipulation.">

	<cffunction name="Init" access="public" returntype="any" output="false">
		<cfargument name="Library" type="any" required="true"/>

		<cfscript>
			// The library variable is a reference to the main UDF library. This is
			// going to be used to reference other parts of the library that are not
			// in this specific component.
			variables.library = arguments.Library;
			return (this);
		</cfscript>

	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="dtColumnSizeInPercent" access="public" returntype="array" output="false" hint="Calculates data table column sizes in percentage">
		<cfargument name="estimatedSizes" type="array" required="true" hint="Array of estimated sizes (e.g. 1=small 2=medium 3=large 4=x-large)"/>

		<cfscript>
			var local = {};
			local.percentageSizes = [];

			local.totalEstimatedSize = 0;
			local.arraySize = arrayLen(arguments.estimatedSizes);

			//calculate total of all estimated sizes
			for(local.ii = 1; local.ii lte local.arraySize; local.ii = local.ii + 1)
			  local.totalEstimatedSize = local.totalEstimatedSize + arguments.estimatedSizes[ local.ii ];

			local.singlePercentageSize = 100 / local.totalEstimatedSize;

			local.subtotalSize = 0;
			//build actual percentage sizes array
			for(local.ii = 1; local.ii lte local.arraySize; local.ii = local.ii + 1) {
				// for last column = take the remaining space
			  if (local.ii eq local.arraySize)
			  	local.columnSize = (100 - local.subtotalSize);
			  // for every 3rd column = use a little bit more space
			  else if (local.ii mod 3 eq 0)
					local.columnSize = ceiling(local.singlePercentageSize * arguments.estimatedSizes[local.ii]);
				// for other columns = use a little bit less space
				else
					local.columnSize = int(local.singlePercentageSize * arguments.estimatedSizes[local.ii]);

				arrayAppend(local.percentageSizes, local.columnSize);
				local.subtotalSize = local.subtotalSize + local.columnSize;
			}

			return local.percentageSizes;
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="arrayOfStructsSort" access="public" returntype="array" output="false" hint="Sorts an array of structures based on a key in the structures.">
		<cfargument name="aofS" type="array" required="true"/>
		<cfargument name="key" required="true"/>
		<cfargument name="sortOrder" required="false" default="asc"/>
		<cfargument name="sortType" required="false" default="textnocase"/>
		<cfargument name="delim" required="false" default="."/>

		<cfscript>
			//make an array to hold the sort stuff
			var sortArray = arraynew(1);
			//make an array to return
			var returnArray = arraynew(1);
			//grab the number of elements in the array (used in the loops)
			var count = arrayLen(aOfS);
			//make a variable to use in the loop
			var ii = 1;

			//loop over the array of structs, building the sortArray
			for(ii = 1; ii lte count; ii = ii + 1)
				sortArray[ii] = aOfS[ii][key] & delim & ii;

			//now sort the array
			arraySort(sortArray,sortType,sortOrder);

			//now build the return array
			for(ii = 1; ii lte count; ii = ii + 1)
				returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];

			return returnArray;
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<!---
	 Parses an array of consistent structs to return one key.

	 @param arry 	 The array of structs. (Required)
	 @param key 	 Key value to return. (Required)
	 @param delim 	 List delimiter. Defaults to a comma. (Optional)
	 @param dedup 	 If true, dedupes the list. Defaults to false. (Optional)
	 @param returnas 	 Allows you to specify list or array for return type. Defaults to list. (Optional)
	 @return Returns a list or array.
	 @author Jon Briccetti (&#106;&#98;&#114;&#105;&#99;&#99;&#101;&#116;&#116;&#105;&#64;&#103;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;)
	 @version 1, September 29, 2011
	--->
	<cffunction name="arrayofStructsToList" output="true" access="public" returntype="any" hint="i return a list of values from a particular key in an array of structs. if the key doesnt exist in an element it is ignored">
		<cfargument name="arry" type="array" required="yes" hint="the array to search" />
		<cfargument name="key" type="string" required="yes" hint="the key name in the structure from which to pull a list value" />
		<cfargument name="delim" type="string" required="no" default="," hint="the list delim character(s)" />
		<cfargument name="dedup" type="boolean" required="no" default="false" hint="if you want me to de-dup the list, lemme know. dont expect any order coming back." />
		<cfargument name="returnas" type="string" required="no" default="list" hint="enum: list,array; you tell me what format you want your 'list' back" />
		<!--- KEEP IN MIND THAT WITH de-dup=true or in the event any key values are missing from struct elements, the order of the returned value may not correspond to the order of the original array --->
		<cfset var local = {} />
		<cfset local.result = "" />
		<cfset local.str = "" />
		<cfset local.dedup = {} />

		<cfset local.returnval = "" />
		<cfloop array="#arry#" index="local.i">
					<cftry>
						<cfif arguments.dedup>
								<cfset local.dedup[local.i[key]] = "" />
		      <cfelse>
		        <cfset local.str = listAppend(local.str,local.i[key],delim) />
		      </cfif>
		    	<cfcatch><!--- FAIL SILENTLY IF KEY DOESNT EXIST ---></cfcatch>
		    </cftry>
		</cfloop>
			<cfif arguments.dedup>
				<cfset local.str = structKeyList(local.dedup,delim) />
		</cfif>
		<cfif arguments.returnas EQ "array">
			<cfset local.result = listToArray(local.str,delim) />
		<cfelse>
			<cfset local.result = local.str />
		</cfif>

		<cfreturn local.result />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="arrayAppendAll" access="public" returntype="array" output="false" hint="I append (concat) the entire incoming array to the target array.">
		<cfargument name="targetArray" type="array" required="true" hint="I am the array being augmented"/>
		<cfargument name="incomingArray" type="array" required="true" hint="I am the array being added to the target array."/>

		<!--- Define the local scope. --->
		<cfset var local = {}/>
		<cfloop index="local.incomingValue" array="#arguments.incomingArray#">
			<!--- Append the incoming value. --->
			<cfset arrayAppend(arguments.targetArray, local.incomingValue)/>
		</cfloop>

		<cfreturn arguments.targetArray/>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="arraySplice" access="public" returntype="array" output="false" hint="I splice an array by deleting and / or adding new elements at the given index.">
		<cfargument name="array" type="array" required="true" hint="I am the array being manipulated."/>
		<cfargument name="index" type="numeric" required="true" hint="I am the index at which to start adding or removing elements to and from the array (respectively)."/>
		<cfargument name="howMany" type="numeric" required="true" hint="I am the number of elements that should be removed from the array, starting at the given index. If zero, no elements will be removed."/>

		<!---
			At this point, the method can take a variable number of
			subsequent arguments that would be the elements to insert
			into the array at the given index.

			<cfargument name="element1" />
			<cfargument name="element2" />
			<cfargument name="element3" />
			....
			<cfargument name="elementN" />
		--->
		<cfset var local = {}/>
		<!---
		    The first thing we want to do is delete any elements from
		    the array that we need to. Since ColdFusion doesn't have
		    an inherent way to delete more than one item, we will have
		    to perform this as a conditional loop.
		--->
		<cfset local.deleteCounter = arguments.howMany/>

		<!---
		    Keep deleting while the DeleteCounter is still non-zero
		    AND while the array length is big enough to encompass the
		    given index.
		--->
		<cfloop condition="(local.deleteCounter-- && (arrayLen( arguments.array ) gte arguments.index))">
			<!--- Delete the given item in the array. --->
			<cfset arrayDeleteAt(arguments.array, arguments.index)/>
		</cfloop>

		<!---
		    Now that we have delete any necessary elements from the
		    array, we need to add any additional items, starting at
		    the given instance.
		--->
		<!---
		    Since we will need to keep updating the index of the
		    insert, start a new pointer for that index.
		--->
		<cfset local.insertIndex = arguments.index/>
		<!---
		    Loop over the optional elements in the arguments. There
		    may be ZERO or more of these elements.
		--->
		<cfloop index="local.elementIndex" from="4" to="#arrayLen( arguments )#" step="1">
			<!---
			    When inserting, we need to make sure that the index
			    of insertion is not beyond the bounds of the array.
			    If it is, we need to do an append (or the insert
			    will error).
			--->
			<cfif (local.insertIndex gt arrayLen(arguments.array))>
				<!--- Append the new element. --->
				<cfset arrayAppend(arguments.array, arguments[local.elementIndex])/>
			<cfelse>
				<!--- Insert the new element. --->
				<cfset arrayInsertAt(arguments.array, local.insertIndex, arguments[local.elementIndex])/>
			</cfif>

			<!--- Increment insertion index. --->
			<cfset ++local.insertIndex/>
		</cfloop>

		<!--- Return the updated array. --->
		<cfreturn arguments.array/>
	</cffunction>

</cfcomponent>