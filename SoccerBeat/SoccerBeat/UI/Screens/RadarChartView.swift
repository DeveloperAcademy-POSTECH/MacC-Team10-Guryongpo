//
//  RadarChartView.swift
//  SoccerBeat
//
//  Created by Gucci on 3/24/24.
//

import SwiftUI

struct RadarChartView: View {
    @EnvironmentObject var profileModel: ProfileModel
    let workout: WorkoutData?
    let width: Double
    let height: Double
    
    init(workout: WorkoutData? = nil, width: Double, height: Double) {
        self.workout = workout
        self.width = width
        self.height = height 
    }
    
    var body: some View {
        
        let recentLevel = DataConverter.toLevels(workout ?? .blankExample)
        let averageLevel = DataConverter.toLevels(profileModel.averageAbility)
        
        /*
        // 방구석 리뷰룸 시연을 위해 작성한 코드
        let tripleAverage = average.map { min($0 * 3, 5.0) }
        let tripleRecent = recent.map { min($0 * 3, 5.0) }
        */
        
        ViewControllerContainer(RadarViewController(radarAverageValue: averageLevel,
                                                    radarAtypicalValue: recentLevel))
        .frame(width: width, height: height)
    }
}

#Preview {
    @StateObject var profileModel = ProfileModel(healthInteractor: HealthInteractor.shared)
    
    return RadarChartView(workout: .example, width: 100, height: 100)
            .environmentObject(profileModel)
}
