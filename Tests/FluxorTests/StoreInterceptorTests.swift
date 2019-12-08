//
//  StoreInterceptorTests.swift
//  FluxorTests
//
//  Created by Morten Bjerg Gregersen on 08/12/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

import XCTest
@testable import Fluxor

class StoreInterceptorTests: XCTestCase {
    func testDispatchedActionsAndStates() {
        // Given
        let storeInterceptor = TestStoreInterceptor<TestState>()
        let action = TestAction()
        let store = Store(initialState: TestState())
        store.register(interceptor: storeInterceptor)
        // When
        store.dispatch(action: action)
        // Then
        let dispatchedAction = storeInterceptor.dispatchedActionsAndStates[0].action as! TestAction
        XCTAssertEqual(dispatchedAction, action)
        let newState = storeInterceptor.dispatchedActionsAndStates[0].newState
        XCTAssertEqual(newState, store.state)
    }
}

fileprivate struct TestState: Encodable, Equatable {}

fileprivate struct TestAction: Action, Equatable {
    let id = UUID()
}
