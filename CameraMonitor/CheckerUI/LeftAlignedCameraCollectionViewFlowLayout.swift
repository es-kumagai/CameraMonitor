import AppKit

/// A vertical flow layout that packs camera previews against the left edge of each row.
@objc(ESLeftAlignedCameraCollectionViewFlowLayout)
@MainActor
final class LeftAlignedCameraCollectionViewFlowLayout: NSCollectionViewFlowLayout {

    /// The copied item attributes with fixed spacing and left-aligned row origins.
    private var alignedAttributes: [IndexPath: NSCollectionViewLayoutAttributes] = [:]

    /// Preserve the flow layout's wrapping and vertical positions while packing each row to the left.
    override func prepare() {
        super.prepare()
        alignedAttributes.removeAll(keepingCapacity: true)
        guard let collectionView else {
            return
        }

        for section in 0..<collectionView.numberOfSections {
            var rowY: CGFloat?
            var nextX = sectionInset.left
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? NSCollectionViewLayoutAttributes else {
                    continue
                }
                if rowY != attributes.frame.minY {
                    rowY = attributes.frame.minY
                    nextX = sectionInset.left
                }
                attributes.frame.origin.x = nextX
                nextX = attributes.frame.maxX + minimumInteritemSpacing
                alignedAttributes[indexPath] = attributes
            }
        }
    }

    /// Return the aligned items intersecting the requested rectangle, retaining supplementary attributes.
    /// - Parameter rect: The visible or prefetched rectangle in collection coordinates.
    /// - Returns: Attributes for intersecting items and the flow layout's non-item elements.
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let supplementary = super.layoutAttributesForElements(in: rect).filter { $0.representedElementCategory != .item }
        return supplementary + alignedAttributes.values.filter { $0.frame.intersects(rect) }
    }

    /// Return the same aligned geometry used by rectangle queries.
    /// - Parameter indexPath: The item location in the collection.
    /// - Returns: The item's aligned attributes, or `nil` when it does not exist.
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        alignedAttributes[indexPath]
    }

    /// Recompute row membership when the available width changes.
    /// - Parameter newBounds: The proposed collection view bounds.
    /// - Returns: Whether the width changed or the base flow layout requires invalidation.
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        newBounds.width != collectionView?.bounds.width || super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
