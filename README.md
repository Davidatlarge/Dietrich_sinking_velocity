sinking velocity
================
David Kaiser
2018-02-23

Description
-----------

Calculates the sinking velocity of a particle in a fluid. By default uses formulas by [Dietrich (1982)](http://onlinelibrary.wiley.com/doi/10.1029/WR018i006p01615/abstract). The script was originally written to calculate the theoretical sinking velocity of microplastic particles with diameters &lt; 5 mm but &gt; 200 µm. This calculation was used e.g. by [Kowalski et al. (2016)](https://www.sciencedirect.com/science/article/pii/S0025326X16303848), because the commonly used Stokes formula overestimates sinking velocity for particles with diameters &gt; 200 µm. The formula by Dietrich considers effects of fluid denisty as well as particle density, size, shape and roundness. Alternatively, setting the argument *method* = "stokes", returns sinking velocity according to Stokes' Law [(see e.g. Glokzin et al. 2010)](https://www.sciencedirect.com/science/article/pii/S0304420314000097). This only considers water denisty and particle size and density, and thus considers all particles perfect spheres. If the particle diameter is &gt; 200 µm, a warning will be printed but the value will be returned nontheless.

For non-spherical particles, the size/diameter can be expressed as equivalent spherical diameter (ESD) [(e.g. Kumar et al. 2010)](https://www.sciencedirect.com/science/article/pii/S0278434310003134).

The function only works when the density of the particle is higher than that of the fluid, i.e. when there is downward sinking. Otherwise the result is NaN and a warning will be printed.

The function requires the package **marelac** to be installed. The package is loaded by the function with a call to library(). Water density is calculated from salinity and temperature, using the older [UNESCO](http://unesdoc.unesco.org/images/0005/000598/059832EB.pdf) calculation because it allows the use of practical salinity (instead of the less commonly recorded absolute salinity). Pressure for density calculation is calculated from depth and latitude. Latitude is also used to calculate gravity.

Arguments
---------

-   *salinity* -- practical salinity (unitless)
-   *temperature* -- in °C
-   *depth* -- in m
-   *latitude* -- in °N (negative for southern hemisphere)
-   *particle.density* -- in kg m<sup>-3</sup>
-   *particle.diameter* -- in m
-   *powers.p* = 6 -- [Powers](https://pubs.geoscienceworld.org/sepm/jsedres/article-abstract/23/2/117/112811/a-new-roundness-scale-for-sedimentary-particles?redirectedFrom=fulltext) roundness; defaults to 6 for perfectly round projected areas, including those of spheres
-   *CSF* = 1 -- [Corey Shape Factor](https://www.researchgate.net/publication/252625134_Settling_Velocities_of_Circular_Cylinders_at_Low_Reynolds_Numbers); defaults to 1 for spheres
-   *method* = c("dietrich", "stokes") -- method to calculate the sinking velocity, defaults to "dietrich"

Value
-----

A numeric value of the sinking velocity in m s<sup>-1</sup>

Example
-------

Use Dietrich formula to calculate the sinking velocity \[m s<sup>-1</sup>\] for a polystyrene sphere (density is 1050 kg m<sup>-3</sup>) with a diameter of 1.5 mm, in temperate ocean surface water.

``` r
sinking.velocity.m.sec(salinity = 36, 
                        temperature = 20, 
                        depth = 0.2, 
                        latitude = 40, 
                        particle.density = 1050, 
                        particle.diameter = 0.0015)
```

    ## [1] 0.01192481

Use Stokes formula to calculate the sinking velocity \[m s<sup>-1</sup>\] for a polystyrene sphere (density is 1050 kg m<sup>-3</sup>) with a diameter of 1.5 mm, in temperate ocean surface water. Prints a warning but also returns the value.

``` r
sinking.velocity.m.sec(salinity = 36, 
                        temperature = 20, 
                        depth = 0.2, 
                        latitude = 40, 
                        particle.density = 1050, 
                        particle.diameter = 0.0015,
                        method = "stokes")
```

    ## Warning: Particle diameter > 200 Âµm! 
    ##  Stokes' Law will overestimate sinking velocity! 
    ##  Use default method = "dietrich"!

    ## [1] 0.02761736

Sinking velocity cannot be calculated for particles with lower density than the fluid, e.g. polyethylene in temperate ocean surface water.

``` r
sinking.velocity.m.sec(salinity = 36, 
                        temperature = 20, 
                        depth = 0.2, 
                        latitude = 40, 
                        particle.density = 955, 
                        particle.diameter = 0.0015,
                        method = "stokes")
```

    ## Warning: Particle diameter > 200 Âµm! 
    ##  Stokes' Law will overestimate sinking velocity! 
    ##  Use default method = "dietrich"!

    ## Warning: Particle density (955) < water density (1026)! Particle will not
    ## sink! Returning NaN.

    ## [1] NaN
