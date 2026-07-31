//
//  ProjectURLValidatorTests.swift
//  MileStoneTests
//

import XCTest
@testable import MileStone

final class ProjectURLValidatorTests: XCTestCase {
    func testAcceptsHTTPAndHTTPSURLs() {
        XCTAssertEqual(
            ProjectURLValidator.validatedURL(from: "https://example.com/path")?.absoluteString,
            "https://example.com/path"
        )
        XCTAssertEqual(
            ProjectURLValidator.validatedURL(from: "http://example.com")?.absoluteString,
            "http://example.com"
        )
    }

    func testTrimsWhitespaceBeforePersistence() {
        XCTAssertEqual(
            ProjectURLValidator.valueForPersistence(from: "  https://example.com/path  \n"),
            "https://example.com/path"
        )
    }

    func testRejectsInvalidOrUnsupportedURLs() {
        XCTAssertNil(ProjectURLValidator.validatedURL(from: "http://exa mple.com"))
        XCTAssertNil(ProjectURLValidator.validatedURL(from: "example.com"))
        XCTAssertNil(ProjectURLValidator.validatedURL(from: "ftp://example.com"))
        XCTAssertNil(ProjectURLValidator.validatedURL(from: "https://"))
        XCTAssertNil(ProjectURLValidator.validatedURL(from: ""))
        XCTAssertNil(ProjectURLValidator.validatedURL(from: nil))
    }

    func testInvalidURLIsNotPersisted() {
        XCTAssertNil(ProjectURLValidator.valueForPersistence(from: "http://exa mple.com"))
    }
}
