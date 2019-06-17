# MappingBlackIncome
Dynamically Mapping Black Household Income 

This app accepts a State and County argument (county derived conditionally on the state selection) and pings the US Census TIGRIS API to get the census tract shapefiles of the selected State and County. Note: Some states and/or counties may have corruput files (California being one, unfortunately). 

For each census tract, the median income class is derived into one of five groups: 

- Under 15k a year
- 15 - 40k 
- 40 - 75k 
- 75k - 125k 
- 125k + 

and a map is shown detailing the number of black households in the census tract, the median income class of black households in the census tract, and the number of "high income" (75k + ) black households. 

The inspiration for this application is pro bono work I am performing for the non-profit collective bb:ARR. 
