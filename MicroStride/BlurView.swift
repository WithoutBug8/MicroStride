//
//  BlurView.swift
//  MicroStride
//  这一页主要负责美化，效果是毛玻璃皮肤
//  Created by 郭博文 on 2025/2/2.
//

import SwiftUI

struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
