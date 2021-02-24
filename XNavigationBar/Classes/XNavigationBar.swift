//
//  XNavigationBar.swift
//  XNavigationBar
//
//  Created by Xwg on 2019/11/7.
//  Copyright © 2019 Xwg. All rights reserved.
//

import Foundation
import UIKit

let myline = XNavigationBar.makeImage(color: .red, size: CGSize(width: UIScreen.main.bounds.width, height: 0.5))

public let kNavBar = XNavigationBar.shared

// MARK: - XNavigationBar
public class XNavigationBar: NSObject {
    
    @objc public static let shared = XNavigationBar()
    
    private override init() {
        UINavigationBar.swizzleMethods()
        UIViewController.swizzleMethods()
        UINavigationController.swizzleMethods()
    }
    
    /// 标题颜色
    @objc public var navTitleColor: UIColor {
        get { navTitleAttributes[.foregroundColor] as? UIColor ?? .black }
        set { navTitleAttributes[.foregroundColor] = newValue }
    }
    /// 标题属性
    @objc public var navTitleAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black
    ]
    /// item 的文字颜色
    @objc public var navTintColor: UIColor = .black
    /// 背景色
    @objc public var navBackgroundColor: UIColor = .white
    /// 背景图, 为 nil 时显示 navBackgroundColor
    @objc public var navBackgroundImage: UIImage?
    /// 背景透明度
    @objc public var navBackgroundAlpha: CGFloat = 1.0
    
    /// nav - 分隔线颜色
    @objc public var navShadowColor: UIColor = XNavigationBar.rgba(r: 228, g: 228, b: 228, a: 1.0)
    
    @objc public var statusBarStyle = UIStatusBarStyle.default
    
    /// rgb 颜色
    /// - Parameters:
    ///   - r: red
    ///   - g: green
    ///   - b: blue
    ///   - a: alpha
    @objc public static func rgba(r: Int, g: Int, b: Int, a: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    /// 生成纯色图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 大小
    @objc public static func makeImage(color: UIColor, size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - XNavigationBarSwizzle 协议
protocol XNavigationBarSwizzle: NSObjectProtocol {
    static func swizzleMethods()
}

extension XNavigationBarSwizzle {
    /// 交换属性方法
    /// - Parameters:
    ///   - originalSelector: 原始方法
    ///   - swizzledSelector: 交换后方法
    static func  x_swizzleInstanceMethod(originalSelector: Selector, swizzledSelector: Selector) {
        
        let cls = Self.self
        
        // the method might not exist in the class, but in its superclass
        guard let originalMethod = class_getInstanceMethod(cls, originalSelector) else {
            fatalError("\(originalSelector) not exists")
        }
        guard let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector) else {
            fatalError("\(swizzledSelector) not exists")
        }
        
        // class_addMethod will fail if original method already exists
        guard class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
            return
        }
        
        // the method doesn’t exist and we just added one
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    }
    
    /// 交换类方法
    /// - Parameters:
    ///   - originalSelector: 原始方法
    ///   - swizzledSelector: 交换后方法
    static func  x_swizzleClassMethod(originalSelector: Selector, swizzledSelector: Selector) {
        
        let cls = Self.self
        
        // the method might not exist in the class, but in its superclass
        guard let originalMethod = class_getClassMethod(cls, originalSelector) else {
            fatalError("\(originalSelector) not exists")
        }
        guard let swizzledMethod = class_getClassMethod(cls, swizzledSelector) else {
            fatalError("\(swizzledSelector) not exists")
        }
        
        // class_addMethod will fail if original method already exists
        guard class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) else { return }
        
        // the method doesn’t exist and we just added one
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    }
}

