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
	
	<cffunction name="scrub" returntype="string" output="false" hint="Strips any non-alpha numeric chars and returns the string.">
		<cfargument name="str" type="string">
		<cfargument name="allow" type="string" default="" hint="Any additional characters to allow other than a-z0-9, must be regex escaped">
		<cfreturn ReReplace(arguments.str, "[^a-zA-Z0-9#arguments.allow#]")>
	</cffunction>
	
	<cffunction name="integer" returntype="numeric" output="false" hint="Ensures that the string is an integer, if not returns 0">
		<cfargument name="str" type="string">
		<cfif NOT ReFind("^-?[0-9]+$", arguments.str)>
			<cfreturn 0>
		<cfelse>
			<cfreturn arguments.str>
		</cfif>
	</cffunction>
	
</cfcomponent>