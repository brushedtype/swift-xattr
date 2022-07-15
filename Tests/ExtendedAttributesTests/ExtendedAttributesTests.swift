import XCTest
@testable import ExtendedAttributes

final class ExtendedAttributesTests: XCTestCase {

    func testExample() throws {
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        guard FileManager.default.createFile(atPath: tempFile.path, contents: nil) == true else {
            return XCTFail("failed to create temporary file")
        }


        // ============================
        // 1. test fetch initial xattrs
        // ============================
        let attrs = try tempFile.extendedAttributes()
        XCTAssertTrue(attrs.isEmpty)


        // =========================
        // 2. test storing new xattr
        // =========================
        var val = UInt16(1).bigEndian
        let dat = Data(bytes: &val, count: MemoryLayout<UInt16>.size)

        try tempFile.setExtendedAttributeData(dat, attributeName: "co.brushedtype.xattr-test", flags: [.contentDependent])

        let updatedAttrs = try tempFile.extendedAttributes()

        guard let firstAttr = updatedAttrs.first else {
            return XCTFail("missing expected xattr")
        }

        XCTAssertEqual(firstAttr.rawValue, "co.brushedtype.xattr-test#C")
        XCTAssertEqual(firstAttr.flags, [.contentDependent])


        // ============================
        // 3. test fetching named xattr
        // ============================
        let outDat = try tempFile.extendedAttributeData(rawAttributeName: firstAttr.rawValue)
        let outVal = outDat.withUnsafeBytes({ $0.load(as: UInt16.self).bigEndian })

        XCTAssertEqual(outVal, 1)


        // ============================
        // 4. test removing named xattr
        // ============================
        try tempFile.removeExtendedAttribute(rawAttributeName: "co.brushedtype.xattr-test#C")

        let finalAttrs = try tempFile.extendedAttributes()
        XCTAssertTrue(finalAttrs.isEmpty)
    }

}
