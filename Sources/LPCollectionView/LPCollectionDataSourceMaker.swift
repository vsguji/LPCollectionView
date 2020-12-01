//
//  LPCollectionDataSourceMaker.swift
//  DemoCollectionView
//
//  Created by lipeng on 2020/7/28.
//  Copyright © 2020 lipeng. All rights reserved.
//

import Foundation
import UIKit

open class LPCollectionDataSourceMaker {
    
    weak var collectionView:UICollectionView?
    weak var collectionViewLayout:UICollectionViewLayout?
    
    lazy var sections = [LPCollectionViewDataSourceSection]()
    var scrollViewDidSCrollBlock:((_ scrollView:UIScrollView) -> Void)?

    required public init(_ collectionView:UICollectionView,_ viewLayout:UICollectionViewLayout?) {
        self.collectionView = collectionView
        self.collectionViewLayout = viewLayout
    }
    
    func makeSection(_ block:@escaping (_ section:LPCollectionViewSectionMaker?) ->Void) {
        let sectionMaker = LPCollectionViewSectionMaker()
        block(sectionMaker)
        if sectionMaker.section.cell != nil {
            self.collectionView?.register(sectionMaker.section.cell, forCellWithReuseIdentifier: sectionMaker.section.identifier ?? "")
        }
        if sectionMaker.section.headerView != nil {
            self.collectionView?.register(sectionMaker.section.headerView,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: sectionMaker.section.headerIdentifier ?? "")
        }
        if sectionMaker.section.footerView != nil {
            self.collectionView?.register(sectionMaker.section.footerView,
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                          withReuseIdentifier: sectionMaker.section.footerIdentifier ?? "")
        }
        self.sections.append(sectionMaker.section)
    }
    
    func height() ->(CGFloat) -> LPCollectionDataSourceMaker {
        return { height in
            
            return self
        }
    }

    fileprivate func scrollViewDidScroll(_ block:@escaping (_ scrollView:UIScrollView) ->Void) {
        self.scrollViewDidSCrollBlock = block
    }
}
