//
//  NSCollectionLayoutSectionExt.swift
//  Tasks
//
//  Created by Dylan  on 1/3/20.
//  Copyright © 2020 Dylan . All rights reserved.
//

import UIKit

extension NSCollectionLayoutSection {
    
    static func grid(itemHeight: NSCollectionLayoutDimension,
                     itemSpacing: CGFloat,
                     numberOfColumns: Int) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: itemHeight)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfColumns)
        
        group.interItemSpacing = .fixed(itemSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = itemSpacing
        
        return section
    }
    
    
    @discardableResult
    func withSectionHeader(estimatedHeight: CGFloat, kind: String) -> NSCollectionLayoutSection {
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: kind,
            alignment: .top)
        
        self.boundarySupplementaryItems = [sectionHeader]
        return self
    }
    
    @discardableResult
    func withContentInsets(top: CGFloat = 0,
                        leading: CGFloat = 0,
                        bottom: CGFloat = 0,
                        trailing: CGFloat = 0) -> NSCollectionLayoutSection {
        
        self.contentInsets = NSDirectionalEdgeInsets(top: top,
                                                     leading: leading,
                                                     bottom: bottom,
                                                     trailing: trailing)
        return self
    }
}

//CollectionView Extensions
extension UICollectionViewCell {
    static var cellReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    static var viewReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    
    //MARK: - Regestering Cells
    func registerCell<T: UICollectionViewCell>(cellClass: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.cellReuseIdentifier)
    }
    
    func registerSupplemenentaryView<T: UICollectionReusableView>(viewClass: T.Type) {
        register(T.self,
                 forSupplementaryViewOfKind: T.viewReuseIdentifier,
                 withReuseIdentifier: T.viewReuseIdentifier)
    }
    
    //MARK: - Dequeueing Cells
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let reuseIdentifier = T.cellReuseIdentifier
        
        guard
            let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? T
            else {
                assertionFailure("Unable to dequeue cell for \(reuseIdentifier)")
                return T()
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        let reuseIdentifier = T.viewReuseIdentifier
        
        guard let cell = dequeueReusableSupplementaryView(ofKind: reuseIdentifier,
                                                          withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? T
            else {
                assertionFailure("Unable to dequeue supplementary view for \(reuseIdentifier)")
                return T()
        }
        return cell
    }
    
}
