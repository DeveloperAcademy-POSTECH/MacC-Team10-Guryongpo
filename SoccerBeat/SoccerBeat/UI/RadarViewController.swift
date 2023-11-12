//
//  RadarViewController.swift
//  SoccerBeat
//
//  Created by daaan on 11/12/23.
//

import SwiftUI
import UIKit

class RadarViewController: UIViewController, TKRadarChartDataSource, TKRadarChartDelegate, UITableViewDelegate {
    var radarValue: [Double]
    
    init(radarValue: [Double]) {
        self.radarValue = radarValue
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
            return "최고 속도"
        case 1:
            return "평균 속도"
        case 2:
            return "평균\n가속도"
        case 3:
            return "어질리티"
        case 4:
            return "뛴 거리"
        default:
            return "스프린트\n횟수"
        }
    }
    
    func valueOfSectionForRadarChart(withRow row: Int, section: Int) -> CGFloat {
        return radarValue[row]
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
            return UIColor.white.withAlphaComponent(0.9)
        } else {
            return UIColor.clear
        }
    }
    
    func colorOfSectionBorderForRadarChart(_ radarChart: TKRadarChart, section: Int) -> UIColor {
        if section == 0 {
            return UIColor(red:1,  green:0.867,  blue:0.012, alpha:1)
        } else {
            return UIColor(red:0,  green:0.788,  blue:0.543, alpha:1)
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
