
HOW TO INSTALL
move BircherMuesli.plugin into ~/Library/Graphics/Quartz Composer Plug-Ins/

THANKS
- Andreas Mayer / Nick Zitzmann / Sean McBride for AMSerialPort
- Anton Marini (vade) for pointing me to AMSerialPort
- dang`r`us for javascript patch help

NOTES
- device hot plugging can be *problematic*, instead stop the composition, plug, then start

- the Serial Devices subpatch vends callout (/dev/cu.*) devices, not the callin (/dev/tty.*) half

- the Serial Reader internally uses \n as the break string
