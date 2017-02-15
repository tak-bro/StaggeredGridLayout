//
//  StaggeredGridLayoutAttributes.swift
//  Rise
//
//  Created by 秋本大介 on 2016/06/06.
//  Copyright © 2016年 秋本大介. All rights reserved.
//

import UIKit

open class StaggeredGridLayoutAttributes: UICollectionViewLayoutAttributes {
    open var imageHeight : CGFloat = 0.0

    open override func copy(with zone: NSZone?) -> Any {
        let copy : StaggeredGridLayoutAttributes = super.copy(with: zone) as! StaggeredGridLayoutAttributes
        copy.imageHeight = self.imageHeight;
        
        return copy;
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        if object is StaggeredGridLayoutAttributes {
            let attributtes : StaggeredGridLayoutAttributes = object as! StaggeredGridLayoutAttributes

            if (attributtes.imageHeight == self.imageHeight) {
                return super.isEqual(attributtes)
            }
        }
        return false;
    }
}
