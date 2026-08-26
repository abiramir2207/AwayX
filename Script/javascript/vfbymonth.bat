@echo off
rem  --------------------------------------------------------------------------------
rem  File: 
rem
rem  Purpose: Combine multiple .js files into one .js file and compress it
rem
rem  --------------------------------------------------------------------------------
rem  Assign JS output file name :: use relative path and file name of your .cfm file
rem
rem     (e.g  tps-index  for   /tps/index.cfm )
rem
rem  Change tps-index with your desired output file name
rem  -------------------------------------------------------------------------------
set output_file_name=vfbymonth

rem  ------------------------------------------------------------------------------------------------
rem  List all .js files that are needed in your .cfm page here so they can be combined into one file
rem
rem  ( replace all .js file names below with your .js file names )
rem  ------------------------------------------------------------------------------------------
type jquery.cfjs.min.js > %output_file_name%.js

type jquery.calculation.min.js   >> %output_file_name%.js
type variable.debugger.js        >> %output_file_name%.js
type jquery-impromptu.3.1.min.js >> %output_file_name%.js
type math_functions.js           >> %output_file_name%.js
type scrollHeader.js             >> %output_file_name%.js

rem  -----------------------------------------------
rem  Compress into an ugly .js format
rem  -----------------------------------------------
echo ...
echo %output_file_name%-ugly.js was created successfully!
echo ...
uglifyjs %output_file_name%.js > %output_file_name%-ugly.js

