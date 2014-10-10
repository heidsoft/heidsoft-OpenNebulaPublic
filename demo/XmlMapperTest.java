//        XmlMapper xml = new XmlMapper();
//        try{
//            JsonNode jsonTemplate=xml.readTree(template.info().getMessage());
//            Iterator<JsonNode> jsonNodeIterator=jsonTemplate.elements();
//            while(jsonNodeIterator.hasNext()){
//                JsonNode node=jsonNodeIterator.next();
//                System.out.println(node.textValue());
//            }
//
//        }catch (JsonProcessingException e){
//            e.printStackTrace();
//        }catch (IOException e){
//            e.printStackTrace();
//        }
