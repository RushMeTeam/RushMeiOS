//
//  MasterViewController.swift
//  RushMe
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import UIKit
// Commit test comment
// Master view controller, a subclass of UITableViewController,
// provides the main list of fraternities from which a user can
// select in order to find detail.
// Notes:
//    -- Allows 3DTouch
//    -- Is the SWRevealViewController's .front view controller
//          -- Set in AppDelegate
class MasterViewController: UITableViewController {
  
  // The hard data used in the table
  var objects = [Any]()
  var fratNames = [String]()
  var fraternities = Dictionary<String, Fraternity>()
  // The menu button used to toggle the slide-out menu
  @IBOutlet var openBarButtonItem: UIBarButtonItem!
  // MARK: SQL
  let sqlHandler = SQLHandler()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Ensure the menu button toggles the menu
    openBarButtonItem.target = self
    openBarButtonItem.action = #selector(self.toggleViewControllers(_:))
    // Allows for drag to open and tap out to close
    view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    
    // Sample/dummy data
//    var imageNames = Dictionary<String, String>();
//    imageNames["profile"] = "chiPhiImage.png"
//    imageNames["cover"] = "rushCalendar.jpg"
//    objects.append(Fraternity(name: "Chi Phi", chapter: "Theta", description:
//      "The Theta Chapter of the Chi Phi Fraternity was founded on May 25, 1878. Chi Phi is the oldest social fraternity in America and the Theta Chapter boasts notable alumnus such as George Ferris and Frank and Kenneth Osborn. Their house is located across from Quad, on the corner of 15th St. and Sage Avenue." +
//      "The brothers of Chi Phi utilize a strong network of alumni who visit and provide aid in academic and professional careers. The brothers of the Theta Chapter of Chi Phi are very diverse in both interests and cultural backgrounds." +
//      "The Theta Chapter is heavily involved in Chi Phi’s national philanthropy, the Boys and Girls Club of America. Theta assist the Boys and Girls Club by tutoring and putting on holiday events for the local youth. Every spring, the brothers of the Theta Chapter partner with the St. Baldrick’s Foundation, an organization that raises money to support the research of childhood cancers. Last spring, 26 of the 41 brothers volunteered to shave their heads to raise money for St. Baldrick’s. In total, the chapter raised in excess of $4,300 becoming the largest donor at the local St. Baldrick’s fundraiser." +
//      "Chi Phi is a vibrant and diverse fraternity that strives to build True Gentleman though Truth, Honor, and Personal Integrity. The brothers of the Theta Chapter of Chi Phi participate in a variety of activities from varsity and intramural sport, clubs, and leadership positions. Chi Phi is a welcoming environment that that anyone can find a home in.",
//                              imageNames : imageNames))
//    objects.append(Fraternity(name: "Pi Kappa Alpha", chapter: "Iota Delta Kappa", description: nil, imageNames: nil))
//
    if let dictArray = sqlHandler.select(aField: "*", fromTable: "house_info") {
      for dict in dictArray {
        
        let name = dict["name"] as! String
        let chapter = dict["chapter"] as! String
        let frat = Fraternity(name: name, chapter: chapter, previewImage: nil)
        fraternities[name] = frat
        fratNames.append(name)
      }
    }
    fraternities["Chi Phi"]?.setProperty(named: "profileImage", to: UIImage(named: "chiPhiImage.png")!)
  
  
  
  }
  @objc func toggleViewControllers(_:Any?) {
    self.revealViewController().revealToggle(self)
    
  }
  // Not a very interesting function, makes sure selection from last time
  // is cleared
  // (i.e. it's not highlighted in the dark gray of a selected cell)
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Checks if segue is going into detail
    if segue.identifier == "showDetail" {
        if let indexPath = tableView.indexPathForSelectedRow {
          if let object = fraternities[fratNames[indexPath.row]] {
            let controller = (segue.destination as! UINavigationController).topViewController
                                                                          as! DetailViewController
            // Send the detail controller the fraternity we're about to display
            controller.selectedFraternity = object
            // Ensure a back button is given
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
          }
        }
        // 3D Touch preview!
        else if let cell = sender as? FratCell {
          // Determine which object user selected
          if let indexPath = tableView.indexPath(for: cell) {
            if let object = fraternities[fratNames[indexPath.row]] {
              let controller = (segue.destination as! UINavigationController).topViewController
                                                                          as! DetailViewController
              controller.selectedFraternity = object
            }
          }
        }
    }
  }

  // MARK: - Table View

  // Should always be 1 (for now!)
  override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

  // Should always be the number of objects to display
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return fratNames.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FratCell") as! FratCell
    if let frat = fraternities[fratNames[indexPath.row]] {
      cell.titleLabel!.text = frat.name
      cell.subheadingLabel!.text = frat.chapter
      cell.previewImageView!.image = frat.previewImage as? UIImage
    }
    return cell
  }
}

