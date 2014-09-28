/*
	c++ 测试opennebula rpc请求
	g++ xmlrpcTest/rpcClient.cpp -o rpcClient  -pthread -L/usr/local/lib  \
		-lxmlrpc_client++ -lxmlrpc_client -lxmlrpc++ -lxmlrpc -lxmlrpc_util \
		-lxmlrpc_xmlparse -lxmlrpc_xmltok -lcurl   \
		-lxmlrpc_packetsocket -I/usr/local/include 

*/

#include <cstdlib>
#include <string>
#include <iostream>
#include <xmlrpc-c/girerr.hpp>
#include <xmlrpc-c/base.hpp>
#include <xmlrpc-c/client_simple.hpp>
#include <map>

using namespace std;

int main(int argc, char **) {
    if (argc-1 > 0) {
        cerr << "This program has no arguments" << endl;
        exit(1);
    }
    try {
        xmlrpc_env env;
        string const serverUrl("http://192.168.70.70:2633/RPC2");
        string const methodAllocate("one.vm.allocate");
        xmlrpc_c::clientSimple myClient;
        xmlrpc_c::value resultSUBMIT;

        xmlrpc_env_init(&env);
		//c++ rpc 发送请求时，的session id是oneadmin:oneadmin
		//参数格式为string int int string [siis]
	    //sessonid=oneadmin:oneadmin  "siis"
    	myClient.call(serverUrl, methodAllocate, "siis",
    				  &resultSUBMIT,
					  "oneadmin:oneadmin",
					  2,
					  0,
    				  "<VMTEMPLATE><NAME>test-clone</NAME><CPU>2</CPU><GRAPHICS><TYPE>VNC</TYPE><LISTEN>0.0.0.0</LISTEN></GRAPHICS><MEMORY>512</MEMORY><DISK><IMAGE>ttylinux - kvm_file0</IMAGE><IMAGE_UID>0</IMAGE_UID><IMAGE_UNAME>oneadmin</IMAGE_UNAME><DEV_PREFIX>xvd</DEV_PREFIX><DRIVER>file</DRIVER></DISK><NIC><NETWORK>opennebula-test-1</NETWORK><NETWORK_UNAME>oneadmin</NETWORK_UNAME><NETWORK_UID>0</NETWORK_UID></NIC><OS><BOOT>hd</BOOT></OS></VMTEMPLATE>");

        xmlrpc_c::value_array resultArray = xmlrpc_c::value_array(resultSUBMIT);
        vector<xmlrpc_c::value> const paramArrayValue(resultArray.vectorValueValue());

        //check posible Errors:
        xmlrpc_c::value firstvalue;
        firstvalue = static_cast<xmlrpc_c::value>(paramArrayValue[0]);
        xmlrpc_c::value_boolean status = static_cast<xmlrpc_c::value_boolean>(firstvalue);

        xmlrpc_c::value secondvalue;
        secondvalue = static_cast<xmlrpc_c::value>(paramArrayValue[1]);
        xmlrpc_c::value_string valueS = static_cast<xmlrpc_c::value_string>(secondvalue);

        if(static_cast<bool>(status)) {
            //Success, returns the id assigned to the VM:
            cout << "vmid returned: " << static_cast<string>(valueS) << endl;
            return 0;
        }
        else{ //Failure:
            string error_value=static_cast<string>(valueS);
            if (error_value.find("Error inserting",0)!=string::npos ) cout << "Error inserting VM in the database" << endl;
            else if (error_value.find("Error parsing",0)!=string::npos ) cout << "Error parsing VM template" << endl;
            else cout << "Unknown error " << static_cast<string>(valueS) << endl;
        };
    } catch (girerr::error const error) {
        cerr << "Client threw error: " << error.what() << endl;
        //"Client threw error:"
        return 20;
    } catch (std::exception const e) {
        cerr << "Client threw unexpected error." << endl;
        //Unexpected error:
        return 999;
    }
    return 0;
}
