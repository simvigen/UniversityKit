//
//  SceneDelegate.swift
//  UniversityKit
//
//  Created by Vigen Simonyan on 13.06.26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private var appFlow: AppFlowCoordinator?
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let coordinator = AppFlowCoordinator(dependencies: AppDependencies())
    appFlow = coordinator
    
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = coordinator.start()
    self.window = window
    window.makeKeyAndVisible()
  }
}

