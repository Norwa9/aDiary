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
    private let screenH = UIScreen.main.bounds.height
    private let screenW = UIScreen.main.bounds.width
    
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
            //竖向的三种情况
            if deviceOriention.isPortrait || deviceOriention == .faceUp{
                return max(screenH, screenW)
            }else{
                return min(screenH, screenW)
            }
        }
    }
    
    var kScreenWidth:CGFloat{
        get{
            if deviceOriention.isLandscape || deviceOriention == .faceUp{
                return max(screenH, screenW)
            }else{
                return min(screenH, screenW)
            }
        }
    }
    
    var tagsVCWidth:CGFloat{
        get{
            return min(kScreenWidth,kScreenHeight) - 20
        }
    }
}

