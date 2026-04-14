//
//  PermissionRequiredView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 4/2/26.
//

import SwiftUI

struct PermissionRequiredView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.yellow)

                Text("권한 필요")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    permissionRow(
                        icon: "heart.fill",
                        label: "건강",
                        isGranted: workoutManager.hasHealthAuthorization()
                    )
                    permissionRow(
                        icon: "location.fill",
                        label: "위치",
                        isGranted: workoutManager.hasLocationAuthorization()
                    )
                }
                .padding(.vertical, 4)

                Text("iPhone 설정에서\n권한을 허용해주세요")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("설정 > 개인정보 보호\n> 건강/위치 > SoccerBeat")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
    }

    private func permissionRow(icon: String, label: String, isGranted: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(isGranted ? .green : .red)
                .frame(width: 20)
            Text(label)
                .font(.caption)
            Spacer()
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .red)
                .font(.caption)
        }
    }
}

#Preview {
    PermissionRequiredView()
        .environmentObject(DIContianer.makeWorkoutManager())
}
