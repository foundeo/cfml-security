component displayName="Test Helper Functions" extends="BaseTest" {
	
	function testValidateFilePath() {
		var sup = getNewSecureUploadInstance();
		var validPaths = [
				getTempDirectory(), 
				"c:\temp\",
				"c:/temp-dir/", 
				"\\network\path\here",
				"/tmp", 
				"d:\user\temp\path/",
				"ram://",
				"ram://foo",
				"s3://accessKeyId:awsSecretKey@bucketname/file.jpg"
		];
		var p = "";
		for (p in validPaths) {
			$assert.isTrue(sup.validateFilePath(p), "Path: #p# should be valid.");	
		}
		
	}

	

}