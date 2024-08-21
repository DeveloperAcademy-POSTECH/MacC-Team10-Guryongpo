import SwiftUI
import Photos

struct ShareView: View {
    @Binding var isBackButtonHidden: Bool
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var healthInteractor: HealthInteractor
    @State var degree: Double = 0
    @State private var showingAlert: Bool = false
    
    private var userName: String {
        return UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                Image(.backgroundPattern)
                Image(.flameEffect)
            }
            .frame(maxHeight: UIScreen.screenHeight)
            VStack {
                Spacer()
                    .frame(height: 50)
                HStack(alignment: .bottom) {
                    CardFront(degree: $degree, width: 100, height: 140)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("# Soccer Beat")
                            .floatingCapsuleStyle()
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Text("SBeat Card")
                            .font(.shareViewSubTitle)
                            .foregroundStyle(.shareViewSubTitleTint)
                        VStack(alignment: .leading, spacing: -10) {
                            HStack {
                                Text(userName)
                                    .highlighter(activity: .heartrate, isDefault: false)
                                    .foregroundStyle(.shareViewTitleTint)
                            }
                        }
                        .font(.shareViewTitle)
                    }
                    .padding(.leading)
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                    .frame(height: 30)
                
                currentBadge
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(isBackButtonHidden)
        .toolbar {
            Button {
                isBackButtonHidden = true
                DispatchQueue.main.async {
                            share()
                        }
                DispatchQueue.main.async {
                    isBackButtonHidden = false
                        }
            } label: {
                Text("공유하기")
                    .foregroundStyle(.shareViewTitleTint)
                    .opacity(isBackButtonHidden ? 0 : 1)
            }
        }
    }
    private func floatingBadgeInfo(at sort: Int) -> some View {
        var message: String {
            switch sort {
            case 0:
                return "뛴 거리에 따라 획득하는 뱃지입니다."
            case 1:
                return "스프린트 횟수에 따라 획득하는 뱃지입니다."
            default: // 2
                return "최고 속도에 따라 획득하는 뱃지입니다."
            }
        }
        return Text(message)
            .padding(.horizontal, 8)
            .floatingCapsuleStyle()
    }
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

extension ShareView {
    @ViewBuilder
    private var currentBadge: some View {
        VStack(alignment: .leading, spacing: 31) {
            ForEach(0..<profileModel.allBadges.count) { sortIndex in
                VStack(alignment: .leading, spacing: 10) {
                    floatingBadgeInfo(at: sortIndex)
                    HStack {
                        ForEach(0..<profileModel.allBadges[sortIndex].count, id: \.self) { levelIndex in
                            let isOpened = profileModel.allBadges[sortIndex][levelIndex]
                            
                            TrophyView(sort: sortIndex, level: levelIndex, isOpened: isOpened)
                                .frame(width: 74, height: 82)
                        }
                    }
                }
            }
        }
    }
    
    private func share() {
        guard let screenshot = ShareView.screenshot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true)
    }
}

extension ShareView {
    static func screenshot() -> UIImage? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return nil }
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { context in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }
}

#Preview {
    ShareView(isBackButtonHidden: .constant(false))
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
}
