//
//  Reducer.swift
//  Fluxor
//
//  Created by Morten Bjerg Gregersen on 31/10/2019.
//  Copyright © 2019 MoGee. All rights reserved.
//

public struct Reducer<S, A> {
    let reduce: (S, A) -> S

    public init(reduce: @escaping (S, A) -> S) {
        self.reduce = reduce
    }
}
