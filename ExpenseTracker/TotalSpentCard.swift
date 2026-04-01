//
//  TotalSpentCard.swift
//  ExpenseTracker
//
//  Card component showing total spent amount
//  Author Zaki Mohammed 101507934
//  Edited by: Benjamin Antolin 101522465 worked on UI
//  Edited by: Uzma Shaikh 101504303 worked on UI components like adding colour schemes 
import SwiftUI

struct TotalSpentCard: View {
    let total: Double
    
    private var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Spent This Month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(formattedTotal)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "#007AFF")?.opacity(0.1) ?? Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 16) {
        TotalSpentCard(total: 1234.56)
        TotalSpentCard(total: 0.0)
        TotalSpentCard(total: 999999.99)
    }
    .padding()
}
