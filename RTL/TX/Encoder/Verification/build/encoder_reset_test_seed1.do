onerror {quit -f -code 2}
onbreak {quit -f -code 0}
coverage save -onexit {D:/Documents/Serial-Link-PHY-GP/RTL/TX/Encoder/Verification/build/encoder_reset_test_seed1.ucdb}
run -all
quit -f -code 0
