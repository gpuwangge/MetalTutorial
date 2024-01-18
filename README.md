# Metal by Tutorial
https://github.com/kodecocodes/met-materials  
PDF Book: http://www.banshujiang.cn/e_books/2941  
Metal by Tutorials: Beginning Game Engine Development With Metal  
Third Edition (2022) Xcode 13, Metal 2.4  
Code repo:  
https://github.com/raywenderlich/met-materials/tree/editions/3.0  

## 本Repo代码使用方法
MacOS环境下使用Xcode打开运行  

## 01 Hello Metal
介绍基本概念  
What is Render: from point to image on the screen. Normally involving light and shade  
What is Rendering Pipeline: from importing model's vertices to generating the final image on your screen. Or a list of commands sent to the GPU, along with resources(vertices, materials and lights). 
Frame: A game concept. Game consists of many images, each is a frame.  
Frame Rate: the speed at which the images appear.  
Render Pass: shadow, lighting and reflections is generally done in separate render passes. Then another render pass would render the models in full color. But for simplicity, we start with single render pass. (instead of multi-pass rendering)
Attachment: render destination  
Submeshes: Mesh is made up of submeshes  
第一个项目是通过Xcode创建的Playground空项目，名字叫Chaptor1  


## 02 3D Models
打开.playground文件，里面包含两个swift文件：  
Render and Export 3D Model  
Import Train  
(教程把它们称为两个Page)  
另外，似乎读取了resource文件夹下的模型，包含两种格式  
train.blend  
train.usdz  
(教程建议在Xcode里设置显示extention作为区分)  

Blender 是一款可以用来创建3D models的app，并且是free的。  
.usdz是Pixar的格式。  

接下来的内容介绍了各种格式，包括.obj, .mtl的存储和读取。  
如何在Blender里打开和编辑模型。  
Vertices和submesh的内存格式，和顺序Order。  

(跳过这一章)  

# 03 The Rendering Pipeline
从这一章开始就不是Playground了。Playground的用处是Testing和Learning，但不是Full Metal Project。  
本章目的：建立pipeline框架，包含以下部分  
1、Shaders.metal，包含两个空shader  
2、Render.swift，包含metal render函数，比如如何获得device，如何建立commandqueue，如何创建shader library。最终创建pipeline state，完成初始化。  
在draw函数中，利用encoder读取pipeline state,并完成绘画。  
然后，使用commandBuffer.present()函数把结果呈现到view上去。  
这个view是如何使用的呢？原来，Render类本身继承自母类NSObject。该类存在MTKView对象。  
Render通过扩展extention MTKViewDelegte功能把这个view呈现出来。  
3、PipelineApp.swift，App的入口类。  
4、ContentView.swift，规定了MetalView如何在画布上呈现  
5、MetalView.swfit，有一些设备相关代码在这里，比如ios or macos。  

概念：  
Arithmetic Logic Unit (ALU)  
Shader Core: GPU has special circuitry for processing geometry and are often called shader cores.  

使用Xcode创建Project。(Name=Pipeline)  
Multiplatform App template  
Uncheck 所有选项，创建的是一个SwiftUI App。  
(如果运行，会产生macOS hello world界面)  
(在Product->Destination里面选择iPhone模拟器，可以运行iOS版本)  
默认项目包含如下文件:  
ContentView.swift  
PipelineApp.swift  

添加MetalView.swift  
为了加速学习，教程提供了以下文件：  
MetalView.swift  
使用方法：把该文件拷贝到文件夹后，拖进Xcode里。Check "Copy items if needed"。选择"Create groups"。勾选"Add to targets"里面的所有选项。  
代码分析：首先改代码Import SwiftUI和MetalKit。它生成了一个MetalVIew。这个MetalView继承自View，是一个struct。在ContentVIew.swift里面可以移除默认的Image/Text，以MetalView()取而代之。这样就把Metal的内容链接上去了。  
另外，这个文件里代码支持macOS/iOS。  

创建Renerer.swift  
这个文件是用来做delegate function的。看起来有点像call back。  
它的原理是从NSObject Inherite下来，然后再MetalView.swfit里面把新的Renderer平替。  
Page 75介绍了Initilization流程  
Page 81介绍了Pipeline流程  

创建Shaders.metal  
使用Metal File template来创建这个文件  

Challenge任务：读train.usdz，略过 (Page 95)  

