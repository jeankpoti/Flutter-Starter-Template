Enable Wireless Debugging on Pixel 9 Pro:

1. Settings → Developer Options → Wireless debugging (toggle ON)
2. Pair device with pairing code → Note the IP address and pairing code
3. On your computer, run:

adb pair <IP_ADDRESS>:<PORT>

# Enter the pairing code when prompted

# Then connect wirelessly:

adb connect <IP_ADDRESS>:<PORT>

Alternative Method - USB First:

1. Connect via USB cable first
2. Enable wireless debugging on phone
3. Run: adb tcpip 5555
4. Disconnect USB and run: adb connect <PHONE_IP>:5555

Find Your Phone's IP:

- Settings → About phone → IP address
- Or Settings → Wi-Fi → Tap your network → Advanced
