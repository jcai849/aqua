#!/usr/bin/env Rscript

# Based heavily upon https://aquariumscience.org/index.php/5-5-3-4-cost-of-conditioners/

M_SodiumThiosulphate <- 248.18	# (1)
rho_SodiumThiosulphate <- 1.667	# (2)
Ar_Cl <- 35.45			# (3)
mol_neutr_ratio <- 4		# (4)
ppm_max_Cl <- 2			# (5)
L_bucket_vol <- 20		# (6)
mL_solution_per_bucket <- 2	# (7)
mL_solution <- 1000		# (8)

ppm_neutr_ratio <- (M_SodiumThiosulphate / Ar_Cl) / mol_neutr_ratio	# (9)
mg_Cl_per_bucket <- L_bucket_vol * ppm_max_Cl				# (10)
mg_SodiumThiosulphate_per_bucket <- mg_Cl_per_bucket * ppm_neutr_ratio	# (11)
ppm_SodiumThiosulphate_solution <- (1000 / mL_solution_per_bucket) *
                                   mg_SodiumThiosulphate_per_bucket	# (12)

g_SodiumThiosulphate_solution <- ppm_SodiumThiosulphate_solution / 1000	# (13)
mL_SodiumThiosulphate_solution <- g_SodiumThiosulphate_solution  / rho_SodiumThiosulphate # (14)
mL_H20_solution <- mL_solution - mL_SodiumThiosulphate_solution		# (15)

# (1) Molar mass
# (2) Density (g/cm^3)
# (3) Atomic Weight
# (4) 1 molecule Sodium Thiosulphate neutralises 4 molecules Chlorine
#     (Na_2S_2O_3 + 4NaClO + H_2O = H_2SO_4 + Na_2SO_4 + 4NaCl)
# (5) rounded max 2ppm Cl in AKL water as per
#     https://wslpwstoreprd.blob.core.windows.net/kentico-media-libraries-prod/watercarepublicweb/media/watercare-media-library/reports-and-publications/watercare_waterquality_report_2020_21.pdf
# (6) bucket volume (L)
# (7) mL of neutralisation solution to be added per bucket of tap
#     water
# (8) mL of neutralisation solution to be made
# (9) ppm Sodium Thiosulphate to neutralise 1ppm chlorine
# (10) mg Cl per bucket of tap water
# (11) mg of Sodium Thiosulphate needed to neutralise one bucket
#      of tap water
# (12) ppm Sodium Thiosulphate required in the neutralisation
#      solution - check this - may differ due to density of Sodium
#      Thiosulphate not same as water
# (13) g Sodium Thiosulphate to be added as the solute to the
#      neutralisation solution
# (14) mL Sodium Thiosulphate to be added as the solute to the
#      neutralisation solution
# (15) mL distilled water (H20) to form the solvent of the solution

cat("Neutralising Solution Parameters", "\n", "================================", "\n", sep="")
cat("Mass fraction of Sodium Thiosulphate:", ppm_SodiumThiosulphate_solution, "ppm", "\n")
cat("Mass of Sodium Thiosulphate:", g_SodiumThiosulphate_solution, "g", "\n")
cat("Volume of H_2O:", mL_H20_solution, "mL", "\n")
cat("Total Volume of solution:", mL_solution, "mL", "\n")
cat("\n")

cat("Usage", "\n", "======", "\n", sep="")
cat("Expected Cl in tap water:", ppm_max_Cl, "ppm", "\n")
cat("Volume of solution per", L_bucket_vol, "L bucket:", mL_solution_per_bucket, "\n")
