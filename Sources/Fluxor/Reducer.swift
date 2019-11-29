//
//  Reducer.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 31/10/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

public struct Reducer<State> {
    public let reduce: (State, Action) -> State

    public init(reduce: @escaping (State, Action) -> State) {
        self.reduce = reduce
    }
}
