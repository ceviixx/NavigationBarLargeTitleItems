//
//  NavigationBarLargeTitleItems.swift
//  umami
//
//  Created by ceviixx on 26.04.25.
//

import SwiftUI

public extension View {
    
    func navigationBarLargeTitleItems<L>(trailing: L) -> some View where L : View {
        overlay(NavigationBarLargeTitleItems(trailing: trailing)
            .frame(width: 0, height: 0))
    }
    
}

fileprivate struct NavigationBarLargeTitleItems<L: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = Wrapper

    private let trailingItems: L

    init(trailing: L) {
        self.trailingItems = trailing
    }

    func makeUIViewController(context: Context) -> Wrapper {
        Wrapper(representable: self)
    }

    func updateUIViewController(_ uiViewController: Wrapper, context: Context) {
        // Optionally forward dynamic updates here
    }

    class Wrapper: UIViewController, UINavigationControllerDelegate {
        private var representable: NavigationBarLargeTitleItems?
        private var controllerVariable: UIHostingController<L>?
        private var originalDelegate: UINavigationControllerDelegate?
        private var gestureObserverAdded = false

        init(representable: NavigationBarLargeTitleItems) {
            self.representable = representable
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let representable = self.representable else { return }
            guard let navigationBar = self.navigationController?.navigationBar else { return }
            guard let UINavigationBarLargeTitleView = NSClassFromString("_UINavigationBarLargeTitleView") else { return }

            // Add trailing items
            navigationBar.subviews.forEach { subview in
                if subview.isKind(of: UINavigationBarLargeTitleView.self) {
                    let controller = UIHostingController(rootView: representable.trailingItems)
                    controller.view.translatesAutoresizingMaskIntoConstraints = false
                    controller.view.backgroundColor = .clear
                    controller.view.tag = 1994

                    self.controllerVariable = controller
                    subview.addSubview(controller.view)

                    NSLayoutConstraint.activate([
                        controller.view.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: -10),
                        controller.view.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: -20)
                    ])
                }
            }

            // Set initial visibility
            updateVisibility(true)

            // Set delegate to observe push/pop
            if let navController = navigationController {
                originalDelegate = navController.delegate
                navController.delegate = self

                // Hook into pop gesture
                if let gesture = navController.interactivePopGestureRecognizer, !gestureObserverAdded {
                    gesture.addTarget(self, action: #selector(handlePopGesture(_:)))
                    gestureObserverAdded = true
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if let coordinator = self.transitionCoordinator {
                // Start custom animation during the transition
                coordinator.animate(alongsideTransition: { context in
                    UIView.animate(
                        withDuration: coordinator.transitionDuration / 3.0,
                        delay: 0,
                        options: [.curveEaseInOut],
                        animations: {
                            self.controllerVariable?.view.alpha = 0
                        },
                        completion: nil
                    )
                }, completion: nil)
            } else {
                updateVisibility(false)
            }
        }

        func updateVisibility(_ visible: Bool) {
            UIView.animate(withDuration: 0.25) {
                self.controllerVariable?.view.alpha = visible ? 1 : 0
            }
        }
        
        // MARK: - UINavigationControllerDelegate

        func navigationController(
            _ navigationController: UINavigationController,
            didShow viewController: UIViewController,
            animated: Bool
        ) {
            if viewController === self {
                updateVisibility(true)
            }
        }

        // MARK: - Handle Swipe Back Gesture

        @objc private func handlePopGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let translation = gesture.translation(in: view)
            let progress = min(max(translation.x / view.bounds.width, 0), 1)

            self.controllerVariable?.view.alpha = progress
        }

        // MARK: - Cleanup

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            // Remove gesture target
            if let gesture = navigationController?.interactivePopGestureRecognizer, gestureObserverAdded {
                gesture.removeTarget(self, action: #selector(handlePopGesture(_:)))
                gestureObserverAdded = false
            }

            // Reset delegate (only if we set it)
            if let navController = navigationController, navController.delegate === self {
                navController.delegate = originalDelegate
            }
        }
        
    }
}
