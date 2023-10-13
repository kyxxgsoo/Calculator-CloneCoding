//
//  UIViewController+Extension.swift
//  UIKit-Study
//
//  Created by Kyungsoo Lee on 2023/09/30.
//

import SwiftUI

// UIKit으로 짠 화면을 SwiftUI로 바로 볼 수 있게 해주는 코드
#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
            let viewController: UIViewController

            func makeUIViewController(context: Context) -> UIViewController {
                return viewController
            }

            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            }
        }

        func toPreview() -> some View {
            Preview(viewController: self)
        }
}
#endif
