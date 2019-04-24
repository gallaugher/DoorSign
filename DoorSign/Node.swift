//
//  Node.swift
//  DoorSign
//
//  Created by John Gallaugher on 4/24/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
// Node is a generic class that should work for all types
class Node<T> {
    var value: T
    weak var parent: Node?
    var children: [Node] = []
    
    init(value: T) {
        self.value = value
    }
    
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
}

extension Node where T: Equatable {
    func search(value: T) -> Node? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        return nil
    }
}
