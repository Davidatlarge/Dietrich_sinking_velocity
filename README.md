Dietrich sinking velocity
================
David Kaiser
2018-11-19

Description
-----------

Calculates the sinking velocity of a particle in a fluid, in meters per second. By default uses formulas by [Dietrich (1982)](http://onlinelibrary.wiley.com/doi/10.1029/WR018i006p01615/abstract). The script was originally written to calculate the theoretical sinking velocity of microplastic particles with diameters &lt; 5 mm but &gt; 200 µm. This calculation was used e.g. by [Kowalski et al. (2016)](https://www.sciencedirect.com/science/article/pii/S0025326X16303848), because the commonly used Stokes formula overestimates sinking velocity for particles with diameters &gt; 200 µm. The formula by Dietrich considers effects of fluid denisty as well as particle density, size, shape and roundness. Alternatively, setting the argument *method* = "stokes" returns sinking velocity according to Stokes' Law [(see e.g. Glokzin et al. 2010)](https://www.sciencedirect.com/science/article/pii/S0304420314000097). This only considers water denisty and particle size and density, and thus considers all particles perfect spheres. If the particle diameter is &gt; 200 µm, a warning will be printed but the value will be returned nontheless. Additionally, setting *method* = "zhiyao" returns sinking velocity calculated after [Zhiyao et al. (2008)](https://www.sciencedirect.com/science/article/pii/S167423701530017X). This method does not require input of shape related variables, but Zhiyao et al. claim their formula is applicable to a wide range of particle shapes and sizes (with Reynolds numbers &lt; 2 x 10<sup>5</sup>). Using method = "ahrens" calculates sinking velocity according to a formula by [Ahrens (2000)](https://ascelibrary.org/doi/pdf/10.1061/(ASCE)0733-950X(2000)126%3A2(99)), which is a generalization of formulas by [Hallmeier (1981)](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1365-3091.1981.tb01948.x). Method = "komar" returns sinking velocity for ellipsoidal particles according to [Komar (1980)](http://www.journals.uchicago.edu/doi/10.1086/628510). Methods "dietrich" and "komar" require the input of a shape factor, with Corey shape factor preferred for "dietrich" and Janke's E factor for "komar" ([Dietrich 1982](http://onlinelibrary.wiley.com/doi/10.1029/WR018i006p01615/abstract), [Komar 1980](http://www.journals.uchicago.edu/doi/10.1086/628510)).

For non-spherical particles, the size/diameter can be expressed as equivalent spherical diameter (ESD) [(e.g. Kumar et al. 2010)](https://www.sciencedirect.com/science/article/pii/S0278434310003134).

The function only works when the density of the particle is higher than that of the fluid, i.e. when there is downward sinking. Otherwise the result is NaN and a warning will be printed.

The function requires the packages **marelac** and **seacarb** to be installed. Required functions are called directly without loading the packages. Water density is calculated from salinity and temperature, using the older [UNESCO](http://unesdoc.unesco.org/images/0005/000598/059832EB.pdf) calculation because it allows the use of practical salinity (instead of the less commonly recorded absolute salinity). Pressure for density calculation is calculated from depth and latitude. Latitude is also used to calculate gravity.

Arguments
---------

-   *salinity* -- practical salinity (unitless)
-   *temperature* -- in °C
-   *depth* -- in m
-   *latitude* -- in °N (negative for southern hemisphere)
-   *particle.density* -- in kg m<sup>-3</sup>
-   *particle.diameter* -- in m
-   *powers.p* = 6 -- [Powers](https://pubs.geoscienceworld.org/sepm/jsedres/article-abstract/23/2/117/112811/a-new-roundness-scale-for-sedimentary-particles?redirectedFrom=fulltext) roundness; defaults to 6 for perfectly round projected areas, including those of spheres
-   *shape.factor* = 1 -- [Corey Shape Factor](https://www.researchgate.net/publication/252625134_Settling_Velocities_of_Circular_Cylinders_at_Low_Reynolds_Numbers) or [Janke E](http://www.journals.uchicago.edu/doi/10.1086/628510); defaults to 1 for spheres
-   *method* = c("dietrich", "stokes", "zhiyao", "ahrens", "komar") -- method to calculate the sinking velocity, defaults to "dietrich"

Value
-----

A numeric value of the sinking velocity in m s<sup>-1</sup>

Examples
--------

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

Use Zhiyao et al. formula for the same case.

``` r
sinking.velocity.m.sec(salinity = 36, 
                        temperature = 20, 
                        depth = 0.2, 
                        latitude = 40, 
                        particle.density = 1050, 
                        particle.diameter = 0.0015,
                       method = "zhiyao")
```

    ## [1] 0.01104578

Use Ahrens formula to calculate the sinking velocity \[m s<sup>-1</sup>\] of a quartz grain (density is 2650 kg m<sup>-3</sup>) with a diameter of 0.4 mm, in deep temperate ocean water.

``` r
sinking.velocity.m.sec(salinity = 36, 
                        temperature = 20, 
                        depth = 2000, 
                        latitude = 40, 
                        particle.density = 2650, 
                        particle.diameter = 0.0004,
                        method = "ahrens")
```

    ## [1] 0.05230099

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
    ##  Use another method!

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
    ##  Use another method!

    ## Warning: Particle density (955) < water density (1026)! Particle will not
    ## sink! Returning NaN.

    ## [1] NaN
