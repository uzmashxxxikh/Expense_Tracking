//
//  Color+Hex.swift
//  ExpenseTracker
//
//  Color utilities for hex conversion
//

import SwiftUI

extension Color {
    /// Initialize Color from hex string
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    var toHex: String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

// MARK: - Predefined Colors
extension Color {
    static let expenseRed = Color(hex: "#FF3B30") ?? .red
    static let categoryBlue = Color(hex: "#007AFF") ?? .blue
    static let categoryGreen = Color(hex: "#34C759") ?? .green
    static let categoryOrange = Color(hex: "#FF9500") ?? .orange
    static let categoryPurple = Color(hex: "#AF52DE") ?? .purple
    static let categoryTeal = Color(hex: "#30B0C7") ?? .teal
}