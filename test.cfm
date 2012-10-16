<cfset request.security = new securityutil()>
<cfinvoke component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#expandPath('./tests')#"
          recurse="true"
          returnvariable="results" />

<cfoutput> #results.getResultsOutput('extjs')# </cfoutput>		  