extension XNavigationBarSwizzle where Self: UINavigationBar {
    static func swizzleMethods() {
        x_swizzleInstanceMethod(originalSelector: #selector(layoutSubviews),
                                swizzledSelector: #selector(x_nav_bar_layoutSubviews))
        x_swizzleInstanceMethod(originalSelector: #selector(didAddSubview(_:)),
                                swizzledSelector: #selector(x_nav_bar_didAddSubview(_:)))
    }
}

extension XNavigationBarSwizzle where Self: UINavigationController {
    static func swizzleMethods() {
        x_swizzleInstanceMethod(originalSelector: NSSelectorFromString("_updateInteractiveTransition:"),
                                swizzledSelector: #selector(x_nav_updateInteractiveTransition(_:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(getter: preferredStatusBarStyle),
                                swizzledSelector: #selector(getter: x_nav_preferredStatusBarStyle))
        
        x_swizzleInstanceMethod(originalSelector: #selector(pushViewController(_:animated:)),
                                swizzledSelector: #selector(x_nav_pushViewController(_:animated:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(popViewController(animated:)),
                                swizzledSelector: #selector(x_nav_popViewController(animated:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(popToViewController(_:animated:)),
                                swizzledSelector: #selector(x_nav_popToViewController(_:animated:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(popToRootViewController(animated:)),
                                swizzledSelector: #selector(x_nav_popToRootViewController(animated:)))
    }
}

extension XNavigationBarSwizzle where Self: UIViewController {
    static func swizzleMethods() {
        x_swizzleInstanceMethod(originalSelector: #selector(getter: preferredStatusBarStyle),
                                swizzledSelector: #selector(getter: x_preferredStatusBarStyle))
        
        x_swizzleInstanceMethod(originalSelector: #selector(present(_:animated:completion:)),
                                swizzledSelector: #selector(x_present(_:animated:completion:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(viewWillAppear(_:)),
                                swizzledSelector: #selector(x_viewWillAppear(_:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(viewDidAppear(_:)),
                                swizzledSelector: #selector(x_viewDidAppear(_:)))
        
        x_swizzleInstanceMethod(originalSelector: #selector(viewWillDisappear(_:)),
                                swizzledSelector: #selector(x_viewWillDisappear(_:)))
    }
}

extension UINavigationBar: XNavigationBarSwizzle {}
extension UIViewController: XNavigationBarSwizzle {}

// MARK: - UINavigationBar 扩展
extension UINavigationBar {
    // MARK: 添加自定义属性
    
    struct X_AssociatedKeys {
        static var sysBackgroundView: Void?
        
        static var backgroundView: Void?
        
        static var navBgView: Void?
        static var navBgColorView: Void?
        static var navBgImageView: Void?
        static var navShadowView: Void?
    }
    
    /// 系统的背景view，在系统添加到  self 之后捕获存储
    private var sysBackgroundView: UIView? {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.sysBackgroundView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.sysBackgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
//    /// 自定义背景 view，放在系统 sysBackgroundView 的最下层
//    var backgroundView: UIImageView {
//        get {
//            guard let imageView = objc_getAssociatedObject(self, &X_AssociatedKeys.backgroundView) as? UIImageView else {
//                let imageView = UIImageView()
//                imageView.contentMode = .scaleAspectFill
//                imageView.clipsToBounds = true
//                if let image = kNavBar.navBackgroundImage {
//                    imageView.image = image
//                } else {
//                    imageView.backgroundColor = kNavBar.navBackgroundColor
//                }
//
//                self.backgroundView = imageView
//                return imageView
//            }
//            return imageView
//        }
//        set {
//            objc_setAssociatedObject(self, &X_AssociatedKeys.backgroundView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
    
    /// 背景图层
    var navBgView: UIView? {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navBgView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navBgView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// nav 背景颜色
    var navBgColorView: UIView? {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navBgColorView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navBgColorView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// nav 背景图片
    var navBgImageView: UIImageView? {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navBgImageView) as? UIImageView
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navBgImageView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// nav 分隔线
    var navShadowView:  UIView? {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navShadowView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navShadowView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 设置导航栏垂直方向偏移
    var translationY: CGFloat {
        get {
            return transform.ty
        }
        set {
            transform = CGAffineTransform(translationX: 0, y: newValue)
        }
    }
    
    /// 更新背景图
    /// - Parameter color: UIColor
    func setNeedsUpdate(backgroundImage image: UIImage?) {
        navBgImageView?.image = image
    }
    
    /// 更新背景颜色
    /// - Parameter color: UIColor
    func setNeedsUpdate(backgroundColor color: UIColor) {
        navBgColorView?.backgroundColor = color
    }
    
    /// 更新背景透明度
    /// - Parameter alpha: CGFloat
    func setNeedsUpdate(backgroundAlpha alpha: CGFloat) {
        navBgColorView?.alpha = alpha
        navBgImageView?.alpha = alpha
    }
    
    /// 更新背景 图片 -> 颜色
    func setNeedsUpdateBackground(from: UIImage, to: UIColor, progress: CGFloat) {
        guard let colorView = navBgColorView, let imageView = navBgImageView else { return }
        imageView.alpha = 1 - progress
        colorView.alpha = progress
    }
    /// 更新背景 颜色 -> 图片
    func setNeedsUpdateBackground(from: UIColor, to: UIImage, progress: CGFloat) {
        guard let colorView = navBgColorView, let imageView = navBgImageView else { return }
        colorView.alpha = 1 - progress
        imageView.alpha = progress
    }
    
    /// 更新分隔线颜色
    /// - Parameter color: UIColor
    func setNeedsUpdate(shadowColor color: UIColor) {
        navShadowView?.backgroundColor = color
    }
    
    /// 设置导航栏 BarButtonItem 透明度
    /// - Parameters:
    ///   - alpha: 透明度
    ///   - hasSystemBackIndicator: Bool
    func setNeedsUpdateBarButtonItems(alpha: CGFloat, hasSystemBackIndicator: Bool) {
        for view in subviews {
            
            let needUpdate: Bool
            
            if hasSystemBackIndicator {
                needUpdate = true
            } else {
                if let cls = NSClassFromString("_UINavigationBarBackIndicatorView"), !view.isKind(of: cls) {
                    needUpdate = true
                } else {
                    needUpdate = false
                }
            }
            
            if needUpdate {
                // _UIBarBackground/_UINavigationBarBackground 对应的view是系统导航栏，不需要改变其透明度
                if let cls = NSClassFromString("_UIBarBackground"), !view.isKind(of: cls) {
                    view.alpha = alpha
                    continue
                }
                if let cls = NSClassFromString("_UINavigationBarBackground"), !view.isKind(of: cls) {
                    view.alpha = alpha
                    continue
                }
            }
        }
    }
    
    @objc func x_nav_bar_layoutSubviews() {
        x_nav_bar_layoutSubviews()
        
    }
    
    /// 重写系统方法，获取 sysBackgroundView ，并添加自定义view
    @objc func x_nav_bar_didAddSubview(_ subview: UIView) {
        x_nav_bar_didAddSubview(subview)
        
        /*
         默认系统 nav 结构图
         UINavigationBar:
             _UIBarBackground:
                sysVisualEffectViewLink(UIVisualEffectView): 背景
                _UIBarBackgroundShadowView: 分隔线
                    sysBarBackgroundShadowContentImageViewLink(_UIBarBackgroundShadowContentImageView):
            _UINavigationBarContentView: nav 实际内容
            UIView: 未知
         */
        
        // 系统导航背景
        if subview.isMember(of: "_UIBarBackground") {
                        
            navBgView = subview
            
            assert(subview.subviews.count == 2, "系统 _UIBarBackground 子 view 数量异常，请检查")
            
            // 背景
            if let ele = subview.subviews.first, ele.isMember(of: "UIVisualEffectView") {
                
                // 隐藏系统模糊效果
                ele.subviews.forEach { $0.isHidden = $0.isMember(of: "_UIVisualEffectBackdropView") }
                
                
                let contentView = (ele as! UIVisualEffectView).contentView
                ele.sendSubviewToBack(contentView) // 将 contentView 移到最底层
                
                // 添加自定义views
                do {
                    let bgColorView = UIView()
                    bgColorView.backgroundColor = .cyan
                    navBgColorView = bgColorView
                    
                    let bgImageView = UIImageView()
                    bgImageView.image = UIImage(named: "nav01")
                    navBgImageView = bgImageView

                    contentView.addSubview(bgColorView)
                    contentView.addSubview(bgImageView)
                    
                    if #available(iOS 9.0, *) {
                        bgColorView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            bgColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                            bgColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                            bgColorView.topAnchor.constraint(equalTo: contentView.topAnchor),
                            bgColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                        ])
                        
                        bgImageView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            bgImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                            bgImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                            bgImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                            bgImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                        ])
                    } else {
                        fatalError("暂不适配 9.0 以下")
                    }
                }
                
            }
            
            // 分隔线
            if let ele = subview.subviews.last, ele.isMember(of: "_UIBarBackgroundShadowView") {
                ele.isHidden = true
                
                let shadowView = UIView()
                shadowView.backgroundColor = UIColor(white: 0, alpha: 0.3)
                navShadowView = shadowView
                
                subview.addSubview(shadowView)
                
                if #available(iOS 9.0, *) {
                    shadowView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        shadowView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
                        shadowView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
                        shadowView.topAnchor.constraint(equalTo: subview.bottomAnchor),
                        shadowView.heightAnchor.constraint(equalToConstant: 1/3.0),
                    ])
                } else {
                    fatalError("暂不适配 9.0 以下")
                }
            }
        }
    }
}

extension NSObject {
    /// 对象是否是某个类型的对象
    func isMember(of aClassName: String) -> Bool {
        guard let cls = NSClassFromString(aClassName) else { return false }
        return isMember(of: cls)
    }
    
    /// 对象是否是某个类型或类型的子类的对象
    func isKind(of aClassName: String) -> Bool {
        guard let cls = NSClassFromString(aClassName) else { return false }
        return isKind(of: cls)
    }
    
    /// 某个类对象是不是另一个类型的子类
    func isSubclass(of aClassName: String) -> Bool {
        guard let cls = NSClassFromString(aClassName) else { return false }
        return Self.classForCoder().isSubclass(of: cls)
    }
}

// MARK: - UIViewController 扩展
extension UIViewController {
    
    private struct X_AssociatedKeys {
        static var statusBarStyle: Void?
        
        static var navTitleAttributes: Void?
        static var navTitleColor: Void?
        static var navTintColor: Void?
        static var navBackgroundImage: Void?
        static var navBackgroundColor: Void?
        static var navBackgroundAlpha: Void?
        static var navShadowImageHidden: Void?
        static var navShadowColor: Void?
        static var navShadowAlpha: Void?
        
        static var isPushToCurrentFinished: Void?
        static var isPushToNextFinished: Void?
    }
    
    /// 状态栏颜色
    @objc public var statusBarStyle: UIStatusBarStyle {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.statusBarStyle) as? UIStatusBarStyle ?? kNavBar.statusBarStyle
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// 标题颜色
    @objc public var navTitleColor: UIColor {
        get {
            return navTitleAttributes[.foregroundColor] as? UIColor ?? kNavBar.navTitleColor
        }
        set {
            navTitleAttributes[.foregroundColor] = newValue
            navigationController?.setNeedsNavigationBarUpdate(titleAttributes: navTitleAttributes)
        }
    }
    
    var navTitleAttributes: [NSAttributedString.Key: Any] {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navTitleAttributes) as? [NSAttributedString.Key: Any] ?? kNavBar.navTitleAttributes
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navTitleAttributes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc public var navTintColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navTintColor) as? UIColor ?? kNavBar.navTintColor
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard canUpdateNavColorOrAlpha else { return }
            navigationController?.setNeedsNavigationBarUpdate(tintColor: newValue)
        }
    }
    
