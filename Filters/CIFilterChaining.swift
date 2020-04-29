////
////  CIFilterChaining.swift
////  Filters
////
////  Created by Jared Warren on 4/28/20.
////  Copyright © 2020 Warren. All rights reserved.
////
//
//import UIKit
//import Metal
//
//public protocol CIFilterChainable {
//    var cifilter: CIFilter? { get }
//}
//
//extension String: CIFilterChainable {
//    public var cifilter: CIFilter? {
//        return CIFilter(name: self)
//    }
//}
//
//extension CIFilter: CIFilterChainable {
//    public var cifilter: CIFilter? { return self }
//}
//
//protocol CIFilterChainState {
//    func add(_ item: CIFilterChainable)
//    func defaults()
//    func generate() -> UIImage
//    func set(_ key: String, _ value: Any?)
//    func input(_ image: UIImage)
//    func input(_ chain: CIFilterChain)
//}
//
//class CIFilterChainErrorState: CIFilterChainState {
//    func add(_ item: CIFilterChainable) {}
//    func defaults() {}
//    func generate() -> UIImage { return UIImage() }
//    func set(_ key: String, _ value: Any?) {}
//    func input(_ image: UIImage) {}
//    func input(_ chain: CIFilterChain) {}
//}
//
//class CIFilterChainBuilderState: CIFilterChainState {
//    class ImagePassthroughFilter: CIFilter {
//        var inputImage: UIImage
//        init(_ inputImage: UIImage) {
//            self.inputImage = inputImage
//            super.init()
//        }
//        required init?(coder aDecoder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//        override var outputImage: CIImage? {
//            return CIImage(image: inputImage)
//        }
//    }
//
//    private var filters = [CIFilter]()
//
//    func add(_ item: CIFilterChainable) {
//        if let filter = item.cifilter {
//            filters.append(filter)
//        }
//    }
//
//    func defaults() {
//        filters.last?.setDefaults()
//    }
//    
//    func set(_ key: String, _ value: Any?) {
//        filters.last?.setValue(value, forKey: key)
//    }
//
//    func input(_ image: UIImage) {
//        if filters.count == 0 {
//            let passthrough = ImagePassthroughFilter(image)
//            filters.append(passthrough)
//        } else if let passthrough = filters.first as? ImagePassthroughFilter {
//            passthrough.inputImage = image
//        } else {
//            filters.first?.setValue(image.cgImage!, forKey: "inputImage")
//        }
//    }
//
//    func input(_ filterChain: CIFilterChain) {
//        input(filterChain.generate())
//    }
//
//    func generate() -> UIImage {
//        let ciContext = CIContext(mtlDevice: MTLCreateSystemDefaultDevice()!)
//
//        for i in 0..<filters.count-1 {
//            filters[i+1].setValue(filters[i].outputImage, forKey: "inputImage")
//        }
//
//        let final = filters.last?.outputImage ?? CIImage.empty()
//        let outputImage = ciContext.createCGImage(final, from: final.extent)!
//
//        return UIImage(cgImage: outputImage)
//    }
//}
//
//public class CIFilterChain {
//
//    var state: CIFilterChainState = CIFilterChainBuilderState()
//
//    @discardableResult
//    public func add(_ item: CIFilterChainable) -> Self {
//        if state is CIFilterChainBuilderState, item.cifilter == nil {
//            print("ERROR: CIFilterChain - cannot add '\(item)' cifilter is nil")
//            state = CIFilterChainErrorState()
//        }
//        state.add(item)
//        return self
//    }
//
//    @discardableResult
//    public func defaults() -> Self {
//        state.defaults()
//        return self
//    }
//
//    @discardableResult
//    public func set(_ key: String, _ value: Any?) -> Self {
//        state.set(key, value)
//        return self
//    }
//
//    @discardableResult
//    public func input(_ image: UIImage) -> Self {
//        state.input(image)
//        return self
//    }
//
//    @discardableResult
//    public func input(_ filterChain: CIFilterChain) -> Self {
//        state.input(filterChain)
//        return self
//    }
//
//    @discardableResult
//    public func generate() -> UIImage {
//        return state.generate()
//    }
//
//}
//
//extension CIFilterChain {
//
//    @discardableResult
//    public func crop(_ width: CGFloat, _ height: CGFloat) -> Self {
//        return
//            add("CICrop")
//                .defaults()
//                .set("inputRectangle", CGRect.init(x: 0, y: 0, width: width, height: height))
//    }
//
//    @discardableResult
//    public func crop(_ rect: CGRect) -> Self {
//        return add("CICrop").defaults().set("inputRectangle", rect)
//    }
//}
//
//extension CIFilter {
//    public func props(_ key: String, _ value: Any?) -> Self {
//        setValue(value, forKey: key)
//        return self
//    }
//}
//
//infix operator >>>: CIFilterChainGroup
//precedencegroup CIFilterChainGroup {
//    associativity: left
//}
//
//public func >>> (lhs: CIFilterChainable, rhs: CIFilterChainable) -> CIFilterChain {
//    let chain = CIFilterChain()
//    return chain.add(lhs).add(rhs)
//}
//
//public func >>> (chain: CIFilterChain, rhs: CIFilterChainable) -> CIFilterChain {
//    return chain.add(rhs)
//}
//
//public typealias CIFilterChainFunction = (CIFilterChain) -> Void
//
//public func >>> (chain: CIFilterChain, f: CIFilterChainFunction) -> CIFilterChain {
//    f(chain)
//    return chain
//}
//
//public func >>> (lhs: CIFilterChainable, f: CIFilterChainFunction) -> CIFilterChain {
//    let chain = CIFilterChain()
//    chain.add(lhs)
//    f(chain)
//    return chain
//}
//
//extension CIFilter {
//    class func crop(_ width: CGFloat, _ height: CGFloat) -> CIFilterChainFunction {
//        return { $0.crop(width, height) }
//    }
//
//    class func set(_ key: String, _ value: Any?) -> CIFilterChainFunction {
//        return { $0.set(key, value) }
//    }
//
//    class func defaults() -> CIFilterChainFunction {
//        return { $0.defaults() }
//    }
//}
