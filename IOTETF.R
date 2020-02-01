iot<-getSymbols('SNSR', src='yahoo', from = "2018-1-01", to = Sys.Date())
iot10<-SMA(SNSR$SNSR.Close, 10)
iotetf<-cbind(iot10,SNSR$SNSR.Close)
dygraph(iotetf, main = 'IOT ETF') %>%
  dySeries('SMA', label = 'sma 10', color = 'blue') %>%
  dySeries('SNSR.Close', label ='close', color = 'black') %>%
  dyLimit(limit = 20, label = "StopLoss", strokePattern = "solid") %>%
  dyRangeSelector(height = 30)

