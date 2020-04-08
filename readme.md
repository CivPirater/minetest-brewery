# Minetest Brewery Mod

This repo is the main home of the Brewery Mod for the Minetest game.

If you need anything contact Pirater or Metriximor as the main maintainers of the project.

## Ideas

|Idea|Status|
|:---:|:---:|
|Medicinal Alcohol| Not started|
|Desinfectant|Not started|

## How it works

### Fermenter

* A **fermenter** is an enclosed and sterilised vessel that maintains optimal conditions for the growth of a **microorganism**.[[1]](https://ib.bioninja.com.au/options/untitled/b1-microbiology-organisms/fermenters.html)

* **Microorganisms/Yeasts** are responsible for breaking down the sugars present in a beverage and converting them into ethanol and carbon dioxide.[[2]](https://en.wikipedia.org/wiki/Fermentation_in_winemaking)

#### Growth of Microorganisms/Yeast

![Growth of Microorganisms](/wiki/microorganism_growth.png)

In a barrel, yeast consumes the sugars present, as they do it, they expend the available sugars which makes them eventually reach a decaying point. What this means for any fermenting process is that there is a point in which there will be a diminishing return for fermenting a beverage.

![Alcohol Percentage](/wiki/alcohol_percentage.png)

* Red Line -> Percentage of Alcohol in drink.(Normalized)
* Blue line -> Concentration of Yeast/Microorganisms present in the beverage.

The function of the concentration of microorganisms is:

![1/(1+e^(-a(x-b)))+1/(1+e^(c(x-d)))-1](/wiki/microorganism_growth_function.png)

The function for the quantity of alcohol is:

![-ln(e^(c*d-c*x)+1)/c+ln(e^(a*x)+e^(a*b))/a-x+(d-b))](/wiki/alcohol_percentage_function.png)

Where:

* x is the time that has passed. *(in minutes)*
* a is the growth rate for the exponential phase.
  * is between 2 and 7
* b is the duration of the lag phase
  * is between 1/2 and 5
* c is the death rate for the death phase.
  * c is atleast a/3
* d is the duration of the stationary phase.
  * d is atleast 2/b+2b

The variables a, b, c and d depend on the used microorganism.
Microorganisms depend on a variety of environmental factors such as humidity, temperature and geographical location.

In theory, the perfect microorganism would have a positive infinite a,c and d values(a for instanteous growth, c for instantaneous death) and a 0 b(for no lag phase).
The value d depends entirely of the quantity of sugar present in the beverage.(e.g. If there's )

### Barrel

Barrel aging is extremely important. It is barrel aging that allows a beverage to mature and grow it's flavor so that it's not dry.

### LONKS

<https://www.masterclass.com/articles/wine-101-what-is-barrel-aging-understanding-the-barrel-aging-process-in-winemaking-and-the-difference-between-steel-and-oak-barrels#what-do-wines-aged-in-new-oak-taste-like>

<https://guide.michelin.com/en/article/dining-out/5-things-you-need-to-know-about-barrel-aging>

<https://en.wikipedia.org/wiki/Aging_of_wine>

<https://www.shakestir.com/features/id/551/science-of-barrel-agingScience>

## License

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
