#!/usr/bin/env python3

import pint
u = pint.UnitRegistry()
u.define('ppm = mg / L')

molarmass_SodiumThiosulphate = 248.18*u.g/u.mol
density_SodiumThiosulphate = 1.667*u.g/u.cm**3
molarmass_Cl = 35.45 * u.g/u.mol
mass_fraction_Cl_in_tapwater = 2*u.ppm

volume_syringe = 2*u.ml
volume_storagecontainer = 500*u.ml
volume_waterchange = 200*u.mm * 300*u.mm * 800*u.mm

molarmass_ratio_SodiumThiosulphate_to_Cl = molarmass_SodiumThiosulphate / molarmass_Cl
# particle ratio 
particlenumber_ratio_SodiumThiosulphate_to_Cl = (1*u.mol/u.avogadro_constant) / (4*u.mol/u.avogadro_constant)
# 1 thiosulphate molecule neutralises 4 Chlorine molecules (Na2S2O3 + 4NaClO + H2O = H2SO4 + Na2SO4 + 4NaCl)
mass_ratio_SodiumThiosulphate_to_Cl = molarmass_ratio_SodiumThiosulphate_to_Cl * particlenumber_ratio_SodiumThiosulphate_to_Cl

mass_Cl_in_waterchange = mass_fraction_Cl_in_tapwater * volume_waterchange
mass_SodiumThiosulphate_in_waterchange = mass_ratio_SodiumThiosulphate_to_Cl * mass_Cl_in_waterchange
mass_SodiumThiosulphate_in_syringe = mass_SodiumThiosulphate_in_waterchange

mass_SodiumThiosulphate_in_storagecontainer = (volume_storagecontainer / volume_syringe) * mass_SodiumThiosulphate_in_syringe
volume_SodiumThiosulphate_in_storagecontainer = mass_SodiumThiosulphate_in_storagecontainer / density_SodiumThiosulphate
volume_H2O_in_storagecontainer = volume_storagecontainer - volume_SodiumThiosulphate_in_storagecontainer
mass_H2O_in_storagecontainer = volume_H2O_in_storagecontainer*u.water

mass_SodiumThiosulphate_in_storagecontainer.ito_base_units()
mass_H2O_in_storagecontainer.ito_base_units()
print("Dechlorinator Solution")
print("----------------------\n")
print(f'{volume_syringe:~P} of solution dechlorinates {volume_waterchange.to("litres"):P~} of water with a Cl concentration of {mass_fraction_Cl_in_tapwater:P~}\n')
print("Constituents:")
print(f' o H2O:                 {mass_H2O_in_storagecontainer:.2f#P~}')
print(f' o Sodium Thiosulphate: {mass_SodiumThiosulphate_in_storagecontainer:.2f#P~}')
