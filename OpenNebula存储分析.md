OpenNebula存储分析
------------------
“jake.liu(heidsoft@sina.com)

#OpenNebula附带3不同数据存储类
##System
  to hold images for running VMs, depending on the storage technology used these temporal images can
  be complete copies of the original image, qcow deltas or simple filesystem links
  存储运行中的虚拟机使用的一些镜像，这些模板镜像依赖于存储中的原始镜像拷贝，qcow增量，或者文件系统软链接。
##
