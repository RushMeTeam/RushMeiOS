//
//  RushMeUITests.swift
//  RushMeUITests
//
//  Created by Adam Kuniholm on 10/7/17.
//  Copyright © 2017 4 1/2 Frat Boys. All rights reserved.
//

import XCTest

class RushMeUITests: XCTestCase {
  
  lazy var app = XCUIApplication()
  lazy var menuButton = app.navigationBars["RushMe.RMView"].buttons["Item"]
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = true
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    //setupSnapshot(app)
    //let drawerScrollView = app.scrollViews["drawerMenuScrollView"]
    //let tableView = app.tables["MasterTable"]
    
    app.launch()    
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    
  }
  
  func testFraternities() {
    let elementsQuery = app.scrollViews.otherElements
    app.searchFields.firstMatch.tap()    
    snapshot("FraternityMaster")
    app.keys["C"].tap()
    app.keys["h"].tap()
    app.keys["i"].tap()
    app/*@START_MENU_TOKEN@*/.keys["space"]/*[[".keyboards.keys[\"space\"]",".keys[\"space\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app/*@START_MENU_TOKEN@*/.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app.keys["P"].tap()
    snapshot("Searched")
    elementsQuery.tables["MasterTable"].cells.firstMatch.tap()
    snapshot("FraternityDetail")
    app.buttons["Back"].tap()
    app.scrollViews.otherElements.buttons["Cancel"].tap()
  }
  
  func testMenu() {
    menuButton.tap()
    snapshot("MenuOpen")
    menuButton.tap()
  }
  
  func testGoingDown(on label: String) {
    menuButton.tap()
    let elementsQuery = app.scrollViews["drawerMenuScrollView"].otherElements
    elementsQuery.buttons[label].swipeUp()
    menuButton.tap()
  }
  func testGoingUp(on label: String) {
    menuButton.tap()
    let elementsQuery = app.scrollViews["drawerMenuScrollView"].otherElements
    elementsQuery.buttons[label].swipeDown()
    menuButton.tap()
  }
  
  func testMaps() {
    sleep(5)
    let label = "Maps"
    testGoingUp(on: label)
    snapshot("Maps")
    testGoingDown(on: label)
    
  }
  
  func testCalendar() {
    sleep(5)
    let label = "Calendar"
    testGoingDown(on: label)
    snapshot("Calendar")
    testGoingUp(on: label)
  }
  
  func testAll() {
    
    testFraternities()
    
    
    
    
    // Use recording to get started writing UI tests.    
    
    //    
    //    if app.buttons["Sure, let's go!"].exists {
    //      app.buttons["Sure, let's go!"].tap()
    //    }
    
    //    snapshot("FraternitiesMaster")
    //    XCUIApplication().scrollViews.otherElements.tables.buttons["Favorites"].tap()
    //    snapshot("FraternitiesMasterFavorites")
    //    XCUIApplication().scrollViews.otherElements.tables.buttons["All"].tap()
    //    
    //    app.scrollViews.otherElements.tables/*@START_MENU_TOKEN@*/.staticTexts["Chi Phi"]/*[[".cells.staticTexts[\"Chi Phi\"]",".staticTexts[\"Chi Phi\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    //    snapshot("FraternitiesDetail")
    //    app.navigationBars["Χ Φ"].buttons["Back"].tap()
    //    app.navigationBars["RushMe.ScrollPageView"].buttons["Item"].tap()
    //    snapshot("FraternitiesMasterDrawer")
    //    drawerScrollView.swipeDown()
    //    snapshot("MapsDrawer")
    //    app.navigationBars["RushMe.ScrollPageView"].buttons["Item"].tap()
    //    snapshot("Maps")
    //    app.navigationBars["RushMe.ScrollPageView"].buttons["Item"].tap()
    //    drawerScrollView.swipeUp()
    //    drawerScrollView.swipeUp()
    //    snapshot("CalendarDrawer")
    //    app.navigationBars["RushMe.ScrollPageView"].buttons["Item"].tap()
    //    let elementsQuery = app.scrollViews.otherElements
    //    elementsQuery/*@START_MENU_TOKEN@*/.collectionViews.staticTexts["10"]/*[[".scrollViews.collectionViews",".cells.staticTexts[\"10\"]",".staticTexts[\"10\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
    //    snapshot("Calendar")
    
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
  }
  
}
