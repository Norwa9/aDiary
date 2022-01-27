//
//  globalConstants.swift
//  日记2.0
//
//  Created by 罗威 on 2021/7/29.
//

import Foundation
import UIKit

class globalConstantsManager{
    static let shared = globalConstantsManager()
    var appSize:CGSize = UIScreen.main.bounds.size
    var currentTraitCollection:UITraitCollection?
    private var screenH:CGFloat{
        get{
            return appSize.height
        }
    }
    private var screenW:CGFloat{
        get{
            return appSize.width
        }
    }
    
    func isCatalyst() -> Bool {
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return false
        #endif
    }
    
    
    var currentDeviceOriention:Int = 0
    
    var zoomModelScale:CGFloat{
        get{
            let zoomScale = UIScreen.main.scale / UIScreen.main.nativeScale // 系统开启放大显示模式后
            let deviceScale = kScreenWidth / 414  // 以414为基准，如果比414大，图标放大，反之缩小。
            print("zoomScale:\(zoomScale),deviceScale:\(deviceScale)")
            if UIDevice.current.userInterfaceIdiom == .pad{
                return zoomScale
            }
            else{
                if zoomScale < 1 {
                    return deviceScale
                }else{
                    return zoomScale * deviceScale
                }
            }
            
            
        }
    }
    
    var interfaceOrientation:UIDeviceOrientation{
        get{
            let oriention = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
            switch oriention {
            case .portrait:
                return .portrait
            case .landscapeLeft,.landscapeRight:
                return .landscapeLeft
            default:
                return .unknown
            }
        }
    }
    
    var deviceOriention:UIDeviceOrientation{
        get{
            //某些情况下直接取方向会得到unknown ，不知道为啥
            //这是去取状态栏的方向来代替
            if UIDevice.current.orientation == .unknown{
                return interfaceOrientation
            }
            return UIDevice.current.orientation
        }
    }
    
    var kScreenHeight:CGFloat{
        get{
//            if let trait = currentTraitCollection{
//                if trait.horizontalSizeClass.rawValue == 1{
//                    // 横向布局为compact时，大的为高，小的为宽
//                    return max(screenH, screenW)
//                }else{
//                    return min(screenH, screenW)
//                }
//            }else{
//                return max(screenH, screenW)
//            }
            return screenH
        }
    }
    
    var kScreenWidth:CGFloat{
        get{
//            if let trait = currentTraitCollection{
//                if trait.horizontalSizeClass.rawValue == 1{
//                    // 横向布局为compact时，大的为高，小的为宽
//                    print("trait.h = 1,kScreenWidth:\(min(screenH, screenW))")
//                    return min(screenH, screenW)
//                }else{
//                    print("trait.h = 2,kScreenWidth:\(max(screenH, screenW))")
//                    return max(screenH, screenW)
//                }
//            }else{
//                return min(screenH, screenW)
//            }
            return screenW
        }
    }
    
    var tagsVCWidth:CGFloat{
        get{
            return kScreenWidth - 20
        }
    }
    
    var kBoundsFrameOfShareView:CGRect{
        get{
            return CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight).insetBy(dx: 20, dy: 70)
        }
    }
    
    var defaultTodoBounds:CGRect{
        get{
            let KtodoViewWidth = globalConstantsManager.shared.kScreenWidth * 0.95
            let defaultTodoViewHeight = userDefaultManager.font.lineHeight // 默认的todo cell 高度
            return CGRect(x: 0, y: 0, width: KtodoViewWidth, height: defaultTodoViewHeight)
        }
    }
    
    var deviceCenterPoint:CGPoint{
        get{
            return CGPoint(x: kScreenWidth / 2, y: kScreenHeight / 2)
        }
    }
    
    /// 显示键盘时，textView的底部需要的inset
    var bottomInset:CGFloat?
}

