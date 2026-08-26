<!---
  * ==================================================================================================== 
  *    @File: \common_Files\_queries.cfm
  *  @Author: Chris Nguyen
  *    @Date: February 2020
  * 
  * @Remarks: Retrieve all queries meta data, place them into a predefine array named '_queries'
  *
  * ==================================================================================================== 
--->

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~ gather all query variables into an array ~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cfset _keys = []>
<cfloop collection="#variables#" item="_key">
    <cfif isQuery(variables[_key])>
        <cfset arrayAppend(_keys, lcase(_key))>
    </cfif>
</cfloop>
<!---  sort the queries array by names ~ --->
<cfset arraySort(_keys, "text")>

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~ gather all queries meta data into an array ~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

<!---  result is stored in this _queries array  --->
<cfset _queries = []>

<cfloop array="#_keys#" item="_key">
    <cftry>
        <cfset _qMeta = variables[_key].getMetadata().getExtendedMetaData()>
        <!--- <cfparam name="_qMeta.SQLParameters" default=""> --->
        <cfset arrayAppend(_queries, {query_name: _key, record_count: _qMeta.recordCount, sql: _qMeta.sql })>
        <cfif isDefined("_qMeta.SQLParameters")>
            <cfset _queries[arrayLen(_queries)].parameters = _qMeta.SQLParameters>
        </cfif>
    <cfcatch type="any">
    </cfcatch>
    </cftry>
</cfloop>
