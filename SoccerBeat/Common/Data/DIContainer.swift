//
//  DIContainer.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/10/24.
//

import Foundation

// TODO: - MOVE DI Container
final class DIContianer {
    static private(set) var matrics: MatricsIndicator?
    
    static func makeWorkoutManager() -> WorkoutManager {
        if let matrics = self.matrics {
            return WorkoutManager(matrics: matrics)
        } else {
            let matrics = makeMatricsIndicator()
            self.matrics = matrics
            return WorkoutManager(matrics: matrics)
        }
    }
    
    static func makeMatricsIndicator() -> MatricsIndicator {
        if let matrics = self.matrics {
            return matrics
        }
        let matrics = MatricsIndicator()
        self.matrics = matrics
        return matrics
    }
}
