#!/usr/bin/env python3

import textwrap
import pint

u = pint.UnitRegistry()
u.define('ppm = mg / kg')

molarmass_SodiumThiosulphate = 248.18*u.g/u.mol
density_SodiumThiosulphate = 1.667*u.g/u.cm**3
molarmass_Cl = 35.45 * u.g/u.mol
mass_fraction_Cl_in_tapwater = 2*u.ppm

volume_dose = 1*u.ml
volume_container = 500*u.ml
volume_waterchange = 100*u.mm * 300*u.mm * 800*u.mm

molarmass_ratio_SodiumThiosulphate_to_Cl = molarmass_SodiumThiosulphate / molarmass_Cl
# particle ratio 
particlenumber_ratio_SodiumThiosulphate_to_Cl = (1*u.mol/u.avogadro_constant) / (4*u.mol/u.avogadro_constant)
# 1 thiosulphate molecule neutralises 4 Chlorine molecules (Na2S2O3 + 4NaClO + H2O = H2SO4 + Na2SO4 + 4NaCl)
mass_ratio_SodiumThiosulphate_to_Cl = molarmass_ratio_SodiumThiosulphate_to_Cl * particlenumber_ratio_SodiumThiosulphate_to_Cl

mass_Cl_in_waterchange = mass_fraction_Cl_in_tapwater * volume_waterchange*u.water
mass_SodiumThiosulphate_in_waterchange = mass_ratio_SodiumThiosulphate_to_Cl * mass_Cl_in_waterchange
mass_SodiumThiosulphate_in_dose = mass_SodiumThiosulphate_in_waterchange

mass_SodiumThiosulphate_in_container = (volume_container / volume_dose) * mass_SodiumThiosulphate_in_dose
volume_SodiumThiosulphate_in_container = mass_SodiumThiosulphate_in_container / density_SodiumThiosulphate
volume_H2O_in_container = volume_container \
                                 - volume_SodiumThiosulphate_in_container
mass_H2O_in_container = volume_H2O_in_container*u.water
concentration_solution = mass_SodiumThiosulphate_in_container / (mass_SodiumThiosulphate_in_container + mass_H2O_in_container)

mass_SodiumThiosulphate_in_container.ito_base_units()
mass_H2O_in_container.ito_base_units()
volume_waterchange.ito("litres")
concentration_solution.ito('ppm')

title = f"{concentration_solution:.0f} Sodium Thiosulphate Dechlorinator Solution"
print(title)
print('-' * len(title), end="\n\n")
for line in textwrap.wrap(f"{volume_dose:~P} of solution dechlorinates {volume_waterchange:P~} of water with a Cl concentration of {mass_fraction_Cl_in_tapwater:P~}.", width=len(title)):
    print(line)
print('\n')
print("Constituents:")
print(f" o H2O:                 {mass_H2O_in_container:.2f#P~}")
print(f" o Sodium Thiosulphate: {mass_SodiumThiosulphate_in_container:.2f#P~}")
