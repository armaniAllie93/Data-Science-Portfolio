#!/usr/bin/env python
# coding: utf-8

# In[13]:


import coinmetrics
import pandas as pd
import ta
import json
import math
import numpy as np
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import requests
import io
from datetime import date
import datetime


# In[32]:


cm = coinmetrics.Community()


# In[33]:


asset = "eth"


# In[34]:


available_data_types = cm.get_available_data_types_for_asset(asset)
available_data_types


# In[35]:


#Initiates current time
now = datetime.datetime.now()
#Converts to a timestamp unit
nowtime = now.timestamp()
#converts timestamp to date unit
today = date.today()
#For metric timeseries begin date
startDay = now - datetime.timedelta(days=600)
#converts to timestamp unit
starttimeML = startDay.timestamp()
#removes unnecessary decimal places
beginTimeML = math.floor(starttimeML)
#converts timestamp back to date unit
beginDate = date.fromtimestamp(beginTimeML)
print(beginDate,today)


# In[36]:


print(beginDate)


# In[89]:


#sets metric to obtain
metrics = "CapMrktCurUSD"
#method to obtain Market Cap
asset_data = cm.get_asset_metric_data(asset, metrics, beginDate, today)
#method from coinmetrics to convert object to pandas dataframe
pandasETH = coinmetrics.cm_to_pandas(asset_data)
#resets index and drops datetime index
pandasETH.reset_index(drop=True,inplace = True)
#converts column values into integers
pandasETH['CapMrktCurUSD'] = pandasETH['CapMrktCurUSD'].astype(int)
#locates the last row representing the current market cap
curr_cap = pandasETH['CapMrktCurUSD'].iloc[-1]
curr_cap


# In[90]:


curr_cap


# In[91]:


#sets metric to obtain
metrics1 = "TxTfrValAdjUSD"
#method to obtain Market Cap
TValue_data = cm.get_asset_metric_data(asset, metrics1, beginDate, today)
#method from coinmetrics to convert object to pandas dataframe
pandasTValue = coinmetrics.cm_to_pandas(TValue_data)
#resets index and drops datetime index
pandasTValue.reset_index(drop=True,inplace = True)
#converts column values into integers
pandasTValue['TxTfrValAdjUSD'] = pandasTValue['TxTfrValAdjUSD'].astype(int)
#selects last 90 days of transcation value
pandasTValue90 = pandasTValue['TxTfrValAdjUSD'].iloc[-90:]
#computes mean of 90 day to smooth out moving average
MA_TValue = pandasTValue90.mean()
#converts value to integer type
MA_TValue = int(MA_TValue)
MA_TValue


# In[92]:


NVT_signal = curr_cap/MA_TValue
NVT_signal


# In[88]:


#initiates email account
MY_ADDRESS = 'EMAIL'
PASSWORD = 'PASSWORD'
s = smtplib.SMTP(host='smtp.gmail.com', port=587)
s.starttls()
s.login(MY_ADDRESS, PASSWORD)

#initiates email sections
msg = MIMEMultipart()
msg['From']=MY_ADDRESS
msg['To']=MY_ADDRESS
msg['Subject']= "NVT Signal"


# In[93]:


NVT_signal = round(NVT_signal,2)
if NVT_signal < 45 or NVT_signal > 140:
    message = str("ETH " + " NVT Signal  " + str(NVT_signal))
    msg.attach(MIMEText(message, 'plain'))
    s.send_message(msg)


# In[ ]:




