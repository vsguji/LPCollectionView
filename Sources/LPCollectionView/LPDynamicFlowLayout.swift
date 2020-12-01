//
//  LPCustomFlowLayout.swift
//  DemoCollectionView
//
//  Created by lipeng on 2020/7/30.
//  Copyright © 2020 lipeng. All rights reserved.
//

import UIKit

open class LPDynamicFlowLayout: UICollectionViewFlowLayout {

   private(set) var _animator:UIDynamicAnimator?
    
    var springDamping:CGFloat = 0.5 { // 阻尼
        didSet{
            _animator?.behaviors.forEach({ (behavior) in
                (behavior as! UIAttachmentBehavior).damping = springDamping
            })
        }
    }
    
    var springFrequency:CGFloat = 0.8 { // 频率
        didSet {
            _animator?.behaviors.forEach({ (behavivor) in
                (behavivor as! UIAttachmentBehavior).frequency = springFrequency
            })
        }
    }
    
    var resistanceFactor:CGFloat = 500 // 阻力
    
    override init() {
        super.init()
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func prepare() {
        super.prepare()
        if _animator == nil {
            _animator = UIDynamicAnimator(collectionViewLayout: self)
            let contentSize = collectionViewContentSize
            let items = super.layoutAttributesForElements(in: CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
            items?.forEach({ (item) in
                let spring = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
                spring.length = 0
                spring.damping = self.springDamping
                spring.frequency = self.springFrequency
                _animator?.addBehavior(spring)
            })
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return _animator?.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return _animator?.layoutAttributesForCell(at: indexPath)
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let scrollView = collectionView else { return false}
        let scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y
        let touchLocation = scrollView.panGestureRecognizer.location(in: scrollView)
        _animator?.behaviors.forEach({ (behavior) in
            let anchorPoint = (behavior as! UIAttachmentBehavior).anchorPoint
            let distanceFromTouch = CGFloat(fabsf(Float(touchLocation.y - anchorPoint.y)))
            let scrollResistance = distanceFromTouch / self.resistanceFactor
            
            let item = (behavior as! UIAttachmentBehavior).items.first!
            var center = item.center
            center.y += scrollDelta > 0 ? min(scrollDelta,scrollDelta * scrollResistance) : max(scrollDelta,scrollDelta * scrollResistance)
            item.center = center
            _animator?.updateItem(usingCurrentState: item)
        })
        return false
    }
    
}
