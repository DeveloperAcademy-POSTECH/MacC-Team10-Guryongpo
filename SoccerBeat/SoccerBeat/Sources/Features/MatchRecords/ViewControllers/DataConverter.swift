//
//  DataConverter.swift
//  SoccerBeat
//
//  Created by daaan on 11/20/23.
//

import Foundation

final class DataConverter {
    // TODO: - 매개 변수가 4개가 넘어가면 별도의 타입을 고려
    static private func toLevelDictionary(totalDistance: Double,
                                      maxHeartRate: Int,
                                      maxVelocity: Double,
                                      sprintCount: Int,
                                      minHeartRate: Int,
                                      rangeHeartRate: Int,
                                      totalMatchTime: Int,
                                      unavailable: Set<WorkoutMetric>) -> [String: Double] {
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
        
        // Missing measurements must not become minimum levels (or a maximum level for zero minimum HR).
        if unavailable.contains(.distance) || !totalDistance.isFinite || totalDistance < 0 {
            levels["totalDistance"] = nil
        }
        if unavailable.contains(.maxSpeed) || !maxVelocity.isFinite || maxVelocity < 0 {
            levels["maxVelocity"] = nil
        }
        if unavailable.contains(.sprint) || sprintCount < 0 { levels["sprintCount"] = nil }
        if unavailable.contains(.minHeartRate) || minHeartRate <= 0 { levels["minHeartRate"] = nil }
        if unavailable.contains(.maxHeartRate) || maxHeartRate <= 0 { levels["maxHeartRate"] = nil }
        if levels["minHeartRate"] == nil || levels["maxHeartRate"] == nil || maxHeartRate < minHeartRate {
            levels["rangeHeartRate"] = nil
        }
        if totalMatchTime <= 0 { levels["totalMatchTime"] = nil }
        return levels
    }
    
    static func toLevels(_ workout: WorkoutData) -> [Double] {
        let recentLevel = toLevelDictionary(totalDistance: workout.distance,
                                       maxHeartRate: workout.maxHeartRate,
                                       maxVelocity: workout.velocity,
                                       sprintCount: workout.sprint,
                                       minHeartRate: workout.minHeartRate,
                                       rangeHeartRate: workout.maxHeartRate-workout.minHeartRate,
                                       totalMatchTime: workout.playtimeSec,
                                       unavailable: workout.unavailableMetrics)
        
        
        return Amplify(recentLevel)
    }
    
    static func toLevels(_ averageWorkout: WorkoutAverageData) -> [Double] {
        let averageLevel = toLevelDictionary(totalDistance: averageWorkout.totalDistance,
                                             maxHeartRate: averageWorkout.maxHeartRate,
                                             maxVelocity: averageWorkout.maxVelocity,
                                             sprintCount: averageWorkout.sprintCount,
                                             minHeartRate: averageWorkout.minHeartRate,
                                             rangeHeartRate: averageWorkout.maxHeartRate-averageWorkout.minHeartRate,
                                             totalMatchTime: averageWorkout.totalMatchTime,
                                             unavailable: averageWorkout.unavailableMetrics)
        return Amplify(averageLevel)
    }
    
    static private func Amplify(_ level: [String: Double]) -> [Double] {
        // Temporary partial-data policy: redistribute each axis's weights among known inputs.
        // If an entire axis is unavailable, use the mean of the other observed input levels.
        let fallback = level.isEmpty ? 0 : level.values.reduce(0, +) / Double(level.count)
        func score(_ inputs: [(String, Double)]) -> Double {
            var weighted = 0.0
            var weight = 0.0
            for (key, contribution) in inputs {
                if let value = level[key] {
                    weighted += value * contribution
                    weight += contribution
                }
            }
            // The previous formula used a total axis weight of 0.5, amplified by 1.5.
            return (weight > 0 ? weighted / weight : fallback) * 0.75
        }
        return [
            score([("totalDistance", 0.15), ("maxHeartRate", 0.35)]),
            score([("maxVelocity", 0.3)]),
            score([("maxVelocity", 0.25), ("sprintCount", 0.125), ("maxHeartRate", 0.125)]),
            score([("minHeartRate", 0.1)]),
            score([("totalDistance", 0.15), ("rangeHeartRate", 0.15), ("totalMatchTime", 0.2)]),
            score([("totalDistance", 0.3), ("sprintCount", 0.1), ("maxHeartRate", 0.1)])
        ]
    }
}
