//
//  XNavigationBar.swift
//  XNavigationBar
//
//  Created by Xwg on 2019/11/7.
//  Copyright © 2019 Xwg. All rights reserved.
//

import Foundation
import UIKit


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
    @objc public var navBackgroundColor: UIColor {
        get {
            switch navBackground {
            case .color(let val):   return val
            default:                return .white
            }
        }
        set {
            navBackground = .color(newValue)
        }
    }
    
    /// 背景图, 为 nil 时显示 navBackgroundColor
    @objc public var navBackgroundImage: UIImage? {
        get {
            switch navBackground {
            case .image(let val):   return val
            default:                return nil
            }
        }
        set {
            navBackground = .image(newValue)
        }
    }
    
    var navBackground: BackgroundAttribute = .color(.white)
    
    /// nav - 分隔线颜色
    @objc public var navShadowColor: UIColor = UIColor(white: 0, alpha: 0.3)
    
    /// 状态栏
    @objc public var statusBarStyle = UIStatusBarStyle.default
    
    /// 黑名单
    @objc public static var blacklist: [String] = [
        "TZImagePickerController",
        "_UIActivityContentNavigationBar"
    ]
    
    static func isInBlacklist(of object: NSObject) -> Bool {
        for className in blacklist {
            if object.isMember(of: className) { return true }
        }
        return false
    }
}

extension XNavigationBar {
    public enum TitleAttribute {
        case color(UIColor)
        case font(UIFont)
        case attributes([NSAttributedString.Key: Any])
    }
    
    public enum BackgroundAttribute {
        case color(UIColor)
        case image(UIImage?)
    }
    
    public enum Attribute {
        /// 标题
        case title(TitleAttribute)
        /// 背景
        case background(BackgroundAttribute)
        /// 分隔线
        case shadowColor(UIColor)
        /// items 颜色
        case tintColor(UIColor)
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

extension NSObject {
    func getAssociatedObject<T>(key: UnsafeRawPointer, default objcet: () -> T) -> T {
        if let obj = objc_getAssociatedObject(self, key) as? T {
            return obj
        }
        
        let newValue = objcet()
    
        setAssociatedObject(key: key, newValue: newValue)
        return newValue
    }
    
    func setAssociatedObject<T>(key: UnsafeRawPointer, newValue: T) {
        objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - UINavigationBar 扩展
extension UINavigationBar {
    // MARK: 添加自定义属性
    struct X_AssociatedKeys {
        
        static var navBgView: Void?
        static var navBgTransitionView: Void?
        static var navShadowView: Void?
    }
    
    private class _XwgBgView: UIImageView {}
    private class _XwgShadowView: UIView {}
    
    /// nav 背景过渡 view
    private var navBgTransitionView: _XwgBgView {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navBgTransitionView) { () -> _XwgBgView in
                let obj = _XwgBgView()
                obj.alpha = 0
                return obj
            }
        }
        set { setAssociatedObject(key: &X_AssociatedKeys.navBgTransitionView, newValue: newValue) }
    }
    
    /// nav 背景 view
    private var navBgView: _XwgBgView {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navBgView) { () -> _XwgBgView in
                let obj = _XwgBgView()
                obj.backgroundColor = kNavBar.navBackgroundColor
                return obj
            }
        }
        set { setAssociatedObject(key: &X_AssociatedKeys.navBgView, newValue: newValue) }
    }
    
