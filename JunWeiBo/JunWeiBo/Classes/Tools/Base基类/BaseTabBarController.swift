//
//  BaseTabBarController.swift
//  JUNWeiBo
//
//  Created by 田全军 on 17/1/7.
//  Copyright © 2017年 田全军. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加子控制器
        addChildViewControllers()
        // 此时 tabBarButton 还没有创建
        print(tabBar.subviews)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("--------------")
        // 此时 tabBarButton 都已经创建
        print(tabBar.subviews)
        // 初始化加号按钮
        setupComposeBtn()
    }

    /**
     添加所有子控制
     */
    func addChildViewControllers() {
        
        // 1.获取json文件路径
        let jsonPath = Bundle.main.path(forResource: "MainVCSettings.json", ofType: nil)
        // 2.加载json数据
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath!))
        // 3.序列化json
        do{
            // throw是Xcode7最明显的一个变化, Xcode7之前都是通过传入error指针捕获异常, Xocode7开始通过try/catch捕获异常
            let dictArray = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            // 遍历字典时候需要明确指明数组中的数据类型
            for dict in dictArray  as! [[String:String]]
            {
                // 由于addChildVC方法参数不能为nil, 但是字典中取出来的值可能是nil, 所以需要加上!
                addChildViewController(dict["vcName"]!, title: dict["title"]! as NSString, imageName: dict["imageName"]!)
            }
        }catch{
            addChildViewController("HomeTableController", title: "首页", imageName: "tabbar_home")
            addChildViewController("MessageTableController", title: "消息", imageName: "tabbar_message_center")
            addChildViewController("PublishTableController", title: "", imageName: "")
            addChildViewController("SearchTableController", title: "发现", imageName: "tabbar_discover")
            addChildViewController("MineTableViewController", title: "我", imageName: "tabbar_profile")

        }
    }
    
    /**
     初始化子控制器
     
     :param: vcName          需要初始化的子控制器
     :param: title           初始化的标题
     :param: imageName       初始化的图片
     */
    func addChildViewController(_ vcName: String, title:NSString, imageName:String) {
        // 0.动态获取命名空间
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        print(namespace)
        
        // 告诉编译器暂时就是AnyClass
        let cls:AnyClass = NSClassFromString(namespace + "." + vcName)!
        print(cls)
        // 告诉编译器真实类型是UIViewController
        let vcCls = cls as! UIViewController.Type
        // 实例化控制器
        let vc = vcCls.init()
        
        // 从内像外设置, nav和tabbar都有
        vc.title = title as String
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        
        // 注意: Xocde7之前只有文字有效果, 还需要设置图片渲染模式
        tabBar.tintColor = UIColor.orange
        
        // 2.创建导航控制器
        let nav = UINavigationController()
        nav.addChildViewController(vc)
        
        // 3.添加控制器到tabbarVC
        addChildViewController(nav)

    }
    
    /**
     监听加号按钮点击
     注意:  运行循环监听到事件后，向 VC 发送消息，动态执行 方法，因此不能设置为 private
     */
    func composeBtnClick(){
        print(#function)
    }
    
    // MARK: - 内部控制方法
    
    /**
     设置加号按钮位置
     */
    fileprivate func setupComposeBtn(){
        
        // 0.添加到tabBar上
        tabBar.addSubview(composeBtn)
        
        // 1.计算按钮宽度
        let width = tabBar.bounds.width / CGFloat(viewControllers!.count)
        // 2.创建按钮frame
        let rect = CGRect(x: 0, y: 0, width: width, height: tabBar.bounds.height)
        // 3.设置按钮frame和偏移位
        composeBtn.frame = rect.offsetBy(dx: width * 2, dy: 0)
    }
    
    /// 加号按钮
    fileprivate lazy var composeBtn:UIButton = {
        // 1.创建按钮
        let button = UIButton()
        // 2.设置图片
        button.setImage(UIImage(named: "tabbar_compose_icon_add"), for: UIControlState())
        button.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), for: UIControlState.highlighted)
        // 3.设置背景图片
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button"), for: UIControlState())
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), for: UIControlState.highlighted)
        
        // 4.监听加号按钮点击
        button.addTarget(self, action: #selector(BaseTabBarController.composeBtnClick), for: UIControlEvents.touchUpInside)
        // 4.返回按钮
        return button
    }()
}
