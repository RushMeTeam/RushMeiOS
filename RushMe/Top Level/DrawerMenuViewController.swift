//
//  DrawerMenuViewController.swift
//  
//
//  Created by Adam Kuniholm on 6/3/18.
//

import UIKit

class DrawerMenuViewController: ScrollButtonViewController {
  
  override var buttonIcons : [UIImage?] {
    get { 
      return [UIImage(named: "MapsIcon"),
              UIImage(named: "FraternitiesIcon"), 
              UIImage(named: "EventsIcon"),
              UIImage(named: "SettingsIcon")]
    }
  }
  override var buttonNames : [String] {
    get {
      return ["Maps", "Fraternities", "Events", "Settings"]
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.view.backgroundColor = Frontend.colors.AppColor

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
