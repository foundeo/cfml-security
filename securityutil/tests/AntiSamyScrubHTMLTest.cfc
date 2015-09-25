<cfcomponent extends="base">
	<!--- 
		These tests are derrived from the AntiSamy tests found here:
		https://code.google.com/p/owaspantisamy/source/browse/Java/antisamy/src/test/java/org/owasp/validator/html/test/AntiSamyTest.java
	--->

	<cffunction name="testScriptAttacks">
		<cfset scrubAssert("test<script>alert(document.cookie)</script>","testalert(document.cookie)")>
		<cfset scrubAssert("<<<><<script src=http://fake-evil.ru/test.js>", "&lt;&lt;&lt;&gt;&lt;")>
		<cfset scrubAssert("<script<script src=http://fake-evil.ru/test.js>>", "&gt;")>
		<cfset scrubAssert("<SCRIPT/XSS SRC=""http://ha.ckers.org/xss.js\""></SCRIPT>", "")>
		<cfset scrubAssert("<DIV onload!##$%&()*~+-_.,:;?@[/|\\]^`=alert(""XSS"")>", "<DIV>")>
		<cfset scrubAssert("<DIV ONLOAD=alert('XSS')>", "<DIV>")>
		<cfset scrubAssert("<iframe src=http://ha.ckers.org/scriptlet.html <", "")>
		<cfset scrubAssert("<INPUT TYPE=""IMAGE"" SRC=""javascript:alert('XSS');"">", "")>
		<cfset scrubAssert("<a onblur=""alert(secret)"" href=""http://www.google.com"">Google</a>", "<a href=""http://www.google.com"">Google</a>")>
	</cffunction>

	<cffunction name="testImgAttacks">
		<cfset scrubAssert("<img src=""http://www.myspace.com/img.gif""/>", "<img src=""http://www.myspace.com/img.gif"" />")>
		<cfset scrubAssert("<img src=javascript:alert(document.cookie)>", "<img>")>
		<cfset scrubAssert("<IMG SRC=&##106;&##97;&##118;&##97;&##115;&##99;&##114;&##105;&##112;&##116;&##58;&##97;&##108;&##101;&##114;&##116;&##40;&##39;&##88;&##83;&##83;&##39;&##41;>", "<IMG>")>
		<cfset scrubAssert("<IMG SRC='&##0000106&##0000097&##0000118&##0000097&##0000115&##0000099&##0000114&##0000105&##0000112&##0000116&##0000058&##0000097&##0000108&##0000101&##0000114&##0000116&##0000040&##0000039&##0000088&##0000083&##0000083&##0000039&##0000041'>", "<IMG>")>
		<cfset scrubAssert("<IMG SRC=""jav&##x0D;ascript:alert('XSS');"">", "<IMG>")>
		<cfset scrubAssert("<IMG SRC=&##000106&##000097&##000118&##000097&##000115&##000099&##000114&##000105&##000112&##000116&##000058&##000097&##000108&##000101&##000114&##000116&##000040&##000039&##000088&##000083&##000083&##000039&##000041>", "<IMG>")>
		<cfset scrubAssert("<IMG SRC=&##6A&##61&##76&##61&##73&##63&##72&##69&##70&##74&##3A&##61&##6C&##65&##72&##74&##28&##27&##58&##53&##53&##27&##29>", "<IMG>")>		
		<cfset scrubAssert("<IMG SRC=""javascript:alert('XSS')""", "")>
		<cfset scrubAssert("<IMG LOWSRC=""javascript:alert('XSS')"">", "<IMG>")>
		<cfset scrubAssert("<BGSOUND SRC=""javascript:alert('XSS');"">", "")>
	</cffunction>

	<cffunction name="scrubAssert" output="false">
		<cfargument name="in" type="string" default="">
		<cfargument name="expect" type="string" default="">
		<cfargument name="tags" default="#getSecurityUtil().getDefaultHTMLTagPolicy()#">
		<cfset var result = getSecurityUtil().scrubHTML(arguments.in, arguments.tags)>
		<cfset assertEquals(arguments.expect, result, "Expected: #getSecurityUtil().encodeHTML(arguments.expect)# But Received: #getSecurityUtil().encodeHTML(result)#")>
	</cffunction>

	

</cfcomponent>