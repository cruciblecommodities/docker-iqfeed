#!/usr/bin/env sh

# first set some reg settings
wine64 reg add HKEY_CURRENT_USER\\\Software\\\DTN\\\IQFeed\\\Startup /t REG_DWORD /v LogLevel /d $IQFEED_LOG_LEVEL /f && \
wine64 reg add HKEY_CURRENT_USER\\\Software\\\DTN\\\IQFeed\\\Startup /v AutoConnect /d 1 /f && \
wine64 reg add HKEY_CURRENT_USER\\\Software\\\DTN\\\IQFeed\\\Startup /v Login /d $IQFEED_LOGIN /f && \
wine64 reg add HKEY_CURRENT_USER\\\Software\\\DTN\\\IQFeed\\\Startup /v Password /d $IQFEED_PASSWORD /f && \
wine64 reg add HKEY_CURRENT_USER\\\Software\\\DTN\\\IQFeed\\\Startup /v SaveLoginPassword /d 1 /f && \
wineserver --wait

# then run iqfeed
savelog -l -n -c 7 /root/DTN/IQFeed/wine.log && \
wine64 /root/.wine/drive_c/Program\ Files/DTN/IQFeed/iqconnect.exe \
    -product $IQFEED_PRODUCT_ID \
    -version IQFEED_LAUNCHER \
    -login $IQFEED_LOGIN \
    -password $IQFEED_PASSWORD \
    -autoconnect -savelogininfo 2>&1 | tee -a /root/DTN/IQFeed/wine.log
