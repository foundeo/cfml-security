component extends="BaseTest" {
	
	function testGetAssetPath() {
		debug(getAssetPath("foundeo.png"));
		$assert.isTrue(fileExists(getAssetPath("foundeo.png")), "File not found: #getAssetPath("foundeo.png")#");
	}

	function testGetUploadURL() {
		debug(getUploadURL());
		$assert.isTrue(IsValid("url",getUploadURL()), "The value: #getUploadURL()# is not a url");
	}

	function testGenerateUploadKey() {
		var k = generateUploadKey("test");
		$assert.isEqual(k.h, Hmac(k.t & "test", application.token, "HMACSHA512"));
	}
}