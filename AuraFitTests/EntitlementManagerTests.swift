import XCTest
@testable import AuraFit

@MainActor
final class EntitlementManagerTests: XCTestCase {

    func testFreeUserIsNotPro() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: false))
        XCTAssertFalse(manager.isPro)
        XCTAssertEqual(manager.tier, .free)
        XCTAssertTrue(manager.exportsWatermarked)
        XCTAssertFalse(manager.canGenerateRevealVideo)
    }

    func testProUserUnlocksEverything() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: true))
        XCTAssertTrue(manager.isPro)
        XCTAssertEqual(manager.tier, .pro)
        XCTAssertFalse(manager.exportsWatermarked)
        XCTAssertTrue(manager.canGenerateRevealVideo)
        XCTAssertTrue(manager.isTemplateUnlocked(ProductCatalog.templateStreetwear))
        XCTAssertTrue(manager.isPersonaTemplateUnlocked(.softLuxury))
    }

    func testTemplateUnlockForFreeUser() {
        let mock = MockPurchaseProvider(isPro: false, purchased: [ProductCatalog.templateStreetwear])
        let manager = EntitlementManager(store: mock)
        XCTAssertTrue(manager.isTemplateUnlocked(ProductCatalog.templateStreetwear))
        XCTAssertFalse(manager.isTemplateUnlocked(ProductCatalog.templateSoftLuxury))
        XCTAssertTrue(manager.isPersonaTemplateUnlocked(.streetwear))
        XCTAssertFalse(manager.isPersonaTemplateUnlocked(.softLuxury))
        // Non-template personas always available.
        XCTAssertTrue(manager.isPersonaTemplateUnlocked(.minimalist))
    }

    func testDailyScanGateForFreeUser() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: false))
        let settings = AppSettings()
        manager.settings = settings

        XCTAssertEqual(manager.remainingFreeScansToday, ProductCatalog.freeDailyScanLimit)
        XCTAssertTrue(manager.canScan)

        for _ in 0..<ProductCatalog.freeDailyScanLimit {
            XCTAssertTrue(manager.canScan)
            manager.registerScan()
        }
        XCTAssertEqual(manager.remainingFreeScansToday, 0)
        XCTAssertFalse(manager.canScan)
    }

    func testProUserHasNoScanLimit() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: true))
        manager.settings = AppSettings()
        for _ in 0..<10 { manager.registerScan() }   // no-op for pro
        XCTAssertTrue(manager.canScan)
        XCTAssertEqual(manager.remainingFreeScansToday, .max)
    }

    func testDailyCounterRollsOverToNewDay() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: false))
        let settings = AppSettings()
        // Simulate yesterday's usage.
        settings.scanCountToday = ProductCatalog.freeDailyScanLimit
        settings.scanCountDayStart = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        manager.settings = settings

        // Rollover happens lazily on read.
        XCTAssertEqual(manager.remainingFreeScansToday, ProductCatalog.freeDailyScanLimit)
        XCTAssertTrue(manager.canScan)
    }

    // MARK: - AURA-ENG-011: unbound settings row must fail closed

    func testUnboundSettingsFailsClosedForFreeUser() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: false))
        XCTAssertNil(manager.settings)
        // Never hand out the full free allowance with nowhere to record usage.
        XCTAssertEqual(manager.remainingFreeScansToday, 0)
        XCTAssertFalse(manager.canScan)
    }

    func testRegisterScanWithUnboundSettingsIsSafeNoOp() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: false))
        manager.registerScan()   // must not trap
        XCTAssertEqual(manager.remainingFreeScansToday, 0)

        // Late binding restores normal quota behaviour.
        let settings = AppSettings()
        manager.settings = settings
        XCTAssertEqual(manager.remainingFreeScansToday, ProductCatalog.freeDailyScanLimit)
        XCTAssertTrue(manager.canScan)
        manager.registerScan()
        XCTAssertEqual(settings.scanCountToday, 1)
    }

    func testUnboundSettingsStillAllowsProUser() {
        let manager = EntitlementManager(store: MockPurchaseProvider(isPro: true))
        XCTAssertNil(manager.settings)
        XCTAssertTrue(manager.canScan)
        XCTAssertEqual(manager.remainingFreeScansToday, .max)
    }

    func testBindSettingsIgnoresNilRatherThanClearingBinding() {
        let environment = AppEnvironment(store: MockPurchaseProvider(isPro: false))
        let settings = AppSettings()
        environment.bindSettings(settings)
        XCTAssertTrue(environment.entitlements.settings === settings)

        // A later nil (row not yet materialized) must not drop a good binding.
        environment.bindSettings(nil)
        XCTAssertTrue(environment.entitlements.settings === settings)
    }

    func testPurchaseUpdatesEntitlement() async throws {
        let mock = MockPurchaseProvider(isPro: false)
        let manager = EntitlementManager(store: mock)
        XCTAssertFalse(manager.isPro)
        mock.simulatePurchase(ProductCatalog.proYearly)
        XCTAssertTrue(manager.isPro)
    }
}
