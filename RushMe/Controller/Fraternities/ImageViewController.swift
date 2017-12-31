//
//  ImageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/30/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
  var image : UIImage = RMImage.NoImage
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var scrollView: UIScrollView!
  var visualEffectView : UIVisualEffectView?
  override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        visualEffectView!.frame = self.view.frame
        self.view.addSubview(visualEffectView!)
        self.view.sendSubview(toBack: visualEffectView!)
        self.view.backgroundColor = UIColor.clear
        self.scrollView.maximumZoomScale = 3
        self.scrollView.minimumZoomScale = 1
        self.scrollView.isScrollEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentSize = imageView.frame.size
        self.scrollView.bounces = true
    }

  override func viewWillAppear(_ animated: Bool) {
    self.imageView?.image = image
    self.imageView?.layer.masksToBounds = true
    self.imageView?.layer.cornerRadius = RMImage.CornerRadius
  }
  
  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    if (scrollView.zoomScale < 0.75) {
      self.dismiss(animated: true, completion: nil)
    }
  }

  @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
