//
//  DataConverter.swift
//  SoccerBeat
//
//  Created by daaan on 11/20/23.
//

import Foundation

final class DataConverter {
    // TODO: - 매개 변수가 4개가 넘어가면 별도의 타입을 고려
    static func dataConverter(totalDistance: Double, maxHeartRate: Int, maxVelocity: Double, maxAcceleration: Double, sprintCount: Int, minHeartRate: Int, rangeHeartRate: Int, totalMatchTime: Int) -> [String: Double] {
        var levels: [String: Double] = [:]
        
        if totalDistance <= 1.0 {
            levels["totalDistance"] = 1.0
        } else if totalDistance > 1.0 && totalDistance <= 2.0 {
            levels["totalDistance"] = 2.0
        } else if totalDistance > 2.0 && totalDistance <= 3.0 {
            levels["totalDistance"] = 3.0
        } else if totalDistance > 3.0 && totalDistance <= 4.0 {
            levels["totalDistance"] = 4.0
        } else if totalDistance > 4.0 {
            levels["totalDistance"] = 5.0
        }
        
        if maxHeartRate <= 165 {
            levels["maxHeartRate"] = 1.0
        } else if maxHeartRate > 165 && maxHeartRate <= 175 {
            levels["maxHeartRate"] = 2.0
        } else if maxHeartRate > 175 && maxHeartRate <= 185 {
            levels["maxHeartRate"] = 3.0
        } else if maxHeartRate > 185 && maxHeartRate <= 195 {
            levels["maxHeartRate"] = 4.0
        } else if maxHeartRate > 195 {
            levels["maxHeartRate"] = 5.0
        }
        
        if maxVelocity <= 15 {
            levels["maxVelocity"] = 1.0
        } else if maxVelocity > 15 && maxVelocity <= 18 {
            levels["maxVelocity"] = 2.0
        } else if maxVelocity > 18 && maxVelocity <= 21 {
            levels["maxVelocity"] = 3.0
        } else if maxVelocity > 21 && maxVelocity <= 24 {
            levels["maxVelocity"] = 4.0
        } else if maxVelocity > 24 {
            levels["maxVelocity"] = 5.0
        }
        
        if maxAcceleration <= 2.0 {
            levels["maxAcceleration"] = 1.0
        } else if maxAcceleration > 2.0 && maxAcceleration <= 3.0 {
            levels["maxAcceleration"] = 2.0
        } else if maxAcceleration > 3.0 && maxAcceleration <= 4.0 {
            levels["maxAcceleration"] = 3.0
        } else if maxAcceleration > 4.0 && maxAcceleration <= 5.0 {
            levels["maxAcceleration"] = 4.0
        } else if maxAcceleration > 5.0 {
            levels["maxAcceleration"] = 5.0
        }
        
        if sprintCount <= 1 {
            levels["sprintCount"] = 1.0
        } else if sprintCount > 1 && sprintCount <= 2 {
            levels["sprintCount"] = 2.0
        } else if sprintCount > 2 && sprintCount <= 3 {
            levels["sprintCount"] = 3.0
        } else if sprintCount > 3 && sprintCount <= 4 {
            levels["sprintCount"] = 4.0
        } else if sprintCount > 4 {
            levels["sprintCount"] = 5.0
        }
        
        if minHeartRate <= 50 {
            levels["minHeartRate"] = 5.0
        } else if minHeartRate > 50 && minHeartRate <= 60 {
            levels["minHeartRate"] = 4.0
        } else if minHeartRate > 60 && minHeartRate <= 70 {
            levels["minHeartRate"] = 3.0
        } else if minHeartRate > 70 && minHeartRate <= 80 {
            levels["minHeartRate"] = 2.0
        } else if minHeartRate > 80 {
            levels["minHeartRate"] = 1.0
        }
        
        if rangeHeartRate <= 65 {
            levels["rangeHeartRate"] = 1.0
        } else if rangeHeartRate > 65 && rangeHeartRate <= 75 {
            levels["rangeHeartRate"] = 2.0
        } else if rangeHeartRate > 75 && rangeHeartRate <= 85 {
            levels["rangeHeartRate"] = 3.0
        } else if rangeHeartRate > 85 && rangeHeartRate <= 95 {
            levels["rangeHeartRate"] = 4.0
        } else if rangeHeartRate > 95 {
            levels["rangeHeartRate"] = 5.0
        }
        
        if totalMatchTime <= 40 * 60 {
            levels["totalMatchTime"] = 1.0
        } else if totalMatchTime > 40 * 60 && totalMatchTime <= 50 * 60 {
            levels["totalMatchTime"] = 2.0
        } else if totalMatchTime > 50 * 60 && totalMatchTime <= 60 * 60 {
            levels["totalMatchTime"] = 3.0
        } else if totalMatchTime > 60 * 60 && totalMatchTime <= 70 * 60 {
            levels["totalMatchTime"] = 4.0
        } else if totalMatchTime > 70 * 60 {
            levels["totalMatchTime"] = 5.0
        }
        
        return levels
    }
}
