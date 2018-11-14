//
//  Point.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

struct Point {
    let x: Int
    let y: Int
}
extension Point {
    static func + (a: Point, b: Point) -> Point { return Point(x: a.x + b.x, y: a.y + b.y) }
    static func - (a: Point, b: Point) -> Point { return Point(x: a.x - b.x, y: a.y - b.y) }
    static func * (a: Point, b: Int) -> Point { return Point(x: a.x * b, y: a.y * b) }
    static func / (a: Point, b: Int) -> Point { return Point(x: a.x / b, y: a.y / b) }
    static func % (a: Point, b: Int) -> Point { return Point(x: a.x % b, y: a.y % b) }
}
extension Point: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
extension Point: CustomStringConvertible {
    var description: String {
        return "(\(x),\(y))"
    }
}

struct Size {
    let width: Int
    let height: Int
}
extension Size {
    static func + (a: Size, b: Size) -> Size { return Size(width: a.width + b.width, height: a.height + b.height) }
    static func - (a: Size, b: Size) -> Size { return Size(width: a.width - b.width, height: a.height - b.height) }
    static func * (a: Size, b: Int) -> Size { return Size(width: a.width * b, height: a.height * b) }
    static func / (a: Size, b: Int) -> Size { return Size(width: a.width / b, height: a.height / b) }
    static func % (a: Size, b: Int) -> Size { return Size(width: a.width % b, height: a.height % b) }
}
extension Size {
    init(point: Point) { self.init(width: point.x, height: point.y) }

    func forEach(_ f: (Point) -> Void) {
        for y in 0 ..< height {
            for x in 0 ..< width {
                f(Point(x: x, y: y))
            }
        }
    }
}
extension Size: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
extension Size: CustomStringConvertible {
    var description: String {
        return "(\(width)×\(height))"
    }
}

struct Rect {
    let origin: Point
    let size: Size
}

extension Rect {
    init(x: Int, y: Int, width: Int, height: Int) {
        self.init(origin: Point(x: x, y: y), size: Size(width: width, height: height))
    }

    @inlinable
    var x: Int { return origin.x }
    @inlinable
    var y: Int { return origin.y }
    @inlinable
    var width: Int { return size.width }
    @inlinable
    var height: Int { return size.height }

    func contains(point p: Point) -> Bool {
        return 0 < width && 0 < height
          && x <= p.x && p.x < x + width
          && y <= p.y && p.y < y + height
    }
    func intersects(rect r: Rect) -> Bool {
        return 0 < r.width && 0 < r.height && 0 < width && 0 < height
          && r.x < x + width && x < r.x + r.width
          && r.y < y + height && y < r.y + r.height
    }
    func forEach(_ f: (Point) -> Void) {
        size.forEach { f($0 + origin) }
    }
}
extension Rect: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(origin)
        hasher.combine(size)
    }
}
extension Rect: CustomStringConvertible {
    var description: String {
        return "(\(origin),\(size))"
    }
}
