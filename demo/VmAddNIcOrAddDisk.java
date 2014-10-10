   /**
     * 增加磁盘
     * @param vmId
     * @param diskTemplate
        <disk_template>
            <DISK>
                <IMAGE>blk-5g</IMAGE>
                <IMAGE_UNAME>oneadmin</IMAGE_UNAME>
                <DRIVER>file</DRIVER>
                <DEV_PREFIX>xvd</DEV_PREFIX>
                <SIZE>10240</SIZE>
                <TYPE>fs</TYPE>
            </DISK>
        </disk_template>
     * @return
     */
    public boolean diskAttach(int vmId,String diskTemplate){

        VirtualMachinePool virtualMachinePool = (VirtualMachinePool)getPool(Constants.POOL_TYPE_VM);
        if(null==virtualMachinePool){
            throw  new OneException("init VirtualMachinePool  failed!");
        }
        OneResponse one = virtualMachinePool.info();
        if(one.isError()){
            throw  new OneException(one.getErrorMessage());
        }
        VirtualMachine virtualMachine=virtualMachinePool.getById(vmId);
        if(null==virtualMachine){
            throw new OneException("VirtualMachinePool is not find "+vmId+" vm object");
        }

        one =  virtualMachine.diskAttach(diskTemplate);

        if(one.getErrorMessage()!=null){
            return false;
        }else{
            return true;
        }
    }

    /**
     * 卸载磁盘
     * @param vmId
     * @param diskId
     * @return
     */
    public boolean  diskDetach(int vmId, int diskId){
        VirtualMachinePool virtualMachinePool = (VirtualMachinePool)getPool(Constants.POOL_TYPE_VM);
        if(null==virtualMachinePool){
            throw  new OneException("init VirtualMachinePool  failed!");
        }
        OneResponse one = virtualMachinePool.info();
        if(one.isError()){
            throw  new OneException(one.getErrorMessage());
        }
        VirtualMachine virtualMachine=virtualMachinePool.getById(vmId);
        if(null==virtualMachine){
            throw new OneException("VirtualMachinePool is not find "+vmId+" vm object");
        }

        one = virtualMachine.diskDetach(diskId);
        if(one.getErrorMessage()!=null){
            return false;
        }else{
            return true;
        }
    }

    /**
     * 附加一张网卡
     * @param vmId
     * @param nicTemplate
     * <nic_template>
            <NIC>
                <NETWORK>public</NETWORK>
                <NETWORK_UNAME>oneadmin</NETWORK_UNAME>
            </NIC>
       </nic_template>
     * @return
     */
    public boolean  nicAttach(int vmId,String nicTemplate ){
        VirtualMachinePool virtualMachinePool = (VirtualMachinePool)getPool(Constants.POOL_TYPE_VM);
        if(null==virtualMachinePool){
            throw  new OneException("init VirtualMachinePool  failed!");
        }
        OneResponse one = virtualMachinePool.info();
        if(one.isError()){
            throw  new OneException(one.getErrorMessage());
        }
        VirtualMachine virtualMachine=virtualMachinePool.getById(vmId);
        if(null==virtualMachine){
            throw new OneException("VirtualMachinePool is not find "+vmId+" vm object");
        }

        one = virtualMachine.nicAttach(nicTemplate);

        if(one.getErrorMessage()!=null){
            return false;
        }else{
            return true;
        }


    }

    /**
     * 卸载一张网卡
     * @param vmId
     * @param nicId
     * @return
     */
    public boolean nicDetach(int vmId,int nicId){

        VirtualMachinePool virtualMachinePool = (VirtualMachinePool)getPool(Constants.POOL_TYPE_VM);
        if(null==virtualMachinePool){
            throw  new OneException("init VirtualMachinePool  failed!");
        }
        OneResponse one = virtualMachinePool.info();
        if(one.isError()){
            throw  new OneException(one.getErrorMessage());
        }
        VirtualMachine virtualMachine=virtualMachinePool.getById(vmId);
        if(null==virtualMachine){
            throw new OneException("VirtualMachinePool is not find "+vmId+" vm object");
        }

        one = virtualMachine.nicDetach(nicId);

        if(one.getErrorMessage()!=null){
            return false;
        }else{
            return true;
        }
    }

    /**
     * 磁盘快照
     * @param vmId
     * @param diskId
     * @param imageName
     * @param imageType
     * @param hot
     * @param doTemplate
     * @return
     */
    public boolean diskSnapshot(int vmId,
                                int diskId,
                                String imageName,
                                String imageType,
                                boolean hot,
                                boolean doTemplate){

        VirtualMachinePool virtualMachinePool = (VirtualMachinePool)getPool(Constants.POOL_TYPE_VM);
        if(null==virtualMachinePool){
            throw  new OneException("init VirtualMachinePool  failed!");
        }
        OneResponse one = virtualMachinePool.info();
        if(one.isError()){
            throw  new OneException(one.getErrorMessage());
        }
        VirtualMachine virtualMachine=virtualMachinePool.getById(vmId);
        if(null==virtualMachine){
            throw new OneException("VirtualMachinePool is not find "+vmId+" vm object");
        }


        if(hot){
            one = virtualMachine.diskSnapshot(diskId,imageName);
        }else{
            one = virtualMachine.diskSnapshot(diskId,imageName,hot);
        };

        return one.isError();
    }



    public static  void main(String[] args){
        Client client = null;
        try {
            client = new Client("oneadmin:oneadmin", "http://192.168.70.77:2633/RPC2");
        } catch (Exception e) {
            e.printStackTrace();
        }

        VMService vmService = new VMService(client);

        int vmId=242;
        String diskTemplate="";
        //附加磁盘


//        diskTemplate="DISK=[";
//        diskTemplate+=" IMAGE=\"blk-5g\"";
//        diskTemplate+=" IMAGE_UNAME=\"oneadmin\"";
//        diskTemplate+=" DRIVER=\"file\"";
//        diskTemplate+=" DEV_PREFIX=\"xvd\"";
//        diskTemplate+=" SIZE=\"10240\"";
//        diskTemplate+=" TYPE=\"fs\"";
//        diskTemplate+=" ]";

//        diskTemplate="<disk_template><DISK>";
//        diskTemplate+="<IMAGE>blk-5g</IMAGE>";
//        diskTemplate+="<IMAGE_UNAME>oneadmin</IMAGE_UNAME>";
//        diskTemplate+="<DRIVER>file</DRIVER>";
//        diskTemplate+="<DEV_PREFIX>xvd</DEV_PREFIX>";
//        diskTemplate+="<SIZE>10240</SIZE>";
//        diskTemplate+="<TYPE>fs</TYPE>";
//        diskTemplate+="</DISK></disk_template>";
//
//        if(vmService.diskAttach(vmId,diskTemplate)){
//            System.out.println("diskAttach ok ");
//        }else{
//            System.out.println("diskAttach error ");
//        }
//
//        int diskId=2;
//        if(vmService.diskDetach(vmId,diskId)){
//            System.out.println("Detach ok");
//        }else{
//            System.out.println("Detach error");
//        }





        String nicTemplate="<nic_template><NIC><NETWORK>public</NETWORK><NETWORK_UNAME>oneadmin</NETWORK_UNAME></NIC></nic_template>";
        int nicId=1;
        if(vmService.nicAttach(vmId,nicTemplate)){
            System.out.println("nicAttach ok ");
        }else{
            System.out.println("nicAttach error ");
        }

//        if(vmService.nicDetach(vmId,nicId)){
//            System.out.println("Detach ok ");
//        }else{
//            System.out.println("Detach error ");
//        }





    }
