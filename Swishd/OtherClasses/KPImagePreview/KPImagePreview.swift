//
//  KPImagePreview.swift
//  MailM8
//
//  Created by iOS Development Company on 12/22/16.
//  Copyright © 2016 iOS Development Company All rights reserved.
//

import UIKit

class KPPrevButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = ((btnsize.height - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsetsMake(verPad, 0, verPad, 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KPImagePreview: UIViewController {
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var imgs: [AnyObject] = []
    fileprivate var btnClose : KPPrevButton!
    fileprivate var bgView: UIView!
    var scrollDirection = UICollectionViewScrollDirection.horizontal
    
    fileprivate let sourceRect: CGRect?
    fileprivate let selectIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hundelTapGesture))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUI()
        prepareUICollection()
        prepareUIButton()
        
        if let _ = sourceRect{
            addAnimatedImage(rect: sourceRect!, idx: selectIndex)
        }
        
        if let _ = selectIndex{
            collectionView.scrollToItem(at: IndexPath(row: selectIndex!, section: 0), at: UICollectionViewScrollPosition.centeredVertically, animated: false)
        }
    }
    
    init(frame: CGRect, objs: [AnyObject],sourceRace: CGRect?, selectedIndex: Int?) {
        imgs = objs
        sourceRect = sourceRace
        selectIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @objc func hundelTapGesture(sender: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - UIRelated methods
extension KPImagePreview{
    
    fileprivate func prepareUI(){
        bgView = UIView(frame: _screenFrame)
        bgView.backgroundColor = UIColor.black
        self.view.addSubview(bgView)
    }
    
    fileprivate func prepareUICollection(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        var rect = CGRect.zero
        if scrollDirection == .horizontal{
            rect = CGRect(x: -12.5, y: 0, width: _screenSize.width + 25, height: _screenSize.height)
        }else{
            rect = CGRect(x: 0, y: -12.5, width: _screenSize.width, height: _screenSize.height + 25)
        }
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionView)
        collectionView.register(KPImgCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.reloadData()
    }
    
    fileprivate func prepareUIButton(){
        btnClose = KPPrevButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnClose.setImage(UIImage(named: "closeIcon"), for: UIControlState.normal)
        btnClose.addTarget(self, action: #selector(KPImagePreview.closeAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(btnClose)
    }
    
    fileprivate func addAnimatedImage(rect: CGRect, idx: Int?){
        let imgView = UIImageView(frame: rect)
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = true
        
        if let _ = idx{
            if let url = imgs[idx!] as? URL{
                imgView.kf.setImage(with: url, placeholder: _placeImage)
            }else{
                imgView.image = imgs[idx!] as? UIImage
            }
        }else{
            if let url = imgs[0] as? URL{
                imgView.kf.setImage(with: url, placeholder: _placeImage)
            }else{
                imgView.image = imgs[0] as? UIImage
            }
        }
        self.collectionView.isHidden = true
        self.view.addSubview(imgView)
        bgView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            imgView.frame = _screenFrame
            self.bgView.alpha = 1.0
            }) { (done) in
                imgView.removeFromSuperview()
                self.collectionView.isHidden = false
        }
    }
    
    @objc fileprivate func closeAction(sender: UIButton){
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Collection view methods
extension KPImagePreview: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return _screenSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        if scrollDirection == .horizontal{
            return UIEdgeInsetsMake(0, 12.5, 0, 12.5)
        }else{
            return UIEdgeInsetsMake(12.5, 0, 12.5, 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KPImgCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imCell = cell as? KPImgCell{
            imCell.setImage(obj: imgs[indexPath.row])
        }
    }
}

class KPImgCell: UICollectionViewCell, UIScrollViewDelegate{
    
    var imgView: UIImageView!
    var scrollView: UIScrollView!
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        self.addSubview(scrollView)
        imgView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        imgView.center = scrollView.center
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFit
        scrollView.addSubview(imgView)
    }

    override func prepareForReuse() {
        scrollView.setZoomScale(1.0, animated: false)
    }
    
    fileprivate func setImage(obj: AnyObject){
        scrollView.setZoomScale(1.0, animated: false)
        if let url = obj as? URL{
            imgView.kf.setImage(with: url, placeholder: _placeImage)
        }else if let img = obj as? UIImage{
            imgView.image = img
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
}
