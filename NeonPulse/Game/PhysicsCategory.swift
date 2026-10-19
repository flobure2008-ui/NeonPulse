import Foundation

public struct PhysicsCategory {
    public static let none: UInt32         = 0
    public static let player: UInt32       = 0x1 << 0
    public static let obstacle: UInt32     = 0x1 << 1
    public static let grazeZone: UInt32    = 0x1 << 2
    public static let collectible: UInt32  = 0x1 << 3
}
