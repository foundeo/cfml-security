<cfcomponent output="false" hint="Security Utility Functions">
	<!---
		Copyright (c) 2012 Pete Freitag Foundeo Inc., http://foundeo.com/

		Permission is hereby granted, free of charge, to any person obtaining
		a copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		
		The above copyright notice and this permission notice shall be
		included in all copies or substantial portions of the Software.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
		NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
		LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
		OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
		WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	--->
	
	<cfset variables.esapiBuiltin = false>
	<cfset variables.inited = false>
	
	<cffunction name="init" returntype="securityutil" output="false">
		<cftry>
			<cfif StructKeyExists(GetFunctionList(), "encodeForHTML")>
				<cfset variables.esapiBuiltin = true>
			<cfelse>
				<cfset variables.esapi = CreateObject("java", "org.owasp.esapi.ESAPI")>
			</cfif>
			<cfset variables.inited = true>
			<cfcatch>
				<cfrethrow>
				<cfthrow message="Unable to leverage ESAPI, please make sure you have applied all security patches, or that ESAPI jar files are part of the classpath." detail="#XmlFormat(cfcatch.message)# -- #XmlFormat(cfcatch.detail)#">
			</cfcatch>
		</cftry>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="scrub" returntype="string" output="false" hint="Strips any non-alpha numeric chars and returns the string.">
		<cfargument name="str" type="string">
		<cfargument name="allow" type="string" default="" hint="Any additional characters to allow other than a-z0-9, must be regex escaped">
		<cfreturn ReReplace(arguments.str, "[^a-zA-Z0-9#arguments.allow#]", "", "ALL")>
	</cffunction>
	
	<cffunction name="scrubList" returntype="string" output="false" hint="Calls scrub on a list of strings, removes items that are empty after scrub">
		<cfargument name="str" type="string">
		<cfargument name="allow" type="string" default="">
		<cfargument name="delimiter" default="," type="string">
		<cfset var result = "">
		<cfset var i = "">
		<cfloop list="#arguments.str#" delimiters="#arguments.delimeter#" index="i">
			<cfset i = scrub(str=arguments.str, allow=arguments.allow)>
			<cfif Len(i) OR NOT arguments.removeEmptyValues>
				<cfset ListAppend(result, i, arguments.delimiter)>
			</cfif>
		</cfloop> 
		<cfreturn result>
	</cffunction>
	
	<cffunction name="integer" returntype="numeric" output="false" hint="Ensures that the string is an integer, if not returns arguments.default/0">
		<cfargument name="str" type="string">
		<cfargument name="default" default="0" type="numeric">
		<cfif NOT ReFind("^-?[0-9]+$", arguments.str)>
			<cfreturn arguments.default>
		<cfelse>
			<cfreturn arguments.str>
		</cfif>
	</cffunction>
	
	<cffunction name="encodeHTML" output="false" hint="Runs the ESAPI encodeForHTML method using either CFs builtin or falls back on java.">
		<cfargument name="input" hint="Currently supports string input but eventually it could operate on an entire data structure at once, eg struct query">
		<cfif variables.esapiBuiltin>
			<cfreturn encodeForHTML(arguments.input)>
		<cfelse>
			<cfset assertInit()>
			<cfreturn variables.esapi.encoder().encodeForHTML(arguments.input)>	
		</cfif>
	</cffunction>
	
	<cffunction name="encodeHTMLAttribute" output="false" hint="Runs the ESAPI encodeForHTMLAttribute method using either CFs builtin or falls back on java.">
		<cfargument name="input">
		<cfif variables.esapiBuiltin>
			<cfreturn encodeForHTMLAttribute(arguments.input)>
		<cfelse>
			<cfset assertInit()>
			<cfreturn variables.esapi.encoder().encodeForHTMLAttribute(arguments.input)>	
		</cfif>
	</cffunction>
	
	<cffunction name="encodeURL" output="false" hint="Runs the ESAPI encodeForURL method using either CFs builtin or falls back on java.">
		<cfargument name="input">
		<cfif variables.esapiBuiltin>
			<cfreturn encodeForURL(arguments.input)>
		<cfelse>
			<cfset assertInit()>
			<cfreturn variables.esapi.encoder().encodeForURL(arguments.input)>	
		</cfif>
	</cffunction>
	
	<cffunction name="reduceEncoding" output="false" hint="Runs ESAPI canonicalize method on the input which decodes HTMLEntity, percent (URL) encoding, and JavaScript encoding">
		<cfargument name="input">
		<cfargument name="restrictMultiple" hint="When true throws exception if multiple encoding is present." type="boolean" default="false">
		<cfargument name="restrictMixed" hint="When true throws exception if mixed encoding is present." type="boolean" default="false">
		<cfif variables.esapiBuiltin>
			<cfreturn canonicalize(arguments.input, arguments.restrictMultiple, arguments.restrictMixed)>
		<cfelse>
			<cfset assertInit()>
			<cfreturn variables.esapi.encoder().canonicalize(arguments.input, JavaCast("boolean", arguments.restrictMultiple), JavaCast("boolean", arguments.restrictMixed))>	
		</cfif>
	</cffunction>
	
	<cffunction name="scrubHTML" output="false" hint="Removes any non-allowed HTML tags or attributes from an input string.">
		<cfargument name="in">
		<cfargument name="tags" default="#getDefaultHTMLTagPolicy()#">
		<cfset var inLen = Len(arguments.in)>
		<cfset var i = 0>
		<cfset var c = "">
		<cfset var out = CreateObject("java", "java.lang.StringBuffer").init(inLen)>
		<cfset var inTag = false>
		<cfset var tag = "">
		<cfset var tagName = "">
		<cfset var next = "">
		<cfset var endTag = false>
		<cfset var attrName = "">
		<cfset var attrValue = "">
		<cfset var tagAllowed = false>
		<cfset var inAttributeName = false>
		<cfset var inAttributeValue = false>
		<cfset var attr = "">
		<cfset var singletonTag = false>
		<cfloop from="1" to="#inLen#" index="i">
			<cfset c = Mid(arguments.in, i, 1)>
			<cfif i LT inLen>
				<cfset next = Mid(arguments.in, i+1, 1)>
			<cfelse>
				<!--- end of string --->
				<cfset next = "">
			</cfif>
			<cfif NOT inTag>
				<cfif c IS "<">
					<!--- the next char must be a-z or / if it is a HTML tag --->
					<cfif next IS "/" OR (Asc(LCase(next)) GTE 97 AND Asc(LCase(next)) LTE 122)>
						<cfset inTag = true>
						<cfset endTag = next IS "/">
						<cfset tag = "">
						<cfset tagName = "">
						<cfset tagAllowed = false>
						<cfset inAttributeName = false>
						<cfset inAttributeValue = false>
						<cfset singletonTag = false>
					<cfelse>
						<cfset out.append("&lt;")>
					</cfif>
				<cfelseif c IS ">">   
					<cfset out.append("&gt;")>
				<cfelse>
					<cfset out.append(c)>
				</cfif>
			<cfelse>
				<!--- inside of a tag --->
				<cfif c IS ">">
					<!--- reached the end of the tag --->
					<cfset inTag = false>
					<cfset inAttributeName = false>
					<cfset inAttributeValue = false>
					<cfif NOT Len(tagName)>
						<cfset tagName = tag>
						<cfset tagAllowed = StructKeyExists(arguments.tags, tagName)>
					</cfif>
					<cfif tagAllowed>
						<cfif IsStruct(attr) AND NOT StructIsEmpty(attr)>
							<cfloop list="#StructKeyList(attr)#" index="attrName">
								<cfif StructKeyExists(arguments.tags[tagName], attrName)>
									<cfif arguments.tags[tagName][attrName] IS "empty">
										<cfset tag = tag & " " & attrName>
									<cfelseif arguments.tags[tagName][attrName] IS "*">
										<!--- allow anything in the attribute value --->
										<cfset tag = tag & " " & attrName & "=""" & attr[attrName] & """">
									<cfelseif arguments.tags[tagName][attrName] IS "uri">
										<cfif ReFind("^/[a-zA-Z0-9%_.?/&=-]*$", attr[attrName]) OR ReFind("^[a-zA-Z0-9%_.?/&=-]+$", attr[attrName])>
											<cfset tag = tag & " " & attrName & "=""" & attr[attrName] & """">
										</cfif>
									<cfelseif arguments.tags[tagName][attrName] IS "url">
										<cfif ReFind("^https?://[a-zA-Z0-9.-]+[a-zA-Z0-9%_.?/&=-]*$", attr[attrName]) OR ReFind("^[a-zA-Z0-9%_.?/&=-]+$", attr[attrName])>
											<cfset tag = tag & " " & attrName & "=""" & attr[attrName] & """">
										</cfif>
									<cfelseif Left(arguments.tags[tagName][attrName], 6) IS "match:">
										<cfif ReFind("^"&Right(arguments.tags[tagName][attrName], Len(arguments.tags[tagName][attrName])-6) & "$", attr[attrName])>
											<cfset tag = tag & " " & attrName & "=""" & attr[attrName] & """">	
										</cfif>
									<cfelseif Left(arguments.tags[tagName][attrName], 7) IS "remove:">
										<cfset attrValue = ReReplace(attr[attrName], Right(arguments.tags[tagName][attrName], Len(arguments.tags[tagName][attrName])-7), "", "ALL")>
										<cfif Len(attrValue)>
											<cfset tag = tag & " " & attrName & "=""" & attrValue & """">
										</cfif>
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
						<cfset out.append("<")>
						<cfif endTag>
							<cfset out.append("/")>
						</cfif>
						<cfset out.append(tag)>
						<cfif singletonTag>
							<cfset out.append(" /")>
						</cfif>
						<cfset out.append(">")>
						
					</cfif>
					<cfset tagName = "">
					<cfset tag = "">
					<cfset attr = StructNew()>
				<cfelse>
					<!--- not end of tag --->
					<cfif NOT Len(tagName)>
						<!--- we have not found the tag name yet --->
						<cfif ReFind("[a-zA-Z]", c)>
							<cfset tag = tag & c>
						<cfelseif c IS " " OR c IS Chr(10) OR c IS Chr(9) OR (c IS "/" AND next IS ">")>
							<cfset tagName = tag>
							<!---<cfset tag = tag & c>--->
							<cfset attr = StructNew()>
							<cfset tagAllowed = StructKeyExists(arguments.tags, tagName)>
						<cfelseif NOT Len(tag) AND c IS "/">
							<!--- end tag --->
							<cfset endTag = true>
						</cfif>
					<cfelseif tagAllowed>
						<!--- we have a tag name and are parsing attributes --->
						<cfif NOT inAttributeName AND NOT inAttributeValue>
							<cfset attrName = "">
							<cfset attrValue = "">
							<cfif c IS " " OR c IS Chr(10) OR c IS Chr(9) OR c IS Chr(13)>
								<!---<cfset tag = tag & c>--->
							<cfelseif ReFind("[a-zA-Z-]", c)>
								<cfset inAttributeName = true>
								<cfset attrName = c>
							<cfelseif c IS "/" AND next IS ">">
								<cfset singletonTag = true>
							</cfif>
						<cfelseif inAttributeName>
							<cfif c IS "=">
								<cfset inAttributeName = false>
								<cfset inAttributeValue = true>
							<cfelseif ReFind("[a-zA-Z-]", c)>
								<cfset attrName = attrName & c>
							</cfif>
						<cfelseif inAttributeValue>
							<cfif c IS "'" OR c IS """" OR next IS ">">
								<cfif Len(attrValue)>
									<!--- reached end of attribute value --->
									<cfset attr[attrName] = attrValue>
									<cfset inAttributeValue = false>
								<cfelseif next IS ">" AND Len(attrName)>
									<!--- attribute name with no value at end of tag --->
									<cfset attr[attrName] = "">
									<cfset inAttributeValue=false>	
								</cfif>
							<cfelseif NOT Len(attrValue) AND (c IS " " OR c IS Chr(10) OR c IS Chr(9) OR c IS Chr(13))>
								<!--- attribute name with no value --->
								<cfset attr[attrName] = "">
								<cfset inAttributeValue=false>
							<cfelse>
								<!--- dont allow newlines in attribute values replace with a space --->
								<cfif c IS Chr(10)>
									<cfset attrValue = attrValue & " ">
								<cfelseif c IS NOT Chr(13)>
									<cfset attrValue = attrValue & c>
								</cfif>
							</cfif>
						</cfif>
						<!---<cfset tag = tag & c>--->	
					</cfif>
				</cfif>
			</cfif>
		</cfloop> 
		<cfreturn out.toString()>
	</cffunction>
	
	<cffunction name="setDefaultHTMLTagPolicy">
		<cfargument name="tags" type="struct">
		<cfset variables.defaultHTMLTagPolicy = arguments.tags>
	</cffunction>
	
	<cffunction name="getDefaultHTMLTagPolicy" returntype="struct" hint="Returns policy set via setDefaultHTMLTagPolicy or a fairly safe default">
		<cfset var t = "">
		<cfif StructKeyExists(variables, "defaultHTMLTagPolicy")>
			<cfreturn variables.defaultHTMLTagPolicy>
		<cfelse>
			<cfset t=StructNew()>
			<cfset t.p=StructNew()>
			<cfset t.em=StructNew()>
			<cfset t.b=StructNew()>
			<cfset t.strong=StructNew()>
			<cfset t.br=StructNew()>
			<cfset t.ul=StructNew()>
			<cfset t.li=StructNew()>
			<cfset t.table=StructNew()>
			<cfset t.table.border="match:[0-9]+">
			<cfset t.table.cellspacing="match:[0-9]+">
			<cfset t.table.cellpadding="match:[0-9]+">
			<cfset t.table.width="match:[0-9]+%?">
			<cfset t.table.height="match:[0-9]+%?">
			<cfset t.thead=StructNew()>
			<cfset t.tbody=StructNew()>
			<cfset t.tfoot=StructNew()>
			<cfset t.th=StructNew()>
			<cfset t.th.width = "match:[0-9]+%?">
			<cfset t.th.height = "match:[0-9]+%?">
			<cfset t.th.colspan = "match:[0-9]+">
			<cfset t.tr = StructNew()>
			<cfset t.td = Duplicate(t.th)>
			<cfset t.a = StructNew()>
			<cfset t.a.href="url">
			<cfset t.a.title="replace:[^a-zA-Z0-9 .()_-]">
			<cfset t.a.target="match:(_blank|_parent|_self|_top)">
			<cfset t.a.rel="match:(nofollow|alternate)">
			<cfset t.a.name="alnum">
			<cfset t.div = StructNew()>
			<cfset t.span = StructNew()>
			<cfset setDefaultHTMLTagPolicy(t)>
			<cfreturn t>
		</cfif>
	</cffunction>
	
	<cffunction name="scrubHTMLSimple" output="false">
		<cfargument name="in">
		<cfset var tags = StructNew()>
		
	</cffunction>
	
	<cffunction name="assertInit" returntype="void" output="false" access="package">
		<cfif NOT variables.inited>
			<cfthrow message="You must call init() on securityutil before calling functions in it." type="foundeo.securityutil.noinit">
		</cfif>
	</cffunction>
	
	
</cfcomponent>