//
//  LPCollectionDataSource.swift
//  DemoCollectionView
//
//  Created by lipeng on 2020/7/28.
//  Copyright © 2020 lipeng. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    internal var lpCollectionDataSource:LPBaseCollectionViewDataSource?{
        
        get {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "lpCollectionDataSource".hashValue)
            return objc_getAssociatedObject(self, key) as? LPBaseCollectionViewDataSource
        }
        set {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "lpCollectionDataSource".hashValue)
            objc_setAssociatedObject(self, key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    var isChange:Bool! {
        get {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "isChange".hashValue)
            return (objc_getAssociatedObject(self, key) as? NSNumber)?.boolValue
        }
        set {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "isChange".hashValue)
            objc_setAssociatedObject(self, key, NSNumber(value: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var cellAttributesArray:[UICollectionViewLayoutAttributes]? {
        get {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "cellAttributesArray".hashValue)
            return (objc_getAssociatedObject(self, key) as? [UICollectionViewLayoutAttributes])
        }
        set {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "cellAttributesArray".hashValue)
            objc_setAssociatedObject(self, key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func getIdentifiter() -> String {
        let uuidRef = CFUUIDCreate(nil)
        let uuidStrRef = CFUUIDCreateString(nil, uuidRef)
        let retStr = uuidStrRef! as String
        return retStr
    }
    
    func makeDataSource(_ maker:@escaping(_:LPCollectionDataSourceMaker?) ->Void,_ viewLayout:UICollectionViewLayout? = UICollectionViewFlowLayout()) {
        let make = LPCollectionDataSourceMaker(self,viewLayout)
        maker(make)
        var dataSourceClass = LPBaseCollectionViewDataSource.self
        var delegates = [AnyHashable:Any]()
        if make.scrollViewDidSCrollBlock != nil {
            let key:UnsafePointer! = UnsafePointer<Int8>.init(bitPattern: "getIdentifier".hashValue)
            dataSourceClass = objc_allocateClassPair(dataSourceClass, key, 0) as! LPBaseCollectionViewDataSource.Type
            if make.scrollViewDidSCrollBlock != nil {
                let key:OpaquePointer! = OpaquePointer.init(bitPattern: "scrollViewDidScroll".hashValue)
                class_addMethod(dataSourceClass, NSSelectorFromString(""), key, "v@:@")
                delegates["scrollViewDidSCroll:"] = make.scrollViewDidSCrollBlock
            }
        }
        let delegateProtocol = dataSourceClass.init()
        delegateProtocol.sections = make.sections
        delegateProtocol.delegates = delegates
        self.lpCollectionDataSource = delegateProtocol
        self.dataSource = delegateProtocol
        self.delegate = delegateProtocol
      //  self.dragDelegate = delegateProtocol
      //  self.dropDelegate = delegateProtocol
        self.isChange = false
        // 增加长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(lonePressMoving(_:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
   func makeSection(withData data:[AnyHashable]?,cellClass:AnyClass) {
        let flowLayout = UICollectionViewFlowLayout()
            makeDataSource({ (make) in
                make?.makeSection({ (section) in
                    section?.data(data)
                    section?.cell(cellClass)
                    section?.adapter({ (cell, rowObj, row, section) in
                        if cell != nil {
                            let cellObj = cell as! NSObjectProtocol
                            if cellObj.responds(to: NSSelectorFromString("configure:")) {
                                cellObj.perform(NSSelectorFromString("configure:"), with: rowObj)
                            }
                            else if cellObj.responds(to: NSSelectorFromString("configure:index:")) {
                                cellObj.perform(NSSelectorFromString("configure:index:"), with: rowObj, with: row)
                            }
                        }
                    })
                })
            }, flowLayout)
      }

    /// MARK : -  长按手势,拖动
    /// 弊端: 长按手势拖动，会影响周围数据变化
    
    @objc func lonePressMoving(_ longPress:UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            let sourceIndexPath = self.indexPathForItem(at:longPress.location(in: self))
            self.beginInteractiveMovementForItem(at: sourceIndexPath!)
            break
        case .changed:
            self.updateInteractiveMovementTargetPosition(longPress.location(in: longPress.view))
            break
        case .ended:
            self.endInteractiveMovement()
            break
        default:
            self.cancelInteractiveMovement()
        }
    }
    
    private func scrollViewDidScroll(_ selfObj:Any? ,_ cmd:Selector,_ scrollView:UIScrollView)  {
        let delegateProtocol:LPBaseCollectionViewDataSourceProtocol = selfObj as! LPBaseCollectionViewDataSourceProtocol
        let block:((_ scrollView:UIScrollView?) -> Void)? = delegateProtocol.delegates?[NSStringFromSelector(cmd)] as? ((UIScrollView?) ->Void)
        block?(scrollView)
    }

}