    /// nav 分隔线
    private var navShadowView: _XwgShadowView {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navShadowView) { () -> _XwgShadowView in
                let obj = _XwgShadowView()
                obj.backgroundColor = kNavBar.navShadowColor
                return obj
            }
        }
        set { setAssociatedObject(key: &X_AssociatedKeys.navShadowView, newValue: newValue) }
    }
    
    /// 设置导航栏垂直方向偏移
    var translationY: CGFloat {
        get { transform.ty }
        set { transform = CGAffineTransform(translationX: 0, y: newValue) }
    }
    
    /// 设置标题
    /// - Parameter title: XNavigationBar.TitleAttribute
    func update(title: XNavigationBar.TitleAttribute) {
        var attributes = titleTextAttributes ?? kNavBar.navTitleAttributes
        
        switch title {
        case .color(let val):
            attributes[.foregroundColor] = val
            update(title: .attributes(attributes))
        case .font(let val):
            attributes[.foregroundColor] = val
            titleTextAttributes = attributes
        case .attributes(let val):
            val.forEach { attributes[$0.key] = $0.value }
        }
        
        titleTextAttributes = attributes
    }
    
    /// 设置背景
    /// - Parameter background: XNavigationBar.BackgroundAttribute
    func setup(background: XNavigationBar.BackgroundAttribute) {
        switch background {
        case .color(let val):
            navBgView.image = nil
            navBgView.backgroundColor = val
        case .image(let val):
            navBgView.image = val
            navBgView.backgroundColor = nil
        }
    }
    
    /// 更新背景 图片 -> 颜色
    func setupBackground(from: UIImage, to: UIColor, progress: CGFloat) {
        navBgTransitionView.image = from
        navBgTransitionView.backgroundColor = nil
        navBgTransitionView.alpha = 1 - progress
        
        navBgView.image = nil
        navBgView.backgroundColor = to
        navBgView.alpha = progress
    }
    /// 更新背景 颜色 -> 图片
    func setupBackground(from: UIColor, to: UIImage, progress: CGFloat) {
        navBgTransitionView.image = nil
        navBgTransitionView.backgroundColor = from
        navBgTransitionView.alpha = 1 - progress
        
        navBgView.image = to
        navBgView.backgroundColor = nil
        navBgView.alpha = progress
    }
    
    func setupBackground(from: UIImage, to: UIImage, progress: CGFloat) {
        guard from != to else { return }
        
        navBgTransitionView.image = from
        navBgTransitionView.backgroundColor = nil
        navBgTransitionView.alpha = 1 - progress
        
        navBgView.image = to
        navBgView.backgroundColor = nil
        navBgView.alpha = progress
    }
    
    /// 分隔线颜色
    /// - Parameter color: UIColor
    func setup(shadowColor color: UIColor) {
        navShadowView.backgroundColor = color
    }
    
    /// 导航栏 BarButtonItem 透明度
    /// - Parameters:
    ///   - alpha: 透明度
    ///   - hasSystemBackIndicator: Bool
    func setupButtonItems(alpha: CGFloat, hasSystemBackIndicator: Bool) {
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
        
        subviews.first?.subviews.forEach({ ele in
            if ![navBgTransitionView, navBgView, navShadowView].contains(ele) {
                ele.isHidden = true
            }
        })
    }

    /// 创建自定义views, 并添加到系统对应层
    @objc func x_nav_bar_didAddSubview(_ subview: UIView) {
        x_nav_bar_didAddSubview(subview)
        
        // 当前 self 在黑名单
        if XNavigationBar.isInBlacklist(of: self) { return }
        // 所在 nav 在黑名单
        if let nav = next?.next as? UINavigationController, XNavigationBar.isInBlacklist(of: nav) { return }
        
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
            print(self)
            // 隐藏系统
            subview.subviews.forEach { $0.isHidden = true }
            
            // 添加背景
            do {
                subview.addSubview(navBgTransitionView)
                subview.addSubview(navBgView)
                
                navBgTransitionView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    navBgTransitionView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
                    navBgTransitionView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
                    navBgTransitionView.topAnchor.constraint(equalTo: subview.topAnchor),
                    navBgTransitionView.bottomAnchor.constraint(equalTo: subview.bottomAnchor),
                ])
                
                navBgView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    navBgView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
                    navBgView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
                    navBgView.topAnchor.constraint(equalTo: subview.topAnchor),
                    navBgView.bottomAnchor.constraint(equalTo: subview.bottomAnchor),
                ])
            }
            
            // 添加阴影
            do {
                subview.addSubview(navShadowView)
                
                navShadowView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    navShadowView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
                    navShadowView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
                    navShadowView.topAnchor.constraint(equalTo: subview.bottomAnchor),
                    navShadowView.heightAnchor.constraint(equalToConstant: 1/3.0),
                ])
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
        static var navBackground: Void?
        static var navShadowImageHidden: Void?
        static var navShadowColor: Void?
        static var navShadowAlpha: Void?
        
        static var isPushToCurrentFinished: Void?
        static var isPushToNextFinished: Void?
    }
    
    /// 状态栏颜色
    @objc public var statusBarStyle: UIStatusBarStyle {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.statusBarStyle) { kNavBar.statusBarStyle }
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.statusBarStyle, newValue: newValue)
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
            navigationController?.setNeedsNavigationBarUpdate(types: [.title(.attributes(navTitleAttributes))])
        }
    }
    
    var navTitleAttributes: [NSAttributedString.Key: Any] {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navTitleAttributes, default: { kNavBar.navTitleAttributes })
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.navTitleAttributes, newValue: newValue)
        }
    }
    
    @objc public var navTintColor: UIColor {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navTintColor, default: { kNavBar.navTintColor })
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.navTintColor, newValue: newValue)
            guard canUpdateNavColorOrAlpha else { return }
            navigationController?.setNeedsNavigationBarUpdate(types: [.tintColor(newValue)])
        }
    }
    
    @objc public var navBackgroundColor: UIColor {
        get {
            switch navBackground {
            case .color(let val):   return val
            default:                return kNavBar.navBackgroundColor
            }
        }
        set {
            navBackground = .color(newValue)
        }
    }
    @objc public var navBackgroundImage: UIImage? {
        get {
            switch navBackground {
            case .image(let val):   return val
            default:                return kNavBar.navBackgroundImage
            }
        }
        set {
            navBackground = .image(newValue)
        }
    }
    public var navBackground: XNavigationBar.BackgroundAttribute {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navBackground, default: { kNavBar.navBackground })
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.navBackground, newValue: newValue)
            navigationController?.setNeedsNavigationBarUpdate(types: [.background(newValue)])
        }
    }
    
    /// 分隔线颜色
    @objc public var navShadowColor: UIColor {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.navShadowColor, default: { kNavBar.navShadowColor })
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.navShadowColor, newValue: newValue)
            guard canUpdateNavColorOrAlpha else { return }
            navigationController?.setNeedsNavigationBarUpdate(types: [.shadowColor(newValue)])
        }
    }
    
    /// navigationBar barTintColor can not change by currentVC before fromVC push to currentVC finished
    fileprivate var isPushToCurrentFinished: Bool {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.isPushToCurrentFinished, default: { false })
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.isPushToCurrentFinished, newValue: newValue)
        }
    }
    
    /// navigationBar barTintColor can not change by currentVC when currentVC push to nextVC finished
    fileprivate var isPushToNextFinished: Bool {
        get {
            getAssociatedObject(key: &X_AssociatedKeys.isPushToNextFinished, default: { false })
        }
        set {
            setAssociatedObject(key: &X_AssociatedKeys.isPushToNextFinished, newValue: newValue)
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
        navigationController?.setNeedsNavigationBarUpdate(types: [
            .title(.attributes(navTitleAttributes)),
            .tintColor(navTintColor)
        ])
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

// MARK: 控制器 push、pop 更新
private extension UINavigationController {
    func setNeedsNavigationBarUpdate(types: [XNavigationBar.Attribute]) {
        
        if XNavigationBar.isInBlacklist(of: self) { return }
        
        for type in types {
            switch type {
            case .title(let val):
                navigationBar.update(title: val)
                
            case .background(let val):
                navigationBar.setup(background: val)
                
            case .shadowColor(let val):
                navigationBar.setup(shadowColor: val)
                
            case .tintColor(let val):
                navigationBar.tintColor = val
            }
        }
    }
    
    /// navigationBar 更新
    /// - Parameter vc: UIViewController
    func setNeedsNavigationBarUpdate(toViewController vc: UIViewController) {
        setNeedsNavigationBarUpdate(types: [
            .background(vc.navBackground),
            .tintColor(vc.navTintColor),
            .title(.attributes(vc.navTitleAttributes)),
            .shadowColor(vc.navShadowColor)
        ])
    }
    
    func navigationBarUpdate(from: UIViewController, to: UIViewController, progress: CGFloat) {

        setNeedsNavigationBarUpdate(types: [
            .tintColor(transitionColor(from: from.navTintColor, to: to.navTintColor, percent: progress)),
            .shadowColor(transitionColor(from: from.navShadowColor, to: to.navShadowColor, percent: progress))
        ])
        
        // 更改背景色
        if let from = from.navBackgroundImage, to.navBackgroundImage == nil {
            navigationBar.setupBackground(from: from, to: to.navBackgroundColor, progress: progress)
        } else if let to = to.navBackgroundImage, from.navBackgroundImage == nil {
            navigationBar.setupBackground(from: from.navBackgroundColor, to: to, progress: progress)
        } else if let from = from.navBackgroundImage, let to = to.navBackgroundImage {
            navigationBar.setupBackground(from: from, to: to, progress: progress)
        } else {
            if from.navBackgroundColor != to.navBackgroundColor {
                setNeedsNavigationBarUpdate(types: [.background(.color(
                    transitionColor(from: from.navBackgroundColor, to: to.navBackgroundColor, percent: progress)
                ))])
            }
        }
    }
    
    /// 过渡色
    /// - Parameters:
    ///   - from: 开始 颜色
    ///   - to: 结束 颜色
    ///   - percent: 过度百分比
    func transitionColor(from: UIColor, to: UIColor, percent: CGFloat) -> UIColor {
        
        guard from != to else { return from }
        
        var from_r: CGFloat = 0
        var from_g: CGFloat = 0
        var from_b: CGFloat = 0
        var from_a: CGFloat = 0
        from.getRed(&from_r, green: &from_g, blue: &from_b, alpha: &from_a)
        
        var to_r: CGFloat = 0
        var to_g: CGFloat = 0
        var to_b: CGFloat = 0
        var to_a: CGFloat = 0
        to.getRed(&to_r, green: &to_g, blue: &to_b, alpha: &to_a)
        
        let r = from_r + (to_r - from_r) * percent
        let g = from_g + (to_g - from_g) * percent
        let b = from_b + (to_b - from_b) * percent
        let a = from_a + (to_a - from_a) * percent
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 过渡 透明度 值
    /// - Parameters:
    ///   - from: 开始 透明度
    ///   - to: 结束 透明度
    ///   - percent: 过度百分比
    func transitionAlpha(from: CGFloat, to: CGFloat, percent: CGFloat) -> CGFloat {
        guard from != to else { return from }
        return from + (to - from) * percent
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
        
        func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
            
            let animations: (UITransitionContextViewControllerKey) -> Void = { key in
                
                let from = context.viewController(forKey: .from)!
                let to = context.viewController(forKey: .to)!
                
                let progress: CGFloat = context.isCancelled ? 0 : 1.0
                navigationController.navigationBarUpdate(from: from, to: to, progress: progress)
            }
            
            if context.isCancelled {
                let duration = context.transitionDuration * Double(context.percentComplete)
                UIView.animate(withDuration: duration) { animations(.from) }
            } else {
                let duration = context.transitionDuration * Double(1 - context.percentComplete)
                UIView.animate(withDuration: duration) { animations(.to) }
            }
        }
        
        if #available(iOS 10.0, *) {
            coordinator.notifyWhenInteractionChanges { context in
                dealInteractionChanges(context)
            }
        } else {
            coordinator.notifyWhenInteractionEnds { context in
                dealInteractionChanges(context)
            }
        }
    }
}

