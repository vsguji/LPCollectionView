//
//  LPBaseCollectionViewDataSource.swift
//  DemoCollectionView
//
//  Created by lipeng on 2020/7/28.
//  Copyright © 2020 lipeng. All rights reserved.
//

import Foundation
import UIKit

protocol LPBaseCollectionViewDataSourceProtocol:UICollectionViewDataSource,UICollectionViewDelegate {
    
    var sections:[LPCollectionViewDataSourceSection]! { get set }
    var delegates:[AnyHashable:Any]? { get set}
}

typealias AdapterCollectionViewBlock = (Any?,Any?,Int,Int) -> Void
typealias EventCollectionViewBlock = (Int,Any,Int) -> Void


typealias AdapterReusableViewBock = (UICollectionReusableView?,Any?,Int,Int) -> Void

class LPBaseCollectionViewDataSource: NSObject {
    
    required public override init() {
        
    }
}


extension LPBaseCollectionViewDataSource:LPBaseCollectionViewDataSourceProtocol {
    
     var sections: [LPCollectionViewDataSourceSection]! {
        get {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "sections".hash)
            return objc_getAssociatedObject(self, key) as? [LPCollectionViewDataSourceSection]
        }
        set {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "sections".hash)
            objc_setAssociatedObject(self, key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var delegates: [AnyHashable : Any]? {
        get {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "delegates".hash)
            return objc_getAssociatedObject(self, key) as? [AnyHashable:Any]
        }
        set {
            let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "delegates".hash)
            objc_setAssociatedObject(self, key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.sections![section].data?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        let index = indexPath.item
        let identifier = self.sections![section].identifier ?? ""
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard let block = self.sections[section].adapter else { return cell }
        let data = self.sections[section].data
        block(cell,data,index,section)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // TODO:
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let event = self.sections[section].event
        if event == nil {
            collectionView.deselectItem(at: indexPath, animated: true)
           return
        }
        let item = indexPath.item
        let data = self.sections![section].data![item]
        event?(item,data as Any,section)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let section = self.sections![indexPath.section]
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: section.headerIdentifier ?? "", for: indexPath)
            let model = section.headerModel
            section.headerAdapter?(sectionHeaderView,model,indexPath.item,indexPath.section)
            return sectionHeaderView
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            let section = self.sections![indexPath.section]
            let sectionFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: section.footerIdentifier ?? "", for: indexPath)
             let model = section.footerModel
             section.footerAdapter?(sectionFooterView,model,indexPath.item,indexPath.section)
            return sectionFooterView
        }
        return UICollectionReusableView()
    }
    
    @available(iOS 9.0,*)
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("== canMoveItem at indexPath :\(indexPath) ==")
        // 允许移动
        return true
    }
    
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            var items = self.sections[sourceIndexPath.section].data!
            items.swapAt(sourceIndexPath.item, destinationIndexPath.item)
            self.sections[sourceIndexPath.section].data = items
            collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
            UIView.performWithoutAnimation {
                 collectionView.reloadSections([sourceIndexPath.section])
            }
        }
        else {
            let count = self.sections.count
            if count >= sourceIndexPath.section && count >= destinationIndexPath.section {
                let oldCount = self.sections[sourceIndexPath.section].data?.count ?? 0
                let oldItem = self.sections[sourceIndexPath.section].data![sourceIndexPath.item]
                let newItem = self.sections[destinationIndexPath.section].data![destinationIndexPath.item]
                let newCount = self.sections[destinationIndexPath.section].data?.count ?? 0
                if oldCount > sourceIndexPath.item && newCount > destinationIndexPath.item {
                 UIView.performWithoutAnimation {
                     collectionView.performBatchUpdates({
                         self.sections[sourceIndexPath.section].data!.replaceSubrange(Range(NSMakeRange(sourceIndexPath.item, 1))!, with: [newItem])
                         self.sections[destinationIndexPath.section].data!.replaceSubrange(Range(NSMakeRange(destinationIndexPath.item, 1))!, with: [oldItem])
                         collectionView.reloadSections([sourceIndexPath.section,destinationIndexPath.section])
                     }) { (finished) in
                         print("== finished \(finished)==")
                           collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                         }
                     }
                }
            }
        }
    }
    
    
    func cellForIdentitfier(_ identifier:String,_ collectionView:UICollectionView,_ indexPath:NSIndexPath) -> UICollectionViewCell {
        let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: identifier.hashValue)
        var templateCellsByIdentifiers:[String:UICollectionViewCell]? = objc_getAssociatedObject(self, key) as? [String:UICollectionViewCell]
        if templateCellsByIdentifiers == nil {
            templateCellsByIdentifiers = [:]
            objc_setAssociatedObject(self, key, collectionView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        var templateCell = templateCellsByIdentifiers?[identifier]
        if templateCell == nil {
            templateCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath)
            templateCell?.contentView.translatesAutoresizingMaskIntoConstraints = false
        }
        return templateCell!
    }

}


extension LPBaseCollectionViewDataSource:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = indexPath.item
        let section = indexPath.section
        let sectionItem = self.sections[section].data?[item]
        let autoModelHeight = self.sections[section].autoModelHeight
        let identifier = self.sections[section].identifier ?? ""
        var itemSize = self.sections![indexPath.section].cellItemSize
        let key:UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern:identifier.hashValue)
        let numberHeight = objc_getAssociatedObject(sectionItem as Any, key) as? NSNumber
        if autoModelHeight {  // 根据模型高度计算
            if itemSize.equalTo(.zero) {
                if collectionViewLayout is UICollectionViewFlowLayout {
                    itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
                }
            }
            else {
                // TODO: 注意 itemSize width 为空,引起错误；需指定itemSize
                itemSize = CGSize(width: collectionView.bounds.size.width, height: 0)
            }
           if numberHeight == nil && sectionItem != nil{ // 获取模型高度 && 模型数据不为空
              let selector = NSSelectorFromString("modelHeight")
                  if sectionItem is NSObjectProtocol {
                       let sectionItemToObj = sectionItem as! NSObjectProtocol
                      if sectionItemToObj.responds(to: selector) {
                          let height = (sectionItemToObj.perform(selector)?.takeUnretainedValue()) as! NSNumber
                          objc_setAssociatedObject(sectionItemToObj as Any, key, height, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                           return CGSize(width: itemSize.width, height: CGFloat(height.floatValue))
                      }
                  }
              }
              else { // 获取模型高度
                  let height = CGFloat(numberHeight?.floatValue ?? 0.0)
                  return CGSize(width: itemSize.width, height: height)
              }
        } else { // 不根据模型高度
              if collectionViewLayout is UICollectionViewFlowLayout { // 如果是瀑布布局
                let layout = collectionViewLayout as! UICollectionViewFlowLayout
                 if itemSize.equalTo(.zero) { // 数据配置分区是否为空,为空取瀑布布局项大小
                     return layout.itemSize
                 }
                 return itemSize
             }
             else { // 非瀑布布局
                 return itemSize
             }
        }
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if collectionViewLayout is UICollectionViewFlowLayout {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            return layout.footerReferenceSize
        }
        let referenceFooterSize = self.sections![section].footerSize
        return referenceFooterSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionViewLayout is UICollectionViewFlowLayout {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            return layout.headerReferenceSize
        }
        let referenceHeaderSize = self.sections![section].headerSize
        return referenceHeaderSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let space = self.sections![section].minimumLineSpacing
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let space = self.sections![section].minimumInteritemSpacing
        return space
    }
}

//extension LPBaseCollectionViewDataSource:UICollectionViewDragDelegate,UICollectionViewDropDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//
//    }
//}
