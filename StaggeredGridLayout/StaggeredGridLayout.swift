//
//  StaggeredGridLayout.swift
//  Rise
//
//  Created by 秋本大介 on 2016/06/06.
//  Copyright © 2016年 秋本大介. All rights reserved.
//

import UIKit

protocol StaggeredGridLayoutDelegate {
    func heightForImageAtIndexPath(_ collectionView : UICollectionView,
        indexPath : IndexPath,
        width : CGFloat
    ) -> CGFloat
    func heightForBodyAtIndexPath(_ collectionView : UICollectionView,
        indexPath : IndexPath,
        width : CGFloat
    ) -> CGFloat
}

class StaggeredGridLayout: UICollectionViewLayout {

    var delegate: StaggeredGridLayoutDelegate! = nil
    
    var cachedAttributes : Array<UICollectionViewLayoutAttributes> = [];

    var contentHeight : CGFloat = 0.0

    let kNumberOfColumns : Int = 2
    let kCellMargin : CGFloat = 10.0

    // MARK: - Accessor
    func contentWidth() -> CGFloat {
        return self.collectionView!.bounds.width - (self.collectionView!.contentInset.left + self.collectionView!.contentInset.right)
    }

    // MARK: - UICollectionViewLayout

    override var collectionViewContentSize : CGSize {
        return CGSize(width: self.contentWidth(), height: self.contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes : Array<UICollectionViewLayoutAttributes> = []
        
        for attribute in self.cachedAttributes {
            if (attribute.frame.intersects(rect)) {
                layoutAttributes.append(attribute)
            }
        }

        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cachedAttributes[indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

    override func prepare() {
        // [1] レイアウト情報をキャッシュ済みの場合は処理を終了する
        if self.cachedAttributes.count > 0 {
            return;
        }
        
        var column : Int = 0

        // [2] セルの幅を計算する
        let totalHorizontalMargin : CGFloat = (kCellMargin * (CGFloat(kNumberOfColumns - 1)))
        let cellWidth : CGFloat = (self.contentWidth() - totalHorizontalMargin) / CGFloat(kNumberOfColumns)
        
        // [3] 「セルの原点 x」の配列を計算する
        var cellOriginXList : Array<CGFloat> = Array<CGFloat>()
        for i in 0..<kNumberOfColumns {
            let originX : CGFloat  = CGFloat(i) * (cellWidth + kCellMargin)
            cellOriginXList.append(originX)
        }

        // [4] カラムごとの「現在計算対象にしているセルの原点 y」を格納した配列を計算する
        var currentCellOriginYList : Array<CGFloat> = Array<CGFloat>()
        for _ in 0..<kNumberOfColumns {
            currentCellOriginYList.append(0.0)
        }

        // [5] 各セルのサイズ・原点座標を計算する
        for item in 0..<self.collectionView!.numberOfItems(inSection: 0) {
            let indexPath : IndexPath = IndexPath(row: item, section: 0)

            // [6] セルの写真部分・ボディ部分のそれぞれの高さを取得する
            let imageHeight : CGFloat  = self.delegate.heightForImageAtIndexPath(
                self.collectionView!, indexPath: indexPath, width: cellWidth)
            
            let bodyHeight : CGFloat  = self.delegate.heightForBodyAtIndexPath(
                self.collectionView!, indexPath: indexPath, width: cellWidth)
            let cellHeight : CGFloat  = imageHeight + bodyHeight;

            // [7] セルの frame を作成する
            let cellFrame : CGRect = CGRect(x: cellOriginXList[column],
                y: currentCellOriginYList[column],
                width: cellWidth,
                height: cellHeight);

            // [8] StaggeredGridLayoutAttributes オブジェクトを作成して、cachedAttributes プロパティに格納する
            let attributes : StaggeredGridLayoutAttributes = StaggeredGridLayoutAttributes(forCellWith: indexPath)
            attributes.imageHeight = imageHeight;
            attributes.frame = cellFrame;
            self.cachedAttributes.append(attributes)

            // [9] UICollectionView のコンテンツの高さを計算して contentHeight プロパティに格納する
            self.contentHeight = max(self.contentHeight, cellFrame.maxY);

            // [10] 次のセルの原点 y を計算する
            currentCellOriginYList[column] = currentCellOriginYList[column] + cellHeight + kCellMargin

            // [11] 次のカラムを決める
            var nextColumn : Int = 0
            var minOriginY : CGFloat = CGFloat.greatestFiniteMagnitude
            let nsCurrentCellOriginYList : NSArray = NSArray(array: currentCellOriginYList)
            nsCurrentCellOriginYList.enumerateObjects({ originY, index, stop in
                if ((originY as! NSNumber).compare(minOriginY as NSNumber) == .orderedAscending) {
                //if ((originY as AnyObject).compare(minOriginY) == .orderedAscending) {
                    minOriginY = CGFloat(originY as! NSNumber);
                    nextColumn = index;
                }
            })
            
            column = nextColumn;
        }
    }
}
