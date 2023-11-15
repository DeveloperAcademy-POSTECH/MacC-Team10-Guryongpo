//
//  RadarViewController.swift
//  SoccerBeat
//
//  Created by daaan on 11/12/23.
//

import SwiftUI
import UIKit

// To attatch radar chart
// call RadarViewController through ViewControllerContainer.
// As ViewControllerContainer(RadarViewController(radarValue: [Double])),
// radarValue should be [최고 속도, 평균 속도, 평균 가속도, 어질리티, 뛴 거리, 스프린트 횟수].
// Call ViewControllerContainer with modifier fixedSize(), frame(width, height)

class RadarViewController: UIViewController, TKRadarChartDataSource, TKRadarChartDelegate, UITableViewDelegate {
    var radarAverageValue: [Double]
    var radarAtypicalValue: [Double]
    
    init(radarAverageValue: [Double], radarAtypicalValue: [Double]) {
        self.radarAverageValue = radarAverageValue
        self.radarAtypicalValue = radarAtypicalValue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let w = view.bounds.width
        let chart = TKRadarChart(frame: CGRect(x: 0, y: 0, width: w, height: w))
        chart.configuration.radius = w / 3
        chart.dataSource = self
        chart.delegate = self
        chart.center = view.center
        chart.reloadData()
        view.addSubview(chart)
    }
    
    func numberOfStepForRadarChart(_ radarChart: TKRadarChart) -> Int {
        return 5
    }
    func numberOfRowForRadarChart(_ radarChart: TKRadarChart) -> Int {
        return 6
    }
    func numberOfSectionForRadarChart(_ radarChart: TKRadarChart) -> Int {
        return 2
    }
    
    func titleOfRowForRadarChart(_ radarChart: TKRadarChart, row: Int) -> String {
        switch row {
        case 0:
            return "민첩성\n7"
        case 1:
            return "적극성\n7.5"
        case 2:
            return "잠재력\n7.2"
        case 3:
            return "정신력\n4.5"
        case 4:
            return "지구력\n5.4"
        default:
            return "폭발력\n7"
        }
    }
    
    func valueOfSectionForRadarChart(withRow row: Int, section: Int) -> CGFloat {
        if section == 0 {
            return radarAverageValue[row]
        } else {
            return radarAtypicalValue[row]
        }
    }
    
    // Color of the graph grid.
    func colorOfLineForRadarChart(_ radarChart: TKRadarChart) -> UIColor {
        return UIColor.white
    }
    
    // Color of entire inner area.
    func colorOfFillStepForRadarChart(_ radarChart: TKRadarChart, step: Int) -> UIColor {
        return UIColor.white.withAlphaComponent(0.2)
    }
    
    // Color of inside area of the graph.
    func colorOfSectionFillForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor {
        if section == 0 {
            return UIColor(red:0.282,  green:1,  blue:1, alpha:0.5)
        } else {
            return UIColor.clear
        }
    }
    
    func colorOfSectionBorderForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor {
        if section == 0 {
            return UIColor(red:0,  green:1,  blue:0.878, alpha:1)
        } else {
            return UIColor(red:1,  green:0,  blue:0.478, alpha:0.7)
        }
    }
    
    func fontOfTitleForRadarChart(_ radarChart: TKRadarChart) -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
}

struct ViewControllerContainer: UIViewControllerRepresentable {
    let content: UIViewController
    
    init(_ content: UIViewController) {
        self.content = content
    }
        
    func makeUIViewController(context: Context) -> UIViewController {
        let size = content.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        content.preferredContentSize = size
        return content
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
