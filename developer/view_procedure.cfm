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

                /* PrismJS 1.15.0
                https://prismjs.com/download.html#themes=prism&languages=sql&plugins=highlight-keywords */
                /**
                * prism.js default theme for JavaScript, CSS and HTML
                * Based on dabblet (http://dabblet.com)
                * @author Lea Verou
                */

                code[class*="language-"],
                pre[class*="language-"] {
                    color: black;
                    background: none;
                    text-shadow: 0 1px white;
                    font-family: Consolas, Monaco, 'Andale Mono', 'Ubuntu Mono', monospace;
                    /* font-size: 1em; */
                    text-align: left;
                    white-space: pre;
                    word-spacing: normal;
                    word-break: normal;
                    word-wrap: normal;
                    line-height: 1.5;

                    -moz-tab-size: 4;
                    -o-tab-size: 4;
                    tab-size: 4;

                    -webkit-hyphens: none;
                    -moz-hyphens: none;
                    -ms-hyphens: none;
                    hyphens: none;
                }

                pre[class*="language-"]::-moz-selection, pre[class*="language-"] ::-moz-selection,
                code[class*="language-"]::-moz-selection, code[class*="language-"] ::-moz-selection {
                    text-shadow: none;
                    background: #b3d4fc;
                }

                pre[class*="language-"]::selection, pre[class*="language-"] ::selection,
                code[class*="language-"]::selection, code[class*="language-"] ::selection {
                    text-shadow: none;
                    background: #b3d4fc;
                }

                @media print {
                    code[class*="language-"],
                    pre[class*="language-"] {
                        text-shadow: none;
                    }
                }

                /* Code blocks */
                pre[class*="language-"] {
                    padding: 1em;
                    margin: .5em 0;
                    overflow: auto;
                }

                :not(pre) > code[class*="language-"],
                pre[class*="language-"] {
                    /* background: #f5f2f0; */
                }

                /* Inline code */
                :not(pre) > code[class*="language-"] {
                    padding: .1em;
                    border-radius: .3em;
                    white-space: normal;
                }

                .token.comment,
                .token.prolog,
                .token.doctype,
                .token.cdata {
                    color: slategray;
                }

                .token.punctuation {
                    color: #999;
                }

                .namespace {
                    opacity: .7;
                }

                .token.property,
                .token.tag,
                .token.boolean,
                .token.number,
                .token.constant,
                .token.symbol,
                .token.deleted {
                    color: #905;
                }

                .token.selector,
                .token.attr-name,
                .token.string,
                .token.char,
                .token.builtin,
                .token.inserted {
                    color: #690;
                }

                .token.operator,
                .token.entity,
                .token.url,
                .language-css .token.string,
                .style .token.string {
                    color: #9a6e3a;
                    background: hsla(0, 0%, 100%, .5);
                }

                .token.atrule,
                .token.attr-value,
                .token.keyword {
                    color: #07a;
                    color: blue;
                }

                .token.function,
                .token.class-name {
                    color: #DD4A68;
                }

                .token.regex,
                .token.important,
                .token.variable {
                    color: #e90;
                }

                .token.important,
                .token.bold {
                    font-weight: bold;
                }
                .token.italic {
                    font-style: italic;
                }

                .token.entity {
                    cursor: help;
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
        <code class="language-sql">
        <cfoutput query="qCode">
            #encodeForHTMLAttribute( qCode.Text )#
        </cfoutput>
        </code>
    </pre>

    <script src="https://cdn.awayx.com/base/script/javascript/prism/1.15/prism.js"></script>
    <cfset request.focusHiLightOff = 1>
</body>
</html>