import AppKit
import XCTest
#if DEBUG
@testable import CameraMonitor_Debug_Debug
#else
@testable import CameraMonitor
#endif

/// Regression coverage for overview frame persistence and camera row placement.
@MainActor
final class CameraMonitorTests: XCTestCase {

    /// Ensure the shipped storyboard installs the custom layout and restores the saved frame.
    func testStoryboardRestoresOverviewFrameAndInstallsLeftAlignedLayout() throws {
        let key = "NSWindow Frame \(CameraCollectionWindow.frameSaveName)"
        let previous = UserDefaults.standard.object(forKey: key)
        defer { restoreDefault(previous, forKey: key) }
        let saved = makeWindow(width: 960, height: 540)
        saved.saveFrame(usingName: CameraCollectionWindow.frameSaveName)
        let application = try XCTUnwrap(NSApplication.shared as? Application)
        let originalChecker = application.checkerController
        let originalWindowController = application.cameraCollectionWindowController
        let originalViewController = application.cameraCollectionViewController
        application.checkerController = CheckerController()
        defer {
            application.checkerController = originalChecker
            application.cameraCollectionWindowController = originalWindowController
            application.cameraCollectionViewController = originalViewController
        }
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: CameraCollectionWindow.self))
        let controller = try XCTUnwrap(storyboard.instantiateInitialController() as? CameraCollectionWindowController)
        let window = try XCTUnwrap(controller.window)
        XCTAssertEqual(window.frame, saved.frame)
        let content = try XCTUnwrap(window.contentViewController as? CameraCollectionViewController)
        content.loadViewIfNeeded()
        XCTAssertTrue(content.cameraCollectionView.collectionViewLayout is LeftAlignedCameraCollectionViewFlowLayout)
    }

    /// Ensure startup geometry notifications cannot replace the frame saved by the previous run.
    func testStartupFrameChangesDoNotOverwriteSavedSize() throws {
        let key = "NSWindow Frame \(CameraCollectionWindow.frameSaveName)"
        let previous = UserDefaults.standard.object(forKey: key)
        defer { restoreDefault(previous, forKey: key) }
        let saved = makeWindow(width: 960, height: 540)
        saved.saveFrame(usingName: CameraCollectionWindow.frameSaveName)

        let reopened = makeWindow(width: 480, height: 270)
        reopened.saveFrame()
        reopened.restoreFrame()
        XCTAssertEqual(reopened.frame, saved.frame)

        reopened.setContentSize(NSSize(width: 800, height: 450))
        reopened.saveFrame()
        let nextLaunch = makeWindow(width: 480, height: 270)
        nextLaunch.restoreFrame()
        XCTAssertEqual(nextLaunch.frame, reopened.frame)
    }

    /// Ensure a first launch keeps its default geometry and then permits persistence.
    func testMissingSavedFrameKeepsDefaultSize() {
        let key = "NSWindow Frame \(CameraCollectionWindow.frameSaveName)"
        let previous = UserDefaults.standard.object(forKey: key)
        defer { restoreDefault(previous, forKey: key) }
        UserDefaults.standard.removeObject(forKey: key)
        let window = makeWindow(width: 480, height: 270)
        let original = window.frame
        window.restoreFrame()
        XCTAssertEqual(window.frame, original)
        window.saveFrame()
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))
    }

    /// Ensure a frame saved on a disconnected display is brought onto an available screen.
    func testFrameFromMissingDisplayRemainsAccessible() {
        let key = "NSWindow Frame \(CameraCollectionWindow.frameSaveName)"
        let previous = UserDefaults.standard.object(forKey: key)
        defer { restoreDefault(previous, forKey: key) }
        UserDefaults.standard.set("50000 50000 960 572 50000 50000 1920 1080 ", forKey: key)
        let window = makeWindow(width: 480, height: 270)
        window.restoreFrame()
        let titleBar = NSRect(x: window.frame.minX, y: window.frame.maxY - 32, width: window.frame.width, height: 32)
        XCTAssertTrue(NSScreen.screens.contains { $0.visibleFrame.intersects(titleBar) })
    }

    /// Verify that full and partial rows remain left aligned as the collection width changes.
    func testCameraRowsStayLeftAlignedAfterResizing() throws {
        let collection = NSCollectionView(frame: NSRect(x: 0, y: 0, width: 1000, height: 800))
        let dataSource = PreviewDataSource()
        collection.dataSource = dataSource
        collection.register(NSCollectionViewItem.self, forItemWithIdentifier: .init("preview"))
        let layout = LeftAlignedCameraCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 300, height: 180)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.sectionInset = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        collection.collectionViewLayout = layout
        collection.reloadData()

        for (width, columns) in [(1000.0, 3), (650.0, 2), (450.0, 1)] {
            collection.setFrameSize(NSSize(width: width, height: 800))
            layout.invalidateLayout()
            layout.prepare()
            for item in 0..<dataSource.count {
                let path = IndexPath(item: item, section: 0)
                let attributes = try XCTUnwrap(layout.layoutAttributesForItem(at: path))
                XCTAssertEqual(attributes.frame.minX, 4 + CGFloat(item % columns) * 304)
                let visible = layout.layoutAttributesForElements(in: attributes.frame)
                XCTAssertEqual(visible.first { $0.indexPath == path }?.frame, attributes.frame)
            }
        }
    }

    /// Ensure an empty collection and a single camera retain the same left margin.
    func testEmptyAndSingleCameraLayout() throws {
        let collection = NSCollectionView(frame: NSRect(x: 0, y: 0, width: 1000, height: 800))
        let dataSource = PreviewDataSource()
        collection.dataSource = dataSource
        collection.register(NSCollectionViewItem.self, forItemWithIdentifier: .init("preview"))
        let layout = LeftAlignedCameraCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 300, height: 180)
        layout.sectionInset = NSEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        collection.collectionViewLayout = layout
        for count in [0, 1] {
            dataSource.count = count
            collection.reloadData()
            layout.invalidateLayout()
            layout.prepare()
            let attributes = layout.layoutAttributesForElements(in: collection.bounds)
            XCTAssertEqual(attributes.count, count)
            if count == 1 {
                XCTAssertEqual(attributes.first?.frame.minX, 4)
            }
        }
    }

    /// Create an overview window with realistic resizable AppKit geometry.
    /// - Parameters:
    ///   - width: The content width in points.
    ///   - height: The content height in points.
    /// - Returns: A hidden window ready for frame restoration.
    private func makeWindow(width: CGFloat, height: CGFloat) -> CameraCollectionWindow {
        CameraCollectionWindow(contentRect: NSRect(x: 100, y: 100, width: width, height: height), styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    }

    /// Restore a defaults entry after exercising the application's real frame storage name.
    /// - Parameters:
    ///   - value: The prior value, or `nil` if the entry was absent.
    ///   - key: The frame defaults key.
    private func restoreDefault(_ value: Any?, forKey key: String) {
        if let value {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

/// Camera-independent items for exercising AppKit's actual wrapping behavior.
@MainActor
private final class PreviewDataSource: NSObject, NSCollectionViewDataSource {
    /// The item count, initially including an incomplete final row at common window widths.
    var count = 5

    /// Return the number of preview placeholders.
    /// - Parameters:
    ///   - collectionView: The collection requesting its item count.
    ///   - section: The section whose items are counted.
    /// - Returns: The configured number of preview items.
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { count }

    /// Create an item without starting camera capture.
    /// - Parameters:
    ///   - collectionView: The collection requesting an item.
    ///   - indexPath: The requested item location.
    /// - Returns: A reusable empty preview item.
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        collectionView.makeItem(withIdentifier: .init("preview"), for: indexPath)
    }
}
