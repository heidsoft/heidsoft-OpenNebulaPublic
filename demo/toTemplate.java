public String toTemplate() {
        Field[] fields=this.getClass().getDeclaredFields();

//        String str ="{\n" +
//                "        \"NAME\": \"testbbbbbbbbbbb\", \n" +
//                "        \"MEMORY\": \"512\", \n" +
//                "        \"CPU\": \"1\", \n" +
//                "        \"DESCRIPTION\": \"test\", \n" +
//                "        \"OS\": {\n" +
//                "            \"ARCH\": \"i686\"\n" +
//                "        }, \n" +
//                "        \"DISK\": [\n" +
//                "            {\n" +
//                "                \"IMAGE\": \"ttylinux\", \n" +
//                "                \"IMAGE_UNAME\": \"oneadmin\"\n" +
//                "            }\n" +
//                "        ], \n" +
//                "        \"NIC\": [\n" +
//                "            {\n" +
//                "                \"NETWORK\": \"cloud\", \n" +
//                "                \"NETWORK_UNAME\": \"oneadmin\"\n" +
//                "            }\n" +
//                "        ], \n" +
//                "        \"CONTEXT\": {\n" +
//                "            \"SSH_PUBLIC_KEY\": \"$USER[SSH_PUBLIC_KEY]\", \n" +
//                "            \"NETWORK\": \"YES\"\n" +
//                "        }\n" +
//                "    }";
//        StringBuffer stringBuffer = new StringBuffer();
//        stringBuffer.append("");
        JSONObject jsonObject = new JSONObject();
        for(Field field:fields){
            field.setAccessible(true);//修改访问权限
            try {
               //System.out.println("field==>>>>"+field.getName().toUpperCase());
                if(field.getName().toUpperCase().equals("NAME")){
                    jsonObject.put("NAME",this.getName());
                    //stringBuffer.append("NAME="+this.getName()+"\n");
                }else if(field.getName().toUpperCase().equals("MEMORY")){
                    jsonObject.put("MEMORY",this.getMemory());
                    //stringBuffer.append("MEMORY="+this.getMemory()+"\n");
                }else if(field.getName().toUpperCase().equals("CPU")){
                    jsonObject.put("CPU",this.getCpu());
                    //stringBuffer.append("CPU="+this.getCpu()+"\n");
                }else if(field.getName().toUpperCase().equals("DISK")){
                    List<Disk> diskList=this.getDisk();
                    //System.out.println("diskjson==>"+JSONObject.fromObject(diskList).toString());

                    if(null!=diskList&&diskList.size()>0){
                        JSONArray jsonArray = new JSONArray();
                        for(Disk disk : diskList){
                            JSONObject node = new JSONObject();
                            node.put("IMAGE",disk.getImage());
                            node.put("IMAGE_UNAME",disk.getImage_uname());
                            jsonArray.add(node);
                        }
                        //log.info(jsonArray.toString());
                        jsonObject.put("DISK",jsonArray);
                    }
                }
            } catch (Exception e) {
                throw new OneException("build template is failed",e);
            }
        }

//        TemplateDTO tDto = new TemplateDTO();
        XmlMapper xml = new XmlMapper();
        StringWriter sw = new StringWriter();
        String xmlTemplate=null;
        try{
            xml.writeValue(sw,jsonObject);
            xmlTemplate=(sw.toString());
        }catch (JsonGenerationException e){
            e.printStackTrace();
        }catch (JsonMappingException e){
            e.printStackTrace();
        }catch (IOException e){
            e.printStackTrace();
        }
//
//        XMLSerializer xmlSerializer = new XMLSerializer();
//        JSON json = JSONSerializer.toJSON(jsonObject);

        log.info("====>>>>>>>"+xmlTemplate);
        return xmlTemplate;
    }
