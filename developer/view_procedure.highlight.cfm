<!---
  * ==================================================================================================== 
  *    @File: 
  *  @Author: Chris Nguyen
  *    @Date: 2019-03-11 08:28:11
  * 
  * @Remarks:   
  *
  *
  * 
  *  
  * ==================================================================================================== 
--->
<!doctype html>
<html>
    <head>
        <cfparam name="url.name" default="">

        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>View Stored Procedure</title>
        <cfsavecontent variable="head_content">
            <!--- <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/styles/default.min.css"> --->
            <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/highlight.min.js"></script>
            <style>
                pre {
                    box-sizing: border-box;
                    width: 100%;
                    padding: 0;
                    margin: 0;
                    overflow: auto;
                    overflow-y: hidden;
                    font-size: 12px;
                    line-height: 20px;
                    /* background: #efefef; */
                    border: 1px solid #777;
                    /* background: url(lines.png) repeat 0 0; */
                    padding: 10px;
                    color: #333;
                }
                h3 {
                    background-image: linear-gradient(to top, #30cfd0 0%, #330867 100%);				
                    border-bottom: 1px dotted;
                    border-radius: 10px;
                    color: white;
                    margin-right: 24px;
                    margin-top: 10px;
                    opacity: .90;
                    padding: 10px 15px;
                    position: fixed;
                    right: 0;
                    text-shadow: 2px 2px 2px #aaa;
                    top: 0;
                    z-index: 99;
                }
                /*
                Visual Studio-like style based on original C# coloring by Jason Diamond <jason@diamond.name>
                */
                .hljs {
                    display: block;
                    overflow-x: auto;
                    padding: 0.5em;
                    background: white;
                    color: black;
                }

                .hljs-comment,
                .hljs-quote,
                .hljs-variable {
                    color: #008000;
                }

                .hljs-keyword,
                .hljs-selector-tag,
                .hljs-built_in,
                .hljs-name,
                .hljs-tag {
                    color: #00f;
                }

                .hljs-string,
                .hljs-title,
                .hljs-section,
                .hljs-attribute,
                .hljs-literal,
                .hljs-template-tag,
                .hljs-template-variable,
                .hljs-type,
                .hljs-addition {
                    color: #a31515;
                }

                .hljs-deletion,
                .hljs-selector-attr,
                .hljs-selector-pseudo,
                .hljs-meta {
                    color: #2b91af;
                }

                .hljs-doctag {
                    color: #808080;
                }

                .hljs-attr {
                    color: #f00;
                }

                .hljs-symbol,
                .hljs-bullet,
                .hljs-link {
                    color: #00b0e8;
                }

                .hljs-emphasis {
                    font-style: italic;
                }

                .hljs-strong {
                    font-weight: bold;
                }
            </style>
        </cfsavecontent>
        <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
        <cfhtmlhead text="#head_content#">
    </head>
    <body>
    <cfquery name="qCode" datasource="#application.datasource#">
        EXEC sp_helptext <cfoutput>'#url.name#'</cfoutput>
    </cfquery>

    <cfoutput><h3>#url.name# - #url.date#</h3></cfoutput>

    <pre>
        <code class="SQL zenburn">
        <cfoutput query="qCode">
            #encodeForHTMLAttribute( qCode.Text )#
        </cfoutput>
        </code>
    </pre>

    <script>
        hljs.initHighlightingOnLoad();
    </script>
</body>
</html>