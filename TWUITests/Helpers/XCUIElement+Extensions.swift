//  Copyright 2019 Hotspring Ventures Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import XCTest

public extension XCUIElement {
    func existsAfterDelay() {
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: self)
        XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertTrue(exists, "Element \(identifier) should exists after delay")
    }

    func exists() {
        XCTAssertTrue(exists, "Element \(identifier) should exists")
    }

    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }

        self.tap()

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)

        self.typeText(deleteString)
        self.typeText(text)
    }

    /**
     Scroll Up in scroll view until XCUIElement is found or until maximum number of swipes is reached
     Parameters:
     - element: XCUIElement in scroll view to be found
     - maxSwipes: maximum swipe actions
     Return:
       true if element was found while swiping
     */
    func swipeUp(to element: XCUIElement, maxSwipes: UInt = 5) -> Bool {
        find(element: element, maxActions: maxSwipes, action: self.swipeUp() )
    }

    /**
     Scroll Left in scroll view until XCUIElement is found or until maximum number of swipes is reached
     Parameters:
     - element: XCUIElement in scroll view to be found
     - maxSwipes: maximum swipe actions
     Return:
       true if element was found while swiping
     */
    func swipeLeft(to element: XCUIElement, maxSwipes: UInt = 5) -> Bool {
        find(element: element, maxActions: maxSwipes, action: self.swipeLeft() )
    }

    /**
     Scroll Right in scroll view until XCUIElement is found or until maximum number of swipes is reached
     Parameters:
     - element: XCUIElement in scroll view to be found
     - maxSwipes: maximum swipe actions
     Return:
       true if element was found while swiping
     */
    func swipeRight(to element: XCUIElement, maxSwipes: UInt = 5) -> Bool {
        find(element: element, maxActions: maxSwipes, action: self.swipeRight() )
    }

    /**
     Scroll Down in scroll view until XCUIElement is found or until maximum number of swipes is reached
     Parameters:
     - element: XCUIElement in scroll view to be found
     - maxSwipes: maximum swipe actions
     Return:
       true if element was found while swiping
     */
    func swipeDown(to element: XCUIElement, maxSwipes: UInt = 5) -> Bool {
        find(element: element, maxActions: maxSwipes, action: self.swipeDown() )
    }

    func find(element: XCUIElement, maxActions: UInt, action: @autoclosure () -> Void) -> Bool {
        for _ in 0..<maxActions {
            if element.exists && element.isHittable {
                return true
            } else {
                action()
            }
        }
        return false
    }
}

public extension XCUIElement {
    func wait(forExpectationWithFormat format: String) -> XCTWaiter.Result {
        return XCTWaiter().wait(for: [
            XCTNSPredicateExpectation(predicate: NSPredicate(format: format), object: self)
            ], timeout: 5)
    }
}
