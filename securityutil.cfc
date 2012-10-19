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
	
	<cffunction name="assertInit" returntype="void" output="false" access="package">
		<cfif NOT variables.inited>
			<cfthrow message="You must call init() no securityutil before calling functions in it." type="foundeo.securityutil.noinit">
		</cfif>
	</cffunction>
	
	
</cfcomponent>