    @objc public var navBackgroundImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navBackgroundImage) as? UIImage ?? kNavBar.navBackgroundImage
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navBackgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            navigationController?.setNeedsNavigationBarUpdate(backgroundImage: newValue)
        }
    }
    
    @objc public var navBackgroundColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navBackgroundColor) as? UIColor ?? kNavBar.navBackgroundColor
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navBackgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard canUpdateNavColorOrAlpha else { return }
            navigationController?.setNeedsNavigationBarUpdate(backgroundColor: newValue)
        }
    }
    
    @objc public var navBackgroundAlpha: CGFloat {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navBackgroundAlpha) as? CGFloat ?? kNavBar.navBackgroundAlpha
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navBackgroundAlpha, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard canUpdateNavColorOrAlpha else { return }
            navigationController?.setNeedsNavigationBarUpdate(backgroundAlpha: newValue)
        }
    }
    
    /// 分隔线颜色
    @objc public var navShadowColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.navShadowColor) as? UIColor ?? kNavBar.navShadowColor
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.navShadowColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard canUpdateNavColorOrAlpha else { return }
            navigationController?.setNeedsNavigationBarUpdate(shadowColor: newValue)
        }
    }
    
    /// navigationBar barTintColor can not change by currentVC before fromVC push to currentVC finished
    fileprivate var isPushToCurrentFinished: Bool {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.isPushToCurrentFinished) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.isPushToCurrentFinished, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// navigationBar barTintColor can not change by currentVC when currentVC push to nextVC finished
    fileprivate var isPushToNextFinished: Bool {
        get {
            return objc_getAssociatedObject(self, &X_AssociatedKeys.isPushToNextFinished) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &X_AssociatedKeys.isPushToNextFinished, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否可以更新 nav 的颜色/透明度
    fileprivate var canUpdateNavColorOrAlpha: Bool {
        let isRootVC = navigationController?.viewControllers.first == self
        return (isPushToCurrentFinished || isRootVC) && !isPushToNextFinished
    }
}

extension UIViewController {
    
    /// 交换后的方法
    @objc fileprivate var x_preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    
    /// 替换系统方法: viewWillAppear(_:)
    @objc fileprivate func x_viewWillAppear(_ animated: Bool) {
        defer { x_viewWillAppear(animated) }
        
        isPushToNextFinished = false
        navigationController?.setNeedsNavigationBarUpdate(tintColor: navTintColor)
        navigationController?.setNeedsNavigationBarUpdate(titleAttributes: navTitleAttributes)
    }
    
    /// 替换系统方法: viewDidAppear(_:)
    @objc fileprivate func x_viewDidAppear(_ animated: Bool) {
        defer { x_viewDidAppear(animated) }
        
        // 如果当前控制器是 nav, 则设置代理为自身，
        if let nav = self as? UINavigationController, nav.delegate == nil { nav.delegate = nav }
        if navigationController?.viewControllers.first != self { isPushToCurrentFinished = true }
    }
    
    /// 替换系统方法: viewWillDisappear(_:)
    @objc fileprivate func x_viewWillDisappear(_ animated: Bool) {
        defer { x_viewWillDisappear(animated) }
        
        isPushToNextFinished = true
    }
    
    @objc fileprivate func x_present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        defer { x_present(viewControllerToPresent, animated: animated, completion: completion) }
        
        print(#function)
    }
    
}

// MARK: - UINavigationController 扩展
extension UINavigationController {
    
    /// 替换系统方法: pushViewController(_:animated:)
    @objc fileprivate func x_nav_pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        configPushTransaction { viewController.isPushToCurrentFinished = true }
        
        CATransaction.begin()
        x_nav_pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    @objc fileprivate func x_nav_popViewController(animated: Bool) -> UIViewController? {
        
        configPopTransaction()
        
        CATransaction.begin()
        let vc = x_nav_popViewController(animated: animated)
        CATransaction.commit()
        return vc
    }
    
    /// 替换系统方法: popToViewController(_:animated:)
    @objc fileprivate func x_nav_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        configPopTransaction()
        
        CATransaction.begin()
        let vcs = x_nav_popToViewController(viewController, animated: animated)
        CATransaction.commit()
        
        return vcs
    }
    
    /// 替换系统方法: popToRootViewController(animated:)
    @objc fileprivate func x_nav_popToRootViewController(animated: Bool) -> [UIViewController]? {
        
        configPopTransaction()
        
        CATransaction.begin()
        let vcs = x_nav_popToRootViewController(animated: animated)
        CATransaction.commit()
        return vcs
    }
    
    // MARK: push 配置
    /// push 配置
    private struct pushConfig {
        fileprivate static let duration = 0.13
        fileprivate static var displayTimes = 0 {
            didSet {
                let total = 60.0 * duration
                isNeedUpdate = progress < 1.0 || Double(displayTimes) <= total
                progress = CGFloat(min(total, Double(displayTimes)) / total)
            }
        }
        fileprivate(set) static var isNeedUpdate = true
        fileprivate(set) static var progress: CGFloat = 0
    }
    
    /// push CATransaction  配置
    /// - Parameter completion: 完成时回调
    private func configPushTransaction(completion: @escaping () -> Void) {
        
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(pushNeedDisplay))
        displayLink?.add(to: .main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            pushConfig.displayTimes = 0
            completion()
        }
        CATransaction.setAnimationDuration(pushConfig.duration)
    }
    
    @objc private func pushNeedDisplay() {
        
        guard let coordinator = topViewController?.transitionCoordinator else { return }
        
        pushConfig.displayTimes += 1
        
        guard pushConfig.isNeedUpdate else { return }
        
        let progress = pushConfig.progress
        if let fromVC = coordinator.viewController(forKey: .from),
            let toVC = coordinator.viewController(forKey: .to) {
            navigationBarUpdate(from: fromVC, to: toVC, progress: progress)
        }
    }
    
    // MARK: pop 配置
    
    /// pop 配置
    private struct popConfig {
        fileprivate static let duration = 0.13
        fileprivate static var displayTimes = 0 {
            didSet {
                let total = 60.0 * duration
                isNeedUpdate = progress < 1.0 || Double(displayTimes) <= total
                progress = CGFloat(min(total, Double(displayTimes)) / total)
            }
        }
        fileprivate(set) static var isNeedUpdate = true
        fileprivate(set) static var progress: CGFloat = 0
    }
    
    
    ///  pop CATransaction 配置
    private func configPopTransaction() {
        
        var displayLink: CADisplayLink? = CADisplayLink(target: self, selector: #selector(popNeedDisplay))
        displayLink?.add(to: .main, forMode: .common)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            displayLink = nil
            popConfig.displayTimes = 0
        }
        CATransaction.setAnimationDuration(popConfig.duration)
    }
    
    @objc private func popNeedDisplay() {
        
        guard let coordinator = transitionCoordinator else { return }
        
        popConfig.displayTimes += 1
        
        guard popConfig.isNeedUpdate else { return }
        
        let progress = popConfig.progress
        if let fromVC = coordinator.viewController(forKey: .from),
            let toVC = coordinator.viewController(forKey: .to) {
            navigationBarUpdate(from: fromVC, to: toVC, progress: progress)
        }
    }
    
}

