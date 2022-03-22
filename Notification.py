# -*- coding: utf-8 -*-
"""
Created on Tue Mar 22 15:05:39 2022

@author: an1519
"""

import serial
ser = serial.Serial('COM4', baudrate=9600)
#%%
import smtplib, ssl

port = 465  # For SSL
#password = input("Type your password and press enter: ")
password = 'QWERTY123='
# Create a secure SSL context
context = ssl.create_default_context()


    # TODO: Send email here
sender_email = "progmikro18@gmail.com"
receiver_email = "alexjakzn@gmail.com"
message = """\
Subject: Home Security Breach

A sensor has detected that someone is in your home."""
#%%
s = ser.read(15)
print(s)
if s == b'ALARM ACTIVATED':
    print('BEEP')
    with smtplib.SMTP_SSL("smtp.gmail.com", port, context=context) as server:
        server.login("progmikro18@gmail.com", password)    
        server.sendmail(sender_email, receiver_email, message)