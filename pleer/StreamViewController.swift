//
//  StreamViewController.swift
//  pleer
//
//  Created by Alexey Galaev on 6/6/18.
//  Copyright © 2018 Alexey Galaev. All rights reserved.
//

import Foundation

class StreamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VLCMediaPlayerDelegate {

    var URI: String? = nil
    @IBOutlet weak var movieView: UIView!
    @IBOutlet var playerTableView: UITableView!
    @IBOutlet var exitButton: UIButton!
    @IBOutlet var subtitlesButton: UIButton!
    
    var items: [MenuItem] = []
    var mediaPlayer = VLCMediaPlayer()
    var activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask  {
        return .landscapeLeft
    }
    
    @objc func tap() {
        playerTableView.isHidden = !playerTableView.isHidden
        exitButton.isHidden = !exitButton.isHidden
        subtitlesButton.isHidden = !subtitlesButton.isHidden
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieView.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        mediaPlayer.delegate = self
        movieView.addSubview(activity)
        exitButton.clipsToBounds = true
        exitButton.layer.cornerRadius = 4
        exitButton.layer.borderColor = UIColor.white.cgColor
        exitButton.layer.borderWidth = 2
        
        subtitlesButton.clipsToBounds = true
        subtitlesButton.layer.cornerRadius = 4
        subtitlesButton.layer.borderColor = UIColor.white.cgColor
        subtitlesButton.layer.borderWidth = 2
        
        playerTableView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @IBAction func close() {
        self.dismiss(animated: true) {
            print("player dissmissed")
        }
    }
    
    @IBAction func toggleSubtitles(_ sender: UIButton) {
        subtitlesButton.isSelected = !sender.isSelected
        guard let subtitle = mediaPlayer.videoSubTitlesIndexes.first as? Int  else { return }
        mediaPlayer.currentVideoSubTitleIndex = Int32(subtitlesButton.isSelected ? subtitle : -1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Associate the movieView to the VLC media player
        mediaPlayer.drawable = self.movieView
        
        // Create `VLCMedia` with the URI retrieved from the camera
        if let URI = URI {
            let url = URL(string: URI)
            let media = VLCMedia(url: url!)
            mediaPlayer.media = media
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activity.center = self.view.center
    }
    
    func play() {
        mediaPlayer.play()
        activity.startAnimating()
        activity.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaPlayer.stop()
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        switch player.state {
        case .playing:
            activity.stopAnimating()
            activity.isHidden = true
           break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let itemcell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell") as! MenuItemCell
        itemcell.confugure(item: item, index: indexPath.row)
        return itemcell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        mediaPlayer.stop()
        guard let url = URL(string: item.url) else { return }
        let media = VLCMedia(url: url)
        mediaPlayer.media = media
        play()
    }
    
    @objc
    func rotated() {
        let number = NSNumber(integerLiteral: UIDeviceOrientation.landscapeLeft.rawValue)
        UIDevice.current.setValue(number, forKey: "orientation")
        while UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            _ = touch.location(in: self.movieView)
           tap()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIViewController
{
    static func load(from storyboard: UIStoryboard, id: String? = nil) -> UIViewController {
        let vcid = id ?? String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: vcid)
    }
    
    static func loadFromCommonStoryboard() -> UIViewController {
        let common = UIStoryboard(name: "Main", bundle: Bundle.main)
        return load(from: common, id: nil)
    }
}

extension UINavigationController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask  {
        return .landscapeLeft
    }
}
