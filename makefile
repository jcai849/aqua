nutrient-data:
	unzip "${@}.zip" -d "${@}"
nutrient-data.zip:
	curl https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_csv_%202019-04-02.zip -o "${@}"
