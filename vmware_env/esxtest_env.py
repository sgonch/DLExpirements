import gym
#import rospy
#import roslaunch
import os
import signal
import subprocess
import numpy as np

from os import path
from gym import utils, spaces
from gym.utils import seeding
from gym.envs.vmware_env.vmware_env import VMwareEnv

class ESXTestEnv(VMwareEnv):
    vmid='VirtualMachine-5'

    def __init__(self):
        VMwareEnv.__init__(self, "VirtESX-v0.launch")
        self.action_space = spaces.Discrete(5) #Freeze,+CPU,-CPU,+RAM,-RAM
        self.reward_range = (-np.inf, np.inf)

        self._seed()
        
    def PCLICommand(self, command, vmid):
        output = subprocess.check_output(
              ["powershell.exe", "C:\CNTK\cntk\Tutorials\DGTest\ConnectESX.ps1 -vmid {0} -action {1}".format(vmid,command)], 
              shell=True)
        #print(output)
        #print("C:\CNTK\cntk\Tutorials\DGTest\ConnectESX.ps1 -vmid {1} -action {2}"%(vmid,command))
        return [output]
    
    def ReadData(self,vmid):
        lines = [] # Declare an empty list named "lines"
        in_file=open('c:\\temp\\{0}-OUT.txt'.format(vmid), encoding="latin-1") # Open file lorem.txt for reading of text data.
        for line in in_file: # For each line of text in in_file, where the data is named "line",
            if(len(line)>4):lines.append(line.rstrip('\n')) # add that line to our list of lines, stripping newlines.

        d = {}
        for element in lines:
            k, v = element.split(':')
            key=k.replace('\x00','').replace(' ', '')
            #unicodedata.name(key.decode('utf-8'))
            d[key] = v.replace('\x00','').replace(' ', '')

        in_file.close
        return d


    def _seed(self, seed=None):
        self.np_random, seed = seeding.np_random(seed)
        return [seed]

    def _step(self, action):

        if action == 0: #Freeze
            self.PCLICommand(0,self.vmid)
        elif action == 1: #+CPU
            self.PCLICommand(1,self.vmid)
        elif action == 2: #-CPU
            self.PCLICommand(2,self.vmid)
        elif action == 3: #+CPU
            self.PCLICommand(3,self.vmid)
        elif action == 4: #-CPU
            self.PCLICommand(4,self.vmid)

        data = None
        while data is None:
            try:
                data = self.ReadData(self.vmid)
            except:
                pass

        done=0
        if float(data["HostReady"])>100: done=1
        if float(data["HostSwapped"])>20: done=1
        if float(data["HostLatency"])>20: done=1
        if float(data["HostBallooned"])>20: done=1
        if float(data["HostCoStop"])>20: done=1

        if not done:
            if action == 0:
                reward = 5
            else:
                reward = 1
        else:
            reward = -200
        state=data
        return state, reward, done, {}

    def _reset(self):


        data = None
        print("Resetting 1...")
        self.PCLICommand(0,self.vmid)
        print("Resetting 2...")
        while data is None:
            try:
                #print("Resetting 2...")
                
                data = self.ReadData(self.vmid)
            except:
                pass
        print("Resetting 3...")
        state=data
        return state