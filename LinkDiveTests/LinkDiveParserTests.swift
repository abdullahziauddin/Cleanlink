import XCTest
// @testable import LinkDive // Uncomment when added to Xcode target

final class LinkDiveParserTests: XCTestCase {
    
    func testInstagramValidURLWithIgsh() {
        let input = "https://www.instagram.com/reel/DCEi_TQpISD/?igsh=MnN5Z3Bkczh1ZDFm"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://www.instagram.com/reel/DCEi_TQpISD/")
    }
    
    func testInstagramMultipleParams() {
        let input = "https://www.instagram.com/p/C12345/?utm_source=ig_web_copy_link&igshid=12345&utm_medium=share_sheet"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://www.instagram.com/p/C12345/")
    }
    
    func testTikTokURL() {
        let input = "https://vm.tiktok.com/ZM8123456/?t=1&_r=1"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://vm.tiktok.com/ZM8123456/")
    }
    
    func testXURL() {
        let input = "https://x.com/user/status/123456789?s=46&t=xyz"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://x.com/user/status/123456789")
    }
    
    func testYouTubeURL() {
        let input = "https://youtu.be/dQw4w9WgXcQ?si=123&feature=shared"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://youtu.be/dQw4w9WgXcQ")
    }
    
    func testFacebookURL() {
        let input = "https://www.facebook.com/share/p/12345/?mibextid=Qwerty"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://www.facebook.com/share/p/12345/")
    }
    
    func testLinkedInURL() {
        let input = "https://www.linkedin.com/posts/user_hey-there-activity-123?utm_source=share"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertEqual(result, "https://www.linkedin.com/posts/user_hey-there-activity-123")
    }
    
    func testUnknownURL() {
        // Just strips standard utm params if unknown, or returns nil if we don't return fallback
        // Current implementation returns nil for unknown platforms.
        let input = "https://www.example.com/page?utm_source=test"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertNil(result) // Or depending on implementation
    }
    
    func testMalformedString() {
        let input = "not a valid url string ^^^"
        let result = LinkDiveParser.clean(urlString: input)
        XCTAssertNil(result)
    }
}
