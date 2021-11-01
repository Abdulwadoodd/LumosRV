import os
path1 = "/home/abd/ComputerArchitecture/ComputerArchitectureLAB/Single_Cycle/AssmblerResources"
path2 = "/home/abd/ComputerArchitecture/ComputerArchitectureLAB/Single_Cycle/Design_Sources"
w = os.path.join(path2,"code.mem")
r = os.path.join(path1,"assembly")
read = open(r,"r") 
write = open(w,"w")
#write.write("0\n")
for x in read:
    write.write(x[14:22] + '\n')
write.close()
read.close()