// MARK: 状态栏设置
extension UINavigationController {
    /// 设置状态栏颜色
    @objc fileprivate var x_nav_preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? kNavBar.statusBarStyle
    }
}

struct XNavigationConfig {
    
    enum UpdateType {

        enum TitleAttribute {
            case color(UIColor)
            case font(UIFont)
            case attributes([NSAttributedString.Key: Any])
        }
        
        enum BgAttribute {
            case color(UIColor)
            case image(UIImage?)
            case alpha(CGFloat)
        }
        
        enum ShadowAttribute {
            case color(UIColor)
            case image(UIImage)
            case alpha(CGFloat)
        }
        
        case title(TitleAttribute)
        
        case tintColor(UIColor)
        
        case bg(BgAttribute)
        
        case shadow(ShadowAttribute)
    }
    
    var `default`: [UpdateType] = [
        .title(.color(.blue)),
        .tintColor(.orange),
        .bg(.color(.cyan))
    ]
}

// MARK: 控制器 push、pop 更新
private extension UINavigationController {
    
    enum UpdateType {

        enum TitleAttribute {
            case color(UIColor)
            case font(UIFont)
            case attributes([NSAttributedString.Key: Any])
        }
        
        enum BgAttribute {
            case color(UIColor)
            case image(UIImage?)
            case alpha(CGFloat)
        }
        
