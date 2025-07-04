//
//  iShuffleApp.swift
//  iShuffle
//
//  Created by Tiago Rundle on 2/10/23.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

@main
struct iShuffleApp: App {
    
    @UIApplicationDelegateAdaptor var delegate: FSAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}

class FSAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = FSSceneDelegate.self
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        if (model.game != nil) {
            model.destroyGame()
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously { authResult, error in
        }
        return true
    }
    
}

class FSSceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneDidDisconnect(_ scene: UIScene) {
        if (model.game != nil) {
            model.destroyGame()
        }
    }
}

var model = ViewModel()
