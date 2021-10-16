import os
path = "/home/abd/Downloads/Repositories/Single-Cycle-RV"
w = os.path.join(path,"code.mem")
r = os.path.join(path,"assembly")
read = open(r,"r") 
write = open(w,"w")
#write.write("0\n")
for x in read:
    write.write(x[14:22] + '\n')
write.close()
read.close()