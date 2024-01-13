//
//  Renderer.swift
//  Pipeline
//
//  Created by XiaojunW Wang on 1/8/24.
//

import MetalKit

class Renderer: NSObject{
    //page 75
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    
    init(metalView: MTKView){
        //page 76
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else{
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        
        //page 77: create vertex buffer
        let allocator = MTKMeshBufferAllocator(device: device)
        let size: Float = 0.8
        let mdlMesh = MDLMesh(boxWithExtent: [size, size, size], segments: [1,1,1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        do{
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        }catch let error{
            print(error.localizedDescription)
        }
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        //page 77: create shader function
        let library = device.makeDefaultLibrary()
        Renderer.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        //page 77: create pipeline state
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error{
            print(error.localizedDescription)
        }
        
        
        super.init()
        
        //page 76: after this code, will see draw in the debug window, but not draw anything yet
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //this function calls everytime the size of window changes
    }
    
    func draw(in view: MTKView) {
        //this function calls every frame
        //print("draw")
        
        //page 79: pre-draw code
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        //page 80: drawing code goes here
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        for submesh in mesh.submeshes{
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        
        
        //page 79: post-draw code
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else{ return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
