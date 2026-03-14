//
//  TotalSpentCard.swift
//  ExpenseTracker
//
//  Converted from total_spent_card.dart
//

import SwiftUI

struct TotalSpentCard: View {
    let total: Double
    
    private var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#007AFF") ?? .blue)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Spent")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(formattedTotal)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
    }
}

#Preview {
    TotalSpentCard(total: 1234.56)
        .padding()
        .background(Color(.systemGroupedBackground))
}

