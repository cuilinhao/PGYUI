import SwiftUI

/// 照片格式选择器 —— 模仿相机 App 里选格式 + 选像素的那种 UI
/// 上面一排是格式切换（HEIF / TIFF / ProRAW），下面一排是像素切换（12MP / 48MP）
struct PhotoFormatSelectorView: View {
    // 支持的三种照片格式
    enum Format: String, CaseIterable {
        case heif = "HEIF"
        case tiff = "TIFF"
        case proRAW = "ProRAW"
    }
    
    // 当前选中的格式，默认 TIFF
    @State private var selectedFormat: Format = .tiff
    // 当前选中的像素，默认 12MP
    @State private var selectedMP: Int = 12
    
    // 主题橙色，用于高亮选中状态
    private let orange = Color(red: 1.0, green: 0.33, blue: 0.02)
    
    var body: some View {
        // 用 GeometryReader 拿到屏幕宽度，所有尺寸按比例算，这样不同屏幕都能自适应
        GeometryReader { geo in
            let screenW = geo.size.width
            // 上面那排（格式选择）的宽度：占屏幕 92%，但最大不超过 620
            let topW = min(screenW * 0.92, 620)
            // 上面那排的高度：按宽度的 8.5% 来算
            let topH = topW * 0.085
            // 下面那排不再需要手动算宽高，靠 padding 自动撑开
            
            ZStack {
                // 深灰绿色背景，模拟相机取景器的感觉
                //Color(red: 0.23, green: 0.24, blue: 0.21)
                Color(.systemGreen)
                    .ignoresSafeArea()
                
                // 上下两排垂直排列，整体距离顶部 100pt
                VStack(spacing: topH * 0.22) {
                    topSegment(width: topW, height: topH)
                    bottomSegment()
                    Spacer() // 把内容推到顶部
                }
                .padding(.top, 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// 上面那排：格式选择器（HEIF / TIFF / ProRAW 三选一）
    /// 选中项外面会套一个橙色边框的胶囊形状，跟着选中项移动
    private func topSegment(width: CGFloat, height: CGFloat) -> some View {
        // 三等分，每个选项占 1/3 宽度
        let itemW = width / 3
        
        return ZStack(alignment: .leading) {
            // 最底层：半透明黑色胶囊背景
            Capsule()
                .fill(Color.black.opacity(0.34))
            
            // 橙色边框胶囊 —— 这就是那个「选中指示器」
            // 通过 offset 水平偏移到当前选中项的位置
            Capsule()
                .stroke(orange, lineWidth: max(1.2, height * 0.035))
                .frame(width: itemW * 0.98, height: height * 0.86)
                .offset(x: selectedIndex * itemW + itemW * 0.01)
            
            // 三个格式按钮水平排列
            HStack(spacing: 0) {
                ForEach(Format.allCases, id: \.self) { item in
                    Button {
                        selectedFormat = item
                    } label: {
                        Text(item.rawValue)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: itemW, height: height)
                            // contentShape 让整个矩形区域都能点击，不只是文字部分
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: width, height: height)
    }
    
    /// 下面那排：像素选择器（12MP / 48MP 二选一）
    /// 用 .regularMaterial 毛玻璃背景 + .capsule 裁切
    private func bottomSegment() -> some View {
        HStack {
            // 12MP 按钮
            Button {
                selectedMP = 12
            } label: {
                Text(verbatim: "12MP")
                    .foregroundStyle(selectedMP == 12 ? orange : .white)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 6)
            }
            
            // 中间竖线分隔符
            Rectangle()
                .frame(width: 0.7, height: 10)
            
            // 48MP 按钮
            Button {
                selectedMP = 48
            } label: {
                HStack(spacing: 3) {
                    Text(verbatim: "48MP")
                    Text("(仅M档支持)")
                        .font(.system(size: 10))
                        //.baselineOffset(2)
                }
                .foregroundStyle(selectedMP == 48 ? orange : .white)
                //--
                .padding(.horizontal, 25)  // 左右各留 25pt 的空间
                .padding(.vertical, 6)     // 上下各留 6pt 的空间
                
                // MARK: --
                .padding(.leading, 16)     // 左边留 16pt
                .padding(.trailing, 5)     // 右边只留 5pt
                .padding(.vertical, 6)     // 上下各留 6pt
            }
        }
        .font(.system(size: 14))
        //.background(.regularMaterial)
        .background(Color.secondary)
        .clipShape(.capsule)
    }
    
    /// 把当前选中的格式转成数字索引（0/1/2），用来算橙色指示器的水平偏移量
    private var selectedIndex: CGFloat {
        switch selectedFormat {
        case .heif:
            return 0
        case .tiff:
            return 1
        case .proRAW:
            return 2
        }
    }
}

#Preview {
    PhotoFormatSelectorView()
        .frame(height: 190)
}
