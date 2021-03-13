//
//  CheckmarkView.swift
//  MagicPaper
//
//  Created by Eddie Char on 1/9/21.
//

import UIKit
import AVFoundation

class CheckmarkView: UIView {
    var superView: UIView!
    let checkmarkSize: CGFloat = 200
    let checkmarkScale: CGFloat = 1/3

    init(frame: CGRect, in superView: UIView) {
        super.init(frame: frame)
        
        self.superView = superView
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to load CheckmarkView")
    }
    
    func animate(completion: @escaping () -> ()) {
        let checkmarkView = UIView()
        let bezierPath = UIBezierPath()
        bezierPath.addArc(withCenter: CGPoint(x: (checkmarkView.frame.width  + checkmarkSize) / 2,
                                              y: (checkmarkView.frame.height + checkmarkSize) / 2),
                          radius: checkmarkSize * checkmarkScale,
                          startAngle: 0,
                          endAngle: 2 * .pi,
                          clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.lineCap = .round
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        
        shapeLayer.add(animation, forKey: "drawLineAnimation")
                        
        checkmarkView.backgroundColor = .black
        checkmarkView.alpha = 0.8
        checkmarkView.layer.cornerRadius = 8.0
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.layer.addSublayer(shapeLayer)
        superView.addSubview(checkmarkView)
        NSLayoutConstraint.activate([checkmarkView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
                                     checkmarkView.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
                                     checkmarkView.widthAnchor.constraint(equalToConstant: checkmarkSize),
                                     checkmarkView.heightAnchor.constraint(equalToConstant: checkmarkSize)])
        
        let checkmarkImage = UIImageView(image: UIImage(systemName: "checkmark")!)
        checkmarkImage.alpha = 0
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.addSubview(checkmarkImage)
        
        let imageWidth: NSLayoutConstraint = checkmarkImage.widthAnchor.constraint(equalToConstant: 0)
        let imageHeight: NSLayoutConstraint = checkmarkImage.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([imageWidth,
                                     imageHeight,
                                     checkmarkImage.centerXAnchor.constraint(equalTo: checkmarkView.centerXAnchor),
                                     checkmarkImage.centerYAnchor.constraint(equalTo: checkmarkView.centerYAnchor)])
        
        imageWidth.constant = checkmarkSize * checkmarkScale
        imageHeight.constant = checkmarkSize * checkmarkScale
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            audioManager.playSound(for: "LaunchButton")
            K.addHapticFeedback(withStyle: .heavy)
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 8, options: .curveEaseIn, animations: {
            checkmarkImage.layoutIfNeeded()
            checkmarkImage.alpha = 1.0
            checkmarkView.alpha = 1.0
            checkmarkView.backgroundColor = .systemGreen
        }, completion: { _ in
            checkmarkView.removeFromSuperview()
            completion()
        })
    }
    
}
