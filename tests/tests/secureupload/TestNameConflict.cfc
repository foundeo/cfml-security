component extends="BaseTest" {

	function testNameConflictOverwrite() {
		var result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));

		$assert.isTrue(result.success, "first upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));

		$assert.isTrue(result.success, "second upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		if (fileExists(result.filePath)) {
			fileDelete(result.filePath);
		}

	}

	function testNameConflictRandom() {
		var result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));
		var secondResult = doUpload({extensions="txt", nameconflict="random"}, getAssetPath("text.txt"));
		$assert.isTrue(result.success, "first upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		$assert.isTrue(secondResult.success, "second upload success should be true");
		$assert.isNotEqual(secondResult.fileName, "text.txt");
		$assert.isFalse(secondResult.fileName contains "text");
		$assert.isEqual(".txt", Right(secondResult.fileName, 4));

		if (fileExists(result.filePath)) {
			fileDelete(result.filePath);
		}

	}

	function testNameConflictError() {
		var result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));
		var secondResult = doUpload({extensions="txt", nameconflict="error"}, getAssetPath("text.txt"));
		$assert.isTrue(result.success, "first upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		$assert.isFalse(secondResult.success, "second upload success should be false");
		$assert.isTrue(StructKeyExists(secondResult, "exception"));

		if (fileExists(result.filePath)) {
			fileDelete(result.filePath);
		}

	}

	function testNameConflictOverwriteWithDestinationFileName() {
		var result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));

		$assert.isTrue(result.success, "first upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		result = doUpload({extensions="txt", nameconflict="overwrite", destinationFileName="text.txt"}, getAssetPath("text.txt"));

		$assert.isTrue(result.success, "second upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		if (fileExists(result.filePath)) {
			fileDelete(result.filePath);
		}

	}

	function testNameConflictRandomWithDestinationFileName() {
		var result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));
		var secondResult = doUpload({extensions="txt", nameconflict="random", destinationFileName="text.txt"}, getAssetPath("test.txt"));
		$assert.isTrue(result.success, "first upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		$assert.isTrue(secondResult.success, "second upload success should be true");
		$assert.isNotEqual(secondResult.fileName, "text.txt", "It should not overwrite text.txt because nameconflict!=overwrite");
		$assert.isNotEqual(secondResult.fileName, "test.txt", "It should not save as test.txt");

		if (fileExists(result.filePath)) {
			fileDelete(result.filePath);
		}

	}

	function testNameConflictMakeuniqueWithDestinationFileName() {
		var result = doUpload({extensions="txt", nameconflict="overwrite", keepUploadedFile=true}, getAssetPath("text.txt"));
		var secondResult = doUpload({extensions="txt", nameconflict="makeunique", destinationFileName="text.txt"}, getAssetPath("test.txt"));
		$assert.isTrue(result.success, "first upload success should be true");
		$assert.isEqual(result.fileName, "text.txt");

		$assert.isTrue(secondResult.success, "second upload success should be true");
		$assert.isNotEqual(secondResult.fileName, "text.txt", "It should not overwrite text.txt because nameconflict!=overwrite");
		$assert.isNotEqual(secondResult.fileName, "test.txt", "It should not save as test.txt");

		if (fileExists(result.filePath)) {
			fileDelete(result.filePath);
		}

	}

}