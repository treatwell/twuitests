<div align="center">  
    
<a href="https://treatwell.com/tech/">
<img style="border-radius: 10%;" src="https://user-images.githubusercontent.com/4553194/61220140-96ec6900-a70d-11e9-9795-cdd61069eb8b.jpg" />
</a>

</div>

# Usage

### Purpose
Lightweight UITests framework based on XCTest to help you write and maintain UITests quickly and easily with well organised code structure.

### Use Swift Package Manager as a dependancy manager 

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler. To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter https://github.com/treatwell/twuitests.git

or add dependency to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    name: "MySPMLibrary",
    dependencies: [
        .package(url: "https://github.com/treatwell/twuitests.git", .upToNextMajor(from: "0.2.0"))
    ]
)
```

### Use Carthage as a dependancy manager

1. Add `git "https://github.com/treatwell/twuitests.git"` to your Cartfile.
2. Run `carthage update`to fetch & build. Append `--platform iOS` if only iOS build is needed.

### Main project UITests target configuration

1. Build settings: in **Runpath Search Paths** add `$(PROJECT_DIR)/Carthage/Build/iOS` to tell linker where to find frameworks.
2. Build phases: drag and drop TWUITests and Swifter frameworks in **Link binaries and frameworks** phase. Frameworks are in `Carthage/Build/iOS`.
3. Info plist file: add `App Transport Security Settings` dictionary and key-value `NSAllowsLocalNetworking` = `true` to allow loading of local resources. 

### Start adding tests
1. Create Configuration class to hold parameters and initial API stubs.
2. Create project specific parameters to be injected into main app.
3. Create API stubs structure.
4. Tip: use template to generate UITests code. Add template to Xcode by running add_ui_tests_templates.sh script (in `Xcode Templates` folder).

### Other information
Server API local responses should be kept at path: `LIBRARY_DIR + "/Developer/CoreSimulator/Devices/" + DEVICE_ID + "/data/Library/Caches/ApiStubs/"`
Tip: have a script to copy stubs to required destination in build phase. Python script example can be found [here](https://github.com/treatwell/twuitests-example).

## Example
Working example project can be found in `Example` folder.

Test:
```swift
final class LoginUITests: UITestCase {
    func testSomething() throws {
        try start(with: Configuration())
        .loginStep.someAction()
        .loginStep.loginPageIsVisible()
    }
}
```
Step:
```swift
final class LoginStep: UITestBase, Step {
    private lazy var loginPage = LoginPage(app: app)

    func tapSomeButton() -> Self {
        loginPage.someButton.tap()
        return self
    }
}
// MARK: - Validation
extension LoginStep {
    func loginPageIsVisible() {
        loginPage.someView.existsAfterDelay()
        loginPage.someButton.existsAfterDelay()
    }
}
```
Page:
```swift
final class LoginPage: UITestBase, Page {
    var someView: XCUIElement {
        return app.otherElements[LoginAccessibilityIndetifiers.View.some] 
    }
    var someButton: XCUIElement {
        return app.buttons[LoginAccessibilityIndetifiers.Button.some]
    }
}
```

## Author Information
Ignas Urbonas - ignas.urbonas@treatwell.com

Marius Kažemėkaitis - marius.kazemekaitis@treatwell.com

## License
The contents of this repository is licensed under the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).