# 04 The Vertex Function
一共就三种Shader function: vertex, fragment and kernel。  
第03课说的是如何用vertex descriptor建立模型，这次要学的是如何不用vertex descriptor  
Metal坐标系从左到右是-1~1  
从下到上是-1~1  
创建了新的文件：  
Quad.swift  
(swift种 )  

虽然可以不通过vertex descriptor就能往GPU输送vertex数据，还是建议使用vertex descriptor，因为可以更方便的带attributes。第一个attribute(0)就是position  
创建了新的文件：  
VertexDescriptor.swift  

创建了Descripor以后，可以方便增加更多attribute，比如color。  
更多的attribute可以添加入Quad.swift里。  
在本例中，虽然color被送过去了，还需要修改fragment变换颜色  

# 16 GPU Compute Programming
Goal: Perform simple GPU programming and explore how to use GPU in ways other than vertex rendering.  

Compute Processing  
In many ways, compute processing is similar to the render pipeline. You set up a  
command queue and a command buffer. In place of the render command encoder,  
compute uses a compute command encoder. Instead of using vertex or fragment  
functions in a compute pass, you use a kernel function. Threads are the input to  
the kernel function, and the kernel function operates on each thread.  

Threads and Threadgroups  
To determine how many times you want the kernel function to run, you need to  
know the size of the array, texture or volume you want to process. This size is the  
grid and consists of threads organized into threadgroups.  

The grid is defined in three dimensions: width, height and depth. But often,  
especially when you’re processing images, you’ll only work with a 1D or 2D grid.  
Every point in the grid runs one instance of the kernel function, each on a separate  
thread.  

举例：  
输入512 x 384 的图片，首先确定维度是2  
然后需要告诉GPU两个数字: Threads per grid, Threads per threadgroup  
（如果使用dispatchThreadgroups()，需要告诉GPU的是threadgroup数量，以及threads per threadgroup数量）  
Threads per grid: 总thread数字，就是512*384，分到2D里就是[512, 384]  
Threads per threadgroup: 跟device有关(threadExecutionWidth=32表示最优化performance的宽度, maxTotalThreadsPerThreadgroup=512表示硬件支持的每个threadgroup内thread的极限)。  
因此 Threads per threadgroup = [32, ?], 32*?必须小于硬件极限512, 所以?=512/32=16  
所以本例中最佳2d threadgroup size = [32, 16]  
(可以反推出threadgroup数量是[512/32=16, 384/16=24])  
因此具体使用的时候，用Threads per threadgroup还是threadgroup结果都一样的。  

下面代码是一个使用threadgroup的例子,其核心思想是指定threadsPerGrid, 然后根据query的最优化width参数自动算出需要的group数量。  
let width = 32  
let height = 16  
let threadsPerThreadgroup = MTLSize(width: width, height: height, depth: 1)  
let gridWidth = 512  
let gridHeight = 384  
let threadGroupCount = MTLSize(  
    width: (gridWidth + width - 1) / width,  
    height: (gridHeight + height - 1) / height,  
    depth: 1)  
computeEncoder.dispatchThreadgroups(  
    threadGroupCount,  
    threadsPerThreadgroup: threadsPerThreadgroup)  

如果grid size不是threadgroup size的整数倍怎么办？使用non-uniform threadgroups。  

接下来是写kernel函数，以下是一个例子  
先建立ConvertMesh.metal，添加如下代码：  
#import "Common.h"  
kernel void convert_mesh(  
device VertexLayout *vertices [[buffer(0)]],  
uint id [[thread_position_in_grid]]){  
     vertices[id].position.z = -vertices[id].position.z;  
}  

效率分析(M1 Mac Mini)  
CPU: 0.00179s  
GPU: 0.000692s  

Atomic Functions  
问题描述：you may want to perform an operation that requires information from other threads.   
An atomic operation works in shared memory and is visible to other threads  
相关Kernel输入：device atomic_int &vertexTotal [[buffer(1)]],  
相关Kernel函数：atomic_fetch_add_explicit(&vertexTotal, 1, memory_order_relaxed);  



