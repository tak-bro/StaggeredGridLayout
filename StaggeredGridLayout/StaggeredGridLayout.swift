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
        // [1] When the layout information has already been cached, the processing is terminated
        if self.cachedAttributes.count > 0 {
            return;
        }
        
        var column : Int = 0

        // [2] Calculate Cell width
        let totalHorizontalMargin : CGFloat = (kCellMargin * (CGFloat(kNumberOfColumns - 1)))
        let cellWidth : CGFloat = (self.contentWidth() - totalHorizontalMargin) / CGFloat(kNumberOfColumns)
        
        // [3] Calculate the array of "Cell origin x"
        var cellOriginXList : Array<CGFloat> = Array<CGFloat>()
        for i in 0..<kNumberOfColumns {
            let originX : CGFloat  = CGFloat(i) * (cellWidth + kCellMargin)
            cellOriginXList.append(originX)
        }

        // [4] Calculate an array that stores "the origin y of the cell currently being calculated" for each column
        var currentCellOriginYList : Array<CGFloat> = Array<CGFloat>()
        for _ in 0..<kNumberOfColumns {
            currentCellOriginYList.append(0.0)
        }

        // [5] Calculate size and origin coordinates of each cell
        for item in 0..<self.collectionView!.numberOfItems(inSection: 0) {
            let indexPath : IndexPath = IndexPath(row: item, section: 0)

            // [6] Acquire the height of each part of the image and the body of the cell
            let imageHeight : CGFloat  = self.delegate.heightForImageAtIndexPath(
                self.collectionView!, indexPath: indexPath, width: cellWidth)
            
            let bodyHeight : CGFloat  = self.delegate.heightForBodyAtIndexPath(
                self.collectionView!, indexPath: indexPath, width: cellWidth)
            let cellHeight : CGFloat  = imageHeight + bodyHeight;

            // [7] Create cell frame
            let cellFrame : CGRect = CGRect(x: cellOriginXList[column],
                y: currentCellOriginYList[column],
                width: cellWidth,
                height: cellHeight);

            // [8] StaggeredGridLayoutAttributes
            // Create an object and store it in the cachedAttributes property
            let attributes : StaggeredGridLayoutAttributes = StaggeredGridLayoutAttributes(forCellWith: indexPath)
            attributes.imageHeight = imageHeight;
            attributes.frame = cellFrame;
            self.cachedAttributes.append(attributes)

            // [9] UICollectionView 
            // Calculate the height of the content and store it in the contentHeight property
            self.contentHeight = max(self.contentHeight, cellFrame.maxY);

            // [10] Calculate the origin y of the next cell
            currentCellOriginYList[column] = currentCellOriginYList[column] + cellHeight + kCellMargin

            // [11] Decide the next column
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
