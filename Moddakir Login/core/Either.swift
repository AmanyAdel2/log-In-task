//
//  Either.swift
//  Moddakir Login
//
//  Created by Macos on 17/10/2026.
//

import Foundation
enum Either<Left, Right> {
    case left(Left)
    case right(Right)

    var right: Right? {
        if case .right(let value) = self { return value }
        return nil
    }

    var left: Left? {
        if case .left(let value) = self { return value }
        return nil
    }
}