        enum ShadowAttribute {
            case color(UIColor)
            case image(UIImage)
            case alpha(CGFloat)
        }
        
        case title(TitleAttribute)
        
        case tintColor(UIColor)
        
        case bg(BgAttribute)
        
        case shadow(ShadowAttribute)
    }
    
    func setNeedsNavigationBarUpdate(types: [UpdateType]) {
        
        #warning("添加过虑")
        if self.isKind(of: "TZImagePickerController") {
            return
        }
        
        for type in types {
            switch type {
            case .title(let attr):
                var attributes = navigationBar.titleTextAttributes ?? kNavBar.navTitleAttributes
                
                switch attr {
                case .color(let val):
                    attributes[.foregroundColor] = val
                case .font(let val):
                    attributes[.font] = val
                case .attributes(let val):
                    val.forEach { attributes[$0.key] = $0.value }
                }
                
                navigationBar.titleTextAttributes = attributes
                
            case .tintColor(let val):
                navigationBar.tintColor = val
                
            case .bg(let attr):
                
                switch attr {
                case .color(let val):
                    navigationBar.setNeedsUpdate(backgroundColor: val)
                case .image(let val):
                    navigationBar.setNeedsUpdate(backgroundImage: val)
                case .alpha(let val):
                    navigationBar.setNeedsUpdate(backgroundAlpha: val)
                }
                
            case .shadow(let attr):
                switch attr {
                case .color(let val):
                    navigationBar.setNeedsUpdate(shadowColor: val)
                case .image(let val):
                    fatalError("暂未实现")
                case .alpha(let val):
                    fatalError("暂未实现")
                }
            }
        }
    }
    
