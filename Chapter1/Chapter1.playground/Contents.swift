//import UIKit
//var greeting = "Hello, playground"

import PlaygroundSupport //let you see live views in assistant editor
import MetalKit //framework that makes using Metal easier. MTKView

guard let device = MTLCreateSystemDefaultDevice() else{
    fatalError("GPU is not supported")
}

//set up the view:
let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 0, blue: 0.8, alpha: 1)
//MTView is a subclass of NSView on macOS and UIView on iOS

//Load Model
//1 allocator manages memory
let allocator = MTKMeshBufferAllocator(device: device)
//2 create a sphere and return vertex information in data buffers
let mdlMesh = MDLMesh(sphereWithExtent: [0.25, 0.75, 0.25], segments: [100, 100], inwardNormals: false, geometryType: .triangles, allocator: allocator)
//3 convert Model I/O mesh to a MetalKit mesh
let mesh = try MTKMesh(mesh: mdlMesh, device: device)

//Create command queue
guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]])
{
    return vertex_in.position;
}

fragment float4 fragment_main(){
    return float4(1, 1, 0, 1);
}
"""

//set up a Metal library containing these two shader functions
let library = try device.makeLibrary(source: shader, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")

//The pipeline state
//we dont create pipeline state directly, instead, we create through a descriptor
//descriptor: holds everything the pipeline needs to know
let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction

//vertex descriptor: to tell GPU how the vertices are laid out in memory
pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

//create pipeline state from the descriptor
let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

//The code above is one-time setup
//In real app, can create several pipeline states

//1.create a command buffer for GPU to run.
//2.obtain a reference to the view's render pass descriptor
//3.get render encoder that holds all information necessary to send to the GPU so that it can draw the vertices
guard let commandBuffer = commandQueue.makeCommandBuffer(), //1
      let renderPassDescriptor = view.currentRenderPassDescriptor, //2
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) //3
else{ fatalError() }

//gives the render encoder the pipeline state that you set up earlier
renderEncoder.setRenderPipelineState(pipelineState)

//gives this buffer to the render encoder by adding the following code
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

guard let submesh = mesh.submeshes.first else {
    fatalError()
}

renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: 0)

renderEncoder.endEncoding() //tell the render that there are no more draw calls and end the render pass
guard let drawable = view.currentDrawable else{
    fatalError()
}
commandBuffer.present(drawable) //ask the command buffer to present the MTKView's drawable and commit to GPU
commandBuffer.commit()

PlaygroundPage.current.liveView = view

