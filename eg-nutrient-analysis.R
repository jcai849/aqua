shrimp <- foods["shrimp"][[1]]
spinach <- foods["spinach"][[1]]
spirulina <- foods["spirulina"][[1]]

fish_food <- 100*shrimp + 20*spinach + 30*spirulina 

energy(fish_food)
sum(energy(fish_food))

############

foods <- structure(new.env(parent=emptyenv()), class="Foods")
assign(foods, read.csv("..."))
assign(foods, read.csv("..."))
assign(foods, read.csv("..."))

`[.Foods` <- function(x, i) {
	lapply(with(x, name_tab[grepl(i, name_tab)]),
	       food_info)
}

food_info <- function(name) {
	#merge, merge, merge,
	#return Food(name, weight=1, nutrients=named double of nutrient weights)
}
Food <- function(names, weights, nutrients) {
	stopifnot(is.character(names),
		  is.numeric(weights), is.numeric(nutrients))
	structure(nutrients,
		  class="Food", FoodNames=names, FoodWeights=weights)
}
is.Food <- function(x) inherits(x, "Food")
`*.Food` <- function(e1, e2) {
	e2$weight <- e1 * e2$weight
}
`+.Food` <- function(e1, e2) {
	stopifnot(is.Food(e1), is.Food(e2))
	nutrients <- union(names(e1), names(e2)) etc...
	Food(c(e1$name, e2$name), c(e1$weight, e2$weight), nutrients)
}
print.Food <- function(x, ...) {
# shrimp (100g), spirulina (30g), spinach (20g)
# carbohydrates: 23g
#...
}

energy <- function(x) {
	# merge with Foods table
	# named double of energies from nutrients
}