    /// navigationBar 更新
    /// - Parameter color: 标题-颜色
    func setNeedsNavigationBarUpdate(titleColor color: UIColor) {
        setNeedsNavigationBarUpdate(types: [.title(.color(color))])
    }
    
    func setNeedsNavigationBarUpdate(titleAttributes attributes: [NSAttributedString.Key: Any]) {
        setNeedsNavigationBarUpdate(types: [.title(.attributes(attributes))])
    }
    
    /// navigationBar 更新
    /// - Parameter color: tint-颜色
    func setNeedsNavigationBarUpdate(tintColor color: UIColor) {
        setNeedsNavigationBarUpdate(types: [.tintColor(color)])
    }
    
    /// navigationBar 更新
    /// - Parameter alpha: 分隔线-颜色
    func setNeedsNavigationBarUpdate(shadowColor color: UIColor) {
        setNeedsNavigationBarUpdate(types: [.shadow(.color(color))])
    }
    
    /// navigationBar 更新
    /// - Parameter color: 背景-图片
    func setNeedsNavigationBarUpdate(backgroundImage image: UIImage?) {
        setNeedsNavigationBarUpdate(types: [.bg(.image(image))])
        
    }
    
    /// navigationBar 更新
    /// - Parameter alpha: 背景-透明度
    func setNeedsNavigationBarUpdate(backgroundAlpha alpha: CGFloat) {
        setNeedsNavigationBarUpdate(types: [.bg(.alpha(alpha))])
    }
    
