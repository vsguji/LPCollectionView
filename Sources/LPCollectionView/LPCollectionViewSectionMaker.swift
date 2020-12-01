//
//  LPCollectionViewSectionMaker.swift
//  DemoCollectionView
//
//  Created by lipeng on 2020/7/28.
//  Copyright © 2020 lipeng. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

open class LPCollectionViewSectionMaker {
    
    lazy var section = LPCollectionViewDataSourceSection()
    
    @discardableResult
    func cell(_ cell:AnyClass) -> LPCollectionViewSectionMaker {
        self.section.cell = cell
        if self.section.identifier == nil {
            self.section.identifier = getIdentifier()
        }
        return self
    }
    
    @discardableResult
    func data(_ data:[Any]?) -> LPCollectionViewSectionMaker {
        if let data = data {
            self.section.data = data
        }
        return self
    }
    
    @discardableResult
    func adapter(_ adapterBlock:@escaping AdapterCollectionViewBlock) -> LPCollectionViewSectionMaker {
        self.section.adapter = adapterBlock
        return self
    }
    
    @discardableResult
    func headerModel(_ model:Any?) -> LPCollectionViewSectionMaker {
        self.section.headerModel = model
        return self
    }
    
    @discardableResult
    func autoModelHeight(_ autoHeight:Bool = false) -> LPCollectionViewSectionMaker {
        self.section.autoModelHeight = autoHeight
        return self
    }
    
    @discardableResult
    func headerAdapter(_ adapterBlock:@escaping AdapterReusableViewBock) -> LPCollectionViewSectionMaker {
        self.section.headerAdapter = adapterBlock
        return self
    }
    
    @discardableResult
    func footerModel(_ model:Any?) -> LPCollectionViewSectionMaker {
        self.section.footerModel = model
        return self
    }
    
    @discardableResult
    func footerAdapter(_ adapterBlock:@escaping AdapterReusableViewBock) -> LPCollectionViewSectionMaker {
        self.section.footerAdapter = adapterBlock
        return self
    }
    
    @discardableResult
    func height (_ height:CGFloat) ->LPCollectionViewSectionMaker {
        self.section.staticHeight = height
        return self
    }
    
    @discardableResult
    func width (_ width:CGFloat) ->LPCollectionViewSectionMaker {
        self.section.staticWidth = width
        return self
    }
    
    @discardableResult
    func autoHeight() -> LPCollectionViewSectionMaker {
        self.section.isAutoHeight = true
        return self
    }
    
    @discardableResult
    func event(_ eventBlock:@escaping EventCollectionViewBlock) ->LPCollectionViewSectionMaker {
        self.section.event = eventBlock
        return self
    }
    
    @discardableResult
    func headerView(_ headerView:AnyClass) -> LPCollectionViewSectionMaker {
         self.section.headerView = headerView
        if self.section.headerIdentifier == nil {
            self.section.headerIdentifier = getHeaderViewIdentifier()
        }
        return self
    }
    
    @discardableResult
    func footerView(_ footerView:AnyClass) -> LPCollectionViewSectionMaker {
        self.section.footerView = footerView
        if self.section.footerIdentifier == nil {
            self.section.footerIdentifier = getFooterViewIdentifier()
        }
        return self
    }
    
    @discardableResult
    func cellItemSize(_ itemSize:CGSize) -> LPCollectionViewSectionMaker {
        self.section.cellItemSize = itemSize
        return self
    }
    
    @discardableResult
    func headerSize(_ size:CGSize) -> LPCollectionViewSectionMaker {
        self.section.headerSize = size
        return self
    }
    
    @discardableResult
    func footerSize(_ size:CGSize) -> LPCollectionViewSectionMaker {
        self.section.footerSize = size
        return self
    }
    
    func getIdentifier() ->String {
        let uuidRef = CFUUIDCreate(nil)
        let uuidStrRef = CFUUIDCreateString(nil, uuidRef)
        let reStr = uuidStrRef! as String
        return reStr
    }
    
    func getHeaderViewIdentifier() ->String {
           let uuidRef = CFUUIDCreate(nil)
           let uuidStrRef = CFUUIDCreateString(nil, uuidRef)
           let reStr = uuidStrRef! as String
           return "headerView" + reStr
    }
    
    func getFooterViewIdentifier() -> String {
        let uuidRef = CFUUIDCreate(nil)
        let uuidStrRef = CFUUIDCreateString(nil, uuidRef)
        let reStr = uuidStrRef! as String
        return "footerView" + reStr
    }
}
