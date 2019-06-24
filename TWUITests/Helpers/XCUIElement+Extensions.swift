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
     Scroll up in scroll view until XCUIElement is found or maximum swipe
     Parameters:
     - element: XCUIElement in scroll view to be found
     - maxSwipes: maximum swipe up actions
     Return: true if element was found while swiping up
     */
    func swipeUp(to element: XCUIElement, maxSwipes: UInt = 5) -> Bool {
        for _ in 0..<maxSwipes {
            if element.exists {
                return true
            } else {
                swipeUp()
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
