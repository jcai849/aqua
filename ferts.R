#!/usr/bin/env Rscript

library(units)

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

fert_npk_prop <- set_units(vapply(solutes, function(x) NPK_prop(x$formula),
				  numeric(3)),
			   g/g)

target_weekly_tank_npk <- set_units(c(N=4.4, P=1.1, K=24), mg/kg)
V <- set_units(125, l)
mass_optimal_npk <- set_units(V * H2O$density * target_weekly_tank_npk, g)

volume_single_dose <- set_units(6, ml)
doses_per_week <- 3
volume_dose <- set_units(volume_single_dose * doses_per_week, ml)
volume_container <- set_units(500, ml)
mass_container_npk <- (volume_container / volume_dose) * mass_optimal_npk

mass_optimal_fert <- set_units(qr.coef(qr(fert_npk_prop), mass_container_npk), g)
conc_fert_container <- mass_optimal_fert / volume_container
solubility <-  do.call(c, lapply(solutes, '[[', "solubility"))
solubility_issue <- any(conc_fert_container > solubility)
minimum_dose <- volume_dose * max(conc_fert_container / solubility)
if (solubility_issue) stop(paste0("solubility issue: increase minimum dose to at least  ", format(minimum_dose)))
solution_npk <- 100 * (mass_container_npk / set_units(volume_container*H2O$density, g))

solvent_volume <- volume_container - sum(mass_optimal_fert / do.call(c, lapply(solutes, '[[', "density")))
solvent_weight <- set_units(solvent_volume * H2O$density, g)

title <- "Aquarium Fertiliser"
cat(title, '\n', paste0(rep('-', nchar(title)), collapse=''), '\n\n',
    "Solution NPK: ", paste(round(solution_npk, 1), collapse='-'), "\n",
    doses_per_week, " doses per week of ", format(volume_single_dose), " per dose\n",
    "targeting a weekly cumulative aquarium NPK of ", paste(round(target_weekly_tank_npk, 1), collapse='-'), '\n\n',
    "composition by weight:\n",
    "H2O: ", format(solvent_weight), '\n',
    paste(names(mass_optimal_fert), format(mass_optimal_fert), sep=":", collapse="\n"),
    "\n"
    ,sep='')
