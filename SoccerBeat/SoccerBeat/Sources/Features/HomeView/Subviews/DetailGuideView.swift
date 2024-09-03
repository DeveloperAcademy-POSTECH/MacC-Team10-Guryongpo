//
//  DetailGuideView.swift
//  SoccerBeat
//
//  Created by jose Yun on 4/8/24.
//

import SwiftUI

struct DetailGuideView: View {
    let alertTitle: String = "문제가 있으신가요?"
    let requestingAuth: Auth
    let TabViewHealthText = ["Privacy & Security", "Health", "SoccerBeat", "Turn On All"]
    let TabViewLocationText = ["Privacy & Security", "Location Services", "SoccerBeat", "While Using the App"]
    @Binding var isShowingQuestion: Bool
    @State var isShowingBug = false
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0.0) {
                            HStack {
                                Text("단계별 설정 방법")
                                    .font(.matchDetailSubTitle)
                                    .foregroundStyle(.shareViewSubTitleTint)
                                Spacer()
                                
                                Button(action: { isShowingBug.toggle() } ) {
                                    Image(systemName: "ant")
                                        .foregroundStyle(.white)
                                        .font(.mainInfoText)
                                        .padding()
                                }
                                .overlay {
                                    Capsule()
                                        .stroke(lineWidth: 0.8)
                                        .frame(height: 24)
                                }
                                .padding(.horizontal)
                            }
                            .padding()
                        }
                        .font(.custom("SFProDisplay-HeavyItalic", size: 36))
                    }
                }
            }.padding(.top, 48)
                .padding(.horizontal)
            
            TabView {
                let langStr = Locale.current.language.languageCode?.identifier ?? "en"
                ForEach(0..<4) { index in

                    VStack() {
                        Image(requestingAuth == .health ? "Health-\(index)\(langStr)" : "Location-\(index)\(langStr)")
                            .resizable()
                            .scaledToFit()
                            .mask{
                                RoundedRectangle(cornerRadius: 20)
                            }
                        
                        Text(requestingAuth == .health ? "* \(TabViewHealthText[index])" : "* \(TabViewLocationText[index])")
                            .font(.mainInfoText)
                        
                        Spacer()
                            .frame(height: 54)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    isShowingQuestion.toggle()
                } label: {
                    ZStack {
                        Capsule(style: .continuous)
                            .stroke()
                            .foregroundStyle(.brightmint)
                            .frame(width: 74, height: 25)
                        Capsule(style: .continuous)
                            .foregroundStyle(.clear)
                            .frame(width: 74, height: 25)
                        Text("확인")
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
            }
            .alert(
                alertTitle,
                isPresented: $isShowingBug
            ) {
                Button("취소", role: .cancel) {
                    // Handle the acknowledgement.
                    isShowingBug.toggle()
                }
                Button("문의하기") {
                    let url = createEmailUrl(to: "guryongpo23@gmail.com", subject: "", body: "")
                    openURL(urlString: url)
                    // TODO: 로그인 안될 때엔 어떻게 됩니까?
                }
            } message: {
                Text("불편을 드려 죄송합니다. \n\nSoccerBeat의 개발자 계정으로 문의를 주시면 빠른 시일 안에 답변드리겠습니다. ")
            }
        }
    }
    
    func openURL(urlString: String){
        if let url = URL(string: "\(urlString)"){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url)
            }
            else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> String {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let defaultUrl = "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        
        return defaultUrl
    }
}

#Preview {
    DetailGuideView(requestingAuth:.location, isShowingQuestion: .constant(true))
}
