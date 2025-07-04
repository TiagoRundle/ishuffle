//
//  ChatView.swift
//  iShuffle
//
//  Created by Tiago Rundle on 6/4/23.
//

import SwiftUI

struct Message: Codable, Equatable {
    var text:String
    var color:String
}

struct Feed:Codable, Equatable {

    var messages:[Message]
    
    init(type:String) {
        messages = [Message(text:"This is the beginning of the " + type + " feed...", color: "white")]
    }
    
}

struct ChatView: View {
    
    @EnvironmentObject var model:ViewModel
    
    @Binding var showChat:Bool
    
    @State var message:String = ""
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack (alignment: .leading, spacing: 25) {
                
                HStack {
                    Button() {
                        showChat.toggle()
                        model.unreadMessages = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                    }
                    Spacer()
                    Text("**Game Chat**")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    Spacer()
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                        .padding()
                }
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack (alignment: .leading, spacing: 0) {
                            HStack {
                                Text(model.gameChat.messages[0].text)
                                    .padding(.bottom, 15)
                                    .padding(.leading, 20)
                                    .font(.title3)
                                Spacer()
                            }
                            
                            ForEach(model.gameChat.messages.indices, id: \.self) { index in
                                if index != 0 {
                                    Text(model.gameChat.messages[index].text)
                                        .foregroundColor(Color[model.gameChat.messages[index].color])
                                        .font(.title3)
                                        .padding(.leading, 20)
                                }
                            }
                            .padding(.bottom, 15)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .preferredColorScheme(.dark)
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(model.gameChat.messages.count - 1, anchor: .bottom)
                        }
                    }
                    .onChange(of: model.gameChat.messages.count - 1) { id in
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
                
                HStack {
                    TextField("", text: $message)
                        .placeholder(when: message.isEmpty) {
                            Text("Send a message...").foregroundColor(.gray)
                        }
                        .padding()
                        .frame(height:50)
                        .foregroundColor(.black)
                        .background(Color.white.cornerRadius(10))
                        .font(.body)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    Spacer()
                    
                    Button() {
                        if message != "" {
                            model.gameChat.messages.append(Message(text: model.myPlayer.displayName + ": " + message, color: model.myPlayer.color!))
                            model.updateChat()
                            message = ""
                        }
                    } label: {
                        Image(systemName: "paperplane.fill").foregroundColor(.white)
                            .font(.system(size: 30))
                            .padding(.trailing, 15)
                    }
                }
                .padding(.leading, 15)
                .padding(.bottom, 15)
                
            }
            
        }
        
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
