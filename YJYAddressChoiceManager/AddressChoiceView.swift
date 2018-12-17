//
//  AddressChoiceView.swift
//  HuoBon
//
//  Created by 杨静云 on 2018/10/9.
//  Copyright © 2018年 lizaonet. All rights reserved.
//

import UIKit

protocol AddressChoiceDelegate:NSObjectProtocol {
    func addressResult(pro:(pro:String,proID:String),city:(city:String,cityID:String),area:(area:String,areaID:String),address:(address:String,addressID:String))
    func dissmiss(str:String)
}

class AddressChoiceView: UIView {
    
    class func initView() -> AddressChoiceView {
        let view = Bundle.main.loadNibNamed("AddressChoiceView", owner: nil, options: nil)?.last! as! AddressChoiceView
        return view
    }

    @IBOutlet weak var backView: UIView!
    
    
    @IBOutlet weak var proBt: UIButton!
    @IBOutlet weak var cityBt: UIButton!
    @IBOutlet weak var areaBt: UIButton!
    @IBOutlet weak var addressBt: UIButton!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //省份数据源
    fileprivate var proArr:[(pro:String,proID:String)] = [(pro:String,proID:String)]()
    //城市数据源
    fileprivate var cityArr:[(city:String,cityID:String)] = [(city:String,cityID:String)]()
    //地区数据源
    fileprivate var areaArr:[(area:String,areaID:String)] = [(area:String,areaID:String)]()
    //街道数据源
    fileprivate var addressArr:[(address:String,addressID:String)] = [(address:String,addressID:String)]()
    
    //传入的省份
    fileprivate var pro:String = ""
    fileprivate var proId:String = ""
    //传入的城市
    fileprivate var city:String = ""
    fileprivate var cityId:String = ""
    //传入的区县
    fileprivate var area:String = ""
    fileprivate var areaId:String = ""
    //定位的区县
    fileprivate var address:String = ""
    fileprivate var addressId:String = ""
    
    //当前定位的index(0:省 1:市 2:区 3:街道)
    fileprivate var currIndex:Int = 0
    
