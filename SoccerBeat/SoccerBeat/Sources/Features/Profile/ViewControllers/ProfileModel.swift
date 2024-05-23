//
//  ProfileModel.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/9/23.
//

import CoreTransferable
import Combine
import PhotosUI
import SwiftUI

@MainActor
final class ProfileModel: ObservableObject {

    let healthInteractor: HealthInteractor
    @Published var averageAbility = WorkoutAverageData()
    @Published var maxAbility = WorkoutAverageData()
    @Published var allBadges: [[Bool]] = [[false, false, false, false],
                                          [false, false, false, false],
                                          [false, false, false, false]]
    
    private var cancellables = Set<AnyCancellable>()
    
    init(healthInteractor: HealthInteractor) {
        self.healthInteractor = healthInteractor
        binding()
    }
    
    private func binding() {
        healthInteractor.fetchWorkoutsSuccess.sink { workouts in
            self.calculateAverageAbility(workouts)
            self.caculateMaxAbility(workouts)
            self.calculateBadge(workouts)
        }
        .store(in: &cancellables)
    }
    
    func calculateBadge(_ workouts: [WorkoutData]) {
        for workout in workouts {
            if workout.distance < 0.2 {
            } else if (0.2 <= workout.distance && workout.distance < 0.4) {
                allBadges[0][0] = true
            } else if (0.4 <= workout.distance && workout.distance < 0.6) {
                allBadges[0][1] = true
            } else if (0.6 <= workout.distance && workout.distance < 0.8) {
                allBadges[0][2] = true
            } else {
                allBadges[0][3] = true
            }
            
            if workout.sprint < 1 {
            } else if (1 <= workout.sprint && workout.sprint < 2) {
                
                allBadges[1][0] = true
            } else if (2 <= workout.sprint && workout.sprint < 3) {
                
                allBadges[1][1] = true
            } else if (3 <= workout.sprint && workout.sprint < 4) {
                
                allBadges[1][2] = true
            } else {
                allBadges[1][3] = true
            }
            
            if workout.velocity < 10 {
                1
            } else if (10 <= workout.velocity && workout.velocity < 15) {
                
                allBadges[2][0] = true
            } else if (15 <= workout.velocity && workout.velocity < 20) {
                
                allBadges[2][1] = true
            } else if (20 <= workout.velocity && workout.velocity < 25) {
                
                allBadges[2][2] = true
            } else {
                allBadges[2][3] = true
            }
        }
    }
    
    private func caculateMaxAbility(_ workouts: [WorkoutData]) {
        for workout in workouts {
            maxAbility.maxHeartRate = max(maxAbility.maxHeartRate, workout.maxHeartRate)
            maxAbility.minHeartRate = min(maxAbility.minHeartRate, workout.minHeartRate)
            maxAbility.rangeHeartRate = max(maxAbility.rangeHeartRate, workout.maxHeartRate - workout.minHeartRate)
            maxAbility.totalDistance = max(maxAbility.totalDistance, workout.distance)
            maxAbility.maxPower = max(maxAbility.maxPower, workout.power)
            maxAbility.maxVelocity = max(maxAbility.maxVelocity, workout.velocity)
            maxAbility.sprintCount = max(maxAbility.sprintCount, workout.sprint)
            maxAbility.totalMatchTime = max(maxAbility.totalMatchTime, workout.playtimeSec)
        }
    }
    
    private func calculateAverageAbility(_ workouts: [WorkoutData]) {
        guard !workouts.isEmpty else { return }
        
        for workout in workouts {
            averageAbility.maxHeartRate += workout.maxHeartRate
            averageAbility.minHeartRate += workout.minHeartRate
            averageAbility.rangeHeartRate += workout.maxHeartRate - workout.minHeartRate
            averageAbility.totalDistance += workout.distance
            averageAbility.maxPower += workout.power
            averageAbility.maxVelocity += workout.velocity
            averageAbility.sprintCount += workout.sprint
            averageAbility.totalMatchTime += workout.playtimeSec
        }
        
        // Calculating average value..
        let workoutCount = workouts.count
        averageAbility.maxHeartRate /= workoutCount
        averageAbility.minHeartRate /= workoutCount
        averageAbility.rangeHeartRate /= workoutCount
        averageAbility.totalDistance /= Double(workoutCount)
        averageAbility.maxPower /= Double(workoutCount)
        averageAbility.maxVelocity /= Double(workoutCount)
        averageAbility.sprintCount /= workoutCount
        averageAbility.totalMatchTime /= workoutCount
    }
    
    // MARK: - Profile Image
    enum ImageState {
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)
    }
    
    enum TransferError: Error {
        case importFailed
    }
    
    struct ProfileImage: Transferable {
        let image: Image
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                print("data transported")
            #if canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                // MARK: save User Defaults Image
                let data = uiImage.jpegData(compressionQuality: 0.1)
                UserDefaults.standard.set(data, forKey: "userImage")
                
                return ProfileImage(image: image)
            #endif
            }
        }
    }
    
    @Published private(set) var imageState = ImageState.empty
    
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.imageState = .success(profileImage.image)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
