//
//  FilterChip.swift
//  GitPulse
//

import SwiftUI

struct FilterChip: View {
    let title: String
    var isSelected = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : GPColor.subtitle)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? GPColor.primary : GPColor.elevated)
                )
                .overlay(
                    Capsule().strokeBorder(isSelected ? .clear : GPColor.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(GPStyle.spring, value: isSelected)
    }
}