    var delegate:AddressChoiceDelegate?
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dissmissView()
    }
    
    override func awakeFromNib() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.initData()
        self.setBtClickNumHiddenAfterBt(num: self.currIndex)
    }
    
    @IBAction func choiceBtAction(_ sender: UIButton) {
        self.currIndex = sender.tag - 200
        switch self.currIndex {
        case 0:
            self.proBt.setTitle("省份", for: .normal)
            break
        case 1:
            self.cityBt.setTitle("城市", for: .normal)
            break
        case 2:
            self.areaBt.setTitle("区县", for: .normal)
            break
        case 3:
            self.addressBt.setTitle("街道", for: .normal)
            break
        default:
            break
        }
        self.initData()
        self.setBtClickNumHiddenAfterBt(num:self.currIndex)
    }
    
    func setBtClickNumHiddenAfterBt(num:Int) {
        for i in 0...num{
            let bt = self.viewWithTag(200 + i)
            bt?.isHidden = false
        }
        for i in num+1...4 {
            let bt = self.viewWithTag(200 + i)
            bt?.isHidden = true
        }
        self.lineAnimation(num: self.currIndex)
    }
    
    func lineAnimation(num:Int) {
        let lineW = ((self.frame.size.width - 30.0)/4.0)
        let lineX = lineW+(lineW + 10.0) * CGFloat(self.currIndex) - lineW/2.0 - 25.0
        UIView.animate(withDuration: 0.2) {
            self.lineView.frame = CGRect(x: lineX, y: 140.0, width: 50.0, height: 2.0)
        }
    }
    
    
    func showView(supView:UIView) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        supView.addSubview(self)
        self.backView.transform = CGAffineTransform(translationX: 0, y: 415)
        UIView.animate(withDuration: 0.3 ) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.backView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func dissmissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.backView.transform = CGAffineTransform(translationX: 0, y: 415)
        }) { (result) in
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
        let touch = ((touches as NSSet).anyObject() as AnyObject)     //进行类  型转化
        if   touch.view.isDescendant(of: self.backView) {
            return
        }
        self.dissmissView()
    }
    
    func initData() {
        //根据市区添加区县
        var listData: NSArray = NSArray()
        let filePath = Bundle.main.path(forResource: "Area.plist", ofType: nil)
        listData = NSArray(contentsOfFile: filePath!)!
        
        self.proArr.removeAll()
        self.cityArr.removeAll()
        self.areaArr.removeAll()
        self.addressArr.removeAll()
        
        //遍历根数组
        for cityDic in listData.reversed(){
            let dicP:NSDictionary = cityDic as! NSDictionary
            self.proArr.append((pro: dicP["province"] as! String, proID: dicP["province_id"] as! String))
            //根据传入的省份获取市区
            if (dicP["province"] as! String) == self.pro{
                self.proId = (dicP["province_id"] as? String)!
                let proArr = dicP["city"] as! NSArray
                for cityDic in proArr.reversed(){
                    let dicC:NSDictionary = cityDic as! NSDictionary
                    self.cityArr.append((city: dicC["city"] as! String, cityID: dicC["city_id"] as! String))
                    //根据传入的市区获取区县
                    if (dicC["city"] as! String) == self.city{
                        self.cityId = (dicC["city_id"] as? String)!
                        let cityArr = dicC["area"] as! NSArray
                        for areaDic in cityArr.reversed(){
                            let dicA:NSDictionary = areaDic as! NSDictionary
                            //print(dicA["-name"])
                            //                            self.areaArr.append(dicA["area"] as! String)
                            self.areaArr.append((area:dicA["area"] as! String, areaID:dicA["area_id"] as! String))
                            //根据传入的区县获取街道
                            if (dicA["area"] as! String) == self.area{
                                self.areaId = (dicA["area_id"] as? String)!
                                //self.areaPosId = (dicA["area_id"] as? String)!
                                if dicA["street"] != nil{
                                    let areaArr = dicA["street"] as! NSArray
                                    for streetDic in areaArr.reversed(){
                                        let dicS:NSDictionary = streetDic as! NSDictionary
                                        //print(dicS["-name"])
                                        self.addressArr.append((address: dicS["street"] as! String, addressID: dicS["street_id"] as! String))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension AddressChoiceView:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.currIndex {
        case 0:
            return self.proArr.count
        case 1:
            return self.cityArr.count
        case 2:
            return self.areaArr.count
        case 3:
            return self.addressArr.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        switch self.currIndex {
        case 0:
            cell.textLabel?.text = self.proArr[indexPath.row].pro
            break
        case 1:
            cell.textLabel?.text = self.cityArr[indexPath.row].city
            break

        case 2:
            cell.textLabel?.text = self.areaArr[indexPath.row].area
            break

        case 3:
            cell.textLabel?.text = self.addressArr[indexPath.row].address
            break

        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.currIndex {
        case 0:
            self.proBt.setTitle(self.proArr[indexPath.row].pro, for: .normal)
            self.pro = self.proArr[indexPath.row].pro
            self.proId = self.proArr[indexPath.row].proID
            self.currIndex = 1
            self.initData()
            self.setBtClickNumHiddenAfterBt(num: self.currIndex)
            break
        case 1:
            self.cityBt.setTitle(self.cityArr[indexPath.row].city, for: .normal)
            self.city = self.cityArr[indexPath.row].city
            self.cityId = self.cityArr[indexPath.row].cityID
            self.currIndex = 2
            self.initData()
            self.setBtClickNumHiddenAfterBt(num: self.currIndex)
            break
            
        case 2:
            self.areaBt.setTitle(self.areaArr[indexPath.row].area, for: .normal)
            self.area = self.areaArr[indexPath.row].area
            self.areaId = self.areaArr[indexPath.row].areaID
            self.currIndex = 3
            self.initData()
            self.setBtClickNumHiddenAfterBt(num: self.currIndex)
            break
            
        case 3:
            self.addressBt.setTitle(self.addressArr[indexPath.row].address, for: .normal)
            self.address = self.addressArr[indexPath.row].address
            self.addressId = self.addressArr[indexPath.row].addressID
            self.initData()
            self.setBtClickNumHiddenAfterBt(num: self.currIndex)
            
            if self.delegate != nil{
                self.delegate?.addressResult(pro:(self.pro,self.proId), city: (self.city,self.cityId), area: (self.area,self.areaId), address: (self.address,self.addressId))
                self.dissmissView()
            }
            break
            
        default:
            break
        }
    }
}
