<!---
Serialize and deserialize JSON data into native ColdFusion objects
http://www.epiphantastic.com/cfjson/

Authors: Jehiah Czebotar (jehiah@gmail.com)
         Thomas Messier  (thomas@epiphantastic.com)

Version: 1.7 March 1st, 2007
--->
<cfscript>
component displayname="JSON" output="No" {

    remote function decode (required _data) returntype="any" output="false" hint="Converts data from JSON to CF format" {
        return isJSON(_data) ? deserializeJSON(_data) : "Invalid argument: either your JSON is wrong or there's a bug in the JSON function";
    }


    remote string function encode (required _data, fmt="query", casing="lower") output="false" hint="Converts data from CF to JSON format" {
        var i = 0;
        if ( ( isBoolean(_data) and not isNumeric(_data)
                and not listFindNoCase("Yes,No", _data) )                   // --- boolean ---
            or ( isNumeric(_data) and not REFind("^0+[^\.]",_data) )        // --- number ---
            or ( isSimpleValue(_data) ) ) {                                 // --- string ---
            return serializeJSON(_data);
        }

        // --- array ---
        if ( isArray(_data) ) {
            var item   = 0;
            var result = [];
            // cfloop ( array=_data, item="item" )
            for (i = 1; i <= _data.length; i++) {
                result.Append( encode( _data[i], fmt ) );
            }
            return "[" & arrayToList(result) & "]";
        }

        // --- query ---
        if ( isQuery(_data) ) {
            var json   = {};
            var column = 0;
            var use_lower = arguments.casing is "lower";

            json[ "recordcount" ] = _data.recordCount;
            json[ "columnlist" ]  = use_lower ? lCase( _data.columnList ) : uCase( _data.columnList );

            if (arguments.fmt is "query") {
                // cfloop ( list=json.columnList, item="column" )
                for (i = 1; i <= listLen(json.columnList); i++) {
                    column = listGetAt(json.columnList, i);
                    json[column] = valueArray(_data, column);
                }
            }

            if (arguments.fmt is "array") {
                json[ "data" ] = [] ;
                _data.each( function ( row ) {
                    if ( use_lower ) {
                        var lc_row = {};        // row with lowered case column names
                        // cfloop ( list=json.columnList, item="column" )
                        for (i = 1; i <= listLen(json.columnList); i++) {
                            column = listGetAt(json.columnList, i);
                            lc_row[ column ] = row[ column ];
                        };
                        json.data.append(lc_row);
                    }
                    else {
                        json.data.append(row);
                    }
                });
            }
            return serializeJSON(json);
        }

        // --- struct ---
        if ( isStruct(_data) ) {
            return serializeJSON(_data);
        }

        return '"unknown-obj"';
    }

}
</cfscript>