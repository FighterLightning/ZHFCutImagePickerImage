//
//  CutImageVC.swift
//  ZHFCutImagePickerImage
//
//  Created by 张海峰 on 2017/9/20.
//  Copyright © 2017年 张海峰. All rights reserved.
//
//设备物理尺寸
let ScreenHeight = UIScreen.main.bounds.size.height
let ScreenWidth = UIScreen.main.bounds.size.width
import UIKit
//代理把剪切好的图传回去
protocol CutImageVCDelegate {
    func CutImageClick(cutImage: UIImage)
}
class CutImageVC: UIViewController {
   
    var topView: UIView!
    var cutView: UIView!
    var cutViewH: CGFloat = 0.0
    
    var imageView: UIImageView!
    var bottomView: UIView!
    
    var delegate: CutImageVCDelegate?
    //接收选择的图片
    var image :UIImage? = nil
    //当拖拽图片的起始点
    var startPoint: CGPoint = CGPoint.init(x: 0, y: 0)
    //imageView的高
    var imageViewH: CGFloat = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        setUI()
        addGestureRecognizer()
    }
    func setUI() {
        // 170 / (ScreenWidth - 60) 为要截取图片的宽高比 可自行调整
        cutViewH =   ScreenWidth * 170 / (ScreenWidth - 60)
        imageViewH = (image?.size.height)! / (image?.size.width)! * ScreenWidth
        topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: (ScreenHeight - cutViewH)/2))
         topView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        cutView = UIView.init(frame: CGRect.init(x: 0 , y: topView.frame.maxY, width: ScreenWidth, height: cutViewH))
        imageView = UIImageView.init(frame: CGRect.init(x: 0, y: (cutViewH-imageViewH)/2, width: ScreenWidth, height: imageViewH))
        imageView.image = image!
        cutView.addSubview(imageView)//一定要放在cutView 上
        bottomView = UIView.init(frame: CGRect.init(x: 0, y:(ScreenHeight + cutViewH)/2, width: ScreenWidth, height: (ScreenHeight - cutViewH)/2))
        bottomView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.view.addSubview(cutView)
        self.view.addSubview(topView)
        self.view.addSubview(bottomView)
        let cancleBtn = UIButton.init(type: UIButtonType.custom)
        cancleBtn.frame = CGRect.init(x: 20, y: bottomView.frame.height - 60, width: 50, height: 40)
        cancleBtn.setTitle("取消", for: UIControlState.normal)
        cancleBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        cancleBtn.addTarget(self, action: #selector(cancleBtnClick), for: UIControlEvents.touchUpInside)
        bottomView.addSubview(cancleBtn)
        let entureBtn = UIButton.init(type: UIButtonType.custom)
        entureBtn.frame = CGRect.init(x: bottomView.frame.maxX-70, y: bottomView.frame.height - 60, width: 50, height: 40)
        entureBtn.setTitle("确定", for: UIControlState.normal)
        entureBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        entureBtn.addTarget(self, action: #selector(entureBtnClick), for: UIControlEvents.touchUpInside)
        bottomView.addSubview(entureBtn)
    }
    func addGestureRecognizer(){
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tap))
        tapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(tapGestureRecognizer)
        //拖拽
        let panGestureRecognizer:UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(pan))
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
        //缩放
        let pinchGestureRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer.init(target: self, action: #selector(pinch))
        pinchGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(pinchGestureRecognizer)
    }
    func cancleBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    func entureBtnClick() {
        //截取高清图
        UIGraphicsBeginImageContextWithOptions(cutView.frame.size, false, 0.0)
        //截取模糊图
        // UIGraphicsBeginImageContext(cutView.frame.size)
        cutView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image1:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        self.dismiss(animated: false) {
            self.delegate?.CutImageClick(cutImage: image1)
        }
    }
}
extension CutImageVC:UIGestureRecognizerDelegate{
    func tap(gesture:UITapGestureRecognizer){
    
        if ScreenWidth == imageView.frame.size.width  {
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.frame = CGRect.init(x:-ScreenWidth/2, y: self.cutViewH/2-self.imageViewH, width: ScreenWidth*2, height: self.imageViewH*2)
            })
        }
        else{
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.frame = CGRect.init(x: 0, y:  -self.imageViewH/2 + self.cutViewH/2, width: ScreenWidth, height: self.imageViewH)
            })
        }
    }
    func pan(recognizer:UIPanGestureRecognizer){
        let translation: CGPoint = recognizer.translation(in: self.view)
        self.imageView.center = CGPoint.init(x: self.imageView.center.x + translation.x, y: self.imageView.center.y + translation.y)
        recognizer.setTranslation(CGPoint.zero, in: self.view)
        if  recognizer.state == UIGestureRecognizerState.began{
            startPoint = self.imageView.center
        }
        if  recognizer.state == UIGestureRecognizerState.ended{
            let translationX: CGFloat = self.imageView.center.x - startPoint.x
            let translationY: CGFloat = self.imageView.center.y - startPoint.y
            if translationX > 0 {
                //右移
                if self.imageView.frame.minX > 0 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.frame.origin.x = 0
                    })}
            }
            if translationX < 0 {
                //左移
                if self.imageView.frame.maxX < ScreenWidth {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.frame.origin.x = ScreenWidth - self.imageView.frame.size.width
                    })}
            }
            if translationY > 0 {
                //下移
                if self.imageView.frame.minY > 0   {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.frame.origin.y = 0
                    })
                }
            }
            if translationY < 0 {
                //上移
                if self.imageView.frame.maxY < (ScreenHeight + self.cutViewH)/2 {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.frame.origin.y = self.cutViewH - self.imageView.frame.size.height
                    })}
            }
        }
        
    }
    func pinch(recognizer:UIPinchGestureRecognizer){
        self.imageView.transform = self.imageView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        recognizer.scale = 1;
        if  recognizer.state == UIGestureRecognizerState.ended{
            let imageViewW: CGFloat = self.imageView.frame.size.width
            if imageViewW <= ScreenWidth{
                UIView.animate(withDuration: 0.3, animations: {
                    self.imageView.frame = CGRect.init(x: 0, y: -(self.imageViewH - self.cutViewH)/2 , width: ScreenWidth, height: self.imageViewH)
                })
            }
            if imageViewW >= ScreenWidth*3{
                UIView.animate(withDuration: 0.3, animations: {
                    self.imageView.frame = CGRect.init(x:-ScreenWidth, y: -self.imageViewH*3/2 + self.cutViewH/2 , width: ScreenWidth*3, height: self.imageViewH*3)
                })
            }
        }
    }
    //防止手势之间是互斥的，如果手势同时触发，那么需要要实现协议
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

