#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(units))

mass_proportion <- function(compound, element) {
    mp <- (atomic_weights[element] * compound[element]) /
		sum(atomic_weights[names(compound)] * compound)
    mp[is.na(mp)] <- 0
    set_units(mp, g/g)
}

atomic_weights_df <- read.csv("atomic-weights.csv", check.names=F)
atomic_weights <- atomic_weights_df$`Abridged standard atomic weight`
names(atomic_weights) <- atomic_weights_df$Symbol

npk_base_compounds <- list(N=c(N=1), P=c(P=2,O=5), K=c(K=2,O=1))
npk_multiplier <- mapply(mass_proportion, npk_base_compounds, names(npk_base_compounds), USE.NAMES=FALSE)

# TODO: query pubchem to automate this
solutes <- list(KNO3 = list(formula=c(K=1,N=1,O=3),
			  solubility=set_units(35, g/dl),
			  density=set_units(2.1, g/cm^3)),
	      KH2PO4 = list(formula=c(K=1,H=2,P=1,O=4),
			    solubility=set_units(18, g/dl),
			    density=set_units(2.34, g/cm^3)),
	      K2SO4 = list(formula=c(K=2,S=1,O=4),
			   solubility=set_units(12, g/dl),
			   density=set_units(2.66, g/cm^3)))
H2O <- list(formula=c(H=2,O=1),
	    solubility=set_units(Inf, g/dl),
	    density=set_units(998.2071, kg/m^3))

NPK_prop <- function(compound)
	mass_proportion(compound, c("N", "P", "K")) / npk_multiplier

volume_aquarium <- set_units(125, l)

fert_npk_prop <- set_units(vapply(solutes, function(x) NPK_prop(x$formula),
				  numeric(3)),
			   g/g)

target_cumulative_tank_npk <- set_units(c(N=4.4, P=1.1, K=24), ppm/week) # ppm = mg/kg; values from https://aquariumscience.org/index.php/15-5-3-estimative-index/ (in turn from Tom Barr)
optimal_cumulative_tank_npk <- set_units(volume_aquarium * H2O$density * target_cumulative_tank_npk, g/week)
names(optimal_cumulative_tank_npk) <- names(target_cumulative_tank_npk)
optimal_cumulative_tank_fert <- set_units(qr.coef(qr(fert_npk_prop), optimal_cumulative_tank_npk), g/week)

volume_dose <- set_units(7, ml)
dosage_rate <- set_units(3, week^-1)
volume_container <- set_units(500, ml)
npk_per_dose <- optimal_cumulative_tank_npk / dosage_rate
ferts_per_dose <- optimal_cumulative_tank_fert / dosage_rate

mass_container_npk <- (volume_container / volume_dose) * npk_per_dose
mass_container_fert <- (volume_container / volume_dose) * ferts_per_dose

solute_density <- do.call(c, lapply(solutes, '[[', "density"))
volume_solvent <- volume_container - sum(mass_container_fert / solute_density)
mass_solvent <- set_units(volume_solvent * H2O$density, g)
names(mass_solvent) <- "H2O"

conc_solution <- mass_container_fert / volume_solvent
solute_solubility <-  do.call(c, lapply(solutes, '[[', "solubility"))
solubility_issue <- any(conc_solution > solute_solubility)
minimum_dose <- volume_dose * max(conc_solution / solute_solubility)
if (solubility_issue) stop(paste0("solubility issue: increase minimum dose to at least  ", format(minimum_dose)))

solution_npk <- set_units(mass_container_npk / set_units(volume_container*H2O$density, g), percent)
names(solution_npk) <- names(mass_container_npk)

pr <- function(x) paste(capture.output(print(x)), collapse='\n')
title <- "Aquarium Fertiliser"
cat(title, '\n', paste0(rep('-', nchar(title)), collapse=''), '\n\n',
    "Providing cumulative aquarium values* of\n", pr(target_cumulative_tank_npk), '\n',
    "For aquarium volume of ", format(volume_aquarium), "\n",
    "At the dosage rate of ", format(dosage_rate), '\n\n',
    "Solutes per dose:\n", pr(round(ferts_per_dose, 3)), '\n\n',
    "Solution NPK*:\n", pr(round(solution_npk, 1)), '\n',
    format(volume_dose), " per dose\n",
    "Solution composition by weight:\n",
    pr(round(c(mass_solvent, mass_container_fert), 3)), "\n\n",
    "*Using standard fertilizer NPK labelling\n"
    ,sep='')