    /// navigationBar 更新
    /// - Parameter color: 背景-颜色
    func setNeedsNavigationBarUpdate(backgroundColor color: UIColor) {
        setNeedsNavigationBarUpdate(types: [.bg(.color(color))])
    }
    
    /// navigationBar 更新
    /// - Parameter vc: UIViewController
    func setNeedsNavigationBarUpdate(toViewController vc: UIViewController) {
        
        if let backgroundImage = vc.navBackgroundImage {
            setNeedsNavigationBarUpdate(backgroundImage: backgroundImage)
        } else {
            setNeedsNavigationBarUpdate(backgroundColor: vc.navBackgroundColor)
        }
        setNeedsNavigationBarUpdate(tintColor: vc.navTintColor)
        setNeedsNavigationBarUpdate(titleAttributes: vc.navTitleAttributes)
        setNeedsNavigationBarUpdate(backgroundAlpha: vc.navBackgroundAlpha)
        setNeedsNavigationBarUpdate(shadowColor: vc.navShadowColor)
    }
    
    func navigationBarUpdate(from: UIViewController, to: UIViewController, progress: CGFloat) {
        // 更新标题颜色
        setNeedsNavigationBarUpdate(titleAttributes: to.navTitleAttributes)
    
        // tint
        var to_tintColor = to.navTintColor
        if from.navTintColor != to_tintColor {
            to_tintColor = transitionColor(from: from.navTintColor, to: to_tintColor, percent: progress)
        }
        setNeedsNavigationBarUpdate(tintColor: to_tintColor)
        
        // 分隔线
        var to_shadowColor = to.navShadowColor
        if from.navShadowColor != to_shadowColor {
            to_shadowColor = transitionColor(from: from.navShadowColor, to: to_shadowColor, percent: progress)
        }
        setNeedsNavigationBarUpdate(shadowColor: to_shadowColor)
        
        // 背景透明度
        var to_alpha = to.navBackgroundAlpha
        if from.navBackgroundAlpha != to_alpha {
            to_alpha = transitionAlpha(from: from.navBackgroundAlpha, to: to_alpha, percent: progress)
        }
        setNeedsNavigationBarUpdate(backgroundAlpha: to_alpha)
        
        // 更改背景色
        var to_backgroundColor = to.navBackgroundColor
        if from.navBackgroundColor != to_backgroundColor {
            to_backgroundColor = transitionColor(from: from.navBackgroundColor, to: to_backgroundColor, percent: progress)
        }
//        setNeedsNavigationBarUpdate(backgroundColor: to_backgroundColor)
        if let img = from.navBackgroundImage, to.navBackgroundImage == nil {
            navigationBar.setNeedsUpdateBackground(from: img, to: to_backgroundColor, progress: progress)
        } else if let img = to.navBackgroundImage, from.navBackgroundImage == nil {
            navigationBar.setNeedsUpdateBackground(from: from.navBackgroundColor, to: img, progress: progress)
        } else {
            setNeedsNavigationBarUpdate(types: [.bg(.color(to_backgroundColor))])
        }
    }
    
