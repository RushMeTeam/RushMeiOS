//
//  ImageViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 11/30/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
  var image : UIImage = RMImage.NoImage {
    didSet {
      //self.imageView?.image = image
      
    }
  
  }
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var scrollView: UIScrollView!
  override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.scrollView.maximumZoomScale = 3
        self.scrollView.minimumZoomScale = 1
        self.scrollView.isScrollEnabled = true
        self.scrollView.delegate = self
        self.scrollView.contentSize = imageView.frame.size
    
    
        // Do any additional setup after loading the view.
    }

  @IBAction func doneButtonHit(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  override func viewWillAppear(_ animated: Bool) {
    self.imageView?.image = image
    self.imageView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    self.imageView?.layer.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
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
  

  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