## Metal Shading Language教程
https://www.youtube.com/watch?v=VQK28rRK6OU  
用途：you dont need to use GPU to do Graphics. can do bitcoin, collision calculations, image processing(every pixel uses a thread  
Goal: add two different arrays(array1+array2)  


Encoder?.dispatchThreads(threadsPerGrid: threadsPerThreadgroup)  
这个应该是个新函数，最低支持到A11 (2017)  
第一个参数是每个Grid多少个Threads  
第二个参数是每个Threadgroup可以有多少个thread  
这两个参数都是三维数据  

Encoder?.dispatchThreadgroups(threadgroupsPerGrid:  threadsPerThreadgroup  )  
这个函数支持性更好  
第一个参数是每个Grid多少个Threadgroup  
第二个参数是每个Threadgroup可以有多少个thread（跟上面那个函数一样的）  
这两个参数都是三维数据  

threadsPerThreadgroup这个参数跟硬件有关。通过pipeline.maxTotalThreadsPerThreadgroup获得。这个参数可以作为dispatch的第二个参数。  
另外，可以通过device.maxThreadsPerThreadgroup获得。这个不知道用来干啥？  

maxTotalThreadsPerThreadgroup  
The maximum number of threads in a threadgroup that you can dispatch to the pipeline.  

maxThreadsPerThreadgroup:  
The maximum number of threads along each dimension of a threadgroup.  

同一个threadgroup里面，thread是并行的。这个 threadsPerThreadgroup可以拉到从硬件query出来的最大值，以保证kernel最大限度的并行计算。  

实例1：  
如果我们要做两个向量相加，用哪个函数，怎么取参数？  
首先确定向量的维度n，这个n就是总的thead数量。  
假定硬件限制的单一维度最大threadPerThreadgroup是m  
选用dispatchThreads()函数，第一个参数取(n, 1, 1)；这样所有维度的份量都并行  
第二个参数取(m, 1, 1)；这样如果n>m，则gpu自动分成多个threadgroup计算  
如果硬件不支持dispatchThreads()，则选用dispatchThreadgroups()函数。  
以下是推测：  
这时候有多少个group要自行计算：假如n<=m，那就一个group呗, g=1  
如果n>m, g=1+(n-1)/m  
第一个参数(g, 1, 1)  
第二个参数仍旧是(m, 1, 1)  

实例2：  
本例的目的是最大化FMA获得throuput结果。要让ALU填满fma。  
单个kernel计划运算1024个FMA，并lunch很多invocation。threadsPerThreadgroup拉到最大  
总共thread设计需求：  
threadPerGrid n = core数(5) * maxTotalThreadsPerThreadgroup(512)  
threadsPerThreadgroup m=query出来的最大值(512)  
n肯定大于m的  
g=1+(n-1)/m=1+4=5  
或者直接给一个非常大的数：  
numThreadgroups = core数(5) * residentThreadgroups(8) * overSubscription（250)  

实例3：  
本例复现github上clpeak的compute_sp_v1函数  
clpeak本身使用opencl完成，测试机器为Apple M2，其主要参数如下：  
globalSize = 5242880, 1 1  
localSize = 256, 1, 1  
globalSize的含义是所有线程的总数，计算方法是10 compute unit, each compute unit支持2048个workgroup，每个workgroup最大的workitem为256: 10*2048*256=5242880  
localSize也就是每个workgroup最大的workitem数，也就是256  
以上数据都是硬件相关数据。  
如果使用metal的Encoder?.dispatchThreadgroups(threadgroupsPerGrid:  threadsPerThreadgroup  )函数复现：  
第二个参数：threadsPerThreadgroup  也就是localSize，取256  
第一个参数：threadgroupsPerGrid 取5242880/256=20480  




## Metal Performance Shader
介绍：是一个shader framework, 包含compute and graphics shaders, 目标是uned to take advantage of the unique hardware characteristics of each GPU family to ensure optimal performance.   
developer.apple.com可以下载Document  

Swfit版本的Sample Code在这里下载：(这个网站看起来不是官方的)  
https://metalbyexample.com/metal-performance-shaders-in-swift/  
解压缩后是Xcode project  
其架构使用storyboard  
运行结果是，在ios上，一只猴子图片不停被Saturation, Desaturation  
并未提供performance benchmark指标  

Metal Performance Shader Framework应该是一系列MPS打头的kernal函数  

比如这个：  
https://www.kodeco.com/books/metal-by-tutorials/v2.0/chapters/21-metal-performance-shaders  

ex:   
let shader = MPSImageSobel(device: device)  
shader.encode(commandBuffer: commandBuffer,   
              sourceTexture: inputImage,  
              destinationTexture: drawable.texture)  



