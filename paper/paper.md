---
title: 'PsychroLib: a library of psychrometric functions to calculate thermodynamic properties of air'
tags:
  - Python
  - Fortran
  - C
  - JavaScript
  - Excel
  - VBA
  - Thermodynamic
  - Engineering
  - Meteorology
  - HVAC
authors:
  - name: D. Meyer
    orcid: 0000-0002-7071-7547
    affiliation: 1
  - name: D. Thevenard
    orcid: 0000-0002-0749-6841
    affiliation: 2
affiliations:
 - name: Department of Meteorology, University of Reading, Reading, UK
   index: 1
 - name: Canadian Solar, Guelph, Canada
   index: 2
date: 30 November 2018
bibliography: paper.bib
---

# Summary

![Relationships of common functions as implemented in PsychroLib. Bold arrows show the relationship between function involving a direct call while light arrow show the relationship between two or more. For a complete list of functions available in PsychroLib, see the README file in the project’s repository.](psychrolib_relationships.pdf){ width=90% }


The estimation of psychrometric properties of air is critical in several engineering and scientific applications such as heating, ventilation, and air conditioning (HVAC) and meteorology. Although formulae to calculate the psychrometric properties of air are widely available in the literature [@Stull2011; @Wexler1983; @Stoecker1982; @Dilley1968; @Humphreys1920], their implementation in computer programs or spreadsheets can be challenging and time consuming. To our knowledge, only few numerical implementations of such formulae are freely available as standalone software libraries for programming languages and spreadsheets used in science and engineering.


Here, we present PsychroLib, a common set of psychrometric software libraries, aimed at improving scientific reproducibility, reducing the likelihood of software errors, and saving time to scientists and engineers when developing software and working with psychrometric calculations. PsychroLib is a free and open-source psychrometric library, currently based on formulae from the ASHRAE Handbook Fundamentals [@Ashrae2017_IP; @Ashrae2017_SI] for both imperial (IP) and metric (SI) systems of units. It includes common functions for estimating dry, moist, saturated properties of air, and standard atmosphere, such as converting between \mbox{dry-,} wet-, dew-point temperature, relative humidity, humidity ratio and vapour pressure (Figure 1).


PsychroLib is available for Python, C, Fortran, JavaScript, and Microsoft Excel Visual Basic for Applications (VBA). It is developed with a common application programming interface (API) across all the supported languages. All functions have been unit tested with a combination of manual and automated tests against standard ASHRAE reference tables or third-party implementations. PsychroLib is available on GitHub at https://github.com/psychrometrics/psychrolib and released under the MIT licence. We strongly encourage users to provide feedback, bug reports and feature requests, through the GitHub’s issue system at https://github.com/psychrometrics/psychrolib/issues.


# References
