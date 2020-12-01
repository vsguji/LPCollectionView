//
//  LPDataSourceSection.swift
//  DemoCollectionView
//
//  Created by lipeng on 2020/7/28.
//  Copyright © 2020 lipeng. All rights reserved.
//

import Foundation
import UIKit

open class  LPCollectionViewDataSourceSection {
    
    var data:[Any]?
    var cell:AnyClass?
    var identifier:String?
    var adapter:AdapterCollectionViewBlock?
    var event:EventCollectionViewBlock?
    
    var headerModel:Any?
    
    var headerIdentifier:String?
    var headerView:AnyClass?
    var headerSize:CGSize = .zero
    var headerAdapter:AdapterReusableViewBock?
    
    var footerModel:Any?
    var footerIdentifier:String?
    var footerView:AnyClass?
    var footerSize:CGSize = .zero
    var footerAdapter:AdapterReusableViewBock?
    
    var isAutoHeight:Bool = false
    var cellItemSize:CGSize = .zero
    var staticWidth:CGFloat = 0.0
    var staticHeight:CGFloat = 0.0
    var autoModelHeight:Bool = false
    var minimumLineSpacing:CGFloat = 10.0
    var minimumInteritemSpacing:CGFloat = 10.0
    
    init() {
        
    }
}
