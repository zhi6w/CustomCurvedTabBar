//
//  CurvedTabBarController.swift
//  CustomTabBar
//
//  Created by Zhi Zhou on 2020/7/14.
//  Copyright © 2020 Zhi Zhou. All rights reserved.
//

import UIKit

open class CurvedTabBarController: UITabBarController {

    open var curvedTabBar: CurvedTabBar? {
        return tabBar as? CurvedTabBar
    }
    
    /// 底部偏移量（用来解决 UIScrollView 底部被遮挡问题）
    open var bottomOffset: CGFloat {
        return tabBar.bounds.height / 2 + (curvedTabBar?.centerButtonBottomOffset ?? 0)
    }
    
    /// 是否自动设定底部偏移量
    /// - note: UIScrollView 类型会出现右侧导航条也会向上偏移的问题。
    open var isAutomaticallyAdditionalSafeAreaInsets: Bool = false {
        didSet {
            guard isAutomaticallyAdditionalSafeAreaInsets else { return }
            
            // 设定 viewController 的底部偏移量
            viewControllers?.forEach({ $0.additionalSafeAreaInsets.bottom = tabBar.bounds.height / 2 + (curvedTabBar?.centerButtonBottomOffset ?? 0) })
        }
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setValue(CurvedTabBar(), forKey: "tabBar")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
                
        guard var vcs = viewControllers else { return }
        
        // 中间占位 item
        let spacingVC = UIViewController()
        let spacingItem = UITabBarItem(title: nil, image: nil, tag: -1)
        spacingItem.isEnabled = false
        spacingVC.tabBarItem = spacingItem
                
        guard vcs.count != 1 else {
            // 仅有一个 item
            vcs.append(spacingVC)
            super.setViewControllers(vcs, animated: animated)
            return
        }
        
        // 如果为奇数个 item 个数，则除去多余的 item。
        if !vcs.count.isMultiple(of: 2) {
            // 最大仅可添加 4个 item，多余的去掉。
            let dropNumber = abs(vcs.count - 4)
            vcs = vcs.dropLast(dropNumber)
        }
        
        let insertIndex = vcs.count / 2
        vcs.insert(spacingVC, at: insertIndex)
        
        super.setViewControllers(vcs, animated: animated)
    }

}

extension UIViewController {

    open var curvedTabBarController: CurvedTabBarController? {
        return tabBarController as? CurvedTabBarController
    }

}




































