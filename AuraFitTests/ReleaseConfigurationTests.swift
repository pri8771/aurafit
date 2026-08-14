import XCTest
@testable import AuraFit

final class ReleaseConfigurationTests: XCTestCase {

    func testPrivacyManifestDeclaresLocalFileTimestampReason() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let data = try Data(contentsOf: url)
        var format = PropertyListSerialization.PropertyListFormat.xml
        let object = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: &format
        )
        let plist = try XCTUnwrap(
            object as? [String: Any]
        )

        XCTAssertEqual(plist["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual((plist["NSPrivacyTrackingDomains"] as? [String])?.count, 0)
        XCTAssertEqual((plist["NSPrivacyCollectedDataTypes"] as? [[String: Any]])?.count, 0)

        let accessed = try XCTUnwrap(plist["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        let fileTimestamp = accessed.first {
            $0["NSPrivacyAccessedAPIType"] as? String
                == "NSPrivacyAccessedAPICategoryFileTimestamp"
        }
        XCTAssertNotNil(fileTimestamp)
        XCTAssertEqual(fileTimestamp?["NSPrivacyAccessedAPITypeReasons"] as? [String], ["C617.1"])
    }

    func testInfoPlistMatchesCameraAndSystemPickerBehavior() {
        let info = Bundle.main.infoDictionary

        XCTAssertNotNil(info?["NSCameraUsageDescription"])
        XCTAssertNotNil(info?["NSPhotoLibraryAddUsageDescription"])
        XCTAssertNil(
            info?["NSPhotoLibraryUsageDescription"],
            "PhotosPicker import must not advertise broad Photo Library read access."
        )
        XCTAssertEqual(info?["ITSAppUsesNonExemptEncryption"] as? Bool, false)
        XCTAssertEqual(info?["CFBundleDisplayName"] as? String, "AuraFit")
    }

    func testDevelopmentAndUnlicensedAssetsAreNotBundled() {
        XCTAssertNil(Bundle.main.url(forResource: "AuraFit", withExtension: "storekit"))
        XCTAssertNil(Bundle.main.url(forResource: "MobileCLIPImageEncoder", withExtension: "mlmodelc"))
        XCTAssertNil(Bundle.main.url(forResource: "CLIPLabelEmbeddings", withExtension: "json"))
        XCTAssertNil(Bundle.main.url(forResource: "OutfitClassifier", withExtension: "mlmodelc"))
    }
}
