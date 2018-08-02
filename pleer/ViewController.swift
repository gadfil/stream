//
//  ViewController.swift
//  pleer
//
//  Created by GalaevAlexey on 24.01.2018.
//  Copyright © 2018 GalaevAlexey. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import Reachability

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet var containerView : UIView! = nil
    var webView: WKWebView?
    var channelName = ""
    private let parser: Parser<Dictionary<String, Any>> = Parser<Dictionary<String, Any>>()
    
    let reachability = Reachability()
    let refreshControl = UIRefreshControl()
    
    // MARK: - URL
    
    let urlString = "http://reed.pe.hu/chanels1/index.html"


    override func loadView() {
        super.loadView()
        refreshControl.addTarget(self, action: #selector(self.refreshWebView(sender:)), for: .valueChanged)
        let contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "window.sendStartApp('Ios')",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.add(
            self,
            name: "callbackHandler"
        )
        
        contentController.add(
            self,
            name: "callbackHandlerArray"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame: self.containerView.bounds,
            configuration: config
        )
        self.webView?.scrollView.addSubview(refreshControl)

        self.view = self.webView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    func configureWebView() {
        
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        
        webViewRequest()
        
        reachability?.whenReachable = { [unowned self] reachability in
            self.webViewRequest()
        }
        
        reachability?.whenUnreachable = { _ in
            let controller = UIAlertController(title: "Internet Connection Error", message: "Try to change your intenet connection", preferredStyle: .alert)
            let later = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(later)
            self.present(controller, animated: true, completion: nil)
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    struct Version: Decodable {
        let needUpdate: Bool
    }
    
    func requestVersion(){
        let jsonString = "https://asemobile-kraftcom.firebaseio.com/ios/1.json"
        let url = URL(string: jsonString)
        URLSession.shared.dataTask(with: url!) {data, response, error in
            guard let data = data else {return}
            do {
                let result = try JSONDecoder().decode(Version.self, from: data)
                print("Результат - \(result)")
                self.updateVersion(update: result.needUpdate)
            }
                catch {
                 print("Ошибка - \(error)")
                }
            }.resume()
        }
    
    func updateVersion(update:Bool){
            guard update == true else {return}
            let controller = UIAlertController(title: "Update", message: "This version of the app is outdated. Please update app from the app store", preferredStyle: .alert)
            let updateNow = UIAlertAction(title: "Later", style: .destructive, handler: nil)
            
            let later = UIAlertAction(title: "Update now", style: .default, handler: nil)
        
            controller.addAction(updateNow)
            controller.addAction(later)
            present(controller, animated: true, completion: nil)
    }
    
    func webViewRequest(){
        
//        let htmlFile = Bundle.main.path(forResource: "index", ofType: "html")
//        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
//        webView?.loadHTMLString(html!, baseURL: nil)
        
        let url = URL(string: urlString)
        let urlRequest = URLRequest(url: url!)
        webView?.load(urlRequest)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let urlChannel = message.body as? String else { return }
        print(message)
        if message.name == "callbackHandler" {
            channelName = urlChannel
        }
        
        if message.name == "callbackHandlerArray" {
                let json = JSON(parseJSON: urlChannel)
                let items = json.arrayValue.map(MenuItem.init)
                self.openPlayer(url: channelName, list: items)
        }
    }
    
    private func openPlayer(url: String?, list: [MenuItem]) {
        let playerVC  = StreamViewController.loadFromCommonStoryboard() as! StreamViewController
        playerVC.URI = url
        playerVC.items = list
        let navVc = UINavigationController(rootViewController: playerVC)
        self.present(navVc, animated: true) {
            playerVC.play()
        }
    }
    
    @objc
    func refreshWebView(sender: UIRefreshControl) {
        webViewRequest()
        sender.endRefreshing()
    }
}

class Parser<T> {
    
    func parse(data: Any) -> Array<Any>? {
        
        var array: Array<Any>?
        
        if data is Array<Any>
        {
            array = data as? Array<Any>
        }
        else if let dataUserType = data as? T
        {
            array = Array<Any>()
            array?.append(dataUserType as Any)
        }
        
        return array
    }
}