    /// 过渡色
    /// - Parameters:
    ///   - fromColor: 开始 颜色
    ///   - toColor: 结束 颜色
    ///   - percent: 过度百分比
    func transitionColor(from fromColor: UIColor, to toColor: UIColor, percent: CGFloat) -> UIColor {
        
        var from_r: CGFloat = 0
        var from_g: CGFloat = 0
        var from_b: CGFloat = 0
        var from_a: CGFloat = 0
        fromColor.getRed(&from_r, green: &from_g, blue: &from_b, alpha: &from_a)
        
        var to_r: CGFloat = 0
        var to_g: CGFloat = 0
        var to_b: CGFloat = 0
        var to_a: CGFloat = 0
        toColor.getRed(&to_r, green: &to_g, blue: &to_b, alpha: &to_a)
        
        let r = from_r + (to_r - from_r) * percent
        let g = from_g + (to_g - from_g) * percent
        let b = from_b + (to_b - from_b) * percent
        let a = from_a + (to_a - from_a) * percent
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 过渡 透明度 值
    /// - Parameters:
    ///   - fromAlpha: 开始 透明度
    ///   - toAlpha: 结束 透明度
    ///   - percent: 过度百分比
    func transitionAlpha(from fromAlpha: CGFloat, to toAlpha: CGFloat, percent: CGFloat) -> CGFloat {
        
        return fromAlpha + (toAlpha - fromAlpha) * percent
    }
}

// MARK: - 过度处理
// MARK: UINavigationBarDelegate
extension UINavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        
        // 点击返回按钮
        let itemCount = navigationBar.items?.count ?? 0
        let n = viewControllers.count >= itemCount ? 2 : 1
        let popToVC = viewControllers[viewControllers.count - n]
        DispatchQueue.main.async { self.popToViewController(popToVC, animated: true) }
        
        return true
    }
    // pop结束
    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {
        // 点击返回按钮
        guard viewControllers.count >= navigationBar.items?.count ?? 1 else { return }
        let toVC = viewControllers[viewControllers.count - 1]
        
        setNeedsNavigationBarUpdate(toViewController: toVC)
    }
    // push结束
    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
        // push 到新的界面
        guard let topViewController = topViewController else { return }
        setNeedsNavigationBarUpdate(toViewController: topViewController)
    }
    
    /// 替换系统方法: _updateInteractiveTransition:
    @objc func x_nav_updateInteractiveTransition(_ percentComplete: CGFloat) {
        
        guard let coordinator = transitionCoordinator else {
            x_nav_updateInteractiveTransition(percentComplete)
            return
        }
        
        if let fromVC = coordinator.viewController(forKey: .from),
            let toVC = coordinator.viewController(forKey: .to) {
            navigationBarUpdate(from: fromVC, to: toVC, progress: percentComplete)
        }
        
        x_nav_updateInteractiveTransition(percentComplete)
    }
}

// MARK: UINavigationControllerDelegate
extension UINavigationController: UINavigationControllerDelegate {
    /// https://www.jianshu.com/p/94910b42396c
    /// 处理滑动返回手指松开后， 系统自动处理过程中 自动操作的那个时间内将透明度变为对应界面的导航栏透明度，让其变化的不那么跳跃
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        guard let coordinator = transitionCoordinator else { return }
        
        if #available(iOS 10.0, *) {
            coordinator.notifyWhenInteractionChanges { context in
                self.dealInteractionChanges(context)
            }
        } else {
            coordinator.notifyWhenInteractionEnds { context in
                self.dealInteractionChanges(context)
            }
        }
    }
    
    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        
        let animations: (UITransitionContextViewControllerKey) -> Void = { key in
            guard let vc = context.viewController(forKey: key) else { return }
            
            let from = context.viewController(forKey: .from)!
            let to = context.viewController(forKey: .to)!
            
            // 更改背景色
            var to_backgroundColor = to.navBackgroundColor
            
            let progress: CGFloat = context.isCancelled ? 0 : 1.0
    
            if let img = from.navBackgroundImage, to.navBackgroundImage == nil {
                self.navigationBar.setNeedsUpdateBackground(from: img, to: to_backgroundColor, progress: progress)
            } else if let img = to.navBackgroundImage, from.navBackgroundImage == nil {
                self.navigationBar.setNeedsUpdateBackground(from: from.navBackgroundColor, to: img, progress: progress)
            }
            
            // 需要设置代理为自身，如果设置为 UIViewController 时，vc.navigationController 会出现 nil，造成无法更新成功
//            self.setNeedsNavigationBarUpdate(toViewController: vc)
        }
        
        if context.isCancelled {
            let duration = context.transitionDuration * Double(context.percentComplete)
            UIView.animate(withDuration: duration) { animations(.from) }
        } else {
            let duration = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: duration) { animations(.to) }
        }
    }
}

