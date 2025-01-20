import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        sleep(5)
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
            
        loginTextField.tap()
        loginTextField.typeText("") // write your email
        webView.swipeUp()
            
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
            
        passwordTextField.tap()
        passwordTextField.typeText("") // write your password
        webView.swipeUp()
            
        webView.buttons["Login"].tap()
            
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        XCTAssertTrue(tablesQuery.firstMatch.waitForExistence(timeout: 3))
            
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
            
        sleep(5)
            
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
            
        cellToLike.buttons["like button off"].tap()
        sleep(5)
        cellToLike.buttons["like button on"].tap()
        sleep(5)
            
        cellToLike.tap()
        sleep(5)
            
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
            
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
           
        XCTAssertTrue(app.staticTexts[""].exists) // write your "Name Surname" from profile
        XCTAssertTrue(app.staticTexts[""].exists) // write your username from profile ("@username")
            
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        let authViewController = app.otherElements["AuthViewController"]
        XCTAssertTrue(authViewController.waitForExistence(timeout: 5))
    }
}
