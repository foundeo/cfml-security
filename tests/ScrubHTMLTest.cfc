<cfcomponent extends="base">
	
	<cffunction name="testScrubHTML">
		<cfset assertEquals("test123", getSecurityUtil().scrubHTML("test123"))>
		
	</cffunction>
	
	<cffunction name="testScrubHTMLSimple">
		<cfset var tags = {"p"={}, "i"={}, "em"={}, "strong"={}, "b"={}}>
		<cfset var result = "">
		<cfset assertEquals("test123", getSecurityUtil().scrubHTML("test123", tags))>
		<cfset result = getSecurityUtil().scrubHTML("<p>test123</p>", tags)>
		<cfset assert("<p>test123</p>" IS result, "Values do not match: #htmlEditFormat(result)#")>
	</cffunction>
	
	<cffunction name="testBR">
		<cfset var tags = {"br"={}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<br />", tags)>
		<cfset assert("<br />" IS result, "Values do not match: #htmlEditFormat(result)#")>
	</cffunction>
	
	<cffunction name="testAttrib">
		<cfset var tags = {"p"={"id"="match:[a-z0-9]*"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<p id=""test"" />", tags)>
		<cfset assert("<p id=""test"" />" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testTagScrub">
		<cfset var tags = {"img"={"id"="match:[a-z0-9]*"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("This is a test. <p id=""test"" />12345", tags)>
		<cfset assert("This is a test. 12345" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testMalformed">
		<cfset var tags = {"img"={"src"="match:^[a-z0-9]+$"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("This is a test. <p id=""test"" /12345", tags)>
		<cfset assert("This is a test. " IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testGroup">
		<cfset var tags = {"p"={"class"="match:(bacon|pork|ham)"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<p class=""chicken"">1<p class=""pork"">2", tags)>
		<cfset assert("<p>1<p class=""pork"">2" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testUri">
		<cfset var tags = {"img"={"src"="uri"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<img src=""/index.cfm?id=1&x=2%20"" />", tags)>
		<cfset assert("<img src=""/index.cfm?id=1&x=2%20"" />" IS result, "Values do not match: #xmlformat(result)#")>
		<cfset result = getSecurityUtil().scrubHTML("<img src=""/index.cfm?id=1&x=2%20 f"" />", tags)>
		<cfset assert("<img />" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testUrl">
		<cfset var tags = {"img"={"src"="url"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<img src=""https://ex-ample.com/index.cfm?id=1&x=2%20"" />", tags)>
		<cfset assert("<img src=""https://ex-ample.com/index.cfm?id=1&x=2%20"" />" IS result, "Values do not match: #xmlformat(result)#")>
		<cfset result = getSecurityUtil().scrubHTML("<img src=""javascript:foo"" />", tags)>
		<cfset assert("<img />" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testRemove">
		<cfset var tags = {"p"={"id"="remove:[^a-zA-Z0-9]"}}>
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<p id=""test@example.com"" />", tags)>
		<cfset assert("<p id=""testexamplecom"" />" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	<cffunction name="testDefaultPolicy">
		<cfset var result = "">
		<cfset result = getSecurityUtil().scrubHTML("<table><thead><tr><th colspan=""2"">Test</th></tr></thead><tbody><tr><td><div /><hacker /></td></tr></tbody></table>")>
		<cfset assert("<table><thead><tr><th colspan=""2"">Test</th></tr></thead><tbody><tr><td><div /></td></tr></tbody></table>" IS result, "Values do not match: #xmlformat(result)#")>
	</cffunction>
	
	
	
</cfcomponent>