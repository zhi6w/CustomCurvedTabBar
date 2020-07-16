//
//  CurvedTabBar.swift
//  CustomTabBar
//
//  Created by Zhi Zhou on 2020/7/14.
//  Copyright © 2020 Zhi Zhou. All rights reserved.
//

import UIKit

open class CurvedTabBar: UITabBar {
    
    private enum ShapeLayerStyle {
        case mask, fill
    }

    private var maskShapeLayer: CALayer?
    private var fillShapeLayer: CALayer?
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))

    private let centerButton = UIButton(type: .system)
    private var centerButtonWidthLayoutConstraint: NSLayoutConstraint?
    private var centerButtonHeightLayoutConstraint: NSLayoutConstraint?
    
    open var centerButtonBottomOffset: CGFloat = 5.0
    
    public typealias ActionHandler = (UIButton) -> Void?

    public var centerActionHandler: ActionHandler?
    
    
    open override func draw(_ rect: CGRect) {
        setupShapeLayer()
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        let buttonRadius: CGFloat = bounds.height / 2
        
        return point.y > 0 || (point.y >= -buttonRadius && (point.x >= center.x - buttonRadius) && (point.x <= center.x + buttonRadius))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupInterface()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutCenterButton()
    }
    
}

extension CurvedTabBar {
    
    private func setupInterface() {
        setupEffectView()
        setupCenterButton()
    }
    
    private func setupEffectView() {
        
        effectView.contentView.layer.masksToBounds = false
        
        insertSubview(effectView, at: 0)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            effectView.leftAnchor.constraint(equalTo: self.leftAnchor),
            effectView.rightAnchor.constraint(equalTo: self.rightAnchor),
            effectView.topAnchor.constraint(equalTo: self.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupCenterButton() {
        
        centerButton.backgroundColor = .systemBlue

        centerButton.isPointerInteractionEnabled = true
        centerButton.pointerStyleProvider = { button, proposedEffect, proposedShape -> UIPointerStyle? in
            var rect = button.bounds.insetBy(dx: 0, dy: 0)
            rect = button.convert(rect, to: proposedEffect.preview.target.container)
            
            return UIPointerStyle(effect: .lift(proposedEffect.preview), shape: .roundedRect(rect, radius: button.bounds.width / 2))
        }
        
        centerButton.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        
        addSubview(centerButton)
        
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        
        centerButtonWidthLayoutConstraint = centerButton.widthAnchor.constraint(equalToConstant: 0)
        centerButtonHeightLayoutConstraint = centerButton.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            centerButton.centerYAnchor.constraint(equalTo: self.topAnchor, constant: -centerButtonBottomOffset),
            centerButtonWidthLayoutConstraint!,
            centerButtonHeightLayoutConstraint!
        ])
    }
    
    private func layoutCenterButton() {
        
        let centerImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: bounds.height / 2 - centerButtonBottomOffset, weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        centerButton.setImage(centerImage, for: .normal)
                        
        centerButtonWidthLayoutConstraint?.constant = bounds.height - centerButtonBottomOffset
        centerButtonHeightLayoutConstraint?.constant = bounds.height - centerButtonBottomOffset
        
        centerButton.layer.cornerRadius = centerButton.bounds.height / 2
    }
    
}

extension CurvedTabBar {
    
    private func setupShapeLayer() {
                
        let maskShapeLayer = CAShapeLayer()
        maskShapeLayer.path = createPath(style: .mask)
        
        if let oldShapeLayer = self.maskShapeLayer {
            effectView.layer.replaceSublayer(oldShapeLayer, with: maskShapeLayer)
        } else {
            effectView.layer.mask = maskShapeLayer
        }
    
        let fillShapeLayer = CAShapeLayer()
        fillShapeLayer.path = createPath(style: .fill)
        fillShapeLayer.strokeColor = UIColor.shadowColor.cgColor

        if let oldShapeLayer = self.fillShapeLayer {
            effectView.contentView.layer.replaceSublayer(oldShapeLayer, with: fillShapeLayer)
        } else {
            effectView.contentView.layer.addSublayer(fillShapeLayer)
        }
        
        self.maskShapeLayer = maskShapeLayer
        self.fillShapeLayer = fillShapeLayer
    }
    
    private func createPath(style: ShapeLayerStyle) -> CGPath {
        
        let height: CGFloat = bounds.height / 2
        let path = UIBezierPath()
        let centerWidth = frame.width / 2
        let shadowHeight = 1 / UIScreen.main.scale

        path.move(to: CGPoint(x: 0, y: -shadowHeight))
        path.addLine(to: CGPoint(x: centerWidth - height * 2, y: -shadowHeight))
        
        path.addCurve(to: CGPoint(x: centerWidth, y: height), controlPoint1: CGPoint(x: centerWidth - height / 2, y: 0), controlPoint2: CGPoint(x: centerWidth - height, y: height))
        path.addCurve(to: CGPoint(x: centerWidth + height * 2, y: -shadowHeight), controlPoint1: CGPoint(x: centerWidth + height, y: height), controlPoint2: CGPoint(x: centerWidth + height / 2, y: 0))
        
        path.addLine(to: CGPoint(x: frame.width, y: -shadowHeight))
        
        switch style {
        case .mask:
            path.addLine(to: CGPoint(x: frame.width, y: frame.height))
            path.addLine(to: CGPoint(x: 0, y: frame.height))
            
        default:
            break
        }
        
        path.close()
        
        return path.cgPath
    }
    
}

extension CurvedTabBar {
    
    @objc private func action(_ button: UIButton) {
        centerActionHandler?(button)
    }
    
}

fileprivate extension UIImage {
    
    /// 根据新的尺寸重绘图片
    func resizeImage(withSize newSize: CGSize) -> UIImage? {
        
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 0
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        
        let newImage = renderer.image { (context) in
            let rect = CGRect(origin: .zero, size: newSize)
            draw(in: rect)
        }
        
        return newImage
    }
    
}

fileprivate extension UIColor {
        
    /// 分割线颜色
    static var shadowColor: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(white: 1, alpha: 0.15)
            } else {
                return UIColor(white: 0, alpha: 0.3)
            }
        }
    }
    
}































