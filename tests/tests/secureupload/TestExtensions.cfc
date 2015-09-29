component displayName="Test Extensions" extends="BaseTest" {
	
	function testExtensionListMiddle() {
		var result = doUpload({extensions="jpg,png,gif", type="image"}, getAssetPath("foundeo.png"));
		$assert.isTrue(result.success, "success should be true");
		$assert.isTrue(result.validExtension, "validExtension should be true");
		$assert.isTrue(result.validType, "validType should be true");
		$assert.isEqual(result.ext, "png", "ext should be png");
		$assert.isTrue(result.deletedUploadedFile, "deletedUploadedFile should be true");
	}

	function testExtensionListEnd() {
		var result = doUpload({extensions="jpg,png", type="image"}, getAssetPath("foundeo.png"));
		$assert.isTrue(result.success, "success should be true");
		$assert.isTrue(result.validExtension, "validExtension should be true");
		$assert.isTrue(result.validType, "validType should be true");
		$assert.isEqual(result.ext, "png", "ext should be png");
		$assert.isTrue(result.deletedUploadedFile, "deletedUploadedFile should be true");
	}

	function testSingleExtension() {
		var result = doUpload({extensions="png", type="image"}, getAssetPath("foundeo.png"));
		$assert.isTrue(result.success, "success should be true");
		$assert.isTrue(result.validExtension, "validExtension should be true");
		$assert.isTrue(result.validType, "validType should be true");
		$assert.isEqual(result.ext, "png", "ext should be png");
		$assert.isTrue(result.deletedUploadedFile, "deletedUploadedFile should be true");
	}

	function testExtensionNoInList() {
		var result = doUpload({extensions="png", onFailure="log" }, getAssetPath("test.txt"));
		$assert.isFalse(result.success, "success should be false");
		$assert.isFalse(result.validExtension, "validExtension should be false");
		
	}

}