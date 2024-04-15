import SwiftUI
import Photos

struct ShareView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var healthInteractor: HealthInteractor
    @State var degree: Double = 0
    @State private var showingAlert: Bool = false
    
    private var userName: String {
        return UserDefaults.standard.string(forKey: "userName") ?? "닉네임"
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("BackgroundPattern")
                .frame(maxHeight: UIScreen.screenHeight)
            Image("FlameEffect")
                .frame(maxHeight: UIScreen.screenHeight)
            VStack {
                Spacer()
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
        .toolbar {
            Button {
                share()
            } label: {
                Text("공유하기")
                    .foregroundStyle(.shareViewTitleTint)
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
    static let screenHeight = UIScreen.main.bounds.size.width
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
}

extension ShareView {
    func screenShot() {
        let screenshot = body.takeScreenshot(origin: UIScreen.main.bounds.origin, size: UIScreen.main.bounds.size)
        UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
        
        PHPhotoLibrary.requestAuthorization( { status in
            switch status {
            case .authorized:
                showingAlert = true
            case .denied:
                break
            case .restricted, .notDetermined:
                break
            default:
                break
            }
        })
    }
    
    func share() {
        let screenshot = body.takeScreenshot(origin: UIScreen.main.bounds.origin, size: UIScreen.main.bounds.size)
        let activityViewController = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true)
    }
}

extension UIView {
    var screenShot: UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.screenShot
    }
}

#Preview {
    ShareView()
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
}
