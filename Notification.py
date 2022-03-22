# -*- coding: utf-8 -*-
"""
Created on Tue Mar 22 15:05:39 2022

@author: an1519
"""

import serial
ser = serial.Serial('COM4', baudrate=9600)
#%%
s = ser.read(15)
print(s)
if s == b'ALARM ACTIVATED':
    print('BEEP')
#%%