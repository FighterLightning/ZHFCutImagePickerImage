//
//  ViewController.swift
//  ZHFCutImagePickerImage
//
//  Created by 张海峰 on 2017/9/20.
//  Copyright © 2017年 张海峰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var picker1: UIImagePickerController =  UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func BtnClick(_ sender: Any) {
        //1.判断照片源是否可用
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            return
        }
        //2.创建照片选择控制器
        let ipc = UIImagePickerController()
        //3.设置照片源
        ipc.sourceType = .photoLibrary
        //4.设置代理
        ipc.delegate = self
        //5.弹出控制器
        present(ipc, animated: true, completion: nil)
    }
    

}
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //  let type :String = info[UIImagePickerControllerMediaType] as! String
        //1.获取选中照片
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let cutImageVC : CutImageVC = CutImageVC()
        cutImageVC.image = image
        cutImageVC.delegate = self
        picker1 = picker
        picker.present(cutImageVC, animated: true, completion: nil)
    }
}
extension ViewController:CutImageVCDelegate
{
    func CutImageClick(cutImage: UIImage) {
        picker1.dismiss(animated: false) {
            self.imageView.image = cutImage
        }
    }
}

