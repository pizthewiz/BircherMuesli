
# Bircher Muesli
a quartz composer patch for the discovery of, reading from and writing to serial devices.

### HOW TO INSTALL
move BircherMuesli.plugin into ~/Library/Graphics/Quartz Composer Plug-Ins/

### NOTES
- _device hot plugging can lead to a race condition somewhere, instead it is suggested that you stop the composition, plug, then start_
- the Serial Reader internally uses \n as the break string
- the Serial Devices subpatch vends callout (/dev/cu.\*) devices, not the callin (/dev/tty.\*) half

### THANKS
- Andreas Mayer / Nick Zitzmann / Sean McBride for [AMSerialPort](https://github.com/pizthewiz/AMSerialPort/)
- Anton Marini (vade) for pointing me to AMSerialPort
- dang&#96;r&#96;us for javascript patch help
